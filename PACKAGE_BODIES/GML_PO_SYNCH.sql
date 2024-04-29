--------------------------------------------------------
--  DDL for Package Body GML_PO_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_SYNCH" AS
/* $Header: GMLPOSYB.pls 120.1 2005/06/21 00:19:19 appldev ship $ */

v_lang  VARCHAR2(10) := 'ENG';

/*============================================================================+
|                                                                             |
| PROCEDURE NAME        next_po_id                                            |
|                                                                             |
| DESCRIPTION           Procedure to get the next available GEMMS po_id       |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   10/15/97     Rajeshwari Chellam     created                               |
|   14-MAY-98    T Ricci         replaced sy_surg_ctl with nextval from       |
|                                sys.dual for GEMMS 5.0                       |
|                                                                             |
+============================================================================*/

-- yannamal GSCC b4403407
PROCEDURE next_po_id ( new_po_id   OUT  NOCOPY PO_ORDR_HDR.PO_ID%TYPE,
                       p_doc_type  IN   VARCHAR2,
                       p_orgn_code IN   VARCHAR2,
                       v_next_id_status OUT NOCOPY BOOLEAN)
AS
 /*  CURSOR NPO_ID_CUR IS
    SELECT last_value + 1
    FROM   sy_surg_ctl
    WHERE  key_name = 'po_id'
    FOR    UPDATE;*/

  CURSOR NPO_ID_CUR IS
    SELECT GEM5_PO_ID_s.nextval
    FROM   sys.dual;

  err_msg  VARCHAR2(100);

BEGIN

  OPEN   npo_id_cur;
  FETCH  npo_id_cur INTO new_po_id;

  /* UPDATE sy_surg_ctl
  SET    last_value = new_po_id
  WHERE  current of npo_id_cur; */

  UPDATE sy_docs_seq
  SET    last_assigned = last_assigned + 1
  WHERE  doc_type      = p_doc_type
  AND    orgn_code     = p_orgn_code;

  CLOSE  npo_id_cur;
  v_next_id_status :=TRUE;

EXCEPTION
   WHEN OTHERS THEN
     v_next_id_status := FALSE;
END next_po_id;

/*============================================================================+
|                                                                             |
| PROCEDURE NAME        next_line_id                                          |
|                                                                             |
| DESCRIPTION           Procedure to get the next available GEMMS line_id     |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   10/15/97     Rajeshwari Chellam     created                               |
|   14-MAY-98    T Ricci         replaced sy_surg_ctl with nextval from       |
|                                sys.dual for GEMMS 5.0                       |
|   23-OCT-98    T Ricci         added IN parm line_type                      |
|                                                                             |
+============================================================================*/

PROCEDURE next_line_id
(line_type   IN VARCHAR2,new_line_id    OUT NOCOPY PO_ORDR_DTL.LINE_ID%TYPE,
 v_next_id_status OUT NOCOPY BOOLEAN) -- yannamal GSCC b4403407
AS

  /* CURSOR nline_id_cur IS
    SELECT last_value + 1
    FROM   sy_surg_ctl
    WHERE  key_name = 'line_id'
    FOR    UPDATE; */

  CURSOR npoline_id_cur IS
    SELECT GEM5_PO_LINE_ID_s.nextval
    FROM   sys.dual;

  CURSOR nbpoline_id_cur IS
    SELECT GEM5_BPO_LINE_ID_s.nextval
    FROM   sys.dual;

  err_msg  VARCHAR2(100);

BEGIN

  IF line_type = 'PO' THEN
    OPEN   npoline_id_cur;

    FETCH  npoline_id_cur INTO new_line_id;

    CLOSE  npoline_id_cur;
    v_next_id_status :=TRUE;

  ELSIF line_type = 'BPO' THEN
    OPEN   nbpoline_id_cur;

    FETCH  nbpoline_id_cur INTO new_line_id;

    CLOSE  nbpoline_id_cur;
    v_next_id_status :=TRUE;
  ELSE
    v_next_id_status :=FALSE;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    v_next_id_status :=FALSE;

END next_line_id;


/*============================================================================+
|                                                                             |
|                                                                             |
| PROCEDURE NAME        next_trans_id                                         |
|                                                                             |
| DESCRIPTION           Procedure to get the next available GEMMS trans_id    |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   10/22/97     Kenny Jiang    created                                       |
|   14-MAY-98    T Ricci        replaced sy_surg_ctl with nextval from        |
|                               sys.dual for GEMMS 5.0                        |
|                                                                             |
+============================================================================*/

PROCEDURE next_trans_id
(v_new_trans_id         OUT  NOCOPY   IC_TRAN_PND.TRANS_ID%TYPE,
 v_next_id_status       OUT   NOCOPY  BOOLEAN) -- yannamal GSCC b4403407
AS

  /* CURSOR NTRANS_ID_CUR IS
    SELECT last_value + 1
    FROM   sy_surg_ctl
    WHERE  key_name = 'trans_id'
    FOR    UPDATE; */

  CURSOR NTRANS_ID_CUR IS
    SELECT GEM5_TRANS_ID_s.nextval
    FROM   sys.dual;

  err_msg  VARCHAR2(100);

BEGIN

  OPEN   ntrans_id_cur;
  FETCH  ntrans_id_cur INTO v_new_trans_id;

  /* UPDATE sy_surg_ctl
  SET    last_value = v_new_trans_id
  WHERE  current of ntrans_id_cur; */

  CLOSE  ntrans_id_cur;
  v_next_id_status :=TRUE;

EXCEPTION

  WHEN OTHERS THEN
    v_next_id_status := FALSE;

END next_trans_id;


/*============================================================================+
|                                                                             |
|                                                                             |
| FUNCTION NAME      new_po_hdr                                               |
|                                                                             |
| DESCRIPTION                                                                 |
|                    function to check if the given PO already exists in GEMMS|
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    10/22/97           Kenny Jiang     created                               |
|    18-JUL-98          Liz Enstone     GEMMS 5.0 Include orgn_code in select |
|                                                                             |
+============================================================================*/

FUNCTION        new_po_hdr
(v_po_no        IN      PO_ORDR_HDR.PO_NO%TYPE,
 v_orgn_code    IN      CPG_PURCHASING_INTERFACE.ORGN_CODE%TYPE)
RETURN  BOOLEAN
IS
  v_row_count   NUMBER :=0;
  err_msg       VARCHAR2(100);

BEGIN
  SELECT COUNT(*)
  INTO   v_row_count
  FROM   po_ordr_hdr
  WHERE  po_no = v_po_no
  AND    orgn_code = v_orgn_code;

  IF  v_row_count > 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION

  WHEN  OTHERS  THEN
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END new_po_hdr;


/*============================================================================+
|                                                                             |
|                                                                             |
| FUNCTION  NAME        new_line                                              |
|                                                                             |
| DESCRIPTION           function to check if the record in the interface table|
|                       is the submission of a new line location              |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    10/27/97           Kenny Jiang     created                               |
|                                                                             |
+============================================================================*/

FUNCTION  new_line
( v_po_header_id        IN  NUMBER,
  v_po_line_id          IN  NUMBER,
  v_po_line_location_id IN  NUMBER )

RETURN  BOOLEAN
IS

  CURSOR id_cur(header NUMBER, line NUMBER, location NUMBER) IS
  SELECT po_id, line_id
  FROM   cpg_oragems_mapping
  WHERE  po_header_id        = header
  AND    po_line_id          = line
  AND    po_line_location_id = location;

  id_rec        id_cur%ROWTYPE;
  err_msg       VARCHAR2(100);

BEGIN

  OPEN  id_cur(v_po_header_id, v_po_line_id, v_po_line_location_id);
  FETCH id_cur INTO id_rec;

  IF (id_rec.po_id IS NULL AND id_rec.line_id IS NULL)  THEN
    RETURN TRUE;
  ELSIF (id_rec.po_id IS NOT NULL AND id_rec.line_id IS NOT NULL) THEN
    RETURN FALSE;
  END IF;

  CLOSE id_cur;

EXCEPTION

  WHEN OTHERS THEN
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END new_line;

/*============================================================================+
|                                                                             |
| FUNCTION  NAME        get_line_no                                           |
|                                                                             |
| DESCRIPTION           function to get the maximum line number so far        |
|                       for a particular PO                                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    10/27/97           Kenny Jiang     created                               |
|    03/24/00   NC - modified the procedure to accept  po_line_id instead of
|                    po_id and return line_num from po_lines all instead of the
|                    max(line_no) from po_ordr_dtl.TAR #12693733.6
|                   (Bug#1249797 base bug#1247332.
|    15/05/00   NC - Added code to take care of line numbering for Planned and|
|                    Blanket POS and in case of more than one shipment per    |
|                    line.Added new parameters.                               |
+============================================================================*/

FUNCTION get_line_no(v_po_id IN NUMBER ,
                        v_po_header_id IN NUMBER,
                        v_po_line_id IN NUMBER,
                        v_po_line_location_id IN NUMBER,
                        v_transaction_type IN VARCHAR2) RETURN NUMBER
IS
  v_line_no             NUMBER;
  v_line_count          NUMBER;
  v_shipment_count      NUMBER;
  err_msg               VARCHAR2(100);

BEGIN

  /* If it is a blanket or a planned purchase order we'll retain the line
     number from apps.  */

  IF v_transaction_type in ( 'BLANKET','PLANNED') THEN
     SELECT shipment_num
     INTO v_line_no
     FROM po_line_locations_all
     WHERE line_location_id = v_po_line_location_id;

  /* If it is a standard PO, we'll retain the line number from apps as long as
     there is only one shipment per line.We'll generate a number if there is
     more than one shipment per line */

  ELSE /* STANDARD */
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
        INTO   v_line_no
        FROM   po_lines_all
        WHERE  po_line_id = v_po_line_id;
     ELSE
        SELECT NVL(MAX(line_no),0) +1
        INTO   v_line_no
        FROM   po_ordr_dtl
        WHERE  po_id = v_po_id;
     END IF;

  END IF;

  RETURN v_line_no;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;

  WHEN OTHERS THEN
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END get_line_no;


/*============================================================================+
|                                                                             |
|                                                                             |
| PROCEDURE NAME        errlog_header                                         |
|                                                                             |
| DESCRIPTION           procedure to print the header for this shipment       |
|                       in the error log                                      |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    11/19/97           Kenny Jiang     created                               |
|    05/12/98           Tony Ricci      changed date modified to              |
|                                       last_update_date for GEMMS 5.0        |
|    04/15/99           Hasan Wahdani added app_date to v_last_update_date    |
+============================================================================*/


PROCEDURE errlog_header(
  v_po_no               IN VARCHAR2,
  v_line_num            IN NUMBER,
  v_shipment_num        IN NUMBER,
  v_revision_count      IN NUMBER,
  v_last_update_date    IN DATE)
IS
  err_msg               VARCHAR2(100);

BEGIN

