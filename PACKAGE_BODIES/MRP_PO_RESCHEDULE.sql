--------------------------------------------------------
--  DDL for Package Body MRP_PO_RESCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PO_RESCHEDULE" AS
/* $Header: MRPPOREB.pls 120.7.12010000.5 2009/10/30 20:27:38 harshsha ship $ */

Type CharTab is TABLE of varchar2(2);
Type LongCharTab is TABLE of varchar2(240);
Type NumTab IS TABLE of number;
Type DateTab IS TABLE of DATE;

l_debug     varchar2(30) := 'Y';
g_dblink    VARCHAR2(129);

g_po_numbers         po_tbl_varchar100;
g_po_header_ids      po_tbl_number;
g_po_line_ids        po_tbl_number;
g_line_location_ids  po_tbl_number;
g_distribution_ids   po_tbl_number;
g_qtys               po_tbl_number;
g_promise_dates      po_tbl_date;
g_uoms               po_tbl_varchar30;
g_operating_units    po_tbl_number;
g_current_rec        NUMBER := 1;
g_current_org_id     NUMBER := NULL;

l_dblink       VARCHAR2(129);

/********************************************************
PROCEDURE : log_message
********************************************************/

PROCEDURE log_message( p_user_info IN VARCHAR2) IS
BEGIN

       FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);

EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;

PROCEDURE debug_message( p_user_info IN VARCHAR2) IS
  fname utl_file.file_type ;
BEGIN
--   fname := utl_file.fopen('/sqlcom/log/mfgstrw','dttmp2','a');
--      utl_file.put(fname, p_user_info);
--      utl_file.fflush(fname);
--      utl_file.fclose(fname);

    IF l_debug = 'Y' THEN
       log_message(p_user_info);
       --INSERT INTO dt_debug VALUES (p_user_info);
    END IF;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END debug_message;

PROCEDURE debug_number_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_number ) IS
   i NUMBER;
BEGIN
   debug_message(p_msg || ' number of changes: ' || p_tbl.COUNT() );
   FOR i IN 1..p_tbl.COUNT() LOOP
      debug_message(p_msg || p_tbl(i));
   END LOOP;
END debug_number_tbl;

PROCEDURE debug_date_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_date ) IS
   i NUMBER;
BEGIN
   debug_message(p_msg || ' number of changes: ' || p_tbl.COUNT() );
   FOR i IN 1..p_tbl.COUNT() LOOP
      debug_message(p_msg || p_tbl(i));
   END LOOP;
END debug_date_tbl;

PROCEDURE debug_varchar30_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_varchar30 ) IS
   i NUMBER;
BEGIN
   debug_message(p_msg || ' number of changes: ' || p_tbl.COUNT() );
   FOR i IN 1..p_tbl.COUNT() LOOP
      debug_message(p_msg || p_tbl(i));
   END LOOP;
END debug_varchar30_tbl;

/**********************************************************************
 Initialization procedures
 **********************************************************************/

/***********************************************************************
 *
 * Move data to global temporary table if this goes across a dblink
 *
 ***********************************************************************/
PROCEDURE transfer_to_temp_table (
   p_dblink       IN VARCHAR2,
   p_instance_id  IN NUMBER,
   p_batch_id     IN NUMBER
) IS
   l_sql_stmt     VARCHAR2(2000);
BEGIN

   IF( p_dblink IS NULL ) THEN
      debug_message( 'No dblink specified in call to transfer_to_temp_table');
      RETURN;
   END IF;

   l_sql_stmt :=
   'INSERT INTO mrp_po_reschedule_gt (
        purchase_order_id
      , po_number
      , line_id
      , line_location_id
      , distribution_id
      , quantity
      , need_by_date
      , action
      , uom
      , operating_unit
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
   ) (
   SELECT
        po_header_id
      , po_number
      , po_line_id
      , po_line_location_id
      , po_distribution_id
      , po_quantity
      , new_need_by_date
      , action
      , uom
      , operating_unit
      , fnd_global.user_id
      , Sysdate
      , fnd_global.user_id
      , Sysdate
      , fnd_global.user_id
   FROM msc_purchase_order_interface' || p_dblink ||
 ' WHERE sr_instance_id = :p_instance_id
     AND batch_id = :p_batch_id)';

   execute immediate l_sql_stmt
     using IN p_instance_id,
           IN p_batch_id;

EXCEPTION
   WHEN OTHERS THEN
      DEBUG_MESSAGE('Error in transfer_to_temp_table : Err Others');
      DEBUG_MESSAGE(SQLERRM);
      RAISE;

END transfer_to_temp_table;

