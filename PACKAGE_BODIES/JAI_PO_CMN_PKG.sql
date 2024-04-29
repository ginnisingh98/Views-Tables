--------------------------------------------------------
--  DDL for Package Body JAI_PO_CMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_CMN_PKG" AS
/* $Header: jai_po_cmn.plb 120.7.12010000.2 2009/03/03 12:47:39 mbremkum ship $ */
 v_conv_rate    NUMBER;
 v_inv_org_id   NUMBER;

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_po_cmn -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.3
               Ramananda for bug#4428980. Removal of SQL LITERALs is done

06-Jul-2005    rallamse for bug# PADDR Elimination
               1. Removed the procedures query_locator_for_release, query_locator_for_hdr and query_locator_for_line
	       from both specification and body.

15-feb-2007    vkaranam for Bug #4601436,File Version 120.4
               1.Forward porting the change sin 11i bug 4562363(autocreate req to spo fails due to localization trigger)

16-Jan-2008 Kevin Cheng for Retroactive Price Enhancement
            Add parameter for process_release_shipment procedure and procedures called in it.

--------------------------------------------------------------------------------------*/

/*  PROCEDURE insert_accrual_reconcile
            (p_transaction_id number,
             p_po_line_location_id number,
             p_po_distribution_id number,
             p_shipment_line_id number,
             p_organization_id number,
             p_transaction_date date,
             p_transaction_amount number,
             p_accrual_account_id number
             )
  IS

    v_operating_unit        org_organization_definitions.operating_unit % type;
    v_line_num              po_lines_all.line_num % type;
    v_item_id               rcv_shipment_lines.item_id % type;
    v_vendor_name           po_vendors.vendor_name % type;
    v_receipt_num           rcv_shipment_headers.receipt_num % type;
    v_po_num                po_headers_all.segment1 % type;
    v_unit_price            number;
    v_primary_uom           mtl_system_items.primary_unit_of_measure % type;

    CURSOR org_cur IS
      SELECT operating_unit
        FROM org_organization_definitions
       WHERE organization_id = p_organization_id;

    CURSOR rcv_cur IS
      SELECT source_document_code,
             unit_of_measure,
             shipment_header_id,
             po_header_id,
             po_line_id,
             po_unit_price,
             requisition_line_id,
             vendor_id,
             quantity
        FROM rcv_transactions
       WHERE transaction_id = p_transaction_id;

    v_rcv_rec                rcv_cur % ROWTYPE;

    CURSOR line_cur IS
      SELECT line_num
        FROM po_lines_all
       WHERE po_line_id = v_rcv_rec.po_line_id;

    CURSOR ven_cur IS
      SELECT vendor_name
        FROM po_vendors
       WHERE vendor_id = v_rcv_rec.vendor_id;

    Cursor ship_cur IS
      SELECT item_id
        FROM rcv_shipment_lines
       WHERE shipment_line_id = p_shipment_line_id;

    CURSOR head_rec IS
      SELECT receipt_num
        FROM rcv_shipment_headers
       WHERE shipment_header_id = v_rcv_rec.shipment_header_id;

    CURSOR po_cur IS
      SELECT segment1
        FROM po_headers_all
       WHERE po_header_id = v_rcv_rec.po_header_id;

    CURSOR uom_cur IS
      SELECT primary_unit_of_measure
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = v_item_id;

	 lv_accrual_code  po_accrual_reconcile_temp_all.accrual_code%type ;
	 lv_po_trans_type po_accrual_reconcile_temp_all.po_transaction_type%type ;
	 lv_destination_type_code po_accrual_reconcile_temp_all.destination_type_code%type ;
  BEGIN

    OPEN rcv_cur;
      FETCH rcv_cur INTO v_rcv_rec;
    CLOSE rcv_cur;

    OPEN org_cur;
      FETCH org_cur INTO v_operating_unit;
    CLOSE org_cur;

    OPEN ship_cur;
      FETCH ship_cur INTO v_item_id;
    CLOSE ship_cur;

    OPEN head_rec;
      FETCH head_rec INTO v_receipt_num;
    CLOSE head_rec;

    OPEN uom_cur;
      FETCH uom_cur INTO v_primary_uom;
    CLOSE uom_cur;

    IF v_rcv_rec.source_document_code = 'PO'
    THEN

      OPEN line_cur;
        FETCH line_cur INTO v_line_num;
      CLOSE line_cur;

      OPEN ven_cur;
        FETCH ven_cur INTO v_vendor_name;
      CLOSE ven_cur;

      OPEN po_cur;
        FETCH po_cur INTO v_po_num;
      CLOSE po_cur;

      v_unit_price := v_rcv_rec.po_unit_price;

    ELSIF v_rcv_rec.source_document_code = 'INVENTORY'
    THEN
      For price_rec IN (SELECT list_price_per_unit price
                          FROM mtl_system_items
                         WHERE inventory_item_id = v_item_id
                           AND organization_id = p_organization_id)
      LOOP
        v_unit_price := price_rec.price;
      END LOOP;
    ELSIF v_rcv_rec.source_document_code = 'REQ'
    THEN
      For price_rec IN (SELECT unit_price
                          FROM po_requisition_lines_all
                         WHERE requisition_line_id = v_rcv_rec.requisition_line_id)
      LOOP
        v_unit_price := price_rec.unit_price;
      END LOOP;
    END IF;

  lv_accrual_code :=   'Receive'  ;
  lv_po_trans_type :=  'RECEIVE'  ;
  lv_destination_type_code := 'INVENTORY';

    INSERT INTO po_accrual_reconcile_temp_all
                (transaction_date,
                 inventory_item_id,
                 transaction_quantity,
                 po_header_id,
                 po_line_num,
                 po_line_id,
                 vendor_name,
                 transaction_organization_id,
                 vendor_id,
                 item_master_organization_id,
                 accrual_account_id,
                 accrual_code,
                 po_transaction_type,
                 receipt_num,
                 po_transaction_id,
                 po_unit_of_measure,
                 primary_unit_of_measure,
                 net_po_line_quantity,
                 po_num,
                 po_distribution_id,
                 transaction_unit_price,
                 avg_receipt_price,
                 transaction_amount,
                 transaction_source_code,
                 write_off_flag,
                 destination_type_code,
                 net_po_line_amount,
                 aging_date,
                 org_id,
                 line_location_id)
         VALUES (p_transaction_date,
                 v_item_id,
                 -v_rcv_rec.quantity,
                 v_rcv_rec.po_header_id,
                 v_line_num,
                 v_rcv_rec.po_line_id,
                 v_vendor_name,
                 p_organization_id,
                 v_rcv_rec.vendor_id,
                 v_operating_unit,
                 p_accrual_account_id,
                 lv_accrual_code, --'Receive',
                 lv_po_trans_type, --'RECEIVE',	    -- Modified by Ramananda for removal of SQL LITERALs :bug#4428980
                 v_receipt_num,
                 p_transaction_id,
                 v_rcv_rec.unit_of_measure,
                 v_primary_uom,
                 - (v_rcv_rec.quantity * 2),
                 v_po_num,
                 p_po_distribution_id,
                 v_unit_price,
                 -(v_unit_price / 2),
                 -p_transaction_amount,
                 v_rcv_rec.source_document_code,
                 'N',
                 lv_destination_type_code, --'INVENTORY',
                 -p_transaction_amount,
                 p_transaction_date,
                 v_operating_unit,
                 p_po_line_location_id);
  END insert_accrual_reconcile;
*/