/* H. Wahdani removed format from v_last_update_date and placed a call to fnd_date.date_tocharDT */

  FND_FILE.NEW_LINE(FND_FILE.LOG, 2 );
  FND_FILE.PUT_LINE(FND_FILE.LOG,
  '------------------------------------------------------------------------');
  FND_FILE.PUT_LINE(FND_FILE.LOG,
                'PO: ' ||v_po_no || 'Line: '||TO_CHAR(v_line_num) || ' Shipment:
 '|| TO_CHAR(v_shipment_num)||' Revision: '||TO_CHAR(v_revision_count)|| ' Time:
 '|| fnd_date.date_to_charDT(v_last_update_date));
  FND_FILE.PUT_LINE(FND_FILE.LOG,
  '-------------------------------------------------------------------------');

EXCEPTION

  WHEN OTHERS THEN
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END errlog_header;

/*============================================================================+
|                                                                             |
| PROCEDURE  NAME       cpg_conv_duom                                         |
|                                                                             |
| DESCRIPTION           Procedure to calculate order qty in dual UOM          |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    11/21/97           Kenny Jiang     created                               |
|                                                                             |
+============================================================================*/

PROCEDURE cpg_conv_duom
( v_item_id  IN   NUMBER,
  v_um1      IN   VARCHAR2,
  v_order1   IN   NUMBER,
  v_um2      IN   VARCHAR2,
  v_order2   OUT NOCOPY NUMBER) -- yannamal GSCC b4403407
IS
  CURSOR  uom_mst_cur(v_um VARCHAR2) IS
    SELECT  std_factor, um_type
    FROM    sy_uoms_mst
    WHERE   um_code = v_um;

  CURSOR tf_cur(v_um_type VARCHAR2) IS
    SELECT type_factor
    FROM   ic_item_cnv
    WHERE  item_id = v_item_id
    AND    um_type = v_um_type;

  CURSOR item_cur IS
    SELECT item_um
    FROM   ic_item_mst
    WHERE  item_id = v_item_id;

  v_std_factor1   NUMBER;
  v_std_factor2   NUMBER;
  v_type1         VARCHAR2(4);
  v_type2         VARCHAR2(4);
  v_std_factor    NUMBER;
  v_type          VARCHAR2(4);
  v_type_factor02 NUMBER;
  v_type_factor01 NUMBER;

  v_um            VARCHAR2(4);

  err_num         NUMBER;
  err_msg         VARCHAR2(100);

BEGIN

  IF v_um2 IS NULL THEN
    v_order2 := NULL;

  ELSE

    OPEN  uom_mst_cur(v_um1);
    FETCH uom_mst_cur INTO v_std_factor1, v_type1;
    CLOSE uom_mst_cur;

    OPEN  uom_mst_cur(v_um2);
    FETCH uom_mst_cur INTO v_std_factor2, v_type2;
    CLOSE uom_mst_cur;

    OPEN item_cur;
    FETCH item_cur INTO v_um;
    CLOSE item_cur;

    OPEN  uom_mst_cur(v_um);
    FETCH uom_mst_cur INTO v_std_factor, v_type;
    CLOSE uom_mst_cur;

    OPEN  tf_cur(v_um1);
    FETCH tf_cur INTO v_type_factor01;
    CLOSE tf_cur;

    OPEN  tf_cur(v_um2);
    FETCH tf_cur INTO v_type_factor02;
    CLOSE tf_cur;

    IF v_type1 = v_type2 THEN
      v_order2 := v_order1 * v_std_factor1 / v_std_factor2;

    ELSIF  v_type = v_type1 THEN
      v_order2 := v_order1 * v_std_factor1 / v_type_factor02 / v_std_factor2;

    ELSE
      v_order2 := v_order1 * v_std_factor1 / v_std_factor2 * v_type_factor01
                  / v_type_factor02;
    END IF;

  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END cpg_conv_duom;

/*============================================================================+
|                                                                             |
| FUNCTION  NAME        gemms_validate                                        |
|                                                                             |
| DESCRIPTION           function to validate all the necessary values in      |
|                       each row of the purchasing interface table            |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    10/27/97           Kenny Jiang     created                               |
|    05/12/98           Tony Ricci      changed date modified to              |
|                                       last_update_datefor GEMMS 5.0         |
|                                                                             |
+============================================================================*/


FUNCTION gemms_validate
( v_orgn_code            IN  VARCHAR2,
  v_of_payvend_site_id   IN  NUMBER,
  v_of_shipvend_site_id  IN  NUMBER,
  v_to_whse              IN  VARCHAR2,
  v_billing_currency     IN  VARCHAR2,
  v_item_no              IN  VARCHAR2,
  v_order_um1            IN  VARCHAR2,
  v_price_um             IN  VARCHAR2,
  v_order_um2            IN  VARCHAR2,
  v_item_um              IN  VARCHAR2,
  v_buyer_code           IN  VARCHAR2,
  v_from_whse            IN  VARCHAR2,
  v_shipper_code         IN  VARCHAR2,
  v_of_frtbill_mthd      IN  VARCHAR2,
  v_of_terms_code        IN  VARCHAR2,
  v_qc_grade_wanted      IN  VARCHAR2,
  v_po_no                IN  VARCHAR2,
  v_line_id              IN  NUMBER,
  v_line_location_id     IN  NUMBER,
  v_revision_count       IN  NUMBER,
  v_last_update_date        IN  DATE)

RETURN BOOLEAN
IS
  v_result        BOOLEAN := TRUE;
  v_co_code           SY_ORGN_MST.CO_CODE%TYPE;
  v_line_num      NUMBER;
  v_shipment_num  NUMBER;

  CURSOR co_code_cur(v_orgn_code SY_ORGN_MST.ORGN_CODE%TYPE) IS
    SELECT co_code
    FROM   sy_orgn_mst
    WHERE  orgn_code = v_orgn_code;

  CURSOR line_no_cur IS
    SELECT line_num
    FROM   po_lines_all
    WHERE  po_line_id = v_line_id;

  CURSOR shipment_cur IS
    SELECT shipment_num
    FROM   po_line_locations_all
    WHERE  line_location_id = v_line_location_id;

  v_err_message   VARCHAR2(2000);

  err_num         NUMBER;
  err_msg         VARCHAR2(100);

BEGIN

  OPEN  co_code_cur(v_orgn_code);
  FETCH co_code_cur
        INTO  v_co_code;
  CLOSE co_code_cur;

  OPEN   shipment_cur;
  FETCH  shipment_cur
  INTO   v_shipment_num;
  CLOSE  shipment_cur;

  OPEN   line_no_cur;
  FETCH  line_no_cur
  INTO   v_line_num;
  CLOSE  line_no_cur;

  /* These are mandatory fields*/

  /* Validate the GEMMS Organization on the Purchase Order */

  IF (v_orgn_code IS NULL) OR
     (GML_VALIDATE_PO.val_orgn_code(v_orgn_code) = FALSE) THEN

    IF v_result = TRUE  THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_ORG');
      FND_MESSAGE.set_token('v_orgn_code',v_orgn_code);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;
  END IF;


  IF (v_of_payvend_site_id IS NULL) OR
     (GML_VALIDATE_PO.val_vendor(v_of_payvend_site_id, v_co_code) = FALSE) THEN

    IF v_result = TRUE  THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_PAY_VEND');
      FND_MESSAGE.set_token('v_of_payvend_site_id',v_of_payvend_site_id);
      v_err_message := FND_MESSAGE.GET;

      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

      v_result := FALSE;
  END IF;

   IF (v_of_shipvend_site_id IS NULL) OR
   (GML_VALIDATE_PO.val_vendor(v_of_shipvend_site_id, v_co_code) = FALSE) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_SHIP_VEND');
      FND_MESSAGE.set_token('v_of_shipvend_site_id',v_of_shipvend_site_id);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;
  END IF;

  IF (v_to_whse IS NULL) OR (v_to_whse = ' ')  OR
     (GML_VALIDATE_PO.val_warehouse(v_to_whse,v_orgn_code) = FALSE)  THEN


    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_TO_WHSE');
      FND_MESSAGE.set_token('v_to_whse',v_to_whse);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;
  END IF;

  IF  (v_billing_currency  IS NULL) OR (v_billing_currency = ' ')  OR
      (GML_VALIDATE_PO.val_currency (v_billing_currency)=FALSE) THEN

    IF v_result = TRUE THEN   /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_BILL_CURR');
      FND_MESSAGE.set_token('v_billing_currency',v_billing_currency);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_item_no IS NULL) OR (v_item_no = ' ') OR
      (GML_VALIDATE_PO.val_item (v_item_no) = FALSE)  THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_ITEM');
      FND_MESSAGE.set_token('v_item_no',v_item_no);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_order_um1 IS NULL) OR (v_order_um1 = ' ') OR
      (GML_VALIDATE_PO.val_uom (v_order_um1) = FALSE) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_UM1');
      FND_MESSAGE.set_token('v_order_um1',v_order_um1);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_price_um  IS NULL) OR (v_price_um    = ' ') OR
      (GML_VALIDATE_PO.val_uom (v_price_um)=FALSE)  THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_PRICE');
      FND_MESSAGE.set_token('v_price_um',v_price_um);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  /* all the following are not mandatory*/

  IF  (v_order_um2 IS NOT NULL)  AND (v_order_um2   <> ' ')  AND
      (GML_VALIDATE_PO.val_uom( v_order_um2) = FALSE ) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_UM2');
      FND_MESSAGE.set_token('v_order_um2',v_order_um2);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_item_um  IS NOT NULL)  AND (v_item_um   <> ' ')  AND
      (GML_VALIDATE_PO.val_uom( v_item_um) = FALSE) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_ITEM_UM');
      FND_MESSAGE.set_token('v_item_um',v_item_um);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_from_whse  IS NOT NULL)  AND (v_from_whse <> ' ') AND
      (GML_VALIDATE_PO.val_warehouse(v_from_whse,v_orgn_code) = FALSE)  THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_FROM_WHSE');
      FND_MESSAGE.set_token('v_from_whse',v_from_whse);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_shipper_code IS NOT NULL)  AND (v_shipper_code <> ' ')  AND
      (GML_VALIDATE_PO.val_shipper_code(v_shipper_code)= FALSE ) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_SHIPPER');
      FND_MESSAGE.set_token('v_shipper_code',v_shipper_code);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_of_frtbill_mthd  IS NOT NULL) AND (v_of_frtbill_mthd <> ' ')  AND
      (GML_VALIDATE_PO.val_frtbill_mthd( v_of_frtbill_mthd) = FALSE ) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_FRTB');
      FND_MESSAGE.set_token('v_of_frtbill_mthd',v_of_frtbill_mthd);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  IF  (v_of_terms_code IS NOT NULL)  AND (v_of_terms_code <> ' ')  AND
      (GML_VALIDATE_PO.val_terms_code(v_of_terms_code) = FALSE ) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_TERMS');
      FND_MESSAGE.set_token('v_of_terms_code',v_of_terms_code);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  /* Validate the qc_grade_wanted*/

  IF  (v_qc_grade_wanted IS NOT NULL)  AND (v_qc_grade_wanted <> ' ')  AND
      (GML_VALIDATE_PO.val_qc_grade_wanted(v_qc_grade_wanted) = FALSE ) THEN

    IF v_result = TRUE THEN    /*if this is the first validation error*/
      GML_PO_SYNCH.errlog_header( v_po_no, v_line_num, v_shipment_num,
                                 v_revision_count, v_last_update_date);
    END IF;

      FND_MESSAGE.set_name('GML', 'PO_BAD_QC');
      FND_MESSAGE.set_token('v_qc_grade_wanted',v_qc_grade_wanted);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      v_result := FALSE;

  END IF;

  RETURN v_result;

EXCEPTION
   WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END gemms_validate;


/*=============================================================================+
|                                                                               |
|                                                                               |
|  FUNCTION     Get_total_Received_qty                                          |
|                                                                               |
|  DESCRIPTION         procedure to get the total received quantity against a po|
|                      line where the receipt is not voided or deleted and then |
|                      Convert the received quantity to the base uom of the item|
| MODIFICATION HISTORY                                                          |
|    07/05/2000         Preetam Bamb         created                            |
|                                                                               |
|    Uday Phadtare B1845881 deduct return qty from received qty to get correct  |
|      total received qty                                                       |
+==============================================================================*/

FUNCTION Get_total_Received_qty(p_po_id IN NUMBER, p_line_id IN NUMBER,p_item_id IN NUMBER,item_um1 IN VARCHAR2)
RETURN NUMBER
IS

 cursor total_rcvd_qty_cur IS
 Select sum(recv_qty1) qty,RECV_UM1
 from   po_Recv_dtl d
 where  po_id           = p_po_id
 and    poline_id       = p_line_id
 and    recv_status     <> -1
 group by recv_um1;

 /* Uday Phadtare BB1845881 */
 cursor total_rtrn_qty_cur IS
 Select sum(d.return_qty1) qty, d.RETURN_UM1
 from   po_Rtrn_hdr h,
        po_Rtrn_dtl d
 where  h.return_id     = d.return_id
 and    d.po_id         = p_po_id
 and    d.poline_id     = p_line_id
 and    h.delete_mark   <> -1
 group by d.return_um1;

 v_total_rcvd_qty       NUMBER  :=0;
 v_total_rtrn_qty       NUMBER  :=0;
 v_rcvd_qty             NUMBER  :=0;
 v_return_qty           NUMBER  :=0;

 BEGIN

        for tot_rec in total_rcvd_qty_cur
        loop
                if tot_rec.recv_um1 = item_um1
                then
                        v_total_rcvd_qty := v_total_rcvd_qty + nvl(tot_rec.qty,0);
                else
                        v_rcvd_qty := GMICUOM.uom_conversion
                                        (p_item_id,0,
                                         tot_rec.qty,
                                         tot_rec.recv_um1,
                                         item_um1,0);

                        v_total_rcvd_qty := v_total_rcvd_qty + nvl(v_rcvd_qty,0);
                end if;

        end loop;

        /* Uday Phadtare BB1845881 */
        for tot_ret in total_rtrn_qty_cur
        loop
                if tot_ret.return_um1 = item_um1
                then
                        v_total_rtrn_qty := v_total_rtrn_qty + nvl(tot_ret.qty,0);
                else
                        v_return_qty := GMICUOM.uom_conversion
                                        (p_item_id,0,
                                         tot_ret.qty,
                                         tot_ret.return_um1,
                                         item_um1,0);

                        v_total_rtrn_qty := v_total_rtrn_qty + nvl(v_return_qty,0);
                end if;

        end loop;

  RETURN        nvl(v_total_rcvd_qty,0) - nvl(v_total_rtrn_qty,0);

 END;



/*============================================================================+
|                                                                             |
|                                                                             |
| FUNCTION  NAME        new_aqcst_line                                        |
|                                                                             |
| DESCRIPTION           This function checks if the given aquisition cost line|
|                       already exists for the shipment on GEMMS              |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    11/6/97            Kenny Jiang     created                               |
|                                                                             |
+============================================================================*/


FUNCTION new_aqcst_line
( v_type     VARCHAR2,
  v_pos_id   NUMBER,
  v_line_id  NUMBER,
  v_cost_id  NUMBER)

RETURN BOOLEAN
IS
  CURSOR cost_line_cur IS
    SELECT cost_amount
    FROM   po_cost_dtl
    WHERE  doc_type     = v_type
    AND    pos_id       = v_pos_id
    AND    line_id      = v_line_id
    AND    aqui_cost_id = v_cost_id
    AND    delete_mark  = 0;

  v_amount NUMBER;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN
  OPEN  cost_line_cur;
  FETCH cost_line_cur
  INTO  v_amount;
  CLOSE cost_line_cur;

  IF v_amount IS NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END new_aqcst_line;


/*============================================================================+
|                                                                             |
|                                                                             |
| PROCEDURE NAME        cpg_aqcst_mv                                          |
|                                                                             |
| DESCRIPTION           This procedure moves the acquisition cost information |
|                       from Oracle to Gemms                                  |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    11/3/97            Kenny Jiang     created                               |
|    11/10/98           Tony Ricci      set trans_cnt on insert to '0' as per |
|                                       OPM 11.0                              |
|                                                                             |
+============================================================================*/

PROCEDURE cpg_aqcst_mv
( v_po_header_id     IN NUMBER,
  v_po_line_id       IN NUMBER,
  v_line_location_id IN NUMBER,
  v_po_id            IN NUMBER,
  v_line_id          IN NUMBER,
  v_doc_type         IN VARCHAR2,
  v_aqcst_status     OUT NOCOPY BOOLEAN) -- yannamal GSCC b4403407
IS
  CURSOR aqcst_cur IS
    SELECT aqui_cost_id,      cost_amount,      incl_ind,
           last_update_date,  created_by, creation_date, last_updated_by,
           last_update_login
    FROM   cpg_cost_dtl
    WHERE  po_header_id     = v_po_header_id
    AND    po_line_id       = v_po_line_id
    AND    line_location_id = v_line_location_id;

  CURSOR gemms_acq_cur  IS
    SELECT aqui_cost_id, cost_amount
    FROM   po_cost_dtl a
    WHERE  pos_id   = v_po_id
    AND    line_id  = v_line_id
    AND    NOT EXISTS (SELECT 'Y'
                       FROM   cpg_cost_dtl b
                       WHERE  b.po_header_id     = v_po_header_id
                       AND    b.po_line_id       = v_po_line_id
                       AND    b.line_location_id = v_line_location_id
                       AND    b.aqui_cost_id     = a.aqui_cost_id
                       AND    b.cost_amount      = a.cost_amount);

  invalid_action EXCEPTION;

  v_new_aqcst_line BOOLEAN;
  p_aqui_cost_id   NUMBER;
  p_cost_amount    NUMBER;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN


  FOR aqcst_rec IN aqcst_cur LOOP

    v_new_aqcst_line := GML_PO_SYNCH.new_aqcst_line
                        (v_doc_type,v_po_id, v_line_id, aqcst_rec.aqui_cost_id);
  /* T. Ricci 5/12/98 GEMMS 5.0 changes for who columns*/

    IF v_new_aqcst_line THEN
      INSERT INTO po_cost_dtl
      (
        doc_type,
        pos_id,
        line_id,
        aqui_cost_id,
        cost_amount,
        incl_ind,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        text_code,
        trans_cnt,
        delete_mark
      )
      VALUES
      ( v_doc_type,
        v_po_id,
        v_line_id,
        aqcst_rec.aqui_cost_id,
        aqcst_rec.cost_amount,
        aqcst_rec.incl_ind,
        aqcst_rec.last_update_date,
        aqcst_rec.last_updated_by,
        aqcst_rec.last_update_login,
        aqcst_rec.created_by,
        aqcst_rec.creation_date,
        NULL,
        0,                     /* T. Ricci 11/10/98 set trans_cnt to '0'*/
        0
      );

    ELSE

      UPDATE po_cost_dtl
      SET    cost_amount   = aqcst_rec.cost_amount,
             incl_ind      = aqcst_rec.incl_ind,
             last_update_date = aqcst_rec.last_update_date
      WHERE  doc_type      = v_doc_type
      AND    pos_id        = v_po_id
      AND    line_id       = v_line_id
      AND    aqui_cost_id  = aqcst_rec.aqui_cost_id;

    END IF;

