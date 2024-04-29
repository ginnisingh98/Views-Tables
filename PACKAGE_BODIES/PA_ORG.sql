--------------------------------------------------------
--  DDL for Package Body PA_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ORG" AS
/* $Header: PAORGB.pls 120.2.12010000.4 2009/08/04 09:30:40 srathi ship $ */
--
    /*
    NAME
      pa_os_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE pa_predel_validation (p_org_id   number) IS
  BEGIN
      --
      --      This procedure is not necessary in this version of PA.  All
      --      organization_id references in PA are limited to only those
      --      organizations that belong to the organization hierarchy used by
      --      PA.  The Define Organizations form already ensures that an
      --      organization cannot be deleted if it belongs to a hierarchy.
      --      This procedure remains for possible future use.
      --
        NULL;
  END pa_predel_validation;
  --
  PROCEDURE pa_os_predel_validation (p_org_structure_id   number) IS
-- This procedure checks that if an Org structure has been specified for
-- PA use then it should not be allowed to be deleted.

    dummy1		VARCHAR2(4);	--	into arg for main SELECT
    cursor check_org_structure_exists  is
    select 'X'
    from  pa_implementations_all pai
    where ( (p_org_structure_id = pai.organization_structure_id)
           OR (p_org_structure_id = pai.proj_org_structure_id)
           OR (p_org_structure_id = pai.exp_org_structure_id)
          );
  BEGIN
      --
      --      hr_utility.set_location('PA_ORG.PA_OS_PREDEL_VALIDATION', 1);
      --
    IF (pa_imp.pa_implemented_all) THEN

     -- Check if the Org Structure being deleted
     -- is used in PA Implementations
     --
      open check_org_structure_exists;
      fetch check_org_structure_exists into dummy1;
      if check_org_structure_exists%found then
        hr_utility.set_message (275,'PA_ORG_CANT_DEL_HIER');
        hr_utility.raise_error;
      end if;
      close check_org_structure_exists;

      --
      -- Check if structure being deleted is the struture used for
      -- burdening in PA (10.7+):

      dummy1 := NULL;

      BEGIN
        -- Check if this Org Structure is used for burdening'
        /* Bug 5405854: The check has to be made from pa_ind_rate_sch_revisions
           as this has the details about the burden schedule revisions.
           We should not be looking at the hierarchy attached at the
           Business group.
        SELECT 'X'
          INTO dummy1
          FROM hr_organization_information
         WHERE organization_id = pa_utils.business_group_id
           AND org_information_context = 'Project Burdening Hierarchy'
           AND to_number(org_information1) = p_org_structure_id;
        */

        /* Replacing the above SELECT with the below SELECT statement. */
        SELECT 'X'
          INTO dummy1
          FROM sys.dual
         WHERE exists (
            SELECT 'X'
              FROM pa_ind_rate_sch_revisions ind
             WHERE ind.organization_structure_id = p_org_structure_id
             );
      EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          NULL;
      END;

      IF ( dummy1 IS NOT NULL ) THEN
         hr_utility.set_message (275,'PA_ORG_CANT_DEL_HIER');
         hr_utility.raise_error;
      END IF;


     ELSE
      --   pass validation.
	   NULL;
     END IF;
  END pa_os_predel_validation;
-------------
  PROCEDURE pa_osv_predel_validation (p_org_structure_version_id number) IS
