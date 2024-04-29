--------------------------------------------------------
--  DDL for Package Body ICX_ITEM_DIAG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ITEM_DIAG_GRP" AS
/* $Header: ICX_ITEM_DIAG_GRP.plb 120.0.12010000.5 2012/04/20 09:08:24 rojain noship $*/

FUNCTION get_html_body
  RETURN VARCHAR;
FUNCTION print_setup_values
  RETURN VARCHAR2 ;
FUNCTION print_file_versions
  RETURN VARCHAR2;
FUNCTION print_id_values
  RETURN VARCHAR2;
FUNCTION validate_values
  RETURN VARCHAR2;
FUNCTION need_patch
  RETURN boolean ;

procedure Split
(
   in_str IN OUT NOCOPY VARCHAR2,         -- input string
   token_num IN NUMBER,         -- token number
   delim IN VARCHAR2 DEFAULT ' ', -- separator character
   out_str out  NOCOPY VARCHAR2
) IS
  l_str VARCHAR2(32767) ;
  l_int      NUMBER ;
  l_int2     NUMBER ;
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Split';
BEGIN
  l_str:= delim || in_str ;
  l_int := INSTR( l_str, delim, 1, token_num ) ;
  IF l_int > 0 THEN
    l_int2 := INSTR( l_str, delim, 1, token_num + 1) ;
    IF l_int2 = 0 THEN l_int2 := LENGTH( l_str ) + 1 ; END IF ;
     out_str:=    SUBSTR( l_str, l_int+1, l_int2 - l_int- 1)  ;
     in_str:= trim(SUBSTR( l_str, l_int2+1)  );
  END IF ;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'split out_str='||out_str||' remaining_str='||in_str);

exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'split EXCEPTION::'||sqlerrm||' code='||sqlcode);
END Split;

PROCEDURE ol
  (
    p_str IN clob)
          IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  fnd_file.put_line(fnd_file.output,p_str);
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, 'ol EXCEPTION::',sqlerrm||' code='||sqlcode);
END ol;

function parse( p_str IN VARCHAR2)
         RETURN VARCHAR2 IS
  str VARCHAR2(4000):= '';
  substr VARCHAR2(4000):= '';
  l_ctr number := 1;
  l_api_name                      CONSTANT VARCHAR2(30)   := 'parse';
BEGIN
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'parse p_str='||p_str);
str:=trim(p_str);
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'str '||str);
while ( str is not null )loop
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'next string ||' ||str);
    split(in_str=>str,
        token_num=>1,
        delim=> ',',
        out_str=>substr);
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'at ctr= '||l_ctr|| ' string='|| str||' token='||substr );
 begin
  ICX_ITEM_DIAG_PVT.g_source_ids(l_ctr) := to_number(substr);
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'  g_source_ids('||l_ctr||') :='|| ICX_ITEM_DIAG_PVT.g_source_ids(l_ctr) );

  if ICX_ITEM_DIAG_PVT.g_source_ids(l_ctr) is null then
   goto END_LOOP;
  end if;
 exception when others then
   ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'at ctr= exception');
 end;

l_ctr:=l_ctr+1;
<<END_LOOP>> null;
end loop;

return 'Y';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'parse EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';
END parse;

FUNCTION row1
  (
    str1 IN VARCHAR2 )
  RETURN VARCHAR2
                    IS
  str VARCHAR2(4000):= '<TD class=''OraTableCellText'' style=''border:1px solid #cccc99''>';
  l_api_name                      CONSTANT VARCHAR2(30)   := 'row1';
BEGIN
  RETURN str|| str1 ||'</TD>';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'row1 '||sqlerrm||' code='||sqlcode);
return 'N';

END row1;

FUNCTION col
  (
    str1 IN VARCHAR2 )
  RETURN VARCHAR2
                    IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'col';
  str VARCHAR2(4000):= '<TH scope=''col'' class=''OraTableColumnHeader'' style=''border-left:1px solid #f7f7e7''>';
BEGIN
  RETURN str|| str1 ||'</TH>';

exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'col EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';
END col;