/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE insert_line
                ( v_code IN VARCHAR2,
                  v_line_loc_id IN NUMBER,
                  v_po_hdr_id IN NUMBER,
                  v_po_line_id IN NUMBER,
                  v_cre_dt IN DATE,
                  v_cre_by IN NUMBER,
                  v_last_upd_dt IN DATE,
                  v_last_upd_by IN NUMBER,
                  v_last_upd_login IN NUMBER,
                  flag IN VARCHAR2,
                v_service_type_code IN VARCHAR2 DEFAULT NULL)
   IS

    v_seq_val     NUMBER;
    v_tax_amt       NUMBER;
    v_total_amt       NUMBER;

    ------------------------------>

    CURSOR Fetch_Focus_Id IS SELECT JAI_PO_LINE_LOCATIONS_S.NEXTVAL
           FROM   Dual;

    ------------------------------>
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.insert_line';
   BEGIN

      OPEN  Fetch_Focus_Id;
      FETCH Fetch_Focus_Id INTO v_seq_val;
      CLOSE Fetch_Focus_Id;

      IF v_code IN  ( 'CATALOG', 'BLANKET' ) THEN
         v_tax_amt := NULL;
         v_total_amt := NULL;
      ELSE
         v_tax_amt := 0;    -- Init first to 0
         v_total_amt := 0;  -- ------"--------
      END IF;

       IF flag = 'I' THEN

           INSERT INTO JAI_PO_LINE_LOCATIONS( Line_Focus_Id, Line_Location_Id, Po_Line_Id, Po_Header_Id,
                              Tax_Modified_Flag, Tax_Amount, Total_Amount,
                        Creation_Date, Created_By, Last_Update_Date, Last_Updated_By,
                  Last_Update_Login,Service_type_code )
           VALUES
                ( v_seq_val, v_line_loc_id , v_po_line_id, v_po_hdr_id,
                  'N', v_tax_amt, v_total_amt,
                  v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by,
                  v_last_upd_login,v_service_type_code );

       ELSIF flag = 'U' THEN

           UPDATE JAI_PO_LINE_LOCATIONS
           SET    Tax_Modified_flag = 'N',
                  Tax_Amount = 0,
                  Total_Amount = 0,
                  Last_Update_Date = v_last_upd_dt,
                  Last_Updated_By  = v_last_upd_by,
                  Last_Update_Login = v_last_upd_login
           WHERE  Line_Location_Id = v_line_Loc_id AND
                  Po_Line_Id = v_po_line_id        AND
                  Po_Header_Id = v_po_hdr_id;

       END IF;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END insert_line;