-- This procedure checks that if an Org structure Version  has been specified for
-- PA use then it should not be allowed to be deleted.
--
    dummy1		VARCHAR2(4);	--	into arg for main SELECT
    cursor check_org_structure_ver_exists  is
    select 'X'
    from  pa_implementations_all pai
    where ( (p_org_structure_version_id = pai.org_structure_version_id)
           OR (p_org_structure_version_id = pai.proj_org_structure_version_id)
           OR (p_org_structure_version_id = pai.exp_org_structure_version_id)
          );
  BEGIN
      --
      --      hr_utility.set_location('PA_ORG.PA_OSV_PREDEL_VALIDATION', 1);
      --
    IF (pa_imp.pa_implemented_all) THEN
      --
      -- Check if this Org Struct Version is not in the OSV
      -- named in PA_Implementations
      --
      open check_org_structure_ver_exists;
      fetch check_org_structure_ver_exists into dummy1;
      if check_org_structure_ver_exists%found then
        hr_utility.set_message (275,'PA_ORG_CANT_DEL_HIER');
        hr_utility.raise_error;
      end if;
      close check_org_structure_ver_exists;

      --  Check if structure version being deleted is the structure version
      --  used by PA for burdening (10.7+):

      dummy1 := NULL;

      BEGIN
        --  Check if this Org Structure is used for burdening
        /* Bug 5405854: The check has to be made from pa_ind_rate_sch_revisions
           as this has the details about the burden schedule revisions.
           We should not be looking at the hierarchy attached at the
           Business group.
          SELECT 'X'
          INTO dummy1
          FROM hr_organization_information
         WHERE organization_id = pa_utils.business_group_id
           AND org_information_context = 'Project Burdening Hierarchy'
           AND to_number(org_information2) = p_org_structure_version_id;
        */

        /* Replacing the above SELECT with the below SELECT statement. */
        SELECT 'X'
          INTO dummy1
          FROM sys.dual
         WHERE exists (
            SELECT 'X'
              FROM pa_ind_rate_sch_revisions ind
             WHERE ind.org_structure_version_id = p_org_structure_version_id
             );

      EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          NULL;
      END;

      IF ( dummy1 IS NOT NULL ) THEN
           hr_utility.set_message (275,'PA_ORG_CANT_DEL_OSV');
           hr_utility.raise_error;
      END IF;

    ELSE
      --   pass validation.
	   NULL;
    END IF;
--
  END pa_osv_predel_validation;
--------------
  PROCEDURE pa_ose_predel_validation (p_org_structure_element_id number) IS
-- This procedure checks that if Start Org has been specified for
-- PA use then it should not be allowed to be deleted from the hierarchy.
--
    dummy1		VARCHAR2(4); --	into arg for main SELECT
--
    cursor check_start_org_exists is
      (
           SELECT 'X'
        FROM pa_implementations_all pai,
             per_org_structure_elements ose
        WHERE  p_org_structure_element_id = ose.org_structure_element_id  /*Start-Added for bug:8285339*/
	AND ((pai.org_structure_version_id = ose.org_structure_version_id
        AND pai.start_organization_id   =  ose.organization_id_child)
        OR (pai.proj_org_structure_version_id =  ose.org_structure_version_id
        AND pai.proj_start_org_id   = ose.organization_id_child)
        OR ( pai.exp_org_structure_version_id =  ose.org_structure_version_id
        AND pai.exp_start_org_id = ose.organization_id_child)) /*End-Added for bug:8285339*/
        UNION /* Added for bug 5405854 - Burdening start org */
        SELECT  'X'
        FROM    pa_ind_rate_sch_revisions ind,
                per_org_structure_elements ose
        WHERE   ose.org_structure_element_id = p_org_structure_element_id
	AND     ind.org_structure_version_id = ose.org_structure_version_id
        AND     ind.start_organization_id = ose.organization_id_child

      ) ;
  BEGIN
-- hr_utility.trace_on(null, 'RMBUG');
-- hr_utility.trace('START - pa_ose_predel_validation');
	--
	--	hr_utility.set_location('PA_ORG.PA_OSE_PREDEL_VALIDATION',1);
	--
    IF (pa_imp.pa_implemented_all) THEN
