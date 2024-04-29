--------------------------------------------------------
--  DDL for Package Body ICX_ITEM_DIAG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ITEM_DIAG_PVT" AS
/* $Header: ICX_ITEM_DIAG_PVT.plb 120.0.12010000.6 2012/04/19 12:10:28 rojain noship $*/
procedure create_missing_data;

PROCEDURE logUnexpectedException
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'icx.plsql.' || UPPER(p_pkg_name) || '.' || UPPER(p_proc_name)|| 'EXCEPTION::'||  p_log_string);
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,'icx.plsql.' || UPPER(p_pkg_name) || '.' || UPPER(p_proc_name) , p_log_string);
    l_err_loc := 300;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 400;
END logUnexpectedException;
procedure add_error(char1 IN VARCHAR2 default null,  		--error name
									  num1       IN NUMBER default null,   --inventory_item_id
						   			num2 			 IN NUMBER default null,   --organization_id
										num3 			 IN NUMBER default null,   --po_line_id
										num4 			 IN NUMBER default null,   --org_id
										char2 		 IN VARCHAR2 default null, --req template name
								  	char3 		 IN VARCHAR2 default null, --req template line num
								  	char4 		 IN VARCHAR2 default null,
								  	char5 		 IN VARCHAR2 default null)
is
begin
INSERT  INTO    po_session_gt
        (index_char1
        ,num1
        ,num2
        ,num3
        ,num4
        ,char1
        ,char2
        ,char3
        ,char4
        ,char5)
VALUES
        (g_error_key
        ,num1
        ,num2
        ,num3
        ,num4
        ,char1
        ,char2
        ,char3
        ,char4
        ,char5);

exception when others then
  logUnexpectedException (g_pkg_name, 'add_error','Exception '||sqlerrm||' code='||sqlcode);
end add_error;

FUNCTION Split
(
   in_str IN VARCHAR2,         -- input string
   token_num IN PLS_INTEGER,         -- token number
   delim IN VARCHAR2 DEFAULT ' ' -- separator character
)
RETURN VARCHAR2
IS
  l_str VARCHAR2(32767) := delim || in_str ;
  l_int      PLS_INTEGER ;
  l_int2     PLS_INTEGER ;
BEGIN
  l_int := INSTR( l_str, delim, 1, token_num ) ;
  IF l_int > 0 THEN
    l_int2 := INSTR( l_str, delim, 1, token_num + 1) ;
    IF l_int2 = 0 THEN l_int2 := LENGTH( l_str ) + 1 ; END IF ;
    RETURN( SUBSTR( l_str, l_int+1, l_int2 - l_int-1 ) ) ;
  ELSE
    RETURN NULL ;
  END IF ;
exception when others then

logUnexpectedException (g_pkg_name, 'Split','Exception sqlerrm'||sqlerrm||' code='||sqlcode);

END Split;

  --120 for should_version contains 12000000 ; 121 for should_version contains  12010000 ;  12 for should_version like 120.x only
  -- -1 for garbage
FUNCTION update_num
  (
    p_version VARCHAR2)
  RETURN NUMBER
IS
BEGIN

  If ( p_version LIKE '120.%' AND NOT p_version LIKE '120.%.%' )
     or p_version LIKE '120.%.%.1' THEN
    RETURN 12;
  elsif INSTR( p_version , '.12000000.' ) > 0 THEN
    RETURN 120;
  elsif INSTR( p_version , '.12010000.' ) > 0 THEN
    RETURN 121;
  END IF;
  RETURN -1;
exception when others then
logUnexpectedException (g_pkg_name, 'update_num','Exception sqlerrm'||sqlerrm||' code='||sqlcode);
END update_num;
-- num1 is 0 for instance_versions equal or greater versions than should_version.
-- num2 is 120 for should_version contains 12000000 ; 121 for should_version contains  12010000 ;  12 for should_version like 120.x only
-- num3 is 120 for instance_versions contains 12000000 ; 121 for instance_versions contains  12010000 ;  12 for instance_versions like 120.x only
-- char4 is apply patch or not
FUNCTION check_file
  RETURN VARCHAR2
IS
  l_ctr NUMBER;
  l_shld_ver varchar2(100);
  l_inst_ver varchar2(100);
  l_num2 number;
  l_num3 number;
  l_apply_patch varchar2(5):='FALSE';
	l_br_iv varchar2(100); -- rep 69 of 120.69.12010000.2 of instance version
	l_br_sv varchar2(100); -- rep 69 of 120.69.12010000.2 of should have version
l_api_name varchar2(30):= 'check_file';
BEGIN
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start check_file');
  forall i IN 1 .. g_file_count
  UPDATE po_session_gt
  SET num3          = update_num( g_instance_versions_tbl(i) ) ,
    num2            = update_num( g_file_versions_tbl(i) )
  WHERE index_char1 =ICX_ITEM_DIAG_PVT.g_file_key
  AND char1         = g_file_tbl(i);

  for i IN 1 .. g_file_count loop
	  -- check if instance file is less than should have version then update apply patch as Y
		select char2, char3, num2, num3 into l_shld_ver, l_inst_ver , l_num2,l_num3
	  FROM  po_session_gt
	  WHERE index_char1 =ICX_ITEM_DIAG_PVT.g_file_key
	  AND char1         = g_file_tbl(i);

		if ( l_num2 <> l_num3) then
			l_apply_patch:= 'TRUE';
   	elsif ( l_num2 <> 12) then
      l_br_sv:= to_number(split(l_shld_ver,2,'.') );
      l_br_iv:= to_number(split(l_inst_ver,2,'.') );

      if l_br_sv > l_br_iv then
							l_apply_patch:= 'TRUE';
  		elsif  l_br_sv < l_br_iv then
							l_apply_patch:= 'FALSE';
      else
 				l_br_sv:= to_number(split(l_shld_ver,4,'.') ); -- last segment 2 of 120.69.12010000.2
	      l_br_iv:= to_number(split(l_inst_ver,4,'.') );
	      if l_br_sv > l_br_iv then
								l_apply_patch:= 'TRUE';
	  		else
								l_apply_patch:= 'FALSE';
	      end if;
  		end if;
    else
     l_br_sv:= to_number(split(l_shld_ver,2,'.') );
     l_br_iv:= to_number(split(l_inst_ver,2,'.') );
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'char4  ver 1 ' ||l_shld_ver || ' ver2 ' || l_inst_ver);
     if l_br_sv > l_br_iv then
							l_apply_patch:= 'TRUE';
  	 else
							l_apply_patch:= 'FALSE';
     end if;
    end if;
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'char4  check_file' ||g_file_tbl(i) || l_apply_patch);
    UPDATE po_session_gt set char4 = l_apply_patch
    WHERE index_char1 =ICX_ITEM_DIAG_PVT.g_file_key
	  AND char1         = g_file_tbl(i);

  end loop;
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'end check_file');
  RETURN 'Y';
exception when others then
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'check_file '||sqlerrm||' code='||sqlcode);
END check_file;

FUNCTION init_file_versions
  RETURN VARCHAR2
                              IS
  l_ctr           NUMBER      :=0;
  l_return_status VARCHAR2(20):='SUCCESS';
  l_file_name     VARCHAR2(30);
  l_file_version  VARCHAR2(20);
l_api_name VARCHAR2(30):='init_file_versions';
  CURSOR instance_ver( i NUMBER)
  IS
    SELECT filename ,
      version
    FROM
      (SELECT filename ,
        version
      FROM ad_file_versions v ,
        ad_files f
      WHERE f.file_id    = v.file_id
      AND app_short_name IN ( 'ICX', 'PO')
      AND subdir         = 'patch/115/sql'
      AND filename       = g_file_tbl(i)
      ORDER BY file_version_id DESC
      )
  WHERE rownum = 1
  ORDER BY filename;
BEGIN
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start init_file_versions');
  /*g_file_tbl :=   DBMS_SQL.VARCHAR2_TABLE(null);
  g_file_versions_tbl :=  DBMS_SQL.VARCHAR2_TABLE(null);
  g_instance_versions_tbl :=  DBMS_SQL.VARCHAR2_TABLE (null);
  */
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPBB.pls';    g_file_versions_tbl(l_ctr) := '120.1.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPBS.pls';    g_file_versions_tbl(l_ctr) := '120.0.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPCB.pls';    g_file_versions_tbl(l_ctr) := '120.2.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPCS.pls';    g_file_versions_tbl(l_ctr) := '120.1.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPMB.pls';    g_file_versions_tbl(l_ctr) := '120.5.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPMS.pls';    g_file_versions_tbl(l_ctr) := '120.1.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPQB.pls';    g_file_versions_tbl(l_ctr) := '120.2.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPQS.pls';    g_file_versions_tbl(l_ctr) := '120.0.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPRB.pls';    g_file_versions_tbl(l_ctr) := '120.2.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXGPPRS.pls';    g_file_versions_tbl(l_ctr) := '120.0.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVBCSB.pls';    g_file_versions_tbl(l_ctr) := '120.8.12010000.3';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVBCSS.pls';    g_file_versions_tbl(l_ctr) := '120.1.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPCSB.pls';    g_file_versions_tbl(l_ctr) := '120.7.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPCSS.pls';    g_file_versions_tbl(l_ctr) := '120.2.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPCB.pls';    g_file_versions_tbl(l_ctr) := '120.3.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPCS.pls';    g_file_versions_tbl(l_ctr) := '120.0.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPDB.pls';    g_file_versions_tbl(l_ctr) := '120.14.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPDS.pls';    g_file_versions_tbl(l_ctr) := '120.3.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPIB.pls';    g_file_versions_tbl(l_ctr) := '120.14.12010000.5';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPIS.pls';    g_file_versions_tbl(l_ctr) := '120.6.12010000.2';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPMB.pls';    g_file_versions_tbl(l_ctr) := '120.8.12010000.10';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPMS.pls';    g_file_versions_tbl(l_ctr) := '120.2.12010000.2';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPRB.pls';    g_file_versions_tbl(l_ctr) := '120.10.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPRS.pls';    g_file_versions_tbl(l_ctr) := '120.3.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPSB.pls';    g_file_versions_tbl(l_ctr) := '120.6.12010000.2';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVPPSS.pls';    g_file_versions_tbl(l_ctr) := '120.6.12010000.1';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVUTLB.pls';    g_file_versions_tbl(l_ctr) := '120.18.12010000.8';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'ICXVUTLS.pls';    g_file_versions_tbl(l_ctr) := '120.14.12010000.2';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'PO_ATTRIBUTE_VALUES_PVT.plb';    g_file_versions_tbl(l_ctr) := '120.30.12010000.7';
l_ctr:=l_ctr+1; g_file_tbl(l_ctr) := 'PO_ATTRIBUTE_VALUES_PVT.pls';    g_file_versions_tbl(l_ctr) := '120.12.12010000.3';


  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'g_file_tbl.count '|| g_file_tbl.count );
  FOR idx IN 1 .. g_file_tbl.count
  LOOP
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'global variables '|| idx);
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name, ' file :' || g_file_tbl(idx) || ' version :' ||g_file_versions_tbl(idx));
  END LOOP;
  -- populate instance versions
  FOR i IN 1 .. g_file_count
  LOOP
    OPEN instance_ver(i);
    FETCH instance_ver INTO l_file_name,l_file_version;

    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'in loop init_file_versions i='|| i|| ' '||l_file_name||' g_instance_versions_tbl(i)='||l_file_version);
    g_instance_versions_tbl(i):=l_file_version;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,g_instance_versions_tbl(i));
    CLOSE instance_ver;
  END LOOP;

  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'deleting done');
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start for' ||g_file_count );
  FOR i IN 1 .. g_file_count
  LOOP
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start of insert '|| i || ' file :' || g_file_tbl(i)||g_file_versions_tbl(i)|| g_instance_versions_tbl(i));
    INSERT
    INTO po_session_gt
      (
        index_char1 --'ITEM_DIAG_FILE_VERSIONS'
        ,
        char1 -- pls file name
        ,
        char2 -- should have version
        ,
        char3  -- instance version
      )
      VALUES
      (
        ICX_ITEM_DIAG_PVT.g_file_key ,
        g_file_tbl(i) ,
        g_file_versions_tbl(i) ,
        g_instance_versions_tbl(i)
      );

    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,  'for alll completed calll check file' );

  END LOOP;
  -- check old files.
  l_return_status:= check_file;

  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,     'end check file' );
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,     'end init_file_versions' );

  RETURN l_return_status;

