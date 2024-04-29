--------------------------------------------------------
--  DDL for Package Body HRI_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_PARAMETERS" AS
/* $Header: hripmgen.pkb 120.1 2008/01/07 12:32:36 aejjavu noship $ */

-- This is the main procedure for this package.
-- It is referenced in the AOL function definition for the report.
-- It creates all the parameters and passes them to a
-- core BIS procedure to create all the formatting of the page

--=========================================================================================


PROCEDURE Parameter_FormView
(p_report_name IN varchar2,
p_param_request IN varchar2
)
IS

-- Create PL/SQL table
  params   BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type;
  paramnum integer;
  p_option integer;

  -- bug fix: 1269713, check required parameter[s]
  l_req_check number;
  e_missing_required_parameter exception;
  l_param_missing_req_val_name varchar2(100);
  l_param_missing_req_label	varchar2(2000);

 l_job_lov_count		number;

 c_job_lov_count_high	number	:= 20;

 cursor c_job_lov_check is
 select count(*)+1
 from   per_jobs            -- bug fix 3680782
 where  business_group_id = Hr_General.Get_Business_Group_Id;


BEGIN

  -- bugs 1355513, 1355528, cbridge 28/07/2000
  -- cause an explicit check to validate the session, this ensures the
  -- session is valid and calls to fnd_global.user_id etc. will return correct values

  if (icx_sec.validatesession) then
	null;
  end if;

  -- end of fix, cbridge 28/07/2000


-- Run Before-Parameter-Form Logic

  Before_Parameter_Form(
    p_function_code => 'BIS_' || p_report_name
   ,p_rdf_filename  => p_report_name
  );

-- Assign report name to global value
  g_report_name := p_report_name;

-- Generate initial HTML

  htp.htmlOpen;
  htp.headOpen;

-- Generate JavaScript functions for cross-validation between
-- Geography dimension level LOV and Geography values LOV

   js.scriptopen;
   icx_util.lovscript;
   js.scriptclose;

-- Format Javascript Functions (if needed)

   IF instr(p_param_request,'GEOGID,') > 0 then
      Geography_Cross_Validation;
   END IF;

-- Finish heading, start body of HTML

  htp.headClose;
  htp.bodyOpen;

-- Open the HTML form

   htp.formOpen ('HRI_Parameters.Param_ActionView', 'GET',NULL,NULL, 'name="params" ');

-- Create each parameter displayed in the HTML form

   paramnum := 1;

