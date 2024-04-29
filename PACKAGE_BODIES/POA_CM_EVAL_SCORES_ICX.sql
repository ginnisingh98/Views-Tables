--------------------------------------------------------
--  DDL for Package Body POA_CM_EVAL_SCORES_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_CM_EVAL_SCORES_ICX" AS
/* $Header: POACMSCB.pls 115.15 2003/04/29 21:47:10 rvickrey ship $ */

PROCEDURE Reload_Header(p_header t_header_record, error_msg VARCHAR2)
IS
BEGIN
    poa_cm_evaluation_icx.header_page(	p_header.custom_measure_code,
			   		p_header.custom_measure,
			   		p_header.period_type,
			   		p_header.user_period_type,
			   		p_header.period_name,
			   		p_header.supplier_id,
			   		p_header.supplier,
			   		p_header.supplier_site_id,
			   		p_header.supplier_site,
			   		p_header.category_id,
			   		p_header.commodity,
			   		p_header.item_id,
			   		p_header.item,
			   		p_header.comments,
			   		p_header.evaluated_by_id,
			   		p_header.evaluated_by,
			   		p_header.org_id,
			   		p_header.oper_unit_id,
			   		p_header.operating_unit,
					p_header.submit_type,
					p_header.evaluation_id,
			   		error_msg);
END;

PROCEDURE  Get_Criteria_Info(  p_category_id	  IN NUMBER,
			       p_oper_unit_id	  IN NUMBER,
			       p_table		  IN OUT NOCOPY t_criteria_table)
IS

  precedence VARCHAR2(80) := FND_PROFILE.value('CUSTOM_MEASURE_PRECEDENCE');

  l_criteria_table t_criteria_table;
  l_index number := 0;
  l_progress varchar2(240) := '';

  type t_Criteria_Cursor is ref cursor return t_criteria_record;

  c_Criteria t_Criteria_Cursor;

BEGIN

  l_progress := '001';

  open c_Criteria for
    select criteria_code, weight, min_score, max_score
      from poa_cm_distributions
     where category_id = nvl(p_category_id, -1)
       and organization_id = nvl(p_oper_unit_id, -1)
     order by criteria_code;

  l_progress := '002';

  loop

    fetch c_Criteria into l_criteria_table(l_index);

    exit when c_Criteria%NOTFOUND;

    l_index := l_index + 1;

  end loop;

  l_progress := '003';

  close c_Criteria;

  if (l_index = 0) then

    if precedence = 'COMMODITY-OU' then

      l_progress := '004';

      open c_Criteria for
	select criteria_code, weight, min_score, max_score
	  from poa_cm_distributions
	 where category_id = nvl(p_category_id, -1)
	   and organization_id is null
	order by criteria_code;

    elsif precedence = 'OU-COMMODITY' then

      l_progress := '005';

      open c_Criteria for
	select criteria_code, weight, min_score, max_score
	  from poa_cm_distributions
	 where organization_id = nvl(p_oper_unit_id, -1)
	   and category_id is null
	order by criteria_code;

    end if;

    l_progress := '006';

    loop

      fetch c_Criteria into l_criteria_table(l_index);

      exit when c_Criteria%NOTFOUND;

      l_index := l_index + 1;

    end loop;

    l_progress := '007';

    close c_Criteria;

    if (l_index = 0) then

      if precedence = 'COMMODITY-OU' then

        l_progress := '008';

	open c_Criteria for
	  select criteria_code, weight, min_score, max_score
	    from poa_cm_distributions
	   where organization_id = nvl(p_oper_unit_id, -1)
	     and category_id is null
	   order by criteria_code;

      elsif precedence = 'OU-COMMODITY' then

        l_progress := '009';

	open c_Criteria for
	  select criteria_code, weight, min_score, max_score
	    from poa_cm_distributions
	   where category_id = nvl(p_category_id, -1)
	     and organization_id is null
	   order by criteria_code;

      end if;

      l_progress := '010';

      loop

	fetch c_Criteria into l_criteria_table(l_index);

	exit when c_Criteria%NOTFOUND;

	l_index := l_index + 1;

      end loop;

      l_progress := '011';

      close c_Criteria;

      if (l_index = 0) then

	open c_Criteria for
	  select criteria_code, weight, min_score, max_score
	    from poa_cm_distributions
	   where category_id is null
	     and organization_id is null
	   order by criteria_code;

        l_progress := '012';

	loop

	  fetch c_Criteria into l_criteria_table(l_index);

	  exit when c_Criteria%NOTFOUND;

	  l_index := l_index + 1;

	end loop;

        l_progress := '013';

	close c_Criteria;

      end if;

    end if;

  end if;

  l_progress := '014';

  p_table := l_criteria_table;

EXCEPTION
  when others then
    null;
END;

PROCEDURE PrintCSS IS
BEGIN

  htp.p('<STYLE TYPE="text/css">');
  htp.p('<!--');
  htp.p('font.pagetitle');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-style: italic;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 14pt;}');
  htp.p('font.itemtitle');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: white;');
  htp.p('		     font-size: 14pt;}');
  htp.p('font.bartitle');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: black;');
  htp.p('		     font-weight: bold;');
  htp.p('		     font-size: 8pt;}');
  htp.p('font.containertitle');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-style: italic;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: #cccccc;');
  htp.p('		     font-size: 14pt;}');
  htp.p('font.graytab');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: black;');
  htp.p('		     text-decoration: none;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.purpletab');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: white;');
  htp.p('		     text-decoration: none;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.promptblack');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: black;');
  htp.p('		     text-decoration: none;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.helptext');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-style: italic;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.helptitle ');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-style: italic;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 14pt;}');
  htp.p('font.promptwhite');
  htp.p('		    {font-family: sans-serif;');
  htp.p('		     font-face: arial;');
  htp.p('		     color: white;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.datablack');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.fielddata ');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.tablefielddata ');
  htp.p('		    {font-family: "arial narrow", sans-serif;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.tabledata ');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: black;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.button');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: black;');
  htp.p('		     text-decoration: none;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.link');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     color: blue;');
  htp.p('		     text-decoration: underline;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.linkbold');
  htp.p('		    {font-family: Arial, sans-serif;');
  htp.p('		     font-weight: bold;');
  htp.p('		     color: blue;');
  htp.p('		     text-decoration: underline;');
  htp.p('		     font-size: 10pt;}');
  htp.p('font.dropdownmenu');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: #003366;');
  htp.p('                    font-style: italic;');
  htp.p('                    font-size: 16pt;}');
  htp.p('-->');
  htp.p('</STYLE>');

END PrintCSS;

PROCEDURE PrintBottomButtons(p_language IN VARCHAR2, which_one IN NUMBER) IS
BEGIN


