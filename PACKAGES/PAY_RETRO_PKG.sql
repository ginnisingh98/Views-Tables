--------------------------------------------------------
--  DDL for Package PAY_RETRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_PKG" 
/* $Header: pyretpay.pkh 120.6.12010000.1 2008/07/27 23:33:02 appldev ship $ */
AUTHID CURRENT_USER as
--
--
/*
PRODUCT
    Oracle*Payroll
--
NAME
   pyretpay.pkh
--
DESCRIPTION
--
    MODIFIED  (DD-MON-YYYY)
    kkawol     02-AUG-2007 Added reset_recorded_request and
                           process_recorded_request.
    nbristow   15-JAN-2006 Added overlap_adjustments.
    nbristow   12-SEP-2006 Added new get_entry_path.
    nbristow   01-JUN-2006 Added process_retro_entry.
    nbristow   14-MAR-2006 Added get_retro_asg_id.
    kkawol     26-JAN-2006 added get_entry_path to convert entry
                           paths for retropay into new shorter format.
    nbristow   25-NOV-2004 Allow Retropaying multi assignments.
    jford      07-SEP-2004 get_retro_component_id, 3 params in pyretutl.pkh
    tbattoo    09-AUG-2004 Added functions to suport reversals in retropay
    jford      27-JUL-2004 maintain_retro_entry
    nbristow   14-JUL-2004 Changes for Enhanced Retro Notifiction.
    nbristow   15-MAR-2004 Added is_retro_rr.
    kkawol     09-DEC-2003 Added latest_replace_ovl_ee,
                           latest_replace_ovl_del_ee.
    kkawol     20-NOV-2003 Passing bus grp id to get_retro_element,
                           this is required when calling is_date_in_span.
    nbristow   07-OCT-2003 Added nocopy to get_ee_overlap_date.
    nbristow   07-OCT-2003 Added process_retro_value.
    nbristow   03-OCT-2003 Added get_ee_overlap_date.
    nbristow   02-SEP-2003 Changed get_retro_element to
                           return correct element.
    nbristow   28-AUG-2003 Added dbdrv statements.
    nbristow   27-AUG-2003 Changes for Advanced Retropay.
    jalloun    30-JUL-1996 Added error handling.
    nbristow   12-MAR-1996 Created.
*/
   procedure retro_run_proc;
   procedure retro_end_proc;
function process_retro_entry(
                       p_element_entry_id in number,
                       p_element_type_id  in number,
                       p_retro_comp_id    in number,
                       p_retro_asg_id     in number,
                       p_ee_creator_id    in number,
                       p_action_sequence  in number
                      )
return number;
function get_rr_source_id(p_rr_id in number)
return number;
function get_rr_source_type(p_rr_id in number)
return varchar2;
function process_value(p_value_type      in varchar2,
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_result_type     in varchar2)
return varchar2;
function is_retro_entry(p_creator_type in varchar2)
return number;
function is_retro_rr(p_element_entry_id in number,
                        p_date             in date)
return number;
function get_reprocess_type(
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_default_type    in varchar2 default 'R'
                      )
return varchar2;
function get_retro_process_type(
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_source_type     in varchar2
                      )
return varchar2;
function get_source_element_type (p_entry_id in number,
                                  p_aa_id    in number)
return number;
--
procedure get_retro_element(p_element_type_id   in            number,
                            p_retro_eff_date    in            date,
                            p_run_eff_date      in            date,
                            p_retro_comp_id     in            number,
                            p_adjustment_type   in            varchar2,
                            p_retro_ele_type_id    out nocopy number,
                            p_business_group_id in number default null
                           );
function process_retro_value(
                             p_entry_id        in number,
                             p_element_type_id in number,
                             p_retro_comp_id   in number,
                             p_retro_asg_id    in number
                             )
return varchar2;
--
procedure get_ee_overlap_date(p_assact         in            number,
                              p_start_date     in            date,
                              p_effective_date in            date,
                              p_adj_start_date    out nocopy date
                             );
--
function latest_replace_ovl_ee ( p_element_entry_id in NUMBER)
return varchar2;
--
function latest_replace_ovl_del_ee ( p_element_entry_id in NUMBER)
return varchar2;
--
FUNCTION get_retro_component_id (
                          p_element_entry_id in number,
                          p_ef_date          in date)
                   return number;
--
procedure maintain_retro_entry
(
          p_retro_assignment_id    IN NUMBER
  ,       p_element_entry_id       IN NUMBER
  ,       p_element_type_id        IN NUMBER
  ,       p_reprocess_date         IN DATE
  ,       p_eff_date               IN DATE
  ,       p_retro_component_id     IN NUMBER
  ,       p_owner_type             IN VARCHAR2 default 'S' --System
  ,       p_system_reprocess_date  IN DATE     default hr_api.g_eot
);
--
procedure merge_retro_assignments(p_asg_act_id in number);
--
procedure generate_obj_grp_actions (p_pactid       in number,
                                    p_chunk_number in number);
--
function get_asg_from_pg_action(p_obj_grp_id in number,
                                p_obj_type   in varchar2,
                                p_pactid     in number)
return number;
--
function get_entry_path( p_entry_process_path in varchar2,
                         p_source_type in varchar2,
                         p_element_type_id in number,
                         p_run_result_id in number)
return varchar2;
function get_entry_path( p_run_result_id in number)
return varchar2;
--
function get_retro_asg_id(p_assignment_action in number)
return number;
--
procedure overlap_adjustments(p_asg_act_id    in number,
                              p_definition_id in number,
                              p_component_id  in number,
                              p_ele_set_id    in number
                             );
--
function process_recorded_date (p_process in varchar2,
                                p_assignment_id in varchar2,
                                p_adj_start_date in date,
                                p_assact_id in number)
return date;
--
procedure reset_recorded_request(p_assact_id in number);
--
end pay_retro_pkg;

/
