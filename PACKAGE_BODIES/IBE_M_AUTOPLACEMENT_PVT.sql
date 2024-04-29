--------------------------------------------------------
--  DDL for Package Body IBE_M_AUTOPLACEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_M_AUTOPLACEMENT_PVT" AS
  /* $Header: IBEVMAPB.pls 120.0.12010000.3 2009/05/06 06:19:42 amaheshw ship $ */


g_debug_flag VARCHAR2(1) := 'N';
g_date DATE := NULL;
g_mode VARCHAR2(30) := NULL;
g_preference VARCHAR2(50) := NULL;
g_start_section VARCHAR2(120) := NULL;
g_include_subsection VARCHAR2(3) := NULL;
g_start_date VARCHAR2(30) := NULL;
g_end_date VARCHAR2(30) := NULL;
g_product_name VARCHAR2(240) := NULL;
g_product_number VARCHAR2(40) := NULL;
g_publish_status VARCHAR2(20) := NULL;
g_index NUMBER := 1;
g_product_tbl PRODUCT_TBL_TYPE;

g_section_code VARCHAR2(240);
g_section_name VARCHAR2(120);
-- Debug Information Pring Procedure
-- Y : Display Debug in the Conc. Program Log.
-- N:  No Debug Statement Printout
PROCEDURE printDebuglog(p_debug_str IN VARCHAR2)
IS
   l_debug VARCHAR2(1);

BEGIN
        l_debug := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  IF g_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_str);
  END IF;
     IF (l_debug = 'Y') THEN
        IBE_UTIL.debug(p_debug_str);
     END IF;
END printDebugLog;

PROCEDURE printOutput(p_message IN VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
END printOutput;

PROCEDURE printReport
IS
  l_i NUMBER;
  l_temp_msg VARCHAR2(2000);
  l_title1 VARCHAR2(2000);
  l_add VARCHAR2(100);
  l_remove VARCHAR2(100);
BEGIN
  fnd_message.set_name('IBE','IBE_M_ADDED_PRMT');
  l_temp_msg := fnd_message.get;
  l_add := substr(l_temp_msg,1,100);
  fnd_message.set_name('IBE','IBE_M_REMOVED_PRMT');
  l_temp_msg := fnd_message.get;
  l_remove := substr(l_temp_msg,1,100);
  fnd_message.set_name('IBE','IBE_PRMT_DATE_G');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_date);
  fnd_message.set_name('IBE','IBE_M_RUNNING_MODE_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_mode);
  fnd_message.set_name('IBE','IBE_PRMT_PREFERENCES_G');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_preference);
  printOutput('');
  fnd_message.set_name('IBE','IBE_M_STARTING_SECTION_PRMT');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_start_section);
  fnd_message.set_name('IBE','IBE_M_SELECT_SUB_SECTION_PRMT');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_include_subsection);
  printOutput('');
  fnd_message.set_name('IBE','IBE_M_SELECT_PRODUCT_PRMT');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||':');
  IF (g_start_date IS NOT NULL) OR (g_end_date IS NOT NULL) THEN
    fnd_message.set_name('IBE','IBE_PRMT_FROM_COLON');
    l_temp_msg := fnd_message.get;
    fnd_message.set_name('IBE','IBE_PRMT_TO_G');
    l_title1 := fnd_message.get;
    printOutput(l_temp_msg||' '||g_start_date||' '||l_title1||' '||g_end_date);
  END IF;
  IF (g_product_name IS NOT NULL) THEN
    fnd_message.set_name('IBE','IBE_PRMT_ITM_NAME_G');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg||': '||g_product_name);
  END IF;
  IF (g_product_number IS NOT NULL) THEN
    fnd_message.set_name('IBE','IBE_M_PRODUCT_NUMBER_PRMT');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg||': '||g_product_number);
  END IF;
  IF (g_publish_status IS NOT NULL) THEN
    fnd_message.set_name('IBE','IBE_M_WEB_PUB_STATUS_PRMT');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg||': '||g_publish_status);
  END IF;
  IF (g_product_tbl.count > 0) THEN
    fnd_message.set_name('IBE','IBE_M_PRODUCT_NUMBER_PRMT');
    l_temp_msg := fnd_message.get;
    IF (length(l_temp_msg) >= 20) THEN
	 l_title1 := substr(l_temp_msg,1,20) || ' ';
    ELSE
	 l_title1 := RPAD(l_temp_msg,20,' ')||' ';
    END IF;
    fnd_message.set_name('IBE','IBE_PRMT_ITM_NAME_G');
    l_temp_msg := fnd_message.get;
    IF (length(l_temp_msg) >= 40) THEN
	 l_title1 := l_title1 || substr(l_temp_msg,1,40);
    ELSE
	 l_title1 := l_title1 || RPAD(l_temp_msg,40,' ')||' ';
    END IF;
    fnd_message.set_name('IBE','IBE_M_ACTION_PRMT');
    l_temp_msg := fnd_message.get;
    IF (length(l_temp_msg) >= 7) THEN
	 l_title1 := l_title1 || substr(l_temp_msg,1,7);
    ELSE
	 l_title1 := l_title1 || RPAD(l_temp_msg,7,' ')||' ';
    END IF;
    fnd_message.set_name('IBE','IBE_PRMT_SECTION_NAME_G');
    l_temp_msg := fnd_message.get;
    IF (length(l_temp_msg) >= 40) THEN
	 l_title1 := l_title1 || substr(l_temp_msg,1,40);
    ELSE
	 l_title1 := l_title1 || RPAD(l_temp_msg,40,' ')||' ';
    END IF;
    fnd_message.set_name('IBE','IBE_PRMT_SECTION_CODE');
    l_temp_msg := fnd_message.get;
    l_title1 := l_title1 || l_temp_msg;
    printOutput(l_title1);
    -- printOutput('Product Number       '||
    -- 'Product Name                             '||
    -- 'Action  Section Name                            '||
    -- ' Section Code        ');
    printOutput('---------------------'||
	 '-----------------------------------------'||
	 '------------------------------------------------'||
	 '---------------------');
    FOR l_i IN 1..g_product_tbl.count LOOP
	 IF g_product_tbl(l_i).action = 'Added' THEN
	   l_temp_msg := RPAD(l_add,7,' ');
	 ELSIF g_product_tbl(l_i).action = 'Removed' THEN
	   l_temp_msg := RPAD(l_remove,7,' ');
	 ELSE
	   l_temp_msg := RPAD(' ',7,' ');
	 END IF;
	 printOutput(RPAD(g_product_tbl(l_i).product_number,20,' ')||
	   ' '||RPAD(g_product_tbl(l_i).product_name,40,' ')||' '
	   ||l_temp_msg||' '
	   ||RPAD(g_product_tbl(l_i).section_name,40,' ')||' '
	   ||RPAD(g_product_tbl(l_i).section_code,20,' '));
    END LOOP;
  END IF;