PROCEDURE init_instance(p_user_name IN VARCHAR2,
                        p_resp_name IN VARCHAR2
) IS
   l_user_id NUMBER;
   l_appl_id NUMBER;
   l_resp_id NUMBER;
   lv_log_msg           varchar2(500);
BEGIN

       /* if user_id = -1, it means this procedure is called from a
       remote database */
    IF FND_GLOBAL.USER_ID = -1 THEN

       BEGIN

          SELECT USER_ID
            INTO l_user_id
            FROM FND_USER
           WHERE USER_NAME = p_user_name;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              raise_application_error (-20001, 'NO_USER_DEFINED');
        END;

        IF MRP_CL_FUNCTION.validateUser(l_user_id,MSC_UTIL.TASK_RELEASE,lv_log_msg) THEN
            MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_RELEASE,
                                           l_user_id,
                                           -1, --l_resp_id,
                                           -1 --l_application_id
                                           );
        ELSE
            --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
            raise_application_error (-20001, lv_log_msg);
        END IF;
    ELSE
       l_appl_id := 724;

       SELECT USER_ID
         INTO l_user_id
         FROM FND_USER
         WHERE USER_NAME = p_user_name;

       SELECT responsibility_id
         INTO l_resp_id
         FROM FND_responsibility_vl
         WHERE responsibility_name = p_resp_name
         AND application_Id = l_appl_id;

       fnd_global.apps_initialize(l_user_id, l_resp_id, l_appl_id);

    END IF;

END init_instance;

PROCEDURE cleanup_destination( p_batch_id IN NUMBER,
                               p_dblink   IN VARCHAR2 )
IS
   l_sql_stmt VARCHAR2(1000);
BEGIN

   l_sql_stmt := 'DELETE FROM msc_purchase_order_interface'||p_dblink||
                 ' WHERE batch_id = :p_batch_id';
   execute immediate l_sql_stmt using
     IN p_batch_id;
END cleanup_destination;

/***********************************************************************
 *
 * populate the global pl/sql tables with the POs that need to be rescheduled
 * sorted by purchase_order_id
 *
 * For cross database releases, first copy the planning database info
 * to a temp tbl on the ERP instance to utilize bulk sql
 *
 ***********************************************************************/

PROCEDURE init(
   p_batch_id    IN NUMBER,
   p_instance_id IN NUMBER,
   p_instance_code IN varchar2 ,
   p_dblink IN varchar2
) IS

CURSOR c_dblink(p_instance_id NUMBER, p_instance_code varchar2,p_dblink varchar2 ) IS
   select DECODE( A2M_DBLINK,
                   NULL, NULL,
                   '@'||A2M_DBLINK),
          INSTANCE_ID
     from MRP_AP_APPS_INSTANCES_ALL
    where ALLOW_RELEASE_FLAG=1
    and instance_id = p_instance_id
    and instance_code=p_instance_code
    and nvl(A2M_DBLINK,'-1') = nvl(p_dblink,'-1');


l_instance_id  NUMBER;

BEGIN

   OPEN c_dblink(p_instance_id,p_instance_code,p_dblink);
   FETCH c_dblink INTO l_dblink, l_instance_id;
   IF( c_dblink%notfound ) THEN
      debug_message('Could not find instance that is valid for release');
      RAISE no_data_found;
   END IF;

   debug_message('p_instance_id' || p_instance_id ||'p_instance_code ' || p_instance_code);
   debug_message('p_dblink' || p_dblink ||'l_dblink ' || l_dblink);

   g_dblink := l_dblink;
   g_current_rec := 1;
   g_po_header_ids     := po_tbl_number();
   g_line_location_ids := po_tbl_number();
   g_distribution_ids  := po_tbl_number();
   g_qtys            := po_tbl_number();
   g_promise_dates   := po_tbl_date();
   g_uoms            := po_tbl_varchar30();
   g_operating_units := po_tbl_number();

   IF( l_dblink IS NOT NULL ) THEN
      debug_message('Get data from dblink ' || l_dblink);
      transfer_to_temp_table( l_dblink, l_instance_id, p_batch_id );

      SELECT i.purchase_order_id
           , i.line_id
           , i.po_number
           , i.line_location_id
           , i.distribution_id
           , i.quantity
           , i.need_by_date
           , u.unit_of_measure
           , i.operating_unit
      bulk collect into
             g_po_header_ids
           , g_po_line_ids
           , g_po_numbers
           , g_line_location_ids
           , g_distribution_ids
           , g_qtys
           , g_promise_dates
           , g_uoms
           , g_operating_units
      FROM   mrp_po_reschedule_gt i,
             mtl_uom_conversions u
      WHERE  i.uom = u.uom_code
        AND  u.inventory_item_id = 0
        AND  i.action <> 2
      ORDER BY i.purchase_order_id;
   ELSE
      debug_message('Data is local');
      SELECT i.po_header_id
           , i.po_line_id
           , i.po_number
           , i.po_line_location_id
           , i.po_distribution_id
           , i.po_quantity
           , i.new_need_by_date
           , u.unit_of_measure
           , i.operating_unit
      bulk collect into
             g_po_header_ids
           , g_po_line_ids
           , g_po_numbers
           , g_line_location_ids
           , g_distribution_ids
           , g_qtys
           , g_promise_dates
           , g_uoms
           , g_operating_units
      FROM   msc_purchase_order_interface i,
             msc_uom_conversions u
      WHERE  i.sr_instance_id = l_instance_id
        AND  i.uom = u.uom_code
        AND  u.inventory_item_id = 0
        AND  i.batch_id = p_batch_id
        AND  i.action <> 2
      ORDER BY i.po_header_id;
   END IF;
   close c_dblink;

   debug_message('Lines loaded in init: ' || SQL%rowcount);
