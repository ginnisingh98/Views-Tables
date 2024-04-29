--------------------------------------------------------
--  DDL for Package Body POA_CM_EVALUATION_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_CM_EVALUATION_ICX" AS
/* $Header: POACMHDB.pls 115.9 2003/04/29 21:46:29 rvickrey ship $ */

TYPE t_attribute_record IS RECORD (
  attribute_name  VARCHAR2(30),
  attribute_value VARCHAR2(1000)
);

TYPE t_attribute_table IS TABLE OF t_attribute_record INDEX BY BINARY_INTEGER;

g_attribute_table t_attribute_table;

PROCEDURE PrintCSS;
PROCEDURE SetAttributeTable(poa_cm_custom_measure_code IN VARCHAR2,
                            poa_cm_custom_measure      IN VARCHAR2,
                            poa_cm_period_type         IN VARCHAR2,
                            poa_cm_user_period_type    IN VARCHAR2,
                            poa_cm_period_name         IN VARCHAR2,
                            poa_cm_supplier_id         IN VARCHAR2,
                            poa_cm_supplier            IN VARCHAR2,
                            poa_cm_supplier_site_id    IN VARCHAR2,
                            poa_cm_supplier_site       IN VARCHAR2,
                            poa_cm_category_id         IN VARCHAR2,
                            poa_cm_commodity           IN VARCHAR2,
                            poa_cm_item_id             IN VARCHAR2,
                            poa_cm_item                IN VARCHAR2,
                            poa_cm_comments            IN VARCHAR2,
                            poa_cm_evaluated_by_id     IN VARCHAR2,
                            poa_cm_evaluated_by        IN VARCHAR2,
                            poa_cm_org_id              IN VARCHAR2,
                            poa_cm_oper_unit_id        IN VARCHAR2,
                            poa_cm_operating_unit      IN VARCHAR2,
			    poa_cm_submit_type 	       IN VARCHAR2,
			    poa_cm_evaluation_id       IN VARCHAR2);

FUNCTION GetAttributeValue(p_attribute_name  IN VARCHAR2,
                           p_start_index     IN NUMBER) RETURN VARCHAR2;

PROCEDURE PrintHeaderPageFields(p_language IN VARCHAR2);

PROCEDURE PrintBottomButtons(p_language IN VARCHAR2);

PROCEDURE header_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
                      poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
                      poa_cm_period_type         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
                      poa_cm_period_name         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_id         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier            IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
                      poa_cm_category_id         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_commodity           IN VARCHAR2 DEFAULT NULL,
                      poa_cm_item_id             IN VARCHAR2 DEFAULT NULL,
                      poa_cm_item                IN VARCHAR2 DEFAULT NULL,
                      poa_cm_comments            IN VARCHAR2 DEFAULT NULL,
                      poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
                      poa_cm_evaluated_by        IN VARCHAR2 DEFAULT NULL,
                      poa_cm_org_id              IN VARCHAR2 DEFAULT NULL,
                      poa_cm_oper_unit_id        IN VARCHAR2 DEFAULT NULL,
                      poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
		      poa_cm_submit_type	 IN VARCHAR2 DEFAULT NULL,
		      poa_cm_evaluation_id	 IN VARCHAR2 DEFAULT NULL,
                      error_msg                  IN VARCHAR2 DEFAULT NULL
) IS
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_oper_unit_id NUMBER;

  l_employee_id NUMBER := null;
  l_emp_name    VARCHAR2(240) := null;

  l_cm_code        VARCHAR2(25) := null;
  l_custom_measure VARCHAR2(25) := null;

  l_period_type      VARCHAR2(15) := null;
  l_user_period_type VARCHAR2(15) := null;
  l_period_name      VARCHAR2(15) := null;

  l_operating_unit VARCHAR2(60) := null;

