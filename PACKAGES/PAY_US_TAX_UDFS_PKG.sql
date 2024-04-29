--------------------------------------------------------
--  DDL for Package PAY_US_TAX_UDFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_UDFS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyustudf.pkh 115.4 2004/06/24 10:58:14 ppanda noship $ */

   TYPE etei_data_rec IS RECORD (
      asg_act_id  pay_assignment_actions.assignment_action_id%TYPE,
      ele_type_id pay_element_types_f.element_type_id%TYPE,
      state_code  pay_us_states.state_code%TYPE,
      calc_method fnd_lookup_values.lookup_code%TYPE
      );

  TYPE etei_data_tab IS TABLE OF etei_data_rec
  INDEX BY BINARY_INTEGER;

   etei_data_val       etei_data_tab;

-------------------------- get_alternate_flat_rate_calc_method ----------
--

FUNCTION get_altrnt_flat_rate_calc_meth(p_assignment_action_id in number,
                                        p_state_code           in varchar2)
RETURN VARCHAR2;
-------------------------- set_proc_ele_state_method -------------------
--

FUNCTION set_altrnt_flat_rate_calc_meth(
                                   p_assignment_action_id in number,
                                   p_element_type_id      in number,
                                   p_date_earned          in date,
                                   p_state_code           in varchar2 default 'NOT_APPLICABLE',
                                   p_calc_method          in varchar2 default 'NOT_APPLICABLE')
RETURN NUMBER;

--

end pay_us_tax_udfs_pkg;

 

/