--
--	Check if this Element is the starting org specified in
--      PA_Implementations for Reports, '

      open check_start_org_exists;
      fetch check_start_org_exists into dummy1;
      if check_start_org_exists%found then
        hr_utility.set_message (275,'PA_ORG_CANT_DELETE_STARTORG'); /* Message_name changed for bug fix 1713199 */
        hr_utility.raise_error;
      end if;
      close check_start_org_exists;

        -- Check if structure element is used by PA for burdening (10.7+):

           dummy1 := NULL;

           BEGIN
             -- Check if this Element is in the Project Burdening Hierarchy'
             /* Bug 5405854: The check has to be made from pa_ind_rate_sch_revisions
                as this has the details about the burden schedule revisions.
                We should not be looking at the hierarchy attached at the
                Business group.
             SELECT 'X'
               INTO dummy1
               FROM sys.dual
              WHERE p_org_structure_element_id IN (
		 SELECT org_structure_element_id
		 FROM hr_organization_information info,
		      per_org_structure_elements ose
		 WHERE info.organization_id = pa_utils.business_group_id
		 AND ose.business_group_id = pa_utils.business_group_id
		 AND info.org_information_context = 'Project Burdening Hierarchy'
                 AND to_number(info.org_information2) = ose.org_structure_version_id
                 );
              */
              /* Replacing the above SELECT with the below SELECT statement. */
              /* Check if the organization being deleted is used in Burdening */
-- hr_utility.trace('before check');
-- hr_utility.trace('before check p_org_structure_element_id IS ' || p_org_structure_element_id);
              SELECT 'X'
                INTO dummy1
                FROM sys.dual
               WHERE exists (
                     SELECT icm.organization_id
                       FROM pa_ind_cost_multipliers icm,
                            pa_ind_rate_sch_revisions irr, --Bug 6074710
                            per_org_structure_elements ose
                      WHERE ose.org_structure_element_id = p_org_structure_element_id
			/* Added below 2 conditions for bug 6074710*/
                        AND ose.org_structure_version_id = irr.org_structure_version_id
                        AND icm.ind_rate_sch_revision_id = irr.ind_rate_sch_revision_id);
                       -- AND ose.organization_id_child = icm.organization_id);
       /* Bug 6074710. Commented the above condition as we only need to check the
          existence of any multiplier for that organization hierarchy*/

            EXCEPTION
              WHEN  NO_DATA_FOUND  THEN
-- hr_utility.trace('after check exception');
                NULL;
            END;

-- hr_utility.trace('after check');
            IF ( dummy1 IS NOT NULL ) THEN
                hr_utility.set_message (275,'PA_ORG_DEL_LINK');
                hr_utility.raise_error;
            END IF;

	ELSE
      --   pass validation.
	   NULL;
	END IF;
      --
  END;

  PROCEDURE pa_org_predel_validation (p_org_id number) IS
  -- This procedure will check if the org being deleted
  -- has been specified for PA use.
  -- This procedure will be called from the Define Org form.

    dummy1		VARCHAR2(4); --	into arg for main SELECT
--
    cursor pa_org_exists is
      select 'X'
      from   pa_all_organizations
      where organization_id = p_org_id;

    cursor nlr_org_exists is
      select 'X'
      from   pa_non_labor_resource_orgs
      where organization_id = p_org_id;

    cursor bill_rate_org_exists is
      select 'X'
      from pa_std_bill_rate_schedules
      where organization_id = p_org_id;

  Begin
    open pa_org_exists;
    fetch pa_org_exists into dummy1;
    if pa_org_exists%found then
      hr_utility.set_message (275,'PA_ORG_CANT_DEL_PAORG');
      hr_utility.raise_error;
    end if;
    close pa_org_exists;
--
    open nlr_org_exists;
    fetch nlr_org_exists into dummy1;
    if nlr_org_exists%found then
      hr_utility.set_message (275,'PA_ORG_CANT_DEL_NLRORG');
      hr_utility.raise_error;
    end if;
    close nlr_org_exists;
--
    open bill_rate_org_exists;
    fetch bill_rate_org_exists into dummy1;
    if bill_rate_org_exists%found then
      hr_utility.set_message (275,'PA_ORG_CANT_DEL_BRORG');
      hr_utility.raise_error;
    end if;
    close bill_rate_org_exists;

  End;

END pa_org;

/
