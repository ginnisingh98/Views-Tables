--------------------------------------------------------
--  DDL for Package PAY_AE_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_ELEMENT_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyaeeltm.pkh 120.1 2006/02/01 02:24:53 abppradh noship $ */

  FUNCTION get_rate_from_tab_id
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_rate_id           IN NUMBER)
  RETURN NUMBER;

  FUNCTION get_rate_from_tab_name
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_rate_table        IN VARCHAR2
    ,p_table_exists     OUT NOCOPY VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_employee_details
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_info_type         IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_absence_days
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_start_date        IN DATE
    ,p_end_date          IN DATE)
  RETURN NUMBER;

  PROCEDURE element_template_post_process
    (p_template_id       IN NUMBER);

  PROCEDURE create_templates;

  PROCEDURE create_flat_amt_template;

  PROCEDURE create_perc_template;

  PROCEDURE create_basic_sal_template;

  PROCEDURE create_hsg_allw_template;

  PROCEDURE create_trn_allw_template;

  PROCEDURE create_col_allw_template;

  PROCEDURE create_child_allw_template;

  PROCEDURE create_social_allw_template;

  PROCEDURE create_shift_allw_template;

  PROCEDURE create_hrly_basic_sal_template;

  PROCEDURE create_ot_allw_template;

  PROCEDURE create_unp_leave_dedn_template;

END pay_ae_element_template_pkg;


 

/
