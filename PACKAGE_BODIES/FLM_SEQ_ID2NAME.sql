--------------------------------------------------------
--  DDL for Package Body FLM_SEQ_ID2NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SEQ_ID2NAME" AS
/* $Header: FLMSQIDB.pls 120.1.12000000.2 2007/02/26 19:33:32 yulin ship $  */


/******************************************************************
 * To check whether given attribute needs ID2Name translation     *
 ******************************************************************/
PROCEDURE ID2Name(     p_attribute_id IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_id2name OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                 ) IS
  i NUMBER;
  l_type NUMBER;
  l_tab VARCHAR2(40);
  l_col VARCHAR2(40);
  l_id2name VARCHAR2(2) := NULL;

  l_return_status VARCHAR2(2);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
BEGIN
  IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_id2name := 'N';

  select
    attribute_type, attribute_source
  into l_type, l_col
  from flm_seq_attributes
  where attribute_id = p_attribute_id;

  if (l_type = 4) then
    l_tab := 'MTL_SYSTEM_ITEMS';
  elsif (l_type = 5) then
    l_tab := 'OE_ORDER_LINES_ALL';
  elsif (l_type = 6) then
    l_tab := 'MRP_RECOMMENDATIONS';
  elsif (l_type = 14) then
    l_tab := 'WIP_FLOW_SCHEDULES';
  end if;

  ID2Name(l_tab, l_col, 'F', l_id2name, l_return_status, l_msg_count, l_msg_data);

  x_return_status := l_return_status;
  x_msg_count := l_msg_count;
  x_msg_data := l_msg_data;
  x_id2name := l_id2name;
  return;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_id2name := 'N';

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('flm_seq_id2name' ,'ID2Name');
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END Id2Name;


/******************************************************************
 * To get LOV query for given ID2Name attribute                   *
 ******************************************************************/
PROCEDURE ID2NameLovQuery(
		       p_attribute_id IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_query OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                 ) IS
  i NUMBER;
  l_type NUMBER;
  l_tab VARCHAR2(40);
  l_col VARCHAR2(40);
  l_query VARCHAR2(2000) := NULL;

  l_return_status VARCHAR2(2);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
BEGIN
  IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select
    attribute_type, attribute_source
  into l_type, l_col
  from flm_seq_attributes
  where attribute_id = p_attribute_id;

  if (l_type = 4) then
    l_tab := 'MTL_SYSTEM_ITEMS';
  elsif (l_type = 5) then
    l_tab := 'OE_ORDER_LINES_ALL';
  elsif (l_type = 6) then
    l_tab := 'MRP_RECOMMENDATIONS';
  elsif (l_type = 14) then
    l_tab := 'WIP_FLOW_SCHEDULES';
  end if;

  ID2NameLovQuery(l_tab, l_col, 'F', l_query, l_return_status, l_msg_count, l_msg_data);

  x_return_status := l_return_status;
  x_msg_count := l_msg_count;
  x_msg_data := l_msg_data;
  x_query := l_query;
  return;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_query := null;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('flm_seq_id2name' ,'ID2NameLovQuery');
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END Id2NameLovQuery;


/******************************************************************
 * To check whether given table.column needs ID2Name translation  *
 ******************************************************************/
PROCEDURE ID2Name(     p_table IN VARCHAR2,
                       p_column IN VARCHAR2,
                       p_init_msg_list IN VARCHAR2,
                       x_id2name OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                 ) IS
  i NUMBER;
BEGIN
  IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_id2name := 'N';

  if (ID2Name_Table is null OR ID2Name_Table.COUNT <= 0) then
    ID2NameInit;
  end if;

  if (ID2Name_Table is null OR ID2Name_Table.COUNT <= 0) then
    return;
  end if;

  i := ID2Name_Table.FIRST;
  LOOP
    if ID2Name_Table(i).table_name = UPPER(p_table) AND
       ID2Name_Table(i).column_name = UPPER(p_column)
    then
       x_id2name := 'Y';
       exit;
    end if;
    exit when (i = ID2Name_Table.LAST);
    i := ID2Name_Table.NEXT(i);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_id2name := 'N';

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('flm_seq_id2name' ,'ID2Name');
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END Id2Name;

/*****************************************************
 * To return a LOV query for given ID column.        *
 *****************************************************/