IF instr(p_param_request,'EMPAPL,') > 0 then
 Build_Employee_Applicant(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('EMPAPL', '');
END IF;

IF instr(p_param_request,'ORG_ID,') > 0 then

   	Build_LOV(params,paramnum, 0, 'P_ORGANIZATION_ID', 'ORGANIZATION');
   	paramnum := paramnum + 1;

ELSIF instr(p_param_request,'ORG_ID+,') > 0 then

        Build_LOV(params,paramnum, 1, 'P_ORGANIZATION_ID', 'ORGANIZATION');
        paramnum := paramnum + 1;

ELSE
  htp.formHidden('P_ORGANIZATION_ID', '');
  htp.formHidden('P_ORGANIZATION_NAME', '');
END IF;

IF instr(p_param_request,'ORGPRC1,') > 0 then
 Build_Incl_Subord(params,paramnum,1);
 paramnum := paramnum + 1;
ELSIF instr(p_param_request,'ORGPRC2,') > 0 then
 Build_Incl_Subord(params,paramnum,2);
 paramnum := paramnum + 1;
ELSIF instr(p_param_request,'ORGPRC3,') > 0 then
 Build_Incl_Subord(params,paramnum,3);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('ORGPRC', '');
END IF;

IF instr(p_param_request,'BPL_ID,') > 0 then
 Build_Business_Plan(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('BPL_ID', '-1');
END IF;

IF instr(p_param_request,'GEOGID,') > 0 then
 Build_Geog_Level(params,paramnum);
 Build_Geog_Value(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('GEOLVL', '');
  htp.formHidden('GEOVAL', '');
END IF;

IF instr(p_param_request,'LOC_ID,') > 0 then

 	Build_LOV(params,paramnum, 1, 'P_LOCATION_ID', 'LOCATION');
 	paramnum := paramnum + 1;

ELSIF instr(p_param_request,'LOC_ID+,') > 0 then

 	Build_LOV(params,paramnum, 1, 'P_LOCATION_ID', 'LOCATION');
 	paramnum := paramnum + 1;

ELSE
  htp.formHidden('P_LOCATION_ID', '-1');
  htp.formHidden('P_LOCATION_NAME', '');
END IF;

IF instr(p_param_request,'PRODID,') > 0 then
 Build_Product(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('PRODID', '');
END IF;

IF  instr(p_param_request,'JOBCAT,') > 0 then
    Build_Job_Category(params,paramnum,0);
    paramnum := paramnum + 1;
    htp.formHidden('JOBCAT1', '');
    htp.formHidden('JOBCAT2', '');
    htp.formHidden('JOBCAT3', '');
ELSIF instr(p_param_request,'JOBCAT+,') > 0 then
    Build_Job_Category(params,paramnum,1);
    paramnum := paramnum + 1;
    htp.formHidden('JOBCAT', '');
ELSE
    htp.formHidden('JOBCAT', '');
    htp.formHidden('JOBCAT1', '');
    htp.formHidden('JOBCAT2', '');
    htp.formHidden('JOBCAT3', '');
END IF;

IF instr(p_param_request,'JOB_ID,') > 0 then

   -- enhancement, 1110938
   open c_job_lov_check;
   fetch c_job_lov_check into l_job_lov_count;
   close c_job_lov_check;

   IF l_job_lov_count < c_job_lov_count_high THEN
	Build_Job(params, paramnum, 0, l_req_check);

	If l_req_check = 0 THEN
		-- no jobs are set up

  		htp.formHidden('JOB_ID', '*');

		l_param_missing_req_val_name := 'JOB_ID';
		Raise e_missing_required_parameter;
	ELSE
  		htp.formHidden('P_JOB_NAME', '');
 		paramnum := paramnum + 1;
	END IF;

   ELSE
   	Build_LOV(params,paramnum, 0, 'P_JOB_ID', 'JOB');
   	paramnum := paramnum + 1;
   END IF;

ELSIF instr(p_param_request,'JOB_ID+,') > 0 then

   -- enhancement, 1110938
   open c_job_lov_check;
   fetch c_job_lov_check into l_job_lov_count;
   close c_job_lov_check;

   IF l_job_lov_count < c_job_lov_count_high THEN
	Build_Job(params, paramnum, 1, l_req_check);

	If l_req_check = 0 THEN
		-- no jobs are set up

  		htp.formHidden('JOB_ID', '*');

		l_param_missing_req_val_name := 'JOB_ID';
		Raise e_missing_required_parameter;
	ELSE
  		htp.formHidden('P_JOB_NAME', '');
 		paramnum := paramnum + 1;
	END IF;

   ELSE
        Build_LOV(params,paramnum, 1, 'P_JOB_ID', 'JOB');
        paramnum := paramnum + 1;
   END IF;
ELSE
  htp.formHidden('P_JOB_ID', '');
  htp.formHidden('P_JOB_NAME', '');
END IF;

IF instr(p_param_request,'GRD_ID,') > 0 then
 --Build_Grade_ID(params,paramnum);
 Build_LOV(params,paramnum,1,'P_GRADE_ID','GRADE');
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('P_GRADE_ID', '');
  htp.formHidden('P_GRADE_NAME','');
END IF;

IF instr(p_param_request,'PERFRT,') > 0 then
 Build_lookup_param(params,paramnum, 'HR_BIS_PERFORMANCE_RATING','PERFRT','PERFORMANCE_RATING','-1');
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('PERFRT', '');
END IF;

IF instr(p_param_request,'COMPID,') > 0 then

 Build_Competence_ID(params,paramnum,l_req_check);

 -- bug fix: 1269713
 IF l_req_check = 0 THEN
	-- a required parameter had no values found on db to populate the drop down list
  	htp.formHidden('COMPID', '*');

	l_param_missing_req_val_name := 'COMPID';
	Raise e_missing_required_parameter;
 END IF;

 paramnum := paramnum + 1;

ELSE
  htp.formHidden('COMPID', '');
END IF;

IF instr(p_param_request,'PFMEAS,') > 0 then
 Build_Proficiency_Measure(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('PFMEAS', '');
END IF;

IF instr(p_param_request,'PAYRLL,') > 0 then

 Build_Payroll_ID(params,paramnum, 0, l_req_check);

 -- bug fix: 1269713
 IF l_req_check = 0 THEN
	-- a required parameter had no values found on db to populate the drop down list
  	htp.formHidden('PAYRLL', '*');

	l_param_missing_req_val_name := 'PAYRLL';
	Raise e_missing_required_parameter;
 END IF;

 paramnum := paramnum + 1;

ELSIF instr(p_param_request,'PAYRLL+,') > 0 then
 Build_Payroll_ID(params,paramnum, 1, l_req_check);

 -- bug fix: 1269713
 IF l_req_check = 0 THEN
	-- a required parameter had no values found on db to populate the drop down list
  	htp.formHidden('PAYRLL', '*');

	l_param_missing_req_val_name := 'PAYRLL';
	Raise e_missing_required_parameter;
 END IF;

 paramnum := paramnum + 1;

ELSE
  htp.formHidden('PAYRLL', '');
END IF;

if instr(p_param_request, 'BGT_ID,') > 0  then
   htp.comment('called Build_Budget');
   Build_Budget(params,paramnum,l_req_check);

 -- bug fix: 1269713
 IF l_req_check = 0 THEN
	-- a required parameter had no values found on db to populate the drop down list
  	htp.formHidden('BGT_ID', '*');

	l_param_missing_req_val_name := 'BGT_ID';
	Raise e_missing_required_parameter;
 END IF;

   paramnum := paramnum+1;

elsif instr(p_param_request, 'BGT_PQH_ID,') > 0  then
   Build_pqh_Budget(params,paramnum,l_req_check);
   htp.comment('called Build_pqh_Budget');

 -- bug fix: 1269713
 IF l_req_check = 0 THEN
        -- a required parameter had no values found on db to populate the drop down list
        htp.formHidden('BGT_ID', '*');

        l_param_missing_req_val_name := 'BGT_ID';
        Raise e_missing_required_parameter;
 END IF;

   paramnum := paramnum+1;
ELSE
  htp.formHidden('BGT_ID', '');
END IF;

IF instr(p_param_request, 'BGTTYP,') > 0 then
 Build_lookup_param(params,paramnum, 'HR_BIS_BGTTYP','BGTTYP','BUDGET_MEASUREMENT_TYPE','');
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('BGTTYP', '');
END IF;

IF instr(p_param_request,'PROPRN,') > 0 then
 Build_lookup_param(params,paramnum, 'HR_BIS_PROPOSAL_REASON', 'PROPRN', 'PROPOSAL_REASON', '');
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('PROPRN', '');
END IF;

IF instr(p_param_request,'SEPRSN,') > 0 then
 Build_lookup_param(params,paramnum, 'HR_BIS_SEPARATION_REASON', 'SEPRSN', 'LEAV_REAS', 'BIS_ALL');
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('SEPRSN', '');
END IF;

IF instr(p_param_request,'VIEWBY1,') > 0 then
 Build_View_By(params,paramnum,1);
 paramnum := paramnum + 1;
ELSIF instr(p_param_request,'VIEWBY2,') > 0 then
 Build_View_By(params,paramnum,2);
 paramnum := paramnum + 1;
ELSIF instr(p_param_request,'VIEWBY3,') > 0 then
 Build_View_By(params,paramnum,3);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('VIEWBY', '');
END IF;

IF instr(p_param_request,'DISPLY,') > 0 then
 Build_Display_By(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('DISPLY', '');
  htp.formHidden('DCOUNT', '');
END IF;

IF instr(p_param_request,'ORDERB1,') > 0 then
 Build_Order_By(params,paramnum,1);
 paramnum := paramnum + 1;
ELSIF instr(p_param_request,'ORDERB2,') > 0 then
 Build_Order_By(params,paramnum,2);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('ORDERB', '');
END IF;

IF instr(p_param_request,'CURRCD,') > 0 then
 Build_Report_Currency(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('CURRCD', '');
END IF;

IF instr(p_param_request,'EXCCUR,') > 0 then
 Build_Exclude_Currency(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('EXCCUR', '');
END IF;

IF instr(p_param_request,'FRQNCY,') > 0 then
 Build_Frequency(params,paramnum);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('FRQNCY', 'CM');
END IF;

IF instr(p_param_request,'DATE1,') > 0 then
 Build_Rep_Dates(params,paramnum,1);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('P_REPORT_DATE_V', '');
END IF;

IF instr(p_param_request,'DATE2,') > 0 then
 Build_Rep_Dates(params,paramnum,2);
 paramnum := paramnum + 1;
ELSE
  htp.formHidden('P_START_DATE_V', '*');
  htp.formHidden('P_END_DATE_V', '*');
END IF;

-- Create hidden fields for Business Group ID and Organization Version

  htp.formHidden('BUS_ID', g_bus_id);
  htp.formHidden('ORGVER', g_orgver);
  htp.formHidden('RPNAME', p_report_name);

-- Build Parameter Form

  BIS_UTILITIES_PUB.Build_Parameter_Form('NAME="'
              || p_report_name || '"
              ACTION="HRI_Parameters.Param_ActionView" METHOD="GET"', params);

  htp.formClose;
  htp.bodyClose;
  htp.htmlClose;

EXCEPTION
	WHEN e_missing_required_parameter THEN
  	  BEGIN

		IF l_param_missing_req_val_name = 'PAYRLL' THEN
			l_param_missing_req_label := Display_Label('HR_BIS_PAYROLL');
		END IF;

		IF l_param_missing_req_val_name = 'ORG_ID' THEN
			l_param_missing_req_label := Display_Label('HR_BIS_ORGANIZATION');
		END IF;

		IF l_param_missing_req_val_name = 'COMPID' THEN
			l_param_missing_req_label := Display_Label('HR_BIS_COMPETENCE');
		END IF;

		IF l_param_missing_req_val_name = 'JOB_ID' THEN
			l_param_missing_req_label := Display_Label('HR_BIS_JOB');
		END IF;

		IF l_param_missing_req_val_name = 'BGT_ID' THEN
			l_param_missing_req_label := Display_Label('HR_BIS_BUDGET');
		END IF;

		fnd_message.set_name('HRI','HR_BIS_PLSQL_CART_REQ_PARAM');
		fnd_message.set_token('PARAMETER',l_param_missing_req_label);

		htp.br;
		htp.br;
		htp.br;
		htp.bold(fnd_message.get);
		htp.formClose;
		htp.bodyClose;
		htp.htmlClose;


	  END;

END Parameter_FormView;

--=========================================================================================

-- Public procedure which executes when the 'OK' button is clicked
-- on the report parameter page

PROCEDURE Param_ActionView(
          P_ORGANIZATION_ID   varchar2 default '-1',
          P_ORGANIZATION_NAME varchar2,
          ORGPRC              varchar2 default 'SIRO',
          ORGVER              number,
          BUS_ID              number,
          BPL_ID              number,
          GEOLVL              varchar2 default '1',
          GEOVAL              varchar2 default '-1',
          PRODID              varchar2 default '-1',
          P_JOB_ID            varchar2 default '-1',
          P_JOB_NAME          varchar2,
          JOBCAT              varchar2 default '__ALL__',
          JOBCAT1             varchar2 default '__ALL__',
          JOBCAT2             varchar2 default '__ALL__',
          JOBCAT3             varchar2 default '__ALL__',
          BGTTYP              varchar2,
          VIEWBY              varchar2 default 'HR_BIS_TIME',
          FRQNCY              varchar2 default 'CM',
          P_START_DATE_V      varchar2,
          P_END_DATE_V        varchar2,
          P_LOCATION_ID       varchar2 default '-1',
          P_LOCATION_NAME     varchar2,
          BGT_ID              varchar2,
          COMPID              varchar2,
          CURRCD              varchar2,
          P_REPORT_DATE_V     varchar2,
          EMPAPL              varchar2,
          EXCCUR              varchar2,
          P_GRADE_ID          varchar2 default '-1',
          P_GRADE_NAME        varchar2,
          ORDERB              varchar2,
          PAYRLL              varchar2,
          PERFRT              varchar2,
          PFMEAS              varchar2,
          PROPRN              varchar2,
          SEPRSN              varchar2,
          DISPLY              varchar2,
          DCOUNT              varchar2,
          RPNAME              varchar2
) IS

BEGIN


-- Run After Parameter Form Logic
   HRI_Parameters.After_Parameter_Form;
/*   OracleOASIS.RunReport(
    report     => RPNAME,
    parameters => 'ORG_ID='         ||nvl(p_organization_id,-1)|| '*' ||
                  'ORGPRC='         ||ORGPRC        || '*' ||
                  'ORGVER='         ||ORGVER        || '*' ||
                  'BUS_ID='         ||BUS_ID        || '*' ||
                  'BPL_ID='         ||BPL_ID        || '*' ||
                  'GEOLVL='         ||GEOLVL        || '*' ||
                  'GEOVAL='         ||GEOVAL        || '*' ||
                  'PRODID='         ||PRODID        || '*' ||
                  'JOB_ID='         ||nvl(p_job_id,'-1')|| '*' ||
                  'JOBCAT='         ||JOBCAT        || '*' ||
                  'JOBCAT1='        ||JOBCAT1       || '*' ||
                  'JOBCAT2='        ||JOBCAT2       || '*' ||
                  'JOBCAT3='        ||JOBCAT3       || '*' ||
                  'BGTTYP='         ||BGTTYP        || '*' ||
                  'VIEWBY='         ||VIEWBY        || '*' ||
                  'FRQNCY='         ||FRQNCY        || '*' ||
                  'LOC_ID='         ||nvl(p_location_id, '-1')|| '*'||
                  'BGT_ID='         ||BGT_ID        || '*' ||
                  'COMPID='         ||COMPID        || '*' ||
                  'CURRCD='         ||CURRCD        || '*' ||
                  'P_REPORT_DATE_V=' ||P_REPORT_DATE_V || '*' ||
                  'EMPAPL='         ||EMPAPL        || '*' ||
                  'EXCCUR='         ||EXCCUR        || '*' ||
                  'GRD_ID='         ||NVL(P_GRADE_ID,'-1')|| '*' ||
                  'ORDERB='         ||ORDERB        || '*' ||
                  'PAYRLL='         ||PAYRLL        || '*' ||
                  'PERFRT='         ||PERFRT        || '*' ||
                  'PFMEAS='         ||PFMEAS        || '*' ||
                  'PROPRN='         ||PROPRN        || '*' ||
                  'SEPRSN='         ||SEPRSN        || '*' ||
                  'DISPLY='         ||DISPLY        || '*' ||
                  'DCOUNT='         ||DCOUNT        || '*' ||
                  'P_START_DATE_V='||P_START_DATE_V|| '*' ||
                  'P_END_DATE_V='  ||P_END_DATE_V  || '*',
    paramform  => 'NO'
  );
*/
END Param_ActionView;

--=========================================================================================

PROCEDURE Before_Parameter_Form(
  p_function_code IN VARCHAR2
 ,p_rdf_filename  IN VARCHAR2
) IS

BEGIN

-- This procedure replaces the reports BeforePForm Trigger and
-- creates the banner and sets up business group id and org ver
-- Create Banner for top of Parameter Form
-- This uses Core BIS package called BIS_UTILITIES_PUB
-- Need to pass it Function Code and RDF Filename (without extension)

  BIS_UTILITIES_PUB.Build_Report_Title(
    p_Function_Code => p_function_code
   ,p_Rdf_Filename  => p_rdf_filename
   ,p_Body_Attribs  => NULL
  );

-- Initialize the report parameters
-- Pass in globals for user id, responsibility id, application id,
-- and security group.  The correct business group and organization
-- version (used to determine Org LOV) are determined and passed back
-- into global variables in this package

  HrFastAnswers.Initialize(
    p_user_id                  => FND_GLOBAL.user_id,
    p_resp_id                  => FND_GLOBAL.resp_id,
    p_resp_appl_id             => FND_GLOBAL.resp_appl_id,
    p_sec_group_id             => FND_GLOBAL.security_group_id,
    p_business_group_id        => g_bus_id,
    p_org_structure_version_id => g_orgver);

END Before_Parameter_Form;

--=========================================================================================

PROCEDURE After_Parameter_Form IS
BEGIN

-- This procedure replaces the reports AfterPForm Trigger and initializes
-- globals (just in case they are not already set)

-- Initialize the report parameters

  HrFastAnswers.Initialize(
    p_user_id                  => FND_GLOBAL.user_id,
    p_resp_id                  => FND_GLOBAL.resp_id,
    p_resp_appl_id             => FND_GLOBAL.resp_appl_id,
    p_sec_group_id             => FND_GLOBAL.security_group_id,
    p_business_group_id        => g_bus_id,
    p_org_structure_version_id => g_orgver);

END After_Parameter_Form;

--=========================================================================================

FUNCTION Display_Label(
  p_label_name IN VARCHAR2 )
RETURN VARCHAR2 IS

BEGIN

-- This private function gets the translation for each of the report parameter
-- labels.  Pass in the message_name (e.g. 'HR_BIS_PRODUCT_CATEGORY') and
-- it passes back the correct translation

   fnd_message.set_name( 'HRI', p_label_name );
   return fnd_message.get;

END Display_Label;

--=========================================================================================

PROCEDURE Build_Business_Plan(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

  cursor c_bpl is
    select -1     plan_id
          ,'    ' plan_name
    from sys.dual
    union
    select plan_id
          ,description plan_name
    from  bisbv_business_plans
    where current_plan_flag = 'Y'
    order by 2;

BEGIN

-- Creates Business Plan Parameter

  params(i).Label := Display_Label('HR_BIS_BUSINESS_PLAN');
  params(i).Value := htf.formSelectOpen( 'BPL_ID' );

  for ci_bpl in c_bpl loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_bpl.plan_name,NULL,
                       'VALUE="'||ci_bpl.plan_id||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Business_Plan;

--=========================================================================================

PROCEDURE Build_Geog_Level(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

  cursor c_geog_level is
    select '1'          lev_code,
           message_text lev
    from   fnd_new_messages
    where  message_name = 'HR_BIS_AREA'
    and    application_id = 453
    and    language_code = userenv('LANG')
    union
    select '2'          lev_code,
           message_text lev
    from   fnd_new_messages
    where  message_name = 'HR_BIS_COUNTRY'
    and    application_id = 453
    and    language_code = userenv('LANG')
    union
    select '3'          lev_code,
           message_text lev
    from   fnd_new_messages
    where  message_name = 'HR_BIS_REGION'
    and    application_id = 453
    and    language_code = userenv('LANG');

BEGIN

-- Creates Geography Dimension Level Parameter

  params(i).Label := htf.formSelectOpen( 'GEOLVL',NULL, NULL,
                     'OnChange="getGeog(document.params.GEOVAL, '||
                               'document.params.GEOLVL.selectedIndex)" '  );

  for ci_geog_level in c_geog_level loop

    params(i).Label := params(i).Label ||
                       htf.formSelectOption(ci_geog_level.lev,NULL,
                       'VALUE="'||ci_geog_level.lev_code||'"');
  end loop;

  params(i).Label := params(i).Label || htf.formSelectClose;

END Build_Geog_Level;

--=========================================================================================

PROCEDURE Build_Geog_Value(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

BEGIN

-- Creates Geography Dimension Value Parameter

  params(i).Value := htf.formSelectOpen( 'GEOVAL' );

  for ci_area in c_area loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_area.area,NULL,
                       'VALUE="'||ci_area.area_code||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Geog_Value;

--=========================================================================================

PROCEDURE Build_Product (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

  cursor c_product_category is
    select '-1' id
    ,      ' ' value
    from dual
    UNION
    select id
    ,      value
    from bis_product_categories_v
    order by 2;

BEGIN

-- Create Product Category parameter
  params(i).Label := Display_Label('HR_BIS_PRODUCT_CATEGORY');
  params(i).Value := htf.formSelectOpen( 'PRODID' );

  for ci_product_category in c_product_category loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_product_category.value,NULL,
                       'VALUE="'||ci_product_category.id||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Product;

--=========================================================================================

PROCEDURE Build_Job_Category (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN OUT  NOCOPY NUMBER
 ,p_option IN NUMBER
) IS

  j integer;

  cursor c_job_category is
    select lookup_code
          ,meaning
    from  fnd_common_lookups
    where lookup_type = 'JOB_CATEGORIES'
    order by 2;

BEGIN

-- This procedure creates the Job Category parameter

IF p_option = 0 THEN
  params(i).Label := Display_Label('HR_BIS_JOB_CATEGORY');
  params(i).Value := htf.formSelectOpen( 'JOBCAT' );
  params(i).Value := params(i).Value ||
                     htf.formSelectOption('    ',NULL, 'VALUE="__ALL__"');

  for ci_job_category in c_job_category loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_category.meaning,NULL,
                       'VALUE="'||ci_job_category.lookup_code||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;
ELSE
  params(i).Label := Display_Label('HR_BIS_JOB_CATEGORY1');
  params(i).Value := htf.formSelectOpen( 'JOBCAT1' );
  for ci_job_category in c_job_category loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_category.meaning,NULL,
                       'VALUE="'||ci_job_category.lookup_code||'"');
  end loop;
  params(i).Value := params(i).Value || htf.formSelectClose;
  i := i + 1;

  params(i).Label := Display_Label('HR_BIS_JOB_CATEGORY2');
  params(i).Value := htf.formSelectOpen( 'JOBCAT2' );
  params(i).Value := params(i).Value ||
                     htf.formSelectOption('    ',NULL, 'VALUE="__ALL__"');
  for ci_job_category in c_job_category loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_category.meaning,NULL,
                       'VALUE="'||ci_job_category.lookup_code||'"');
  end loop;
  params(i).Value := params(i).Value || htf.formSelectClose;
  i := i + 1;

  params(i).Label := Display_Label('HR_BIS_JOB_CATEGORY3');
  params(i).Value := htf.formSelectOpen( 'JOBCAT3' );
  params(i).Value := params(i).Value ||
                     htf.formSelectOption('    ',NULL, 'VALUE="__ALL__"');
  for ci_job_category in c_job_category loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_category.meaning,NULL,
                       'VALUE="'||ci_job_category.lookup_code||'"');
  end loop;
  params(i).Value := params(i).Value || htf.formSelectClose;

END IF;

END Build_Job_Category;

--=========================================================================================


-- cbridge , 28/06/2001, added build_pqh_budget for pqh budget changes

PROCEDURE build_pqh_budget (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
, p_return_status IN OUT NOCOPY  NUMBER
) IS

  cursor c_bgt_id is
  select b.budget_id, b.budget_name
  from pqh_budgets b ,pqh_budget_versions bv
  where b.business_group_id = g_bus_id
  and   b.budget_id = bv.budget_id
  and trunc(sysdate) between bv.date_from and nvl( bv.date_to, sysdate+1 )
  order by b.budget_name ;

  l_budget_id_count     number :=0;

BEGIN

-- This procedure creates the Budget parameter
  params(i).Label := Display_Label('HR_BIS_BUDGET');
  params(i).Value := htf.formSelectOpen( 'BGT_ID' );

  for ci_bgt_id in c_bgt_id loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_bgt_id.budget_name, NULL,
                       'VALUE="'||ci_bgt_id.budget_id||'"');

    l_budget_id_count := l_budget_id_count+1;

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

  IF l_budget_id_count = 0 THEN
        p_return_status := 0;  -- error, no budget set up
  ELSE
        p_return_status := 1;
  END IF;

END build_pqh_budget;


PROCEDURE Build_Budget (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
, p_return_status IN OUT NOCOPY  NUMBER
) IS

  cursor c_bgt_id is
  select b.budget_id, b.name
  from per_budgets b ,per_budget_versions bv
  where b.business_group_id = g_bus_id
  and b.budget_id = bv.budget_id
  and trunc(sysdate) between bv.date_from and nvl( bv.date_to, sysdate+1 )
  order by b.name ;

  l_budget_id_count	number :=0;

BEGIN

-- This procedure creates the Budget Measurement Type parameter

  params(i).Label := Display_Label('HR_BIS_BUDGET');
  params(i).Value := htf.formSelectOpen( 'BGT_ID' );

  for ci_bgt_id in c_bgt_id loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_bgt_id.name, NULL,
                       'VALUE="'||ci_bgt_id.budget_id||'"');

    l_budget_id_count := l_budget_id_count+1;

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

  IF l_budget_id_count = 0 THEN
	p_return_status := 0;  -- error, no budget set up
  ELSE
	p_return_status := 1;
  END IF;

END Build_Budget;

--=========================================================================================

PROCEDURE Build_Frequency (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

  cursor c_frequency is
    select lookup_code
          ,meaning
    from   hr_lookups
    where  lookup_type = 'PROC_PERIOD_TYPE'
    and    lookup_code in ('CM','BM','Q','SY','Y')
    order by decode(lookup_code, 'CM',1, 'BM',2, 'Q',3, 'SY',6, 'Y',12, 99);

BEGIN

-- This procedure creates the Frequency Parameter

  params(i).Label := Display_Label('HR_BIS_FREQUENCY');
  params(i).Value := htf.formSelectOpen( 'FRQNCY' );

  for ci_frequency in c_frequency loop

    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_frequency.meaning, NULL,
                       'VALUE="'||ci_frequency.lookup_code||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Frequency;

--=========================================================================================

PROCEDURE Geography_Cross_Validation IS

-- This procedure builds the JavaScript code for cross-validation of the
-- Geography parameter.
-- Whenever the Geography dimension level (Area/Country/Region) changes,
-- the values displayed in the Geography LOV must change.

-- Cursor for Countries

  cursor c_country is
    select '-1' territory_code
    ,      ' ' country
    from dual
    union
    select territory_code
    , territory_short_name country
    from fnd_territories_vl
    order by 2;

-- Cursor for Regions

  cursor c_region is
    select '-1' region_code, ' ' region
    from dual
    union
    select lookup_code region_code, meaning region
    from fnd_lookups
    where lookup_type = 'REGION'
    order by 2;

-- bug 1301690 start

    java_string  varchar2(6000);
    java_string2 varchar2(32767);
    java_string3 varchar2(6000);

BEGIN

--  js.scriptopen;
--  icx_util.lovscript;
--  js.scriptclose;

-- Java Script to create functionality for cross validation of Geography parameters

  java_string := java_string|| 'function getGeog(field, index)' ;
  java_string := java_string|| '{' ;
  java_string := java_string|| ' while( field.length > 0 )' ;
  java_string := java_string|| '  field.options[field.length -1 ] = null;' ;
  java_string := java_string|| ' if (index == 0 )' ;
  java_string := java_string||   '{' ;

  for ci_area in c_area loop
    java_string := java_string||    '  field.options[field.length] = ';
    java_string := java_string||    ' new Option(''' ||replace(ci_area.area, '''');
    java_string := java_string||             ''',''' ||ci_area.area_code||''');';
  end loop;

  java_string := java_string||     '}' ;
  java_string := java_string||   '  else if (index == 1 )' ;
  java_string := java_string||     '{' ;

  for ci_country in c_country loop

    java_string2 := java_string2||      '  field.options[field.length] = ';
    java_string2 := java_string2||      ' new Option('''||replace(ci_country.country, '''');
    java_string2 := java_string2||             ''',''' ||ci_country.territory_code||''');' ;
  end loop;

  java_string2 := java_string2||   '}' ;
  java_string2 := java_string2|| '  else if (index == 2 )' ;
  java_string2 := java_string2||   '{' ;

  for ci_region in c_region loop
    java_string3 := java_string3||     '  field.options[field.length] = ';
    java_string3 := java_string3||     ' new Option('''||replace(ci_region.region, '''');
    java_string3 := java_string3||             ''','''||ci_region.region_code||''');' ;
  end loop;

  java_string3 := java_string3||   '}' ;
  java_string3 := java_string3|| '}' ;
  java_string3 := java_string3|| ' ' ;

-- Build up Java Script
  BIS_UTILITIES_PUB.Build_Report_Header(java_string||java_string2||java_string3);

-- bug 1301690 end

END Geography_Cross_Validation;

--=========================================================================================

PROCEDURE Build_Budget_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS


-- This function sets up a drop down list containing the manpower budgets which
-- have been set up for the current responsibilities business group.
-- The value returned by this drop down list will be called 'BGT_ID'
-- Parameter Request String : BGT_ID

  cursor c_bgt_id is
  select b.budget_id, b.name
  from per_budgets b ,per_budget_versions bv
  where b.business_group_id = g_bus_id
  and b.budget_id = bv.budget_id
  and trunc(sysdate) between bv.date_from and nvl( bv.date_to, sysdate+1 );

  BEGIN

  params(i).Label := Display_Label('HR_BIS_BUDGET');
  params(i).Value := htf.formSelectOpen('BGT_ID');

  for ci_bgt_id in c_bgt_id loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_bgt_id.name, NULL,
                       'VALUE="'||ci_bgt_id.budget_id||'"');


  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;


END Build_Budget_ID;

--=========================================================================================

PROCEDURE Build_Competence_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,p_return_status IN OUT NOCOPY NUMBER
) IS

-- This function sets up a drop down list containing the competancies
-- which have been set up for the current responsibilities business group.
-- The value returned by this drop down list will be called 'COMPID'.
-- Parameter Request String : COMPID

  cursor c_compid is
  select competence_id, name
  from   per_competences_vl
  where  business_group_id = g_bus_id
  or     business_group_id is null -- bug 2518364 dsheth Sep 3, 2002
  order  by 2;

  l_comp_id_count	 number :=0;

  BEGIN

  params(i).Label := Display_Label('HR_BIS_COMPETENCE');

  params(i).Value := htf.formSelectOpen('COMPID');

  for ci_compid in c_compid loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_compid.name, NULL,
                       'VALUE="'||ci_compid.competence_id||'"');

    l_comp_id_count := l_comp_id_count+1;

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

  IF l_comp_id_count = 0 THEN
	p_return_status := 0;  -- error, no competencies set up
  ELSE
	p_return_status := 1;
  END IF;


END Build_Competence_ID;

--=========================================================================================

PROCEDURE Build_Report_Currency(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS
-- This function gives a drop down list showing the currencies in
-- which the figures can appear on the report
-- Parameter Request String : CURRCD

  cursor c_currcd is
  select c.currency_code , c.name
  from per_business_groups b , fnd_currencies_vl c
  where b.business_group_id = hr_bis.get_sec_profile_bg_id     -- bug 2968520
  and c.enabled_flag = 'Y'
  and sysdate between nvl(c.start_date_active, hr_general.start_of_time)
  and nvl(c.end_date_active, hr_general.end_of_time)
  order by decode(b.currency_code, c.currency_code, 1,2) , c.currency_code;

  BEGIN

  params(i).Label := Display_Label('HR_BIS_REPORT_CURRENCY');

  params(i).Value := htf.formSelectOpen('CURRCD');

  for ci_currcd in c_currcd loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_currcd.currency_code||' - '||ci_currcd.name, NULL,
                       'VALUE="'||ci_currcd.currency_code||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Report_Currency;

--=========================================================================================

PROCEDURE Build_Display_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

   inc_amt integer;

-- This function sets up a drop down list containing two display by options.
-- The first part of the function builds a list containing options to see
-- the Top or Bottom values; the variable returned by this drop down
-- list will be called 'DISPLY'.
-- The second part of the function builds a numeric list,
-- to elect how many rows the user wishes to see on the report;
-- the variable returned by this drop down list will be called 'DCOUNT.

  BEGIN

-- Parameter Request String : DISPLY

   params(i).Label := Display_Label('HR_BIS_DISPLAY');
   params(i).Value := htf.formSelectOpen('DISPLY');
   params(i).Value := params(i).Value || htf.formSelectOption(fnd_message.get_string( 'HRI' ,'HR_BIS_TOP'), NULL, 'VALUE="'||'HR_BIS_TOP'||'"');
   params(i).Value := params(i).Value || htf.formSelectOption(fnd_message.get_string( 'HRI' ,'HR_BIS_BOTTOM'), NULL, 'VALUE="'||'HR_BIS_BOTTOM'||'"');

   params(i).Value := params(i).Value || htf.formSelectClose;

   params(i).Value := params(i).Value || htf.formSelectOpen('DCOUNT');

   inc_amt := 1;
   for inc_val IN 1 .. 9
   LOOP
       params(i).Value := params(i).Value || htf.formSelectOption(inc_val, NULL, 'VALUE="'||inc_val||'"');
   END LOOP;

   params(i).Value := params(i).Value || htf.formSelectOption(10, 'Yes', 'VALUE="10"');

   for inc_val IN 11.. 30
   LOOP
       params(i).Value := params(i).Value || htf.formSelectOption(inc_val, NULL, 'VALUE="'||inc_val||'"');
   END LOOP;
   inc_amt := 2;

   for inc_val IN 16 .. 24
   LOOP
       params(i).Value := params(i).Value || htf.formSelectOption(inc_amt*inc_val, NULL, 'VALUE="'||inc_amt*inc_val||'"');
   END LOOP;

   inc_amt := 5;

   for inc_val IN 10 .. 19
   LOOP
       params(i).Value := params(i).Value || htf.formSelectOption(inc_amt*inc_val, NULL, 'VALUE="'||inc_amt*inc_val||'"');
   END LOOP;

   params(i).Value := params(i).Value || htf.formSelectOption('99', NULL, 'VALUE="99"');

   params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Display_by;

--=========================================================================================

PROCEDURE Build_Exclude_Currency(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

-- This list gives the option to include (or exclude)
-- currencies other than the reporting currency.
-- Parameter Request String : EXCCUR

  cursor c_exccur is
  select message_name , message_text
  from fnd_new_messages
  where message_name in ('HR_BIS_INCLUDE','HR_BIS_EXCLUDE')
  and language_code = userenv('LANG')
  and application_id = 453
  order by decode(message_name,'HR_BIS_EXCLUDE','1,2');

  BEGIN

  params(i).Label := Display_Label('HR_BIS_OTHER_CURRENCIES');
  params(i).Value := htf.formSelectOpen('EXCCUR');

  for ci_exccur in c_exccur loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_exccur.message_text, NULL,
                       'VALUE="'||ci_exccur.message_name||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Exclude_Currency;

--=========================================================================================

/*
This procedure was commented out to fix the bug 1863276.
D.sheth 08-AUG-2001

PROCEDURE Build_Grade_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

-- This function gives a list of grades as defined in HR,
-- upon which the report willl be based.
-- Parameter Request String : GRD_ID

  cursor c_grd_id is
  select grade_id,name
  from per_grades
  where business_group_id = g_bus_id
  order by name;

  BEGIN

  params(i).Label := Display_Label('HR_BIS_GRADE');
  params(i).Value := htf.formSelectOpen('GRD_ID');
  params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="-1"');

  for ci_grd_id in c_grd_id loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_grd_id.name, NULL,
                       'VALUE="'||ci_grd_id.grade_id||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Grade_ID;
*/
--=========================================================================================

PROCEDURE Build_Employee_Applicant(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

-- Facility Provided : gives an option whether to show employees or applicants on the report
-- Parameter Request String : EMPAPL

  BEGIN

  params(i).Label := Display_Label('HR_BIS_EMP_APP');
  params(i).Value := htf.formSelectOpen('EMPAPL');
  params(i).Value := params(i).Value
                     || htf.formSelectOption(fnd_message.get_string( 'HRI' ,'HR_BIS_CURRENT_EMPL_IN_JOB'),
                     NULL,
                     'VALUE="E"');
  params(i).Value := params(i).Value
                     || htf.formSelectOption(fnd_message.get_string( 'HRI' ,'HR_BIS_CURRENT_APPL_FOR_JOB'),
                     NULL,
                     'VALUE="A"');

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Employee_Applicant;

--=========================================================================================

PROCEDURE Build_Order_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i        IN   NUMBER
 ,p_option IN   NUMBER
) IS

-- Parameter Request String : ORDERB1, ORDERB2
-- Depending on p_option, this function sets up a
-- list to elect to order the report by "total" / "percent"
-- separated OR by "total" / "percent" increase in manpower.
-- Parameters received : p_option - value 1 returns a list for
-- 'Separated'; value 2 returns a list for 'Increase'

  BEGIN

  params(i).Label := Display_Label('HR_BIS_ORDER_BY');
  params(i).Value := htf.formSelectOpen('ORDERB');

  IF p_option = 1
  THEN
    params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI' ,'HR_BIS_TOTAL')
                     || ' ' || fnd_message.get_string('HRI', 'HR_BIS_SEPARATED'),
                     NULL, 'VALUE="HR_BIS_TOTAL"');
    params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI', 'HR_BIS_PERCENT')
                     || ' ' || fnd_message.get_string('HRI', 'HR_BIS_SEPARATED'),
                     NULL, 'VALUE="HR_BIS_PERCENT"');
  ELSIF p_option = 2
  THEN
    params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI', 'HR_BIS_PERCENT')
                     || ' ' || fnd_message.get_string('HRI', 'HR_BIS_INCREASE'),
                     NULL, 'VALUE="HR_BIS_PERCENT"');
    params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI' ,'HR_BIS_TOTAL')
                     || ' ' || fnd_message.get_string('HRI', 'HR_BIS_INCREASE'),
                     NULL, 'VALUE="HR_BIS_TOTAL"');
  END IF;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Order_By;

--=========================================================================================

PROCEDURE Build_Incl_Subord(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i         IN   NUMBER
 ,p_option  IN   NUMBER
) IS

-- Parameter Request String : ORGPRC1
-- gives the option of rolling up the values
--  this parameter is for reports which Include Subordinates
--
-- Parameter Request String : ORGPRC2
-- gives the option of showing a single instance,
-- or of showing the selected organisation with all subordinates.
-- This parameter is for reports which do not Roll Up values.
--
-- Parameter Request String : ORGPRC3
-- gives the option of rolling up the values
-- this parameter is for reports which show only the selected organisation
--

  cursor c_lookup is
  select meaning, lookup_code
  from hr_lookups
  where lookup_type = 'YES_NO'
  and lookup_code IN ('Y', 'N');

  lookup_yes varchar2(80);
  lookup_no  varchar2(80);

  BEGIN

  -- If p_option = 1 then the rollup label needs to be a rollup each org
  -- label.  Bug #1349001 - mjandrew - 01-Aug-2000
  IF p_option = 1 THEN
    params(i).Label := Display_Label('HR_BIS_ROLLUP_EACH_ORG');
  ELSE
    params(i).Label := Display_Label('HR_BIS_ROLLUP_ORGANIZATIONS');
  END IF;
  params(i).Value := htf.formSelectOpen('ORGPRC');

  for ci_lookup in c_lookup loop
      IF ci_lookup.lookup_code = 'Y'
      THEN
         lookup_yes := ci_lookup.meaning;
      ELSE
         lookup_no  := ci_lookup.meaning;
      END IF;
  end loop;

  if p_option = 1
  THEN
--   'ISRO'-'Y'   'ISNR'-'N'
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_yes, NULL, 'VALUE="ISRO"');

-- this one is the default selection, so has 'Yes' instead of NULL for the second parameter.
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_no,  'Yes', 'VALUE="ISNR"');

  ELSIF p_option = 2
  THEN
--   'ISNR'-'Y'   'SINR'-'N'
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_yes, NULL, 'VALUE="ISNR"');
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_no,  NULL, 'VALUE="SINR"');
  ELSIF p_option = 3
  THEN
