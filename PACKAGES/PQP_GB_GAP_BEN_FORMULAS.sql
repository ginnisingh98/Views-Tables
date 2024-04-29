--------------------------------------------------------
--  DDL for Package PQP_GB_GAP_BEN_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_GAP_BEN_FORMULAS" AUTHID CURRENT_USER AS
--  $Header: pqpgbofm.pkh 115.1 2003/03/04 13:01:22 rrazdan noship $
--
-- Debug Variables.
--
  g_proc_name              VARCHAR2(61):= 'pqp_gb_gap_ben_formulas.';
  g_nested_level           NUMBER:= 0;
--
-- Global Varibales
--
  g_use_this_functionality BOOLEAN:= FALSE;
  g_business_group_id      NUMBER;
  g_legislation_code       VARCHAR2(10):= 'GB';
  g_effective_date         DATE;
--
--
--
  TYPE t_formulas IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_formulas t_formulas;

  CURSOR csr_get_formula_id
    (p_business_group_id            IN     NUMBER
    ,p_formula_name                 IN     VARCHAR2
    ) IS
  SELECT formula_id
    FROM ff_formulas_f
   WHERE formula_name = p_formula_name
     AND business_group_id = p_business_group_id
  ;

  l_check_ler_formulas  csr_get_formula_id%ROWTYPE;
--
--
--
  PROCEDURE create_ben_formulas
    (p_business_group_id            IN     NUMBER
    ,p_effective_date               IN     DATE
    ,p_absence_pay_plan_category    IN     VARCHAR2
    ,p_base_name                    IN     VARCHAR2
    ,p_formulas IN OUT NOCOPY pqp_gb_gap_ben_formulas.t_formulas
    ,p_error_code                      OUT NOCOPY NUMBER
    ,p_error_message                   OUT NOCOPY VARCHAR2
    )
  ;
--
--
--
  PROCEDURE delete_ben_formulas
    (p_business_group_id            IN     NUMBER
    ,p_effective_date               IN     DATE
    ,p_absence_pay_plan_category    IN     VARCHAR2
    ,p_base_name                    IN     VARCHAR2
    ,p_error_code                      OUT NOCOPY NUMBER
    ,p_error_message                   OUT NOCOPY VARCHAR2
    )
  ;
--
--
--
END pqp_gb_gap_ben_formulas;

 

/
