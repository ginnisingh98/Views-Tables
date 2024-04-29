--------------------------------------------------------
--  DDL for Package PAY_FR_DADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_DADS_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrdads.pkh 115.0 2003/09/09 01:20 hwinsor noship $ */
--
-- Types
--
type t_asg_h is record(
        start_date         date,
        start_reason       number,
        end_reason         number,
        establishment_id   number,
        company_id         number);

type t_asg_h_tbl is table of t_asg_h index by binary_integer;

function get_parameter (
         p_parameter_string          in varchar2
        ,p_token                     in varchar2
        ,p_segment_number            in number default null)  return varchar2;
--
procedure get_all_parameters (
          p_payroll_action_id                    in number
         ,p_issuing_estab_id                     out nocopy number
         ,p_company_id                           out nocopy number
         ,p_estab_id                             out nocopy number
         ,p_business_group_id                    out nocopy number
         ,p_reference                            out nocopy varchar2
         ,p_start_date                           out nocopy date
         ,p_effective_date                       out nocopy date);
--
procedure range_cursor(
      pactid                         in number
     ,sqlstr                         out nocopy varchar);
--
procedure action_creation(
      pactid                         in number
     ,stperson                       in number
     ,endperson                      in number
     ,chunk                          in number);
--
procedure archive_init(
      p_payroll_action_id            in number);
--
procedure archive_code(
      p_assactid                     in number
     ,p_effective_date               in date);
--
PROCEDURE deinitialize_code(p_payroll_action_id    in number);
--
end PAY_FR_DADS_PKG;

 

/
