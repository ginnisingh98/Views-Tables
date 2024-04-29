--------------------------------------------------------
--  DDL for Package Body MRP_PARAMETER_MRPEPPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PARAMETER_MRPEPPS" AS
/* $Header: MRPBISPB.pls 120.0 2007/12/19 02:43:48 ahoque noship $ */



/* some constants */
FORM_FUNCTION constant varchar2(20) := 'BIS_MRPEPPS';
RDF_FILENAME  constant varchar2(20) := 'MRPEPPS';
DATE_FORMAT   constant varchar2(20) := 'DD-MON-YYYY';




/*
 * error
 *
 *   This creates the pretty looking error message page.
 */
PROCEDURE error( P_FIELD IN VARCHAR2 ) IS
BEGIN
  BIS_UTILITIES_PUB.Build_Report_Title( FORM_FUNCTION, RDF_FILENAME, NULL );
  htp.p( '<FONT face="arial" size=+1><BR><BR>' ||
         fnd_message.get_string( 'WIP', 'INVALID_PARAM' ) || ': <B>' ||
         P_FIELD || '</B></FONT>');
  htp.p( '<FONT face="arial"><BR><BR>' ||
         fnd_message.get_string( 'WIP', 'INVALID_PARAM_INSTRUCTION' ) ||
         '</FONT>');
END error;




/*
 * Before_Parameter_MRPEPPS
 *
 *   This function is called by Parameter_FormView_MRPEPPS
 *   to perform initial setups.  It should not be invoked
 *   directly.
 */
PROCEDURE Before_Parameter_MRPEPPS IS
  l_user_id NUMBER;
  l_resp_id NUMBER;
  l_appl_id NUMBER;
  l_org_id  NUMBER;
BEGIN
    -- Initialize the report
    -- FND_GLOBAL.apps_initialize(l_user_id, l_resp_id, l_appl_id);
    l_org_id := fnd_profile.value('ORG_ID');
    FND_CLIENT_INFO.set_org_context(l_org_id);
END Before_Parameter_MRPEPPS;




/*
 * After_Parameter_MRPEPPS
 *
 *   This function is called by Parameter_ActionView_MRPEPPS
 *   to perform validations.  It should not be invoked
 *   directly.
 */
PROCEDURE After_Parameter_MRPEPPS IS
BEGIN
  null;
END After_Parameter_MRPEPPS;




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
 * Commenting out for bug 6687733

  OracleOASIS.RunReport(
    report => RDF_FILENAME,
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
PROCEDURE Parameter_FormView_MRPEPPS (force_display in varchar2 default null ) IS

  params BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type;

  CURSOR c_business_plans IS
    select plan_id, name from bisbv_business_plans;

  CURSOR c_period_types IS
  SELECT distinct period_type name from gl_periods;

  CURSOR c_plans IS
  SELECT distinct compile_designator name from mrp_plans
   	where data_completion_date is not null
	and plan_completion_date is not null;

  CURSOR c_orgs IS
  SELECT organization_name name, organization_id from org_organization_definitions;

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

  Before_Parameter_MRPEPPS;


  htp.htmlOpen;

  BIS_UTILITIES_PUB.Build_Report_Title( FORM_FUNCTION, RDF_FILENAME, '' );

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

  params(3).Label := fnd_message.get_string( 'MRP', 'MRP_PLAN_NAME_LABEL' );
  params(3).Value := htf.formSelectOpen('P_PLAN1');
  FOR c1 in c_plans LOOP
	params(3).Value := params(3).Value || htf.formSelectOption( c1.name, NULL, 'value=' || c1.name );
  END LOOP;
  params(3).Value := params(3).Value || htf.formSelectClose;
  params(3).Value := params(3).Value || ' - ' || htf.formSelectOpen( 'P_PLAN2' );
  FOR c1 in c_plans LOOP
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
    'NAME="param" ACTION="MRP_PARAMETER_MRPEPPS.Parameter_ActionView_MRPEPPS" METHOD="GET" ', params );


END Parameter_FormView_MRPEPPS;