--   'SIRO'-'Y'   'SINR'-'N'
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_yes, NULL, 'VALUE="SIRO"');
     params(i).Value := params(i).Value ||
                     htf.formSelectOption(lookup_no,  NULL, 'VALUE="SINR"');
  END IF;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Incl_Subord;

--=========================================================================================

PROCEDURE Build_Payroll_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,p_option IN NUMBER
 ,p_return_status IN OUT NOCOPY  NUMBER
) IS

-- This function gives a list of payrolls which can be viewed on the report.
-- Parameter Request String : PAYRLL

  cursor c_payrll is
  select DISTINCT payroll_id , payroll_name
  from pay_payrolls_f
  where business_group_id = g_bus_id
  order by payroll_name;
  -- bug 3264873, added DISTINCT in cursor to exlcude multiple payroll names
  -- that appear to customers to be duplicates.

  l_payroll_id_counter	number	:=0;

  BEGIN

  params(i).Label := Display_Label('HR_BIS_PAYROLL');
  params(i).Value := htf.formSelectOpen('PAYRLL');

  IF p_option = 1 THEN
     params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="-1"');
  END IF;

  for ci_payrll in c_payrll loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_payrll.payroll_name, NULL,
                       'VALUE="'||ci_payrll.payroll_id||'"');

    l_payroll_id_counter := l_payroll_id_counter +1;

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

  IF l_payroll_id_counter = 0 THEN
	p_return_status := 0;  -- error, no payrolls set up
  ELSE
	p_return_status := 1;
  END IF;