END printReport;

FUNCTION checkSection(p_section_id IN NUMBER)
  RETURN VARCHAR2
IS
  l_master_mini_site_id NUMBER;
  l_master_root_section_id NUMBER;
BEGIN
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id(
    x_mini_site_id => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id);
  RETURN check_section(p_section_id, l_master_mini_site_id);
END;

FUNCTION check_section(p_section_id IN NUMBER,
                       p_master_mini_site_id IN NUMBER) RETURN VARCHAR2
IS
  l_temp NUMBER;
  l_featured_section VARCHAR2(1) := 'N';
  l_leaf_section VARCHAR2(1) := 'N';
  l_return VARCHAR2(1) := 'N';

  -- Check if a section is a featured section
  CURSOR c_check_featured_section(c_section_id NUMBER) IS
    SELECT 1
	 FROM ibe_dsp_sections_b
     WHERE section_id = c_section_id
	  AND section_type_code = 'F';

  -- Check if a section has subsection or not
  CURSOR c_check_leaf_section(c_section_id NUMBER,
    c_master_mini_site_id NUMBER) IS
    SELECT 1
	 FROM ibe_dsp_msite_sct_sects
     WHERE mini_site_id = c_master_mini_site_id
	  AND parent_section_id = c_section_id;

BEGIN
  l_featured_section := 'N';
  OPEN c_check_featured_section(p_section_id);
  FETCH c_check_featured_section INTO l_temp;
  IF c_check_featured_section%FOUND THEN
    l_featured_section := 'Y';
  END IF;
  CLOSE c_check_featured_section;
  l_leaf_section := 'Y';
  OPEN c_check_leaf_section(p_section_id, p_master_mini_site_id);
  FETCH c_check_leaf_section INTO l_temp;
  IF c_check_leaf_section%FOUND THEN
    l_leaf_section := 'N';
  END IF;
  CLOSE c_check_leaf_section;
  IF (l_featured_section = 'Y') OR (l_leaf_section = 'Y') THEN
    l_return := 'Y';
  END IF;
  RETURN l_return;
END check_section;

PROCEDURE add_only(p_mode IN VARCHAR2,
			    p_category_set_id IN NUMBER,
			    p_organization_id IN NUMBER,
			    p_section_id IN NUMBER,
			    p_product_name IN VARCHAR2,
			    p_product_number IN VARCHAR2,
			    p_publish_flag IN VARCHAR2,
			    p_start_date IN DATE,
			    p_end_date IN DATE,
			    x_return_status OUT NOCOPY VARCHAR2,
			    x_msg_count OUT NOCOPY NUMBER,
			    x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_only';

  l_inventory_item_id NUMBER;
  l_part_number VARCHAR2(40);
  l_description VARCHAR2(240);
  l_category_id NUMBER;
  l_temp NUMBER;

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_section_item_id NUMBER;
  l_mini_site_section_item_id NUMBER;
  l_mini_site_id NUMBER;

  l_published_flag VARCHAR2(15);
  l_bind_flag NUMBER := 0;
  l_start_date DATE := NULL;
  l_end_date DATE := NULL;

  TYPE ItemCurType IS REF CURSOR;
  item_csr ItemCurType;
  -- product name, product_number
  -- CURSOR c_inventory_items(c_category_id NUMBER,
  --   c_category_set_id NUMBER, c_organization_id NUMBER) IS
  l_sql VARCHAR2(2000) := 'SELECT mic.inventory_item_id, '||
    'msi.concatenated_segments, ms.description '||
    'FROM mtl_item_categories mic, mtl_system_items_kfv msi, '||
    '     mtl_system_items_vl ms ' ||
    'WHERE mic.inventory_item_id = ms.inventory_item_id ' ||
    '  AND mic.organization_id = ms.organization_id ' ||
    '  AND mic.organization_id = msi.organization_id ' ||
    '  AND mic.inventory_item_id = msi.inventory_item_id ' ||
    '  AND mic.category_set_id = :category_set_id ' ||
    '  AND mic.organization_id = :organization_id ' ||
    '  AND mic.category_id = :category_id ' ||
    -- This is for fixing bug 3037399 and 3036491
    '  AND NOT(ms.replenish_to_order_flag = ' || '''' || 'Y' || '''' ||
    '  AND ms.base_item_id  is not null ' ||
    '  AND ms.auto_created_config_flag = ' || '''' || 'Y' || '''' || ') ';

  CURSOR c_categories(c_section_id NUMBER) IS
    SELECT dest_object_id
	 FROM ibe_ct_relation_rules
     WHERE relation_type_code = 'AUTOPLACEMENT'
	  AND origin_object_type = 'S'
	  AND dest_object_type = 'C'
	  AND origin_object_id = c_section_id;
