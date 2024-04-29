--------------------------------------------------------
--  DDL for Package PAY_COSTING_DETAIL_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COSTING_DETAIL_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: pycstrep.pkh 120.0 2005/05/29 04:15:44 appldev noship $ */

  PROCEDURE costing_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_selection_criteria        in  varchar2
             ,p_is_ele_set                in  varchar2
             ,p_element_set_id            in  number
             ,p_is_ele_class              in  varchar2
             ,p_element_classification_id in  number
             ,p_is_ele                    in  varchar2
             ,p_element_type_id           in  number
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_person_id                 in  number
             ,p_assignment_set_id         in  number
             ,p_cost_type                 in varchar2
             ,p_output_file_type          in  varchar2
             );


  /**************************************************************
  ** PL/SQL table of records to store Costing Segment Label and
  ** Application Column used.
  ***************************************************************/
  TYPE costing_rec  IS RECORD (segment_label  varchar2(100),
                               column_name    varchar2(100));
  TYPE costing_tab IS TABLE OF costing_rec INDEX BY BINARY_INTEGER;

  TYPE tab_tax_unit_name is TABLE OF HR_ORGANIZATION_UNITS.NAME%TYPE index by BINARY_INTEGER;
  g_tax_unit_name     tab_tax_unit_name;

  function get_costing_tax_unit_id(p_ACTION_TYPE            pay_payroll_actions.action_type%TYPE,
                                    p_TAX_UNIT_ID            pay_assignment_actions.TAX_UNIT_ID%TYPE,
                                    p_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE,
                                    p_element_type_id        pay_element_types_f.element_type_id%TYPE
                                   ) return number;
  function get_costing_tax_unit_name(p_tax_unit_id   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE)
    return VARCHAR2;

end pay_costing_detail_rep_pkg;

 

/
