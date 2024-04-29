--------------------------------------------------------
--  DDL for Package PAY_GB_P46EXP_EDI_BIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P46EXP_EDI_BIP" AUTHID CURRENT_USER as
/* $Header: PYGBP46EXP.pkh 120.0.12010000.2 2010/01/22 16:02:13 krreddy noship $ */
--
p_payroll_action_id number;

g_address1 varchar2(240) := ' ';
g_address2 varchar2(240) := ' ';
g_address3 varchar2(240) := ' ';
g_address4 varchar2(240) := ' ';

procedure set_address_lines(p_assignment_action_id IN NUMBER);
function cp_address(p_assignment_action_id IN NUMBER) return varchar2;

END pay_gb_p46exp_edi_bip;

/