END Build_Payroll_ID;

--=========================================================================================

PROCEDURE Build_Rep_Dates(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i             IN NUMBER
 ,P_OPTION      IN NUMBER
) IS

-- DATE1 - gives a single date on which to report (snapshot)
-- DATE2 - gives two date fields representing the start and end of a time period (range)

BEGIN

If p_option = 1 THEN
    params(i).Label := Display_Label('HR_BIS_REPORTING_DATE');
    params(i).Value := htf.formtext('P_REPORT_DATE_V', 11, NULL, to_char(sysdate,'DD-MON-YYYY'));
 else
    params(i).Label := Display_Label('HR_BIS_REPORTING_DATES');

    params(i).Value := htf.formText('P_START_DATE_V',11,NULL, to_char(add_months(sysdate,-12)+1,'DD-MON-YYYY'))
                             ||'  -  '||
                       htf.formText('P_END_DATE_V',11,NULL, to_char(sysdate,'DD-MON-YYYY'));
end if;

END Build_Rep_Dates;

--=========================================================================================

PROCEDURE Build_lookup_param(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i             IN NUMBER
 ,P_LABEL       IN VARCHAR2
 ,P_FORM_NAME   IN VARCHAR2
 ,P_LOOKUP_TYPE IN VARCHAR2
 ,P_ALL_OPTION  IN VARCHAR2
) IS