PROCEDURE ID2NameLovQuery(    p_table IN VARCHAR2,
                              p_column IN VARCHAR2,
			      p_init_msg_list IN VARCHAR2,
                              x_query OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
IS
  i NUMBER;
BEGIN
  IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_query := null;

  if (ID2Name_Table is null OR ID2Name_Table.COUNT <= 0) then
    ID2NameInit;
  end if;

  if (ID2Name_Table is null OR ID2Name_Table.COUNT <= 0) then
    return;
  end if;

  i := ID2Name_Table.FIRST;
  LOOP
    if ID2Name_Table(i).table_name = UPPER(p_table) AND
       ID2Name_Table(i).column_name = UPPER(p_column)
    then
       x_query := ID2Name_Table(i).query_string;
       exit;
    end if;
    exit when (i = ID2Name_Table.LAST);
    i := ID2Name_Table.NEXT(i);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_query := null;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('flm_seq_id2name' ,'ID2NameLovQuery');
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END Id2NameLovQuery;


/*****************************************************
 * To return a name for given ID column and ID value *
 *****************************************************/
PROCEDURE ID2NameAttributeValue(
                              p_table IN VARCHAR2,
                              p_column IN VARCHAR2,
                              p_org_id IN NUMBER,
                              p_value IN NUMBER,
			      p_init_msg_list IN VARCHAR2,
                              x_name OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_query VARCHAR2(2000);
  l_return_status VARCHAR2(2);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_cursor INTEGER;
  l_dummy INTEGER;
  l_name VARCHAR2(240) := null;
BEGIN
  IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ID2NameLovQuery(p_table, p_column, p_init_msg_list, l_query,
                  l_return_status, l_msg_count, l_msg_data);

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_query is null) then
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    x_name := null;
    return;
  end if;

  flm_util.init_bind;
  flm_util.add_bind(':org_id', p_org_id);

  l_query := l_query || ' WHERE ID_VALUE=:column_value';
  flm_util.add_bind(':column_value', p_value);

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_query, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_name, 240);

  flm_util.do_binds(l_cursor);

  l_dummy := DBMS_SQL.EXECUTE(l_cursor);
  IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_name);
  END IF;
  DBMS_SQL.CLOSE_CURSOR(l_cursor);

  x_name := l_name;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_name := null;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('flm_seq_id2name' ,'ID2NameAttributeValue');
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END Id2NameAttributeValue;



/******************************************************************
 * Initialize ID2Name_Table if it is not initialized.             *
 ******************************************************************/
PROCEDURE Id2NameInit IS
  i NUMBER := 0;
