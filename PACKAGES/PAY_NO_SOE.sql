--------------------------------------------------------
--  DDL for Package PAY_NO_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_SOE" AUTHID CURRENT_USER AS
/* $Header: pynosoe.pkh 120.0.12000000.1 2007/05/20 09:29:11 rlingama noship $ */

 --

function Elements1(p_assignment_action_id number) return long;
--
function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long;



-- end of package
END pay_no_soe;

 

/
