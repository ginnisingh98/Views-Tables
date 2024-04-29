--------------------------------------------------------
--  DDL for Package PAY_IE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_SOE" AUTHID CURRENT_USER AS
/* $Header: pyiesoer.pkh 120.0 2005/05/29 05:47:18 appldev noship $ */
function setParameters(p_person_id in number, p_assignment_id number, p_effective_date date) return varchar2;
function setParameters(p_assignment_action_id number) return varchar2;
function Employee(p_assignment_action_id number) return long;
function PAYE_Info(p_assignment_action_id NUMBER) return long ;
function Tax_PRSI_Info(p_assignment_action_id NUMBER) return long ;
function PRSI_Info(p_assignment_action_id NUMBER) return long ;
function Elements4(p_assignment_action_id number) return long;
function Elements1(p_assignment_action_id number, P_ELEMENT_SET_NAME varchar2) return long;
function set_cutoff_prompt(p_assignment_action_id NUMBER) return Varchar2;
function set_credit_prompt(p_assignment_action_id NUMBER) return Varchar2;


END PAY_IE_SOE;

 

/