/*------------------------------------------------------------------------------------------------------------*/
  FUNCTION Ja_In_Po_Get_Func_Curr( p_po_header_id IN NUMBER ) RETURN VARCHAR2

  IS

     v_set_of_books_id  NUMBER;
     v_func_curr    Gl_Sets_Of_Books.Currency_Code%TYPE;
     v_location_id    NUMBER;

      CURSOR Get_Inv_Org_Id_Cur IS SELECT Inventory_Organization_Id
                         FROM   Hr_Locations
                       WHERE  Location_Id = v_location_id;
      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Removed the cursors Get_Set_Of_Book_Cur and
       * Get_Func_Curr_Cur and implemented caching logic
       * for getting SOB and SOB curr.
       */

      lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.ja_in_po_get_func_curr';

      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Defined variable for implementing caching logic.
       */
       l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
/*------------------------------------------------------------------------------------------------------------*/
      FUNCTION Ja_In_Po_Get_Loc_Id( p_po_header_id IN NUMBER ) RETURN NUMBER IS

        CURSOR Fetch_Location_Id_Cur IS SELECT Ship_To_Location_Id
                FROM   Po_Headers_All
                WHERE  Po_Header_Id = p_po_header_id;

        v_location_id NUMBER;

      BEGIN

        OPEN  Fetch_Location_Id_Cur;
        FETCH Fetch_Location_Id_Cur INTO v_location_id;
        CLOSE Fetch_Location_Id_Cur;

        RETURN( v_location_id );


      END Ja_In_Po_Get_Loc_Id;

  BEGIN

    v_location_id := ja_in_po_get_loc_id( p_po_header_id );

    OPEN  Get_Inv_Org_Id_Cur;
    FETCH Get_Inv_Org_Id_Cur INTO v_inv_org_id;
    CLOSE Get_Inv_Org_Id_Cur;

    IF v_inv_org_id IS NULL THEN --added bby vkaranam for Bug#4601436
       RAISE_APPLICATION_ERROR(-20121,'No Inventory Org is associated to the Location with Id:'||v_location_id);
    END IF ;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors Get_Set_Of_Book_Cur and Get_Func_Curr_Cur
     * and implemented caching logic to get the sob and sob currency.
     */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_inv_org_id );
    v_set_of_books_id := l_func_curr_det.ledger_id;
    v_func_curr       := l_func_curr_det.currency_code;

    RETURN( v_func_curr );

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END Ja_In_Po_Get_Func_Curr;