EXCEPTION
   WHEN OTHERS THEN
      IF c_dblink%ISOPEN THEN
         close c_dblink;
      END IF ;
      LOG_MESSAGE('Error in init : Err Others');
      LOG_MESSAGE(SQLERRM);
      RAISE;

END init;

/**********************************************************************
 *Functions/procedures used during processing
 **********************************************************************/

FUNCTION same_record(idx1 IN NUMBER, idx2 IN NUMBER)
RETURN BOOLEAN IS
   l_same BOOLEAN;
BEGIN

   l_same := TRUE;
   IF( g_po_header_ids(idx1) <> g_po_header_ids(idx2) ) THEN
      l_same := FALSE;
   END IF;

   IF( l_same = TRUE AND
       Nvl(g_po_line_ids(idx1), -1) <> Nvl(g_po_line_ids(idx2), -1) ) THEN
      l_same := FALSE;
   END IF;

   IF( l_same = TRUE AND
       Nvl(g_line_location_ids(idx1), -1) <> Nvl(g_line_location_ids(idx2), -1) )
   THEN
      l_same := FALSE;
   END IF;

   IF( l_same ) THEN
     debug_message('Compare recs: ' || idx1 || ' ' || idx2 || ': TRUE');
   ELSE
      debug_message('Compare recs: ' || idx1 || ' ' || idx2 || ': TRUE');
   END IF;

   RETURN l_same;
END same_record;

/***********************************************************************
 *
 * Take the next PO we want to process from  the global variables
 * and put it into the output tables
 *
 * Currently each record corresponds to a po. Not a shipment or distribution
 *
 ***********************************************************************/
FUNCTION get_next_record (
   x_po_header_id       OUT nocopy NUMBER,
   x_po_number          OUT nocopy VARCHAR2,
   x_operating_unit     OUT nocopy NUMBER,
   x_po_line_ids        OUT nocopy po_tbl_number,
   x_line_location_ids  OUT nocopy po_tbl_number,
   x_distribution_ids   OUT nocopy po_tbl_number,
   x_qtys               OUT nocopy po_tbl_number,
   x_promise_dates      OUT nocopy po_tbl_date,
   x_uoms               OUT nocopy po_tbl_varchar30
) RETURN BOOLEAN IS
/*
   CURSOR c_po_header (p_po_number VARCHAR2) IS
      select  po_header_id
      from    po_headers
      where   segment1 = p_PO_NUMBER
      and     type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED');
*/
   DISTRIBUTION_LVL   CONSTANT NUMBER := 0;
   SHIPMENT_LVL       CONSTANT NUMBER := 1;
   PO_LINE_LVL        CONSTANT NUMBER := 2;

   l_po_number        VARCHAR2(100);
   l_starting_rec     NUMBER;
   shipment_ctr       NUMBER := 1;
   distribution_ctr   NUMBER := 1;
   po_line_ctr        NUMBER := 1;
   l_record_lvl       NUMBER := 0;
