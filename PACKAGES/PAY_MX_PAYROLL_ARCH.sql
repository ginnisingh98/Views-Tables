--------------------------------------------------------
--  DDL for Package PAY_MX_PAYROLL_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_PAYROLL_ARCH" AUTHID CURRENT_USER AS
/* $Header: paymxpaysliparch.pkh 120.1 2005/10/10 10:43:37 vmehta noship $ */
--

  PROCEDURE get_payroll_action_info(p_payroll_action_id   in         NUMBER
                                   ,p_end_date            OUT NOCOPY DATE
                                   ,p_start_date          OUT NOCOPY DATE
                                   ,p_business_group_id   OUT NOCOPY NUMBER
                                   ,p_cons_set_id         OUT NOCOPY NUMBER
                                   ,p_payroll_id          OUT NOCOPY NUMBER
                                   );

  PROCEDURE range_code(p_payroll_action_id IN NUMBER
                      ,p_sqlstr           OUT NOCOPY VARCHAR2);

  PROCEDURE assignment_action_code(p_payroll_action_id IN NUMBER
                                  ,p_start_person_id   IN NUMBER
                                  ,p_end_person_id     IN NUMBER
                                  ,p_chunk             IN NUMBER);

  PROCEDURE archive_code(p_xfr_action_id  IN NUMBER,
                         p_effective_date IN DATE);


  PROCEDURE initialization_code(p_payroll_action_id IN NUMBER);

  gv_act_param_val         VARCHAR2(240);
  gn_np_sepchk_run_type_id NUMBER;
  gn_sepchk_run_type_id    NUMBER;
  run_bal_stat             pay_ac_action_arch.run_bal_stat_tab;

  TYPE def_bal  IS RECORD ( act_info_category   VARCHAR2(50),
                            bal_name            VARCHAR2(240),
                            bal_type_id         NUMBER(10),
                            pymt_def_bal_id     NUMBER(10),
                            gre_ytd_def_bal_id  NUMBER(10),
                            run_def_bal_id      NUMBER(10),
                            jurisdiction_cd     VARCHAR2(30));

  TYPE def_bal_tbl IS TABLE OF def_bal INDEX BY BINARY_INTEGER;

END pay_mx_payroll_arch;

 

/
