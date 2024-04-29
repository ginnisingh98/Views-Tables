--------------------------------------------------------
--  DDL for Package Body PO_GML_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GML_DB_COMMON" AS
/* $Header: GMLPOXCB.pls 120.0 2005/05/25 16:28:32 appldev noship $ */

  /*##########################################################################
  #
  #  FUNCTION
  #   check_process_org
  #
  #  DESCRIPTION
  #
  #      This function checks whether the inventory org. is process or not.
  #
  #
  # MODIFICATION HISTORY
  # 06-FEB-2001  MChandak    Created
  #
  ## #######################################################################*/

-- bug# 3061052 create global package variable to indicate whether
-- procurement FP J or higher is installed or not.
G_PRC_PATCH_MIN_J       BOOLEAN := NULL ;

FUNCTION check_process_org(x_inventory_org_id IN NUMBER) RETURN VARCHAR2 IS
v_process_enabled_flag  VARCHAR2(1);
v_progress VARCHAR2(3) := '010';
BEGIN
      IF nvl(x_inventory_org_id,-9999) < 0  OR  NOT GML_PO_FOR_PROCESS.check_po_for_proc
      THEN
         RETURN ('N');
      END IF;
      BEGIN
         SELECT process_enabled_flag INTO v_process_enabled_flag
         FROM   mtl_parameters
         WHERE  organization_id = x_inventory_org_id ;
         RETURN v_process_enabled_flag;

         EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN('N');
      END;

EXCEPTION
 WHEN OTHERS THEN
   po_message_s.sql_error('check_process_org',v_progress,sqlcode);
   raise;
END check_process_org ;


/*##########################################################################
  #
  #  FUNCTION
  #   get_opm_uom_code
  #
  #  DESCRIPTION
  #
  #
  #
  #
  # MODIFICATION HISTORY
  # 06-FEB-2001  MChandak    Created
  #
  ## #######################################################################*/