/*
  CURSOR c_section_msites(c_section_id NUMBER) IS
    SELECT DISTINCT mini_site_id
	 FROM ibe_dsp_msite_sct_sects
     WHERE SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE)
	  AND child_section_id = c_section_id;
*/
  -- start_date, end_date
  CURSOR c_check_section_item(c_section_id NUMBER,
    c_item_id NUMBER, c_organization_id NUMBER) IS
    SELECT section_item_id
	 FROM ibe_dsp_section_items
     WHERE section_id = c_section_id
	  AND inventory_item_id = c_item_id
	  AND organization_id = c_organization_id;

  l_inventory_item_ids JTF_NUMBER_TABLE;
  l_organization_ids JTF_NUMBER_TABLE;
  l_start_date_actives JTF_DATE_TABLE;
  l_end_date_actives JTF_DATE_TABLE;
  l_sort_orders JTF_NUMBER_TABLE;
  l_association_reason_codes JTF_VARCHAR2_TABLE_300;
  x_section_item_ids JTF_NUMBER_TABLE;
  x_duplicate_association_status VARCHAR2(10);

  l_master_mini_site_id NUMBER;
  l_master_root_section_id NUMBER;
  l_sect_item_id NUMBER;
  CURSOR c_check_msite_sct_items(c_section_item_id NUMBER,
    c_minisite_id NUMBER) IS
    SELECT mini_site_section_item_id
	 FROM ibe_dsp_msite_sct_items
      WHERE mini_site_id = c_minisite_id
	   AND section_item_id = c_section_item_id;
