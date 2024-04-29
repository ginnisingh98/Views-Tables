--------------------------------------------------------
--  DDL for Package Body GML_SYNCH_BPOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_SYNCH_BPOS" AS
/* $Header: GMLPBPOB.pls 115.12 2002/12/04 19:05:25 gmangari ship $ */

/*----------------------------------------------------------------------------+
 |                                                                            |
 | PROCEDURE NAME    next_bpo_id                                              |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |   Procedure to get the next available bpo_id (For Planned POs only)        |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |                                                                            |
 |   26-OCT-97    R Chellam       Created                                     |
 |   20-NOV-97    R Chellam       Modified to deal only with PPOs             |
 |   14-MAY-98    T Ricci         replaced sy_surg_ctl with nextval from      |
 |                                sys.dual for GEMMS 5.0                      |
 +----------------------------------------------------------------------------*/

PROCEDURE next_bpo_id ( new_bpo_id  OUT NOCOPY PO_BPOS_HDR.BPO_ID%TYPE,
			p_orgn_code IN  SY_ORGN_MST.ORGN_CODE%TYPE,
                        v_next_id_status OUT NOCOPY BOOLEAN)
IS

  /* CURSOR NBPO_ID_CUR IS
    SELECT last_value + 1
    FROM   sy_surg_ctl
    WHERE  key_name = 'bpo_id'
    FOR    UPDATE; */

  CURSOR NBPO_ID_CUR IS
    SELECT GEM5_BPO_ID_s.nextval
    FROM   sys.dual;

  err_msg  VARCHAR2(100);

BEGIN

  OPEN   nbpo_id_cur;

  FETCH  nbpo_id_cur into new_bpo_id;

  /* UPDATE sy_surg_ctl
  SET    last_value = new_bpo_id
  WHERE  current of nbpo_id_cur; */

  UPDATE sy_docs_seq
  SET    last_assigned = last_assigned + 1
  WHERE  doc_type  = 'PBPO'
  AND    orgn_code = p_orgn_code;

  CLOSE  nbpo_id_cur;
  v_next_id_status :=TRUE;

EXCEPTION
  WHEN OTHERS THEN
    v_next_id_status :=FALSE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);
END next_bpo_id;


/* Function to get the next available  GEMMS line_id for Planned
   POs is same as    for Standard PO's. Hence no different procedure */

/*-----------------------------------------------------------------------------|
|                                                                              |
| FUNCTION  NAME    bpo_exist                                                  |
|                                                                              |
| DESCRIPTION                                                                  |
|                                                                              |
|   Procedure to check if the Planned PO already exists in bpos tables         |
|                                                                              |
| MODIFICATION HISTORY                                                         |
|                                                                              |
|   26-OCT-97                R Chellam       Created                           |
|   20-NOV-97                R Chellam       Modified to deal only with PPOs   |
+-----------------------------------------------------------------------------*/


FUNCTION bpo_exist
( v_bpo_no  IN PO_BPOS_HDR.BPO_NO%TYPE)
RETURN BOOLEAN
IS

  v_row_count  NUMBER :=0;
  err_msg      VARCHAR2(100);

  CURSOR row_count1_cur IS
    SELECT     COUNT(*)
    FROM       po_bpos_hdr
    WHERE      bpo_no = v_bpo_no;

BEGIN
  OPEN  row_count1_cur;
  FETCH row_count1_cur
  INTO  v_row_count;
  CLOSE row_count1_cur;

  IF   v_row_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END bpo_exist;


/*-----------------------------------------------------------------------------|
|                                                                              |
| FUNCTION  NAME    bpo_line_exist                                             |
|                                                                              |
| DESCRIPTION                                                                  |
|                                                                              |
|   Function to check if bpo_line already exists and is to be updated or is new|
|                                                                              |
| MODIFICATION HISTORY                                                         |
|                                                                              |
|   26-OCT-97                R Chellam                    Created              |
|   20-NOV-97                R Chellam       Modified to deal only with PPOs   |
+-----------------------------------------------------------------------------*/


FUNCTION bpo_line_exist

( v_po_header_id         IN   CPG_PURCHASING_INTERFACE.PO_HEADER_ID%TYPE,
  v_po_line_id           IN   CPG_PURCHASING_INTERFACE.PO_LINE_ID%TYPE,
  v_po_line_location_id  IN   CPG_PURCHASING_INTERFACE.PO_LINE_LOCATION_ID%TYPE)

RETURN BOOLEAN
IS

  CURSOR id_cur (header NUMBER, line NUMBER, location NUMBER) IS
    SELECT  bpo_id, bpo_line_id
    FROM    cpg_oragems_mapping
    WHERE   po_header_id        = v_po_header_id
    AND     po_line_id          = v_po_line_id
    AND     po_line_location_id = v_po_line_location_id;

  id_rec    id_cur%ROWTYPE;
  err_msg   VARCHAR2(100);

