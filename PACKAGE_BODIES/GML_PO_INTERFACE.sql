--------------------------------------------------------
--  DDL for Package Body GML_PO_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_INTERFACE" AS
/* $Header: GMLIPOIB.pls 115.23 2002/03/01 12:46:02 pkm ship      $ */

  /*##########################################################################
  #
  #  PROC
  #
  #     insert          Insert Data into the  PO INTERFACE Table
  #
  #  DESCRIPTION
  #
  #      This procedure inserts data into the Oracle  Interface Table.
  #
  #
  # MODIFICATION HISTORY
  #
  #  08-OCT-97      Ravi Dasani , Rajeshwari Chellam       Created.
  #  11-MAY-98      Tony Ricci changes for GEMMS 5.0 database changes
  #  07-JUL-98      Tony Ricci changes for GEMMS 5.0 nullable columns
  #  11/10/98       T.Ricci added shipper_code_cur to retreive correct
  #                 shipper_code 4 char value from op_ship_mst
  #  11/11/98       T.Ricci added fob_code_cur to retreive correct
  #                 fob_code 4 char value from op_fobc_mst
  #  12/24/98       added defaults for who columns in cpg_oragems_mapping
  #  05/13/99       T.Ricci removed checking of inventory_item_flag and
  #                 replaced with call to check_opm_item
  #
  ## #######################################################################*/
PROCEDURE insert_rec
( p_po_header_id              IN     NUMBER,
  p_po_line_id                IN     NUMBER,
  p_po_line_location_id       IN     NUMBER,
  p_quantity                  IN     NUMBER,
  p_need_by_date              IN     DATE,
  p_promised_date             IN     DATE,
  p_last_accept_date          IN     DATE,
  p_po_release_id             IN     NUMBER,
  p_cancel_flag               IN     VARCHAR2,
  p_closed_code               IN     VARCHAR2,
  p_source_shipment_id        IN     NUMBER,
  p_close_trig_call           IN     VARCHAR2,
  p_price_override            IN     NUMBER,
  p_ship_to_location_id       IN     NUMBER,
  p_shipment_num              IN     NUMBER
) IS

/* Definitions for variables that are derived from columns of
   po_headers_all table
   T. Ricci 5/11/98 added v_created_by, v_last_updated_by, v_last_update_login
   for GEMMS 5.0 who columns */

/* T.Ricci 10/15/98 added v_terms_name for terms code fix for OPM 11.0
   T.Ricci 11/10/98 added v_shipper_code for OPM 11.0
   T.Ricci 11/11/98 added v_fob_code for OPM 11.0*/
  v_po_no                 PO_HEADERS_ALL.SEGMENT1%TYPE;
  v_old_po_no             PO_HEADERS_ALL.SEGMENT1%TYPE;
/* HW BUG#:1107267 - new variable to hold rate */
  v_exchange_rate         PO_HEADERS_ALL.RATE%TYPE;
  v_type_lookup_code      PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
  v_last_update_date      PO_HEADERS_ALL.LAST_UPDATE_DATE%TYPE;
  v_creation_date         PO_HEADERS_ALL.CREATION_DATE%TYPE;
  v_print_count           PO_HEADERS_ALL.PRINT_COUNT%TYPE;
  v_revision_num          PO_HEADERS_ALL.REVISION_NUM%TYPE;
  v_printed_date          PO_HEADERS_ALL.PRINTED_DATE%TYPE;
  v_approved_date         PO_HEADERS_ALL.APPROVED_DATE%TYPE;
  v_agent_id              PO_HEADERS_ALL.AGENT_ID%TYPE;
  v_currency_code         PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
  v_bill_to_location_id   PO_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE;
  v_terms_id              PO_HEADERS_ALL.TERMS_ID%TYPE;
  v_terms_name            AP_TERMS.NAME%TYPE;
  v_org_id                PO_HEADERS_ALL.ORG_ID%TYPE;
  v_start_date            PO_HEADERS_ALL.START_DATE%TYPE;
  v_end_date              PO_HEADERS_ALL.END_DATE%TYPE;
  v_terms_code            PO_HEADERS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE;
  v_gemms_orgn_code       VARCHAR2(4);
  v_opm_rel_orgn_code     VARCHAR2(4);
  v_blanket_total_amount  PO_HEADERS_ALL.BLANKET_TOTAL_AMOUNT%TYPE;
  v_created_by            PO_HEADERS_ALL.CREATED_BY%TYPE;
  v_last_updated_by       PO_HEADERS_ALL.LAST_UPDATED_BY%TYPE;
  v_last_update_login     PO_HEADERS_ALL.LAST_UPDATE_LOGIN%TYPE;
  v_opm_rel_exchg_rate    PO_HEADERS_ALL.RATE%TYPE; /* Bug 1427876 */

  v_shipper_code          OP_SHIP_MST.SHIPPER_CODE%TYPE;
  v_fob_code              OP_FOBC_MST.FOB_CODE%TYPE;
