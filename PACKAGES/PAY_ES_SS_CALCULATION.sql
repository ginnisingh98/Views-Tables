--------------------------------------------------------
--  DDL for Package PAY_ES_SS_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_SS_CALCULATION" AUTHID CURRENT_USER as
/* $Header: pyesssdc.pkh 120.4 2005/08/08 07:16:25 grchandr noship $ */
--
FUNCTION get_assignment_info(p_assignment_id       IN  NUMBER
                            ,p_effective_date      IN  DATE
                            ,p_Contribution_grp    OUT NOCOPY VARCHAR2
                            ,p_work_center         OUT NOCOPY NUMBER
                            ,p_35_yrs_ss           OUT NOCOPY VARCHAR2
                            ,p_seniority_yrs       OUT NOCOPY NUMBER
                            ,p_date                IN  DATE) RETURN NUMBER;
--
FUNCTION get_absence_days(p_assignment_id     IN NUMBER
                         ,p_business_group_id IN NUMBER
                         ,p_effective_date    IN DATE
                         ,p_period_start_date IN DATE
                         ,p_period_end_date   IN DATE
                         ,p_leave_type        IN VARCHAR2
                         ,p_work_pattern      IN VARCHAR2) RETURN NUMBER;
--
FUNCTION get_absence_Hours(p_assignment_id     IN NUMBER
                          ,p_business_group_id IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_period_start_date IN DATE
                          ,p_period_end_date   IN DATE
                          ,p_leave_type        IN VARCHAR2) RETURN NUMBER;
--
FUNCTION get_working_time(p_assignment_id     IN NUMBER
                         ,p_business_group_id IN NUMBER
                         ,p_period_start_date IN DATE
                         ,p_period_end_date   IN DATE
                         ,p_working_days      OUT NOCOPY NUMBER
                         ,p_working_hours     OUT NOCOPY NUMBER) RETURN NUMBER;
--
FUNCTION get_work_center_info(p_business_gr_id      IN  NUMBER
                             ,p_work_center         IN  NUMBER
                             ,p_info1               OUT NOCOPY VARCHAR2
                             ,p_info2               OUT NOCOPY VARCHAR2
                             ,p_info3               OUT NOCOPY VARCHAR2
                             ,p_info4               OUT NOCOPY VARCHAR2
                             ,p_info5               OUT NOCOPY VARCHAR2
                             ,p_info6               OUT NOCOPY VARCHAR2
                             ,p_info7               OUT NOCOPY VARCHAR2
                             ,p_info8               OUT NOCOPY VARCHAR2
                             ,p_info9               OUT NOCOPY VARCHAR2
                             ,p_info10              OUT NOCOPY VARCHAR2) RETURN NUMBER;
--
FUNCTION get_legal_employer_info(p_business_gr_id       IN  NUMBER
                                ,p_effective_date       IN  DATE
                                ,p_assignment_id        IN  NUMBER
                                ,p_work_center          IN  NUMBER
                                ,p_period_start_date    IN  DATE
                                ,p_period_end_date      IN  DATE
                                ,p_ss_type              IN  VARCHAR2
                                ,p_td_flag              OUT NOCOPY VARCHAR2
                                ,p_td_rebate_days       OUT NOCOPY NUMBER
                                ,p_le_td_perc           OUT NOCOPY NUMBER
                                ,p_ss_td_perc           OUT NOCOPY NUMBER
                                ,p_exempt_flag          OUT NOCOPY VARCHAR2
                                ,p_exempt_days          OUT NOCOPY NUMBER
                                ,p_le_exempt_perc       OUT NOCOPY NUMBER
                                ,p_emp_exempt_perc      OUT NOCOPY NUMBER
                                ,p_tot_days             IN  NUMBER
                                ,p_contract_type        IN  VARCHAR2) RETURN NUMBER;
--
FUNCTION get_trng_hours(p_business_gr_id       IN  NUMBER
                       ,p_assignment_id        IN  NUMBER
                       ,p_effective_date       IN  DATE
                       ,p_in_class_trng_hours  OUT NOCOPY NUMBER
                       ,p_remote_trng_hours    OUT NOCOPY NUMBER) RETURN NUMBER;
--
FUNCTION get_defined_bal_id(p_bal_name         IN  VARCHAR2
                           ,p_db_item_suffix   IN  VARCHAR2) RETURN NUMBER;
--
FUNCTION get_prev_salary(p_assignment_action_id   IN NUMBER
                        ,p_balance_name           IN VARCHAR2
                        ,p_database_item_suffix   IN VARCHAR2
                        ,p_period_start_date      IN DATE
                        ,p_no_month               IN NUMBER
                        ,p_flag                   IN VARCHAR2
                        ,p_context                IN VARCHAR2
                        ,p_context_val            IN VARCHAR2
                        ,p_days                   IN OUT NOCOPY NUMBER) RETURN NUMBER;
--
FUNCTION get_row_value(p_effective_date IN DATE
                      ,p_reduction_id   IN VARCHAR2
                      ,p_duration       IN NUMBER) RETURN VARCHAR2;
