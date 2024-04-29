--------------------------------------------------------
--  DDL for Package PAY_CN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_RULES" AUTHID CURRENT_USER AS
/* $Header: pycnrule.pkh 120.0.12000000.1 2007/01/17 17:59:05 appldev noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEFAULT_JURISDICTION                            --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to get the default jurisdcition           --
--                  for China tax processing.                           --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_asg_act_id           NUMBER                       --
--                  p_ee_id                NUMBER                       --
--        IN/OUT  : p_jurisdiction         VARCHAR2                     --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_default_jurisdiction( p_asg_act_id                 NUMBER
                                  , p_ee_id                      NUMBER
                                  , p_jurisdiction IN OUT NOCOPY VARCHAR2
                                  ) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RETRO_COMPONENT_ID                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to get the default retro component id for --
--                  a particular element entry from Org DDF             --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_ee_id                NUMBER                       --
--        IN/OUT  : p_retro_component_id   NUMBER                       --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_retro_component_id ( p_ee_id               IN NUMBER
                                 , p_element_type_id     IN NUMBER
                                 , p_retro_component_id  IN OUT NOCOPY NUMBER
                                 );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to do psot processing for template engines--
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_template_id          NUMBER                       --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process (p_template_id IN NUMBER);

END pay_cn_rules;

 

/