FUNCTION table_hdr
  (
    str1 IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'table_hdr';
BEGIN
  RETURN '<span class="section">'||str1 ||'</span><TABLE class=''OraTable'' style=''border-collapse:collapse'' width=''100%'' cellpadding=1 cellspacing=0 border=0 summary=''' || str1||'''>';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'table_hdr EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';

END table_hdr;

FUNCTION print_table(table_name IN VARCHAR2
										, col_num IN NUMBER
      							, col_val IN  DBMS_SQL.VARCHAR2_TABLE
										, row_num IN NUMBER
      							, row_val IN  VARCHAR_TABLE )
  RETURN clob
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'print_table';
l_html clob;
i number;
j number;
BEGIN
  l_html:=table_hdr(table_name);
	l_html:=l_html|| '<TR>';
  ol(l_html);
  FOR i IN 1 .. col_num LOOP
		ol( col( col_val(i) ));
  END LOOP;

	ol( '</TR><TR>');

 l_html:='';
  FOR i IN 1 .. row_num LOOP
	  FOR j IN 1 .. col_num LOOP
		ol( row1(row_val(i)(j)) );
	  END LOOP;
	ol( '</TR><TR>' );
  END LOOP;
   ol('</TR></TABLE>');
return 'Y';
exception when others then
   ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'print_table exception'|| sqlerrm||' '||sqlcode);
return 'N';
END print_table;

function init (org_id in varchar2,
							 action_code in varchar2,
						 	auto_map_category VARCHAR2 default null)return varchar2 is
  l_api_name                      CONSTANT VARCHAR2(30)   := 'init';
begin
/* Init values*/

ICX_ITEM_DIAG_PVT.g_org_id := to_number(org_id);
if action_code ='SYNC_MASTER' then
 ICX_ITEM_DIAG_PVT.g_source_type :='MASTER_ITEM';
elsif action_code ='SYNC_BPA' then
 ICX_ITEM_DIAG_PVT.g_source_type :='BLANKET';
end if;
ICX_ITEM_DIAG_PVT.g_source_type_values(1):='ALL';ICX_ITEM_DIAG_PVT.g_source_type_values(2):='BPA';ICX_ITEM_DIAG_PVT.g_source_type_values(3):='MASTER ITEM';
ICX_ITEM_DIAG_PVT.g_auto_map_category:=nvl(auto_map_category,'N');

ICX_ITEM_DIAG_PVT.g_table_names(1):='MTL_SYSTEM_ITEMS_B';ICX_ITEM_DIAG_PVT.g_table_names(2):='MTL_SYSTEM_ITEMS_TL';ICX_ITEM_DIAG_PVT.g_table_names(3):='MTL_ITEM_CATEGORIES';
ICX_ITEM_DIAG_PVT.g_table_names(4):='MTL_UNITS_OF_MEASURE';ICX_ITEM_DIAG_PVT.g_table_names(5):='ICX_CAT_CATEGORIES_TL';ICX_ITEM_DIAG_PVT.g_table_names(6):='ICX_CAT_ITEMS_CTX_HDRS_TLP';
ICX_ITEM_DIAG_PVT.g_table_names(7):='ICX_CAT_ITEMS_CTX_DTLS_TLP';ICX_ITEM_DIAG_PVT.g_table_names(8):='DR$SQE';ICX_ITEM_DIAG_PVT.g_table_names(9):='PO_ATTRIBUTE_VALUES';
ICX_ITEM_DIAG_PVT.g_table_names(10):='PO_ATTRIBUTE_VALUES_TLP';ICX_ITEM_DIAG_PVT.g_table_names(11):='ICX_CAT_ATTRIBUTE_VALUES';ICX_ITEM_DIAG_PVT.g_table_names(12):='ICX_CAT_ATTRIBUTE_VALUES_TLP';
ICX_ITEM_DIAG_PVT.g_table_names(13):='PO_SESSION_GT';

ICX_ITEM_DIAG_PVT.g_error_code(1):='TOO_MANY_PO_CATEGORY_ASSIGNED';ICX_ITEM_DIAG_PVT.g_error_code(2):='IP_CATEGORY_MISSING';ICX_ITEM_DIAG_PVT.g_error_code(3):='CATEGORY_MAPPING_MISSING';
ICX_ITEM_DIAG_PVT.g_error_code(4):='PO_ATTRIBUTE_RECORDS_MISSING';ICX_ITEM_DIAG_PVT.g_error_code(5):='MASTER ITEM NOT ASSIGNED';ICX_ITEM_DIAG_PVT.g_error_code(6):='ICX_CTX_HDRS_MISSING';
ICX_ITEM_DIAG_PVT.g_error_code(7):='NOT_VALID_FOR_SEARCH';

  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'deleting po_session_gt');
DELETE FROM po_session_gt WHERE index_char1 in ( ICX_ITEM_DIAG_PVT.g_file_key , ICX_ITEM_DIAG_PVT.g_error_key,ICX_ITEM_DIAG_PVT.g_id_values_key) ;

return 'Y';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'init EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';

end init;

PROCEDURE START_THIS
  (
    errbuff OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    org_id      VARCHAR2,
    action_code VARCHAR2,
	--	source_type VARCHAR2,
    source_ids  VARCHAR2 default null,
		auto_map_category VARCHAR2 default null)
                            IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'START_THIS';
l_ret VARCHAR2(20);
  l_start_date			DATE;
  l_html_out VARCHAR2(4000) :='<html><head><title>Procurement Product Report</title>';
l_log_string VARCHAR2(1000);
BEGIN
    l_start_date	:= sysdate;
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS');
      ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string);

  l_html_out :=l_html_out || '<style type="text/css">body {background-color:ffffff;background-repeat:no-repeat;background-position:top left;background-attachment:fixed;}' ;
  l_html_out :=l_html_out || 'h1{font-family:Verdana;color:000000;}' ;
  l_html_out :=l_html_out || 'p {font-family:Helvetica;font-size:14px;font-style:normal;font-weight:normal;color:000000;}' ;
  l_html_out :=l_html_out || '.error {color: #cc0000; font-size: 10pt; font-weight: normal}.errorbold {font-weight: bold; color: #cc0000; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.warning {font-weight: normal; color: #336699; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.warningbold {font-weight: bold; color: #336699; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.notice {font-weight: normal; color: #663366; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.noticebold {font-weight: bold; color: #663366; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.section {font-weight: bold; font-size: 12pt}' ;
  l_html_out :=l_html_out || '.subsection {font-weight: bold; font-size: 10pt}' ;
  l_html_out :=l_html_out || '.toplink {font-weight: normal; font-size: 8pt}' ;
  l_html_out :=l_html_out || '.tableFooter {font-weight: normal; font-size: 8pt}' ;
  l_html_out :=l_html_out || 'ul.report {list-style: disc;}' ;
  l_html_out :=l_html_out || 'ul.nobull {list-style: none}' ;
  l_html_out :=l_html_out || 'table.report {background-color: #000000 color:#000000; font-size: 10pt; font-weight: bold; line-height:1.5; padding:2px; text-align:left}' ;
  l_html_out :=l_html_out || 'td.report {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; border-style: solid; border-width: 1; border-color: #CCCC99; white-space: nowrap}' ;
  l_html_out :=l_html_out || 'tr.report {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; white-space: nowrap}' ;
  l_html_out :=l_html_out || 'th.report {background-color: #CCCC99; color: #336699; height: 20; border-style: solid; border-width: 1; border-left-color:';
  l_html_out :=l_html_out || ' #f7f7e7; border-right-color: #f7f7e7; border-top-width: 0; border-bottom-width: 0; white-space: nowrap}' ;
  l_html_out :=l_html_out || '.OraTableColumnHeader {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;text-align:left;background-color:#cccc99;color:#336699;vertical-align:bottom}' ;
  l_html_out :=l_html_out || '.OraTableColumnHeaderNumber {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:right}' ;
  l_html_out :=l_html_out || '.OraTableCellText {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;background-color:#f7f7e7;color:#000000;vertical-align:baseline}' ;
  l_html_out :=l_html_out || '.OraTableTitle {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:13pt;background-color:#ffffff;color:#336699}' ;
  l_html_out :=l_html_out || '.OraTable {background-color:#999966}' ;
  l_html_out :=l_html_out || '</style>' ;
  l_html_out :=l_html_out || '</head>' ;
  ol(l_html_out);

  l_log_string := 'Input Parameters: org_id=' || org_id || ' action_code='||action_code || ' ,auto_map_category='||auto_map_category;
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string);

l_ret:=init(org_id,action_code,auto_map_category);
if action_code = 'SYNC_ITEM' then
l_ret:= parse(source_ids);
end if;

ol(table_hdr('ITEM_DIAG_GRP table header org_id ='||org_id||' action type='|| action_code || ' sourceids = '||source_ids || ' auto_map_category='||auto_map_category));

/*if auto_map_category then
ol(table_hdr('auto_map_category is true'));
else
ol(table_hdr('auto_map_category is false'));
end if;*/

  ol('<TR>') ;
  l_html_out:=get_html_body();

	if action_code <> 'SYNC_ITEM' and NOT need_patch then
    ICX_ITEM_DIAG_PVT.sync_sources(p_org_id  =>ICX_ITEM_DIAG_PVT.g_org_id,
												 p_source_type =>ICX_ITEM_DIAG_PVT.g_source_type,
												x_return_status => l_ret	);
	end if;

  ol('</html>');
commit;


 l_log_string :=' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, sysdate);
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string);

exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start_this '||sqlerrm||' code='||sqlcode);
END START_THIS;

FUNCTION get_html_body
  RETURN VARCHAR
                         IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'get_html_body';
  l_start VARCHAR2(2000) := '<body>' ;
  l_hrd1  VARCHAR2(2000) := '<h1>Item Extractor Diagnostics</h1>' ;
  --  l_hrd2  VARCHAR2(2000) := '<span class="section">Related File versions</span>' ;
  --<ul class="report"><li>Server = myMachine<br></li>
  l_ret VARCHAR2(20);
BEGIN
  --Heading 1 : Checking file versions...
--  ol(l_hrd2);
  l_ret:= print_file_versions;
if l_ret='Y' then
  l_ret:=  print_setup_values;
  l_ret:=  print_id_values;
  l_ret:=  validate_values;
end if;
  RETURN 'Y';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'get_html_body EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';

END get_html_body;

FUNCTION print_file_versions
  RETURN VARCHAR2 IS
 /* l_hrd0 VARCHAR2(2000):= '<ul class="report">';
  l_hrd1 VARCHAR2(2000):= '<li>';
  l_hrd2 VARCHAR2(20)  := '<br></li>';*/
  l_hrd3 VARCHAR(4000);
  l_api_name                      CONSTANT VARCHAR2(30)   := 'print_file_versions';
  CURSOR c
  IS
    SELECT  char1,  char2 ,  char3, char4
    FROM po_session_gt
    WHERE index_char1 =ICX_ITEM_DIAG_PVT.g_file_key;

l_col_val  DBMS_SQL.VARCHAR2_TABLE;
l_row_val  VARCHAR_TABLE;
l_ret VARCHAR2(20);
BEGIN
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start print_file_versions');

  ICX_ITEM_DIAG_PVT.file_versions('Y');

    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'completed  ICX_ITEM_DIAG_PVT.file_versions');
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'Files from po session gt ');
 --ol(l_hrd0);
  OPEN c;
  FOR i IN 1 .. ICX_ITEM_DIAG_PVT.g_file_count
  LOOP
/*    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'Files from po session gt i='|| i);
    FETCH c INTO l_hrd3;

      ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_hrd3);
    l_hrd3 := l_hrd1 || l_hrd3 || l_hrd2;
    ol(l_hrd3);*/

    FETCH c INTO l_row_val(i)(1),l_row_val(i)(2),l_row_val(i)(3),l_row_val(i)(4);

  END LOOP;
  CLOSE c;
  l_col_val(1):= 'File name';    l_col_val(2):= 'Should have version';    l_col_val(3):= 'Instance has Version';    l_col_val(4):= 'Need to Apply Patch?';
 l_ret:= print_table(table_name => 'RELATED FILE VERSIONS'
										, col_num => 4
      							, col_val =>l_col_val
										, row_num => ICX_ITEM_DIAG_PVT.g_file_count
      							, row_val => l_row_val );

    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'end print_file_versions');

  if need_patch then
ol( table_hdr('APPLY RECOMMENDED PATCH'));
 RETURN 'ABORT';
  end if;
  RETURN 'Y';
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'print_file_versions '||sqlerrm||' code='||sqlcode);
return 'N';

END print_file_versions;

FUNCTION need_patch
  RETURN boolean IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'need_patch';
l_c_row varchar2(10);
l_ret boolean := false;
cursor c is
    SELECT 'TRUE' from dual where exists (select 'Y'
    FROM po_session_gt
    WHERE index_char1 =ICX_ITEM_DIAG_PVT.g_file_key
    and   char4 = 'TRUE' );
begin

 open c;
 fetch c into  l_c_row;
 if l_c_row = 'TRUE' then
   l_ret := true;
   ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'need_patch returning true');
  else
   ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'need_patch returning false');
 end if;
 return l_ret;
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'need_patch EXCEPTION::'||sqlerrm||' code='||sqlcode);
return false;
end need_patch;

FUNCTION print_setup_values
  RETURN VARCHAR2 IS
l_col_val  DBMS_SQL.VARCHAR2_TABLE;
l_row_val  VARCHAR_TABLE;
l_ret VARCHAR2(20);
l_api_name                      CONSTANT VARCHAR2(30)   := 'print_setup_values';

begin

ICX_ITEM_DIAG_PVT.get_setup_values (p_table_name => 'Setup Values', p_col_val=>l_col_val,p_row_val=>l_row_val);

l_ret:= print_table(table_name => 'Setup Values'
										, col_num => 11
      							, col_val =>l_col_val
										, row_num => 1
      							, row_val => l_row_val );

return l_ret;
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'print_setup_values '||sqlerrm||' code='||sqlcode);
return 'N';

END print_setup_values;

FUNCTION print_id_values
  RETURN VARCHAR2 IS
l_col_val  DBMS_SQL.VARCHAR2_TABLE;
l_row_val  VARCHAR_TABLE;
l_col_num number;
l_row_num number;
l_ret VARCHAR2(20);
i number;
l_api_name                      CONSTANT VARCHAR2(30)   := 'print_id_values';

begin

for i in 1..ICX_ITEM_DIAG_PVT.g_table_names.COUNT loop
ICX_ITEM_DIAG_PVT.get_IDs_values(p_table_name => ICX_ITEM_DIAG_PVT.g_table_names(i)
										, p_col_num => l_col_num
      							, p_row_num => l_row_num
      							, p_col_val =>l_col_val
										, p_row_val => l_row_val );

 l_ret:= print_table(table_name => ICX_ITEM_DIAG_PVT.g_table_names(i)
										, col_num => l_col_num
      							, col_val =>l_col_val
										, row_num => l_row_num
      							, row_val => l_row_val );
end loop;

return l_ret;
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'print_id_values EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';

end print_id_values;

FUNCTION validate_values
  RETURN VARCHAR2 IS
l_col_val  DBMS_SQL.VARCHAR2_TABLE;
l_row_val  VARCHAR_TABLE;
l_col_num number;
l_row_num number;
l_ret varchar2(10);
l_api_name                      CONSTANT VARCHAR2(30)   := 'validate_values';

begin
  ICX_ITEM_DIAG_PVT.validate_values(p_table_name => 'VALIDATE'
										, p_col_num => l_col_num
      							, p_row_num => l_row_num
      							, p_col_val =>l_col_val
										, p_row_val => l_row_val );


 l_ret:= print_table(table_name => 'VALIDATE'
										, col_num => l_col_num
      							, col_val =>l_col_val
										, row_num => l_row_num
      							, row_val => l_row_val );
return l_ret;
exception when others then
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'print_id_values EXCEPTION::'||sqlerrm||' code='||sqlcode);
return 'N';
end validate_values;

END ICX_ITEM_DIAG_GRP;

/