--
FUNCTION get_input_value(p_assignment_id            IN  NUMBER
                        ,p_effective_date           IN  DATE
                        ,p_no_ptm_days              OUT NOCOPY NUMBER
                        ,p_no_ptm_hours             OUT NOCOPY NUMBER
                        ,p_no_partial_strike_days   OUT NOCOPY NUMBER
                        ,p_no_partial_strike_hours  OUT NOCOPY NUMBER
                        ,p_active_without_pay_days  OUT NOCOPY NUMBER
                        ,p_active_without_pay_hours OUT NOCOPY NUMBER
                        ,p_rec_start_date           IN  DATE
                        ,p_rec_end_date             IN  DATE
                        ,p_cac                      IN  VARCHAR2
                        ,p_epigraph_code            IN  VARCHAR2
                        ,p_period_end_date          IN  DATE) RETURN NUMBER;
--
FUNCTION get_table_value(bus_group_id    IN NUMBER
                        ,ptab_name       IN VARCHAR2
                        ,pcol_name       IN VARCHAR2
                        ,prow_value      IN VARCHAR2
                        ,peffective_date IN DATE )RETURN NUMBER;
--
FUNCTION get_org_context_info(p_assignment_id       IN  NUMBER
                             ,p_business_group_id   IN  NUMBER
                             ,p_work_center         IN  NUMBER
                             ,p_context             IN  VARCHAR2
                             ,p_period_start_date   IN  DATE
                             ,p_period_end_date     IN  DATE
                             ,p_tot_days             IN  NUMBER
                             ,p_contract_type        IN  VARCHAR2) RETURN NUMBER;
--
FUNCTION write_cac_epigraph_chg_table(p_assignment_id      NUMBER
                                     ,p_effective_date     DATE
                                     ,p_business_group_id  NUMBER
                                     ,p_period_start_date  DATE
                                     ,p_period_end_date    DATE
                                     ,p_contract_type      VARCHAR2
                                     ,p_hire_date          DATE
                                     ,p_end_date           DATE) RETURN NUMBER;
--
FUNCTION read_cac_epigraph_chg_table(p_assignment_id            IN NUMBER
                                    ,p_cac                      IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph                 IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph_114             IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph_126             IN OUT NOCOPY VARCHAR2
                                    ,p_days                     IN OUT NOCOPY NUMBER
                                    ,p_start_date               IN OUT NOCOPY DATE
                                    ,p_end_date                 IN OUT NOCOPY DATE
                                    ,p_no_ptm_days              IN OUT NOCOPY NUMBER
                                    ,p_no_ptm_hours             IN OUT NOCOPY NUMBER
                                    ,p_no_partial_strike_days   IN OUT NOCOPY NUMBER
                                    ,p_no_partial_strike_hours  IN OUT NOCOPY NUMBER
                                    ,p_active_without_pay_days  IN OUT NOCOPY NUMBER
                                    ,p_active_without_pay_hours IN OUT NOCOPY NUMBER
                                    ,p_curr_index               IN OUT NOCOPY NUMBER
                                    ,p_next_epigraph            IN OUT NOCOPY VARCHAR2
                                    ,p_next_cac                 IN OUT NOCOPY VARCHAR2
                                    ,p_days_worked              IN OUT NOCOPY NUMBER
                                    ,p_td_days                  IN OUT NOCOPY NUMBER
                                    ,p_tot_days                 IN OUT NOCOPY NUMBER
                                    ,p_pu_days                  IN OUT NOCOPY NUMBER) RETURN NUMBER;
--
FUNCTION read_table_index_values(p_assignment_id            IN NUMBER
                                ,p_index                    IN NUMBER
                                ,p_cac                      IN OUT NOCOPY VARCHAR2
                                ,p_epigraph                 IN OUT NOCOPY VARCHAR2
                                ,p_epigraph_114             IN OUT NOCOPY VARCHAR2
                                ,p_epigraph_126             IN OUT NOCOPY VARCHAR2
                                ,p_days                     IN OUT NOCOPY NUMBER
                                ,p_start_date               IN OUT NOCOPY DATE
                                ,p_end_date                 IN OUT NOCOPY DATE
                                ,p_no_ptm_days              IN OUT NOCOPY NUMBER
                                ,p_no_ptm_hours             IN OUT NOCOPY NUMBER
                                ,p_no_partial_strike_days   IN OUT NOCOPY NUMBER
                                ,p_no_partial_strike_hours  IN OUT NOCOPY NUMBER
                                ,p_active_without_pay_days  IN OUT NOCOPY NUMBER
                                ,p_active_without_pay_hours IN OUT NOCOPY NUMBER
                                ,p_days_worked              IN OUT NOCOPY NUMBER
                                ,p_td_days                  IN OUT NOCOPY NUMBER
                                ,p_tot_days                 IN OUT NOCOPY NUMBER
                                ,p_pu_days                  IN OUT NOCOPY NUMBER) RETURN NUMBER;
--
FUNCTION read_table_index(p_next_epigraph            IN OUT NOCOPY VARCHAR2
                         ,p_next_cac                 IN OUT NOCOPY VARCHAR2) RETURN NUMBER;
--
FUNCTION get_prev_base(p_assignment_action_id   IN NUMBER
                      ,p_balance_name           IN VARCHAR2
                      ,p_database_item_suffix   IN VARCHAR2
                      ,p_period_start_date      IN DATE
                      ,p_no_month               IN NUMBER
                      ,p_flag                   IN VARCHAR2
                      ,p_context                IN VARCHAR2
                      ,p_context_val            IN VARCHAR2
                      ,p_ss_days                IN OUT NOCOPY NUMBER
                      ,p_days                   IN OUT NOCOPY NUMBER) RETURN NUMBER;
--
END pay_es_ss_calculation;

 

/