EXCEPTION
WHEN OTHERS THEN
  logUnexpectedException(g_pkg_name, l_api_name, 'exception init_file_versions' || sqlerrm || SQLCODE  )  ;
  l_return_status :='FAILURE';
  RETURN l_return_status;
END init_file_versions;

PROCEDURE file_versions
  (
    status IN VARCHAR2
  )
IS
  l_ret VARCHAR2  (20)  ;
  num1_tbl DBMS_SQL.NUMBER_TABLE;
  num2_tbl DBMS_SQL.NUMBER_TABLE;
  num3_tbl DBMS_SQL.NUMBER_TABLE;
  l_char1_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_char2_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_char3_tbl DBMS_SQL.VARCHAR2_TABLE;
l_api_name VARCHAR2  (20):='file_versions';
  l_log VARCHAR2
  (
    4000
  )
  ;
  CURSOR c
  IS
    SELECT char1 ,
      char2 ,
      char3,
      num1,
      num2,
      num3
    FROM po_session_gt
    WHERE index_char1 = ICX_ITEM_DIAG_PVT.g_file_key;

  l_limit NUMBER:=100;
BEGIN
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start file_versions');
  l_ret := init_file_versions;
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'printing session gt ');
  OPEN c ;
  LOOP
    FETCH c BULK COLLECT
    INTO l_char1_tbl,
      l_char2_tbl,
      l_char3_tbl,
      num1_tbl,
      num2_tbl,
      num3_tbl LIMIT l_limit;
    EXIT
  WHEN l_char1_tbl.COUNT = 0;
    FOR i               IN 1 .. l_char1_tbl.COUNT
    LOOP
      ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'finally i='|| l_char1_tbl(i)|| ' l_char2_tbl='||l_char2_tbl(i)||' l_char3_tbl='||l_char3_tbl(i)||' num1_tbl='||num1_tbl(i)||' num2_tbl='||num2_tbl(i)||' num3_tbl='||num3_tbl(i));
    END LOOP ;
  END LOOP ;
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'end file_versions');
EXCEPTION
WHEN OTHERS THEN
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'exception file_versions'||sqlerrm||SQLCODE );
END file_versions;

procedure get_setup_values ( p_table_name in VARCHAR2 ,
 														 p_col_val out NOCOPY DBMS_SQL.VARCHAR2_TABLE,
														 p_row_val  out NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE)
is

cursor OU_INV is
select ORG_ID, org.SHORT_CODE OU_CODE, org.NAME OU_NAME ,
fsp.INVENTORY_ORGANIZATION_ID inventory_ORGANIZATION, org1.ORGANIZATION_CODE INV_ORG_CODE,org1.ORGANIZATION_NAME INV_ORG_NAME
,mparams.MASTER_ORGANIZATION_ID
from financials_system_params_all fsp, hr_operating_units  org ,org_organization_definitions org1 ,mtl_parameters mparams
where fsp.org_id =ICX_ITEM_DIAG_PVT.g_org_id
and fsp.org_id =org.ORGANIZATION_ID
and fsp.INVENTORY_ORGANIZATION_ID=org1.ORGANIZATION_ID
AND mparams.organization_id=fsp.INVENTORY_ORGANIZATION_ID;

cursor cat_set is
SELECT  functional_area_id
       ,category_set_id
       ,validate_flag
       ,structure_id
FROM    mtl_default_sets_view
WHERE   functional_area_id = 2;

l_api_name VARCHAR2  (20):='get_setup_values';

begin

p_col_val(1):= 'Operating Unit ID'; p_col_val(2):= 'ORG_CODE'; p_col_val(3):= 'ORG_NAME';
p_col_val(4):= 'Inventory Oragnization ID'; p_col_val(5):= 'INV_ORG_CODE'; p_col_val(6):= 'INV_ORG_NAME';
p_col_val(7):= 'Master Organization ID';
p_col_val(8):= 'Functional Area ID'; p_col_val(9):= 'Category Set Id'; p_col_val(10):= 'Validate Flag';
p_col_val(11):= 'Structure ID';


p_row_val(1)(1):='';p_row_val(1)(2):='';p_row_val(1)(3):='';p_row_val(1)(4):='';
p_row_val(1)(5):='';p_row_val(1)(6):='';p_row_val(1)(7):='';p_row_val(1)(8):='';
p_row_val(1)(9):='';p_row_val(1)(10):='';p_row_val(1)(11):='';


open OU_INV;
fetch OU_INV into p_row_val(1)(1),p_row_val(1)(2),p_row_val(1)(3),p_row_val(1)(4),p_row_val(1)(5),p_row_val(1)(6),p_row_val(1)(7);
close OU_INV;

open cat_set;
fetch cat_set into p_row_val(1)(8),p_row_val(1)(9),p_row_val(1)(10),p_row_val(1)(11);
close cat_set;

g_organization_id := p_row_val(1)(4);
g_master_organization_id := p_row_val(1)(7);
g_category_set_id := p_row_val(1)(9);
ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'g_organization_id='||g_organization_id||' g_master_organization_id'||g_master_organization_id||' g_category_set_id'||g_category_set_id);
exception when others then
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'get_setup_values '||sqlerrm||' code='||sqlcode);

end get_setup_values ;

procedure get_IDs_values ( p_table_name in VARCHAR2
												 , p_col_num out NOCOPY NUMBER
    								     , p_row_num out NOCOPY NUMBER
 												 , p_col_val out NOCOPY DBMS_SQL.VARCHAR2_TABLE
												 , p_row_val  out NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE)
is
i number;
l_cat_num number;
l_old_organization_id varchar2(100);
cursor mi(j number) is
SELECT  inventory_item_id       ,organization_id   ,segment1    ,internal_order_enabled_flag
       ,purchasing_enabled_flag ,outside_operation_flag,list_price_per_unit
       ,rfq_required_flag       ,primary_uom_code     ,replenish_to_order_flag  ,base_item_id
       ,auto_created_config_flag,nvl( (select 'Not Valid Record' from dual where  replenish_to_order_flag = 'Y'
                        AND base_item_id IS NOT NULL
                        AND auto_created_config_flag = 'Y'), 'Valid Record') RULE_1_ISVALID ,
  nvl( ( select 'Not Valid Record' from dual
	   where nvl(internal_order_enabled_flag,'N') ='N'
	     and ( list_price_per_unit is null or nvl(outside_operation_flag,'Y') ='Y' ) ),'Valid Record')   RULE_2_ISVALID
FROM    mtl_system_items_b
WHERE   inventory_item_id = g_source_ids(j)
AND     organization_id =nvl(g_organization_id,organization_id) ;

cursor mtl(j number) is
SELECT  inventory_item_id,organization_id,language
		      ,source_lang       ,description    ,long_description
					,nvl(( select 'Not Valid Record' from dual
							   where  mtl.language <> mtl.source_lang), 'Valid Record') RULE_1_ISVALID
FROM    mtl_system_items_tl mtl
WHERE   mtl.inventory_item_id =  g_source_ids(j)
AND     mtl.organization_id =  nvl(g_organization_id,organization_id) ;

cursor mic(j number) is
select inventory_item_id ,organization_id,category_set_id, mic.category_id PO_CATEGORY, nvl(i.category_key ,-2) category_key,'Validate'
	    FROM mtl_item_categories mic , icx_por_category_data_sources i
		WHERE mic.inventory_item_id =  g_source_ids(j)
        AND mic.organization_id =  nvl(g_organization_id,mic.organization_id)
        AND mic.category_set_id = g_category_set_id
		and i.external_source(+)  = 'Oracle'
		and i.external_source_key(+) = TO_CHAR(mic.category_id)
order by mic.inventory_item_id,mic.organization_id;

cursor muom(j number) is
SELECT  mi.inventory_item_id       ,mi.organization_id ,    muom.unit_of_measure,muom.uom_code
FROM    mtl_units_of_measure muom,mtl_system_items_b mi
WHERE   mi.inventory_item_id = g_source_ids(j)
AND     mi.organization_id = nvl(g_organization_id,mi.organization_id)
AND    	 muom.uom_code = mi.primary_uom_code   ;

cursor ip_cat(j number) is
SELECT mtl.inventory_item_id       ,mtl.organization_id, i.language,
			nvl (i.rt_category_id,- 2) ip_category_id,i.category_name ip_category_name
FROM    icx_cat_categories_tl i
       ,mtl_system_items_tl mtl
WHERE   mtl.inventory_item_id = g_source_ids(j)
AND     mtl.organization_id = nvl(g_organization_id,mtl.organization_id)
AND     i.key = g_category_key(j)
AND     i.type = 2
AND     i.language = mtl.language;

cursor hdrs(j number) is
SELECT  inventory_item_id      	,po_line_id  						     ,req_template_name
       ,req_template_line_num   ,org_id   								   ,language
			 ,unit_price      			 	,unit_meas_lookup_code       ,line_type_id
       ,document_number    		  ,item_type   							   ,supplier_site_id
       ,supplier_id   			    ,po_category_id   				   ,ip_category_id
       ,ip_category_name        ,source_type       , decode(ip_category_id,-2,'May not be searchable',decode(supplier_id,-2,'May not be searchable',null)) WARNING