/*------------------------------------------------------------------------------------------------------------*/
  FUNCTION Ja_In_Po_Assessable_Val_Conv( p_po_header_id IN NUMBER,
                                         p_assessable_val IN NUMBER,
					 p_func_curr IN VARCHAR2,
					 p_doc_curr IN VARCHAR2,
					 /* Bug 5096787. Added by Lakshmi Gopalsami */
					 p_rate IN NUMBER DEFAULT NULL,
					 p_rate_date IN DATE DEFAULT NULL,
					 p_rate_type IN VARCHAR2 DEFAULT NULL
					 )
            RETURN NUMBER IS

     v_rate_type  VARCHAR2(30);
     v_rate_date  DATE;
     v_rate   NUMBER;
     v_bookid   NUMBER;
     v_org_id   NUMBER;

     /* Bug 5243532. Added by Lakshmi Gopalsami
      * Removed cursor Fetch_SET_Of_Books_Id_Cur
      * and used caching logic for getting SOB
      */

    CURSOR Fetch_Curr_Details_Cur IS
           SELECT Rate, Rate_Date, Rate_Type
       FROM   Po_Headers_All
       WHERE  Po_Header_Id = p_po_header_id;

   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.ja_in_po_assessable_val_conv';

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Defined variable for implementing caching logic.
    */
       l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

    FUNCTION Ja_In_Po_Get_Org_Id RETURN NUMBER IS

          CURSOR Fetch_Org_Id_Cur IS SELECT NVL( Org_Id, -99 )
                           FROM   Po_Headers_All
                         WHERE  Po_Header_Id = p_po_header_id;

          v_org_id    NUMBER;

   BEGIN
      OPEN  Fetch_Org_Id_Cur;
      FETCH Fetch_Org_Id_Cur INTO v_org_id;
      CLOSE Fetch_Org_Id_Cur;

      RETURN( v_org_id );
   END Ja_In_Po_Get_Org_Id;

  BEGIN
    IF p_func_curr <> p_doc_curr OR p_doc_curr IS NOT NULL THEN
       OPEN  Fetch_Curr_Details_Cur;
       FETCH Fetch_Curr_Details_Cur INTO v_rate, v_rate_date, v_rate_type;
       CLOSE Fetch_Curr_Details_Cur;
       IF v_rate_type = 'User' THEN
          v_conv_rate := 1/v_rate;
       ELSE
          /* Bug 5243532. Added by Lakshmi Gopalsami
	   * Removed cursor Fetch_SET_Of_Books_Id_Cur
	   * and used caching logic for getting SOB
	   */
	   l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_inv_org_id );
           v_bookid := l_func_curr_det.ledger_id;
           v_conv_rate := jai_cmn_utils_pkg.currency_conversion
                        ( v_bookid, p_doc_curr, v_rate_date, v_rate_type, 1 );
           v_conv_rate := 1/v_conv_rate;
       END IF;
    ELSE
       v_conv_rate := 1;
    END IF;
    RETURN( NVL( p_assessable_val * v_conv_rate, 0 ) );
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END Ja_In_Po_Assessable_Val_Conv;
/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE Ja_In_Po_Func_Curr( p_po_header_id IN NUMBER,
                                p_assessable_val IN OUT NOCOPY NUMBER,
				p_doc_curr IN VARCHAR2,
				p_conv_rate IN OUT NOCOPY NUMBER,
				/* Bug 5096787. Added by Lakshmi Gopalsami */
				p_rate IN NUMBER DEFAULT NULL,
				p_rate_date IN DATE DEFAULT NULL,
				p_rate_type IN VARCHAR2 DEFAULT NULL
				) IS
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.ja_in_po_func_curr';
  BEGIN

    p_assessable_val :=  jai_po_cmn_pkg.ja_in_po_assessable_val_conv
                        ( p_po_header_id, p_assessable_val,
                          jai_po_cmn_pkg.ja_in_po_get_func_curr( p_po_header_id ),
                          p_doc_curr
                        );
    p_conv_rate := v_conv_rate;
  EXCEPTION
    WHEN OTHERS THEN
    p_assessable_val := null;
    p_conv_rate := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END Ja_In_Po_Func_Curr;

