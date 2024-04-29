--------------------------------------------------------
--  DDL for Package Body ICX_POR_ITEM_UPLOAD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_ITEM_UPLOAD_VALIDATE" AS
/* $Header: ICXIULVB.pls 115.33 2004/03/31 21:51:08 vkartik ship $*/

--BUG#2228935
g_operating_unit_id NUMBER;

/**
 ** Proc : validate_interface_data
 ** Desc : Validate data of interface table.
 **/

PROCEDURE validate_interface_data (p_job_supplier_name IN VARCHAR2,
                                   p_job_supplier_id IN NUMBER,
                                   p_exchange_operator_name IN VARCHAR2,
                                   p_table_name IN VARCHAR2,
                                   p_language IN VARCHAR2,
                                   p_start_row IN NUMBER,
                                   p_end_row IN NUMBER) IS
  xErrLoc INTEGER := 0;
  l_count1 INTEGER;
  l_sql_string VARCHAR2(4000);
  l_cursor_id NUMBER;
  l_result_count NUMBER;
  l_organization_id NUMBER;
-- Bug#1991093
  l_list_price_name VARCHAR2(90);
  l_list_price_currency VARCHAR2(4);
  l_list_price_id NUMBER;
  l_bus_group_id NUMBER := 0; /* vkartik */
  l_supplier_id NUMBER := 0; /* vkartik */
  l_chk_multi_org VARCHAR2(1); --Bug#2375254