BEGIN

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  BEGIN

    select
      nvl(poa_cm_evaluated_by_id, user_id),
      nvl(poa_cm_evaluated_by, user_name)
    into
      l_employee_id,
      l_emp_name
    from
      fnd_user
    where
      user_id = l_user_id;

    select
      nvl(poa_cm_custom_measure_code, lookup_code),
      nvl(poa_cm_custom_measure, displayed_field)
    into
     l_cm_code,
     l_custom_measure
    from
      po_lookup_codes
    where
      lookup_type = 'CUSTOM MEASURE' and
      lookup_code = 'CUSTOMER SATISFACTION';

    select nvl(poa_cm_period_type, t.period_type),
           nvl(poa_cm_user_period_type, t.user_period_type),
           nvl(poa_cm_period_name, p.period_name)
      into l_period_type,
           l_user_period_type,
           l_period_name
      from gl_periods p,
           gl_period_types t,
           financials_system_parameters f,
           gl_sets_of_books b
     where f.set_of_books_id = b.set_of_books_id
       and b.accounted_period_type = p.period_type
       and b.period_set_name = p.period_set_name
       and p.period_type = t.period_type
       and trunc(sysdate) >= trunc(p.start_date)
       and trunc(sysdate) <= trunc(p.end_date);

  EXCEPTION
    when others then
      null;
  END;

  BEGIN
     select nvl(poa_cm_operating_unit, name)
       into l_operating_unit
       from hr_operating_units
      where organization_id = l_org_id;
  EXCEPTION
    when others then
      null;
  END;

  BEGIN
       select decode(l_operating_unit, name, l_org_id, nvl(poa_cm_oper_unit_id, to_number(NULL)))
       into l_oper_unit_id
       from hr_operating_units
       where organization_id = l_org_id;
  EXCEPTION
    when others then
      null;
  END;

  htp.htmlOpen;
  htp.title('Survey Response');

  htp.headOpen;
  icx_util.copyright;

  PrintCSS;

  js.scriptOpen;

  icx_util.LOVscript;