FROM    icx_cat_items_ctx_hdrs_tlp
WHERE   inventory_item_id =g_source_ids(j)
AND     org_id = nvl(g_org_id,org_id)
order by language,source_type;

cursor dtls(j number) is
SELECT inventory_item_id       ,po_line_id       ,req_template_name
       ,req_template_line_num  ,org_id           ,language
			 ,SEQUENCE							 , htf.escape_sc(CTX_DESC)
FROM icx_cat_items_ctx_dtls_tlp
WHERE inventory_item_id  =g_source_ids(j)
AND     org_id = nvl(g_org_id,org_id)
order by po_line_id       ,req_template_name,language , sequence;

cursor sqe is
select rownum,SQE_OWNER#,SQE_NAME,SQE_QUERY from ctxsys.dr$sqe
where SQE_NAME in (
    SELECT UPPER(decode( fnd_profile.value('REQUISITION_TYPE'),'INTERNAL','icxzi','PURCHASE','icxzp','icxzb') || SQE_SEQUENCE)
    FROM
       ICX_CAT_CONTENT_ZONES_B zoneb,
       ICX_CAT_STORE_CONTENTS_V contentv
    WHERE
    zoneb.ZONE_ID = contentv.CONTENT_ID AND
    zoneb.TYPE ='LOCAL'  );


cursor po_attr(j number) is
select
INVENTORY_ITEM_ID,ORG_ID,PO_LINE_ID,REQ_TEMPLATE_NAME,REQ_TEMPLATE_LINE_NUM,IP_CATEGORY_ID,MANUFACTURER_PART_NUM,LEAD_TIME,PICTURE,THUMBNAIL_IMAGE,SUPPLIER_URL,MANUFACTURER_URL,ATTACHMENT_URL,UNSPSC,AVAILABILITY
from po_attribute_values
WHERE INVENTORY_ITEM_ID =g_source_ids(j)
and org_id = g_org_id;

cursor po_attr_tlp(j number) is
select INVENTORY_ITEM_ID,ORG_ID,LANGUAGE,PO_LINE_ID,REQ_TEMPLATE_NAME,REQ_TEMPLATE_LINE_NUM,IP_CATEGORY_ID,DESCRIPTION,MANUFACTURER,LONG_DESCRIPTION
from po_attribute_values_tlp
WHERE INVENTORY_ITEM_ID =g_source_ids(j)
and org_id = g_org_id;

cursor icx_attr(j number) is
select
INVENTORY_ITEM_ID,ORG_ID,PO_LINE_ID,REQ_TEMPLATE_NAME,REQ_TEMPLATE_LINE_NUM,IP_CATEGORY_ID,MANUFACTURER_PART_NUM,LEAD_TIME,PICTURE,THUMBNAIL_IMAGE,SUPPLIER_URL,MANUFACTURER_URL,ATTACHMENT_URL,UNSPSC,AVAILABILITY
from icx_cat_attribute_values
WHERE INVENTORY_ITEM_ID =g_source_ids(j)
and org_id = g_org_id;

cursor icx_attr_tlp(j number) is
select INVENTORY_ITEM_ID,ORG_ID,LANGUAGE,PO_LINE_ID,REQ_TEMPLATE_NAME,REQ_TEMPLATE_LINE_NUM,IP_CATEGORY_ID,DESCRIPTION,MANUFACTURER,LONG_DESCRIPTION
from icx_cat_attribute_values_tlp
WHERE INVENTORY_ITEM_ID =g_source_ids(j)
and org_id = g_org_id;

cursor po_gt is
select index_char1,num1,num2,num3,num4,char1,char2,char3,char4
from po_session_gt
WHERE index_char1 = ICX_ITEM_DIAG_PVT.g_error_key ;

l_api_name VARCHAR2  (20):='get_IDs_values';

begin
ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'start');
if p_table_name = 'MTL_SYSTEM_ITEMS_B' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'1');
	p_col_val(1):= 'INVENTORY_ITEM_ID';
	p_col_val(2):= 'ORGANIZATION_ID';
	p_col_val(3):= 'SEGMENT1';
	p_col_val(4):= 'IS INTERNAL?';
	p_col_val(5):= 'IS PURCHASABLE?';
	p_col_val(6):= 'OUTSIDE OPERATION FLAG';
	p_col_val(7):= 'LIST PRICE';
	p_col_val(8):= 'RFQ REQUIRED FLAG';
	p_col_val(9):= 'PRIMARY UOM CODE';
	p_col_val(10):= 'REPLENISH TO ORDER FLAG';
	p_col_val(11):= 'BASE ITEM ID';
	p_col_val(12):= 'AUTO CREATED CONFIG FLAG';
	p_col_val(13):= 'Rule 1';
	p_col_val(14):= 'Rule 2';

	p_row_num:=1;

--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'12 g_source_ids.count'||g_source_ids.count);
	for j in 1.. g_source_ids.count loop
	--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'12 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
	--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open mi(j);
		 loop
		 fetch mi  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
																p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
																p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
																p_row_val(p_row_num)(10),p_row_val(p_row_num)(11),p_row_val(p_row_num)(12),
																p_row_val(p_row_num)(13),p_row_val(p_row_num)(14);
 			 if mi%ROWCOUNT <1 then
				 	add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(5),
									num1 => g_source_ids(j),
									num2 => g_organization_id,
									num3 => -2,
									num4 => g_org_id,
									char2 =>'-2',
									char3 =>'-2');
	     end if;
				exit when mi%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;

		 close mi;
	 end loop;
	 p_col_num :=14;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'MTL_SYSTEM_ITEMS_TL' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'2');
	p_col_val(1):= 'INVENTORY_ITEM_ID';
	p_col_val(2):= 'ORGANIZATION_ID';
	p_col_val(3):= 'LANGUAGE';
	p_col_val(4):= 'SOURCE_LANG';
	p_col_val(5):= 'DESCRIPTION';
	p_col_val(6):= 'LONG_DESCRIPTION';
	p_col_val(7):= 'Rule 1';
	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'22 g_source_ids.count'||g_source_ids.count);
	for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'22 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);
		open mtl(j);
		 loop
		 fetch mtl  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
																p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
																p_row_val(p_row_num)(7);
				exit when mtl%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close mtl;
	 end loop;
	 p_col_num :=7;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'MTL_ITEM_CATEGORIES' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'3');
	p_col_val(1):= 'INVENTORY_ITEM_ID';
	p_col_val(2):= 'ORGANIZATION_ID';
	p_col_val(3):= 'CATEGORY_SET_ID';
	p_col_val(4):= 'PO_CATEGORY_ID';
	p_col_val(5):= 'CATEGORY_KEY';
	p_col_val(6):= 'Rule 1';
	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'32 g_source_ids.count'||g_source_ids.count);
 for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'32 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);
		l_cat_num:=0;
		l_old_organization_id :='-2';
		open mic(j);
		 loop
		 fetch mic  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
																p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6);
				exit when mic%NOTFOUND ;
     if(l_old_organization_id = '-2') then
			l_old_organization_id:=p_row_val(p_row_num)(2);
     end if;
		g_category_key(j) := p_row_val(p_row_num)(5);
		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'32 categoryid='||g_category_key(j)||' l_old_organization_id='||l_old_organization_id|| ' compare with '||p_row_val(p_row_num)(2) || ' l_cat_num='||l_cat_num);


     if(l_old_organization_id=p_row_val(p_row_num)(2)) then
		   l_cat_num:=l_cat_num+1;
     else
       if l_cat_num >1 then
									  p_row_val(p_row_num-1)(6):='NOT VALID';
						 				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(1),
															num1 => g_source_ids(j),
															num2 => p_row_val(p_row_num-1)(2),
															num3 => -2,
															num4 => g_org_id,
															char2 =>'-2',
															char3 =>'-2',
						                  char4 =>  p_row_val(p_row_num-1)(4) );
		    elsif l_cat_num =1 AND  p_row_val(p_row_num-1)(5) ='-2'   then
  								  p_row_val(p_row_num-1)(6):='May not be searchable';
						 				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(2),
															num1 => g_source_ids(j),
															num2 => p_row_val(p_row_num-1)(2),
															num3 => -2,
															num4 => g_org_id,
															char2 =>'-2',
															char3 =>'-2',
						                  char4 =>  p_row_val(p_row_num-1)(4) );
				end if;
      end if;

