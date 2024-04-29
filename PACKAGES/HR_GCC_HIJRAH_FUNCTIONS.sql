--------------------------------------------------------
--  DDL for Package HR_GCC_HIJRAH_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GCC_HIJRAH_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pegcchjf.pkh 120.0 2005/05/31 09:16:25 appldev noship $ */

  function hijrah_to_gregorian
    (p_input_date         in  varchar2)
  return varchar2;

  function gregorian_to_hijrah
    (p_input_date         in  date)
  return varchar2;

  function add_days
    (p_input_date         in  varchar2
    ,p_num                in  number)
  return varchar2;

  function days_between
    (p_high_date          in  varchar2
    ,p_low_date           in  varchar2)
  return number;

  function get_day
    (p_input_date         in  varchar2)
  return varchar2;

  function get_month
    (p_input_date         in  varchar2)
  return varchar2;

  function get_weekday
    (p_input_date         in  varchar2)
  return number;

  function get_yearday
    (p_input_date         in  varchar2)
  return number;

  procedure validate_date
    (p_input_date         in  varchar2,
     p_output_date 	  out nocopy varchar2);
--
end hr_gcc_hijrah_functions;

 

/
