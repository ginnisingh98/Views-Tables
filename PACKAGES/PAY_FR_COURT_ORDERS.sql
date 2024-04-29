--------------------------------------------------------
--  DDL for Package PAY_FR_COURT_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_COURT_ORDERS" AUTHID CURRENT_USER as
/* $Header: pyfrcord.pkh 115.3 2002/11/25 15:53:52 asnell noship $ */
--
function process (p_assignment_action_id     in number
                 ,p_date_earned              in date
                 ,p_source_id                in number
                 ,p_net_payment_ptd          in number
                 ,p_rmi                      in number
                 ,p_addl_threshold_per_dpndt in number
                 ,p_addl_seizable            in number
                 ,p_error_msg                out nocopy varchar2) return number;
--
function get_balance_value(p_element_name         in varchar2
                          ,p_dimension_name       in varchar2
                          ,p_source_id            in number
                          ,p_assignment_action_id in number) return number;
--
function co_payment (p_source_id in number) return number;
--
function validation return varchar2;
--
function map_names (p_direct_name   in varchar2 default null
                   ,p_indirect_name in varchar2 default null) return varchar2;
--
function direct_to_indirect (p_direct_name in varchar2) return varchar2;
--
function indirect_to_direct (p_indirect_name in varchar2) return varchar2;
--
function get_payment (p_source_id         in number
                     ,p_payment_reference in varchar2
                     ,p_element_name      in varchar2
                     ,p_message           out nocopy varchar2
                     ,p_message_text      out nocopy varchar2
                     ,p_stop              out nocopy varchar2) return number;
--
function processed (p_assignment_action_id in number) return varchar2;
--
function net_pay_valid return varchar2;
--
g_assignment_action_id number;
g_funds                number;
g_net_pay_valid        varchar2(1);
--
/* This record holds all information for each individual court order
   processed per assignment. It is indexed by Element Source ID*/
type court_order_record is record
  ( reference_code      number
   ,monthly_payment     number
   ,amount              number
   ,outstanding_balance number
   ,balance_ptd         number
   ,priority            number
   ,payment             number
   ,processing_order    number);
--
/* This record holds all summed information on each court order
   - it is grouped, and indexed, by priority */
type total_court_order_record is record
  ( monthly_payment     number
   ,amount              number
   ,outstanding_balance number
   ,start_pos           number
   ,end_pos             number
   ,payment             number
   ,number_of_orders    number);
--
type map_element_record is record
  ( indirect_name varchar2(80) default null
   ,direct_name   varchar2(80) default null);
--
/* This holds the order in which elements were processed
   and is indexed by a sequence - representing that order */
type court_order_id is record
  ( source_id           number);
--
type court_order_tab is table of court_order_record
  index by Binary_Integer;
--
type total_order_tab is table of total_court_order_record
  index by Binary_Integer;
--
type court_order_index_tab is table of court_order_id
  index by Binary_Integer;
--
type map_element_record_tab is table of map_element_record
  index by Binary_Integer;
--
court_order       court_order_tab;
total_order       total_order_tab;
court_order_index court_order_index_tab;
map_element       map_element_record_tab;
court_order_null  court_order_tab;
total_order_null  total_order_tab;
court_order_index_null court_order_index_tab;
--
end pay_fr_court_orders;

 

/