/*--			l_cat_num:=l_cat_num+1;
     if(l_old_organization_id<>p_row_val(p_row_num)(2)) then
						ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'l_cat_num='||l_cat_num );
						 -- too many po category assigned to master item.
						   if l_cat_num <>1 then
						        p_row_val(p_row_num-1)(6):='May not be searchable';
						   			g_category_key(j) := '-2';
						 		if l_cat_num >1 then
						 				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(1),
															num1 => g_source_ids(j),
															num2 => p_row_val(p_row_num)(2),
															num3 => -2,
															num4 => g_org_id,
															char2 =>'-2',
															char3 =>'-2',
						                  char4 =>  p_row_val(1)(4) );
						    else
						 				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(2),
															num1 => g_source_ids(j),
															num2 => p_row_val(p_row_num)(2),
															num3 => -2,
															num4 => g_org_id,
															char2 =>'-2',
															char3 =>'-2',
						                  char4 =>  p_row_val(1)(4) );
						   end if;
						   else
						   			g_category_key(j) := p_row_val(1)(5);
										if ( g_category_key(j) ='-2' ) then
												add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(3),
																	num1 => g_source_ids(j),
																	num2 => p_row_val(p_row_num)(2),
																	num3 => -2,
																	num4 => g_org_id,
																	char2 =>'-2',
																	char3 =>'-2',
																	char4 => p_row_val(1)(4));
										end if;
									  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'po category id='||p_row_val(1)(4)||'g_category_key='||g_category_key(j) );
						   end if;

      		l_old_organization_id:=p_row_val(p_row_num)(2);
       		l_cat_num:=1;
	   else
		 	 l_cat_num:=l_cat_num+1;
	   end if;
     if p_row_val(p_row_num)(5) = '-2' then
     p_row_val(p_row_num)(6):='May not be searchable';
		 else
     p_row_val(p_row_num)(6):='';
     end if;*/

		 p_row_num:=p_row_num+1;
  	 end loop;
		 close mic;
	 end loop;
	 p_col_num :=6;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'MTL_UNITS_OF_MEASURE' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'4');
	p_col_val(1):= 'INVENTORY_ITEM_ID';
	p_col_val(2):= 'ORGANIZATION_ID';
	p_col_val(3):= 'Unit of Measure';
	p_col_val(4):= 'UOM Code';
	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'42 g_source_ids.count'||g_source_ids.count);
 for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'42 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);
		open muom(j);
		 loop
		 fetch muom  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
																p_row_val(p_row_num)(4);
				exit when muom%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close muom;
	 end loop;
	 p_col_num :=4;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'ICX_CAT_CATEGORIES_TL' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'5');
	p_col_val(1):= 'INVENTORY_ITEM_ID';
	p_col_val(2):= 'ORGANIZATION_ID';
	p_col_val(3):= 'Language';
	p_col_val(4):= 'IP Category ID';
	p_col_val(5):= 'IP Category Name';
	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'52 g_source_ids.count'||g_source_ids.count);
 for j in 1.. g_source_ids.count loop
		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'52 g_category_key(j) ='||g_category_key(j) );
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);
  if 	g_category_key(j) <> '-2' then
  	open ip_cat(j);
		 loop
		 fetch ip_cat  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
																p_row_val(p_row_num)(4),	p_row_val(p_row_num)(5);
				exit when ip_cat%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close ip_cat;

   end if;
	 end loop;
	 p_col_num :=5;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'ICX_CAT_ITEMS_CTX_HDRS_TLP' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'6');
	p_col_val(1):='INVENTORY_ITEM_ID';
	p_col_val(2):='PO_LINE_ID';
	p_col_val(3):='REQ_TEMPLATE_NAME';
	p_col_val(4):='REQ_TEMPLATE_LINE_NUM';
	p_col_val(5):='ORG_ID';
	p_col_val(6):='LANGUAGE';
	p_col_val(7):='UNIT_PRICE';
	p_col_val(8):='UNIT_MEAS_LOOKUP_CODE';
	p_col_val(9):='LINE_TYPE_ID';
	p_col_val(10):='DOCUMENT_NUMBER';
	p_col_val(11):='ITEM_TYPE';
	p_col_val(12):='SUPPLIER_SITE_ID';
	p_col_val(13):='SUPPLIER_ID';
	p_col_val(14):='PO_CATEGORY_ID';
	p_col_val(15):='IP_CATEGORY_ID';
	p_col_val(16):='IP_CATEGORY_NAME';
	p_col_val(17):='SOURCE_TYPE';
	p_col_val(18):='WARNING';

	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'62 g_source_ids.count'||g_source_ids.count);
 for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'62 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open hdrs(j);
		 loop
		 fetch hdrs  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
											p_row_val(p_row_num)(10),p_row_val(p_row_num)(11),p_row_val(p_row_num)(12),
											p_row_val(p_row_num)(13),p_row_val(p_row_num)(14),p_row_val(p_row_num)(15),
											p_row_val(p_row_num)(16),p_row_val(p_row_num)(17),p_row_val(p_row_num)(18);
				exit when hdrs%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close hdrs;
	 end loop;
	 p_col_num :=18;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'ICX_CAT_ITEMS_CTX_DTLS_TLP' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'7');
	p_col_val(1):='INVENTORY_ITEM_ID';
	p_col_val(2):='PO_LINE_ID';
	p_col_val(3):='REQ_TEMPLATE_NAME';
	p_col_val(4):='REQ_TEMPLATE_LINE_NUM';
	p_col_val(5):='ORG_ID';
	p_col_val(6):='LANGUAGE';
	p_col_val(7):='SEQUENCE';
	p_col_val(8):='CTX_DESC';

	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'72 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'72 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open dtls(j);
		 loop
		 fetch dtls  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8);
				exit when dtls%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close dtls;
	 end loop;
	 p_col_num :=8;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'DR$SQE' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'8');
	 p_col_val(1):='ROWNUM';
	 p_col_val(2):='SQE_OWNER#';
	 p_col_val(3):='SQE_NAME';
	 p_col_val(4):='SQE_QUERY';


	p_row_num:=1;
	--ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'82 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'82 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open sqe;
		 loop
		 fetch sqe  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4);
				exit when sqe%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close sqe;
	 end loop;
	 p_col_num :=4;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'PO_ATTRIBUTE_VALUES' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'9');
	 p_col_val(1):='INVENTORY_ITEM_ID';
	 p_col_val(2):='ORG_ID';
	 p_col_val(3):='PO_LINE_ID';
	 p_col_val(4):='REQ_TEMPLATE_NAME';
	 p_col_val(5):='REQ_TEMPLATE_LINE_NUM';
	 p_col_val(6):='IP_CATEGORY_ID';
	 p_col_val(7):='MANUFACTURER_PART_NUM';
	 p_col_val(8):='LEAD_TIME';
	 p_col_val(9):='PICTURE';
	 p_col_val(10):='THUMBNAIL_IMAGE';
	 p_col_val(11):='SUPPLIER_URL';
	 p_col_val(12):='MANUFACTURER_URL';
	 p_col_val(13):='ATTACHMENT_URL';
	 p_col_val(14):='UNSPSC';
	 p_col_val(15):='AVAILABILITY';


	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'92 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'92 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open po_attr(j);
		 loop
		 fetch po_attr  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
											p_row_val(p_row_num)(10),p_row_val(p_row_num)(11),p_row_val(p_row_num)(12),
											p_row_val(p_row_num)(13),p_row_val(p_row_num)(14),p_row_val(p_row_num)(15);
				exit when po_attr%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close po_attr;
	 end loop;
	 p_col_num :=15;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);


elsif p_table_name = 'PO_ATTRIBUTE_VALUES_TLP' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'10');
	 p_col_val(1):='INVENTORY_ITEM_ID';
	 p_col_val(2):='ORG_ID';
	 p_col_val(3):='LANGUAGE';
	 p_col_val(4):='PO_LINE_ID';
	 p_col_val(5):='REQ_TEMPLATE_NAME';
	 p_col_val(6):='REQ_TEMPLATE_LINE_NUM';
	 p_col_val(7):='IP_CATEGORY_ID';
	 p_col_val(8):='DESCRIPTION';
	 p_col_val(9):='MANUFACTURER';
	 p_col_val(10):='LONG_DESCRIPTION';

	p_row_num:=1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'102 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'102 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open po_attr_tlp(j);
		 loop
		 fetch po_attr_tlp  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
											p_row_val(p_row_num)(10);
				exit when po_attr_tlp%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close po_attr_tlp;
	 end loop;
	 p_col_num :=10;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'ICX_CAT_ATTRIBUTE_VALUES' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'11');
	 p_col_val(1):='INVENTORY_ITEM_ID';
	 p_col_val(2):='ORG_ID';
	 p_col_val(3):='PO_LINE_ID';
	 p_col_val(4):='REQ_TEMPLATE_NAME';
	 p_col_val(5):='REQ_TEMPLATE_LINE_NUM';
	 p_col_val(6):='IP_CATEGORY_ID';
	 p_col_val(7):='MANUFACTURER_PART_NUM';
	 p_col_val(8):='LEAD_TIME';
	 p_col_val(9):='PICTURE';
	 p_col_val(10):='THUMBNAIL_IMAGE';
	 p_col_val(11):='SUPPLIER_URL';
	 p_col_val(12):='MANUFACTURER_URL';
	 p_col_val(13):='ATTACHMENT_URL';
	 p_col_val(14):='UNSPSC';
	 p_col_val(15):='AVAILABILITY';


	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'112 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'112 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open icx_attr(j);
		 loop
		 fetch icx_attr  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
											p_row_val(p_row_num)(10),p_row_val(p_row_num)(11),p_row_val(p_row_num)(12),
											p_row_val(p_row_num)(13),p_row_val(p_row_num)(14),p_row_val(p_row_num)(15);
				exit when icx_attr%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close icx_attr;
	 end loop;
	 p_col_num :=15;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);


elsif p_table_name = 'ICX_CAT_ATTRIBUTE_VALUES_TLP' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'12');
	 p_col_val(1):='INVENTORY_ITEM_ID';
	 p_col_val(2):='ORG_ID';
	 p_col_val(3):='LANGUAGE';
	 p_col_val(4):='PO_LINE_ID';
	 p_col_val(5):='REQ_TEMPLATE_NAME';
	 p_col_val(6):='REQ_TEMPLATE_LINE_NUM';
	 p_col_val(7):='IP_CATEGORY_ID';
	 p_col_val(8):='DESCRIPTION';
	 p_col_val(9):='MANUFACTURER';
	 p_col_val(10):='LONG_DESCRIPTION';

	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'122 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'122 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open icx_attr_tlp(j);
		 loop
		 fetch icx_attr_tlp  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9),
											p_row_val(p_row_num)(10);
				exit when icx_attr_tlp%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close icx_attr_tlp;
	 end loop;
	 p_col_num :=10;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

elsif p_table_name = 'PO_SESSION_GT' then
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'13');
	 p_col_val(1):='INDEX_CHAR1';
	 p_col_val(2):='NUM1';
	 p_col_val(3):='NUM2';
	 p_col_val(4):='NUM3';
	 p_col_val(5):='NUM4';
	 p_col_val(6):='CHAR1';
	 p_col_val(7):='CHAR2';
	 p_col_val(8):='CHAR3';
	 p_col_val(9):='CHAR4';


	p_row_num:=1;
--	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'132 g_source_ids.count'||g_source_ids.count);
  for j in 1.. g_source_ids.count loop
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'132 g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id'||g_organization_id);
--		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num);

		open po_gt;
		 loop
		 fetch po_gt  into p_row_val(p_row_num)(1),p_row_val(p_row_num)(2),p_row_val(p_row_num)(3),
											p_row_val(p_row_num)(4),p_row_val(p_row_num)(5),p_row_val(p_row_num)(6),
											p_row_val(p_row_num)(7),p_row_val(p_row_num)(8),p_row_val(p_row_num)(9);
				exit when po_gt%NOTFOUND ;
			p_row_num:=p_row_num+1;
		 end loop;
		 close po_gt;
	 end loop;
	 p_col_num :=9;
	 p_row_num:=p_row_num-1;
	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || ' p_col_num='||p_col_num);

end if;
exception when others then
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'get_IDs_values '||sqlerrm||' code='||sqlcode);

end get_IDs_values;


procedure validate_values ( p_table_name in VARCHAR2
												 , p_col_num out NOCOPY NUMBER
    								     , p_row_num out NOCOPY NUMBER
 												 , p_col_val out NOCOPY DBMS_SQL.VARCHAR2_TABLE
												 , p_row_val  out NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE) is

l_row_val  ICX_ITEM_DIAG_GRP.VARCHAR_TABLE;
l_api_name VARCHAR2  (20):='validate_values';

