--------------------------------------------------------
--  DDL for Package PAY_ES_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_RULES" AUTHID CURRENT_USER AS
/* $Header: pyesrule.pkh 120.1 2005/06/22 07:55:10 viviswan noship $ */

--
    PROCEDURE get_main_tax_unit_id(p_assignment_id   IN     NUMBER
                                  ,p_effective_date  IN     DATE
                                  ,p_tax_unit_id     IN OUT NOCOPY NUMBER);
--
    PROCEDURE get_source_text_context(p_asg_act_id  NUMBER
                                     ,p_ee_id       NUMBER
                                     ,p_source_text IN OUT NOCOPY VARCHAR2);
--
    PROCEDURE get_source_text2_context(p_asg_act_id   NUMBER
                                      ,p_ee_id        NUMBER
                                      ,p_source_text2 IN OUT NOCOPY VARCHAR2);
--
    PROCEDURE get_source_number_context(p_asg_act_id    NUMBER
                                       ,p_ee_id         NUMBER
                                       ,p_source_number IN OUT NOCOPY VARCHAR2);
--
    PROCEDURE get_source_number2_context(p_asg_act_id     NUMBER
                                        ,p_ee_id          NUMBER
                                        ,p_source_number2 IN OUT NOCOPY VARCHAR2);
--
END pay_es_rules;


 

/
