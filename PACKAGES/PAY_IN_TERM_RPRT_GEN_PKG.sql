--------------------------------------------------------
--  DDL for Package PAY_IN_TERM_RPRT_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_TERM_RPRT_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: pyintrpt.pkh 120.0.12010000.3 2009/11/17 09:59:51 rsaharay ship $ */
TYPE XMLRec
IS RECORD
  (
    Name VARCHAR2(240),
    Value VARCHAR2(240)
  );

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;

gXMLTable tXMLTable;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : multiColumnar                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create xml for multiple columns        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
--------------------------------------------------------------------------
procedure multiColumnar(p_type     IN         VARCHAR2
                       ,p_data     IN         tXMLTable
                       ,p_count    IN         NUMBER);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : twoColumnar                                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create xml for two columns             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
--------------------------------------------------------------------------
procedure twoColumnar(p_type     IN         VARCHAR2
                     ,p_data     IN         tXMLTable
                     ,p_count    IN         NUMBER);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : getTag                                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Procedure to create tags                            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION getTag(p_tag_name  IN VARCHAR2
               ,p_tag_value IN VARCHAR2)
RETURN VARCHAR2;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_TEMPLATE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure gets the final settlement template   --
  --                  code set at organization level.If no template is    --
  --                  set default template code is returned               --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id    NUMBER                       --
  --            OUT : p_template             VARCHAR2                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_template (
                          p_business_group_id    IN NUMBER
                         ,p_template             OUT NOCOPY VARCHAR2
                         );


--------------------------------------------------------------------------
--                                                                      --
-- Name           : create_xml                                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create tags                            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_employee_number   VARCHAR2                        --
--                  p_bus_grp_id        NUMBER                          --
--            OUT : l_xml_data          CLOB                            --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE create_xml(p_employee_number IN         VARCHAR2
                    ,p_bus_grp_id      IN         NUMBER
		    ,p_term_date       IN         VARCHAR2
                    ,l_xml_data        OUT NOCOPY CLOB);



END pay_in_term_rprt_gen_pkg;

/