----- Begin Javascript -----

  htp.p('

function submitDoc(submit_type)
{
  var f = document.POA_CM_EVALUATION_R;

  if (submit_type == "Update")
    f.POA_CM_SUBMIT_TYPE.value = "Update";
  else if (submit_type == "Next")
    f.POA_CM_SUBMIT_TYPE.value = "Next";

  if (f.POA_CM_USER_PERIOD_TYPE.value == "")
    alert(''Please enter a valid period type.'');
  else if (f.POA_CM_PERIOD_NAME.value == "")
    alert(''Please enter a valid period name.'');
  else if (f.POA_CM_SUPPLIER.value == "")
    alert(''Please enter a valid supplier.'');
  else
    document.POA_CM_EVALUATION_R.submit();
}

function call_LOV(c_attribute_code)
{
  var f = document.POA_CM_EVALUATION_R;
  var c_js_where_clause = "";

  if (c_attribute_code == "POA_CM_PERIOD_NAME")
  {
    if (f.POA_CM_PERIOD_TYPE.value != "")
      c_js_where_clause = " PERIOD_TYPE = ''" + f.POA_CM_PERIOD_TYPE.value.replace(/''/g,"''''") + "''";
    else
      c_js_where_clause = " USER_PERIOD_TYPE = ''" + f.POA_CM_USER_PERIOD_TYPE.value.replace(/''/g,"''''") + "''";
  }
  else if (c_attribute_code == "POA_CM_SUPPLIER_SITE")
  {
    if (f.POA_CM_SUPPLIER_ID.value !="")
      c_js_where_clause = " VENDOR_ID = " + f.POA_CM_SUPPLIER_ID.value.replace(/''/g,"''''") +
                          " AND ORG_ID = " + f.POA_CM_ORG_ID.value.replace(/''/g,"''''");
    else
      c_js_where_clause = " VENDOR_NAME = ''" + f.POA_CM_SUPPLIER.value.replace(/''/g,"''''") +
                          "'' AND ORG_ID = " + f.POA_CM_ORG_ID.value.replace(/''/g,"''''");
  }
  else if (c_attribute_code == "POA_CM_OPERATING_UNIT")
  {
    if (f.POA_CM_SUPPLIER_SITE.value != "")
      if (f.POA_CM_SUPPLIER_SITE_ID.value != "")
        if (f.POA_CM_SUPPLIER_ID.value != "")
          c_js_where_clause = " ORG_ID in (select ORG_ID  from POA_CM_SITE_LOV_V where " +
                              " VENDOR_ID = " + f.POA_CM_SUPPLIER_ID.value.replace(/''/g,"''''") + " AND " +
                              " VENDOR_SITE_ID = " + f.POA_CM_SUPPLIER_SITE_ID.value.replace(/''/g,"''''") + ")";
        else
          c_js_where_clause = " ORG_ID in (select ORG_ID  from POA_CM_SITE_LOV_V where " +
                              " VENDOR_NAME = ''" + f.POA_CM_SUPPLIER.value.replace(/''/g,"''''") + "'' AND " +
                              " VENDOR_SITE_ID = " + f.POA_CM_SUPPLIER_SITE_ID.value.replace(/''/g,"''''") + ")";
      else
        if (f.POA_CM_SUPPLIER_ID.value != "")
          c_js_where_clause = " ORG_ID in (select ORG_ID  from POA_CM_SITE_LOV_V where " +
                              " VENDOR_ID = " + f.POA_CM_SUPPLIER_ID.value.replace(/''/g,"''''") + " AND " +
                              " VENDOR_SITE_CODE = ''" + f.POA_CM_SUPPLIER_SITE.value.replace(/''/g,"''''") + "'')";
        else
          c_js_where_clause = " ORG_ID in (select ORG_ID  from POA_CM_SITE_LOV_V where " +
                              " VENDOR_NAME = ''" + f.POA_CM_SUPPLIER.value.replace(/''/g,"''''") + "'' AND " +
                              " VENDOR_SITE_CODE = ''" + f.POA_CM_SUPPLIER_SITE.value.replace(/''/g,"''''") + "'')";

  }
  else if (c_attribute_code == "POA_CM_ITEM")
  {
    if (f.POA_CM_COMMODITY.value != "")
      if (f.POA_CM_CATEGORY_ID.value != "")
        c_js_where_clause = " ORGANIZATION_ID in (select INVENTORY_ORGANIZATION_ID from FINANCIALS_SYSTEM_PARAMETERS)" +
                            " AND CATEGORY_ID = " + f.POA_CM_CATEGORY_ID.value.replace(/''/g,"''''");
      else
        c_js_where_clause = " ORGANIZATION_ID in (select INVENTORY_ORGANIZATION_ID from FINANCIALS_SYSTEM_PARAMETERS)" +
                            " AND COMMODITY = ''" + f.POA_CM_COMMODITY.value.replace(/''/g,"''''") + "''";
    else
      c_js_where_clause = " ORGANIZATION_ID in (select INVENTORY_ORGANIZATION_ID from FINANCIALS_SYSTEM_PARAMETERS)";
  }

  c_js_where_clause = escape(c_js_where_clause, 1);

  LOV("201", c_attribute_code, "201", "POA_CM_EVALUATION_R", "POA_CM_EVALUATION_R", "", "", c_js_where_clause);

  reset_hidden(c_attribute_code);
}

function reset_hidden(c_attribute_code)
{
  var f = document.POA_CM_EVALUATION_R;

  if (c_attribute_code == "POA_CM_USER_PERIOD_TYPE")
  {
    f.POA_CM_PERIOD_TYPE.value = "";
    f.POA_CM_PERIOD_NAME.value = "";
  }
  else if (c_attribute_code == "POA_CM_SUPPLIER")
  {
    f.POA_CM_SUPPLIER_ID.value = "";
    f.POA_CM_SUPPLIER_SITE_ID.value = "";
    f.POA_CM_SUPPLIER_SITE.value = "";
  }
  else if (c_attribute_code == "POA_CM_SUPPLIER_SITE")
  {
    f.POA_CM_SUPPLIER_SITE_ID.value = "";
    f.POA_CM_OPER_UNIT_ID.value = "";
    f.POA_CM_OPERATING_UNIT.value = "";
  }
  else if (c_attribute_code == "POA_CM_OPERATING_UNIT")
  {
    f.POA_CM_OPER_UNIT_ID.value = "";
  }
  else if (c_attribute_code == "POA_CM_COMMODITY")
  {
    f.POA_CM_CATEGORY_ID.value = "";
    f.POA_CM_ITEM_ID.value = "";
    f.POA_CM_ITEM.value = "";
  }
  else if (c_attribute_code == "POA_CM_ITEM")
  {
    f.POA_CM_ITEM_ID.value = "";
  }
  else if (c_attribute_code == "POA_CM_EVALUATED_BY")
  {
    f.POA_CM_EVALUATED_BY_ID.value = "";
  }
}


function check_read_only(c_attribute_code)
{
  var f = document.POA_CM_EVALUATION_R;

  if (c_attribute_code == "POA_CM_CUSTOM_MEASURE")
  {
    f.POA_CM_CUSTOM_MEASURE.blur();
  }
}

function cancelAction()
{
  var f = document.POA_CM_EVALUATION_R;

   f.POA_CM_PERIOD_TYPE.value = "";
   f.POA_CM_USER_PERIOD_TYPE.value = "";
   f.POA_CM_PERIOD_NAME.value = "";
   f.POA_CM_SUPPLIER_ID.value = "";
   f.POA_CM_SUPPLIER.value = "";
   f.POA_CM_SUPPLIER_SITE_ID.value = "";
   f.POA_CM_SUPPLIER_SITE.value = "";
   f.POA_CM_CATEGORY_ID.value = "";
   f.POA_CM_COMMODITY.value = "";
   f.POA_CM_ITEM_ID.value = "";
   f.POA_CM_ITEM.value = "";
   f.POA_CM_COMMENTS.value = "";
   f.POA_CM_EVALUATED_BY_ID.value = "";
   f.POA_CM_EVALUATED_BY.value = "";
   f.POA_CM_OPER_UNIT_ID.value = "";
   f.POA_CM_OPERATING_UNIT.value = "";
}

function loadPage(error_msg, emp_id, emp_name, cm_code, cm, p_type, u_type, p_name, org_id, oper_unit_id, oper)
{
  var f = document.POA_CM_EVALUATION_R;

  f.POA_CM_EVALUATED_BY_ID.value = emp_id;
  f.POA_CM_EVALUATED_BY.value = emp_name;

  f.POA_CM_CUSTOM_MEASURE_CODE.value = cm_code;
  f.POA_CM_CUSTOM_MEASURE.value = cm;

  f.POA_CM_PERIOD_TYPE.value = p_type;
  f.POA_CM_USER_PERIOD_TYPE.value = u_type;
  f.POA_CM_PERIOD_NAME.value = p_name;

  f.POA_CM_OPER_UNIT_ID.value = oper_unit_id;
  f.POA_CM_OPERATING_UNIT.value = oper;

  if (error_msg.length > 0)
    alert(error_msg);
}

  ');

----- End Javascript -----

  js.scriptClose;

htp.p('<LINK REL="stylesheet" HREF="/OA_HTML/bismarli.css">');

  htp.headClose;

  htp.bodyOpen;

htp.p('<BODY bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000" onLoad="javascript:loadPage(');
htp.p('''' || ICX_UTIL.replace_quotes(error_msg) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(to_char(l_employee_id)) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_emp_name) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_cm_code) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_custom_measure) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_period_type) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_user_period_type) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_period_name) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(to_char(l_org_id)) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(to_char(l_oper_unit_id)) || ''',');
htp.p('''' || ICX_UTIL.replace_quotes(l_operating_unit) || ''')">');

htp.p('<FORM NAME="POA_CM_EVALUATION_R" ACTION="'||l_script_name||'/POA_CM_EVAL_SCORES_ICX.redirect_page" METHOD="POST">');

htp.p('<INPUT NAME="POA_CM_SUBMIT_TYPE" TYPE="hidden" value ="">');
htp.p('<INPUT NAME="POA_CM_EVALUATION_ID" TYPE="hidden" value ="">');

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
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">Create/Find Survey Response</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">Enter the criteria to either find a survey response or to create a new one.</font></td></tr>
        </table>
</td></tr>
</table>

  ');

  htp.p('<table width=100% bgcolor=#FFFFFF cellpadding=1 cellspacing=0 border=0>');

  SetAttributeTable(poa_cm_custom_measure_code=>poa_cm_custom_measure_code,
                    poa_cm_custom_measure=>poa_cm_custom_measure,
                    poa_cm_period_type=>poa_cm_period_type,
                    poa_cm_user_period_type=>poa_cm_user_period_type,
                    poa_cm_period_name=>poa_cm_period_name,
                    poa_cm_supplier_id=>poa_cm_supplier_id,
                    poa_cm_supplier=>poa_cm_supplier,
                    poa_cm_supplier_site_id=>poa_cm_supplier_site_id,
                    poa_cm_supplier_site=>poa_cm_supplier_site,
                    poa_cm_category_id=>poa_cm_category_id,
                    poa_cm_commodity=>poa_cm_commodity,
                    poa_cm_item_id=>poa_cm_item_id,
                    poa_cm_item=>poa_cm_item,
                    poa_cm_comments=>poa_cm_comments,
                    poa_cm_evaluated_by_id=>poa_cm_evaluated_by_id,
                    poa_cm_evaluated_by=>poa_cm_evaluated_by,
                    poa_cm_org_id=>l_org_id,
                    poa_cm_oper_unit_id=>poa_cm_oper_unit_id,
                    poa_cm_operating_unit=>poa_cm_operating_unit,
 		    poa_cm_submit_type=>poa_cm_submit_type,
		    poa_cm_evaluation_id=>poa_cm_evaluation_id);

PrintHeaderPageFields(l_language);

 PrintBottomButtons(l_language);

  htp.bodyClose;
  htp.htmlClose;

END header_page;

PROCEDURE PrintCSS IS
BEGIN

  htp.p('<STYLE TYPE="text/css">');
  htp.p('<!--');
  htp.p('font.pagetitle');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-style: italic;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 14pt;}');
  htp.p('font.itemtitle');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: white;');
  htp.p('                    font-size: 14pt;}');
  htp.p('font.bartitle');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: black;');
  htp.p('                    font-weight: bold;');
  htp.p('                    font-size: 8pt;}');
  htp.p('font.containertitle');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-style: italic;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: #cccccc;');
  htp.p('                    font-size: 14pt;}');
  htp.p('font.graytab');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: black;');
  htp.p('                    text-decoration: none;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.purpletab');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: white;');
  htp.p('                    text-decoration: none;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.promptblack');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: black;');
  htp.p('                    text-decoration: none;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.helptext');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-style: italic;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.helptitle ');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-style: italic;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 14pt;}');
  htp.p('font.promptwhite');
  htp.p('                   {font-family: sans-serif;');
  htp.p('                    font-face: arial;');
  htp.p('                    color: white;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.datablack');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.fielddata ');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.tablefielddata ');
  htp.p('                   {font-family: "arial narrow", sans-serif;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.tabledata ');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: black;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.button');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: black;');
  htp.p('                    text-decoration: none;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.link');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: blue;');
  htp.p('                    text-decoration: underline;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.linkbold');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    font-weight: bold;');
  htp.p('                    color: blue;');
  htp.p('                    text-decoration: underline;');
  htp.p('                    font-size: 10pt;}');
  htp.p('font.dropdownmenu');
  htp.p('                   {font-family: Arial, sans-serif;');
  htp.p('                    color: #003366;');
  htp.p('                    font-style: italic;');
  htp.p('                    font-size: 16pt;}');
  htp.p('-->');
  htp.p('</STYLE>');