BEGIN

  -- ID2Name in MSI (Item)

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'INVENTORY_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'PRODUCT_FAMILY_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID AND BOM_ITEM_TYPE = 5' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'BASE_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID AND BOM_ITEM_TYPE = 1' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'ATP_RULE_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT RULE_NAME NAME_VALUE, RULE_ID ID_VALUE ' ||
    'FROM MTL_ATP_RULES ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'ITEM_CATALOG_GROUP_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, ITEM_CATALOG_GROUP_ID ID_VALUE ' ||
    'FROM MTL_ITEM_CATALOG_GROUPS_KFV ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'PICKING_RULE_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT PICKING_RULE_NAME NAME_VALUE, PICKING_RULE_ID ID_VALUE ' ||
    'FROM MTL_PICKING_RULES ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'HAZARD_CLASS_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT HAZARD_CLASS NAME_VALUE, HAZARD_CLASS_ID ID_VALUE ' ||
    'FROM PO_HAZARD_CLASSES ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_SYSTEM_ITEMS';
  ID2Name_Table(i).column_name := 'ENGINEERING_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID AND ENG_ITEM_FLAG = ''Y''' ||
    ')';
  i := i + 1;

  -- ID2Name in SO (Sales Order)

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'INVENTORY_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'ARRIVAL_SET_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT SET_NAME NAME_VALUE, SET_ID ID_VALUE ' ||
    'FROM OE_SETS ' ||
    'WHERE :ORG_ID IS NOT NULL AND SET_TYPE = ''ARRIVAL''' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'SHIP_SET_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT SET_NAME NAME_VALUE, SET_ID ID_VALUE ' ||
    'FROM OE_SETS ' ||
    'WHERE :ORG_ID IS NOT NULL AND SET_TYPE = ''SHIP''' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'LINE_TYPE_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT TRANSACTION_TYPE_CODE NAME_VALUE, TRANSACTION_TYPE_ID ID_VALUE ' ||
    'FROM OE_TRANSACTION_TYPES_ALL ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'SHIP_FROM_ORG_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT NAME NAME_VALUE, ORGANIZATION_ID ID_VALUE ' ||
    'FROM HR_ALL_ORGANIZATION_UNITS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'SHIP_TO_ORG_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT ORGANIZATION_CODE NAME_VALUE, ORGANIZATION_ID ID_VALUE ' ||
    'FROM MTL_PARAMETERS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'PROJECT_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT segment1 NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'FROM PA_PROJECTS_ALL ' ||
    'WHERE :ORG_ID IS NOT NULL ' ||
    'union ' ||
    'select  project_number NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'from  mrp_seiban_numbers ' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'TASK_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT TASK_NUMBER NAME_VALUE, TASK_ID ID_VALUE ' ||
    'FROM PA_TASKS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'LINE_SET_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT SET_NAME NAME_VALUE, SET_ID ID_VALUE ' ||
    'FROM OE_SETS ' ||
    'WHERE :ORG_ID IS NOT NULL AND SET_TYPE = ''LINE''' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'ORDER_SOURCE_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT NAME NAME_VALUE, ORDER_SOURCE_ID ID_VALUE ' ||
    'FROM OE_ORDER_SOURCES ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  /*
  ID2Name_Table(i).table_name := 'OE_ORDER_LINES_ALL';
  ID2Name_Table(i).column_name := 'CONFIG_HEADER_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT NAME NAME_VALUE, CONFIG_HDR_ID ID_VALUE ' ||
    'FROM CZ_CONFIG_HDRS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;
  */


  -- ID2Name in PO (Plan Order)

  ID2Name_Table(i).table_name := 'MRP_RECOMMENDATIONS';
  ID2Name_Table(i).column_name := 'INVENTORY_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MRP_RECOMMENDATIONS';
  ID2Name_Table(i).column_name := 'PROJECT_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT segment1 NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'FROM PA_PROJECTS_ALL ' ||
    'WHERE :ORG_ID IS NOT NULL ' ||
    'union ' ||
    'select  project_number NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'from  mrp_seiban_numbers ' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MRP_RECOMMENDATIONS';
  ID2Name_Table(i).column_name := 'TASK_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT TASK_NUMBER NAME_VALUE, TASK_ID ID_VALUE ' ||
    'FROM PA_TASKS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;


  -- ID2Name in WFS (Flow Schedule)

  ID2Name_Table(i).table_name := 'WIP_FLOW_SCHEDULES';
  ID2Name_Table(i).column_name := 'PRIMARY_ITEM_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT CONCATENATED_SEGMENTS NAME_VALUE, INVENTORY_ITEM_ID ID_VALUE ' ||
    'FROM MTL_SYSTEM_ITEMS_KFV ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'WIP_FLOW_SCHEDULES';
  ID2Name_Table(i).column_name := 'SCHEDULE_GROUP_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT SCHEDULE_GROUP_NAME NAME_VALUE, SCHEDULE_GROUP_ID ID_VALUE ' ||
    'FROM WIP_SCHEDULE_GROUPS ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'WIP_FLOW_SCHEDULES';
  ID2Name_Table(i).column_name := 'KANBAN_CARD_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT KANBAN_CARD_NUMBER NAME_VALUE, KANBAN_CARD_ID ID_VALUE ' ||
    'FROM MTL_KANBAN_CARDS ' ||
    'WHERE ORGANIZATION_ID = :ORG_ID' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'WIP_FLOW_SCHEDULES';
  ID2Name_Table(i).column_name := 'PROJECT_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT segment1 NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'FROM PA_PROJECTS_ALL ' ||
    'WHERE :ORG_ID IS NOT NULL ' ||
    'union ' ||
    'select  project_number NAME_VALUE, PROJECT_ID ID_VALUE ' ||
    'from  mrp_seiban_numbers ' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'WIP_FLOW_SCHEDULES';
  ID2Name_Table(i).column_name := 'TASK_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT TASK_NUMBER NAME_VALUE, TASK_ID ID_VALUE ' ||
    'FROM PA_TASKS ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;

  ID2Name_Table(i).table_name := 'MTL_CATEGORIES';
  ID2Name_Table(i).column_name := 'CATEGORY_ID';
  ID2Name_Table(i).query_string :=
    'SELECT NAME_VALUE, ID_VALUE FROM ' ||
    '(' ||
    'SELECT concatenated_segments NAME_VALUE, CATEGORY_ID ID_VALUE ' ||
    'FROM MTL_CATEGORIES_KFV ' ||
    'WHERE :ORG_ID IS NOT NULL' ||
    ')';
  i := i + 1;


END Id2NameInit;


END flm_seq_id2name;

/