/** MC BUG# 1554088  **/
/** new variable to hold order um1. **/
  v_order_um1             SY_UOMS_MST.UM_CODE%TYPE;


/* Definitions for variables that are derived from columns of
   po_lines_all table*/

  v_item_id               PO_LINES_ALL.ITEM_ID%TYPE;
  v_unit_meas_lookup_code PO_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%TYPE;
  v_unit_price            PO_LINES_ALL.UNIT_PRICE%TYPE;
  v_qc_grade_wanted       VARCHAR2(4);

/* Definitions for variables that are derived from columns of
   po_releases_all table*/

  v_release_num           PO_RELEASES_ALL.RELEASE_NUM%TYPE;

/* Definitions for variables that are derived from columns of
   po_line_locations_all table*/

  v_quantity              PO_LINE_LOCATIONS_ALL.QUANTITY%TYPE;
  v_need_by_date          PO_LINE_LOCATIONS_ALL.NEED_BY_DATE%TYPE;
  v_promised_date         PO_LINE_LOCATIONS_ALL.PROMISED_DATE%TYPE;
  v_db_promised_date      PO_LINE_LOCATIONS_ALL.PROMISED_DATE%TYPE;
  v_last_accept_date      PO_LINE_LOCATIONS_ALL.LAST_ACCEPT_DATE%TYPE;
  v_po_release_id         PO_LINE_LOCATIONS_ALL.PO_RELEASE_ID%TYPE;
  v_cancel_flag           PO_LINE_LOCATIONS_ALL.CANCEL_FLAG%TYPE;
  v_closed_code           PO_LINE_LOCATIONS_ALL.CLOSED_CODE%TYPE;
  v_fob_lookup_code       PO_LINE_LOCATIONS_ALL.FOB_LOOKUP_CODE%TYPE;
  v_ship_via_lookup_code  PO_LINE_LOCATIONS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE;
  v_source_shipment_id    PO_LINE_LOCATIONS_ALL.SOURCE_SHIPMENT_ID%TYPE;
  v_freight_terms_lookup_code
                 PO_LINE_LOCATIONS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE;
  v_price_override        PO_LINE_LOCATIONS_ALL.PRICE_OVERRIDE%TYPE;
  v_ship_to_location_id   PO_LINE_LOCATIONS_ALL.SHIP_TO_LOCATION_ID%TYPE;
  v_shipment_num          PO_LINE_LOCATIONS_ALL.SHIPMENT_NUM%TYPE;

/* Bug# 1200791 Added by Preetam Bamb for warehouse changes.*/
  v_ship_to_organization_id  PO_LINE_LOCATIONS_ALL.SHIP_TO_ORGANIZATION_ID%TYPE;

  /* Miscellaneous variables */