END PrintCSS;

PROCEDURE SetAttributeTable(poa_cm_custom_measure_code IN VARCHAR2,
                            poa_cm_custom_measure      IN VARCHAR2,
                            poa_cm_period_type         IN VARCHAR2,
                            poa_cm_user_period_type    IN VARCHAR2,
                            poa_cm_period_name         IN VARCHAR2,
                            poa_cm_supplier_id         IN VARCHAR2,
                            poa_cm_supplier            IN VARCHAR2,
                            poa_cm_supplier_site_id    IN VARCHAR2,
                            poa_cm_supplier_site       IN VARCHAR2,
                            poa_cm_category_id         IN VARCHAR2,
                            poa_cm_commodity           IN VARCHAR2,
                            poa_cm_item_id             IN VARCHAR2,
                            poa_cm_item                IN VARCHAR2,
                            poa_cm_comments            IN VARCHAR2,
                            poa_cm_evaluated_by_id     IN VARCHAR2,
                            poa_cm_evaluated_by        IN VARCHAR2,
                            poa_cm_org_id              IN VARCHAR2,
                            poa_cm_oper_unit_id        IN VARCHAR2,
                            poa_cm_operating_unit      IN VARCHAR2,
			    poa_cm_submit_type	       IN VARCHAR2,
			    poa_cm_evaluation_id       IN VARCHAR2
) IS