BEGIN

  OPEN  id_cur (v_po_header_id, v_po_line_id, v_po_line_location_id);
  FETCH id_cur INTO id_rec;
  CLOSE id_cur;

  IF (id_rec.bpo_id IS NULL AND id_rec.bpo_line_id IS NULL) THEN
    RETURN FALSE;
  ELSIF (id_rec.bpo_id IS NOT NULL AND id_rec.bpo_line_id IS NOT NULL) THEN
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END bpo_line_exist;


/*-----------------------------------------------------------------------------|
|                                                                              |
| FUNCTION  NAME    get_bpo_line_no                                            |
|                                                                              |
| DESCRIPTION                                                                  |
|                                                                              |
|   Function to get the maximum line number so far for a particular PPO        |
|                                                                              |
| MODIFICATION HISTORY                                                         |
|                                                                              |
|   26-OCT-97 R Chellam   Created               			       |
|   20-NOV-97 R Chellam   Modified to deal only with PPOs                      |
|   25-APR-00 N Chekuri   Changed to return line_num from  po_lines_all instead|
|                         of the max(line_no) from  po_bpos_dtl. Bug#1246767.  |
|                         Changed parameter accordingly.
|   15-MAY-00 N Chekuri   Added logic to take care of more than one shipment   |
|                         line per PO line. Added parameters.
|-----------------------------------------------------------------------------*/

FUNCTION get_bpo_line_no( v_bpo_id IN NUMBER,v_po_header_id IN NUMBER,
			  v_po_line_id IN NUMBER)
RETURN NUMBER
IS

  v_bpo_line_no       NUMBER;
  v_line_count        NUMBER;
  v_shipment_count    NUMBER;
  err_msg             VARCHAR2(100);

BEGIN

  /* Retain the line number from apps as long as there is only
     one shipment per line.We'll generate a number if there is
     more than one shipment per line */

  SELECT count(*)
  INTO v_line_count
  FROM po_lines_all
  WHERE po_header_id = v_po_header_id;

  SELECT count(*)
  INTO v_shipment_count
  FROM po_line_locations_all
  WHERE po_header_id = v_po_header_id;

  IF v_line_count = v_shipment_count THEN
    SELECT  line_num
    INTO   v_bpo_line_no
    FROM   po_lines_all
    WHERE  po_line_id = v_po_line_id;
  ELSE
    SELECT NVL(MAX(line_no),0) +1
    INTO   v_bpo_line_no
    FROM   po_bpos_dtl
    WHERE  bpo_id = v_bpo_id;
  END IF;

  RETURN v_bpo_line_no;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;

  WHEN OTHERS THEN
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END get_bpo_line_no;


/*-----------------------------------------------------------------------------|
|                                                                              |
| PROCEDURE NAME    cpg_bint2gms                                               |
|                                                                              |
| DESCRIPTION                                                                  |
|                                                                              |
|   Procedure to synchronize rows from Oracle to Gemms for Planned  PO's       |
|                                                                              |
| MODIFICATION HISTORY                                                         |
|                                                                              |
|   26-OCT-97               R Chellam                    Created               |
|   20-NOV-97               R Chellam       Modified to deal only with PPOs    |
|   06/NOV/98           Tony Ricci          removed call to GML_PO_SYNCH.      |
|                                           cpg_conv_duom and replaced with    |
|                                           GMICUOM.icuomcv which is the OPM   |
|                                           standard uom conversion            |
|   28-JAN-99            T.Ricci            check dualum_ind before calling    |
|                                           GMICUOM.icuomcv and remove nvl on  |
|                                           item_um2 before insert to          |
|                                           po_rels_schBUG#809339              |
|   15-MAY-2001          PKU               Bug 1776328 - Contract dates for BPO|
|                                          are same on OPM and APPS side       |
|   04-JUN-2001          PKU               Bug 1811587 - Contract dates for BPO|
|                                          are same on OPM after update on     |
|                                          APPS side.                          |
|-----------------------------------------------------------------------------*/