cursor validate(j number) is
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ROWIDTOCHAR(ctx.rowid) ctx_rowid,
					 null IS_VALID
    FROM
         (
           SELECT  /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  mi.inventory_item_id inventory_item_id,
                  -2 po_line_id,
                  -2 req_template_name,
                  -2 req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id
           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap
           WHERE mi.inventory_item_id = g_source_ids(j)
           AND mi.organization_id = mparams.organization_id
           AND (mparams.organization_id = nvl(g_organization_id,mparams.organization_id)
                OR mparams.master_organization_id =nvl(g_organization_id,mparams.master_organization_id))
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = 2
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+)
    order by doc.ORG_ID,doc.LANGUAGE ;
begin
 p_col_val(1):='INVENTORY_ITEM_ID';
 p_col_val(2):='PO_LINE_ID';
 p_col_val(3):='REQ_TEMPLATE_NAME';
 p_col_val(4):='REQ_TEMPLATE_LINE_NUM';
 p_col_val(5):='ORG_ID';
 p_col_val(6):='LANGUAGE';
 p_col_val(7):='SOURCE_TYPE';
 p_col_val(8):='PURCHASING_ORG_ID';
 p_col_val(9):='PO_CATEGORY_ID';
 p_col_val(10):='CATEGORY_KEY';
 p_col_val(11):='INTERNAL_ORDER_ENABLED_FLAG';
 p_col_val(12):='PURCHASING_ENABLED_FLAG';
 p_col_val(13):='OUTSIDE_OPERATION_FLAG';
 p_col_val(14):='UNIT_MEAS_LOOKUP_CODE';
 p_col_val(15):='UNIT_PRICE';
 p_col_val(16):='RFQ_REQUIRED_FLAG';
 p_col_val(17):='DESCRIPTION';
 p_col_val(18):='LONG_DESCRIPTION';
 p_col_val(19):='ORGANIZATION_ID';
 p_col_val(20):='MASTER_ORGANIZATION_ID';
 p_col_val(21):='IP_CATEGORY_ID';
 p_col_val(22):='IP_CATEGORY_NAME';
 p_col_val(23):='CTX_INVENTORY_ITEM_ID';
 p_col_val(24):='CTX_SOURCE_TYPE';
 p_col_val(25):='CTX_ITEM_TYPE';
 p_col_val(26):='CTX_PURCHASING_ORG_ID';
 p_col_val(27):='CTX_SUPPLIER_ID';
 p_col_val(28):='CTX_SUPPLIER_SITE_ID';
 p_col_val(29):='CTX_SUPPLIER_PART_NUM';
 p_col_val(30):='CTX_SUPPLIER_PART_AUXID';
 p_col_val(31):='CTX_IP_CATEGORY_ID';
 p_col_val(32):='CTX_PO_CATEGORY_ID';
 p_col_val(33):='CTX_IP_CATEGORY_NAME';
 p_col_val(34):='CTX_ROWID';
 p_col_val(35):='IS VALID?';

	p_row_num:=1;
  for j in 1.. g_source_ids.count loop
		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'validate g_source_ids(j)='||g_source_ids(j)|| ' g_organization_id='||g_organization_id);

	--if generic mode then at j=1 open validate(null) ; at j=2 exit

		open validate(j);
		 loop
		 fetch validate  into       l_row_val(p_row_num)(1),l_row_val(p_row_num)(2),l_row_val(p_row_num)(3),
																l_row_val(p_row_num)(4),l_row_val(p_row_num)(5),l_row_val(p_row_num)(6),
																l_row_val(p_row_num)(7),l_row_val(p_row_num)(8),l_row_val(p_row_num)(9),
																l_row_val(p_row_num)(10),l_row_val(p_row_num)(11),l_row_val(p_row_num)(12),
																l_row_val(p_row_num)(13),l_row_val(p_row_num)(14),l_row_val(p_row_num)(15),
																l_row_val(p_row_num)(16),l_row_val(p_row_num)(17),l_row_val(p_row_num)(18),
																l_row_val(p_row_num)(19),l_row_val(p_row_num)(20),l_row_val(p_row_num)(21),
																l_row_val(p_row_num)(22),l_row_val(p_row_num)(23),l_row_val(p_row_num)(24),
																l_row_val(p_row_num)(25),l_row_val(p_row_num)(26),l_row_val(p_row_num)(27),
																l_row_val(p_row_num)(28),l_row_val(p_row_num)(29),l_row_val(p_row_num)(30),
																l_row_val(p_row_num)(31),l_row_val(p_row_num)(32),l_row_val(p_row_num)(33),
																l_row_val(p_row_num)(34),l_row_val(p_row_num)(35);

  			exit when validate%NOTFOUND ;

        /*
 				validation 1 # If CATEGORY_KEY is null , then you need to create shopping category and mapping
											programmatically or manually
 				validation 2 # If CTX_IP_INVENTORY_ITEM_ID is -2 , then you need to reextract the item.
											icx_cat_items_ctx_hdrs_tlp record missing.
 				validation 3 # If CTX_IP_CATEGORY_ID is -2 , then you need to reextract the item.
 				validation 4 # validate item using api ICX_CAT_UTIL_PVT.is_item_valid_for_search
 				*/
				if l_row_val(p_row_num)(10) IS NULL THEN
					l_row_val(p_row_num)(35):=g_error_code(2);
   				add_error(char1 =>  g_error_code(2),
															num1 => l_row_val(p_row_num)(1),
															num2 => l_row_val(p_row_num)(19),
															num3 => l_row_val(p_row_num)(2),
															num4 => l_row_val(p_row_num)(5),
															char2 =>l_row_val(p_row_num)(3),
															char3 =>l_row_val(p_row_num)(4),
						                  char4 =>l_row_val(p_row_num)(9));
				elsif  l_row_val(p_row_num)(23) is null or l_row_val(p_row_num)(23) = '-2' then
					l_row_val(p_row_num)(35):=g_error_code(6);
   				add_error(char1 => g_error_code(6),
															num1 => l_row_val(p_row_num)(1),
															num2 => l_row_val(p_row_num)(19),
															num3 => l_row_val(p_row_num)(2),
															num4 => l_row_val(p_row_num)(5),
															char2 =>l_row_val(p_row_num)(3),
															char3 =>l_row_val(p_row_num)(4));

				elsif  l_row_val(p_row_num)(31) is null or l_row_val(p_row_num)(31) = '-2' then
					l_row_val(p_row_num)(35):=g_error_code(3);
   				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(3),
															num1 => l_row_val(p_row_num)(1),
															num2 => l_row_val(p_row_num)(19),
															num3 => l_row_val(p_row_num)(2),
															num4 => l_row_val(p_row_num)(5),
															char2 =>l_row_val(p_row_num)(3),
															char3 =>l_row_val(p_row_num)(4),
						                  char4 =>l_row_val(p_row_num)(9));

				elsif ( ICX_CAT_UTIL_PVT.is_item_valid_for_search(l_row_val(p_row_num)(7),
																												to_number(l_row_val(p_row_num)(2)),
																												l_row_val(p_row_num)(3),
																											  to_number(l_row_val(p_row_num)(4)),
																											  to_number(l_row_val(p_row_num)(9)),
																											  to_number(l_row_val(p_row_num)(5))
																														) =0 ) then
					l_row_val(p_row_num)(35):=g_error_code(7);
   				add_error(char1 => ICX_ITEM_DIAG_PVT.g_error_code(7),
															num1 => l_row_val(p_row_num)(9), --po_category_id
															num2 => l_row_val(p_row_num)(19),
															num3 => l_row_val(p_row_num)(2),
															num4 => l_row_val(p_row_num)(5),
															char2 =>l_row_val(p_row_num)(3),
															char3 =>l_row_val(p_row_num)(4),
						                  char4 =>l_row_val(p_row_num)(7)); --source_type
        end if;

        if 	l_row_val(p_row_num)(35) is not null then
        	p_row_val(p_row_num):= l_row_val(p_row_num);
  				p_row_num:=p_row_num+1;
 				end if;

		 end loop;
		 close validate;
	 end loop;
		 p_col_num :=35;
  	 p_row_num:=p_row_num-1;
   	ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'p_row_num='||p_row_num || 'p_col_num='||p_col_num);


    create_missing_data;

exception when others then
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'validate_values '||sqlerrm||' code='||sqlcode);

end validate_values;

procedure create_missing_data
is
l_option_value varchar2(10);
l_api_name VARCHAR2  (20):='create_missing_data';

cursor create_ip_cat is
select distinct to_number(CHAR4) from po_session_gt
where INDEX_CHAR1='ITEM_DIAG_ERRORS'
and   CHAR1='IP_CATEGORY_MISSING';

cursor create_mappings is
select distinct to_number(CHAR4) from po_session_gt
where INDEX_CHAR1='ITEM_DIAG_ERRORS'
and   CHAR1=g_error_code(3)
AND   CHAR4 NOT IN (select distinct CHAR4 from po_session_gt
where INDEX_CHAR1='ITEM_DIAG_ERRORS'
and   CHAR1='IP_CATEGORY_MISSING') ;

cursor create_ctx_hdrs is
select distinct num1, num2 from po_session_gt
where INDEX_CHAR1='ITEM_DIAG_ERRORS'
and   CHAR1='ICX_CTX_HDRS_MISSING';

l_inv_item_id number;
l_organization_id number;
l_po_category_id  number;
l_ret varchar2(1000);
begin
IF g_auto_map_category = 'Y' THEN
	 fnd_profile.get('POR_AUTO_CREATE_SHOPPING_CAT', l_option_value);
	 ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'1 POR_AUTO_CREATE_SHOPPING_CAT='||l_option_value);
	 fnd_profile.put('POR_AUTO_CREATE_SHOPPING_CAT', 'Y');

  open create_ip_cat;
  loop
  fetch create_ip_cat into l_po_category_id;
  exit when create_ip_cat%NOTFOUND;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting po_category_id='||l_po_category_id);
	  ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := TRUE;
		ICX_CAT_POPULATE_CATG_GRP.populateValidCategorySetInsert
		(       p_api_version     =>1.0                                 ,
		 p_commit          =>FND_API.G_TRUE		         ,
		 x_return_status   => l_ret                              ,
		 p_category_set_id => g_category_set_id                  ,
		 p_category_id     =>l_po_category_id
		);
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting over');

  end loop;
  close create_ip_cat;

   fnd_profile.put('POR_AUTO_CREATE_SHOPPING_CAT', l_option_value);

END IF;
l_po_category_id:=0;

 open create_mappings;
  loop
  fetch create_mappings into l_po_category_id;
  exit when create_mappings%NOTFOUND;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting item='||l_po_category_id);
    ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := TRUE;
		ICX_CAT_POPULATE_CATG_GRP.populateValidCategorySetInsert
		(p_api_version     =>1.0                                 ,
		 p_commit          =>FND_API.G_TRUE		                   ,
		 x_return_status   => l_ret                              ,
		 p_category_set_id => g_category_set_id                  ,
		 p_category_id     =>l_po_category_id
		);

    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting over');

  end loop;
  close create_mappings;

