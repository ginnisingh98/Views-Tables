--------------------------------------------------------
--  DDL for Package Body WMS_UT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_UT_PKG" AS
/* $Header: WMSUTTSB.pls 120.6.12010000.3 2008/09/19 09:48:16 haluthra ship $ */


TYPE demandinfo_rec_type IS RECORD
  (   label                    VARCHAR2(150)
   ,  demand_source_type_id    NUMBER
   ,  demand_source_header_id  NUMBER
   ,  demand_source_line_id    NUMBER
   ,  demand_source_name       VARCHAR2(30)
   ,  demand_source_delivery   NUMBER
   ,  mo_line_id               NUMBER
   );
--
TYPE demand_tbl_type IS TABLE OF demandinfo_rec_type
   INDEX BY BINARY_INTEGER;

--  This record holds information about the reservations for a
--  transaction
TYPE rsvinfo_rec_type IS RECORD
  ( label               VARCHAR2(150)
   ,revision            VARCHAR2(3)
   ,lot_number          VARCHAR2(80)
   ,subinventory_code   VARCHAR2(10)
   ,locator_id          NUMBER
   ,lpn_id              NUMBER
   ,quantity            NUMBER
   ,secondary_quantity  NUMBER
   );
--
TYPE rsvinfo_tbl_type IS TABLE OF rsvinfo_rec_type
   INDEX BY BINARY_INTEGER;



g_trolin_tbl             INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
g_trolin_tbl_clear             INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
g_reservations      inv_reservation_global.mtl_reservation_tbl_type;
g_reservations_clear      inv_reservation_global.mtl_reservation_tbl_type;
g_demand_tbl        demand_tbl_type;
g_demand_tbl_clear  demand_tbl_type;
g_rsvs_tbl          rsvinfo_tbl_type;
g_link_mo_dem	    numtabtype;
g_testname       VARCHAR2(2000);
g_is_simulation  BOOLEAN  := FALSE;
g_item           VARCHAR2(30);
g_item_id        NUMBER;

g_set_material_status    VARCHAR2(80)  :=  'MAT_STATUS';

Procedure print_debug(p_msg     VARCHAR2)
IS
BEGIN
 inv_trx_util_pub.trace(p_msg, 'UTTEST');
 --dbms_output.put_line(p_msg);
END;

Procedure initialize
IS
BEGIN
  g_demand_tbl := g_demand_tbl_clear;
  g_trolin_tbl := g_trolin_tbl_clear;
  g_reservations := g_reservations_clear;
  g_is_simulation := FALSE;

  g_data_masks(1).dtype := 'ORG';
  g_data_masks(1).dmask := '<ORG>';

  g_data_masks(2).dtype := 'FLOW';
  g_data_masks(2).dmask := '<FLOW CODE>';

  g_data_masks(4).dtype := 'REQNUM';
  g_data_masks(4).dmask := '<REQUEST NUMBER>';

  g_data_masks(3).dtype := 'MORDER';
  g_data_masks(3).dmask := '<LABEL>,<TYPE>,<ITEM>,<PRI QTY>,<PRI UOM>,<SEC QTY>,<SEC UOM>,<FROM SUB>,<FROM LOC>,<TO SUB>,<TO LOC>,<DEMAND NAME>';

  g_data_masks(5).dtype := 'RSVS';
  g_data_masks(5).dmask := '<LABEL>, <ITEM>, <REV>, <LOT>, <SUB>, <LOC>, <LPN>, <PRI QTY>, <PRI UOM>, <SEC QTY>, <SEC UOM>';

  g_data_masks(6).dtype := 'SERIAL';
  g_data_masks(6).dmask := '<LABEL>,<L/E>,<SERIAL NUMBER>,<SERIAL NUMBER>, .... ,<SERIAL NUMBER>';

  g_data_masks(7).dtype := 'LOT';
  g_data_masks(7).dmask := '<LABEL>,<LOT,<PRI QTY>,<PRI UOM>,<SEC QTY>,<SEC UOM>';

  g_data_masks(8).dtype := 'ONHAND';
  g_data_masks(8).dmask := g_data_masks(5).dmask;

  g_data_masks(9).dtype := 'ACTION';
  g_data_masks(9).dmask := '<ACTION>,<PARAM 1>, ... ,<PARAM N>';

  g_data_masks(10).dtype := 'SORDER_L';
  g_data_masks(10).dmask := '<LABEL>, <SALES ORDER NUMBER>, <SALES ORDER LINE NUMBER>';

  g_data_masks(11).dtype := 'MMTT';
  g_data_masks(11).dmask := '<TXN  ID>,<SUB>,<TO SUB>,<LOC>,<TO LOC>,<TXN QTY>,<TXN UOM>,<RSV ID>,<Pick Rule>,<Put Rule>';

  g_data_masks(12).dtype := 'MTLT';
  g_data_masks(12).dmask := '<LOT NUMBER>, <TRANSACTION QUANTITY>';

  g_data_masks(13).dtype := 'RULES';
  g_data_masks(13).dmask := '<TYPE PICK/PUT/FULL>, <MODE >, <ID>';

  g_data_masks(14).dtype := 'TXNS';
  g_data_masks(14).dmask := '<LABEL>, <TRX MR / MI>, <ITEM>, <REV>, <SUB>, <TO SUB>, <LOC>, <TO LOC> ,<LPN>, <QTY>, <UOM>';

  g_data_masks(15).dtype := 'SORDER';
  g_data_masks(15).dmask := '<LABEL>, <TYPE>, <ITEM>, <QUANTITY>, ..., <NUM OF ORDERS>, <LINES PER ORDER>';

  g_data_masks(16).dtype := 'SO_ITEM';
  g_data_masks(16).dmask := '<LABEL>, <ITEM>, <QUANTITY>';

 -- Pick or Put
 -- Full, Rule, Strategy
 -- ID - number


  g_flow_type_datatypes(1).flowtype := 'ALLOCATION';
  g_flow_type_datatypes(1).datatype(1) := 2;
  g_flow_type_datatypes(1).datatype(2) := 1;
  g_flow_type_datatypes(1).datatype(3) := 9;
  g_flow_type_datatypes(1).datatype(4) := 13;
  g_flow_type_datatypes(1).datatype(5) := 4;
  g_flow_type_datatypes(1).datatype(6) := 8;
  g_flow_type_datatypes(1).datatype(7) := 5;
  g_flow_type_datatypes(1).datatype(8) := 7;
  g_flow_type_datatypes(1).datatype(9) := 6;
  g_flow_type_datatypes(1).datatype(10) := 3;
  g_flow_type_datatypes(1).datatype(11) := 15;
  g_flow_type_datatypes(1).datatype(12) := 16;
  g_flow_type_datatypes(1).datatype(13) := 10;
  g_flow_type_datatypes(1).datatype(14) := 14;
END;


Function get_datatype_id(p_datatype   VARCHAR2)
Return NUMBER
IS
i NUMBER;
BEGIN
  FOR i in 1..g_data_masks.count LOOP
     IF p_datatype = g_data_masks(i).dtype THEN
        return i;
     END IF;
  END LOOP;

  return 0;

END get_datatype_id;


Function get_lst_val(p_vallst   chartabtype150, p_indx     number)
RETURN VARCHAR2
IS
 l_ret_val   VARCHAR2(150);
BEGIN
  l_ret_val :=  p_vallst(p_indx);
  return l_ret_val;
EXCEPTION
  WHEN OTHERS THEN
  return NULL;
END;


Function get_value(p_data   IN   dblarrchartabtype150,
                   p_datatype   VARCHAR2)
Return VARCHAR2 IS
l_dt_id   NUMBER;
l_ret_val  VARCHAR2(2000);
BEGIN

  l_dt_id := get_datatype_id(p_datatype);
  IF p_data.EXISTS(l_dt_id) THEN
     l_ret_val := p_data(l_dt_id)(1)(1);
  END IF;

  return l_ret_val;

END get_value;

Function get_value_list(p_data   IN   dblarrchartabtype150,
                   p_datatype   VARCHAR2)
Return arrchartabtype150 IS
l_dt_id   NUMBER;
l_ret_val  arrchartabtype150;
BEGIN

  l_dt_id := get_datatype_id(p_datatype);
  IF p_data.EXISTS(l_dt_id) THEN
     l_ret_val := p_data(l_dt_id);
  END IF;

  return l_ret_val;

END get_value_list;

Function get_value_label_list(p_data   IN   dblarrchartabtype150,
                   p_datatype   VARCHAR2,
                   p_label      VARCHAR2)
Return arrchartabtype150 IS
l_dt_id   NUMBER;
i   NUMBER;
j   NUMBER;
l_ret_val  arrchartabtype150;
BEGIN

  l_dt_id := get_datatype_id(p_datatype);
  IF p_data.EXISTS(l_dt_id) THEN
     j := 1;
     FOR i in 1..p_data(l_dt_id).count LOOP
        IF upper(p_data(l_dt_id)(i)(1)) = upper(p_label) THEN
           l_ret_val(j) := p_data(l_dt_id)(i);
           j := j + 1;
        END IF;
     END LOOP;
  END IF;

  return l_ret_val;

END get_value_label_list;

FUNCTION get_demand_label_index(p_label  VARCHAR2)
RETURN NUMBER
IS
BEGIN
  FOR i in 1..g_demand_tbl.count LOOP
     IF g_demand_tbl(i).label = p_label THEN
        return i;
     END IF;
  END LOOP;

  return 0;

END get_demand_label_index;

FUNCTION nospaces(p_text VARCHAR2)
Return VARCHAR2
IS
l_rem_txt    VARCHAR2(150);
l_ret_txt    VARCHAR2(150);
spaceseparation  NUMBER;
BEGIN
  l_rem_txt := p_text;
  LOOP
    EXIT WHEN l_rem_txt IS NULL;
    spaceseparation := INSTR(l_rem_txt, ' ',1,1);
    IF spaceseparation = 0 THEN
       spaceseparation := length(l_rem_txt) + 1;
    END IF;

    l_ret_txt := l_ret_txt || SUBSTR(l_rem_txt,1,spaceseparation - 1);
    l_rem_txt := LTRIM(SUBSTR(l_rem_txt,1,spaceseparation + 1));

  END LOOP;

  return l_ret_txt;
END nospaces;


FUNCTION parse_text(p_text VARCHAR2, p_separation VARCHAR2)
Return chartabtype150
IS
l_parsed_text  chartabtype150;
l_rem_text     VARCHAR2(2000);
commaseparation NUMBER;
l_indx          NUMBER;
BEGIN

  l_indx := 0;
  l_rem_text := p_text;
  LOOP
    EXIT WHEN l_rem_text IS NULL;
    l_indx := l_indx + 1;
    commaseparation := INSTR(l_rem_text, p_separation,1,1);
    IF commaseparation = 0 THEN
       commaseparation := length(l_rem_text) + 1;
    END IF;
    l_parsed_text(l_indx) := RTRIM(LTRIM(SUBSTR(l_rem_text, 1, commaseparation - 1)));
    --print_debug(l_parsed_text(l_indx));
    l_rem_text := SUBSTR(l_rem_text, commaseparation + 1);

  END LOOP;
  RETURN l_parsed_text;

END parse_text;


PROCEDURE write_to_output(p_test_id NUMBER, p_datatype    VARCHAR2, p_text     VARCHAR2, p_runid    VARCHAR2) IS

 TYPE   c_ut_tab_rec  IS RECORD (
  FLOW_TYPE_ID   NUMBER,
  TESTSET_ID     NUMBER,
  TESTSET        VARCHAR2(80),
  TEST_ID        NUMBER,
  TESTNAME       VARCHAR2(150),
  TEXT           VARCHAR2(2000),
  DATATYPE       VARCHAR2(80),
  IN_OUT         VARCHAR2(3),
  RUNID          NUMBER);

 c_test_rec c_ut_tab_rec;
 --c_test_rec    WMS_UT_TAB%ROWTYPE;
BEGIN
print_debug(' write_to_output - ' || p_datatype || ' : ' || p_text);

 EXECUTE IMMEDIATE
  ' SELECT * '			 ||
  ' FROM wms_ut_tab'		 ||
  ' WHERE test_id = :p_test_id ' ||
    ' AND ROWNUM = 1 '
   INTO c_test_rec
   USING p_test_id;

 EXECUTE IMMEDIATE
 ' INSERT INTO wms_ut_tab '	||
 ' (FLOW_TYPE_ID,'		||
 ' TESTSET_ID,'			||
 ' TESTSET,'			||
 ' TEST_ID,'			||
 ' TESTNAME,'			||
 ' TEXT,'			||
 ' DATATYPE,'			||
 ' IN_OUT,'			||
 ' RUNID)'			||
 ' values '			||
 ' (:flow_type_id, :testset_id, :testset, :p_test_id, :testname, :p_text, :p_datatype, :p_out, :p_runid) '
 using c_test_rec.flow_type_id, c_test_rec.testset_id, c_test_rec.testset, p_test_id, c_test_rec.testname, p_text, p_datatype, 'OUT', p_runid;
end write_to_output;

PROCEDURE write_ut_error(p_test_id NUMBER, p_text     VARCHAR2, p_runid    VARCHAR2)
IS
BEGIN

   write_to_output(p_test_id, 'UTERROR',p_text, p_runid);

END write_ut_error;


FUNCTION get_item_id (p_org_id    NUMBER, p_item    VARCHAR2, p_test_id NUMBER, p_run_id  NUMBER)
RETURN NUMBER
IS
BEGIN
     IF nvl(g_item,'@#') <> p_item THEN
        SELECT inventory_item_id
         INTO g_item_id
        FROM mtl_system_items
        WHERE organization_id = p_org_id
          AND segment1 = p_item;
        g_item := p_item;
     END IF;
     return g_item_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        write_ut_error(p_test_id,' Item ' || p_item || ' does not exist in org id ' || p_org_id, p_run_id);
        RAISE;

END;


FUNCTION get_loc_id (p_org_id  NUMBER,p_sub_code   VARCHAR2, p_loc  VARCHAR2)
RETURN NUMBER
IS
l_segs  chartabtype150;
l_loc_id  NUMBER;
BEGIN
   IF p_loc IS NULL THEN
      return NULL;
   END IF;
        l_segs := parse_text(p_loc,'.');
        select inventory_location_id
        into l_loc_id
        from mtl_item_locations
        where organization_id = p_org_id
          and subinventory_code = p_sub_code
          and segment1 =  l_segs(1)
          and segment2 =  l_segs(2)
          and segment3 =  l_segs(3);

        return l_loc_id;
END get_loc_id;

