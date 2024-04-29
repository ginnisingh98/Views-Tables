--------------------------------------------------------
--  DDL for Package Body MRP_PARAMETER_MRPFSETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PARAMETER_MRPFSETA" as
/* $Header: MRPBISFB.pls 120.1 2007/12/19 02:34:04 ahoque noship $ */


PROCEDURE error( P_FIELD IN VARCHAR2 ) IS
BEGIN
  BIS_UTILITIES_PUB.Build_Report_Title( 'BIS_MRPFSETA', 'MRPFSETA', NULL );
  htp.p( '<FONT face="arial" size=+1><BR><BR>' ||
         fnd_message.get_string( 'WIP', 'INVALID_PARAM' ) || ': <B>' ||
         P_FIELD || '</B></FONT>');
  htp.p( '<FONT face="arial"><BR><BR>' ||
         fnd_message.get_string( 'WIP', 'INVALID_PARAM_INSTRUCTION' ) ||
         '</FONT>');
END error;


/*

FUNCTION Validate_Org(P_ORG_ID      IN OUT NUMBER,
                      P_ORG_NAME        IN VARCHAR2 default null)
         RETURN BOOLEAN IS
  l_org_id number := 0;
  l_exist number := 0;
  l_count number := 0;
BEGIN

    if (P_ORG_NAME is NULL) then
        return FALSE;
    end if;

        select max(organization_id), count(organization_name)
          into l_org_id, l_count
          from org_organization_definitions
         where organization_name = P_ORG_NAME;
        if (l_org_id is NULL) then
            goto no_org_found;
        end if;
        if (l_count > 1) then       -- duplicate org name, verify id
            select 1
              into l_exist
              from org_organization_definitions
             where organization_name = P_ORG_NAME
               and organization_id = P_ORG_ID;
        end if;

    if (l_org_id <> P_ORG_ID) then
        P_ORG_ID := l_org_id;
    end if;

    return TRUE;

<< no_org_found >>
    htp.p('no org found at all');
    return FALSE;

EXCEPTION
    WHEN OTHERS then
        htp.p('no org id for duplicate data');
        return FALSE;

END Validate_Org;

FUNCTION Validate_Per(p_org_id   IN NUMBER,
                      P_PERIOD       IN VARCHAR2)
         RETURN BOOLEAN IS
  l_period_type VARCHAR2(240);
BEGIN
    if (P_PERIOD is NULL) then
        return FALSE;
    else
        select distinct period_type
          into l_period_type
	  from gl_periods
	  where period_set_name in (select period_set_name
            from gl_sets_of_books gl,
		org_organization_definitions org
	    where org.set_of_books_id = gl.set_of_books_id
		and org.organization_id = p_org_id)
	 and period_type = P_PERIOD;
    end if;

    return TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND then
        htp.p('no period type');
        return FALSE;

END Validate_Per;

FUNCTION Validate_Fcst(p_org_id   IN NUMBER,
                      P_FROM_FORECAST   IN VARCHAR2,
		      P_TO_FORECAST	IN VARCHAR2)
         RETURN BOOLEAN IS
	l_from_forecast VARCHAR2(30);
	l_to_forecast VARCHAR2(30);
BEGIN
    if (P_FROM_FORECAST is NULL) OR (P_TO_FORECAST IS NULL) then
        return FALSE;
    else
        select forecast_designator
 	  into l_from_forecast
	  from mrp_forecast_designators
         where organization_id = p_org_id
         and forecast_set is null
	 and forecast_designator = P_FROM_FORECAST;

        select forecast_designator
 	  into l_to_forecast
	  from mrp_forecast_designators
         where organization_id = p_org_id
         and forecast_set is null
         and forecast_designator >= P_FROM_FORECAST
	 and forecast_designator = P_TO_FORECAST;
    end if;

    return TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND then
        htp.p('no forecast');
        return FALSE;

END Validate_Fcst;

FUNCTION Validate_Parameters(
    P_ORG_ID                         IN OUT NUMBER,
    P_ORG_NAME                              VARCHAR2 default null,
    P_FROM_FORECAST		  IN VARCHAR2 default null,
    P_TO_FORECAST		  IN VARCHAR2 default null,
    P_PERIOD                      IN VARCHAR2) RETURN BOOLEAN IS
  l_org_id              NUMBER  := P_ORG_ID;
  l_status              BOOLEAN;
BEGIN
    if Validate_Org(l_org_id, P_ORG_NAME) then
        if Validate_Per(l_org_id, P_PERIOD) then
          if Validate_Fcst(l_org_id, P_FROM_FORECAST, P_TO_FORECAST) then
            l_status := TRUE;
          end if;
        end if;
    end if;

    P_ORG_ID := l_org_id;

    return l_status;
END Validate_Parameters;

*/