open create_ctx_hdrs;
  loop
  fetch create_ctx_hdrs into l_inv_item_id,l_organization_id;
  exit when create_ctx_hdrs%NOTFOUND;
		ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting inv_item_id='||l_inv_item_id|| ' organization_id'||l_organization_id );

   ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);
	 ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := FALSE;
	 ICX_CAT_POPULATE_MI_PVT.populateItemChange(l_inv_item_id, l_organization_id, NULL, NULL);
	 ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

end loop;
close create_ctx_hdrs;

commit;
exception when others then
  logUnexpectedException(g_pkg_name, l_api_name,'create_missing_data '||sqlerrm||' code='||sqlcode);

end create_missing_data;

procedure PO_ATTRIBUTE_VALUES_DATA_FIX is

CURSOR master_csr  IS
  SELECT *
  FROM icx_cat_items_ctx_hdrs_tlp ctx
  WHERE ctx.PO_LINE_ID=-2
    AND  ctx.REQ_TEMPLATE_NAME='-2'
    AND  ctx.REQ_TEMPLATE_LINE_NUM = -2
    AND    ctx.SOURCE_TYPE = 'MASTER_ITEM'
    AND NOT EXISTS ( SELECT 'Row Found for inventory item id'
             FROM  po_attribute_values poav
             WHERE  poav.INVENTORY_ITEM_ID = ctx.INVENTORY_ITEM_ID
		AND poav.ORG_ID = ctx.ORG_ID
		AND  poav.PO_LINE_ID=-2
		AND  poav.REQ_TEMPLATE_NAME='-2'
		AND  poav.REQ_TEMPLATE_LINE_NUM = -2)
ORDER BY INVENTORY_ITEM_ID;

rec_MI  icx_cat_items_ctx_hdrs_tlp%ROWTYPE;
l_organization_id         NUMBER;
l_master_organization_id  NUMBER;
l_long_description PO_ATTRIBUTE_VALUES_TLP.LONG_DESCRIPTION%TYPE;
l_api_name VARCHAR2(50) := 'PO_ATTRIBUTE_VALUES_DATA_FIX';
l_progress      VARCHAR2(4);
l_counter NUMBER := 0;
l_message VARCHAR2(4000);
l_item_invalid BOOLEAN := FALSE;
l_dummy  VARCHAR2(10);
l_skip   number;
BEGIN


 l_progress := '000';

 l_message :='Start of data fix';

	logStatement(g_pkg_name,  l_api_name ,l_message);


 OPEN master_csr ;
 LOOP
    l_skip:=0;
    FETCH master_csr into rec_MI;
    exit when master_csr%notfound;

    l_message := 'Cursor count=' || master_csr%ROWCOUNT;

    logStatement(g_pkg_name,  l_api_name ,l_message);
   begin
    SELECT  organization_id, master_organization_id
    INTO l_organization_id,l_master_organization_id
    FROM(
          SELECT  mparams.organization_id organization_id, mparams.master_organization_id  master_organization_id
          FROM    mtl_parameters mparams,financials_system_params_all fsp, mtl_system_items_b mtlb
          WHERE 	fsp.ORG_ID = rec_MI.ORG_ID
          AND mtlb.inventory_item_id = rec_MI.inventory_item_id
          AND mtlb.organization_id = mparams.organization_id
          AND (mparams.organization_id = fsp.INVENTORY_ORGANIZATION_ID
              OR mparams.master_organization_id = fsp.INVENTORY_ORGANIZATION_ID)
        ) WHERE ROWNUM =1;
  exception when others then
	  l_message := 'Exception at '||sqlerrm ||' sqlcode:'|| sqlcode ||'INVENTORY_ITEM_ID=' || rec_MI.INVENTORY_ITEM_ID || ', org_id: ' || rec_MI.ORG_ID ;
	  logStatement(g_pkg_name,  l_api_name ,l_message);