-- Lookup Parameters
-- The following parameters are passed to this function :
-- P_LABEL - contains the label to be displayed next to the list
-- P_FORM_NAME - contains the name of the variable the form field returns
-- P_LOOKUP_TYPE - contains the look up type to be looked up on fnd_common_lookups
-- P_ALL_OPTION - if the field is to have an 'all values' option,
--                it is passed in here, otherwise this must be empty - i.e. ''

  cursor c_lookup(p_lookup_type in varchar2) is
  select lookup_code,meaning
  from  hr_lookups   /* bug fix 3323544*/
  where lookup_type = p_lookup_type
  and enabled_flag = 'Y' /* bug fix 1608726 */
  order by 2;

  BEGIN

  params(i).Label := Display_Label(P_LABEL);
  params(i).Value := htf.formSelectOpen(P_FORM_NAME);

  IF P_ALL_OPTION IS NOT NULL THEN
     params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="' || P_ALL_OPTION || '"');
  END IF;

  for ci_lookup in c_lookup(P_LOOKUP_TYPE) loop
      params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_lookup.meaning, NULL,
                       'VALUE="'||ci_lookup.lookup_code||'"');
  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_lookup_param;

--=========================================================================================

PROCEDURE Build_Proficiency_Measure(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
) IS

-- Proficiency Measure to Compare Against.
-- This gives the option to base the report on a Minimum
-- Proficiency level required, or on the range of proficiencies found.
-- Parameter Request String : PFMEAS

  BEGIN

  params(i).Label := Display_Label('HR_BIS_PROFICIENCY_LEVEL');
  params(i).Value := htf.formSelectOpen('PFMEAS');
  params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI','HR_BIS_MINIMUM_PROFICIENCY'),
                     NULL,
                     'VALUE="M"');
  params(i).Value := params(i).Value ||
                     htf.formSelectOption(fnd_message.get_string('HRI','HR_BIS_PROFICIENCY_RANGE'),
                     NULL,
                     'VALUE="R"');

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Proficiency_Measure;

