--------------------------------------------------------
--  DDL for Package PAY_DK_BIK_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_BIK_UTILITY" AUTHID CURRENT_USER as
/* $Header: pydkbiku.pkh 120.0.12010000.2 2009/11/05 06:54:39 vijranga ship $ */


function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null)
         return varchar2;


function get_vehicle_info
( p_assignment_id        in     per_all_assignments_f.assignment_id%TYPE,
  p_business_group_id    in     number,
  p_date_earned          in     DATE,
  p_vehicle_allot_id     in     pqp_vehicle_allocations_f.VEHICLE_ALLOCATION_ID%TYPE,
  p_lic_reg_date OUT NOCOPY pqp_vehicle_repository_f.INITIAL_REGISTRATION%TYPE,
  p_buying_date OUT NOCOPY pqp_vehicle_repository_f.LAST_REGISTRATION_RENEW_DATE%TYPE,
  p_buying_price   OUT NOCOPY pqp_vehicle_repository_f.LIST_PRICE%TYPE,
  p_green_environment_fee OUT NOCOPY pqp_vehicle_repository_f.vre_information2%TYPE -- 9079593 fix
)
return NUMBER;
--
--
END pay_dk_bik_utility;


/