BEGIN
  printDebuglog('Get Master Minisite');
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id(
    x_mini_site_id => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id);
  printDebuglog('Master minisite='||to_char(l_master_mini_site_id));
  IF (p_start_date IS NOT NULL) THEN
    l_start_date := p_start_date;
  END IF;
  l_sql := l_sql || ' AND ms.creation_date>=NVL( :start_date ,ms.creation_date)';
  IF (p_end_date IS NOT NULL) THEN
    l_end_date := p_end_date;
  END IF;
  l_sql := l_sql || ' AND ms.creation_date<=NVL( :end_date ,ms.creation_date)';
  IF (p_product_name IS NOT NULL) THEN
    l_sql := l_sql || ' AND NLS_UPPER(ms.description) LIKE :product_name';
    l_bind_flag := l_bind_flag + 1;
  END IF;
  IF (p_product_number IS NOT NULL) THEN
    l_sql:=l_sql||' AND NLS_UPPER(msi.concatenated_segments) LIKE :product_number';
    l_bind_flag := l_bind_flag + 10;
  END IF;
  IF (p_publish_flag IS NOT NULL) THEN
    -- This is for fixing bug 2577496
    l_sql := l_sql || ' AND msi.web_status = :published_flag';
    l_bind_flag := l_bind_flag + 100;
    IF (p_publish_flag = 'Y') THEN
	 l_published_flag := 'PUBLISHED';
    ELSIF (p_publish_flag = 'N') THEN
	 l_published_flag := 'UNPUBLISHED';
    END IF;
  ELSE
    -- This is for fixing bug 3037399 and 3036491
    -- only associate published and unpublished products to section
    l_sql := l_sql || ' AND msi.web_status in (' ||
	 ''''||'PUBLISHED'||''''||','||''''||'UNPUBLISHED'||''''||')';
  END IF;
  printDebuglog('SQL='||l_sql);
  -- Begin for calling associate item to section
  l_inventory_item_ids := JTF_NUMBER_TABLE();
  l_organization_ids := JTF_NUMBER_TABLE();
  l_start_date_actives := JTF_DATE_TABLE();
  l_end_date_actives := JTF_DATE_TABLE();
  l_sort_orders := JTF_NUMBER_TABLE();
  l_association_reason_codes := JTF_VARCHAR2_TABLE_300();
  x_section_item_ids := JTF_NUMBER_TABLE();
  l_inventory_item_ids.extend(1);
  l_organization_ids.extend(1);
  l_start_date_actives.extend(1);
  l_end_date_actives.extend(1);
  l_sort_orders.extend(1);
  l_association_reason_codes.extend(1);
  x_section_item_ids.extend(1);
  -- End for calling associate item to section
  OPEN c_categories(p_section_id);
  LOOP
    FETCH c_categories INTO l_category_id;
    EXIT WHEN c_categories%NOTFOUND;
    -- OPEN c_inventory_items(l_category_id, p_category_set_id,
    -- p_organization_id);
    IF (l_bind_flag = 0) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date;
    ELSIF (l_bind_flag = 1) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_name='||NLS_UPPER(p_product_name));
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_name);
    ELSIF (l_bind_flag = 10) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_number='||NLS_UPPER(p_product_number));
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_number);
    ELSIF (l_bind_flag = 100) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('published_flag='||l_published_flag);
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, l_published_flag;
    ELSIF (l_bind_flag = 11) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_name='||NLS_UPPER(p_product_name));
	 printDebuglog('product_number='||NLS_UPPER(p_product_number));
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_name), NLS_UPPER(p_product_number);
    ELSIF (l_bind_flag = 101) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_name='||NLS_UPPER(p_product_name));
	 printDebuglog('published_flag='||l_published_flag);
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_name), l_published_flag;
    ELSIF (l_bind_flag = 110) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_number='||NLS_UPPER(p_product_number));
	 printDebuglog('published_flag='||l_published_flag);
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_number), l_published_flag;
    ELSIF (l_bind_flag = 111) THEN
      printDebuglog('bind_flag='||l_bind_flag);
	 printDebuglog('category_set_id='||p_category_set_id);
	 printDebuglog('organization_id='||p_organization_id);
	 printDebuglog('category_id='||l_category_id);
	 printDebuglog('start_date='||l_start_date);
	 printDebuglog('end_date='||l_end_date);
	 printDebuglog('product_name='||NLS_UPPER(p_product_name));
	 printDebuglog('product_number='||NLS_UPPER(p_product_number));
	 printDebuglog('published_flag='||l_published_flag);
      OPEN item_csr FOR l_sql
	   USING p_category_set_id, p_organization_id, l_category_id, l_start_date,
	   l_end_date, NLS_UPPER(p_product_name), NLS_UPPER(p_product_number),
	   l_published_flag;
    END IF;
    LOOP
      FETCH item_csr INTO l_inventory_item_id, l_part_number,
	   l_description;
	 EXIT WHEN item_csr%NOTFOUND;
	 OPEN c_check_section_item(p_section_id,l_inventory_item_id,
	   p_organization_id);
	 FETCH c_check_section_item INTO l_temp;
	 IF (c_check_section_item%NOTFOUND) THEN
        printDebuglog('Add Inventory item id='||to_char(l_inventory_item_id)
		||' Part number='||l_part_number);
	   g_product_tbl(g_index).product_number := l_part_number;
	   g_product_tbl(g_index).product_name := l_description;
	   g_product_tbl(g_index).action := 'Added';
	   g_product_tbl(g_index).section_code := g_section_code;
	   g_product_tbl(g_index).section_name := g_sectioN_name;
	   g_index := g_index + 1;
	   IF (p_mode = 'EXECUTION') THEN
		-- Call Associate_Items_To_Section to assign
		-- item to a section
		l_inventory_item_ids(1) := l_inventory_item_id;
		l_organization_ids(1) := p_organization_id;
		l_start_date_actives(1) := SYSDATE;
		l_end_date_actives(1) := NULL;
		l_sort_orders(1) := NULL;
		l_association_reason_codes(1) := NULL;
		printDebuglog('before calling Associate_Items_To_Section');
		printDebuglog('inventory_item_id='||to_char(l_inventory_item_ids(1)));
		printDebuglog('organization_id='||to_char(l_organization_ids(1)));
		IBE_DSP_HIERARCHY_SETUP_PVT.Associate_Items_To_Section(
		  p_api_version => 1.0,
		  p_init_msg_list => FND_API.G_FALSE,
		  p_commit => FND_API.G_FALSE,
		  p_validation_level =>  FND_API.G_VALID_LEVEL_FULL,
		  p_section_id => p_section_id,
		  p_inventory_item_ids => l_inventory_item_ids,
		  p_organization_ids => l_organization_ids,
		  p_start_date_actives => l_start_date_actives,
		  p_end_date_actives => l_end_date_actives,
		  p_sort_orders => l_sort_orders,
		  p_association_reason_codes => l_association_reason_codes,
		  x_section_item_ids => x_section_item_ids,
		  x_duplicate_association_status => x_duplicate_association_status,
		  x_return_status => l_return_status,
		  x_msg_count => l_msg_count,
		  x_msg_data => l_msg_data);
	    printDebuglog('after calling Associate_Items_To_Section:'
		 ||l_return_status);
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		   COMMIT;
		   printDebuglog('Commit the section_item association');
		 ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		   printDebuglog('G_RET_STS_ERROR in Associate_Items_To_Section');
		   FOR i IN 1..l_msg_count LOOP
		     l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
		     printDebuglog(l_msg_data);
         END LOOP;
		   RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		   printDebuglog('G_RET_STS_UNEXP_ERROR in Associate_Items_To_Section');
		   FOR i IN 1..l_msg_count LOOP
		     l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
		     printDebuglog(l_msg_data);
         END LOOP;
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
	   END IF;
	 ELSE
	   printDebuglog('Inventory item id='||to_char(l_inventory_item_id)
		||' Part number='||l_part_number);
	   printDebuglog('Item is linked to section already');
        -- If section_item is found
	   -- For execution mode, check if the section-item is linked
	   -- to master minisite, if so, clean the data
	   IF (p_mode = 'EXECUTION') THEN
		printDebuglog('Execution mode: Check if master minisite is' ||
		  'linked to the section-item:'||to_char(l_temp)||
		  ' master site='||to_char(l_master_mini_site_id));
          l_sect_item_id := l_temp;
		-- Check if section_item is assigned to minisite
		OPEN c_check_msite_sct_items(l_sect_item_id,l_master_mini_site_id);
		FETCH c_check_msite_sct_items INTO l_temp;
		IF (c_check_msite_sct_items%FOUND) THEN
		  CLOSE c_check_msite_sct_items;
            printDebuglog('Clean master minisite from section-item:' ||
		    to_char(l_temp));
            DELETE FROM IBE_DSP_MSITE_SCT_ITEMS
		    WHERE mini_site_section_item_id = l_temp;
		ELSE
		  printDebuglog('No data clean action');
		  CLOSE c_check_msite_sct_items;
		END IF;
	   END IF;
	 END IF;
	 CLOSE c_check_section_item;
    END LOOP;
    CLOSE item_csr;
  END LOOP;
  CLOSE c_categories;
  l_inventory_item_ids.delete;
  l_organization_ids.delete;
  l_start_date_actives.delete;
  l_end_date_actives.delete;
  l_sort_orders.delete;
  l_association_reason_codes.delete;
  x_section_item_ids.delete;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data);
END add_only;