PROCEDURE Before_Parameter_MRPFSETA IS
  l_user_id NUMBER;
  l_resp_id NUMBER;
  l_appl_id NUMBER;
  l_org_id  NUMBER;
BEGIN
    -- Initialize the report
    -- FND_GLOBAL.apps_initialize(l_user_id, l_resp_id, l_appl_id);
    l_org_id := fnd_profile.value('ORG_ID');
    FND_CLIENT_INFO.set_org_context(l_org_id);
END Before_Parameter_MRPFSETA;

PROCEDURE After_Parameter_MRPFSETA IS
BEGIN
    NULL;
END After_Parameter_MRPFSETA;


PROCEDURE MRPFSETA_Parameter_PrintOrg(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type, --2663505
            i IN NUMBER) IS
    CURSOR c_organizations IS
        SELECT organization_id org_id, organization_name name
	FROM org_organization_definitions
        ORDER BY organization_name;
BEGIN
--    htp.formHidden('p_org_id');
    param(i).Label := FND_MESSAGE.get_string( 'MRP', 'MRP_ORGANIZATION_LABEL');
    param(i).Value := htf.formSelectOpen( 'P_ORG' );
--    param(i).Value := htf.formSelectOpen( 'P_ORG', cattributes=>'onChange="setPoplists()"' );
    FOR c1 in c_organizations LOOP
        param(i).Value := param(i).Value || htf.formSelectOption( c1.name, NULL, 'value=' || c1.org_id );
    END LOOP;
    param(i).Value := param(i).Value || htf.formSelectClose;

END MRPFSETA_Parameter_PrintOrg;

PROCEDURE MRPFSETA_Parameter_PrintTrgt(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type, --2663505
            i IN NUMBER) IS
    CURSOR c_business_plans IS
        SELECT plan_id, name FROM bisbv_business_plans;
BEGIN
    param(i).Label := FND_MESSAGE.get_string( 'BOM', 'CST_BUSINESS_PLAN_LABEL');
    param(i).Value := htf.formSelectOpen( 'P_TARGET' );
    FOR c1 in c_business_plans LOOP
        param(i).Value := param(i).Value ||
                 htf.formSelectOption( c1.name, NULL, 'value=' || c1.plan_id );
    END LOOP;
    param(i).Value := param(i).Value || htf.formSelectClose;

END MRPFSETA_Parameter_PrintTrgt;

PROCEDURE MRPFSETA_Parameter_PrintPer(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type, --2663505
            i IN NUMBER) IS
    CURSOR c_period IS SELECT distinct period_type name, period_type id
	FROM gl_periods;
BEGIN
    param(i).Label := FND_MESSAGE.get_string( 'MRP', 'MRP_PERIOD_LABEL');
    param(i).Value := htf.formSelectOpen( 'P_PERIOD' );
    FOR c1 in c_period LOOP
        param(i).Value := param(i).Value ||
                 htf.formSelectOption( c1.name, NULL, 'value=' || c1.id );
    END LOOP;
    param(i).Value := param(i).Value || htf.formSelectClose;

END MRPFSETA_Parameter_PrintPer;

PROCEDURE MRPFSETA_Parameter_PrintFcst(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type, --2663505
            i IN NUMBER) IS
            --v_org_id IN PLS_INTEGER) IS
    CURSOR c_forecast IS
        SELECT forecast_designator name, forecast_designator id
	    FROM mrp_forecast_designators
	    WHERE forecast_set IS NULL
              AND organization_id = 207
 	    ORDER BY forecast_designator;
BEGIN
    param(i).Label := FND_MESSAGE.get_string( 'MRP', 'MRP_FORECAST_SET_LABEL');
    param(i).Value := htf.formSelectOpen( 'P_FROM_FORECAST' );
    FOR c1 in c_forecast LOOP
        param(i).Value := param(i).Value ||
                 htf.formSelectOption( c1.name, NULL, 'value=' || c1.id );
    END LOOP;
    param(i).Value := param(i).Value || htf.formSelectClose;

    param(i).Value := param(i).Value || ' - ' ||
		htf.formSelectOpen( 'P_TO_FORECAST' );
    FOR c1 in c_forecast LOOP
	param(i).Value := param(i).Value ||
		htf.formSelectOption( c1.name, NULL, 'value=' || c1.id );
    END LOOP;
    param(i).Value := param(i).Value || htf.formSelectClose;

END MRPFSETA_Parameter_PrintFcst;

/*
 * LaunchReport
 *   Launches the report using parameters in
 *   the ICX session attibutes.
 *   Returns TRUE if all necessary parameters are present,
 *   and the report is launched.  Otherwise returns FALSE.
 */

