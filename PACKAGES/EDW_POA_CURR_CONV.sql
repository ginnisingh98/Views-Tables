--------------------------------------------------------
--  DDL for Package EDW_POA_CURR_CONV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_CURR_CONV" AUTHID CURRENT_USER as
/*$Header: poacurrs.pls 115.2 2003/01/09 23:39:27 rvickrey ship $ */

function convert_currency(p_from_currency varchar2, p_to_currency varchar2, p_rate_date date, p_rate_type varchar2) return number;
END EDW_POA_CURR_CONV;


 

/