PROCEDURE add_remove(p_mode IN VARCHAR2,
				 p_category_set_id IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_section_id IN NUMBER,
				 p_product_name IN VARCHAR2,
				 p_product_number IN VARCHAR2,
				 p_publish_flag IN VARCHAR2,
				 p_start_date IN DATE,
				 p_end_date IN DATE,
			      x_return_status OUT NOCOPY VARCHAR2,
			      x_msg_count OUT NOCOPY NUMBER,
			      x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_remove';

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_section_item_id NUMBER;
  l_inventory_item_id NUMBER;
  l_part_number VARCHAR2(40);
  l_description VARCHAR2(240);
  l_temp NUMBER;

--04/20/09   amaheshw Bug 8415339
  TYPE ItemCurType IS REF CURSOR;
  c_check_item ItemCurType;

  l_sql VARCHAR2(2000) := 'SELECT 1 FROM mtl_item_categories mic, ibe_ct_relation_rules rule, mtl_system_items_vl ms ' ||
    ' WHERE mic.category_set_id = :c_category_set_id ' ||
    '  AND mic.organization_id = :p_organization_id ' ||
    '  AND mic.inventory_item_id = :c_inventory_item_id ' ||
    '  AND mic.category_id = rule.dest_object_id ' ||
    '  AND rule.relation_type_code = ' || '''' || 'AUTOPLACEMENT' || '''' ||
    '  AND rule.origin_object_type = ' || '''' || 'S' || '''' ||
    '  AND rule.dest_object_type = ' || '''' || 'C' || '''' ||
    '  AND rule.origin_object_id = :c_section_id ' ||
    '  AND ms.inventory_item_id = mic.inventory_item_id ' ||
    '  AND  ms.organization_id = mic.organization_id '     ||
    -- This is for fixing bug 3037399 and 3036491
    '  AND NOT(ms.replenish_to_order_flag = ' || '''' || 'Y' || '''' ||
    '  AND ms.base_item_id  is not null ' ||
    '  AND ms.auto_created_config_flag = ' || '''' || 'Y' || '''' || ') ';


/*  Commented 04/20/09   amaheshw Bug 8415339
  CURSOR c_check_item(c_section_id NUMBER,
    c_category_set_id NUMBER, c_organization_id NUMBER,
    c_inventory_item_id NUMBER) IS
    SELECT 1 FROM mtl_item_categories mic, ibe_ct_relation_rules rule,
	   mtl_system_items_vl ms
     WHERE mic.category_set_id = c_category_set_id
	  AND mic.organization_id = p_organization_id
	  AND mic.inventory_item_id = c_inventory_item_id
	  AND mic.category_id = rule.dest_object_id
	  AND rule.relation_type_code = 'AUTOPLACEMENT'
	  AND rule.origin_object_type = 'S'
	  AND rule.dest_object_type = 'C'
	  AND rule.origin_object_id = c_section_id
	  AND ms.inventory_item_id = mic.inventory_item_id
	  AND ms.organization_id = mic.organization_id
	  AND ms.web_status in ('PUBLISHED','UNPUBLISHED')
       AND NOT(ms.replenish_to_order_flag = 'Y'
              AND ms.base_item_id  is not null
              AND ms.auto_created_config_flag = 'Y');
end of comment */

  -- start_date, end_date
  CURSOR c_section_items(c_section_id NUMBER,
    c_organization_id NUMBER, c_start_date DATE,
    c_end_date DATE) IS
    SELECT si.section_item_id, si.inventory_item_id,
		 msi.concatenated_segments, ms.description
	 FROM ibe_dsp_section_items si, mtl_system_items_kfv msi,
		 mtl_system_items_vl ms
     WHERE si.inventory_item_id = ms.inventory_item_id
	  AND si.organization_id = ms.organization_id
	  AND si.organization_id = msi.organization_id
	  AND si.inventory_item_id = msi.inventory_item_id
	  AND si.section_id = c_section_id
	  AND si.organization_id = c_organization_id;

BEGIN

--04/20/09   amaheshw Bug 8415339

  IF (p_publish_flag IS NOT NULL) THEN


    IF (p_publish_flag = 'Y') THEN
        l_sql := l_sql || ' AND ms.web_status= ' || '''' || 'PUBLISHED' || '''' ;
    ELSIF (p_publish_flag = 'N') THEN
        l_sql := l_sql || ' AND ms.web_status= ' || '''' || 'UNPUBLISHED' || '''' ;
    END IF;
  ELSE

    l_sql := l_sql || ' AND ms.web_status in (' ||
     ''''||'PUBLISHED'||''''||','||''''||'UNPUBLISHED'||''''||')';
  END IF;
-- end 04/20/09   amaheshw Bug 8415339
  printDebuglog('SQL='||l_sql);
  -- Remove section item and minisite logic
  OPEN c_section_items(p_section_id, p_organization_id,
    p_start_date, p_end_date);
  LOOP
    FETCH c_section_items INTO l_section_item_id,
	 l_inventory_item_id, l_part_number, l_description;
    EXIT WHEN c_section_items%NOTFOUND;

/* Bug 8490654
-- 04/20/09   amaheshw Bug 8415339
   OPEN c_check_item FOR l_sql
        USING p_section_id, p_category_set_id,
     p_organization_id, l_inventory_item_id;

*/
   OPEN c_check_item FOR l_sql
                   USING  p_category_set_id,
			         p_organization_id, l_inventory_item_id, p_section_id;

