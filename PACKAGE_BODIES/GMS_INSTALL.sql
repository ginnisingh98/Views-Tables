--------------------------------------------------------
--  DDL for Package Body GMS_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_INSTALL" as
-- $Header: GMSINSTB.pls 120.6 2006/07/30 20:19:08 spunathi noship $


-- ------------------------------------------------------------------+
-- --------------------- MOAC CHANGES START -------------------------+
-- ------------------------------------------------------------------+
-- Function ENABLED and ENABLED(x_org_id number) rewritten on
-- Jul-22-05 .. K.Biju
-- ------------------------------------------------------------------+
FUNCTION ENABLED return boolean
is
 l_org_id NUMBER;

Begin

     l_org_id :=    PA_MOAC_UTILS.get_current_org_id ;


     -- GMS responsibility
     -- PO/AP etc ..
     RETURN enabled(l_org_id);

end ENABLED;

-- -----------------------------------------------------------+
FUNCTION ENABLED(x_org_id number) return boolean
is
  l_dummy number;
begin

  If x_org_id is NULL then

     select 1 into l_dummy
     from dual where exists
        (select 1
         from gms_implementations
         where enabled = 'Y');

  Else

     select 1 into l_dummy
     from dual where exists
        (select 1
         from gms_implementations
         where org_id = x_org_id
         and   enabled = 'Y');

  End If;

      Return TRUE;
Exception
 When no_data_found then
      Return FALSE;
end ENABLED;

-- Following procedure and function called from GMS.pld
-- ------------------------------------------------------------------+
-- This procedure will build the pl/sql table containing orgs where
-- grants is implemented ..
-- ------------------------------------------------------------------+
PROCEDURE SET_ORG_ARRAY
IS
BEGIN
  -- Build a pl/sql table for the GMS implemented org ..
  select org_id
  BULK COLLECT into t_org_id
  from  gms_implementations;

END SET_ORG_ARRAY;

-- -----------------------------------------------------------------------+
-- This procedure will be called from gms.style and gms.event for AP/PO ..
-- -----------------------------------------------------------------------+
FUNCTION GMS_ENABLED_MOAC(p_org_id IN NUMBER) RETURN BOOLEAN
IS
  l_dummy number(1);
BEGIN
      for x in 1..t_org_id.COUNT
      loop
        If p_org_id = t_org_id(x) then
           l_dummy := 1;
           EXIT;
        End If;
      end loop;

      If l_dummy =1 then
         RETURN TRUE;
      Else
         RETURN FALSE;
      End If;

END GMS_ENABLED_MOAC;

-- -----------------------------------------------------------------------+
-- Function is_sponsored_project returns:
--     'Y' if project is sponsored
--     'N' if the project is non sponsored.
--  Called from GMS.pld
-- -----------------------------------------------------------------------+
 FUNCTION IS_SPONSORED_PROJECT ( p_project_id NUMBER )
 RETURN VARCHAR2 is
 BEGIN

  If p_project_id is NULL then
     g_sponsored_flag := 'N';
     RETURN g_sponsored_flag;
  End if;

  If (g_project_id is not null and
      g_project_id = p_project_id)
  then
     null;
  Else

   g_sponsored_flag := 'N';
   g_project_id     := p_project_id;

   select 'Y'
   into   g_sponsored_flag
   from   pa_projects_all pp,
          pa_project_types_all pt
   where  pp.project_id = p_project_id
   and    pp.project_type = pt.project_type
   and    pp.org_id = pt.org_id
   and    nvl(pt.sponsored_flag,'N') = 'Y';

  End If;

   RETURN g_sponsored_flag;

 EXCEPTION
    When no_data_found then
	RETURN g_sponsored_flag;

 END IS_SPONSORED_PROJECT ;

-- ------------------------------------------------------------------+
-- --------------------- MOAC CHANGES START -------------------------+
-- ------------------------------------------------------------------+

	function SITE_ENABLED return boolean
	is
 		x_temp     varchar2(1) ;
	begin
-- Bug 2254944 (CODING STANDARD VIOLATIONS TO BE FIXED) - replaced rownum with exists
    		--select 'X'
	  	--into x_temp
	  	select 'X' into x_temp from dual where exists (
	  	select 1
	  	from gms_implementations_all );
	  	--where rownum < 2 ;

		return TRUE;

	EXCEPTION
  		WHEN TOO_MANY_ROWS THEN
	 		return TRUE ;
  		WHEN OTHERS THEN
	 		return FALSE ;
	end SITE_ENABLED;

-------------------------------------------------------------+
	function FAB_ENABLED return boolean
	is
	begin
		RETURN FALSE;

	end FAB_ENABLED;

-------------------------------------------------------------+
	function FAB_ENABLED(x_org_id NUMBER) return boolean
	is
	begin
		RETURN FALSE;

	end FAB_ENABLED;

-------------------------------------------------------------+

end GMS_INSTALL;

/