--=========================================================================================

PROCEDURE Build_View_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,p_option IN NUMBER
) IS

-- View By
-- Gives a list of categories which the data in the report can be broken down into.
-- Parameter Request String : VIEWBY1, VIEWBY2, VIEWBY3
-- p_option - determines which set of view by options appears

  cursor c_viewby1 is
  select message_name , message_text
  from fnd_new_messages
  where language_code = userenv('LANG')
  and application_id  = 453
  and message_name in ('HR_BIS_GRADE', 'HR_BIS_PERFORMANCE_RATING', 'HR_BIS_SERVICE_BAND',
                       'HR_BIS_JOB', 'HR_BIS_LOCATION', 'HR_BIS_GENDER')
  UNION
  select message_name , message_text
  from fnd_new_messages , per_business_groups
  where business_group_id = hr_bis.get_sec_profile_bg_id    -- bug 2968520
  and legislation_code = 'US'
  and language_code = userenv('LANG')
  and application_id  = 453
  and message_name = 'HR_BIS_EEO_CATEGORY'
  UNION
  select message_name , message_text
  from fnd_new_messages fnm , per_business_groups bus
  where bus.business_group_id = hr_bis.get_sec_profile_bg_id    -- bug 2968520
  and language_code = userenv('LANG')
  and application_id  = 453
  and legislation_code <> 'US'
  and message_name = 'HR_BIS_ETHNIC_ORIGIN' order by 2;

  cursor c_viewby2 is
  select message_name , message_text
  from fnd_new_messages
  where language_code = userenv('LANG')
  and application_id  = 453
  and message_name in ('HR_BIS_AGE_YEARS', 'HR_BIS_LOS_YEARS', 'HR_BIS_GRADE', 'HR_BIS_PERFORMANCE_RATING')
  order by message_name;

  cursor c_viewby3 is
  select message_name,
         message_text
  from   fnd_new_messages
  where  message_name IN ('HR_BIS_TIME', 'HR_BIS_GEOGRAPHY', 'HR_BIS_PRODUCT')
  and    application_id = 453
  and    language_code = userenv('LANG')
  order by 1 desc;

  BEGIN

  params(i).Label := Display_Label('HR_BIS_VIEW_BY');
  params(i).Value := htf.formSelectOpen('VIEWBY');

  IF p_option = 1 THEN
     for ci_viewby in c_viewby1 loop
         params(i).Value := params(i).Value ||
            htf.formSelectOption(ci_viewby.message_text, NULL, 'VALUE="'||ci_viewby.message_name||'"');
     end loop;
  ELSIF p_option = 2 THEN
     for ci_viewby in c_viewby2 loop
         params(i).Value := params(i).Value ||
            htf.formSelectOption(ci_viewby.message_text, NULL, 'VALUE="'||ci_viewby.message_name||'"');
     end loop;
  ELSIF p_option = 3 THEN
     for ci_viewby in c_viewby3 loop
         params(i).Value := params(i).Value ||
             htf.formSelectOption(ci_viewby.message_text, NULL, 'VALUE="'||ci_viewby.message_name||'"');
     end loop;
  END IF;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_View_By;

