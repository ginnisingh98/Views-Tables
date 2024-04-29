--------------------------------------------------------
--  DDL for Package PAY_ES_TWR_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_TWR_CALC_PKG" AUTHID CURRENT_USER AS
/* $Header: pyestwrc.pkh 120.3 2005/07/20 04:08:24 grchandr noship $ */
--
    TYPE XMLRec IS RECORD(
    TagName VARCHAR2(240),
    TagValue VARCHAR2(240));
    TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
    vXMLTable tXMLTable;
    vCtr NUMBER;
    --
    FUNCTION get_payment_key(passignment_id  NUMBER
                            ,peffective_date DATE ) RETURN VARCHAR2;
    --
    FUNCTION get_no_contacts(passignment_id               IN NUMBER
                        ,pbusiness_gr_id                  IN NUMBER
                        ,peffective_date                  IN DATE
                        ,pno_descendant                   OUT NOCOPY NUMBER
                        ,pno_descendant_less_3            OUT NOCOPY NUMBER
                        ,pno_descendant_bet_3_25          OUT NOCOPY NUMBER
                        ,pno_desc_disability_33_64        OUT NOCOPY NUMBER
                        ,pno_desc_disability_gr_65        OUT NOCOPY NUMBER
                        ,pno_desc_reduced_mobility        OUT NOCOPY NUMBER
                        ,pno_desc_single_parent           OUT NOCOPY NUMBER
                        ,pno_ascendant                    OUT NOCOPY NUMBER
                        ,pno_ascendant_gr_75              OUT NOCOPY NUMBER
                        ,pno_asc_disability_33_64         OUT NOCOPY NUMBER
                        ,pno_asc_disability_gr_65         OUT NOCOPY NUMBER
                        ,pno_asc_reduced_mobility         OUT NOCOPY NUMBER
                        ,pno_asc_single_descendant        OUT NOCOPY NUMBER
                        ,pdescendant_dis_amt              OUT NOCOPY NUMBER
                        ,pdescendant_sp_assistance_amt    OUT NOCOPY NUMBER
                        ,pascendant_dis_amt               OUT NOCOPY NUMBER
                        ,pascendant_sp_assistance_amt     OUT NOCOPY NUMBER
                        ,pascendant_age_deduction_amt     OUT NOCOPY NUMBER
                        ,pno_independent_siblings         OUT NOCOPY NUMBER
                        ,psingle_parent                   OUT NOCOPY VARCHAR2
                        ,pno_descendant_adopt_less_3      OUT NOCOPY NUMBER)
                         RETURN NUMBER;
    --
    FUNCTION get_marital_status(passignment_id         IN   NUMBER
                               ,peffective_date        IN   DATE
                               ,passignment_number     OUT  NOCOPY VARCHAR2
                               ,pmarital_status_code   OUT  NOCOPY VARCHAR2) RETURN VARCHAR2;
    --
    FUNCTION get_spouse_info(pperson_id        NUMBER
                            ,peffective_date   DATE ) RETURN VARCHAR2;
    --
    FUNCTION get_disability_info(passignment_id         IN NUMBER
                                ,peffective_date    IN DATE
                                ,pdegree            OUT NOCOPY NUMBER
                                ,pspecial_care_flag OUT NOCOPY VARCHAR2)
                                 RETURN VARCHAR2;
    --
    FUNCTION get_disability_detail(pperson_id         IN NUMBER
                                  ,peffective_date    IN DATE
                                  ,pdegree            OUT NOCOPY NUMBER
                                  ,pspecial_care_flag OUT NOCOPY VARCHAR2)
                                  RETURN VARCHAR2;
    --
    FUNCTION get_table_value(bus_group_id    IN NUMBER
			                ,ptab_name       IN VARCHAR2
			                ,pcol_name       IN VARCHAR2
			                ,prow_value      IN VARCHAR2
                            ,peffective_date IN DATE )RETURN NUMBER;
    --
    FUNCTION get_parameter_value(p_payroll_action_id IN  NUMBER
                                ,p_token_name        IN  VARCHAR2) RETURN VARCHAR2;
    --
    FUNCTION Emp_Address_chk(passignment_id IN  NUMBER
                        ,peffective_date        IN DATE ) RETURN VARCHAR2 ;
    --
    FUNCTION get_effective_date(p_payroll_action_id IN  NUMBER
                               ,p_assignment_id     IN  NUMBER
                               ,p_date_earned       IN  DATE
                               ,p_run_type          OUT NOCOPY VARCHAR2
                               ,p_process_twr_flag  OUT NOCOPY VARCHAR2) RETURN DATE;
    --
    FUNCTION get_pay_period_number(payroll_id        IN NUMBER
                                  ,peffective_date  IN DATE) RETURN NUMBER;
    --
    FUNCTION get_proration_factor(passignment_id            IN NUMBER
                                 ,payroll_id                IN NUMBER
                                 ,peffective_date           IN DATE
                                 ,phire_date                IN DATE
                                 ,ptermination_date         IN DATE
                                 ,ppay_periods_per_year     IN NUMBER
                                 ,ppay_proc_period_number   IN NUMBER
                                 ,pchk_new_emp              IN VARCHAR2
                                 ,p_run_type                IN VARCHAR2) RETURN NUMBER;
    --
    FUNCTION chk_new_employee(passignment_id  IN  NUMBER
                             ,peffective_date IN DATE) RETURN VARCHAR2;
    --
    FUNCTION get_user_table_upper_value(pvalue IN NUMBER
                                       ,peffective_date IN DATE) RETURN NUMBER;
    --
    FUNCTION get_previous_twr_run_values(passignment_id   IN  NUMBER
                                        ,peffective_date  IN DATE
                                        ,ptax_base        OUT NOCOPY NUMBER
                                        ,pcont_earnings  OUT NOCOPY NUMBER) RETURN NUMBER;
    --
    PROCEDURE populate_TWR_Report(p_request_id IN      NUMBER
                                 ,p_payroll_action_id  NUMBER
                                 ,p_legal_employer     NUMBER
                                 ,p_person_id          NUMBER
                                 ,p_xfdf_blob          OUT NOCOPY BLOB);
    --
    PROCEDURE fetch_pdf_blob (p_pdf_blob OUT NOCOPY BLOB);
    --
    FUNCTION get_name(p_payroll_action_id IN NUMBER
                              ,p_action_type       IN VARCHAR2
                              ,p_effective_date    IN DATE) RETURN VARCHAR2;

    --
    PROCEDURE populate_plsql_table(p_request_id IN      NUMBER
                                  ,p_payroll_action_id  NUMBER
                                  ,p_legal_employer     NUMBER
                                  ,p_person_id          NUMBER);
    --
    PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);
    --
    PROCEDURE WritetoCLOB (p_xfdf_blob OUT NOCOPY blob
                      ,p_xfdf_string OUT NOCOPY clob);
    --
    FUNCTION get_contractual_earnings(p_assignment_id    IN NUMBER
                                     ,p_calculation_date IN DATE
                                     ,p_name             IN VARCHAR2
                                     ,p_rt_element       IN VARCHAR2
                                     ,p_to_time_dim      IN VARCHAR2
                                     ,p_rate             IN OUT NOCOPY NUMBER
                                     ,p_error_message    IN OUT NOCOPY VARCHAR2) RETURN NUMBER;
    --
    FUNCTION calc_withholding_quota(p_business_gr_id IN NUMBER
                                   ,p_effective_date IN DATE
                                   ,p_tax_base       IN NUMBER)  RETURN NUMBER;
    --
    FUNCTION get_contract_end_date(p_assignment_id        IN  NUMBER
                                  ,p_effective_date       IN  DATE) RETURN DATE;
    --
    FUNCTION get_contractual_deductions(p_assignment_id          IN NUMBER
                                       ,p_calculation_date       IN DATE
                                       ,p_period_start_date      IN DATE
                                       ,p_period_end_date        IN DATE
                                       ,p_pay_periods_per_year   IN NUMBER
                                       ,p_pay_proc_period_number IN NUMBER
                                       ,p_child_support_amt      OUT NOCOPY NUMBER
                                       ,p_spouse_alimony_amt     OUT NOCOPY NUMBER) RETURN NUMBER;
    --
END pay_es_twr_calc_pkg;

 

/