/* 04/20/09   amaheshw Bug 8415339
    OPEN c_check_item(p_section_id, p_category_set_id,
	 p_organization_id, l_inventory_item_id);
*/
    FETCH c_check_item INTO l_temp;
    IF c_check_item%NOTFOUND THEN
      printDebuglog('Remove Inventory item id='||to_char(l_inventory_item_id)
	   ||' Part number='||l_part_number);
	 g_product_tbl(g_index).product_number := l_part_number;
	 g_product_tbl(g_index).product_name := l_description;
	 g_product_tbl(g_index).action := 'Removed';
	 g_product_tbl(g_index).section_code := g_section_code;
	 g_product_tbl(g_index).section_name := g_sectioN_name;
	 g_index := g_index + 1;
	 IF (p_mode = 'EXECUTION') THEN
	   -- Should set the end_date_active in IBE_DSP_SECTION_ITEMS
	   -- table and IBE_DSP_MSITE_SCT_ITEMS
        -- For fixing bug 2771549
	   IBE_DSP_SECTION_ITEM_PVT.Delete_Section_Item
		(p_api_version => 1.0,
		 p_init_msg_list => FND_API.G_FALSE,
		 p_commit => FND_API.G_FALSE,
		 p_section_id => p_section_id,
		 p_inventory_item_id => l_inventory_item_id,
		 p_organization_id => p_organization_id,
		 x_return_status => l_return_status,
		 x_msg_count => l_msg_count,
		 x_msg_data => l_msg_data);
        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       COMMIT;
		    printDebuglog('Commit the delete section_item assoication');
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          printDebuglog('G_RET_STS_ERROR in Delete_Section_Item');
          printOutput('G_RET_STS_ERROR in Delete_Section_Item');
          FOR i IN 1..l_msg_count LOOP
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       printDebuglog(l_msg_data);
	       printOutput(l_msg_data);
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          printDebuglog('G_RET_STS_UNEXP_ERROR in Delete_Section_Item');
          printOutput('G_RET_STS_UNEXP_ERROR in Delete_Section_Item');
          FOR i IN 1..l_msg_count LOOP
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       printDebuglog(l_msg_data);
	       printOutput(l_msg_data);
          END LOOP;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
/*
        IBE_DSP_SECTION_ITEM_PVT.Delete_Section_Items_For_Item
          (p_inventory_item_id => l_inventory_item_id,
	      p_organization_id => p_organization_id);
*/
	 END IF;
    END IF;
    CLOSE c_check_item;
  END LOOP;
  CLOSE c_section_items;
  -- Call add_only procedure to add the inventory item to
  -- section
  add_only(p_mode, p_category_set_id, p_organization_id, p_section_id,
    p_product_name, p_product_number, p_publish_flag,
    p_start_date, p_end_date, l_return_status, l_msg_count, l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    printDebuglog('G_RET_STS_ERROR in add_only');
    printOutput('G_RET_STS_ERROR in add_only');
    FOR i IN 1..l_msg_count LOOP
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 printDebuglog(l_msg_data);
	 printOutput(l_msg_data);
    END LOOP;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    printDebuglog('G_RET_STS_UNEXP_ERROR in add_only');
    printOutput('G_RET_STS_UNEXP_ERROR in add_only');
    FOR i IN 1..l_msg_count LOOP
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 printDebuglog(l_msg_data);
	 printOutput(l_msg_data);
    END LOOP;
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data);
END add_remove;

-- p_placement_mode: EVALUATION/EXECUTION
-- p_assignment_mode: ADD_ONLY/ADD_REMOVE
PROCEDURE prod_autoplacement(
	    p_placement_mode IN VARCHAR2,
	    p_assignment_mode IN VARCHAR2,
	    p_target_section IN NUMBER,
	    p_include_subsection IN VARCHAR2,
	    p_product_name IN VARCHAR2,
	    p_product_number VARCHAR2,
	    p_publish_flag VARCHAR2,
	    p_start_date IN DATE,
	    p_end_date IN DATE,
	    x_return_status OUT NOCOPY VARCHAR2,
	    x_msg_count OUT NOCOPY NUMBER,
	    x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'prod_autoplacement';

  l_category_set_id_str VARCHAR2(30);
  l_organization_id_str VARCHAR2(30);
  l_category_set_id NUMBER;
  l_organization_id NUMBER;
  l_master_mini_site_id NUMBER;
  l_master_root_section_id NUMBER;

  l_section_code VARCHAR2(240);
  l_display_name VARCHAR2(120);

  l_section_id NUMBER;

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  CURSOR c_subsections(c_section_id NUMBER,
    c_master_mini_site_id NUMBER) IS
    SELECT child_section_id
	 FROM ibe_dsp_msite_sct_sects
     WHERE mini_site_id = c_master_mini_site_id
	  AND sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate)
     START WITH child_section_id = c_section_id
	  AND mini_site_id = c_master_mini_site_id
     CONNECT BY PRIOR child_section_id = parent_section_id
	  AND mini_site_id = c_master_mini_site_id
	  AND PRIOR mini_site_id = c_master_mini_site_id;

  CURSOR c_get_section_info(c_section_id NUMBER) IS
    SELECT access_name, display_name
	 FROM ibe_dsp_sections_vl
     WHERE section_id = c_section_id;

