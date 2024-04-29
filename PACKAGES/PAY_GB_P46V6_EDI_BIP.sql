--------------------------------------------------------
--  DDL for Package PAY_GB_P46V6_EDI_BIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P46V6_EDI_BIP" AUTHID CURRENT_USER as
/* $Header: pygbp46v6.pkh 120.0.12010000.1 2010/01/22 13:31:16 namgoyal noship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name : PYGBP46V6.pkh

  DATE         AUTHOR    Version           Bug        Comments
===========================================================================
 19/01/2010   namgoyal 120.0.12010000.1   9255173     Created.
===========================================================================  */

p_payroll_action_id number;

g_address1 varchar2(240) := ' ';
g_address2 varchar2(240) := ' ';
g_address3 varchar2(240) := ' ';
g_address4 varchar2(240) := ' ';

procedure set_address_lines(p_assignment_action_id IN NUMBER);
function cp_address(p_assignment_action_id IN NUMBER) return varchar2;

end pay_gb_p46v6_edi_bip;

/