--=========================================================================================

PROCEDURE Build_LOV(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN Number
 ,p_option IN Number
 ,param_name IN varchar2
 ,LOV_name   IN varchar2
) IS

  l_where_clause   varchar2(10000);
  l_return_status  varchar2(1000);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  params(i).Label := Display_Label('HR_BIS_'||LOV_Name);

  params(i).Value :=
        htf.formHidden(param_name)||                       -- AK Attribute 1
        htf.formText('P_'||LOV_name||'_NAME',30,200,'');   -- AK Attribute 2

  params(i).Action := '<A HREF="javascript:LOV
                         (453
                         ,''P_'||LOV_name||'_NAME''
                         ,453
                         ,''HRI_'||LOV_name||'''
                         ,''params''
                         ,''''
                         ,'''||l_where_clause||'''
                         ,'''')" onMouseOver="window.status=''List of Values'';return true"><IMG SRC="/OA_MEDIA/FNDILOV.gif" ALT="List of Values" ALIGN=absmiddle BORDER=0></A>';

END Build_LOV;

Procedure Build_Organization(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN Number
 ,p_option IN Number
) IS

cursor c_organization_list is
select organization_id, organization_name
from hri_org_lov_v
order by organization_name;


BEGIN

  params(i).Label := Display_Label('HR_BIS_ORGANIZATION');
  params(i).Value := htf.formSelectOpen('P_ORGANIZATION_ID');

  IF p_option = 1 THEN
     params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="-1"');
  END IF;

  for ci_org_list in c_organization_list loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_org_list.organization_name, NULL,
                       'VALUE="'||ci_org_list.organization_id||'"');

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Organization;



