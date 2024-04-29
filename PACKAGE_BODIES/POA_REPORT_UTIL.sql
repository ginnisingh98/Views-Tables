--------------------------------------------------------
--  DDL for Package Body POA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_REPORT_UTIL" AS
/* $Header: poarutlb.pls 115.12 2003/01/23 18:59:15 rvickrey ship $ */

PROCEDURE Build_OrderDates(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_ORDER_DATES');
  p_param(p_index).Value := htf.formText('P_FDATE', NULL, NULL,
    to_char(add_months(trunc(sysdate), -12) + 1, icx_sec.g_date_format));
  p_param(p_index).Value := p_param(p_index).Value || ' - ' ||
    htf.formText('P_TDATE', NULL, NULL, to_char(trunc(sysdate),
    icx_sec.g_date_format));
END Build_OrderDates;

PROCEDURE Build_ReportingDates(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_REPORTING_DATES');
  p_param(p_index).Value := htf.formText('P_FDATE', NULL, NULL,
    to_char(add_months(trunc(sysdate), -12) + 1, icx_sec.g_date_format));
  p_param(p_index).Value := p_param(p_index).Value || ' - ' ||
    htf.formText('P_TDATE', NULL, NULL, to_char(trunc(sysdate),
    icx_sec.g_date_format));
END Build_ReportingDates;

PROCEDURE Build_SupplierItem(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_ITEM');
  p_param(p_index).Value := htf.formText('POA_BIS_ITEM_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_ITEM_NAME'', ''201'',
     ''POA_BIS_SUPPERF_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_ITEM_ID');
END Build_SupplierItem;

PROCEDURE Build_PrefSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_PREF_SUPPLIER');
  p_param(p_index).Value := htf.formText('POA_BIS_PREF_SUPP_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_PREF_SUPP_NAME'', ''201'',
     ''POA_BIS_SUPPERF_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_PREF_SUPP_ID');
END Build_PrefSupplier;

PROCEDURE Build_ConsSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_CONS_SUPPLIER');
  p_param(p_index).Value := htf.formText('POA_BIS_CONS_SUPP_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_CONS_SUPP_NAME'', ''201'',
     ''POA_BIS_SUPPERF_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_CONS_SUPP_ID');
END Build_ConsSupplier;

PROCEDURE Build_HiddenStartDate(p_start_date IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
--  p_param(p_index).Label := 'Reporting Start Date';
  p_param(p_index).Action := p_param(p_index).Action ||
      htf.formHidden('P_FDATE', p_start_date);
END Build_HiddenStartDate;

PROCEDURE Build_HiddenEndDate(p_end_date IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
--  p_param(p_index).Label := 'Reporting End Date';
  p_param(p_index).Action := p_param(p_index).Action ||
      htf.formHidden('P_TDATE', p_end_date);
END Build_HiddenEndDate;

PROCEDURE Build_HiddenCurrency(p_currency_code IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
--  p_param(p_index).Label := 'Currency';
  p_param(p_index).Action := p_param(p_index).Action ||
      htf.formHidden('POA_BIS_CURRENCY', p_currency_code);
END Build_HiddenCurrency;

PROCEDURE Build_HiddenItem(p_item_id IN VARCHAR2,
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
--  p_param(p_index).Label := 'Item';
  p_param(p_index).Action := p_param(p_index).Action ||
      htf.formHidden('POA_BIS_ITEM_ID', p_item_id);
END Build_HiddenItem;

PROCEDURE Build_SupplierNum(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_SUPPLIER_NUM');
  p_param(p_index).Value := htf.formText('POA_BIS_SUPPLIER_NUM', NULL, NULL,
    to_char(3));
END Build_SupplierNum;

PROCEDURE Build_QualityCost(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_QUALITY_COST');
  p_param(p_index).Value := htf.formText('POA_BIS_QUALITY_COST', NULL, NULL,
    to_char(25));
END Build_QualityCost;

PROCEDURE Build_DeliveryCost(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_DELIVERY_COST');
  p_param(p_index).Value := htf.formText('POA_BIS_DELIVERY_COST', NULL, NULL,
    to_char(25));
END Build_DeliveryCost;

PROCEDURE Build_SupplierOrderBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_ORDER_BY');
  Build_Selection('POA_BIS_MEASURE',
  'SELECT poc.lookup_code, poc.displayed_field
  FROM po_lookup_codes poc
  WHERE poc.lookup_type = ''POA BIS REPORT OPTION''
  AND poc.lookup_code in (''DEFECTS'', ''EXCEPTIONS'', ''PRICE'', ''AMOUNT'', ''VOLUME'')
  ORDER BY poc.displayed_field', p_param(p_index).Value);

  p_param(p_index).Value := p_param(p_index).Value || ' ' ;

  Build_Selection('POA_BIS_SORT_CRITERIA',
  'SELECT poc.lookup_code, poc.displayed_field
  FROM po_lookup_codes poc
  WHERE poc.lookup_type = ''POA BIS REPORT OPTION''
  AND poc.lookup_code in (''HIGHEST'', ''LOWEST'')
  ORDER BY poc.displayed_field', p_param(p_index).Action);


END Build_SupplierOrderBy;

PROCEDURE Build_SavingsOperatingUnit(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
l_where_clause    VARCHAR2(1000);
l_return_status   VARCHAR2(1000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_region_code          VARCHAR2(30);
BEGIN

  IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
  -- Use region pointing to BIS lov restricted based on responsibilities
    l_region_code := 'POA_BIS_SAVINGS_RPT';
    BIS_UTILITIES_PUB.Retrieve_Where_Clause
    (p_user_id           => FND_GLOBAL.user_id,
     p_region_code       => 'BIS_OPERATING_UNIT',
     x_where_clause      => l_where_clause,
     x_return_status     => l_return_status,
     x_error_Tbl         => l_error_tbl);
  ELSE
  -- Use region pointing to unrestricted POA lov
    l_region_code := 'POA_BIS_SAVINGS_RPT_G';
    l_where_clause := NULL;
  END IF;

  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_OPERATING_UNIT');
  p_param(p_index).Value := htf.formText('POA_BIS_OPER_UNIT_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_OPER_UNIT_NAME'', ''201'',''' ||
     l_region_code || ''',''RPTPFORM'','''', '''', '''||l_where_clause ||''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_OPER_UNIT_ID');
END Build_SavingsOperatingUnit;

PROCEDURE Build_PPS_OperatingUnit(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
l_where_clause    VARCHAR2(1000);
l_return_status   VARCHAR2(1000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_region_code     VARCHAR2(30);
BEGIN

  IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
  -- Use region pointing to BIS lov restricted based on responsibilities
    l_region_code := 'POA_BIS_PPS_RPT';
    BIS_UTILITIES_PUB.Retrieve_Where_Clause
    (p_user_id           => FND_GLOBAL.user_id,
     p_region_code       => 'BIS_OPERATING_UNIT',
     x_where_clause      => l_where_clause,
     x_return_status     => l_return_status,
     x_error_Tbl         => l_error_tbl);
  ELSE
  -- Use unrestricted LOV
    l_region_code := 'POA_BIS_PPS_RPT_G';
    l_where_clause := NULL;
  END IF;

  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_OPERATING_UNIT');
  p_param(p_index).Value := htf.formText('POA_BIS_PPS_OPER_UNIT_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_PPS_OPER_UNIT_NAME'', ''201'',
     ''' || l_region_code || ''',''RPTPFORM'','''','''',''' ||
     l_where_clause || ''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_PPS_OPER_UNIT_ID');
END Build_PPS_OperatingUnit;

PROCEDURE Build_SavingsBuyer(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_BUYER');
  p_param(p_index).Value := htf.formText('POA_BIS_BUYER_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_BUYER_NAME'', ''201'',
     ''POA_BIS_SAVINGS_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_BUYER_ID');
END Build_SavingsBuyer;

PROCEDURE Build_SavingsCommodity(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_COMMODITY');
  p_param(p_index).Value := htf.formText('POA_BIS_COMMODITY_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_COMMODITY_NAME'', ''201'',
     ''POA_BIS_SAVINGS_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_COMMODITY_ID');
END Build_SavingsCommodity;

PROCEDURE Build_SavingsItem(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_ITEM');
  p_param(p_index).Value := htf.formText('POA_BIS_ITEM_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_ITEM_NAME'', ''201'',
     ''POA_BIS_SAVINGS_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_ITEM_ID');
END Build_SavingsItem;

PROCEDURE Build_SavingsSupplier(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_SUPPLIER');
  p_param(p_index).Value := htf.formText('POA_BIS_SUPPLIER_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_SUPPLIER_NAME'', ''201'',
     ''POA_BIS_SAVINGS_RPT'',''RPTPFORM'','''','''','''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_SUPPLIER_ID');
END Build_SavingsSupplier;

PROCEDURE Build_KPIPeriodType(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_PERIOD_TYPE');
  Build_Selection('POA_BIS_PERIOD_TYPE',
  'SELECT distinct gpt.period_type, gpt.user_period_type
  FROM gl_period_types gpt, gl_periods glp
  WHERE glp.period_set_name = (SELECT sob.period_set_name
  FROM gl_sets_of_books sob
  WHERE sob.set_of_books_id =
    to_number(fnd_profile.value_wnps(''GL_SET_OF_BKS_ID'')))
  AND glp.period_type = gpt.period_type
  AND glp.adjustment_period_flag = ''N''
  order by gpt.user_period_type', p_param(p_index).Value);
END Build_KPIPeriodType;

PROCEDURE Build_KPI_2PeriodType(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label := FND_MESSAGE.get_string('POA', 'POA_VIEW_BY');
  Build_Selection('POA_BIS_PERIOD_TYPE2',
  'SELECT FND_MESSAGE.get_string(''PO'',''POA_OPERATING_UNIT''),
   FND_MESSAGE.get_string(''PO'',''POA_OPERATING_UNIT'')
   FROM dual UNION ALL
   SELECT FND_MESSAGE.get_string(''PO'',''POA_TIME''),
   FND_MESSAGE.get_string(''PO'',''POA_TIME'') FROM dual',
  p_param(p_index).Value);
END Build_KPI_2PeriodType;

PROCEDURE Build_CTL_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label := FND_MESSAGE.get_string('POA', 'POA_VIEW_BY');
  Build_Selection('POA_BIS_VIEW_BY',
 'select FND_MESSAGE.get_string(''PO'', ''POA_LEAKAGE_TREND''),
    FND_MESSAGE.get_string(''PO'', ''POA_LEAKAGE_TREND'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_EPS''),
    FND_MESSAGE.get_string(''PO'', ''POA_EPS'')from sys.dual',
  p_param(p_index).Value);
END Build_CTL_ViewBy;

PROCEDURE Build_LSS_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label := FND_MESSAGE.get_string('POA', 'POA_VIEW_BY');
  Build_Selection('POA_BIS_VIEW_BY',
 'select FND_MESSAGE.get_string(''PO'', ''POA_SUPPLIER''),
    FND_MESSAGE.get_string(''PO'', ''POA_SUPPLIER'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_ORGANIZATION''),
    FND_MESSAGE.get_string(''PO'', ''POA_ORGANIZATION'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_COMMODITY''),
    FND_MESSAGE.get_string(''PO'', ''POA_COMMODITY'')from sys.dual',
  p_param(p_index).Value);
END Build_LSS_ViewBy;

PROCEDURE Build_SPA_ViewBy(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
BEGIN
  p_param(p_index).Label := FND_MESSAGE.get_string('POA', 'POA_VIEW_BY');
  Build_Selection('POA_BIS_VIEW_BY',
 'select FND_MESSAGE.get_string(''PO'', ''POA_SUPPLIER''),
    FND_MESSAGE.get_string(''PO'', ''POA_SUPPLIER'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_COMMODITY''),
    FND_MESSAGE.get_string(''PO'', ''POA_COMMODITY'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_BUYER''),
    FND_MESSAGE.get_string(''PO'', ''POA_BUYER'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_OPERATING_UNIT''),
    FND_MESSAGE.get_string(''PO'', ''POA_OPERATING_UNIT'')from sys.dual
 union select FND_MESSAGE.get_string(''PO'', ''POA_ITEM''),
    FND_MESSAGE.get_string(''PO'', ''POA_ITEM'')from sys.dual',
  p_param(p_index).Value);
END Build_SPA_ViewBy;

PROCEDURE Build_SavingsShipToOrg(
p_param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
p_index IN NUMBER) IS
l_where_clause    VARCHAR2(1000);
l_return_status   VARCHAR2(1000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_region_code     VARCHAR2(30);
BEGIN

  IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
  -- Use restricted LOV
    l_region_code := 'POA_BIS_SAVINGS_RPT';
    Retrieve_Org_Where_Clause
    (p_user_id           => FND_GLOBAL.user_id,
     x_where_clause      => l_where_clause,
     x_return_status     => l_return_status,
     x_error_Tbl         => l_error_tbl);
  ELSE
    l_region_code := 'POA_BIS_SAVINGS_RPT_G';
    l_where_clause := NULL;
  END IF;

  p_param(p_index).Label :=
    FND_MESSAGE.get_string('PO', 'POA_SHIP_TO_ORG');
  p_param(p_index).Value := htf.formText('POA_BIS_ORG_NAME');
  p_param(p_index).Action :=
    '<A HREF="javascript:LOV(''201'', ''POA_BIS_ORG_NAME'', ''201'',''' ||
    l_region_code || ''',''RPTPFORM'','''','''','''|| l_where_clause ||''')">
     <IMG SRC="/OA_MEDIA/FNDILOV.gif" ALIGN="ABSMIDDLE" BORDER=0 ALT
     ="List of Values"></A>';
  p_param(p_index).Action := p_param(p_index).Action ||
    htf.formHidden('POA_BIS_ORG_ID');
END Build_SavingsShipToOrg;

PROCEDURE Build_Selection(p_name IN VARCHAR2,
    p_select IN VARCHAR2, p_output IN OUT NOCOPY VARCHAR2) IS
  l_cursor NUMBER;
  l_value  VARCHAR2(254);
  l_display VARCHAR2(254);
  l_ret_code NUMBER;
  l_count NUMBER;
BEGIN
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, p_select, DBMS_SQL.V7);
  dbms_sql.define_column(l_cursor, 1, l_value, 254);
  dbms_sql.define_column(l_cursor, 2, l_display, 254);
  l_ret_code := dbms_sql.execute(l_cursor);
  l_count := 0;
  p_output := p_output || ' ' || htf.formSelectOpen(p_name);

  LOOP

    IF (dbms_sql.fetch_rows(l_cursor) > 0) THEN
      l_count := l_count + 1;
      dbms_sql.column_value(l_cursor, 1, l_value);
      dbms_sql.column_value(l_cursor, 2, l_display);

      IF l_count = 1 THEN
        p_output := p_output || ' ' ||
          htf.formSelectOption(l_display, 'YES', 'value="' || l_value || '"');
      ELSE
        p_output := p_output || ' ' ||
          htf.formSelectOption(l_display, NULL, 'value="' || l_value || '"');
      END IF;

    ELSE
      EXIT;
    END IF;

  END LOOP;

  dbms_sql.close_cursor(l_cursor);
  p_output := p_output || ' ' || htf.formSelectClose;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in Build_Selection procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END Build_Selection;

PROCEDURE Build_ErrorPage(
p_param IN BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type) IS
l_count NUMBER;
BEGIN
  IF p_param.count > 0 THEN
    htp.p('<table align=center border=0 cellpadding=0 cellspacing=0
    width=672> <tr><td><br></td></tr> <tr> <td align=center> <font face=arial>
    <font size=+1>' ||
    nvl(FND_MESSAGE.get_string('PO', 'POA_REPORT_PARAM'), 'Report Parameters?')
    || '</font></td></tr><tr><td><br></td></tr>
    <tr> <td align=left> <font face=arial>' ||
    nvl(FND_MESSAGE.get_string('PO', 'POA_INVALID_PARAM'), 'The following parameters are invalid?')
    || '</font></td></tr> <tr><td><br></td></tr> </table>');
    htp.tableOpen (calign => 'CENTER', cattributes => ' BORDER=0 WIDTH=96%');

    FOR l_count in 1..p_param.count LOOP
      htp.tableRowOpen;
      htp.tableData(cvalue => p_param(l_count).label,
                    calign => 'RIGHT',
                    cattributes => 'VALIGN=CENTER WIDTH=50%');
      htp.tableData(cvalue => '<I>' || p_param(l_count).value || '</I>',
                    calign => 'LEFT',
                    cattributes => 'VALIGN=CENTER WIDTH=50%');
      htp.tableRowClose;
    END LOOP;

    htp.tableRowOpen;
    htp.tableData(cvalue => '<A Href="javascript:history.back()">Back to parameter page</A>', calign => 'CENTER', cattributes => 'VALIGN=CENTER COLSPAN=2');
    htp.tableRowClose;
    htp.tableClose;
  END IF;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in Build_ErrorPage procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END Build_ErrorPage;

FUNCTION Validate_OrderDates(p_fdate IN OUT NOCOPY VARCHAR2,
  p_tdate IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF (p_fdate IS NULL) THEN
    SELECT to_char(add_months(sysdate, -12)+1, icx_sec.g_date_format)
    INTO p_fdate
    FROM SYS.DUAL;
  END IF;

  IF (p_tdate IS NULL) THEN
    SELECT to_char(sysdate, icx_sec.g_date_format)
    INTO p_tdate
    FROM SYS.DUAL;
  END IF;

-- Convert date to DD-MON-YYYY format as thats the format reports expect
   SELECT to_char(to_date(p_fdate, icx_sec.g_date_format), 'DD-MON-YYYY')
   INTO p_fdate
   FROM SYS.DUAL;

   SELECT to_char(to_date(p_tdate, icx_sec.g_date_format), 'DD-MON-YYYY')
   INTO p_tdate
   FROM SYS.DUAL;

  RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
  RETURN FALSE;

END Validate_OrderDates;

FUNCTION Validate_SupplierNum(p_num_of_suppliers IN OUT NOCOPY NUMBER)
   RETURN BOOLEAN IS
BEGIN
  IF (p_num_of_suppliers is NULL) THEN
    p_num_of_suppliers := 3;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in Validate_SupplierNum procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END Validate_SupplierNum;

FUNCTION Validate_QualityCost(p_quality_cost IN OUT NOCOPY NUMBER)
   RETURN BOOLEAN IS
BEGIN
  IF (p_quality_cost is NULL) THEN
    p_quality_cost := 25;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in Validate_QualityCost procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END Validate_QualityCost;

FUNCTION Validate_DeliveryCost(p_delivery_cost IN OUT NOCOPY NUMBER)
   RETURN BOOLEAN IS
BEGIN
  IF (p_delivery_cost is NULL) THEN
    p_delivery_cost := 25;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in Validate_DeliveryCost procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END Validate_DeliveryCost;

FUNCTION Validate_SupplierItem(p_item_name IN VARCHAR2,
p_item_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT msi.inventory_item_id
  FROM mtl_system_items_kfv msi
  where msi.concatenated_segments in (p_item_name) ;
BEGIN
  IF (p_item_name IS NULL OR p_item_name = '') THEN
    p_item_id := NULL;
    return FALSE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_item_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_SupplierItem;

FUNCTION Validate_PrefSupplier(p_pref_supp_name IN VARCHAR2,
p_pref_supp_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT pov.vendor_id
  FROM po_vendors pov
  where pov.vendor_name = p_pref_supp_name;
BEGIN
  IF (p_pref_supp_name IS NULL OR p_pref_supp_name = '') THEN
    p_pref_supp_id := NULL;
    return FALSE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_pref_supp_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_PrefSupplier;

FUNCTION Validate_ConsSupplier(p_cons_supp_name IN VARCHAR2,
p_cons_supp_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT pov.vendor_id
  FROM po_vendors pov
  where pov.vendor_name = p_cons_supp_name;
BEGIN
  IF (p_cons_supp_name IS NULL OR p_cons_supp_name = '') THEN
    p_cons_supp_id := -9999;
    return TRUE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_cons_supp_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_ConsSupplier;

FUNCTION Validate_SavingsBuyer(p_buyer_name IN VARCHAR2,
p_buyer_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT b.person_id
  FROM po_agents a, per_all_people_f b
  WHERE a.agent_id = b.person_id
  AND trunc(sysdate) between b.effective_start_date AND b.effective_end_date
  AND b.full_name = p_buyer_name;
BEGIN
  IF (p_buyer_name IS NULL OR p_buyer_name = '') THEN
    p_buyer_id := -9999;
    return TRUE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_buyer_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_SavingsBuyer;

FUNCTION Validate_SavingsSupplier(p_supplier_name IN VARCHAR2,
p_supplier_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT vendor_id
  FROM po_vendors
  WHERE vendor_name = p_supplier_name;
BEGIN
  IF (p_supplier_name IS NULL OR p_supplier_name = '') THEN
    p_supplier_id := -9999;
    return TRUE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_supplier_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_SavingsSupplier;

FUNCTION Validate_SavingsShipToOrg(p_org_name IN VARCHAR2,
p_org_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
l_global_check NUMBER;
CURSOR c0 IS
  SELECT hr.organization_id
  FROM hr_organization_units hr
  WHERE hr.name = p_org_name;
CURSOR c1 IS
  SELECT hr.organization_id
  FROM hr_organization_units hr
  WHERE hr.name = p_org_name
  AND (hr.organization_id IN
    (SELECT organization_id FROM org_organization_definitions
      WHERE set_of_books_id IN
        (SELECT id
         FROM bis_sets_of_books_v
         WHERE responsibility_id IN
           (SELECT responsibility_id
            FROM fnd_user_resp_groups
            WHERE user_id = FND_GLOBAL.user_id
            AND sysdate BETWEEN start_date and nvl(end_date, sysdate+1)))));

BEGIN
  IF (p_org_name IS NULL OR p_org_name = '') THEN
    p_org_id := -9999;
    return TRUE;
  ELSE

    IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
    -- Use restricted check
      OPEN c1;
      FETCH c1 INTO p_org_id;

      IF c1%NOTFOUND THEN
        CLOSE c1;
        RETURN FALSE;
      ELSE
        CLOSE c1;
        RETURN TRUE;
      END IF;

    ELSE
    -- Use unrestricted check
      OPEN c0;
      FETCH c0 INTO p_org_id;

      IF c0%NOTFOUND THEN
        CLOSE c0;
        RETURN FALSE;
      ELSE
        CLOSE c0;
        RETURN TRUE;
      END IF;

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  IF c0%ISOPEN THEN
    CLOSE c0;
  END IF;
  RETURN FALSE;
END Validate_SavingsShipToOrg;

FUNCTION Validate_SavingsCommodity(p_commodity_name IN VARCHAR2,
p_commodity_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c1 IS
  SELECT category_id
  FROM mtl_categories_kfv
  WHERE concatenated_segments = p_commodity_name;
BEGIN
  IF (p_commodity_name IS NULL OR p_commodity_name = '') THEN
    p_commodity_id := -9999;
    return TRUE;
  ELSE
    OPEN c1;
    FETCH c1 INTO p_commodity_id;

    IF c1%NOTFOUND THEN
      CLOSE c1;
      RETURN FALSE;
    ELSE
      CLOSE c1;
      RETURN TRUE;
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN FALSE;
END Validate_SavingsCommodity;

FUNCTION Validate_SavingsOperatingUnit(p_oper_unit_name IN VARCHAR2,
p_oper_unit_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c0 IS
  SELECT organization_id
  FROM hr_operating_units
  WHERE name = p_oper_unit_name;
CURSOR c1 IS
  SELECT organization_id
  FROM hr_operating_units
  WHERE name = p_oper_unit_name
  and organization_id IN
    (SELECT id from bis_operating_units_v
     WHERE responsibility_id IN
       (SELECT responsibility_id
        FROM fnd_user_resp_groups
        WHERE user_id = FND_GLOBAL.user_id
        AND sysdate BETWEEN start_date and nvl(end_date, sysdate+1)));

BEGIN

  IF (p_oper_unit_name IS NULL OR p_oper_unit_name = '') THEN
    p_oper_unit_id := -9999;
    return TRUE;
  ELSE

    IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
      -- Use restricted check
      OPEN c1;
      FETCH c1 INTO p_oper_unit_id;

      IF c1%NOTFOUND THEN
        CLOSE c1;
        RETURN FALSE;
      ELSE
        CLOSE c1;
        RETURN TRUE;
      END IF;

    ELSE
      -- Use unrestricted check
      OPEN c0;
      FETCH c0 INTO p_oper_unit_id;

      IF c0%NOTFOUND THEN
        CLOSE c0;
        RETURN FALSE;
      ELSE
        CLOSE c0;
        RETURN TRUE;
      END IF;

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  IF c0%ISOPEN THEN
    CLOSE c0;
  END IF;
  RETURN FALSE;
END Validate_SavingsOperatingUnit;

FUNCTION Validate_PPS_OperatingUnit(p_oper_unit_name IN VARCHAR2,
p_oper_unit_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
CURSOR c0 IS
  SELECT organization_id
  FROM hr_operating_units
  WHERE name = p_oper_unit_name;
CURSOR c1 IS
  SELECT organization_id
  FROM hr_operating_units
  WHERE name = p_oper_unit_name
  and organization_id IN
    (SELECT id FROM bis_operating_units_v
      WHERE responsibility_id IN
        (SELECT responsibility_id
         FROM fnd_user_resp_groups
         WHERE user_id = FND_GLOBAL.user_id
         AND sysdate between start_date and nvl(end_date, sysdate+1)));
BEGIN
  IF (p_oper_unit_name IS NULL OR p_oper_unit_name = '') THEN
    p_oper_unit_id := -9999;
    return TRUE;
  ELSE

    IF nvl(fnd_profile.value('POA_GLOBAL_SECURITY'), 'N') = 'N' THEN
      OPEN c1;
      FETCH c1 INTO p_oper_unit_id;

      IF c1%NOTFOUND THEN
        CLOSE c1;
        RETURN FALSE;
      ELSE
        CLOSE c1;
        RETURN TRUE;
      END IF;

    ELSE
      -- Use unrestricted check
      OPEN c0;
      FETCH c0 INTO p_oper_unit_id;

      IF c0%NOTFOUND THEN
        CLOSE c0;
        RETURN FALSE;
      ELSE
        CLOSE c0;
        RETURN TRUE;
      END IF;

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  IF c0%ISOPEN THEN
    CLOSE c0;
  END IF;
  RETURN FALSE;
END Validate_PPS_OperatingUnit;

--Retrieve the where clause used to extract the set of
--organizations tied to a union of responsibilities.

PROCEDURE Retrieve_Org_Where_Clause
(p_user_id             IN NUMBER := NULL
,p_user_name           IN VARCHAR2 := NULL
,x_where_clause        OUT NOCOPY VARCHAR2
,x_return_status       OUT NOCOPY VARCHAR2
,x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id              NUMBER;
l_Responsibility_tbl   BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_SOB_tbl              POA_REPORT_UTIL.SOB_Tbl_Type;
l_where_clause         BIS_LEVELS.WHERE_CLAUSE%TYPE;
l_comma                VARCHAR2(2) := ',';
l_database_object      VARCHAR2(30);

BEGIN

  IF p_user_id is null then
    SELECT user_id
    INTO l_user_id
    FROM fnd_user
    WHERE user_name = p_user_name;
  ELSE
    l_user_id := p_user_id;
  END IF;

  BIS_RESPONSIBILITY_PVT.Retrieve_User_Responsibilities
  (p_api_version             => 1.0
  ,p_user_id                 => l_user_id
  ,p_Responsibility_version  => NULL
  ,x_Responsibility_Tbl      => l_Responsibility_tbl
  ,x_return_status           => x_return_status
  ,x_error_tbl               => x_error_tbl
  );

  --Ship-to Orgs are tied to a set of books id.
  --For each responsibility_id, find the corresponding set of books id
  --to determine which set of orgs to display in the lov.

  Retrieve_Set_of_Books_Id
  (x_Responsibility_tbl    => l_Responsibility_tbl
  ,x_SOB_tbl               => l_SOB_tbl
  ,x_return_status         => x_return_status
  );

  SELECT database_object_name
  INTO l_database_object
  FROM ak_regions
  WHERE region_code = 'BIS_INV_ORGANIZATIONS';


  l_where_clause := ' 1 = 2 '
                    || ' UNION SELECT DISTINCT VALUE, ID '
                    || ' FROM ' || l_database_object
                    || ' WHERE ID IN '
                    || ' (SELECT organization_id FROM org_organization_definitions '
                    || '    WHERE set_of_books_id IN ( ';


  FOR i IN 1..l_SOB_tbl.COUNT LOOP
    IF i = l_SOB_tbl.LAST THEN
      l_where_clause := l_where_clause || l_SOB_tbl(i).SOB_ID;
    ELSE
      l_where_clause := l_where_clause || l_SOB_tbl(i).SOB_ID || l_comma;
    END IF;
  END LOOP;

  l_where_clause := l_where_clause || ' ))';

  -- convert all of the ASCIII special characters
  l_where_clause := WFA_HTML.conv_special_url_chars(l_where_clause);

  x_where_clause := l_where_clause;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
    (p_error_msg_id       => SQLCODE
    ,p_error_description  => SQLERRM
    ,p_error_proc_name    => 'POA_REPORT_UTIL.Retrieve_Org_Where_Clause'
    ,p_error_table        => x_error_tbl
    ,x_error_table        => x_error_tbl
    );

END Retrieve_Org_Where_Clause;

--Retrieve the set of books id associated with each responsibility id
PROCEDURE Retrieve_Set_of_Books_Id
(x_Responsibility_tbl  IN BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type
,x_SOB_tbl             OUT NOCOPY POA_REPORT_UTIL.SOB_Tbl_Type
,x_return_status       OUT NOCOPY VARCHAR2
)
IS
CURSOR sob_cur(p_resp_id NUMBER) IS
  SELECT id
  FROM bis_sets_of_books_v
  WHERE responsibility_id = p_resp_id;

l_rec                  POA_REPORT_UTIL.SOB_Rec_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  FOR i IN 1..x_Responsibility_tbl.COUNT LOOP
    FOR cr in sob_cur(x_Responsibility_tbl(i).Responsibility_ID) LOOP
      l_rec.SOB_ID  := cr.id;
      x_SOB_tbl(x_SOB_tbl.COUNT+1) := l_rec;
    END LOOP;
  END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id       => SQLCODE
       ,p_error_description  => SQLERRM
       ,p_error_proc_name    => 'POA_REPORT_UTIL.Retrieve_Set_of_Books_Id'
      );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Set_of_Books_Id;

END POA_REPORT_UTIL;

/