function LaunchReport(
  l_session_id          in  number,
  L_BUSINESS_PLAN_ID    in  varchar2,
  L_ORGANIZATION_ID  in  varchar2,
  L_PLAN1     in  varchar2,
  L_PLAN2     in  varchar2,
  L_PERIOD_TYPE         in  varchar2
) return boolean is
begin

  if( L_BUSINESS_PLAN_ID is null or
      L_ORGANIZATION_ID is null or
      L_PLAN1 is null or
      L_PLAN2 is null or
      L_PERIOD_TYPE is null ) then
    return false;
  end if;

/*
 *  Commenting out for bug 6687733
  OracleOASIS.RunReport(
    report => 'MRPFSETA',
    parameters =>
    replace(
    'paramform=NO*'          ||
    'P_BIS_PLAN='            || L_BUSINESS_PLAN_ID    || '*' ||
    'P_ORGANIZATION_ID='     || L_ORGANIZATION_ID     || '*' ||
    'PF_1='                  || L_PLAN1     || '*' ||
    'PF_2='                  || L_PLAN2   || '*' ||
    'P_PERIOD_TYPE='         || L_PERIOD_TYPE     || '*',
    ' ', '%20' ),
    paramform=> 'NO');
*/

  return true;

end LaunchReport;




/*
 * Parameter_FormView_MRPEPPS
 *
 *   This function is invoked via a form function
 *   and is the entry point into this package.
 *   It creates the HTML parameter page used by
 *   the BIS Sales Revenue report.
 */
PROCEDURE Parameter_FormView_MRPFSETA (force_display in varchar2 default null ) IS

  params BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type;

  CURSOR c_business_plans IS
    select plan_id, name from bisbv_business_plans;

  CURSOR c_period_types IS
  SELECT distinct period_type name from gl_periods;

  CURSOR c_forecast IS
  SELECT distinct forecast_designator name from mrp_forecast_designators
   	where forecast_set IS null
	AND organization_id = 207
            ORDER BY forecast_designator;

  CURSOR c_orgs IS
  SELECT organization_name name, organization_id from org_organization_definitions
	ORDER BY organization_name;

  l_return_status         VARCHAR2(1000);
  l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;

  l_launch_success        boolean;



  l_session_id          number;

  L_BUSINESS_PLAN_ID    varchar2(80);
  L_ORGANIZATION_ID  varchar2(80);
  L_PLAN1     varchar2(80);
  L_PLAN2     varchar2(80);
  L_PERIOD_TYPE         varchar2(80);


BEGIN


  if not icx_sec.validateSession THEN
    return;
  end if;

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  L_BUSINESS_PLAN_ID    := icx_sec.getSessionAttributeValue( 'BUSINESS PLAN',       l_session_id );
  L_ORGANIZATION_ID  := icx_sec.getSessionAttributeValue( 'ORGANIZATION_ID',  l_session_id );
  L_PLAN1     := icx_sec.getSessionAttributeValue( 'PLAN1',        l_session_id );
  L_PLAN2     := icx_sec.getSessionAttributeValue( 'PLAN2',        l_session_id );
  L_PERIOD_TYPE         := icx_sec.getSessionAttributeValue( 'PERIOD TYPE',         l_session_id );


  /* launch the report if we have the necessary parameters */

  if( force_display is null or
      upper(force_display) = 'NO' or
      upper(force_display) = 'N' ) then
    l_launch_success := LaunchReport
    (
      l_session_id          ,
      L_BUSINESS_PLAN_ID    ,
      L_ORGANIZATION_ID  ,
      L_PLAN1     ,
      L_PLAN2     ,
      L_PERIOD_TYPE
    );
    if( l_launch_success ) then
      return;
    end if;
  end if;

  Before_Parameter_MRPFSETA;


  htp.htmlOpen;

  BIS_UTILITIES_PUB.Build_Report_Title( 'BIS_MRPFSETA', 'MRPFSETA', '' );

  htp.headOpen;
  js.scriptOpen;
  icx_util.LOVScript;

  js.scriptClose;
  htp.headClose;

  htp.bodyOpen;

  htp.centerOpen;


/* ORGANIZATION */

  params(1).Label := fnd_message.get_string( 'MRP', 'MRP_ORGANIZATION_LABEL' );
  params(1).Value := htf.formSelectOpen( 'P_ORGANIZATION_ID' );
  FOR c1 in c_orgs LOOP
    if( c1.organization_id = L_ORGANIZATION_ID ) then
      params(1).Value := params(1).Value || htf.formSelectOption( c1.name, 'Y', 'value=' || c1.organization_id );
    else
      params(1).Value := params(1).Value || htf.formSelectOption( c1.name, 'Y', 'value=' || c1.organization_id );
    end if;
  END LOOP;
  params(1).Value := params(1).Value || htf.formSelectClose;


