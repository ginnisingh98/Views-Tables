--------------------------------------------------------
--  DDL for Package AR_XML_VIEW_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_XML_VIEW_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: ARDTUVFS.pls 120.1 2007/08/07 11:08:04 nproddut noship $ */

function header_function1(p_trx_id in number) return varchar2;
function header_function2(p_trx_id in number) return varchar2;
function header_function3(p_trx_id in number) return varchar2;
function header_function4(p_trx_id in number) return varchar2;
function header_function5(p_trx_id in number) return varchar2;
function header_function6(p_trx_id in number) return varchar2;
function header_function7(p_trx_id in number) return varchar2;
function header_function8(p_trx_id in number) return varchar2;
function header_function9(p_trx_id in number) return varchar2;
function header_function10(p_trx_id in number) return varchar2;

function line_function1(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function2(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function3(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function4(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function5(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function6(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function7(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function8(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function9(p_trx_id in number, p_trx_line_id in number) return varchar2;
function line_function10(p_trx_id in number, p_trx_line_id in number) return varchar2;

function charge_function1(p_trx_id in number, p_trx_line_id in number) return varchar2;
function charge_function2(p_trx_id in number, p_trx_line_id in number) return varchar2;
function charge_function3(p_trx_id in number, p_trx_line_id in number) return varchar2;
function charge_function4(p_trx_id in number, p_trx_line_id in number) return varchar2;
function charge_function5(p_trx_id in number, p_trx_line_id in number) return varchar2;

function tax_function1(p_trx_id in number, p_trx_line_id in number) return varchar2;
function tax_function2(p_trx_id in number, p_trx_line_id in number) return varchar2;
function tax_function3(p_trx_id in number, p_trx_line_id in number) return varchar2;
function tax_function4(p_trx_id in number, p_trx_line_id in number) return varchar2;
function tax_function5(p_trx_id in number, p_trx_line_id in number) return varchar2;

function po_function1(p_trx_id in number) return varchar2;
function po_function2(p_trx_id in number) return varchar2;
function po_function3(p_trx_id in number) return varchar2;
function po_function4(p_trx_id in number) return varchar2;
function po_function5(p_trx_id in number) return varchar2;

function pt_function1(p_trx_id in number, p_term_id in number, p_payment_schedule_id in number) return varchar2;
function pt_function2(p_trx_id in number, p_term_id in number, p_payment_schedule_id in number) return varchar2;
function pt_function3(p_trx_id in number, p_term_id in number, p_payment_schedule_id in number) return varchar2;
function pt_function4(p_trx_id in number, p_term_id in number, p_payment_schedule_id in number) return varchar2;
function pt_function5(p_trx_id in number, p_term_id in number, p_payment_schedule_id in number) return varchar2;

function rt_function1(p_party_site_id in number) return varchar2;
function rt_function2(p_party_site_id in number) return varchar2;
function rt_function3(p_party_site_id in number) return varchar2;
function rt_function4(p_party_site_id in number) return varchar2;
function rt_function5(p_party_site_id in number) return varchar2;

function so_function1(p_trx_id in number, p_trx_line_id in number) return varchar2;
function so_function2(p_trx_id in number, p_trx_line_id in number) return varchar2;
function so_function3(p_trx_id in number, p_trx_line_id in number) return varchar2;
function so_function4(p_trx_id in number, p_trx_line_id in number) return varchar2;
function so_function5(p_trx_id in number, p_trx_line_id in number) return varchar2;

function tp_function1(p_party_site_id in number) return varchar2;
function tp_function2(p_party_site_id in number) return varchar2;
function tp_function3(p_party_site_id in number) return varchar2;
function tp_function4(p_party_site_id in number) return varchar2;
function tp_function5(p_party_site_id in number) return varchar2;

end;

/
