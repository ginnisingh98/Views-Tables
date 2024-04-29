--------------------------------------------------------
--  DDL for Package PAY_IN_PROF_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_PROF_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: pyinptax.pkh 120.3 2006/01/09 05:05 abhjain noship $*/

  FUNCTION get_state (p_pt_org IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE check_pt_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_pt_org           IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
         );


   PROCEDURE check_pt_exemptions
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_state               IN VARCHAR2
          ,p_exemption_catg      IN VARCHAR2
          ,p_eff_start_date      IN VARCHAR2
          ,p_eff_end_date        IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type);

   PROCEDURE check_pt_frequency
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_state               IN VARCHAR2
          ,p_frequency           IN VARCHAR2
          ,p_eff_start_date      IN VARCHAR2
          ,p_eff_end_date        IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type);


   PROCEDURE check_pt_challan_info
          (p_organization_id    IN NUMBER
          ,p_org_info_type_code IN VARCHAR2
          ,p_payment_month      IN VARCHAR2
          ,p_payment_date       IN VARCHAR2
          ,p_payment_mode       IN VARCHAR2
          ,p_voucher_number     IN VARCHAR2
          ,p_amount             IN VARCHAR2
          ,p_interest           IN VARCHAR2
          ,p_payment_year       IN VARCHAR2
          ,p_excess_tax         IN VARCHAR2
          ,p_calling_procedure  IN VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);

   PROCEDURE check_stat_setup_df
          (p_organization_id    IN NUMBER
          ,p_org_info_type_code IN VARCHAR2
          ,p_state_level_bal    IN VARCHAR2
          ,p_gratuity_coverage  IN VARCHAR2
          ,p_calling_procedure  IN VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);

   PROCEDURE check_pt_loc
          (p_organization_id    IN NUMBER
          ,p_location_id        IN NUMBER
          ,p_calling_procedure  IN VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);

   PROCEDURE check_pt_org_class
          (p_organization_id    IN NUMBER
          ,p_calling_procedure  IN  VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);

    FUNCTION get_pt_balance(p_payroll_id      IN NUMBER
                       ,p_assignment_id   IN NUMBER
                       ,p_assignment_action_id IN NUMBER
                       ,p_balance_name    IN VARCHAR2
                       ,p_year_start      IN DATE
                       ,p_end_date        IN DATE
                       ,p_tot_pay_periods IN NUMBER
                       ,p_period_num      IN NUMBER
                       ,p_frequency       IN NUMBER
                       ,p_state           IN VARCHAR2
                       ,p_gross_salary    OUT NOCOPY NUMBER
                       ,p_prepaid_tax     OUT NOCOPY NUMBER
                       ,p_period_count    OUT NOCOPY NUMBER
                       ,p_pt_org          IN NUMBER)
    RETURN VARCHAR2;

    FUNCTION check_pt_input
            (p_assignment_id      IN NUMBER
            ,p_state              IN VARCHAR2
            ,p_period_end_date    IN DATE
            ,p_prorate_end_date   IN DATE
            ,p_pt_salary          IN OUT NOCOPY NUMBER)
    RETURN VARCHAR2;

    FUNCTION check_pt_state_end_date
            (p_assignment_id    IN NUMBER
            ,p_date             IN DATE
            ,p_state            IN VARCHAR2)
    RETURN NUMBER ;

    PROCEDURE check_srtc_state
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_srtc                IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type);

    FUNCTION get_projected_pt
            (p_pt_dedn_ptd      IN number
            ,p_lrpp             IN number
            ,p_period_num       IN number
            ,p_std_ptax         IN NUMBER
            ,p_frequency        IN NUMBER
            ,p_state            IN VARCHAR2)
    RETURN NUMBER ;

g_count NUMBER := 0;

TYPE PTRec
IS RECORD
  (
    State     VARCHAR2(240),
    PT_Salary NUMBER
  );

TYPE tPTTable IS TABLE OF PTRec INDEX BY BINARY_INTEGER;

gPTTable tPTTable;


END pay_in_prof_tax_pkg;

 

/