/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE locate_source_line
  (
    p_header_id IN NUMBER,
    p_line_num  IN NUMBER,
    p_line_quantity IN NUMBER,
    p_po_line_id       OUT NOCOPY NUMBER,
    p_line_location_id OUT NOCOPY NUMBER,
    p_line_id NUMBER DEFAULT NULL
  ) IS
  -- This procedure is used to find out the line_location_id from which the taxes should be defaulted in case
  -- there are multiple price break lines for the specified p_line_id or p_line_num of p_header_id

    i                 NUMBER  :=  1;
    v_po_line_id      NUMBER;
    v_cum_flag        Po_Lines_All.Price_Break_Lookup_Code % TYPE;
    v_quantity        NUMBER; --  :=  p_line_quantity; --Ramananda for File.Sql.35
    v_qty             NUMBER;
    v_count           NUMBER;

    TYPE v_Llid_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE v_Qty_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    Llid_tab  v_Llid_tab;
    Qty_tab v_Qty_Tab;

    CURSOR Fetch_Qty_Cur IS
      SELECT Quantity, Line_Location_Id
      FROM   Po_Line_Locations_All
      WHERE  Po_Header_Id = p_header_id
        AND  Po_Line_Id = v_po_line_id
        and SYSDATE between nvl(start_date, SYSDATE) and nvl(end_date, SYSDATE) -- cbabu for Bug# 2740918
    ORDER BY Quantity;

    CURSOR Fetch_Line_Id_Cur IS
      SELECT Po_Line_Id, NVL( Price_Break_Lookup_Code, 'NC' ) Price_Break_Lookup_Code
      FROM   Po_Lines_All
      WHERE  Po_Header_Id = p_header_id
        AND  Line_Num = p_line_num;

    CURSOR Fetch_Line1_Id_Cur IS
      SELECT NVL( Price_Break_Lookup_Code, 'NC' ) Price_Break_Lookup_Code
      FROM   Po_Lines_All
      WHERE  Po_Line_Id = p_line_id;

    CURSOR Fetch_Cum_Qty_Cur IS
      SELECT SUM( Quantity )
      FROM   Po_Line_Locations_All
      WHERE  Po_Line_Id = v_po_line_id;

    CURSOR Chk_Line_Loc_Cur IS
      SELECT COUNT( * )
      FROM   Po_Line_Locations_All
      WHERE  Po_Line_Id = v_po_line_id;

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.locate_source_line';

  BEGIN

  /*----------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for ja_in_locate_line_p.sql
  S.No  DD/MM/YYYY  Author and Details
  ------------------------------------------------------------------------------------------------------------
  1     06/02/2003  Vijay Shankar for Bug# 2740918, Version# 615.1
                     When multiple price break lines are there for quotation with different effectivity dates, then taxes
                     are not picked up properly, this is fixed by adding a condition in the where clause
  ----------------------------------------------------------------------------------------------------------*/
    v_quantity        :=  p_line_quantity; --Ramananda for File.Sql.35

    IF NVL( p_line_id, -999 ) = -999 THEN
       OPEN  Fetch_Line_Id_Cur;
       FETCH Fetch_Line_Id_Cur INTO v_po_line_id, v_cum_flag;
       CLOSE Fetch_Line_Id_Cur;
    ELSE
       OPEN  Fetch_Line1_Id_Cur;
       FETCH Fetch_Line1_Id_Cur INTO v_cum_flag;
       CLOSE Fetch_Line1_Id_Cur;

       v_po_line_id := p_line_id;
    END IF;

    p_po_line_id := v_po_line_id;

    OPEN  Fetch_Cum_Qty_Cur;
    FETCH Fetch_Cum_Qty_Cur INTO v_qty;
    CLOSE Fetch_Cum_Qty_Cur;

    IF v_cum_flag = 'CUMULATIVE' THEN
       v_quantity := v_qty;
    ELSE
       v_quantity := p_line_quantity;
    END IF;

    OPEN  Chk_Line_Loc_Cur;
    FETCH Chk_Line_Loc_Cur INTO v_count;
    CLOSE Chk_Line_Loc_Cur;

    IF v_count = 0 THEN
       p_line_location_id := -999;
    ELSE
      FOR rec IN Fetch_Qty_Cur LOOP
          Llid_tab( i ) := NVL( rec.Line_Location_Id, -99 );
          Qty_Tab( i ) := rec.quantity;
          i := i + 1;
      END LOOP;
      i := i - 1;

      IF Qty_tab( 1 ) > v_quantity THEN
         p_line_location_id := -999;
      ELSE
         FOR j IN 1 .. i-1 LOOP
           IF v_quantity >= Qty_tab( j ) AND v_quantity < Qty_tab( j + 1 ) THEN
              p_line_location_id := Llid_tab( j );
           END IF;
         END LOOP;
         IF v_quantity >= Qty_tab( i ) THEN
            p_line_location_id := Llid_tab( i );
         END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    p_po_line_id      := null;
    p_line_location_id:= null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END locate_source_line;
