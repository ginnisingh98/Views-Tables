--------------------------------------------------------
--  DDL for Package Body HR_PARAMETER_HRMNPSUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PARAMETER_HRMNPSUM" AS
/* $Header: hripmsum.pkb 120.2 2008/02/01 11:07:56 vjaganat noship $ */

    bus_id number;
    orgver number;

PROCEDURE Before_Parameter_HRMNPSUM IS

BEGIN
-- This procedure replaces the reports BeforePForm Trigger and
-- creates the banner and sets up business group id and org ver
-- Create Banner for top of Parameter Form
-- This uses Core BIS package called BIS_UTILITIES_PUB
-- Need to pass it Function Code and RDF Filename (without extension)
  BIS_UTILITIES_PUB.Build_Report_Title(
      p_Function_Code => 'BIS_HRMNPSUM',
      p_Rdf_Filename  => 'HRMNPSUM',
      p_Body_Attribs  => NULL);

-- Initialize the report parameters
-- Pass in globals for user id, responsibility id, application id,
-- and security group.  The correct business group and organization
-- version (used to determine Org LOV) are determined and passed back
-- into global variables in this package
    HrFastAnswers.Initialize(
      p_user_id => FND_GLOBAL.user_id,
      p_resp_id => FND_GLOBAL.resp_id,
      p_resp_appl_id => FND_GLOBAL.resp_appl_id,
      p_sec_group_id => FND_GLOBAL.security_group_id,
      p_business_group_id => bus_id,
      p_org_structure_version_id => orgver);

END Before_Parameter_HRMNPSUM;

PROCEDURE After_Parameter_HRMNPSUM IS

