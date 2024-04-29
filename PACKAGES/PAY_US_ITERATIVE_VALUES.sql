--------------------------------------------------------
--  DDL for Package PAY_US_ITERATIVE_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ITERATIVE_VALUES" AUTHID CURRENT_USER AS
/* $Header: pyusifun.pkh 120.0.12010000.2 2009/04/03 09:16:42 svannian ship $ */

   TYPE iter_data_rec IS RECORD (
      entry_id    number,
      asg_id      number,
      iter_no     number,
      max_dedn    number,
      min_dedn    number,
      new_dedn    number,
      des_amt     number,
      calc_method varchar2(20),
      to_within   number,
      clr_add_amt number,
      clr_rep_amt number );

  TYPE iter_info_tab IS TABLE OF iter_data_rec
  INDEX BY BINARY_INTEGER;

  iter_val      iter_info_tab;

/* to store the stopper flag */

   TYPE iter_stop_rec IS RECORD (
      entry_id    number,
      asg_id      number,
      stop_flag   varchar2(5));

  TYPE iter_stop_tab IS TABLE OF iter_stop_rec
  INDEX BY BINARY_INTEGER;

  iter_stop      iter_stop_tab;

/* to indicate that pretax is being processed */

   TYPE iter_ele_type_rec IS RECORD (
      entry_id    number,
      asg_id      number,
      ele_type    varchar2(50));

  TYPE iter_ele_type_tab IS TABLE OF iter_ele_type_rec
  INDEX BY BINARY_INTEGER;

  iter_ele_type      iter_ele_type_tab;

/* to store the inserted flag */

  TYPE iter_ins_rec IS RECORD (
      entry_id    number,
      asg_id      number,
      ins_flag    varchar2(5));

  TYPE iter_ins_tab IS TABLE OF iter_ins_rec
  INDEX BY BINARY_INTEGER;

  iter_ins      iter_ins_tab;

/* to store various amounts required for 401, 403 and 457 elements */

  TYPE iter_amt_rec IS RECORD (
      entry_id    number,
      asg_id      number,
      calc_amt    number,
      passed_amt  number );

  TYPE iter_amt_tab IS TABLE OF iter_amt_rec
  INDEX BY BINARY_INTEGER;

  iter_amt      iter_amt_tab;

  g_aaid    pay_assignment_actions.assignment_action_id%TYPE := 0;

FUNCTION get_stopper_flag ( p_entry_id      in     number)
RETURN varchar2 ;

FUNCTION set_stopper_flag(p_entry_id      in number,
                          p_asg_id        in number,
                          p_stopper_flag  in VARCHAR2)
RETURN number;

FUNCTION get_iterative_value(
                          p_entry_id        in  number,
			  iteration_number  in  number,
			  max_deduction     out nocopy number,
			  min_deduction     out nocopy number,
                          p_desired_amt     out nocopy number,
                          p_calc_method     out nocopy varchar2,
                          p_to_within       out nocopy number,
                          p_clr_add_amt     out nocopy number,
                          p_clr_rep_amt     out nocopy number)
return number ;

FUNCTION set_iterative_value(
                          p_entry_id        in number,
                          p_asg_id          in number,
			  iteration_number  in number,
			  max_deduction     in number,
			  min_deduction     in number,
                          new_deduction     in number,
                          p_desired_amt     in number,
                          p_calc_method     in varchar2,
                          p_to_within       in number,
                          p_clr_add_amt     in number,
                          p_clr_rep_amt     in number )
return number ;

FUNCTION clear_iterative_value(p_entry_id        in  number)
return number ;

FUNCTION clear_on_asg(p_asg_id        in  number,
                      p_aaid          in  number)
return number ;

FUNCTION get_iter_count(p_entry_id in  number )
return number;

FUNCTION inc_iter_count(p_entry_id in  number)
return number;

FUNCTION Iterative_Arrearage (  p_eletype_id            IN NUMBER,
                        p_date_earned           IN DATE,
                        p_assignment_id         IN NUMBER ,
                        p_ele_entry_id          IN NUMBER,
                        p_partial_flag          IN VARCHAR2 DEFAULT 'N',
                        p_net_asg_run           IN NUMBER,
                        p_arrears_itd           IN NUMBER,
                        p_guaranteed_net        IN NUMBER,
                        p_dedn_amt              IN NUMBER,
                        p_amount                IN NUMBER,
                        p_iter_count            IN NUMBER,
                        p_to_arrears            IN OUT nocopy NUMBER,
                        p_not_taken             IN OUT nocopy NUMBER,
                        p_ins_flag              IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;

FUNCTION reduces_disposable_income (
                        p_assignment_id   IN NUMBER,
                        p_date_earned     IN DATE,
                        p_element_type_id IN NUMBER,
                        p_tax_type        IN pay_balance_types.tax_type%TYPE)
RETURN VARCHAR2;

FUNCTION partial_deduction_allowed (
                        p_element_type_id   IN NUMBER,
                        p_date_earned       IN DATE )
RETURN VARCHAR2;

FUNCTION set_processing_element (p_asg_id   in  number,
                                 p_ele_type in  varchar2)
RETURN NUMBER;

FUNCTION get_processing_element (p_ele_type in  varchar2)
RETURN VARCHAR2;

FUNCTION set_inserted_flag (p_entry_id in  number,
                            p_asg_id   in  number,
                            p_ins_flag in  varchar2 )
RETURN VARCHAR2;

FUNCTION get_inserted_flag (p_entry_id in  number)
RETURN VARCHAR2;

FUNCTION get_iter_amt(p_entry_id   in     number,
                      p_passed_amt in out nocopy number )
return number;

FUNCTION set_iter_amt(p_entry_id   in  number,
                      p_asg_id     in  number,
                      p_calc_amt   in  number,
                      p_passed_amt in  number)
return number;

FUNCTION clear_iter_ins
return number;

end pay_us_iterative_values;

/
