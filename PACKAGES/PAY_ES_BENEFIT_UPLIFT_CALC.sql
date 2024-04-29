--------------------------------------------------------
--  DDL for Package PAY_ES_BENEFIT_UPLIFT_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_BENEFIT_UPLIFT_CALC" AUTHID CURRENT_USER AS
/* $Header: pyesssbu.pkh 120.0 2005/05/29 04:39:50 appldev noship $ */
    --
    FUNCTION  get_gross_per_day(p_assignment_id              IN NUMBER
                               ,p_business_group_id          IN NUMBER
                               ,p_date_earned                IN DATE
                               ,p_formula_name               IN VARCHAR2
                               ) RETURN NUMBER;
    --
    FUNCTION  get_duration(p_assignment_id              IN NUMBER
                      ,p_business_group_id          IN NUMBER
                      ,p_date_earned                IN DATE
                      ,p_formula_name               IN VARCHAR2
                      ,p_rate1                      OUT NOCOPY NUMBER
                      ,p_value1                     OUT NOCOPY NUMBER
                      ,p_rate2                      OUT NOCOPY NUMBER
                      ,p_value2                     OUT NOCOPY NUMBER
                      ,p_rate3                      OUT NOCOPY NUMBER
                      ,p_value3                     OUT NOCOPY NUMBER
                      ,p_rate4                      OUT NOCOPY NUMBER
                      ,p_value4                     OUT NOCOPY NUMBER
                      ,p_rate5                      OUT NOCOPY NUMBER
                      ,p_value5                     OUT NOCOPY NUMBER
                      ,p_rate6                      OUT NOCOPY NUMBER
                      ,p_value6                     OUT NOCOPY NUMBER
                      ,p_rate7                      OUT NOCOPY NUMBER
                      ,p_value7                     OUT NOCOPY NUMBER
                      ,p_rate8                      OUT NOCOPY NUMBER
                      ,p_value8                     OUT NOCOPY NUMBER
                      ,p_rate9                      OUT NOCOPY NUMBER
                      ,p_value9                     OUT NOCOPY NUMBER
                      ,p_rate10                     OUT NOCOPY NUMBER
                      ,p_value10                    OUT NOCOPY NUMBER
                       ) RETURN VARCHAR2;
    --
    PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                            ,p_business_group_id     IN NUMBER
                            ,p_effective_date        IN DATE
                            ,p_formula_id		     IN OUT NOCOPY NUMBER
                            ,p_formula_exists	     IN OUT NOCOPY BOOLEAN
                            ,p_formula_cached	     IN OUT NOCOPY BOOLEAN
                            );
    --
    PROCEDURE run_formula(p_formula_id      IN NUMBER
                         ,p_effective_date  IN DATE
                         ,p_formula_name    IN VARCHAR2
                         ,p_inputs          IN ff_exec.inputs_t
                         ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t);
    --
END pay_es_benefit_uplift_calc;

 

/