FUNCTION get_lpn_id (p_org_id  NUMBER, p_lpn  VARCHAR2)
RETURN NUMBER
IS
  l_lpn_id     NUMBER;
  l_return_status    VARCHAR(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(200);

BEGIN

  SELECT lpn_id
  INTO l_lpn_id
  FROM wms_license_plate_numbers
  WHERE license_plate_number = p_lpn
    AND organization_id = p_org_id;

  RETURN l_lpn_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  WMS_Container_PUB.Create_LPN (
  p_api_version      => 1.0
, x_return_status    => l_return_status
, x_msg_count        => l_msg_count
, x_msg_data         => l_msg_data
, p_lpn              => p_lpn
, p_organization_id  => p_org_id
, x_lpn_id     => l_lpn_id);

  RETURN l_lpn_id;
END;


PROCEDURE create_txns(p_data  IN OUT NOCOPY    dblarrchartabtype150
                   , p_org_id   IN	NUMBER
                   , p_user_id  IN	NUMBER
                   , p_runid  IN	NUMBER
                   , p_test_id    IN      NUMBER)
IS
l_txns_lst  arrchartabtype150;
l_trx_hdr_id    NUMBER;
l_item_id       NUMBER;
l_revision       VARCHAR2(10);
l_trx_action_id NUMBER;
l_subinv_code     VARCHAR2(10);
l_tosubinv_code   VARCHAR2(10);
l_locator_id    NUMBER;
l_tolocator_id  NUMBER;
l_trx_type_id   NUMBER;
l_trx_src_type_id NUMBER;
l_pri_qty       NUMBER;
l_uom           VARCHAR2(3);
trxid           NUMBER;
l_ret_msg       VARCHAR2(200);
retval          NUMBER;
l_txn_type      VARCHAR2(4);
l_lpn_id        NUMBER;

-- '<LABEL>, <TRX MR / MI>, <ITEM>, <REV>, <SUB>, <TO SUB>, <LOC>, <TO LOC> ,<LPN>, <QTY>, <UOM>'

BEGIN
  l_txns_lst := get_value_list(p_data, 'TXNS');

  FOR l_ix in 1..l_txns_lst.count LOOP
     l_txn_type := get_lst_val(l_txns_lst(l_ix),2);
     IF l_txn_type = 'MR' THEN
        l_trx_type_id := 42;
        l_trx_action_id := 27;
        l_trx_src_type_id := 13;
     ELSIF l_txn_type = 'MI' THEN
        l_trx_type_id := 32;
        l_trx_action_id := 1;
        l_trx_src_type_id := 13;
     END IF;
     SELECT MTL_MATERIAL_TRANSACTIONS_S.nextval
     INTO l_trx_hdr_id
     FROM DUAL;
     print_debug('Item : ' || get_lst_val(l_txns_lst(l_ix),3));
     l_item_id := get_item_id(p_org_id, get_lst_val(l_txns_lst(l_ix),3), p_test_id, p_runid);
     print_debug('Item ID : ' || l_item_id);
     l_revision := get_lst_val(l_txns_lst(l_ix),4);
     l_subinv_code := get_lst_val(l_txns_lst(l_ix),5);
     l_tosubinv_code := get_lst_val(l_txns_lst(l_ix),6);
     l_locator_id := get_loc_id(p_org_id,l_subinv_code,get_lst_val(l_txns_lst(l_ix),7));
     l_tolocator_id := get_loc_id(p_org_id,l_subinv_code,get_lst_val(l_txns_lst(l_ix),8));
     l_lpn_id := get_lpn_id(p_org_id, get_lst_val(l_txns_lst(l_ix),9));
     l_pri_qty := to_number(get_lst_val(l_txns_lst(l_ix),10));
     l_uom := get_lst_val(l_txns_lst(l_ix),11);


     print_debug('Writing mmtt line with header : ' || l_trx_hdr_id);
     retval := INV_TRX_UTIL_PUB.INSERT_LINE_TRX(
                                p_trx_hdr_id => l_trx_hdr_id,
                                p_item_id => l_item_id,
                                p_revision => l_revision,
                                p_org_id => p_org_id,
                                p_trx_action_id => l_trx_action_id,
                                p_subinv_code => l_subinv_code,
                                p_tosubinv_code => l_tosubinv_code,
                                p_locator_id => l_locator_id,
                                p_tolocator_id => l_tolocator_id,
                                p_xfr_org_id => NULL,
                                p_trx_type_id => l_trx_type_id,
                                p_trx_src_type_id => l_trx_src_type_id,
                                p_trx_qty => l_pri_qty,
                                p_pri_qty => l_pri_qty,
                                p_uom => l_uom,
                                p_date =>  sysdate,
                                p_reason_id => NULL,
                                p_user_id => p_user_id,
                                x_trx_tmp_id => trxid,
                                x_proc_msg => l_ret_msg);

     print_debug('Processing transaction : ' || l_trx_hdr_id);
     retval := INV_LPN_TRX_PUB.PROCESS_LPN_TRX(
                                    p_trx_hdr_id => l_trx_hdr_id,
                                    p_commit => fnd_api.g_false,
                                    x_proc_msg => l_ret_msg,
                                    p_proc_mode => 1,
                                    p_process_trx => fnd_api.g_true,
                                    p_atomic  => fnd_api.g_true,
				    p_business_flow_code => NULL,
				    p_init_msg_list => TRUE);
     print_debug('Done Processing transaction : ' || l_ret_msg);
  END LOOP;
END create_txns;


PROCEDURE create_onhand(p_data  IN OUT NOCOPY    dblarrchartabtype150
                   , p_org_id   IN	NUMBER
                   , p_user_id  IN	NUMBER
                   , p_runid  IN	NUMBER
                   , p_test_id    IN      NUMBER)
IS
-- <LABEL>,<ITEM>,<REV>,<LOT>,<SUB>,<LOC>,<LPN>,<PRI QTY>,<PRI UOM>,<SEC QTY>,<SEC UOM>

moqdrec mtl_onhand_quantities_detail%ROWTYPE;
lotrec mtl_lot_numbers%ROWTYPE;
serrec mtl_serial_numbers%ROWTYPE;

l_last_item     VARCHAR2(30);
l_item     VARCHAR2(30);
l_sub_code VARCHAR2(30);
l_last_loc      VARCHAR2(30);
l_loc      VARCHAR2(30);
l_rev      VARCHAR2(10);
l_item_id   NUMBER;
l_loc_id   NUMBER;

l_moqd_lst  arrchartabtype150;
l_ser_ctrl  NUMBER;
l_lot_ctrl NUMBER;
l_sr_count  NUMBER;
l_ser_num  VARCHAR2(30);
l_serial_number_lst arrchartabtype150;
l_oh_id  NUMBER;
l_sr_lines NUMBER;
sk NUMBER;

BEGIN

  l_moqd_lst := get_value_list(p_data, 'ONHAND');
  select *
  into moqdrec
  from mtl_onhand_quantities_detail
  where creation_date > sysdate - 800
    and organization_id = p_org_id
    and rownum = 1;

  select *
  into lotrec
  from mtl_lot_numbers
  where creation_date > sysdate - 800
    and rownum = 1;

  FOR i in 1..l_moqd_lst.count LOOP

     l_item := l_moqd_lst(i)(2);
     l_sub_code := l_moqd_lst(i)(5);
     l_loc := l_moqd_lst(i)(6);
     print_Debug('Txn Qty' || l_moqd_lst(i)(8));
     moqdrec.transaction_quantity := to_number(l_moqd_lst(i)(8));
     moqdrec.transaction_uom_code := l_moqd_lst(i)(9);

     if nvl(l_last_item,'@@@') <> l_item THEN
        SELECT inventory_item_id, SERIAL_NUMBER_CONTROL_CODE, lot_control_code
        INTO l_item_id, l_ser_ctrl, l_lot_ctrl
        FROM mtl_system_items
        WHERE organization_id = p_org_id
          AND segment1 = l_item;

        l_last_item := l_item;
     end if;
     if nvl(l_last_loc,'@@@') <> l_loc THEN
        l_loc_id := get_loc_id(p_org_id,l_sub_code, l_loc);
        l_last_loc := l_loc;
     end if;
     moqdrec.inventory_item_id := l_item_id;
     moqdrec.organization_id := p_org_id;
     moqdrec.planning_organization_id := p_org_id;
     moqdrec.owning_organization_id := p_org_id;
     moqdrec.subinventory_code := l_sub_code;
     moqdrec.locator_id := l_loc_id;
     moqdrec.lot_number := NULL;
     moqdrec.lpn_id := NULL;

     IF l_lot_ctrl = 2 THEN
        IF l_moqd_lst(i)(4) IS NOT NULL THEN
          moqdrec.lot_number := l_moqd_lst(i)(4);
        ELSE
           moqdrec.lot_number := 'UTLOT-' || p_runid || '-' || g_lotser_cnt;
           g_lotser_cnt := g_lotser_cnt + 1;
        END IF;
     END IF;

     SELECT MTL_ONHAND_QUANTITIES_S.nextval INTO l_oh_id FROM DUAL;

     print_debug('Writing to MOQD ID : ' || l_oh_id);

     insert into mtl_onhand_quantities_detail
       (INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        DATE_RECEIVED,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PRIMARY_TRANSACTION_QUANTITY,
        SUBINVENTORY_CODE,
        REVISION,
        LOCATOR_ID,
        CREATE_TRANSACTION_ID,
        UPDATE_TRANSACTION_ID,
        LOT_NUMBER,
        ORIG_DATE_RECEIVED,
        COST_GROUP_ID,
        CONTAINERIZED_FLAG,
                PROJECT_ID,
                TASK_ID,
                ONHAND_QUANTITIES_ID,
                ORGANIZATION_TYPE,
                OWNING_ORGANIZATION_ID,
                OWNING_TP_TYPE,
                PLANNING_ORGANIZATION_ID,
                PLANNING_TP_TYPE,
                TRANSACTION_UOM_CODE,
                TRANSACTION_QUANTITY,
                SECONDARY_UOM_CODE,
                SECONDARY_TRANSACTION_QUANTITY,
        IS_CONSIGNED)
                values
                (
                moqdrec.INVENTORY_ITEM_ID,
                moqdrec.ORGANIZATION_ID,
                sysdate,
                sysdate,
                moqdrec.LAST_UPDATED_BY,
                sysdate,
                moqdrec.CREATED_BY,
                moqdrec.LAST_UPDATE_LOGIN,
                moqdrec.TRANSACTION_QUANTITY, -- CHECK
                moqdrec.SUBINVENTORY_CODE,
                moqdrec.REVISION,
                moqdrec.LOCATOR_ID,
                moqdrec.CREATE_TRANSACTION_ID,
                moqdrec.UPDATE_TRANSACTION_ID,
                moqdrec.LOT_NUMBER,
                moqdrec.ORIG_DATE_RECEIVED,
                moqdrec.COST_GROUP_ID,
                moqdrec.CONTAINERIZED_FLAG,
                moqdrec.PROJECT_ID,
                moqdrec.TASK_ID,
                l_oh_id,
                moqdrec.ORGANIZATION_TYPE,
                moqdrec.OWNING_ORGANIZATION_ID,
                moqdrec.OWNING_TP_TYPE,
                moqdrec.PLANNING_ORGANIZATION_ID,
                moqdrec.PLANNING_TP_TYPE,
                moqdrec.TRANSACTION_UOM_CODE,
                moqdrec.TRANSACTION_QUANTITY,
        moqdrec.SECONDARY_UOM_CODE,
        moqdrec.SECONDARY_TRANSACTION_QUANTITY,
        moqdrec.IS_CONSIGNED);


     IF l_lot_ctrl = 2 THEN

     print_debug('Writing to LOT : ' ||  moqdrec.lot_number);

        lotrec.lot_number :=  moqdrec.lot_number;
        lotrec.inventory_item_id := l_item_id;
        lotrec.organization_id := p_org_id;
        insert into mtl_lot_numbers(
                INVENTORY_ITEM_ID,
                 ORGANIZATION_ID,
                 LOT_NUMBER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 EXPIRATION_DATE,
                 DISABLE_FLAG,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 GEN_OBJECT_ID,
                 DESCRIPTION,
                 VENDOR_NAME,
                 SUPPLIER_LOT_NUMBER,
                 GRADE_CODE,
                 ORIGINATION_DATE,
                 DATE_CODE,
                 STATUS_ID,
                 CHANGE_DATE,
                 AGE,
                 RETEST_DATE,
                 MATURITY_DATE,
                 LOT_ATTRIBUTE_CATEGORY,
                 ITEM_SIZE,
                 COLOR,
                 VOLUME,
                 VOLUME_UOM,
                 PLACE_OF_ORIGIN,
                 BEST_BY_DATE,
                 LENGTH,
                 LENGTH_UOM,
                 RECYCLED_CONTENT,
                 THICKNESS,
                 THICKNESS_UOM,
                 WIDTH,
                 WIDTH_UOM,
                 CURL_WRINKLE_FOLD,
                 VENDOR_ID,
                 TERRITORY_CODE)
( SELECT
 lotrec.INVENTORY_ITEM_ID,
 lotrec.ORGANIZATION_ID,
 lotrec.LOT_NUMBER,
 sysdate,
 lotrec.LAST_UPDATED_BY,
 sysdate,
 lotrec.CREATED_BY,
 lotrec.LAST_UPDATE_LOGIN,
 null,
 lotrec.DISABLE_FLAG,
 lotrec.ATTRIBUTE_CATEGORY,
 lotrec.ATTRIBUTE1,
 lotrec.ATTRIBUTE2,
 lotrec.ATTRIBUTE3,
 lotrec.ATTRIBUTE4,
 lotrec.ATTRIBUTE5,
 lotrec.ATTRIBUTE6,
 lotrec.ATTRIBUTE7,
 lotrec.ATTRIBUTE8,
 lotrec.ATTRIBUTE9,
 lotrec.ATTRIBUTE10,
 lotrec.ATTRIBUTE11,
 lotrec.ATTRIBUTE12,
 lotrec.ATTRIBUTE13,
 lotrec.ATTRIBUTE14,
 lotrec.ATTRIBUTE15,
 lotrec.REQUEST_ID,
 lotrec.PROGRAM_APPLICATION_ID,
 lotrec.PROGRAM_ID,
 lotrec.PROGRAM_UPDATE_DATE,
 MTL_GEN_OBJECT_ID_S.nextval,
 lotrec.DESCRIPTION,
 lotrec.VENDOR_NAME,
 lotrec.SUPPLIER_LOT_NUMBER,
 lotrec.GRADE_CODE,
 lotrec.ORIGINATION_DATE,
 lotrec.DATE_CODE,
 lotrec.STATUS_ID,
 lotrec.CHANGE_DATE,
 lotrec.AGE,
 lotrec.RETEST_DATE,
 lotrec.MATURITY_DATE,
 lotrec.LOT_ATTRIBUTE_CATEGORY,
 lotrec.ITEM_SIZE,
 lotrec.COLOR,
 lotrec.VOLUME,
 lotrec.VOLUME_UOM,
 lotrec.PLACE_OF_ORIGIN,
 lotrec.BEST_BY_DATE,
 lotrec.LENGTH,
 lotrec.LENGTH_UOM,
 lotrec.RECYCLED_CONTENT,
 lotrec.THICKNESS,
 lotrec.THICKNESS_UOM,
 lotrec.WIDTH,
 lotrec.WIDTH_UOM,
 lotrec.CURL_WRINKLE_FOLD,
 lotrec.VENDOR_ID,
 lotrec.TERRITORY_CODE FROM DUAL);


     print_debug('Done writing LOT : ' ||  moqdrec.lot_number);
     end if;

     IF l_ser_ctrl = 5 THEN
        l_sr_count := 0;
        sk := 2;
        l_sr_lines := 1;
        l_serial_number_lst := get_value_label_list(p_data,'SERIAL',l_moqd_lst(i)(1));
        LOOP
          print_debug('Serial cnt ' || l_sr_count || '  - Txn Qty ' || moqdrec.transaction_quantity);
          EXIT WHEN l_sr_count = moqdrec.transaction_quantity;
           l_sr_count := l_sr_count + 1;
           IF l_serial_number_lst.count > 0 THEN
              if l_serial_number_lst(l_sr_lines).count > sk THEN
                 sk := sk + 1;
              else
                 l_sr_lines := l_sr_lines + 1;
                 sk := 3;
              end if;
            print_debug('Sr Lines ' || l_sr_lines || '  Sr count ' || l_serial_number_lst.count);
            EXIT WHEN l_sr_lines > l_serial_number_lst.count;
              l_ser_num := l_serial_number_lst(l_sr_lines)(sk);
           ELSE
              l_ser_num := 'UTSER-' || p_runid || '-' || g_lotser_cnt;
              g_lotser_cnt := g_lotser_cnt + 1;
           END IF;
           serrec.serial_number := l_ser_num;
           serrec.inventory_item_id := moqdrec.inventory_item_id;
           serrec.current_organization_id := moqdrec.organization_id;
           serrec.current_subinventory_code := moqdrec.subinventory_code;
           serrec.current_locator_id := moqdrec.locator_id;
           serrec.current_status := 3;
           serrec.revision := moqdrec.revision;
           serrec.cost_group_id := moqdrec.cost_group_id;
           serrec.lpn_id := moqdrec.lpn_id;
           serrec.onhand_quantities_id := l_oh_id;
           serrec.lot_number := moqdrec.lot_number;

           print_debug('Inserting Serial : ' || serrec.serial_number || ' - item : ' || serrec.inventory_item_id);


           INSERT INTO mtl_serial_numbers
              ( INVENTORY_ITEM_ID
                ,SERIAL_NUMBER
                , LAST_UPDATE_DATE
                , LAST_UPDATED_BY
                , CREATION_DATE
                , CREATED_BY
                , LAST_UPDATE_LOGIN
                , REQUEST_ID
                , PROGRAM_APPLICATION_ID
                , PROGRAM_ID
                , PROGRAM_UPDATE_DATE
                , INITIALIZATION_DATE
                , COMPLETION_DATE
                , SHIP_DATE
                , CURRENT_STATUS
                , REVISION
                , LOT_NUMBER
                , FIXED_ASSET_TAG
                , RESERVED_ORDER_ID
                , PARENT_ITEM_ID
                , PARENT_SERIAL_NUMBER
                , ORIGINAL_WIP_ENTITY_ID
                , ORIGINAL_UNIT_VENDOR_ID
                , VENDOR_SERIAL_NUMBER
                , VENDOR_LOT_NUMBER
                , LAST_TXN_SOURCE_TYPE_ID
                , LAST_TRANSACTION_ID
                , LAST_RECEIPT_ISSUE_TYPE
                , LAST_TXN_SOURCE_NAME
                , LAST_TXN_SOURCE_ID
                , DESCRIPTIVE_TEXT
                , CURRENT_SUBINVENTORY_CODE
                , CURRENT_LOCATOR_ID
                , CURRENT_ORGANIZATION_ID
                , GEN_OBJECT_ID
                , LPN_ID
                , COST_GROUP_ID
                , ONHAND_QUANTITIES_ID)
VALUES
(
 serrec.INVENTORY_ITEM_ID
,serrec.SERIAL_NUMBER
, sysdate
, p_user_id
, sysdate
, p_user_id
, p_user_id
, serrec.REQUEST_ID
, serrec.PROGRAM_APPLICATION_ID
, serrec.PROGRAM_ID
, serrec.PROGRAM_UPDATE_DATE
, SYSDATE
, SYSDATE
, NULL
, 3
, serrec.REVISION
, serrec.LOT_NUMBER
, serrec.FIXED_ASSET_TAG
, NULL
, NULL
, NULL
, NULL
, NULL
, serrec.VENDOR_SERIAL_NUMBER
, serrec.VENDOR_LOT_NUMBER
, NULL
, NULL
, NULL
, NULL
, NULL
, 'UT Serial Number'
, serrec.CURRENT_SUBINVENTORY_CODE
, serrec.CURRENT_LOCATOR_ID
, serrec.CURRENT_ORGANIZATION_ID
, MTL_GEN_OBJECT_ID_S.nextval
, serrec.LPN_ID
, serrec.cost_group_id
, serrec.ONHAND_QUANTITIES_ID);

  END LOOP;
     IF l_sr_count < moqdrec.transaction_quantity THEN
        write_ut_error(p_test_id, 'INSUFFICIENT SERIAL NUMBERS PROVIDED FOR ONHAND : ' || l_moqd_lst(i)(1), p_runid);
     END IF;
  END IF;
  END LOOP;

END create_onhand;


PROCEDURE create_rsvs(p_data  IN OUT NOCOPY    dblarrchartabtype150
                   , p_org_id   IN	NUMBER
                   , p_user_id  IN	NUMBER
                   , p_runid    IN      NUMBER
                   , p_test_id    IN      NUMBER) IS

-- RSVS : <LABEL>, <ITEM>, <REV>, <LOT>, <SUB>, <LOC>, <LPN>, <PRI QTY>, <PRI UOM>, <SEC QTY>, <SEC UOM>
-- SERIAL : <LABEL>, <SERIAL>
l_rsvs_lst   arrchartabtype150;
l_rsvs_ser_lst  arrchartabtype150;
l_rsvs_label  VARCHAR2(150);
l_reserved_serials       inv_reservation_global.serial_number_tbl_type;
l_rsvs_serials           inv_reservation_global.serial_number_tbl_type;
l_new_reservation        inv_reservation_global.mtl_reservation_rec_type;

l_dem_label_index   NUMBER;

l_return_status    VARCHAR(10);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(200);
l_rt         VARCHAR2(200);
l_rsv_label         VARCHAR2(150);
l_qty_succ_reserved   NUMBER;
l_new_reservation_id   NUMBER;
l_inventory_item_id   NUMBER;

l_demand_source_type_id   NUMBER;
l_demand_source_header_id   NUMBER;
l_demand_source_line_id   NUMBER;
l_demand_source_name   VARCHAR2(80);


BEGIN

  l_rsvs_lst := get_value_list(p_data, 'RSVS');

  print_debug('Creating Input Reservations # =' || l_rsvs_lst.count);

  For i in 1..l_rsvs_lst.count LOOP
     l_rsv_label := l_rsvs_lst(i)(1);
     l_dem_label_index := get_demand_label_index(l_rsv_label);
     print_debug('Demand Label : ' || l_rsv_label || '   ID:'||l_dem_label_index || ' i = ' || i);
     IF l_dem_label_index = 0 THEN
        l_demand_source_type_id := inv_reservation_global.g_source_type_inv;
        l_demand_source_header_id := NULL;
        l_demand_source_line_id := NULL;
        l_demand_source_name := g_testname || '_' || p_runid;
     ELSE
        l_demand_source_type_id := g_demand_tbl(l_dem_label_index).demand_source_type_id;
        l_demand_source_header_id := g_demand_tbl(l_dem_label_index).demand_source_header_id;
        l_demand_source_line_id := g_demand_tbl(l_dem_label_index).demand_source_line_id;
        l_demand_source_name := g_demand_tbl(l_dem_label_index).demand_source_name;
     END IF;

     print_debug('Rsv Dem Type :' || l_demand_source_type_id);
     SELECT inventory_item_id
     INTO l_inventory_item_id
     FROM mtl_system_items
     WHERE organization_id = p_org_id
       AND segment1 = l_rsvs_lst(i)(2);
     print_debug('Rsv Dem header :' || l_demand_source_header_id);

     l_new_reservation.organization_id :=  p_org_id;
     l_new_reservation.inventory_item_id :=  l_inventory_item_id;
     l_new_reservation.reservation_id := NULL;
     l_new_reservation.revision :=  l_rsvs_lst(i)(3);
     l_new_reservation.lot_number := l_rsvs_lst(i)(4);
     l_new_reservation.subinventory_code := l_rsvs_lst(i)(5);
     l_new_reservation.locator_id := get_loc_id(p_org_id,l_rsvs_lst(i)(5),l_rsvs_lst(i)(6));
     l_new_reservation.lpn_id := l_rsvs_lst(i)(7);
     l_new_reservation.primary_uom_code              := l_rsvs_lst(i)(9);
     --l_new_reservation.secondary_uom_code            := l_rsvs_lst(i)(11);
     l_new_reservation.primary_reservation_quantity  := to_number(l_rsvs_lst(i)(8));
     l_new_reservation.secondary_reservation_quantity  := to_number(l_rsvs_lst(i)(10));
     l_new_reservation.demand_source_type_id   := l_demand_source_type_id;
     l_new_reservation.demand_source_header_id := l_demand_source_header_id;
     l_new_reservation.demand_source_line_id   := l_demand_source_line_id;
     l_new_reservation.demand_source_name   := l_demand_source_name;
     l_new_reservation.reservation_id             := NULL; -- cannot know
     l_new_reservation.requirement_date           := SYSDATE;
     l_new_reservation.demand_source_delivery        := NULL;
     l_new_reservation.primary_uom_id                := NULL;
     l_new_reservation.secondary_uom_id              := NULL;
     l_new_reservation.reservation_uom_code          := NULL;
     l_new_reservation.reservation_uom_id            := NULL;
     l_new_reservation.reservation_quantity          := NULL;
     l_new_reservation.autodetail_group_id           := NULL;
     l_new_reservation.external_source_code          := NULL;
     l_new_reservation.external_source_line_id       := NULL;
     l_new_reservation.supply_source_type_id         := inv_reservation_global.g_source_type_inv;
     l_new_reservation.supply_source_header_id       := NULL;
     l_new_reservation.supply_source_line_id         := NULL;
     l_new_reservation.supply_source_name            := NULL;
     l_new_reservation.supply_source_line_detail     := NULL;
     l_new_reservation.subinventory_id               := NULL;
     l_new_reservation.lot_number_id                 := NULL;
     l_new_reservation.pick_slip_number              := NULL;
     l_new_reservation.lpn_id                        := NULL;
     l_new_reservation.attribute_category            := NULL;
     l_new_reservation.attribute1                    := NULL;
     l_new_reservation.attribute2                    := NULL;
     l_new_reservation.attribute3                    := NULL;
     l_new_reservation.attribute4                    := NULL;
     l_new_reservation.attribute5                    := NULL;
     l_new_reservation.attribute6                    := NULL;
     l_new_reservation.attribute7                    := NULL;
     l_new_reservation.attribute8                    := NULL;
     l_new_reservation.attribute9                    := NULL;
     l_new_reservation.attribute10                   := NULL;
     l_new_reservation.attribute11                   := NULL;
     l_new_reservation.attribute12                   := NULL;
     l_new_reservation.attribute13                   := NULL;
     l_new_reservation.attribute14                   := NULL;
     l_new_reservation.attribute15                   := NULL;
     l_new_reservation.serial_number                   := NULL;
     l_new_reservation.ship_ready_flag               := 2;
     l_new_reservation.detailed_quantity             := 0;

     l_rsvs_ser_lst := get_value_label_list(p_data, 'SERIAL', l_rsv_label);
     For j in 1..l_rsvs_ser_lst.count LOOP
        FOR k in 3..l_rsvs_ser_lst(j).count LOOP
           l_rsvs_serials(k-2).serial_number := l_rsvs_ser_lst(j)(k);
           l_rsvs_serials(k-2).inventory_item_id := l_inventory_item_id;
           print_debug('Adding serial number ' || l_rsvs_ser_lst(j)(k) || ' to reservation');
        END LOOP;
     END LOOP;

     print_debug('Rsv Dem line :' || l_demand_source_line_id);
     inv_reservation_pub.create_reservation(
         p_api_version_number         => 1.0
       , p_init_msg_lst               => fnd_api.g_false
       , x_return_status              => l_return_status
       , x_msg_count                  => l_msg_count
       , x_msg_data                   => l_msg_data
       , p_rsv_rec                    => l_new_reservation
       , p_serial_number              => l_rsvs_serials
       , x_serial_number              => l_reserved_serials
       , p_partial_reservation_flag   => fnd_api.g_true
       , p_force_reservation_flag     => fnd_api.g_false
       , p_validation_flag            => 'Q'
       , x_quantity_reserved          => l_qty_succ_reserved
       , x_reservation_id             => l_new_reservation_id
      );

  IF l_new_reservation_id IS NOT NULL THEN
  SELECT ROWNUM || ' : ' ||
         mr.reservation_id || ', ' ||
         mp.organization_code || ', ' ||
         msi.segment1 || ', ' ||
         mr.revision || ', ' ||
         mr.lot_number || ', ' ||
         mr.subinventory_code || ', ' ||
         mil.segment1 || '.' || mil.segment2 || '.' || mil.segment3 || ', ' ||
         wlpn.LICENSE_PLATE_NUMBER || ', ' ||
         mr.primary_reservation_quantity || ', ' ||
         mr.primary_uom_code || ', ' ||
         Nvl(mr.detailed_quantity,0) || ', ' ||
         mr.secondary_reservation_quantity || ', ' ||
         mr.secondary_uom_code || ', ' ||
         Nvl(mr.secondary_detailed_quantity,0) as p_text
     INTO l_rt
     FROM mtl_reservations mr, mtl_parameters mp, mtl_system_items msi, wms_license_plate_numbers wlpn, mtl_item_locations mil
     WHERE reservation_id = l_new_reservation_id
       AND msi.organization_id = mr.organization_id
       AND msi.inventory_item_id = mr.inventory_item_id
       AND mp.organization_id = mr.organization_id
       AND wlpn.lpn_id (+) = mr.lpn_id
       AND mil.inventory_location_id (+) = mr.locator_id;

     write_to_output(p_test_id, 'RSVS_IN', l_rt, p_runid);
     l_new_reservation.reservation_id := l_new_reservation_id;
     g_reservations(g_reservations.count + 1) := l_new_reservation;

  ELSE
        write_ut_error(p_test_id, 'Create reservation failed : ' || l_msg_data, p_runid);
  END IF;

    print_debug('After creating the reservations: Reservation ID =' || l_new_reservation_id);
    print_debug(l_rt);

  END LOOP;

 EXCEPTION WHEN NO_DATA_FOUND THEN
               write_ut_error(p_test_id, 'Reservations : ', p_runid ) ;
               RAISE;

           WHEN OTHERS THEN
        write_ut_error(p_test_id, 'Failed when trying to create reservation : ' || SQLERRM, p_runid);
        RAISE;

END create_rsvs;


PROCEDURE create_so (p_data  IN OUT NOCOPY     dblarrchartabtype150,
                            p_org_id   IN	NUMBER,
                            p_user_id  IN       NUMBER,
                            p_run_id   IN       NUMBER,
                            p_test_id   IN       NUMBER) IS
  l_so_orders     arrchartabtype150;
  l_demand_source_type_id    NUMBER;
  l_demand_source_header_id  NUMBER;
  l_demand_source_line_id    NUMBER;
  l_demand_source_name       VARCHAR2(30);
  l_demand_source_delivery   NUMBER;
  l_source_doc_type   NUMBER;
  l_transaction_type_id   NUMBER;
  l_dem_indx       NUMBER;
  l_o_header_id    NUMBER;
  l_o_type_id      NUMBER;
  i                NUMBER;
BEGIN

  -- Temporary Code to get an existing sales order
  l_so_orders  := get_value_list(p_data, 'SORDER_L');

  FOR i in 1..l_so_orders.count LOOP
     l_dem_indx := g_demand_tbl.count + 1;

  print_debug('Order ' || l_so_orders(i)(2));
  print_debug('Line ' || l_so_orders(i)(3));
     SELECT mso.sales_order_id, ol.line_id, nvl(oh.source_document_type_id,11), oh.header_id, oh.order_type_id
     into l_demand_source_header_id, l_demand_source_line_id, l_source_doc_type, l_o_header_id, l_o_type_id
     FROM oe_order_headers_all oh, oe_order_lines_all ol, mtl_sales_orders mso
     WHERE ol.header_id = oh.header_id
       AND oh.order_number = to_number(l_so_orders(i)(2))
       AND ol.line_number = to_number(l_so_orders(i)(3))
       AND mso.segment1 = to_char(oh.order_number)
       AND ROWNUM < 2;

     IF l_source_doc_type = 10 THEN
        l_transaction_type_id := INV_GLOBALS.G_TYPE_INTERNAL_ORDER_STGXFR;
     ELSE
        l_transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;
     END IF;
     SELECT transaction_source_type_id
     INTO l_demand_source_type_id
     FROM mtl_transaction_types
     WHERE transaction_type_id = l_transaction_type_id;

     print_debug('Type :' || l_demand_source_type_id);
     print_debug('Type :' || l_demand_source_header_id);
     print_debug('Type :' || l_demand_source_line_id);
     g_demand_tbl(l_dem_indx).label := l_so_orders(i)(1);
     g_demand_tbl(l_dem_indx).demand_source_type_id := l_demand_source_type_id;
     g_demand_tbl(l_dem_indx).demand_source_header_id := l_demand_source_header_id;
     g_demand_tbl(l_dem_indx).demand_source_line_id := l_demand_source_line_id;
     g_demand_tbl(l_dem_indx).demand_source_name := l_demand_source_name;
     g_demand_tbl(l_dem_indx).demand_source_delivery := l_demand_source_delivery;
     g_params('ORDER_TYPE_ID') := l_o_type_id;
     g_params('ORDER_HEADER_ID') := l_o_header_id;
 END LOOP;

 EXCEPTION WHEN NO_DATA_FOUND THEN
               write_ut_error(p_test_id, 'Sales Order : ' || l_so_orders(i)(2) || ' ln : ' || l_so_orders(i)(3) || ' does Not Exist!', p_run_id);

           WHEN OTHERS THEN
        write_ut_error(p_test_id, 'Failed when trying to create sales order ', p_run_id);
        RAISE;

END create_so;


PROCEDURE create_mo (p_data  IN OUT NOCOPY     dblarrchartabtype150,
                            p_org_id   IN	NUMBER,
                            p_user_id  IN       NUMBER,
                            p_run_id   IN       NUMBER,
			    p_test_id  IN	NUMBER) IS

 l_item  VARCHAR2(30);
 l_request_quantity   NUMBER;
 l_quantity_to_reserve  NUMBER;
 l_primary_uom VARCHAR2(3);
  l_rsv_lines    arrchartabtype150;
  l_mo_orders     arrchartabtype150;

  l_trolin_tbl             INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
  l_trolin_val_tbl         INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;
  l_trohdr_rec             INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
  l_trohdr_val_rec         INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;

  l_date        DATE   := SYSDATE;

  l_mo_header_id    NUMBER;
  l_mo_line_id      NUMBER;

  l_return_status    VARCHAR(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(200);
  l_commit  VARCHAR2(1) := FND_API.G_FALSE;

  l_update_rsv_rec      inv_reservation_global.mtl_reservation_rec_type;
  l_reservations      inv_reservation_global.mtl_reservation_tbl_type;
  l_dummy_sn            inv_reservation_global.serial_number_tbl_type;
  l_qty_succ_reserved   NUMBER;
  l_reservation_id      NUMBER;
  l_ix                  NUMBER;
  l_inventory_item_id   NUMBER;
  l_num_rsv             NUMBER := 0;
  i   NUMBER;
  l_message    VARCHAR2(2000);

  l_request_number varchar(30);

  l_dem_indx NUMBER;

 --'<LABEL>,<TYPE>,<ITEM>,<PRI QTY>,<PRI UOM>,<SEC QTY>,<SEC UOM>,<FROM SUB>,<FROM LOC>,<TO SUB>,<TO LOC>,<DEMAND NAME>'
begin

   l_request_number := get_value(p_data, 'REQNUM');

   l_request_number := l_request_number || to_char(p_run_id);

   print_debug('Request Number : ' || l_request_number);
   l_mo_orders  := get_value_list(p_data, 'MORDER');

   l_ix := 0;

   LOOP
    EXIT WHEN l_ix = l_mo_orders.count;

     print_debug('Starting the Move Order processing - ' || l_ix || ' of ' || l_mo_orders.count);
     l_ix := l_ix + 1;
     l_item := l_mo_orders(l_ix)(3);
   SELECT inventory_item_id
   INTO l_inventory_item_id
   FROM mtl_system_items
   WHERE segment1 = l_item
     AND organization_id = p_org_id;

   print_debug('Item : ' || l_inventory_item_id);

    IF l_ix = 1 THEN
/* Start Creating Move order Header */

          l_trohdr_rec.created_by       := p_user_id;
          l_trohdr_rec.creation_date    := l_date;
          l_trohdr_rec.last_updated_by  := p_user_id;
          l_trohdr_rec.last_update_date := l_date;
          l_trohdr_rec.last_update_login := p_user_id;
          l_trohdr_rec.organization_id  := p_org_id;
          --l_trohdr_rec.grouping_rule_id := NULL; --l_org_infopick_grouping_rule_id;
          l_trohdr_rec.move_order_type  := INV_GLOBALS.G_MOVE_ORDER_REQUISITION;
          --l_trohdr_rec.transaction_type_id := NULL;
          l_trohdr_rec.operation        := INV_GLOBALS.G_OPR_CREATE;
          l_trohdr_rec.header_status    :=  INV_Globals.G_TO_STATUS_PREAPPROVED;
          l_trohdr_rec.request_number   := l_request_number;


          Inv_Move_Order_Pub.Create_Move_Order_Header
              (
                p_api_version_number => 1.0,
                p_init_msg_list      => FND_API.G_FALSE,
                p_return_values      => FND_API.G_TRUE,
                p_commit             => l_commit,
                p_trohdr_rec         => l_trohdr_rec,
                p_trohdr_val_rec     => l_trohdr_val_rec,
                x_trohdr_rec         => l_trohdr_rec,
                x_trohdr_val_rec     => l_trohdr_val_rec,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data
              );
              FOR i in 1..l_msg_count LOOP
                  l_message := fnd_msg_pub.get(i,'F');
   print_debug('Move order header err : ' || l_message);
              END LOOP;
   l_mo_header_id  := l_trohdr_rec.header_id;
   IF nvl(l_mo_header_id,-1) < 1 OR nvl(l_mo_header_id,1000000000001) > 100000000000 THEN
      write_ut_error(p_test_id, 'Error creating move order Header ', p_run_id);
   END IF;

   print_debug('Move order header : ' || l_mo_header_id || l_msg_data);
/* End Creating Move order Header */

    END IF;

/* Start Creating Move order Line */

   l_request_quantity := to_number(l_mo_orders(l_ix)(4));
   l_trolin_tbl(l_ix).line_number := l_ix;
   l_trolin_tbl(l_ix).created_by         := p_user_id;
   l_trolin_tbl(l_ix).creation_date      := l_date;
   l_trolin_tbl(l_ix).last_updated_by    := p_user_id;
   l_trolin_tbl(l_ix).last_update_date   := l_date;
   l_trolin_tbl(l_ix).last_update_login  := p_user_id;
   l_trolin_tbl(l_ix).header_id          := l_mo_header_id;
   l_trolin_tbl(l_ix).date_required      := l_date;
-- source
   l_trolin_tbl(l_ix).txn_source_line_detail_id := NULL;
   l_trolin_tbl(l_ix).txn_source_line_id := NULL;
   l_trolin_tbl(l_ix).txn_source_id := l_mo_header_id;
   l_trolin_tbl(l_ix).transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_MOVEORDER;
-- source
   l_trolin_tbl(l_ix).organization_id    := p_org_id;
   l_trolin_tbl(l_ix).from_subinventory_code := NULL; --p_from_subinventory;
   l_trolin_tbl(l_ix).from_locator_id        := NULL; --p_from_locator;
   l_trolin_tbl(l_ix).to_subinventory_code := NULL;
   l_trolin_tbl(l_ix).to_locator_id        := NULL;
   l_trolin_tbl(l_ix).project_id         := NULL;
   l_trolin_tbl(l_ix).task_id            := NULL;
   l_trolin_tbl(l_ix).inventory_item_id  := l_inventory_item_id;
   l_trolin_tbl(l_ix).quantity           := l_request_quantity;
   print_debug('Req Qty : ' || l_request_quantity );
   l_trolin_tbl(l_ix).primary_quantity   := l_request_quantity;
   l_trolin_tbl(l_ix).required_quantity   := l_request_quantity;
   l_trolin_tbl(l_ix).uom_code           := l_mo_orders(l_ix)(5);
   l_trolin_tbl(l_ix).grade_code         := NULL;
   l_trolin_tbl(l_ix).line_status        := INV_Globals.G_TO_STATUS_PREAPPROVED;
   l_trolin_tbl(l_ix).unit_number        := NULL;

   l_trolin_tbl(l_ix).transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;

    IF l_ix = l_mo_orders.count THEN
	print_debug('Calling create move order lines  - ' ||  l_trolin_tbl.count);
        Inv_Move_Order_Pub.Create_Move_Order_Lines
                    (
                       p_api_version_number  => 1.0,
                       p_init_msg_list       => FND_API.G_FALSE,
                       p_return_values       => FND_API.G_TRUE,
                       p_commit              => l_commit,
                       x_return_status       => l_return_status,
                       x_msg_count           => l_msg_count,
                       x_msg_data            => l_msg_data,
                       p_trolin_tbl          => l_trolin_tbl,
                       p_trolin_val_tbl      => l_trolin_val_tbl,
                       x_trolin_tbl          => l_trolin_tbl,
                       x_trolin_val_tbl      => l_trolin_val_tbl,
                       p_validation_flag     => 'N' -- Inventory will skip most validations
                      );
	print_debug('After calling create move order lines - ' || l_trolin_tbl.count);
        /*      FOR i in 1..nvl(l_msg_count,0) LOOP
	print_debug('After calling create move order lines - ' || l_trolin_tbl.count);
                  l_message := fnd_msg_pub.get(i,'F');
                  print_debug('Move order Line err : ' || l_message);
              END LOOP;*/
	print_debug('After calling create move order lines - ' || l_trolin_tbl.count);
     END IF;

/* End Creating Move order Line */

	print_debug('After calling create move order lines - ' || l_trolin_tbl.count);
  END LOOP;
   print_debug('Done with all move orders');
  FOR l_ix in 1..l_trolin_tbl.count LOOP
   print_debug('Recording the demand information');
   l_dem_indx := g_demand_tbl.count + 1;

   g_demand_tbl(l_dem_indx).label := l_mo_orders(l_ix)(1);
   g_demand_tbl(l_dem_indx).demand_source_type_id := 13;
   g_demand_tbl(l_dem_indx).demand_source_header_id := l_trolin_tbl(l_ix).header_id;
   g_demand_tbl(l_dem_indx).demand_source_line_id := l_trolin_tbl(l_ix).line_id;
   g_demand_tbl(l_dem_indx).demand_source_name := NULL;
   g_demand_tbl(l_dem_indx).demand_source_delivery := NULL;
   UPDATE mtl_txn_request_lines
   SET txn_source_line_id = l_trolin_tbl(l_ix).line_id
   WHERE line_id = l_trolin_tbl(l_ix).line_id;

   IF l_mo_orders(l_ix)(1) IS NOT NULL THEN
      g_demand_tbl(l_dem_indx).demand_source_type_id :=  inv_reservation_global.g_source_type_inv;
      g_demand_tbl(l_dem_indx).demand_source_name := l_mo_orders(l_ix)(1);
   END IF;
   g_demand_tbl(l_dem_indx).mo_line_id := l_trolin_tbl(l_ix).line_id;

   print_debug('Move order line : ' || l_trolin_tbl(l_ix).line_id);

   g_link_mo_dem(l_trolin_tbl(l_ix).line_id) := l_dem_indx;
  END LOOP;

  g_trolin_tbl := l_trolin_tbl;
 EXCEPTION WHEN NO_DATA_FOUND THEN
        write_ut_error(p_test_id, 'Error while creating move order Item Does not exist : ' || l_item, p_run_id);
        RAISE;

           WHEN OTHERS THEN
        write_ut_error(p_test_id, 'Error while creating move order :  ' || SQLERRM, p_run_id);
        RAISE;
END create_mo;


PROCEDURE create_sorder(p_data  IN OUT NOCOPY    dblarrchartabtype150
                   , p_org_id   IN      NUMBER
                   , p_user_id  IN      NUMBER
                   , p_run_id  IN        NUMBER
                   , p_test_id    IN      NUMBER) IS

	loop_counter1 NUMBER;
	loop_counter2 NUMBER;
	l_item_counter NUMBER := 0;
	ij NUMBER := 0;
	l_request_id NUMBER;
	cust_id NUMBER;
	number_of_orders  NUMBER;
	lines_per_order   NUMBER;
	c_item_no   	  VARCHAR2(30);
	c_quantity        NUMBER;
	l_orig_sys_document_ref VARCHAR2(50);
	invoice_to_id	NUMBER;
	ship_to_id	NUMBER;
	sold_to_contact_id	NUMBER;
	ship_to_contact_id	NUMBER;
	invoice_to_contact_id	NUMBER;
        l_order_source_id       NUMBER;
        item_arr  numtabtype;
	quantity_arr numtabtype;
	c_item_id	NUMBER;
	numofdistinctlines NUMBER;

        l_order_type_id    NUMBER;
        l_so_orders     arrchartabtype150;
        l_so_items     arrchartabtype150;
        l_start_req_date   VARCHAR2(20);
        l_end_req_date     VARCHAR2(20);

-- used to store demand information for test case processing
  l_demand_source_type_id    NUMBER;
  l_demand_source_header_id  NUMBER;
  l_demand_source_line_id    NUMBER;
  l_demand_source_name       VARCHAR2(30);
  l_demand_source_delivery   NUMBER;
  l_source_doc_type   NUMBER;
  l_transaction_type_id   NUMBER;
  l_dem_indx       NUMBER;
  l_o_header_id    NUMBER;


-- needed to run order import
  l_header_id  NUMBER;
  l_order_number NUMBER;
  l_init_msg_list   VARCHAR2(1):='T';
  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);
  l_return_status  VARCHAR2(80);

  l_dummy  VARCHAR2(10);

  l_orig_sys  oe_headers_interface%ROWTYPE;


  type los_tt is TABLE of oe_headers_interface%ROWTYPE index by BINARY_INTEGER;

  l_orig_sys_tbl   los_tt;

  CURSOR l_orig_sys_reference_cursor IS
    SELECT * --order_source_id
           --,ORIG_SYS_DOCUMENT_REF
    FROM oe_headers_interface
    WHERE request_id=l_request_id;

  CURSOR c_solines (p_header_id  NUMBER) IS
     SELECT mso.sales_order_id as header_id, ol.line_id, nvl(oh.source_document_type_id,11) as source_doc_type_id
     FROM oe_order_headers_all oh, oe_order_lines_all ol, mtl_sales_orders mso
     WHERE ol.header_id = oh.header_id
       AND oh.header_id = p_header_id
       AND mso.segment1 = to_char(oh.order_number);

-- '<LABEL>, <TYPE>, <ITEM>, <QUANTITY>, ..., <NUM OF ORDERS>, <LINES PER ORDER>';
BEGIN

  l_so_orders  := get_value_list(p_data, 'SORDER');

  SELECT to_char(sysdate, 'MM/DD/RR hh:mi:ss')
  INTO l_start_req_date FROM dual;

  ij := 0;

  FOR i in 1..l_so_orders.count LOOP
    IF i = 1 THEN
      BEGIN
         select order_type_id
         into l_order_type_id
         from OE_ORDER_TYPES_V
         where upper(name) = 'ORDER ONLY';
      EXCEPTION WHEN NO_DATA_FOUND THEN
         l_order_type_id := 2539;
      END;
     END IF;

     number_of_orders := to_number(nvl(l_so_orders(i)(l_so_orders(i).count - 1), 1));
     lines_per_order := to_number(nvl(l_so_orders(i)(l_so_orders(i).count), 1));
     IF l_so_orders(i)(3) is NULL THEN
	l_so_items := get_value_label_list(p_data, 'SO_ITEM',l_so_orders(i)(1));
        numofdistinctlines := 1;
     ELSE
        item_arr(1) := get_item_id(p_org_id, l_so_orders(i)(3), p_test_id, p_run_id);
        quantity_arr(1) := l_so_orders(i)(4);
        numofdistinctlines := 1;
     END IF;

/*     select oe_perf_orig_sys_doc_ref_s.nextval
     into l_request_id from dual;

     select oe_perf_orig_sys_doc_ref_s.nextval
     into l_order_source_id from dual;*/

     l_request_id := p_run_id;
     l_order_source_id := 0;

     FOR loop_counter1 IN 1..number_of_orders LOOP

        cust_id := 1005;
       -- Change customers on alternate order headers
       -- 1006: 	Computer Services and Rentals
       -- 1005:	ATandT Universal Card
        if cust_id = 1006 then
   	   cust_id := 1005;
	   invoice_to_id := 1023; --1023
	   ship_to_id := 1024; --1024
	   sold_to_contact_id := 1008;
	   ship_to_contact_id := 1008;
	   invoice_to_contact_id := 1008;
        elsif cust_id = 1005 then
	   cust_id := 1006;
	   invoice_to_id := 1025;
	   ship_to_id := 1026;
	   sold_to_contact_id := 1013;
	   ship_to_contact_id := 1013;
	   invoice_to_contact_id := 1013;
        end if;

      /* Needed a distinct doc ref id for each order */
        select MTL_MATERIAL_TRANSACTIONS_S.nextval
        into l_orig_sys_document_ref from dual;


      print_debug('Orig sys ref :'||l_orig_sys_document_ref);
      INSERT INTO OE_HEADERS_IFACE_ALL (
         creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , orig_sys_document_ref
        , order_type_id
        , sold_to_org_id
        , sold_to_contact_id
        , order_source_id
        , ordered_date
        , transactional_curr_code
        , invoice_customer_number
        , invoice_to_org_id
        , ship_to_org_id
        , ship_to_customer_number
        , price_list_id
        , request_date
        , invoice_to_contact_id
        , ship_to_contact_id
        , shipment_priority_code
        , shipping_method_code
        , freight_terms_code
        , fob_point_code
        , accounting_rule_id
        , invoicing_rule_id
        , operation_code
        , request_id
        , salesrep_id			-- SALESREP_ID
        , payment_term_id		-- PAYMENT_TERM_ID
        , tax_exempt_flag		-- Tax_Exempt_Flag
        , attribute10
        , attribute1
        , attribute2
        , batch_id
        , header_id
        )
        VALUES(
         SYSDATE	-- creation_date
         , p_user_id  	-- created_by constant
        , SYSDATE	-- last_update_date
        , p_user_id	-- last_updated_by constant
        , l_orig_sys_document_ref	-- orig_sys_document_ref
        , l_order_type_id --'Order Only'2539 	-- order_type
        , cust_id	-- sold_to_org_id
        , sold_to_contact_id	-- sold_to_contact_id
        , l_order_source_id	-- order_source_id
        , sysdate	-- ordered_date
        , 'USD'		-- transactional_curr_code
        , null    -- cust_id	-- invoice_customer_number
        , invoice_to_id  	-- invoice_to_org_id
        , ship_to_id	-- ship_to_org_id
        , null -- cust_id	-- ship_to_customer_number
        , 1000		-- price_list_id
        , sysdate	-- request_date
        , invoice_to_contact_id		-- invoice_to_contact_id
        , ship_to_contact_id		-- ship_to_contact_id
        , 'Standard'		-- shipment_priority_code
        , null		-- shipping_method_code DHL
        , NULL		-- freight_terms_code
        , NULL		-- fob_point_code
        , 1		-- accounting_rule_id
        , '-2'		-- invoicing_rule_id
        , 'INSERT' --OE_GLOBALS.G_OPR_CREATE   --'INSERT'      -- 'INSERT'	-- operation_code
        , l_request_id
        , 1000		-- salesrep_id
        , 4		-- PAYMENT_TERM_ID
        , 'S'		-- Tax_Exempt_Flag
        , '11'
        , sysdate + 10
        , 'G'
        , l_request_id
        , oe_order_headers_s.nextval -- header_id
        );

       FOR loop_counter2 IN 1..lines_per_order LOOP
       l_item_counter := l_item_counter + 1;
       c_item_id := item_arr(((l_item_counter - 1) mod numofdistinctlines) + 1);
       c_quantity := quantity_arr(((l_item_counter - 1) mod numofdistinctlines) + 1);

	INSERT INTO OE_LINES_IFACE_ALL (
	 creation_date
	, created_by
	, last_update_date
	, last_updated_by
	, orig_sys_document_ref
	, orig_sys_line_ref
	, sold_to_org_id
	, line_number
	, line_type_id
	, order_quantity_uom
	, ordered_quantity
	, unit_list_price
	, unit_selling_price
	, customer_item_id_type
	, inventory_item_id
	, customer_item_id
	, schedule_date
	, ship_to_contact_id
	, shipment_priority_code
	, shipping_method_code
	, price_list_id
	, accounting_rule_id
	, invoicing_rule_id
	, calculate_price_flag
	, order_source_id
	, pricing_date
	, promise_date
	, TAX_CODE
	, operation_code
	, request_id
	, salesrep_id
	, payment_term_id
	, tax_exempt_flag
	, invoice_to_org_id
	, invoice_to_contact_id
	, ship_from_org_id
        , line_id
        , request_date
        , schedule_ship_date
	)
	VALUES(
	  SYSDATE		-- creation_date
        , -1			-- created_by
        , SYSDATE		-- last_update_date
        , -1			-- last_updated_by
        , l_orig_sys_document_ref	-- orig_sys_document_ref
        , loop_counter2		-- orig_sys_line_ref
	, cust_id		-- sold_to_org_id
        , loop_counter2		-- line_number
        , 1427   --null			-- line_type_id
        , 'Ea'			-- order_quantity_uom
        , c_quantity			-- ordered_quantity
        , 27.34 --null         --5354.15		-- unit_list_price
        , 27.34 --null         --5354.15		-- unit_selling_price
	   ,'INT'			-- item_identifier_type
        , c_item_id			-- inventory_item_id
        , c_item_id			-- item_id
        , SYSDATE		-- schedule_date
        , ship_to_contact_id		-- ship_to_contact_id
        , 'Standard'			-- shipment_priority_code
        , null		-- shipping_method_code DHL
        , 1000			-- price_list_id
        , 1			-- accounting_rule_id
        , '-2'			-- invoicing_rule_id
        , 'N'			-- calculate_price_flag
        , l_order_source_id              -- order_source_id
        , SYSDATE		-- pricing_date
        , SYSDATE		-- promise_date
        , NULL			-- 'Sales Tax' tax code
        , 'INSERT' --OE_GLOBALS.G_OPR_CREATE  --'INSERT'		-- operation_code
        , l_request_id
	, 1000			-- salesrep_id
	, 4			-- payment term : '30 Net'
	, 'S'			-- tax exempt: 'Standard'
	, invoice_to_id	-- invoice_to_org_id
	, invoice_to_contact_id		-- invoice_to_contact_id
	, p_org_id                         -- ship_from_org_id
        , oe_order_lines_s.nextval -- line_id
        , sysdate      --request_date
        , sysdate + 1
        );

        print_debug('Inserted Order Line ' || loop_counter2);
       END LOOP;

       -- insert action request to book the order
       INSERT INTO OE_ACTIONS_INTERFACE (
        order_source_id
       , orig_sys_document_ref
       , operation_code
       , request_id
        )
       VALUES(
        l_order_source_id         -- order_source_id
       , l_orig_sys_document_ref   -- orig_sys_document_ref
       , OE_GLOBALS.G_BOOK_ORDER   -- operation_code
       , l_request_id
       );

       ij := ij + 1;
       l_orig_sys_tbl(ij).order_source_id := l_order_source_id;
       l_orig_sys_tbl(ij).ORIG_SYS_DOCUMENT_REF := l_orig_sys_document_ref;
    END LOOP;

  END LOOP;

IF l_so_orders IS NOT NULL AND  (l_so_orders.count > 0) THEN
  fnd_msg_pub.initialize;
  oe_msg_pub.initialize;

  OE_STANDARD_WF.RESET_APPS_CONTEXT_OFF;

  print_debug('Importing orders............... ' || l_orig_sys_tbl.first || '-' || l_orig_sys_tbl.last);
  OE_BULK_ORDER_PVT.Process_Batch(
           p_batch_id => l_request_id
           ,p_validate_only => FND_API.G_FALSE
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
           ,x_return_status => l_return_status);
  if l_msg_count > 2 then
    l_msg_count := 2;
  end if;
  for k in 1 .. l_msg_count loop
        l_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
        print_debug('Error msg: '||substr(l_msg_data,1,300));
  end loop;

  print_debug('after import order');
  oe_msg_pub.count_and_get( p_encoded    => 'F'
                         , p_count      => l_msg_count
                        , p_data        => l_msg_data);
  print_debug('no. of OE messages :'||l_msg_count);
  for k in 1 .. l_msg_count loop
        l_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
       print_debug('Error msg: '||substr(l_msg_data,1,200));
  end loop;

  fnd_msg_pub.count_and_get( p_encoded    => 'F'
                         , p_count      => l_msg_count
                        , p_data        => l_msg_data);
  print_debug('no. of FND messages :'||l_msg_count);
  for k in 1 .. l_msg_count loop
       l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
       print_debug(substr(l_msg_data,1,200));
  end loop;

  if l_return_status = FND_API.G_RET_STS_ERROR then
    print_debug('Expected error');
  elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    print_debug('UNExpected error');
  end if;
--  Setting end request date
  SELECT to_char(sysdate, 'MM/DD/RR hh:mi:ss')
  INTO l_end_req_date FROM dual;

  for ij in l_orig_sys_tbl.first..l_orig_sys_tbl.last LOOP
     l_orig_sys := l_orig_sys_tbl(ij);

     l_order_source_id := l_orig_sys.order_source_id;
     l_orig_sys_document_ref := l_orig_sys.orig_sys_document_ref;

     update oe_headers_interface
       set error_flag = 'N'
      where request_id = l_request_id
       and order_source_id = l_order_source_id
       and orig_sys_document_ref = l_orig_sys_document_ref;

     select order_number, header_id
     into l_order_number, l_o_header_id
     from oe_order_headers_all
     where ORIG_SYS_DOCUMENT_REF = L_ORIG_SYS_DOCUMENT_REF
          and creation_date > sysdate - 1 ;
     write_to_output(p_test_id, 'SORDER_NUM', 'Order Only, ' || l_order_number, p_run_id);

     FOR sol_rec in c_solines(l_o_header_id) LOOP

        l_dem_indx := g_demand_tbl.count + 1;

        IF sol_rec.source_doc_type_id = 10 THEN
           l_transaction_type_id := INV_GLOBALS.G_TYPE_INTERNAL_ORDER_STGXFR;
        ELSE
           l_transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;
        END IF;
        SELECT transaction_source_type_id
        INTO l_demand_source_type_id
        FROM mtl_transaction_types
        WHERE transaction_type_id = l_transaction_type_id;

        print_debug('Type :' || l_demand_source_type_id);
        print_debug('Type :' || l_demand_source_header_id);
        print_debug('Type :' || l_demand_source_line_id);
        g_demand_tbl(l_dem_indx).label := l_so_orders(ij)(1);
        g_demand_tbl(l_dem_indx).demand_source_type_id := l_demand_source_type_id;
        g_demand_tbl(l_dem_indx).demand_source_header_id := sol_rec.header_id;
        g_demand_tbl(l_dem_indx).demand_source_line_id := sol_rec.line_id;
        g_demand_tbl(l_dem_indx).demand_source_name := NULL;
        g_demand_tbl(l_dem_indx).demand_source_delivery := NULL;
     END LOOP;
  END LOOP;

  IF l_orig_sys_tbl.count > 1 THEN
    g_params('FROM_REQUESTED_DATE') := l_start_req_date;
    g_params('TO_REQUESTED_DATE') := l_end_req_date;
    g_params('ORDER_NUMBER') := NULL;
    g_params('ORDER_HEADER_ID') := NULL;
    g_params('ORDER_TYPE_ID') := NULL;
  ELSE
    g_params('FROM_REQUESTED_DATE') := ' ';
    g_params('TO_REQUESTED_DATE') := ' ';
    g_params('ORDER_NUMBER') := l_order_number;
    g_params('ORDER_HEADER_ID') := l_o_header_id;
    g_params('ORDER_TYPE_ID') := l_order_type_id;
  END IF;
  print_debug('Order Header ID  : ' || l_o_header_id || ' - ' || g_params('ORDER_HEADER_ID'));
END IF;

END create_sorder;

PROCEDURE data_setup_alloc (p_data  IN OUT NOCOPY     dblarrchartabtype150,
                            p_org_id   IN	NUMBER,
                            p_user_id  IN       NUMBER,
                            p_run_id   IN       NUMBER,
			    p_test_id  IN       NUMBER) IS
BEGIN


   create_so(p_data , p_org_id , p_user_id, p_run_id, p_test_id);

   create_sorder(p_data , p_org_id , p_user_id, p_run_id, p_test_id);

   create_mo(p_data , p_org_id , p_user_id, p_run_id, p_test_id);

   create_onhand(p_data , p_org_id , p_user_id, p_run_id, p_test_id);

   create_txns(p_data , p_org_id , p_user_id, p_run_id, p_test_id);


   create_rsvs(p_data , p_org_id , p_user_id, p_run_id, p_test_id);

END data_setup_alloc;


PROCEDURE prcom(p_org_id    NUMBER,
		p_run_id    NUMBER,
		p_test_id   NUMBER)
 IS
batch_id number;

l_count number :=1;
l_ERRBUF   VARCHAR2(2000) ;
l_RETCODE   VARCHAR2(2000) ;
l_X_ROWID   VARCHAR2(2000) ;
l_X_BATCH_ID   NUMBER ;
l_X_NAME   VARCHAR2(2000) ;

l_summary  VARCHAR2(2000) ;
l_detail   VARCHAR2(2000) ;

--l_P_SHIP_CONFIRM_RULE_ID   NUMBER :=1;
l_P_MODE   VARCHAR2(2000) :='ALL' ;

l_header_id NUMBER;
l_order_type_id NUMBER;
l_from_req_date DATE;
l_to_req_date DATE;

cursor c1 is select distinct a.batch_id
       from wsh_new_deliveries a, wsh_delivery_details b,wsh_delivery_assignments c
       where c.delivery_id = a.delivery_id
         and c.delivery_detail_id = b.delivery_detail_id
         and b.batch_id =l_X_BATCH_ID;
Begin

  print_debug(' header : ' || g_params('ORDER_HEADER_ID'));
  print_debug(' from req : ' || g_params('FROM_REQUESTED_DATE'));
IF nvl(g_params('FROM_REQUESTED_DATE'),' ') = ' ' THEN
  print_debug('Calling PR with order header : ' || g_params('ORDER_HEADER_ID'));
  l_header_id := to_number(g_params('ORDER_HEADER_ID'));
  l_order_type_id := to_number(g_params('ORDER_TYPE_ID'));
  l_from_req_date := NULL;
  l_to_req_date := NULL;
ELSE
  print_debug('In else');
  l_header_id := NULL;
  l_order_type_id := NULL;
  l_from_req_date := to_date(g_params('FROM_REQUESTED_DATE'),'MM/DD/RR hh:mi:ss');
  l_to_req_date := to_date(g_params('TO_REQUESTED_DATE'),'MM/DD/RR hh:mi:ss');
END IF;


WSH_PICKING_BATCHES_PKG.Insert_Row(
X_ROWID => l_X_ROWID
,X_BATCH_ID => l_X_BATCH_ID
,P_CREATION_DATE => sysdate
,P_CREATED_BY => fnd_global.user_id
,P_LAST_UPDATE_DATE => sysdate
,P_LAST_UPDATED_BY => fnd_global.user_id
,P_LAST_UPDATE_LOGIN => fnd_global.user_id
--,P_batch_name_prefix => NULL
,X_NAME => l_X_NAME
,P_BACKORDERS_ONLY_FLAG => 'I'
,P_DOCUMENT_SET_ID => NULL
,P_EXISTING_RSVS_ONLY_FLAG => NULL
,P_SHIPMENT_PRIORITY_CODE => NULL
,P_SHIP_METHOD_CODE => NULL
,P_CUSTOMER_ID => NULL
,P_ORDER_HEADER_ID => l_header_id
,P_SHIP_SET_NUMBER => NULL
,P_INVENTORY_ITEM_ID => NULL
,P_ORDER_TYPE_ID => l_order_type_id
,P_FROM_REQUESTED_DATE => l_from_req_date
,P_TO_REQUESTED_DATE => l_to_req_date
,P_FROM_SCHEDULED_SHIP_DATE => NULL
,P_TO_SCHEDULED_SHIP_DATE => NULL --SYSDATE
,P_SHIP_TO_LOCATION_ID => NULL
,P_SHIP_FROM_LOCATION_ID => NULL
,P_TRIP_ID => NULL
,P_DELIVERY_ID => NULL
,P_INCLUDE_PLANNED_LINES => NULL
,P_PICK_GROUPING_RULE_ID => NULL
,P_PICK_SEQUENCE_RULE_ID => NULL
,P_AUTOCREATE_DELIVERY_FLAG => 'N'
,P_ATTRIBUTE_CATEGORY => NULL
,P_ATTRIBUTE1 => NULL
,P_ATTRIBUTE2 => NULL
,P_ATTRIBUTE3 => NULL
,P_ATTRIBUTE4 => NULL
,P_ATTRIBUTE5 => NULL
,P_ATTRIBUTE6 => NULL
,P_ATTRIBUTE7 => NULL
,P_ATTRIBUTE8 => NULL
,P_ATTRIBUTE9 => NULL
,P_ATTRIBUTE10 => NULL
,P_ATTRIBUTE11 => NULL
,P_ATTRIBUTE12 => NULL
,P_ATTRIBUTE13 => NULL
,P_ATTRIBUTE14 => NULL
,P_ATTRIBUTE15 => NULL
,P_AUTODETAIL_PR_FLAG => 'Y'
,P_CARRIER_ID => NULL
,P_TRIP_STOP_ID => NULL
,P_DEFAULT_STAGE_SUBINVENTORY => NULL
,P_DEFAULT_STAGE_LOCATOR_ID => NULL
,P_PICK_FROM_SUBINVENTORY => NULL
,P_PICK_FROM_LOCATOR_ID => NULL
,P_AUTO_PICK_CONFIRM_FLAG => 'N'
,P_DELIVERY_DETAIL_ID => NULL
,P_PROJECT_ID => NULL
,P_TASK_ID => NULL
,P_ORGANIZATION_ID => NULL -- p_org_id
,P_SHIP_CONFIRM_RULE_ID => NULL
,P_AUTOPACK_FLAG => 'N' --NULL
,P_AUTOPACK_LEVEL => 0
,P_TASK_PLANNING_FLAG => NULL
,P_NON_PICKING_FLAG => NULL
,p_regionID => NULL
,p_zoneId => NULL
,p_categoryID => NULL
,p_categorySetID => NULL
,p_acDelivCriteria => NULL
,p_RelSubinventory => NULL
,p_Append_FLAG => 'N' --NULL
,p_task_priority => NULL
,P_ALLOCATION_METHOD => 'I'
,P_CROSSDOCK_CRITERIA_ID => NULL
);

print_debug('l_X_BATCH_ID:'||l_X_BATCH_ID);
print_debug('l_X_NAME:'||l_X_NAME);



----Pick Release
print_debug('***** Testing WSH_PICK_LIST.Release_Batch *****');


WSH_PICK_LIST.Release_Batch(
ERRBUF => l_ERRBUF
,RETCODE => l_RETCODE
,P_BATCH_ID => l_X_BATCH_ID
,P_LOG_LEVEL => 1
,p_NUM_WORKERS => 1
);

print_Debug('l_ERRBUF:'||l_ERRBUF);

print_debug('l_RETCODE:'||l_RETCODE);

wsh_util_core.get_messages('Y',l_summary,l_detail,l_count);
print_debug('Summary Msg from Stack:'||substr(l_summary,1,length(l_summary)));

print_debug('Detail Msg from Stack:'||substr(l_detail,1,length(l_detail)));

print_debug('^^^^^^ Finished Pick Release Process ^^^^^^');

EXCEPTION
   WHEN OTHERS THEN
        write_ut_error(p_test_id, 'Error while calling Pick Release :  ' || SQLERRM, p_run_id);

End prcom;


PROCEDURE execute_flowtype_alloc(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                                 p_org_id  IN  NUMBER,
				 p_run_id  IN  NUMBER,
				 p_test_id  IN  NUMBER)
IS

  l_return_status    VARCHAR(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(200);
  l_commit  VARCHAR2(1) := FND_API.G_FALSE;
  l_flow    VARCHAR2(10);
  l_wtt_tbl             wms_rule_extn_pvt.g_suggestion_list_rec_type;
  l_simulation_mode number;
  l_simulation_id number;
  l_start    DATE;
  l_rule_param   arrchartabtype150;

  l_demand_rsvs_ordered     inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_qty_available       NUMBER;

   l_rsv_qty2_available      NUMBER; --BUG#7377744 Added a secondary quantity available to reserve to make it consistent with process_reservations call
  l_demand_info             wsh_inv_delivery_details_v%ROWTYPE;
  l_dem_indx                NUMBER;

BEGIN
  l_flow := get_value(p_data, 'FLOW');


  IF l_flow = g_flow_sugg_rsv THEN
/* Calling API */

    FOR i in 1..g_trolin_tbl.count LOOP
  wms_rule_extn_pvt.suggest_reservations(
     p_api_version      =>  1.0
  , p_init_msg_list    => fnd_api.g_false
  , p_commit           => fnd_api.g_false
  , p_validation_level => 0
  , x_return_status    => l_return_status
  , x_msg_count        => l_msg_count
  , x_msg_data         => l_msg_data
  , p_transaction_temp_id  => NULL
  , p_allow_partial_pick   => 'Y'
  , p_suggest_serial       => 'N'
  , p_mo_line_rec         => g_trolin_tbl(i)
  , p_demand_source_header_id     => NULL
  , p_demand_source_line_id       => NULL
  , p_demand_source_type  =>  inv_reservation_global.g_source_type_inv
  , p_demand_source_name  =>  g_trolin_tbl(i).line_id
  , p_suggestions         => l_wtt_tbl);

/* End Calling API */
       print_debug('After suggest reservations ');
       IF l_return_status <> 'S' THEN
          write_ut_error(p_test_id,'Suggest Reservations err : ' || l_msg_data, p_run_id);
       END IF;
    END LOOP;
  ELSIF l_flow = g_flow_pick_rel THEN
     print_debug('Calling Pick Release  : ' );
    prcom(p_org_id, p_run_id, p_test_id);
  ELSIF l_flow = g_flow_create_sugg THEN
      l_simulation_mode := 0;
      l_simulation_id := 0;


   --delete mtl_material_transactions_temp where move_order_line_id = g_trolin_tbl(1).line_id;

      l_rule_param := get_value_list(p_data,'RULES');
      IF l_rule_param.count > 0 THEN
         l_simulation_id := to_number(l_rule_param(1)(3));
         IF l_rule_param(1)(1) = 'PICK' THEN
            IF l_rule_param(1)(2) = 'RULE' THEN
               l_simulation_mode := wms_engine_pvt.g_pick_rule_mode;
            ELSIF  l_rule_param(1)(2) = 'STRATEGY' THEN
               l_simulation_mode := wms_engine_pvt.g_pick_strategy_mode;
            ELSIF  l_rule_param(1)(2) = 'FULL' THEN
               l_simulation_mode := wms_engine_pvt.g_pick_full_mode;
               l_simulation_id := NULL;
            END IF;
         ELSIF l_rule_param(1)(1) = 'PUT' THEN
            IF l_rule_param(1)(2) = 'RULE' THEN
               l_simulation_mode := wms_engine_pvt.g_put_rule_mode;
            ELSIF  l_rule_param(1)(2) = 'STRATEGY' THEN
               l_simulation_mode := wms_engine_pvt.g_put_strategy_mode;
            ELSIF  l_rule_param(1)(2) = 'FULL' THEN
               l_simulation_mode := wms_engine_pvt.g_put_full_mode;
               l_simulation_id := NULL;
            END IF;
         ELSIF l_rule_param(1)(1) = 'FULL' THEN
            l_simulation_mode := wms_engine_pvt.g_full_simulation;
         END IF;
      END IF;
    IF l_simulation_mode <> 0 THEN
       g_is_simulation := TRUE;
    END IF;

    print_debug ('Simulation Mode : ' || l_simulation_mode);
    print_debug ('Simulation ID : ' || l_simulation_id);

    FOR i in 1..g_trolin_tbl.count LOOP

      print_debug ('Mo Line ID : ' || g_trolin_tbl(i).line_id);
      select sysdate into l_start from dual;

      delete wms_transactions_temp;

      l_demand_info.oe_line_id := g_trolin_tbl(i).line_id;

      l_dem_indx := g_link_mo_dem(g_trolin_tbl(i).line_id);

  --Bug#7377744 : included secondary quantity available to reserve in the parameters
      inv_pick_release_pvt.process_reservations(
        x_return_status => l_return_status
      , x_msg_count => l_msg_count
      , x_msg_data => l_msg_data
      , p_demand_info => l_demand_info
      , p_mo_line_rec => g_trolin_tbl(i)
      , p_mso_line_id => g_demand_tbl(l_dem_indx).demand_source_header_id
      , p_demand_source_type => g_demand_tbl(l_dem_indx).demand_source_type_id
      , p_demand_source_name => g_demand_tbl(l_dem_indx).demand_source_name
      , p_allow_partial_pick => 'Y'
      , x_demand_rsvs_ordered => l_demand_rsvs_ordered
      , x_rsv_qty_available => l_rsv_qty_available
      ,x_rsv_qty2_available  => l_rsv_qty2_available);

      g_start_time := SYSDATE;
      wms_engine_pvt.create_suggestions
        (
         p_api_version           => 1.0,
         p_init_msg_list         => fnd_api.g_true,
         p_commit                => fnd_api.g_false,
         p_validation_level      => fnd_api.g_valid_level_full,
         x_return_status         => l_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data,
         p_transaction_temp_id   => g_trolin_tbl(i).line_id,
         p_reservations          => l_demand_rsvs_ordered,
         p_suggest_serial        => fnd_api.g_true,
         p_simulation_mode       => l_simulation_mode,
         p_simulation_id         => l_simulation_id
         );
     ------------------------
      print_debug('Stack Msg'|| l_msg_data);
      print_debug('After calling create_suggestions  Return '|| l_return_status);

      IF l_return_status <> 'S' THEN
         write_ut_error(p_test_id,'Create Suggestions returned with an error : ' || l_msg_data, p_run_id);
      END IF;
    END LOOP;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      write_ut_error(p_test_id,'Failure in alloc execution : ' || SQLERRM, p_run_id);

END execute_flowtype_alloc;




PROCEDURE write_alloc_rsvs(p_test_id     NUMBER, p_run_id   NUMBER) IS

CURSOR c_get_rsvs_lines (p_di   NUMBER) IS
  SELECT ROWNUM || ' : ' ||
         mp.organization_code || ', ' ||
         msi.segment1 || ', ' ||
         mr.revision || ', ' ||
         mr.lot_number || ', ' ||
         mr.subinventory_code || ', ' ||
         mil.segment1 || '.' ||
         mil.segment2 || '.' ||
         mil.segment3 || ', ' ||
         wlpn.LICENSE_PLATE_NUMBER || ', ' ||
         mr.primary_reservation_quantity || ', ' ||
         mr.primary_uom_code || ', ' ||
         Nvl(mr.detailed_quantity,0) || ', ' ||
         mr.secondary_reservation_quantity || ', ' ||
         mr.secondary_uom_code || ', ' ||
         Nvl(mr.secondary_detailed_quantity,0) as p_text,
         mr.reservation_id as reservation_id
     FROM mtl_reservations mr, mtl_parameters mp, mtl_system_items msi, wms_license_plate_numbers wlpn, mtl_item_locations mil
     WHERE
       Nvl(mr.supply_source_type_id, 13) = 13
       AND g_demand_tbl(p_di).demand_source_type_id = mr.demand_source_type_id
       AND nvl(g_demand_tbl(p_di).demand_source_header_id,-9999) = nvl(mr.demand_source_header_id, -9999)
       AND Nvl(g_demand_tbl(p_di).demand_source_line_id, -9999) = Nvl(mr.demand_source_line_id,-9999)
       AND Nvl(g_demand_tbl(p_di).demand_source_name, '@@@###@@#') = Nvl(mr.demand_source_name,'@@@###@@#')
       AND mr.organization_id = mp.organization_id
       AND mr.organization_id = msi.organization_id
       AND mr.inventory_item_id = msi.inventory_item_id
       AND wlpn.lpn_id (+) = mr.lpn_id
       AND mil.inventory_location_id (+) = mr.locator_id;

CURSOR c_get_ser_rsvs(p_rsid   NUMBER) IS
  SELECT serial_number
   FROM  mtl_serial_numbers;
   --WHERE reservation_id = p_rsid;

  l_ix    NUMBER;
  l_mo_line_id    NUMBER;
  l_ser_txt    VARCHAR2(150);
  l_ser_cnt    NUMBER := 0;
BEGIN

  l_ix := 1;
  FOR i in 1..g_demand_tbl.count LOOP
    FOR l_rsv in c_get_rsvs_lines(i) LOOP

     write_to_output(p_test_id, 'RSVS', l_rsv.p_text, p_run_id);
     --SELECT count(*) INTO l_ser_cnt FROM mtl_serial_numbers where reservation_id = l_rsv.reservation_id;
     IF l_ser_cnt > 0 THEN
        l_ser_txt := '';
        write_to_output(p_test_id, 'INFO','  ' || l_ser_cnt || ' serial numbers reserved.', p_run_id);
        FOR l_ser in c_get_ser_rsvs(l_rsv.reservation_id) LOOP
            l_ser_txt := l_ser_txt || ',' || l_ser.serial_number;
            IF length(l_ser_txt) > 135 THEN
               write_to_output(p_test_id, 'SERIALS', '     ' || l_ser_txt, p_run_id);
               l_ser_txt := '';
            END IF;
        END LOOP;
        IF length(l_ser_txt) > 0 THEN
           write_to_output(p_test_id, 'SERIALS', '     ' || l_ser_txt, p_run_id);
        END IF;
     END IF;

    END LOOP;
  END LOOP;

END write_alloc_rsvs;


PROCEDURE write_alloc_mmtt(p_test_id     NUMBER, p_run_id   NUMBER) IS

CURSOR c_get_wtt_lines (p_di   NUMBER) IS
  SELECT DECODE(mmtt.type_code,1,'PUT :: ','PICK :: ') || mmtt.LOT_NUMBER || mmtt.FROM_SUBINVENTORY_CODE || ', ' || mil.segment1 || '.' || mil.segment2 || '.' || mil.segment3 || ', ' ||
         mmtt.TRANSACTION_QUANTITY || ', ' || 'UOM' || ', ' || RESERVATION_ID || ', ' || wr1.name || ', ' || wr2.name as ptext,
    mmtt.transaction_temp_id as transaction_temp_id
  FROM wms_transactions_temp mmtt, wms_rules wr1, wms_rules wr2,
       mtl_item_locations mil
  WHERE --mmtt.move_order_line_id = g_demand_tbl(p_di).mo_line_id
        mmtt.line_type_code = 2
    AND wr1.rule_id (+) = mmtt.rule_id  --pick_rule_id
    AND wr2.rule_id (+) = mmtt.rule_id  --putaway_rule_id
    AND mil.inventory_location_id (+) = mmtt.from_locator_id;

/*CURSOR c_get_wtt_lines (p_di   NUMBER) IS
  SELECT mmtt.TRANSACTION_TEMP_ID || ', ' || mmtt.LOT_NUMBER || mmtt.FROM_SUBINVENTORY_CODE || ', ' || mmtt.TRANSFER_SUBINVENTORY || ', ' || mil.segment1 || '.' || mil.segment2 || '.' || mil.segment3 || ', ' ||
         mmtt.QUANTITY || ', ' || 'UOM' || ', ' || 'RESERVATION_ID' || ', ' || wr1.name || ', ' || wr2.name as ptext,
    mmtt.transaction_temp_id as transaction_temp_id
  FROM wms_transactions_temp mmtt, wms_rules wr1, wms_rules wr2,
       mtl_item_locations mil
  WHERE --mmtt.move_order_line_id = g_demand_tbl(p_di).mo_line_id
        mmtt.line_type_code = 2
    AND wr1.rule_id (+) = mmtt.rule_id  --pick_rule_id
    AND wr2.rule_id (+) = mmtt.rule_id  --putaway_rule_id
    AND mil.inventory_location_id (+) = mmtt.from_locator_id;*/

CURSOR c_get_mmtt_lines (p_di   NUMBER, p_use_mol  VARCHAR2) IS
  SELECT mmtt.TRANSACTION_TEMP_ID || ', ' || mmtt.SUBINVENTORY_CODE || ', ' || mmtt.TRANSFER_SUBINVENTORY || ', ' ||
         mil.segment1 || '.' || mil.segment2 || '.' || mil.segment3 || ', ' || mil2.segment1 || '.' || mil2.segment2 || '.' || mil2.segment3 || ', ' ||
         mmtt.TRANSACTION_QUANTITY || ', ' || mmtt.TRANSACTION_UOM || ', ' || mmtt.RESERVATION_ID || ', ' || wr1.name || ', ' || wr2.name as ptext,
     nvl(mtlt.LOT_NUMBER,mmtt.lot_number) || ', ' || nvl(mtlt.TRANSACTION_QUANTITY,mmtt.transaction_quantity) as ltext,
    mmtt.transaction_temp_id as transaction_temp_id, mtlt.lot_number as lot_number
  FROM mtl_material_transactions_temp mmtt, wms_rules wr1, wms_rules wr2, mtl_transaction_lots_temp mtlt,
       mtl_item_locations mil, mtl_item_locations mil2
  WHERE (p_use_mol = 'Y' AND (mmtt.move_order_line_id = g_demand_tbl(p_di).mo_line_id)
        OR (p_use_mol = 'N' AND g_demand_tbl(p_di).demand_source_type_id = mmtt.transaction_source_type_id
            AND nvl(g_demand_tbl(p_di).demand_source_header_id,-9999) = nvl(mmtt.transaction_source_id, -9999)
            AND Nvl(g_demand_tbl(p_di).demand_source_line_id, -9999) = Nvl(mmtt.trx_source_line_id,-9999)
            AND Nvl(g_demand_tbl(p_di).demand_source_name, '@@@###@@#') = Nvl(mmtt.transaction_source_name,'@@@###@@#')))
    AND wr1.rule_id (+) = mmtt.pick_rule_id
    AND wr2.rule_id (+) = mmtt.put_away_rule_id
    AND mmtt.creation_date > sysdate - 1
    AND mtlt.transaction_temp_id (+) = mmtt.transaction_temp_id
    AND mil.inventory_location_id (+) = mmtt.locator_id
    AND mil2.inventory_location_id (+) = mmtt.transfer_to_location;

CURSOR c_get_msnt_lines(p_tid  NUMBER)  IS
  SELECT msnt.fm_serial_number || ',' || msnt.to_serial_number as stext
  FROM mtl_serial_numbers_temp msnt, mtl_serial_numbers msn, mtl_material_transactions_temp mmtt
  WHERE mmtt.transaction_temp_id = p_tid
   AND msnt.transaction_temp_id = mmtt.transaction_temp_id
   AND msn.serial_number = msnt.fm_serial_number
   AND msn.inventory_item_id = mmtt.inventory_item_id;

CURSOR c_get_msnt_lines_wlot(p_tid  NUMBER, p_lot_number   VARCHAR2)  IS
  SELECT msnt.fm_serial_number || ',' || msnt.to_serial_number as stext
  FROM mtl_serial_numbers_temp msnt, mtl_serial_numbers msn, mtl_material_transactions_temp mmtt
  WHERE mmtt.transaction_temp_id = p_tid
   AND msnt.transaction_temp_id = mmtt.transaction_temp_id
   AND msn.serial_number = msnt.fm_serial_number
   AND msn.lot_number (+) = nvl(p_lot_number,'###')
   AND msn.inventory_item_id = mmtt.inventory_item_id;

CURSOR c_get_mtlt_lines(p_tid NUMBER) IS
  SELECT 'MTLT ' || ROWNUM || ' : ' || TRANSACTION_TEMP_ID || ', ' || LOT_NUMBER || ', ' || TRANSACTION_QUANTITY as ptext
  FROM mtl_transaction_lots_temp
  WHERE transaction_temp_id = p_tid;

  l_ix    NUMBER;
  l_mo_line_id    NUMBER;
  l_use_mol    VARCHAR2(1);
  l_sp         VARCHAR2(12);
BEGIN
   print_debug('In side write_alloc_mmtt' );
  l_ix := 1;
  FOR l_ix in 1..g_demand_tbl.count LOOP

    print_debug('Writing MMTT for MOL : ' || g_demand_tbl(l_ix).mo_line_id);
    IF g_demand_tbl(l_ix).mo_line_id IS NOT NULL THEN
       l_use_mol := 'Y';
    ELSE
       l_use_mol := 'N';
    END IF;
    --l_mo_line_id := g_demand_tbl(l_ix).line_id;

    IF g_is_simulation THEN
    FOR l_wtt in c_get_wtt_lines(l_ix) LOOP

       l_sp := '';
       write_to_output(p_test_id, 'WTT', l_wtt.ptext, p_run_id);
    END LOOP;
    ELSE
    FOR l_mmtt in c_get_mmtt_lines(l_ix, l_use_mol) LOOP

       l_sp := '';
       write_to_output(p_test_id, 'MMTT', l_mmtt.ptext, p_run_id);
       l_sp := l_sp || '    ';
       IF l_mmtt.lot_number IS NOT NULL THEN
          write_to_output(p_test_id, 'MTLT', l_sp || l_mmtt.ltext, p_run_id);
          l_sp := l_sp || '    ';
          FOR l_ser in c_get_msnt_lines_wlot(l_mmtt.transaction_temp_id, l_mmtt.lot_number) LOOP
            write_to_output(p_test_id, 'MSNT', l_sp || l_ser.stext, p_run_id);
          END LOOP;
       ELSE
          FOR l_ser in c_get_msnt_lines(l_mmtt.transaction_temp_id) LOOP
            write_to_output(p_test_id, 'MSNT', l_sp || l_ser.stext, p_run_id);
          END LOOP;
       END IF;

    END LOOP;
    END IF;

  END LOOP;

END write_alloc_mmtt;




PROCEDURE write_flowtype_alloc(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                            p_org_id   IN	NUMBER,
                            p_user_id  IN       NUMBER,
                            p_test_id  IN       NUMBER,
                            p_run_id   IN       NUMBER)
IS
l_r NUMBER;
BEGIN
   print_debug('write => p_test_id '|| p_test_id);
   write_alloc_mmtt(p_test_id, p_run_id);
   print_debug('write => p_run_id '|| p_run_id);
   write_alloc_rsvs(p_test_id, p_run_id);

   EXECUTE IMMEDIATE  ' SELECT max(runid) FROM wms_ut_tab '  INTO l_r ;
   print_debug(l_r);

END write_flowtype_alloc;



PROCEDURE data_setup_inbound (p_data  IN OUT NOCOPY     dblarrchartabtype150,
                            p_org_id   IN	NUMBER,
                            p_user_id  IN       NUMBER,
                            p_run_id   IN       NUMBER) IS

BEGIN

   print_debug('See data_setup_alloc example');

END data_setup_inbound;






PROCEDURE write_ut_test_output(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                           p_org_id    IN     NUMBER,
                           p_user_id   IN     NUMBER,
                           p_flow_type_id IN     NUMBER,
                            p_testset_id  IN       NUMBER,
                            p_test_id  IN       NUMBER,
                            p_run_id   IN       NUMBER,
                            p_file_name IN     VARCHAR2,
                            p_log_dir   IN     VARCHAR2) IS

BEGIN

   print_debug('Writing flowtype alloc ' || p_run_id);
    --print_debug(

    EXECUTE IMMEDIATE
   ' INSERT into wms_ut_run (RUNID, TESTSET_ID, TEST_ID, START_DATE, END_DATE, USER_ID, FILE_NAME, FILE_PATH)'||
   ' VALUES ( :p_run_id, :p_testset_id, :p_test_id, :p_start_time, :p_end_time, :p_user_id, :p_file_name, :p_log_dir)'
    using p_run_id, p_testset_id, p_test_id, g_start_time, g_end_time, p_user_id, p_file_name, p_log_dir;

   print_debug('In write test');
  IF p_flow_type_id = g_ft_rule_alloc THEN
   print_debug('Calling alloc write');
   print_debug(' p_test_id ' ||  p_test_id);
   print_debug(' p_run_id '|| p_run_id);
   print_debug(' p_user_id ' || p_user_id);
   print_debug(' p_org_id ' || p_org_id);
     write_flowtype_alloc(p_data, p_org_id, p_user_id, p_test_id, p_run_id);
  ELSIF p_flow_type_id = g_ft_inbound THEN
     write_flowtype_alloc(p_data, p_org_id, p_user_id, p_test_id, p_run_id);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
       print_debug(SQLERRM);

END write_ut_test_output;


PROCEDURE execute_ut_test_flow(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                           p_org_id    IN     NUMBER,
                           p_user_id   IN     NUMBER,
                           p_flow_type_id IN     NUMBER,
			   p_run_id    IN     NUMBER,
		           p_test_id   IN     NUMBER) IS

BEGIN

  IF p_flow_type_id = g_ft_rule_alloc THEN
     execute_flowtype_alloc(p_data, p_org_id,p_run_id,p_test_id);
  ELSIF p_flow_type_id = g_ft_inbound THEN
     execute_flowtype_alloc(p_data, p_org_id,p_run_id,p_test_id);
  END IF;

END execute_ut_test_flow;


PROCEDURE action_clear_lpns (p_org_id   IN NUMBER,
                             p_params  IN chartabtype150,
                             p_run_id  IN  NUMBER,
                             p_test_id  IN  NUMBER)
IS

  l_lpn_id     NUMBER;
  l_return_status    VARCHAR(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(200);

BEGIN

  FOR l_param_indx in 2..p_params.count LOOP
     l_lpn_id := get_lpn_id(p_org_id, p_params(l_param_indx));
     WMS_CONTAINER_PVT.Initialize_LPN(
        p_api_version             => 1.0
      , x_return_status           => l_return_status
      , x_msg_count               => l_msg_count
      , x_msg_data                => l_msg_data
      , p_organization_id         => p_org_id
      , p_outermost_lpn_id        => l_lpn_id);

    UPDATE wms_license_plate_numbers
    SET parent_lpn_id = lpn_id
    WHERE parent_lpn_id = l_lpn_id;

    UPDATE wms_license_plate_numbers
    SET outermost_lpn_id = parent_lpn_id
    WHERE outermost_lpn_id = l_lpn_id;

  END LOOP;

END action_clear_lpns;

PROCEDURE action_set_status (p_org_id   IN NUMBER,
                             p_params  IN chartabtype150,
			     p_run_id  IN  NUMBER,
			     p_test_id  IN  NUMBER)
IS
 l_obj         VARCHAR2(80);
 l_obj_type    VARCHAR2(80);
 l_item_id     NUMBER;
 l_status_id   NUMBER;
 l_start       NUMBER;

BEGIN
  l_obj_type := p_params(2);

  SELECT status_id
  INTO l_status_id
  FROM mtl_material_statuses
  WHERE status_code = p_params(3);

  IF l_obj_type in ('SER','LOT') THEN
     l_item_id := get_item_id(p_org_id,p_params(4), p_test_id, p_run_id);
     l_start := 5;
  ELSE
     l_start := 4;
  END IF;

  FOR l_param_indx in l_start..p_params.count LOOP
     l_obj := p_params(l_param_indx);
     IF l_obj_type = 'LOT' THEN
        print_debug('Setting status of LOT ' || l_obj || ' to ' || p_params(3));
        UPDATE mtl_lot_numbers
        SET status_id = l_status_id
        WHERE organization_id = p_org_id
          AND lot_number = l_obj
          AND inventory_item_id = l_item_id;
     ELSIF l_obj_type = 'SUB' THEN
        print_debug('Setting status of SUB ' || l_obj || ' to ' || p_params(3));
        UPDATE mtl_secondary_inventories
        SET status_id = l_status_id
        WHERE organization_id = p_org_id
          AND secondary_inventory_name = l_obj;
     ELSIF l_obj_type = 'LOC' THEN
        print_debug('Setting status of SUB ' || l_obj || ' to ' || p_params(3));
        UPDATE mtl_secondary_inventories
        SET status_id = l_status_id
        WHERE organization_id = p_org_id
          AND secondary_inventory_name = l_obj;
     ELSIF l_obj_type = 'SER' THEN
        print_debug('Setting status of SUB ' || l_obj || ' to ' || p_params(3));
        UPDATE mtl_serial_numbers
        SET status_id = l_status_id
        WHERE current_organization_id = p_org_id
          AND serial_number = l_obj
          AND inventory_item_id = l_item_id;
     END IF;


  END LOOP;
END action_set_status;

PROCEDURE action_ref_onhand (p_org_id   IN NUMBER,
                             p_params  IN chartabtype150,
			     p_run_id  IN  NUMBER,
			     p_test_id  IN  NUMBER)
IS
  CURSOR c_mol (p_item_id  NUMBER) IS
  SELECT line_id
  FROM MTL_TXN_REQUEST_LINES
  WHERE organization_id = p_org_id
    AND inventory_item_id = p_item_id;

  CURSOR c_mmtt (p_item_id  NUMBER) IS
  SELECT transaction_temp_id
  FROM MTL_MATERIAL_TRANSACTIONS_TEMP
  WHERE organization_id = p_org_id
    AND inventory_item_id = p_item_id;

  CURSOR c_sol (p_item_id  NUMBER) IS
  SELECT line_id
  FROM oe_order_lines_all
  WHERE inventory_item_id = p_item_id
    AND org_id = p_org_id;

  l_item   VARCHAR2(80);
  l_item_id   NUMBER;
  l_return_status    VARCHAR(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(200);
  l_soh  OE_Order_PUB.Header_Rec_Type;
  l_max_del_det_id        NUMBER;
  l_req_qty        NUMBER;

BEGIN

  FOR l_param_indx in 2..p_params.count LOOP
  l_item := p_params(l_param_indx);
  print_debug('Refreshing onhand for item ' || l_item || ' - org ' || p_org_id);
  l_item_id := get_item_id(p_org_id, l_item, p_test_id, p_run_id);

  FOR s_rec in c_sol(l_item_id) LOOP
     --l_soh := oe_header_util.query_row(s_rec.header_id);
     -- OE_SALES_CAN_UTIL.perform_cancel_order ( p_header_rec   => l_soh , x_return_status => l_return_status);
     print_debug('Deleting detail deliveries from line ' || s_rec.line_id);
     SELECT sum(requested_quantity), max(delivery_detail_id)
     INTO l_req_qty, l_max_del_det_id
     FROM wsh_delivery_details
     WHERE source_line_id = s_rec.line_id;

     DELETE FROM wsh_delivery_details
     WHERE  source_line_id = s_rec.line_id
      AND delivery_detail_id <> l_max_del_det_id;

     --- Bug 4951858
     UPDATE wsh_delivery_details
       SET requested_quantity = l_req_qty
      WHERE delivery_detail_id =  l_max_del_det_id;
  END LOOP;

  -- Backorder all Move Order Line with allocations
  FOR c_rec in c_mol(l_item_id) LOOP
     print_debug ('Backorder MOL : ' || c_rec.line_id);
      inv_mo_backorder_pvt.backorder(x_return_status  =>  l_return_status,
                             x_msg_count =>  l_msg_count,
                             x_msg_data  =>  l_msg_data,
                             p_line_id   =>  c_rec.line_id);


    UPDATE wsh_delivery_details set move_order_line_id = NULL, released_status = 'R'
    WHERE move_order_line_id = c_rec.line_id;

--      INV_MO_ADMIN_PUB.cancel_line(1.0,'F','F',FND_API.G_VALID_LEVEL_FULL,c_rec.line_id,l_msg_count,l_msg_data,l_return_status);
  END LOOP;

  DELETE FROM mtl_txn_request_lines
  WHERE organization_id = p_org_id
    AND inventory_item_id = l_item_id;
  print_debug('Deleted All MOLs');
  FOR c_rec in c_mmtt(l_item_id) LOOP
     DELETE FROM mtl_serial_numbers_temp
     WHERE transaction_temp_id = c_rec.transaction_temp_id;

     DELETE FROM mtl_transaction_lots_temp
     WHERE transaction_temp_id = c_rec.transaction_temp_id;
  END LOOP;

  DELETE FROM mtl_material_transactions_temp
  WHERE organization_id = p_org_id
    AND inventory_item_id = l_item_id;

  DELETE FROM mtl_reservations
  WHERE organization_id = p_org_id
    AND inventory_item_id = l_item_id;

  DELETE FROM mtl_serial_numbers
  WHERE current_organization_id = p_org_id
    AND inventory_item_id = l_item_id;

  DELETE FROM mtl_lot_numbers
  WHERE organization_id = p_org_id
    AND inventory_item_id = l_item_id;

  DELETE FROM mtl_onhand_quantities_detail
  WHERE organization_id = p_org_id
    AND inventory_item_id = l_item_id;
  print_debug('Deleted ALL Onhand');

  END LOOP;

  inv_quantity_tree_pub.clear_quantity_cache;

EXCEPTION
   WHEN OTHERS THEN
        write_ut_error(p_test_id, 'Error ' || SQLERRM || ' while refreshing state for item : ' || l_item, p_run_id);
        RAISE;

END action_ref_onhand;

PROCEDURE gather_and_setup(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                           p_org_id    IN     NUMBER,
                           p_user_id   IN     NUMBER,
                           p_flow_type_id IN     NUMBER,
                           p_run_id    IN     NUMBER,
			   p_test_id   IN     NUMBER) IS

  l_action_lst arrchartabtype150;
  i NUMBER;
BEGIN

  l_action_lst := get_value_list(p_data,'ACTION');

  FOR i in 1..l_action_lst.count LOOP
    IF l_action_lst(i)(1) = g_refresh_onhand_picture THEN
       action_ref_onhand(p_org_id, l_action_lst(i), p_run_id,p_test_id);
    ELSIF l_action_lst(i)(1) = g_clear_lpns THEN
       action_clear_lpns(p_org_id, l_action_lst(i), p_run_id,p_test_id);
    ELSIF l_action_lst(i)(1) = g_set_material_status THEN
       action_set_status(p_org_id, l_action_lst(i), p_run_id,p_test_id);
    END IF;
  END LOOP;

  IF p_flow_type_id = g_ft_rule_alloc THEN
     data_setup_alloc(p_data, p_org_id, p_user_id, p_run_id, p_test_id);
  ELSIF p_flow_type_id = g_ft_inbound THEN
     data_setup_inbound(p_data, p_org_id, p_user_id, p_run_id);
  END IF;

END gather_and_setup;

PROCEDURE create_wms_ut123_pkg is
/*
Procedure run_ut_test(p_test_id      NUMBER,
                      p_testset_id  NUMBER,
                      p_run_id  NUMBER,
                      p_user_id      IN NUMBER,
                      p_log_dir      IN VARCHAR2
                      ) IS*/

l_test_id  NUMBER;
l_indx     NUMBER;
l_ctr      VARCHAR2(10);
l_data  dblarrchartabtype150;
l_text  arrchartabtype150;
l_file_name      VARCHAR2(80);
l_path      VARCHAR2(80);
l_flag boolean;
l_batch_name    VARCHAR2(40);
l_org_code    VARCHAR2(10);
l_org_id     NUMBER;

l_pkg_spec long;
l_pkg_body long;



BEGIN


 l_pkg_spec :=
 ' CREATE OR REPLACE PACKAGE wms_ut123_pkg  AS '
  ||'  PROCEDURE run_ut_test( p_test_id      NUMBER, '
  ||'                       p_testset_id  NUMBER,'
  ||'                       p_run_id  NUMBER,'
  ||'                       p_user_id      IN NUMBER,'
  ||' 		            p_log_dir     VARCHAR2);'
  ||' g_use   		BOOLEAN;'
  ||' g_testname        VARCHAR2(2000);'
  ||' g_start_time      DATE;'
  ||' g_end_time        DATE;'
  ||' '
  ||' TYPE numtabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;'
  ||' TYPE datetabtype IS TABLE OF DATE INDEX BY BINARY_INTEGER;'
  ||' TYPE chartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;'
  ||' TYPE chartabtype3 IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;'
  ||' TYPE chartabtype10 IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;'
  ||' TYPE chartabtype80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;'
  ||' TYPE chartabtype150 IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;'
  ||' TYPE arrchartabtype150 IS TABLE OF chartabtype150 INDEX BY BINARY_INTEGER;'
  ||' TYPE dblarrchartabtype150 IS TABLE OF arrchartabtype150 INDEX BY BINARY_INTEGER;'
  ||'    TYPE charchartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30); '
  ||' END wms_ut123_pkg; '
  ;
 EXECUTE IMMEDIATE l_pkg_spec;
 -----

 l_pkg_body :=
 ' CREATE OR REPLACE PACKAGE BODY wms_ut123_pkg IS'
  ||' g_test_id   NUMBER;'
  ||' Procedure run_ut_test(p_test_id       IN NUMBER,'
  ||'                       p_testset_id    IN  NUMBER,'
  ||'                       p_run_id        IN NUMBER,'
  ||'                       p_user_id       IN NUMBER,'
  ||'                       p_log_dir       IN VARCHAR2'
  ||'                       ) IS'
  ||' '
  ||' l_test_id  NUMBER;'
  ||' l_indx     NUMBER;'
  ||' l_ctr      VARCHAR2(10);'
  ||' l_data     wms_ut_pkg.dblarrchartabtype150;'
  ||' l_data_clear     wms_ut_pkg.dblarrchartabtype150;'
  ||' l_text     wms_ut_pkg.arrchartabtype150;'
  ||' l_text_clear     wms_ut_pkg.arrchartabtype150;'
  ||' l_file_name      VARCHAR2(80);'
  ||' l_path      VARCHAR2(80);'
  ||' l_flag boolean;'
  ||' l_batch_name    VARCHAR2(20);'
  ||' l_org_code    VARCHAR2(10);'
  ||' l_org_id     NUMBER;'
  ||' '
  ||' '
  ||' '
  ||'  CURSOR c_get_testids IS'
  ||'   Select distinct testset_id, test_id, flow_type_id, testname'
  ||'   From wms_ut_tab'
  ||'   Where test_id = nvl(p_test_id,test_id)'
  ||'     and testset_id = nvl(p_testset_id, testset_id); '
  ||'  CURSOR c_get_testdtypes(p_tid  NUMBER) IS'
  ||'   Select distinct upper(datatype) datatype'
  ||'   From wms_ut_tab'
  ||'   Where test_id = p_tid'
  ||'     AND upper(IN_OUT) <> ''OUT'';'
  ||'  CURSOR c_get_testtext(p_tid  NUMBER, p_dtype  VARCHAR2) IS'
  ||'   Select text'
  ||'   From wms_ut_tab'
  ||'   Where test_id = p_tid'
  ||'     and upper(datatype) = p_dtype'
  ||'     AND upper(IN_OUT) <> ''OUT'';'
  ||' '
  ||' BEGIN'
  ||'  '
  ||'  wms_ut_pkg.initialize;'
  ||'   '
  ||'   FOR l_test_rec in c_get_testids LOOP'
  ||'      '
  ||'    l_batch_name := RTRIM(LTRIM(l_test_rec.testname));'
  ||'    l_file_name := l_batch_name || ''_'' || to_char(p_run_id);'
  ||'    l_path := p_log_dir;'
  ||'    l_path := ''/slot02/oracle/wmsperfdb/10.1.0/temp/'';'
  ||'    l_path := ''/sqlcom/log/wmsdv11i/'';'
  ||'    l_path := ''/appslog/dist_top/utl/wmsdv11i/log/'';'
  ||'    commit;'
  ||'    l_flag :=FND_PROFILE.SAVE(''INV_DEBUG_FILE'', l_path||l_file_name, ''USER'', p_user_id);'
  ||'    fnd_global.apps_initialize(p_user_id,21676, 385);'
  ||'            wms_ut_pkg.print_debug(''Done setting up logging''); '
  ||' '
  ||'      l_data := l_data_clear;'
  ||'      l_test_id := l_test_rec.test_id;'
  ||'      g_test_id := l_test_id;'
  ||'      FOR l_dtypes in c_get_testdtypes(l_test_id) LOOP'
  ||'         l_indx := 0;'
  ||'         wms_ut_pkg.print_debug(''Setting datatype : '' || l_dtypes.datatype);'
  ||'         l_text := l_text_clear;'
  ||'         FOR l_t in c_get_testtext(l_test_id, l_dtypes.datatype) LOOP '
  ||'            wms_ut_pkg.print_debug(''Setting text : '' || l_t.text); '
  ||'            l_indx := l_indx + 1; '
  ||'            l_text(l_indx) := wms_ut_pkg.parse_text(l_t.text, '',''); '
  ||'         END LOOP;'
  ||'         l_indx := wms_ut_pkg.get_datatype_id(l_dtypes.datatype); '
  ||'         l_data(l_indx) := l_text;'
  ||'      END LOOP;'
  ||'  '
  ||'      l_org_code := wms_ut_pkg.get_value(l_data, ''ORG'');'
  ||'      select organization_id'
  ||'      into l_org_id'
  ||'      from mtl_parameters'
  ||'      where organization_code = l_org_code;'
  ||' '
  ||'      g_testname := l_test_rec.testname;'
  ||'      wms_ut_pkg.gather_and_setup(l_data, l_org_id, p_user_id, l_test_rec.flow_type_id, p_run_id, l_test_id);'
  ||' '
  ||'   wms_ut_pkg.g_start_time := SYSDATE; '
  ||'    wms_ut_pkg.execute_ut_test_flow(l_data, l_org_id, p_user_id, l_test_rec.flow_type_id, p_run_id,l_test_id);'
  ||'   wms_ut_pkg.g_end_time := SYSDATE; '
  ||'    wms_ut_pkg.write_ut_test_output(l_data, l_org_id, p_user_id, l_test_rec.flow_type_id, l_test_rec.testset_id, l_test_id, p_run_id, l_file_name, l_path); '
  ||'    commit;'
  ||'   END LOOP;'
  ||'   '
  ||' END run_ut_test; '
  ||'  '
  ||'  END wms_ut123_pkg ;' ;
  EXECUTE IMMEDIATE l_pkg_body;
END create_wms_ut123_pkg;


PROCEDURE import_test_cases(p_txt   chartabtype150,
                      p_overwrite   VARCHAR2)
IS
l_set_name    VARCHAR2(150);
l_test        VARCHAR2(150);
l_testset     VARCHAR2(150);
l_text        VARCHAR2(150);
l_pre_text    VARCHAR2(150);
colonseparation      NUMBER;
l_test_id            NUMBER;
l_testset_id         NUMBER;
l_fl_type            NUMBER := 10;
i                    NUMBER;
BEGIN

  FOR i in 1..p_txt.count LOOP
     colonseparation := INSTR(p_txt(i), ':',1,1);
     l_pre_text := RTRIM(LTRIM(SUBSTR(p_txt(i),1,colonseparation - 1)));
     l_text := RTRIM(LTRIM(SUBSTR(p_txt(i),colonseparation + 1)));
       print_debug ('Pre text |' || l_pre_text || '|');
     IF l_pre_text IS NOT NULL OR l_text IS NOT NULL THEN
     IF l_testset_id IS NULL AND l_pre_text = 'SET' THEN
        -- Get the test set id
        BEGIN
       print_debug ('setting testset' || l_text);
          l_test_id := NULL;
          l_test := NULL;
          l_testset := l_text;

       EXECUTE IMMEDIATE
         ' SELECT testset_id '		||
         ' FROM wms_ut_testset '	||
         ' WHERE testset = :l_testset '
         INTO l_testset_id
         USING l_testset;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

             EXECUTE IMMEDIATE  ' select wms_ut_tab_testset_s.nextval from dual' INTO l_testset_id ;
             EXECUTE IMMEDIATE  ' INSERT INTO WMS_UT_TESTSET (TESTSET_ID, TESTSET)' ||
            ' VALUES (:l_testset_id, :l_testset)' USING l_testset_id, l_testset;
        END;
     ELSIF l_testset_id IS NULL THEN
       print_debug ('setting default testset' || l_text);
        l_testset_id := 1;
        l_testset := 'Default';
        l_test_id := NULL;
        l_test := NULL;
     END IF;

     IF l_pre_text = 'TEST' THEN
       -- Start new test
       -- should check if test already defined and overwrite
          BEGIN
             l_test := l_text;
             EXECUTE IMMEDIATE
             ' Select test_id ' 			||
             ' from wms_ut_test'			||
             ' where testset_id = :l_testset_id'	||
             '  and testname = :l_test'
              INTO l_test_id
              USING l_testset_id, l_test;

             IF p_overwrite = 'Y' THEN
               -- Rename existing test cases and create this new test case
               EXECUTE IMMEDIATE
               ' Update wms_ut_test' 			||
               ' Set testname = ''DEL-'' || testname'    ||
               ' WHERE test_id = l_test_id;';

               EXECUTE IMMEDIATE
               ' Update wms_ut_tab' 			||
               ' Set testname = ''DEL-'' || testname' 	||
               ' WHERE test_id = l_test_id;';


               RAISE NO_DATA_FOUND;
             ELSE
               print_debug('Test Case ' || l_test || ' already exists in set ' || l_testset);
               l_test_id := NULL;
               l_test := NULL;
             END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
             EXECUTE IMMEDIATE 'select wms_ut_tab_test_s.nextval  from dual' INTO l_test_id;
             EXECUTE IMMEDIATE
               ' INSERT INTO WMS_UT_TEST (testset_id, test_id, testname)' ||
               ' VALUES (:l_testset_id, :l_test_id, :l_test)' USING l_testset_id, l_test_id, l_test;
          END;
     ELSIF l_test_id IS NULL THEN
       print_debug ('Test Name is missing');
     ELSE
       EXECUTE IMMEDIATE
       ' INSERT INTO WMS_UT_TAB ' 									||
         ' (FLOW_TYPE_ID, TESTSET_ID, TESTSET, TEST_ID, TESTNAME, TEXT, DATATYPE, IN_OUT, RUNID) ' 	||
       ' VALUES (:l_fl_type, :l_testset_id, :l_testset, :l_test_id, :l_test, :l_text, :l_pre_text, :l_in , :l_var)'
       USING l_fl_type, l_testset_id, l_testset, l_test_id, l_test, l_text, l_pre_text, 'IN', '';
       -----********************
     END IF;

     END IF;

  END LOOP;


END import_test_cases;


PROCEDURE import_test_cases (p_file    IN   VARCHAR2,
                             p_path    IN   VARCHAR2,
                             p_overwrite IN VARCHAR2)
IS
l_file_text  chartabtype150;
l_text_line  VARCHAR2(150);
inputfile UTL_FILE.FILE_TYPE;
BEGIN

  --inputfile := utl_file.fopen(p_path, p_file, 'r');
  inputfile := utl_file.fopen(p_path, p_file, 'r');

  LOOP
    BEGIN
      UTL_FILE.GET_LINE(inputfile, l_text_line);
      l_file_text(l_file_text.count + 1) := l_text_line;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         EXIT;
    END;
  END LOOP;

  import_test_cases(l_file_text, p_overwrite);

  utl_file.fclose(inputfile);

END;

/*
PROCEDURE export_test_cases (p_file    IN   VARCHAR2,
                             p_path    IN   VARCHAR2,
                             p_overwrite IN BOOLEAN,
                             p_test_id IN   NUMBER,
                             p_testset_id   NUMBER)
IS
TYPE l_tests IS RECORD (
  TEST_TEXT       VARCHAR2(2080) ,
  TESTSET         VARCHAR2(80),
  TESTNAME        VARCHAR2(150),
  TESTSET_ID      NUMBER,
  TEST_ID         NUMBER   );

 t_rec  l_tests;

l_file_text  chartabtype150;
l_text_line  VARCHAR2(150);
outputfile UTL_FILE.FILE_TYPE;
l_last_testset_id   NUMBER := -1;
l_last_test_id   NUMBER := -1;

--p_cur_tests wms_ut_pkg.cur_tests;

 CURSOR c_tests IS
SELECT datatype || ' : ' || text as test_text, testset, testname, testset_id, test_id
FROM wms_ut_tab
WHERE in_out = 'IN'
  AND test_id = nvl(p_test_id,test_id)
  AND testset_id = nvl(p_testset_id, testset_id)
ORDER BY testset_id, test_id;

BEGIN


  IF p_overwrite THEN
     --outputfile := utl_file.fopen(p_path || '/' || p_file, 'w');
     print_debug('Opening File to write cases');
  ELSE
     --outputfile := utl_file.fopen(p_path || '/' || p_file, 'a');
     print_debug('Opening File to append cases');
  END IF;

  FOR t_rec in c_tests LOOP
  --WHILE TRUE LOOP
  -- FETCH p_cur_tests into t_rec;
  -- EXIT WHEN t_rec.testset_id is NULL;
      IF l_last_testset_id <> t_rec.testset_id THEN
        UTL_FILE.PUT_LINE(outputfile, 'SET : ' || t_rec.testset);
        l_last_testset_id := t_rec.testset_id;
      END IF;
      IF l_last_test_id <> t_rec.test_id THEN
        UTL_FILE.PUT_LINE(outputfile, 'TEST : ' || t_rec.testname);
        l_last_test_id := t_rec.test_id;
      END IF;
      UTL_FILE.PUT_LINE(outputfile, t_rec.test_text);
   END LOOP;
   --close p_cur_tests;
  utl_file.fclose(outputfile);

END;
 ---
Procedure copy_test (p_from_test_id     IN    NUMBER,
                     p_to_test         IN    VARCHAR2,
                     p_to_testset      IN    VARCHAR2,
                     x_new_testset_id  OUT   NUMBER,
                     x_new_test_id     OUT   NUMBER)
IS
l_testset    VARCHAR2(30);



 CURSOR c_test IS
  SELECT *
  FROM wms_ut_tab
  WHERE test_id = p_from_test_id
    AND in_out = 'IN';

BEGIN

  IF p_to_testset IS NOT NULL THEN
  BEGIN
   EXECUTE IMMEDIATE
    ' SELECT testset_id, testset' 	||
    ' FROM wms_ut_testset' 		||
    ' WHERE testset = :l_testset'
    INTO x_new_testset_id, l_testset
    USING l_testset;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       EXECUTE IMMEDIATE  'select wms_ut_tab_testset_s.nextval  from dual' INTO x_new_testset_id;
       EXECUTE IMMEDIATE
        ' INSERT INTO WMS_UT_TESTSET (TESTSET_ID, TESTSET)' ||
        ' VALUES (:x_new_testset_id, :p_to_testset)'
        USING x_new_testset_id, p_to_testset;
      l_testset := p_to_testset;
  END;
  ELSE
   EXECUTE IMMEDIATE
    ' SELECT testset_id' 		||
    ' FROM wms_ut_test' 		||
    ' WHERE test_id = :p_from_test_id'
      INTO x_new_testset_id
      USING p_from_test_id;
  END IF;
  EXECUTE IMMEDIATE   'select wms_ut_tab_test_s.nextval  from dual' INTO x_new_test_id;
  EXECUTE IMMEDIATE
    ' INSERT INTO WMS_UT_TEST (testset_id, test_id, testname)' ||
    ' VALUES (:x_new_testset_id, :x_new_test_id, :p_to_test)'
    USING x_new_testset_id, x_new_test_id, p_to_test;


 FOR test_rec in c_test LOOP
  -- WHILE TRUE LOOP
  -- FETCH p_cur_tests_all into c_test;
   EXECUTE IMMEDIATE
      ' INSERT INTO WMS_UT_TAB' 									||
      ' (FLOW_TYPE_ID, TESTSET_ID, TESTSET, TEST_ID, TESTNAME, TEXT, DATATYPE, IN_OUT, RUNID)' 	||
      ' VALUES (:flow_type_id, :x_new_testset_id, :l_testset, :x_new_test_id, :p_to_test, :text, :datatype, :l_in , :l_null)'
      USING test_rec.flow_type_id, x_new_testset_id, l_testset, x_new_test_id, p_to_test, test_rec.text, test_rec.datatype, 'IN', '';
      ----- ************
  END LOOP;
  --CLOSE p_cur_tests_all;

END;

*/

Procedure indt
IS
 l_dt   chartabtype150;
begin

  l_dt(1) := 'SET : RTST';
  l_dt(2) := 'TEST : TST1';
  l_dt(3) := 'ORG : W1';
  l_dt(4) := 'FLOW : CS';
  l_dt(5) := 'MORDER : AS54888,Ea,3';
  l_dt(6) := 'REQNUM : RA1';


  import_test_cases(l_dt, 'Y');
end indt;

---------
FUNCTION get_flow_mask(p_mask IN varchar2, p_flow  IN  number) RETURN VARCHAR2  IS
        l_ctr                     INTEGER;
        l_flow_ctr                INTEGER;
        l_datatype                VARCHAR2(150);
        l_text                    VARCHAR2(2000);
 BEGIN
      wms_ut_pkg.initialize;
        IF P_MASK is not  NULL THEN
          l_flow_ctr := 1;
          FOR l_ctr IN 1..wms_ut_pkg.g_flow_type_datatypes(l_flow_ctr).datatype.count LOOP
            l_datatype      := wms_ut_pkg.g_data_masks( wms_ut_pkg.g_flow_type_datatypes(l_flow_ctr).datatype(l_ctr)).dtype;
            IF P_MASK = l_datatype THEN
               l_text  := wms_ut_pkg.g_data_masks( wms_ut_pkg.g_flow_type_datatypes(l_flow_ctr).datatype(l_ctr)).dmask;
             RETURN P_MASK || ' : ' ||l_Text;
          END IF;
         END LOOP;
       END IF;
       RETURN ' ';
 EXCEPTION
        WHEN OTHERS THEN
          RETURN ' ';
 END get_flow_mask;

FUNCTION get_mask(p_mask IN varchar2) RETURN VARCHAR2 IS
        l_ctr                     INTEGER;
        l_datatype                VARCHAR2(150);
        l_text                    VARCHAR2(2000);
BEGIN
        IF P_MASK is not  NULL THEN
          FOR l_ctr IN 1..wms_ut_pkg.g_data_masks.count LOOP
            l_datatype      := wms_ut_pkg.g_data_masks(l_ctr).dtype;
            IF P_MASK = l_datatype THEN
               l_text  := wms_ut_pkg.g_data_masks(l_ctr).dmask;
             RETURN P_MASK || ' : ' ||l_Text;
          END IF;
         END LOOP;
       END IF;
       RETURN ' ';
 EXCEPTION
        WHEN OTHERS THEN
          RETURN ' ';


END get_mask;


---
PROCEDURE Create_ut_tables
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2,
   p_commit                     IN      VARCHAR2,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2
 )IS
  table_exists EXCEPTION  ;
  PRAGMA Exception_Init(table_exists, -00942);
  l_sql                  VARCHAR2(2000);
  l_Testset              VARCHAR2(2000);
  l_Testname             VARCHAR2(2000);
  l_test_run             VARCHAR2(2000);

  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_message  varchar2(2000);
  BEGIN

  l_sql := 'create table WMS_UT_TAB( flow_type_id NUMBER NOT NULL, TestSet_id NUMBER NOT NULL ,TestSet VARCHAR2(80) NOT NULL, Test_id NUMBER
NOT NULL , Testname VARCHAR2(150), Text        VARCHAR2(2000),  DataType    VARCHAR2(80),  In_Out VARCHAR2(3),  RUNID  NUMBER )' ;
  l_testset := 'create table WMS_UT_TESTSET ( TestSet_id NUMBER NOT NULL ,TestSet VARCHAR2(150) NOT NULL , Set_desc VARCHAR2(150))';
  l_testname := 'create table WMS_UT_TEST   ( TestSet_id NUMBER NOT NULL ,Test_id NUMBER NOT NULL , Testname VARCHAR2(150) , Test_desc VARCHAR2(150) )';
  l_test_run := 'create table WMS_UT_RUN ( Runid NUMBER NOT NULL , TestSET_id NUMBER , Test_id NUMBER , Start_date  Date ,    END_DATE DATE , USER_ID NUMBER , FILE_NAME VARCHAR2(80) , FILE_PATH VARCHAR2(240)) ';

   EXECUTE IMMEDIATE   l_sql;
   EXECUTE IMMEDIATE   l_testset;
   EXECUTE IMMEDIATE   l_testname;
   EXECUTE IMMEDIATE   l_test_run;

  END Create_ut_tables;

   PROCEDURE Create_ut_seq
    (p_api_version                IN      NUMBER,
     p_init_msg_list              IN      VARCHAR2,
     p_commit                     IN      VARCHAR2,
     x_return_status              OUT     NOCOPY VARCHAR2,
     x_msg_count                  OUT     NOCOPY NUMBER,
     x_msg_data                   OUT     NOCOPY VARCHAR2
   )IS

     l_testset_seq      VARCHAR2(2000);
     l_test_seq         VARCHAR2(2000);
     l_run_seq          VARCHAR2(2000);
    BEGIN

    l_testset_seq := 'Create SEQUENCE  wms_ut_tab_testset_s INCREMENT BY 1 START WITH 100 MINVALUE 1 MAXVALUE 999999999999999999999999999 NOCYCLE NOORDER CACHE 20';
    l_test_seq    := 'Create SEQUENCE wms_ut_tab_test_s     INCREMENT BY 1 START WITH 100 MINVALUE 1 MAXVALUE 999999999999999999999999999 NOCYCLE NOORDER CACHE 20';
    l_run_seq     := 'Create SEQUENCE wms_ut_tab_run_s      INCREMENT BY 1 START WITH 100 MINVALUE 1 MAXVALUE 999999999999999999999999999 NOCYCLE NOORDER CACHE 20';

    EXECUTE IMMEDIATE   l_testset_seq;
    EXECUTE IMMEDIATE   l_test_seq;
    EXECUTE IMMEDIATE   l_run_seq;
    EXCEPTION
     WHEN others THEN
      Null;
  END Create_ut_seq;

  PROCEDURE drop_ut_tables is
   BEGIN
     EXECUTE IMMEDIATE 'drop table wms_ut_tab' ;
     EXECUTE IMMEDIATE 'drop table wms_ut_testset';
     EXECUTE IMMEDIATE 'drop table wms_ut_test';
     EXECUTE IMMEDIATE 'drop table wms_ut_run';
  END drop_ut_tables ;

  PROCEDURE drop_ut_seq is
  BEGIN
    EXECUTE IMMEDIATE 'drop SEQUENCE wms_ut_tab_test_s ';
    EXECUTE IMMEDIATE 'drop SEQUENCE wms_ut_tab_testset_s ';
    EXECUTE IMMEDIATE 'drop SEQUENCE wms_ut_tab_run_s ';
  END drop_ut_seq;

PROCEDURE drop_ut_pkg is
 BEGIN
 EXECUTE IMMEDIATE 'drop package wms_ut123_pkg';
END drop_ut_pkg;


  PROCEDURE Create_ut_datatypes
    (p_flow_type_id               IN      NUMBER,
     p_testset_id                 IN      NUMBER,
     p_testset                    IN      VARCHAR2,
     p_test_id                    IN      NUMBER,
     p_testname                   IN      VARCHAR2,
     p_runid                      IN      NUMBER,
     x_return_status              OUT     NOCOPY VARCHAR2,
     x_msg_count                  OUT     NOCOPY NUMBER,
     x_msg_data                   OUT     NOCOPY VARCHAR2) IS
        l_ctr                     INTEGER;
        l_flow_ctr                INTEGER;
        l_flow_type_id            INTEGER;
        l_testset_id              NUMBER;
        l_testset                 VARCHAR2(150);
        l_test_id                 NUMBER;
        l_testname                VARCHAR2(150);
        l_runid                   NUMBER;
        l_datatype                VARCHAR2(150);
        l_text                    VARCHAR2(2000);
     BEGIN
        l_flow_type_id           := p_flow_type_id;
        l_testset_id             := p_testset_id ;
        l_testset                := p_testset;
        l_test_id                := p_test_id;
        l_testname               := p_testname;
        l_runid                  := p_runid;

        If l_flow_type_id IS NOT NULL OR l_testset_id IS NOT NULL OR l_test_id IS  NOT NULL THEN

        wms_ut_pkg.initialize;
          FOR l_ctr IN 1..wms_ut_pkg.g_data_masks.count LOOP
           --- for each flow type , set l_flow_ctr
           l_flow_ctr := 1;

           l_datatype      := wms_ut_pkg.g_data_masks( wms_ut_pkg.g_flow_type_datatypes(l_flow_ctr).datatype(l_ctr)).dtype;
           l_text          := wms_ut_pkg.g_data_masks( wms_ut_pkg.g_flow_type_datatypes(l_flow_ctr).datatype(l_ctr)).dmask;


           EXECUTE IMMEDIATE
            ' INSERT INTO wms_ut_tab' 	||
            ' (FLOW_TYPE_ID, ' 		||
            ' TESTSET_ID,'		||
            ' TESTSET,' 		||
            ' TEST_ID,' 		||
            ' TESTNAME,' 		||
            ' TEXT,' 			||
            ' DATATYPE,'		||
            ' IN_OUT,'			||
            ' RUNID)' 			||
            '  values ' 		||
            '   (:l_flow_type_id, ' 	||
            '    :l_testset_id,' 	||
            '    :l_testset,'		||
            '    :l_test_id,'		||
            '    :l_testname,'		||
            '    :l_text,'		||
            '    :l_datatype,'		||
            '    :l_in,'		||
            '    :l_runid)'
            USING  l_flow_type_id,  l_testset_id, l_testset, l_test_id, l_testname, l_text, l_datatype,'IN', l_runid
            ;
          END LOOP;
          commit;
          END IF;

        EXCEPTION
        WHEN OTHERS THEN
          NULL;
   END Create_ut_datatypes;


END wms_ut_pkg;



/
