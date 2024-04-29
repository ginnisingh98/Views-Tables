--------------------------------------------------------
--  DDL for Package PAY_GB_ONLINE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_ONLINE_SOE" AUTHID CURRENT_USER as
/* $Header: pygbsoer.pkh 120.0 2005/05/29 05:30 appldev noship $ */

function Tax_Info(p_assignment_action_id NUMBER) return long;

function Balances1(p_assignment_action_id NUMBER) return long;

function Balances2(p_assignment_action_id NUMBER) return long;

function Balances3(p_assignment_action_id NUMBER) return long;

function setParameters(p_assignment_action_id NUMBER) return varchar2;

function setParameters(p_person_id in NUMBER,
                       p_assignment_id in NUMBER,
                       p_effective_date date) return varchar2;

end pay_gb_online_soe;

 

/
