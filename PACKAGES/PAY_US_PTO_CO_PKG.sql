--------------------------------------------------------
--  DDL for Package PAY_US_PTO_CO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PTO_CO_PKG" AUTHID CURRENT_USER as
/* $Header: pyuspaco.pkh 120.0.12010000.1 2008/07/27 23:54:55 appldev ship $ */

  --
  -- Package global constants.
  --
  DEBUG   CONSTANT NUMBER := 0;
  NORMAL  CONSTANT NUMBER := 1;

  SUCCESS CONSTANT NUMBER := 0;
  WARNING CONSTANT NUMBER := 1;
  ERROR   CONSTANT NUMBER := 2;

  --
  -- Package global variables.
  --
  g_errbuf        VARCHAR2(2000);
  g_retcode       NUMBER;

PROCEDURE initialize_logging
    (p_action_parameter_group_id IN NUMBER DEFAULT NULL);

PROCEDURE write_log
    (p_text IN VARCHAR2
    ,p_type IN NUMBER DEFAULT NORMAL);

PROCEDURE carry_over( ERRBUF           OUT NOCOPY varchar2,
                      RETCODE          OUT NOCOPY number,
                      P_calculation_date          varchar2,
                      P_business_group_id         number,
                      P_plan_id                   number   DEFAULT NULL,
                      P_plan_category             varchar2 DEFAULT NULL,
                      P_mode                      varchar2 DEFAULT 'N',
		      p_accrual_term              varchar2 DEFAULT 'C',
                      p_action_parameter_group_id number   DEFAULT NULL
		      );
--

/* For 2932073 P_Legislation_cd             Varchar2 DEFAULT NULL is added */
/* In the pto_carry_over_for_plan Procedure */
PROCEDURE pto_carry_over_for_plan
                    ( p_plan_id                    number,
                      p_co_formula_id              number,
                      P_plan_ele_type_id           number,
                      P_co_ele_type_id             number,
                      P_co_input_val_id            number,
                      P_co_date_input_value_id     number,
		      P_co_exp_date_input_value_id number,
                      P_res_ele_type_id            number,
                      P_res_input_val_id           number,
                      P_res_date_input_value_id    number,
		      P_business_group_id          number,
                      P_Calculation_date           date,
                      P_co_mode                    varchar2,
		      p_accrual_term               varchar2,
		      p_session_date               date,
		      p_legislation_code           Varchar2 DEFAULT NULL
		      );
--

/* For 2932073 P_Legislation_cd             Varchar2 DEFAULT NULL is added */
/* In the pto_carry_over_for_asg Procedure */
PROCEDURE pto_carry_over_for_asg
                    ( p_plan_id                    number,
                      p_assignment_id              number,
                      p_co_formula_id              number,
                      p_plan_ele_type_id           number,
                      p_co_ele_type_id             number,
                      p_co_input_val_id            number,
                      p_co_date_input_value_id     number,
		      p_co_exp_date_input_value_id number,
                      p_res_ele_type_id            number,
                      p_res_input_val_id           number,
                      p_res_date_input_value_id    number,
		      p_business_group_id          number,
                      p_calculation_date           date,
                      p_co_mode                    varchar2,
		      p_accrual_term               varchar2,
		      p_session_date               date,
		      p_legislation_code           Varchar2 DEFAULT NULL
		      );
--
END pay_us_pto_co_pkg;

/
