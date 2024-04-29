--------------------------------------------------------
--  DDL for Package Body XLA_OA_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_OA_FUNCTIONS_PKG" AS
/* $Header: xlaoaftn.pkb 120.3 2003/04/26 00:38:04 wychan ship $ */

-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================


--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_ccid_description
  (p_coa_id             IN INTEGER
  ,p_ccid               IN INTEGER)
RETURN VARCHAR2
IS
  l_desc	VARCHAR2(2400) := null;
BEGIN
  xla_utility_pkg.trace('> .get_ccid_description', 20);

  if (fnd_flex_keyval.validate_ccid('SQLGL', 'GL#', p_coa_id, p_ccid)) then
    l_desc := fnd_flex_keyval.concatenated_descriptions;
  end if;

  xla_utility_pkg.trace('< .get_ccid_description', 20);
  return l_desc;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_oa_functions_pkg.get_ccid_description');

END get_ccid_description;

FUNCTION get_message
  (p_encoded_msg	IN VARCHAR2)
RETURN VARCHAR2
IS
  l_msg 	VARCHAR2(2000);
BEGIN
  xla_utility_pkg.trace('> .get_message', 20);

  fnd_message.set_encoded(p_encoded_msg);
  l_msg := fnd_message.get();

  xla_utility_pkg.trace('< .get_message', 20);
  return l_msg;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_oa_functions_pkg.get_message');

END get_message;


end xla_oa_functions_pkg;

/
