--------------------------------------------------------
--  DDL for Package Body FND_ACCESS_CONTROL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ACCESS_CONTROL_UTIL" AS
/* $Header: AFACUTLB.pls 120.1.12010000.5 2017/03/16 15:07:34 emiranda ship $ */

--
-- Name
--   Get_Org_Name
-- Purpose
--   Return the Organization Name based on the passed ORG_ID
--   This function is called in the multi-org stripped views
--   to display organization name without joining to the HR table
--   Since the multi-org stripped views are used as base tables,
--   to use function in the select clause can have better performance
-- Arguments
--   p_org_id
--
FUNCTION Get_Org_Name( p_org_id NUMBER )
RETURN VARCHAR2
IS
  l_return hr_all_organization_units_tl.name%TYPE;
BEGIN

  BEGIN
    SELECT name
    INTO   l_return
    FROM   hr_all_organization_units_tl
    WHERE  organization_id = p_org_id
    AND    language = userenv('LANG');

/* Commented out the following lines of code since exception
   is not raised properly
   IF SQL%NOTFOUND
   THEN
     l_return := NULL;
   END IF;
*/
   EXCEPTION
     WHEN no_data_found THEN
       l_return := NULL;
   END;

   RETURN l_return;

END Get_Org_Name;


--
-- Name
--   Policy_Exists
-- Purpose
--   Check if a policy is already attached to the object.
--   This function is called in the Drop_Policy and
--   the Add_Policy procedure
-- Arguments
--   p_object_schema
--   p_object_name
--   p_policy_name
--
FUNCTION Policy_Exists(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
) RETURN VARCHAR2
IS

  l_return   VARCHAR2(10) := 'FALSE';

  CURSOR c_policy_exists
  ( xp_object_schema    VARCHAR2
  , xp_object_name      VARCHAR2
  , xp_policy_name      VARCHAR2
  )
  IS
    SELECT  'TRUE'
    FROM    sys.dual
    WHERE   EXISTS
      (SELECT  1
       FROM    sys.dba_policies
       WHERE   object_owner = UPPER(xp_object_schema)
       AND     object_name  = UPPER(xp_object_name)
       AND     policy_name  = UPPER(xp_policy_name)
      );

BEGIN

  OPEN c_policy_exists(p_object_schema, p_object_name, p_policy_name);
  FETCH c_policy_exists INTO l_return;

  CLOSE c_policy_exists;

  RETURN l_return;

END Policy_Exists;


--
-- Name
--   Add_Policy
-- Purpose
--   This is a wrapper for the DBMS_RLS.Add_Policy procedure
--   This procedure will check if a policy exists before
--   adding a policy
--   The add_policy procedure should be executed in the en phase
--   during AutoInstall processing
-- Arguments
--   p_object_schema
--   p_object_name
--   p_policy_name
--   p_function_schema
--   p_policy_function
--   p_statement_types
--   p_update_check
--   p_enable
--
PROCEDURE Add_Policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
, p_function_schema     IN VARCHAR2
, p_policy_function     IN VARCHAR2
, p_statement_types     IN VARCHAR2 := 'SELECT, INSERT, UPDATE, DELETE'
, p_update_check        IN BOOLEAN  := TRUE
, p_enable              IN BOOLEAN  := TRUE
)
IS
BEGIN

  ADD_POLICY(
    p_object_schema       => p_object_schema,
    p_object_name         => p_object_name,
    p_policy_name         => p_policy_name,
    p_function_schema     => p_function_schema,
    p_policy_function     => p_policy_function,
    p_statement_types     => p_statement_types,
    p_update_check        => p_update_check,
    p_enable              => p_enable,
    p_static_policy       => FALSE
  );

END Add_Policy;


--
-- Name
--   Drop_Policy
-- Purpose
--   This is a wrapper for the DBMS_RLS.Drop_Policy procedure
--   This procedure will check if a policy exists before
--   droping a policy
--   The drop_policy procedure should be executed in the con phase
--   during AutoInstall processing
-- Arguments
--   p_object_schema
--   p_object_name
--   p_policy_name
--
PROCEDURE drop_policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
)
IS
BEGIN

  IF policy_exists(  p_object_schema
                   , p_object_name
                   , p_policy_name ) = 'TRUE'
  THEN
    DBMS_RLS.DROP_POLICY(
      p_object_schema
    , p_object_name
    , p_policy_name
    );
  END IF;

END drop_policy;

--
-- Name
--   Add_Policy
-- Purpose
--   This is a wrapper for the DBMS_RLS.Add_Policy procedure
--   This procedure will check if a policy exists before
--   adding a policy
--   The add_policy procedure should be executed in the en phase
--   during AutoInstall processing
--   p_policy_type has been added for bug#13059469, since the default
--   for p_policy_type in DBMS_RLS package is null same is being passed here.
-- Arguments
--   p_object_schema
--   p_object_name
--   p_policy_name
--   p_function_schema
--   p_policy_function
--   p_statement_types
--   p_update_check
--   p_enable
--   p_static_policy
--   p_policy_type
--
PROCEDURE Add_Policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
, p_function_schema     IN VARCHAR2
, p_policy_function     IN VARCHAR2
, p_statement_types     IN VARCHAR2 := 'SELECT, INSERT, UPDATE, DELETE'
, p_update_check        IN BOOLEAN  := TRUE
, p_enable              IN BOOLEAN  := TRUE
, p_static_policy       IN BOOLEAN
, p_policy_type         IN BINARY_INTEGER
)
IS

BEGIN

  IF policy_exists(  p_object_schema
                   , p_object_name
                   , p_policy_name ) = 'TRUE'
  THEN
    DBMS_RLS.DROP_POLICY(
      p_object_schema
    , p_object_name
    , p_policy_name
    );
  END IF;

        DBMS_RLS.ADD_POLICY (
		object_schema   => p_object_schema,
		object_name     => p_object_name,
		policy_name     => p_policy_name,
                function_schema => p_function_schema,
		policy_function => p_policy_function,
		statement_types => p_statement_types,
		update_check    => p_update_check,
		enable          => p_enable,
		static_policy   => p_static_policy,
		policy_type	=> p_policy_type
		);

END Add_Policy;


END fnd_access_control_util;

/