BEGIN

   IF g_current_rec > g_po_header_ids.COUNT() THEN
      RETURN FALSE;
   END IF;

   l_starting_rec   := g_current_rec;
   x_po_header_id   := g_po_header_ids(g_current_rec);
   x_po_number      := g_po_numbers(g_current_rec);
   x_operating_unit := g_operating_units(g_current_rec);

   /***********
   WHILE( x_po_header_id IS NULL ) LOOP

      l_po_number := g_po_numbers(g_current_rec);

      OPEN c_po_header(l_po_number);
      FETCH po_header_csr
        INTO x_po_number;
      IF( po_header_csr%notfound ) THEN
         -- order number is invalid. go to next record
         g_current_rec := g_current_rec + 1;
      END IF;
      CLOSE po_header_csr;

   END LOOP;
     ***********/

   x_po_line_ids        := po_tbl_number();
   x_line_location_ids  := po_tbl_number();
   x_distribution_ids   := po_tbl_number();
   x_qtys               := po_tbl_number();
   x_promise_dates      := po_tbl_date();
   x_uoms               := po_tbl_varchar30();

   IF( g_distribution_ids(l_starting_rec) IS NOT NULL ) THEN
      l_record_lvl := DISTRIBUTION_LVL;
   ELSIF( g_line_location_ids(l_starting_rec) IS NOT NULL ) THEN
      l_record_lvl := SHIPMENT_LVL;
   ELSIF( g_po_line_ids(l_starting_rec) IS NOT NULL ) THEN
      l_record_lvl := PO_LINE_LVL;
   ELSE
      debug_message('GET_NEXT_RECORD: ERROR in setting record_lvl');
      RETURN FALSE;
   END IF;

   debug_message( 'get_next_record: starting rec: ' || l_starting_rec );
   debug_message( '  tot rec: ' || g_po_header_ids.COUNT() );
   debug_message( '  header_id: ' || x_po_header_id );
   WHILE( g_current_rec <= g_po_header_ids.COUNT() AND
          same_record(l_starting_rec, g_current_rec) )
   LOOP

      -- add some better logic here

      IF( l_record_lvl = DISTRIBUTION_LVL ) THEN
         x_distribution_ids.extend();
         x_qtys.extend();
         x_uoms.extend();
         x_distribution_ids(distribution_ctr) := g_distribution_ids(g_current_rec);
         x_qtys(distribution_ctr)             := g_qtys(g_current_rec);
         x_uoms(distribution_ctr)             := g_uoms(g_current_rec);
         distribution_ctr := distribution_ctr + 1;
         IF( shipment_ctr = 1 OR
             x_line_location_ids( shipment_ctr - 1 ) <> g_line_location_ids(g_current_rec) )
         THEN
             x_promise_dates.extend();
             x_promise_dates(shipment_ctr)     := g_promise_dates(g_current_rec);

             x_line_location_ids.extend();
             x_line_location_ids(shipment_ctr) := g_line_location_ids(g_current_rec);
             shipment_ctr := shipment_ctr + 1;
         ELSE
            debug_message('Skipping duplicate shipment for distribution lvl change');
            IF( g_promise_dates(g_current_rec) <> x_promise_dates(shipment_ctr - 1) ) THEN
               debug_message('Mismatched dates for shipment.');
               debug_message('first date:   ' || To_char(x_promise_dates(shipment_ctr - 1), 'DD-MON-YYYY HH24:MI:SS'));
               debug_message('current date: ' || To_char(g_promise_dates(g_current_rec) , 'DD-MON-YYYY HH24:MI:SS'));
            END IF;

         END IF;
      ELSIF( l_record_lvl = SHIPMENT_LVL ) THEN
             x_promise_dates.extend();
             x_qtys.extend();
             x_uoms.extend();

             x_qtys(shipment_ctr)              := g_qtys(g_current_rec);
             x_uoms(shipment_ctr)              := g_uoms(g_current_rec);
             x_promise_dates(shipment_ctr)     := g_promise_dates(g_current_rec);

             x_line_location_ids.extend();
             x_line_location_ids(shipment_ctr) := g_line_location_ids(g_current_rec);
             shipment_ctr := shipment_ctr + 1;
      ELSE
            x_po_line_ids.extend();
            x_promise_dates.extend();
            x_qtys.extend();
            x_uoms.extend();
            x_po_line_ids(po_line_ctr)   := g_po_line_ids(g_current_rec);
            x_promise_dates(po_line_ctr) := g_promise_dates(g_current_rec);
            x_qtys(po_line_ctr)          := g_qtys(g_current_rec);
            x_uoms(po_line_ctr)          := g_uoms(g_current_rec);
            po_line_ctr := po_line_ctr + 1;
            debug_message('Adding po_line change: ' || g_current_rec);
      END IF;

      g_current_rec := g_current_rec + 1;
   END LOOP;
   debug_message( '  ending rec: ' || g_current_rec );

   debug_number_tbl('shipment: ',    x_line_location_ids);
   debug_number_tbl('dstribution: ', x_distribution_ids);
   debug_number_tbl('po_line: ',     x_po_line_ids);
   debug_number_tbl('qty: ',    x_qtys);
   debug_varchar30_tbl('uom: ', x_uoms);
   debug_date_tbl('date: ',     x_promise_dates);

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err Others');
      LOG_MESSAGE(SQLERRM);
      RAISE;
