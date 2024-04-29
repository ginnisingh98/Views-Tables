--------------------------------------------------------
--  DDL for Package Body PNP_OTH_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNP_OTH_PROD" AS
  -- $Header: PNOTPRDB.pls 115.2 2002/04/22 18:44:56 pkm ship    $

FUNCTION delete_project (p_project_id IN NUMBER)
-------------------------------------------------------------------------------
-- FUNCTION
--    delete_project
--
-- PURPOSE
--    Function to check project id is being used in Property Manager.
--
-- DESCRIPTION
--    This function checks to see whether passed project id exists in
--    PN_PAYMENT_TERMS table or not. If exists then it returns FALSE
--    else it returns TRUE.
--    This function will be used in Projects Purge program to see if
--    a project id is used in Property Manager before purging projects.
--    As per their design if a project is being used it should not be purged.
--
-- ARGUMENTS
--    IN  : p_project_id
--    OUT : None
--
-- RETURNS
--    Boolean (TRUE/FALSE)
--
-- SCOPE - PUBLIC
--
-- HISTORY
--
--    22-APR-2002   Mrinal Misra   o Created.
--
--------------------------------------------------------------------------------
RETURN BOOLEAN IS

   l_flag           VARCHAR2(1);
   l_project_name   pa_projects_expend_v.project_name%TYPE;

   CURSOR get_proj_name(p_project_id IN NUMBER) IS
      SELECT project_name
      FROM   pa_projects_all_basic_v
      WHERE  project_id = p_project_id;

BEGIN

   OPEN  get_proj_name(p_project_id);
   FETCH get_proj_name INTO l_project_name;
   CLOSE get_proj_name;

   l_flag := 'N';

   SELECT 'Y'
   INTO   l_flag
   FROM   DUAL
   WHERE EXISTS(SELECT NULL
                FROM   PN_PAYMENT_TERMS_ALL
                WHERE  (project_id IS NOT NULL AND -- For Payables.
                        project_id = p_project_id)
                OR     (project_attribute3 IS NOT NULL AND -- For Receivables.
                        project_attribute3 = l_project_name));

   IF l_flag = 'Y' THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN TRUE;

END delete_project;

END PNP_OTH_PROD;

/