/* H. Wahdani temp. variable to store SY$ZERODATE */
  bind_date               DATE;
  v_vendor_site_id        PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE;
  v_cancellation_code     VARCHAR2(4);
  v_location_code         IC_WHSE_MST.WHSE_CODE%TYPE ; /*Changed by Preetam for warehouse change HR_LOCATIONS.LOCATION_CODE%TYPE*/
  v_buyer_code            VARCHAR2(35);

  v_po_id                 number;
  v_line_id               number;
  v_item_desc             VARCHAR2(70);
  v_item_no               VARCHAR2(32);
  v_inventory_item_flag   VARCHAR2(1);

  opmitem		  NUMBER DEFAULT 0;

  err_num                 NUMBER;
  err_msg                 VARCHAR2(100);

  CURSOR c_checkpll_cur  ( p_po_header_id        IN VARCHAR2,
                           p_po_line_id          IN VARCHAR2,
                           p_po_line_location_id IN VARCHAR2
                         )
  IS
    SELECT *
    FROM   CPG_ORAGEMS_MAPPING
    WHERE  po_header_id        = p_po_header_id
    AND    po_line_id          = p_po_line_id
    AND    po_line_location_id = p_po_line_location_id
    FOR    UPDATE;

  r_checkpll_rec    c_checkpll_cur%ROWTYPE;

 /* Uday Phadtare B2038851 */
  CURSOR c_get_old_po_no  ( p_po_header_id        IN VARCHAR2
                          )
  IS
    SELECT po_no
    FROM   CPG_ORAGEMS_MAPPING
    WHERE  po_header_id        = p_po_header_id;

/*    Cursor to select buyer code */

  CURSOR buyer_code_cur
  IS
    SELECT upper(substrb(last_name ,1,35))
    FROM   per_people_f
    WHERE  person_id=v_agent_id;

/*     Cursor to select values from po_headers_all
   T. Ricci 5/11/98 added created_by, last_updated_by, last_update_login
   for GEMMS 5.0 who columns */

  CURSOR hdr_vars_cur
  IS
    SELECT segment1,                   type_lookup_code,
           currency_code,              agent_id,        print_count,
           revision_num,               printed_date,    approved_date,
           terms_id,                   vendor_site_id,
           creation_date,              last_update_date,
           start_date,                 end_date ,
	   fob_lookup_code,            ship_via_lookup_code,
	   freight_terms_lookup_code, substrb(attribute15,1,4) gemms_orgn_code,
	   blanket_total_amount,       created_by,      last_updated_by,
	   last_update_login,rate
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id;

/*    Cursor to select location code */
/* Bug# 1200791  Previously it was this cursor -- after the warehouse modification this
was changed to the below cursor - 17-Feb-2000 - Preetam Bamb
  CURSOR loc_code_cur
  IS
    SELECT location_code
    FROM   hr_locations
    WHERE  location_id = v_ship_to_location_id;
*/
CURSOR loc_code_cur
  IS
    SELECT whse_code
    FROM   ic_whse_mst
    WHERE  MTL_ORGANIZATION_ID  = v_ship_to_organization_id;

/*    Cursor to select values from po_lines_all table */

  CURSOR line_vars_cur
  IS
    SELECT item_id, unit_meas_lookup_code, unit_price, qc_grade qc_grade_wanted
--    substrb(attribute11,1,4) qc_grade_wanted
    FROM   po_lines_all
    WHERE  po_header_id = p_po_header_id
    AND    po_line_id   = p_po_line_id;

/*    Cursor to select values from po_line_locations_all table */
/*Bug# 1200791 */
  CURSOR lineloc_vars_cur
  IS
    SELECT quantity,        need_by_date,   closed_code,
           promised_date,   last_accept_date,
           po_release_id,   cancel_flag,
	   source_shipment_id,
	   price_override,
	   nvl(SHIP_TO_ORGANIZATION_ID,0), /*Bug# 1200791  nvl(ship_to_location_id,0) Changed by Preetam for warehouse changes */
	   shipment_num
    FROM   po_line_locations_all
    WHERE  po_header_id     = p_po_header_id
    AND    po_line_id       = p_po_line_id
    AND    line_location_id = p_po_line_location_id;

