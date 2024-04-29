--------------------------------------------------------
--  DDL for Package Body PJI_PMV_DFLT_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_DFLT_PARAMS_PVT" AS
/* $Header: PJIRX03B.pls 120.6 2007/11/16 15:25:39 vvjoshi ship $ */

G_Period_Type_Code      VARCHAR2(30);   -- PJI_SYSTEM_PARAMETERS.DFLT_PRJPIP_PERIOD_TYPE%TYPE;
G_Period_Type_ID        VARCHAR2(30);   -- PJI_SYSTEM_PARAMETERS.DFLT_PRJPIP_PERIOD_TYPE%TYPE;
G_Cycle_ID_Code         NUMBER  (15);   -- PJI_SYSTEM_PARAMETERS.DFLT_PRJPIP_CYCLE_ID%TYPE;
G_Cycle_ID_Value        NUMBER  (15);   -- PJI_SYSTEM_PARAMETERS.DFLT_PRJPIP_CYCLE_ID%TYPE;
G_Currency_ID           VARCHAR (30):= 'FII_GLOBAL1'; --
G_Org_Version_Id        NUMBER  (15);   -- PJI_SYSTEM_PARAMETERS.ORG_STRUCTURE_VERSION_ID;
G_Org_Structure_Id      NUMBER  (15);   -- PJI_SYSTEM_PARAMETERS.ORGANIZATION_STRUCTURE_ID;
G_Org_ID                VARCHAR2(30);
-- G_Exception_Msg         VARCHAR2(2000);
G_Avail_Threshold       VARCHAR2(30);
G_EntPeriod_ID          VARCHAR2(30);
G_EntWeek_ID            VARCHAR2(30);

-- Variable to extract ID for the sysdate from PJI_SYSTEM_SETTTINGS

G_Period_Id_Value       VARCHAR2(30);

-- Variables for drrive any valid ID from FII_TIME_DAY table

G_Month_ID_Value        NUMBER;
G_Ent_Period_ID_Value   NUMBER;
G_Ent_Quarter_ID_Value  NUMBER;
G_Ent_Year_ID_Value     NUMBER;
G_Week_ID_Value         NUMBER;

TYPE InitParams IS RECORD (

ORGANIZATION_STRUCTURE_ID                 NUMBER(15)
,ORG_STRUCTURE_VERSION_ID                 NUMBER(15)
,DFLT_PRJPIP_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJPIP_CYCLE_ID                     NUMBER(15)
,DFLT_PRJBAB_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJBAB_CYCLE_ID                     NUMBER(15)
,DFLT_RESUTL_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_RESUTL_CYCLE_ID                     NUMBER(15)
,DFLT_RESAVL_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_RESAVL_CYCLE_ID                     NUMBER(15)
,DFLT_RESPLN_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_RESPLN_CYCLE_ID                     NUMBER(15)
,DFLT_PRJHLT_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJHLT_CYCLE_ID                     NUMBER(15)
,DFLT_PRJACT_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJACT_CYCLE_ID                     NUMBER(15)
,DFLT_PRJPRF_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJPRF_CYCLE_ID                     NUMBER(15)
,DFLT_PRJCST_PERIOD_TYPE                  VARCHAR2(30)
,DFLT_PRJCST_CYCLE_ID                     NUMBER(15));

InitialValues  InitParams;


-- *************************************************************************
--  API called to read the initialization parameters from PJI_SYSTEM_SETINGS
-- *************************************************************************

PROCEDURE InitEnvironment(p_Calling_Context VARCHAR2 DEFAULT NULL) IS
BEGIN
  SELECT        ORGANIZATION_STRUCTURE_ID,
                ORG_STRUCTURE_VERSION_ID,
                DFLT_PRJPIP_PERIOD_TYPE,
                DFLT_PRJPIP_CYCLE_ID,
                DFLT_PRJBAB_PERIOD_TYPE,
                DFLT_PRJBAB_CYCLE_ID,
                DFLT_RESUTL_PERIOD_TYPE,
                DFLT_RESUTL_CYCLE_ID,
                DFLT_RESAVL_PERIOD_TYPE,
                DFLT_RESAVL_CYCLE_ID,
                DFLT_RESPLN_PERIOD_TYPE,
                DFLT_RESPLN_CYCLE_ID,
                DFLT_PRJHLT_PERIOD_TYPE,
                DFLT_PRJHLT_CYCLE_ID,
                DFLT_PRJACT_PERIOD_TYPE,
                DFLT_PRJACT_CYCLE_ID,
                DFLT_PRJPRF_PERIOD_TYPE,
                DFLT_PRJPRF_CYCLE_ID,
                DFLT_PRJCST_PERIOD_TYPE,
                DFLT_PRJCST_CYCLE_ID
      INTO InitialValues
      FROM PJI_SYSTEM_SETTINGS;

    select  MONTH_ID,
            ENT_PERIOD_ID,
            ENT_QTR_ID,
            ENT_YEAR_ID,
            WEEK_ID
    into    G_Month_ID_Value,
            G_Ent_Period_ID_Value,
            G_Ent_Quarter_ID_Value,
            G_Ent_Year_ID_Value,
            G_Week_ID_Value
    from   fii_time_day
    where report_date = trunc(sysdate);