PROCEDURE cpg_bint2gms  ( retcode   OUT   NOCOPY NUMBER)
IS

  CURSOR int_cur IS
    SELECT  *
    FROM    cpg_purchasing_interface
    WHERE   invalid_ind       = 'N'
    AND     (transaction_type = 'PLANNED' AND release_num = 0);

  int_rec   int_cur%ROWTYPE;

  err_num   NUMBER;
  err_msg   VARCHAR2(100);

  /* Cursor to select shipvend_id  and payvend_id */

  CURSOR  vendor_cur (p_of_vendor_site_id  PO_VEND_MST.OF_VENDOR_SITE_ID%TYPE)
  IS
    SELECT  vendor_id
    FROM    po_vend_mst
    WHERE   of_vendor_site_id = p_of_vendor_site_id;

  /* Cursor to select fob_code */

  CURSOR  fob_code_cur (p_of_fob_code OP_FOBC_MST.OF_FOB_CODE%TYPE) IS
    SELECT  fob_code
    FROM    op_fobc_mst
    WHERE   of_fob_code = p_of_fob_code;

  /* Cursor to select terms_code */

  CURSOR  terms_code_cur (p_of_terms_code OP_TERM_MST.OF_TERMS_CODE%TYPE) IS
    SELECT  terms_code
    FROM    op_term_mst
    WHERE   of_terms_code = p_of_terms_code;

  /* Cursor to select bpo_id */

  CURSOR  bpo_id_cur (p_bpo_no PO_BPOS_HDR.BPO_NO%TYPE) IS
    SELECT  bpo_id
    FROM    po_bpos_hdr
    WHERE   bpo_no = p_bpo_no;

  /* Cursor to select bpo_line_id */

  CURSOR  bpo_line_id_cur
   (
    p_po_header_id        CPG_PURCHASING_INTERFACE.PO_HEADER_ID%TYPE,
    p_po_line_id          CPG_PURCHASING_INTERFACE.PO_LINE_ID%TYPE,
    p_po_line_location_id CPG_PURCHASING_INTERFACE.PO_LINE_LOCATION_ID%TYPE
   ) IS
    SELECT  bpo_line_id
    FROM    cpg_oragems_mapping
    WHERE   po_header_id        = p_po_header_id
    AND     po_line_id          = p_po_line_id
    AND     po_line_location_id = p_po_line_location_id;

  /* Cursor to select values from ic_item_mst */

  CURSOR  item_cur (p_item_no IC_ITEM_MST.ITEM_NO%TYPE) IS
    SELECT  item_id, nvl(item_desc1,' '), item_um2, dualum_ind
    FROM    ic_item_mst
    WHERE   item_no = p_item_no;

  /* Cursor to select co_code */

  CURSOR  co_code_cur (p_orgn_code SY_ORGN_MST.ORGN_CODE%TYPE) IS
    SELECT  co_code
    FROM    sy_orgn_mst
    WHERE   orgn_code = p_orgn_code;

  v_po_status             NUMBER;
  v_order2                NUMBER;

  v_new_bpo_id            PO_BPOS_HDR.BPO_ID%TYPE;
  v_bpo_id                PO_BPOS_HDR.BPO_ID%TYPE;
  v_bpo_line_id           PO_BPOS_DTL.LINE_ID%TYPE;
  v_new_line_id           PO_BPOS_DTL.LINE_ID%TYPE;
  v_bpo_line_no           PO_BPOS_DTL.LINE_NO%TYPE;

  v_item_id               IC_ITEM_MST.ITEM_ID%TYPE;
  v_item_um2              IC_ITEM_MST.ITEM_UM%TYPE;
  v_item_dualum_ind       IC_ITEM_MST.DUALUM_IND%TYPE;

  v_item_desc             IC_ITEM_MST.ITEM_DESC1%TYPE;
  v_ship_vendor_id        PO_VEND_MST.VENDOR_ID%TYPE;
  v_pay_vendor_id         PO_VEND_MST.VENDOR_ID%TYPE;
  v_fob_code              OP_FOBC_MST.FOB_CODE%TYPE;
  v_terms_code            OP_TERM_MST.TERMS_CODE%TYPE;

  v_exchange_rate         GL_XCHG_RTE.EXCHANGE_RATE%TYPE;
  v_mul_div_sign          GL_XCHG_RTE.MUL_DIV_SIGN%TYPE;
  v_exchange_rate_date    GL_XCHG_RTE.EXCHANGE_RATE_DATE%TYPE;
  v_base_currency         GL_XCHG_RTE.TO_CURRENCY_CODE%TYPE;
  v_gl_source_type        GL_SRCE_MST.TRANS_SOURCE_TYPE%TYPE;

  v_next_id_status        BOOLEAN;

BEGIN


  retcode := 0;

  OPEN  int_cur;

  FETCH int_cur INTO int_rec;

  WHILE int_cur%FOUND
  LOOP
    IF GML_PO_SYNCH.gemms_validate
		     (int_rec.orgn_code,
		      int_rec.of_payvend_site_id,
                      int_rec.of_shipvend_site_id,
                      int_rec.to_whse,
                      int_rec.billing_currency,
                      int_rec.item_no,
                      int_rec.order_um1,
                      int_rec.price_um,
                      int_rec.order_um2,
                      int_rec.item_um,
                      int_rec.buyer_code,
                      int_rec.from_whse,
                      int_rec.shipper_code,
                      int_rec.of_frtbill_mthd,
                      int_rec.of_terms_code,
                      int_rec.qc_grade_wanted,
                      int_rec.po_no,
                      int_rec.po_line_id,
                      int_rec.po_line_location_id,
                      int_rec.revision_count,
		      /* T. Ricci 5/12/98 replaced date_modified with */
		      /* last_update_date for GEMMS 5.0*/
                      int_rec.last_update_date
                     ) = FALSE  THEN

      UPDATE  cpg_purchasing_interface
      SET     invalid_ind = 'Y'
      WHERE   po_header_id        = int_rec.po_header_id
      AND     po_line_id          = int_rec.po_line_id
      AND     po_line_location_id = int_rec.po_line_location_id;

      retcode := 1;

    ELSE  /* all fields are validate*/