END get_next_record;



PROCEDURE change_operating_unit( p_org_id IN NUMBER )
IS

CURSOR c_security (l_org_id  number,
                   l_user_id number,
                   l_appl_id number) IS
SELECT  level_value
FROM  fnd_profile_options opt,
      fnd_profile_option_values opt_vals,
      fnd_user_resp_groups user_resp
WHERE opt.profile_option_name = 'ORG_ID'
      AND   opt.profile_option_id = opt_vals.profile_option_id
      AND   opt_vals.profile_option_value = to_char(l_org_id)
      AND   opt_vals.level_id = 10003  -- responsibility level
      AND   user_resp.user_id = l_user_id
      AND   user_resp.responsibility_id = opt_vals.level_value
      AND   user_resp.responsibility_application_id = l_appl_id
      AND   rownum = 1;

l_user_id         NUMBER;
l_appl_id         NUMBER;
l_resp_id         NUMBER;

BEGIN
   IF( g_current_org_id = p_org_id ) THEN
      RETURN;
   END IF;

   l_user_id := fnd_global.user_id();
   l_appl_id := 724;

   OPEN c_security( p_org_id,
                    l_user_id,
                    l_appl_id );
   FETCH c_security INTO l_resp_id;
   IF c_security%notfound THEN
      debug_message( 'Could not find appropriate resp for operating unit: ' || p_org_id ||
                     ' and user: ' || l_user_id );
   ELSE
      fnd_global.apps_initialize(l_user_id, l_resp_id, l_appl_id);
      g_current_org_id := p_org_id;
   END IF;
   CLOSE c_security;

EXCEPTION
   WHEN OTHERS THEN
      LOG_MESSAGE('Error in change_operating_unit : Err Others');
      LOG_MESSAGE(SQLERRM);
      RAISE;

END change_operating_unit;

PROCEDURE msc_cancel_po(
   errbuf        OUT NOCOPY VARCHAR2,
   retcode       OUT NOCOPY VARCHAR2,
   p_batch_id    IN         NUMBER,
   P_instance_id IN NUMBER,
   p_instance_code IN varchar2,
   p_dblink IN varchar2
) IS
v_old_need_by_date dateTab;
 v_new_need_by_date dateTab;
 v_po_header_id  numTab;
 v_po_line_id  numTab;
 v_po_shipment_num number; /*v_po_location_id  number;*/
 v_po_number LongCharTab;

 /* bug 8276422 */
 l_original_org_context  VARCHAR2(10);
l_document_org_id       NUMBER;
l_release_number NUMBER;
l_po_line_id NUMBER;
l_pos_lbrace NUMBER;
l_pos_rbrace NUMBER;
x_return_status VARCHAR2(1);
l_po_operating_unit NUMBER; /*end bug 8276422 */

 first_left_pare_pos number;
first_right_pare_pos number;
second_left_pare_pos number;
second_right_pare_pos number;
third_left_pare_pos number;
third_right_pare_pos number;
v_release_num number;
l_doc_type VARCHAR2(30);
l_doc_subtype VARCHAR2(30);

sql_stmt varchar2(2000);

TYPE type_cursor IS REF CURSOR;
 po_cursor type_cursor;

BEGIN

