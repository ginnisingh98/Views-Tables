--------------------------------------------------------
--  DDL for Package PAY_NL_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_SOE" AUTHID CURRENT_USER as
/* $Header: pynlsoer.pkh 120.0.12000000.1 2007/01/17 23:00:00 appldev noship $ */

/* ---------------------------------------------------------------------
Function : Tax_Info

Text     : Fetches Tax Information
------------------------------------------------------------------------ */
function Tax_Info(p_assignment_action_id NUMBER) return long ;
--
function Get_Spl_Tax_Ind(p_spl_ind VARCHAR2) return varchar2 ;
--
function Elements2(p_assignment_action_id number) return long;
--
function Balances1(p_assignment_action_id number) return long;
--
function Balances2(p_assignment_action_id number) return long;
--
END PAY_NL_SOE;

 

/