/* BUSINESS PLAN */

  params(2).Label := fnd_message.get_string( 'BOM', 'CST_BUSINESS_PLAN_LABEL' );
  params(2).Value := htf.formSelectOpen( 'P_BUSINESS_PLAN' );
  FOR c1 in c_business_plans LOOP
    if( c1.plan_id = L_BUSINESS_PLAN_ID ) then
      params(2).Value := params(2).Value || htf.formSelectOption( c1.name, 'Y', 'value=' || c1.plan_id );
    else
      params(2).Value := params(2).Value || htf.formSelectOption( c1.name, NULL, 'value=' || c1.plan_id );
    end if;
  END LOOP;
  params(2).Value := params(2).Value || htf.formSelectClose;

/* MRP PLANS */

  params(3).Label := fnd_message.get_string( 'MRP', 'MRP_FORECAST_SET_LABEL' );
  params(3).Value := htf.formSelectOpen('P_PLAN1');
  FOR c1 in c_forecast LOOP
	params(3).Value := params(3).Value || htf.formSelectOption( c1.name, NULL, 'value=' || c1.name );
  END LOOP;
  params(3).Value := params(3).Value || htf.formSelectClose;
  params(3).Value := params(3).Value || ' - ' || htf.formSelectOpen( 'P_PLAN2' );
  FOR c1 in c_forecast LOOP
	params(3).Value := params(3).Value || htf.formSelectOption( c1.name, NULL, 'value=' || c1.name );
  END LOOP;
  params(3).Value := params(3).Value || htf.formSelectClose;


/* PERIOD TYPE */

  params(4).Label := fnd_message.get_string( 'MRP', 'MRP_PERIOD_TYPE_LABEL' );
  params(4).Value := htf.formSelectOpen( 'P_PERIOD_TYPE' );
  FOR c1 in c_period_types LOOP
    params(4).Value := params(4).Value ||
		htf.formSelectOption( c1.name, NULL, 'value=' || c1.name);
  END LOOP;
  params(4).Value := params(4).Value || htf.formSelectClose;

  BIS_UTILITIES_PUB.Build_Parameter_Form(
    'NAME="param" ACTION="MRP_PARAMETER_MRPFSETA.Parameter_ActionView_MRPFSETA" METHOD="GET" ', params );


END Parameter_FormView_MRPFSETA;


/*
 * Parameter_ActionView_MRPEPPS
 *
 *   This function is invoked when the user clicks
 *   the OK button in the HTML page generated by
 *   Parameter_FormView_MRPEPPS.  It will validate
 *   the input parameters and launch the Sales Revenue
 *   report.
 */
PROCEDURE Parameter_ActionView_MRPFSETA(
  P_BUSINESS_PLAN                         NUMBER,
  P_ORGANIZATION_ID                       NUMBER,
  P_PLAN1                                 VARCHAR2,
  P_PLAN2                                 VARCHAR2,
  P_PERIOD_TYPE                           VARCHAR2)
IS

  l_session_id          number;

  L_BUSINESS_PLAN_ID    varchar2(80);
  L_ORGANIZATION_ID     varchar2(80);
  L_PLAN1               varchar2(80);
  L_PLAN2               varchar2(80);
  L_PERIOD_TYPE         varchar2(80);

  l_launch_success      boolean;

BEGIN

  if not icx_sec.validateSession THEN
    return;
  end if;

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  L_BUSINESS_PLAN_ID := p_business_plan;
  L_PERIOD_TYPE      := p_period_type;
  L_ORGANIZATION_ID  := p_organization_id;
  L_PLAN1            := p_plan1;
  L_PLAN2            := p_plan2;

  icx_sec.putSessionAttributeValue( 'BUSINESS PLAN',       L_BUSINESS_PLAN_ID   , l_session_id );
  icx_sec.putSessionAttributeValue( 'ORGANIZATION',      L_ORGANIZATION_ID  , l_session_id );
  icx_sec.putSessionAttributeValue( 'PLAN1',           L_PLAN1          , l_session_id );
  icx_sec.putSessionAttributeValue( 'PLAN2',             L_PLAN2            , l_session_id );
  icx_sec.putSessionAttributeValue( 'PERIOD TYPE',         L_PERIOD_TYPE        , l_session_id );


  l_launch_success := LaunchReport
  (
    l_session_id          ,
    L_BUSINESS_PLAN_ID    ,
    L_ORGANIZATION_ID  ,
    L_PLAN1     ,
    L_PLAN2     ,
    L_PERIOD_TYPE
  );


END Parameter_ActionView_MRPFSETA;


END MRP_PARAMETER_MRPFSETA;

/