mo_global.init('PO');  -- MOAC Change

   IF( l_dblink IS NOT NULL ) THEN
     sql_stmt:=
       ' select old_need_by_date,'|| --?????
              ' new_need_by_date,'||
              ' po_header_id,'||
              ' po_line_id,'||
              ' po_number'||
     ' from mrp_po_reschedule_gt ' ||
     ' where sr_instance_id = '||p_instance_id||
       ' and batch_id ='||p_batch_id ||
       ' and action = 2' ||
       ' order by po_number ';
   ELSE
     sql_stmt:=
       ' select old_need_by_date,'||
              ' new_need_by_date,'||
              ' po_header_id,'||
              ' po_line_id,'||
              ' po_number'||
     ' from msc_purchase_order_interface' ||
     ' where sr_instance_id = '||p_instance_id||
       ' and batch_id ='||p_batch_id ||
       ' and action = 2' ||
       ' order by po_number ';

   END IF;

  LOG_MESSAGE('opening Cursor sql_stmt : '|| sql_stmt);
  OPEN po_cursor FOR sql_stmt;
  FETCH po_cursor BULK COLLECT INTO v_old_need_by_date,
                                    v_new_need_by_date,
                                    v_po_header_id,
                                    v_po_line_id,
                                    v_po_number;
  CLOSE po_cursor;
  LOG_MESSAGE('Closed Cursor  ');
  FOR i in 1..nvl(v_po_line_id.LAST, 0) LOOP
  LOG_MESSAGE('Inside Loop  ');

  /* in R12, order number(release number)(line number)(shipment number),
   but release number could be empty,
   in 11.5.10 and prior,
    order number(release number)(shipment number) -- blanket PO or
    order number(shipment number)  -- standard PO                   */

       first_left_pare_pos := instr(v_po_number(i), '(');
       second_left_pare_pos := instr(v_po_number(i), '(',1,2);
       third_left_pare_pos := instr(v_po_number(i), '(',1,3);
       first_right_pare_pos := instr(v_po_number(i), ')');
       third_right_pare_pos := instr(v_po_number(i), ')', 1,3);
       v_po_shipment_num := substr(v_po_number(i),
                third_left_pare_pos+1,third_right_pare_pos -
                   third_left_pare_pos -1);

       begin
          v_release_num :=  substr(v_po_number(i),
                first_left_pare_pos+1,first_right_pare_pos -
                   first_left_pare_pos -1);
       exception when others then
              v_release_num :=null;
       end;

       if v_release_num is null then
            l_doc_type := 'PO';
            l_doc_subtype := 'STANDARD';
            v_po_number(i) := substr(v_po_number(i), 1,first_left_pare_pos -1);
       else
            l_doc_type := 'RELEASE';
            l_doc_subtype := 'BLANKET';
            v_po_number(i) := substr(v_po_number(i),1,second_left_pare_pos -1);
       end if;

/* bug 8276422 */
-- Remember the current org context.
              l_original_org_context := SUBSTRB(USERENV('CLIENT_INFO'),1,10);

  -- Before calling the PO Cancel API (which uses org-striped views),
              -- We need to retrieve and set the org context to the document's operating unit.
              SELECT org_id
              INTO l_po_operating_unit
              FROM po_headers_all
              WHERE po_header_id = v_po_header_id(i);

	          mo_global.set_policy_context('S',l_po_operating_unit);  -- MOAC Change

              l_po_line_id := v_po_line_id(i);
              IF l_doc_type = 'RELEASE' THEN
                  l_pos_lbrace := instr(v_po_number(i),'(');
                  l_pos_rbrace := instr(v_po_number(i),')');
                  l_release_number := substr(v_po_number(i),l_pos_lbrace+1,(l_pos_rbrace -(l_pos_lbrace+1)));
                  l_po_line_id := NULL;
              END IF;

   LOG_MESSAGE('Calling API  PO_Document_Control_GRP.control_document with parameters'||
				    ' v_po_header_id(i) '|| v_po_header_id(i)||
					' v_po_line_id(i) '||v_po_line_id(i)||
				    ' v_po_number(i) '||v_po_number(i)||
               	    ' v_po_shipment_num '||v_po_shipment_num||
					' l_doc_type '||l_doc_type||
				    ' l_doc_subtype '||	l_doc_subtype||
					' v_release_num '||v_release_num);


   --call the Cancel API

         PO_Document_Control_GRP.control_document(
                  p_api_version  => 1.0,
                  p_init_msg_list => FND_API.G_TRUE,
                  p_commit     => FND_API.G_TRUE,
                  x_return_status  => x_return_status,
                  p_doc_type    =>  l_doc_type,
                  p_doc_subtype  => l_doc_subtype,
                  p_doc_id    => v_po_header_id(i),
                  p_doc_num    => null,
                  p_release_id  => null,
                  p_release_num  => l_release_number,
                  p_doc_line_id  => l_po_line_id,
                  p_doc_line_num  => NULL,
                  p_doc_line_loc_id  => NULL,
                  p_doc_shipment_num => v_po_shipment_num ,
                  p_source     => NULL,
                  p_action      => 'CANCEL',
                  p_action_date   => SYSDATE,
                  p_cancel_reason  => null,
                  p_cancel_reqs_flag  => null,
                  p_print_flag     => null,
                  p_note_to_vendor  =>null);

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          	  retcode := 1;
	          LOG_MESSAGE('x_return_status returned by API PO_Document_Control_GRP.control_document = '
						||x_return_status);
	          LOG_MESSAGE('PO cancellation was not successful');
 		  else
   	          LOG_MESSAGE('x_return_status returned by API PO_Document_Control_GRP.control_document = '
						||x_return_status);
          	  LOG_MESSAGE('PO cancellation successful');
          end if;
