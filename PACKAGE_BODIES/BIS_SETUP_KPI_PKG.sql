--------------------------------------------------------
--  DDL for Package Body BIS_SETUP_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_SETUP_KPI_PKG" AS
/* $Header: BISKPISB.pls 120.1 2006/01/17 03:30:46 aguwalan noship $ */
version     CONSTANT VARCHAR2(80) := '$Header: BISKPISB.pls 120.1 2006/01/17 03:30:46 aguwalan noship $';

FUNCTION getValue(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter  IN VARCHAR2 := c_amp
) RETURN VARCHAR2
IS
  l_key VARCHAR2(2000);
  l_parameters VARCHAR2(2000);
  l_key_start NUMBER;
  l_value_start NUMBER;
  l_amp_start NUMBER;

  l_val VARCHAR2(2000);
BEGIN
  IF ( (p_key IS NULL) or (p_parameters IS NULL)) THEN
    RETURN NULL;
  END IF;

  l_key := UPPER(p_key);
  l_parameters := UPPER(p_parameters);
--  dbms_output.put_line('p_parameters='|| p_parameters);
  -- first occurance
  l_key_start := INSTRB(l_parameters, RTRIM(l_key)|| c_eq, 1);
--    dbms_output.put_line('l key start='||l_key_start);
  IF (l_key_start = 0) THEN -- key not found
    RETURN NULL;
  END IF;

  -- get the starting position of v2 in "p2=v2"
  l_value_start := l_key_start + LENGTHB(p_key)+1;  -- including c_eq
  l_amp_start :=  INSTRB(p_parameters, p_delimiter, l_value_start);

  IF (l_amp_start = 0) THEN -- the last one or key not found
    l_val := SUBSTRB(p_parameters, l_value_start);
  ELSE
    l_val := SUBSTRB(p_parameters, l_value_start, (l_amp_start - l_value_start));
  END IF;
  RETURN l_val;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END getValue;