/*    Cursor to select release_num from po_releases_all table */

  CURSOR rel_num_cur
  IS
    SELECT release_num
    FROM   po_releases_all
    WHERE  po_release_id = v_po_release_id;

/*    Cursor to select values from mtl_system_items table */

  CURSOR mtl_vars_cur
  IS
    SELECT distinct substrb(segment1,1,32),  substrb(description, 1,70),
	   inventory_item_flag
    FROM   mtl_system_items
    WHERE  inventory_item_id = v_item_id;

/* T.Ricci 10/15/98 added terms_name_cur for terms code fix for OPM 11.0*/
  CURSOR terms_name_cur
  IS
    SELECT name
    FROM   ap_terms
    WHERE  term_id = v_terms_id;

/* T.Ricci 11/10/98 added shipper_code_cur to retreive correct shipper_code
   4 char value from op_ship_mst*/
  CURSOR shipper_code_cur
  IS
    SELECT shipper_code
    FROM   op_ship_mst
    WHERE  of_shipper_code = v_ship_via_lookup_code;

/* T.Ricci 11/11/98 added fob_code_cur to retreive correct fob_code
   4 char value from op_fobc_mst*/
  CURSOR fob_code_cur
  IS
    SELECT fob_code
    FROM   op_fobc_mst
    WHERE  of_fob_code = v_fob_lookup_code;

/** MC BUG# 1554088  **/
/* Cursor to fetch  OPM uom code corr. to 25 char APPS unit of measure **/
  CURSOR uom_code_cur
  IS
    SELECT um_code
    FROM   sy_uoms_mst
    WHERE  unit_of_measure = v_unit_meas_lookup_code;

/* Uday Phadtare B1410454 Select the orgn code for the release */
  CURSOR opm_rel_orgn_cur
    IS
      SELECT substr(attribute15,1,4) opm_rel_orgn_code
      FROM   po_releases_all
      WHERE  po_header_id = p_po_header_id
      AND    po_release_id = v_po_release_id;

  /* BEGIN - Bug 1427876 */
  CURSOR opm_rel_exchange_rate
  IS
      SELECT RATE
      FROM   po_distributions_all
      WHERE  po_header_id     = p_po_header_id
      AND    po_line_id       = p_po_line_id
      AND    line_location_id = p_po_line_location_id;
  /* END - Bug 1427876 */
BEGIN

  /* T. Ricci 5/11/98 added v_created_by, v_last_updated_by, v_last_update_login
  for GEMMS 5.0 who columns */

  OPEN  hdr_vars_cur;
  FETCH hdr_vars_cur
  INTO  v_po_no,            v_type_lookup_code,    v_currency_code,
        v_agent_id,         v_print_count,         v_revision_num,
        v_printed_date,     v_approved_date,       v_terms_id,
        v_vendor_site_id,   v_creation_date,
        v_last_update_date, v_start_date,          v_end_date,
	v_fob_lookup_code,  v_ship_via_lookup_code,
	v_freight_terms_lookup_code, v_gemms_orgn_code,  v_blanket_total_amount,
        v_created_by, v_last_updated_by, v_last_update_login,v_exchange_rate;
  CLOSE hdr_vars_cur;


  OPEN  buyer_code_cur;
  FETCH buyer_code_cur
  INTO  v_buyer_code ;
  CLOSE buyer_code_cur;


  OPEN  line_vars_cur;
  FETCH line_vars_cur
  INTO  v_item_id,     v_unit_meas_lookup_code ,   v_unit_price,
        v_qc_grade_wanted;
  CLOSE line_vars_cur;

