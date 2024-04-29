--------------------------------------------------------
--  DDL for Package PAY_GB_WNU_EDI_BIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_WNU_EDI_BIP" AUTHID CURRENT_USER as
/* $Header: PYGBWNU.pkh 120.0.12010000.2 2010/01/12 07:25:42 dwkrishn noship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name : PYGBWNU.pkh

  DATE         AUTHOR    Version  Comments
===========================================================================
  30/11/2009   DWKRISHN  Created.
===========================================================================  */


p_payroll_action_id number;


function beforereport return boolean;

function cp_address_1 return varchar2;
function cp_address_2 return varchar2;
function cp_address_3 return varchar2;
function cp_address_4 return varchar2;
function cp_address_5 return varchar2;

g_address1 varchar2(50) := ' ';
g_address2 varchar2(50) := ' ';
g_address3 varchar2(50) := ' ';
g_address4 varchar2(50) := ' ';
g_address5 varchar2(50) := ' ';


end pay_gb_wnu_edi_bip;

/