FUNCTION get_opm_uom_code(x_apps_unit_meas_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
v_um_code SY_UOMS_MST.UM_CODE%TYPE;
v_progress VARCHAR2(3) := '010';
BEGIN
	/*
     Select decode(length(uom.unit_of_measure), 1, uom.unit_of_measure,
                   2, uom.unit_of_measure, 3, uom.unit_of_measure,
                   4, uom.unit_of_measure, uom.uom_code) um_code
     into v_um_code
     from mtl_units_of_measure uom
     WHERE unit_of_measure = x_apps_unit_meas_lookup_code;

	*/
	/* Bug #3514053 */

     Select um_code
     Into   v_um_code
     From   sy_uoms_mst
     Where  unit_of_measure = x_apps_unit_meas_lookup_code;

     RETURN(v_um_code);

EXCEPTION
 WHEN OTHERS THEN
   po_message_s.sql_error('get_opm_uom_code',v_progress,sqlcode);
   raise;

END get_opm_uom_code;


/*##########################################################################
  #
  #  FUNCTION
  #   get_apps_uom_code
  #
  #  DESCRIPTION
  #
  #
  #
  #
  # MODIFICATION HISTORY
  # 06-FEB-2001  MChandak    Created
  #
  ## #######################################################################*/
FUNCTION get_apps_uom_code(x_opm_um_code IN VARCHAR2) RETURN VARCHAR2 IS
v_progress VARCHAR2(3) := '010';
v_unit_of_measure MTL_UNITS_OF_MEASURE.unit_of_measure%TYPE;
v_delete_mark NUMBER;
uom_deleted EXCEPTION ;
BEGIN
	/*
     SELECT uom.unit_of_measure,decode(sign(sysdate-uom.disable_date),1,1,0)
     INTO v_unit_of_measure,v_delete_mark
     FROM mtl_units_of_measure uom
     WHERE decode(length(uom.unit_of_measure), 1, uom.unit_of_measure,
                   2, uom.unit_of_measure, 3, uom.unit_of_measure,
                   4, uom.unit_of_measure, uom.uom_code) = x_opm_um_code;

     If v_delete_mark = 1 then
        raise uom_deleted;
     End If;

	*/
	/* Bug #3514053 */

     select unit_of_measure,delete_mark
     into   v_unit_of_measure,v_delete_mark
     from   sy_uoms_mst
     where  um_code = x_opm_um_code;

     If v_delete_mark = 1 then
	raise uom_deleted;
     End If;

     RETURN(v_unit_of_measure);

EXCEPTION
 WHEN uom_deleted THEN
   FND_MESSAGE.Set_Name('RLM', 'RLM_UOM_INACTIVE');
   FND_MESSAGE.Set_Token('UOM_CODE',x_opm_um_code);
   APP_EXCEPTION.Raise_Exception;
 WHEN OTHERS THEN
   po_message_s.sql_error('get_apps_uom_code',v_progress,sqlcode);
   raise;

END get_apps_uom_code;


/*##########################################################################
  #
  #  FUNCTION
  #   get_quantity_onhand
  #
  #  DESCRIPTION
  #  This function returns onhand quantity for a given item,lot/sublot,
  #
  #
  # MODIFICATION HISTORY
  # 06-FEB-2001  jsrivast    Created
  #
  ## #######################################################################*/


FUNCTION get_quantity_onhand( pitem_id IN NUMBER
                             ,plot_no  IN VARCHAR2
                             ,psublot_no IN VARCHAR2
                             ,porg_id    IN NUMBER
                             ,plocator_id IN NUMBER
                            ) RETURN NUMBER IS

v_progress VARCHAR2(3) := '010';
l_whse_code ic_whse_mst.whse_code%TYPE;
l_location ic_loct_mst.location%TYPE;
l_quantity_onhand NUMBER;
l_lot_id   ic_lots_mst.lot_id%TYPE;
BEGIN
  BEGIN
--get lot id
      IF (psublot_no is NULL) THEN
         select lot_id INTO l_lot_id
         from   ic_lots_mst
         where  item_id = pitem_id
         and    lot_no  = plot_no
         and    sublot_no is null;

      ELSE

         select lot_id INTO l_lot_id
         from   ic_lots_mst
         where  item_id = pitem_id
         and    lot_no  = plot_no
         and    sublot_no = psublot_no;

      END IF;

    EXCEPTION WHEN NO_DATA_FOUND
    THEN
        RETURN 0;

  END;

--get whse code
     select whse_code INTO l_whse_code
     from ic_whse_mst
     where mtl_organization_id = porg_id;


--get location code
    IF (plocator_id IS NULL) THEN
       l_location := fnd_profile.value('IC$DEFAULT_LOCT');

    ELSE
        BEGIN
                select location INTO l_location
                from ic_loct_mst
                where whse_code = l_whse_code
                and   inventory_location_id = plocator_id;

                EXCEPTION WHEN NO_DATA_FOUND
                THEN
                        RETURN 0;
        END;
    END IF;

--OK , all set let's get quantity onhand
BEGIN
    -- Bug 3869782 Round loct_onhand to 6 decimal
    select ROUND(loct_onhand,6) INTO l_quantity_onhand
    from ic_loct_inv
    where item_id = pitem_id
    and   lot_id  = l_lot_id
    and   whse_code = l_whse_code
    and   location = l_location;

    EXCEPTION WHEN NO_DATA_FOUND
    THEN
        RETURN 0;
END;

return l_quantity_onhand;

EXCEPTION
WHEN OTHERS THEN
   po_message_s.sql_error('get_quantity_onhand',v_progress,sqlcode);
   raise;

END get_quantity_onhand;

/*##########################################################################
  #
  #  PROCEDURE
  #   insert_po_errors
  #
  #  DESCRIPTION
  #  This procedure inserts records in po_interface_errors table.
  #  This is an autonomous transaction.
  #
  #
  # MODIFICATION HISTORY
  #
  #########################################################################*/
PROCEDURE INSERT_PO_ERRORS(  p_interface_type            IN  VARCHAR2
                           , p_interface_transaction_id  IN  NUMBER
                           , p_error_message             IN  VARCHAR2
                           , p_processing_date           IN  DATE
                           , p_creation_date             IN  DATE
                           , p_created_by                IN  NUMBER
                           , p_last_update_date          IN  DATE
                           , p_last_updated_by           IN  NUMBER
                           , p_last_update_login         IN  NUMBER
                           , p_request_id                IN  NUMBER
                           , p_program_application_id    IN  NUMBER
                           , p_program_id                IN  NUMBER
                           , p_program_update_date       IN  DATE
                           , p_table_name                IN  VARCHAR2) IS

   PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN
               INSERT INTO po_interface_errors
                        (  interface_type
                         , interface_transaction_id
                         , error_message
                         , processing_date
                         , creation_date
                         , created_by
                         , last_update_date
                         , last_updated_by
                         , last_update_login
                         , request_id
                         , program_application_id
                         , program_id
                         , program_update_date
                         , table_name )
                 VALUES (  p_interface_type
                         , p_interface_transaction_id
                         , p_error_message
                         , p_processing_date
                         , p_creation_date
                         , p_created_by
                         , p_last_update_date
                         , p_last_updated_by
                         , p_last_update_login
                         , p_request_id
                         , p_program_application_id
                         , p_program_id
                         , p_program_update_date
                         , p_table_name);

                 COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END INSERT_PO_ERRORS;

/*##########################################################################
  #
  #  FUNCTION
  #   GET_SHIPPED_QTY
  #
  #  DESCRIPTION
  #  This function returns Primary shipped quantity.
  #  required by the Receiving transactions screen.
  #
  # MODIFICATION HISTORY
  # 01-DEC-2004  pkanetka    Created this function for Bug 3950010 FP for 3936459
  #
  ## #######################################################################*/

FUNCTION GET_SHIPPED_QTY(l_delivery_detail_id IN NUMBER, l_trans_qty2 IN NUMBER) RETURN NUMBER IS

l_shipped_quantity     Number;
l_shipped_quantity2    Number;

Cursor cur_shipped_qty is
Select shipped_quantity, shipped_quantity2 from wsh_delivery_details
where  delivery_detail_id = l_delivery_detail_id;

BEGIN

  OPEN cur_shipped_qty;
  FETCH cur_shipped_qty INTO l_shipped_quantity, l_shipped_quantity2;
  CLOSE cur_shipped_qty;
  -- If fully receiving only then get shipped quantity as trans quantity.
  IF ( l_trans_qty2 =  l_shipped_quantity2) THEN
    RETURN l_shipped_quantity;
  ELSE
    RETURN 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;

END GET_SHIPPED_QTY;

/*##########################################################################
  #
  #  FUNCTION
  #   CREATE_INV_TRANS_OPM
  #
  #  DESCRIPTION
  #  This function is the inventory engine called from the Receiving Transaction Processor
  #  when it encounters a process item (OPM item shipped to an process organization).
  #
  #
  # MODIFICATION HISTORY
  # 06-FEB-2001  pbamb    Created
  # 23-MAR-2003  pbamb    Added code to handel internal orders with direct shipment
  #
  #########################################################################*/
PROCEDURE CREATE_INV_TRANS_OPM (P_interface_trx_id IN NUMBER,
                                P_Line_Id IN    NUMBER,
                                X_Return_Status IN OUT NOCOPY VARCHAR2) IS
        l_organization_id               NUMBER;
        l_doc_id                        NUMBER;
        l_line_id                       NUMBER;
        l_ora_item_id           NUMBER;
        l_locator_id            NUMBER;
        l_to_locator_id         NUMBER;
        l_from_locator_id       NUMBER;
        l_trans_date            DATE;
        l_trans_qty             NUMBER;
        l_trans_qty2            NUMBER;
        l_lot_exists            NUMBER;
        l_negate_lot_qty                NUMBER;
        l_return_status         VARCHAR2(1000);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(1000);
        dummy                   VARCHAR2(1000);
        l_trans_opm_um          VARCHAR2(25);
        l_trans_opm_um2         VARCHAR2(25);

        l_trans_um              rcv_transactions_interface.primary_unit_of_measure%TYPE;
        l_trans_um2             rcv_transactions_interface.primary_unit_of_measure%TYPE;
        l_src_doc_type          rcv_transactions_interface.source_document_code%TYPE;
        l_trx_type              rcv_transactions_interface.transaction_type%TYPE;
        l_destination_type_code rcv_transactions_interface.destination_type_code%TYPE;
        l_req_line_id           rcv_transactions_interface.requisition_line_id%TYPE;
        l_receipt_source_code   rcv_transactions_interface.receipt_source_code%TYPE;

        l_tran_row              ic_tran_cmp%ROWTYPE;
        l_tran_rec              gmi_trans_engine_pub.ictran_rec;

        l_whse_code             ic_tran_pnd.whse_code%TYPE;
        l_orgn_code             ic_tran_pnd.orgn_code%TYPE;
        l_loct_ctl              ic_whse_mst.loct_ctl%TYPE;
        l_item_loct_ctl         ic_item_mst.loct_ctl%TYPE;
        l_item_lot_ctl          ic_item_mst.lot_ctl%TYPE;
        l_co_code               ic_tran_pnd.co_code%TYPE;
        l_item_id               ic_tran_pnd.item_id%TYPE;
        l_lot_status            ic_tran_pnd.lot_status%TYPE;
        l_qc_grade              ic_tran_pnd.qc_grade%TYPE := NULL;
        l_location              ic_tran_pnd.location%TYPE;
        l_user_id               ic_tran_pnd.created_by%TYPE;
        l_doc_type              ic_tran_pnd.doc_type%TYPE;
        l_non_inv               ic_item_mst.noninv_ind%TYPE;
        l_lot_no                ic_lots_mst.lot_no%TYPE;
        l_sublot_no             ic_lots_mst.sublot_no%TYPE;
        ex_exception_found      EXCEPTION;

        l_creation_date         DATE;

        l_oe_line_id            NUMBER;
        l_oe_line_detail_id     NUMBER;
        l_auto_transact_code    VARCHAR2(25);

        l_loop_cnt              NUMBER;
        l_dummy_cnt             NUMBER;
        l_transaction_type      VARCHAR2(25);
        l_group_id              NUMBER;
        l_dummy                 VARCHAR2(2) := 'N';
        l_created_by            NUMBER;
        l_last_update_date      DATE;
        l_last_updated_by       NUMBER;
        l_last_update_login     NUMBER;
        l_request_id            NUMBER;
        l_program_application_id NUMBER;
        l_program_id            NUMBER;
        l_error_message         VARCHAR2(1000);

        l_receipt_qty           NUMBER;
        l_receipt_unit_of_measure     VARCHAR2(25);
        l_primary_quantity      NUMBER;
        l_receipt_opm_um        VARCHAR2(25);
        l_lot_receive_qty       NUMBER;

        -- lot status: bug 3278027
        l_item_sts_ctl          ic_item_mst.status_ctl%TYPE;
        l_rec_cnt               NUMBER := 0;
        l_ship_status           VARCHAR2(4) := NULL;
        l_rcpt_status           VARCHAR2(4) := NULL;
        l_txn_allowed           VARCHAR2(1) := NULL;
        -- Bug 3936459
        l_comments              VARCHAR2(240);
        l_wdd                   NUMBER;
        l_temp_qty              NUMBER;

CURSOR  cr_intorg_tran IS
select  TRANS_ID               ,
        ITEM_ID                ,
        LINE_ID                ,
        CO_CODE                ,
        ORGN_CODE              ,
        WHSE_CODE              ,
        LOT_ID                 ,
        LOCATION               ,
        DOC_ID                 ,
        DOC_TYPE               ,
        DOC_LINE               ,
        LINE_TYPE              ,
        REASON_CODE            ,
        CREATION_DATE          ,
        TRANS_DATE             ,
        TRANS_QTY              ,
        TRANS_QTY2             ,
        QC_GRADE               ,
        LOT_STATUS             ,
        TRANS_STAT             ,
        TRANS_UM               ,
        TRANS_UM2              ,
        OP_CODE                ,
        COMPLETED_IND          ,
        STAGED_IND             ,
        GL_POSTED_IND          ,
        EVENT_ID               ,
        DELETE_MARK            ,
        TEXT_CODE              ,
        LAST_UPDATE_DATE       ,
        CREATED_BY             ,
        LAST_UPDATED_BY        ,
        LAST_UPDATE_LOGIN      ,
        PROGRAM_APPLICATION_ID ,
        PROGRAM_ID             ,
        PROGRAM_UPDATE_DATE    ,
        REQUEST_ID             ,
        REVERSE_ID             ,
        PICK_SLIP_NUMBER       ,
        MVT_STAT_STATUS        ,
        MOVEMENT_ID            ,
        LINE_DETAIL_ID         ,
        INVOICED_FLAG
FROM    ic_tran_pnd
WHERE   doc_type = 'OMSO'
AND     line_id =  l_oe_line_id
AND     line_detail_id = l_oe_line_detail_id
AND     COMPLETED_IND = 1;

cr_intorg_tran_rec cr_intorg_tran%ROWTYPE;

-- ROI enhancements bug# 3061052
-- create two new cursors for retreiving lot information.
l_validation_flag       rcv_transactions_interface.validation_flag%TYPE ;


CURSOR cr_rcv_lots_interface IS
SELECT primary_quantity,
       quantity,
       secondary_quantity,
       lot_num,
       sublot_num,
       reason_code
FROM   rcv_lots_interface
WHERE  interface_transaction_id = p_interface_trx_id ;

CURSOR cr_mtl_transaction_lots_temp IS
SELECT primary_quantity,
       transaction_quantity quantity,
       secondary_quantity,
       lot_number lot_num,
       sublot_num,
       reason_code
FROM   mtl_transaction_lots_temp
WHERE  product_transaction_id =  p_interface_trx_id
AND    product_code = 'RCV' ;

l_lot_attributes_rec    cr_rcv_lots_interface%ROWTYPE ;

-- Bug 3876496
l_line_num NUMBER := 0;

-- PK Bug 3991705 Declarations
l_recv_qty               NUMBER;
l_receipt_um             VARCHAR2(25);
l_return_qty             NUMBER;
l_return_um              VARCHAR2(25);
l_lot_txn_qty            NUMBER;
l_rettxn_qty		 NUMBER;
l_rettxn_qty2		 NUMBER;
l_parent_transaction_id  NUMBER;
l_copy_return_txn        BOOLEAN := FALSE;
l_lot_qty_mismatch       BOOLEAN := TRUE;


CURSOR Cur_Receipt_qty IS
Select QUANTITY, UNIT_OF_MEASURE
From   rcv_transactions
where  TRANSACTION_ID = l_parent_transaction_id;


CURSOR Cur_rcv_lot_txn(l_parent_transaction_id IN NUMBER, v_lot_num IN VARCHAR2, v_sublot_num IN VARCHAR2) IS
Select PRIMARY_QUANTITY
From rcv_lot_transactions
where TRANSACTION_ID = l_parent_transaction_id
  and LOT_NUM = v_lot_num
  and SUBLOT_NUM = v_sublot_num;

CURSOR Cur_opm_txn(l_line_id IN NUMBER, v_item_id IN NUMBER, v_lot_id IN NUMBER) IS
SELECT trans_qty, trans_qty2
FROM   IC_TRAN_PND
where  doc_type = 'PORC'
  and  line_id = l_line_id
  and  delete_mark = 0
  and  completed_ind = 1
  and  lot_id = v_lot_id;

BEGIN

        x_return_status := '0';
        /* Get the details from the transaction table */
        -- bug# 3061052 get from_locator_id also.
        -- starting from 11.5.10 , receiving has added a from_locator_id
        -- the following logic is being used.
        -- assign locator_id to to_locator_id variable instead of locator_id.
        /**
        Trans. Type        Locator_id       From_locator_id    Parent trans type
          RECEIVE             R1                   -                  -
          DELIVER             D1                   R1               RECEIVE
          CORRECT(-VE)        R1                   D1               DELIVER
          CORRECT(+VE)        D1                   R1               DELIVER
          RTR                 R1                   D1               DELIVER
          RTC/RTV             -                    D1               DELIVER
        **/

        BEGIN
           SELECT rti.source_document_code,
                rti.transaction_type,
                rti.to_organization_id,
                rti.shipment_header_id,
                rti.shipment_line_id,
                rti.item_id,
                rti.locator_id,
                rti.from_locator_id,
                rti.transaction_date,
                rti.creation_date,
                rti.PRIMARY_QUANTITY,
                rti.PRIMARY_UNIT_OF_MEASURE,
                rti.SECONDARY_QUANTITY,
                rti.SECONDARY_UNIT_OF_MEASURE,
                rti.created_by ,
                rti.interface_source_line_id,
                rti.document_shipment_line_num,
                rti.auto_transact_code,
                rti.transaction_type,
                rti.group_id,
                rti.created_by,
                rti.last_update_date,
                rti.last_updated_by,
                rti.last_update_login,
                rti.request_id,
                rti.program_application_id,
                rti.program_id,
                rti.quantity,
                rti.unit_of_measure,
                rti.destination_type_code,
                rti.validation_flag,
                rti.requisition_line_id,     -- lot status: bug 3278027
                rti.receipt_source_code,      -- lot status: bug 3278027
                rti.parent_transaction_id,    -- Bug 3991705
                rsl.comments                  -- Bug 3936459
           INTO l_src_doc_type,
                l_trx_type,
                l_organization_id,
                l_doc_id,
                l_line_id,
                l_ora_item_id,
                l_to_locator_id,
                l_from_locator_id,
                l_trans_date,
                l_creation_date,
                l_trans_qty,
                l_trans_um,
                l_trans_qty2,
                l_trans_um2,
                l_user_id,
                l_oe_line_id,
                l_oe_line_detail_id,
                l_auto_transact_code,
                l_transaction_type,
                l_group_id,
                l_created_by,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                l_request_id,
                l_program_application_id,
                l_program_id     ,
                l_receipt_qty,
                l_receipt_unit_of_measure,
                l_destination_type_code,
                l_validation_flag,
                l_req_line_id,
                l_receipt_source_code,
                l_parent_transaction_id,
                l_comments
           FROM rcv_transactions_interface rti,
                rcv_shipment_lines rsl
           WHERE rti.shipment_line_id = rsl.shipment_line_id(+) and
                 rti.interface_transaction_id = p_interface_trx_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              x_return_status := '-5';
              raise ex_exception_found;
        END;

        -- PK Bug 3991705
        /*
        IF (l_trx_type = 'RETURN TO VENDOR' or l_trx_type = 'RETURN TO RECEIVING')

             Check Profile OPtion  GML Validate return
             Check Receipt_qty = Return qty  in same UM's in rcv_transactions
             Check if rcv_Lots_interface records for return match with rcv_lot_transactions for receipt
             then find ic_tran_pnd record for rcv_lots_interface for receipt and copy the quantitiy.

             If anything does not match do Nothing */

        IF (NVL(fnd_profile.value('GML_VAL_RET_CORR_LOT_QTY'), 'Y') = 'N') AND
           (l_trx_type = 'RETURN TO VENDOR' or l_trx_type = 'RETURN TO RECEIVING') THEN
          -- Now check for receipt_qty matching Return_qty
          OPEN Cur_Receipt_qty;
          FETCH Cur_Receipt_qty INTO l_recv_qty, l_receipt_um;
          CLOSE Cur_Receipt_qty;

          IF (l_recv_qty = l_receipt_qty) AND (l_receipt_um = l_receipt_unit_of_measure) THEN
            -- Compare current txn qty with rcv_lot_transaction Should loop through all lot txn
            FOR rliret in (select * from rcv_lots_interface where interface_transaction_id = p_interface_trx_id)
            LOOP
              OPEN Cur_rcv_lot_txn(l_parent_transaction_id, rliret.lot_num, rliret.sublot_num);
              FETCH Cur_rcv_lot_txn INTO l_lot_txn_qty;
              CLOSE Cur_rcv_lot_txn;

              IF (l_lot_txn_qty <> rliret.PRIMARY_QUANTITY) THEN
                l_lot_qty_mismatch := FALSE;
                EXIT;
              END IF;
            END LOOP;

            IF (l_lot_qty_mismatch = TRUE) THEN
              l_copy_return_txn := TRUE;
            END IF;


          END IF; -- (l_recv_qty = l_return_qty) AND (l_receipt_um = l_return_um)



        END IF; -- (l_val_ret_qty = 'N") AND(l_trx_type = 'RETURN TO VENDOR' or l_trx_type = 'RETURN TO RECEIVING')

        -- End Bug 3991705

        -- Begin Bug 3876496
           BEGIN

               select rs.line_num
               into   l_line_num
               from   rcv_shipment_lines rs, rcv_transactions rt
               where  rt.interface_transaction_id = p_interface_trx_id
               and    rs.shipment_header_id       = rt.shipment_header_id
               and    rs.shipment_line_id         = rt.shipment_line_id
               and    rt.transaction_type         IN('DELIVER','RETURN TO RECEIVING','CORRECT');

           EXCEPTION
             WHEN OTHERS THEN
               NULL;

           END;
        -- End Bug 3876496

        -- If its an internal order with transfer type intransit then return.
        IF (l_trx_type = 'SHIP' AND l_auto_transact_code = 'SHIP') THEN
           x_return_status := '1';
           RETURN;
        END IF;

        -- 3061052
        IF PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J THEN
             G_PRC_PATCH_MIN_J := TRUE;
        ELSE
             G_PRC_PATCH_MIN_J := FALSE;
        END IF;

        l_negate_lot_qty := 0;

        /* In case of returns negate the transaction quantity */
        IF (l_trx_type = 'RETURN TO VENDOR' or l_trx_type = 'RETURN TO RECEIVING' or l_trx_type = 'RETURN TO CUSTOMER') THEN
           l_trans_qty  := -l_trans_qty;
           l_trans_qty2         := -l_trans_qty2;
           l_negate_lot_qty     := 1;
        END IF;

        -- bug# 3061052
        -- from PRC FP J onwards for -ve corrections and returns, take the
        -- from_locator_id because from_locator_id stores the source location
        -- in this case DELIVER locatoin.
        -- below FP J , use locator_id ( to_locator_id).

        IF G_PRC_PATCH_MIN_J THEN
           IF l_trans_qty < 0 THEN
               l_locator_id := l_from_locator_id ;
           ELSE
               l_locator_id := l_to_locator_id ;
           END IF;
        ELSE
           l_locator_id := l_to_locator_id ;
        END IF;


        /* Get the whse, orgn and the company codes */
        BEGIN
           SELECT       w.whse_code, w.orgn_code, o.co_code,w.loct_ctl
           INTO         l_whse_code, l_orgn_code, l_co_code, l_loct_ctl
           FROM         ic_whse_mst w, sy_orgn_mst o
           WHERE        mtl_organization_id = l_organization_id
           AND          w.orgn_code = o.orgn_code;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              x_return_status := '-10';
              raise ex_exception_found;
        END;
        /* Get the OPM item_id */
        BEGIN
           -- lot status: bug 3278027, added l_item_sts_ctl
           SELECT oi.item_id , oi.noninv_ind, oi.loct_ctl, oi.lot_ctl, oi.status_ctl
           INTO l_item_id, l_non_inv, l_item_loct_ctl, l_item_lot_ctl, l_item_sts_ctl
           FROM ic_item_mst oi, mtl_system_items ai
           WHERE ai.organization_id = l_organization_id
           AND  ai.inventory_item_id = l_ora_item_id
           AND  ai.segment1 = oi.item_no;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              x_return_status := '-20';
              raise ex_exception_found;
        END;

        /* Validate the UOM exist in OPM and fetch the corresponding OPM um_code*/
        BEGIN
           IF l_trans_um IS NOT NULL THEN
              l_trans_opm_um := get_opm_uom_code(l_trans_um);
           END IF;

           IF l_trans_um2 IS NOT NULL THEN
              l_trans_opm_um2 := get_opm_uom_code(l_trans_um2);
           END IF;

           --Bug# 2968924 added receipt uom and get corresponding opm uom
           --we will need it to convert lot transaction qty into primary qty.
           IF l_receipt_unit_of_measure IS NOT NULL THEN
              l_receipt_opm_um := get_opm_uom_code(l_receipt_unit_of_measure);
           END IF;
        EXCEPTION
           WHEN OTHERS THEN
              x_return_status := '-30';
              raise ex_exception_found;
        END;

        l_location := fnd_profile.value('IC$DEFAULT_LOCT');

        --2491449 Preetam Bamb added check for item location control
        --send location to the inventory API only if both the item and the
        --warehouse are location controlled.Else send the default location populated above.

        IF l_locator_id is NOT NULL and l_loct_ctl * l_item_loct_ctl = 1
        then
           BEGIN
              select location
              into l_location
              from ic_loct_mst
              where whse_code = l_whse_code
              and  inventory_location_id = l_locator_id;
           EXCEPTION
              When NO_DATA_FOUND then
                 x_return_status := '-40';
                 raise ex_exception_found;
           END;
        ELSIF l_locator_id is NOT NULL and l_loct_ctl * l_item_loct_ctl > 1
        THEN
           BEGIN
              select    substrb(segment1,1,16)
              into      l_location
              from      mtl_item_locations
              where     inventory_location_id = l_locator_id;
           EXCEPTION
              When NO_DATA_FOUND then
              x_return_status := '-50';
              raise ex_exception_found;
           END;
        -- Bug 3597203 following condition added.
        ELSIF l_locator_id is NULL and l_loct_ctl * l_item_loct_ctl >= 1
        THEN
           x_return_status := '-55';
           raise ex_exception_found;
        END IF;

        /* Assign the values to the transaction record */
        l_tran_rec.item_id              := l_item_id;
        l_tran_rec.line_id              := p_line_id;
        l_tran_rec.co_code              := l_co_code;
        l_tran_rec.orgn_code            := l_orgn_code;
        l_tran_rec.whse_code            := l_whse_code;
        l_tran_rec.doc_id               := l_doc_id;
        l_tran_rec.doc_type             := 'PORC';
        -- Bug 3876496 assigned l_line_num instead of zero.
        l_tran_rec.doc_line             := l_line_num;
        l_tran_rec.line_type            := 0;
        l_tran_rec.reason_code          := NULL;

        --Bug 2407358 Trans date in ic_tran_pnd does not have time stamp since transaction_date
        --from rcv_Transactions_itnerface does not have time stamp
        --If the profile option GML: Use Creation Date as Transaction Date is set to Yes then
        --see if the date part of the creation_date and transaction_date from RTI table are same
        --if they are then use the creation_date which has the time stamp else use the transaction_date

        -- 3061052. starting from PRC FP J , receipt date in receiving forms will have a time portion.

        IF G_PRC_PATCH_MIN_J THEN
           l_tran_rec.trans_date        := l_trans_date;
        ELSE
           IF G_USE_CREATION_DATE = 'Y' THEN
               IF trunc(l_creation_date) = trunc(l_trans_date) THEN
                   l_tran_rec.trans_date        := l_creation_date;
               ELSE
                   l_tran_rec.trans_date        := l_trans_date;
               END IF;
           ELSE
               l_tran_rec.trans_date    := l_trans_date;
           END IF;
        END IF;

        l_tran_rec.trans_qty            := l_trans_qty;
        l_tran_rec.trans_qty2           := l_trans_qty2;
        l_tran_rec.qc_grade             := l_qc_grade;
        l_tran_rec.lot_id               := 0 ; /* (to be populated later) */
        l_tran_rec.location             := l_location;
        l_tran_rec.lot_no               := NULL;
        l_tran_rec.sublot_no            := NULL;
        l_tran_rec.lot_status           := NULL;
        l_tran_rec.trans_stat           := NULL;
        l_tran_rec.trans_um             := l_trans_opm_um;
        l_tran_rec.trans_um2            := l_trans_opm_um2;
        l_tran_rec.user_id              := l_user_id;

        l_tran_rec.staged_ind           := 0;
        --l_tran_rec.delete_mark                := 0;
        --l_tran_rec.gl_posted_ind      := 0;
        l_tran_rec.event_id             := 0;


        /* For internal order between 2 process org which have their shipping network set to
        DIRECT instead of INTRANSIT the transaction type is SHIP and the PROC transactions should mimic
        the OMSO transactions for lot information*/

        IF l_trx_type = 'SHIP' and l_auto_transact_code = 'DELIVER' and l_oe_line_id IS NOT NULL
        THEN

                OPEN    cr_intorg_tran;
                FETCH   cr_intorg_tran INTO cr_intorg_tran_rec;
                IF      cr_intorg_tran%NOTFOUND THEN
                        CLOSE   cr_intorg_tran;
                        x_return_status := '-60';
                        raise ex_exception_found;
                END IF;

                /* Assign the values to the transaction record */
                l_tran_rec.item_id              := l_item_id;
                l_tran_rec.line_id              := p_line_id;
                l_tran_rec.co_code              := l_co_code;
                l_tran_rec.orgn_code            := l_orgn_code;
                l_tran_rec.whse_code            := l_whse_code;
                l_tran_rec.doc_id               := l_doc_id;
                l_tran_rec.doc_type             := 'PORC';
                -- Bug 3876496 assigned l_line_num instead of zero.
                l_tran_rec.doc_line             := l_line_num;
                l_tran_rec.line_type            := 0;

                l_tran_rec.trans_qty            := cr_intorg_tran_rec.trans_qty * -1;
                l_tran_rec.trans_qty2           := cr_intorg_tran_rec.trans_qty2 * -1;
                l_tran_rec.trans_um             := cr_intorg_tran_rec.trans_um;
                l_tran_rec.trans_um2            := cr_intorg_tran_rec.trans_um2;
                l_tran_rec.lot_id               := cr_intorg_tran_rec.lot_id;
                l_tran_rec.reason_code          := cr_intorg_tran_rec.reason_code;
                l_tran_rec.location             := l_location;


                IF l_tran_rec.lot_id > 0 THEN

                   select qc_grade
                   into l_tran_rec.qc_grade
                   from ic_lots_mst
                   where item_id = l_tran_rec.item_id
                   and   lot_id = l_tran_rec.lot_id;

                   /* Select lot status Check a record in ic_loct_inv for the item,lot,warehouse,location
                   if no record in ic_loct_inv then get default status from ic_item_mst */

                   -- lot status: bug 3278027, this is for direct shipment of internal orders
                   -- Bug 3917381 changed following IF condition from l_item_sts_ctl = 1 to l_item_sts_ctl <> 0
                   IF l_item_sts_ctl <> 0 THEN
                      IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts = 'Y'
                           AND l_receipt_source_code = 'INTERNAL ORDER' ) THEN

                         GML_INTORD_LOT_STS.derive_porc_lot_status(   p_item_id         => l_item_id
                                                                    , p_whse_code       => l_tran_rec.whse_code
                                                                    , p_lot_id          => l_tran_rec.lot_id
                                                                    , p_location        => l_tran_rec.location
                                                                    , p_ship_lot_status => cr_intorg_tran_rec.lot_status
                                                                    , x_rcpt_lot_status => l_rcpt_status
                                                                    , x_txn_allowed     => l_txn_allowed
                                                                    , x_return_status   => l_return_status
                                                                    , x_msg_data        => l_msg_data );

			-- bug 3590359
                        -- proper error message was not getting logged in po_interface_erors in case
                        -- inventory lot status is different than shipped lot status.
                        -- the above API derive_porc_lot_status returns receipt status as NULL
                        -- in case transaction is not allowed. We need to get the actual receipt status
                        -- from the inventory for the message purpose.

			 IF l_return_status = 'S' THEN
                             IF (l_txn_allowed = 'N' OR l_rcpt_status IS NULL) THEN

                        -- start bug 3590359
                                BEGIN

                             	   SELECT lot_status
                             	   INTO   l_rcpt_status
  				   FROM   ic_loct_inv
  				   WHERE  item_id   = l_item_id
  				   AND    whse_code = l_tran_rec.whse_code
  				   AND    lot_id    = l_tran_rec.lot_id
  				   AND    location  = l_tran_rec.location ;

  				EXCEPTION WHEN OTHERS THEN
  				   l_rcpt_status := NULL ;

  				END ;

                             	FND_MESSAGE.SET_NAME('GMI', 'GMI_INTORD_LOTSTS_ERROR');
                             	FND_MESSAGE.SET_TOKEN('S1',cr_intorg_tran_rec.lot_status);
                             	FND_MESSAGE.SET_TOKEN('S2',l_rcpt_status);

                             	l_msg_data := FND_MESSAGE.GET ;

			-- end bug 3590359

                             	x_return_status := '-61';
                                raise ex_exception_found;

                             END IF;
                         END IF;

                         -- in case of error , the above api puts message in l_msg_data.

                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            x_return_status := '-62';
                            raise ex_exception_found;
                         END IF;

                         IF (l_txn_allowed = 'Y' AND l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                               l_tran_rec.lot_status := l_rcpt_status;
                         END IF;
                      ELSE
                         BEGIN
                            select    lot_status
                            into      l_tran_rec.lot_status
                            from      ic_loct_inv
                            where     item_id = l_item_id
                            and       WHSE_CODE       = l_tran_rec.whse_code
                            and       LOT_ID          = l_tran_rec.lot_id
                            and       LOCATION        = l_tran_rec.location;

                         EXCEPTION
                            When NO_DATA_FOUND then
                               select      lot_status
                               into        l_tran_rec.lot_status
                               from        ic_item_mst
                               where       item_id = l_item_id;

                            When OTHERS then
                               x_return_status := '-70';
                               raise ex_exception_found;
                         END;
                      END IF;  /* IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts = 'Y' */
                   END IF;   /* IF l_item_sts_ctl <> 0 */

                END IF; /* IF l_tran_rec.lot_id is not null */

                gmi_trans_engine_pub.create_completed_transaction(
                                        p_api_version => 1.0,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_commit => FND_API.G_FALSE,
                                        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                        p_tran_rec => l_tran_rec,
                                        x_tran_row => l_tran_row,
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data,
                                        p_table_name  =>  'IC_TRAN_PND');



                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := '-80';
                        raise ex_exception_found;
                END IF;

                --every thing is successful then return 1
                x_return_status := '1';

                RETURN; /*Transactions created in ic_tran_pnd for Direct Shipment and so return from here*/

        END IF; /*l_trx_type = 'SHIP' and l_auto_transact_code = 'DELIVER'*/

        /* Now create the completed transaction */
        /* If the lot information exists create transaction for each lot and quantity*/
        l_lot_exists             := 0;
        IF (l_trans_qty < 0) THEN
                l_negate_lot_qty := 1;
        END IF;

        -- ROI enhancements bug# 3061052
        -- use mtl_transaction_lots_temp instead of rcv_lots_interface for the ROI.
        -- From the applications(forms) lot data goes into rcv_lots_interface and mtl_transaction_lots_temp.
        -- From the ROI(starting from 11.5.10) lot data goes only into mtl_transaction_lots_temp.
        -- validation_flag is used to check the source of the data into rcv_transactions_interface
        -- if it is 'Y' it is coming from ROI(third party) else it is coming from the Receiving forms.

        IF l_validation_flag = 'Y' THEN
              OPEN  cr_mtl_transaction_lots_temp ;
        ELSE
              OPEN  cr_rcv_lots_interface ;
        END IF;

        LOOP
            IF l_validation_flag = 'Y' THEN
               FETCH  cr_mtl_transaction_lots_temp INTO l_lot_attributes_rec;
               IF cr_mtl_transaction_lots_temp%NOTFOUND THEN
                   CLOSE cr_mtl_transaction_lots_temp;
                   EXIT ;
               END IF;
            ELSE
               FETCH cr_rcv_lots_interface INTO l_lot_attributes_rec;
               IF cr_rcv_lots_interface%NOTFOUND THEN
                   CLOSE cr_rcv_lots_interface;
                   EXIT ;
               END IF;

            END IF;

            l_lot_exists                := 1;
            l_tran_rec.trans_qty        := l_lot_attributes_rec.primary_quantity;
            l_lot_receive_qty           := l_lot_attributes_rec.quantity;
            l_tran_rec.trans_qty2       := l_lot_attributes_rec.secondary_quantity;
            l_tran_rec.lot_no           := l_lot_attributes_rec.lot_num;
            l_tran_rec.sublot_no        := l_lot_attributes_rec.sublot_num;
            l_tran_rec.reason_code      := l_lot_attributes_rec.reason_code;

            BEGIN
                IF l_lot_attributes_rec.sublot_num is not null then
                        Select  lot_id, qc_grade
                        into    l_tran_rec.lot_id, l_tran_rec.qc_grade
                        from    ic_lots_mst
                        where   lot_no  = l_lot_attributes_rec.lot_num
                        and     sublot_no = l_lot_attributes_rec.sublot_num
                        and     item_id = l_item_id;
                ELSE
                        Select  lot_id, qc_grade
                        into    l_tran_rec.lot_id, l_tran_rec.qc_grade
                        from    ic_lots_mst
                        where   lot_no  = l_lot_attributes_rec.lot_num
                        and     sublot_no is null
                        and     item_id = l_item_id;
                End if;

                EXCEPTION
                        When NO_DATA_FOUND then
                        x_return_status := '-90';
                        raise ex_exception_found;
            END;

            /* Bug# 2968924 pbamb - Get the transaction quantity in
               Primary unit of measure if transaction uom and primary uom
               are not same and pass lot id to get lot specific conversion */
            IF l_receipt_unit_of_measure <> l_trans_um THEN

               gmicuom.icuomcv ( l_item_id,
                          l_tran_rec.lot_id,
                          l_lot_receive_qty,
                              l_receipt_opm_um,
                              l_trans_opm_um,
                          l_primary_quantity );

               l_tran_rec.trans_qty     := l_primary_quantity;

            END IF;

            /* for negative corrections */
            IF (l_negate_lot_qty = 1) THEN
                l_tran_rec.trans_qty    := -l_tran_rec.trans_qty;
                l_tran_rec.trans_qty2   := -l_tran_rec.trans_qty2;
            END IF;

            -- begin lot status: bug 3278027
            -- Bug 3917381 changed last AND condition from l_item_sts_ctl = 1 to l_item_sts_ctl <> 0
            IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts = 'Y'
                 AND l_req_line_id IS NOT NULL
                 AND l_receipt_source_code = 'INTERNAL ORDER'
                 AND l_item_sts_ctl <> 0 ) THEN
                 BEGIN
                 -- fetch the omso lots
                 GML_INTORD_LOT_STS.get_omso_lot_status(  p_req_line_id    => l_req_line_id
                                                        , p_item_id        => l_item_id
                                                        , x_lot_sts_tab    => GML_INTORD_LOT_STS.G_lot_sts_tab
                                                        , x_return_status  => l_return_status
                                                        , x_msg_data       => l_msg_data);
                 EXCEPTION
                    WHEN OTHERS THEN
                       x_return_status := '-91';
                       raise ex_exception_found;
                 END;
            END IF;
            -- end lot status: bug 3278027

                -- lot status: bug 3278027, this is for indirect shipment of internal orders
                -- Bug 3917381 changed following IF condition from l_item_sts_ctl = 1 to l_item_sts_ctl <> 0
                IF l_item_sts_ctl <> 0 THEN
                   IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts = 'Y'
                        AND l_receipt_source_code = 'INTERNAL ORDER' ) THEN

                      l_ship_status := NULL;
                      l_rec_cnt := GML_INTORD_LOT_STS.G_lot_sts_tab.count;
                      FOR i in 1 .. l_rec_cnt LOOP
                        IF GML_INTORD_LOT_STS.G_lot_sts_tab(i).lot_id = l_tran_rec.lot_id THEN
                           l_ship_status := GML_INTORD_LOT_STS.G_lot_sts_tab(i).lot_status;
                           EXIT;
                        END IF;
                      END LOOP;

                      -- omso lot/status found
                      IF l_ship_status IS NOT NULL THEN

                           -- derive porc lot status
                           GML_INTORD_LOT_STS.derive_porc_lot_status(  p_item_id         => l_item_id
                                                                     , p_whse_code       => l_tran_rec.whse_code
                                                                     , p_lot_id          => l_tran_rec.lot_id
                                                                     , p_location        => l_tran_rec.location
                                                                     , p_ship_lot_status => l_ship_status
                                                                     , x_rcpt_lot_status => l_rcpt_status
                                                                     , x_txn_allowed     => l_txn_allowed
                                                                     , x_return_status   => l_return_status
                                                                     , x_msg_data        => l_msg_data );

			-- bug 3590359
                        -- proper error message was not getting logged in po_interface_erors in case
                        -- inventory lot status is different than shipped lot status.
                        -- removed the begin/exception handling portion of the code. No need.

			   IF l_return_status = 'S' THEN
                             	IF (l_txn_allowed = 'N' OR l_rcpt_status IS NULL) THEN

                             	   -- start bug 3590359
                                   BEGIN

                             	      SELECT lot_status
                             	      INTO   l_rcpt_status
  				      FROM   ic_loct_inv
  				      WHERE  item_id   = l_item_id
  				      AND    whse_code = l_tran_rec.whse_code
  				      AND    lot_id    = l_tran_rec.lot_id
  				      AND    location  = l_tran_rec.location ;

  				   EXCEPTION WHEN OTHERS THEN
  				      l_rcpt_status := NULL ;

  				   END ;

                             	   FND_MESSAGE.SET_NAME('GMI', 'GMI_INTORD_LOTSTS_ERROR');
                             	   FND_MESSAGE.SET_TOKEN('S1',l_ship_status);
                             	   FND_MESSAGE.SET_TOKEN('S2',l_rcpt_status);

                             	   l_msg_data := FND_MESSAGE.GET ;

			-- end bug 3590359
                             	   x_return_status := '-92';
                                   raise ex_exception_found;
                             	END IF;
                           END IF;

                         -- in case of error , the above api puts message in l_msg_data.

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            	x_return_status := '-93';
                            	raise ex_exception_found;
                           END IF;


                           IF (l_txn_allowed = 'Y' AND l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                               l_tran_rec.lot_status := l_rcpt_status;
                           END IF;
                      END IF; -- IF l_ship_status IS NOT NULL
                   END IF; -- IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts = 'Y'

                   /* lot status: bug 3278027, null l_ship_status indicates omso lot not found
                      hence continue as per previous functionality                              */
                   IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts <> 'Y'
                        OR l_receipt_source_code <> 'INTERNAL ORDER'
                        OR l_ship_status IS NULL) THEN

                       /* Select lot status Check a record in ic_loct_inv for the item,lot,warehouse,location
                          if no record in ic_loct_inv then get default status from ic_item_mst                */

                        BEGIN
                           select  lot_status
                           into    l_tran_rec.lot_status
                           from    ic_loct_inv
                           where   item_id         = l_item_id
                           and     WHSE_CODE       = l_whse_code
                           and     LOT_ID          = l_tran_rec.lot_id
                           and     LOCATION        = l_location;

                        EXCEPTION
                           When NO_DATA_FOUND then
                                select  lot_status
                                into    l_tran_rec.lot_status
                                from    ic_item_mst
                                where   item_id = l_item_id;

                           When OTHERS then
                                x_return_status := '-100';
                                raise ex_exception_found;
                        END;
                   END IF; -- IF ( GML_INTORD_LOT_STS.G_retain_ship_lot_sts <> 'Y'
                END IF; -- IF l_item_sts_ctl <> 1
                -- end lot status: bug 3278027

                -- PK Bug 3991705

                -- Keep only txn copy code here

                IF (l_copy_return_txn = TRUE AND l_tran_rec.lot_id <> 0) THEN
                  -- Find and copy reversal of OPM Txn
                  OPEN Cur_opm_txn(l_parent_transaction_id , l_item_id , l_tran_rec.lot_id);
                  FETCH Cur_opm_txn INTO l_rettxn_qty, l_rettxn_qty2;
                  CLOSE Cur_opm_txn;
                  l_tran_rec.trans_qty  := -1 * l_rettxn_qty;
                  l_tran_rec.trans_qty2 := -1 * l_rettxn_qty2;
                END IF;

                -- End 3991705

            /*--------------------------------------------------------------------------------------------------
            Parameters that need to be passed to the gmi_trans_engine_pub.create_pending_transaction routine are
            Parameter   Value
            p_api_version       1.0
            p_init_msg_list     FND_API.G_FALSE
            p_commit    FND_API.G_FALSE
            p_validation_level  FND_API.G_VALID_LEVEL_FULL
            p_tran_rec  Record that needs to be processed. GMI_TRANS_ENGINE_PUB.ictran_rec
            x_tran_row  Processed record with trans id created in the procedure.
            x_return_status     Success of the procedure.
            x_msg_count Error message.
            */--------------------------------------------------------------------------------------------------
                -- PK Begin Bug 3936459
                BEGIN
                  l_wdd := 0;
-- l_trans_um = l_trans_um2  AND
                  IF (   l_comments IS NOT NULL AND ( substr(l_comments, 1, 8) = 'OPM WDD:')) THEN

                   l_wdd := to_number(substr(l_comments, 9));
                  END IF;
                EXCEPTION

                  WHEN OTHERS THEN
                    l_wdd := 0;
                END;
                l_temp_qty := 0;
                IF (l_wdd <> 0) THEN
                  l_temp_qty := GET_SHIPPED_QTY(l_wdd, l_tran_rec.trans_qty2);
                  IF (l_temp_qty <> 0) THEN
                    l_tran_rec.trans_qty := l_temp_qty;
                  END IF;
                END IF;
                -- PK End Bug 3936459.
            gmi_trans_engine_pub.create_completed_transaction(
                                        p_api_version => 1.0,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_commit => FND_API.G_FALSE,
                                        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                        p_tran_rec => l_tran_rec,
                                        x_tran_row => l_tran_row,
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data,
                                        p_table_name  =>  'IC_TRAN_PND');

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := '-110';
                raise ex_exception_found;
            END IF;
        END LOOP;

        /*If there were no lots for this transactions then do the following insert */
        IF l_lot_exists = 0 THEN
                gmi_trans_engine_pub.create_completed_transaction(
                                                p_api_version => 1.0,
                                                p_init_msg_list => FND_API.G_FALSE,
                                                p_commit => FND_API.G_FALSE,
                                                p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                p_tran_rec => l_tran_rec,
                                                x_tran_row => l_tran_row,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_table_name  =>  'IC_TRAN_PND');




                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := '-120';
                        raise ex_exception_found;
                END IF;

        END IF;

        /* Bug 3172267 Do not call DropShipReceive if a correction/return is made
           against a drop ship receipt. This is in line with discrete.            */
        IF ((l_trx_type = 'DELIVER' and l_destination_type_code = 'INVENTORY') OR
            (l_trx_type = 'RECEIVE' and l_auto_transact_code = 'DELIVER' and l_destination_type_code = 'INVENTORY'))
            THEN
            if (OE_INSTALL.Get_Active_Product = 'ONT' ) and nvl(l_non_inv,0) <> 1 then
                /* New OE => ONT is installed. */
                if (not OE_DS_PVT.DropShipReceive(P_Line_Id,'INV')) then
                        x_return_status := -95;
                        raise ex_exception_found;
                end if;
            end if;
        END IF;

        /* Everything went through smoothly, set the return status to success */
        x_return_status := '1';

EXCEPTION
        WHEN ex_exception_found THEN

        -- ROI enhancements bug# 3061052
           IF cr_mtl_transaction_lots_temp%ISOPEN THEN
               CLOSE cr_mtl_transaction_lots_temp;
           END IF;

           IF cr_rcv_lots_interface%ISOPEN THEN
               CLOSE cr_rcv_lots_interface;
           END IF;

           IF  x_return_status = '-5' THEN
                l_error_message := x_return_Status||' No data found in RCV_TRANSACTIONS_INTERFACE';

           ELSIF  x_return_status = '-10' THEN
              l_error_message := x_return_Status||' No data found in IC_WHSE_MST for organization with id '||to_char(l_organization_id);

           ELSIF  x_return_status = '-20' THEN
              l_error_message := x_return_Status||' No data found in IC_ITEM_MST for item with id '||to_char(l_ora_item_id);

           ELSIF  x_return_status = '-30' THEN
               l_error_message :=  x_return_Status||' When others in get_opm_uom_code';

           ELSIF  x_return_status = '-40' THEN
              l_error_message :=  x_return_Status||' No data found in IC_LOCT_MST for locator with id '||to_char(l_locator_id);

           ELSIF  x_return_status = '-50' THEN
              l_error_message :=  x_return_Status||' No data found in MTL_ITEM_LOCATIONS for locator with id '||to_char(l_locator_id);
           -- Bug 3597203 following condition added.
           ELSIF  x_return_status = '-55' THEN
              FND_MESSAGE.SET_NAME('PO','RCV_LOCATOR_CONTROL_INVALID');
              l_error_message :=  x_return_status||' : '||FND_MESSAGE.GET;
           ELSIF  x_return_status = '-60' THEN
              l_error_message :=  x_return_Status||' No data found in CURSOR CR_INTORG_TRAN for direct shipment in Internal Orders';
-- bug 3590359
           ELSIF  x_return_status = '-61' THEN
              l_error_message :=  x_return_Status||' '|| l_msg_data;
           ELSIF  x_return_status = '-62' THEN
              l_error_message :=  x_return_Status||' derive_ship_lot_status failed with unexpected error  '||l_msg_data;
           ELSIF  x_return_status = '-70' THEN

              x_return_status := sqlerrm;
              l_error_message := '-70'||x_return_Status||' When others while getting lot status';
           ELSIF x_return_status = '-80' THEN

                IF (l_msg_count > 0) THEN
                  l_loop_cnt  :=1;
                  LOOP

                     FND_MSG_PUB.Get   (
                                p_msg_index     => l_loop_cnt,
                                p_data          => l_msg_data,
                                p_encoded       => FND_API.G_FALSE,
                                p_msg_index_out => l_dummy_cnt);

                     --gml_po_log('l_msg_data :' ||l_msg_data);

                             l_loop_cnt  := l_loop_cnt + 1;
                     IF (l_loop_cnt > l_msg_count) THEN
                        EXIT;
                     END IF;

                   END LOOP;
                END IF;
              l_error_message := x_return_Status||'-'||l_msg_data;

           ELSIF x_return_status = '-90' THEN
              l_error_message := x_return_Status||' Lot not found in po_gml_db_common.create_inv_transaction';

           ELSIF x_return_status = '-91' THEN
              l_error_message := '-91'||x_return_Status||' When others in fetching omso lots, get_omso_lot_status';

-- bug# 3590359
-- removed text error in derive_porc_lot_status
           ELSIF x_return_status = '-92' THEN
              l_error_message := x_return_Status||' '||l_msg_data;

           ELSIF x_return_status = '-93' THEN
              l_error_message := x_return_Status||'  '||l_msg_data||'   unexpected error in derive_porc_lot_status';

           ELSIF x_return_status = '-94' THEN
              l_error_message := x_return_Status||'  '||l_msg_data||'   when others in derive_porc_lot_status';

           ELSIF x_return_status = '-100' THEN
              x_return_status := sqlerrm;
              l_error_message := '-100'||x_return_Status||' When others while getting lot status';

           ELSIF x_return_status = '-110' THEN
                IF (l_msg_count > 0) THEN
                  l_loop_cnt  :=1;
                  LOOP

                     FND_MSG_PUB.Get   (
                                p_msg_index     => l_loop_cnt,
                                p_data          => l_msg_data,
                                p_encoded       => FND_API.G_FALSE,
                                p_msg_index_out => l_dummy_cnt);

                     --gml_po_log('l_msg_data :' ||l_msg_data);

                     l_loop_cnt  := l_loop_cnt + 1;
                     IF (l_loop_cnt > l_msg_count) THEN
                        EXIT;
                     END IF;

                   END LOOP;
                END IF;
             l_error_message := x_return_Status||'-'||l_msg_data;

           ELSIF x_return_status = '-120' THEN
                IF (l_msg_count > 0) THEN
                  l_loop_cnt  :=1;
                  LOOP

                     FND_MSG_PUB.Get   (
                                p_msg_index     => l_loop_cnt,
                                p_data          => l_msg_data,
                                p_encoded       => FND_API.G_FALSE,
                                p_msg_index_out => l_dummy_cnt);

                     --gml_po_log('l_msg_data :' ||l_msg_data);

                     l_loop_cnt  := l_loop_cnt + 1;
                     IF (l_loop_cnt > l_msg_count) THEN
                        EXIT;
                     END IF;

                   END LOOP;
                END IF;
              l_error_message := x_return_Status||'-'||l_msg_data;

           ELSIF x_return_status = '-130' THEN
              l_error_message := x_return_Status||' error in call oe_ds_pvt.DropShipReceive';

           END IF;

           INSERT_PO_ERRORS( 'RECEIVING',
                             p_interface_trx_id,
                             l_error_message,
                             sysdate,
                             l_creation_date,
                             l_created_by,
                             l_last_update_date,
                             l_last_updated_by,
                             l_last_update_login,
                             l_request_id,
                             l_program_application_id,
                             l_program_id,
                             sysdate,
                             'IC_TRAN_PND' );

        WHEN OTHERS THEN
            x_return_status := SQLERRM;
            l_error_message := '-140 '||x_return_Status||' when others in PO_GML_DB_COMMON.CREATE_INV_TRANS_OPM';

            -- ROI enhancements bug# 3061052
           IF cr_mtl_transaction_lots_temp%ISOPEN THEN
               CLOSE cr_mtl_transaction_lots_temp;
           END IF;

           IF cr_rcv_lots_interface%ISOPEN THEN
               CLOSE cr_rcv_lots_interface;
           END IF;

            INSERT_PO_ERRORS( 'RECEIVING',
                              p_interface_trx_id,
                              l_error_message,
                              sysdate,
                              l_creation_date,
                              l_created_by,
                              l_last_update_date,
                              l_last_updated_by,
                              l_last_update_login,
                              l_request_id,
                              l_program_application_id,
                              l_program_id,
                              sysdate,
                              'IC_TRAN_PND' );

END CREATE_INV_TRANS_OPM;


/*##########################################################################
  #
  #  FUNCTION
  #   GET_CORR_QTY
  #
  #  DESCRIPTION
  #  This function returns correction quantity for a given transaction
  #
  #
  # MODIFICATION HISTORY
  # 06-APR-2001  pbamb    Created
  #
  ## #######################################################################*/

PROCEDURE GET_CORR_QTY( X_tran_type     IN VARCHAR2,
                        X_tran_id       IN NUMBER,
                        X_final_qty     IN OUT NOCOPY NUMBER)
IS

Cursor get_corr_qty( v_tran_id NUMBER) is
        Select  transaction_type,
                secondary_quantity
        from    rcv_transactions
        where   parent_transaction_id = v_tran_id
        and     transaction_type in ('CORRECT','RETURN TO RECEIVING') ;

BEGIN

        For  v_rec  in  get_corr_qty(X_tran_id)
        Loop
                If v_rec.transaction_type = 'CORRECT'
                then
                        X_final_qty := nvl(X_final_qty,0) - nvl(v_rec.secondary_quantity,0);

                end if;

                If X_tran_type = 'DELIVER' and v_rec.transaction_type = 'RETURN TO RECEIVING'
                Then
                        X_final_qty := nvl(X_final_qty,0) + nvl(v_rec.secondary_quantity,0);
                End If;

        End Loop;
END GET_CORR_QTY;


/*##########################################################################
  #
  #  FUNCTION
  #   GET_SECONDARY_TRAN_QTY
  #
  #  DESCRIPTION
  #  This function returns secondary transaction quantity for a given transaction
  #  required by the Receiving transactions screen. This procedure is being called by the
  #  package RCV_QUANTITIES_S.get_transaction_quantity in RCVTXQUB.pls file.
  #
  # MODIFICATION HISTORY
  # 06-APR-2001  pbamb    Created
  #
  ## #######################################################################*/
PROCEDURE GET_SECONDARY_TRAN_QTY ( p_transaction_id          IN NUMBER,
                                   p_secondary_available_qty IN OUT NOCOPY NUMBER) IS

Cursor get_qty(v_transaction_id IN NUMBER) is
        select  transaction_type,
                secondary_quantity
        from    rcv_transactions
        where   transaction_id = v_transaction_id;

Cursor get_child_qty(v_p_transaction_id IN NUMBER) is
        select  transaction_id,
                transaction_type,
                secondary_quantity
        from    rcv_transactions
        where   parent_transaction_id = v_p_transaction_id;

v_transaction_type      VARCHAR2(100);
v_final_qty             NUMBER DEFAULT 0;

BEGIN

        Open get_qty(p_transaction_id);
        Fetch get_qty into v_transaction_type,
                           v_final_qty;
        Close get_qty;

        If v_transaction_type   = 'RECEIVE'
        then
                For t_rec in get_child_qty(p_transaction_id)
                LOOP
                        If t_rec.transaction_type  in ('CORRECT' )
                        then
                                v_final_qty := nvl(v_final_qty,0) + nvl(t_rec.secondary_quantity,0);

                        ElsIf t_rec.transaction_type  in ( 'REJECT' ,'ACCEPT' )
                        then
                                v_final_qty := nvl(v_final_qty,0) - nvl(t_rec.secondary_quantity,0);
                                get_corr_qty(t_rec.transaction_type,t_rec.transaction_id ,v_final_qty);

                        ElsIf t_rec.transaction_type  in ( 'RETURN TO VENDOR' ,'RETURN TO RECEIVING','DELIVER')
                        then
                                v_final_qty := nvl(v_final_qty,0) - nvl(t_rec.secondary_quantity,0);
                                get_corr_qty(t_rec.transaction_type,t_rec.transaction_id ,v_final_qty);
                        End if;

                End LOOP;

        Elsif  v_transaction_type in ( 'REJECT' ,'ACCEPT')
        then
                For c_rec in get_child_qty(p_transaction_id)
                LOOP
                        If c_rec.transaction_type = 'CORRECT'
                        then
                                v_final_qty :=  nvl(v_final_qty,0) + nvl(c_rec.secondary_quantity,0);

                        Elsif c_rec.transaction_type in ('ACCEPT' ,'REJECT')
                        then
                                v_final_qty :=  nvl(v_final_qty,0) - nvl(c_rec.secondary_quantity,0);
                                get_corr_qty(c_rec.transaction_type,c_rec.transaction_id ,v_final_qty);
                        End if;

                End LOOP;

        Elsif  v_transaction_type in ('DELIVER')
        then
                For c_rec in get_child_qty(p_transaction_id)
                LOOP
                        If c_rec.transaction_type = 'CORRECT'
                        then
                                v_final_qty :=  nvl(v_final_qty,0) + nvl(c_rec.secondary_quantity,0);
                        End if;
                End LOOP;
        Elsif  v_transaction_type in ('MATCH')
        then
                For c_rec in get_child_qty(p_transaction_id)
                LOOP
                        If c_rec.transaction_type in ( 'RETURN TO VENDOR' ,'RETURN TO RECEIVING','DELIVER')
                        then
                                v_final_qty :=  nvl(v_final_qty,0) - nvl(c_rec.secondary_quantity,0);
                                get_corr_qty(c_rec.transaction_type,c_rec.transaction_id ,v_final_qty);

                        End if;
                End LOOP;
        End if;

        p_secondary_available_qty  := v_final_qty;
END GET_SECONDARY_TRAN_QTY;

/*##########################################################################
  #
  #  PROCEDURE
  #   VALIDATE_QUANTITY
  #
  #  DESCRIPTION
  #  This procedure validates the primary and secondary qty.are within deviation
  #  and if not it will return correct secondary qty.If secondary qty is null,
  #  it will calculate the corr. secondary qty for given primary qty.
  #
  #
  # MODIFICATION HISTORY
  # 07-JUN-2001  mchandak    Created
  #
  ## #######################################################################*/


PROCEDURE VALIDATE_QUANTITY(
        x_opm_item_id           IN NUMBER,
        x_opm_dual_uom_type     IN NUMBER,
        x_quantity              IN NUMBER,
        x_opm_um_code           IN VARCHAR2,
        x_opm_secondary_uom     IN VARCHAR2,
        x_secondary_quantity    IN OUT NOCOPY NUMBER) IS

  v_ret_val     pls_integer;
  v_secondary_quantity_temp   number := x_secondary_quantity;
  BEGIN
        if x_opm_dual_uom_type = 0 or x_quantity is null then
                return;
        end if;

        if x_secondary_quantity is not null and x_quantity is not null then
                v_ret_val := gmicval.dev_validation ( x_opm_item_id,
                                              0,
                                              x_quantity,
                                              x_opm_um_code,
                                              x_secondary_quantity,
                                              x_opm_secondary_uom,
                                              0 );
                if v_ret_val = -68 or v_ret_val = -69 then
                        null;  -- deviation error. need to recalculate secondary quantity.
                elsif v_ret_val < 0 then
                        return;  -- unknown error..
                else  -- everything is fine
                        if x_opm_dual_uom_type = 1 then
                                null; -- for uom_type = 1,the procedure doesn't check for deviation
                        else
                                return;
                        end if;
                end if;

        end if;

        gmicuom.icuomcv ( x_opm_item_id,
                          0,
                          x_quantity,
                          x_opm_um_code,
                          x_opm_secondary_uom,
                          v_secondary_quantity_temp );

        X_secondary_quantity := round(v_secondary_quantity_temp,5);

EXCEPTION
WHEN OTHERS THEN
    return;
END VALIDATE_QUANTITY;

/*##########################################################################
  #
  #  PROCEDURE
  #   CREATE_LOT_SPECIFIC_CONVERSION
  #
  #  DESCRIPTION
  #  This procedure will create lot specific conversion for a new lot if user
  #  selects a yes to the question asked in RCVGMLCR.pld in when-validate-record
  #  of Lot Entry block.
  # MODIFICATION HISTORY
  # 20-JUN-2002  pbamb    Created
  #
  ## #######################################################################*/


PROCEDURE CREATE_LOT_SPECIFIC_CONVERSION(
        x_item_number           IN VARCHAR2,
        x_lot_number            IN VARCHAR2,
        x_sublot_number         IN VARCHAR2,
        x_from_uom              IN VARCHAR2,
        x_to_uom                IN VARCHAR2,
        x_type_factor           IN NUMBER,
        x_status                IN OUT NOCOPY VARCHAR2,
        x_data                  IN OUT NOCOPY VARCHAR2) IS

l_trans_rec     Gmigapi.conv_rec_typ;
l_ic_item_cnv_row IC_ITEM_CNV%ROWTYPE;
l_status        VARCHAR2(1);
l_return_status VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count         NUMBER;
l_count_msg     NUMBER;
l_data          VARCHAR2(2000);
l_dummy_cnt     NUMBER  :=0;
l_record_count  NUMBER  :=0;
e_lot_conv_failed       EXCEPTION;

BEGIN

        l_trans_rec.item_no     := x_item_number;
        l_trans_rec.lot_no      := x_lot_number ;
        l_trans_rec.sublot_no   := x_sublot_number;
        l_trans_rec.from_uom    := x_from_uom   ;
        l_trans_rec.to_uom      := x_to_uom     ;
        l_trans_rec.type_factor := x_type_factor;
        l_trans_rec.user_name   := FND_GLOBAL.USER_NAME;

        -- Set the context for the GMI APIs
        IF( NOT Gmigutl.Setup(l_trans_rec.user_name) )
        THEN
                RAISE e_lot_conv_failed;
        END IF;

        -- Call the standard API and check the return status
        Gmipapi.Create_Item_Lot_Conv
        ( p_api_version         => 3.0
        , p_init_msg_list       => FND_API.G_TRUE
        , p_commit              => FND_API.G_FALSE
        , p_validation_level    => FND_API.G_valid_level_full
        , p_conv_rec            => l_trans_rec
        , x_ic_item_cnv_row     => l_ic_item_cnv_row
        , x_return_status       => l_status
        , x_msg_count           => l_count
        , x_msg_data            => l_data
        );

        x_status :=     l_status;

        FOR l_loop_cnt IN 1..l_count
        LOOP
                FND_MSG_PUB.Get(
                    p_msg_index     => l_loop_cnt,
                    p_data          => l_data,
                    p_encoded       => FND_API.G_FALSE,
                    p_msg_index_out => l_dummy_cnt);

                x_data := x_data||l_data;

        END LOOP;

        EXCEPTION
        WHEN e_lot_conv_failed THEN
                -- API Failed. Error message must be on stack.
                l_count_msg := fnd_msg_pub.Count_Msg;

                FOR l_loop_cnt IN 1..l_count_msg
                LOOP
                        FND_MSG_PUB.GET(P_msg_index => l_loop_cnt,
                        P_data          => l_data,
                        P_encoded       => FND_API.G_FALSE,
                        P_msg_index_out => l_dummy_cnt);

                        x_data := x_data||l_data;

                END LOOP;
                X_status := 'U';


        WHEN OTHERS THEN
                RAISE;

END CREATE_LOT_SPECIFIC_CONVERSION;

END PO_GML_DB_COMMON;

/