BEGIN
-- This procedure replaces the reports AfterPForm Trigger and initializes
-- globals (just in case they are not already set

-- Initialize the report parameters
    HrFastAnswers.Initialize(
      p_user_id => FND_GLOBAL.user_id,
      p_resp_id => FND_GLOBAL.resp_id,
      p_resp_appl_id => FND_GLOBAL.resp_appl_id,
      p_sec_group_id => FND_GLOBAL.security_group_id,
      p_business_group_id => bus_id,
      p_org_structure_version_id => orgver);
END After_Parameter_HRMNPSUM;

FUNCTION Display_Label (p_label_name IN VARCHAR2) RETURN VARCHAR2 is
BEGIN
-- This function gets the tranlation for each of the report parameter
-- labels.  Pass in the message_name (ie HR_BIS_PRODUCT_CATEGORY) and
-- it passes back the correct translation

   fnd_message.set_name('PER',p_label_name);
   return fnd_message.get;
END Display_Label;

PROCEDURE Build_Organization (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  l_where_clause   varchar2(10000);
  l_return_status  varchar2(1000);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
-- This procedure creates the data required to display the Organization
-- Parameter

-- Create Label, Value and Action (LOV Button) to pass to BIS core code
-- in a pl/sql table.  Core BIS code creates the correct layout for the
-- parameter page
  params(i).Label := Display_Label('HR_BIS_ORGANIZATION');
  params(i).Value :=
        htf.formHidden('P_ORGANIZATION_ID')||
        htf.formText('P_ORGANIZATION_NAME',30,200,'');
  params(i).Action := '<A HREF="javascript:LOV
                         (453
                         ,''P_ORGANIZATION_NAME''
                         ,453
                         ,''HRI_ORGANIZATION''
                         ,''params''
                         ,''''
                         ,''''
                         ,'''')" onMouseOver="window.status=''List of Values'';return true"><IMG SRC="/OA_MEDIA/FNDILOV.gif" ALT="List of Values" ALIGN=absmiddle BORDER=0></A>';

END Build_Organization;

PROCEDURE Build_Incl_Subord (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_incl_subord is
    select 'SIRO' lookup_code
    ,      meaning
    from   hr_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = 'Y'
    UNION
    select 'SINR' lookup_code
    ,       meaning
    from   hr_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = 'N'
    order by 1 desc;

BEGIN

-- Creates Include Subordinates Parameter

  params(i).Label := Display_Label('HR_BIS_ROLLUP_ORGANIZATIONS');
  params(i).Value := htf.formSelectOpen( 'ORGPRC' );
  for ci_incl_subord in c_incl_subord loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_incl_subord.meaning,NULL,
                       'VALUE="'||ci_incl_subord.lookup_code||'"');
  end loop;
    params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Incl_Subord;

PROCEDURE Build_Business_Plan (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_bpl is
    select -1 plan_id, '    ' plan_name
      from sys.dual
     union
    select plan_id, description plan_name
      from bisbv_business_plans
     where current_plan_flag='Y'
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

PROCEDURE Build_Geog_Level (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_geog_level is
    select '1' lev_code,
           message_text lev
    from fnd_new_messages
    where message_name = 'HR_BIS_AREA'
    and application_id = 800
    and language_code = userenv('LANG')
    union
    select '2' lev_code,
           message_text lev
    from fnd_new_messages
    where message_name = 'HR_BIS_COUNTRY'
    and application_id = 800
    and language_code = userenv('LANG')
    union
    select '3' lev_code,
           message_text lev
    from fnd_new_messages
    where message_name = 'HR_BIS_REGION'
    and application_id = 800
    and language_code = userenv('LANG');

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

PROCEDURE Build_Geog_Value (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_area is
    select '-1' area_code
    ,      ' ' area
    from dual
    union
    select area_code
    ,      name area
    from bis_areas_v
    order by 2;

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

PROCEDURE Build_Product (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

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

PROCEDURE Build_Job (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  l_where_clause varchar2(10000);

BEGIN

-- Create Job parameter

  params(i).Label := Display_Label('HR_BIS_JOB');
  params(i).Value :=
        htf.formHidden('P_JOB_ID')||		-- AK Attribute 1
        htf.formText('P_JOB_NAME',30,200,''); 	-- AK Attribute 2
  params(i).Action := '<A HREF="javascript:LOV
                         (453
                         ,''P_JOB_NAME''
                         ,453
                         ,''HRI_JOB''
                         ,''params''
                         ,''''
                         ,''''
                         ,'''')" onMouseOver="window.status=''List of Values'';return true"><IMG SRC="/OA_MEDIA/FNDILOV.gif" ALT="List of Values" ALIGN=absmiddle BORDER=0></A>';

END Build_Job;

PROCEDURE Build_Job_Category (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_job_category is
    select '__ALL__' lookup_code
    ,      ' ' meaning
    from dual
    union
    select lookup_code, meaning
    from fnd_common_lookups
    where lookup_type = 'JOB_CATEGORIES'
    order by 2;

BEGIN

-- This procedure creates the Job Category parameter
  params(i).Label := Display_Label('HR_BIS_JOB_CATEGORY');
  params(i).Value := htf.formSelectOpen( 'JOBCAT' );
  for ci_job_category in c_job_category loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_job_category.meaning,NULL,
                       'VALUE="'||ci_job_category.lookup_code||'"');
  end loop;
    params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Job_Category;

PROCEDURE Build_Budget (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_bgttyp is
    select lookup_code
    ,      meaning
    from hr_lookups
    where lookup_type = 'BUDGET_MEASUREMENT_TYPE'
    order by meaning;

BEGIN

-- This procedure creates the Budget Measurement Type parameter
  params(i).Label := Display_Label('HR_BIS_BGTTYP');
  params(i).Value := htf.formSelectOpen( 'BGTTYP' );
  for ci_bgttyp in c_bgttyp loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_bgttyp.meaning, NULL,
                       'VALUE="'||ci_bgttyp.lookup_code||'"');
  end loop;
    params(i).Value := params(i).Value || htf.formSelectClose;

END Build_Budget;

PROCEDURE Build_View_By (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_view_by is
    select message_name,
           message_text view_by
    from fnd_new_messages
    where message_name = 'HR_BIS_TIME'
    and application_id = 800
    and language_code = userenv('LANG')
    union
    select message_name,
           message_text view_by
    from fnd_new_messages
    where message_name = 'HR_BIS_GEOGRAPHY'
    and application_id = 800
    and language_code = userenv('LANG')
    union
    select message_name,
           message_text view_by
    from fnd_new_messages
    where message_name = 'HR_BIS_PRODUCT'
    and application_id = 800
    and language_code = userenv('LANG')
    order by 1 desc;

BEGIN

-- This procedure creates the View By Parameter
  params(i).Label := Display_Label('HR_BIS_VIEW_BY');
  params(i).Value := htf.formSelectOpen( 'VIEWBY' );
  for ci_view_by in c_view_by loop
    params(i).Value := params(i).Value ||
                       htf.formSelectOption(ci_view_by.view_by,NULL,
                       'VALUE="'||ci_view_by.message_name||'"');
  end loop;
    params(i).Value := params(i).Value || htf.formSelectClose;

END Build_View_By;

PROCEDURE Build_Frequency (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

  cursor c_frequency is
    select lookup_code,meaning
    from hr_lookups
    where lookup_type = 'PROC_PERIOD_TYPE'
    and lookup_code in ('CM','BM','Q','SY','Y')
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

PROCEDURE Build_Rep_Dates (
     params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
     i      IN Number) IS

BEGIN

-- This procedure creates the Reporting Dates parameters
    params(i).Label := Display_Label('HR_BIS_REPORTING_DATES');
    params(i).Value := htf.formText('P_START_DATE_V',NULL,NULL,
                             to_char(add_months(sysdate,-12)+1,'DD-MON-YYYY'))
                             ||'  -  '||
                        htf.formText('P_END_DATE_V',NULL,NULL,
                             to_char(sysdate,'DD-MON-YYYY'));

END Build_Rep_Dates;

PROCEDURE Parameter_FormView_HRMNPSUM IS

-- This is the main procedure for this package
-- It creates all the parameters and passes them to a
-- core BIS procedure to create all the formatting of the page

-- Create PL/SQL table
  params BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type;

-- Cursor for Geography Level Parameter
  cursor c_area is
    select '-1' area_code
    ,      ' ' area
    from dual
    union
    select area_code
    ,      name area
    from bis_areas_v
    order by 2;

-- Cursor for Geography Value (Country) Parameter
  cursor c_country is
    select '-1' territory_code
    ,      ' ' country
    from dual
    union
    select territory_code
    , replace(territory_short_name,'''','_') country
    from fnd_territories_vl
    order by 2;

-- Cursor for Geography Value (Region) Parameter
  cursor c_region is
    select '-1' region_code
    ,      ' ' region
    from dual
    union
    select region_code
    ,      name region
    from bis_regions_v
    order by 2;

    java_string varchar2(32767);

BEGIN

-- Run Before Parameter Form Logic
  HR_PARAMETER_HRMNPSUM.Before_Parameter_HRMNPSUM;

  htp.htmlOpen;
  htp.headOpen;

  js.scriptopen;
   icx_util.lovscript;
  js.scriptclose;
-- Java Script to create functionality for cross validation of Geography
-- Parameters
    java_string := java_string|| 'function getGeog(field, index)' ;
    java_string := java_string|| '{' ;
    java_string := java_string|| ' while( field.length > 0 )' ;
    java_string := java_string|| '  field.options[field.length -1 ] = null;' ;
    java_string := java_string|| ' if (index == 0 )' ;
    java_string := java_string||   '{' ;
  for ci_area in c_area loop
    java_string := java_string||    '  field.options[field.length] = ';
    java_string := java_string||    ' new Option(''' ||ci_area.area;
    java_string := java_string||             ''',''' ||ci_area.area_code||''');';
  end loop;
    java_string := java_string||     '}' ;
    java_string := java_string||   '  else if (index == 1 )' ;
    java_string := java_string||     '{' ;
  for ci_country in c_country loop
    java_string := java_string||      '  field.options[field.length] = ';
    java_string := java_string||      ' new Option('''||ci_country.country;
    java_string := java_string||             ''',''' ||ci_country.territory_code||''');' ;
  end loop;
    java_string := java_string||   '}' ;
    java_string := java_string|| '  else if (index == 2 )' ;
    java_string := java_string||   '{' ;
  for ci_region in c_region loop
    java_string := java_string||     '  field.options[field.length] = ';
    java_string := java_string||     ' new Option('''||ci_region.region;
    java_string := java_string||             ''','''||ci_region.region_code||''');' ;
  end loop;
    java_string := java_string||   '}' ;
    java_string := java_string|| '}' ;
    java_string := java_string|| ' ' ;

-- Build up Java Script
  BIS_UTILITIES_PUB.Build_Report_Header(java_string);

  htp.headClose;
  htp.bodyOpen;

  htp.formOpen ('HR_PARAMETER_HRMNPSUM.Param25_ActionView_HRMNPSUM', 'GET',
                 NULL,NULL, 'name="params"');
-- Create each Parameter displayed on the page
   Build_Organization(params,1);
   Build_Incl_Subord(params,2);
   Build_Business_Plan(params,3);
   Build_Geog_Level(params,4);
   Build_Geog_Value(params,4); -- In same record as Geog Level
   Build_Product(params,5);
   Build_Job_Category(params,6);
   Build_Job(params,7);
   Build_Budget(params,8);
   Build_View_By(params,9);
   Build_Frequency(params,10);
   Build_Rep_Dates(params,11);

-- Create hidden fields for Business Group ID and Organization Version
  htp.formHidden('BUS_ID',bus_id);
  htp.formHidden('ORGVER',orgver);

-- Build Parameter Form
  BIS_UTILITIES_PUB.Build_Parameter_Form(
   'NAME="HRMNPSUM" ACTION="HR_PARAMETER_HRMNPSUM.Param25_ActionView_HRMNPSUM" M
ETHOD="GET"', params);

  htp.formClose;
  htp.bodyClose;

  htp.htmlClose;

END Parameter_FormView_HRMNPSUM;

PROCEDURE Param25_ActionView_HRMNPSUM(
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
          BGTTYP              varchar2,
          VIEWBY              varchar2 default 'HR_BIS_TIME',
          FRQNCY              varchar2 default 'CM',
          P_START_DATE_V      varchar2,
          P_END_DATE_V        varchar2) IS

BEGIN
-- Run After Parameter Form Logic
  HR_PARAMETER_HRMNPSUM.After_Parameter_HRMNPSUM;

-- Now Run the report passing all the parameters
 /* OracleOASIS.RunReport(
    report => 'HRMNPSUM',
    parameters => 'ORG_ID='        ||nvl(p_organization_id,-1)|| '*' ||
                  'ORGPRC='        ||ORGPRC        || '*' ||
                  'ORGVER='        ||ORGVER        || '*' ||
                  'BUS_ID='        ||BUS_ID        || '*' ||
                  'BPL_ID='        ||BPL_ID        || '*' ||
                  'GEOLVL='        ||GEOLVL        || '*' ||
                  'GEOVAL='        ||GEOVAL        || '*' ||
                  'PRODID='        ||PRODID        || '*' ||
                  'JOB_ID='        ||nvl(p_job_id,'-1')|| '*' ||
                  'JOBCAT='        ||JOBCAT        || '*' ||
                  'BGTTYP='        ||BGTTYP        || '*' ||
                  'VIEWBY='        ||VIEWBY        || '*' ||
                  'FRQNCY='        ||FRQNCY        || '*' ||
                  'P_START_DATE_V='||P_START_DATE_V|| '*' ||
                  'P_END_DATE_V='  ||P_END_DATE_V  || '*',
    paramform => 'NO');
  */
END Param25_ActionView_HRMNPSUM;

END HR_PARAMETER_HRMNPSUM;

/