FUNCTION Validate_Org( P_ORG_ID             IN  VARCHAR2,
                       P_ORG_NAME           IN  VARCHAR2,
                       l_organization_id    out NOCOPY varchar2) RETURN BOOLEAN IS
  l_count  INTEGER;
BEGIN
  if (P_ORG_NAME is NULL) then
    -- htp.p( 'Please select an organization' );
    error( FND_MESSAGE.get_string( 'BOM', 'CST_ORGANIZATION_LABEL' ) );
    return FALSE;
  end if;

    select organization_id
    into l_organization_id
    from org_organization_definitions
    where organization_name like P_ORG_NAME;

  RETURN TRUE;

EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    if P_ORG_ID is null then
      -- htp.p( 'Too many matching organizations found' );
      error( FND_MESSAGE.get_string( 'BOM', 'CST_ORGANIZATION_LABEL' ) );
      return FALSE;
    end if;

      select max(organization_id), count(*)
      into l_organization_id, l_count
      from org_organization_definitions
      where organization_name like P_ORG_NAME AND
            organization_id = P_ORG_ID;

    if l_count = 1 then
      RETURN TRUE;
    else
      -- htp.p( 'Too many matching organizations found' );
      error( FND_MESSAGE.get_string( 'BOM', 'CST_ORGANIZATION_LABEL' ) );
      RETURN FALSE;
    end if;

  WHEN NO_DATA_FOUND THEN
    -- htp.p( 'No matching organization found' );
    error( FND_MESSAGE.get_string( 'BOM', 'CST_ORGANIZATION_LABEL' ) );
    return FALSE;

  WHEN OTHERS THEN
    -- htp.p( 'Uncaught exception' );
    error( FND_MESSAGE.get_string( 'BOM', 'CST_ORGANIZATION_LABEL' ) );
    return FALSE;

END Validate_Org;


FUNCTION Validate_Plan(P_PLAN_NAME       IN  VARCHAR2,
                            l_plan_name  out NOCOPY varchar2) RETURN BOOLEAN IS
  l_count  INTEGER;
BEGIN

    select compile_designator
    into l_plan_name
    from mrp_plans
    where compile_designator like P_PLAN_NAME;

  RETURN TRUE;

EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    if P_PLAN_NAME is null then
      -- htp.p( 'Too many matching areas found' );
      error( FND_MESSAGE.get_string( 'BOM', 'CST_AREA_LABEL' ) );
      return FALSE;
    end if;

    select max(compile_designator), count(*)
    into l_plan_name, l_count
    from mrp_plans
    where compile_designator like P_PLAN_NAME;

    if l_count = 1 then
      RETURN TRUE;
    else
      -- htp.p( 'Too many matching areas found' );
      error( FND_MESSAGE.get_string( 'BOM', 'CST_AREA_LABEL' ) );
      RETURN FALSE;
    end if;

  WHEN NO_DATA_FOUND THEN
    -- htp.p( 'No matching area found' );
    error( FND_MESSAGE.get_string( 'BOM', 'CST_AREA_LABEL' ) );
    return FALSE;

  WHEN OTHERS THEN
    -- htp.p( 'Uncaught exception' );
    error( FND_MESSAGE.get_string( 'BOM', 'CST_AREA_LABEL' ) );
    return FALSE;

END Validate_Plan;


/*
 * Parameter_ActionView_MRPEPPS
 *
 *   This function is invoked when the user clicks
 *   the OK button in the HTML page generated by
 *   Parameter_FormView_MRPEPPS.  It will validate
 *   the input parameters and launch the Sales Revenue
 *   report.
 */
PROCEDURE Parameter_ActionView_MRPEPPS(
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
/*
  IF( Validate_Org
      ( P_ORGANIZATION_ID, P_ORGANIZATION_NAME,
        L_ORGANIZATION_ID ) = FALSE OR
      Validate_Plan
      ( P_PLAN_NAME, L_PLAN1 ) = FALSE OR
      Validate_Plan
      ( P_PLAN_NAME, L_PLAN2 ) = FALSE ) THEN
    return;
  END IF;
*/
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


END Parameter_ActionView_MRPEPPS;





END MRP_PARAMETER_MRPEPPS;

/