/*bug 8276422*/
       /*LOG_MESSAGE('Calling API :'||v_po_header_id(i));
               mrp_cancel_po.cancel_po_program(v_po_header_id(i), v_po_line_id(i),
                                           v_po_number(i), v_po_location_id,
                                           l_doc_type , l_doc_subtype);*/
  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      debug_MESSAGE('Error in Canecl PO : Err OTHERS');
      debug_MESSAGE(SQLERRM);
      retcode := 1;
END msc_cancel_po;

/**********************************************************
 *
 * Procedure:  MSC_RESCHED_PO
 *
 * Main Procedure. Structure is as follows
 * 1) initialize global variables that store all the pos
 *    that need to be rescheduled
 * 2) while there are still pos left, get the next po that
 *    needs to be rescheduled
 * 3) reschedule the PO by calling the bulk change apis
 *
 ***********************************************************/
PROCEDURE msc_resched_po(
   errbuf        OUT NOCOPY VARCHAR2,
   retcode       OUT NOCOPY VARCHAR2,
   p_batch_id    IN         NUMBER,
   P_instance_id IN NUMBER,
   p_instance_code IN varchar2,
   p_dblink IN varchar2
) IS
l_instance_id NUMBER;


l_po_header_id     NUMBER;
l_po_number        VARCHAR2(100); --bug 7144230
l_operating_unit  NUMBER;
l_po_release_id   NUMBER; --bug 7144230
l_po_release_num   varchar2(100); --bug 7144230
l_po_release_number   NUMBER :=NULL; --bug 7144230

l_po_return_status   VARCHAR2(1);
l_po_api_errors      PO_API_ERRORS_REC_TYPE;

l_po_line_ids        po_tbl_number;
l_line_location_ids  po_tbl_number;
l_distribution_ids   po_tbl_number;
l_qtys               po_tbl_number;
l_promise_dates      po_tbl_date;
l_uoms               po_tbl_varchar30;

l_po_line_changes      po_lines_rec_type;
l_shipment_changes     PO_SHIPMENTS_REC_TYPE;
l_distribution_changes PO_DISTRIBUTIONS_REC_TYPE;
l_changes              PO_CHANGES_REC_TYPE;
l_po_operating_unit     NUMBER;



