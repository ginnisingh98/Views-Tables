--------------------------------------------------------
--  DDL for Package PAY_SE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_SOE" AUTHID CURRENT_USER as
/* $Header: pysesoer.pkh 120.0 2005/05/29 08:38:04 appldev noship $ */
--
g_currency_code varchar2(10);
--
function Elements1(p_assignment_action_id number) return long;
--
function Elements2(p_assignment_action_id number) return long;
--
function Information1(p_assignment_action_id number) return long;
--
--

end pay_se_soe;

 

/