BEGIN

  xErrLoc := 100;

  l_bus_group_id := p_job_supplier_id; /* vkartik */

  -- Figure out what the action should be
  -- We use bind for row number but not language since the language
  -- will not change within a job, but the row numbers will
  -- BUG#2228935
  -- If operating unit specified from the UI then also joining with oracle_item_subtable
  -- So as to handle the special cases for extracted items
  -- having more than one row in items table for the same supplier supplier_part_num
  -- Outer joined with oracle_item_subtable as bulkloaded items will have no row in oracle_item_subtable
  if ( g_operating_unit_id is not null) then
    l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
      ' SET (system_action, rt_item_id) = (SELECT DISTINCT decode(it2.action, ' ||
      '''SYNC'', decode(it2.row_type, ''PRICE'', ''ADD'', ' ||
      'decode(item.rt_item_id, NULL, ''ADD'', decode(tl.rt_item_id, ' ||
      'NULL, ''TRANSLATE'', ''UPDATE''))), it2.action), item.rt_item_id ' ||
      'FROM icx_por_items_tl tl, icx_por_items item, ' || p_table_name ||
      ' it2, icx_por_oracle_item_subtable orc ' ||
      'WHERE it1.rowid = it2.rowid ' ||
      'AND it2.supplier_name = item.a1 (+) ' ||
      'AND it2.supplier_part_num = item.a3 (+) ' ||
      'AND item.rt_item_id = orc.rt_item_id (+) ' ||
      'AND (orc.orc_operating_unit_id = :oper_unit_id OR orc.orc_operating_unit_id is null) '||
      'AND item.rt_item_id = tl.rt_item_id (+) ' ||
      'AND tl.language (+) = ''' || p_language || ''') ' ||
      'WHERE line_number between :startrow AND :endrow';
  else
    l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
      ' SET (system_action, rt_item_id) = (SELECT decode(it2.action, ' ||
      '''SYNC'', decode(it2.row_type, ''PRICE'', ''ADD'', ' ||
      'decode(item.rt_item_id, NULL, ''ADD'', decode(tl.rt_item_id, ' ||
      'NULL, ''TRANSLATE'', ''UPDATE''))), it2.action), item.rt_item_id ' ||
      'FROM icx_por_items_tl tl, icx_por_items item, ' || p_table_name ||
      ' it2 WHERE it1.rowid = it2.rowid AND it2.supplier_name = item.a1 (+) ' ||
      'AND it2.supplier_part_num = item.a3 (+) ' ||
      'AND item.rt_item_id = tl.rt_item_id (+) ' ||
      'AND tl.language (+) = ''' || p_language || ''') ' ||
      'WHERE line_number between :startrow AND :endrow';
  end if;

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 110;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 120;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 130;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 140;
  if ( g_operating_unit_id is not null) then	-- BUG#2228935
    DBMS_SQL.bind_variable(l_cursor_id, ':oper_unit_id', g_operating_unit_id);
  end if;
  xErrLoc := 14000;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 150;
  DBMS_SQL.close_cursor(l_cursor_id);

  commit;

  -- Now validate:
  -- Mandatory variables for adding items: supplier_part_num, description,
  -- price, uom
  -- Mandatory variables for translating items - description
  -- Mandatory variables for updating items - none
  -- Mandatory variables for updating item price - price, uom
  -- Mandatory variables for deleting items - supplier_part_num
  -- Mandatory variables for adding price - supplier_part_num, price, uom,
  -- buyer, price list name, currency
  -- Mandatory variables for deleting price - supplier_part_num, buyer
  -- Item exists if action is delete

  xErrLoc := 200;
  -- Bug#1581013: Get the Buyer Id here
  -- Bug#2160017: If the Buyer name is "All-Buyers", Buyer id must be -2
  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
  'SET (buyer_id, error_message) = (SELECT decode(it2.buyer_name, null, -2, ''All-Buyers'', -2, buy.organization_id), it1.error_message || ' ||
  'decode(it2.system_action, ''ADD'', decode(it2.supplier_part_num, null, ' ||
  '''.SUPPLIER_PART_NUM:ICX_POR_SUPPLIER_PART_REQD'', null), ' ||
  '''DELETE'', decode(it2.supplier_part_num, null, ' ||
  '''.SUPPLIER_PART_NUM:ICX_POR_SUPPLIER_PART_REQD'', null), null) || ' ||
  'decode(it2.system_action, ''DELETE'', decode(it2.rt_item_id, null, ' ||
  '''.SUPPLIER_PART_NUM:ICX_POR_PRC_INVALID_SUP_PART'', null), null) || ' ||
  -- Bug 1344934: Loading item and buyer-specific price in a file will
  -- reject buyer-specific price
  -- Will check item of Price line during moving data process
  -- 'decode(it2.row_type, ''PRICE'', decode(it2.rt_item_id, null, ' ||
  -- '''.SUPPLIER_PART_NUM:ICX_POR_PRC_INVALID_SUP_PART'', null), null) || ' ||
  'decode(it2.system_action, ''TRANSLATE'', decode(it2.description, null, ' ||
  '''.DESCRIPTION:ICX_POR_INVALID_DESCRIPTION'', null), null) || ' ||
  'decode(it2.system_action, ''ADD'', decode(it2.row_type, ''ITEM_PRICE'', ' ||
  'decode(it2.description, null, ' ||
  '''.DESCRIPTION:ICX_POR_INVALID_DESCRIPTION'', null), null),null) || ' ||
  'decode(it2.system_action, ''ADD'', decode(it2.row_type, ''ITEM'', ' ||
  'decode(it2.price_string, null, ' ||
  '''.PRICE:ICX_POR_PRICE_REQD'', null), null), null) || ' ||
  'decode(it2.system_action, ''ADD'', decode(it2.row_type, ''ITEM'', ' ||
  'decode(it2.uom_code, null, ' ||
  '''.PRICE:ICX_POR_UOM_REQD'', null), null), null) || ' ||
  'decode(it2.row_type, ''PRICE'', decode(it2.buyer_name, null, ' ||
  '''.BUYER:ICX_POR_BUYER_REQD'', null), null) || ' ||
  'decode(it2.row_type, ''PRICE'', decode(it2.pricelist_name, null, ' ||
  '''.PRICELIST:ICX_POR_CAT_PRICE_LIST_NAME_M'', null), null) || ' ||
  'decode(it2.row_type, ''PRICE'', decode(it2.currency_code, null, ' ||
  '''.CURRENCY:ICX_POR_CURRENCY_REQD'', null), null) || ' ||
  'decode(it2.row_type, ''PRICE'', decode(it2.price_string, null, ' ||
  '''.PRICE:ICX_POR_PRICE_REQD'', null), null) || ' ||
  'decode(it2.row_type, ''PRICE'', decode(it2.uom_code, null, ' ||
  '''.UOM:ICX_POR_UOM_REQD'', null), null) || ' ||
  -- BUG#2228935  Check Price and UOM reqd only if system_action is ADD
  'decode(it2.system_action, ''ADD'', ' ||
  'decode(it2.row_type, ''ITEM_PRICE'', decode(it2.price_string, null, ' ||
  '''.PRICE:ICX_POR_PRICE_REQD'', null), null), null) || ' ||
  -- BUG#2228935 Check Price and UOM reqd only if system_action is ADD
  'decode(it2.system_action, ''ADD'', ' ||
  'decode(it2.row_type, ''ITEM_PRICE'', decode(it2.uom_code, null, ' ||
  '''.UOM:ICX_POR_UOM_REQD'', null), null), null)  || ' ||
  'decode(it2.buyer_name, null, null, :all_buyer_list_name' ||
  ', null, decode(buy.name, null, ' ||
  '''.BUYER:ICX_POR_INVALID_BUYER'')) ' ||
  ' FROM hr_all_organization_units buy, ' || p_table_name  || ' it2 WHERE it1.rowid = it2.rowid  ' ||
  ' AND it2.buyer_name = buy.name (+) ' ||
  ' AND :bus_group_id = buy.business_group_id (+)) ' ||
  'WHERE line_number between :startrow AND :endrow';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 210;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 220;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 230;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 240;
  -- Bug#1581013
  DBMS_SQL.bind_variable(l_cursor_id, ':all_buyer_list_name', p_exchange_operator_name);
  xErrLoc := 245;
  DBMS_SQL.bind_variable(l_cursor_id, ':bus_group_id', l_bus_group_id);
  xErrLoc := 250;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 260;
  DBMS_SQL.close_cursor(l_cursor_id);

  commit;

  xErrLoc := 300;
  -- Get exchange operator id
  -- vkartik
   l_organization_id := -2 ;

  l_sql_string := 'SELECT vendor_id '  ||
                       'FROM po_vendors supp, ' || p_table_name || ' it2 ' ||
                       'WHERE supp.vendor_name = it2.supplier_name ';
  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 301;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 302;
  DBMS_SQL.define_column(l_cursor_id, 1, l_supplier_id);
  xErrLoc := 303;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 304;

  IF DBMS_SQL.fetch_rows(l_cursor_id) <> 0 THEN
      DBMS_SQL.column_value(l_cursor_id, 1, l_supplier_id);
  END IF;

  xErrLoc := 305;

  DBMS_SQL.close_cursor(l_cursor_id);