EXCEPTION
WHEN NO_DATA_FOUND THEN
-- Bug 5391217 If the call is from Discoverer ignore the exception
IF p_Calling_Context IS NULL THEN
raise_application_error(-20010,
 'Parametrization table contains no data. Please, check tables PJI_SYSTEM_SETTINGS and FII_TIME_DAY');
ELSE
RETURN;
END IF;
WHEN TOO_MANY_ROWS
THEN
raise_application_error(-20010,
 'Parametrization table contains more than 1 row. Please, check tables PJI_SYSTEM_SETTINGS and FII_TIME_DAY');

END InitEnvironment ;

-- ********************************************************
--  API to be called from each report type Procedure
-- ********************************************************

PROCEDURE InitParameters (p_Report_Type VARCHAR2) IS

l_Report_Type VARCHAR2(150);

BEGIN
l_Report_Type:=p_Report_Type;

    CASE WHEN l_Report_Type ='Project Pipeline'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJPIP_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJPIP_CYCLE_ID;

         WHEN l_Report_Type ='Project Bookings and Backlog'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJBAB_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJBAB_CYCLE_ID;

         WHEN l_Report_Type ='Resource Utilization'
            THEN G_Period_Type_Code :=InitialValues.DFLT_RESUTL_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_RESUTL_CYCLE_ID;

         WHEN l_Report_Type ='Resource Availability'
            THEN G_Period_Type_Code :=InitialValues.DFLT_RESAVL_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_RESAVL_CYCLE_ID;

         WHEN l_Report_Type ='Resource Planning'
            THEN G_Period_Type_Code :=InitialValues.DFLT_RESPLN_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_RESPLN_CYCLE_ID;

         WHEN l_Report_Type ='Project Health'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJHLT_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJHLT_CYCLE_ID;

         WHEN l_Report_Type ='Project Activity'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJACT_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJACT_CYCLE_ID;

         WHEN l_Report_Type ='Project Profitability'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJPRF_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJPRF_CYCLE_ID;

         WHEN l_Report_Type ='Project Cost'
            THEN G_Period_Type_Code :=InitialValues.DFLT_PRJCST_PERIOD_TYPE;
                 G_Cycle_ID_Code    :=InitialValues.DFLT_PRJCST_CYCLE_ID;
END CASE;

EXCEPTION
    WHEN OTHERS
        THEN RAISE;

END InitParameters;

--*************************************************************
-- Derive Default Organization
--*************************************************************