htp.p('
<table width=100% border=0 cellspacing=0 cellpadding=15>
  <tr>
    <td>
      <table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr>
          <td width=604>&nbsp;</td>
          <td rowspan=2 valign=bottom width=12><img src=/OA_MEDIA/bisslghr.gif width=12 height=14></td>
        </tr>
        <tr>
          <td bgcolor=#CCCC99 height=1><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td>
        </tr>
        <tr>
          <td height=5><img src=http:/OA_MEDIA/bisspace.gif width=1 height=1></td>
        </tr>

        <tr>
          <td align="right"> &nbsp; <span class="OraALinkText"><span class="OraALinkText"> ');

if (which_one = 1) then
htp.p('
	   <A href=OracleNavigate.Responsibility onMouseOver="window.status=''Cancel'';return true"><img src=/OA_MEDIA/poacancl.gif border="0"></a>&nbsp;&nbsp;&nbsp;
	   <A href="javascript:window.history.back()" onMouseOver="window.status=''Back'';return true"><img src=/OA_MEDIA/poaback.gif border="0"></a>&nbsp;&nbsp;&nbsp;
           <A href="javascript:submitDoc(''Done'')" onMouseOver="window.status=''Save'';return true"><img src=/OA_MEDIA/poasave.gif border="0"></a> ');
end if;

if (which_one = 3) then
htp.p('
	   <A href=OracleNavigate.Responsibility onMouseOver="window.status=''Cancel'';return true"><img src=/OA_MEDIA/poacancl.gif border="0"></a>&nbsp;&nbsp;&nbsp;
           <A href="javascript:window.history.back()" onMouseOver="window.status=''Back'';return true"><img src=/OA_MEDIA/poaback.gif border="0"></a>&nbsp;&nbsp;&nbsp; ');
end if;

if (which_one = 2) then
htp.p('
	   <A href="javascript:window.history.back()" onMouseOver="window.status=''Back'';return true"><img src=/OA_MEDIA/poaback.gif border="0"></a>&nbsp;&nbsp;&nbsp;
           <a href="javascript:document.POA_CM_EVAL_SCORES_R.submit()" onMouseOver="window.status=''Modify'';return true"><img src=/OA_MEDIA/poamodfy.gif border="0"></a> ');
end if;

htp.p('
           </span></span></td>
        </tr>
      </table>
      </td>
          </tr>
        </table>
');

END PrintBottomButtons;

PROCEDURE redirect_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			POA_CM_SUBMIT_TYPE	   IN VARCHAR2 DEFAULT NULL,
			POA_CM_EVALUATION_ID	   IN VARCHAR2 DEFAULT NULL
) IS

  x_category_set_id  NUMBER;
  x_structure_id     NUMBER;
  x_organization_id  NUMBER;

  l_language	     VARCHAR2(5);
  l_script_name      VARCHAR2(240);

  l_period_type      VARCHAR2(15) := poa_cm_period_type;
  l_period_name      VARCHAR2(15) := poa_cm_period_name;
  l_supplier_id      NUMBER := to_number(poa_cm_supplier_id);
  l_supplier_site_id NUMBER := to_number(poa_cm_supplier_site_id);
  l_org_id	     NUMBER := to_number(poa_cm_org_id);
  l_category_id      NUMBER := to_number(poa_cm_category_id);
  l_item_id	     NUMBER := to_number(poa_cm_item_id);
  l_evaluated_by_id  NUMBER := to_number(poa_cm_evaluated_by_id);
  l_oper_unit_id     NUMBER := to_number(poa_cm_oper_unit_id);
  l_evaluation_id    NUMBER := to_number(poa_cm_evaluation_id);

  l_user_period_type VARCHAR2(15) := poa_cm_user_period_type;
  l_supplier_name    PO_VENDORS.VENDOR_NAME%TYPE := poa_cm_supplier;
  l_site_name	     VARCHAR2(15) := poa_cm_supplier_site;
  l_operating_unit   hr_all_organization_units.NAME%TYPE := poa_cm_operating_unit;
  l_commodity	     VARCHAR2(81) := poa_cm_commodity;
  l_item	     VARCHAR2(40) := poa_cm_item;
  l_evaluated_by     VARCHAR2(240):= poa_cm_evaluated_by;
  l_submit_type      VARCHAR2(10) := poa_cm_submit_type;

  temp_var  	     VARCHAR2(1) := null;

  l_progress         VARCHAR2(240);
  l_header           t_header_record;

BEGIN


  l_header.custom_measure_code := poa_cm_custom_measure_code;
  l_header.custom_measure := poa_cm_custom_measure;
  l_header.period_type := poa_cm_period_type;
  l_header.user_period_type := poa_cm_user_period_type;
  l_header.period_name := poa_cm_period_name;
  l_header.supplier_id := poa_cm_supplier_id;
  l_header.supplier := poa_cm_supplier;
  l_header.supplier_site_id := poa_cm_supplier_site_id ;
  l_header.supplier_site := poa_cm_supplier_site;
  l_header.category_id := poa_cm_category_id;
  l_header.commodity := poa_cm_commodity;
  l_header.item_id := poa_cm_item_id;
  l_header.item := poa_cm_item;
  l_header.comments := poa_cm_comments;
  l_header.evaluated_by_id := poa_cm_evaluated_by_id;
  l_header.evaluated_by := poa_cm_evaluated_by;
  l_header.org_id := poa_cm_org_id;
  l_header.oper_unit_id := poa_cm_oper_unit_id;
  l_header.operating_unit := poa_cm_operating_unit;
  l_header.submit_type := poa_cm_submit_type;
  l_header.evaluation_id := poa_cm_evaluation_id;


  -- Set multi-org context

  l_progress := '001';

  fnd_client_info.set_org_context(poa_cm_org_id);

  -- Get Period Type

  begin
    if l_period_type is null then

      SELECT period_type
        INTO l_period_type
        FROM gl_period_types
       WHERE USER_PERIOD_TYPE = l_user_period_type;

      if l_period_type is null then
        reload_header(l_header, 'Invalid Period Type');
        return;
      end if;

    end if;

  exception
    when others then
      reload_header(l_header, 'Invalid Period Type');
      return;
  end;

  --Check period name

  begin

    SELECT count(1)
      INTO temp_var
      FROM gl_periods
     WHERE PERIOD_NAME = l_period_name
       AND PERIOD_TYPE = l_period_type;

    if temp_var = 0 then
      reload_header(l_header, 'Invalid Period Name');
      return;
    end if;

  exception
    when others then
      reload_header(l_header, 'Invalid Period Name');
      return;
  end;

  -- Get supplier id

  l_progress := '00';

  begin

    if l_supplier_id is null then

      SELECT min(vendor_id)
        INTO l_supplier_id
        FROM PO_VENDORS
       WHERE VENDOR_NAME = l_supplier_name;

      if l_supplier_id is null then
        reload_header(l_header, 'Invalid Supplier');
        return;
      end if;

    end if;

  exception
    when others then
      reload_header(l_header, 'Invalid Supplier');
      return;
  end;

  -- Get supplier site id

  begin
    if (l_supplier_site_id is null) AND (l_site_name is not null) then

      SELECT min(vendor_site_id)
        INTO l_supplier_site_id
        FROM PO_VENDOR_SITES
       WHERE VENDOR_SITE_CODE = l_site_name
         AND VENDOR_ID = nvl(l_supplier_id,-1);

      if l_supplier_site_id is null then
        reload_header(l_header, 'Invalid Supplier Site');
        return;
      end if;

    end if;

  exception
    when others then
      reload_header(l_header, 'Invalid Supplier Site');
      return;
  end;

  -- Get oper_unit_id

  begin
    if (l_oper_unit_id is null) and (l_operating_unit is not null) then

      SELECT min(organization_id)
        INTO l_oper_unit_id
        FROM HR_OPERATING_UNITS
       WHERE name = l_operating_unit AND EXISTS (
	     SELECT '1' FROM PO_VENDOR_SITES_ALL WHERE
	        vendor_site_id = nvl(l_supplier_site_id, vendor_site_id));

      if l_oper_unit_id is null then
        reload_header(l_header, 'Invalid Operating Unit');
        return;
      end if;

    end if;

  exception
    when others then
        reload_header(l_header, 'Invalid Operating Unit');
        return;
  end;

  -- Get Category id

  po_core_s.get_item_category_structure(x_category_set_id, x_structure_id);

  begin

    if (l_category_id is null) and (l_commodity is not null) then

      SELECT min(category_id)
        INTO l_category_id
        FROM mtl_categories_kfv
       WHERE CONCATENATED_SEGMENTS = l_commodity
         AND STRUCTURE_ID = x_structure_id;

      if l_category_id is null then
        reload_header(l_header, 'Invalid Category');
        return;
      end if;

    end if;

  exception
    when others then
        reload_header(l_header, 'Invalid Category');
        return;
  end;

  begin

  -- Get organization_id

    SELECT inventory_organization_id
      INTO x_organization_id
      FROM financials_system_parameters;

    -- Get item id

    if (l_item_id is null) and (l_item is not null) then
      SELECT min(msi.inventory_item_id)
        INTO l_item_id
        FROM mtl_system_items_kfv msi,
             mtl_item_categories mic
       WHERE msi.CONCATENATED_SEGMENTS = l_item
         AND msi.organization_id = x_organization_id
         AND msi.inventory_item_id = mic.inventory_item_id
         AND msi.organization_id = mic.organization_id
         AND mic.category_set_id = x_category_set_id
         AND nvl(l_category_id, mic.category_id) = mic.category_id;

      if l_item_id is null then
        reload_header(l_header, 'Invalid Tom');
        return;
      end if;

    end if;

    -- Get Category_id from item if category_id is null;

    if (l_category_id is null) and (l_item_id is not null) then

      SELECT CATEGORY_ID
        INTO l_category_id
        FROM mtl_item_categories
       WHERE organization_id = x_organization_id
         AND category_set_id = x_category_set_id
         AND INVENTORY_ITEM_ID = l_item_id;

    end if;

  exception
    when others then
        reload_header(l_header, SQLERRM || ',' || x_organization_id || ',' ||
		x_category_set_id || ',' || l_item_id);
        return;
  end;

  -- Get evaluator id

  begin

    if (l_evaluated_by_id is null) and (l_evaluated_by is not null) then

      SELECT orig_system_id
        INTO l_evaluated_by_id
        FROM WF_USERS
       WHERE NAME = l_evaluated_by;

      if l_evaluated_by_id is null then
        reload_header(l_header, 'Invalid Evaluator');
        return;
      end if;
    end if;

  exception
    when others then
        reload_header(l_header, 'Invalid Evaluator');
        return;
  end;



if (POA_CM_SUBMIT_TYPE = 'Next') then
	poa_cm_eval_scores_icx.score_entry_page(
			poa_cm_custom_measure_code ,
			poa_cm_custom_measure      ,
			l_period_type	   	   ,
			poa_cm_user_period_type    ,
			poa_cm_period_name	   ,
			l_supplier_id	   	   ,
			poa_cm_supplier	      	   ,
			l_supplier_site_id    	   ,
		 	poa_cm_supplier_site       ,
			l_category_id	   	   ,
			poa_cm_commodity	   ,
			l_item_id		   ,
			poa_cm_item		   ,
			poa_cm_comments		   ,
			l_evaluated_by_id     	   ,
			poa_cm_evaluated_by	   ,
			poa_cm_org_id	      	   ,
			l_oper_unit_id	   	   ,
			poa_cm_operating_unit      ,
			'Update'		   ,
			POA_CM_EVALUATION_ID	   );
end if;

if (POA_CM_SUBMIT_TYPE = 'Update') then
   	poa_cm_eval_scores_icx.query_evals(
			poa_cm_custom_measure_code ,
			poa_cm_custom_measure      ,
			l_period_type	   	   ,
			poa_cm_user_period_type    ,
			poa_cm_period_name	   ,
			l_supplier_id		   ,
			poa_cm_supplier	      	   ,
			l_supplier_site_id    	   ,
		 	poa_cm_supplier_site       ,
			l_category_id	   	   ,
			poa_cm_commodity	   ,
			l_item_id		   ,
			poa_cm_item		   ,
			poa_cm_comments		   ,
			l_evaluated_by_id  	   ,
			poa_cm_evaluated_by	   ,
			poa_cm_org_id	      	   ,
			l_oper_unit_id	   	   ,
			poa_cm_operating_unit      ,
			poa_cm_submit_type	   ,
			poa_cm_evaluation_id	   );
end if;

if (POA_CM_SUBMIT_TYPE is null) then
  poa_cm_evaluation_icx.header_page();
end if;

END redirect_page;

PROCEDURE score_entry_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			   poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_period_type	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			   poa_cm_period_name	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			   poa_cm_category_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_commodity	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_item_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_item		      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_comments	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluated_by	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_org_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_oper_unit_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_submit_type	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluation_id       IN VARCHAR2 DEFAULT NULL
) IS

  l_language	     VARCHAR2(5);
  l_script_name      VARCHAR2(240);

  l_period_type      VARCHAR2(15) := poa_cm_period_type;
  l_period_name      VARCHAR2(15) := poa_cm_period_name;
  l_supplier_id      NUMBER := to_number(poa_cm_supplier_id);
  l_supplier_site_id NUMBER := to_number(poa_cm_supplier_site_id);
  l_org_id	     NUMBER := to_number(poa_cm_org_id);
  l_category_id      NUMBER := to_number(poa_cm_category_id);
  l_item_id	     NUMBER := to_number(poa_cm_item_id);
  l_evaluated_by_id  NUMBER := to_number(poa_cm_evaluated_by_id);
  l_oper_unit_id     NUMBER := to_number(poa_cm_oper_unit_id);
  l_evaluation_id    NUMBER := to_number(poa_cm_evaluation_id);

  l_user_period_type VARCHAR2(15) := poa_cm_user_period_type;
  l_supplier_name    PO_VENDORS.VENDOR_NAME%TYPE := poa_cm_supplier;
  l_site_name	     VARCHAR2(15) := poa_cm_supplier_site;
  l_operating_unit   hr_all_organization_units.NAME%TYPE := poa_cm_operating_unit;
  l_commodity	     VARCHAR2(81) := poa_cm_commodity;
  l_item	     VARCHAR2(40) := poa_cm_item;
  l_evaluated_by     VARCHAR2(240):= poa_cm_evaluated_by;
  l_submit_type      VARCHAR2(10) := poa_cm_submit_type;

  l_criteria_table   t_criteria_table;
  v_Criteria	     VARCHAR2(80);

  l_scores_table     t_scores_table;
  l_index            NUMBER := 0;

  type t_Scores_Cursor is ref cursor return t_scores_record;
  c_eval_scores t_Scores_Cursor;

  type t_Criteria_Cursor is ref cursor return t_criteria_record;
  c_Criteria t_Criteria_Cursor;

BEGIN

IF (l_evaluation_id is null) THEN

  Get_Criteria_Info(	l_category_id,
			l_oper_unit_id,
			l_criteria_table);

ELSE

	SELECT 	category_id, oper_unit_id
	INTO 	l_category_id, l_oper_unit_id
	FROM 	poa_cm_evaluation
	WHERE	evaluation_id = l_evaluation_id;

  	open c_Criteria for
		select criteria_code, weight, min_score, max_score
		from poa_cm_eval_scores
		where evaluation_id = l_evaluation_id;

  	loop
     		fetch c_Criteria into l_criteria_table(l_index);
    		exit when c_Criteria%NOTFOUND;
    		l_index := l_index + 1;
  	end loop;

	FOR v_counter IN 1..l_criteria_table.count LOOP

		OPEN c_eval_scores FOR
			SELECT 	score, comments
			FROM	poa_cm_eval_scores
			WHERE	evaluation_id = l_evaluation_id
			AND	criteria_code = l_criteria_table(v_counter-1).criteria_code;

		FETCH c_eval_scores INTO l_scores_table(v_counter-1).score, l_scores_table(v_counter-1).comments;

		CLOSE c_eval_scores;
	END LOOP;

END IF;


  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');

  htp.htmlOpen;
  htp.title('Survey Response Scores');

  js.scriptOpen;

  htp.p('
function weighted_score(linenum)
{
  var f = document.POA_CM_EVAL_SCORES_R;

  if (isNaN(f.SCORE[linenum].value))
  {
    alert(''Please enter a valid score.'');
    f.SCORE[linenum].focus();
    return;
  }

  if (f.SCORE[linenum].value * 1 > f.MAX_SCORE[linenum].value * 1)
  {
    alert(''Score is out of range.'');
    f.SCORE[linenum].focus();
    return;
  }

  if (f.SCORE[linenum].value * 1 < f.MIN_SCORE[linenum].value * 1)
  {
    alert(''Score is out of range.'');
    f.SCORE[linenum].focus();
    return;
  }

  if (f.WEIGHT[linenum].value * 1 == -1)
  {
    f.WEIGHTED_SCORE[linenum].value = f.SCORE[linenum].value;
  }
  else
  {
    f.WEIGHTED_SCORE[linenum].value = roundDecimal(((f.SCORE[linenum].value - f.MIN_SCORE[linenum].value)  *
					f.WEIGHT[linenum].value /
                                      	(f.MAX_SCORE[linenum].value - f.MIN_SCORE[linenum].value)), 2);
  }

  var temp = 0;

  for (var i = 0; i < f.WEIGHTED_SCORE.length; i++)
    temp = temp + f.WEIGHTED_SCORE[i].value * 1;

  f.TOTAL_SCORE.value = roundDecimal(temp, 2);
}

function updateScores()
{

  var f = document.POA_CM_EVAL_SCORES_R;

  for (var i = 0; i < (f.WEIGHTED_SCORE.length-1); i++)
    weighted_score(i);
}

function roundDecimal(expr, digits)
{
  var str= "" + Math.round(eval(expr) * Math.pow(10, digits));
  while (str.length <= digits)
  {
    str= "0"+str;
  }
  var decpoint= str.length- digits;
  return str.substring(0, decpoint) + "." + str.substring(decpoint, str.length);
}


function submitDoc(submit_type)
{
  var f = document.POA_CM_EVAL_SCORES_R;

  if (submit_type == "Refresh")
    f.POA_CM_SUBMIT_TYPE.value = "Refresh";
  else if (submit_type == "Done")
    f.POA_CM_SUBMIT_TYPE.value = "Done";

  for (var i = 0; i < f.SCORE.length; i++)
  {
    if (isNaN(f.SCORE[i].value))
    {
      return;
    }

    if (f.SCORE[i].value * 1 > f.MAX_SCORE[i].value * 1)
    {
      return;
    }

    if (f.SCORE[i].value * 1 < f.MIN_SCORE[i].value * 1)
    {
      return;
    }
  }

  document.POA_CM_EVAL_SCORES_R.submit();
}

function cancelAction()
{
  var f = document.POA_CM_EVAL_SCORES_R;

  for (var i = 0; i < f.SCORE.length; i++)
  {
    f.SCORE[i].value = "";
    f.WEIGHTED_SCORE[i].value = "0.00";
  }

  f.TOTAL_SCORE.value = "0.00";

}

  ');

  js.scriptClose;

  htp.headOpen;
  icx_util.copyright;

  PrintCSS;

htp.p('<LINK REL="stylesheet" HREF="/OA_HTML/bismarli.css">');

  htp.headClose;

  htp.bodyOpen;


  htp.p('<BODY bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000" onLoad="javascript:updateScores()">');


  htp.p('

     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=/OA_MEDIA/bisorcl.gif border=no height=23 width=141></a></td>
     <tr align=left> <td valign=bottom><img src=/OA_MEDIA/POABRAND.gif border=no></a></td></td></tr>
     </table>
     </td><td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href=Oraclemypage.home onMouseOver="window.status=''Return to Portal''; return true">
          <img alt=Return to Portal src=/OA_MEDIA/bisrtrnp.gif width=32 border=0 height=32></a></td>
          <td width=60 align=center><a href=OracleNavigate.Responsibility onMouseOver="window.status=''Menu''; return true">
          <img alt=Menu src=/OA_MEDIA/bisnmenu.gif width=32 border=0
height=32></a></td>
          <td width=60 align=center valign=bottom><a href="javascript:help_window()", onMouseOver="window.status=''Help''; return true">
          <img alt=Help src=/OA_MEDIA/bisnhelp.gif width=32 border=0
height=32></a></td>
        </tr>
        <tr align=center valign=top>
          <td width=60><a href=Oraclemypage.home onMouseOver="window.status=''Return to Portal''; return true">
          <span class="OraGlobalButtonText">Return to Portal</span></a></td>
          <td width=60><a href=OracleNavigate.Responsibility onMouseOver="window.status=''Menu''; return true">
          <span class="OraGlobalButtonText">Menu</span></a></td>
          <td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''Help''; return true">
          <span class="OraGlobalButtonText">Help</span></a></td>
        </tr></table>
    </td>
    </tr></table>
   </table>

<table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src=/OA_MEDIA/bisspace.gif width=1></td>
    <td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">&nbsp;</font></td>
    <td background=/OA_MEDIA/bisrhshd.gif height=21 width=5><img border=0 height=1
src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=5></td>
    <td background=/OA_MEDIA/bisbot.gif width=1000><img align=top height=16
src=/OA_MEDIA/bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src=/OA_MEDIA/bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background=/OA_MEDIA/bisbot.gif height=8 valign=top width=9><img height=8
src=/OA_MEDIA/bislend.gif width=10></td>
    <td background=/OA_MEDIA/bisbot.gif height=8 width=5><img border=0 height=1
src=/OA_MEDIA/bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src=/OA_MEDIA/bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>

<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">Survey Response Scores</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">Enter the desired scores and then save.</font></td></tr>
        </table>
</td></tr>
</table>

  ');




  htp.p('<table width=100% bgcolor=#FFFFFF cellpadding=10 cellspacing=0 border=0>');
  htp.p('<tr><td>');
  htp.p('<table ALIGN=center cellpadding=2 cellspacing=1 border=2>');

-- Heading

  ak_query_pkg.exec_query(p_parent_region_appl_id=>201,
                          p_parent_region_code=>'POA_CM_EVAL_SCORES_R',
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'F',
                          p_return_children=>'F');

  htp.p('<TR>');

  FOR v_counter IN 1..7 LOOP

    htp.p('<TH bgcolor=#31659C align=' || ak_query_pkg.g_items_table(v_counter).horizontal_alignment ||
          ' valign=bottom><font class=promptwhite>' ||
          ak_query_pkg.g_items_table(v_counter).attribute_label_long || '</font></TH>');

  END LOOP;

  htp.p('</TR>');

 htp.p('<FORM NAME="POA_CM_EVAL_SCORES_R" ACTION="' ||l_script_name|| '/POA_CM_ENTER_SCORES_ICX.redirect_page" METHOD="POST">');


  FOR v_counter IN 1..l_criteria_table.count LOOP

    -- Get Displayed field

    SELECT displayed_field
      INTO v_Criteria
      FROM po_lookup_codes
     WHERE lookup_type = 'SATISFACTION CRITERIA'
       AND lookup_code = l_criteria_table(v_counter - 1).criteria_code;

    -- Criteria

    htp.p('<TD ALIGN=left><font class=tabledata><INPUT NAME="CRITERIA_CODE" TYPE="HIDDEN" VALUE="' || l_criteria_table(v_counter - 1).criteria_code || '">');
    htp.p(v_Criteria || '</font></TD>');

    -- Score

    if (l_evaluation_id is null) then
      htp.p('<TD><font class=datablack><INPUT NAME="SCORE" TYPE="TEXT" onChange="javascript:weighted_score('|| to_char(v_counter - 1) ||')" VALUE="" SIZE=4 MAXLENGTH=25></font>&nbsp;</TD>');
    else
      htp.p('<TD><font class=datablack><INPUT NAME="SCORE" TYPE="TEXT" onChange="javascript:weighted_score('|| to_char(v_counter - 1) ||')" VALUE="' ||  l_scores_table(v_counter-1).score || '" SIZE=4 MAXLENGTH=25></font>&nbsp;</TD>');
    end if;

    -- Weight

    if l_criteria_table(v_counter - 1).weight is null then
      l_criteria_table(v_counter - 1).weight := -1;
    end if;

      htp.p('<TD ALIGN=right><font class=tabledata><INPUT NAME="WEIGHT" TYPE="HIDDEN" VALUE=' || to_char(l_criteria_table(v_counter - 1).weight) || ' SIZE=4 MAXLENGTH=25></font>');

    if l_criteria_table(v_counter - 1).weight = -1 then
      htp.p('<font class=tabledata>None</font></TD>');
    else
      htp.p('<font class=tabledata>' || to_char(l_criteria_table(v_counter - 1).weight, '9990D00') || '</font></TD>');
    end if;

    -- Weighted Score

      htp.p('<TD ALIGN=center><font class=datablack><INPUT NAME="WEIGHTED_SCORE" TYPE="TEXT" onfocus="javascript:this.blur()" VALUE="0.00" SIZE=4 MAXLENGTH=25></font></TD>');

    -- Min Score

    if l_criteria_table(v_counter - 1).min_score is null then
      l_criteria_table(v_counter - 1).min_score := 0;
    end if;

    htp.p('<TD ALIGN=right><font class=tabledata><INPUT NAME="MIN_SCORE" TYPE="HIDDEN" VALUE=' || to_char(l_criteria_table(v_counter - 1).min_score) || ' SIZE=4 MAXLENGTH=25></font>');


    htp.p('<font class=tabledata>' || to_char(l_criteria_table(v_counter - 1).min_score, '9990D00') || '</font></TD>');

    -- Max Score

    if l_criteria_table(v_counter - 1).max_score is null then
      l_criteria_table(v_counter - 1).max_score := 100;
    end if;

    htp.p('<TD ALIGN=right><font class=tabledata><INPUT NAME="MAX_SCORE" TYPE="HIDDEN" VALUE=' || to_char(l_criteria_table(v_counter - 1).max_score) || ' SIZE=4 MAXLENGTH=25></font>');

    htp.p('<font class=tabledata>' || to_char(l_criteria_table(v_counter - 1).max_score, '9990D00') || '</font></TD>');

    -- Comments

if (l_evaluation_id is null) then

    htp.p('<TD ALIGN=LEFT><font class=datablack><INPUT NAME="COMMENTS" TYPE="TEXT" VALUE="" SIZE=15 MAXLENGTH=240></font>&nbsp;</TD>');

else

    htp.p('<TD ALIGN=LEFT><font class=datablack><INPUT NAME="COMMENTS" TYPE="TEXT" VALUE="' || l_scores_table(v_counter-1).comments || '" SIZE=15 MAXLENGTH=240></font>&nbsp;</TD>');

end if;

    htp.p('</TR>');

  END LOOP;

  htp.p('<TR>');

    htp.p('<INPUT NAME="CRITERIA_CODE" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="SCORE" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="WEIGHT" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="WEIGHTED_SCORE" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="MIN_SCORE" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="MAX_SCORE" TYPE="HIDDEN" VALUE="">');

    htp.p('<INPUT NAME="COMMENTS" TYPE="HIDDEN" VALUE="">');


  htp.p('<TD COLSPAN=3 ALIGN=RIGHT><font class=datablack>' || ak_query_pkg.g_items_table(8).attribute_label_long || '</font></TD>');

  htp.p('<TD COLSPAN=1 ALIGN=CENTER BGCOLOR=''#31659C''><font class=datablack><INPUT NAME="TOTAL_SCORE" TYPE="TEXT" onfocus="javascript:this.blur()" VALUE="0.00" SIZE=4 MAXLENGTH=25></font></TD>');

  htp.p('<TD COLSPAN=3><FONT COLOR=#CCCCCC>&nbsp;</FONT>');

  htp.p('<INPUT NAME="poa_cm_custom_measure_code" TYPE="HIDDEN" VALUE="' || poa_cm_custom_measure_code || '">');
  htp.p('<INPUT NAME="poa_cm_custom_measure" TYPE="HIDDEN" VALUE="' || poa_cm_custom_measure || '">');
  htp.p('<INPUT NAME="poa_cm_period_type" TYPE="HIDDEN" VALUE="' || l_period_type || '">');
  htp.p('<INPUT NAME="poa_cm_user_period_type" TYPE="HIDDEN" VALUE="' || poa_cm_user_period_type || '">');
  htp.p('<INPUT NAME="poa_cm_period_name" TYPE="HIDDEN" VALUE="' || poa_cm_period_name || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_id" TYPE="HIDDEN" VALUE="' || to_char(l_supplier_id) || '">');
  htp.p('<INPUT NAME="poa_cm_supplier" TYPE="HIDDEN" VALUE="' || l_supplier_name || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_site_id" TYPE="HIDDEN" VALUE="' || to_char(l_supplier_site_id) || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_site" TYPE="HIDDEN" VALUE="' || l_site_name || '">');
  htp.p('<INPUT NAME="poa_cm_category_id" TYPE="HIDDEN" VALUE="' || to_char(l_category_id) || '">');
  htp.p('<INPUT NAME="poa_cm_commodity" TYPE="HIDDEN" VALUE="' || l_commodity || '">');
  htp.p('<INPUT NAME="poa_cm_item_id" TYPE="HIDDEN" VALUE="' || to_char(l_item_id) || '">');
  htp.p('<INPUT NAME="poa_cm_item" TYPE="HIDDEN" VALUE="' || l_item || '">');
  htp.p('<INPUT NAME="poa_cm_comments" TYPE="HIDDEN" VALUE="' || poa_cm_comments || '">');
  htp.p('<INPUT NAME="poa_cm_evaluated_by_id" TYPE="HIDDEN" VALUE="' || to_char(l_evaluated_by_id) || '">');
  htp.p('<INPUT NAME="poa_cm_evaluated_by" TYPE="HIDDEN" VALUE="' || l_evaluated_by || '">');
  htp.p('<INPUT NAME="poa_cm_org_id" TYPE="HIDDEN" VALUE="' || to_char(l_org_id)  || '">');
  htp.p('<INPUT NAME="poa_cm_oper_unit_id" TYPE="HIDDEN" VALUE="' || to_char(l_oper_unit_id) || '">');
  htp.p('<INPUT NAME="poa_cm_operating_unit" TYPE="HIDDEN" VALUE="' || l_operating_unit || '">');
  htp.p('<INPUT NAME="POA_CM_SUBMIT_TYPE" TYPE="HIDDEN" VALUE="' || l_submit_type || '">');
  htp.p('<INPUT NAME="POA_CM_EVALUATION_ID" TYPE="HIDDEN" VALUE="' || l_evaluation_id || '">');

  htp.p('</TD></TR>');

  htp.p('</table>');
  htp.p('</td></tr></table>');

  PrintBottomButtons(l_language, 1);

  htp.bodyClose;
  htp.htmlClose;

EXCEPTION
  when others then
    null;

END score_entry_page;

PROCEDURE query_evals(  poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			POA_CM_SUBMIT_TYPE	   IN VARCHAR2 DEFAULT NULL,
			POA_CM_EVALUATION_ID	   IN VARCHAR2 DEFAULT NULL
) IS

  l_language	     VARCHAR2(5);
  l_script_name      VARCHAR2(240);

  l_period_type      VARCHAR2(15) := poa_cm_period_type;
  l_period_name      VARCHAR2(15) := poa_cm_period_name;
  l_supplier_id      NUMBER := to_number(poa_cm_supplier_id);
  l_supplier_site_id NUMBER := to_number(poa_cm_supplier_site_id);
  l_org_id	     NUMBER := to_number(poa_cm_org_id);
  l_category_id      NUMBER := to_number(poa_cm_category_id);
  l_item_id	     NUMBER := to_number(poa_cm_item_id);
  l_evaluated_by_id  NUMBER := to_number(poa_cm_evaluated_by_id);
  l_oper_unit_id     NUMBER := to_number(poa_cm_oper_unit_id);
  l_evaluation_id    NUMBER := to_number(poa_cm_evaluation_id);

  l_user_period_type VARCHAR2(15) := poa_cm_user_period_type;
  l_supplier_name    PO_VENDORS.VENDOR_NAME%TYPE := poa_cm_supplier;
  l_site_name	     VARCHAR2(15) := poa_cm_supplier_site;
  l_operating_unit   hr_all_organization_units.NAME%TYPE := poa_cm_operating_unit;
  l_commodity	     VARCHAR2(81) := poa_cm_commodity;
  l_item	     VARCHAR2(40) := poa_cm_item;
  l_evaluated_by     VARCHAR2(240):= poa_cm_evaluated_by;
  l_submit_type      VARCHAR2(10) := poa_cm_submit_type;

  v_eval_id		NUMBER;
  v_supplier_site	VARCHAR2(15);
  v_oper_unit		hr_all_organization_units.NAME%TYPE;
  v_commodity		VARCHAR2(81);
  v_item		VARCHAR2(40);
  v_evaluator		VARCHAR2(100);
  v_creation_date	DATE;
  v_last_update_date	DATE;

  v_counter		NUMBER := 0;

  type t_Eval_Cursor is ref cursor return t_eval_record;
  c_evaluation t_Eval_Cursor;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');

  htp.htmlOpen;
  htp.title('Survey Response Scores');

  js.scriptOpen;

  js.scriptClose;

  htp.headOpen;

  icx_util.copyright;

  PrintCSS;

  htp.p('<LINK REL="stylesheet" HREF="/OA_HTML/bismarli.css">');

  htp.headClose;

  htp.bodyOpen;

 htp.p('<BODY bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">');

htp.p('


     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=/OA_MEDIA/bisorcl.gif border=no height=23 width=141></a></td>
     <tr align=left> <td valign=bottom><img src=/OA_MEDIA/POABRAND.gif border=no></a></td></td></tr>
     </table>
     </td><td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href=Oraclemypage.home onMouseOver="window.status=''Return to Portal''; return true">
          <img alt=Return to Portal src=/OA_MEDIA/bisrtrnp.gif width=32 border=0 height=32></a></td>
          <td width=60 align=center><a href=OracleNavigate.Responsibility onMouseOver="window.status=''Menu''; return true">
          <img alt=Menu src=/OA_MEDIA/bisnmenu.gif width=32 border=0
height=32></a></td>
          <td width=60 align=center valign=bottom><a href="javascript:help_window()", onMouseOver="window.status=''Help''; return true">
          <img alt=Help src=/OA_MEDIA/bisnhelp.gif width=32 border=0
height=32></a></td>
        </tr>
        <tr align=center valign=top>
          <td width=60><a href=Oraclemypage.home onMouseOver="window.status=''Return to Portal''; return true">
          <span class="OraGlobalButtonText">Return to Portal</span></a></td>
          <td width=60><a href=OracleNavigate.Responsibility onMouseOver="window.status=''Menu''; return true">
          <span class="OraGlobalButtonText">Menu</span></a></td>
          <td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''Help''; return true">
          <span class="OraGlobalButtonText">Help</span></a></td>
        </tr></table>
    </td>
    </tr></table>
   </table>

<table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src=/OA_MEDIA/bisspace.gif width=1></td>
    <td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">&nbsp;</font></td>
    <td background=/OA_MEDIA/bisrhshd.gif height=21 width=5><img border=0 height=1
src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=5></td>
    <td background=/OA_MEDIA/bisbot.gif width=1000><img align=top height=16
src=/OA_MEDIA/bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src=/OA_MEDIA/bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background=/OA_MEDIA/bisbot.gif height=8 valign=top width=9><img height=8
src=/OA_MEDIA/bislend.gif width=10></td>
    <td background=/OA_MEDIA/bisbot.gif height=8 width=5><img border=0 height=1
src=/OA_MEDIA/bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src=/OA_MEDIA/bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>

<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">Survey Response Query Results</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">Select the survey response that you would like to modify.</font></td></tr>
        </table>
</td></tr>
</table>


  ');

htp.p('
<table width=100% bgcolor=#FFFFFF cellpadding=15 cellspacing=0 border=0>

<TR><td>
<table width=100% cellpadding=0 cellspacing=0 border=0>
<TR> <td><b>Period Type: ' || l_period_type   || '</b></td></tr>
<TR> <td><b>Period Name: ' || l_period_name   || '</b></td></tr>
<TR> <td><b>Supplier: '    || l_supplier_name || '</b></td></tr>
</TR>
</table>

<tr><td>
<table ALIGN=center cellpadding=2 cellspacing=1 border=2>
<TH bgcolor=#31659C align=left valign=bottom width=5%><font class=promptwhite>&nbsp</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=15%><font class=promptwhite>Operating Unit</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=15%><font class=promptwhite>Commodity</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=15%><font class=promptwhite>Item</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=15%><font class=promptwhite>Supplier Site</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=15%><font class=promptwhite>Evaluator</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=10%><font class=promptwhite>Creation Date</font></TH>
<TH bgcolor=#31659C align=left valign=bottom width=10%><font class=promptwhite>Last Update Date</font></TH>
</TR>
<FORM NAME="POA_CM_EVAL_SCORES_R" ACTION="' ||l_script_name|| '/POA_CM_EVAL_SCORES_ICX.score_entry_page" METHOD="POST">

');

  htp.p('<INPUT NAME="poa_cm_custom_measure_code" TYPE="HIDDEN" VALUE="' || poa_cm_custom_measure_code || '">');
  htp.p('<INPUT NAME="poa_cm_custom_measure" TYPE="HIDDEN" VALUE="' || poa_cm_custom_measure || '">');
  htp.p('<INPUT NAME="poa_cm_period_type" TYPE="HIDDEN" VALUE="' || l_period_type || '">');
  htp.p('<INPUT NAME="poa_cm_user_period_type" TYPE="HIDDEN" VALUE="' || poa_cm_user_period_type || '">');
  htp.p('<INPUT NAME="poa_cm_period_name" TYPE="HIDDEN" VALUE="' || poa_cm_period_name || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_id" TYPE="HIDDEN" VALUE="' || to_char(l_supplier_id) || '">');
  htp.p('<INPUT NAME="poa_cm_supplier" TYPE="HIDDEN" VALUE="' || l_supplier_name || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_site_id" TYPE="HIDDEN" VALUE="' || to_char(l_supplier_site_id) || '">');
  htp.p('<INPUT NAME="poa_cm_supplier_site" TYPE="HIDDEN" VALUE="' || l_site_name || '">');
  htp.p('<INPUT NAME="poa_cm_category_id" TYPE="HIDDEN" VALUE="' || to_char(l_category_id) || '">');
  htp.p('<INPUT NAME="poa_cm_commodity" TYPE="HIDDEN" VALUE="' || l_commodity || '">');
  htp.p('<INPUT NAME="poa_cm_item_id" TYPE="HIDDEN" VALUE="' || to_char(l_item_id) || '">');
  htp.p('<INPUT NAME="poa_cm_item" TYPE="HIDDEN" VALUE="' || l_item || '">');
  htp.p('<INPUT NAME="poa_cm_comments" TYPE="HIDDEN" VALUE="' || poa_cm_comments || '">');
  htp.p('<INPUT NAME="poa_cm_evaluated_by_id" TYPE="HIDDEN" VALUE="' || to_char(l_evaluated_by_id) || '">');
  htp.p('<INPUT NAME="poa_cm_evaluated_by" TYPE="HIDDEN" VALUE="' || l_evaluated_by || '">');
  htp.p('<INPUT NAME="poa_cm_org_id" TYPE="HIDDEN" VALUE="' || to_char(l_org_id)  || '">');
  htp.p('<INPUT NAME="poa_cm_oper_unit_id" TYPE="HIDDEN" VALUE="' || to_char(l_oper_unit_id) || '">');
  htp.p('<INPUT NAME="poa_cm_operating_unit" TYPE="HIDDEN" VALUE="' || l_operating_unit || '">');
  htp.p('<INPUT NAME="POA_CM_SUBMIT_TYPE" TYPE="HIDDEN" VALUE="Refresh">');

if (l_oper_unit_id is not null) and (l_category_id is null) then
  OPEN c_evaluation FOR
	SELECT 	pce.evaluation_id,
		pvs.vendor_site_code,
		hr.name,
		cat.concatenated_segments,
		item.concatenated_segments,
		fu.user_name,
		pce.creation_date,
		pce.last_update_date
	FROM 	poa_cm_evaluation pce,
		hr_operating_units hr,
		fnd_user fu,
		mtl_categories_kfv cat,
		mtl_system_items_kfv item,
		po_vendor_sites pvs
	WHERE 	pce.supplier_id = l_supplier_id
	AND	pce.period_type = l_period_type
	AND 	pce.period_name = l_period_name
	AND	hr.organization_id (+)= pce.oper_unit_id
	AND	fu.user_id (+)= pce.evaluated_by
	AND	cat.category_id  (+)= pce.category_id
	AND 	item.inventory_item_id (+)= pce.item_id
	AND	item.organization_id (+)= pce.org_id
	AND 	pvs.vendor_site_id (+)= pce.supplier_site_id
	AND 	pce.oper_unit_id = l_oper_unit_id
	ORDER BY pce.evaluation_id;

elsif (l_oper_unit_id is null) and (l_category_id is not null) then
  OPEN c_evaluation FOR
	SELECT 	pce.evaluation_id,
		pvs.vendor_site_code,
		hr.name,
		cat.concatenated_segments,
		item.concatenated_segments,
		fu.user_name,
		pce.creation_date,
		pce.last_update_date
	FROM 	poa_cm_evaluation pce,
		hr_operating_units hr,
		fnd_user fu,
		mtl_categories_kfv cat,
		mtl_system_items_kfv item,
		po_vendor_sites pvs
	WHERE 	pce.supplier_id = l_supplier_id
	AND	pce.period_type = l_period_type
	AND 	pce.period_name = l_period_name
	AND	hr.organization_id (+)= pce.oper_unit_id
	AND	fu.user_id (+)= pce.evaluated_by
	AND	cat.category_id  (+)= pce.category_id
	AND 	item.inventory_item_id (+)= pce.item_id
	AND	item.organization_id (+)= pce.org_id
	AND 	pvs.vendor_site_id (+)= pce.supplier_site_id
	AND 	pce.category_id = l_category_id
	ORDER BY pce.evaluation_id;

elsif (l_oper_unit_id is not null) and (l_category_id is not null) then
  OPEN c_evaluation FOR
	SELECT 	pce.evaluation_id,
		pvs.vendor_site_code,
		hr.name,
		cat.concatenated_segments,
		item.concatenated_segments,
		fu.user_name,
		pce.creation_date,
		pce.last_update_date
	FROM 	poa_cm_evaluation pce,
		hr_operating_units hr,
		fnd_user fu,
		mtl_categories_kfv cat,
		mtl_system_items_kfv item,
		po_vendor_sites pvs
	WHERE 	pce.supplier_id = l_supplier_id
	AND	pce.period_type = l_period_type
	AND 	pce.period_name = l_period_name
	AND	hr.organization_id (+)= pce.oper_unit_id
	AND	fu.user_id (+)= pce.evaluated_by
	AND	cat.category_id  (+)= pce.category_id
	AND 	item.inventory_item_id (+)= pce.item_id
	AND	item.organization_id (+)= pce.org_id
	AND 	pvs.vendor_site_id (+)= pce.supplier_site_id
	AND 	pce.oper_unit_id = l_oper_unit_id
	AND 	pce.category_id = l_category_id
	ORDER BY pce.evaluation_id;

else
  OPEN c_evaluation FOR
	SELECT 	pce.evaluation_id,
		pvs.vendor_site_code,
		hr.name,
		cat.concatenated_segments,
		item.concatenated_segments,
		fu.user_name,
		pce.creation_date,
		pce.last_update_date
	FROM 	poa_cm_evaluation pce,
		hr_operating_units hr,
		fnd_user fu,
		mtl_categories_kfv cat,
		mtl_system_items_kfv item,
		po_vendor_sites pvs
	WHERE 	pce.supplier_id = l_supplier_id
	AND	pce.period_type = l_period_type
	AND 	pce.period_name = l_period_name
	AND	hr.organization_id (+)= pce.oper_unit_id
	AND	fu.user_id (+)= pce.evaluated_by
	AND	cat.category_id  (+)= pce.category_id
	AND 	item.inventory_item_id (+)= pce.item_id
	AND	item.organization_id (+)= pce.org_id
	AND 	pvs.vendor_site_id (+)= pce.supplier_site_id
	ORDER BY pce.evaluation_id;
end if;

LOOP

	FETCH c_evaluation into v_eval_id, v_supplier_site, v_oper_unit, v_commodity, v_item, v_evaluator, v_creation_date, v_last_update_date;
	EXIT WHEN c_evaluation%NOTFOUND;

 	v_counter := v_counter + 1;

	if ((v_counter mod 2) = 0) THEN
      		htp.p('<TR BGCOLOR=''#ffffff'' >');
    	else
      		htp.p('<TR BGCOLOR=''#ffffff'' >');
    	end if;

	if (v_counter = 1) THEN

		htp.p('<TD ALIGN=CENTER BGCOLOR=''#FFFFFF''><font class=tabledata> <input type="RADIO" name="POA_CM_EVALUATION_ID" value=' || v_eval_id || ' checked></font></td>');
	else
		htp.p('<TD ALIGN=CENTER BGCOLOR=''#FFFFFF''><font class=tabledata> <input type="RADIO" name="POA_CM_EVALUATION_ID" value=' || v_eval_id || '></font></td>');
	end if;

	htp.p('
		<TD ALIGN=left><font class=tabledata>' || v_oper_unit || '&nbsp</font></td>
		<TD ALIGN=left><font class=tabledata>' || v_commodity || '&nbsp</font></td>
		<TD ALIGN=left><font class=tabledata>' || v_item || '</font>&nbsp</td>
		<TD ALIGN=left><font class=tabledata>' || v_supplier_site || '&nbsp</font></td>
		<TD ALIGN=left><font class=tabledata>' || v_evaluator || '&nbsp</font></td>
		<TD ALIGN=left><font class=tabledata>' || v_creation_date || '&nbsp</font></td>
		<TD ALIGN=left><font class=tabledata>' || v_last_update_date || '&nbsp</font></td>
		</tr>
');

END LOOP;
CLOSE c_evaluation;

htp.p('</table></td></tr>');

if (v_counter = 0) then
	htp.p('<tr><td align=center><b>Your query returned no records.</b></td></tr>');
end if;

  htp.p('</table>');

if (v_counter = 0) then
	PrintBottomButtons(l_language, 3);
else
  	PrintBottomButtons(l_language, 2);
end if;

  htp.bodyClose;
  htp.htmlClose;

END query_evals;

END poa_cm_eval_scores_icx;

/