END LOOP;

/*Commenting out the following code as its not clear what its doing - Preetam Bamb */
/*
    OPEN gemms_acq_cur;
    LOOP
      FETCH gemms_acq_cur INTO p_aqui_cost_id, p_cost_amount;
      EXIT  WHEN gemms_acq_cur%NOTFOUND;
      UPDATE po_cost_dtl
      SET    delete_mark = 1
      WHERE  pos_id = v_po_id
      AND    line_id = v_line_id
      AND    aqui_cost_id = p_aqui_cost_id
      AND    cost_amount = p_cost_amount;
    END LOOP;
    CLOSE gemms_acq_cur;
*/


  v_aqcst_status :=TRUE;

EXCEPTION

  WHEN OTHERS THEN
     v_aqcst_status :=FALSE;
    err_num := SQLCODE;
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END cpg_aqcst_mv;



 /*=============================================================================+
|                                                                               |
|                                                                               |
|  PROCEDURE    Update_header_status                                            |
|                                                                               |
|  DESCRIPTION  procedure to update the header status to close or calcel        |
|               in case where the po has                                        |
|               only one line and that line is closed or calcelled or all the   |
|               lines are closed or cancelled.                                  |
| MODIFICATION HISTORY                                                          |
|    07/26/2000         Preetam Bamb         created                            |
|                                                                               |
|                                                                               |
|                                                                               |
|   11/15/2001 Uday Phadtare  B2068007 procedure Update_header_status. Cancel the PO
|                             header only if all PO lines are cancelled.
+==============================================================================*/

PROCEDURE Update_header_status(p_po_id IN NUMBER,p_cancellation_code IN VARCHAR2)
IS

 cursor total_lines_cur IS
 Select count(*)
 From   cpg_oragems_mapping
 Where  po_id   = p_po_id;

 Cursor get_line_status IS
 Select po_status
 From   po_ordr_dtl
 Where  po_id           = p_po_id
 and    po_status       = 0;

 Cursor get_uncancelled_lines IS
 Select count(*)
 From   po_ordr_dtl
 Where  po_id           = p_po_id
 and    cancellation_code IS NULL;

 v_total_lines          NUMBER  :=0 ;
 v_po_status            NUMBER  :=0;
 v_count                NUMBER  :=0;
 v_cancellation_code PO_ORDR_DTL.CANCELLATION_CODE%TYPE := p_cancellation_code;

 BEGIN

        Open    total_lines_cur;
        Fetch   total_lines_cur into v_total_lines;
        Close   total_lines_cur;

        IF      v_total_lines = 1
        THEN
                update  po_ordr_hdr
                set     po_status               = 20,
                        cancellation_code       = p_cancellation_code
                where   po_id                   = p_po_id;
        ELSE
                OPEN    get_line_status;
                FETCH   get_line_status into v_po_status;
                IF      get_line_status%FOUND
                THEN
                        CLOSE   get_line_status;
                ELSE
                        CLOSE   get_line_status;
                          IF v_cancellation_code IS NOT NULL THEN
                             OPEN    get_uncancelled_lines;
                             FETCH   get_uncancelled_lines INTO v_count;
                             CLOSE   get_uncancelled_lines;
                             IF v_count > 0 THEN
                                v_cancellation_code := NULL;
                             END IF;
                          END IF;
                          update    po_ordr_hdr
                          set       po_status           = 20,
                                    cancellation_code   = v_cancellation_code
                          where     po_id               = p_po_id;
                END IF; /* %FOUND */
        END IF; /*v_total_lines = 1 */

 END;


/*============================================================================+
|                                                                             |
| PROCEDURE NAME       cpg_int2gms                                            |
|                                                                             |
| DESCRIPTION          procedure to move records from the purchasing interface|
|                      table to the gemms base tables                         |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    10/22/97           Kenny Jiang          created                          |
|    11/01/97           Rajeshwari Chellam   modified for bpo/ppo releases    |
|    05/12/98           Tony Ricci           GEMMS 5.0 database changes       |
|    07/06/98           Tony Ricci           GEMMS 5.0 integrity constraint   |
|                                            changes where NULL is allowed    |
|                                            insert one.                      |
|   17/AUG/98           KYH                  Replace hard coded values with   |
|                                            appropriate system constants     |
|   03/NOV/98           Tony Ricci           added calls to                   |
|                                            GML_PO_GLDIST.receive_data to |
|                                            perform GL mapping               |
|   06/NOV/98           Tony Ricci           removed call to GML_PO_SYNCH.    |
|                                            cpg_conv_duom and replaced with  |
|                                            GMICUOM.icuomcv which is the OPM |
|                                            standard uom conversion          |
|    11/10/98           Tony Ricci           set trans_cnt on insert to '0'   |
|                                            as per OPM 11.0                  |
|    11/10/98           Tony Ricci           added frtbill_mthd_cur so OPM    |
|                                            value will be used               |
|    11/11/98           Tony Ricci           removed fob_code_cur so OPM      |
|                                            value will be used (already in   |
|                                            int_rec.fob_code                 |
|    11/24/98           Tony Ricci           added call to GMICCAL.trans_date |
|                                            _validate to check for a valid   |
|                                            Inventory calendar               |
|    02/04/99           Tony Ricci           use correct variable for um2     |
|                                            when inserting/updating          |
|                                            ic_tran_pnd BUG#814841           |
|    04/19/00           N Chekuri            Added appropriate error messages |
|                                            for Inventory calendar validation|
|                                            routine GMICAL.trans_date_validate
|                                            ().Bug#1274130.                  |
|    14/18/2001         Pushkar Upakare      In ic_tran_pnd(TRANS_UM)         |
|                                            inserted primary UOM instead of  |
|                                            order UOM.                       |
|    05/21/2001         Uday Phadtare  B1795095 In ic_tran_pnd set delete_mark|
|                                            to 1 if po is closed and set to  |
|                                            if PO is opened.                 |
|    05/22/2001         P. Arvind Dath       Added code to synch Attributes to|
|                                            OPM                              |
|    06/28/2001         Pushkar Upakare Bug 1854280                           |
|                                            BPO table updates are corrected. |
|    10/12/01           V. Ajay Kumar   BUG#2041468 Modified the update       |
|                                                   statement to get the PO   |
|                                                   numbers in the LOV for PO |
|                                                   NUMBER field in Receipt   |
|                                                   Selection Screen.         |
|    11/13/2001         Pushkar Upakare Bug 2031029                           |
|                                            Exclude PPO template record from |
|                                            being picked up in int_cur cursor|
|    06/27/2003         Mohit Kapoor    Bug 3019986                           |
|                                            Made the insertion/updation of   |
|                                            ic_summ_inv conditional, only if |
|                                            the table exists                 |
+============================================================================*/

PROCEDURE cpg_int2gms( retcode out Nocopy number) -- yannamal GSCC b4403407
IS

/* T. Ricci 5/12/98 removed user_class and added new who columns*/

  CURSOR int_cur  IS
  SELECT rowid,
         item_um,
         transaction_id,
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
  FROM   cpg_purchasing_interface
  WHERE  invalid_ind ='N'
  AND    (transaction_type IN ('STANDARD','BLANKET')   /* Bug 2031029 - Do not select TEMPLATE PPOs */
          OR
          (transaction_type = 'PLANNED' AND nvl(po_release_id,0) <> 0 AND nvl(release_num,0) <> 0)
         )
  ORDER BY transaction_id;

  int_rec int_cur%ROWTYPE;

  /* BEGIN BUG#1731582 P. Arvind Dath */

  CURSOR attr_hdr_cur(v_po_ordr_header_id PO_HEADERS_ALL.PO_HEADER_ID%TYPE)
  IS
  SELECT attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14
  FROM   PO_HEADERS_ALL
  WHERE  PO_HEADER_ID = v_po_ordr_header_id;

  CURSOR attr_dtl_cur(v_line_locations_id PO_LINE_LOCATIONS_ALL.LINE_LOCATION_ID%TYPE,
                                          v_ordr_header_id PO_LINE_LOCATIONS_ALL.PO_HEADER_ID%TYPE,
                                          v_po_line_id PO_LINE_LOCATIONS_ALL.PO_LINE_ID%TYPE)
  IS
  SELECT attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15
  FROM   PO_LINE_LOCATIONS_ALL
  WHERE  LINE_LOCATION_ID = v_line_locations_id
  AND    PO_HEADER_ID = v_ordr_header_id
  AND    PO_LINE_ID = v_po_line_id;

  attr_hdr_rec attr_hdr_cur%ROWTYPE;
  attr_dtl_rec attr_dtl_cur%ROWTYPE;

  /* END BUG#1731582 */

    /* Uday Phadtare B2085936 */
  CURSOR po_lines_all_cur
     (  v_ordr_header_id PO_LINE_LOCATIONS_ALL.PO_HEADER_ID%TYPE,
        v_line_id PO_LINES_ALL.po_line_id%TYPE) IS
  SELECT substrb(item_description,1,70)
    FROM po_lines_all
   WHERE po_header_id = v_ordr_header_id
     AND po_line_id   = v_line_id;


  v_po_no                 PO_ORDR_HDR.PO_NO%TYPE;
  v_bpo_id                PO_ORDR_HDR.BPO_ID%TYPE;
  v_bpo_line_id           PO_ORDR_DTL.BPO_LINE_ID%TYPE;
  v_po_status             NUMBER;
  v_doc_type              VARCHAR2(4);
  v_amt_purchased         NUMBER;
  v_qty_purchased         NUMBER;
  v_order2                NUMBER;
  /* Added by PPB-UOM */
  v_order1                NUMBER;

  v_exchange_rate         GL_XCHG_RTE.EXCHANGE_RATE%TYPE;
  v_mul_div_sign          GL_XCHG_RTE.MUL_DIV_SIGN%TYPE;
  v_exchange_rate_date    GL_XCHG_RTE.EXCHANGE_RATE_DATE%TYPE;
  v_base_currency         GL_XCHG_RTE.TO_CURRENCY_CODE%TYPE;
  v_gl_source_type        GL_SRCE_MST.TRANS_SOURCE_TYPE%TYPE;


  err_num                 NUMBER;
  err_msg                 VARCHAR2(100);
  v_retval                NUMBER DEFAULT 0;
  v_err_message           VARCHAR2(2000);

  /* variables to fetch values of columns*/

  v_new_po_id             PO_ORDR_HDR.PO_ID%TYPE;
  v_po_id                 PO_ORDR_HDR.PO_ID%TYPE;
  v_line_id               PO_ORDR_DTL.LINE_id%TYPE;
  v_new_line_id           PO_ORDR_DTL.LINE_id%TYPE;
  v_line_no               PO_ORDR_DTL.LINE_no%TYPE;
  v_dtl_line_no           PO_ORDR_DTL.LINE_no%TYPE;
  v_item_id               IC_ITEM_MST.ITEM_ID%TYPE;
  v_item_um2              IC_ITEM_MST.ITEM_UM2%TYPE;
  v_item_um1              IC_ITEM_MST.ITEM_UM%TYPE; /* PPB */
  v_item_desc             IC_ITEM_MST.ITEM_DESC1%TYPE;
  v_dualum_ind            IC_ITEM_MST.DUALUM_IND%TYPE;
  v_ship_vendor_id        PO_VEND_MST.VENDOR_ID%TYPE;
  v_pay_vendor_id         PO_VEND_MST.VENDOR_ID%TYPE;
  v_frtbill_mthd          OP_FRGT_MTH.FRTBILL_MTHD%TYPE;
  v_terms_code            OP_TERM_MST.TERMS_CODE%TYPE;
  v_new_trans_id          IC_TRAN_PND.TRANS_ID%TYPE;
  v_co_code               SY_ORGN_MST.CO_CODE%TYPE;
  v_old_order_qty1        PO_ORDR_DTL.ORDER_QTY1%TYPE;
  v_old_order_qty2        PO_ORDR_DTL.ORDER_QTY2%TYPE;
  v_old_order_um1         PO_ORDR_DTL.ORDER_UM1%TYPE;
  v_old_order_um2         PO_ORDR_DTL.ORDER_UM2%TYPE;
  v_old_extended_price    PO_ORDR_DTL.EXTENDED_PRICE%TYPE;
  v_acct_map_ind          NUMBER DEFAULT 0;
  v_map_retcode           NUMBER DEFAULT 0;
  uomcv_item_id           NUMBER;

  /*PPB - Bug# 1365777 */
  v_noninv_ind            IC_ITEM_MST.NONINV_IND%TYPE;

  v_old_po_status         PO_ORDR_DTL.PO_STATUS%TYPE;
  v_old_cancellation_code PO_ORDR_DTL.CANCELLATION_CODE%TYPE;

  v_old_order_base_qty    PO_ORDR_DTL.ORDER_QTY1%TYPE;
  v_old_order_sec_qty     PO_ORDR_DTL.ORDER_QTY1%TYPE;
  v_total_received_qty    NUMBER DEFAULT 0;
  v_total_received_qty2   NUMBER DEFAULT 0;

  /* BEGIN - BUG 1785704 */
  v_release_date          DATE;
  v_po_date               DATE;
  v_creation_date         DATE;

  /* Bug 1829102 - Declaring variables and
     modifying cursor to fetch more fields */

  v_created_by            PO_RELEASES_ALL.created_by%TYPE;
  v_last_updated_by       PO_RELEASES_ALL.last_updated_by%TYPE;
  v_last_update_date      DATE;
  v_buyer_code            VARCHAR2(35);
  v_agent_id              PO_RELEASES_ALL.agent_id%TYPE;

  CURSOR release_date_cur (
         v_po_header_id       CPG_PURCHASING_INTERFACE.PO_HEADER_ID%TYPE,
         v_release_num        CPG_PURCHASING_INTERFACE.RELEASE_NUM%TYPE)
  IS
  SELECT release_date,created_by, last_updated_by, last_update_date,agent_id
  FROM   po_releases_all
  WHERE  po_header_id        = v_po_header_id
  AND    release_num         = v_release_num;

  CURSOR buyer_code_cur ( v_agent_id PO_RELEASES_ALL.agent_id%TYPE )
  IS
  SELECT  upper(substrb(last_name ,1,35))
    FROM  per_people_f
   WHERE  person_id=v_agent_id;

  /* END - BUG 1829102,BUG 1785704 */

  CURSOR bpo_cur (
          v_po_header_id       CPG_PURCHASING_INTERFACE.PO_HEADER_ID%TYPE,
          v_po_line_id         CPG_PURCHASING_INTERFACE.PO_LINE_ID%TYPE,
          v_source_shipment_id CPG_PURCHASING_INTERFACE.SOURCE_SHIPMENT_ID%TYPE
          )
  IS
  SELECT bpo_id, bpo_line_id
  FROM   cpg_oragems_mapping
  WHERE  po_header_id        = v_po_header_id
  AND    po_line_id          = v_po_line_id
  AND    po_line_location_id = v_source_shipment_id;

