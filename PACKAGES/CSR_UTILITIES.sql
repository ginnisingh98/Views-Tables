--------------------------------------------------------
--  DDL for Package CSR_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSR_UTILITIES" AUTHID CURRENT_USER as
/*$Header: CSRDUTIS.pls 115.6.11510.1 2004/04/16 12:45:58 dwals ship $*/

  function compare_values
  (
    p_val1 in varchar2
  , p_val2 in varchar2
  )
  return boolean;

  function compare_values
  (
    p_val1 in number
  , p_val2 in number
  )
  return boolean;

  function compare_values
  (
    p_val1 in date
  , p_val2 in date
  )
  return boolean;

end CSR_UTILITIES;

 

/