BEGIN
  IF (g_attribute_table.COUNT > 0) THEN
    g_attribute_table.DELETE;
  END IF;
  g_attribute_table(1).attribute_name := 'POA_CM_CUSTOM_MEASURE_CODE';
  g_attribute_table(1).attribute_value := poa_cm_custom_measure_code;
  g_attribute_table(2).attribute_name := 'POA_CM_CUSTOM_MEASURE';
  g_attribute_table(2).attribute_value := poa_cm_custom_measure;
  g_attribute_table(3).attribute_name := 'POA_CM_PERIOD_TYPE';
  g_attribute_table(3).attribute_value := poa_cm_period_type;
  g_attribute_table(4).attribute_name := 'POA_CM_USER_PERIOD_TYPE';
  g_attribute_table(4).attribute_value := poa_cm_user_period_type;
  g_attribute_table(5).attribute_name := 'POA_CM_PERIOD_NAME';
  g_attribute_table(5).attribute_value := poa_cm_period_name;
  g_attribute_table(6).attribute_name := 'POA_CM_SUPPLIER_ID';
  g_attribute_table(6).attribute_value := poa_cm_supplier_id;
  g_attribute_table(7).attribute_name := 'POA_CM_SUPPLIER';
  g_attribute_table(7).attribute_value := poa_cm_supplier;
  g_attribute_table(8).attribute_name := 'POA_CM_SUPPLIER_SITE_ID';
  g_attribute_table(8).attribute_value := poa_cm_supplier_site_id;
  g_attribute_table(9).attribute_name := 'POA_CM_SUPPLIER_SITE';
  g_attribute_table(9).attribute_value := poa_cm_supplier_site;
  g_attribute_table(10).attribute_name := 'POA_CM_ORG_ID';
  g_attribute_table(10).attribute_value := poa_cm_org_id;
  g_attribute_table(11).attribute_name := 'POA_CM_OPER_UNIT_ID';
  g_attribute_table(11).attribute_value := poa_cm_oper_unit_id;
  g_attribute_table(12).attribute_name := 'POA_CM_OPERATING_UNIT';
  g_attribute_table(12).attribute_value := poa_cm_operating_unit;
  g_attribute_table(13).attribute_name := 'POA_CM_CATEGORY_ID';
  g_attribute_table(13).attribute_value := poa_cm_category_id;
  g_attribute_table(14).attribute_name := 'POA_CM_COMMODITY';
  g_attribute_table(14).attribute_value := poa_cm_commodity;
  g_attribute_table(15).attribute_name := 'POA_CM_ITEM_ID';
  g_attribute_table(15).attribute_value := poa_cm_item_id;
  g_attribute_table(16).attribute_name := 'POA_CM_ITEM';
  g_attribute_table(16).attribute_value := poa_cm_item;
  g_attribute_table(17).attribute_name := 'POA_CM_COMMENTS';
  g_attribute_table(17).attribute_value := poa_cm_comments;
  g_attribute_table(18).attribute_name := 'POA_CM_EVALUATED_BY_ID';
  g_attribute_table(18).attribute_value := poa_cm_evaluated_by_id;
  g_attribute_table(19).attribute_name := 'POA_CM_EVALUATED_BY';
  g_attribute_table(19).attribute_value := poa_cm_evaluated_by;
  g_attribute_table(20).attribute_name := 'POA_CM_SUBMIT_TYPE';
  g_attribute_table(20).attribute_value := poa_cm_submit_type;
  g_attribute_table(21).attribute_name := 'POA_CM_EVALUATION_ID';
  g_attribute_table(21).attribute_value := poa_cm_evaluation_id;