/* BUG#:1231038 match vendor_id with co_code */
  CURSOR vendor_cur(v_of_shipvend_site_id PO_VEND_MST.OF_VENDOR_SITE_ID%TYPE,
                    v_co_code PO_VEND_MST.CO_CODE%TYPE)
  IS
  SELECT vendor_id
  FROM   po_vend_mst
  WHERE  of_vendor_site_id = v_of_shipvend_site_id
  AND    co_code = v_co_code;

  CURSOR terms_code_cur(v_of_terms_code OP_TERM_MST.OF_TERMS_CODE%TYPE) IS
  SELECT terms_code
  FROM   op_term_mst
  WHERE  of_terms_code = v_of_terms_code;
/* Liz Enstone 18/AUG/98 Add orgn_code parameter*/
  CURSOR po_id_cur(v_po_no PO_ORDR_HDR.PO_NO%TYPE,
                   v_orgn_code int_rec.orgn_code%TYPE) IS
  SELECT po_id
  FROM   po_ordr_hdr
  WHERE  po_no = v_po_no
  AND    orgn_code = v_orgn_code;

  CURSOR line_id_cur(v_po_header_id NUMBER, v_po_line_id NUMBER,
                     v_po_line_location_id NUMBER) IS
  SELECT line_id
  FROM   cpg_oragems_mapping
  WHERE  po_header_id        = v_po_header_id
  AND    po_line_id          = v_po_line_id
  AND    po_line_location_id = v_po_line_location_id;

  CURSOR item_cur(v_item_no IC_ITEM_MST.ITEM_NO%TYPE) IS
  SELECT item_id, nvl(item_desc1,' '), item_um, item_um2, dualum_ind, noninv_ind
  FROM   ic_item_mst
  WHERE item_no = v_item_no;

  CURSOR co_code_cur(v_orgn_code SY_ORGN_MST.ORGN_CODE%TYPE) IS
  SELECT co_code
  FROM   sy_orgn_mst
  WHERE  orgn_code = v_orgn_code;

  CURSOR order_qty_price_cur(v_po_id NUMBER, v_line_id NUMBER) IS
  SELECT order_qty1, order_qty2,order_um1,order_um2, extended_price, line_no
  FROM   po_ordr_dtl
  WHERE  po_id = v_po_id
  AND    line_id = v_line_id;

  CURSOR Old_po_line_status_cur(v_po_id NUMBER, v_line_id NUMBER) IS
  SELECT po_status,cancellation_code
  FROM   po_ordr_dtl
  WHERE  po_id = v_po_id
  AND    line_id = v_line_id;


/* T. Ricci 11/10/98 added frtbill_mthd_cur so OPM value will be used*/
  CURSOR frtbill_mthd_cur(c_of_frtbill_mthd OP_FRGT_MTH.OF_FRTBILL_MTHD%TYPE) IS
  SELECT frtbill_mthd
  FROM   op_frgt_mth
  WHERE  of_frtbill_mthd = c_of_frtbill_mthd;

  complete_msg VARCHAR2(2000);

  v_next_id_status BOOLEAN;
  v_aqcst_status BOOLEAN;
  l_iret   NUMBER := 0;
  v_date_flag NUMBER := 0;


  -- Bug 1882830, lswamy
  -- Should not check for inventory period, if po is closed at Apps end.

  v_closed_code PO_LINE_LOCATIONS_ALL.CLOSED_CODE%TYPE;

  CURSOR po_line_locns_cur(v_po_line_locations_id PO_LINE_LOCATIONS_ALL.LINE_LOCATION_ID%TYPE,
                           v_po_header_id PO_LINE_LOCATIONS_ALL.PO_HEADER_ID%TYPE,
                           v_po_line_id PO_LINE_LOCATIONS_ALL.PO_LINE_ID%TYPE) IS

  SELECT  closed_code
  FROM    po_line_locations_all
  WHERE   po_header_id = v_po_header_id
  AND     po_line_id = v_po_line_id
  AND     line_location_id = v_po_line_locations_id;
  -- End bug1882830.

    /* Begin B2043468 */

  CURSOR opm_po_line_dtl(v_po_id NUMBER, v_line_id NUMBER) IS
  SELECT order_qty1,received_qty1
  FROM   po_ordr_dtl
  WHERE  po_id = v_po_id
  AND    line_id = v_line_id;

  rec_opm_po_line_dtl opm_po_line_dtl%ROWTYPE;

  CURSOR item_dtl(v_item_no IC_ITEM_MST.ITEM_NO%TYPE) IS
  SELECT item_id,item_um2
  FROM   ic_item_mst
  WHERE  item_no = v_item_no;

  rec_item_dtl item_dtl%ROWTYPE;

  /* End B2043468 */

  /* Begin B2594000 */
  cursor check_dup is
  select 1
  from po_ordr_dtl
  where  po_id   = v_po_id
  and    line_no = v_line_no;

  v_check   NUMBER := 0;
  error_ind NUMBER := 0;
  /* End B2594000 */

  ic_summ_inv_view_exists number:=0;  /* Bug 3019986 Mohit Kapoor */
  p_view_owner VARCHAR2(30) ;