/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE process_release_shipment
  (
    v_shipment_type IN VARCHAR2,
    v_src_ship_id IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_qty IN NUMBER,
    v_po_rel_id IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    flag IN VARCHAR2 DEFAULT NULL
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/11
  )
  IS

    req_id    NUMBER;
    result    BOOLEAN;
    v_tax_amt   NUMBER;
    v_total_amt NUMBER;
    v_seq_val   NUMBER;
--Added by kunkumar for forward porting to R12 Start
v_vendor_id number;
v_vendor_site_id  number;
v_service_type_code varchar2(30);


cursor fetch_vendor_id_cur IS
select vendor_id,vendor_site_id
from po_headers_all
where po_header_id=v_po_hdr_id;

--Added by kunkumar End

    v_cum_flag  VARCHAR2(50);

   ------------------------------>

    /*Bug 8303124 - Added precedence 6 to 10*/

    CURSOR fetch_taxes_cur IS
    SELECT line_location_id, tax_line_no, po_line_id, po_header_id,
      precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
      precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
      tax_id, currency, tax_rate, qty_rate, uom, tax_amount, tax_type,
      vendor_id, modvat_flag, tax_target_amount,
      tax_category_id   -- cbabu for EnhancementBug# 2427465
    FROM JAI_PO_TAXES
    WHERE line_location_id = v_src_ship_id
    AND po_line_id = v_po_line_id;

    ------------------------------>


    CURSOR Fetch_Focus_Id IS SELECT JAI_PO_LINE_LOCATIONS_S.NEXTVAL
             FROM   Dual;

    ------------------------------>

    /* Fetch Cumulative pricing flag */

    CURSOR Fetch_Cum_Pr_Cur IS SELECT Price_Break_Lookup_Code
               FROM   Po_Lines_All
               WHERE  Po_Line_Id = v_po_line_id;


    ------------------------------>
    --Start, cbabu for EnhancementBug# 2427465
    v_tax_category_id_holder JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE;
    CURSOR c_get_tax_category_id( p_line_location_id IN NUMBER) IS
      SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
      WHERE line_location_id = p_line_location_id;
    -- End, cbabu for EnhancementBug# 2427465

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.process_release_shipment';

  BEGIN
  /*-----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:   FILENAME: ja_in_po_releases_p.sql
  S.No   Date       Author and Details
  -------------------------------------------------------------------------------------------------------------------------
  1  06/12/2002   cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                     tax_category_id column is populated into PO and SO localization tables, which will be used to
                    identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                    the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.
  2  21/12/2004       avallabh for bug#4070899, file version 115.1
        When submitting request for JAINPOCR, the description is being displayed without an "India - " prefix.
        Changed the FND_REQUEST.submit_request procedure and attached the prefix "India - ".

  3  15/01/2008   Kevin Cheng for Retroactive Price Enhancement
                  Add parameter pv_retroprice_changed to indicate whether it is called by retroactive price concurrent;
                  Add parameter to procedures called here;
  -------------------------------------------------------------------------------------------------------------------------*/

    OPEN  Fetch_Focus_Id;
    FETCH Fetch_Focus_Id INTO v_seq_val;
    CLOSE Fetch_Focus_Id;

    OPEN  Fetch_Cum_Pr_Cur;
    FETCH Fetch_Cum_Pr_Cur INTO v_cum_flag;
    CLOSE Fetch_Cum_Pr_Cur;

    -- cbabu for EnhancementBug# 2427465
    OPEN  c_get_tax_category_id(v_src_ship_id);
    FETCH c_get_tax_category_id INTO v_tax_category_id_holder;
    CLOSE c_get_tax_category_id;