i                  NUMBER;
BEGIN

   init(p_batch_id,p_instance_id ,p_instance_code  , p_dblink );

   while get_next_record(x_po_header_id      => l_po_header_id,
                         x_po_number         => l_po_number,
                         x_operating_unit    => l_operating_unit,
                         x_po_line_ids       => l_po_line_ids,
                         x_line_location_ids => l_line_location_ids,
                         x_distribution_ids  => l_distribution_ids,
                         x_qtys              => l_qtys,
                         x_promise_dates     => l_promise_dates,
                         x_uoms              => l_uoms)
   loop

        begin
           SAVEPOINT before_change;

           select org_id
           into l_po_operating_unit
           from po_headers_all
           where PO_HEADER_ID= l_po_header_id;

           change_operating_unit( l_po_operating_unit );

           mo_global.init('PO');  -- MOAC Change
           mo_global.set_policy_context('S',l_po_operating_unit);  -- MOAC Change

           debug_message('Changing to operating unit: ' || l_po_operating_unit );

           IF( l_distribution_ids.COUNT() > 0 ) THEN
               debug_message('Creating distribution and shipment changes');
               l_distribution_changes := PO_DISTRIBUTIONS_REC_TYPE.create_object (
                                             p_po_distribution_id => l_distribution_ids,
                                             p_request_unit_of_measure => l_uoms,
                                             p_quantity_ordered => l_qtys);
               l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
                                         p_po_line_location_id => l_line_location_ids,
                                         p_need_by_date    => l_promise_dates);
           ELSIF( l_line_location_ids.COUNT() > 0 ) THEN
               debug_message('Creating shipment changes');
               l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
                                         p_po_line_location_id => l_line_location_ids,
                                         p_quantity            => l_qtys,
                                         p_request_unit_of_measure => l_uoms,
                                         p_need_by_date    => l_promise_dates);
           ELSE
              debug_message('Creating po line changes');
              l_po_line_changes := po_lines_rec_type.create_object(
                                       p_po_line_id => l_po_line_ids,
                                       p_quantity => l_qtys,
                                       p_request_unit_of_measure => l_uoms,
                                       p_start_date => l_promise_dates );
           END IF;

           debug_message('Header id: ' || l_po_header_id );
           -- Create a change object for the document with the line and
           -- shipment changes.
           /* We have to obtain the po_release_id in case of blanket PO
             The release Id is buried in the column order_number in MSC_SUPPLIES which comes back to MSC_PURCHASE_ORDER_INTERFACE  bug 7144230*/
           select substr(l_po_number,
                instr(l_po_number,'(',1,1)+1,
                instr(l_po_number,')',1,1) - instr(l_po_number,'(',1,1) -1)
           into l_po_release_num
           from dual;
           if (l_po_release_num = ''  or  l_po_release_num = ' ') then
               l_po_release_num  := NULL;
           else
               l_po_release_number := to_number(l_po_release_num);
           end if;
           debug_message('Release num ' || l_po_release_number );

           begin
             select po_release_id
             into l_po_release_id
             from po_releases_all
             where po_header_id = l_po_header_id
             and release_num  = l_po_release_number ;

           exception
           when NO_DATA_FOUND then
             l_po_release_id := NULL;
           end;

           debug_message('Release id: ' || l_po_release_id );
           l_changes := PO_CHANGES_REC_TYPE.create_object (p_po_header_id => l_po_header_id,
                                                           p_po_release_id => l_po_release_id,
                                                           p_line_changes => l_po_line_changes,
                                                           p_shipment_changes => l_shipment_changes,
                                                           p_distribution_changes => l_distribution_changes
                                                           );

           debug_message('Updating document...');
           -- Call the PO Change API.
           PO_DOCUMENT_UPDATE_GRP.update_document (p_api_version => 1.0,
                                                   p_init_msg_list => FND_API.G_TRUE,
                                                   x_return_status => l_po_return_status,
                                                   p_changes => l_changes,
                                                   p_run_submission_checks => FND_API.G_TRUE,
                                                   p_launch_approvals_flag => FND_API.G_TRUE,
                                                   p_buyer_id => NULL,
                                                   p_update_source => NULL,
                                                   p_override_date => NULL,
                                                   x_api_errors => l_po_api_errors
                                                   );

           debug_message('Return status: ' || l_po_return_status);

           IF (l_po_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
              -- handle error
              FOR i IN 1..l_po_api_errors.message_text.COUNT LOOP
                 debug_message( l_po_api_errors.message_text(i) );
              END LOOP;
              retcode := MSC_UTIL.G_WARNING;
              ROLLBACK TO SAVEPOINT before_change;
           END IF;
        EXCEPTION
           WHEN OTHERS THEN
              debug_MESSAGE('Error in updating document : Err OTHERS');
              debug_MESSAGE(SQLERRM);
              ROLLBACK TO SAVEPOINT before_change;
        END;
    end loop;

    debug_message( 'Calling msc_cancel_po');
    msc_cancel_po(errbuf,
                  retcode,
                  p_batch_id,
                  P_instance_id,
                  p_instance_code,
                  p_dblink);

    cleanup_destination(p_batch_id, g_dblink);
EXCEPTION
   WHEN OTHERS THEN
      debug_MESSAGE('Error in MSC_RESCHED_PO : Err OTHERS');
      debug_MESSAGE(SQLERRM);
      retcode := MSC_UTIL.G_WARNING;

END msc_resched_po;

/***********************************************************************
 *
 * Procedure to launch the po reschedule concurrent program
 *
 ***********************************************************************/
PROCEDURE launch_reschedule_po(
   p_user_name   IN VARCHAR2,
   p_resp_name   IN VARCHAR2,
   p_batch_id    IN NUMBER,
   p_instance_id IN NUMBER,
   p_instance_code IN varchar2,
   p_dblink IN varchar2,
   x_req_id      OUT NOCOPY NUMBER
) IS

l_result  BOOLEAN;

errbuf VARCHAR2(10000);
retcode VARCHAR2(10000);
msg VARCHAR2(10000);
BEGIN

   init_instance(p_user_name, p_resp_name);
   l_result := fnd_request.set_mode(TRUE);

   x_req_id := FND_REQUEST.SUBMIT_REQUEST('MSC',
                                          'MSC_PO_RESCHEDULE',
                                          NULL,
                                          null,
                                          FALSE, p_batch_id,p_instance_id,p_instance_code,p_dblink);


   IF nvl(x_req_id,0) = 0 THEN
      DEBUG_MESSAGE('Error in MSC_PO_RESCHEDULE');
      fnd_message.retrieve(msg);
      debug_message(msg);
    ELSE
      DEBUG_MESSAGE('Concurrent Request ID For PO Reschedule : ' || x_req_id);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_req_id := 0;
      DEBUG_MESSAGE('Error in launch_po_reschedule : Err OTHERS');
      RAISE;

END launch_reschedule_po;

END mrp_po_reschedule;

/
