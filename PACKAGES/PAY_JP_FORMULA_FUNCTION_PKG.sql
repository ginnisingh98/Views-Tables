--------------------------------------------------------
--  DDL for Package PAY_JP_FORMULA_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_FORMULA_FUNCTION_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjpffuc.pkh 120.0.12010000.2 2009/02/09 05:49:22 keyazawa ship $ */
/* ------------------------------------------------------------------------------------ */
--
g_legislation_code  per_business_groups.legislation_code%type;
g_business_group_id number;
g_effective_date date;
g_session_id number;
--
type t_glb_rec is record(
  global_name  ff_globals_f.global_name%type,
  global_value ff_globals_f.global_value%type);
--
type t_glb_tbl is table of t_glb_rec index by binary_integer;
--
g_glb_tbl t_glb_tbl;
--
FUNCTION get_table_value_with_default(
		p_business_group_id	IN NUMBER,
		p_table_name		IN VARCHAR2,
		p_column_name		IN VARCHAR2,
		p_row_value		IN VARCHAR2,
		p_effective_date	IN DATE DEFAULT NULL,
		p_default_value		IN VARCHAR2,
		p_default_by_row	IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;
/* ------------------------------------------------------------------------------------ */
FUNCTION chk_smc(
		p_table_name		IN      VARCHAR2,
		p_column_name		IN      VARCHAR2,
		p_effective_date	IN      DATE,
		p_value			IN      VARCHAR2)
RETURN VARCHAR2;
/* ------------------------------------------------------------------------------------ */
-- ----------------------------------------------------------------------------
-- |----------------------------< get_jp_parameter >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns the parameter value of hr_jp_parameters.
--
-- Prerequisites:
--  None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_owner                        Yes  VARCHAR2 owner of the parameter.
--   p_parameter_name               Yes  VARCHAR2 parameter name.
--
-- Post Success:
--   Returns the parameter value.  If the specified parameter does not exist,
--   returns NULL.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Development Use.
--
-- {End Of Comments}
--
 FUNCTION get_jp_parameter(
  p_owner               IN      VARCHAR2,
  p_parameter_name      IN      VARCHAR2) RETURN VARCHAR2;
 --
--
function get_global_value(
  p_business_group_id in number,
  p_global_name       in varchar2,
  p_effective_date    in date default null)
return varchar2;
--
END pay_jp_formula_function_pkg;

/
