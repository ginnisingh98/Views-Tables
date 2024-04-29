--------------------------------------------------------
--  DDL for Package Body CSR_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_UTILITIES" as
/*$Header: CSRDUTIB.pls 115.6.11510.1 2004/04/16 12:45:53 dwals ship $*/

  function compare_values
  (
    p_val1 in varchar2
  , p_val2 in varchar2
  )
  return boolean is
  begin
    return ( p_val1 = fnd_api.g_miss_char or
             p_val1 = p_val2              or
             ( p_val1 is null and p_val2 is null )
           );
  end compare_values;

  function compare_values
  (
    p_val1 in number
  , p_val2 in number
  )
  return boolean is
  begin
    return ( p_val1 = fnd_api.g_miss_num or
             p_val1 = p_val2             or
             ( p_val1 is null and p_val2 is null )
           );
  end compare_values;

  function compare_values
  (
    p_val1 in date
  , p_val2 in date
  )
  return boolean is
  begin
    return ( p_val1 = fnd_api.g_miss_date or
             p_val1 = p_val2              or
             ( p_val1 is null and p_val2 is null )
           );
  end compare_values;
end CSR_UTILITIES;

/
