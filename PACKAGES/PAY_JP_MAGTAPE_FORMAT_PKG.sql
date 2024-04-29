--------------------------------------------------------
--  DDL for Package PAY_JP_MAGTAPE_FORMAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_MAGTAPE_FORMAT_PKG" AUTHID CURRENT_USER as
/* $Header: payjpmgf.pkh 115.1 2002/11/06 09:31:35 ytohya noship $ */
--------------------------------------------------------------------------------
function header_record(
	p_data	in pay_jp_magtape_pkg.header) return varchar2;
--------------------------------------------------------------------------------
function data_record(
	p_data	in pay_jp_magtape_pkg.data) return varchar2;
--------------------------------------------------------------------------------
function trailer_record(
	p_data	in pay_jp_magtape_pkg.trailer) return varchar2;
--------------------------------------------------------------------------------
function end_record return varchar2;
--------------------------------------------------------------------------------
end pay_jp_magtape_format_pkg;

 

/
