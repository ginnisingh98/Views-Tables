--------------------------------------------------------
--  DDL for Package PAY_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUMP_GET" AUTHID CURRENT_USER as
/* $Header: paydpget.pkh 115.0 2003/02/14 15:07:18 arashid noship $ */
--------------------------------
-- List Of Supported Entities --
--------------------------------
-- Entity                      Access Method
-- ------                      -------------
-- PAY_RUN_TYPES_F             MAPPING FUNCTION/USER_KEY
--
--------------------------- get_run_type_id ---------------------------------
/*
  NAME
    get_run_type_id
  DESCRIPTION
    Returns a run_type_id (PAY_RUN_TYPES_F).
  NOTES
    This function is only intended for use with data pump.
*/
function get_run_type_id
(p_run_type_user_key in varchar2
) return number;
--------------------------- get_run_type_ovn --------------------------------
/*
  NAME
    get_run_type_ovn
  DESCRIPTION
    Returns a run type object version number.
  NOTES
    This function is only intended for use with data pump.
*/
function get_run_type_ovn
(p_run_type_user_key in varchar2
,p_effective_date    in date
) return number;
end pay_pump_get;

 

/
