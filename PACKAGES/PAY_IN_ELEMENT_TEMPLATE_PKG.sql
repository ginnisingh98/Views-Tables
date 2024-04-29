--------------------------------------------------------
--  DDL for Package PAY_IN_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_ELEMENT_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyineltm.pkh 120.2.12010000.1 2008/07/27 22:52:56 appldev ship $ */
   g_package    CONSTANT VARCHAR2(30) := 'pay_in_element_template_pkg.';

--------------------------------------------------------------------------
-- Name           : CREATE_TEMPLATE                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create the templates for ETW           --
-- Parameters     :                                                     --
--             IN : p_template_name         VARCHAR2                    --
--            OUT : p_template_id           NUMBER                      --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE create_template
       (p_template_name                 IN   VARCHAR2
       ,p_template_id                   OUT NOCOPY  NUMBER
       );

--------------------------------------------------------------------------
-- Name           : CREATE_TEMPLATE_ASSOCIATION                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to associate template with classification --
-- Parameters     :                                                     --
--             IN : p_template_name         VARCHAR2                    --
--                  p_classification_name   VARCHAR2                    --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE create_template_association
         (p_template_id      IN NUMBER
         ,p_classification   IN VARCHAR2 );

--------------------------------------------------------------------------
-- Name           : DELETE_TEMPLATE_ASSOCIATION                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to delete template-classification relation--
-- Parameters     :                                                     --
--             IN : p_template_name         VARCHAR2                    --
--                  p_classification_name   VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_template_association
         (p_template_name    IN VARCHAR2
	 ,p_classification   IN VARCHAR2 );

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_PRE_PROCESS                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_obj          PAY_ELE_TMPLT_OBJ           --
--            OUT : p_template_obj          PAY_ELE_TMPLT_OBJ           --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION element_template_pre_process
          (p_template_obj    IN PAY_ELE_TMPLT_OBJ)
RETURN PAY_ELE_TMPLT_OBJ;

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_UPD_USER_STRU                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE element_template_upd_user_stru
          (p_template_id    IN  NUMBER);

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process
          (p_template_id    IN NUMBER);

--------------------------------------------------------------------------
-- Name           : DELETE_PRE_PROCESS                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_pre_process
          (p_template_id    IN NUMBER);

END  pay_in_element_template_pkg;

/