BEGIN
  g_index := 1;
  l_category_set_id_str
    := FND_PROFILE.VALUE_SPECIFIC('IBE_AUTO_PLACEMENT_CATEGORY_SET',
    null, null, 671);
  printDebuglog('Category set='||l_category_set_id_str);
  IF (l_category_set_id_str IS NULL) THEN
    l_category_set_id_str
	 := FND_PROFILE.VALUE_SPECIFIC('IBE_CATEGORY_SET', null, null, 671);
    printDebuglog('Category set from IBE_CATEGORY_SET'||l_category_set_id_str);
  END IF;
  l_category_set_id := to_number(l_category_set_id_str);
  l_organization_id_str
    := FND_PROFILE.VALUE_SPECIFIC('IBE_ITEM_VALIDATION_ORGANIZATION',
    null, null, 671);
  IF (l_organization_id_str IS NULL) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    l_organization_id := to_number(l_organization_id_str);
  END IF;
  printDebuglog('Organization id='||l_organization_id_str);
  -- Get the master mini-site id
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id(
    x_mini_site_id => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id);
  printDebuglog('Master mini site id='||to_char(l_master_mini_site_id));
  IF (p_include_subsection = 'Y') THEN
    printDebuglog('search subsection...');
    OPEN c_subsections(p_target_section,
				   l_master_mini_site_id);
    LOOP
      FETCH c_subsections INTO l_section_id;
      EXIT WHEN c_subsections%NOTFOUND;
	 OPEN c_get_section_info(l_section_id);
	 FETCH c_get_section_info INTO l_section_code, l_display_name;
	 CLOSE c_get_section_info;
      printDebuglog('Section id='||to_char(l_section_id)
	   ||' Section name='||l_display_name);
	 IF (check_section(l_section_id, l_master_mini_site_id)
	   = 'Y') THEN
        printDebuglog('Section is featured or leaf section');
        g_section_code := l_section_code;
	   g_section_name := l_display_name;
	   IF (p_assignment_mode = 'ADD_ONLY') THEN
          -- printDebuglog('p_assignment_mode is add_only, calling add_only proc');
          add_only(p_placement_mode, l_category_set_id, l_organization_id,
		  l_section_id, p_product_name, p_product_number,
		  p_publish_flag, p_start_date, p_end_date,
		  l_return_status, l_msg_count, l_msg_data);
          printDebuglog('after calling add_only, return status:'||l_return_status);
	   ELSIF (p_assignment_mode = 'ADD_REMOVE') THEN
          --printDebuglog('p_assignment_mode is add_remove, calling add_remove proc');
          add_remove(p_placement_mode, l_category_set_id, l_organization_id,
		  l_section_id, p_product_name, p_product_number,
		  p_publish_flag, p_start_date, p_end_date,
		  l_return_status, l_msg_count, l_msg_data);
          printDebuglog('after calling add_remove, return status:'||l_return_status);
	   END IF;
	   -- Check status
	   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          printDebuglog('G_RET_STS_ERROR in add_remove/add_only');
          printOutput('G_RET_STS_ERROR in add_remove/add_only');
          FOR i IN 1..l_msg_count LOOP
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       printDebuglog(l_msg_data);
	       printOutput(l_msg_data);
          END LOOP;
		RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          printDebuglog('G_RET_STS_UNEXP_ERROR in add_remove/add_only');
          printOutput('G_RET_STS_UNEXP_ERROR in add_remove/add_only');
          FOR i IN 1..l_msg_count LOOP
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       printDebuglog(l_msg_data);
	       printOutput(l_msg_data);
          END LOOP;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	   -- Commit product autoplacement for each section
	   COMMIT;
	 ELSE
        printDebuglog('Section is not a featured or leaf section');
      END IF;
    END LOOP;
    CLOSE c_subsections;
  ELSE
  -- Not include subsection
    IF (check_section(p_target_section, l_master_mini_site_id)
	 = 'Y') THEN
	 -- This is to fix bug 2577441
	 l_section_id := p_target_section;
	 OPEN c_get_section_info(l_section_id);
	 FETCH c_get_section_info INTO l_section_code, l_display_name;
	 CLOSE c_get_section_info;
	 g_section_code := l_section_code;
	 g_section_name := l_display_name;
	 IF (p_assignment_mode = 'ADD_ONLY') THEN
        add_only(p_placement_mode, l_category_set_id, l_organization_id,
		p_target_section, p_product_name, p_product_number,
		p_publish_flag, p_start_date, p_end_date,
		l_return_status, l_msg_count, l_msg_data);
	 ELSIF (p_assignment_mode = 'ADD_REMOVE') THEN
        add_remove(p_placement_mode, l_category_set_id, l_organization_id,
		p_target_section, p_product_name, p_product_number,
		p_publish_flag, p_start_date, p_end_date,
		l_return_status, l_msg_count, l_msg_data);
	 END IF;
	 -- Check status
	 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        printDebuglog('G_RET_STS_ERROR in add_remove/add_only');
        printOutput('G_RET_STS_ERROR in add_remove/add_only');
        FOR i IN 1..l_msg_count LOOP
	     l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	     printDebuglog(l_msg_data);
	     printOutput(l_msg_data);
        END LOOP;
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        printDebuglog('G_RET_STS_UNEXP_ERROR in add_remove/add_only');
        printOutput('G_RET_STS_UNEXP_ERROR in add_remove/add_only');
        FOR i IN 1..l_msg_count LOOP
	     l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	     printDebuglog(l_msg_data);
	     printOutput(l_msg_data);
        END LOOP;
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
	 -- Commit product autoplacement for each section
	 COMMIT;
    ELSE
	 printDebuglog('The target section is not featured or leaf section!');
    END IF;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
	 p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data);
END prod_autoplacement;


PROCEDURE autoPlacement(errbuf OUT NOCOPY VARCHAR2,
				    retcode OUT NOCOPY VARCHAR2,
				    p_placement_mode IN VARCHAR2,
				    p_assignment_mode IN VARCHAR2,
				    p_target_section IN VARCHAR2,
				    p_include_subsection IN VARCHAR2,
				    p_product_name IN VARCHAR2,
				    p_product_number IN VARCHAR2,
				    p_publish_flag IN VARCHAR2,
				    p_start_date IN VARCHAR2,
				    p_end_date IN VARCHAR2,
				    p_debug_flag IN VARCHAR2)
IS
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_assignment_mode VARCHAR2(20);

  l_start_date DATE := NULL;
  l_end_date DATE := NULL;

  l_publish_flag VARCHAR2(1);

  CURSOR c_get_section_info(c_section_id NUMBER) IS
    SELECT display_name
	 FROM ibe_dsp_sections_vl
     WHERE section_id = c_section_id;

