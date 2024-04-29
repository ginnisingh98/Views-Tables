--------------------------------------------------------
--  DDL for Package Body PA_FUND_REVAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUND_REVAL_UTIL" AS
--$Header: PAXFRUTB.pls 120.0.12000000.2 2007/03/22 14:45:58 rgandhi ship $

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   log_message                                                            |
   |   Purpose    :   To write log message as supplied by the process                        |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_message                        IN      Message to be logged                       |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE log_message(p_message IN VARCHAR2) IS

   BEGIN

      pa_debug.log_message (p_message =>p_message);

   END log_message;

-- Function   :  Valid_Include_Gains_Losses
-- Parameters :  Org_Id
-- Purpose    :  Function to check  whether user can modify
--		 include gains and losses option or not
--               If the function returns Y then user should not able to
--               Modify it.
--               This should be called only when disable the option

FUNCTION Valid_Include_Gains_Losses(p_org_id IN NUMBER) RETURN VARCHAR2 IS
l_flag    VARCHAR2(1):='N';
BEGIN
    -- Check project type level
       BEGIN
		SELECT 'Y' INTO l_flag
		FROM DUAL
		WHERE exists (SELECT NULL FROM
			      PA_PROJECT_TYPES_ALL
			      WHERE org_id = p_org_id
	    /*  WHERE NVL(org_id,-99) = NVL(p_org_id,-99)  Bug 5900353*/
				AND NVL(include_gains_losses_flag,'N') ='Y');

		EXCEPTION
		WHEN NO_DATA_FOUND  THEN
			l_flag := 'N';
	END;

	IF l_flag ='Y' THEN

		RETURN l_flag;

	END IF;

    -- Check project level
       BEGIN
		SELECT 'Y' INTO l_flag
		FROM DUAL
		WHERE exists (SELECT NULL FROM
			      PA_PROJECTS_ALL
			      WHERE org_id = p_org_id
			    /*  WHERE NVL(org_id,-99) = NVL(p_org_id,-99)  Bug 5900353*/
				AND NVL(include_gains_losses_flag,'N') ='Y');
		EXCEPTION
		WHEN NO_DATA_FOUND  THEN
			l_flag := 'N';
	END;

	IF l_flag ='Y' THEN

		RETURN l_flag;

	END IF;

    -- Check events level
       BEGIN
		SELECT 'Y' INTO l_flag
		FROM DUAL
		WHERE exists (SELECT NULL FROM
		        PA_EVENTS evt, PA_PROJECTS_ALL pr,
		        PA_EVENT_TYPES evttyp
			WHERE pr.org_id = p_org_id
			/*  WHERE NVL(pr.org_id,-99) = NVL(p_org_id,-99) Bug 5900353 */
		          AND evt.project_id = pr.project_id
		          AND evt.event_type = evttyp.event_type
		          AND evttyp.event_type_classification in
				('REALIZED_GAINS','REALIZED_LOSSES'));
		EXCEPTION
		WHEN NO_DATA_FOUND  THEN
			l_flag := 'N';
	END;

return l_flag;

END Valid_Include_Gains_Losses;
-- Function   :  Is_Ou_Include_Gains_Losses
-- Parameters :  Org_Id
-- Purpose    :  Function to get the OU level include gains and
--               losses option Value

FUNCTION Is_OU_Include_Gains_Losses(p_org_id IN NUMBER) RETURN VARCHAR2 IS
l_flag    VARCHAR2(1):='N';
BEGIN
       BEGIN
		SELECT NVL(imp.include_gains_losses_flag,'N')
		  INTO l_flag
		  FROM PA_IMPLEMENTATIONS_ALL imp
	         WHERE imp.org_id = p_org_id;
	         /*  WHERE NVL(imp.org_id,-99) = NVL(p_org_id,-99);Bug 5900353  */

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     l_flag :='N';
	END;

	RETURN l_flag;

END Is_Ou_Include_Gains_Losses;
-- Function   :  Is_PT_Include_Gains_Losses
-- Parameters :  Org_Id, Project Type
-- Purpose    :  Function to get the Project Type include gains and
--               losses option Value
FUNCTION Is_PT_Include_Gains_Losses(p_org_id IN NUMBER,p_project_type IN VARCHAR2) RETURN VARCHAR2 IS
l_flag    VARCHAR2(1):='N';
BEGIN
       BEGIN
		SELECT NVL(pt.include_gains_losses_flag,'N')
		  INTO l_flag
		  FROM PA_PROJECT_TYPES_ALL pt
	         WHERE pt.org_id = p_org_id
	         /*  WHERE NVL(pt.org_id,-99) = NVL(p_org_id,-99)Bug 5900353  */
	           AND pt.project_type = p_project_type;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     l_flag :='N';
	END;

	RETURN l_flag;

END Is_PT_Include_Gains_Losses;

-- Function   :  Is_Ar_Installed
-- Parameters :  None

FUNCTION Is_AR_Installed RETURN VARCHAR2 IS
 l_installed  VARCHAR2(1):= 'N';
BEGIN
  l_installed := PA_OUTPUT_TAX.IS_AR_INSTALLED( P_Check_prod_installed=>'Y',
                                 		P_Check_org_installed=>'Y');

  RETURN(l_installed);

END Is_Ar_Installed;

-- Function   :  Get_Ar_Application_Id
-- Parameters :  None

FUNCTION Get_AR_Application_Id RETURN NUMBER IS

 l_ar_app_id NUMBER:=222;

BEGIN

	return(l_ar_app_id);

END Get_AR_Application_ID;

END PA_FUND_REVAL_UTIL;

/
