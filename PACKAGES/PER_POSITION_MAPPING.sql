--------------------------------------------------------
--  DDL for Package PER_POSITION_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POSITION_MAPPING" AUTHID CURRENT_USER as
-- $Header: perpomap.pkh 115.3 99/10/18 20:41:07 porting shi $
  function get_position_id
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number;

  function get_position_definition_id
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number;

   function get_prior_position_id
   ( p_prior_position_name IN varchar2,
     p_effective_date IN date )
   return number;

   function get_supervisor_position_id
   ( p_supervisor_position_name IN varchar2,
     p_effective_date IN date )
   return number;

   function get_successor_position_id
   ( p_successor_position_name IN varchar2,
     p_effective_date IN date )
   return number;

   function get_relief_position_id
   ( p_relief_position_name IN varchar2,
     p_effective_date IN date )
   return number;

   function get_AVAILABILITY_STATUS_id (
            p_shared_type_name      varchar2
           ,p_system_type_cd        varchar2
           ,p_business_group_id     number )
     return number ;

   function get_entry_step_id (
         p_spinal_point      varchar2
       , p_effective_date    date
           ,p_business_group_id     number )
      return number ;

   function get_pay_freq_payroll_id (
            p_pay_freq_payroll_name varchar2
           ,p_business_group_id     number )
      return number ;

  function get_position_ovn
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number ;
END;

 

/