-- note that we only take seeded OA pages in RSG into account
-- the following function is changed to procedure due to 9i dependency
-- problem. Now instead of returning a PL/SQL table, we will be using
-- temporary global table, which is in a DB session scope
-- FUNCTION getKpisAndPages RETURN t_bis_kpi_page_tab IS
/* This API is not used with current Administer KPI UI; and the query used is coming up
   in the APPSPERF: R12 bug#4912250. Hence commenting this API
PROCEDURE getKpisAndPages IS
   CURSOR c_pages IS
      SELECT distinct kpi_funcs.function_id, kpi_funcs.parameters,
	pages.page_name, pages.page_internal_name
	FROM
	(SELECT page_funcs.user_function_name page_name,
	 prop.object_name page_internal_name, menus.menu_id page_menu_id
	 FROM bis_obj_properties prop, fnd_form_functions_vl page_funcs, fnd_menus menus
	 WHERE prop.object_type = 'PAGE'
	 --AND prop.object_name like '%_OA'
	 AND page_funcs.type = 'JSP'
	 AND UPPER(page_funcs.web_html_call) like 'OA.JSP?AKREGIONCODE=BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
	 AND UPPER(page_funcs.parameters) LIKE '%PAGENAME%'
	 --AND page_funcs.FUNCTION_NAME = SUBSTR(prop.object_name, 1, LENGTH(prop.object_name)-3)
	 AND page_funcs.function_name = bis_impl_dev_pkg.get_function_by_page(prop.object_name)
	 AND menus.menu_name = getValue('pageName', page_funcs.parameters)
	 ) pages,
	fnd_form_functions kpi_portlet_funcs,
	fnd_menus kpi_portlet_menus,
	fnd_form_functions kpi_funcs
	WHERE kpi_portlet_funcs.type in ('WEBPORTLET','WEBPORTLETX')
	AND (UPPER(kpi_portlet_funcs.parameters) LIKE '%PMEASUREDEFINITION%'
	     OR UPPER(kpi_portlet_funcs.parameters) LIKE '%PXMLDEFINITION%')
	AND UPPER(kpi_portlet_funcs.web_html_call) LIKE 'OA.JSP?AKREGIONCODE=BIS_PMF_PORTLET_TABLE_LAYOUT'||'&'||'AKREGIONAPPLICATIONID=191%'
	AND kpi_portlet_funcs.function_id IN (SELECT entries.function_id
					      FROM fnd_menu_entries entries
					      START WITH entries.menu_id = pages.page_menu_id
					      CONNECT BY PRIOR entries.sub_menu_id = entries.menu_id)
	AND kpi_portlet_menus.menu_name = Nvl(getValue('pMeasureDefinition', kpi_portlet_funcs.parameters), getValue('pXMLDefinition', kpi_portlet_funcs.parameters))
	AND kpi_funcs.type <> 'DBPORTLET'
	AND kpi_funcs.type <> 'WEBPORTLET'
	and kpi_funcs.type<>'WEBPORTLETX'
	AND UPPER(kpi_funcs.parameters) LIKE '%PTARGETLEVELSHORTNAME%'
	AND kpi_funcs.function_id IN (SELECT entries1.function_id
				      FROM fnd_menu_entries entries1
				      START WITH entries1.menu_id = kpi_portlet_menus.menu_id
				      CONNECT BY PRIOR entries1.sub_menu_id = entries1.menu_id);

   CURSOR c_kpis(p_func_param VARCHAR2) IS
        SELECT tl.indicator_id, indicators.name indicator_name
	  FROM bis_target_levels tl, bis_indicators_vl indicators
	  WHERE tl.short_name = getValue('pTargetLevelShortName', p_func_param)
	  AND nvl(Upper(getValue('pHide', p_func_param)), 'NO') <> 'YES'
	  AND tl.indicator_id = indicators.indicator_id;

   v_page c_pages%ROWTYPE;
   v_kpi c_kpis%ROWTYPE;
   v_page_kpi t_bis_kpi_page_obj;

BEGIN
   --dbms_output.put_line('g_populated: '||g_populated);
   IF (g_populated = 'Y') THEN
      --RETURN g_kpis_pages;
      RETURN;
    ELSE
      execute immediate 'delete from BIS_SETUP_KPI_PAGE';
      --IF (g_kpis_pages IS NOT NULL AND g_kpis_pages.COUNT > 0) THEN
	-- g_kpis_pages.DELETE;
      --END IF;
   END IF;

   --dbms_output.put_line('execute complicated queries');

   OPEN c_pages;

   --dbms_output.put_line('after executing complicated queries');

   LOOP
      FETCH c_pages INTO v_page;
      EXIT WHEN c_pages%NOTFOUND;

      OPEN c_kpis(v_page.parameters);
      FETCH c_kpis INTO v_kpi;
      CLOSE c_kpis;

      IF (v_kpi.indicator_id IS NOT NULL) THEN
	 --v_page_kpi := t_bis_kpi_page_obj(v_page.page_name, v_page.page_internal_name, v_kpi.indicator_id, v_kpi.indicator_name);
	 --g_kpis_pages.extend;
	 --g_kpis_pages(g_kpis_pages.COUNT) := v_page_kpi;
	 execute immediate 'insert into BIS_SETUP_KPI_PAGE values (:1, :2, :3, :4)'
	   using v_page.page_name, v_page.page_internal_name,
	   v_kpi.indicator_id, v_kpi.indicator_name;

	 --execute immediate 'insert into ywu_debug_bis_setup_kpi_page (:1, :2, :3, :4)'
	 --  using v_page.page_name, v_page.page_internal_name,
	 --  v_kpi.indicator_id, v_kpi.indicator_name;
	 --COMMIT;
      END IF;
   END LOOP;

   CLOSE c_pages;

   g_populated := 'Y';

   --RETURN g_kpis_pages;
EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('exception thrown in getKpisAndPages:' || sqlerrm);
      -- RETURN NULL;
      RETURN;
END getKpisAndPages;
*/


--new implementation
FUNCTION getPagesAndImplFlag(
  p_kpi_id    IN NUMBER
) RETURN VARCHAR2
IS
  CURSOR c_pages_and_impl_flag(p_c_kpi_id NUMBER) IS
	SELECT distinct b.IMPLEMENTATION_FLAG, a.page_name
	--FROM TABLE(cast(getKpisAndPages AS t_bis_kpi_page_tab)) a,
	  FROM bis_setup_kpi_page a,
	  bis_obj_properties b
	WHERE a.indicator_id = p_c_kpi_id
	  AND a.page_internal_name = b.object_name
	  AND b.object_type = 'PAGE';

  v_pages VARCHAR2(4000);
  v_impl_flag CHAR(1) := 'N';
  v_pages_and_impl_flag_rec c_pages_and_impl_flag%ROWTYPE;
