--------------------------------------------------------
--  DDL for Package PQH_PRVCALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PRVCALC" AUTHID CURRENT_USER as
/* $Header: pqprvcal.pkh 115.13 2002/12/03 20:42:30 rpasapul ship $ */

  type t_task_templ is table of pqh_template_attributes.template_id%type
    index by binary_integer ;

  type t_attid_priv_typ is record (
    Attribute_id pqh_attributes.attribute_id%type,
    task_type varchar2(1),
    mode_flag varchar2(1),
    reqd_flag varchar2(1) );

  type t_attid_priv is table of t_attid_priv_typ
   index by binary_integer ;

  type t_attname_priv_typ is record (
    form_column_name varchar2(100),
    mode_flag varchar2(1),
    reqd_flag varchar2(1));

  type t_attname_priv is table of t_attname_priv_typ
    index by binary_integer ;

  type t_blocks is table of varchar2(40)
    index by binary_integer;

-- global variable to hold the result and return onw by one
  g_result t_attname_priv;

--
-- ----------------------------------------------------------------------------
-- |------------------------< domain_result_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure domain_result_calc (p_domain in pqh_template_attributes.template_id%type,
                              p_result    out nocopy t_attid_priv);

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_references >------------------------|
-- ----------------------------------------------------------------------------
--

procedure task_references(p_task       in pqh_template_attributes.template_id%type,
                          p_result_int in out nocopy t_attid_priv);

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_result_update >------------------------|
-- ----------------------------------------------------------------------------
--

procedure task_result_update(p_task       in pqh_template_attributes.template_id%type,
			     p_task_type  in varchar2,
                             p_result_int in out nocopy t_attid_priv);

--
-- ----------------------------------------------------------------------------
-- |------------------------< attribute_flag_result >------------------------|
-- ----------------------------------------------------------------------------
--

procedure attribute_flag_result (p_edit_flag   in varchar2,
                                 p_view_flag   in varchar2,
                                 p_result_flag    out nocopy varchar2 );

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_task_mode_comp_flag >------------------------|
-- ----------------------------------------------------------------------------
--

procedure task_task_mode_comp_flag (p_task1_flag  in varchar2,
                                    p_task2_flag  in varchar2 ,
                                    p_result_flag    out nocopy varchar2 );

--
-- ----------------------------------------------------------------------------
-- |------------------------< domain_task_mode_comp_flag >------------------------|
-- ----------------------------------------------------------------------------
--

procedure domain_task_mode_comp_flag (p_domain_mode_flag in varchar2,
                                      p_task_mode_flag   in varchar2,
                                      p_result_flag         out nocopy varchar2 );

--
-- ----------------------------------------------------------------------------
-- |------------------------< priviledge_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure priviledge_calc (p_domain in pqh_template_attributes.template_id%type,
                           p_tasks  in t_task_templ,
  		           p_transaction_category_id in number,
                           p_result    out nocopy t_attname_priv );

--
-- ----------------------------------------------------------------------------
-- |------------------------< template_attrib_reqd_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure template_attrib_reqd_calc (p_tasks in t_task_templ,
				     p_transaction_category_id in number,
                                     p_result   out nocopy t_attname_priv);


--
-- ----------------------------------------------------------------------------
-- |------------------------< get_row_prv >------------------------|
-- ----------------------------------------------------------------------------
--

procedure get_row_prv( p_row            in number,
                       p_form_column_name    out nocopy pqh_txn_category_attributes.form_column_name%type,
                       p_mode_flag         out nocopy varchar2,
                       p_reqd_flag         out nocopy varchar2);

--
-- ----------------------------------------------------------------------------
-- |------------------------< check_priv_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure check_priv_calc;

--
-- ----------------------------------------------------------------------------
-- |------------------------< priviledge_calc_count >------------------------|
-- ----------------------------------------------------------------------------
--

procedure priviledge_calc_count (p_domain       in pqh_template_attributes.template_id%type,
                                 p_tasks        in t_task_templ,
				 p_transaction_category_id in number,
			         p_result_count    out nocopy number ) ;

--
-- ----------------------------------------------------------------------------
-- |------------------------< get_attribute_mode >----------------------------|
-- ----------------------------------------------------------------------------
--

function get_attribute_mode(p_form_column_name       in varchar2) return varchar2;

end pqh_prvcalc;

 

/