open fetch_vendor_id_cur;
fetch fetch_vendor_id_cur into v_vendor_id, v_vendor_site_id;
close fetch_vendor_id_cur;

v_service_type_code :=jai_ar_rctla_trigger_pkg.get_service_type(v_vendor_id,v_vendor_site_id,'V');


    IF flag <> 'U' THEN

    INSERT INTO JAI_PO_LINE_LOCATIONS(
      line_focus_id, line_location_id, po_line_id, po_header_id,
      tax_modified_flag, tax_amount, total_amount,
      creation_date, created_by, last_update_date, last_updated_by, last_update_login,
      tax_category_id   -- cbabu for EnhancementBug# 2427465
   ,service_type_code ) VALUES (
      v_seq_val, v_line_loc_id,  v_po_line_id,  v_po_hdr_id,
      'N', v_tax_amt, v_total_amt,
      v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login,
      v_tax_category_id_holder    -- cbabu for EnhancementBug# 2427465
  , v_service_type_code );
    END IF;

    IF v_shipment_type = 'SCHEDULED' THEN
       FOR Tax_Rec IN Fetch_Taxes_Cur LOOP

      /*Bug 8303124 - Added precedence 6 to 10*/

      INSERT INTO JAI_PO_REQUEST_T(
        Line_Focus_Id, Line_Location_Id, Tax_Line_No,
        Po_Line_Id, Po_Header_Id, Precedence_1,
        Precedence_2, Precedence_3, Precedence_4,
        Precedence_5, Precedence_6,
        Precedence_7, Precedence_8, Precedence_9,
        Precedence_10,
        Tax_Id, Currency,
        Tax_Rate, Qty_Rate, UOM,
        Tax_Amount, Tax_Type, Modvat_Flag,
        Vendor_Id, Tax_Target_Amount, Creation_Date,
        Created_By, Last_Update_Date, Last_Updated_By, Last_Update_Login,
        tax_category_id   -- cbabu for EnhancementBug# 2427465
      ) VALUES (
        v_seq_val, v_line_loc_id, Tax_Rec.Tax_Line_No,
        v_Po_Line_Id, v_Po_Hdr_Id, Tax_Rec.Precedence_1,
        Tax_Rec.Precedence_2, Tax_Rec.Precedence_3, Tax_Rec.Precedence_4,
        Tax_Rec.Precedence_5, Tax_Rec.Precedence_6,
        Tax_Rec.Precedence_7, Tax_Rec.Precedence_8, Tax_Rec.Precedence_9,
        Tax_Rec.Precedence_10,
        Tax_Rec.Tax_Id, Tax_Rec.Currency,
        Tax_Rec.Tax_Rate, Tax_Rec.Qty_Rate, Tax_Rec.UOM,
        Tax_Rec.Tax_Amount, Tax_Rec.Tax_Type, Tax_Rec.Modvat_Flag,
        Tax_Rec.Vendor_Id, Tax_Rec.Tax_Target_Amount, v_cre_dt,
        v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login,
        tax_rec.tax_category_id   -- cbabu for EnhancementBug# 2427465
      );

       END LOOP;

       -- Run concurrent request.

    /* Changed the submit_request calls below and prefixed with "India - " for bug #4070899 */

       result := Fnd_Request.Set_Mode( TRUE );
       req_id := Fnd_Request.Submit_Request( 'JA', 'JAINPOCR', 'India - Concurrent request for ' || v_shipment_type || ' Release',
                          SYSDATE, FALSE,
                  v_seq_val, v_qty, NULL, NULL, v_src_ship_id,
                  v_shipment_type, NULL,
                  v_cre_dt, v_cre_by, v_last_upd_dt,  v_last_upd_by, v_last_upd_login );


    ELSIF v_shipment_type = 'BLANKET' THEN

             -- Run concurrent request.

       result := Fnd_Request.Set_Mode( TRUE );
       req_id := Fnd_Request.Submit_Request( 'JA', 'JAINPOCR', 'India - Concurrent request for ' || v_shipment_type || ' Release',
                              SYSDATE, FALSE,
                  v_seq_val, v_qty, v_po_hdr_id, v_po_line_id, v_line_loc_id,
                  v_shipment_type, v_cum_flag,
                  v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login
                  ,pv_retroprice_changed --Added by Kevin Cheng for Retroactive Price 2008/01/11
                   );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END process_release_shipment;

