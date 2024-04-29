--------------------------------------------------------
--  DDL for Package Body BIS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REPORT_PUB" as
/* $Header: BISPREPB.pls 120.2 2005/11/03 16:49:31 hengliu noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.3=120.2):~PROD:~PATH:~FILE
-- Purpose: Briefly explain the functionality of the package body
-- Can use this package for general report related routines.
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- mdamle     10/11/04  Initial Creation
-- arhegde    09/08/05 Increased lengths of variables in getRegionCode
--            since incorrect defn. from product teams made these fail
-- hengliu    11/03/05  Bug#4717611 Handle new pmv report definition
---------------------------------------------------------------------

function getRegionCode(pFunctionName IN VARCHAR2) return varchar2 IS

l_parameters		VARCHAR2(2000);
l_region		VARCHAR2(2000);
l_type			VARCHAR2(2000);
l_web_html_call		VARCHAR2(2000);
l_ref_function_name	VARCHAR2(2000);

cursor c_form_func(cpFunctionName varchar2) is
select web_html_call,parameters,type
  from fnd_form_functions
 where function_name = cpFunctionName;

BEGIN

	-- mdamle 12/27/2001 - Region Code is specified in web_html_call when type = WWW
	--		     - Region Code may be specified in parameters when type = DBPORTLET / WEBPORTLET
        if c_form_func%ISOPEN then
           close c_form_func;
        end if;
        open c_form_func(pFunctionName);
             fetch c_form_func into l_web_html_call, l_parameters, l_type;
        close c_form_func;

	if l_type = 'WWW' then
		l_region := substr( substr( l_web_html_call, instr(l_web_html_call, '''')+1 ), 1, instr(substr( l_web_html_call, instr(l_web_html_call, '''')+1 ),'''')-1 );
		if l_region is null then
			-- Try parameters
			l_region := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'pRegionCode');
		end if;
        elsif l_type = 'WEBPORTLET' then
                l_region := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'pRegionCode');
	else
		-- Type = DBPORTLET
		l_region := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'pRegionCode');

		-- Check if portlet is pointing to another function
		-- Get region code from that function
		l_ref_function_name := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'pFunctionName');
		if l_ref_function_name is null then
			l_ref_function_name := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'FUNCTION_NAME');
		end if;

             if l_ref_function_name is not null and l_ref_function_name <> '' then
                if c_form_func%ISOPEN then
                   close c_form_func;
                end if;
                open c_form_func(l_ref_function_name);
                     fetch c_form_func into l_web_html_call, l_parameters, l_type;
                close c_form_func;

		if l_type = 'WWW' then
			l_region := substr( substr( l_web_html_call, instr(l_web_html_call, '''')+1 ), 1, instr(substr( l_web_html_call, instr(l_web_html_call, '''')+1 ),'''')-1 );
			if l_region is null then
				-- Try parameters
				l_region := BIS_COMMON_UTILS.getParameterValue(l_parameters, 'pRegionCode');
			end if;
		end if;
             end if; -- l_ref_function_name is not null
	end if;

	return l_region;

END getRegionCode;

FUNCTION getRegionApplicationId(pRegionCode IN VARCHAR2) RETURN NUMBER IS

CURSOR region_app_id_cursor(cp_region_code VARCHAR2) IS
SELECT region_application_id FROM ak_regions
WHERE region_code = cp_region_code;

l_region_app_id NUMBER;

BEGIN

  IF region_app_id_cursor%ISOPEN THEN
    CLOSE region_app_id_cursor;
  END IF;

  OPEN region_app_id_cursor(pRegionCode);
  FETCH region_app_id_cursor INTO l_region_app_id;
  IF region_app_id_cursor%NOTFOUND THEN
     l_region_app_id := -1;
  END IF;
  CLOSE region_app_id_cursor;

  RETURN l_region_app_id;
EXCEPTION
  WHEN others THEN
    IF region_app_id_cursor%ISOPEN THEN
      CLOSE region_app_id_cursor;
    END IF;

END getRegionApplicationId;

FUNCTION getPortletType(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN VARCHAR2 IS
    l_request_type CHAR;
BEGIN
  IF (upper(pType) = 'JSP' OR upper(pType) = 'WWW') THEN
    RETURN fnd_message.get_string('BIS', 'BIS_REPORT_TITLE');
  ELSE
    IF (upper(pType) = 'WEBPORTLET') THEN
      l_request_type := BIS_COMMON_UTILS.getParameterValue(pParameters, 'pRequestType');
      IF (l_request_type = 'T') THEN
        RETURN fnd_message.get_string('BIS', 'BIS_TREND_TABLE');
      ELSIF (l_request_type = 'G') THEN
        RETURN fnd_message.get_string('BIS', 'BIS_TREND_GRAPH');
      ELSIF (l_request_type = 'P') THEN
        RETURN fnd_message.get_string('BIS', 'BIS_PARAMETERS');
      END IF;
    END IF;
  END IF;

  RETURN null;

END getPortletType;

FUNCTION getPortletTypeCode(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN CHAR IS
    l_request_type CHAR;
BEGIN
  IF (upper(pType) = 'JSP' OR upper(pType) = 'WWW') THEN
    RETURN 'R';
  ELSE
    IF (upper(pType) = 'WEBPORTLET') THEN
        RETURN BIS_COMMON_UTILS.getParameterValue(pParameters, 'pRequestType');
    ELSE
        RETURN NULL;
    END IF;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  RETURN null;

END getPortletTypeCode;

FUNCTION getRegionCode(pType IN VARCHAR2, pParameters IN VARCHAR2, webHtmlCall IN VARCHAR2, functionName IN VARCHAR2) RETURN CHAR IS
    l_request_type CHAR;
BEGIN
  IF (pType = 'JSP') THEN
    RETURN nvl(BIS_COMMON_UTILS.getParameterValue(webHtmlCall, 'regionCode'), BIS_COMMON_UTILS.getparametervalue(pParameters,'pRegionCode'));
  ELSIF (pType = 'WWW') THEN
    RETURN nvl(trim(BIS_COMMON_UTILS.getParameterValue(pParameters, 'pRegionCode')), getRegionCode(functionName));
  ELSIF (pType = 'WEBPORTLET') THEN
    RETURN BIS_COMMON_UTILS.getParameterValue(pParameters, 'pRegionCode');
  END IF;

  RETURN NULL;

END getRegionCode;

FUNCTION getRegionApplicationName(pRegionCode IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR region_app_name_cursor(cp_region_code VARCHAR2) IS
SELECT application_name FROM ak_regions R, fnd_application_vl A
WHERE R.region_code = cp_region_code AND R.region_application_id = A.application_id;

l_code VARCHAR2(3);

  CURSOR app_name_from_table is
  SELECT application_name
  FROM fnd_application_vl app
  WHERE app.application_short_name = l_code;

l_region_app_name VARCHAR2(2000);

BEGIN

  IF region_app_name_cursor%ISOPEN THEN
    CLOSE region_app_name_cursor;
  END IF;

  OPEN region_app_name_cursor(pRegionCode);
  FETCH region_app_name_cursor INTO l_region_app_name;
  IF region_app_name_cursor%NOTFOUND THEN
    IF app_name_from_table%ISOPEN THEN
        CLOSE app_name_from_table;
    END IF;

    l_code := 'FND';
    OPEN app_name_from_table;
    FETCH app_name_from_table INTO l_region_app_name;
    CLOSE app_name_from_table;
  END IF;
  CLOSE region_app_name_cursor;

  RETURN l_region_app_name;
EXCEPTION
  WHEN others THEN
    IF region_app_name_cursor%ISOPEN THEN
      CLOSE region_app_name_cursor;
    END IF;

END getRegionApplicationName;


FUNCTION getRegionDataSourceType(pRegionCode IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR source_type_cursor(cp_region_code VARCHAR2) IS
SELECT attribute10 FROM ak_regions
WHERE region_code = cp_region_code;

l_source_type	VARCHAR2(150);

BEGIN

  IF source_type_cursor%ISOPEN THEN
    CLOSE source_type_cursor;
  END IF;

  OPEN source_type_cursor(pRegionCode);
  FETCH source_type_cursor INTO l_source_type;
  IF source_type_cursor%NOTFOUND THEN
     l_source_type := NULL;
  END IF;
  CLOSE source_type_cursor;

  RETURN l_source_type;
EXCEPTION
  WHEN others THEN
    IF source_type_cursor%ISOPEN THEN
      CLOSE source_type_cursor;
    END IF;

END getRegionDataSourceType;


FUNCTION isRegionItemRequired(
 p_required_flag in VARCHAR2
,p_dim_group_name in VARCHAR2 := NULL
,p_attribute1 in VARCHAR2) RETURN NUMBER IS

l_dim_level_name VARCHAR2(30);
l_dim_group_name VARCHAR2(30);
l_dim_level_id NUMBER;
l_dim_group_id NUMBER;
l_total_flag NUMBER;

BEGIN

  if (p_required_flag = 'Y') then
    return 1;
  end if;

  l_dim_group_name := p_dim_group_name;
  if p_dim_group_name is null then
	l_dim_group_name := SUBSTR(p_attribute1, 1,INSTR(p_attribute1, '+' ) - 1);
  end if;

  l_dim_level_name := SUBSTR(p_attribute1, INSTR(p_attribute1, '+' ) + 1);

  select dim_group_id into l_dim_group_id
  from bsc_sys_dim_groups_vl
  where short_name = l_dim_group_name;

  select dim_level_id into l_dim_level_id
  from bsc_sys_dim_levels_b
  where short_name = l_dim_level_name;

  select total_flag into l_total_flag
  from bsc_sys_dim_levels_by_group
  where dim_group_id = l_dim_group_id
  and dim_level_id = l_dim_level_id;


  if l_total_flag = -1 then
	return 0;
  else
	return 1;
  end if;

EXCEPTION
  WHEN others THEN
  	return 0;

END isRegionItemRequired;

FUNCTION isWeightedAverageReport(
 p_region_code in VARCHAR2
,p_region_application_id in NUMBER) RETURN CHAR IS

l_count number;
BEGIN

  select count(*) into l_count
  from ak_region_items ri, bis_indicators i, bsc_sys_datasets_b d
  where ri.region_code = p_region_code
  and ri.region_application_id = p_region_application_id
  and attribute1 = 'MEASURE_NOTARGET'
  and attribute2 = i.short_name
  and i.dataset_id = d.dataset_id
  and d.source = 'CDS';

  if (l_count > 0) then
    return 'Y';
  else
    return 'N';
  end if;

EXCEPTION
  WHEN others THEN
  	return 'N';

END isWeightedAverageReport;

END BIS_REPORT_PUB;

/