/** MC BUG# 1554088  **/
  OPEN  uom_code_cur;
  FETCH uom_code_cur
  INTO  v_order_um1;
  CLOSE uom_code_cur;

  IF P_CLOSE_TRIG_CALL = 'Y' THEN
    v_quantity                  := p_quantity;
    v_need_by_date              := p_need_by_date;
    v_closed_code               := p_closed_code;
    v_promised_date             := p_promised_date;
    v_last_accept_date          := p_last_accept_date;
    v_po_release_id             := p_po_release_id;
    v_cancel_flag               := p_cancel_flag;
    v_source_shipment_id        := p_source_shipment_id;
    v_price_override            := p_price_override;
    v_ship_to_organization_id   := p_ship_to_location_id;
/*Bug# 1224724 Commented the line below as now ship to organizaion is used to determine the warehouse code
    v_ship_to_location_id       := p_ship_to_location_id;*/
    v_shipment_num              := p_shipment_num;
  ELSE
    OPEN  lineloc_vars_cur;
    FETCH lineloc_vars_cur
    INTO  v_quantity,             v_need_by_date,    v_closed_code,
          v_promised_date,        v_last_accept_date,
          v_po_release_id,        v_cancel_flag,
          v_source_shipment_id,   v_price_override,  v_ship_to_organization_id,/*Bug# 1200791 */
          v_shipment_num;
    CLOSE lineloc_vars_cur;
  END IF;

  OPEN  loc_code_cur;
  FETCH loc_code_cur
  INTO  v_location_code;
  CLOSE loc_code_cur;

  OPEN   rel_num_cur;
  FETCH  rel_num_cur
  INTO   v_release_num;
  CLOSE  rel_num_cur;

  OPEN   mtl_vars_cur;
  FETCH  mtl_vars_cur
  INTO   v_item_no, v_item_desc, v_inventory_item_flag;
  CLOSE  mtl_vars_cur;

/* T.Ricci 10/15/98 added terms_name_cur for terms code fix for OPM 11.0*/
  OPEN   terms_name_cur;
  FETCH  terms_name_cur
  INTO   v_terms_name;
  CLOSE  terms_name_cur;

/* T.Ricci 11/10/98 added shipper_code_cur to retreive correct shipper_code
   4 char value from op_ship_mst*/
  OPEN   shipper_code_cur;
  FETCH  shipper_code_cur
  INTO   v_shipper_code;
  CLOSE  shipper_code_cur;

/* T.Ricci 11/11/98 added fob_code_cur to retreive correct fob_code
   4 char value from op_fobc_mst*/
  OPEN   fob_code_cur;
  FETCH  fob_code_cur
  INTO   v_fob_code;
  CLOSE  fob_code_cur;

  IF v_cancel_flag = 'Y' THEN
     /* BEGIN - Bug 1228034 Pushkar Upakare */
     /* v_cancellation_code := fnd_profile.value('OP$HOLDREAS_CODE'); */
     v_cancellation_code := fnd_profile.value('PO$CANCEL_CODE');
    /* END - Bug 1228034 */
  ELSE
    v_cancellation_code := NULL;  /* T.Ricci 7/6/98 changed to NULL*/
  END IF;

/* H. Wahdani - retrieve SY$ZERODATE */
  bind_date := gma_core_pkg.get_date_constant('SY$ZERODATE');