BEGIN
  g_date := SYSDATE;
  g_mode := p_placement_mode;
  g_debug_flag := p_debug_flag;
  IF p_debug_flag = 'Y' THEN
    IBE_UTIL.Enable_Debug;
  END IF;
  printDebuglog('----Begin:Parameter list from autoPlacement----');
  printDebuglog('Placement mode='||p_placement_mode);
  printDebuglog('Assignment mode='||p_assignment_mode);
  printDebuglog('Target section='||p_target_section);
  printDebuglog('Include subsection='||p_include_subsection);
  printDebuglog('Product name='||p_product_name);
  printDebuglog('Product number='||p_product_number);
  printDebuglog('Publish flag='||p_publish_flag);
  printDebuglog('Start date='||p_start_date);
  printDebuglog('End date='||p_end_date);
  printDebuglog('Debug flag='||p_debug_flag);
  printDebuglog('----End:Parameter list from autoPlacement----');
  printDebuglog('----Begin:Convert Parameter list for autoPlacement----');
  IF (p_assignment_mode = 'APPEND') THEN
    l_assignment_mode := 'ADD_ONLY';
    g_preference := 'Add Product associations only';
  ELSIF (p_assignment_mode = 'REPLACE') THEN
    l_assignment_mode := 'ADD_REMOVE';
    g_preference := 'Add and remove Product associations';
  END IF;
  printDebuglog('Preference ='||g_preference);
  IF (p_target_section IS NULL) OR (TRIM(p_target_section) = '') THEN
    NULL;
  ELSE
    printDebuglog('Target section id ='||p_target_section);
    open c_get_section_info(to_number(p_target_section));
    FETCH c_get_section_info INTO g_start_section;
    IF c_get_section_info%NOTFOUND THEN
	 g_start_section := NULL;
    END IF;
    CLOSE c_get_section_info;
    printDebuglog('Target section = '||g_start_section);
  END IF;
  IF (p_include_subsection = 'Y') THEN
    g_include_subsection := 'Yes';
  ELSIF (p_include_subsection = 'N') THEN
    g_include_subsection := 'No';
  ELSE
    NULL;
  END IF;
  printDebuglog('Include subsection = '||g_include_subsection);
  g_product_name := p_product_name;
  printDebuglog('Product name = '||g_product_name);
  g_product_number := p_product_number;
  printDebuglog('Product Number = '||g_product_number);
  IF p_publish_flag = 'ALL' THEN
    g_publish_status := 'ALL';
    l_publish_flag :=  NULL;
  ELSIF p_publish_flag = 'PUBLISHED' THEN
    g_publish_status := 'Published';
    l_publish_flag := 'Y';
  ELSIF p_publish_flag = 'UNPUBLISHED' THEN
    g_publish_status := 'Unpublished';
    l_publish_flag := 'N';
  END IF;
  printDebuglog('publish status = '||g_publish_status);
/*
  IF (g_publish_status IS NOT NULL) THEN
    IF (p_publish_flag = 'Y') THEN
      g_publish_status := 'Yes';
    ELSE
      g_publish_status := 'No';
    END IF;
  ELSE
    g_publish_status := NULL;
  END IF;
*/
  IF (p_start_date IS NOT NULL) THEN
    g_start_date := p_start_date;
    l_start_date := fnd_date.canonical_to_date(p_start_date);
    -- to_date(p_start_date,'RRRR/MM/DD HH24:MI:SS');
    l_start_date := trunc(l_start_date);
    printDebuglog('After tuncating start date:'||
	 to_char(l_start_date,'mm/dd/rrrr hh24:mi:ss'));
  ELSE
    g_start_date := NULL;
    l_start_date := NULL;
  END IF;
  IF (p_end_date IS NOT NULL) THEN
    g_end_date := p_end_date;
    l_end_date := fnd_date.canonical_to_date(p_end_date);
    -- to_date(p_end_date,'RRRR/MM/DD HH24:MI:SS');
    l_end_date := trunc(l_end_date) + 1 - 1/(24*3600);
    printDebuglog('After tuncating end date:'||
	 to_char(l_end_date,'mm/dd/rrrr hh24:mi:ss'));
  ELSE
    g_end_date := NULL;
    l_end_date := NULL;
  END IF;
  printDebuglog('----End:Convert Parameter list for autoPlacement----');
  -- Calling prod_autoplacement
  prod_autoplacement(
	    p_placement_mode => p_placement_mode,
	    p_assignment_mode => l_assignment_mode,
	    p_target_section => p_target_section,
	    p_include_subsection => p_include_subsection,
	    p_product_name => p_product_name,
	    p_product_number => p_product_number,
	    p_publish_flag => l_publish_flag,
	    p_start_date => l_start_date,
	    p_end_date => l_end_date,
	    x_return_status => l_return_status,
	    x_msg_count => l_msg_count,
	    x_msg_data => l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    printDebuglog('G_RET_STS_ERROR in prod_autoplacement');
    printOutput('G_RET_STS_ERROR in prod_autoplacement');
    FOR i IN 1..l_msg_count LOOP
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 printDebuglog(l_msg_data);
	 printOutput(l_msg_data);
    END LOOP;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    printDebuglog('G_RET_STS_UNEXP_ERROR in prod_autoplacement');
    FOR i IN 1..l_msg_count LOOP
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 printDebuglog(l_msg_data);
	 printOutput(l_msg_data);
    END LOOP;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  printReport;
  retcode := 0;
  errbuf := 'SUCCESS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    printOutput(SQLCODE||'-'||SQLERRM);
    printDebuglog(SQLCODE||'-'||SQLERRM);
    COMMIT;
    retcode := -1;
    errbuf := SQLCODE||'-'||SQLERRM;
END autoPlacement;


END IBE_M_AUTOPLACEMENT_PVT;

/
