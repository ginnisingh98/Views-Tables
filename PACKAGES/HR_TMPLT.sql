--------------------------------------------------------
--  DDL for Package HR_TMPLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TMPLT" AUTHID CURRENT_USER as
/* $Header: hrfcrlct.pkh 120.2 2005/06/09 18:01:54 pganguly noship $ */

  function get_item_name (
    p_item_id in number,
    p_application_id in number ,
    p_form_id in number
    )
  return varchar2;
  function get_formula_name(p_formula_id in number) return varchar2;

  function get_formula_name(p_element_type_id IN NUMBER,
                            p_effective_date IN DATE) return varchar2;

  function get_legislation_name(p_formula_id in number) return varchar2;

  function get_bus_group_name(p_formula_id in number) return varchar2;

  function get_tab_page_name(p_form_tab_page_id in number,
                             p_form_canvas_id in number) return varchar2;

  function get_template_name(p_form_template_id in number) return varchar2;

  function get_application_name(p_form_template_id in number) return varchar2;

  function get_form_name(p_form_template_id in number) return varchar2;

  function get_balance_category(p_category_id NUMBER) return varchar2;

end HR_TMPLT;

 

/
