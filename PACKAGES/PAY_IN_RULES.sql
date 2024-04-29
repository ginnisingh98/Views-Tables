--------------------------------------------------------
--  DDL for Package PAY_IN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_RULES" AUTHID CURRENT_USER AS
/*   $Header: pyinrule.pkh 120.2 2006/08/28 12:24:40 statkar noship $ */

PROCEDURE get_default_run_type(p_asg_id   IN NUMBER,
                               p_ee_id    IN NUMBER,
                               p_effdate  IN DATE,
                               p_run_type OUT NOCOPY VARCHAR2);

PROCEDURE get_source_context(p_asg_act_id IN NUMBER,
                             p_ee_id      IN NUMBER,
                             p_source_id  IN OUT NOCOPY VARCHAR2);

PROCEDURE get_default_jurisdiction(p_asg_act_id   NUMBER,
                                   p_ee_id        NUMBER,
                                   p_jurisdiction IN OUT NOCOPY VARCHAR2);

PROCEDURE get_source_text2_context(p_asg_act_id   NUMBER
                                  ,p_ee_id        NUMBER
                                  ,p_source_text2 IN OUT NOCOPY VARCHAR2);

FUNCTION  element_template_pre_process
          (p_template_obj    IN PAY_ELE_TMPLT_OBJ)
RETURN PAY_ELE_TMPLT_OBJ;

PROCEDURE element_template_upd_user_stru
          (p_template_id    IN  NUMBER);

PROCEDURE element_template_post_process
          (p_template_id    IN NUMBER);

PROCEDURE delete_pre_process
          (p_template_id    IN NUMBER);

END pay_in_rules;

/
