--------------------------------------------------------
--  DDL for Package Body HR_TMPLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TMPLT" as
/* $Header: hrfcrlct.pkb 120.2 2005/06/09 18:02:46 pganguly noship $ */
  function get_item_name(
    p_item_id in number ,
    p_application_id in number ,
    p_form_id in number
    )
  return varchar2 is
    l_return varchar2(80);
  begin
    if p_item_id is null then
      l_return := null;
    else
      select full_item_name
      into l_return
      from hr_form_items_b
      where form_item_id = p_item_id
      and application_id = p_application_id
      and form_id = p_form_id;
    end if;
    return l_return;
  end get_item_name;

  function get_formula_name(p_formula_id in number) return varchar2 is
    l_return varchar2(80);
  begin
    if p_formula_id is null then
      l_return := null;
    else
      select formula_name
      into l_return
      from ff_formulas_f
      where formula_id = p_formula_id
      and sysdate between effective_start_date and effective_end_date;
    end if;
    return l_return;
   end get_formula_name;

  FUNCTION get_formula_name(p_element_type_id IN NUMBER,
                            p_effective_date IN DATE) RETURN VARCHAR2 IS
    l_return varchar2(80);

    CURSOR cur_formula_name IS
    SELECT
      ff.formula_name
    FROM
      pay_status_processing_rules_f pspr,
      ff_formulas_f ff
    WHERE
      pspr.element_type_id = p_element_type_id AND
      p_effective_date BETWEEN pspr.effective_start_date AND
                               pspr.effective_end_date AND
      pspr.formula_id = ff.formula_id AND
      p_effective_date BETWEEN ff.effective_start_date AND
                               ff.effective_end_date;
  BEGIN

    IF p_element_type_id IS NULL THEN
      l_return := null;
    ELSE
      OPEN  cur_formula_name;
      FETCH cur_formula_name
      INTO  l_return;
      CLOSE cur_formula_name;
    END IF;

    RETURN l_return;

  END get_formula_name;

  function get_legislation_name(p_formula_id in number) return varchar2 is
    l_return varchar2(80);
    l_leg_code varchar2(30);
  begin
    if p_formula_id is null then
      l_return := null;
    else
      select legislation_code
      into l_leg_code
      from ff_formulas_f
      where formula_id = p_formula_id
      and sysdate between effective_start_date and effective_end_date;

      if l_leg_code is null then
        l_return := null;
      else
        select territory_short_name
        into l_return
        from fnd_territories_vl
        where territory_code = l_leg_code;
      end if;
    end if;
    return l_return;
   end get_legislation_name;
  function get_bus_group_name(p_formula_id in number) return varchar2 is
    l_return varchar2(60);
    l_bus_group_id number;
  begin
    if p_formula_id is null then
      l_return := null;
    else
      select business_group_id
      into l_bus_group_id
      from ff_formulas_f
      where formula_id = p_formula_id
      and sysdate between effective_start_date and effective_end_date;

      if l_bus_group_id is null then
        l_return := null;
      else
        select name
        into l_return
        from per_business_groups
        where business_group_id = l_bus_group_id;
      end if;
    end if;
    return l_return;
   end get_bus_group_name;
  function get_tab_page_name(
    p_form_tab_page_id in number,
    p_form_canvas_id in number
    )
  return varchar2 is
    l_return varchar2(30);
  begin
    if p_form_tab_page_id is null then
      l_return := null;
    else
      select tab_page_name
      into l_return
      from hr_form_tab_pages_b
      where form_tab_page_id = p_form_tab_page_id
      and form_canvas_id = p_form_canvas_id;
    end if;
    return l_return;
  end get_tab_page_name;
  function get_template_name(
    p_form_template_id in number
    )
  return varchar2 is
    l_return varchar2(30);
  begin
    if p_form_template_id is null then
      l_return := null;
    else
      select template_name
      into l_return
      from hr_form_templates_b
      where form_template_id = p_form_template_id;
    end if;
    return l_return;
  end get_template_name;

  function get_application_name(
    p_form_template_id in number
    )
  return varchar2 is
    l_return varchar2(50);
  begin
    if p_form_template_id is null then
      l_return := null;
    else
      select application_short_name
      into l_return
      from hr_form_templates_b hft,
           fnd_application fa
      where hft.form_template_id = p_form_template_id
      and fa.application_id = hft.application_id;
    end if;
    return l_return;
  end get_application_name;

  function get_form_name(
    p_form_template_id in number
    )
  return varchar2 is
    l_return varchar2(50);
  begin
    if p_form_template_id is null then
      l_return := null;
    else
      select form_name
      into l_return
      from hr_form_templates_b hft,
           fnd_form ff
      where hft.form_template_id = p_form_template_id
      and ff.application_id = hft.application_id
      and ff.form_id = hft.form_id;
    end if;
    return l_return;
  end get_form_name;

  FUNCTION get_balance_category(
    p_category_id IN NUMBER
  )
  RETURN VARCHAR2 IS
   l_return pay_balance_categories_f.category_name%TYPE;

   CURSOR cur_balance_category
   IS SELECT
     bcf.category_name
   FROM
     pay_balance_categories_f bcf
   WHERE
     bcf.balance_category_id = p_category_id AND
     SYSDATE BETWEEN bcf.effective_start_date AND
                     bcf.effective_end_date;

  BEGIN

    IF p_category_id IS NULL then
      l_return := NULL;
    ELSE
      OPEN cur_balance_category;
      FETCH cur_balance_category
      INTO  l_return;
      CLOSE  cur_balance_category;
    END IF;

    RETURN l_return;

  END get_balance_category;

END HR_TMPLT;

/
