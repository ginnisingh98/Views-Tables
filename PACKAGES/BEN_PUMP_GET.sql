--------------------------------------------------------
--  DDL for Package BEN_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PUMP_GET" AUTHID CURRENT_USER as
/* $Header: bedpget.pkh 120.0 2006/02/17 13:24:22 ikasired noship $ */
/*
  Notes:
    The functions declared in this header are designed to be used by
    the Data Pump engine to resolve id values that have to be passed
    to the API modules.  However, most of these functions could also
    be used by any program that might want to do something similar.

    The exceptions to are likely to be the functions where a user
    key value is one of the parameters.
*/

/*
 *  The following functions have been defined in this
 *  header file.

*/
------------------------------ get_acty_base_rt_id ---------------------------
/*
  NAME
    get_acty_base_rt_id
  DESCRIPTION
    Returns an acty base rate ID.
  NOTES
    This function returns an acty_base_rt_id1 and is designed for use with the Data Pump.
*/
function get_acty_base_rt_id1
( p_data_pump_always_call in varchar2,
  p_business_group_id       in number,
  p_acty_base_rate_name1    in varchar2 default null,
  p_acty_base_rate_num1     in number   default null,
  p_effective_date          in date
) return number;
pragma restrict_references (get_acty_base_rt_id1 , WNDS);
--
------------------------------ get_acty_base_rt_id2 ---------------------------
/*
  NAME
    get_acty_base_rt_id2
  DESCRIPTION
    Returns an acty base rate ID.
  NOTES
    This function returns an acty_base_rt_id2 and is designed for use with the Data Pump.
*/
function get_acty_base_rt_id2
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_acty_base_rate_name2    in varchar2 default null,
  p_acty_base_rate_num2     in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_acty_base_rt_id2 , WNDS);
--
------------------------------ get_acty_base_rt_id3 ---------------------------
/*
  NAME
    get_acty_base_rt_id3
  DESCRIPTION
    Returns an acty base rate ID.
  NOTES
    This function returns an acty_base_rt_id3 and is designed for use with the Data Pump.
*/
function get_acty_base_rt_id3
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_acty_base_rate_name3    in varchar2 default null,
  p_acty_base_rate_num3     in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_acty_base_rt_id3 , WNDS);
--
------------------------------ get_acty_base_rt_id4 ---------------------------
/*
  NAME
    get_acty_base_rt_id4
  DESCRIPTION
    Returns an acty base rate ID.
  NOTES
    This function returns an acty_base_rt_id and is designed for use with the Data Pump.
*/
function get_acty_base_rt_id4
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_acty_base_rate_name4    in varchar2 default null,
  p_acty_base_rate_num4     in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_acty_base_rt_id4 , WNDS);
--
------------------------------ get_pgm_id ---------------------------
/*
  NAME
    get_pgm_id
  DESCRIPTION
    Returns a Program ID.
  NOTES
    This function returns a pgm_id and is designed for use with the Data Pump.
*/
function get_pgm_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_program              in varchar2 default null,
  p_program_num          in number   default null,
  p_effective_date       in date
) return number;
pragma restrict_references (get_pgm_id , WNDS);
--

------------------------------ get_pl_id ---------------------------
/*
  NAME
    get_pl_id
  DESCRIPTION
    Returns a Plan ID.
  NOTES
    This function returns a pl_id and is designed for use with the Data Pump.
*/
function get_pl_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_plan              in varchar2 default null,
  p_plan_num          in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pl_id , WNDS);
--

------------------------------ get_ended_pl_id ---------------------------
/*
  NAME
    get_ended_pl_id
  DESCRIPTION
    Returns a ended_Plan ID.
  NOTES
    This function returns a ended_pl_id and is designed for use with the Data Pump.
*/
function get_ended_pl_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_ended_plan        in varchar2 default null,
  p_ended_plan_num    in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_ended_pl_id , WNDS);
--
------------------------------ get_opt_id ---------------------------
/*
  NAME
    get_opt_id
  DESCRIPTION
    Returns an option (definition) ID.
  NOTES
    This function returns a opt_id and is designed for use with the Data Pump.
*/
function get_opt_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_option            in varchar2 default null,
  p_option_num        in number   default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_opt_id, WNDS);
--
------------------------------ get_ended_opt_id ---------------------------
/*
  NAME
    get_ended_opt_id
  DESCRIPTION
    Returns an ended_option (definition) ID.
  NOTES
    This function returns a ended_opt_id and is designed for use with the Data Pump.
*/
function get_ended_opt_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_ended_option      in varchar2 default null,
  p_ended_option_num  in number default null,
  p_effective_date    in date
) return number;
pragma restrict_references (get_ended_opt_id, WNDS);
--
------------------------------ get_pen_person_id ---------------------------
/*
  NAME
    get_pen_person_id
  DESCRIPTION
    Returns an person_id
  NOTES
    This function returns a eperson_id and is designed for use with the Data Pump.
*/
--
function get_pen_person_id
( p_data_pump_always_call in varchar2,
  p_business_group_id   in number,
  p_employee_number     in varchar2 default null,
  p_national_identifier in varchar2 default null,
  p_full_name           in varchar2 default null,
  p_date_of_birth       in date     default null,
  p_person_num          in number   default null,
  p_effective_date      in date
) return number;
--
function get_con_person_id
( p_data_pump_always_call in varchar2,
  p_business_group_id   in number,
  p_con_employee_number     in varchar2 default null,
  p_con_national_identifier in varchar2 default null,
  p_con_full_name           in varchar2 default null,
  p_con_date_of_birth       in date     default null,
  p_con_person_num          in number   default null,
  p_effective_date      in date
) return number;
--
pragma restrict_references (get_pen_person_id , WNDS);
--
end ben_pump_get;

 

/