/* T. Ricci 11/12/98 added check before insert - MEGAPATCH fix*/
  v_db_promised_date := v_promised_date;

  IF v_db_promised_date IS NULL THEN
     v_db_promised_date := v_need_by_date;
  END IF;

 -- Begin B1410454
 /* Select the OPM orgn Code from the PO_RELEASES_ALL table, if it is
     release, else the v_gemms_orgn_code will be from the PO_HEADERS_ALL
     table for all other purposes. If the v_opm_rel_orgn_code is NOT NULL
     then it will be used , else the v_gemms_orgn_code from the PO_HEAD
     ERS_ALL will be used */

  IF (v_po_release_id is not null) THEN
     OPEN opm_rel_orgn_cur;
     FETCH opm_rel_orgn_cur
     INTO v_opm_rel_orgn_code;
     CLOSE opm_rel_orgn_cur;

     IF (v_opm_rel_orgn_code IS NOT NULL) THEN
        v_gemms_orgn_code := v_opm_rel_orgn_code;
     END IF;

     /* BEGIN - Bug 1427876 */
     OPEN opm_rel_exchange_rate;
     FETCH opm_rel_exchange_rate into v_opm_rel_exchg_rate;
     CLOSE opm_rel_exchange_rate;

     IF (v_opm_rel_exchg_rate IS NOT NULL) THEN
	v_exchange_rate := v_opm_rel_exchg_rate;
     END IF;
     /* END - Bug 1427876 */

  END IF;
  -- End B1410454

  IF v_gemms_orgn_code IS NULL THEN
     v_gemms_orgn_code := fnd_profile.value('GEMMS_DEFAULT_ORGN');
  END IF;

/* T.Ricci  5/13/99 added call to check for opm item */
  opmitem := GMF_OPM_ITEM.check_opm_item (v_item_no);