/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE get_functional_curr
    ( v_ship_to_loc_id IN NUMBER, v_po_org_id IN NUMBER, v_inv_org_id IN NUMBER,
      v_doc_curr IN VARCHAR2, v_assessable_value IN OUT NOCOPY NUMBER,
      v_rate IN OUT NOCOPY NUMBER, v_rate_type IN VARCHAR2, v_rate_date IN DATE,
      v_func_currency IN OUT NOCOPY VARCHAR2
    )
  IS

     v_set_of_books_id  NUMBER;
     v_func_curr    Gl_Sets_Of_Books.Currency_Code%TYPE;
     v_location_id    NUMBER;

     v_bookid   NUMBER;
     v_org_id   NUMBER;

     conv_rate  NUMBER;

      CURSOR Get_Inv_Org_Id_Cur IS SELECT Inventory_Organization_Id
                     FROM   Hr_Locations
                   WHERE  Location_Id = v_location_id;
     /* Bug 5243532. Added by Lakshmi Gopalsami
      * Removed cursors Get_Set_Of_Book_Cur and Get_Func_Curr_Cur
      * and implemented caching logic
      * Removed the unused cursor Fetch_SET_Of_Books_Id_Cur
      */

      lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_cmn_pkg.get_functional_curr';
      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Defined variable for implementing caching logic.
       */
       l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  BEGIN
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors Get_Set_Of_Book_Cur and Get_Func_Curr_Cur
     * and implemented caching logic
     */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_inv_org_id );
    v_set_of_books_id := l_func_curr_det.ledger_id;
    v_func_curr       := l_func_curr_det.currency_code;

    IF v_func_curr <> v_doc_curr OR v_doc_curr IS NOT NULL THEN

      IF v_rate_type = 'User' THEN
         conv_rate := 1/v_rate;
      ELSE
         /* Bug 5243532. Added by Lakshmi Gopalsami
	  * Removed the commented code
	  */
         conv_rate := jai_cmn_utils_pkg.currency_conversion
                     ( v_set_of_books_id,
                       v_doc_curr,
                       v_rate_date,
                       v_rate_type,
                       1
                      );
         conv_rate := 1/conv_rate;
      END IF;
    ELSE
       conv_rate := 1;
    END IF;

    v_assessable_value := NVL( v_assessable_value * conv_rate, 0 );
    v_func_currency := v_func_curr;
    v_rate := conv_rate;
  EXCEPTION
    WHEN OTHERS THEN
    v_assessable_value := null;
    v_rate := null;
    v_func_currency:= null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_functional_curr;

/*------------------------------------------------------------------------------------------------------------*/

END jai_po_cmn_pkg;

/