END SetAttributeTable;

FUNCTION GetAttributeValue(p_attribute_name  IN VARCHAR2,
                           p_start_index     IN NUMBER) RETURN VARCHAR2 IS
  l_start_index NUMBER;
  l_index NUMBER;
  l_wrapped BOOLEAN;
BEGIN
  IF (p_attribute_name IS NULL OR g_attribute_table.COUNT <= 0) THEN
    RETURN NULL;
  END IF;
  l_start_index := NVL(p_start_index, g_attribute_table.FIRST);
  IF (g_attribute_table.EXISTS(p_start_index) AND
      g_attribute_table(p_start_index).attribute_name = p_attribute_name) THEN
    RETURN g_attribute_table(p_start_index).attribute_value;
  END IF;
  l_index := g_attribute_table.NEXT(p_start_index);
  l_wrapped := FALSE;
  WHILE (l_index IS NOT NULL AND NOT (l_wrapped AND l_index >= p_start_index)) LOOP
    IF (g_attribute_table(l_index).attribute_name = p_attribute_name) THEN
      RETURN g_attribute_table(p_start_index).attribute_value;
    END IF;

    l_index := g_attribute_table.NEXT(l_index);
    IF (l_index IS NULL) THEN
      l_index := g_attribute_table.FIRST;
      l_wrapped := TRUE;
    END IF;
  END LOOP;

  RETURN NULL;