--	  continue;
	 l_skip:=1;
  end;
  if l_skip <> 1 then
  l_message := 'INVENTORY_ITEM_ID=' || rec_MI.INVENTORY_ITEM_ID || ' ,l_organization_id: ' || l_organization_id ||
  			 ', org_id: ' || rec_MI.ORG_ID || ', l_master_organization_id: ' || l_master_organization_id;


	    logStatement(g_pkg_name,  l_api_name ,l_message);



    l_item_invalid := FALSE;
    BEGIN
        SELECT  1
        INTO l_dummy
        FROM mtl_system_items_b
        WHERE     inventory_item_id = rec_MI.INVENTORY_ITEM_ID
        AND       organization_id = l_organization_id;
    EXCEPTION
    WHEN No_Data_Found THEN
    	--Item not assigend to the org now
	      l_item_invalid := TRUE;

	         logStatement(g_pkg_name,  l_api_name ,'item is not assigned to this org now');

    END;

    IF NOT l_item_invalid THEN
      PO_ATTRIBUTE_VALUES_PVT.create_default_attributes_MI
      (
      p_ip_category_id    =>  rec_MI.IP_CATEGORY_ID,
      p_inventory_item_id =>  rec_MI.INVENTORY_ITEM_ID,
      p_org_id            =>  rec_MI.ORG_ID,
      p_description       =>  rec_MI.DESCRIPTION,
      p_organization_id   =>  l_organization_id,
      p_master_organization_id =>  l_master_organization_id
      );

      Begin
        SELECT  LONG_DESCRIPTION
        INTO l_long_description
        FROM MTL_SYSTEM_ITEMS_TL
        WHERE     inventory_item_id = rec_MI.INVENTORY_ITEM_ID
        AND       organization_id = l_master_organization_id
        AND       LANGUAGE     = rec_MI.LANGUAGE;
      EXCEPTION
      WHEN No_Data_Found THEN
        l_long_description:='';
      END;
      PO_ATTRIBUTE_VALUES_PVT.create_attributes_tlp_MI
      (
      p_inventory_item_id      =>  rec_MI.INVENTORY_ITEM_ID,
      p_ip_category_id         =>  rec_MI.IP_CATEGORY_ID,
      p_org_id                 =>  rec_MI.ORG_ID,
      p_language               =>  rec_MI.LANGUAGE,
      p_description            =>  rec_MI.DESCRIPTION,
      p_long_description       =>  l_long_description,
      p_organization_id        =>  l_organization_id,
      p_master_organization_id =>  l_master_organization_id
      );

      MERGE INTO icx_cat_attribute_values icav
        USING (SELECT *
             FROM po_attribute_values
             WHERE inventory_item_id = rec_MI.INVENTORY_ITEM_ID
             AND   po_line_id = -2
             AND   req_template_name = '-2'
             AND   req_template_line_num = -2
             AND   org_id = rec_MI.ORG_ID) temp
        ON (icav.inventory_item_id = temp.inventory_item_id AND
          icav.po_line_id = temp.po_line_id AND
          icav.req_template_name = temp.req_template_name AND
          icav.req_template_line_num = temp.req_template_line_num AND
          icav.org_id = temp.org_id)
        WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.manufacturer_part_num, temp.picture, temp.thumbnail_image,
          temp.supplier_url, temp.manufacturer_url, temp.attachment_url, temp.unspsc,
          temp.availability, temp.lead_time,
          temp.text_base_attribute1, temp.text_base_attribute2, temp.text_base_attribute3,
          temp.text_base_attribute4, temp.text_base_attribute5, temp.text_base_attribute6,
          temp.text_base_attribute7, temp.text_base_attribute8, temp.text_base_attribute9,
          temp.text_base_attribute10, temp.text_base_attribute11, temp.text_base_attribute12,
          temp.text_base_attribute13, temp.text_base_attribute14, temp.text_base_attribute15,
          temp.text_base_attribute16, temp.text_base_attribute17, temp.text_base_attribute18,
          temp.text_base_attribute19, temp.text_base_attribute20, temp.text_base_attribute21,
          temp.text_base_attribute22, temp.text_base_attribute23, temp.text_base_attribute24,
          temp.text_base_attribute25, temp.text_base_attribute26, temp.text_base_attribute27,
          temp.text_base_attribute28, temp.text_base_attribute29, temp.text_base_attribute30,
          temp.text_base_attribute31, temp.text_base_attribute32, temp.text_base_attribute33,
          temp.text_base_attribute34, temp.text_base_attribute35, temp.text_base_attribute36,
          temp.text_base_attribute37, temp.text_base_attribute38, temp.text_base_attribute39,
          temp.text_base_attribute40, temp.text_base_attribute41, temp.text_base_attribute42,
          temp.text_base_attribute43, temp.text_base_attribute44, temp.text_base_attribute45,
          temp.text_base_attribute46, temp.text_base_attribute47, temp.text_base_attribute48,
          temp.text_base_attribute49, temp.text_base_attribute50, temp.text_base_attribute51,
          temp.text_base_attribute52, temp.text_base_attribute53, temp.text_base_attribute54,
          temp.text_base_attribute55, temp.text_base_attribute56, temp.text_base_attribute57,
          temp.text_base_attribute58, temp.text_base_attribute59, temp.text_base_attribute60,
          temp.text_base_attribute61, temp.text_base_attribute62, temp.text_base_attribute63,
          temp.text_base_attribute64, temp.text_base_attribute65, temp.text_base_attribute66,
          temp.text_base_attribute67, temp.text_base_attribute68, temp.text_base_attribute69,
          temp.text_base_attribute70, temp.text_base_attribute71, temp.text_base_attribute72,
          temp.text_base_attribute73, temp.text_base_attribute74, temp.text_base_attribute75,
          temp.text_base_attribute76, temp.text_base_attribute77, temp.text_base_attribute78,
          temp.text_base_attribute79, temp.text_base_attribute80, temp.text_base_attribute81,
          temp.text_base_attribute82, temp.text_base_attribute83, temp.text_base_attribute84,
          temp.text_base_attribute85, temp.text_base_attribute86, temp.text_base_attribute87,
          temp.text_base_attribute88, temp.text_base_attribute89, temp.text_base_attribute90,
          temp.text_base_attribute91, temp.text_base_attribute92, temp.text_base_attribute93,
          temp.text_base_attribute94, temp.text_base_attribute95, temp.text_base_attribute96,
          temp.text_base_attribute97, temp.text_base_attribute98, temp.text_base_attribute99,
          temp.text_base_attribute100,
          temp.num_base_attribute1, temp.num_base_attribute2, temp.num_base_attribute3,
          temp.num_base_attribute4, temp.num_base_attribute5, temp.num_base_attribute6,
          temp.num_base_attribute7, temp.num_base_attribute8, temp.num_base_attribute9,
          temp.num_base_attribute10, temp.num_base_attribute11, temp.num_base_attribute12,
          temp.num_base_attribute13, temp.num_base_attribute14, temp.num_base_attribute15,
          temp.num_base_attribute16, temp.num_base_attribute17, temp.num_base_attribute18,
          temp.num_base_attribute19, temp.num_base_attribute20, temp.num_base_attribute21,
          temp.num_base_attribute22, temp.num_base_attribute23, temp.num_base_attribute24,
          temp.num_base_attribute25, temp.num_base_attribute26, temp.num_base_attribute27,
          temp.num_base_attribute28, temp.num_base_attribute29, temp.num_base_attribute30,
          temp.num_base_attribute31, temp.num_base_attribute32, temp.num_base_attribute33,
          temp.num_base_attribute34, temp.num_base_attribute35, temp.num_base_attribute36,
          temp.num_base_attribute37, temp.num_base_attribute38, temp.num_base_attribute39,
          temp.num_base_attribute40, temp.num_base_attribute41, temp.num_base_attribute42,
          temp.num_base_attribute43, temp.num_base_attribute44, temp.num_base_attribute45,
          temp.num_base_attribute46, temp.num_base_attribute47, temp.num_base_attribute48,
          temp.num_base_attribute49, temp.num_base_attribute50, temp.num_base_attribute51,
          temp.num_base_attribute52, temp.num_base_attribute53, temp.num_base_attribute54,
          temp.num_base_attribute55, temp.num_base_attribute56, temp.num_base_attribute57,
          temp.num_base_attribute58, temp.num_base_attribute59, temp.num_base_attribute60,
          temp.num_base_attribute61, temp.num_base_attribute62, temp.num_base_attribute63,
          temp.num_base_attribute64, temp.num_base_attribute65, temp.num_base_attribute66,
          temp.num_base_attribute67, temp.num_base_attribute68, temp.num_base_attribute69,
          temp.num_base_attribute70, temp.num_base_attribute71, temp.num_base_attribute72,
          temp.num_base_attribute73, temp.num_base_attribute74, temp.num_base_attribute75,
          temp.num_base_attribute76, temp.num_base_attribute77, temp.num_base_attribute78,
          temp.num_base_attribute79, temp.num_base_attribute80, temp.num_base_attribute81,
          temp.num_base_attribute82, temp.num_base_attribute83, temp.num_base_attribute84,
          temp.num_base_attribute85, temp.num_base_attribute86, temp.num_base_attribute87,
          temp.num_base_attribute88, temp.num_base_attribute89, temp.num_base_attribute90,
          temp.num_base_attribute91, temp.num_base_attribute92, temp.num_base_attribute93,
          temp.num_base_attribute94, temp.num_base_attribute95, temp.num_base_attribute96,
          temp.num_base_attribute97, temp.num_base_attribute98, temp.num_base_attribute99,
          temp.num_base_attribute100,
          temp.text_cat_attribute1, temp.text_cat_attribute2, temp.text_cat_attribute3,
          temp.text_cat_attribute4, temp.text_cat_attribute5, temp.text_cat_attribute6,
          temp.text_cat_attribute7, temp.text_cat_attribute8, temp.text_cat_attribute9,
          temp.text_cat_attribute10, temp.text_cat_attribute11, temp.text_cat_attribute12,
          temp.text_cat_attribute13, temp.text_cat_attribute14, temp.text_cat_attribute15,
          temp.text_cat_attribute16, temp.text_cat_attribute17, temp.text_cat_attribute18,
          temp.text_cat_attribute19, temp.text_cat_attribute20, temp.text_cat_attribute21,
          temp.text_cat_attribute22, temp.text_cat_attribute23, temp.text_cat_attribute24,
          temp.text_cat_attribute25, temp.text_cat_attribute26, temp.text_cat_attribute27,
          temp.text_cat_attribute28, temp.text_cat_attribute29, temp.text_cat_attribute30,
          temp.text_cat_attribute31, temp.text_cat_attribute32, temp.text_cat_attribute33,
          temp.text_cat_attribute34, temp.text_cat_attribute35, temp.text_cat_attribute36,
          temp.text_cat_attribute37, temp.text_cat_attribute38, temp.text_cat_attribute39,
          temp.text_cat_attribute40, temp.text_cat_attribute41, temp.text_cat_attribute42,
          temp.text_cat_attribute43, temp.text_cat_attribute44, temp.text_cat_attribute45,
          temp.text_cat_attribute46, temp.text_cat_attribute47, temp.text_cat_attribute48,
          temp.text_cat_attribute49, temp.text_cat_attribute50,
          temp.num_cat_attribute1, temp.num_cat_attribute2, temp.num_cat_attribute3,
          temp.num_cat_attribute4, temp.num_cat_attribute5, temp.num_cat_attribute6,
          temp.num_cat_attribute7, temp.num_cat_attribute8, temp.num_cat_attribute9,
          temp.num_cat_attribute10, temp.num_cat_attribute11, temp.num_cat_attribute12,
          temp.num_cat_attribute13, temp.num_cat_attribute14, temp.num_cat_attribute15,
          temp.num_cat_attribute16, temp.num_cat_attribute17, temp.num_cat_attribute18,
          temp.num_cat_attribute19, temp.num_cat_attribute20, temp.num_cat_attribute21,
          temp.num_cat_attribute22, temp.num_cat_attribute23, temp.num_cat_attribute24,
          temp.num_cat_attribute25, temp.num_cat_attribute26, temp.num_cat_attribute27,
          temp.num_cat_attribute28, temp.num_cat_attribute29, temp.num_cat_attribute30,
          temp.num_cat_attribute31, temp.num_cat_attribute32, temp.num_cat_attribute33,
          temp.num_cat_attribute34, temp.num_cat_attribute35, temp.num_cat_attribute36,
          temp.num_cat_attribute37, temp.num_cat_attribute38, temp.num_cat_attribute39,
          temp.num_cat_attribute40, temp.num_cat_attribute41, temp.num_cat_attribute42,
          temp.num_cat_attribute43, temp.num_cat_attribute44, temp.num_cat_attribute45,
          temp.num_cat_attribute46, temp.num_cat_attribute47, temp.num_cat_attribute48,
          temp.num_cat_attribute49, temp.num_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);


	      logStatement(g_pkg_name,  l_api_name ,'Num. of rows inserted into icx_cat_attribute_values:' ||SQL%ROWCOUNT);

      MERGE INTO icx_cat_attribute_values_tlp icavt
        USING (SELECT *
             FROM po_attribute_values_tlp
             WHERE inventory_item_id = rec_MI.INVENTORY_ITEM_ID
             AND   po_line_id = -2
             AND   req_template_name = '-2'
             AND   req_template_line_num = -2
             AND   org_id =  rec_MI.ORG_ID
             AND   language = rec_MI.LANGUAGE ) temp
        ON (icavt.inventory_item_id = temp.inventory_item_id AND
          icavt.po_line_id = temp.po_line_id AND
          icavt.req_template_name = temp.req_template_name AND
          icavt.req_template_line_num = temp.req_template_line_num AND
          icavt.org_id = temp.org_id AND
          icavt.language = temp.language)
        WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_tlp_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.language, temp.description, temp.manufacturer,
          temp.comments, temp.alias, temp.long_description,
          temp.tl_text_base_attribute1, temp.tl_text_base_attribute2, temp.tl_text_base_attribute3,
          temp.tl_text_base_attribute4, temp.tl_text_base_attribute5, temp.tl_text_base_attribute6,
          temp.tl_text_base_attribute7, temp.tl_text_base_attribute8, temp.tl_text_base_attribute9,
          temp.tl_text_base_attribute10, temp.tl_text_base_attribute11, temp.tl_text_base_attribute12,
          temp.tl_text_base_attribute13, temp.tl_text_base_attribute14, temp.tl_text_base_attribute15,
          temp.tl_text_base_attribute16, temp.tl_text_base_attribute17, temp.tl_text_base_attribute18,
          temp.tl_text_base_attribute19, temp.tl_text_base_attribute20, temp.tl_text_base_attribute21,
          temp.tl_text_base_attribute22, temp.tl_text_base_attribute23, temp.tl_text_base_attribute24,
          temp.tl_text_base_attribute25, temp.tl_text_base_attribute26, temp.tl_text_base_attribute27,
          temp.tl_text_base_attribute28, temp.tl_text_base_attribute29, temp.tl_text_base_attribute30,
          temp.tl_text_base_attribute31, temp.tl_text_base_attribute32, temp.tl_text_base_attribute33,
          temp.tl_text_base_attribute34, temp.tl_text_base_attribute35, temp.tl_text_base_attribute36,
          temp.tl_text_base_attribute37, temp.tl_text_base_attribute38, temp.tl_text_base_attribute39,
          temp.tl_text_base_attribute40, temp.tl_text_base_attribute41, temp.tl_text_base_attribute42,
          temp.tl_text_base_attribute43, temp.tl_text_base_attribute44, temp.tl_text_base_attribute45,
          temp.tl_text_base_attribute46, temp.tl_text_base_attribute47, temp.tl_text_base_attribute48,
          temp.tl_text_base_attribute49, temp.tl_text_base_attribute50, temp.tl_text_base_attribute51,
          temp.tl_text_base_attribute52, temp.tl_text_base_attribute53, temp.tl_text_base_attribute54,
          temp.tl_text_base_attribute55, temp.tl_text_base_attribute56, temp.tl_text_base_attribute57,
          temp.tl_text_base_attribute58, temp.tl_text_base_attribute59, temp.tl_text_base_attribute60,
          temp.tl_text_base_attribute61, temp.tl_text_base_attribute62, temp.tl_text_base_attribute63,
          temp.tl_text_base_attribute64, temp.tl_text_base_attribute65, temp.tl_text_base_attribute66,
          temp.tl_text_base_attribute67, temp.tl_text_base_attribute68, temp.tl_text_base_attribute69,
          temp.tl_text_base_attribute70, temp.tl_text_base_attribute71, temp.tl_text_base_attribute72,
          temp.tl_text_base_attribute73, temp.tl_text_base_attribute74, temp.tl_text_base_attribute75,
          temp.tl_text_base_attribute76, temp.tl_text_base_attribute77, temp.tl_text_base_attribute78,
          temp.tl_text_base_attribute79, temp.tl_text_base_attribute80, temp.tl_text_base_attribute81,
          temp.tl_text_base_attribute82, temp.tl_text_base_attribute83, temp.tl_text_base_attribute84,
          temp.tl_text_base_attribute85, temp.tl_text_base_attribute86, temp.tl_text_base_attribute87,
          temp.tl_text_base_attribute88, temp.tl_text_base_attribute89, temp.tl_text_base_attribute90,
          temp.tl_text_base_attribute91, temp.tl_text_base_attribute92, temp.tl_text_base_attribute93,
          temp.tl_text_base_attribute94, temp.tl_text_base_attribute95, temp.tl_text_base_attribute96,
          temp.tl_text_base_attribute97, temp.tl_text_base_attribute98, temp.tl_text_base_attribute99,
          temp.tl_text_base_attribute100,
          temp.tl_text_cat_attribute1, temp.tl_text_cat_attribute2, temp.tl_text_cat_attribute3,
          temp.tl_text_cat_attribute4, temp.tl_text_cat_attribute5, temp.tl_text_cat_attribute6,
          temp.tl_text_cat_attribute7, temp.tl_text_cat_attribute8, temp.tl_text_cat_attribute9,
          temp.tl_text_cat_attribute10, temp.tl_text_cat_attribute11, temp.tl_text_cat_attribute12,
          temp.tl_text_cat_attribute13, temp.tl_text_cat_attribute14, temp.tl_text_cat_attribute15,
          temp.tl_text_cat_attribute16, temp.tl_text_cat_attribute17, temp.tl_text_cat_attribute18,
          temp.tl_text_cat_attribute19, temp.tl_text_cat_attribute20, temp.tl_text_cat_attribute21,
          temp.tl_text_cat_attribute22, temp.tl_text_cat_attribute23, temp.tl_text_cat_attribute24,
          temp.tl_text_cat_attribute25, temp.tl_text_cat_attribute26, temp.tl_text_cat_attribute27,
          temp.tl_text_cat_attribute28, temp.tl_text_cat_attribute29, temp.tl_text_cat_attribute30,
          temp.tl_text_cat_attribute31, temp.tl_text_cat_attribute32, temp.tl_text_cat_attribute33,
          temp.tl_text_cat_attribute34, temp.tl_text_cat_attribute35, temp.tl_text_cat_attribute36,
          temp.tl_text_cat_attribute37, temp.tl_text_cat_attribute38, temp.tl_text_cat_attribute39,
          temp.tl_text_cat_attribute40, temp.tl_text_cat_attribute41, temp.tl_text_cat_attribute42,
          temp.tl_text_cat_attribute43, temp.tl_text_cat_attribute44, temp.tl_text_cat_attribute45,
          temp.tl_text_cat_attribute46, temp.tl_text_cat_attribute47, temp.tl_text_cat_attribute48,
          temp.tl_text_cat_attribute49, temp.tl_text_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);



	      logStatement(g_pkg_name,  l_api_name ,'Num. of rows inserted into icx_cat_attribute_values_tlp:' ||SQL%ROWCOUNT);
       END IF;
   end if;
  END LOOP;

  l_message := 'Total Cursor count=' || master_csr%ROWCOUNT;

    logStatement(g_pkg_name,  l_api_name ,l_message);

    logStatement(g_pkg_name,  l_api_name ,'END of data fix');