/* T.Ricci 5/12/98 set po_status = 0 for 'CANCEL'*/

      IF int_rec.po_status = 'OPEN' THEN
        v_po_status := 0;
      ELSIF int_rec.po_status = 'CANCEL' THEN
        v_po_status :=0;
      ELSIF (int_rec.po_status = 'CLOSED' OR
	    int_rec.po_status = 'CLOSED FOR RECEIVING' OR
	    int_rec.po_status = 'CLOSED FOR INVOICE'   OR
	    int_rec.po_status = 'FINALLY CLOSED') THEN
        /*v_po_status := 2;*/
        v_po_status := 20;
      END IF;

      GML_VALIDATE_PO.get_base_currency (v_base_currency,
					  int_rec.orgn_code);

      IF (v_base_currency <> int_rec.billing_currency) THEN

	GML_VALIDATE_PO.get_gl_source (v_gl_source_type);

	GML_VALIDATE_PO.get_exchange_rate (v_exchange_rate,
					    v_mul_div_sign,
					    v_exchange_rate_date,
					    v_base_currency,   /* to-currency*/
					    int_rec.billing_currency,
					    v_gl_source_type);
      END IF;

      OPEN  vendor_cur(int_rec.of_shipvend_site_id);
      FETCH vendor_cur
      INTO  v_ship_vendor_id;
      CLOSE vendor_cur;

      OPEN  vendor_cur(int_rec.of_payvend_site_id);
      FETCH vendor_cur
      INTO  v_pay_vendor_id;
      CLOSE vendor_cur;

      OPEN  fob_code_cur(int_rec.fob_code);
      FETCH fob_code_cur
      INTO  v_fob_code;
      CLOSE fob_code_cur;

      OPEN  terms_code_cur(int_rec.of_terms_code);
      FETCH terms_code_cur
      INTO  v_terms_code;
      CLOSE terms_code_cur;

      IF  NOT  GML_SYNCH_BPOS.bpo_exist(int_rec.po_no)  THEN
      BEGIN
        GML_SYNCH_BPOS.next_bpo_id(v_new_bpo_id, int_rec.orgn_code,
                                  v_next_id_status);
        IF v_next_id_status=FALSE THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error getting next bpo_id');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END IF;


        /* T.Ricci 5/11/98 removed user_class and added new who columns*/

        BEGIN
        INSERT INTO po_bpos_hdr
        (
          bpo_id,
          orgn_code,
          bpo_no,
          rel_count,
          payvend_id,
          contract_no,
          contract_value,
          contract_currency,
          currency_bght_fwd,
          contract_exchange_rate,
          mul_div_sign,
          amount_purchased,
          contract_start_date,
          contract_end_date,
          shipvend_id,
          shipper_code,
          recv_desc,
          ship_mthd,
          frtbill_mthd,
          terms_code,
          bpo_status,
          bpohold_code,
          cancellation_code,
          closure_code,
          activity_ind,
          fob_code,
          buyer_code,
          icpurch_class,
          vendso_no,
          project_no,
          date_printed,
          revision_count,
          in_use,
          print_count,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          delete_mark,
          text_code,
          orgnaddr_id
        )
        VALUES  /* Insertion                        */
        (
          v_new_bpo_id,
	  nvl(int_rec.orgn_code, '-1'),
          int_rec.po_no,
          nvl(int_rec.rel_count,0),
          nvl(v_pay_vendor_id,0),
          int_rec.contract_no,         /* KYH 24/AUG/98 nullable column*/
          int_rec.contract_value,      /* KYH 24/AUG/98 nullable column*/
          nvl(int_rec.billing_currency,'USD'),
          nvl(int_rec.currency_bght_fwd,0),
          nvl(v_exchange_rate,1),
          nvl(v_mul_div_sign,0),
          int_rec.amount_purchased,    /* KYH 24/AUG/98 nullable column */
          nvl(int_rec.contract_start_date, sysdate), /* PKU bug 1776328 */
          nvl(int_rec.contract_end_date , to_date('31-12-2010','DD-MM-YYYY')),
          nvl(v_ship_vendor_id, 0),
          int_rec.shipper_code,        /* KYH 24/AUG/98 nullable column */
          int_rec.recv_desc,           /* KYH 24/AUG/98 nullable column*/
          int_rec.ship_mthd,           /* KYH 24/AUG/98 integ constr change*/
          int_rec.of_frtbill_mthd,     /* KYH 24/AUG/98 nullable column*/
          v_terms_code,                /* KYH 24/AUG/98 nullable column*/
          nvl(v_po_status,0),
          int_rec.bpohold_code,        /* KYH 24/AUG/98 integ constr change */
          int_rec.cancellation_code,   /* KYH 24/AUG/98 nullable column*/
          int_rec.closure_code,        /* KYH 24/AUG/98 integ constr change*/
          nvl(int_rec.activity_ind,0),
          v_fob_code, /*int_rec.fob_code, KYH 24/AUG/98 nullable column*/
          int_rec.buyer_code,          /* KYH 24/AUG/98 nullable column*/
          int_rec.icpurch_class,       /* KYH 24/AUG/98 integ constr change*/
          int_rec.vendso_no,           /* KYH 24/AUG/98 nullable column*/
          int_rec.project_no,          /* KYH 24/AUG/98 integ constr change*/
          nvl(int_rec.date_printed,sysdate),
          int_rec.revision_count,      /* KYH 24/AUG/98 nullable column */
          nvl(int_rec.in_use,0),
          nvl(int_rec.print_count,0),
          nvl(int_rec.creation_date,sysdate),
          nvl(int_rec.created_by,0),
          nvl(int_rec.last_update_date,sysdate),
          nvl(int_rec.last_updated_by,0),
          nvl(int_rec.last_update_login,0),
          nvl(int_rec.delete_mark,0),
          int_rec.text_code,            /* KYH 24/AUG/98 integ const change*/
          int_rec.orgnaddr_id           /* KYH 24/AUG/98 integ const change*/
        );
        EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into po_bpos_hdr');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END;
      END;
    END IF;

    /* Fetch bpo_id for record*/
    OPEN  bpo_id_cur(int_rec.po_no);
    FETCH bpo_id_cur
    INTO  v_bpo_id;
    CLOSE bpo_id_cur;

    OPEN  item_cur(int_rec.item_no);
    FETCH item_cur
    INTO  v_item_id, v_item_desc, v_item_um2, v_item_dualum_ind;
    CLOSE item_cur;


      /* 11/6/1998 T. Ricci added*/
      IF v_item_dualum_ind > 0 THEN
      GMICUOM.icuomcv
        (v_item_id,0,
         int_rec.order_qty1,
         int_rec.order_um1,
         v_item_um2,
         v_order2);
      ELSE
         v_order2 := 0;
      END IF;

    IF  NOT GML_SYNCH_BPOS.bpo_line_exist
     ( int_rec.po_header_id,
       int_rec.po_line_id,
       int_rec.po_line_location_id)  THEN

      GML_PO_SYNCH.next_line_id('BPO', v_new_line_id, v_next_id_status);
      IF v_next_id_status=FALSE THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error getting next line_id');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
      END IF;

      /* 03/24/00 NC - Bug#1249797
          OPM was generating it's own line number  regardless of what
          the line number is in oracle.Modified to take oracle line number
          instead.
       */

      /*
      v_bpo_line_no :=  GML_SYNCH_BPOS.get_bpo_line_no(v_bpo_id) + 1;
       */
      v_bpo_line_no := GML_SYNCH_BPOS.get_bpo_line_no(v_bpo_id,int_rec.po_header_id,int_rec.po_line_id);


      /* T.Ricci 5/12/98 removed user_class and added new who columns*/

      BEGIN
      INSERT INTO po_bpos_dtl
      (
        bpo_id,
        line_no,
        line_id,
        item_id,
        generic_id,
        item_desc,
        contract_value,
        contract_qty,
        amount_purchased,
        item_um,
        qty_purchased,
        std_qty,
        release_interval,
        icpurch_class,
        bpo_status,
        net_price,
        from_whse,
        to_whse,
        recv_loct,
        recvaddr_id,
        recv_desc,
        ship_mthd,
        shipper_code,
        shipvend_id,
        qc_grade_wanted,
        frtbill_mthd,
        terms_code,
        bpohold_code,
        cancellation_code,
        closure_code,
        fob_code,
        vendso_no,
        buyer_code,
        project_no,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        text_code,
        trans_cnt,
        max_rels_qty,
        match_type
      )
      VALUES
      ( v_bpo_id,
        v_bpo_line_no,
        v_new_line_id,
        nvl(v_item_id, 0),                    /*int_rec.item_id,*/
        int_rec.generic_id,                   /*KYH 24/AUG/98 integ constr*/
        nvl(v_item_desc,' '),                 /*int_rec.item_desc,*/
        int_rec.contract_value,               /*KYH 24/AUG/98 nullable column*/
        int_rec.std_qty,         /*contract_qty KYH 24/AUG/98 nullable column*/
        0, /* amount_purchased,*/
        nvl(int_rec.order_um1, ' '),          /*int_rec.item_um,*/
        0, /*qty_purchased*/
        nvl(int_rec.std_qty, 0),
        nvl(int_rec.release_interval,1),
        int_rec.icpurch_class,                /*KYH 24/AUG/98 integ constr*/
        nvl(v_po_status,0),
        nvl(int_rec.net_price,0),
        int_rec.from_whse,                    /*KYH 24/AUG/98 integ constr*/
        nvl(int_rec.to_whse,' '),
        int_rec.recv_loct,                    /*KYH 24/AUG/98 integ constr*/
        int_rec.recvaddr_id,                  /*KYH 24/AUG/98 integ constr*/
        int_rec.recv_desc,                    /*KYH 24/AUG/98 nullable column*/
        int_rec.ship_mthd,                    /*KYH 24/AUG/98 integ constr */
        int_rec.shipper_code,                 /*KYH 24/AUG/98 nullable column*/
        nvl(v_ship_vendor_id,0),             /*int_rec.of_shipvend_site_id,*/
        int_rec.qc_grade_wanted,              /*KYH 24/AUG/98 nullable column*/
        int_rec.of_frtbill_mthd,              /*KYH 24/AUG/98 nullable column*/
        v_terms_code,/*int_rec.of_terms_code, --KYH 24/AUG/98 nullable column*/
        int_rec.bpohold_code,                 /*KYH 24/AUG/98 nullable column   */
        int_rec.cancellation_code,            /*KYH 24/AUG/98 nullable column*/
        int_rec.closure_code,                /*KYH 24/AUG/98 integ constr chnge*/
        v_fob_code,          /*int_rec.fob_code,KYH 24/AUG/98 nullable column*/
        int_rec.vendso_no,                    /*KYH 24/AUG/98 nullable column*/
        int_rec.buyer_code,                   /*KYH 24/AUG/98 nullable column*/
        int_rec.project_no,                  /*KYH 24/AUG/98 integ constr chnge*/
        nvl(int_rec.creation_date,sysdate),
        nvl(int_rec.created_by,0),
        nvl(int_rec.last_update_date,sysdate),
        nvl(int_rec.last_updated_by,0),
        nvl(int_rec.last_update_login,0),
        int_rec.text_code,                   /*KYH 24/AUG/98 integ constr chnge*/
        nvl(int_rec.trans_cnt,1),
        nvl(int_rec.max_rels_qty, 0),
        nvl(int_rec.match_type,3)
      );
      EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into po_bpos_dtl');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
      END;


      /* T.Ricci 5/12/98 removed user_class and added new who columns*/

      BEGIN
      INSERT INTO po_rels_sch
      (
        bpoline_id,
        agreed_dlvdate,
        line_status,
        order_qty1,
        order_qty2,
        order_um1,
        order_um2,
        from_whse,
        to_whse,
        recv_loct,
        recvaddr_id,
        recv_desc,
        ship_mthd,
        shipper_code,
        poline_id,
        creation_date,
        last_update_login,
        created_by,
        last_update_date,
        last_updated_by,
        text_code,
        trans_cnt,
        delete_mark
      )
      VALUES
      (
        v_new_line_id,
 	nvl(int_rec.agreed_dlvdate, sysdate),      /*agreed_dlvdate,*/
 	1, /*line_status,*/
 	nvl(int_rec.order_qty1,0),                 /*order_qty1,*/
 	nvl(v_order2, 0),                          /*order_qty2,*/
 	nvl(int_rec.order_um1,' '),
 	v_item_um2,
 	int_rec.from_whse,                         /*KYH 24/AUG/98 Integ Constr*/
 	nvl(int_rec.to_whse,' '),
 	int_rec.recv_loct,                         /*KYH 24/AUG/98 Integ Constr*/
 	int_rec.recvaddr_id,                       /*KYH 24/AUG/98 Integ Constr*/
 	int_rec.recv_desc,                         /*KYH 24/AUG/98 Nullable Col*/
 	int_rec.ship_mthd,                         /*KYH 24/AUG/98 Integ Constr*/
 	int_rec.shipper_code,                      /*KYH 24/AUG/98 Integ Constr*/
 	NULL,                                      /*KYH 24/AUG/98 Integ Constr*/
        nvl(int_rec.creation_date,sysdate),
        nvl(int_rec.last_update_login,0),
        nvl(int_rec.created_by,0),
        nvl(int_rec.last_update_date,sysdate),
        nvl(int_rec.last_updated_by,0),
 	int_rec.text_code,                        /*KYH 24/AUG/98 Integ Constr*/
 	nvl(int_rec.trans_cnt,1),
 	nvl(int_rec.delete_mark,0)
      );
      EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into po_rels_sch');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
      END;


      UPDATE  cpg_oragems_mapping
      SET     bpo_id       = v_bpo_id,
              bpo_line_id  = v_new_line_id
      WHERE   po_header_id        = int_rec.po_header_id
      AND     po_line_id          = int_rec.po_line_id
      AND     po_line_location_id = int_rec.po_line_location_id;

    ELSE  /* Else condition for BPO exist */
      /*Get bpo_line_id*/
      OPEN  bpo_line_id_cur (int_rec.po_header_id, int_rec.po_line_id,
            int_rec.po_line_location_id);
      FETCH bpo_line_id_cur INTO v_bpo_line_id;
      CLOSE bpo_line_id_cur;


      /*Updates including closed/cancel*/

      BEGIN
      UPDATE po_bpos_hdr
      SET    payvend_id              = nvl(v_pay_vendor_id,0),
             contract_no             = int_rec.contract_no, /*KYH nullable*/
             contract_value          = int_rec.contract_value,/*KYH nullable*/
             contract_currency       = nvl(int_rec.billing_currency,'USD'),
             currency_bght_fwd       = nvl(int_rec.currency_bght_fwd,0),
             contract_exchange_rate  = nvl(v_exchange_rate,1),
             mul_div_sign            = nvl(v_mul_div_sign,0),
             contract_start_date     = nvl(int_rec.contract_start_date, sysdate), /* PKU bug 1811587 */
             contract_end_date       = nvl(int_rec.contract_end_date , to_date('31-12-2010','DD-MM-YYYY')), /* PKU bug 1811587 */
             shipvend_id             = nvl(v_ship_vendor_id, 0),
             shipper_code            = int_rec.shipper_code, /*KYH nullable*/
             recv_desc               = int_rec.recv_desc,    /*KYH nullable*/
             ship_mthd               = int_rec.ship_mthd,    /*KYH nullable*/
             frtbill_mthd            = int_rec.of_frtbill_mthd,/* KYH nullable*/
             terms_code              = v_terms_code,         /*KYH nullable */
      /*     bpo_status              = nvl(v_po_status,0),*/
             bpohold_code            = int_rec.bpohold_code, /*KYH nullable*/
             cancellation_code       = int_rec.cancellation_code,/*KYH nullable*/
             closure_code            = int_rec.closure_code,/*KYH nullable*/
             activity_ind            = nvl(int_rec.activity_ind,0),
             fob_code                = v_fob_code,          /*KYH nullable */
             buyer_code              = int_rec.buyer_code,  /*KYH nullable*/
             icpurch_class           = int_rec.icpurch_class,/*KYH nullable*/
             vendso_no               = int_rec.vendso_no,   /*KYH nullable*/
             project_no              = int_rec.project_no,  /*KYH nullable*/
             date_printed            = nvl(int_rec.date_printed,sysdate),
             revision_count          = int_rec.revision_count,/*KYH nullable*/
             in_use                  = nvl(int_rec.in_use,0),
             print_count             = nvl(int_rec.print_count,0),
             creation_date           = nvl(int_rec.creation_date,sysdate),
             last_update_login       = nvl(int_rec.last_update_login,0),
             created_by              = nvl(int_rec.created_by,0),
             last_update_date        = nvl(int_rec.last_update_date,sysdate),
             last_updated_by         = nvl(int_rec.last_updated_by,0),
             delete_mark             = nvl(int_rec.delete_mark,0),
             text_code               = int_rec.text_code,   /*KYH nullable*/
             orgnaddr_id             = int_rec.orgnaddr_id  /*KYH nullable*/
      WHERE  bpo_id = v_bpo_id;
      EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_bpos_hdr');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
      END;

      BEGIN
      UPDATE po_bpos_dtl
      SET    item_id                 = nvl(v_item_id, 0),
             generic_id              = int_rec.generic_id, /* KYH nullable  */
             item_desc               = nvl(v_item_desc,' '),
             contract_value          = int_rec.contract_value,/* KYH nullable*/
             contract_qty            = int_rec.std_qty,       /* KYH nullable*/
             item_um                 = nvl(int_rec.order_um1, ' '),
             std_qty                 = nvl(int_rec.std_qty, 0),
             release_interval        = nvl(int_rec.release_interval,1),
             icpurch_class           = int_rec.icpurch_class,/* KYH 24/AUG/98*/
             bpo_status              = nvl(v_po_status,0),
             net_price               = nvl(int_rec.net_price,0),
             from_whse               = int_rec.from_whse,    /* KYH nullable*/
             to_whse                 = nvl(int_rec.to_whse,' '),
             recv_loct               = int_rec.recv_loct,    /* KYH nullable*/
             recvaddr_id             = int_rec.recvaddr_id,  /* KYH nullable*/
             recv_desc               = int_rec.recv_desc,    /* KYH nullable*/
             ship_mthd               = int_rec.ship_mthd,    /* KYH nullable*/
             shipper_code            = int_rec.shipper_code, /* KYH nullable*/
             shipvend_id             = nvl(v_ship_vendor_id,0),
             qc_grade_wanted         = int_rec.qc_grade_wanted,/* KYH nullable*/
             frtbill_mthd            = int_rec.of_frtbill_mthd,/* KYH nullable*/
             terms_code              = v_terms_code,           /* KYH nullable*/
             bpohold_code            = int_rec.bpohold_code,/* KYH nullable */
             cancellation_code       = int_rec.cancellation_code,/*KYH nullable*/
             closure_code            = int_rec.closure_code,/* KYH nullable*/
             fob_code                = v_fob_code,/*KYH nullable       */
             vendso_no               = int_rec.vendso_no,/* KYH nullable*/
             buyer_code              = int_rec.buyer_code,/* KYH nullable*/
             project_no              = int_rec.project_no,/* KYH nullable*/
             creation_date           = nvl(int_rec.creation_date,sysdate),
             last_update_login       = nvl(int_rec.last_update_login,0),
             created_by              = nvl(int_rec.created_by,0),
             last_update_date        = nvl(int_rec.last_update_date,sysdate),
             last_updated_by         = nvl(int_rec.last_updated_by,0),
             text_code               = int_rec.text_code, /* KYH nullable*/
             trans_cnt               = nvl(int_rec.trans_cnt, 1),
             max_rels_qty            = nvl(int_rec.max_rels_qty, 0),
             match_type              = nvl(int_rec.match_type,3)
      WHERE  bpo_id  = v_bpo_id
      AND    line_id = v_bpo_line_id;
      EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_bpos_dtl');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
      END;

      BEGIN
      UPDATE po_rels_sch
      SET    agreed_dlvdate          = nvl(int_rec.agreed_dlvdate, sysdate),
             line_status             = 1, /*line_status,*/
             order_qty1              = nvl(int_rec.order_qty1,0),
             order_qty2              = nvl(v_order2, 0),
             order_um1               = nvl(int_rec.order_um1,' '),
             order_um2               = v_item_um2,  /* KYH nullable*/
             from_whse               = int_rec.from_whse, /* KYH nullable*/
             to_whse                 = nvl(int_rec.to_whse,' '),
             recv_loct               = int_rec.recv_loct, /* KYH nullable*/
             recvaddr_id             = int_rec.recvaddr_id,/* KYH nullable*/
             recv_desc               = int_rec.recv_desc, /* KYH nullable*/
             ship_mthd               = int_rec.ship_mthd, /* KYH nullable*/
             shipper_code            = int_rec.shipper_code,/* KYH nullable*/
             poline_id               = NULL,
             creation_date           = nvl(int_rec.creation_date,sysdate),
             last_update_login       = nvl(int_rec.last_update_login,0),
             created_by              = nvl(int_rec.created_by,0),
             last_update_date        = nvl(int_rec.last_update_date,sysdate),
             last_updated_by         = nvl(int_rec.last_updated_by,0),
             trans_cnt               = nvl(int_rec.trans_cnt,1) + 1
       WHERE  bpoline_id = v_bpo_line_id;
       EXCEPTION
         WHEN OTHERS THEN
	   FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_rels_sch');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
       END;

       /*Only for Closing/Cancellation of line in Planned PO*/
       /*for cancelling cancellation_code = 'ORAF' */
       /*for closing cancellation_code = ' ' */
       IF int_rec.po_status IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                'CLOSED FOR INVOICE', 'FINALLY CLOSED') THEN

         UPDATE po_bpos_dtl
         SET    bpo_status        = v_po_status, /*20, */
                cancellation_code = int_rec.cancellation_code,
                trans_cnt         = trans_cnt + 1
         WHERE  bpo_id  = v_bpo_id
         AND    line_id = v_bpo_line_id;

       END IF; /* Cancel/Close of PPO. */

    END IF;  /* End of If condition for bpo_line existing*/

    UPDATE  cpg_purchasing_interface
    SET     invalid_ind         = 'P'           /*row processed*/
    WHERE   po_header_id        = int_rec.po_header_id
    AND     po_line_id          = int_rec.po_line_id
    AND     po_line_location_id = int_rec.po_line_location_id;
  END IF; /* of gemms_validate*/

  COMMIT;

  FETCH int_cur INTO int_rec;


  END LOOP;

  CLOSE   int_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
    retcode := 1;
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END cpg_bint2gms ;


END GML_SYNCH_BPOS;

/