END GetAttributeValue;


PROCEDURE PrintHeaderPageFields(p_language IN VARCHAR2) IS
  l_index NUMBER;
  l_count NUMBER;
  l_where_clause VARCHAR2(240) := null;
  temp    VARCHAR2(30);
BEGIN
  ak_query_pkg.exec_query(p_parent_region_appl_id=>201,
                          p_parent_region_code=>'POA_CM_EVALUATION_R',
                          p_responsibility_id=>icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id=>icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents=>'F',
                          p_return_children=>'F');

  l_count := 0;
  l_index := ak_query_pkg.g_items_table.FIRST;
  WHILE (l_index IS NOT NULL) LOOP
    l_count := l_count + 1;
    IF (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y') AND
       (ak_query_pkg.g_items_table(l_index).secured_column = 'F') THEN
      IF (ak_query_pkg.g_items_table(l_index).item_style = 'HIDDEN') THEN
        htp.p('<INPUT NAME="'||
              ak_query_pkg.g_items_table(l_index).attribute_code||
              '" TYPE="hidden" VALUE="'||
              GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                p_start_index=>l_count)||
              '">');
      ELSIF (ak_query_pkg.g_items_table(l_index).item_style = 'TEXT') THEN
        htp.p('<TR>');
        htp.p('<TD VALIGN=CENTER ALIGN=RIGHT WIDTH=30%BGCOLOR=#FFFFFF>'||
              '<FONT CLASS=promptblack>'||
              ak_query_pkg.g_items_table(l_index).attribute_label_long||
              '</FONT>&nbsp;</TD>');
        htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=70%BGCOLOR=#FFFFFF>'||
              '<FONT CLASS=datablack>');
        htp.p('<INPUT NAME="'||ak_query_pkg.g_items_table(l_index).attribute_code||'" TYPE="text"' ||
              ' onChange="javascript:reset_hidden(''' || ak_query_pkg.g_items_table(l_index).attribute_code || ''')"' ||
              ' onFocus="javascript:check_read_only(''' || ak_query_pkg.g_items_table(l_index).attribute_code || ''')"' ||
              ' VALUE="'|| GetAttributeValue(p_attribute_name=>ak_query_pkg.g_items_table(l_index).attribute_code,
                                            p_start_index=>l_count)||
              '" SIZE='||ak_query_pkg.g_items_table(l_index).display_value_length||' MAXLENGTH='||ak_query_pkg.g_items_table(l_index).attribute_value_length||'></FONT>&nbsp');

        IF (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
            ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT NULL) THEN
            htp.p('<A HREF="javascript:call_LOV('''|| ak_query_pkg.g_items_table(l_index).attribute_code || ''')"' ||
--            ' onMouseOver="window.status=''List of Values'';return true"' ||
            '><IMG SRC="/OA_MEDIA/FNDILOV.gif" BORDER=0 align=absmiddle></A></TD>');

        END IF;

        htp.p('</TD>');
        htp.p('<TD BGCOLOR=#FFFFFF>&nbsp;</TD>');
        htp.p('</TR>');

      ELSE

        htp.p('<!-- '||ak_query_pkg.g_items_table(l_index).attribute_code||
              ' - '||ak_query_pkg.g_items_table(l_index).item_style||' -->');

      END IF;

    END IF;

    l_index := ak_query_pkg.g_items_table.NEXT(l_index);

  END LOOP;

htp.p('</TABLE>');

END PrintHeaderPageFields;

PROCEDURE PrintBottomButtons(p_language IN VARCHAR2) IS
BEGIN

htp.p('
<table width=100% border=0 cellspacing=0 cellpadding=15>
  <tr>
    <td>
      <table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr>
          <td width=604>&nbsp;</td>
          <td rowspan=2 valign=bottom width=12><img src=/OA_MEDIA/bisslghr.gif width=12
height=14></td>
        </tr>
        <tr>
          <td bgcolor=#CCCC99 height=1><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td>
        </tr>
        <tr>
          <td height=5><img src=/OA_MEDIA/bisspace.gif width=1 height=1></td>
        </tr>

        <tr>
          <td align="right"> &nbsp; <span class="OraALinkText"><span class="OraALinkText">
           <A href=OracleNavigate.Responsibility onMouseOver="window.status=''Cancel'';return true"><img src=/OA_MEDIA/poacancl.gif border="0"></a>&nbsp;&nbsp;&nbsp;
	   <A href="javascript:submitDoc(''Update'')" onMouseOver="window.status=''Find Survey'';return true"><img src=/OA_MEDIA/poafind.gif border="0"></a>&nbsp;&nbsp;&nbsp;
           <A href="javascript:submitDoc(''Next'')" onMouseOver="window.status=''New Survey'';return true"><img src=/OA_MEDIA/poanew.gif border="0"></a>
           </span></span></td>
        </tr>

      </table>
      </td>
          </tr>
        </table>
');


END PrintBottomButtons;


END poa_cm_evaluation_icx;

/
