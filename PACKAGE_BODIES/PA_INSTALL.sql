--------------------------------------------------------
--  DDL for Package Body PA_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INSTALL" AS
/* $Header: PAXINSB.pls 120.2.12010000.2 2009/06/23 23:57:07 cklee ship $ */

CRL_INSTALLED  BOOLEAN  :=NULL ;
-- ==========================================================================
-- = FUNCTION  is_pji_installed
--             This function is used to indicate if Utilization Consolidation
--             patch is applied or not. If the function returns 'Y' then
--             it means the PJI utilization model is implemented, otherwise
--             old PJR utilization model is used. This API is used to alter
--             menu's and concurrent programs with different PA responsibilities
-- ==========================================================================

  FUNCTION is_pji_installed RETURN VARCHAR2
  IS
    l_pji_installed VARCHAR2(2);
    l_meaning       VARCHAR2(80);
  BEGIN

    SELECT meaning
    INTO   l_meaning
    FROM fnd_lookup_values
    WHERE lookup_type = 'PA_RES_UTIL_DEF_PERIOD_TYPES'
    AND   lookup_code = 'GE'
and view_application_id = 275 -- 06/23/09  cklee      fixed bug: 6708599
    AND   language = 'US';

    IF l_meaning like 'Enterprise%' THEN
      l_pji_installed := 'Y';
    ELSE
      l_pji_installed := 'N';
    END IF;

    return(l_pji_installed);

  /* Bug :  3558604

    select count(*)
    into   l_count
    from   fnd_tables
    where  application_id = 1292
    and    rownum         = 1
    ;

    if (l_count = 0 )   then
        l_pji_installed := 'N';
    else
        l_pji_installed := 'Y';
    end if;
    return(l_pji_installed); */

  EXCEPTION
    when OTHERS then
        return('N');
 END is_pji_installed;