BEGIN

  -- GSCC b4403407 fix for File.Sql.47
  select oracle_username
  into p_view_owner
  from fnd_oracle_userid
  where read_only_flag = 'U';

  /* Begin B3019986 Mohit Kapoor */
  SELECT COUNT(*) INTO ic_summ_inv_view_exists
  FROM ALL_VIEWS
  WHERE VIEW_NAME = 'IC_SUMM_INV_V' and
  owner = p_view_owner ;

  /* End B3019986 */

  OPEN  int_cur;

  FETCH  int_cur  INTO  int_rec;

  -- Begin bug1882830
  OPEN  po_line_locns_cur(int_rec.po_line_location_id,int_rec.po_header_id,int_rec.po_line_id);
  FETCH po_line_locns_cur INTO v_closed_code;
  CLOSE po_line_locns_cur;
  -- End bug188283


  WHILE  int_cur%FOUND
  LOOP
    retcode  := 0;
    v_retval := 0;
    error_ind := 0;   /* B2594000 */

    -- bug1882830, Introduced the following condition.

    IF  (v_closed_code NOT IN ('CLOSED','FINALLY CLOSED')) THEN

       /* T Ricci 11/24/98 added inventory calendar check*/
       v_retval := GMICCAL.trans_date_validate(int_rec.agreed_dlvdate,
                                            int_rec.orgn_code,int_rec.to_whse);
    END IF;

    IF v_retval < 0 THEN
      IF int_rec.transaction_type IN('PLANNED','BLANKET') AND int_rec.release_num <> 0 THEN
        FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
        FND_FILE.PUT_LINE(FND_FILE.LOG,
          'Inventory Calendar not set up for PO: '||int_rec.po_no||'-'||TO_CHAR(int_rec.release_num));
        FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      ELSE
        FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inventory Calendar not set up for PO: '|| int_rec.po_no);
        FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      END IF;

       /* Bug#1274130 */

       IF v_retval = -21 THEN /* Fiscal Yr and Fiscal Yr beginning date
                                 not found. */
          FND_MESSAGE.SET_NAME('GMI','INVCAL_FISCALYR_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF v_retval = -22 THEN /* Period end date and close indicator
                                    not found. */
          FND_MESSAGE.SET_NAME('GMI','INVCAL_PERIOD_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF v_retval = -23 THEN /* Date is within a closed Inventory
                                calendar period */
       /*
          FND_MESSAGE.SET_NAME('GMI','INVCAL_CLOSED_PERIOD_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
       */
           v_retval := 0;

       ELSIF v_retval = -24 THEN /*  Company Code not found. */

          FND_MESSAGE.SET_NAME('GMI','INVCAL_INVALIDCO_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF  v_retval = -25 THEN /* Warehouse has been closed for the period */
       /*
          FND_MESSAGE.SET_NAME('GMI','INVCAL_WHSE_CLOSED_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
       */
           v_retval := 0;

       ELSIF  v_retval = -26 THEN /* Transaction not passed in as
                                     a parameter.*/
          FND_MESSAGE.SET_NAME('GMI','INVCAL_TRANS_DATE_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF  v_retval = -27 THEN /* Organization code not passed as
                                     a parameter.*/
          FND_MESSAGE.SET_NAME('GMI','INVCAL_INVALIDORGN_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

        ELSIF  v_retval = -28 THEN /* Warehouse code not passed as
                                     a parameter.*/
          FND_MESSAGE.SET_NAME('GMI','INVCAL_WHSEPARM_ERR');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF  v_retval = -29 THEN /* Warehouse code is not found. */

          FND_MESSAGE.SET_NAME('GMI','INVCAL_WHSE_ERR ');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       ELSIF v_retval < -29 THEN /* Log a general message */
          FND_MESSAGE.SET_NAME('GMI','INVCAL_GENL_ERR ');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );

       END IF;

      IF (v_retval NOT IN (-23, -25)) THEN
        retcode :=1;
      END IF;

    END IF;

    /* T Ricci 5/12/98 changed date_modified to last_update_date*/

    IF GML_PO_SYNCH.gemms_validate(
                      int_rec.orgn_code,
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
                      int_rec.last_update_date)   = FALSE OR
                      v_retval < 0  THEN

        UPDATE  cpg_purchasing_interface
        SET     invalid_ind = 'Y'
        WHERE   rowid = int_rec.rowid;

        retcode :=1;

    ELSE  /* all fields are validate*/

      /*IF int_rec.transaction_type = 'STANDARD' THEN
        v_doc_type := 'PORD';
      ELSE
        v_doc_type := 'PBPO';
      END IF;*/
      v_doc_type := 'PORD';

      /* BEGIN - BUG 1785704 */
      v_po_date       := int_rec.po_date;
      /* END - BUG 1785704 */

     /*  Begin - Bug 1781846 */
      v_date_flag  := FND_PROFILE.VALUE('PO$DEF_DATE');

      IF (v_date_flag = 1) THEN
         v_creation_date := int_rec.po_date; -- approved date
      ELSIF (v_date_flag = 2) THEN
         v_creation_date := int_rec.creation_date;
      ELSE
         v_creation_date := SYSDATE;
      END IF;

     /* End - Bug 1781846 */



     /* Begin bug 1829102 */

      v_created_by        := nvl(int_rec.created_by,0);
      v_last_updated_by   := nvl(int_rec.last_updated_by,0);
      v_last_update_date  := nvl(int_rec.last_update_date,sysdate);
      v_buyer_code        := int_rec.buyer_code;

     /* End bug 1829102 */


      IF int_rec.transaction_type = 'PLANNED' THEN
        OPEN  bpo_cur (int_rec.po_header_id, int_rec.po_line_id,
                      int_rec.source_shipment_id);
        FETCH bpo_cur INTO v_bpo_id, v_bpo_line_id;
        CLOSE bpo_cur;

        /* BEGIN - BUG 1829102, BUG 1785704 */
        OPEN  release_date_cur (int_rec.po_header_id,int_rec.release_num);
        FETCH release_date_cur into v_release_date,v_created_by,v_last_updated_by,v_last_update_date,v_agent_id;
        CLOSE release_date_cur;

        IF (v_agent_id  is NOT NULL) THEN
           OPEN  buyer_code_cur (v_agent_id);
           FETCH buyer_code_cur INTO v_buyer_code;
           CLOSE buyer_code_cur;
        END IF;

        v_po_date       := v_release_date;

        /* END -  BUG 1829102,BUG 1785704 */

        v_po_no         := CONCAT (CONCAT(int_rec.po_no, '-'),
                           TO_CHAR(int_rec.release_num)
                           );

      ELSIF int_rec.transaction_type = 'BLANKET' THEN
        v_bpo_id      :=NULL;     /* KYH 25/AUG/98 Foreign key constraints*/
        v_bpo_line_id :=NULL;     /* KYH 25/AUG/98 Foreign key constraints*/

        /* BEGIN - BUG 1829102, BUG 1785704 */
        OPEN  release_date_cur (int_rec.po_header_id,int_rec.release_num);
        FETCH release_date_cur into v_release_date ,v_created_by,v_last_updated_by,v_last_update_date, v_agent_id;
        CLOSE release_date_cur;

        IF (v_agent_id  is NOT NULL) THEN
          OPEN  buyer_code_cur (v_agent_id);
          FETCH buyer_code_cur INTO v_buyer_code;
          CLOSE buyer_code_cur;
        END IF;

        v_po_date       := v_release_date;

        /* END -  BUG 1829102,BUG 1785704 */

        v_po_no         := CONCAT (CONCAT(int_rec.po_no, '-'),
                           TO_CHAR(int_rec.release_num)
                           );

      ELSE /* Standard PO's */
        v_bpo_id      :=NULL; /* T.Ricci 7/6/98 integ constraint change*/
        v_bpo_line_id :=NULL; /* T.Ricci 7/7/98 integ constraint change*/
        v_po_no       := int_rec.po_no;
      END IF;

      /* T. Ricci 5/12/98 set po_status to '0' for cancelled PO's */
      /* Uday Phadtare B1820461 do not change v_po_status to 20 if CLOSED FOR INVOICE */
      IF (int_rec.po_status = 'OPEN' OR int_rec.po_status = 'CLOSED FOR INVOICE') THEN
        v_po_status := 0;
      ELSIF int_rec.po_status = 'CANCEL' THEN
        v_po_status := 0;
      ELSIF (int_rec.po_status = 'CLOSED' OR
            int_rec.po_status = 'CLOSED FOR RECEIVING' OR
            /* int_rec.po_status = 'CLOSED FOR INVOICE' OR     B1820461  */
            int_rec.po_status = 'FINALLY CLOSED') THEN
        v_po_status := 20;
      END IF;

      GML_VALIDATE_PO.get_base_currency (v_base_currency,
                                          int_rec.orgn_code);

/* HW BUG#:1107267 don't get exchange rate, rate is already in cpg_purchasing_interface */
/*      IF (v_base_currency <> int_rec.billing_currency) THEN

        GML_VALIDATE_PO.get_gl_source (v_gl_source_type);

        GML_VALIDATE_PO.get_exchange_rate (v_exchange_rate,
                                            v_mul_div_sign,
                                            v_exchange_rate_date,
                                            v_base_currency,
                                            int_rec.billing_currency,
                                            v_gl_source_type);
      END IF;
*/

/* HW BUG#:1231038 match payvendor_id and shipvend_id with correct co_code */
      OPEN  co_code_cur(int_rec.orgn_code);
      FETCH co_code_cur
      INTO  v_co_code;
      CLOSE co_code_cur;

      OPEN  vendor_cur(int_rec.of_shipvend_site_id,v_co_code);
      FETCH vendor_cur
      INTO  v_ship_vendor_id;
      CLOSE vendor_cur;

      OPEN  vendor_cur(int_rec.of_payvend_site_id,v_co_code);
      FETCH vendor_cur
      INTO  v_pay_vendor_id;
      CLOSE vendor_cur;

      OPEN  frtbill_mthd_cur(int_rec.of_frtbill_mthd);
      FETCH frtbill_mthd_cur
      INTO  v_frtbill_mthd;
      CLOSE frtbill_mthd_cur;

      OPEN  terms_code_cur(int_rec.of_terms_code);
      FETCH terms_code_cur
      INTO  v_terms_code;
      CLOSE terms_code_cur;

      /* if the first encounter with a PO, insert the header*/
      /* Liz Enstone 18/AUG/98 Include orgn code parameter*/
      IF  GML_PO_SYNCH.new_po_hdr(v_po_no,int_rec.orgn_code) THEN
      BEGIN


        GML_PO_SYNCH.next_po_id(v_new_po_id, v_doc_type, int_rec.orgn_code,
                                v_next_id_status);
        IF v_next_id_status=FALSE THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error getting next po_id');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END IF;

      /* BEGIN BUG#1731582 P. Arvind Dath */

      OPEN  attr_hdr_cur(int_rec.PO_HEADER_ID);
      FETCH attr_hdr_cur INTO  attr_hdr_rec;
      CLOSE attr_hdr_cur;


        /* T. Ricci 5/12/98 removed user_class and changed who */
        /* columns for GEMMS 5.0*/
        BEGIN
        INSERT INTO po_ordr_hdr
        ( po_id,
          orgn_code,
          po_no,
          bpo_id,
          bpo_release_no,
          po_type,
          payvend_id,
          shipvend_id,
          recvaddr_id,
          shipper_code,
          recv_desc,
          from_whse,
          to_whse,
          recv_loct,
          ship_mthd,
          frtbill_mthd,
          purchase_exchange_rate,
          mul_div_sign,
          billing_currency,
          currency_bght_fwd,
          terms_code,
          po_status,
          pohold_code,
          cancellation_code,
          fob_code,
          buyer_code,
          icpurch_class,
          vendso_no,
          project_no,
          po_date,
          requested_dlvdate,
          sched_shipdate,
          required_dlvdate,
          agreed_dlvdate,
          date_printed,
          expedite_date,
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
          exported_date,
          attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14
        )
        VALUES  /* Insertion                        */
        ( v_new_po_id,
          nvl(int_rec.orgn_code,'-1'), /* orgn_code,*/
          v_po_no,                     /* modified int_rec.po_no to v_po_no*/
          v_bpo_id,                    /* modified int_rec.bpo_id to v_bpo_id*/
                                       /* T. Ricci 7/6/98 NULL OK.*/
          int_rec.bpo_release_number,  /* LE 25/08/98 NULL OK*/
          nvl(int_rec.po_type,0),
          nvl(v_pay_vendor_id,0),
          nvl(v_ship_vendor_id,0),
          int_rec.recvaddr_id,     /* T. Ricci 7/6/98 integ constraint chg*/
                                   /* LE 25/08/98 NULL OK*/
          int_rec.shipper_code,
          int_rec.recv_desc,       /* LE 25/08/98 NULL OK*/
          int_rec.from_whse,       /* T.Ricci 7/6/98 integ constraint change*/
          int_rec.to_whse,         /* mandatory field, checked not null*/
          int_rec.recv_loct,       /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.ship_mthd,       /* T.Ricci 7/6/98 integ constraint change*/
          v_frtbill_mthd,          /* LE 25/08/98 NULL OK*/
/*  nvl(v_exchange_rate, 1), BUG#:1107267. Get value from cpg_purchasing_interface */
          nvl(int_rec.purchase_exchange_rate, 1),
/*   nvl(v_mul_div_sign, 0), BUG#:1107267. Get value from cpg_purchasing_interface */
          nvl(int_rec.mul_div_sign, 0),
          int_rec.billing_currency,   /*mandatory field, not null*/
          nvl(int_rec.currency_bght_fwd, 0),
          v_terms_code,               /* KYH 28/AUG/98 nullable column  */
          nvl(v_po_status, 0),
          int_rec.pohold_code,        /* T.Ricci 7/6/98 integ constraint chg*/
          int_rec.cancellation_code,  /* T.Ricci 7/6/98 integ constraint chg*/
          int_rec.fob_code,           /* LE 25/08/98 NULL OK*/
          v_buyer_code,      /*LE 25/08/98 NULL OK,Lswamy - BUG 1829102*/
          int_rec.icpurch_class,      /* T.Ricci 7/6/98 integ constraint chg*/
          int_rec.vendso_no,          /* LE 25/08/98 NULL OK  */
          int_rec.project_no,         /* T.Ricci 7/6/98 integ constraint chg*/
          nvl(v_po_date, SYSDATE),    /* PKU - BUG 1785704 */
          nvl(int_rec.requested_dlvdate, SYSDATE),
          nvl(int_rec.sched_shipdate, SYSDATE),
          nvl(int_rec.required_dlvdate, SYSDATE),
          nvl(int_rec.agreed_dlvdate, SYSDATE),
          nvl(int_rec.date_printed, SYSDATE),
          int_rec.expedite_date,      /* LE 25/AUG/98 NULL OK*/
          int_rec.revision_count,     /* LE 25/AUG/98 NULL OK*/
          nvl(int_rec.in_use, 0),
          int_rec.print_count,        /* LE 25/AUG/98 NULL OK*/
          nvl(v_creation_date,sysdate), /* PKU - BUG 1785704 */
          nvl(v_created_by,0), /* lswamy - BUG 1829102 */
          nvl(v_last_update_date,sysdate), /* lswamy - BUG 1829102 */
          nvl(v_last_updated_by,0),  /* lswamy - BUG 1829102 */
          int_rec.last_update_login,  /* LE 25/08/98 NULL OK*/
          nvl(int_rec.delete_mark,0),
          int_rec.text_code,        /* T. Ricci 7/6/98 integ constraint chg*/
          int_rec.exported_date,        /* LE 25/08/98 NULL OK*/
          attr_hdr_rec.attribute1,
                    attr_hdr_rec.attribute2,
                    attr_hdr_rec.attribute3,
                    attr_hdr_rec.attribute4,
                    attr_hdr_rec.attribute5,
                    attr_hdr_rec.attribute6,
                    attr_hdr_rec.attribute7,
                    attr_hdr_rec.attribute8,
                    attr_hdr_rec.attribute9,
                    attr_hdr_rec.attribute10,
                    attr_hdr_rec.attribute11,
                    attr_hdr_rec.attribute12,
                    attr_hdr_rec.attribute13,
                    attr_hdr_rec.attribute14
        );
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into po_ordr_hdr')
;
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;
        END;
                /* END BUG#1731582 */

                /* PO ordr header OK*/
      END IF;  /* new PO*/

      OPEN  item_cur(int_rec.item_no);
      FETCH item_cur INTO  v_item_id, v_item_desc,v_item_um1, v_item_um2, v_dualum_ind,v_noninv_ind;
      CLOSE item_cur;

      /* Bug 1857224 */
      OPEN  po_lines_all_cur (int_rec.po_header_id, int_rec.po_line_id);
      FETCH po_lines_all_cur INTO v_item_desc;
      CLOSE po_lines_all_cur;
      /* End Bug 1857224 */


      /*modified int_rec.po_no to v_po_no*/
      /* Liz Enstone 18/AUG/98 Add orgn_code to parameters      */
      OPEN  po_id_cur(v_po_no,int_rec.orgn_code);
      FETCH po_id_cur INTO v_po_id;
      CLOSE po_id_cur;

      /* 11/6/1998 T. Ricci commented*/
      /* GML_PO_SYNCH.cpg_conv_duom
        (v_item_id,
         int_rec.order_um1,
         int_rec.order_qty1,
         v_item_um2,
         v_order2); */

      uomcv_item_id := v_item_id;


      /* Added by PPB for UOM changes */
      IF (int_rec.order_um1 <> v_item_um1) THEN
        v_order1 := GMICUOM.uom_conversion
                    (v_item_id,0,
                     int_rec.order_qty1,
                     int_rec.order_um1,
                     v_item_um1,0);
      ELSE
        v_order1 := int_rec.order_qty1;
      END IF;

      /* 11/6/1998 T. Ricci added*/
      IF v_dualum_ind > 0 THEN
         v_order2 :=GMICUOM.uom_conversion
                    (v_item_id,0,
                     int_rec.order_qty1,
                     int_rec.order_um1,
                     v_item_um2,0);
      ELSE
         v_order2 := 0;
      END IF;


      IF GML_PO_SYNCH.new_line(int_rec.po_header_id, int_rec.po_line_id,
                               int_rec.po_line_location_id)  THEN
      BEGIN

        /* insert the line location information*/

        GML_PO_SYNCH.next_line_id('PO', v_new_line_id, v_next_id_status);
        IF (v_next_id_status=FALSE) THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error getting next line_id');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END IF;

        /* 03/24/00 NC - TAR# 12693733.6 (Bug# 1249797 ; Base Bug#1247332)
          OPM was generating it's own line number  regardless of what
          the line number is in oracle.Modified to take oracle line number
          instead.
       */

        /* v_line_no := GML_PO_SYNCH.get_line_no(v_po_id) + 1; */

        v_line_no := GML_PO_SYNCH.get_line_no( v_po_id,
                                               int_rec.po_header_id,
                                               int_rec.po_line_id,
                                               int_rec.po_line_location_id,
                                               int_rec.transaction_type);

      /* BEGIN BUG#1731582 P. Arvind Dath */

          OPEN  attr_dtl_cur(int_rec.PO_LINE_LOCATION_ID,
                             int_rec.PO_HEADER_ID,
                                                 int_rec.PO_LINE_ID);
      FETCH attr_dtl_cur INTO  attr_dtl_rec;
      CLOSE attr_dtl_cur;

        /* T. Ricci 5/12/98 removed user_class and changed who */
        /* columns for GEMMS 5.0*/

      /* Begin B2594000 */
      OPEN  check_dup;
      FETCH check_dup into v_check;
      IF check_dup%FOUND THEN
         error_ind := 1;
      ELSE
         error_ind := 0;
      END IF;
      CLOSE check_dup;
      /* End B2594000 */

     IF error_ind = 0 THEN      /* B2594000 */
        BEGIN
        INSERT INTO po_ordr_dtl
        ( po_id,
          line_no,
          line_id,
          bpo_line_id,
          apinv_line_id,
          item_id,
          generic_id,
          item_desc,
          icpurch_class,
          order_qty1,
          order_qty2,
          order_um1,
          order_um2,
          received_qty1,
          received_qty2,
          net_price,
          extended_price,
          price_um,
          recvaddr_id,
          ship_mthd,
          shipper_code,
          shipvend_id,
          to_whse,
          from_whse,
          recv_loct,
          recv_desc,
          qc_grade_wanted,
          frtbill_mthd,
          terms_code,
          pohold_code,
          cancellation_code,
          fob_code,
          vendso_no,
          buyer_code,
          project_no,
          agreed_dlvdate,
          requested_dlvdate,
          required_dlvdate,
          sched_shipdate,
          expedite_date,
          po_status,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          text_code,
          trans_cnt,
          match_type,
          exported_date,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15
        )
        VALUES
        ( v_po_id,
          v_line_no,
          v_new_line_id,
          v_bpo_line_id,             /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.apinv_line_id,     /* LE 25/AUG/98 NULL OK*/
          v_item_id,                 /*mandatory field, already checked not null*/
          int_rec.generic_id,        /* T.Ricci 7/7/98 integ constraint change*/
          nvl(v_item_desc, ' '),
          int_rec.icpurch_class,     /* T.Ricci 7/7/98 integ constraint change*/
          nvl(int_rec.order_qty1,0),
          v_order2,                  /* LE 25/AUG/98 NULL OK*/
          int_rec.order_um1,         /*mandatory field, not null*/
          v_item_um2,                /* LE 25/AUG/98 NULL OK*/
          int_rec.received_qty1,     /* LE 25/AUG/98 NULL OK*/
          int_rec.received_qty2,     /* LE 25/AUG/98 NULL OK*/
          nvl(int_rec.net_price,0),
          nvl(int_rec.extended_price,0),
          nvl(int_rec.price_um,' '),
          int_rec.recvaddr_id,       /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.ship_mthd,         /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.shipper_code,      /* LE 25/AUG/98 NULL OK*/
          v_ship_vendor_id,          /*mandatory, checked not null*/
          nvl(int_rec.to_whse, ' '),
          int_rec.from_whse,         /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.recv_loct,         /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.recv_desc,         /* LE 25/AUG/98 NULL OK*/
          int_rec.qc_grade_wanted,   /* LE 25/AUG/98 NULL OK*/
          v_frtbill_mthd,            /* LE 25/AUG/98 NULL OK*/
          v_terms_code,              /* Bug 2237409 - PKU */
          int_rec.pohold_code,       /* T.Ricci 7/7/98 integ constraint change*/
          int_rec.cancellation_code, /* T.Ricci 7/7/98 integ constraint change */
          int_rec.fob_code,          /* LE 25/AUG/98 NULL OK*/
          int_rec.vendso_no,   /* LE 25/AUG/98 NULL OK */
          v_buyer_code,        /* LE 25/AUG/98 NULL OK ,Lswamy - BUG 1829102*/
          int_rec.project_no,        /* T.Ricci 7/7/98 integ constraint change*/
          nvl(int_rec.agreed_dlvdate, sysdate),
          nvl(int_rec.requested_dlvdate, sysdate),
          nvl(int_rec.required_dlvdate, sysdate),
          nvl(int_rec.sched_shipdate, sysdate),
          int_rec.expedite_date,     /* LE 25/AUG/98 NULL OK*/
          nvl(v_po_status,0),        /*modified int_rec.po_status to v_po_status*/
          nvl(v_creation_date,sysdate), /* PKU - BUG 1785704 */
          nvl(v_created_by,0), /* Lswamy - BUG 1829102 */
          nvl(v_last_update_date,sysdate),  /* Lswamy - BUG 1829102 */
          nvl(v_last_updated_by,0),  /* Lswamy - BUG 1829102 */
          int_rec.last_update_login, /* LE 25/AUG/98 NULL OK*/
          int_rec.text_code,         /* T.Ricci 7/7/98 integ constraint change*/
          0,                         /* T. Ricci 11/10/98 set trans_cnt to '0'*/
          nvl(int_rec.match_type, 3),
          int_rec.exported_date,     /* LE 25/AUG/98 NULL OK*/
          attr_dtl_rec.attribute1,
                 attr_dtl_rec.attribute2,
                 attr_dtl_rec.attribute3,
                 attr_dtl_rec.attribute4,
                 attr_dtl_rec.attribute5,
                 attr_dtl_rec.attribute6,
                 attr_dtl_rec.attribute7,
                 attr_dtl_rec.attribute8,
                 attr_dtl_rec.attribute9,
                 attr_dtl_rec.attribute10,
                 attr_dtl_rec.attribute11,
                 attr_dtl_rec.attribute12,
                 attr_dtl_rec.attribute13,
                 attr_dtl_rec.attribute14,
                 attr_dtl_rec.attribute15
        );
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into po_ordr_dtl');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;
                /* END BUG#1731582 */

        /* BEGIN - Bug 1854280 Pushkar Upakare */
        IF int_rec.transaction_type = 'PLANNED' THEN

            BEGIN
            UPDATE po_bpos_hdr
            SET    amount_purchased = nvl(amount_purchased,0) + nvl(int_rec.extended_price,0),
                   activity_ind     = 1,
                   rel_count        = nvl(rel_count,0) + 1,
                   last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                   last_updated_by  = nvl(int_rec.last_updated_by, 0),
                   last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
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
            SET    amount_purchased = nvl(amount_purchased,0) + nvl(int_rec.extended_price,0),
                   qty_purchased    = nvl(qty_purchased,0)    + nvl(int_rec.order_qty1,0),
                   last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                   last_updated_by  = nvl(int_rec.last_updated_by, 0),
                   last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
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

        END IF; /*int_rec.transaction_type = 'PLANNED' */
        /* END - Bug 1854280*/

        /*insert into the ic_tran_pnd table*/


        OPEN  co_code_cur(int_rec.orgn_code);
        FETCH co_code_cur
        INTO  v_co_code;
        CLOSE co_code_cur;

        GML_PO_SYNCH.next_trans_id(v_new_trans_id, v_next_id_status);
        IF v_next_id_status=FALSE THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error getting next trans_id');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END IF;

        BEGIN    /*insert into ic_tran_pnd*/
        /* T. Ricci 5/12/98 changed who columns for GEMMS 5.0*/

        INSERT INTO ic_tran_pnd
        ( item_id,
          line_id,
          trans_id,
          co_code,
          orgn_code,
          whse_code,
          lot_id,
          location,
          doc_id,
          doc_type,
          doc_line,
          line_type,
          reason_code,
          trans_date,
          trans_qty,
          trans_qty2,
          qc_grade,
          lot_status,
          trans_stat,
          trans_um,
          trans_um2,
          op_code,
          completed_ind,
          staged_ind,
          gl_posted_ind,
          event_id,
          delete_mark,
          text_code,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date
        )
        VALUES
        ( v_item_id,    /*mandatory, checked not null*/
          v_new_line_id,
          v_new_trans_id,
          nvl(v_co_code, '-1'),
          nvl(int_rec.orgn_code, '-1'),  /*GEMMS Organization Code*/
          int_rec.to_whse,               /*mandatory*/
          0,                             /*lot_id always initialized to 0*/
          fnd_profile.value('IC$DEFAULT_LOCT'), /*location KYH 17/AUG/98*/
          v_po_id,                       /*doc_id,*/
          v_doc_type,                    /*doc_type,*/
          0,                             /*doc_line, not used*/
          0,                             /*line_type,*/
          NULL,                          /*reason_code T.Ricci added NULL,*/
          nvl(int_rec.agreed_dlvdate, SYSDATE), /*trans_date T.Ricci changed to*/
                                         /* agreed_dlvdate 7/27,*/
          nvl(v_order1,0),  /* PPB-UOM nvl(int_rec.order_qty1, 0),    trans_qty,*/
          v_order2,              /*trans_qty2, LE 26/AUG/98 NULL OK*/
          int_rec.qc_grade_wanted,       /* LE 26/AUG/98 NULL OK */
          NULL,                          /*lot_status T.Ricci added NULL,*/
          NULL,                          /*trans_stat,  LE 26/AUG/98 NULL OK*/
          v_item_um1,             /* PKU - bug 1516895, not null*/
          v_item_um2,             /*um2 T.Ricci integ constraint change */
          /*1004,                        op_code T.Ricci change to number,*/
          nvl(int_rec.created_by, 0),    /*op_code T.Ricci change to number,*/
          0,                             /*completed_ind,*/
          0,                             /*staged_ind,*/
          0,                             /*gl_posted_ind,*/
          0,                             /*event_id,*/
          0,                             /*delete_mark,*/
          NULL,                          /*text_code,*/
          nvl(int_rec.last_update_date,sysdate),  /* last_update_date,*/
          nvl(int_rec.last_updated_by,0),         /* last_updated_by,*/
          int_rec.last_update_login,    /* last_update_login,  LE 26/AUG/98 NULL OK*/
          nvl(int_rec.created_by,0),              /* created_by,*/
          nvl(v_creation_date,sysdate)  /* PKU - BUG 1785704 */
        );

        EXCEPTION
          WHEN OTHERS THEN
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into ic_tran_pnd');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
/** MC BUG# 1360002**/
/** removed the comment from the below 2 lines **/
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END;      /* insert into ic_tran_pnd;*/


        /* update the ic_summ_inv table*/

    IF ic_summ_inv_view_exists = 0 THEN  /* Bug 3019986 Mohit Kapoor */
    /*Bug 1365777 - If item is a non-inventory item then do not update or insert
         into ic_summ_inv table - PPB */

      If v_noninv_ind = 0
      then
        BEGIN


                if      int_rec.qc_grade_wanted is NULL
                then
                        UPDATE ic_summ_inv
                        SET    onpurch_qty     = onpurch_qty + nvl(v_order1,0),
                                onpurch_qty2    = onpurch_qty2 + nvl(v_order2,0)
                        WHERE  item_id=v_item_id
                        AND    whse_code=int_rec.to_whse;
                else
                        UPDATE ic_summ_inv
                        SET    onpurch_qty     = onpurch_qty + nvl(v_order1,0),
                                onpurch_qty2    = onpurch_qty2 + nvl(v_order2,0)
                        WHERE  item_id=v_item_id
                        AND    whse_code=int_rec.to_whse
                        AND    qc_grade = int_rec.qc_grade_wanted;
                end if;/*int_rec.qc_grade_wanted is NULL*/


          /*Preetam Bamb Bug# 1288128  03/May/00
            If there is no entry for the item/warehouse/qc grade combn
            in ic_summ_inv table then insert a row in it.*/
           IF (SQL%ROWCOUNT = 0) THEN
            /*  Get the next sequence number */
            select gem5_summ_inv_id_s.nextval into l_iret from dual;

           /*  Since a row for this item does not already exists enter a row  */
             INSERT INTO ic_summ_inv
              (summ_inv_id, item_id, whse_code, qc_grade,
               onhand_qty, onhand_qty2, onhand_prod_qty,
               onhand_prod_qty2, onhand_order_qty, onhand_order_qty2,
               onhand_ship_qty, onhand_ship_qty2, onpurch_qty,
               onpurch_qty2, onprod_qty, onprod_qty2,
               committedsales_qty, committedsales_qty2,
               committedprod_qty,
               committedprod_qty2, intransit_qty, intransit_qty2,
               last_updated_by, created_by, last_update_date,
               creation_date)
            VALUES (l_iret, v_item_id, int_rec.to_whse,
               int_rec.qc_grade_wanted,
               0, 0, 0, 0, 0, 0, 0, 0,
               nvl(v_order1,0), nvl(v_order2,0),
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, SYSDATE, SYSDATE);


          END IF; /* SQL%ROWCOUNT = 0 */



          EXCEPTION
          WHEN OTHERS THEN
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating ic_summ_inv');
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
            err_num := SQLCODE;
            err_msg := SUBSTRB (SQLERRM, 1, 100);
            FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END;     /* update ic_summ_inv*/

      end if; /* if v_noninv_ind = 0 */
    END IF; /* Bug 3019986 ic_summ_inv_view_exists */

        /* Synchronize Acquisition Costs from Oracle */

        GML_PO_SYNCH.cpg_aqcst_mv
                    (int_rec.po_header_id,
                     int_rec.po_line_id,
                     int_rec.po_line_location_id,
                     v_po_id,
                     v_new_line_id,
                     v_doc_type,
                     v_aqcst_status);

        IF v_aqcst_status=FALSE THEN
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error with cpg_aqcst_mv procedure');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'po_header_id='|| int_rec.po_header_id
);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'po_line_id='|| int_rec.po_line_id);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'lineloc_id='|| int_rec.po_line_location_id);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'po_id=' || v_po_id);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'new_line_id=' || v_new_line_id);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'doc_type=' || v_doc_type);
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END IF;

       /* add the GEMMS id's to the record in mapping table*/

       /* After getting a new line, Open the status of the PO */

        BEGIN
       /* BEGIN BUG#2041468 V. Ajay Kumar */
       /* Modified the following update statement by adding 'cancellation_code = NULL' */
          UPDATE po_ordr_hdr
          SET    po_status = 0, cancellation_code = NULL
          WHERE  po_id = v_po_id;
       /* END BUG#2041468 */
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating status in po_ordr_hdr');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;

        BEGIN
        UPDATE cpg_oragems_mapping
        SET    po_id   = v_po_id,
               line_id = v_new_line_id
        WHERE  po_header_id        = int_rec.po_header_id
        AND    po_line_id          = int_rec.po_line_id
        AND    po_line_location_id = int_rec.po_line_location_id;
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating cpg_oragems_mapping
');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;

