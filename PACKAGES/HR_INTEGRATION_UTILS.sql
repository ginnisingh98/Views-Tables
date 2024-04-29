--------------------------------------------------------
--  DDL for Package HR_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INTEGRATION_UTILS" AUTHID CURRENT_USER AS
/* $Header: hrintutl.pkh 115.7 2004/09/01 04:07:24 mroberts noship $ */
--
-- -------------------------------------------------------------------------
-- |----------------------< fetch_other_params >---------------------------|
-- -------------------------------------------------------------------------
--
-- Description:
--
--   For a particular form, determines the parameter list in the BNE schema
--   for that form, and then the integrators associated with that
--   parameter list.  These are returned as parameters for the call to
--   Web ADI.
--
-- -------------------------------------------------------------------------
FUNCTION fetch_other_params(p_form_name IN varchar2) RETURN varchar2;
--
FUNCTION fetch_other_letter_params(p_letter IN varchar2) RETURN varchar2;
--
--
-- -------------------------------------------------------------------------
-- |--------------------------< store_sql >--------------------------------|
-- -------------------------------------------------------------------------
--
-- Description:
--
--  Takes some SQL and stores it in the BNE schema, using BNE api.  Uses
--  dynamic SQL to remove the dependency on BNE schema.
--
-- -------------------------------------------------------------------------
FUNCTION store_sql(p_sql IN varchar2, p_date in varchar2) RETURN varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< add_or_update_session >------------------------|
-- -------------------------------------------------------------------------
--
-- Description:
--
--  Takes a date, and adds a row to fnd_sessions table for the current
--  session, or updates the date in the table, if a row already exists.
--  This enables Web ADI queries to be performed against date effective
--  views.
--
-- -------------------------------------------------------------------------
PROCEDURE add_or_update_session(p_sess_date in date);
--
-- -------------------------------------------------------------------------
-- |------------------< add_hr_param_list_to_content >---------------------|
-- -------------------------------------------------------------------------
--
-- Description:
--
--  For the given content, update the content with this parameter list.
--  Required for all Contents to be used from Forms.
--
-- -------------------------------------------------------------------------
PROCEDURE add_hr_param_list_to_content(p_application_id in number
                                      ,p_content_code   in varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------< add_hr_upload_list_to_integ >---------------------|
-- -------------------------------------------------------------------------
--
-- Description:
--
-- For the given integrator, update the metadata with this parameter list.
--
-- -------------------------------------------------------------------------
PROCEDURE add_hr_upload_list_to_integ(p_application_id in number
                                     ,p_integrator_code   in varchar2);
--
-- ------------------------------------------------------------------------
-- | -----------------< register_integrator_to_form >---------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--  Takes an integrator id, and a form name, and registers the integrator
--  for use on that form.
--  The param list for the form MUST exist.
--
-- ------------------------------------------------------------------------
PROCEDURE register_integrator_to_form(p_integrator    in varchar2
                                     ,p_form_name     in varchar2);
--
-- ------------------------------------------------------------------------
-- | ---------------------< process_where_clause >------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--  Takes the FROM and WHERE clause, replaces FROM clause with an ALIAS
--  and alters references to base table to the alias.
--
-- ------------------------------------------------------------------------
FUNCTION process_where_clause(p_where_clause IN varchar2) RETURN varchar2;
--
-- ------------------------------------------------------------------------
-- |------------------------<add_sql_to_content >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--   Takes a SQL statement, and some parameters for that SQL statement,
--   and stores it in the BNE schema, then creates a parameter list for
--   parameters, and definitions if necessary.  This is then assigned to
--   the content also.
--
-- ------------------------------------------------------------------------
PROCEDURE add_sql_to_content
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2
  ,p_param1_name       in varchar2 default NULL
  ,p_param1_type       in varchar2 default NULL
  ,p_param1_prompt     in varchar2 default NULL
  ,p_param2_name       in varchar2 default NULL
  ,p_param2_type       in varchar2 default NULL
  ,p_param2_prompt     in varchar2 default NULL
  ,p_param3_name       in varchar2 default NULL
  ,p_param3_type       in varchar2 default NULL
  ,p_param3_prompt     in varchar2 default NULL
  ,p_param4_name       in varchar2 default NULL
  ,p_param4_type       in varchar2 default NULL
  ,p_param4_prompt     in varchar2 default NULL
  ,p_param5_name       in varchar2 default NULL
  ,p_param5_type       in varchar2 default NULL
  ,p_param5_prompt     in varchar2 default NULL
  );
--
-- ------------------------------------------------------------------------
-- |----------------------< hr_disable_integrator >-----------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--  Allows a customer to disable any customer defined integrator, by
--  setting its enabled flag, and altering the user integrator name.
--  The integrator will also be removed from any parameter lists.
--
-- -----------------------------------------------------------------------
PROCEDURE hr_disable_integrator
  (p_application_short_name  in varchar2
  ,p_integrator_user_name    in varchar2
  ,p_disable                 in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-------------------< hr_create_resp_association >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Called to populate an entry in the HR_ADI_INTG_RESP table, which is
--   a table holding associations between integrators and responsibilities.
--
-- ----------------------------------------------------------------------------
PROCEDURE hr_create_resp_association
  (p_intg_application     IN varchar2
  ,p_integrator_user_name IN varchar2
  ,p_resp_application     IN varchar2
  ,p_responsibility_name  IN varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------< hr_upd_or_del_resp_association >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Called to update or delete an entry in the HR_ADI_INTG_RESP table.  If
--   the resp associated with an integrator is updated to NULL, then it is
--   removed from the table.  Otherwise, the resp_application_id and resp_name
--   fields are updated.
--
-- ----------------------------------------------------------------------------
PROCEDURE hr_upd_or_del_resp_association
  (p_resp_association_id IN number
  ,p_resp_application    IN varchar2 default null
  ,p_responsibility_name IN varchar2 default null
  );
--
--
-- +--------------------------------------------------------------------------+
-- |--------------------< hr_maint_form_func_association >--------------------|
-- +--------------------------------------------------------------------------+
--
-- Description:
--   Called to create, update or delete entries in the BNE schema delivered
--   to allow form functions to be associated with integrators.
--
-- +--------------------------------------------------------------------------+
PROCEDURE hr_maint_form_func_association
  (p_intg_application     IN varchar2
  ,p_integrator_user_name IN varchar2
  ,p_security_value       IN varchar2
  );
--
FUNCTION fetchname
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2;
--
FUNCTION fetchtype
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2;
--
FUNCTION fetchprompt
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2;
--
END hr_integration_utils;

 

/