--   SELECT organization_id INTO l_organization_id FROM hr_all_organization_units
--   WHERE name = p_exchange_operator_name;
--   AND type = 'EXCHANGE_OPERATOR'; ?? DIV ??

--  SELECT party_id INTO l_organization_id FROM hz_parties
--  WHERE party_name = p_exchange_operator_name
--  AND party_type = 'EXCHANGE_OPERATOR';

  xErrLoc := 310;
/*
  BEGIN
    -- Get Exchange price list name and id
--Bug#1505751: was using supplier id from batch jobs, which is wrong.
    SELECT header_id, name, currency_code
    INTO l_list_price_id, l_list_price_name, l_list_price_currency
    FROM icx_por_price_lists
    WHERE supplier_id = l_supplier_id AND Buyer_id = l_organization_id;

  EXCEPTION
    WHEN no_data_found THEN
      l_list_price_id := NULL;
      l_list_price_name := NULL;
      l_list_price_currency := NULL;
  END;
*/

  -- Now validate (if specified):
  -- UNSPSC code exists in ICX_UNSPSC_CODES
  -- Uom code exists in MTL_UNITS_OF_MEASURE
  -- Currency exists in FND_CURRENCIES
  -- Product type exists in FND_LOOKUP_VALUES
  -- If price list already exists, currency and price list name is the same
  -- Buyer is Exchange operator if row_type is ITEM_PRICE system action is 'ADD'
  -- Buyer is not exchange operator if row_type is 'PRICE' and action is DELETE
  -- Owner is a valid user

  xErrLoc := 400;

  -- Bug#1975528
  -- Use Bind variables instead of literals.
  -- move the site validation part in this sql into the
  -- site validation sql that is following this sql. Remove joins
  -- to po_vendor_sites_all.
  -- Bug#1581013: Dont get the buyer id here..
  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
  'SET (pricelist_id, supplier_id, error_message) = ' ||
  '(SELECT DISTINCT pl.header_id, ' ||
  'supp.vendor_id,  it1.error_message || '||

  'decode(it2.supplier_name, null, null, decode(supp.vendor_name, null, ' ||
  '''.SNAME:ICX_POR_INVALID_SUPPLIER'', null)) || ' ||
  'decode(greatest( nvl(supp.start_date_active,sysdate-1), sysdate), sysdate, null, ' ||
  '''.SNAME:ICX_POR_INACTIVE_SUPPLIER'') || ' ||
  'decode(greatest( nvl(supp.end_date_active ,sysdate+1), sysdate), sysdate, '||
  '''.SNAME:ICX_POR_INACTIVE_SUPPLIER'', null) || ' ||
  'decode(it2.item_type, null, null, decode(lkp.lookup_code, null, ' ||
  '''.ITEM_TYPE:ICX_POR_INVALID_ITEM_TYPE'', null)) || ' ||
  'decode(it2.currency_code, null, null, decode(cur.currency_code, null, ' ||
  '''.CURRENCY:ICX_POR_INVALID_CURRENCY'', null))  ' ||
  ' FROM po_vendors supp, icx_por_price_lists pl, ' ||
  ' fnd_lookup_values lkp, fnd_currencies cur, '||
  p_table_name ||' it2 ' ||
  ' WHERE it1.rowid = it2.rowid ' ||
  ' AND upper(it2.currency_code) = cur.currency_code (+) ' ||
  ' AND it2.item_type = lkp.lookup_code (+) ' ||
  ' AND lkp.lookup_type (+) = ''ICX_CATALOG_ITEM_TYPE'' ' ||
  ' AND lkp.language (+) = :language' ||
  ' AND it2.buyer_id = pl.buyer_id (+) ' ||
--Bug#1581013: Currency validation
  ' AND it2.currency_code = pl.currency_code (+) ' ||
  ' AND pl.supplier_id (+) = :supplier_id ' ||
  ' AND supp.vendor_name (+) = it2.supplier_name ' ||
  ') WHERE line_number BETWEEN :startrow AND :endrow ';
  l_cursor_id := DBMS_SQL.open_cursor;

  xErrLoc := 410;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 420;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 430;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 435;
  DBMS_SQL.bind_variable(l_cursor_id, ':supplier_id', l_supplier_id);
  xErrLoc := 440;
  DBMS_SQL.bind_variable(l_cursor_id, ':language', p_language);
  xErrLoc := 470;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 480;
  DBMS_SQL.close_cursor(l_cursor_id);

  xErrLoc := 700;

  -- Bug#1975528
  -- Check supplier_site, buyer combination specified in the file is valid
  -- Need a separate sql
  -- Bug#1975528
  -- Added the constraint, vendor_id for po_vendor_sites_all table
  -- Added extra site validation that existed from the previous sql
  -- into this sql.

  -- Bug#2375254
  -- Need seperate sql for non multi-org instance
  -- as site.org_id is null in non multi-org instance

  xErrLoc := 701;

  SELECT nvl(multi_org_flag, 'N') INTO l_chk_multi_org
  FROM fnd_product_groups ;

  xErrLoc := 705;

  if (l_chk_multi_org='Y') then

    l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
    'SET error_message = error_message ||( ' ||
    'SELECT DISTINCT error_message || ' ||
    'decode(site.purchasing_site_flag, ' ||'''N''' || ', ' ||
    '''.SITE:ICX_POR_INVALID_SUPP_SITE_2'', null ) || ' ||
    'decode(greatest(nvl(site.inactive_date ,sysdate+1), sysdate), sysdate, ' ||
    '''.SITE:ICX_POR_INACTIVE_SUPP_SITE'', null) || ' ||
  -- Bug#2054819
  -- Bug 2182815 fixed by sosingha
  -- Bug 2107543 fixed by sosingha
    'decode(it2.supplier_site, null, null, decode(it2.buyer_id,'
    ||  '''-2'', ''.SITE:ICX_POR_OU_REQD'', '
  -- Bug 2325999
    || 'decode(it2.row_type, ''PRICE'', '
    || '   decode(it2.rt_item_id, null, ''.SITE:ICX_POR_PRC_INVALID_SUP_PART'', '
    || '   decode(site.vendor_site_code,null, ''.SITE:ICX_POR_INVALID_SUPP_SITE'', null)), '
    || 'decode(site.vendor_site_code, null, '
    ||'''.SITE:ICX_POR_INVALID_SUPP_SITE'', null)))) '||
    'FROM ' || p_table_name || ' it2 , po_vendor_sites_all site '||
    'WHERE it1.rowid = it2.rowid ' ||
    ' AND it2.buyer_id IS NOT NULL ' ||
    -- Bug#1975528: Vendor ID constraint added.
    ' AND site.vendor_id (+) = it2.supplier_id ' ||
    ' AND site.vendor_site_code (+) = UPPER(it2.supplier_site) ' ||
    ' AND site.org_id (+) = it2.buyer_id ' ||
    ') WHERE line_number BETWEEN :startrow AND :endrow ';

  else

    l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
    'SET error_message = error_message ||( ' ||
    'SELECT DISTINCT error_message || ' ||
    'decode(site.purchasing_site_flag, ' ||'''N''' || ', ' ||
    '''.SITE:ICX_POR_INVALID_SUPP_SITE_2'', null ) || ' ||
    'decode(greatest(nvl(site.inactive_date ,sysdate+1), sysdate), sysdate, ' ||
    '''.SITE:ICX_POR_INACTIVE_SUPP_SITE'', null) || ' ||
    'decode(it2.supplier_site, null, null, ' ||
    'decode(it2.row_type, ''PRICE'', ' ||
    'decode(it2.rt_item_id, null, ''.SITE:ICX_POR_PRC_INVALID_SUP_PART'', ' ||
    'decode(site.vendor_site_code, null, ''.SITE:ICX_POR_INVALID_SUPP_SITE'', ' ||
    'null)), decode(site.vendor_site_code, null, ' ||
    '''.SITE:ICX_POR_INVALID_SUPP_SITE'', null))) ' ||
    'FROM ' || p_table_name || ' it2 , po_vendor_sites_all site '||
    'WHERE it1.rowid = it2.rowid ' ||
    ' AND site.vendor_id (+) = it2.supplier_id ' ||
    ' AND site.vendor_site_code (+) = UPPER(it2.supplier_site) ' ||
    ') WHERE line_number BETWEEN :startrow AND :endrow ';

  end if;

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 710;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 720;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 730;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 740;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 750;
  DBMS_SQL.close_cursor(l_cursor_id);


  xErrLoc := 500;
