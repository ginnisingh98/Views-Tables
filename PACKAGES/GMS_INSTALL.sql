--------------------------------------------------------
--  DDL for Package GMS_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_INSTALL" AUTHID CURRENT_USER as
-- $Header: GMSINSTS.pls 120.2 2005/07/29 13:50:28 bkattupa noship $

/*---------------------------------------------------------------
 function ENABLED return boolean

   	Function to check the implementation status of OGM
 	from Oracle applications
   Return  values
     	TRUE 	if OGM is implemented for the login org_id
     	FALSE 	if OGM is not implemented for login org_id
--------------------------------------------------------------- */
function ENABLED return boolean;
/* PRAGMA RESTRICT_REFERENCES(enabled, WNDS,WNPS); */

/*---------------------------------------------------------------
 function ENABLED(x_org_id NUMBER) return boolean

   	Function to check the implementation status of OGM
 	for an Organization.
   Parameter
	x_org_id : The multi org org_id for which
   			OGM  implemention status is requested.
   Return  value
     	TRUE 	if OGM is implemented for the x_org_id passed.
     	FALSE 	if OGM is not implemented for the x_org_id passed.
--------------------------------------------------------------- */
function ENABLED(x_org_id NUMBER) return boolean;
PRAGMA RESTRICT_REFERENCES(enabled, WNDS,WNPS);

/*---------------------------------------------------------------
function FAB_ENABLED return boolean

 Function to check the FAB implementation status of OGM.
 Returns
     TRUE if OGM FAB is implemented for the Login Responsibility .
     FALSE if OGM FAB is not implemented for the Login Responsibility .
--------------------------------------------------------------- */
function FAB_ENABLED return boolean;
PRAGMA RESTRICT_REFERENCES(fab_enabled, WNDS,WNPS);

/*---------------------------------------------------------------
function FAB_ENABLED(x_org_id NUMBER) return boolean

Function to check the FAB implementation status of OGM for an Organization.
Returns
	TRUE if OGM FAB is implemented for the login Responsibility.
	FALSE if OGM FAB is not implemented for the Login Responsibility.
--------------------------------------------------------------- */
function FAB_ENABLED(x_org_id NUMBER) return boolean;
PRAGMA RESTRICT_REFERENCES(fab_enabled, WNDS,WNPS);

/*---------------------------------------------------------------
function SITE_ENABLED return boolean

 Function to check the installation status of OGM at a Site.
 Returns
     TRUE if OGM is implemented for  any Organization.
     FALSE if OGM is not implemented for any Organization.
--------------------------------------------------------------- */
function SITE_ENABLED return boolean;
PRAGMA RESTRICT_REFERENCES(site_enabled, WNDS,WNPS);


-- -----------------------------------------------------------------+
-- MOAC changes start .. the following procedure and function is
-- accessed from GMS.pld ..
-- -----------------------------------------------------------------+

 Type TypeNum is table of number index by binary_integer;
 t_org_id TypeNum;

 g_sponsored_flag VARCHAR2(1);
 g_project_id     pa_projects_all.project_id%TYPE;

 -- This function will check if the project is sponsored
 FUNCTION is_sponsored_project ( p_project_id NUMBER )
 RETURN VARCHAR2 ;

 -- This procedure will build the pl/sql org table .. containing orgs
 -- where grants is implemented

 PROCEDURE SET_ORG_ARRAY;

 --This procedure will be called from gms.style and gms.event for AP/PO ..
 FUNCTION GMS_ENABLED_MOAC(p_org_id IN NUMBER) RETURN BOOLEAN;

-- -----------------------------------------------------------------+
-- MOAC changes end
-- -----------------------------------------------------------------+

end GMS_INSTALL;

 

/