PROCEDURE Build_Job(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN Number
 ,p_option IN Number
 ,p_return_status IN OUT NOCOPY  NUMBER
) IS

cursor c_job_list is
select job_id, name job_name
from   per_jobs            -- bug fix 3680782
where  business_group_id = Hr_General.Get_Business_Group_Id
order by name;	-- use of p_option = 1

l_job_id_count	number :=0;

BEGIN

  params(i).Label := Display_Label('HR_BIS_JOB');
  params(i).Value := htf.formSelectOpen('P_JOB_ID');

  IF p_option = 1 THEN
     params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="-1"');
  END IF;

  for ci_job_list in c_job_list loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_list.job_name, NULL,
                       'VALUE="'||ci_job_list.job_id||'"');

    l_job_id_count := l_job_id_count+1;

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

  IF l_job_id_count = 0 THEN
	p_return_status := 0;  -- error, no jobs set up
  ELSE
	p_return_status := 1;
  END IF;

END Build_Job;

PROCEDURE Build_Location(
	params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
,	i IN NUMBER
,	p_option	IN NUMBER
) IS

cursor c_loc_list is
select location_id, location_name
from hri_loc_lov_v;

BEGIN

  params(i).Label := Display_Label('HR_BIS_LOCATION');
  params(i).Value := htf.formSelectOpen('P_LOCATION_ID');

  IF p_option = 1 THEN
     params(i).Value := params(i).Value || htf.formSelectOption('    ', NULL, 'VALUE="-1"');
  END IF;

  for ci_loc_list in c_loc_list loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_loc_list.location_name, NULL,
                       'VALUE="'||ci_loc_list.location_id||'"');

  end loop;

  params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Location;

-- LINK_ procedures modified to make them call the LINK_PARAMPAGE
-- procedure, so that they will use the parameters in the database.
-- mjandrew - 31-Jul-2000 - Bug #1349114

PROCEDURE LINK_HRCOMGAP IS
BEGIN
  LINK_PARAMPAGE('HRCOMGAP');
END LINK_HRCOMGAP;

PROCEDURE LINK_HRCOMPEO IS
BEGIN
  LINK_PARAMPAGE('HRCOMPEO');
END LINK_HRCOMPEO;

PROCEDURE LINK_HRCOMREC IS
BEGIN
  LINK_PARAMPAGE('HRCOMREC');
END LINK_HRCOMREC;

PROCEDURE LINK_HRMNPBGT IS
BEGIN
  LINK_PARAMPAGE('HRMNPBGT');
END LINK_HRMNPBGT;

PROCEDURE LINK_HRMNPCMP IS
BEGIN
  LINK_PARAMPAGE('HRMNPCMP');
END LINK_HRMNPCMP;

PROCEDURE LINK_HRMNPRAT IS
BEGIN
  LINK_PARAMPAGE('HRMNPRAT');
END LINK_HRMNPRAT;

PROCEDURE LINK_HRMNPSUM IS
BEGIN
  LINK_PARAMPAGE('HRMNPSUM');
END LINK_HRMNPSUM;

PROCEDURE LINK_HRORGBGT IS
BEGIN
  LINK_PARAMPAGE('HRORGBGT');
END LINK_HRORGBGT;

PROCEDURE LINK_HRORGCHG IS
BEGIN
  LINK_PARAMPAGE('HRORGCHG');
END LINK_HRORGCHG;

PROCEDURE LINK_HRORGSEP IS
BEGIN
  LINK_PARAMPAGE('HRORGSEP');
END LINK_HRORGSEP;

PROCEDURE LINK_HRSALCOM IS
BEGIN
  LINK_PARAMPAGE('HRSALCOM');
END LINK_HRSALCOM;

PROCEDURE LINK_HRSALGRG IS
BEGIN
  LINK_PARAMPAGE('HRSALGRG');
END LINK_HRSALGRG;

PROCEDURE LINK_HRSALGRP IS
BEGIN
  LINK_PARAMPAGE('HRSALGRP');
END LINK_HRSALGRP;

PROCEDURE LINK_HRSALSPD IS
BEGIN
  LINK_PARAMPAGE('HRSALSPD');
END LINK_HRSALSPD;

PROCEDURE LINK_HRSALTND IS
BEGIN
  LINK_PARAMPAGE('HRSALTND');
END LINK_HRSALTND;

PROCEDURE LINK_HRTRNSUC IS
BEGIN
  LINK_PARAMPAGE('HRTRNSUC');
END LINK_HRTRNSUC;

PROCEDURE LINK_HRUTLABH IS
BEGIN
  LINK_PARAMPAGE('HRUTLABH');
END LINK_HRUTLABH;

PROCEDURE LINK_HRUTLHRS IS
BEGIN
  LINK_PARAMPAGE('HRUTLHRS');
END LINK_HRUTLHRS;

--cbridge, 28/06/2001, pqh budgets report link
PROCEDURE LINK_HRORGPSB IS
BEGIN
  LINK_PARAMPAGE('HRORGPSB');
END LINK_HRORGPSB;

--cbridge, 28/06/2001, pqh budgets report link
PROCEDURE LINK_HRMNPPSB IS
BEGIN
  LINK_PARAMPAGE('HRMNPPSB');
END LINK_HRMNPPSB;



-- Added to make the parameter page calls (above) look at the database
-- to find their list of values, rather than having them hard coded.
-- This reduces the chances of one place being updated, while the other
-- isn't.  - Bug #1349114 - M.J.Andrews - 31-July-2000

  PROCEDURE LINK_PARAMPAGE
    ( p_report_name  IN VarChar2 ) IS

    -- Cursor to get the parameter list from the database for the report
    cursor c_report_parameters( cp_report VarChar2 )
    is
      select substrb( web_html_call, 48, length(web_html_call)-49)
      from   fnd_form_functions
      where  function_name = 'BIS_' || cp_report;

    l_function_params fnd_form_functions.web_html_call%TYPE;

  BEGIN

    -- IMPORTANT : The call in the database MUST follow the following format
    -- to allow it to be read properly by this procedure:
    -- HRI_Parameters.Parameter_FormView('HRXXXXXX', '<params>')
    -- - HRXXXXXX is the 8 letter report filename,
    -- - <params> is the list of parameters seperated by comma's (with a comma at the end)

    open  c_report_parameters( p_report_name );
    fetch c_report_parameters into l_function_params;
    if ( c_report_parameters%notfound ) then
      raise no_data_found;
    end if;
    close c_report_parameters;
    IF ( l_function_params is not null ) THEN
      Parameter_FormView( p_report_name, l_function_params );
    END IF;

  END LINK_PARAMPAGE;

END HRI_Parameters;

/