/* HW BUG#:1178415 - Pass int_rec.mul_div_sign and int_rec.purchase_exchange_rate */
        /* Call GL Mapping and insert into po_dist_dtl*/

        GML_PO_GLDIST.P_row_num_upd := 0 ;

        GML_PO_GLDIST.receive_data ('PORD', v_po_id,
                                 v_new_line_id, int_rec.orgn_code,
                                 int_rec.po_date, v_ship_vendor_id,
                                 v_base_currency, int_rec.billing_currency,
                                 int_rec.to_whse, v_line_no,
                                 int_rec.item_no, int_rec.extended_price,
                                 int_rec.project_no, int_rec.order_qty1,
                                 int_rec.order_um1, v_item_id,
                                 int_rec.mul_div_sign,int_rec.purchase_exchange_rate,
                                 int_rec.net_price,1, FALSE,
                                 v_map_retcode,
/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.Just added one paramerter passed to receive_data procedure.
P_transaction_type */
                                 int_rec.transaction_type       );

        IF v_map_retcode = 0 THEN
                v_acct_map_ind := 1;
        ELSIF v_map_retcode = 1 THEN
           FND_MESSAGE.SET_NAME  ('GML', 'PO_ACCT_NOT_DEFINED');
           v_err_message := FND_MESSAGE.GET;
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           retcode :=1;
        ELSIF v_map_retcode = 2 THEN
           FND_MESSAGE.SET_NAME  ('GMF', 'GL_NO_ACCTG_MAP2');
           FND_MESSAGE.SET_TOKEN ('S1', int_rec.orgn_code );
           FND_MESSAGE.SET_TOKEN ('S2', int_rec.orgn_code );
           FND_MESSAGE.SET_TOKEN ('S3', int_rec.to_whse );
           v_err_message := FND_MESSAGE.GET;
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           retcode :=1;
        ELSIF v_map_retcode = 3 THEN
           FND_MESSAGE.SET_NAME  ('GMF', 'GL_INVALID_FISCAL_YEAR_PERIOD');
           v_err_message := FND_MESSAGE.GET;
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           retcode :=1;
        ELSIF v_map_retcode = 4 THEN
           FND_MESSAGE.SET_NAME ('GMF', 'GL_NO_LEDGER_MAP2');
           FND_MESSAGE.SET_TOKEN ('S1', int_rec.orgn_code );
           FND_MESSAGE.SET_TOKEN ('S2', int_rec.orgn_code );
           v_err_message := FND_MESSAGE.GET;
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           retcode :=1;
        END IF;

        IF v_map_retcode > 0 THEN
           UPDATE  cpg_purchasing_interface
           SET     invalid_ind = 'Y'
           WHERE   rowid = int_rec.rowid;
           EXIT;
        END IF;
       END IF;     /* B2594000 */
      END; /*new line*/

      /* cancelling or closing a line */

      ELSIF  (int_rec.po_status  IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                      /* 'CLOSED FOR INVOICE',  B1820461 */
                                      'FINALLY CLOSED')
              /* B2113809 following or condition added */
              OR (int_rec.cancellation_code IS NOT NULL AND int_rec.po_status = 'CLOSED FOR INVOICE')) THEN
      BEGIN
        OPEN  line_id_cur(int_rec.po_header_id, int_rec.po_line_id,
                          int_rec.po_line_location_id);
        FETCH line_id_cur
        INTO  v_line_id;
        CLOSE line_id_cur;


        OPEN  old_po_line_status_cur(v_po_id, v_line_id);
        FETCH old_po_line_status_cur INTO v_old_po_status,v_old_cancellation_code;
        CLOSE old_po_line_status_cur;


        /* for cancelling, cancellation_code = 'ORAF'*/
        /* for closing,    cancellation_code = ' '*/
        /* T. Ricci 5/12/98 changed who columns for GEMMS 5.0*/
        /* T. Ricci 11/10/98 removed trans_cnt = trans_cnt + 1 from update*/

        UPDATE po_ordr_dtl
        SET    po_status         = 20,
               cancellation_code = int_rec.cancellation_code,
               last_update_date  = nvl(int_rec.last_update_date, SYSDATE),
               last_updated_by   = nvl(int_rec.last_updated_by, 0),
               last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
        WHERE  po_id   = v_po_id
        AND    line_id = v_line_id;


        Update_header_status(v_po_id,int_rec.cancellation_code);


        /* Bug# 1357575 - The delete_mark is set to one only of the po is cancelled added the if condition */
        /* Uday Phadtare B1795095 commented the if condition */
        --IF int_rec.cancellation_code IS NOT NULL THEN
                UPDATE ic_tran_pnd
                SET    delete_mark   = 1          /* only column changed by GEMMS   */
                WHERE  doc_type      = v_doc_type
                AND    doc_id        = v_po_id
                AND    line_id       = v_line_id;
        --END IF;

        /* Begin B2043468 */
        IF (int_rec.po_status IN ('CLOSED','CLOSED FOR RECEIVING') AND nvl(v_old_po_status,0) = 20) THEN
            OPEN  opm_po_line_dtl(v_po_id, v_line_id);
            FETCH opm_po_line_dtl INTO rec_opm_po_line_dtl;
            CLOSE opm_po_line_dtl;

            OPEN  item_dtl(int_rec.item_no);
            FETCH item_dtl INTO  rec_item_dtl.item_id, rec_item_dtl.item_um2;
            CLOSE item_dtl;

            IF int_rec.order_qty1 <> rec_opm_po_line_dtl.order_qty1 THEN
                IF v_dualum_ind > 0 THEN
                    v_order2 := GMICUOM.uom_conversion
                                        (rec_item_dtl.item_id,0,
                                         int_rec.order_qty1,
                                         int_rec.order_um1,
                                         rec_item_dtl.item_um2,0);
                ELSE
                    v_order2 := 0;
                END IF;
                UPDATE po_ordr_dtl
                SET    order_qty1 = int_rec.order_qty1, order_qty2 = v_order2
                WHERE  po_id   = v_po_id
                AND    line_id = v_line_id;
             END IF;

        END IF;

        /* End B2043468 */


        /* PPB */

        IF nvl(v_old_po_status,0) <> 20
        THEN

                 v_total_received_qty := Get_total_Received_qty(v_po_id,v_line_id,v_item_id,v_item_um1);

                 IF v_item_um2 IS NOT NULL
                 THEN
                        v_total_received_qty2 := GMICUOM.uom_conversion
                                                        (v_item_id,0,
                                                         v_total_received_qty,
                                                         v_item_um1,
                                                         v_item_um2,0);
                 ELSE
                        v_total_received_qty2   := 0;
                 END IF;

            IF ic_summ_inv_view_exists = 0 THEN  /* Bug 3019986 Mohit Kapoor */
              /*Bug 1365777 - If item is a non-inventory item then do not update or insert
              into ic_summ_inv table - PPB */

              IF v_noninv_ind = 0
              THEN
                        /* RVK */
                        IF (int_rec.qc_grade_wanted is not null) THEN
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty  = onpurch_qty - (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                        onpurch_qty2 = onpurch_qty2- (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE   item_id      = v_item_id
                                AND     whse_code    = int_rec.to_whse
                                AND     qc_grade     = int_rec.qc_grade_wanted;


                        ELSE
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty      = onpurch_qty - (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                        onpurch_qty2     = onpurch_qty2- (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE   item_id          = v_item_id
                                AND     whse_code        = int_rec.to_whse
                                AND     qc_grade is  null;


                        END IF; /*(int_rec.qc_grade_wanted is not null) */
              END IF; /* If noninv_ind = 0 */
            END IF; /* Bug 3019986 ic_summ_inv_view_exists */
                /* BEGIN - Bug 1854280 Pushkar Upakare */
                IF int_rec.transaction_type = 'PLANNED' THEN
                      IF int_rec.cancellation_code IS NOT NULL THEN /* Cancel*/

                        BEGIN
                        UPDATE po_bpos_hdr
                        SET    amount_purchased = amount_purchased -
                                                nvl(int_rec.extended_price,0),
                             activity_ind     = 1,
                             rel_count        = rel_count + 1,
                             last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                             last_updated_by  = nvl(int_rec.last_updated_by, 0),
                             last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
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
                        SET    amount_purchased = amount_purchased -
                                                nvl(int_rec.extended_price,0),
                             qty_purchased    = qty_purchased    -
                                                nvl(int_rec.order_qty1,0),
                             last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                             last_updated_by  = nvl(int_rec.last_updated_by, 0),
                             last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
                             WHERE  bpo_id  = v_bpo_id
                             AND    line_id = v_bpo_line_id; /* Bug 1854280 Pushkar Upakare */
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
                      END IF; /* CANCELLATION_CODE not null */
                END IF; /* PLANNED */
                /* END - Bug 1854280 */

        END IF; /*nvl(v_old_po_status,0) <> 20*/


        GML_PO_SYNCH.cpg_aqcst_mv
                   (int_rec.po_header_id,
                    int_rec.po_line_id,
                    int_rec.po_line_location_id,
                    v_po_id,
                    v_line_id,
                    v_doc_type,
                    v_aqcst_status);

        IF v_aqcst_status=FALSE THEN
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error with cpg_aqcst_mv procedure');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END IF;


        /* Begin Bug 2817410 */
        GML_PO_GLDIST.P_row_num_upd := 0 ;

        GML_PO_GLDIST.receive_data ('PORD', v_po_id,
                                     v_line_id, int_rec.orgn_code,
                                     int_rec.po_date, v_ship_vendor_id,
                                     v_base_currency, int_rec.billing_currency,
                                     int_rec.to_whse, v_dtl_line_no,
                                     int_rec.item_no, int_rec.extended_price,
                                     int_rec.project_no, int_rec.order_qty1,
                                     int_rec.order_um1, v_item_id,
                                     int_rec.mul_div_sign,int_rec.purchase_exchange_rate,
                                     int_rec.net_price,4, FALSE,
                                     v_map_retcode,
                                     int_rec.transaction_type );

          IF v_map_retcode = 0 THEN
             v_acct_map_ind := 1;
          END IF;

        /* End Bug 2817410 */

      END; /* cancelling or closing a line */

      ELSE /* updates including cancel/close  */
      BEGIN

        /* pure updates, not cancel/close*/
        OPEN  line_id_cur(int_rec.po_header_id, int_rec.po_line_id,
                          int_rec.po_line_location_id);
        FETCH line_id_cur
        INTO  v_line_id;
        CLOSE line_id_cur;


        OPEN  old_po_line_status_cur(v_po_id, v_line_id);
        FETCH old_po_line_status_cur INTO v_old_po_status,v_old_cancellation_code;
        CLOSE old_po_line_status_cur;

          /* BEGIN BUG#1731582 P. Arvind Dath */

      OPEN  attr_hdr_cur(int_rec.PO_HEADER_ID);
      FETCH attr_hdr_cur INTO  attr_hdr_rec;
      CLOSE attr_hdr_cur;

        /* T. Ricci 5/12/98 changed who columns for GEMMS 5.0*/

        BEGIN
        UPDATE po_ordr_hdr
        SET    payvend_id             = nvl(v_pay_vendor_id,0),
               shipvend_id            = nvl(v_ship_vendor_id,0),
                                      /* HW BUG#:1095846 */
               po_status              = nvl(v_po_status,0),
               shipper_code           = int_rec.shipper_code,
               to_whse                = int_rec.to_whse,
                                                /* LE 26/AUG/98 NULL OK*/
                                      /* LE 26/AUG/98 NULL OK*/
               frtbill_mthd           = v_frtbill_mthd,
               billing_currency       = int_rec.billing_currency,
                                      /* LE 26/AUG/98 NULL OK*/
               purchase_exchange_rate =
                              nvl(int_rec.purchase_exchange_rate, 1), /* Bug 1427876 */
               terms_code             = v_terms_code,
               fob_code               = int_rec.fob_code,
               buyer_code             = v_buyer_code,  /* Lswamy - BUG 1829102 */
                /* Bug# 1357575  PB*/
               /* po_date                = nvl(int_rec.po_date, SYSDATE), */
               date_printed           = nvl(int_rec.date_printed, SYSDATE),
                                      /* LE 26/AUG/98 NULL OK*/
               revision_count         = int_rec.revision_count,
                                      /* LE 26/AUG/98 NULL OK*/
               print_count            = int_rec.print_count,
               last_update_date       = nvl(v_last_update_date, SYSDATE), /* Lswamy - BUG 1829102 */
               last_updated_by        = nvl(v_last_updated_by, 0),   /* Lswamy - BUG 1829102 */
                                      /* LE 26/AUG/98 NULL OK*/
               last_update_login      = int_rec.last_update_login,
               attribute1 = attr_hdr_rec.attribute1,
               attribute2 = attr_hdr_rec.attribute2,
                      attribute3 = attr_hdr_rec.attribute3,
                      attribute4 = attr_hdr_rec.attribute4,
                      attribute5 = attr_hdr_rec.attribute5,
                      attribute6 = attr_hdr_rec.attribute6,
                      attribute7 = attr_hdr_rec.attribute7,
                      attribute8 = attr_hdr_rec.attribute8,
                      attribute9 = attr_hdr_rec.attribute9,
                      attribute10 = attr_hdr_rec.attribute10,
                      attribute11 = attr_hdr_rec.attribute11,
                      attribute12 = attr_hdr_rec.attribute12,
                      attribute13 = attr_hdr_rec.attribute13,
                      attribute14 = attr_hdr_rec.attribute14
        WHERE  po_id = v_po_id;
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_ordr_hdr');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;
        OPEN  order_qty_price_cur(v_po_id, v_line_id);
        FETCH order_qty_price_cur INTO v_old_order_qty1,
                                       v_old_order_qty2,
                                       v_old_order_um1,
                                       v_old_order_um2,
                                       v_old_extended_price,
                                       v_dtl_line_no;
        CLOSE order_qty_price_cur;


        /* PPB */
        IF (v_old_order_um1 <> v_item_um1) THEN
                v_old_order_base_qty := GMICUOM.uom_conversion
                                                (v_item_id,0,
                                                v_old_order_qty1,
                                                v_old_order_um1,
                                                v_item_um1,0);
        ELSE
                v_old_order_base_qty := v_old_order_qty1;
        END IF;

        IF v_dualum_ind > 0 THEN
                v_order2 :=     GMICUOM.uom_conversion
                                        (v_item_id,0,
                                        int_rec.order_qty1,
                                        int_rec.order_um1,
                                        v_item_um2,0);

                v_old_order_sec_qty := GMICUOM.uom_conversion
                                                (v_item_id,0,
                                                v_old_order_base_qty,
                                                v_item_um1,
                                                v_item_um2,0);
        ELSE

                v_order2 := 0;
                v_old_order_sec_qty := 0;

        END IF;

          /* BEGIN BUG#1731582 P. Arvind Dath */

          OPEN  attr_dtl_cur(int_rec.PO_LINE_LOCATION_ID,
                             int_rec.PO_HEADER_ID,
                             int_rec.PO_LINE_ID);

      FETCH attr_dtl_cur INTO  attr_dtl_rec;
      CLOSE attr_dtl_cur;


        /* T. Ricci 5/12/98 changed who columns for GEMMS 5.0*/
        /* T. Ricci 11/10/98 removed trans_cnt = trans_cnt + 1 from update*/
        /* T. Ricci 12/01/98 removed line_no from update*/

        BEGIN
        UPDATE po_ordr_dtl
        SET    item_id           = v_item_id,
               item_desc         = nvl(v_item_desc, ' '),
               order_qty1        = nvl(int_rec.order_qty1,0),
                                 /* LE 26/AUG/98 NULL OK*/
               order_qty2        = v_order2,
               order_um1         = int_rec.order_um1,
                                 /* LE 26/AUG/98 NULL OK*/
               order_um2         = v_item_um2,
               net_price         = nvl(int_rec.net_price,0),
               extended_price    = nvl(int_rec.extended_price,0),
               price_um          = nvl(int_rec.price_um,' '),
                                 /* LE 26/AUG/98 NULL OK*/
               shipper_code      = int_rec.shipper_code,
               shipvend_id       = v_ship_vendor_id,
               to_whse           = nvl(int_rec.to_whse,' '),
                                 /* LE 26/AUG/98 NULL OK*/
               qc_grade_wanted   = int_rec.qc_grade_wanted,
                                 /* LE 26/AUG/98 NULL OK*/
               frtbill_mthd      = v_frtbill_mthd,
                                 /* LE 26/AUG/98 NULL OK*/
               terms_code        = v_terms_code,
                                 /* LE 26/AUG/98 NULL OK*/
               fob_code          = int_rec.fob_code,
                                 /* LE 26/AUG/98 NULL OK*/
               buyer_code        = v_buyer_code,   /* Lswamy - BUG 1829102 */
               agreed_dlvdate    = nvl(int_rec.agreed_dlvdate, sysdate),
               requested_dlvdate = nvl(int_rec.requested_dlvdate, sysdate),
               required_dlvdate  = nvl(int_rec.required_dlvdate, sysdate),
               sched_shipdate    = nvl(int_rec.sched_shipdate, sysdate),
               last_update_date  = nvl(v_last_update_date, SYSDATE), /* Lswamy - BUG 1829102 */
               last_updated_by   = nvl(v_last_updated_by, 0),  /* Lswamy - BUG 1829102 */
                                 /* LE 26/AUG/98 NULL OK*/
               last_update_login = int_rec.last_update_login,
               po_status         = nvl(v_po_status, 0),
               /* T.Ricci 7/8/98 integrity constraint change NULL's allowed*/
               cancellation_code = int_rec.cancellation_code,
               attribute1 = attr_dtl_rec.attribute1,
                      attribute2 = attr_dtl_rec.attribute2,
                      attribute3 = attr_dtl_rec.attribute3,
                      attribute4 = attr_dtl_rec.attribute4,
                      attribute5 = attr_dtl_rec.attribute5,
                      attribute6 = attr_dtl_rec.attribute6,
                      attribute7 = attr_dtl_rec.attribute7,
                      attribute8 = attr_dtl_rec.attribute8,
                      attribute9 = attr_dtl_rec.attribute9,
                      attribute10 = attr_dtl_rec.attribute10,
                      attribute11 = attr_dtl_rec.attribute11,
                      attribute12 = attr_dtl_rec.attribute12,
                      attribute13 = attr_dtl_rec.attribute13,
                      attribute14 = attr_dtl_rec.attribute14,
                      attribute15 = attr_dtl_rec.attribute15
        WHERE  po_id   = v_po_id
        AND    line_id = v_line_id;
        EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_ordr_dtl');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
        END;
      /* regular updates, not cancel/close*/
        IF  (int_rec.po_status NOT IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                        /* 'CLOSED FOR INVOICE',  B1820461 */
                                        'FINALLY CLOSED')) THEN
        BEGIN



                /* Added the code below to get the total received qty since only the delta should
                be added to the ic_tran_pnd table - Preetam Bamb */

                v_total_received_qty := Get_total_Received_qty(v_po_id,v_line_id,v_item_id,v_item_um1);

                IF v_item_um2 IS NOT NULL
                THEN
                        v_total_received_qty2 := GMICUOM.uom_conversion
                                                        (v_item_id,0,
                                                         v_total_received_qty,
                                                         v_item_um1,
                                                         v_item_um2,0);
                ELSE
                        v_total_received_qty2   := 0;
                END IF;


          /* T. Ricci 5/12/98 changed who columns for GEMMS 5.0*/
         BEGIN
          UPDATE ic_tran_pnd
          SET    item_id       = v_item_id,
/*                 co_code       = nvl(v_co_code, '-1'),
                 orgn_code     = nvl(int_rec.orgn_code, '-1'), */
                 whse_code     = int_rec.to_whse,
          /*     trans_qty     = nvl(v_order1,0) - nvl(v_total_received_qty,0), /* PPB nvl(int_rec.order_qty1, 0),  */
          /*     trans_qty2    = nvl(v_order2,0) - nvl(v_total_received_qty2,0),/*PPB Substracted old received qty */
                                                          /* LE 26/AUG/98 NULL OK*/
          /* B1878034 update trans_qty to zero if recv_qty is more than order_qty */
                 trans_qty     = DECODE(SIGN(nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                        -1,0,nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                 trans_qty2    = DECODE(SIGN(nvl(v_order2,0) - nvl(v_total_received_qty2,0)),
                                        -1,0,nvl(v_order2,0) - nvl(v_total_received_qty2,0)),
                 qc_grade      = int_rec.qc_grade_wanted, /* LE 26/AUG/98 NULL OK*/
                 trans_um      = int_rec.order_um1,
                 trans_um2     = v_item_um2,  /* LE 26/AUG/98 NULL OK*/
/** MC BUG# 1491754 update trans_date **/
                 trans_date    = nvl(int_rec.agreed_dlvdate,SYSDATE),
                 last_update_date  = nvl(int_rec.last_update_date, SYSDATE),
                 last_updated_by   = nvl(int_rec.last_updated_by, 0),
                 last_update_login = int_rec.last_update_login, /* LE 26/AUG/98 NULL OK*/
                 delete_mark    = 0  /* Uday Phadtare B1795095 */
          WHERE  doc_type      = v_doc_type
          AND    doc_id        = v_po_id
          AND    line_id       = v_line_id;
          EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating ic_tran_pnd');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
/*            retcode :=1;
              raise_application_error(-20001, err_msg);*/
         END;  /*update ic_tran_pnd*/

          /* For Standard/PPO release/Blanket release*/

      IF ic_summ_inv_view_exists = 0 THEN  /* Bug 3019986 Mohit Kapoor */
      /*Bug 1365777 - If item is a non-inventory item then do not update or insert
       into ic_summ_inv table - PPB */

        If v_noninv_ind = 0
        then
            BEGIN


                IF v_old_po_status = 20
                THEN

                        /* PPB */
                        IF (int_rec.qc_grade_wanted is not null) THEN
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty  = onpurch_qty + (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                        onpurch_qty2 = onpurch_qty2+ (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE   item_id      = v_item_id
                                AND     whse_code    = int_rec.to_whse
                                AND     qc_grade     = int_rec.qc_grade_wanted;


                        ELSE
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty      = onpurch_qty + (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                        onpurch_qty2     = onpurch_qty2+ (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE   item_id          = v_item_id
                                AND     whse_code        = int_rec.to_whse
                                AND     qc_grade is  null;


                        END IF; /*(int_rec.qc_grade_wanted is not null)*/

                ELSE
                        IF int_rec.qc_grade_wanted IS NULL
                        THEN
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty     = onpurch_qty
                                                                - nvl(v_old_order_base_qty,0) /*RVK nvl(v_old_order_qty1,0) */
                                                                + v_order1 /* RVK int_rec.order_qty1 */,
                                        onpurch_qty2    = onpurch_qty2
                                                                - nvl(v_old_order_sec_qty,0) /* RVK v_old_order_qty2 */
                                                                + nvl(v_order2,0)
                                WHERE  item_id   = v_item_id
                                AND    whse_code = int_rec.to_whse
                                AND    qc_grade  IS NULL;
                        ELSE
                                UPDATE  ic_summ_inv
                                SET     onpurch_qty     = onpurch_qty
                                                                - nvl(v_old_order_base_qty,0) /*RVK nvl(v_old_order_qty1,0) */
                                                                + v_order1 /* RVK int_rec.order_qty1 */,
                                        onpurch_qty2    = onpurch_qty2
                                                                - nvl(v_old_order_sec_qty,0) /* RVK v_old_order_qty2 */
                                                                + nvl(v_order2,0)
                                WHERE  item_id   = v_item_id
                                AND    whse_code = int_rec.to_whse
                                AND    qc_grade  = int_rec.qc_grade_wanted;
                        END  IF; /*int_rec.qc_grade_wanted IS NULL*/

                END IF; /*If v_po_old_status = 20 */



          EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating ic_summ_inv');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
          END; /*update ic_summ_inv*/

        End If; /* If noninv_ind = 0 */
      END IF; /* Bug 3019986 ic_summ_inv_view_exists */

          IF int_rec.transaction_type = 'PLANNED' THEN

            BEGIN
            UPDATE po_bpos_hdr
            SET    amount_purchased =
                   amount_purchased - nvl(v_old_extended_price,0) +
                                      nvl(int_rec.extended_price,0),
                   activity_ind     = 1,
                   rel_count        = rel_count + 1,
                   last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                   last_updated_by  = nvl(int_rec.last_updated_by, 0),
                   last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
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

        /*  T. Ricci 11/10/98 removed trans_cnt = trans_cnt + 1 from update*/

            BEGIN
            UPDATE po_bpos_dtl
            SET    amount_purchased =
                   amount_purchased - nvl(v_old_extended_price,0) +
                                      nvl(int_rec.extended_price,0),
                   qty_purchased    =
                   qty_purchased    - nvl(v_old_order_qty1,0) +
                                      nvl(int_rec.order_qty1,0),
                   last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                   last_updated_by  = nvl(int_rec.last_updated_by, 0),
                   last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
                   WHERE  bpo_id  = v_bpo_id
                   AND    line_id = v_bpo_line_id; /* Bug 1854280 Pushkar Upakare */
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
            UPDATE po_ordr_hdr
            SET    revision_count = revision_count + 1,
                   last_update_date = nvl(int_rec.last_update_date, SYSDATE),
                   last_updated_by  = nvl(int_rec.last_updated_by, 0),
                   last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
            WHERE  po_id          = v_po_id
            AND    revision_count = 0;
            EXCEPTION
             WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_ordr_hdr');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
            END;
          END IF; /*int_rec.transaction_type = 'PLANNED' */

/* HW BUG#:1178415 - Pass int_rec.mul_div_sign and int_rec.purchase_exchange_rate */

        /*PPB reset this varaible for every new line. */
        GML_PO_GLDIST.P_row_num_upd := 0 ;

        GML_PO_GLDIST.receive_data ('PORD', v_po_id,
                                 v_line_id, int_rec.orgn_code,
                                 int_rec.po_date, v_ship_vendor_id,
                                 v_base_currency, int_rec.billing_currency,
                                 int_rec.to_whse, v_dtl_line_no,
                                 int_rec.item_no, int_rec.extended_price,
                                 int_rec.project_no, int_rec.order_qty1,
                                 int_rec.order_um1, v_item_id,
                                 int_rec.mul_div_sign,int_rec.purchase_exchange_rate,
                                 int_rec.net_price,4, FALSE,
                                 v_map_retcode,
/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.Just added one paramerter passed to receive_data procedure.
P_transaction_type */
                                 int_rec.transaction_type       );

          IF v_map_retcode = 0 THEN
          v_acct_map_ind := 1;
          END IF;

        END; /*regular update*/

        ELSE  /* cancel/close*/
        BEGIN

                OPEN  old_po_line_status_cur(v_po_id, v_line_id);
                FETCH old_po_line_status_cur INTO v_old_po_status,v_old_cancellation_code;
                CLOSE old_po_line_status_cur;

          BEGIN
          UPDATE ic_tran_pnd
          SET    delete_mark   = 1          /* only column changed by GEMMS   */
          WHERE  doc_type      = v_doc_type
          AND    doc_id        = v_po_id
          AND    line_id       = v_line_id;
          EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error inserting into ic_tran_pnd')
;
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
/*            retcode :=1;
              raise_application_error(-20001, err_msg);*/
          END; /*update ic_tran_pnd*/

          BEGIN
              IF v_old_po_status <> 20
              THEN

                        v_total_received_qty := Get_total_Received_qty(v_po_id,v_line_id,v_item_id,v_item_um1);

                        IF v_item_um2 IS NOT NULL
                        THEN
                                v_total_received_qty2 := GMICUOM.uom_conversion
                                                                (v_item_id,0,
                                                                 v_total_received_qty,
                                                                 v_item_um1,
                                                                 v_item_um2,0);
                        ELSE
                                v_total_received_qty2   := 0 ;
                        END IF; /*IF v_item_um2 IS NOT NULL */

                IF ic_summ_inv_view_exists = 0 THEN  /* Bug 3019986 Mohit Kapoor */
                  /*Bug 1365777 - If item is a non-inventory item then do not update or insert
                  into ic_summ_inv table - PPB */

                  If v_noninv_ind = 0
                  then
                        IF int_rec.qc_grade_wanted IS NULL
                        THEN
                                UPDATE ic_summ_inv
                                SET     onpurch_qty  = onpurch_qty - (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                                onpurch_qty2 = onpurch_qty2 - (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE   item_id      = v_item_id
                                AND     whse_code    = int_rec.to_whse
                                AND     qc_grade     IS NULL;
                        ELSE
                                UPDATE ic_summ_inv
                                SET    onpurch_qty  = onpurch_qty - (nvl(v_order1,0) - nvl(v_total_received_qty,0)),
                                                onpurch_qty2 = onpurch_qty2 - (nvl(v_order2,0) - nvl(v_total_received_qty2,0))
                                WHERE  item_id      = v_item_id
                                AND    whse_code    = int_rec.to_whse
                                AND    qc_grade     = int_rec.qc_grade_wanted;
                        END IF;/*If int_rec.qc_grade_wanted IS NULL*/

                  End If; /* If noninv_ind = 0 */
                END IF; /* Bug 3019986 ic_summ_inv_view_exists */
              END IF; /*IF v_old_po_status <> 20 */

          EXCEPTION
             WHEN OTHERS THEN
               FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating ic_summ_inv');
               FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
               err_num := SQLCODE;
               err_msg := SUBSTRB (SQLERRM, 1, 100);
               FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
               retcode :=1;
               raise_application_error(-20001, err_msg);
          END;/*update ic_summ_inv*/

        END; /*cancel/close*/

      END IF;  /* int_rec.po_status NOT IN (...)   */

      GML_PO_SYNCH.cpg_aqcst_mv
                   (int_rec.po_header_id,
                    int_rec.po_line_id,
                    int_rec.po_line_location_id,
                    v_po_id,
                    v_line_id,
                    v_doc_type,
                    v_aqcst_status);

        IF v_aqcst_status=FALSE THEN
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error with cpg_aqcst_mv procedure');
           FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
           err_num := SQLCODE;
           err_msg := SUBSTRB (SQLERRM, 1, 100);
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
           retcode :=1;
           raise_application_error(-20001, err_msg);
        END IF;

      END;  /* end update including cancel/close*/

      END IF;

    IF error_ind = 0 THEN     /* B2594000 */
      BEGIN
      UPDATE po_ordr_dtl        /* For standard, blanket and PPOs */
      SET    acct_map_ind = v_acct_map_ind,
             last_update_date = nvl(v_last_update_date, SYSDATE),/* lswamy - BUG 1829102 */
             last_updated_by  = nvl(v_last_updated_by, 0), /* lswamy - BUG 1829102 */
             last_update_login = int_rec.last_update_login /* LE 26/AUG/98 NULL OK*/
      WHERE  po_id = v_po_id;
      EXCEPTION
            WHEN OTHERS THEN
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error updating po_ordr_dtl');
              FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
              err_num := SQLCODE;
              err_msg := SUBSTRB (SQLERRM, 1, 100);
              FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
              retcode :=1;
              raise_application_error(-20001, err_msg);
      END;
      /* set the record's flag as 'P', for processed*/

      UPDATE cpg_purchasing_interface
      SET    invalid_ind = 'P'           /*row processed*/
      WHERE  rowid       = int_rec.rowid;

      FND_MESSAGE.set_name('GML', 'PO_NUM_OK');
      FND_MESSAGE.set_token('v_po_no',v_po_no);
      v_err_message := FND_MESSAGE.GET;
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
      FND_FILE.PUT_LINE(FND_FILE.LOG, v_err_message );  /*message */
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
    ELSE
      UPDATE cpg_purchasing_interface
      SET    invalid_ind = 'E'           /* This line can not be inserted in po_ordr_dtl */
      WHERE  rowid       = int_rec.rowid;
    END IF;    /* B2594000 */

    END IF;  /* if gemms_validate is true*/

    /* fetch the next record in interface table*/

    COMMIT;

    FETCH  int_cur  INTO  int_rec;

  END LOOP;

  CLOSE    int_cur;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB (SQLERRM, 1, 100);
    FND_FILE.NEW_LINE(FND_FILE.LOG, 1 );
    FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg );  /*message */
    retcode := 1;
    RAISE_APPLICATION_ERROR(-20001, err_msg);

END cpg_int2gms;


END GML_PO_SYNCH;

/
