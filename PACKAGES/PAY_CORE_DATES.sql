--------------------------------------------------------
--  DDL for Package PAY_CORE_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_DATES" AUTHID CURRENT_USER as
/* $Header: pycordat.pkh 115.0 2003/08/27 03:01:45 nbristow noship $ */
--
function get_time_definition_date(p_time_def_id     in            number,
                                    p_effective_date  in            date,
                                    p_bus_grp         in            number   default null)
return date;
--
function is_date_in_span(p_start_time_def_id in     number,
                          p_end_time_def_id   in     number,
                          p_test_date         in     date,
                          p_effective_date    in     date,
                          p_bus_grp           in     number default null
                         )
return varchar2;
--
end pay_core_dates;

 

/