BEGIN
   IF (p_kpi_id IS NULL) THEN
      RETURN NULL;
   END IF;

   --initialize BIS_SETUP_KPI_PAGE
   --dbms_output.put_line('before calling getkpisandpages ');
   --getkpisandpages;

   --dbms_output.put_line('after calling getkpisandpages ');

   OPEN c_pages_and_impl_flag(p_kpi_id);

   LOOP
      FETCH c_pages_and_impl_flag INTO v_pages_and_impl_flag_rec;
      EXIT WHEN c_pages_and_impl_flag%NOTFOUND;
      IF (v_pages_and_impl_flag_rec.implementation_flag = 'Y') THEN
	 v_impl_flag := 'Y';
      END IF;
      IF (Length(v_pages) > 0) THEN
	v_pages := v_pages || ',' || v_pages_and_impl_flag_rec.page_name;
       ELSE
	 v_pages := v_pages || v_pages_and_impl_flag_rec.page_name;
      END IF;
   END LOOP;
   CLOSE c_pages_and_impl_flag;

   IF (v_impl_flag = 'Y') THEN
      v_impl_flag := 'N';
    ELSE
      v_impl_flag := 'Y';
   END IF;

   IF (Length(v_pages) > 0) THEN
      RETURN 'pages=' || v_pages || '&' || 'implFlag=' || v_impl_flag;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END getPagesAndImplflag;
-- new implementation




--new implementation
-- get rid of 9i dependency
--FUNCTION getKpis(p_page_name IN VARCHAR2) RETURN t_bis_setup_kpi_tab
PROCEDURE getkpis(p_page_name IN VARCHAR2)
IS
    CURSOR c_kpis(p_c_page_name VARCHAR2) IS
        SELECT DISTINCT indicator_id, indicator_name
	  --FROM TABLE(cast(getKpisAndPages AS t_bis_kpi_page_tab))
	  FROM BIS_SETUP_KPI_PAGE
	  WHERE Upper(page_name) LIKE Upper(p_c_page_name);

   v_kpi          t_bis_setup_kpi_obj := t_bis_setup_kpi_obj(-1, '');
   v_ret_kpis     t_bis_setup_kpi_tab := t_bis_setup_kpi_tab();
   v_index        INTEGER;

BEGIN

   execute immediate 'delete from BIS_SETUP_KPI';

   IF (p_page_name IS NULL) THEN
      --RETURN NULL;
      RETURN;
   END IF;

   --initialize BIS_SETUP_KPI_PAGE
   --getkpisandpages;

   --dbms_output.put_line('before cleaning up BIS_SETUP_KPI');
   -- clear up the global temporary table
   --dbms_output.put_line('after cleaning up BIS_SETUP_KPI');

   OPEN c_kpis(p_page_name);

   LOOP
      FETCH c_kpis INTO v_kpi.kpi_id, v_kpi.kpi_name;
      EXIT WHEN c_kpis%notfound;

      IF v_kpi.kpi_id IS NOT NULL THEN
	 --v_ret_kpis.extend;
	 --v_ret_kpis(v_ret_kpis.count) := v_kpi;
	 execute immediate 'insert into BIS_SETUP_KPI values (:1, :2)'
	   using v_kpi.kpi_id, v_kpi.kpi_name;

	 --execute immediate 'insert into ywu_debug_bis_setup_kpi values (:1, :2)'
	 --  using v_kpi.kpi_id, v_kpi.kpi_name;
	 --COMMIT;
      END IF;
   END LOOP;

   CLOSE c_kpis;

   --RETURN v_ret_kpis;
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      --RETURN NULL;
      --dbms_output.put_line('Exception thrown in getKpis');
      RETURN;
END getkpis;
-- new implementation


PROCEDURE invalidatecache IS
BEGIN
   g_populated := 'N';
   RETURN;
END invalidatecache;

END bis_setup_kpi_pkg;


/