FUNCTION Derive_Organization_ID(p_Calling_Context VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
l_top_organization_id   per_security_profiles.organization_id%TYPE;
l_top_org_name          hr_all_organization_units_tl.name%TYPE;
l_user_assmt_flag       VARCHAR2(1);
l_insert_top_org_flag   VARCHAR2(1);
BEGIN

G_Org_Structure_Id  :=InitialValues.ORGANIZATION_STRUCTURE_ID;
G_Org_Version_Id    :=InitialValues.ORG_STRUCTURE_VERSION_ID;

 PJI_PMV_UTIL.get_top_org_details(
    x_top_org_id          => l_top_organization_id,
    x_top_org_name        => l_top_org_name,
    x_user_assmt_flag     => l_user_assmt_flag,
    x_insert_top_org_flag => l_insert_top_org_flag);

    --Bug 4599990. View All Orgz
    IF l_top_organization_id = 0 THEN
	SELECT DISTINCT first_value(ID) over (ORDER BY lvl) into G_Org_ID
	FROM
	    (
		SELECT organization_level  Lvl
		     , organization_id  id
		FROM
		       hri_org_hrchy_summary org_roll
		WHERE org_roll.org_structure_version_id = G_Org_Version_Id
        AND   organization_level - sub_organization_level =0
	    );

    Else
	SELECT DISTINCT first_value(ID) over (ORDER BY lvl) into G_Org_ID
	FROM
	    (
		SELECT org_roll.sup_org_absolute_level Lvl
		     , org_list.id id
		     , org_list.value value
		FROM
		       hri_cs_orghro_v org_roll
		     , pji_organizations_v org_list
		WHERE
		org_roll.org_hierarchy_version_id = G_Org_Version_Id
		AND org_roll.sup_organization_id = org_list.id
		AND org_roll.sup_org_absolute_level - org_roll.sub_org_absolute_level = 0
		AND org_roll.subro_sup_org_relative_level = 0
		AND org_roll.subro_sub_org_relative_level = 0
	    );
END IF;
RETURN G_Org_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
-- Bug 5086074 This check will not happen for discoverer implementation
IF p_Calling_Context IS NULL THEN
raise_application_error(-20010,
 'Following views HRI_CS_ORGHRO_V,
    PJI_ORGANIZATIONS_V may contain no data. Please, verify');
END IF;
RETURN NULL; /* added for bug 6034422 */
END Derive_Organization_ID;

--******************************************************
-- Derive Default Period ID
--******************************************************

FUNCTION Derive_Period_ID RETURN VARCHAR2 IS

BEGIN
SELECT  prjpip.ID into G_Period_Type_ID
-- 	,prjbab.value
        FROM
        pji_system_settings syssetting
        , pji_period_types_v prjpip
        , pji_period_types_v prjbab
        WHERE
        prjbab.global_disp_flag = 0
        AND prjpip.global_disp_flag = 0
        AND prjpip.ID='FII_TIME_'||DECODE(G_Period_Type_Code,
				'YEAR','ENT_YEAR',
				'QUARTER','ENT_QTR',
				'MONTH','ENT_PERIOD',
				'WEEK','WEEK')
        AND prjbab.ID='FII_TIME_'||DECODE(G_Period_Type_Code,
				'YEAR','ENT_YEAR',
				'QUARTER','ENT_QTR',
				'MONTH','ENT_PERIOD',
				'WEEK','WEEK');
 RETURN G_Period_Type_ID;
END Derive_Period_ID;

--******************************************************
-- Derive Enterprise Period ID
--******************************************************

FUNCTION Derive_EntPeriod_ID RETURN VARCHAR2 IS
BEGIN
SELECT  LOOKUP_CODE into G_EntPeriod_ID
        FROM
        pji_lookups
        WHERE LOOKUP_TYPE='PJI_PERIOD_TYPE_LIST'
            AND LOOKUP_CODE='FII_TIME_ENT_PERIOD';
 RETURN G_EntPeriod_ID;
END Derive_EntPeriod_ID;

--******************************************************
-- Derive Enterprise Week ID
--******************************************************

FUNCTION Derive_EntWeek_ID RETURN VARCHAR2 IS
BEGIN
SELECT  LOOKUP_CODE into G_EntWeek_ID
        FROM
        pji_lookups
        WHERE LOOKUP_TYPE='PJI_PERIOD_TYPE_LIST'
            AND LOOKUP_CODE='FII_TIME_WEEK';
 RETURN G_EntWeek_ID;
END Derive_EntWeek_ID;

--*******************************************************
--Derive Default Curency ID
--*******************************************************

FUNCTION Derive_Currency_ID RETURN VARCHAR2 IS

BEGIN
    RETURN G_Currency_ID;
END Derive_Currency_ID;

--********************************************************
--Derive Derive_Period_ID_Value Paramater
--********************************************************

FUNCTION Derive_Period_ID_Value RETURN VARCHAR2 IS

BEGIN
select DECODE(G_Period_Type_Code,'WEEK', WEEK_ID
                                ,'MONTH', MONTH_ID
                                ,'PERIOD',ENT_PERIOD_ID
                                ,'QUARTER',ENT_QTR_ID
                                ,'YEAR',ENT_YEAR_ID)

into   G_Period_Id_Value from
       fii_time_day
where report_date = trunc(sysdate);
RETURN G_Period_Id_Value;

EXCEPTION
WHEN NO_DATA_FOUND THEN
 RAISE;
END Derive_Period_ID_Value;

--********************************************************
--Derive Ent Qtr ID Value Paramater (Portal)
--********************************************************

FUNCTION Derive_Ent_Quarter_ID_Value RETURN NUMBER IS
BEGIN
    RETURN G_Ent_Quarter_ID_Value;
END Derive_Ent_Quarter_ID_Value;

--********************************************************
--Derive Ent Period ID Value
--********************************************************

FUNCTION Derive_Ent_Period_ID_Value RETURN NUMBER IS
BEGIN
    RETURN G_Ent_Period_ID_Value;
END Derive_Ent_Period_ID_Value;

--********************************************************
--Derive Week ID Value Paramater
--********************************************************

FUNCTION Derive_Week_ID_Value RETURN NUMBER IS
BEGIN
    RETURN G_Week_ID_Value;
END Derive_Week_ID_Value;


--*******************************************************
--Derive Availability Threshold
--*******************************************************

FUNCTION Derive_Avail_Threshold RETURN VARCHAR2 IS

BEGIN
 select TO_CHAR(seq) into G_Avail_Threshold
     from pji_mt_buckets where bucket_set_code ='PJI_RESOURCE_AVAILABILITY'
     and default_flag='Y';
    RETURN G_Avail_Threshold;
END Derive_Avail_Threshold;

END PJI_PMV_DFLT_PARAMS_PVT;


/