/* T. Ricci 5/11/98 changed INSERT for 5.0 changes, removed user_class
   columns and implemented new who columns */

  IF NOT ( nvl(substrb(v_type_lookup_code,1,10), ' ') = 'BLANKET' AND
     nvl(v_po_release_id, 0) = 0)
     AND opmitem = 1 THEN

  /* Uday Phadtare B2038851 */
    OPEN  c_get_old_po_no  ( p_po_header_id );
    FETCH c_get_old_po_no into v_old_po_no;
    IF c_get_old_po_no%FOUND then
      v_po_no := v_old_po_no;
    END IF;
    CLOSE c_get_old_po_no;


  INSERT INTO cpg_purchasing_interface
    ( transaction_id,
      transaction_type,
      orgn_code,
      po_no,
      po_header_id,
      po_line_id,
      po_line_location_id,
      po_distribution_id,
      po_status,
      buyer_code,
      po_id,
      bpo_id,
      bpo_release_number,
      of_payvend_site_id,
      of_shipvend_site_id,
      po_date,
      po_type,
      from_whse,
      to_whse,
      recv_desc,
      recv_loct,
      recvaddr_id,
      ship_mthd,
      shipper_code,
      of_frtbill_mthd,
      of_terms_code,
      billing_currency,
      purchase_exchange_rate,
      mul_div_sign,
      currency_bght_fwd,
      pohold_code,
      cancellation_code,
      fob_code,
      icpurch_class,
      vendso_no,
      project_no,
      requested_dlvdate,
      sched_shipdate,
      required_dlvdate,
      agreed_dlvdate,
      date_printed,
      expedite_date,
      revision_count,
      in_use,
      print_count,
      line_id,
      bpo_line_id,
      apinv_line_id,
      item_no,
      generic_id,
      item_desc,
      order_qty1,
      order_qty2,
      order_um1,
      order_um2,
      received_qty1,
      received_qty2,
      net_price,
      extended_price,
      price_um,
      qc_grade_wanted,
      match_type,
      text_code,
      trans_cnt,
      exported_date,
      last_update_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_login,
      delete_mark,
      contract_value,
      contract_start_date,
      contract_end_date,
      std_qty,
      max_rels_qty,
      invalid_ind,
      po_release_id,
      release_num,
      source_shipment_id,
      line_no
    )
    VALUES
    ( nvl(cpg_potrans.nextval,0),
      nvl(substrb(v_type_lookup_code,1,10),' '),
      v_gemms_orgn_code,
      nvl(v_po_no,' '),
      nvl(p_po_header_id,0),
      nvl(p_po_line_id,0),
      nvl(p_po_line_location_id,0),
      0,                                     /*distribution id*/
      nvl(v_closed_code, '0'),               /*po_status,*/
      nvl(v_buyer_code,' '),                 /*buyer_code,       */
      0,                                     /*po_id,*/
      NULL,                                  /*bpo_id T.Ricci added NULL,*/
      nvl(v_release_num, 0),                 /*bpo_release_number,*/
      nvl(v_vendor_site_id,1),
      nvl(v_vendor_site_id,1),
      nvl(v_approved_date, sysdate),         /*po_date, PKU - BUG 1785704 */
      1,                                     /*po_type,  */
      NULL,                                  /*from_whse T.Ricci added NULL,*/
      nvl(substrb(v_location_code,1,4),' '),  /*to_whse, */
      ' ',                                   /*recv_desc,*/
      NULL,                                  /*recv_loct T.Ricci added NULL,*/
      NULL,                                  /*recvaddr_id T.Ricci added NULL,*/
      NULL,                                  /*ship_mthd T.Ricci added NULL,
   T.Ricci 11/10/98 added v_shipper_code to retreive correct shipper_code*/
      v_shipper_code,                        /*shipper_code,*/
      v_freight_terms_lookup_code,           /*of_frtbill_mthd,
   T.Ricci 10/15/98 added terms_name for terms code fix for OPM 11.0*/
      v_terms_name,                          /*PKU - Bug 2195821 removed nvl(of_terms_code,'20')*/
      nvl(substrb(v_currency_code,1,4),'USD'),/*billing_currency,*/
/*   1,                                     purchase_exchange_rate,*/
      nvl(v_exchange_rate,1),              /* HW BUG:1107267 purchase_exchang_rate */
      0,                                     /*mul_div_sign,*/
      0,                                     /*currency_bght_fwd,*/
      NULL,                                  /*pohold_code T.Ricci added NULL,*/
      v_cancellation_code,                  /*cancellation_code TR remove nvl,
   T.Ricci 11/10/98 added v_fob_code to retreive correct fob_code*/
      v_fob_code,                            /*fob_code,*/
      NULL,                                  /*icpurch_class T.Ricci add NULL,  */
      ' ',                                   /*vendso_no,     */
      NULL,                                  /*project_no T.Ricci added NULL,   */
      nvl(v_need_by_date, sysdate),         /*requested_dlvdate,  */
      nvl(v_promised_date, sysdate),         /*sched_shipdate,    */
      nvl(v_last_accept_date, sysdate),      /*required_dlvdate, */
      nvl(v_db_promised_date, sysdate),      /*agreed_dlvdate,  */
      nvl(v_printed_date, sysdate),          /*date_printed,   */
/*    nvl(fnd_profile.value('SY$ZERODATE'),sysdate),  expedite_date, */
      nvl(bind_date,sysdate),                /* expedite_date H. Wahdani */
      nvl(v_revision_num,0),                 /*revision_count, */
      0,                                     /*in_use,        */
      nvl(v_print_count,0),                  /*print_count,  */
      0, /*v_line_id,                        --line_id,   */
      0,                                     /*bpo_line_id,*/
      0,                                     /*apinv_line_id,*/
      nvl(v_item_no,0),                      /*item_no,     */
      NULL,                                  /*generic_id T.Ricci added NULL,*/
      nvl(v_item_desc,'NONE'),               /*item_desc, */
      nvl(v_quantity,0),                     /*order_qty1,*/
      0,                                     /*order_qty2, */
      v_order_um1,/** MC BUG# 1554088 nvl(substrb(v_unit_meas_lookup_code,1,4),' '),**/   /*order_um1, */
      NULL,                                  /*order_um2 T.Ricci added NULL,*/
      0,                                     /*received_qty1, */
      0,                                     /*received_qty2,*/
      nvl(v_price_override, 0),              /*net_price,*/
      nvl(v_quantity*v_price_override,0),    /*extended_price, */
      v_order_um1,/** MC BUG# 1554088 nvl(substrb(v_unit_meas_lookup_code,1,4),' '),**/  /*price_um,      */
      v_qc_grade_wanted,                    /*qc_grade_wanted,*/
      3,                                    /*match_type,    */
      NULL,                                 /*text_code T.Ricci added NULL,  */
      1,                                    /*trans_cnt, */
      to_date('01/01/1970', 'DD/MM/YYYY'),  /*exported_date,H. Wahdani, added 19 */
      nvl(v_last_update_date,sysdate),      /*last_update_date,*/
      nvl(v_created_by, 0),                 /*created_by, */
      nvl(v_creation_date,sysdate),         /*creation_date,  */
      nvl(v_last_updated_by, 0),            /*last_updated_by, */
      nvl(v_last_update_login, 0),          /*last_update_login, */
      0,                                    /*delete_mark,*/
      nvl(v_blanket_total_amount, 0),       /*contract_value,*/
      nvl(v_start_date, v_approved_date),   /*contract_start_date,*/
      nvl(v_end_date, to_date('31/12/2010', 'DD/MM/YYYY')),
                                            /*contract_end_date,*/
      nvl(v_quantity,0),                    /*std_qty,*/
      nvl(v_quantity,0),                    /*max_rels_qty,*/
      'N',                                  /*invalid_ind*/
      nvl(v_po_release_id,0),               /*po_release_id,*/
      nvl(v_release_num, 0),                /*release_num,*/
      nvl(v_source_shipment_id, 0),         /*source_shipment_id*/
      nvl(v_shipment_num, 0)                /*shipment_num*/
    );


    OPEN  c_checkpll_cur(p_po_header_id, p_po_line_id, p_po_line_location_id);
    FETCH c_checkpll_cur
    INTO  r_checkpll_rec;

    IF c_checkpll_cur%NOTFOUND THEN
      INSERT INTO cpg_oragems_mapping
      ( po_header_id,
        po_line_id,
        po_line_location_id,
        po_no,
        po_status,
        time_stamp,
        po_release_id,
        release_num,
	transaction_type,
        last_update_login,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date
      )
      VALUES
      ( p_po_header_id,
        p_po_line_id,
        p_po_line_location_id,
        nvl(v_po_no,' '),
        nvl(v_closed_code, 'OPEN'),
        sysdate,
        v_po_release_id,
        v_release_num,
        v_type_lookup_code,
        nvl(v_last_update_login, 0),
        sysdate,
        nvl(v_last_updated_by, 0),
        nvl(v_created_by, 0),
        sysdate
      );

    ELSIF (v_closed_code = 'FINALLY CLOSED')  THEN
      UPDATE cpg_oragems_mapping
      SET    po_status  = v_closed_code,
	     time_stamp = sysdate,
	     last_update_date = sysdate
      WHERE  CURRENT of c_checkpll_cur;

    ELSIF (v_cancel_flag ='Y') THEN
      UPDATE cpg_oragems_mapping
      SET    po_status  = 'CANCELLED',
	     time_stamp = sysdate,
	     last_update_date = sysdate
      WHERE  CURRENT of c_checkpll_cur;

    END IF;

    CLOSE c_checkpll_cur;

/** MC BUG# 1625573 **/
/** changed bug no. from 1527076 to 1625573  **/
/** cpg_purchasing_interface should have po_no column with value = OPM PO. Right
 now
it is fetching from segment1 from po_headers_all but for migrated PO's segment1
can be different than OPM PO. so pick up the correct po no from cpg_oragems_mapp
ing table **/

/* Uday Phadtare B2038851 following update statement commented */

/*  UPDATE cpg_purchasing_interface a
    SET    a.po_no = ( SELECT b.po_no from cpg_oragems_mapping b
                       WHERE
                       b.po_header_id = a.po_header_id AND
                       b.po_line_id   = a.po_line_id   AND
                       b.po_line_location_id = a.po_line_location_id ) ; */


  END IF; /* Blanket and release_id = 0 and inventory item condition */

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);
END insert_rec;

END GML_PO_INTERFACE;

/