exception when others then
  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'exception '||sqlerrm||' code='||sqlcode);

END PO_ATTRIBUTE_VALUES_DATA_FIX;

procedure sync_sources(p_org_id  in number,
											 p_source_type in varchar2,
									     x_return_status out NOCOPY varchar2	)
is
l_min_row_id ROWID;
l_max_row_id ROWID;
l_api_name VARCHAR2  (20):='sync_sources';
l_inv_item_id number;
l_organization_id number;


Cursor master_item_sync     is
select distinct inventory_item_id,organization_id from (   SELECT /*+ LEADING(doc) */
              doc.*,
              nvl(ic1.rt_category_id, -2) ip_category_id,
              ic1.category_name ip_category_name,
              ctx.inventory_item_id ctx_inventory_item_id,
              ctx.source_type ctx_source_type,
              ctx.item_type ctx_item_type,
              ctx.purchasing_org_id ctx_purchasing_org_id,
              ctx.supplier_id ctx_supplier_id,
              ctx.supplier_site_id ctx_supplier_site_id,
              ctx.supplier_part_num ctx_supplier_part_num,
              ctx.supplier_part_auxid ctx_supplier_part_auxid,
              ctx.ip_category_id ctx_ip_category_id,
              ctx.po_category_id ctx_po_category_id,
              ctx.ip_category_name ctx_ip_category_name,
              ctx.unit_price ctx_unit_price,
              ROWIDTOCHAR(ctx.rowid) ctx_rowid

       FROM
            (
              SELECT  /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                     mi.inventory_item_id inventory_item_id,
                     -2 po_line_id,
                     '-2' req_template_name,
                     -2 req_template_line_num,
                     NVL(fsp.org_id, -2) org_id,
                     mitl.language,
                     'MASTER_ITEM' source_type,
                     NVL(fsp.org_id, -2) purchasing_org_id,
                     mic.category_id po_category_id,
                     catMap.category_key category_key,
                     mi.internal_order_enabled_flag,
                     mi.purchasing_enabled_flag,
                     mi.outside_operation_flag,
                     muom.unit_of_measure unit_meas_lookup_code,
                     DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                     mi.rfq_required_flag,
                     mitl.description,
                     mitl.long_description,
                     mparams.organization_id,
                     mparams.master_organization_id
              FROM mtl_system_items_b mi,
                   mtl_parameters mparams,
                   mtl_system_items_tl mitl,
                   mtl_item_categories mic,
                   mtl_units_of_measure muom,
                   financials_system_params_all fsp,
                   icx_por_category_data_sources catMap
              WHERE
	mi.organization_id = mparams.organization_id
              AND (mparams.organization_id = nvl(p_org_id,mparams.organization_id)
                   OR mparams.master_organization_id = nvl(p_org_id,mparams.master_organization_id))
              AND mi.inventory_item_id = mitl.inventory_item_id
              AND mi.organization_id = mitl.organization_id
              AND mitl.language = mitl.source_lang
              AND mic.inventory_item_id = mi.inventory_item_id
              AND mic.organization_id = mi.organization_id
              AND mic.category_set_id = 2
              AND muom.uom_code = mi.primary_uom_code
              AND NOT (mi.replenish_to_order_flag = 'Y'
                       AND mi.base_item_id IS NOT NULL
                       AND mi.auto_created_config_flag = 'Y')
              AND mi.organization_id = fsp.inventory_organization_id
              AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
              AND catMap.external_source (+) = 'Oracle'
            ) doc,
            icx_cat_categories_tl ic1,
            icx_cat_items_ctx_hdrs_tlp ctx
       WHERE ic1.key (+) = doc.category_key
       AND ic1.type (+) = 2
       AND ic1.language (+) = doc.language
       AND doc.inventory_item_id = ctx.inventory_item_id (+)
       AND doc.po_line_id = ctx.po_line_id (+)
       AND doc.req_template_name = ctx.req_template_name (+)
       AND doc.req_template_line_num = ctx.req_template_line_num (+)
       AND doc.org_id = ctx.org_id (+)
       AND doc.language = ctx.language (+)
       AND doc.source_type = ctx.source_type (+))
where  ip_category_id <> ctx_ip_category_id
or unit_price <> ctx_unit_price
or ctx_inventory_item_id <> inventory_item_id  ;

   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_err_loc			PLS_INTEGER;
   l_start_date			DATE;
   l_end_date			DATE;
   l_log_string			VARCHAR2(2000);
   BEGIN
     l_err_loc := 100;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     x_return_status := FND_API.G_RET_STS_SUCCESS;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 200;
     -- Standard Start of API savepoint
     SAVEPOINT populateItemSync_sp;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 300;
     l_start_date := sysdate;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS')|| ' p_source_type=' ||p_source_type  ;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
    END IF;
    ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 600;
     --Initialize the purchasing category set info.
     ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;
     ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 800;
     ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);
     ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 900;
     -- Set the global parameter ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
     ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := TRUE;
     ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 1000;
     -- Set the batch_size for the online case
     ICX_CAT_UTIL_PVT.setBatchSize;
     ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,l_log_string||l_err_loc);

     l_err_loc := 400;
     ICX_CAT_UTIL_PVT.setWhoColumns(g_request_id);
     if p_source_type = 'MASTER_ITEM' then

     PO_ATTRIBUTE_VALUES_DATA_FIX;

 			open master_item_sync;
			  loop
			  fetch master_item_sync into l_inv_item_id,l_organization_id;
			  exit when master_item_sync%NOTFOUND;
					ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting inv_item_id='||l_inv_item_id|| ' organization_id'||l_organization_id );

       ICX_CAT_POPULATE_MI_PVT.populateItemChange(l_inv_item_id, l_ORGANIZATION_ID,null,null);
 			end loop;
			close master_item_sync;
		 end if;
    if p_source_type = 'BLANKET' then
ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,p_source_type);

		update po_headers_all set last_update_date = sysdate
				where po_header_id in ( select distinct pol.po_header_id from po_attribute_values_tlp po , icx_cat_items_ctx_hdrs_tlp ctx, po_lines_all pol
				where po.po_line_id=ctx.po_line_id
				and po.po_line_id=pol.po_line_id
				and ctx.source_type in ('BLANKET','QUOTATION','GLOBAL_BLANKET')
				and (po.ip_category_id <> ctx.ip_category_id or pol.unit_price <> ctx.unit_price)
				);
		  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting BPA count='||Sql%ROWCOUNT);

       select min(rowid), max(rowid) into l_min_row_id,l_max_row_id from po_headers_all;
    	 ICX_CAT_POPULATE_PODOCS_PVT.upgradeR12PODocs(sysdate-1,l_min_row_id,l_max_row_id);
		  ICX_ITEM_DIAG_PVT.logStatement(g_pkg_name, l_api_name,'extracting done for bpa ');

    end if;
    l_err_loc := 1200;
    COMMIT;
       l_err_loc := 1400;
       -- Call the rebuild index
       ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
             ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
             'Rebuild indexes called.');
       END IF;

     l_err_loc := 1600;
     l_end_date := sysdate;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
          ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       BEGIN
         ROLLBACK TO populateItemSync_sp;
       EXCEPTION
         WHEN OTHERS THEN
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                            'ROLLBACK TO the savepoint caused the exception -->'
                            || SQLERRM);
           END IF;
           NULL;
       END;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  logUnexpectedException(g_pkg_name, l_api_name,'sync_sources '||sqlerrm||' code='||sqlcode);

end sync_sources;


PROCEDURE logStatement
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'icx.plsql.' || UPPER(p_pkg_name) || '.' || UPPER(p_proc_name)|| '::'||  p_log_string);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.' || UPPER(p_pkg_name) || '.' || UPPER(p_proc_name), p_log_string);
    l_err_loc := 400;
  END IF;
EXCEPTION WHEN OTHERS THEN
    l_err_loc := 500;
END logStatement;


END ICX_ITEM_DIAG_PVT;

/