--Bug#1581013: Removed code to check for the uniqueness of the pricelist name

  xErrLoc := 600;
  -- Find the current category if the action is update
  -- Bug#2049568 : Check for only Genus categories,
  --               (item could be in both a Genus category and template)
  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
  'SET old_category_id = (SELECT cai.rt_category_id ' ||
  'FROM icx_por_category_items cai, icx_por_categories_tl ca '||
  'WHERE cai.rt_item_id = it1.rt_item_id '||
  ' AND  ca.rt_category_id = cai.rt_category_id '||
  ' AND  ca.type = 2 '||
  ' AND  ca.language = ''' || p_language || ''') ' ||
  'WHERE it1.system_action = ''UPDATE'' AND it1.rt_item_id IS NOT NULL ' ||
  'AND line_number BETWEEN :startrow AND :endrow ';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 610;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 620;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 630;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 640;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 650;
  DBMS_SQL.close_cursor(l_cursor_id);

  commit;


EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD_VALIDATE.validate_interface_data('
        || xErrLoc || '): ' || SQLERRM);

END validate_interface_data;

PROCEDURE validate_duplicate_item2(p_table_name IN VARCHAR2) IS
xErrLoc NUMBER;
l_result_count NUMBER;
l_cursor_id NUMBER;
l_sql_string VARCHAR2(4000);
BEGIN
  -- There are duplicate item numbers within the interface table
  xErrLoc := 100;

  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
  'SET it1.error_message = it1.error_message || ' ||
  'decode(it1.error_message, it1.error_message, ' ||
  'decode(it1.row_type, ''PRICE'', ''.PRICELIST:ICX_POR_DUP_PRICE_LIST1'', '||
  '''ITEM_PRICE'', ''.SUPPLIER_PART_NUM:ICX_POR_DUP_SUPPLIER_PART'', ' ||
  '''.SUPPLIER_PART_NUM:ICX_POR_DUP_SUPPLIER_PART'')) ' ||
  'WHERE NOT it1.ROWID = ( ' ||
  'SELECT MAX(it2.ROWID) ' ||
  'FROM ' || p_table_name || ' it2 ' ||
  'WHERE  it2.supplier_part_num = it1.supplier_part_num ' ||
  'AND  it2.supplier_id = it1.supplier_id ' ||
  'AND NVL(it2.buyer_id,-2) = NVL(it1.buyer_id,-2) ' ||
-- Bug#2352152 : Constraint for currency check
  'AND NVL(it2.currency_code,''USD'') = NVL(it1.currency_code,''USD'') ' ||
  'AND  it2.row_type = it1.row_type )';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 110;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 120;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 130;
  DBMS_SQL.close_cursor(l_cursor_id);

  xErrLoc := 140;

/*
   Bug# 2192779 - srmani:  Included the validation for duplicate item
    with same supplier-supplier part number but different buyer.
    In this case there will be only a single entry for the idential items
    in items table and one entry in price lists table for each buyer.
    Care is taken care of that the ones modified in the previous cursor
    are omitted over here.
*/

  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
  'SET it1.row_type = ''PRICE'', it1.system_action = ''ADD''  '||
  'WHERE NOT it1.ROWID = ( ' ||
  'SELECT MIN(it2.ROWID) ' ||
  'FROM ' || p_table_name || ' it2 ' ||
  'WHERE it2.error_message IS NULL ' ||
  'AND  it2.supplier_part_num = it1.supplier_part_num ' ||
  'AND  it2.supplier_id = it1.supplier_id ' ||
  'AND  it2.row_type = it1.row_type ) '  ||
  'AND it1.error_message IS NULL ';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 150;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 160;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 170;
  DBMS_SQL.close_cursor(l_cursor_id);

  commit;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD_VALIDATE.validate_duplicate_item2('
        || xErrLoc || '): ' || SQLERRM);
END validate_duplicate_item2;

PROCEDURE check_pricelines(p_table_name IN VARCHAR2,
                           p_start_row IN NUMBER,
                           p_end_row IN NUMBER) IS
xErrLoc NUMBER;
l_result_count NUMBER;
l_cursor_id NUMBER;
l_sql_string VARCHAR2(4000);
BEGIN
  xErrLoc := 100;

  l_sql_string := 'UPDATE ' || p_table_name || ' it1 ' ||
--Bug#1505751
  'SET priceline_rowid = (SELECT DISTINCT pl.rowid FROM icx_por_price_list_lines pl ' ||
  'WHERE it1.pricelist_id = pl.header_id ' ||
  'AND it1.rt_item_id = pl.item_id ' ||
  'AND pl.buyer_approval_status = ''APPROVED'' ' ||
  'AND ((it1.row_type = ''ITEM_PRICE'' ' ||
  'AND it1.system_action IN (''UPDATE'', ''TRANSLATE'')) ' ||
  'OR (it1.row_type = ''PRICE'' ' ||
  'AND it1.system_action IN (''ADD'',''DELETE'')))) ' ||
  'WHERE line_number between :startrow AND :endrow';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 110;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 120;
  DBMS_SQL.bind_variable(l_cursor_id, ':startrow', p_start_row);
  xErrLoc := 130;
  DBMS_SQL.bind_variable(l_cursor_id, ':endrow', p_end_row);
  xErrLoc := 140;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 150;
  DBMS_SQL.close_cursor(l_cursor_id);

  commit;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD_VALIDATE.check_pricelines('
        || xErrLoc || '): ' || SQLERRM);
END check_pricelines;

/**
 ** Proc : validate_interface_data
 ** Desc : Validate data of interface table.
 **/

PROCEDURE validate_interface_data (p_job_supplier_name IN VARCHAR2,
                                   p_job_supplier_id IN NUMBER,
                                   p_exchange_operator_name IN VARCHAR2,
                                   p_table_name IN VARCHAR2,
                                   p_language IN VARCHAR2,
                                   p_row_count IN NUMBER) IS
xErrLoc NUMBER;
l_batch_size NUMBER := 10000;
l_start_row NUMBER := 0;
l_end_row NUMBER := 0;
l_sql_string VARCHAR2(4000);
l_cursor_id NUMBER;
l_count1 NUMBER := 0;
l_result_count NUMBER;
l_bus_group_id NUMBER := 0; --BUG#2228935
BEGIN
  xErrLoc := 100;

  IF ICX_POR_ITEM_UPLOAD_VALIDATE.g_debug_channel THEN
    ICX_POR_ITEM_UPLOAD_VALIDATE.g_job_number :=
       substr(p_table_name,16,length(p_table_name)-instr(p_table_name,'_IT')+1);
    ICX_POR_ITEM_UPLOAD_VALIDATE.g_module_name:=
       'ICX.PLSQL.LOADER.'|| ICX_POR_ITEM_UPLOAD_VALIDATE.g_job_number;
    fnd_global.apps_initialize(-1, -1, 178);
    fnd_profile.put('AFLOG_ENABLED', 'Y');
    fnd_profile.put('AFLOG_MODULE', ICX_POR_ITEM_UPLOAD_VALIDATE.g_module_name);
    fnd_profile.put('AFLOG_LEVEL', '1');
    fnd_profile.put('AFLOG_FILENAME', '');
    fnd_log_repository.init;
  END IF;


/*Bug#2047776
  -- Check duplicate item with same file
  l_sql_string :=
  'SELECT count(*) - count(distinct supplier_name || supplier_part_num) ' ||
  'FROM ' || p_table_name;

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 110;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 120;
  DBMS_SQL.define_column(l_cursor_id, 1, l_count1);
  xErrLoc := 130;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 140;

  LOOP
    IF DBMS_SQL.fetch_rows(l_cursor_id) = 0 THEN
      EXIT;
    END IF;

    DBMS_SQL.column_value(l_cursor_id, 1, l_count1);
  END LOOP;

  xErrLoc := 150;
  DBMS_SQL.close_cursor(l_cursor_id);
*/

  --BUG#2228935
  l_bus_group_id := p_job_supplier_id;

  l_sql_string :=
  'SELECT buy.organization_id ' ||
  'FROM   hr_all_organization_units buy, icx_por_uploader_subtable ipus, ' || p_table_name || ' it ' ||
  'WHERE  buy.business_group_id = :bus_group_id ' ||
  'AND    buy.name = ipus.operating_unit ' ||
  'AND    ipus.job_number = it.job_number ' ||
  'AND    ROWNUM < 2';

  l_cursor_id := DBMS_SQL.open_cursor;
  xErrLoc := 110;
  DBMS_SQL.parse(l_cursor_id, l_sql_string, DBMS_SQL.NATIVE);
  xErrLoc := 120;
  DBMS_SQL.bind_variable(l_cursor_id, ':bus_group_id', l_bus_group_id);
  xErrLoc := 130;
  DBMS_SQL.define_column(l_cursor_id, 1, g_operating_unit_id);
  xErrLoc := 130;
  l_result_count := DBMS_SQL.execute(l_cursor_id);
  xErrLoc := 140;

  IF DBMS_SQL.fetch_rows(l_cursor_id) <> 0 THEN
      DBMS_SQL.column_value(l_cursor_id, 1, g_operating_unit_id);
  ELSE
      g_operating_unit_id := null;
  END IF;

  xErrLoc := 150;
  DBMS_SQL.close_cursor(l_cursor_id);

  xErrLoc := 160;

  WHILE l_end_row < p_row_count LOOP
    l_start_row := l_end_row + 1;
    l_end_row := l_end_row + l_batch_size;
    validate_interface_data(p_job_supplier_name, p_job_supplier_id,
      p_exchange_operator_name, p_table_name, p_language,
      l_start_row, l_end_row);
  END LOOP;

  -- Duplicate exists within the same file
  --Bug#2047776
  xErrLoc := 170;
  validate_duplicate_item2(p_table_name);

  -- Populate rowid for price lines that need to be updated
  xErrLoc := 180;
  l_start_row := 0;
  l_end_row := 0;

  WHILE l_end_row < p_row_count LOOP
    l_start_row := l_end_row + 1;
    l_end_row := l_end_row + l_batch_size;
    check_pricelines(p_table_name, l_start_row, l_end_row);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD_VALIDATE.validate_interface_data('
        || xErrLoc || '): ' || SQLERRM);
END validate_interface_data;

/*
 ** Procedure to insert the SQL string and Bind variables into
 ** FND_LOG_MESSAGES table using the AOL API.
 */

PROCEDURE insert_fnd_log_messages(p_debug_bind_variables VARCHAR2,
                                 p_debug_sql_string VARCHAR2) is
l_size     NUMBER := 2000;
l_sql_string_length  NUMBER := LENGTH(p_debug_sql_string);
l_bind_string_length NUMBER := LENGTH(p_debug_bind_variables);
l_debug_sql_string VARCHAR2(20000) := p_debug_sql_string;
l_debug_bind_variable VARCHAR2(20000) := p_debug_bind_variables;
l_start NUMBER := 0;

BEGIN

  /*Insert the Debug SQL string */
   WHILE l_start < l_sql_string_length LOOP
      l_start := l_start + l_size;
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        ICX_POR_ITEM_UPLOAD_VALIDATE.g_module_name,
        substrb(l_debug_sql_string,1,l_size));
      l_debug_sql_string := substrb(l_debug_sql_string,l_size+1);
   END LOOP;

   l_start  := 0;
   /*Insert the Debug Bind Variable string */
   WHILE l_start < l_bind_string_length LOOP
      l_start := l_start + l_size;
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
         ICX_POR_ITEM_UPLOAD_VALIDATE.g_module_name,
         substrb(l_debug_bind_variable,1,l_size));
      l_debug_bind_variable := substrb(l_debug_bind_variable,l_size+1);
   END LOOP;

END insert_fnd_log_messages;


/* Procedure to set the debug channel*/
PROCEDURE set_debug_channel(p_debug_channel number) is
BEGIN
  IF p_debug_channel=1 THEN
    ICX_POR_ITEM_UPLOAD_VALIDATE.g_debug_channel := true;
  ELSE
    ICX_POR_ITEM_UPLOAD_VALIDATE.g_debug_channel :=false;
  END IF;
END set_debug_channel;


END ICX_POR_ITEM_UPLOAD_VALIDATE;

/