-- ==========================================================================
-- = FUNCTION  is_pji_licensed
-- ==========================================================================

  FUNCTION is_pji_licensed RETURN VARCHAR2
  IS
    x_pji_installed VARCHAR2(2);
    x_status           VARCHAR2(1) :=NULL ;
  BEGIN

    select p.status
    into   x_status
    from   fnd_product_installations p
    where  p.application_id = (select a.application_id
                               from   fnd_application a
                               where  a.application_short_name = 'PJI'
                              )
    ;

    if (x_status = 'N' OR x_status is null)   then
        x_pji_installed := 'N';
    else
        x_pji_installed := 'Y';
    end if;
    return(x_pji_installed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_pji_licensed;

-- ==========================================================================
-- = FUNCTION  is_billing_licensed
-- ==========================================================================

  FUNCTION is_billing_licensed RETURN VARCHAR2
  IS
    x_pa_billing_installed VARCHAR2(2);
  BEGIN

    if (fnd_profile.value('PA_BILLING_LICENSED') = 'Y') then
        x_pa_billing_installed := 'Y';
    else
        x_pa_billing_installed := 'N';
    end if;
    return(x_pa_billing_installed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_billing_licensed;

-- ==========================================================================
-- = FUNCTION  is_prm_licensed
-- ==========================================================================

  FUNCTION is_prm_licensed RETURN VARCHAR2
  IS
    x_pa_prm_licensed VARCHAR2(2);

  BEGIN

    if (fnd_profile.value('PA_PRM_LICENSED') = 'Y') then
        x_pa_prm_licensed := 'Y';
    else
        x_pa_prm_licensed := 'N';
    end if;
    return(x_pa_prm_licensed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_prm_licensed;

-- ==========================================================================
-- = FUNCTION  is_costing_licensed
-- ==========================================================================

  FUNCTION is_costing_licensed RETURN VARCHAR2
  IS
    x_pa_costing_installed VARCHAR2(2);
    l_status fnd_product_installations.status%type;
  BEGIN

    select status
    into l_status
    from fnd_product_installations
    where application_id = 275;

    if ( l_status = 'I') then
        x_pa_costing_installed := 'Y';
    else
        x_pa_costing_installed := 'N';
    end if;

    return(x_pa_costing_installed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_costing_licensed;

FUNCTION is_product_installed(p_product_short_name IN VARCHAR2)
 RETURN BOOLEAN
 is
  cursor get_application_id is
  select application_id
  from fnd_application
  where application_short_name = p_product_short_name;
  x_application_id fnd_application.application_id%TYPE;

  Cursor get_installation_status is
  select nvl(status,'N') from fnd_product_installations
  where application_id = x_application_id;

  x_status fnd_product_installations.status%TYPE;

Begin
 IF p_product_short_name = 'IPA' then
    if CRL_INSTALLED IS NULL then
       if fnd_profile.value('PA_CRL_LICENSED')='Y' then
          CRL_INSTALLED := TRUE ;
       else
          CRL_INSTALLED := FALSE ;
       end if;
     end if ;
    return CRL_INSTALLED ;
 ELSE
  -- Get the Application_id from the application short name
   open get_application_id;
   fetch get_application_id into x_application_id;
   if(get_application_id%NOTFOUND) then
     close get_application_id;
     return FALSE;
   end if;
   close get_application_id;
 -- Get the application_status I - Installed, S - Installed in shared mode, N - Not Installed
   open get_installation_status;
   fetch get_installation_status into x_status;
   if(get_installation_status%NOTFOUND) then
     close get_installation_status;
     return FALSE;
   end if;
   close get_installation_status;

   if(x_status <> 'N') then
     return TRUE;
  else
     return FALSE;
   end if;
END IF;
end is_product_installed;


-- ==========================================================================
-- = FUNCTION  is_pjt_licensed
-- ==========================================================================

  FUNCTION is_pjt_licensed RETURN VARCHAR2
  IS
    x_pa_pjt_licensed VARCHAR2(2);

  BEGIN

    return 'Y';

--    if (fnd_profile.value('PA_PJT_LICENSED') = 'Y') then
--        x_pa_pjt_licensed := 'Y';
--    else
--        x_pa_pjt_licensed := 'N';
--    end if;
--    return(x_pa_pjt_licensed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_pjt_licensed;


-- ==========================================================================
-- = FUNCTION is_utilization_implemented
-- ==========================================================================

  FUNCTION is_utilization_implemented RETURN VARCHAR2
  IS
   l_utilization_implemented varchar2(1):= 'N';
  BEGIN
	/*
	** Check if Utilization is enabled in the system settings
	** and also if the PJI load program has been run.
	*/
	SELECT 'Y' is_pji_setup
	INTO l_utilization_implemented
	FROM pji_system_settings
	WHERE
	organization_structure_id IS NOT NULL
	AND org_structure_version_id IS NOT NULL
	AND config_util_flag='Y'
	AND EXISTS (
	SELECT 'Y' is_pji_load_program_run
	FROM
	pji_system_parameters
	WHERE NAME = 'LAST_PJI_EXTR_DATE');

	RETURN l_utilization_implemented;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN l_utilization_implemented;
    WHEN OTHERS THEN
	/*
	** retaining this for backward compatibility
	*/
	RETURN 'N';
 END is_utilization_implemented;

-- ==========================================================================
-- = FUNCTION is_ord_mgmt_installed
-- ==========================================================================
FUNCTION is_ord_mgmt_installed RETURN VARCHAR2
  IS
    x_ord_mgmt_installed VARCHAR2(6);
    x_status           VARCHAR2(1) :=NULL ;
  BEGIN

    select p.status
    into   x_status
    from   fnd_product_installations p
    where  p.application_id = (select a.application_id
                               from   fnd_application a
                               where  a.application_short_name = 'ONT'
                              ) ;

    if (x_status = 'N' OR x_status is null)   then
        x_ord_mgmt_installed := 'N';
    else
        x_ord_mgmt_installed := 'Y';
    end if;
    return(x_ord_mgmt_installed);

  EXCEPTION
    when OTHERS then
        return('N');
 END is_ord_mgmt_installed;
END PA_INSTALL;

/
