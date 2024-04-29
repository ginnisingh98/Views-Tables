--------------------------------------------------------
--  DDL for Package Body JAI_OE_OLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OE_OLA_TRIGGER_PKG" AS
/* $Header: jai_oe_ola_t.plb 120.15.12010000.20 2010/06/09 09:47:39 srjayara ship $ */
/*REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OE_OLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OE_OLA_ARD_T4
  REM
  REM +======================================================================+
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  v_header_id           Number;
  v_line_id             Number; --File.Sql.35 Cbabu   :=      pr_old.line_id;
  v_operating_id                     number; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
  v_line_category_code  varchar2(30); --File.Sql.35 Cbabu  := pr_old.line_category_code;
  v_gl_set_of_bks_id                 gl_sets_of_books.set_of_books_id%type;
  v_currency_code                     gl_sets_of_books.currency_code%type;

  /* Bug 5095812. Added by Lakshmi Gopalsami */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  /* Bug 5095812. Added by Lakshmi Gopalsami
     Removed the cursors Fetch_Book_Id_Cur and
     Sob_Cur as this is not used anywhere.
  */

  BEGIN
    pv_return_code := jai_constants.successful ;

  v_header_id             :=      pr_old.header_id;
  v_line_id               :=      pr_old.line_id;
  v_operating_id          :=pr_old.ORG_ID; /*bgowrava for forwrad porting bug#5591347, changed pr_new to pr_old */
  v_line_category_code   := pr_old.line_category_code;

  /* Bug 5095812. Added by Lakshmi Gopalsami
     Removed the code which is fetching from
     org_organization_definitions
     the following and implemented the same using cache.
     Removed the existing commented codes.
  */

  l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_operating_id );

  v_gl_set_of_bks_id := l_func_curr_det.ledger_id;
  v_currency_code    := l_func_curr_det.currency_code;

   IF v_line_category_code = 'RETURN' THEN
      DELETE JAI_OM_OE_RMA_LINES
      WHERE  rma_header_id = v_header_id
      AND    rma_line_id   = v_line_id;

      DELETE FROM JAI_OM_OE_RMA_TAXES
      WHERE  rma_line_id   = v_line_id;
   ELSE
      DELETE JAI_OM_OE_SO_LINES
      WHERE  header_id = v_header_id
      AND line_id   = v_line_id;

      DELETE JAI_OM_OE_SO_TAXES
      WHERE  header_id = v_header_id
      AND line_id   = v_line_id;
   END IF;
    /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
    WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_OE_OLA_TRIGGER_PKG.ARD_T1 '  || substr(sqlerrm,1,1900);
  END ARD_T1 ;

  /*
REM +======================================================================+
  REM NAME          ARIU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OE_OLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OE_OLA_ARIU_T5
  REM
  REM +======================================================================+
*/
  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
        v_row_id                        ROWID;
        v_sid                           NUMBER;
        v_header_id                     NUMBER; --File.Sql.35 Cbabu   := pr_new.header_id;
        v_line_id                       NUMBER; --File.Sql.35 Cbabu   := pr_new.line_id;
        v_line_number                   NUMBER; --File.Sql.35 Cbabu   := pr_new.line_number;
        v_ship_to_site_use_id           NUMBER; --File.Sql.35 Cbabu   :=  NVL(pr_new.ship_to_ORG_id,0);
        v_inventory_item_id             NUMBER; --File.Sql.35 Cbabu   := pr_new.inventory_item_id;
        v_line_quantity                 NUMBER; --File.Sql.35 Cbabu   :=  NVL(pr_new.ordered_quantity,0);
        v_uom_code                      VARCHAR2(3); --File.Sql.35 Cbabu  := pr_new.ORDER_QUANTITY_UOM;
        v_warehouse_id                  NUMBER; --File.Sql.35 Cbabu  := pr_new.SHIP_FROM_ORG_ID;
        v_creation_date                 DATE; --File.Sql.35 Cbabu  := pr_new.creation_date;
        v_created_by                    NUMBER; --File.Sql.35 Cbabu  := pr_new.created_by;
        v_last_update_date              DATE ; --File.Sql.35 Cbabu := pr_new.last_update_date;
        v_last_updated_by               NUMBER ; --File.Sql.35 Cbabu := pr_new.last_updated_by;
        v_last_update_login             NUMBER ; --File.Sql.35 Cbabu := pr_new.last_update_login;
        v_original_system_line_ref      VARCHAR2(50); --File.Sql.35 Cbabu := pr_new.ORIG_SYS_LINE_REF;
        v_original_line_reference       VARCHAR2(50); --File.Sql.35 Cbabu := pr_new.ORIG_SYS_LINE_REF;
        v_Line_Category_Code            VARCHAR2(30); --File.Sql.35 Cbabu := pr_new.Line_Category_Code;
        v_line_amount                   NUMBER; --File.Sql.35 Cbabu  := (NVL(pr_new.ordered_quantity,0)*NVL(pr_new.UNIT_SELLING_PRICE,0));
        v_line_new_tax_amount           NUMBER;
        v_line_new_amount               NUMBER;
  v_new_vat_assessable_value      NUMBER;  -- added by ssawant for Bug 4660756
        v_old_quantity                  NUMBER;
        v_original_system_reference     VARCHAR2(50);
        v_orig_sys_document_ref         VARCHAR2(50);
        v_customer_id                   NUMBER;
        v_address_id                    NUMBER;
        v_price_list_id                 NUMBER;
        v_org_id                        NUMBER;
        v_order_number                  NUMBER;
        v_source_header_id              NUMBER;
        --v_currency_code               varchar2(15);--2001/06/14 Gadde,Jagdish
        v_conv_type_code                VARCHAR2(30);
        v_conv_rate                     NUMBER;
        v_conv_date                     DATE;
        v_conv_factor                   NUMBER;
        v_set_of_books_id               NUMBER;
        v_tax_category_id               NUMBER;
        v_order_category                VARCHAR2(30);
        v_source_order_category         VARCHAR2(30);
        v_tax_amount                    NUMBER;
        v_assessable_value              NUMBER;
        v_assessable_amount             NUMBER;
        v_price_list_uom_code           VARCHAR2(3);
        v_converted_rate                NUMBER;
        v_date_ordered                  DATE;
        v_so_lines_count                NUMBER;
        v_so_tax_lines_count            NUMBER;
        v_ordered_date                  DATE;
        v_so_lines_check_count          NUMBER;
        v_service_order                 NUMBER;
        v_new_tax_amount                NUMBER;
        v_new_base_tax_amount           NUMBER;
        v_new_func_tax_amount           NUMBER;
        v_transaction_name              VARCHAR2(30); --File.Sql.35 Cbabu  := 'SALES_ORDER';
        v_base_tax_amount               NUMBER; --File.Sql.35 Cbabu  := 0;
        v_func_tax_amount               NUMBER; --File.Sql.35 Cbabu  := 0;
        v_line_tax_amount               NUMBER; --File.Sql.35 Cbabu  := 0;
        v_ordered_quantity              NUMBER; --File.Sql.35 Cbabu  := 0;
        v_conversion_rate               NUMBER; --File.Sql.35 Cbabu  := 0;
        v_shipment_schedule_line_id     NUMBER;
        v_ship_count                    NUMBER; --File.Sql.35 Cbabu  := 0;
        v_item_type_code                VARCHAR2(30); --File.Sql.35 Cbabu  := pr_new.item_type_code;
        v_reference_line_id             NUMBER; --File.Sql.35 Cbabu  := pr_new.reference_line_id;-- 2001/05/09  Anuradha Parthasarathy
        v_return_reference_id           NUMBER;
        v_count                         NUMBER;      --2001/04/25   Deepak Prabhakar
        c_source_line_id                NUMBER;
        v_header_tax_amount             number; --File.Sql.35 Cbabu  :=0; --Added by Nagaraj.s for Bug3140153.(Holds sum of tax amount for each order line. Used in case of a split line)
        v_rounding_factor               JAI_CMN_TAXES_ALL.rounding_factor%type; --Added by Nagaraj.s for Bug3140153.

        -- additions by sriram - ATO - LMW
        v_ato_line_amount               Number;
        v_ato_tax_amount                Number;
        v_ato_assessable_value          Number;
        v_ato_selling_price             Number;
        v_ato_vat_assessable_value      NUMBER; --added for bug#8924003
         -- additions by sriram - ATO - LMW  - ends here

        -- added by Allen Yang for bug 9666476 28-apr-2010, begin
        lv_shippable_flag               VARCHAR2(1);
        -- added by Allen Yang for bug 9666476 28-apr-2010, end

        /* Bug 5095812. Added by Lakshmi Gopalsami */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
v_service_type_code   varchar2(30);/*bduvarag for the bug#5694855*/
        CURSOR bind_cur(p_header_id NUMBER) IS
                SELECT rowid, nvl(org_id,0), sold_to_org_id,
                        source_document_id, order_number, price_list_id,
                        order_category_code, orig_sys_document_ref, transactional_curr_code,
                        conversion_type_code, conversion_rate, conversion_rate_date,
                        nvl(ordered_date, creation_date)
                FROM oe_order_headers_all
                WHERE header_id = p_header_id;

        CURSOR soure_doc_cur(p_header_id NUMBER) IS
                SELECT order_category_code
                FROM oe_order_headers_all
                WHERE header_id = p_header_id;

        CURSOR address_cur(p_ship_to_site_use_id IN NUMBER) IS
          SELECT NVL(cust_acct_site_id, 0) address_id
          FROM hz_cust_site_uses_all a  /* Removed ra_site_uses_all for Bug# 4434287 */
          WHERE A.site_use_id = p_ship_to_site_use_id;  /* Modified by Ramananda for removal of SQL LITERALs */
           --WHERE A.site_use_id = NVL(p_ship_to_site_use_id,0);
        /*
        ||Cursor modified by aiyer for the bug 3792765
        ||Take the set of books from the hr_operating_units table instead of the org_organization_id using the :new_org_id
        || instead of the warehouse id. This is required as the warehouse id can be null .
        */
  /* Bug 5095812. Added by Lakshmi Gopalsami
     Removed the cursor set_of_books_cur and implemented
     the same using plsql cache.
  */

        CURSOR po_reqn_lines_count(p_requisition_number VARCHAR2) IS
                SELECT count(1)
                FROM JAI_PO_REQ_LINES
                WHERE requisition_header_id IN ( SELECT requisition_header_id
                        FROM po_requisition_headers_all a, oe_order_headers_all b
                        WHERE A.segment1 = b.orig_sys_document_ref
                        AND A.segment1 = p_requisition_number );


        CURSOR so_tax_lines_cur(p_header_id NUMBER, p_line_id NUMBER) IS
                SELECT tax_line_no, tax_id, tax_rate, qty_rate, uom,
                        precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
      precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,  -- precedence 6 to 10 added for bug#6485212
                        tax_amount, base_tax_amount, func_tax_amount,
                        tax_category_id                 -- cbabu for EnhancementBug# 2427465
                FROM JAI_OM_OE_SO_TAXES
                WHERE header_id = p_header_id
                AND line_id = p_line_id;

        --Added by Nagaraj.s for Bug3140153.
        cursor c_fetch_rounding_factor(p_tax_id number) is
        select nvl(rounding_factor,0),
        nvl(adhoc_flag,'N') --Added by Nagaraj.s for Bug3207633
        from   JAI_CMN_TAXES_ALL
        where  tax_id = p_tax_id;

        v_adhoc_flag   JAI_CMN_TAXES_ALL.adhoc_flag%type; --3207633

        CURSOR order_tax_amount_Cur (p_header_id NUMBER, p_line_id      NUMBER) IS
        SELECT  SUM(A.tax_amount)
        FROM    JAI_OM_OE_SO_TAXES A,
        JAI_CMN_TAXES_ALL b
        WHERE   A.Header_ID = p_header_id
        AND     A.line_id       = p_line_id
        AND     b.tax_id        = A.tax_id
        AND     b.tax_type      <> jai_constants.tax_type_tds /* 'TDS'; Ramananda for removal of SQL LITERALs */
        AND     NVL(b.inclusive_tax_flag, 'N') = 'N';  -- Added by Jia Li for inclusive tax on 2008/01/08

        CURSOR return_tax_amount_Cur (p_header_id NUMBER, p_line_id     NUMBER) IS
                SELECT SUM(A.tax_amount)
                FROM JAI_OM_OE_RMA_TAXES a, JAI_CMN_TAXES_ALL b
                WHERE a.rma_line_id = p_line_id
                AND b.tax_id = A.tax_id
                AND b.tax_type  <> jai_constants.tax_type_tds  /* 'TDS'; Ramananda for removal of SQL LITERALs */
                AND NVL(b.inclusive_tax_flag, 'N') = 'N';  -- Added by Jia Li for inclusive tax on 2008/01/08

        CURSOR get_so_lines_count_cur (p_line_id NUMBER) IS
                SELECT COUNT(1)
                FROM JAI_OM_OE_SO_LINES
                WHERE line_id = p_line_id;

        CURSOR get_rma_lines_count_cur(p_line_id NUMBER) IS
                SELECT COUNT(1)
                FROM JAI_OM_OE_RMA_LINES
                WHERE rma_line_id = v_line_id;

        CURSOR get_so_tax_lines_count_cur( p_header_id NUMBER, p_line_id NUMBER) IS
                SELECT COUNT(1)
                FROM JAI_OM_OE_SO_TAXES
                WHERE header_id = p_header_id
                AND line_id = p_line_id;

        CURSOR get_rma_tax_lines_count_cur IS
                SELECT COUNT(1)
                FROM JAI_OM_OE_RMA_TAXES
                WHERE rma_line_id = pr_new.line_id;

        CURSOR get_assessable_value_cur(p_customer_id NUMBER, p_address_id NUMBER,
                        p_inventory_item_id NUMBER, p_uom_code VARCHAR2, p_ordered_date DATE )IS
                SELECT b.operand list_price, c.product_uom_code list_price_uom_code
                FROM JAI_CMN_CUS_ADDRESSES a, qp_list_lines b, qp_pricing_attributes c
                WHERE A.customer_id = p_customer_id
                AND A.address_id = p_address_id
                AND A.price_list_id = b.LIST_header_ID
                AND c.list_line_id = b.list_line_id
                AND c.PRODUCT_ATTR_VALUE = TO_CHAR(p_inventory_item_id) --2001/02/14    Manohar Mishra
                AND c.product_uom_code      = p_uom_code          -- Bug# 3210713 Sriram
                AND TRUNC(NVL(b.end_date_active,SYSDATE)) >= TRUNC(p_ordered_date);

        -- Cursor for defaulting of taxes for
        -- Web Stores Order's Import
        -- by Amit Chopra on 7th June 2000
        CURSOR get_original_source IS
                SELECT NVL(orig_sys_document_ref,'NON_IMPORT')
                FROM oe_order_headers_all
                WHERE header_id = v_header_id ;

        v_source_id     NUMBER;
        CURSOR get_source_id IS
                SELECT order_source_id
                FROM oe_order_headers_all
                WHERE header_id = v_header_id;

        ---------------------------------
        /* Declarations for Copy Order */
        ---------------------------------

        v_source_document_id            OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_ID%TYPE; --File.Sql.35 Cbabu       := pr_new.SOURCE_DOCUMENT_ID      ;
        v_source_document_line_id       OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE; --File.Sql.35 Cbabu  := pr_new.SOURCE_DOCUMENT_LINE_ID ;
        v_source_document_type_id       OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_TYPE_ID%TYPE; --File.Sql.35 Cbabu  := pr_new.SOURCE_DOCUMENT_TYPE_ID ;
        v_order_source_type             VARCHAR2(240);

        --2001/10/01  Anuradha Parthasarathy
        v_source_order_category_code    VARCHAR2(30);
        CURSOR source_order_doc_cur(P_Source_Document_Id NUMBER) IS
                SELECT order_category_code
                FROM oe_order_headers_all
                WHERE header_id = p_source_document_id;

        --2001/10/01  Anuradha Parthasarathy
        CURSOR get_order_source_type(p_source_document_type_id NUMBER) IS
                SELECT name
                FROM oe_order_sources
                WHERE order_source_id = p_source_document_type_id;

        CURSOR get_copy_order_line (p_header_Id NUMBER, p_Line_Id NUMBER) IS
                SELECT inventory_item_id, unit_code, quantity,
                        tax_category_id, selling_price, line_amount, assessable_value,
                        tax_amount, line_tot_amount, shipment_line_number,
                        excise_exempt_type, excise_exempt_refno, excise_exempt_date,    -- added by sriram for Bug # 2672114
                        vat_exemption_flag,vat_exemption_type,vat_exemption_date ,vat_exemption_refno,vat_assessable_value  /* added by ssumaith for vat */,
      vat_reversal_price,service_type_code
                FROM JAI_OM_OE_SO_LINES
                WHERE header_id = p_header_Id
                AND line_id = p_Line_Id ;


        --2001/04/24 Anuradha Parthasarathy
        CURSOR get_copy_order_count(p_header_id NUMBER) IS
                SELECT count(1)
                FROM JAI_OM_OE_SO_LINES
                WHERE header_id = p_header_id;

        copy_rec        get_copy_order_line%ROWTYPE;

        v_so_lines_copy_count   NUMBER;

        --2001/06/14 Gadde,Jagdish
        v_operating_id                          NUMBER; --File.Sql.35 Cbabu  := pr_new.ORG_ID;
        v_gl_set_of_bks_id                      GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
        v_currency_code                         GL_SETS_OF_BOOKS.currency_code%TYPE;

        v_excise_exempt_type            VARCHAR2(60);
        v_excise_exempt_refno           VARCHAR2(30);
        v_excise_exempt_date            DATE;

        v_trigg_stat                    VARCHAR2(100);

        /* This cursor has been added by Aiyer for the fix of the bug #2798930.
           Get the details from the JAI_OM_OE_RMA_LINES table.
        */
         CURSOR cur_get_rma_entry_lines  (
                                           p_header_id JAI_OM_OE_RMA_LINES.RMA_HEADER_ID%TYPE,
                                           p_Line_Id   JAI_OM_OE_RMA_LINES.RMA_LINE_ID%TYPE
                                         )
         IS
         SELECT
                 *
         FROM
                 JAI_OM_OE_RMA_LINES
         WHERE
                 rma_header_id   = p_header_id AND
                 rma_line_id     = p_Line_Id ;

        rec_cur_get_rma_entry_lines   cur_get_rma_entry_lines%ROWTYPE;
        v_debug                     VARCHAR2(1); --File.Sql.35 Cbabu      := 'N' ;         -- Added by Aparajita on 29-may-2002
        v_utl_location              VARCHAR2(512)      ;         --For Log file.
        v_myfilehandle              UTL_FILE.FILE_TYPE ;         -- This is for File handling
        v_hook                      VARCHAR2(6)        ;
        v_tax_line_count            NUMBER             ;         --ashish for bug # 2519043
--        warehouse_not_found         EXCEPTION          ;

        CURSOR cur_source_line_id_exists ( p_line_id   OE_ORDER_LINES_ALL.LINE_ID%TYPE   ,
                                           p_header_id OE_ORDER_LINES_ALL.HEADER_ID%TYPE
                                         )
          IS
         SELECT
                    'X'
         FROM
                    JAI_OM_OE_SO_LINES
         WHERE
                    line_id   = p_line_id   AND
                    header_id = p_header_id ;

        l_exists          VARCHAR2(1);
        l_tax_lines_exist VARCHAR2(10); --File.Sql.35 Cbabu  := 'FALSE' ;

        /*
           This code added by aiyer for the bug #3057594
           Get the lc_flag value from the orginal line from where the line has been split.
        */
        -- Start of bug # 3057594
        CURSOR rec_get_lc_flag
        IS
        SELECT
               lc_flag
        FROM
                JAI_OM_OE_SO_LINES
        WHERE
                line_id = pr_new.split_from_line_id;

        l_lc_flag JAI_OM_OE_SO_LINES.LC_FLAG%TYPE;

      -- End of bug # 3057594

   ln_vat_assessable_value JAI_OM_OE_SO_LINES.VAT_ASSESSABLE_VALUE%TYPE;

   r_get_copy_order_line get_copy_order_line%ROWTYPE; --bgowrava for forward porting bug#4895477

  -- code segment added by sriram - LMW ATO
    procedure calc_price_tax_for_config_item (p_header_id Number, p_line_id number)
    is
       cursor c_get_line_tax_amt is
        select  line_amount , tax_amount , selling_price , assessable_value , quantity, -- quantity added to the select clause Bug # 2968360
                vat_assessable_value -- added for bug#8924003
        from    JAI_OM_OE_SO_LINES
        where   header_id = pr_new.header_id
        and     shipment_schedule_line_id   = pr_new.ato_line_id;

        -- the last where clause handles the case where there are multiple config items in the single order

   begin

     For so_lines_rec in c_get_line_tax_amt
      Loop
         v_ato_line_amount := NVL(v_ato_line_amount,0)  + NVL(so_lines_rec.line_amount,0);
         v_ato_tax_amount  := NVL(v_ato_tax_amount,0)   + NVL(so_lines_rec.tax_amount,0);
         v_ato_selling_price := NVL(v_ato_selling_price,0) + (( NVL(so_lines_rec.selling_price,0) * so_lines_rec.quantity ) / pr_new.ordered_quantity) ; -- 2968360
         v_ato_assessable_value := NVL(v_ato_assessable_value,0) + (( NVL(so_lines_rec.assessable_value,so_lines_rec.selling_price) * so_lines_rec.quantity ) / pr_new.ordered_quantity); -- 2968360
         --added the following for bug#8924003
         v_ato_vat_assessable_value := NVL(v_ato_vat_assessable_value,0) + (( NVL(so_lines_rec.vat_assessable_value,so_lines_rec.selling_price) * so_lines_rec.quantity ) / pr_new.ordered_quantity );
      end loop;
      --p_ato_line_amount := v_ato_line_amount;
      --p_ato_tax_amount  := v_ato_tax_amount;
   end;

-- ends here - code added by sriram LMW ATO
  BEGIN
/*-------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:

  Sl. YYYY/MM/DD  Author and Details
---------------------------------------------------------------------------------------------------------------
  1. 20-FEB-2007  bgowrava - bug# 4895477 , File Version 120.5

                  Issue : - When a cancelled order was copied , the taxes were getting copied as zero.

                  Resolution :-

                          The reason for this behaviour was because , the code was just copying the taxes
                          from the source order. In the case of a cancelled order , the quantity is zero, and it
                          causes the line amount, vat assessable value to be zero and all the taxes which are zero
                          in the source order are copied as it is.

                          Code changes done are as follows :

                          1. Added a call to the ja_in_calc_Taxes_ato procedure which does the tax recalculation.
                          2. Added a call to get the vat assessable value prior to the copy so that the current
                             value can be fetched.

                 Dependencies due to this bug: - None.


  2. 20-FEB-2007  bgowrava for forward porting bug#5554420 (11i bug#5550848). File Version 120.5
                  Issue: Copy order is throwing the error.
                  Reason: During copy order, ja_in_calc_taxes_ato is being called everytime the a tax is inseted
                        in the loop. And ja_in_calc_taxes_ato is expecting the tax line number will be from 1 to n
                        which will not happen if 6th tax is being inserted first.

                  Resolution: call to ja_in_calc_taxes_ato is moved out of the tax insertion loop

                      --- Dependancy Introduced: Nothing ------

 3.  15-MAY-2007   SSAWANT , File version 120.8
      Forward porting the change in 11.5 bug 4439200 to R12 bug no 4660756.


      Vat Assessable Value was calculated incorrectly in case of Split line functionality.
                  Added code to calculate Vat Assessable Value based on the Quantity.

4.  04/06/2007  bduvarag for the bug#6071813,5989740,5256498
      Forward ported the 11i bugs 6053462,5907436,5256498



5. 12/06/2007   Bgowrava, for Bug# 6126581 , File Version 120.11
                Uncommented the line wdd.delivery_detail_id = TO_NUMBER(pr_new.attribute2) in the
                cursor c_get_detail_id

6. 13/06/2007   Bgowrava, for Bug# 6126581 , File Version 120.12
                created a cursor cur_get_ddetail_id to get the delivery detail id of the RMA and
                used the delivery detail id in the c_get_detail_id instead of the Attribute2 parameter.

7. 14/06/2007   sacsethi for bug 6072461 file version 120.13
                This bug is used to fp 11i bug 5183031 for vat reveresal

    Problem - Vat Reversal Enhancement not forward ported
    Solution - Changes has been done to make it compatible for vat reversal functioanlity also.

8.  08/10/2007  CSahoo for bug#6485212  File Version 120.14
    Added the precedences 6 to 10 in the code.

9.  01-JAN-2008  Added by Jia Li
                 for inclusive tax

10. 25-Sep-2008 CSahoo for bug#7316234 File Version 120.15.12010000.3
                Issue:EXCISE RETURN DAYS AND ST/ CST REURN DAYS FUNCTIONALITY NOT WORKING AS DESIRED
                Fix: removed the concept of 180 days in return days functionality. Modified the IF condition
                     for the same.
11. 30-oct-2008 bug#7523501   120.15.12010000.4
              forwardported the changes done in 115 bug#7523501

12. 20-Nov-2008 CSahoo for bug#7568194, File Version 120.15.12010000.5
                ISSUE: AFTER SAVING THE RMA IT IS REFERENCED TO AN AR INVOICE BUT AN ERROR  OCCURS
                Fix: Modified the code in the BRIU_T1 procedure. Added jai_constants.UPDATING in the
                     IF condition.

13. 20-May-2009 CSahoo for bug#8485149, File Version 120.15.12010000.7
                ISSUE: ATO MODEL EXCISE ITEM ATTRIBUTES ARE NOT GETTING CREATED FOR STAR(*) ITEM
                FIX: Modified the code in the procedure BRIU_T1. Added the curs37.   07-apr-2009
     and cur_get_model_line_dtls. Added the code to check for the config item and
                     create a entry for the item in the table jai_inv_itm_setups

       vkaranam for bug#8413915
       Issue:
                   UOM IN RMA ORDER IS COMING INCORRECT IF THE UOM IS CHANGED IN THE BASE FORM
                   Fix:
                   In the Update to table ja_in_rma_entry_lines, added the column UOM in the Set Clause
or cur_chk_item_dtls    (fwdported the changes done in 115 bug 8403321)

14. 13-aug-09  vkaranam for bug 8356692
               Issue:
         RMA lines are not flowing on the localized sales order
         Fix:
         Forwardported the changes done in 115 bug 7568180

      added the conversion factor and ROUND function for rma qty
           validation
           IF ROUND(v_shipped_quantity,2) < ROUND(pr_new.ordered_quantity*
           (1/v_conversion_rate),2)

15. 23-Sep-2009 CSahoo for bug#8924003, File Version 120.15.12010000.10
                Issue: TAXES AND UNIT RATE  COMING WRONGLY FOR THE ATO/PTO ITEM
                Fix: forward ported the changes done for bug#6147494. Added the code to
                     calculate the vat assessable value for config item.

16. 11-Dec-2209 CSahoo for bug#9067808, File Version 120.15.12010000.11
                Issue: IN ATO UNIT SELLING PRICE IS NOT UPDATING IN THE SALES ORDER LOCALIZED FORM
                Fix: Modified the code in procedure ARU_T1. Added the procedure calc_price_tax_for_config_item
                     and get_config_item.

17. 28-JAN-2010 CSahoo for bug#9191274, File Version 120.15.12010000.12
                Issue: VAT ITEM ATTRIBUTES NOT ASSIGNED AUTOMATICALLY FOR STAR ITEM,  AFTER CONFIGURATI
                Fix: modified the procedure BRIU_T1. Added a call to jai_inv_items_pkg.copy_items for
                     populating VAT attributes of the star item.
18. 28-APR-2010 Allen Yang modified for bug 9666476 File Version 120.15.12010000.14
                Issue: TST1213.NON SHIPPABLE: SUPPORT FOR RMA AND OTHER CHANGES FOR NON-SHIPPABLE ITEMS
                Fix:   Added process logic for non-shippables lines when copying RMA lines from normal order lines.
19. 07-MAY-2010 Allen Yang modified for bug 9691880 File Version 120.15.12010000.15
                Issue: TST1213.NON SHIPPABLE: CONSOLIDATED PATCH FOR CORE PART AND RMA OF NON-SHIPPABLE
                Fix:   1). modified logic of getting shippable flag variable lv_shippable_flag
                       2). added logic to copy Indian taxes from orginal Sales Order line to RMA Order line when
                           copy is happening from 'Mixed' order type to 'Return' line type.
                       3). added logic to validate VAT Return days for Order copying from 'Standard' / 'Mixed'
                           order type to 'Return' line type.
20.  13-MAY-2010 vkaranam for bug#9436523
                 issue:
                 ORA-20001: APP--20110: Taxes are not matching in JAI_OM_OE_SO_LINES and
                 JA_IN_SO_TAX_LINE FOR LINE_ID 4656 while shipping the splitted line.
                 Reason:
                 issue is happening with order having inclusive taxes.
                 inclusive tax amount is updated in jai_om_oe_so_lines.tax_amount.
                 ideally jai_om_oe_so_lines.tax_amount shall be 0 for inclusive taxes.

                 Fix:

                 updated jai_om_oe_so_lines.tax_amount as the tax amount for exclusive taxes.
21. 27-May-2010   Allen Yang for bug #9722577
                  Issue: variable v_converted_rate is used without initialization for func_tax_amount
                         calculation when copying from Order to Order.
                  Fix:   added logic to initialize v_converted_rate

22  09-Jun-2010  Bug 9786306
                 Issue - Interface trip stop ends in warning for partial (split) shipments.
                 Cause - In the changes done for bug 9436523, utl_file.put_line was called without
                         checking v_debug.
                 Fix - Added IF v_debug = 'Y' condition before calling utl_file.put_line.
----------------------------------------------------------------------------------------------------------------*/
    pv_return_code := jai_constants.successful ;

  /*
  || Code modified by aiyer for the bug #3134082
  || Initially this validation was below the ware house validation (which now follows next to this piece of validation).
  || Due to this the trigger used to raise the error message 'Ware House ID is mandatory for Calculating Localization taxes'
  || even in case of Non Indian Operating units.
  || Hence to prevent this, the INR check validation has now been moved up so that this is the first validation to be executed .
  || The trigger should get bypassed if the functional currency is not 'INR'.
 */
 -- Start of Bug #3134082

  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */

  --File.Sql.35 Cbabu
  v_header_id                      := pr_new.header_id;
  v_line_id                        := pr_new.line_id;
  v_line_number                    := pr_new.line_number;
  v_ship_to_site_use_id            :=  NVL(pr_new.ship_to_ORG_id,0);
  v_inventory_item_id              := pr_new.inventory_item_id;
  v_line_quantity                  :=  NVL(pr_new.ordered_quantity,0);
  v_uom_code                      := pr_new.ORDER_QUANTITY_UOM;
  v_warehouse_id                  := pr_new.SHIP_FROM_ORG_ID;
  v_creation_date                 := pr_new.creation_date;
  v_created_by                     := pr_new.created_by;
  v_last_update_date              := pr_new.last_update_date;
  v_last_updated_by                := pr_new.last_updated_by;
  v_last_update_login              := pr_new.last_update_login;
  v_original_system_line_ref      := pr_new.ORIG_SYS_LINE_REF;
  v_original_line_reference       := pr_new.ORIG_SYS_LINE_REF;
  v_Line_Category_Code            := pr_new.Line_Category_Code;
  v_line_amount                   := (NVL(pr_new.ordered_quantity,0)*NVL(pr_new.UNIT_SELLING_PRICE,0));
  v_transaction_name              := 'SALES_ORDER';
  v_base_tax_amount               := 0;
  v_func_tax_amount               := 0;
  v_line_tax_amount               := 0;
  -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
  --v_ordered_quantity              := 0;
  v_ordered_quantity              := pr_new.ORDERED_QUANTITY;
  -- modified by Allen Yang for bug 9666476 28-apr-2010, end
  v_conversion_rate               := 0;
  v_ship_count                    := 0;
  v_item_type_code                := pr_new.item_type_code;
  v_reference_line_id             := pr_new.reference_line_id;-- 2001/05/09  Anuradha Parthasarathy
  v_header_tax_amount             :=0; --Added by Nagaraj.s for Bug3140153.(Holds sum of tax amount for each order line. Used in case of a split line)
  v_operating_id                  := pr_new.ORG_ID;
  v_source_document_id            := pr_new.SOURCE_DOCUMENT_ID      ;
  v_source_document_line_id       := pr_new.SOURCE_DOCUMENT_LINE_ID ;
  v_source_document_type_id       := pr_new.SOURCE_DOCUMENT_TYPE_ID ;
  v_debug                         := jai_constants.no;
  l_tax_lines_exist               := 'FALSE' ;
  -- added by Allen Yang for bug 9666476 28-apr-2010, begin
  -- lv_shippable_flag               := pr_new.SHIPPING_INTERFACED_FLAG;
  lv_shippable_flag               := pr_new.SHIPPABLE_FLAG; -- modified by Allen Yang for bug 9691880 07-MAY-2010
  -- added by Allen Yang for bug 9666476 28-apr-2010, end

 -- End  of Bug #3134082

/*  added by ssumaith- bug# 3959984*/

    if  ( pv_action = jai_constants.updating and ( (nvl(pr_old.line_number,-9999) <> nvl(pr_new.line_number,-9998)) and pr_new.line_number is not null))
     OR
        ( pv_action = jai_constants.updating and ( (nvl(pr_old.shipment_number,-9999) <> nvl(pr_new.shipment_number,-9998)) and pr_new.shipment_number is not null))
    then

       update JAI_OM_OE_SO_LINES
       set    line_number = pr_new.line_number  , shipment_line_number = pr_new.shipment_number
       where  line_id = pr_new.line_id;

       return;
    end if;

 /*  added by ssumaith- bug# 3959984*/




        -- Block added by Aparajita for log file generation
        -- localization hook introduced by ashish for bug no 2413327
        v_hook := jai_cmn_hook_pkg.oe_lines_insert(
                                pr_new.line_id, pr_new.org_id, pr_new.line_type_id, pr_new.ship_from_org_id,
                                pr_new.ship_to_org_id, pr_new.invoice_to_org_id, pr_new.sold_to_org_id, pr_new.sold_from_org_id,
                                pr_new.inventory_item_id, pr_new.tax_code, pr_new.price_list_id, pr_new.source_document_type_id,
                                pr_new.source_document_line_id, pr_new.reference_line_id, pr_new.reference_header_id, pr_new.salesrep_id,
                                pr_new.order_source_id, pr_new.orig_sys_document_ref, pr_new.orig_sys_line_ref
                        );


        IF v_hook = 'FALSE' THEN
                RETURN;
        END IF;


  IF v_debug = 'Y' THEN

    BEGIN
    pv_return_code := jai_constants.successful ;

      SELECT DECODE(SUBSTR(value,1,INSTR(value,',') -1),
                        NULL,
                    value,
                                        SUBSTR (value,1,INSTR(value,',') -1)
                                        )
      INTO   v_utl_location
      FROM   v$parameter
      WHERE  LOWER(name) = 'utl_file_dir';

          -- if there are more than one directory defined for the parameter pick up the first one.

          IF v_utl_location IS NULL THEN
            -- utl file dir not defined, log file cannot be generated.
            v_debug := 'N';
          ELSE
            -- open the file in append mode.
            v_myfilehandle := utl_file.fopen(v_utl_location, 'OE_ORDER_LINES_ALL_triggers_ja.LOG','A');
          END IF;

    EXCEPTION
      WHEN OTHERS THEN
            -- some exceptions have occured, log file cannot be generated,
                -- but the normal processing should contunue.
            v_debug := 'N';
    END;

  END IF; -- v_debug

  -- Added by Aparajita for writing onto the log file
  IF v_debug = 'Y' THEN
    -- log start of trigger
    utl_file.put_line(v_myfilehandle,'** START OF TRIGGER JA_IN_OE_ORDER_LINES_AIU_TRG AFTER INSERT OR UPDATE ON OE_ORDER_LINES_ALL FOR EACH ROW ~ ' || TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss'));
        utl_file.put_line(v_myfilehandle,'Header ID ~ Line ID :' || TO_CHAR(pr_new.header_id) || ' ~ ' || TO_CHAR(pr_new.line_id));
  END IF; -- v_debug


  /*
  Added by ssumaith - bug#3671871
  */

  IF pv_action = jai_constants.updating AND pr_new.inventory_item_id <> pr_old.inventory_item_id THEN
     DELETE JAI_OM_OE_SO_LINES
     WHERE  line_id = pr_new.line_id;

     DELETE JAI_OM_OE_SO_TAXES
     WHERE line_id = pr_new.line_id;

  END IF;


  /*
  Added by ssumaith -bug#3671871  -- ends here
  */

  --2001/06/14 Gadde,Jagdish
  OPEN bind_cur(v_header_id);
  FETCH bind_cur INTO
    v_row_id,
    v_org_id,
    v_customer_id,
    v_source_header_id,
    v_order_number,
    v_price_list_id,
    v_order_category,
    v_original_system_reference,
    v_currency_code,
    v_conv_type_code,
    v_conv_rate,
    v_conv_date,
    v_date_ordered;

  CLOSE bind_cur;
  v_service_type_code := JAI_AR_RCTLA_TRIGGER_PKG.get_service_type( v_customer_id, v_ship_to_site_use_id, 'C'); /*bduvarag for the bug#5694855*/
  -- check for conversion date
  IF v_conv_date IS NULL THEN
    v_conv_date := v_date_ordered;
  END IF;

  --2001/04/18 Anuradha Parthasarathy
  OPEN get_so_lines_count_cur(pr_new.split_from_line_id);
  FETCH get_so_lines_count_cur INTO v_so_lines_count;
  CLOSE get_so_lines_count_cur;
  --2001/04/24 Anuradha Parthasarathy

  OPEN Get_Copy_Order_Count(v_source_header_id);
  FETCH Get_Copy_Order_Count INTO v_so_lines_copy_count;
  CLOSE Get_Copy_Order_Count;

  -- Cursor for defaulting of taxes for
  -- Web Stores Order's Import
  OPEN get_original_source ;
  FETCH get_original_source INTO v_orig_sys_document_ref;
  CLOSE get_original_source ;
  -- End Add

  OPEN  po_reqn_lines_count(v_orig_sys_document_ref); --2001/04/25 Deepak Prabhakar
  FETCH po_reqn_lines_count INTO v_count;
  CLOSE po_reqn_lines_count;

  /*
  || Added by aiyer for the bug 5401180,
  || Modified the IF condition. Original Condition
  ||    IF v_item_type_code = 'STANDARD'
  ||       AND
  ||           ( (v_reference_line_id IS NOT NULL OR v_order_category = 'RETURN')
  ||             AND
  ||             ( NVL(pr_new.RETURN_CONTEXT, 'XX') <> 'LEGACY') -- and legacy condition added by Aparajita for bug # 2504184
  ||           )
  ||           AND
  ||           NVL(V_Source_Document_Type_Id,0) <> 2
  || has been replaced by the new condition.
  */
  IF v_item_type_code                  = 'STANDARD'     AND
     (  ( v_reference_line_id          IS NOT NULL      OR
          pr_new.line_category_code    = 'RETURN'
        )                                              AND
        pr_new.return_context          IS NOT NULL
     )                                                  AND
     NVL(V_Source_Document_Type_Id,0) <> 2
  THEN
   /* End of bug 5401180 */

        IF v_debug = 'Y' THEN
          utl_file.put_line(v_myfilehandle,'Returning at  STANDARD , RETURN, V_Source_Document_Type_Id' );
          utl_file.put_line(v_myfilehandle,'** END OF TRIGGER jai_oe_ola_ariu_t5 AFTER INSERT OR UPDATE ON OE_ORDER_LINES_ALL FOR EACH ROW ~ ' || TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss'));
          utl_file.fclose(v_myfilehandle);
        END IF; -- v_debug
    RETURN;
  END IF;

  OPEN  Get_Order_Source_Type(V_Source_Document_Type_Id);
  FETCH Get_Order_Source_Type INTO V_Order_Source_Type;
  CLOSE Get_Order_Source_Type;

  IF (
                       pr_new.SPLIT_FROM_LINE_ID IS NULL                 -- cbabu for Bug# 2510362
                AND     V_SOURCE_DOCUMENT_TYPE_ID IS NOT NULL
                AND     V_SOURCE_DOCUMENT_LINE_ID IS NOT NULL
                AND     V_Order_Source_Type='Copy'
     )
  THEN

    -- Copy Order
    OPEN Get_Copy_Order_Line(v_source_document_id, v_source_document_line_id);
    FETCH Get_Copy_Order_Line INTO copy_rec;

        -- start added for bug#3223481
        IF Get_Copy_Order_Line%NOTFOUND THEN
            -- source order line does not exist in JAI_OM_OE_SO_LINES , should not process
            -- this could be because of quantity being 0 / cancelled line.

            IF v_line_category_code = 'ORDER' THEN -- ABCD
              CLOSE get_copy_order_line ;
              RETURN;
            END IF; -- ABCD
        END IF;
        CLOSE get_copy_order_line ;
    -- end added for bug#3223481

    OPEN  source_order_doc_cur(V_Source_Document_Id);
    FETCH source_order_doc_cur INTO v_source_order_category_code;
    CLOSE source_order_doc_cur;

    --2001/10/01 Anuradha Parthasarathy
    /*
      This code has been added by Arun Iyer for the fix of the bug #2798930.
      Made the check more explicit as functionality in case of order to order and return to order is different.
    */
    IF v_source_order_category_code = 'ORDER' AND v_line_category_code = 'ORDER'  THEN

       --ashish  shukla 1 aug02 2489301
       SELECT COUNT(*) INTO c_source_line_id FROM JAI_OM_OE_SO_LINES WHERE LINE_ID = v_line_id;
       IF c_source_line_id = 0 THEN
         /*
          in the following insert - changes are done to the insert by ssumaith - bug#3959984
                                  - inventory_item_id    -> v_inventory_item_id
                                  - shipment_line_number -> pr_new.shipment_number
                                  - unit_selling_price   ->  pr_new.unit_selling_price
                                  - quantity             ->  pr_new.ordered_quantity
                                  - line_amount          ->  nvl(pr_new.unit_selling_price * pr_new.ordered_quantity ,0)
         */
          -- Start of changed by bgowrava for forward porting bug#4895477 to recalculate VAT taxes in case of copying order.

         ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                        (
                         p_party_id           => v_customer_id          ,
                         p_party_site_id      => v_ship_to_site_use_id  ,
                         p_inventory_item_id  => v_inventory_item_id    ,
                         p_uom_code           => v_uom_code             ,
                         p_default_price      => pr_new.unit_selling_price,
                         p_ass_value_date     => v_date_ordered         ,
                         p_party_type         => 'C'
                        );

         ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_line_quantity;

         --End of bug#4895477


         INSERT INTO JAI_OM_OE_SO_LINES (
                          line_number, line_id, header_id, inventory_item_id,
                          unit_code, quantity, tax_category_id, ato_flag,
                          selling_price, line_amount, assessable_value, tax_amount,
                          line_tot_amount, shipment_line_number,
                          excise_exempt_type , excise_exempt_refno ,excise_exempt_date, /* added by ssumaith for vat */
                          vat_exemption_flag,vat_exemption_type,vat_exemption_date ,vat_exemption_refno,vat_assessable_value,  /* added by ssumaith for vat */
                          vat_reversal_price, --Date 14/06/2007 by sacsethi for bug 6072461
                          creation_date, created_by,
                          last_update_date, last_updated_by, last_update_login,service_type_code
          ) VALUES (
                          v_line_number, v_line_id, v_header_id, v_inventory_item_id,
                          copy_rec.unit_code, pr_new.ordered_quantity, copy_rec.tax_category_id, 'Y',
                          pr_new.unit_selling_price,  nvl(pr_new.unit_selling_price * pr_new.ordered_quantity ,0),
                          copy_rec.assessable_value, copy_rec.tax_amount,
                          copy_rec.line_tot_amount, pr_new.shipment_number,
                          copy_rec.excise_exempt_type , copy_rec.excise_exempt_refno , copy_rec.excise_exempt_date, /* added by ssumaith for vat */
                          copy_rec.vat_exemption_flag,copy_rec.vat_exemption_type,copy_rec.vat_exemption_date ,copy_rec.vat_exemption_refno,copy_rec.vat_assessable_value,  /* added by ssumaith for vat */
                          nvl(copy_rec.vat_reversal_price,0) * v_line_quantity, --Date 14/06/2007 by sacsethi for bug 6072461
        v_creation_date, v_created_by,
                          v_last_update_date, v_last_updated_by, v_last_update_login,copy_rec.service_type_code
              );
       END IF;

    ELSIF  v_source_order_category_code = 'RETURN' AND v_line_category_code = 'ORDER'  THEN

    /*
      This code has been added by Arun Iyer for the fix of the bug #2798930.
      IF the source_order categoy code is Return and line category code is ORDER then
       1. Check whether a corresponding record exists in the rma_entry_lines table.
          IF Yes then get the details of this record into the record group variable rec_cur_get_rma_entry_lines and check whether a
          record with the same line_id exists in the JAI_OM_OE_SO_LINES table.
          IF such a record is not found then then insert a record into the JAI_OM_OE_SO_LINES table.
    */

             OPEN cur_get_rma_entry_lines (V_Source_Document_Id, V_Source_Document_Line_Id);
             FETCH cur_get_rma_entry_lines INTO rec_cur_get_rma_entry_lines;

             IF cur_get_rma_entry_lines%FOUND THEN
                OPEN   cur_source_line_id_exists ( p_line_id   => v_line_id   ,
                                                   p_header_id => v_header_id
                                                  );

                FETCH  cur_source_line_id_exists INTO l_exists;
                 IF cur_source_line_id_exists%NOTFOUND THEN

                    INSERT INTO JAI_OM_OE_SO_LINES (
                                                    line_number                                               ,
                                                    line_id                                                   ,
                                                    header_id                                                 ,
                                                    inventory_item_id                                         ,
                                                    unit_code                                                 ,
                                                    quantity                                                  ,
                                                    tax_category_id                                           ,
                                                    ato_flag                                                  ,
                                                    selling_price                                             ,
                                                    line_amount                                               ,
                                                    assessable_value                                          ,
                                                    tax_amount                                                ,
                                                    line_tot_amount                                           ,
                                                    shipment_line_number                                      ,
                                                    creation_date                                             ,
                                                    created_by                                                ,
                                                    last_update_date                                          ,
                                                    last_updated_by                                           ,
                                                    last_update_login,service_type_code
                                                )
                                VALUES          (
                                                    v_line_number                                             ,
                                                    v_line_id                                                 ,
                                                    v_header_id                                               ,
                                                    rec_cur_get_rma_entry_lines.inventory_item_id             ,
                                                    rec_cur_get_rma_entry_lines.uom                           ,
                                                    rec_cur_get_rma_entry_lines.quantity                      ,
                                                    rec_cur_get_rma_entry_lines.tax_category_id               ,
                                                    'Y'                                                       ,
                                                    rec_cur_get_rma_entry_lines.selling_price                 ,
                                                    v_line_amount                                             ,
                                                    rec_cur_get_rma_entry_lines.assessable_value              ,
                                                    rec_cur_get_rma_entry_lines.tax_amount                    ,
                                                    (v_line_amount + rec_cur_get_rma_entry_lines.tax_amount)  ,
                                                    pr_new.shipment_number                                      ,
                                                    v_creation_date                                           ,
                                                    v_created_by                                              ,
                                                    v_last_update_date                                        ,
                                                    v_last_updated_by                                         ,
                                                    v_last_update_login,rec_cur_get_rma_entry_lines.service_type_code
                                                 );

                  END IF;
                  CLOSE cur_source_line_id_exists;
               END IF;
               CLOSE cur_get_rma_entry_lines ;

    /*
      This code has been added by Arun Iyer for the fix of the bug #2820360.
      Made the check more explicit as functionality in case of ORDER  to RETURN
      Even though base apps allows this feature this functionality is not currently supported by India Localisation
      Raise an error in such scenario's
    */

    ELSIF v_source_order_category_code = 'ORDER' AND v_line_category_code = 'RETURN' THEN

      DECLARE
         -- get the details from JAI_OM_WSH_LINES_ALL table
         CURSOR cur_get_picking_lines(
                                                  p_source_document_id        OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_ID%TYPE     ,
                                                  p_source_document_line_id   OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE
                                               )
         IS
         /* Commented by Brathod for Bug#4244829
   SELECT
                 pl.inventory_item_id       ,
                 pl.unit_code               ,
                 pl.quantity                ,
                 pl.tax_category_id         ,
                 pl.selling_price           ,
                 pl.tax_amount              ,
                 pl.delivery_detail_id
         FROM
                 JAI_OM_WSH_LINES_ALL pl
         WHERE
                 pl.order_header_id       = p_source_document_id       AND
                 pl.order_line_id         = p_source_document_line_id  ;
         */

        /* Added by Brathod for Bug# 4244829 */
        SELECT
                 pl.inventory_item_id       inventory_item_id    ,
                 pl.unit_code               unit_code            ,
                 sum(pl.quantity )          quantity             ,
                 pl.tax_category_id         tax_category_id      ,
                 pl.selling_price           selling_price        ,
                 sum(pl.tax_amount)         tax_amount           ,
                 min(pl.delivery_detail_id) delivery_detail_id
         FROM
                 JAI_OM_WSH_LINES_ALL pl
         WHERE
                 pl.order_header_id       = p_source_document_id       AND
                 pl.order_line_id         = p_source_document_line_id
         GROUP BY
            pl.inventory_item_id      ,
            pl.unit_code              ,
      pl.selling_price        ,
            pl.tax_category_id        ;


  /* End Bug#4244829 */


--Added by kunkumar for forward porting to R12

cursor c_sales_order_cur is
                  select quantity,service_type_code
                  from JAI_OM_OE_SO_LINES
                  where line_id=v_reference_line_id;


         CURSOR cur_rma_entry_line_exists ( p_line_id   OE_ORDER_LINES_ALL.LINE_ID%TYPE   ,
                                            p_header_id OE_ORDER_LINES_ALL.HEADER_ID%TYPE
                                          )
         IS
         SELECT
                     'X'
         FROM
                     JAI_OM_OE_RMA_LINES
         WHERE
                     rma_line_id   = p_line_id   AND
                     rma_header_id = p_header_id ;

         l_exists    VARCHAR2(1);

        rec_cur_get_picking_lines  cur_get_picking_lines%ROWTYPE;

        /*
        || Added for bug#5256498, Starts --bduvarag
        */
         CURSOR cur_get_picking_tax_lines (
                                              p_source_document_id        JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE    ,
                                              p_source_document_line_id   JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE
                                          )
         IS
          SELECT
                  ptl.tax_line_no                  tax_line_no      ,
                  ptl.tax_id                       tax_id           ,
                  ptl.tax_rate                     tax_rate         ,
                  ptl.qty_rate                     qty_rate         ,
                  ptl.uom                          uom              ,
                  ptl.precedence_1                 precedence_1     ,
                  ptl.precedence_2                 precedence_2     ,
                  ptl.precedence_3                 precedence_3     ,
                  ptl.precedence_4                 precedence_4     ,
                  ptl.precedence_5                 precedence_5     ,
                  ptl.precedence_6                 precedence_6     ,
                  ptl.precedence_7                 precedence_7     ,
                  ptl.precedence_8                 precedence_8     ,
                  ptl.precedence_9                 precedence_9     ,
                  ptl.precedence_10                precedence_10    ,
                  jtc.tax_type                     tax_type         ,
      nvl(jtc.rounding_factor,0)       rounding_factor  ,         /*bduvarag for the bug#6071813*/
                  SUM (ptl.tax_amount)             tax_amount       ,
                  SUM (ptl.base_tax_amount)        base_tax_amount  ,
                  SUM (ptl.func_tax_amount)        func_tax_amount  ,
                  MIN (ptl.delivery_detail_id)     delivery_detail_id
          FROM
                  JAI_OM_WSH_LINES_ALL          pl    ,
                  JAI_OM_WSH_LINE_TAXES     ptl    ,
                  JAI_CMN_TAXES_ALL                jtc
          WHERE
                  ptl.delivery_detail_id = pl.delivery_detail_id     AND
                  pl.order_header_id     = p_source_document_id      AND
                  pl.order_line_id       = p_source_document_line_id AND
                  jtc.tax_id             = ptl.tax_id
          GROUP by    ptl.tax_line_no                       ,
                      ptl.tax_id                            ,
                      ptl.tax_rate                          ,
                      ptl.qty_rate                          ,
                      ptl.uom                               ,
                      precedence_1                      ,
                      precedence_2                      ,
                      precedence_3                      ,
                      precedence_4                      ,
                      precedence_5                      ,
                      precedence_6                      ,
                      precedence_7                      ,
                      precedence_8                      ,
                      precedence_9                      ,
                      precedence_10                     ,
                      jtc.tax_type      ,
          nvl(jtc.rounding_factor,0) ;/*bduvarag for the bug#6071813*/

        CURSOR cur_chk_rma_tax_lines_exists(p_line_id JAI_OM_OE_RMA_TAXES.RMA_LINE_ID%TYPE ,
                                            p_tax_id  JAI_OM_OE_RMA_TAXES.TAX_ID%TYPE)
        IS
        SELECT
                  'X'
        FROM
                  JAI_OM_OE_RMA_TAXES
        WHERE
                  rma_line_id     = p_line_id     AND
                  tax_id          = p_tax_id ;

        CURSOR c_get_quantity(
                              p_source_document_id        JAI_OM_WSH_LINES_ALL.order_header_id%type    ,
                              p_source_document_line_id   JAI_OM_WSH_LINES_ALL.order_line_id%type
                              )
        IS
        SELECT
                quantity
        FROM
                JAI_OM_WSH_LINES_ALL          pl    ,
                JAI_OM_WSH_LINE_TAXES     ptl
        WHERE
                ptl.delivery_detail_id = pl.delivery_detail_id     AND
                pl.order_header_id     = p_source_document_id      AND
                pl.order_line_id       = p_source_document_line_id ;

        CURSOR requested_qty_uom_cur(p_delivery_detail_id NUMBER)
        IS
        SELECT
               requested_quantity_uom
        FROM
               wsh_delivery_details
        WHERE
               delivery_detail_id = p_delivery_detail_id;

        CURSOR c_check_vat_type_tax_exists (cp_tax_type VARCHAR2)
        IS
        SELECT
               1
        FROM
               jai_regime_tax_types_v
        WHERE
               regime_code = jai_constants.vat_regime
        AND    tax_type    = cp_tax_type;

        /*Added by Bgowrava for Bug#6126581 */
        cursor cur_get_ddetail_id(p_source_document_id OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_ID%TYPE , p_source_document_line_id OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE) is
        select delivery_detail_id from JAI_OM_OE_RMA_LINES
        where rma_header_id     = p_source_document_id      AND
              rma_line_id       = p_source_document_line_id;

        v_ddetail_id JAI_OM_OE_RMA_LINES.delivery_detail_id%type;
        /* END, Bug#6126581*/

        /*Added a parameter p_ddetail_id in the below cursor for Bug#6126581 */
        CURSOR c_get_detail_id(p_ddetail_id JAI_OM_OE_RMA_LINES.delivery_detail_id%type)
        IS
        SELECT
               wdd.delivery_detail_id,
               wnd.confirm_date
        FROM
              wsh_delivery_details wdd,
              wsh_delivery_assignments wda,
              wsh_new_deliveries wnd
        WHERE
            wdd.delivery_detail_id = p_ddetail_id  AND  -- Added p_ddetail_id by bgowrava for bug#6126581
        wda.delivery_detail_id = wdd.delivery_detail_id AND
        wnd.delivery_id = wda.delivery_id ;

         CURSOR c_get_days_flags
         IS
         SELECT
                excise_return_days,
                sales_return_days,
                vat_return_days ,
                nvl(manufacturing,'N') manufacturing,
                nvl(trading,'N') trading
          FROM
               JAI_CMN_INVENTORY_ORGS
         WHERE
               organization_id = pr_new.ship_from_org_id
           AND location_id = 0 ;

         CURSOR c_ordered_date
         IS
         SELECT
               ordered_date
          FROM
               oe_order_headers_all
         WHERE
               header_id = pr_new.header_id ;

         -- added by Allen Yang for bug 9691880 10-May-2010, begin
         CURSOR c_fulfilled_date
         IS
         SELECT
           CREATION_DATE
         FROM
           JAI_OM_WSH_LINES_ALL
         WHERE ORDER_LINE_ID = v_reference_line_id
           AND SHIPPABLE_FLAG = 'N';
         -- added by Allen Yang for bug 9691880 10-May-2010, end

         CURSOR c_get_ship_qty(cp_delivery_detail_id wsh_delivery_details.delivery_detail_id%TYPE)
         IS
         SELECT
                SUM(wdd.shipped_quantity) qty
           FROM
                wsh_delivery_details wdd
          WHERE
                wdd.delivery_detail_id = cp_delivery_detail_id
            AND wdd.inventory_item_id = pr_new.inventory_item_id ;

/**        CURSOR c_sales_order_cur
        IS
        SELECT
               quantity
        FROM
               JAI_OM_OE_SO_LINES
        WHERE
               line_id = pr_new.reference_line_id ;**/

        CURSOR c_so_tax_amount (p_tax_id JAI_CMN_TAXES_ALL.tax_id%type)
        IS
        SELECT
               tax_amount
        FROM
               JAI_OM_OE_SO_TAXES
        WHERE
               line_id = pr_new.reference_line_id
        AND    tax_id = p_tax_id ;

        lv_check_vat_type_exists VARCHAR2(1);
        v_date_ordered        DATE;
        v_date_confirmed      DATE;
        v_delivery_detail_id  JAI_OM_WSH_LINES_ALL.delivery_detail_id % TYPE;
        v_excise_return_days  JAI_CMN_INVENTORY_ORGS.excise_return_days % TYPE;
        v_sales_return_days   JAI_CMN_INVENTORY_ORGS.sales_return_days % TYPE;
        v_vat_return_days     JAI_CMN_INVENTORY_ORGS.vat_return_days % TYPE;
        v_excise_flag         VARCHAR2(1);
        v_sales_flag          VARCHAR2(1);
        v_vat_flag            VARCHAR2(1);
        v_round_tax           NUMBER;
        v_round_base          NUMBER;
        v_round_func          NUMBER;
        v_tax_total           NUMBER;
        v_manufacturing       JAI_CMN_INVENTORY_ORGS.manufacturing%type;
        v_trading             JAI_CMN_INVENTORY_ORGS.trading%type;
        v_shipped_quantity    wsh_delivery_details.shipped_quantity % TYPE;
        v_quantity            JAI_OM_WSH_LINES_ALL.quantity % TYPE;
        v_requested_quantity_uom VARCHAR2(3);
        v_conversion_rate     NUMBER  := 0;
        v_cor_amount          JAI_OM_WSH_LINES_ALL.tax_amount % TYPE;
        v_orig_ord_qty  Number;
        v_so_tax_amount Number;
        v_rma_quantity_uom    VARCHAR2(3);
        /*
        || Added for bug#5256498, Ends-- bduvarag
        */

      BEGIN
    pv_return_code := jai_constants.successful ;
    v_rma_quantity_uom   := pr_new.order_quantity_uom;
        OPEN c_sales_order_cur;
        FETCH c_sales_order_cur into v_orig_ord_qty, v_service_type_code;
        CLOSE c_sales_order_cur;

        OPEN cur_get_picking_lines  (  p_source_document_id       => v_source_document_id      ,
                                       p_source_document_line_id  => v_source_document_line_id
                                        );
        FETCH cur_get_picking_lines INTO rec_cur_get_picking_lines;
        IF cur_get_picking_lines%FOUND THEN

           OPEN cur_rma_entry_line_exists ( p_line_id   => v_line_id   ,
                                            p_header_id => v_header_id
                                           );
           FETCH cur_rma_entry_line_exists INTO l_exists;
           /*
             IF a record does not exists with the newline_id and header_id
             only then go ahead with the insert
           */
           IF cur_rma_entry_line_exists%NOTFOUND THEN
              -- Insert a record into JAI_OM_OE_RMA_LINES
              INSERT INTO JAI_OM_OE_RMA_LINES
              (
                       rma_line_number                                          ,
                       rma_line_id                                              ,
                       rma_header_id                                            ,
                       rma_number                                               ,
                       inventory_item_id                                        ,
                       uom                                                      ,
                       quantity                                                 ,
                       tax_category_id                                          ,
                       selling_price                                            ,
                       tax_amount                                               ,
                       delivery_detail_id                                       ,
                       creation_date                                            ,
                       created_by                                               ,
                       last_update_date                                         ,
                       last_updated_by                                          ,
                       last_update_login,service_type_code
               )
               VALUES
               (
                       v_line_number                                            ,
                       v_line_id                                                ,
                       v_header_id                                              ,
                       v_order_number                                           ,
                       rec_cur_get_picking_lines.inventory_item_id     ,
                       rec_cur_get_picking_lines.unit_code             ,
                       rec_cur_get_picking_lines.quantity              ,
                       rec_cur_get_picking_lines.tax_category_id       ,
                       rec_cur_get_picking_lines.selling_price         ,
                       rec_cur_get_picking_lines.tax_amount            ,
                       rec_cur_get_picking_lines.delivery_detail_id   ,
                       v_creation_date                                          ,
                       v_created_by                                             ,
                       v_last_update_date                                       ,
                       v_last_updated_by                                        ,
                       v_last_update_login,v_service_type_code
               );
            END IF;
            CLOSE cur_rma_entry_line_exists;

            /* Added by Bgowrava for Bug#6126581*/
            /*replaced the input parameters from v_source_document_id,v_source_document_line_id
            by v_header_id, v_line_id for bug#7316234*/
            open cur_get_ddetail_id(p_source_document_id => v_header_id,
                                    p_source_document_line_id  => v_line_id);
            fetch cur_get_ddetail_id into v_ddetail_id ;
            close cur_get_ddetail_id;


            /*END, Bug#6126581*/
            /*
            || Following code copied from internal procedure rma_insert of Procedure JA_IN_RMA_MAINTAIN (version 115.5)
            || Added for bug#5256498, Starts --bduvarag
            */
            OPEN c_get_detail_id(v_ddetail_id) ;
            FETCH c_get_detail_id INTO v_delivery_detail_id, v_date_confirmed ;
            CLOSE c_get_detail_id ;

            -- added by Allen Yang for bug 9691880 10-May-2010, begin
            /* moved code from below IF condition to here to check VAT return days for both
               shippable and non-shippalbe lines.*/
            OPEN c_get_days_flags ;
            FETCH c_get_days_flags INTO  v_excise_return_days,
                                         v_sales_return_days ,
                                         v_vat_return_days   ,
                                         v_manufacturing     ,
                                         v_trading           ;
            CLOSE c_get_days_flags ;

            OPEN c_ordered_date ;
            FETCH c_ordered_date INTO v_date_ordered ;
            CLOSE c_ordered_date ;
            -- added by Allen Yang for bug 9691880 10-May-2010, end

            IF v_delivery_detail_id IS NOT NULL
            THEN
              /* -- commented by Allen Yang for bug 9691880 10-May-2010, begin
              OPEN c_get_days_flags ;
              FETCH c_get_days_flags INTO  v_excise_return_days,
                                           v_sales_return_days ,
                                           v_vat_return_days   ,
                                           v_manufacturing     ,
                                           v_trading           ;
              CLOSE c_get_days_flags ;

              OPEN c_ordered_date ;
              FETCH c_ordered_date INTO v_date_ordered ;
              CLOSE c_ordered_date ;
              -- commented by Allen Yang for bug 9691880 10-May-2010, end */

              --Uncommented the following and modified the IF condition for bug#7316234

              IF (v_excise_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_excise_return_days)
              THEN
                 v_excise_flag := 'Y';
              ELSE
                 v_excise_flag := 'N';
              END IF;

              --Uncommented the following and modified the IF condition for bug#7316234

              IF (v_sales_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_sales_return_days)
              THEN
                 v_sales_flag := 'Y';
              ELSE
                 v_sales_flag := 'N';
              END IF;

              ---modified the IF condition for bug#7316234
              IF (v_vat_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_vat_return_days)
              THEN

                 v_vat_flag := 'Y';
              ELSE
                 v_vat_flag := 'N';
              END IF;

              OPEN  c_get_ship_qty (v_delivery_detail_id);
              FETCH c_get_ship_qty INTO v_shipped_quantity ;
              CLOSE c_get_ship_qty ;
 --start additions for bug#7675274
         OPEN  c_get_quantity(p_source_document_id      => v_source_document_id,
                                          p_source_document_line_id => v_source_document_line_id );
              FETCH c_get_quantity INTO v_quantity ;
              CLOSE c_get_quantity ;

              IF v_quantity <> 0 THEN
                OPEN requested_qty_uom_cur(v_delivery_detail_id);
                FETCH requested_qty_uom_cur INTO v_requested_quantity_uom;
                CLOSE requested_qty_uom_cur;

                INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                              v_rma_quantity_uom,
                                              pr_new.inventory_item_id,
                                              v_conversion_rate);
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                  INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                v_rma_quantity_uom,
                                                0,
                                                v_conversion_rate);
                  IF NVL(v_conversion_rate, 0) <= 0 THEN
                         v_conversion_rate := 1; --Changed v_conversion_rate from 0 to 1, so that divide by zero error does not occur. ---bug  8356692
                  END IF;
                END IF;
                v_cor_amount := (pr_new.ordered_quantity / v_quantity)*(1/v_conversion_rate);
              END IF;

        --end additions for bug#7675274


              IF ROUND(v_shipped_quantity,2) < ROUND(pr_new.ordered_quantity *(1/ v_conversion_rate),2)  THEN --added *(1/ v_conversion_rate) for bug#7675274 and ROUND for bug #8356692
               RAISE_APPLICATION_ERROR(-20401, 'RMA quantity can NOT be more than shipped quantity');
              END IF;

             /*moved the below code before the    IF v_shipped_quantity < pr_new.ordered_quantity    THEN
       for bug#7675274
              OPEN  c_get_quantity(p_source_document_id      => v_source_document_id,
                                          p_source_document_line_id => v_source_document_line_id );
              FETCH c_get_quantity INTO v_quantity ;
              CLOSE c_get_quantity ;

              IF v_quantity <> 0 THEN
                OPEN requested_qty_uom_cur(v_delivery_detail_id);
                FETCH requested_qty_uom_cur INTO v_requested_quantity_uom;
                CLOSE requested_qty_uom_cur;

                INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                              v_rma_quantity_uom,
                                              pr_new.inventory_item_id,
                                              v_conversion_rate);
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                  INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                v_rma_quantity_uom,
                                                0,
                                                v_conversion_rate);
                  IF NVL(v_conversion_rate, 0) <= 0 THEN
                        v_conversion_rate := 0;
                  END IF;
                END IF;
                v_cor_amount := (pr_new.ordered_quantity / v_quantity)*(1/v_conversion_rate);
              END IF;
        */
 FOR rec_cur_get_picking_tax_lines IN cur_get_picking_tax_lines
                                                   ( p_source_document_id      => v_source_document_id,
                                                     p_source_document_line_id => v_source_document_line_id
                                                    )
              LOOP
                 OPEN cur_chk_rma_tax_lines_exists (  p_line_id => v_line_id                            ,
                                                      p_tax_id  => rec_cur_get_picking_tax_lines.tax_id
                                                    );
                 FETCH cur_chk_rma_tax_lines_exists INTO l_exists;
                 IF cur_chk_rma_tax_lines_exists%NOTFOUND THEN

                    IF rec_cur_get_picking_tax_lines.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', 'TDS', 'CVD')
                      THEN
                        v_round_tax := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);          /*bduvarag for 5989740*/
                        v_round_base := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.base_tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);    /*bduvarag for 5989740*/
                        v_round_func := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.func_tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);    /*bduvarag for 5989740*/
                      ELSE
                        v_round_tax := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.tax_amount), 2);
                        v_round_base := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.base_tax_amount), 2);
                        v_round_func := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.func_tax_amount), 2);
                    END IF;

/**                    OPEN  c_sales_order_cur;
                    FETCH c_sales_order_cur into v_orig_ord_qty;
                    CLOSE c_sales_order_cur;
**/
                    lv_check_vat_type_exists := NULL;

                    OPEN   c_check_Vat_type_Tax_exists (rec_cur_get_picking_tax_lines.tax_type);
                    FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
                    CLOSE  c_check_Vat_type_Tax_exists;

                    IF (rec_cur_get_picking_tax_lines.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS)
                                                                   AND v_excise_flag = 'N') /*bduvarag for bug5989740*/
                       OR
                       (rec_cur_get_picking_tax_lines.tax_type IN ('Sales Tax', 'CST') AND v_sales_flag = 'N')
                       OR
                       ( lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
                    THEN
                      v_round_tax := 0;
                      v_round_base := 0;
                      v_round_func := 0;
                    END IF;

                   INSERT INTO JAI_OM_OE_RMA_TAXES
                      (
                                rma_line_id                                           ,
                                tax_line_no                                           ,
                                tax_id                                                ,
                                tax_rate                                              ,
                                qty_rate                                              ,
                                uom                                                   ,
                                tax_amount                                            ,
                                base_tax_amount                                       ,
                                func_tax_amount                                       ,
                                precedence_1                                          ,
                                precedence_2                                          ,
                                precedence_3                                          ,
                                precedence_4                                          ,
                                precedence_5                                          ,
                                precedence_6                                          ,
                                precedence_7                                          ,
                                precedence_8                                          ,
                                precedence_9                                          ,
                                precedence_10                                          ,
                                delivery_detail_id                                    ,
                                creation_date                                         ,
                                created_by                                            ,
                                last_update_date                                      ,
                                last_updated_by                                       ,
                                last_update_login
                        )
                      VALUES
                      (
                              v_line_id                                             ,
                              rec_cur_get_picking_tax_lines.tax_line_no             ,
                              rec_cur_get_picking_tax_lines.tax_id                  ,
                              rec_cur_get_picking_tax_lines.tax_rate                ,
                              rec_cur_get_picking_tax_lines.qty_rate                ,
                              rec_cur_get_picking_tax_lines.uom                     ,
                              v_round_tax,
                              v_round_base,
                              v_round_func,
                              rec_cur_get_picking_tax_lines.precedence_1            ,
                              rec_cur_get_picking_tax_lines.precedence_2            ,
                              rec_cur_get_picking_tax_lines.precedence_3            ,
                              rec_cur_get_picking_tax_lines.precedence_4            ,
                              rec_cur_get_picking_tax_lines.precedence_5            ,
                              rec_cur_get_picking_tax_lines.precedence_6            ,
                              rec_cur_get_picking_tax_lines.precedence_7            ,
                              rec_cur_get_picking_tax_lines.precedence_8            ,
                              rec_cur_get_picking_tax_lines.precedence_9            ,
                              rec_cur_get_picking_tax_lines.precedence_10            ,
                              rec_cur_get_picking_tax_lines.delivery_detail_id      ,
                              v_creation_date                                       ,
                              v_created_by                                          ,
                              v_last_update_date                                    ,
                              v_last_updated_by                                     ,
                              v_last_update_login
                      );

                   IF rec_cur_get_picking_tax_lines.tax_type <> 'TDS'
                   THEN
                     v_tax_total := NVL(v_tax_total, 0) + v_round_tax;
                   END IF;
                 END IF ;  --IF cur_chk_rma_tax_lines_exists%NOTFOUND
                 CLOSE cur_chk_rma_tax_lines_exists ;
              END LOOP;

              UPDATE JAI_OM_OE_RMA_LINES
                 SET tax_amount =  v_tax_total
              WHERE rma_line_id = v_line_id ;

           -- added by Allen Yang for bug 9666476 28-apr-2010, begin
           -- need to process copying taxes from referenced SO line for non-shippable RMA line whose delivery_detail_id is NULL
           ELSIF NVL(lv_shippable_flag, 'Y') = 'N'
           THEN
             -- added by Allen Yang for bug 9691880 10-May-2010, begin
             -- need to check VAT flag for non-shippable, if the validation fails, then vat taxes amounts should be copied as zero.
             OPEN c_fulfilled_date;
             FETCH c_fulfilled_date INTO v_date_confirmed;
             CLOSE c_fulfilled_date;

             IF (v_vat_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_vat_return_days)
             THEN

                 v_vat_flag := 'Y';
             ELSE
                 v_vat_flag := 'N';
             END IF;
             -- added by Allen Yang for bug 9691880 10-May-2010, end

             IF v_ordered_quantity <> 0
             THEN
               FOR tax_line_rec IN (SELECT tax_line_no,
                                    precedence_1,
                                    precedence_2,
                                    precedence_3,
                                    precedence_4,
                                    precedence_5,
                                    sptl.tax_id,
                                    sptl.tax_rate,
                                    sptl.qty_rate,
                                    uom,
                                    sptl.tax_amount,
                                    nvl(jtc.rounding_factor,0) rounding_factor,
                                    base_tax_amount,
                                    func_tax_amount,
                                    jtc.tax_type ,
                                    precedence_6,
                                    precedence_7,
                                    precedence_8,
                                    precedence_9,
                                    precedence_10
                               FROM JAI_OM_WSH_LINE_TAXES sptl,
                                    JAI_CMN_TAXES_ALL jtc
                              WHERE order_line_id = v_reference_line_id
                                AND jtc.tax_id = sptl.tax_id)
              LOOP
                -- added by Allen Yang for bug 9691880 10-May-2010, begin
                lv_check_vat_type_exists := NULL;

                OPEN   c_check_Vat_type_Tax_exists (tax_line_rec.tax_type);
                FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
                CLOSE  c_check_Vat_type_Tax_exists;

                IF (lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
                THEN
                  v_round_tax := 0;
                  v_round_base := 0;
                  v_round_func := 0;
                ELSE
                  v_round_tax := tax_line_rec.tax_amount;
                  v_round_base := tax_line_rec.base_tax_amount;
                  v_round_func := tax_line_rec.func_tax_amount;
                END IF; -- lv_check_vat_type_exists = 1 AND v_vat_flag = 'N'
                -- added by Allen Yang for bug 9691880 10-May-2010, end

                INSERT INTO JAI_OM_OE_RMA_TAXES
                 (rma_line_id,
                  delivery_detail_id,
                  tax_line_no,
                  precedence_1,
                  precedence_2,
                  precedence_3,
                  precedence_4,
                  precedence_5,
                  tax_id,
                  tax_rate,
                  qty_rate,
                  uom,
                  tax_amount,
                  base_tax_amount,
                  func_tax_amount,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login ,
                  precedence_6,
                  precedence_7,
                  precedence_8,
                  precedence_9,
                  precedence_10)
                VALUES (v_line_id,
                  NULL,  -- delivery_detail_id
                  tax_line_rec.tax_line_no,
                  tax_line_rec.precedence_1,
                  tax_line_rec.precedence_2,
                  tax_line_rec.precedence_3,
                  tax_line_rec.precedence_4,
                  tax_line_rec.precedence_5,
                  tax_line_rec.tax_id,
                  tax_line_rec.tax_rate,
                  tax_line_rec.qty_rate,
                  tax_line_rec.uom,
                  -- modified by Allen Yang for bug 9691880 10-May-2010, begin
                  v_round_tax, --tax_line_rec.tax_amount,
                  v_round_base, --tax_line_rec.base_tax_amount,
                  v_round_func, --tax_line_rec.func_tax_amount,
                  -- modified by Allen Yang for bug 9691880 10-May-2010, end
                  v_creation_date,
                  v_created_by,
                  v_last_update_date,
                  v_last_updated_by,
                  v_last_update_login ,
                  tax_line_rec.precedence_6,
                  tax_line_rec.precedence_7,
                  tax_line_rec.precedence_8,
                  tax_line_rec.precedence_9,
                  tax_line_rec.precedence_10
                );
                END LOOP; -- tax_line_rec IN (SELECT tax_line_no ......
             END IF; --IF v_ordered_quantity <> 0
           -- added by Allen Yang for bug 9666476 28-apr-2010, end

           END IF ;  --IF v_delivery_detail_id IS NOT NULL
           /*
           || Added for bug#5256498, Ends-- bduvarag
           */

        ELSE
          -- Details in picking lines not found . Raise an error message
          CLOSE cur_get_picking_lines;
/*           RAISE_APPLICATION_ERROR (-20001,'No data found in localisation shipping tables, hence copy cannot be done');
       */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'No data found in localisation shipping tables,hence copy cannot be done' ; return ;
        END IF;
        CLOSE cur_get_picking_lines;
      END;

    /*  added by ssumaith - bug# 3972034*/

/*
    ELSIF rtrim(ltrim(v_source_order_category_code)) = 'MIXED' AND ltrim(rtrim(v_line_category_code)) = 'RETURN'
    AND nvl(pr_new.return_context,'$$$') = 'LEGACY' THEN
*/
   /*
   || IF condition modified by aiyer for the bug 5401180
   || Replaced the condition nvl(pr_new.return_context,'$$$') = 'LEGACY' with
   || pr_new.return_context                      IS NULL
   */
    ELSIF rtrim(ltrim(v_source_order_category_code)) = 'MIXED'   AND
          ltrim(rtrim(v_line_category_code))         = 'RETURN'
 --       pr_new.return_context                      IS NULL  commented for bug#7675274
    THEN
   /*End of bug 5401180 */
    -- here need to code the cases where order category code is MIXED and line_category_code is RETURN
    -- this is typically the case where a legacy RMA is copied another legacy RMA
    -- need to insert into JAI_OM_OE_RMA_LINES from the source.

    --added the below if condition for bug#7675274
     IF     pr_new.return_context                      IS NULL
     THEN

    DECLARE

       /* fetch the details of the original RMA order
       */
       CURSOR  c_rma_details(cp_rma_header_id number , cp_rma_line_id number) is
       SELECT  *
       FROM    JAI_OM_OE_RMA_LINES
       WHERE   rma_header_id = cp_rma_header_id
       AND     rma_line_id   = cp_rma_line_id;

       /* get the new order number from oe_order_headers_all*/
       CURSOR  c_rma_number(cp_rma_header_id number) is
       SELECT  order_number
       FROM    oe_order_headers_all
       WHERE   header_id = cp_rma_header_id;

       cv_rma_details C_RMA_DETAILS%ROWTYPE;
       lv_rma_number  OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE;

    BEGIN
    pv_return_code := jai_constants.successful ;

       open   c_rma_details(pr_new.source_document_id , pr_new.source_document_line_id);
       fetch  c_rma_details into cv_rma_details;
       close  c_rma_details;

       open   c_rma_number(pr_new.header_id );
       fetch  c_rma_number into lv_rma_number;
       close  c_rma_number;

       insert into JAI_OM_OE_RMA_LINES
                  (
                    rma_line_id           ,
                    rma_line_number       ,
                    rma_header_id         ,
                    rma_number            ,
                    picking_line_id       ,
                    uom                   ,
                    selling_price         ,
                    quantity              ,
                    tax_category_id       ,
                    tax_amount            ,
                    inventory_item_id     ,
                    received_flag         ,
                    assessable_value      ,
                    creation_date         ,
                    created_by            ,
                    last_update_date      ,
                    last_updated_by       ,
                    last_update_login     ,
                    excise_duty_rate      ,
                    rate_per_unit         ,
                    delivery_detail_id
                  )
       values     (
                    pr_new.line_id          ,
                    pr_new.line_number      ,
                    pr_new.header_id        ,
                    lv_rma_number         ,
                    null                  ,
                    pr_new.order_quantity_uom     ,
                    pr_new.unit_selling_price,
                    pr_new.ordered_quantity,
                    cv_rma_details.tax_category_id ,
                    (cv_rma_details.tax_amount) ,
                    pr_new.inventory_item_id ,
                    cv_rma_details.received_flag,
                    cv_rma_details.assessable_value,
                    sysdate,
                    pr_new.created_by,
                    sysdate,
                    pr_new.last_updated_by,
                    pr_new.last_update_login,
                    cv_rma_details.excise_duty_rate,
                    cv_rma_details.rate_per_unit,
                    null
                  );

      FOR cv_rma_taxes in
      (select *
       from   JAI_OM_OE_RMA_TAXES
       where  rma_line_id = pr_new.source_document_line_id
      )
      Loop
        insert into JAI_OM_OE_RMA_TAXES
        (
         rma_line_id                 ,
         tax_line_no                 ,
         precedence_1                ,
         precedence_2                ,
         precedence_3                ,
         precedence_4                ,
         precedence_5                ,
         tax_id                      ,
         tax_rate                    ,
         qty_rate                    ,
         uom                         ,
         tax_amount                  ,
         base_tax_amount             ,
         func_tax_amount             ,
         creation_date               ,
         created_by                  ,
         last_update_date            ,
         last_updated_by             ,
         last_update_login           ,
         delivery_detail_id      ,
   /*added precedence 6 to 10 for bug#6485212  */
   precedence_6                ,
         precedence_7                ,
         precedence_8                ,
         precedence_9                ,
         precedence_10
        )
        values
        (
         pr_new.line_id,
         cv_rma_taxes.tax_line_no ,
         cv_rma_taxes.precedence_1,
         cv_rma_taxes.precedence_2,
         cv_rma_taxes.precedence_3,
         cv_rma_taxes.precedence_4,
         cv_rma_taxes.precedence_5,
         cv_rma_taxes.tax_id      ,
         cv_rma_taxes.tax_rate,
         cv_rma_taxes.qty_rate,
         cv_rma_taxes.uom,
         (cv_rma_taxes.tax_amount)  ,
         cv_rma_taxes.base_tax_amount,
         cv_rma_taxes.func_Tax_amount,
         pr_new.creation_date,
         pr_new.created_by,
         pr_new.last_update_Date,
         pr_new.last_updated_by ,
         pr_new.last_update_login,
         cv_rma_taxes.delivery_detail_id,
  /*added precedence 6 to 10 for bug#6485212  */
   cv_rma_taxes.precedence_6,
         cv_rma_taxes.precedence_7,
         cv_rma_taxes.precedence_8,
         cv_rma_taxes.precedence_9,
         cv_rma_taxes.precedence_10
        );

      end Loop;

    end;
     --start additions for bug#7675274
 elsif pr_new.return_context = 'ORDER' THEN --added the elif condition on 17th dec based on the review comments by Rajnish,7675274
    -- here need to code the cases where order catego
   --this script will execute only for the return order context.
  DECLARE


       /* get the new order number from oe_order_headers_all*/
       CURSOR  c_rma_number(cp_rma_header_id number) is
       SELECT  order_number
       FROM    oe_order_headers_all
       WHERE   header_id = cp_rma_header_id;

       -- get the details from JAI_OM_WSH_LINES_ALL table
         CURSOR cur_get_picking_lines(
                                                  p_source_document_id        OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_ID%TYPE     ,
                                                  p_source_document_line_id   OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE
                                               )
         IS
        SELECT
                 pl.inventory_item_id       inventory_item_id    ,
                 pl.unit_code               unit_code            ,
                 sum(pl.quantity )          quantity             ,
                 pl.tax_category_id         tax_category_id      ,
                 pl.selling_price           selling_price        ,
                 sum(pl.tax_amount)         tax_amount           ,
                 min(pl.delivery_detail_id) delivery_detail_id
         FROM
                 JAI_OM_WSH_LINES_ALL pl
         WHERE
                 pl.order_header_id       = p_source_document_id       AND
                 pl.order_line_id         = p_source_document_line_id
         GROUP BY
            pl.inventory_item_id      ,
            pl.unit_code              ,
            pl.selling_price        ,
            pl.tax_category_id        ;

      cursor c_sales_order_cur is
                  select quantity,service_type_code
                  from JAI_OM_OE_SO_LINES
                  where line_id=v_reference_line_id;


         CURSOR cur_rma_entry_line_exists ( p_line_id   OE_ORDER_LINES_ALL.LINE_ID%TYPE   ,
                                            p_header_id OE_ORDER_LINES_ALL.HEADER_ID%TYPE
                                          )
         IS
         SELECT
                     'X'
         FROM
                     JAI_OM_OE_RMA_LINES
         WHERE
                     rma_line_id   = p_line_id   AND
                     rma_header_id = p_header_id ;

         l_exists    VARCHAR2(1);

        rec_cur_get_picking_lines  cur_get_picking_lines%ROWTYPE;

        CURSOR cur_get_picking_tax_lines (
                                              p_source_document_id        JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE    ,
                                              p_source_document_line_id   JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE
                                          )
         IS
          SELECT
                  ptl.tax_line_no                  tax_line_no      ,
                  ptl.tax_id                       tax_id           ,
                  ptl.tax_rate                     tax_rate         ,
                  ptl.qty_rate                     qty_rate         ,
                  ptl.uom                          uom              ,
                  ptl.precedence_1                 precedence_1     ,
                  ptl.precedence_2                 precedence_2     ,
                  ptl.precedence_3                 precedence_3     ,
                  ptl.precedence_4                 precedence_4     ,
                  ptl.precedence_5                 precedence_5     ,
                  ptl.precedence_6                 precedence_6     ,
                  ptl.precedence_7                 precedence_7     ,
                  ptl.precedence_8                 precedence_8     ,
                  ptl.precedence_9                 precedence_9     ,
                  ptl.precedence_10                precedence_10    ,
                  jtc.tax_type                     tax_type         ,
      nvl(jtc.rounding_factor,0)       rounding_factor  ,         /*bduvarag for the bug#6071813*/
                  SUM (ptl.tax_amount)             tax_amount       ,
                  SUM (ptl.base_tax_amount)        base_tax_amount  ,
                  SUM (ptl.func_tax_amount)        func_tax_amount  ,
                  MIN (ptl.delivery_detail_id)     delivery_detail_id
          FROM
                  JAI_OM_WSH_LINES_ALL          pl    ,
                  JAI_OM_WSH_LINE_TAXES     ptl    ,
                  JAI_CMN_TAXES_ALL                jtc
          WHERE
                  ptl.delivery_detail_id = pl.delivery_detail_id     AND
                  pl.order_header_id     = p_source_document_id      AND
                  pl.order_line_id       = p_source_document_line_id AND
                  jtc.tax_id             = ptl.tax_id
          GROUP by    ptl.tax_line_no                       ,
                      ptl.tax_id                            ,
                      ptl.tax_rate                          ,
                      ptl.qty_rate                          ,
                      ptl.uom                               ,
                      precedence_1                      ,
                      precedence_2                      ,
                      precedence_3                      ,
                      precedence_4                      ,
                      precedence_5                      ,
                      precedence_6                      ,
                      precedence_7                      ,
                      precedence_8                      ,
                      precedence_9                      ,
                      precedence_10                     ,
                      jtc.tax_type      ,
          nvl(jtc.rounding_factor,0) ;/*bduvarag for the bug#6071813*/

 CURSOR cur_chk_rma_tax_lines_exists(p_line_id JAI_OM_OE_RMA_TAXES.RMA_LINE_ID%TYPE ,
                                            p_tax_id  JAI_OM_OE_RMA_TAXES.TAX_ID%TYPE)
        IS
        SELECT
                  'X'
        FROM
                  JAI_OM_OE_RMA_TAXES
        WHERE
                  rma_line_id     = p_line_id     AND
                  tax_id          = p_tax_id ;

        CURSOR c_get_quantity(
                              p_source_document_id        JAI_OM_WSH_LINES_ALL.order_header_id%type    ,
                              p_source_document_line_id   JAI_OM_WSH_LINES_ALL.order_line_id%type
                              )
        IS
        SELECT
                quantity
        FROM
                JAI_OM_WSH_LINES_ALL          pl    ,
                JAI_OM_WSH_LINE_TAXES     ptl
        WHERE
                ptl.delivery_detail_id = pl.delivery_detail_id     AND
                pl.order_header_id     = p_source_document_id      AND
                pl.order_line_id       = p_source_document_line_id ;

        CURSOR requested_qty_uom_cur(p_delivery_detail_id NUMBER)
        IS
        SELECT
               requested_quantity_uom
        FROM
               wsh_delivery_details
        WHERE
               delivery_detail_id = p_delivery_detail_id;

        CURSOR c_check_vat_type_tax_exists (cp_tax_type VARCHAR2)
        IS
        SELECT
               1
        FROM
               jai_regime_tax_types_v
        WHERE
               regime_code = jai_constants.vat_regime
        AND    tax_type    = cp_tax_type;

  /*Added by Bgowrava for Bug#6126581 */
        cursor cur_get_ddetail_id(p_source_document_id OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_ID%TYPE , p_source_document_line_id OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE) is
        select delivery_detail_id from JAI_OM_OE_RMA_LINES
        where rma_header_id     = p_source_document_id      AND
              rma_line_id       = p_source_document_line_id;

        v_ddetail_id JAI_OM_OE_RMA_LINES.delivery_detail_id%type;
        /* END, Bug#6126581*/

     /*Added a parameter p_ddetail_id in the below cursor for Bug#6126581 */
        CURSOR c_get_detail_id(p_ddetail_id JAI_OM_OE_RMA_LINES.delivery_detail_id%type)
        IS
        SELECT
               wdd.delivery_detail_id,
               wnd.confirm_date
        FROM
              wsh_delivery_details wdd,
              wsh_delivery_assignments wda,
              wsh_new_deliveries wnd
        WHERE
            wdd.delivery_detail_id = p_ddetail_id  AND  -- Added p_ddetail_id by bgowrava for bug#6126581
        wda.delivery_detail_id = wdd.delivery_detail_id AND
        wnd.delivery_id = wda.delivery_id ;

         CURSOR c_get_days_flags
         IS
         SELECT
                excise_return_days,
                sales_return_days,
                vat_return_days ,
                nvl(manufacturing,'N') manufacturing,
                nvl(trading,'N') trading
          FROM
               JAI_CMN_INVENTORY_ORGS
         WHERE
               organization_id = pr_new.ship_from_org_id
           AND location_id = 0 ;

        CURSOR c_ordered_date
         IS
         SELECT
               ordered_date
          FROM
               oe_order_headers_all
         WHERE
               header_id = pr_new.header_id ;

         -- added by Allen Yang for bug 9691880 10-May-2010, begin
         CURSOR c_fulfilled_date
         IS
         SELECT
           CREATION_DATE
         FROM
           JAI_OM_WSH_LINES_ALL
         WHERE ORDER_LINE_ID = v_reference_line_id
           AND SHIPPABLE_FLAG = 'N';
         -- added by Allen Yang for bug 9691880 10-May-2010, end

         CURSOR c_get_ship_qty(cp_delivery_detail_id wsh_delivery_details.delivery_detail_id%TYPE)
         IS
         SELECT
                SUM(wdd.shipped_quantity) qty
           FROM
                wsh_delivery_details wdd
          WHERE
                wdd.delivery_detail_id = cp_delivery_detail_id
            AND wdd.inventory_item_id = pr_new.inventory_item_id ;



    CURSOR c_so_tax_amount (p_tax_id JAI_CMN_TAXES_ALL.tax_id%type)
        IS
        SELECT
               tax_amount
        FROM
               JAI_OM_OE_SO_TAXES
        WHERE
               line_id = pr_new.reference_line_id
        AND    tax_id = p_tax_id ;

        lv_check_vat_type_exists VARCHAR2(1);
        v_date_ordered        DATE;
        v_date_confirmed      DATE;
        v_delivery_detail_id  JAI_OM_WSH_LINES_ALL.delivery_detail_id % TYPE;
        v_excise_return_days  JAI_CMN_INVENTORY_ORGS.excise_return_days % TYPE;
        v_sales_return_days   JAI_CMN_INVENTORY_ORGS.sales_return_days % TYPE;
        v_vat_return_days     JAI_CMN_INVENTORY_ORGS.vat_return_days % TYPE;
        v_excise_flag         VARCHAR2(1);
        v_sales_flag          VARCHAR2(1);
        v_vat_flag            VARCHAR2(1);
        v_round_tax           NUMBER;
        v_round_base          NUMBER;
        v_round_func          NUMBER;
        v_tax_total           NUMBER;
        v_manufacturing       JAI_CMN_INVENTORY_ORGS.manufacturing%type;
        v_trading             JAI_CMN_INVENTORY_ORGS.trading%type;
        v_shipped_quantity    wsh_delivery_details.shipped_quantity % TYPE;
        v_quantity            JAI_OM_WSH_LINES_ALL.quantity % TYPE;
        v_requested_quantity_uom VARCHAR2(3);
        v_conversion_rate     NUMBER  := 0;
        v_cor_amount          JAI_OM_WSH_LINES_ALL.tax_amount % TYPE;
        v_orig_ord_qty  Number;
        v_so_tax_amount Number;
        v_rma_quantity_uom    VARCHAR2(3);
        /*
        || Added for bug#5256498, Ends-- bduvarag
        */


    BEGIN
      pv_return_code := jai_constants.successful ;
        v_rma_quantity_uom   := pr_new.order_quantity_uom;

      OPEN c_sales_order_cur;
        FETCH c_sales_order_cur into v_orig_ord_qty, v_service_type_code;
        CLOSE c_sales_order_cur;

         OPEN cur_get_picking_lines  (  p_source_document_id       => v_source_document_id      ,
                                       p_source_document_line_id  => v_source_document_line_id
                                        );
        FETCH cur_get_picking_lines INTO rec_cur_get_picking_lines;
        IF cur_get_picking_lines%FOUND THEN

         OPEN cur_rma_entry_line_exists ( p_line_id   => v_line_id   ,
                                            p_header_id => v_header_id
                                           );
           FETCH cur_rma_entry_line_exists INTO l_exists;
           /*
             IF a record does not exists with the newline_id and header_id
             only then go ahead with the insert
           */
           IF cur_rma_entry_line_exists%NOTFOUND THEN

              INSERT INTO JAI_OM_OE_RMA_LINES
              (
                       rma_line_number                                          ,
                       rma_line_id                                              ,
                       rma_header_id                                            ,
                       rma_number                                               ,
                       inventory_item_id                                        ,
                       uom                                                      ,
                       quantity                                                 ,
                       tax_category_id                                          ,
                       selling_price                                            ,
                       tax_amount                                               ,
                       delivery_detail_id                                       ,
                       creation_date                                            ,
                       created_by                                               ,
                       last_update_date                                         ,
                       last_updated_by                                          ,
                       last_update_login,service_type_code
               )
               VALUES
               (
                       v_line_number                                            ,
                       v_line_id                                                ,
                       v_header_id                                              ,
                       v_order_number                                           ,
                       rec_cur_get_picking_lines.inventory_item_id     ,
                       rec_cur_get_picking_lines.unit_code             ,
                       rec_cur_get_picking_lines.quantity              ,
                       rec_cur_get_picking_lines.tax_category_id       ,
                       rec_cur_get_picking_lines.selling_price         ,
                       rec_cur_get_picking_lines.tax_amount            ,
                       rec_cur_get_picking_lines.delivery_detail_id   ,
                       v_creation_date                                          ,
                       v_created_by                                             ,
                       v_last_update_date                                       ,
                       v_last_updated_by                                        ,
                       v_last_update_login,v_service_type_code
               );
            END IF;
            CLOSE cur_rma_entry_line_exists;


      open cur_get_ddetail_id(p_source_document_id => v_header_id,
                                                   p_source_document_line_id  => v_line_id);
            fetch cur_get_ddetail_id into v_ddetail_id ;
            close cur_get_ddetail_id;

             OPEN c_get_detail_id(v_ddetail_id) ;
            FETCH c_get_detail_id INTO v_delivery_detail_id, v_date_confirmed ;
            CLOSE c_get_detail_id ;

            -- added by Allen Yang for bug 9691880 10-May-2010, begin
            /* moved code from below IF condition to here to check VAT return days both for
               shippable and non-shippalbe lines. */
            OPEN c_get_days_flags ;
            FETCH c_get_days_flags INTO  v_excise_return_days,
                                         v_sales_return_days ,
                                         v_vat_return_days   ,
                                         v_manufacturing     ,
                                         v_trading           ;
            CLOSE c_get_days_flags ;

            OPEN c_ordered_date ;
            FETCH c_ordered_date INTO v_date_ordered ;
            CLOSE c_ordered_date ;
            -- added by Allen Yang for bug 9691880 10-May-2010, end

 IF v_delivery_detail_id IS NOT NULL
            THEN
              /* -- commented by Allen Yang for bug 9691880 10-May-2010, begin
              OPEN c_get_days_flags ;
              FETCH c_get_days_flags INTO  v_excise_return_days,
                                           v_sales_return_days ,
                                           v_vat_return_days   ,
                                           v_manufacturing     ,
                                           v_trading           ;
              CLOSE c_get_days_flags ;

              OPEN c_ordered_date ;
              FETCH c_ordered_date INTO v_date_ordered ;
              CLOSE c_ordered_date ;
              -- commented by Allen Yang for bug 9691880 10-May-2010, end */

              --Uncommented the following and modified the IF condition for bug#7316234

              IF (v_excise_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_excise_return_days)
              THEN
                 v_excise_flag := 'Y';
              ELSE
                 v_excise_flag := 'N';
              END IF;

              --Uncommented the following and modified the IF condition for bug#7316234

              IF (v_sales_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_sales_return_days)
              THEN
                 v_sales_flag := 'Y';
              ELSE
                 v_sales_flag := 'N';
              END IF;

              ---modified the IF condition for bug#7316234
              IF (v_vat_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_vat_return_days)
              THEN

                 v_vat_flag := 'Y';
              ELSE
                 v_vat_flag := 'N';
              END IF;

               --start additions for bug#7675274
         OPEN  c_get_ship_qty (v_delivery_detail_id);
              FETCH c_get_ship_qty INTO v_shipped_quantity ;
              CLOSE c_get_ship_qty ;

         OPEN  c_get_quantity(p_source_document_id      => v_source_document_id,
                                          p_source_document_line_id => v_source_document_line_id );
              FETCH c_get_quantity INTO v_quantity ;
              CLOSE c_get_quantity ;

              IF v_quantity <> 0 THEN
                OPEN requested_qty_uom_cur(v_delivery_detail_id);
                FETCH requested_qty_uom_cur INTO v_requested_quantity_uom;
                CLOSE requested_qty_uom_cur;

                INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                              v_rma_quantity_uom,
                                              pr_new.inventory_item_id,
                                              v_conversion_rate);
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                  INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                v_rma_quantity_uom,
                                                0,
                                                v_conversion_rate);
                  IF NVL(v_conversion_rate, 0) <= 0 THEN
                         v_conversion_rate := 1; --Changed v_conversion_rate from 0 to 1, so that divide by zero error does not occur. --bug 8356692
                  END IF;
                END IF;
                v_cor_amount := (pr_new.ordered_quantity / v_quantity)*(1/v_conversion_rate);
              END IF;
         --end additions for bug#7675274


              IF round(v_shipped_quantity,2) <  round(pr_new.ordered_quantity*(1/ v_conversion_rate),2)   THEN --added *(1/ v_conversion_rate) for bug#7675274  and round for bug 8356692
               RAISE_APPLICATION_ERROR(-20401, 'RMA quantity can NOT be more than shipped quantity');

              END IF;

              /*moved the below code to before  if v_shipped_quantity < pr_new.ordered_quantity    THEN
        for bug#7675274
        OPEN  c_get_quantity(p_source_document_id      => v_source_document_id,
                                          p_source_document_line_id => v_source_document_line_id );
              FETCH c_get_quantity INTO v_quantity ;
              CLOSE c_get_quantity ;

              IF v_quantity <> 0 THEN
                OPEN requested_qty_uom_cur(v_delivery_detail_id);
                FETCH requested_qty_uom_cur INTO v_requested_quantity_uom;
                CLOSE requested_qty_uom_cur;

                INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                              v_rma_quantity_uom,
                                              pr_new.inventory_item_id,
                                              v_conversion_rate);
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                  INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                v_rma_quantity_uom,
                                                0,
                                                v_conversion_rate);
                  IF NVL(v_conversion_rate, 0) <= 0 THEN
                        v_conversion_rate := 0;
                  END IF;
                END IF;
                v_cor_amount := (pr_new.ordered_quantity / v_quantity)*(1/v_conversion_rate);
              END IF;
        */

              FOR rec_cur_get_picking_tax_lines IN cur_get_picking_tax_lines
                                                   ( p_source_document_id      => v_source_document_id,
                                                     p_source_document_line_id => v_source_document_line_id
                                                    )
              LOOP
                 OPEN cur_chk_rma_tax_lines_exists (  p_line_id => v_line_id                            ,
                                                      p_tax_id  => rec_cur_get_picking_tax_lines.tax_id
                                                    );
                 FETCH cur_chk_rma_tax_lines_exists INTO l_exists;
                 IF cur_chk_rma_tax_lines_exists%NOTFOUND THEN

                    IF rec_cur_get_picking_tax_lines.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', 'TDS', 'CVD')
                      THEN
                        v_round_tax := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);          /*bduvarag for 5989740*/
                        v_round_base := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.base_tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);    /*bduvarag for 5989740*/
                        v_round_func := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.func_tax_amount),rec_cur_get_picking_tax_lines.rounding_factor);    /*bduvarag for 5989740*/
                      ELSE
                        v_round_tax := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.tax_amount), 2);
                        v_round_base := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.base_tax_amount), 2);
                        v_round_func := ROUND((v_cor_amount * rec_cur_get_picking_tax_lines.func_tax_amount), 2);
                    END IF;

/**                    OPEN  c_sales_order_cur;
                    FETCH c_sales_order_cur into v_orig_ord_qty;
                    CLOSE c_sales_order_cur;
**/
                    lv_check_vat_type_exists := NULL;

                    OPEN   c_check_Vat_type_Tax_exists (rec_cur_get_picking_tax_lines.tax_type);
                    FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
                    CLOSE  c_check_Vat_type_Tax_exists;

                    IF (rec_cur_get_picking_tax_lines.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS)
                                                                   AND v_excise_flag = 'N') /*bduvarag for bug5989740*/
                       OR
                       (rec_cur_get_picking_tax_lines.tax_type IN ('Sales Tax', 'CST') AND v_sales_flag = 'N')
                       OR
                       ( lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
                    THEN
                      v_round_tax := 0;
                      v_round_base := 0;
                      v_round_func := 0;
                    END IF;


                   INSERT INTO JAI_OM_OE_RMA_TAXES
                      (
                                rma_line_id                                           ,
                                tax_line_no                                           ,
                                tax_id                                                ,
                                tax_rate                                              ,
                                qty_rate                                              ,
                                uom                                                   ,
                                tax_amount                                            ,
                                base_tax_amount                                       ,
                                func_tax_amount                                       ,
                                precedence_1                                          ,
                                precedence_2                                          ,
                                precedence_3                                          ,
                                precedence_4                                          ,
                                precedence_5                                          ,
                                precedence_6                                          ,
                                precedence_7                                          ,
                                precedence_8                                          ,
                                precedence_9                                          ,
                                precedence_10                                          ,
                                delivery_detail_id                                    ,
                                creation_date                                         ,
                                created_by                                            ,
                                last_update_date                                      ,
                                last_updated_by                                       ,
                                last_update_login
                        )
                      VALUES
                      (
                              v_line_id                                             ,
                              rec_cur_get_picking_tax_lines.tax_line_no             ,
                              rec_cur_get_picking_tax_lines.tax_id                  ,
                              rec_cur_get_picking_tax_lines.tax_rate                ,
                              rec_cur_get_picking_tax_lines.qty_rate                ,
                              rec_cur_get_picking_tax_lines.uom                     ,
                              v_round_tax,
                              v_round_base,
                              v_round_func,
                              rec_cur_get_picking_tax_lines.precedence_1            ,
                              rec_cur_get_picking_tax_lines.precedence_2            ,
                              rec_cur_get_picking_tax_lines.precedence_3            ,
                              rec_cur_get_picking_tax_lines.precedence_4            ,
                              rec_cur_get_picking_tax_lines.precedence_5            ,
                              rec_cur_get_picking_tax_lines.precedence_6            ,
                              rec_cur_get_picking_tax_lines.precedence_7            ,
                              rec_cur_get_picking_tax_lines.precedence_8            ,
                              rec_cur_get_picking_tax_lines.precedence_9            ,
                              rec_cur_get_picking_tax_lines.precedence_10            ,
                              rec_cur_get_picking_tax_lines.delivery_detail_id      ,
                              v_creation_date                                       ,
                              v_created_by                                          ,
                              v_last_update_date                                    ,
                              v_last_updated_by                                     ,
                              v_last_update_login
                      );

                   IF rec_cur_get_picking_tax_lines.tax_type <> 'TDS'
                   THEN
                     v_tax_total := NVL(v_tax_total, 0) + v_round_tax;
                   END IF;
                 END IF ;  --IF cur_chk_rma_tax_lines_exists%NOTFOUND
                 CLOSE cur_chk_rma_tax_lines_exists ;
              END LOOP;

              UPDATE JAI_OM_OE_RMA_LINES
                 SET tax_amount =  v_tax_total
              WHERE rma_line_id = v_line_id ;

           -- added by Allen Yang for bug 9691880 07-MAY-2010, begin
           -- need to process copying taxes from referenced SO line for non-shippable RMA line whose delivery_detail_id is NULL
           ELSIF NVL(lv_shippable_flag, 'Y') = 'N'
           THEN
             -- should check VAT return date, if the validation fails, then vat amounts should be copied as zero.
             OPEN c_fulfilled_date;
             FETCH c_fulfilled_date INTO v_date_confirmed;
             CLOSE c_fulfilled_date;

             IF (v_vat_return_days IS NULL
                 OR
                 (v_date_ordered - v_date_confirmed) <= v_vat_return_days)
             THEN
                 v_vat_flag := 'Y';
             ELSE
                 v_vat_flag := 'N';
             END IF; -- v_vat_return_days IS NULL OR .....

             IF v_ordered_quantity <> 0
             THEN
               FOR tax_line_rec IN (SELECT tax_line_no,
                                    precedence_1,
                                    precedence_2,
                                    precedence_3,
                                    precedence_4,
                                    precedence_5,
                                    sptl.tax_id,
                                    sptl.tax_rate,
                                    sptl.qty_rate,
                                    uom,
                                    sptl.tax_amount,
                                    nvl(jtc.rounding_factor,0) rounding_factor,
                                    base_tax_amount,
                                    func_tax_amount,
                                    jtc.tax_type ,
                                    precedence_6,
                                    precedence_7,
                                    precedence_8,
                                    precedence_9,
                                    precedence_10
                               FROM JAI_OM_WSH_LINE_TAXES sptl,
                                    JAI_CMN_TAXES_ALL jtc
                              WHERE order_line_id = v_reference_line_id
                                AND jtc.tax_id = sptl.tax_id)
              LOOP
                lv_check_vat_type_exists := NULL;

                OPEN   c_check_Vat_type_Tax_exists (tax_line_rec.tax_type);
                FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
                CLOSE  c_check_Vat_type_Tax_exists;

                IF (lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
                THEN
                  v_round_tax := 0;
                  v_round_base := 0;
                  v_round_func := 0;
                ELSE
                  v_round_tax := tax_line_rec.tax_amount;
                  v_round_base := tax_line_rec.base_tax_amount;
                  v_round_func := tax_line_rec.func_tax_amount;
                END IF; -- lv_check_vat_type_exists = 1 AND v_vat_flag = 'N'

                INSERT INTO JAI_OM_OE_RMA_TAXES
                 (rma_line_id,
                  delivery_detail_id,
                  tax_line_no,
                  precedence_1,
                  precedence_2,
                  precedence_3,
                  precedence_4,
                  precedence_5,
                  tax_id,
                  tax_rate,
                  qty_rate,
                  uom,
                  tax_amount,
                  base_tax_amount,
                  func_tax_amount,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login ,
                  precedence_6,
                  precedence_7,
                  precedence_8,
                  precedence_9,
                  precedence_10)
                VALUES (v_line_id,
                  NULL,  -- delivery_detail_id
                  tax_line_rec.tax_line_no,
                  tax_line_rec.precedence_1,
                  tax_line_rec.precedence_2,
                  tax_line_rec.precedence_3,
                  tax_line_rec.precedence_4,
                  tax_line_rec.precedence_5,
                  tax_line_rec.tax_id,
                  tax_line_rec.tax_rate,
                  tax_line_rec.qty_rate,
                  tax_line_rec.uom,
                  v_round_tax,  --tax_line_rec.tax_amount,
                  v_round_base, --tax_line_rec.base_tax_amount,
                  v_round_func, --tax_line_rec.func_tax_amount,
                  v_creation_date,
                  v_created_by,
                  v_last_update_date,
                  v_last_updated_by,
                  v_last_update_login ,
                  tax_line_rec.precedence_6,
                  tax_line_rec.precedence_7,
                  tax_line_rec.precedence_8,
                  tax_line_rec.precedence_9,
                  tax_line_rec.precedence_10
                );
                END LOOP; -- tax_line_rec IN (SELECT tax_line_no ......
             END IF; --IF v_ordered_quantity <> 0
           -- added by Allen Yang for bug 9691880 07-MAY-2010, end

         END IF ;  --IF v_delivery_detail_id IS NOT NULL
           /*
           || Added for bug#5256498, Ends-- bduvarag
           */

        ELSE
          -- Details in picking lines not found . Raise an error message
          CLOSE cur_get_picking_lines;
/*           RAISE_APPLICATION_ERROR (-20001,'No data found in localisation shipping tables, hence copy cannot be done');
       */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'No data found in localisation shipping tables,hence copy cannot be done' ; return ;
        END IF;
        CLOSE cur_get_picking_lines;
 end;


end if;--endif return_context<>'LEGACY'--bug#7675274
--end additions for bug#7675274


    ELSIF  v_source_order_category_code = 'RETURN' AND v_line_category_code = 'RETURN' THEN
         -- Raise an Error
/*          RAISE_APPLICATION_ERROR (-20001,'Copying of Return Order to Return Order is not currently supported with India Localization Taxes');
       */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Copying of Return Order to Return Order is not currently supported with India Localization Taxes' ; return ;
    END IF;
     END IF;

   /*********************** Tax line computation starts from here ***************************/
    /*
      This code has been added by Arun Iyer for the fix of the bug #2798930.
      Made if condition more explicit for Tax lines computation in case of ORDER to ORDER.
    */
    /*********************  Order TO Order tax lines computation **************************/

    IF v_source_order_category_code = 'ORDER' AND v_line_category_code = 'ORDER' THEN
       OPEN Get_So_Tax_Lines_Count_Cur(v_source_document_id, v_source_document_line_id);
       FETCH Get_So_Tax_Lines_Count_Cur INTO v_so_tax_lines_count;
       CLOSE Get_So_Tax_Lines_Count_Cur;

      IF NVL(v_so_tax_lines_count,0)>0 THEN
          l_tax_lines_exist := 'TRUE' ;
         FOR Rec IN So_Tax_Lines_Cur(V_SOURCE_DOCUMENT_ID, V_SOURCE_DOCUMENT_LINE_ID)
          LOOP
           --code to check the existing line in table JAI_OM_OE_SO_TAXES for bug #2519043
             SELECT COUNT(1) INTO v_tax_line_count
             FROM JAI_OM_OE_SO_TAXES
             WHERE line_id = v_line_id
             AND tax_id = rec.tax_id ;

             IF v_tax_line_count = 0 THEN


             /*
             || call to the ja_in_calc_Taxes_ato would do the trick thru re-calculating the taxes.
             */

             /*
             || Start additions by bgowrava for forward porting bug#4895477 - Copy Order
             */


                INSERT INTO JAI_OM_OE_SO_TAXES (
                                header_id, line_id, tax_line_no, tax_id,
                                tax_rate, qty_rate, uom, precedence_1,
                                precedence_2, precedence_3, precedence_4, precedence_5,
        /*precedence 6 to 10 added by csahoo for bug#6485212 */
        precedence_6, precedence_7, precedence_8, precedence_9  ,precedence_10,
                                tax_amount, base_tax_amount, func_tax_amount, creation_date,
                                created_by, last_update_date, last_updated_by, last_update_login,
                                tax_category_id                       -- cbabu for EnhancementBug# 2427465
                ) VALUES (
                                v_header_id, v_line_id, rec.tax_line_no, rec.tax_id,
                                rec.tax_rate, rec.qty_rate, rec.uom, rec.precedence_1,
                                rec.precedence_2, rec.precedence_3, rec.precedence_4, rec.precedence_5,
        /*precedence 6 to 10 added by csahoo for bug#6485212 */
        rec.precedence_6,rec.precedence_7, rec.precedence_8, rec.precedence_9, rec.precedence_10,
                                rec.tax_amount, rec.base_tax_amount, rec.func_tax_amount, v_creation_date,
                                v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login,
                                rec.tax_category_id                   -- cbabu for EnhancementBug# 2427465
                );


             END IF;
         END LOOP; -- FOR Rec IN So_Tax_Lines_Cur(V_SOURCE_DOCUMENT_ID, V_SOURCE_DOCUMENT_LINE_ID)

         /* moved this call from inside above loop to here by bgowrava for forward porting bug#5554420 */
         OPEN  get_copy_order_line(pr_new.header_id , pr_new.line_id);
         FETCH get_copy_order_line INTO r_get_copy_order_line;
         CLOSE get_copy_order_line;

         /*
         || The variable r_get_copy_order_line has the details of the current line from JAI_OM_OE_SO_LINES table
         */

       -- added a call to the procedure ja_in_calc_taxes_ato - bgowrava for forward porting bug#4895477 so that tax recalculation can happen.

       -- added by Allen Yang for bug #9722577 27-May-2010, begin
       --------------------------------------------------------------------------------------
       l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr( p_org_id  => v_operating_id );
       v_set_of_books_id := l_func_curr_det.ledger_id;
       v_converted_rate :=jai_cmn_utils_pkg.currency_conversion( v_set_of_books_id
                                                               , v_currency_code
                                                               , v_conv_date
                                                               , v_conv_type_code
                                                               , v_conv_rate );
       --------------------------------------------------------------------------------------
       -- added by Allen Yang for bug #9722577 27-May-2010, end

            jai_om_tax_pkg.calculate_ato_taxes
            (
            'OE_LINES_UPDATE',NULL,pr_new.header_id , pr_new.line_id ,
            r_get_copy_order_line.assessable_value * (pr_new.ordered_quantity) ,
            r_get_copy_order_line.line_amount ,
            v_converted_rate,pr_new.inventory_item_id,pr_new.ordered_quantity , pr_new.ordered_quantity, pr_new.pricing_quantity_uom,
            NULL,NULL,NULL,NULL,pr_new.last_update_date,pr_new.last_updated_by,pr_new.last_update_login , r_get_copy_order_line.vat_assessable_value
            );


            update JAI_OM_OE_SO_LINES
            set    tax_amount      =  NVL(r_get_copy_order_line.line_amount,0) ,
              line_tot_amount =  line_amount +  NVL(r_get_copy_order_line.line_amount,0),
              vat_assessable_Value = r_get_copy_order_line.vat_assessable_value
            where  header_id       = pr_new.header_id
            and    line_id         = pr_new.line_id;

        -- ends here  bug# 4895477

       END IF ; -- End of tax lines_count if statement
    /*
      This code has been added by Arun Iyer for the fix of the bug #2820380
      Made if condition more explicit for Tax lines computation in case of RETURN to ORDER.
    */

    /*********************  Return TO Order tax lines computation **************************/

    ELSIF v_source_order_category_code = 'RETURN' AND v_line_category_code = 'ORDER' THEN
       DECLARE
         /*
           Added by aiyer for the bug # #2798930.
           Get the rma trax lines detail from the table JAI_OM_OE_RMA_TAXES
         */
         CURSOR cur_get_JAI_OM_OE_RMA_TAXES (p_line_id OE_ORDER_LINES_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE)
         IS
         SELECT
                   tax_line_no        ,
                   tax_id             ,
                   tax_rate           ,
                   qty_rate           ,
                   uom                ,
                   precedence_1       ,
                   precedence_2       ,
                   precedence_3       ,
                   precedence_4       ,
                   precedence_5       ,
       /*precedence 6 to 10 added for bug#6485212 */
       precedence_6       ,
                   precedence_7       ,
                   precedence_8       ,
                   precedence_9       ,
                   precedence_10       ,
                   tax_amount         ,
                   base_tax_amount    ,
                   func_tax_amount
         FROM
                   JAI_OM_OE_RMA_TAXES
         WHERE
                   rma_line_id = p_line_id ;


         /*
           Added by aiyer for the bug # #2798930.
           code to check whether a record exists in the table JAI_OM_OE_SO_TAXES for a given line_id and tax_id.
         */
        CURSOR cur_chk_tax_lines_exists ( p_line_id1 OE_ORDER_LINES_ALL.LINE_ID%TYPE ,
                                          p_tax_id   JAI_OM_OE_SO_TAXES.TAX_ID%TYPE
                                        )
        IS
        SELECT
                   'X'
        FROM
                   JAI_OM_OE_SO_TAXES
        WHERE
                   line_id = p_line_id1        AND
                   tax_id  = p_tax_id;

        rec_get_rma_tax_lines      cur_get_JAI_OM_OE_RMA_TAXES%ROWTYPE;
        l_exists                   VARCHAR2(1);

        BEGIN
    pv_return_code := jai_constants.successful ;

          FOR rec_get_rma_tax_lines in cur_get_JAI_OM_OE_RMA_TAXES ( p_line_id => v_source_document_line_id )
          loop
             l_tax_lines_exist := 'TRUE' ;
             OPEN cur_chk_tax_lines_exists ( p_line_id1 => v_line_id                         ,
                                             p_tax_id   => rec_get_rma_tax_lines.tax_id
                                           );
             FETCH cur_chk_tax_lines_exists  INTO l_exists;
             IF cur_chk_tax_lines_exists%NOTFOUND THEN
                -- Insert into JAI_OM_OE_SO_LINES

                 INSERT INTO JAI_OM_OE_SO_TAXES (
                                                     header_id                               ,
                                                     line_id                                 ,
                                                     tax_line_no                             ,
                                                     tax_id                                  ,
                                                     tax_rate                                ,
                                                     qty_rate                                ,
                                                     uom                                     ,
                                                     precedence_1                            ,
                                                     precedence_2                            ,
                                                     precedence_3                            ,
                                                     precedence_4                            ,
                                                     precedence_5                            ,
                 /*precedence 6 to 10 added by csahoo for bug#6485212 */
                 precedence_6                            ,
                                                     precedence_7                            ,
                                                     precedence_8                            ,
                                                     precedence_9                            ,
                                                     precedence_10                           ,
                                                     tax_amount                              ,
                                                     base_tax_amount                         ,
                                                     func_tax_amount                         ,
                                                     creation_date                           ,
                                                     created_by                              ,
                                                     last_update_date                        ,
                                                     last_updated_by                         ,
                                                     last_update_login
                                                )
                                       VALUES   (
                                                     v_header_id                             ,
                                                     v_line_id                               ,
                                                     rec_get_rma_tax_lines.tax_line_no       ,
                                                     rec_get_rma_tax_lines.tax_id            ,
                                                     rec_get_rma_tax_lines.tax_rate          ,
                                                     rec_get_rma_tax_lines.qty_rate          ,
                                                     rec_get_rma_tax_lines.uom               ,
                                                     rec_get_rma_tax_lines.precedence_1      ,
                                                     rec_get_rma_tax_lines.precedence_2      ,
                                                     rec_get_rma_tax_lines.precedence_3      ,
                                                     rec_get_rma_tax_lines.precedence_4      ,
                                                     rec_get_rma_tax_lines.precedence_5      ,
                 /*precedence 6 to 10 added by csahoo for bug#6485212 */
                                                     rec_get_rma_tax_lines.precedence_6      ,
                                                     rec_get_rma_tax_lines.precedence_7      ,
                                                     rec_get_rma_tax_lines.precedence_8      ,
                                                     rec_get_rma_tax_lines.precedence_9      ,
                                                     rec_get_rma_tax_lines.precedence_10     ,
                                                     rec_get_rma_tax_lines.tax_amount        ,
                                                     rec_get_rma_tax_lines.base_tax_amount   ,
                                                     rec_get_rma_tax_lines.func_tax_amount   ,
                                                     v_creation_date                         ,
                                                     v_created_by                            ,
                                                     v_last_update_date                      ,
                                                     v_last_updated_by                       ,
                                                     v_last_update_login
                                             );

             END IF;
             CLOSE cur_chk_tax_lines_exists;
           END LOOP;
       END;

     IF l_tax_lines_exist = 'TRUE' THEN
       -----------cbabu 30/07/02 for Bug# 2485077, start-------------------------
        /*
         Bug 5095812. Added by Lakshmi Gopalsami
   Removed  the code which is selcting from hr_operating_units and
   added the following check using plsql caching for performance
   issues reported.
  */

   l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_operating_id );

         v_set_of_books_id := l_func_curr_det.ledger_id;

         v_converted_rate :=jai_cmn_utils_pkg.currency_conversion
                 ( v_set_of_books_id , v_currency_code , v_conv_date , v_conv_type_code, v_conv_rate );
/*
  Code added by aiyer  for the bug 3700249
 */

  v_assessable_value := jai_om_utils_pkg.get_oe_assessable_value
                            (
                                p_customer_id         => v_customer_id,
                                p_ship_to_site_use_id => v_ship_to_site_use_id,
                                p_inventory_item_id   => v_inventory_item_id,
                                p_uom_code            => v_uom_code,
                                p_default_price       => pr_new.unit_selling_price,
                                p_ass_value_date      => v_date_ordered,
        /* Bug 5096787. Added by Lakshmi Gopalsami */
        p_sob_id              => v_set_of_books_id ,
        p_curr_conv_code      => v_conv_type_code  ,
        p_conv_rate           => v_conv_rate


                            );

         v_assessable_amount := NVL(v_assessable_value,0) * v_line_quantity;
         v_line_tax_amount := v_line_amount;

  ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                               (
                                p_party_id           => v_customer_id          ,
                                p_party_site_id      => v_ship_to_site_use_id  ,
                                p_inventory_item_id  => v_inventory_item_id    ,
                                p_uom_code           => v_uom_code             ,
                                p_default_price      => pr_new.unit_selling_price,
                                p_ass_value_date     => v_date_ordered         ,
                                p_party_type         => 'C'
                               );

  ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_line_quantity;

         /*
           This code has been added by Arun Iyer for the fix of the bug #2820380.
           Made if condition more explicit for Tax recalculation in case order to ORDER to ORDER.
         */
         IF v_source_order_category_code = 'ORDER' AND v_line_category_code = 'ORDER' THEN
            IF v_assessable_value <> copy_rec.assessable_value THEN
               jai_om_tax_pkg.recalculate_oe_taxes(
                                  v_header_id                 ,
                                  v_line_id                   ,
                                  v_assessable_amount         ,
                                  ln_vat_assessable_value     ,
                                  v_line_tax_amount           ,
                                  copy_rec.inventory_item_id  ,
                                  copy_rec.quantity           ,
                                  copy_rec.unit_code          ,
                                  v_converted_rate            ,
                                  v_last_update_date          ,
                                  v_last_updated_by           ,
                                  v_last_update_login
                              );

               UPDATE
                        JAI_OM_OE_SO_LINES
               SET
                        assessable_value   =  v_assessable_value                       ,
                        tax_amount         =  NVL(v_line_tax_amount,0)                 ,
                        line_tot_amount    =  v_line_amount + NVL(v_line_tax_amount,0) ,
                        last_update_date   =  v_last_update_date                       ,
                        last_updated_by    =  v_last_updated_by                        ,
                        last_update_login  =  v_last_update_login
               WHERE
                        header_id = v_header_id AND
                        line_id = v_line_id;

             END IF;

         /*
           This code has been added by Arun Iyer for the fix of the bug #2798930.
           Made if condition more explicit for Tax recalculation in case order to RETURN to ORDER.
         */

         ELSIF  v_source_order_category_code = 'RETURN' AND v_line_category_code = 'ORDER'THEN
            IF v_assessable_value <> rec_cur_get_rma_entry_lines.assessable_value THEN
               jai_om_tax_pkg.recalculate_oe_taxes(
                                 v_header_id                                                  ,
                                 v_line_id                                                    ,
                                 v_assessable_amount                                          ,
                                 ln_vat_assessable_value                                      ,
                                 v_line_tax_amount                                            ,
                                 rec_cur_get_rma_entry_lines.inventory_item_id                ,
                                 rec_cur_get_rma_entry_lines.quantity                         ,
                                 rec_cur_get_rma_entry_lines.uom                              ,
                                 v_converted_rate                                             ,
                                 v_last_update_date                                           ,
                                 v_last_updated_by                                            ,
                                 v_last_update_login
                               );

                UPDATE
                            JAI_OM_OE_SO_LINES
                SET
                            assessable_value   =    v_assessable_value                        ,
                            tax_amount         =    NVL(v_line_tax_amount,0)                  ,
                            line_tot_amount    =    v_line_amount + NVL(v_line_tax_amount,0)  ,
                            last_update_date   =    v_last_update_date                        ,
                            last_updated_by    =    v_last_updated_by                         ,
                            last_update_login  =    v_last_update_login
                   WHERE
                            header_id = v_header_id AND
                            line_id = v_line_id;

             END IF;
          END IF;
             v_line_tax_amount := 0;  -- before this bug, the variable is not used in this loop. so i used it and made it null

     END IF; -- end if of l_tax_lines_exist = 'TRUE'

  ----------cbabu 30/07/02 for Bug# 2485077, end ---------------------

  /************************************  Order TO Return tax lines computations  ********************************************/

  ELSIF v_source_order_category_code = 'ORDER' AND v_line_category_code = 'RETURN' THEN
     DECLARE
       CURSOR cur_get_picking_tax_lines (
                                            p_source_document_id        JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE    ,
                                            p_source_document_line_id   JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE
                                        )
       IS
       /* Commented By Brathod for Bug# 4244829
       SELECT
                ptl.tax_line_no                       ,
                ptl.tax_id                            ,
                ptl.tax_rate                          ,
                ptl.qty_rate                          ,
                ptl.uom                               ,
                ptl.precedence_1                      ,
                ptl.precedence_2                      ,
                ptl.precedence_3                      ,
                ptl.precedence_4                      ,
                ptl.precedence_5                      ,
                ptl.tax_amount                        ,
                ptl.base_tax_amount                   ,
                ptl.func_tax_amount                   ,
                ptl.delivery_detail_id
        FROM
                JAI_OM_WSH_LINES_ALL          pl    ,
                JAI_OM_WSH_LINE_TAXES     ptl
        WHERE
                ptl.delivery_detail_id = pl.delivery_detail_id          AND
                pl.order_header_id     = p_source_document_id          AND
                pl.order_line_id       = p_source_document_line_id;
        */
        /* Added by Brathod for Bug# 42444829 */
        SELECT
                ptl.tax_line_no                  tax_line_no      ,
                ptl.tax_id                       tax_id           ,
                ptl.tax_rate                     tax_rate         ,
                ptl.qty_rate                     qty_rate         ,
                ptl.uom                          uom              ,
                ptl.precedence_1                 precedence_1     ,
                ptl.precedence_2                 precedence_2     ,
                ptl.precedence_3                 precedence_3     ,
                ptl.precedence_4                 precedence_4     ,
                ptl.precedence_5                 precedence_5     ,
     /*precedence 6 to 10 added for bug#6485212 */
    ptl.precedence_6                 precedence_6     ,
                ptl.precedence_7                 precedence_7     ,
                ptl.precedence_8                 precedence_8     ,
                ptl.precedence_9                 precedence_9     ,
                ptl.precedence_10                precedence_10     ,
                SUM (ptl.tax_amount)             tax_amount       ,
                SUM (ptl.base_tax_amount)        base_tax_amount  ,
                SUM (ptl.func_tax_amount)        func_tax_amount  ,
                MIN (ptl.delivery_detail_id)     delivery_detail_id
        FROM
                JAI_OM_WSH_LINES_ALL          pl    ,
                JAI_OM_WSH_LINE_TAXES     ptl
        WHERE
                ptl.delivery_detail_id = pl.delivery_detail_id    AND
                pl.order_header_id     = p_source_document_id     AND
                pl.order_line_id       = p_source_document_line_id
        GROUP by    tax_line_no                       ,
                    tax_id                            ,
                    tax_rate                          ,
                    qty_rate                          ,
                    uom                               ,
                    precedence_1                      ,
                    precedence_2                      ,
                    precedence_3                      ,
                    precedence_4                      ,
                    precedence_5                      ,
         /*precedence 6 to 10 added for bug#6485212 */
        precedence_6                      ,
                    precedence_7                      ,
                    precedence_8                      ,
                    precedence_9                      ,
                    precedence_10         ;

      /* End Bug# 4244829 */

      -- Check whether a rma_tax_lines exist for the new line_id and tax_id
      CURSOR cur_chk_rma_tax_lines_exists  (
                                             p_line_id JAI_OM_OE_RMA_TAXES.RMA_LINE_ID%TYPE ,
                                             p_tax_id  JAI_OM_OE_RMA_TAXES.TAX_ID%TYPE
                                           )
      IS
      SELECT
                'X'
      FROM
                JAI_OM_OE_RMA_TAXES
      WHERE
                rma_line_id     = p_line_id     AND
                tax_id          = p_tax_id;

        l_exists       VARCHAR2(1) ;

     BEGIN
    pv_return_code := jai_constants.successful ;
        FOR rec_cur_get_picking_tax_lines IN cur_get_picking_tax_lines  ( p_source_document_id      => V_SOURCE_DOCUMENT_ID      ,
                                                                           p_source_document_line_id => V_SOURCE_DOCUMENT_LINE_ID
                                                                         )
        LOOP
           OPEN cur_chk_rma_tax_lines_exists (  p_line_id => v_line_id                            ,
                                                p_tax_id  => rec_cur_get_picking_tax_lines.tax_id
                                              );
           FETCH cur_chk_rma_tax_lines_exists INTO l_exists;
           IF cur_chk_rma_tax_lines_exists%NOTFOUND THEN
             -- Insert into ja_in_rma_entax_lines
                       INSERT INTO JAI_OM_OE_RMA_TAXES
                                        (
                                                  rma_line_id                                           ,
                                                  tax_line_no                                           ,
                                                  tax_id                                                ,
                                                  tax_rate                                              ,
                                                  qty_rate                                              ,
                                                  uom                                                   ,
                                                  tax_amount                                            ,
                                                  base_tax_amount                                       ,
                                                  func_tax_amount                                       ,
                                                  precedence_1                                          ,
                                                  precedence_2                                          ,
                                                  precedence_3                                          ,
                                                  precedence_4                                          ,
                                                  precedence_5                                          ,
              /*precedence 6 to 10 added for bug#6485212 */
              precedence_6                                          ,
                                                  precedence_7                                          ,
                                                  precedence_8                                          ,
                                                  precedence_9                                          ,
                                                  precedence_10                                          ,
                                                  delivery_detail_id                                    ,
                                                  creation_date                                         ,
                                                  created_by                                            ,
                                                  last_update_date                                      ,
                                                  last_updated_by                                       ,
                                                  last_update_login
                                          )
                          VALUES         (
                                                  v_line_id                                             ,
                                                  rec_cur_get_picking_tax_lines.tax_line_no             ,
                                                  rec_cur_get_picking_tax_lines.tax_id                  ,
                                                  rec_cur_get_picking_tax_lines.tax_rate                ,
                                                  rec_cur_get_picking_tax_lines.qty_rate                ,
                                                  rec_cur_get_picking_tax_lines.uom                     ,
                                                  rec_cur_get_picking_tax_lines.tax_amount              ,
                                                  rec_cur_get_picking_tax_lines.base_tax_amount         ,
                                                  rec_cur_get_picking_tax_lines.func_tax_amount         ,
                                                  rec_cur_get_picking_tax_lines.precedence_1            ,
                                                  rec_cur_get_picking_tax_lines.precedence_2            ,
                                                  rec_cur_get_picking_tax_lines.precedence_3            ,
                                                  rec_cur_get_picking_tax_lines.precedence_4            ,
                                                  rec_cur_get_picking_tax_lines.precedence_5            ,
              /*precedence 6 to 10 added for bug#6485212 */
              rec_cur_get_picking_tax_lines.precedence_6            ,
                                                  rec_cur_get_picking_tax_lines.precedence_7            ,
                                                  rec_cur_get_picking_tax_lines.precedence_8            ,
                                                  rec_cur_get_picking_tax_lines.precedence_9            ,
                                                  rec_cur_get_picking_tax_lines.precedence_10            ,
                                                  rec_cur_get_picking_tax_lines.delivery_detail_id      ,
                                                  v_creation_date                                       ,
                                                  v_created_by                                          ,
                                                  v_last_update_date                                    ,
                                                  v_last_updated_by                                     ,
                                                  v_last_update_login
                                          );

           END IF;
           CLOSE cur_chk_rma_tax_lines_exists ;
        END LOOP;
     END;

  /**************************************  Return TO Return tax lines computations ***************************************/

  ELSIF v_source_order_category_code = 'RETURN' AND v_line_category_code = 'RETURN' THEN
    -- Raise an error in case of return to return scenario
    -- However the control would not come to this point because this condition is blocked while calculating rma_entry_lines.
/*   RAISE_APPLICATION_ERROR (-20001,'Copying of Return Order to Return Order is not currently supported with India Localization Taxes'); */
pv_return_code := jai_constants.expected_error ; pv_return_message := 'Copying of Return Order to Return Order is not currently supported with India Localization Taxes' ; return ;

  ELSE
    /************ Else split_from_line_id is Not Null ********************/
    IF pr_new.SPLIT_FROM_LINE_ID IS NOT NULL
        AND
       pr_new.LINE_CATEGORY_CODE  <> 'RETURN'                -- cbabu for Bug# 2772120
    THEN
      /*moved the below code for bug#7523501
      -- When this is a split line
      OPEN  Get_Copy_Order_Line(v_header_id, pr_new.SPLIT_FROM_LINE_ID);
      FETCH Get_Copy_Order_Line INTO  copy_rec;
      CLOSE Get_Copy_Order_Line;
      -- Proportionate the corresponding amount according to the new quantity
      --v_line_new_tax_amount:=(copy_rec.tax_amount/copy_rec.QUANTITY)* (v_line_quantity);
      --commented the above line and replaced by the one below by Nagaraj.s for Bug3140153
      --The same is replaced by an Update statement later.
      v_line_new_amount :=(copy_rec.line_amount/copy_rec.QUANTITY) * (v_line_quantity);
      v_new_vat_assessable_value :=(copy_rec.vat_assessable_value/copy_rec.quantity) * (v_line_quantity); -- added by ssawant for Bug 4660756
      *//*bug#7523501*/
      -- the following select and if added by sriram
      -- bug # 2503978

      c_source_line_id :=0;
      SELECT COUNT(*) INTO c_source_line_id FROM JAI_OM_OE_SO_LINES WHERE LINE_ID = v_line_id;
      IF c_source_line_id = 0 THEN
        /*
          This code added by aiyer for the bug #3057594
          If the original line from which the new line has been split is lc enabled i.e lc _flag has been checked
          the new line should also have the same value for lc_flag.
          copy the original value of lc_flag value from the orginal line from where the new line has been split.
        */

  /*start bug#7523501*/
      -- When this is a split line
      OPEN  Get_Copy_Order_Line(v_header_id, pr_new.SPLIT_FROM_LINE_ID);
      FETCH Get_Copy_Order_Line INTO  copy_rec;
      CLOSE Get_Copy_Order_Line;
      -- Proportionate the corresponding amount according to the new quantity
      --v_line_new_tax_amount:=(copy_rec.tax_amount/copy_rec.QUANTITY)* (v_line_quantity);
      --commented the above line and replaced by the one below by Nagaraj.s for Bug3140153
      --The same is replaced by an Update statement later.
      v_line_new_amount :=(copy_rec.line_amount/copy_rec.QUANTITY) * (v_line_quantity);
      v_new_vat_assessable_value :=(copy_rec.vat_assessable_value/copy_rec.quantity) * (v_line_quantity); -- added by ssawant for Bug 4660756
   /*end bug#7523501*/

        /* Start of bug # 3057594 */
        OPEN  rec_get_lc_flag ;
        FETCH rec_get_lc_flag  INTO l_lc_flag;
        CLOSE rec_get_lc_flag;
        INSERT INTO JAI_OM_OE_SO_LINES  (
                                          line_number,
                                          line_id,
                                          header_id,
                                          SPLIT_FROM_LINE_ID,
                                          SHIPMENT_LINE_NUMBER,
                                          shipment_schedule_line_id, -- uncommented by sriram - for lmw ATO issue
                                          inventory_item_id,
                                          unit_code,
                                          ato_flag,
                                          quantity,
                                          tax_category_id,
                                          selling_price,
                                          assessable_value,
                                          line_amount,
                                          tax_amount,
                                          line_tot_amount,
                                          creation_date,
                                          created_by,
                                          last_update_date,
                                          last_updated_by,
                                          last_update_login,
                                          /* following 3 columns added by sriram on 03-nov-2002 bug # 2672114*/
                                           EXCISE_EXEMPT_TYPE,
                                           EXCISE_EXEMPT_REFNO,
                                           EXCISE_EXEMPT_DATE ,
                                           lc_flag         ,/*  added by aiyer for the bug #3057594 */
                                           VAT_EXEMPTION_FLAG ,
                                           VAT_EXEMPTION_TYPE ,
                                           VAT_EXEMPTION_DATE ,
                                           VAT_EXEMPTION_REFNO,
                                           VAT_ASSESSABLE_VALUE,
                                           VAT_REVERSAL_PRICE,--Added by kunkumar for forward porting to R12
                                           service_type_code --Added by kunkumar for forward porting to R12
                                    )
                               VALUES
                                    (
                                          pr_new.line_number,
                                          v_line_id,
                                          v_header_id,
                                          pr_new.SPLIT_FROM_LINE_ID,
                                          pr_new.SHIPMENT_NUMBER,
                                          pr_new.ato_line_id, -- changed this column from pr_new.shipment_schedule_line_id - sriram - LMW issue.
                                          v_inventory_item_id,
                                          pr_new.ORDER_QUANTITY_UOM,
                                          'Y',
                                          pr_new.ordered_quantity,
                                          copy_rec.tax_category_id,
                                          pr_new.UNIT_SELLING_PRICE,
                                          copy_rec.assessable_value,
                                          v_line_new_amount,
                                          0, --v_line_new_tax_amount, commented by Nagaraj.s for Bug3140153
                                          0, --(v_line_new_amount + v_line_new_tax_amount), --v_line_new_tax_amount, commented by Nagaraj.s for Bug3140153
                                          v_creation_date,
                                          v_created_by,
                                          v_last_update_date,
                                          v_last_updated_by,
                                          v_last_update_login,
                                          Copy_rec.EXCISE_EXEMPT_TYPE, /* following 3 columns added by sriram on 03-nov-2002 bug # 2672114*/
                                          copy_rec.EXCISE_EXEMPT_REFNO,
                                          copy_rec.EXCISE_EXEMPT_DATE ,
                                          l_lc_flag       ,             /* added by aiyer for the bug #3057594 */
                                          Copy_rec.VAT_EXEMPTION_FLAG ,
                                          Copy_rec.VAT_EXEMPTION_TYPE ,
                                          Copy_rec.VAT_EXEMPTION_DATE ,
                                          Copy_rec.VAT_EXEMPTION_REFNO,
                                          v_new_vat_assessable_value, -- added by ssawant for Bug 4660756
            (copy_rec.vat_reversal_price/copy_rec.quantity)*(v_line_quantity),--Added by kunkumar for forward porting to R12
            copy_rec.service_type_code --Added by kunkumar for forward porting to R12
                                    );

      END IF;
      -- carry over the old ordered quantity into the below tax line loop for tax amount proportionating

      v_old_quantity :=copy_rec.QUANTITY;

      OPEN Get_So_Tax_Lines_Count_Cur(v_header_id, pr_new.SPLIT_FROM_LINE_ID);
      FETCH Get_So_Tax_Lines_Count_Cur INTO v_so_tax_lines_count;
      CLOSE Get_So_Tax_Lines_Count_Cur;

      IF NVL(v_so_tax_lines_count,0)>0 THEN

        FOR Rec IN So_Tax_Lines_Cur( v_header_id, pr_new.SPLIT_FROM_LINE_ID)
        LOOP
   /*moved this code to below for bug#7523501
          --Added for Fetching the Rounding factor by Nagaraj.s for Bug3140153.
            open c_fetch_rounding_factor(rec.tax_id);
            fetch c_fetch_rounding_factor into v_rounding_factor,v_adhoc_flag; --Bug3207633
            close c_fetch_rounding_factor;
          --Ends here to Fetch Rounding Factor.



          --v_new_tax_amount      := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(rec.tax_rate)/100,v_rounding_factor);

          --commented the above line and replaced by the one below by Nagaraj.s for Bug3207633
          IF v_adhoc_flag ='N' THEN
            -- Start of bug 37706050
            /*
               --If the tax is a qty rate based tax then pick up the qty rate instead of the tax_rate so added an nvl condition
               --to also add qty_rate.

            --Commented rpokkula for Bug#4161579
            --v_new_tax_amount      := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(nvl(rec.tax_rate,rec.qty_rate))/100,v_rounding_factor);
            -- End of bug 37706050

          --added rpokkula for Bug#4161579, start
            IF rec.tax_rate is not null THEN
                 v_new_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(rec.tax_rate)/100,v_rounding_factor);
            ELSIF rec.qty_rate is not null THEN
                 v_new_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity) ,v_rounding_factor);
            END IF ;
          --added rpokkula for Bug#4161579, end

          ELSIF v_adhoc_flag='Y' THEN
            v_new_tax_amount      := round((rec.tax_amount/v_old_quantity)*v_line_quantity,v_rounding_factor);
          END IF;

          v_new_base_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity), v_rounding_factor);
          v_new_func_tax_amount := round((rec.func_tax_amount/v_old_quantity )*(v_line_quantity), v_rounding_factor);
          --Added by Nagaraj.s for Bug3140153
          v_header_tax_amount      := v_header_tax_amount + v_new_tax_amount;
    *//*7523501*/
          --code to check the existing line in table JAI_OM_OE_SO_TAXES for bug #2519043
          SELECT COUNT(1) INTO v_tax_line_count
          FROM JAI_OM_OE_SO_TAXES
          WHERE line_id = v_line_id
          AND tax_id = rec.tax_id ;

          IF v_tax_line_count = 0 THEN

   /*start for bug#7523501*/
          --Added for Fetching the Rounding factor by Nagaraj.s for Bug3140153.
            open c_fetch_rounding_factor(rec.tax_id);
            fetch c_fetch_rounding_factor into v_rounding_factor,v_adhoc_flag; --Bug3207633
            close c_fetch_rounding_factor;
          --Ends here to Fetch Rounding Factor.



          --v_new_tax_amount      := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(rec.tax_rate)/100,v_rounding_factor);

          --commented the above line and replaced by the one below by Nagaraj.s for Bug3207633
          IF v_adhoc_flag ='N' THEN
            -- Start of bug 37706050

               --If the tax is a qty rate based tax then pick up the qty rate instead of the tax_rate so added an nvl condition
               --to also add qty_rate.

            --Commented rpokkula for Bug#4161579
            --v_new_tax_amount      := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(nvl(rec.tax_rate,rec.qty_rate))/100,v_rounding_factor);
            -- End of bug 37706050

          --added rpokkula for Bug#4161579, start
            IF rec.tax_rate is not null THEN
                 v_new_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity)*(rec.tax_rate)/100,v_rounding_factor);
            ELSIF rec.qty_rate is not null THEN
                 v_new_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity) ,v_rounding_factor);
            END IF ;
          --added rpokkula for Bug#4161579, end

          ELSIF v_adhoc_flag='Y' THEN
            v_new_tax_amount      := round((rec.tax_amount/v_old_quantity)*v_line_quantity,v_rounding_factor);
          END IF;

          v_new_base_tax_amount := round((rec.base_tax_amount/v_old_quantity )*(v_line_quantity), v_rounding_factor);
          v_new_func_tax_amount := round((rec.func_tax_amount/v_old_quantity )*(v_line_quantity), v_rounding_factor);
          --Added by Nagaraj.s for Bug3140153
          v_header_tax_amount      := v_header_tax_amount + v_new_tax_amount;
   /*end bug 7523501*/
          INSERT INTO JAI_OM_OE_SO_TAXES (
                          header_id, line_id, tax_line_no, tax_id,
                          tax_rate, qty_rate, uom, precedence_1,
                          precedence_2, precedence_3, precedence_4, precedence_5,
        /*precedence 6 to 10 added by csahoo for bug#6485212 */
        precedence_6, precedence_7, precedence_8, precedence_9,precedence_10,
                          tax_amount, base_tax_amount, func_tax_amount, creation_date,
                          created_by, last_update_date, last_updated_by, last_update_login,
                          tax_category_id                       -- cbabu for EnhancementBug# 2427465
                           ) VALUES (
                          v_header_id, v_line_id, rec.tax_line_no, rec.tax_id,
                          rec.tax_rate, rec.qty_rate, rec.uom, rec.precedence_1,
                          rec.precedence_2, rec.precedence_3, rec.precedence_4, rec.precedence_5,
        /*precedence 6 to 10 added by csahoo for bug#6485212 */
        rec.precedence_6, rec.precedence_7, rec.precedence_8, rec.precedence_9,rec.precedence_10,
                          v_new_tax_amount, v_new_base_tax_amount, v_new_func_tax_amount, v_creation_date,
                          v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login,
                          rec.tax_category_id                   -- cbabu for EnhancementBug# 2427465
          );
        END IF;
        END LOOP; --FOR Rec IN So_Tax_Lines_Cur( v_header_id, pr_new.SPLIT_FROM_LINE_ID)

  --start additions for bug#9436523
     IF v_debug = 'Y' THEN
     utl_file.put_line(v_myfilehandle,'** START OForder_tax_amount_Cur '|| v_header_id ||' line id '||v_line_id);
     END IF;
         OPEN  order_tax_amount_Cur(v_header_id, v_line_id);
         FETCH order_tax_amount_Cur INTO v_header_tax_amount;
         CLOSE order_tax_amount_Cur;
     IF v_debug = 'Y' THEN
     utl_file.put_line(v_myfilehandle,'** v_header_tax_amount '||v_header_tax_amount);
     END IF;
    --end additions for bug#9436523
       update JAI_OM_OE_SO_LINES
        set    tax_amount = nvl(v_header_tax_amount,0),
               line_tot_amount = nvl(v_header_tax_amount,0) + nvl(line_amount,0)
        where  header_id = v_header_id
        and    line_id   = v_line_id;
  --end  bug#7523501
      END IF; --  NVL(v_so_tax_lines_count,0)>0 THEN
        /*moved this up for bug#7523501
  --Added by Nagaraj.s for 3140153
        update JAI_OM_OE_SO_LINES
        set    tax_amount = v_header_tax_amount,
               line_tot_amount = v_header_tax_amount + line_amount
        where  header_id = v_header_id
        and    line_id   = v_line_id;
  *//*bug#7523501*/

    ELSE
    /*ELSIF of NEW.SPLIT_FROM_LINE_ID IS NOT NULL AND NEW.LINE_CATEGORY_CODE <> 'RETURN'*/
      /***** Normal Order creation scenario *********/

      /*
        This code has been modified by Aiyer for the fix of the bug #2979969.
        Issue:-
          If an RMA order is created having a return_context as null then the record gets
          inserted into the JAI_OM_OE_SO_LINES table.
          Even though a rma line is not having the return_context field still the line should be treated as
          RMA and not as a sales order line.

        Solution:-
          Added an NVL clause to the below IF statement .
          Now even if the Return_context is null it would be treated as = LEGACY
          and the v_transaction_name flag would be set to LEGACY.
          Due to this the record would be inserted into the JAI_OM_OE_RMA_LINES table instead of the
          JAI_OM_OE_SO_LINES table.
      */
      -- Start of bug #2979969
      IF  pr_new.LINE_CATEGORY_CODE  = 'RETURN'  THEN
        -- Start of Bug # 3344454
        /**************
          Code modified by aiyer for the bug 3344454
        **********/
        /*
        ||Added by aiyer for the bug 5401180
        ||modified the if statement , original condition
        || IF  NVL(pr_new.RETURN_CONTEXT,'LEGACY') = 'LEGACY'
        */
        IF  pr_new.return_context IS NULL  THEN
          -- End of bug #2979969
          -- overwrite the transaction name
          v_transaction_name := 'RMA_LEGACY_INSERT';

        ELSE
          RETURN;
        END IF;
        -- End of Bug 3344454
      END IF;
      -- Added by Aparajita for writing onto the log file
      IF v_debug = 'Y' THEN
        utl_file.put_line(v_myfilehandle, ' Inside ELSE OF NEW.SPLIT_FROM_LINE_ID IS NOT NULL ' || v_transaction_name);
      END IF;

      -- Else if the line is a fresh line , Unsplitted
      /*
         Bug 5095812. Added by Lakshmi Gopalsami
   Removed the cursor set_of_books_cur and added the following check
   using plsql caching for performance issues reported.
      */

   l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_operating_id);

         v_set_of_books_id := l_func_curr_det.ledger_id;


      v_converted_rate :=jai_cmn_utils_pkg.currency_conversion  (
                                         v_set_of_books_id ,
                                         v_currency_code ,
                                         v_conv_date ,
                                         v_conv_type_code,
                                         v_conv_rate
                                       );
  v_assessable_value := jai_om_utils_pkg.get_oe_assessable_value
                            (
                                p_customer_id         => v_customer_id,
                                p_ship_to_site_use_id => v_ship_to_site_use_id,
                                p_inventory_item_id   => v_inventory_item_id,
                                p_uom_code            => v_uom_code,
                                p_default_price       => pr_new.unit_selling_price,
                                p_ass_value_date      => v_date_ordered,
        /* Bug 5096787. Added by Lakshmi Gopalsami */
        p_sob_id              => v_set_of_books_id ,
        p_curr_conv_code      => v_conv_type_code  ,
        p_conv_rate           => v_converted_rate
                            );

   v_assessable_amount := NVL(v_assessable_value,0) * v_line_quantity;

   ln_vat_assessable_value :=  jai_general_pkg.JA_IN_VAT_ASSESSABLE_VALUE
                               (
                                P_PARTY_ID           => v_customer_id          ,
                                P_PARTY_SITE_ID      => v_ship_to_site_use_id  ,
                                P_INVENTORY_ITEM_ID  => v_inventory_item_id    ,
                                P_UOM_CODE           => v_uom_code             ,
                                P_DEFAULT_PRICE      => pr_new.unit_selling_price,
                                P_ASS_VALUE_DATE     => v_date_ordered         ,
                                P_PARTY_TYPE         => 'C'
                               );

   ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_line_quantity;


      IF v_debug = 'Y' THEN
        utl_file.put_line(v_myfilehandle, ' v_assessable_value -> '||v_assessable_value);
      END IF;

      --IF v_order_category not in ('ORDER','MIXED','RETURN')

      OPEN  get_source_id;
      FETCH get_source_id INTO v_source_id;
      CLOSE get_source_id;

      IF (  (v_line_category_code='ORDER') OR  (v_transaction_name='RMA_LEGACY_INSERT') ) THEN --and V_Order_Source_Type = 'Internal'

        IF v_debug = 'Y' THEN
          utl_file.put_line(v_myfilehandle, ' inside IF OF v_line_category_code IN (ORDER) OR  v_transaction_name = RMA_LEGACY_INSERT');
        END IF;

        -- When ship to site is changed
        IF NVL(pr_new.ship_to_ORG_id,0)  <> NVL(pr_old.ship_to_ORG_id,0) THEN
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' BEFORE DELETING WHEN ship TO org has changed');
          END IF;

          IF ( v_transaction_name = 'RMA_LEGACY_INSERT') THEN

            DELETE JAI_OM_OE_RMA_LINES
            WHERE  RMA_LINE_ID = V_LINE_ID;
            DELETE JAI_OM_OE_RMA_TAXES
            WHERE  RMA_LINE_ID = V_LINE_ID;
          ELSE
            DELETE JAI_OM_OE_SO_LINES
            WHERE  LINE_ID = v_line_id;
            DELETE JAI_OM_OE_SO_TAXES
            WHERE  Line_ID = v_line_id;
          END IF;
        END IF;

        -- End of Ship to site changed
        IF v_debug = 'Y' THEN
          utl_file.put_line(v_myfilehandle, ' BEFORE calling jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes ');
        END IF;

        jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes (
                                                    v_warehouse_id,
                                                    v_customer_id,
                                                    v_ship_to_site_use_id,
                                                    v_inventory_item_id,
                                                    v_header_id,
                                                    v_line_id,
                                                    v_tax_category_id
                                               );

        IF v_tax_category_id IS NULL THEN
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' BEFORE calling jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes ');
          END IF;

          jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes (
                                                  v_warehouse_id,
                                                  v_inventory_item_id,
                                                  v_tax_category_id
                                                );

        ELSE /* elsif of v_tax_category_id IS NULL */
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' BEFORE setting v_line_tax_amount := v_line_amount ');
          END IF;
          v_line_tax_amount := v_line_amount;
        END IF;

        IF v_transaction_name = 'RMA_LEGACY_INSERT' THEN
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' inside IF OF RMA_LEGACY_INSERT ');
          END IF;

          OPEN get_rma_tax_lines_count_cur;
          FETCH get_rma_tax_lines_count_cur INTO v_so_tax_lines_count;
          CLOSE get_rma_tax_lines_count_cur;

        ELSE                                                                              --14
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' inside ELSE OF RMA_LEGACY_INSERT ');
          END IF;

          OPEN get_so_tax_lines_count_cur(v_header_id,v_line_id);
          FETCH get_so_tax_lines_count_cur INTO         v_so_tax_lines_count;
          CLOSE get_so_tax_lines_count_cur;
        END IF;

        IF v_so_tax_lines_count = 0 THEN
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' inside IF OF v_so_tax_lines_count = 0 ');
          END IF;
          jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes (
                                                  transaction_name               => v_transaction_name,
                                                  p_tax_category_id              => v_tax_category_id,
                                                  p_header_id                    => v_header_id,
                                                  p_line_id                      => v_line_id,
                                                  p_assessable_value             => v_assessable_amount,
                                                  p_tax_amount                   => v_line_tax_amount,
                                                  p_inventory_item_id            => v_inventory_item_id,
                                                  p_line_quantity                => v_line_quantity,
                                                  p_uom_code                     => v_uom_code,
                                                  p_vendor_id                    => '',
                                                  p_currency                     => '',
                                                  p_currency_conv_factor         => v_converted_rate,
                                                  p_creation_date                => v_creation_date,
                                                  p_created_by                   => v_created_by,
                                                  p_last_update_date             => v_last_update_date,
                                                  p_last_updated_by              => v_last_updated_by,
                                                  p_last_update_login            => v_last_update_login,
                                                  p_operation_flag               => NULL,
                                                  p_vat_assessable_value         => ln_vat_assessable_value
                                               );

        END IF; -- v_so_tax_lines_count = 0 THEN
      END IF; -- v_line_category_code IN ('ORDER')  THEN

      IF V_SHIPMENT_SCHEDULE_LINE_ID IS NULL    THEN
        IF v_debug = 'Y' THEN
          utl_file.put_line(v_myfilehandle, ' inside IF OF V_SHIPMENT_SCHEDULE_LINE_ID IS NULL ');
        END IF;

        IF v_transaction_name = 'RMA_LEGACY_INSERT' THEN
          OPEN get_rma_lines_count_cur(v_line_id);
          FETCH get_rma_lines_count_cur INTO v_so_lines_count;
          CLOSE get_rma_lines_count_cur;
        ELSE
          OPEN get_so_lines_count_cur(v_line_id);
          FETCH get_so_lines_count_cur INTO v_so_lines_count;
          CLOSE get_so_lines_count_cur;
        END IF;

        IF v_so_lines_count = 0 THEN

          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' inside IF OF v_so_lines_count = 0 ');
          END IF;
          IF v_transaction_name = 'RMA_LEGACY_INSERT' THEN
            IF v_debug = 'Y' THEN -- added by sriram - because it was causing errors when utl_file is not setup bug # 2687045
              utl_file.put_line(v_myfilehandle, 'BEFORE  opening return_tax_amount_Cur ');
            END IF;
            OPEN  return_tax_amount_Cur(v_header_id, pr_new.LINE_ID);
            FETCH return_tax_amount_Cur INTO v_line_tax_amount;
            CLOSE return_tax_amount_Cur;
          ELSE
            OPEN  order_tax_amount_Cur(v_header_id, pr_new.LINE_ID);
            FETCH order_tax_amount_Cur INTO v_line_tax_amount;
            CLOSE order_tax_amount_Cur;
          END IF;
          IF v_debug = 'Y' THEN
            utl_file.put_line(v_myfilehandle, ' Total tax : ' || v_line_tax_amount);
          END IF;

          IF v_transaction_name = 'RMA_LEGACY_INSERT' THEN
            IF v_debug = 'Y' THEN
              utl_file.put_line(v_myfilehandle, ' BEFORE INSERTING RECORD INTO JAI_OM_OE_RMA_LINES ');
            END IF;
            INSERT INTO JAI_OM_OE_RMA_LINES  (
                                                    rma_line_number,
                                                    rma_line_id,
                                                    rma_header_id,
                                                    rma_number,
                                                    inventory_item_id,
                                                    uom,
                                                    quantity,
                                                    tax_category_id,
                                                    selling_price,
                                                    tax_amount,
                                                    creation_date,
                                                    created_by,
                                                    last_update_date,
                                                    last_updated_by,
                                                    last_update_login,
                                                    assessable_value    -- cbabu for Bug# 2687130
                                               )
                                        VALUES
                                               (
                                                    v_line_number,
                                                    v_line_id,
                                                    v_header_id,
                                                    v_order_number,
                                                    v_inventory_item_id,
                                                    pr_new.ORDER_QUANTITY_UOM,
                                                    pr_new.ordered_quantity,
                                                    v_tax_category_id,
                                                    pr_new.UNIT_SELLING_PRICE,
                                                    v_line_tax_amount,
                                                    v_creation_date,
                                                    v_created_by,
                                                    v_last_update_date,
                                                    v_last_updated_by,
                                                    v_last_update_login,
                                                    v_assessable_value          -- cbabu for Bug# 2687130
                                                );
          ELSE /* else if of v_transaction_name = 'RMA_LEGACY_INSERT' */
            IF v_debug = 'Y' THEN
              utl_file.put_line(v_myfilehandle, ' BEFORE INSERTING RECORD INTO JAI_OM_OE_SO_LINES ');
            END IF;
            -- the following select and if added by sriram
            -- bug # 2503978

            c_source_line_id :=0;
            SELECT COUNT(*) INTO c_source_line_id FROM JAI_OM_OE_SO_LINES WHERE LINE_ID = v_line_id;
            IF c_source_line_id = 0 THEN
              INSERT INTO JAI_OM_OE_SO_LINES
              (
              line_number,
              line_id,
              header_id,
              SHIPMENT_LINE_NUMBER,
              shipment_schedule_line_id,-- uncommented by sriram - for lmw ato issue
              inventory_item_id,
              unit_code,
              ato_flag,
              quantity,
              tax_category_id,
              selling_price,
              assessable_value,
              line_amount,
              tax_amount,
              line_tot_amount,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              vat_assessable_value,
        service_type_code/*bduvarag for the bug#5694855*/
              )
              VALUES
              (
              pr_new.line_number,
              v_line_id,
              v_header_id,
              pr_new.SHIPMENT_NUMBER,
              pr_new.ato_line_id, -- uncommented by sriram - for lmw ato issue
              v_inventory_item_id,
              pr_new.ORDER_QUANTITY_UOM,
              'Y',
              pr_new.ordered_quantity,
              v_tax_category_id,
              pr_new.UNIT_SELLING_PRICE,
              v_assessable_value,
              v_line_amount,
              v_line_tax_amount,
              (v_line_amount + v_line_tax_amount),
              v_creation_date,
              v_created_by,
              v_last_update_date,
              v_last_updated_by,
              v_last_update_login,
              ln_vat_assessable_value,
        v_service_type_code/*bduvarag for the bug#5694855*/
              );
            END IF;
          END IF;--

        END IF; -- IF v_so_lines_count = 0

      END IF;   -- V_SHIPMENT_SCHEDULE_LINE_ID

    END IF; -- IF pr_new.SPLIT_FROM_LINE_ID IS NOT NULL THEN

  END IF;
-- code segment added by sriram - LMW ATO
if upper(pr_new.item_type_code) = 'CONFIG' then
   IF pr_new.SPLIT_FROM_LINE_ID IS  NULL
       AND
      pr_new.LINE_CATEGORY_CODE  <> 'RETURN'
   THEN

     -- Select 'before calling calc_price_tax_for_config_item ' into v_trigg_stat from dual;

     calc_price_tax_for_config_item(pr_new.header_id , pr_new.line_id );

     -- Select 'after calling calc_price_tax_for_config_item ' into v_trigg_stat from dual;

     update JAI_OM_OE_SO_LINES
     set    line_amount      = v_ato_line_amount,
            --tax_amount     =  v_ato_tax_amount -- Not reqired
            assessable_value = v_ato_assessable_value,
            vat_assessable_value = v_ato_vat_assessable_value, --added for bug#8924003
            selling_price    = v_ato_selling_price
     where  header_id   = pr_new.header_id
     and    line_id     = pr_new.line_id;

     -- Select 'after update after calc_price_tax_for_config_item ' into v_trigg_stat from dual;

     Declare

      cursor c_model_taxes is
      select *
      from   JAI_OM_OE_SO_TAXES
      where  header_id = pr_new.header_id
      and    line_id = pr_new.ato_line_id ;
      -- ato_line_id gets the line_id of the model item

      cursor c_model_tax_Categ is
            select tax_category_id , inventory_item_id , line_amount
            from   JAI_OM_OE_SO_LINES
            where  header_id = pr_new.header_id
            and    line_id = pr_new.ato_line_id ;

      v_output_tax_amount       Number;
      v_tax_category            Number;
      v_ato_inventory_item_id   Number;


     Begin

      -- copy the taxes of model item into config item

      -- Select 'in code segment for ATO in ja_in_oe_order_lines_aiu_trg ' into v_trigg_stat from dual;

      open  c_model_tax_Categ;
      Fetch c_model_tax_Categ into v_tax_category, v_ato_inventory_item_id , v_output_tax_amount;
      close c_model_tax_Categ;

      -- Select 'after c_mode_tax_categ in  ja_in_oe_order_lines_aiu_trg ' into v_trigg_stat from dual;

      For model_rec in c_model_taxes
      Loop

        IF v_debug = 'Y' THEN
           -- log start of trigger
           utl_file.put_line(v_myfilehandle,'In the Loop Header ID ~ Line ID :' || TO_CHAR(pr_new.header_id) || ' ~ ' || TO_CHAR(pr_new.line_id));
        end if;

         -- Select 'before insert into ja_in_oe_order_lines_aiu_trg 12345' into v_trigg_stat from dual;


         -- select ' before insert  1 values are : ' || model_rec.tax_line_no || pr_new.line_id || pr_new.header_id into v_trigg_stat from dual;
         -- select ' before insert  2 values are : ' || model_rec.precedence_1|| model_rec.precedence_2||        model_rec.precedence_3||        model_rec.precedence_4 into v_trigg_stat from dual;

         -- select ' before insert  3 values are : ' || model_rec.precedence_5|| model_rec.tax_id||         model_rec.tax_rate||         model_rec.qty_rate||         model_rec.uom into v_trigg_stat from dual;
         -- select ' before insert  4 values are : ' || model_rec.tax_amount  || model_rec.base_tax_amount||        model_rec.func_tax_amount||         model_rec.creation_date into v_trigg_stat from dual;
         -- select ' before insert  5 values are : ' || model_rec.created_by  || model_rec.last_update_date||         model_rec.last_updated_by||   model_rec.last_update_login||     model_rec.tax_category_id into v_trigg_stat from dual;

         Insert into JAI_OM_OE_SO_TAXES
        (
         tax_line_no      ,
         line_id          ,
         header_id        ,
         precedence_1     ,
         precedence_2     ,
         precedence_3     ,
         precedence_4     ,
         precedence_5     ,
         tax_id           ,
         tax_rate         ,
         qty_rate         ,
         uom              ,
         tax_amount       ,
         base_tax_amount  ,
         func_tax_amount  ,
         creation_date    ,
         created_by       ,
         last_update_date ,
         last_updated_by  ,
         last_update_login,
         tax_category_id  ,
   /*precedence 6 to 10 added by csahoo for bug#6485212 */
   precedence_6     ,
         precedence_7     ,
         precedence_8     ,
         precedence_9     ,
         precedence_10
        )
        Values
        (
         model_rec.tax_line_no,
         pr_new.line_id,
         pr_new.header_id,
         model_rec.precedence_1,
         model_rec.precedence_2,
         model_rec.precedence_3,
         model_rec.precedence_4,
         model_rec.precedence_5,
         model_rec.tax_id,
         model_rec.tax_rate,
         model_rec.qty_rate,
         model_rec.uom,
         model_rec.tax_amount,
         model_rec.base_tax_amount,
         model_rec.func_tax_amount,
         model_rec.creation_date,
         model_rec.created_by,
         model_rec.last_update_date,
         model_rec.last_updated_by,
         model_rec.last_update_login,
         model_rec.tax_category_id  ,
   /*precedence 6 to 10 added by csahoo for bug#6485212 */
   model_rec.precedence_6,
         model_rec.precedence_7,
         model_rec.precedence_8,
         model_rec.precedence_9,
         model_rec.precedence_10
        );

      End Loop;
      -- to recalculate taxes


      -- Select 'before jai_om_tax_pkg.calculate_ato_taxes in ja_in_oe_order_lines_aiu_trg ' into v_trigg_stat from dual;

      jai_om_tax_pkg.calculate_ato_taxes
       (
        'OE_LINES_UPDATE',NULL,pr_new.header_id , pr_new.line_id , v_ato_assessable_value, v_ato_line_amount ,
        v_converted_rate,pr_new.inventory_item_id,pr_new.ordered_quantity , pr_new.ordered_quantity, pr_new.pricing_quantity_uom,
        NULL,NULL,NULL,NULL,pr_new.last_update_date,pr_new.last_updated_by,pr_new.last_update_login
        ,v_ato_vat_assessable_value --added for bug#8924003
       );

      -- update the tax amounts after doing tax recalculation .
      update JAI_OM_OE_SO_LINES
      set    tax_amount      =  NVL(v_ato_line_amount,0) ,
             line_tot_amount =  line_amount +  NVL(v_ato_line_amount,0)
      where  header_id   = pr_new.header_id
      and    line_id     = pr_new.line_id;

     End;

   END IF;
  end if;

-- code segment added by sriram - LMW ATO   ends here

  -- Added by Aparajita for writing onto the log file
  IF v_debug = 'Y' THEN
    -- log start of trigger
    utl_file.put_line(v_myfilehandle,'** SUCCESSFUL END  OF TRIGGER jai_oe_ola_ariu_t5 AFTER INSERT OR UPDATE ON OE_ORDER_LINES_ALL FOR EACH ROW ~ ' || TO_CHAR(SYSDATE,'DD/mm/rrrr hh24:mi:ss'));
    utl_file.put_line(v_myfilehandle,'Header ID ~ Line ID :' || TO_CHAR(pr_new.header_id) || ' ~ ' || TO_CHAR(pr_new.line_id));
    utl_file.fclose(v_myfilehandle);
  END IF; -- v_debug

-- Select 'End of trigger ' into v_trigg_stat from dual;

EXCEPTION
  WHEN OTHERS THEN
    IF v_debug = 'Y' THEN
      -- log start of trigger
      utl_file.put_line(v_myfilehandle,'Header ID ~ Line ID :' || TO_CHAR(pr_new.header_id) || ' ~ ' || TO_CHAR(pr_new.line_id));
      utl_file.put_line(v_myfilehandle,'Error :' || SQLERRM );
      utl_file.put_line(v_myfilehandle,'** Error END  OF TRIGGER jai_oe_ola_ariu_t5 AFTER INSERT OR UPDATE ON OE_ORDER_LINES_ALL FOR EACH ROW ~ ' || TO_CHAR(SYSDATE,'DD/mm/rrrr hh24:mi:ss'));
      utl_file.fclose(v_myfilehandle);
    END IF; -- v_debug

    --RAISE_APPLICATION_ERROR(-20002, 'ERROR - TRIGGER JA_IN_OE_ORDER_LINES_AIU_TRG : ' || SQLERRM);
    /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_OE_OLA_TRIGGER_PKG.ARIU_T1 '  || substr(sqlerrm,1,1900);

  END ARIU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARIU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_OE_OLA_ARIUD_T1
  REM               Populate JAI tables JAI_RGM_INVOICE_GEN_T, JAI_OM_WSH_LINES_ALL,
  REM               and JAI_OM_WSH_LINE_TAXES for fulfilled non-shippable items.
  REM
  REM NOTES
  REM
  REM HISTORY
  REM 31-Mar-2010  Created by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement)
  REM
  REM +======================================================================+
  */
  PROCEDURE ARIU_T2
  ( pr_old             t_rec%TYPE
  , pr_new             t_rec%TYPE
  , pv_action          VARCHAR2
  , pv_return_code     OUT NOCOPY VARCHAR2
  , pv_return_message  OUT NOCOPY VARCHAR2
  )
  IS
  ld_creation_date                 DATE;
  ln_created_by                    NUMBER;
  ld_last_update_date              DATE;
  ln_last_updated_by               NUMBER;
  ln_last_update_login             NUMBER;

  ln_order_header_id               NUMBER;
  ln_order_number                  NUMBER;
  ln_order_line_id                 NUMBER;
  ln_picking_tax_lines_count       NUMBER;
  ln_fulfill_line_count            NUMBER;
  ln_selling_price                 NUMBER;
  ln_quantity                      NUMBER;
  ln_assessable_value              NUMBER;
  ln_tot_tax_amount                NUMBER;
  ln_tax_category_id               NUMBER(15);
  ln_inventory_item_id             NUMBER;
  ln_organization_Id               NUMBER;
  ln_order_type_id                 NUMBER;
  lv_subinventory                  VARCHAR2(10);
  ln_location_id                   NUMBER;
  lv_trading_flag                  VARCHAR2(1);
  lv_unit_code                     VARCHAR2(3);
  lv_excise_exempt_type            VARCHAR2(60);
  lv_excise_exempt_refno           VARCHAR2(30);
  ld_excise_exempt_date            DATE;
  ln_org_Id                        NUMBER;
  ln_customer_id                   NUMBER;
  ln_ship_to_org_id                NUMBER;
  ln_fulfilled_quantity            NUMBER;

  ln_vat_assessable_value         JAI_OM_OE_SO_LINES.VAT_ASSESSABLE_VALUE%TYPE;
  lv_vat_exemption_flag           JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_FLAG%TYPE;
  lv_vat_exemption_type           JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_TYPE%TYPE;
  ld_vat_exemption_date           JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_DATE%TYPE;
  lv_vat_exemption_refno          JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_REFNO%TYPE;

  ln_vat_cnt                      NUMBER DEFAULT 0 ;
  ln_vat_proc_cnt                 NUMBER DEFAULT 0 ;
  ln_regime_id                    JAI_RGM_ORG_REGNS_V.REGIME_ID%TYPE;
  lv_regns_num                    JAI_RGM_ORG_REGNS_V.ATTRIBUTE_VALUE%TYPE;

  ln_vat_reversal_exists          NUMBER ;
  lv_vat_reversal                 VARCHAR2(100);
  lv_vat_invoice_no               VARCHAR2(10);
  lv_vat_inv_gen_status           VARCHAR2(10);

  lv_module_prefix                 VARCHAR2(50) :='ja.plsql.JAI_OE_OLA_TRIGGER_PKG';
  lv_procedure_name                VARCHAR2(50) :='ARIU_T2';
  ln_dbg_level                     NUMBER       :=FND_LOG.G_Current_Runtime_Level;
  ln_proc_level                    NUMBER       :=FND_LOG.Level_Procedure;

  CURSOR Get_Tax_Lines_Details_Cur IS
  SELECT
    jcta.Tax_Type
  , NVL(jcta.Rounding_Factor,2) Rounding_Factor
  , joost.Tax_Line_No
  , joost.Precedence_1
  , joost.Precedence_2
  , joost.Precedence_3
  , joost.Precedence_4
  , joost.Precedence_5
  , joost.Precedence_6
  , joost.Precedence_7
  , joost.Precedence_8
  , joost.Precedence_9
  , joost.Precedence_10
  , joost.Tax_Id
  , joost.Tax_Rate
  , joost.Qty_Rate
  , joost.Uom
  , joost.Tax_Amount
  , joost.Base_Tax_Amount
  , joost.Func_Tax_Amount
  FROM
    JAI_OM_OE_SO_TAXES joost
  , JAI_CMN_TAXES_ALL jcta
  WHERE  joost.line_id = ln_order_line_id
    AND  joost.Tax_Id = jcta.Tax_Id
  ORDER BY joost.Tax_Line_No;

  CURSOR Get_Fulfill_Line_Count_Cur IS
  SELECT  COUNT(*)
  FROM    JAI_OM_WSH_LINES_ALL
  WHERE   Order_Line_Id = ln_order_line_id
  AND     Shippable_Flag = 'N';

  CURSOR Pick_Tax_Line_Count_Cur(P_Tax_Id NUMBER) IS
  SELECT  COUNT(*)
  FROM   JAI_OM_WSH_LINE_TAXES
  WHERE  Order_Line_Id = ln_order_line_id
    AND  Tax_Id = P_Tax_Id;

  CURSOR Get_So_Lines_Details_Cur IS
  SELECT NVL(Selling_Price,0)
       , NVL(Quantity,0)
       , NVL(Tax_Category_Id,0)
       , NVL(Assessable_Value,0)
       , NVL(vat_assessable_value,0)
       , Excise_Exempt_Type
       , Excise_Exempt_Refno
       , Excise_Exempt_Date
       , vat_exemption_flag
       , vat_exemption_type
       , vat_exemption_date
       , vat_exemption_refno
  FROM    JAI_OM_OE_SO_LINES
  WHERE   Line_id = ln_order_line_id;

  CURSOR Get_Tot_Tax_Amount_Cur IS
  SELECT  SUM(jowlt.Tax_Amount)
  FROM    JAI_OM_WSH_LINE_TAXES jowlt
        , JAI_CMN_TAXES_ALL jcta
  WHERE   jowlt.Order_Line_Id = ln_order_line_id
    AND   jcta.Tax_Id = jowlt.Tax_Id
    AND   jcta.Tax_Type <> 'TDS';

  CURSOR Location_Cursor IS
  SELECT  Location_id
        , trading
  FROM  JAI_INV_SUBINV_DTLS
  WHERE  Sub_Inventory_Name      = lv_subinventory
    AND  organization_id         = ln_organization_Id;

  CURSOR cur_chk_vat_exists  (cp_order_line_id JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE)
  IS
  SELECT 1
  FROM   JAI_OM_WSH_LINE_TAXES   jsptl
         , JAI_CMN_TAXES_ALL       jtc
         , jai_regime_tax_types_v  tax_types
  WHERE   jsptl.order_line_id    = cp_order_line_id
    AND    jtc.tax_id            = jsptl.tax_id
    AND    jtc.tax_type          = tax_types.tax_type
    AND    tax_types.regime_code = jai_constants.vat_regime;

  CURSOR cur_chk_vat_proc_entry (cp_order_line_id JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE)
  IS
  SELECT 1
  FROM   JAI_RGM_INVOICE_GEN_T
  WHERE  order_line_id =  cp_order_line_id;

  -- Check if only 'VAT REVERSAL' tax type is present in JAI_OM_WSH_LINE_TAXES
  CURSOR c_chk_vat_reversal (cp_order_line_id JAI_OM_WSH_LINES_ALL.order_line_id%TYPE
                           , cp_tax_type      JAI_CMN_TAXES_ALL.tax_type%TYPE )
  IS
  SELECT 1
  FROM   JAI_OM_WSH_LINE_TAXES  jsptl
       , JAI_CMN_TAXES_ALL      jtc
  WHERE  jsptl.order_line_id      = cp_order_line_id
    AND  jtc.tax_id               = jsptl.tax_id
    AND  jtc.tax_type             = cp_tax_type;

  CURSOR cur_get_regime_info (cp_organization_id JAI_RGM_ORG_REGNS_V.ORGANIZATION_ID%TYPE
                            , cp_location_id     JAI_RGM_ORG_REGNS_V.LOCATION_ID%TYPE)
  IS
  SELECT regime_id
       , attribute_value
  FROM   JAI_RGM_ORG_REGNS_V orrg
  WHERE  orrg.organization_id    =  cp_organization_id
    AND  orrg.location_id        =  NVL(cp_location_id, cp_organization_id)
    AND  attribute_type_code     =  jai_constants.rgm_attr_type_code_primary
    AND  attribute_code          =  jai_constants.attr_code_regn_no
    AND  regime_code             =  jai_constants.vat_regime;

  CURSOR cur_get_order_header_info
  IS
  SELECT order_type_id
       , order_number
  FROM   oe_order_headers_all
  WHERE  header_id = ln_order_header_id;

  BEGIN
    -- log for debug
    IF( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.String(ln_proc_level
                   , lv_module_prefix || '.' || lv_procedure_name || '.begin'
                   , 'Enter procedure'
                    );
    END IF;  --( lv_proc_level >= ln_dbg_level)

    pv_return_code               := jai_constants.successful ;
    ld_creation_date              := sysdate;
    ln_created_by                 := pr_new.Created_By;
    ld_last_update_date           := pr_new.Last_Update_Date;
    ln_last_updated_by            := pr_new.Last_Updated_By;
    ln_last_update_login          := pr_new.Last_Update_Login;

    ln_order_header_id            := pr_new.Header_Id;
    ln_order_line_id              := pr_new.Line_Id;
    ln_picking_tax_lines_count    := 0;
    ln_fulfill_line_count         := 0;
    ln_selling_price              := 0;
    ln_quantity                   := 0;
    ln_assessable_value           := 0;
    ln_tot_tax_amount             := 0;
    ln_tax_category_id            := 0;
    ln_inventory_item_id          := pr_new.Inventory_Item_Id;
    ln_organization_Id            := pr_new.SHIP_FROM_ORG_ID;
    ln_order_type_id              := 0;
    ln_order_number               := 0;
    lv_subinventory               := pr_new.SUBINVENTORY;
    ln_location_id                := NULL;
    lv_trading_flag               := NULL;
    lv_unit_code                  := pr_new.ORDER_QUANTITY_UOM;
    lv_excise_exempt_type         := NULL;
    lv_excise_exempt_refno        := NULL;
    ld_excise_exempt_date         := NULL;
    ln_org_Id                     := pr_new.ORG_ID;
    ln_customer_id                := pr_new.SOLD_TO_ORG_ID;
    ln_ship_to_org_id             := pr_new.Ship_To_Org_Id;

    ln_vat_assessable_value      := 0;
    lv_vat_invoice_no            := NULL;
    ln_fulfilled_quantity         := pr_new.FULFILLED_QUANTITY;

    -- Start Inserting Tax Lines
    FOR Rec IN Get_Tax_Lines_Details_Cur
    LOOP
      -- Check for the existence of Tax Lines on JAI_OM_WSH_LINE_TAXES
      OPEN Pick_Tax_Line_Count_Cur(rec.tax_id);
      FETCH Pick_Tax_Line_Count_Cur INTO ln_picking_tax_lines_count;
      CLOSE Pick_Tax_Line_Count_Cur;
      IF ln_picking_tax_lines_count = 0
      THEN
        INSERT INTO JAI_OM_WSH_LINE_TAXES(Delivery_Detail_Id
                                        , order_line_id
                                        , Tax_Line_No
                                        , Precedence_1
                                        , Precedence_2
                                        , Precedence_3
                                        , Precedence_4
                                        , Precedence_5
                                        , Precedence_6
                                        , Precedence_7
                                        , Precedence_8
                                        , Precedence_9
                                        , Precedence_10
                                        , Tax_Id
                                        , Tax_Rate
                                        , Qty_Rate
                                        , Uom
                                        , Tax_Amount
                                        , Base_Tax_Amount
                                        , Func_Tax_Amount
                                        , Creation_Date
                                        , Created_By
                                        , Last_Update_Date
                                        , Last_Updated_By
                                        , Last_Update_Login
                                        )
                                 VALUES (NULL -- delivery_detail_id
                                       , ln_order_line_id
                                       , rec.Tax_Line_No
                                       , rec.Precedence_1
                                       , rec.Precedence_2
                                       , rec.Precedence_3
                                       , rec.Precedence_4
                                       , rec.Precedence_5
                                       , rec.Precedence_6
                                       , rec.Precedence_7
                                       , rec.Precedence_8
                                       , rec.Precedence_9
                                       , rec.Precedence_10
                                       , rec.Tax_id
                                       , rec.Tax_rate
                                       , rec.Qty_Rate
                                       , rec.Uom
                                       , rec.tax_amount
                                       , rec.base_tax_amount
                                       , rec.func_tax_amount
                                       , ld_creation_date
                                       , ln_created_by
                                       , ld_last_update_date
                                       , ln_last_updated_by
                                       , ln_last_update_login
                                        );
       ELSE
         UPDATE  JAI_OM_WSH_LINE_TAXES
         SET Tax_Amount                    = rec.tax_amount,
             Last_Update_Date              = ld_last_update_date,
             Last_Updated_By               = ln_last_updated_by,
             Last_Update_Login             = ln_last_update_login
         WHERE ORDER_LINE_ID               = ln_order_line_id
         AND   Tax_Id                      = rec.Tax_Id;
       END IF; -- ln_picking_tax_lines_count = 0
     END LOOP; -- FOR Rec IN Get_Tax_Lines_Details_Cur

     --  Fetch Lines Details from Localization Table
     OPEN Get_So_Lines_Details_Cur;
     FETCH
       Get_So_Lines_Details_Cur
     INTO
       ln_selling_price
     , ln_quantity
     , ln_tax_category_id
     , ln_assessable_value
     , ln_vat_assessable_value
     , lv_excise_exempt_type
     , lv_excise_exempt_refno
     , ld_excise_exempt_date
     , lv_vat_exemption_flag
     , lv_vat_exemption_type
     , ld_vat_exemption_date
     , lv_vat_exemption_refno;
     CLOSE Get_So_Lines_Details_Cur;

     -- Get Total Tax Amount for the Line
     -- for Inserting into JAI_OM_WSH_LINES_ALL Table.
     OPEN Get_Tot_Tax_Amount_Cur;
     FETCH Get_Tot_Tax_Amount_Cur  INTO ln_tot_tax_amount;
     CLOSE Get_Tot_Tax_Amount_Cur;

     --Get The Location Id
     OPEN Location_Cursor;
     FETCH
       Location_Cursor
     INTO
       ln_location_id
     , lv_trading_flag;
     CLOSE Location_Cursor;

     -- get ln_location_id from WSH API if ln_location_id IS NULL
     IF ln_location_id IS NULL
     THEN
       ln_location_id := WSH_UTIL_CORE.Org_To_Location(ln_organization_Id, TRUE);
     END IF; -- ln_location_id IS NULL

     -- Get Order Header Information
     OPEN cur_get_order_header_info;
     FETCH
       cur_get_order_header_info
     INTO
       ln_order_type_id
     , ln_order_number;
     CLOSE cur_get_order_header_info;

     -- Check for fulfilled non-shippable lines existence on JAI_OM_WSH_LINES_ALL Table
     OPEN Get_Fulfill_Line_Count_Cur;
     FETCH Get_Fulfill_Line_Count_Cur INTO  ln_fulfill_line_count;
     CLOSE Get_Fulfill_Line_Count_Cur;
     IF ln_fulfill_line_count = 0
     THEN
       INSERT INTO JAI_OM_WSH_LINES_ALL(Delivery_Detail_Id
                                      , Order_Header_Id
                                      , Order_Line_Id
                                      , split_from_delivery_detail_id
                                      , Selling_Price
                                      , Quantity
                                      , Assessable_value
                                      , vat_assessable_value
                                      , Tax_Category_Id
                                      , Tax_Amount
                                      , Inventory_Item_Id
                                      , Organization_Id
                                      , Location_Id
                                      , Unit_Code
                                      , Excise_Amount
                                      , Basic_Excise_Duty_Amount
                                      , Add_Excise_Duty_Amount
                                      , Oth_Excise_Duty_Amount
                                      , Excise_Exempt_Type
                                      , Excise_Exempt_Refno
                                      , Excise_Exempt_Date
                                      , Creation_Date
                                      , Created_By
                                      , Last_Update_Date
                                      , Last_Updated_By
                                      , Last_Update_Login
                                      , ORG_ID
                                      , CUSTOMER_ID
                                      , SHIP_TO_ORG_ID
                                      , ORDER_TYPE_ID
                                      , SUBINVENTORY
                                      , DELIVERY_ID
                                      , VAT_EXEMPTION_FLAG
                                      , VAT_EXEMPTION_TYPE
                                      , VAT_EXEMPTION_DATE
                                      , VAT_EXEMPTION_REFNO
                                      , Shippable_Flag
                                      )
                               VALUES (NULL   -- delivery_detail_id
                                     , ln_order_header_id
                                     , ln_order_line_id
                                     , NULL   -- split_from_delivery_detail_id
                                     , ln_selling_price
                                     , ln_quantity
                                     , ln_assessable_value
                                     , ln_vat_assessable_value
                                     , ln_tax_category_id
                                     , ln_tot_tax_amount
                                     , ln_inventory_item_id
                                     , ln_organization_Id
                                     , NVL(ln_location_id, ln_organization_Id)
                                     , lv_unit_code
                                     , NULL      -- excise amount should be 0 for non-shippable item
                                     , NULL      -- basic_excise_duty_amount should be 0
                                     , NULL      -- add_excise_duty_amount should be 0
                                     , NULL      -- oth_excise_duty_amount should be 0
                                     , lv_excise_exempt_type
                                     , lv_excise_exempt_refno
                                     , ld_excise_exempt_date
                                     , ld_creation_date
                                     , ln_created_by
                                     , ld_last_update_date
                                     , ln_last_updated_by
                                     , ln_last_update_login
                                     , ln_org_Id
                                     , ln_customer_id
                                     , ln_ship_to_org_id
                                     , ln_order_type_id
                                     , lv_subinventory
                                     , NULL    -- delivery_id
                                     , lv_vat_exemption_flag
                                     , lv_vat_exemption_type
                                     , ld_vat_exemption_date
                                     , lv_vat_exemption_refno
                                     , 'N'     -- shippable_flag
                                      );
      -- check if VAT type of tax exists
      OPEN  cur_chk_vat_exists (cp_order_line_id => ln_order_line_id) ;
      FETCH cur_chk_vat_exists INTO ln_vat_cnt;
      CLOSE cur_chk_vat_exists ;

      OPEN  cur_chk_vat_proc_entry (cp_order_line_id => ln_order_line_id);
      FETCH cur_chk_vat_proc_entry INTO ln_vat_proc_cnt ;
      CLOSE cur_chk_vat_proc_entry;

      -- Check if only 'VAT REVERSAL' tax type is present in JAI_OM_WSH_LINE_TAXES
      IF nvl(ln_vat_cnt,0) = 0
      THEN
        -- If taxes of type 'VAT' are not present
        lv_vat_reversal := 'VAT REVERSAL' ;
        OPEN  c_chk_vat_reversal(cp_order_line_id => ln_order_line_id
                               , cp_tax_type      => lv_vat_reversal);
        FETCH c_chk_vat_reversal INTO ln_vat_reversal_exists;
        CLOSE c_chk_vat_reversal ;

        /*
        || VAT invoice number should be punched as 'NA' and accounting should happen
        || when 'VAT REVERSAL' type of tax exist and 'VAT' type of tax(es) doesn't exist
        */
        lv_vat_invoice_no     := jai_constants.not_applicable ;
        lv_vat_inv_gen_status := 'C' ;
      END IF ; -- nvl(ln_vat_cnt,0) = 0

      -- If taxes of 'VAT' type (or) taxes of 'VAT REVERSAL' type exists
      IF (nvl(ln_vat_cnt,0) > 0 OR nvl(ln_vat_reversal_exists,0) = 1 ) AND nvl (ln_vat_proc_cnt,0) = 0
      THEN
        /* VAT type of tax exists*/
        /* Get the regime id for these type of taxes */
        OPEN  cur_get_regime_info (cp_organization_id => ln_organization_Id
                                 , cp_location_id     => ln_location_id
                                  );
        FETCH
          cur_get_regime_info
        INTO ln_regime_id
           , lv_regns_num;
        CLOSE cur_get_regime_info;

        INSERT INTO JAI_RGM_INVOICE_GEN_T ( regime_id
                                          , delivery_id
                                          , delivery_date
                                          , order_line_id
                                          , order_number
                                          , customer_trx_id
                                          , organization_id
                                          , location_id
                                          , registration_num
                                          , vat_invoice_no
                                          , vat_inv_gen_status
                                          , vat_inv_gen_err_message
                                          , vat_acct_status
                                          , vat_acct_err_message
                                          , request_id
                                          , program_application_id
                                          , program_id
                                          , program_update_date
                                          , party_id
                                          , party_site_id
                                          , party_type
                                          , creation_date
                                          , created_by
                                          , last_update_date
                                          , last_update_login
                                          , last_updated_by
                                          )
                              VALUES       (ln_regime_id
                                         ,  NULL                          -- delivery_id
                                         ,  ld_creation_date -- delivery_date, for nonshippable it should be fulfilled date
                                         ,  ln_order_line_id
                                         ,  ln_order_number
                                         ,  NULL                          -- customer_trx_id
                                         ,  ln_organization_Id
                                         ,  NVL(ln_location_id, ln_organization_Id)
                                         ,  lv_regns_num
                                         ,  lv_vat_invoice_no
                                         ,  nvl(lv_vat_inv_gen_status, 'P')
                                         ,  NULL                          -- vat_inv_gen_err_message
                                         ,  'P'                           -- vat_acct_status
                                         ,  NULL                          -- vat_acct_err_message
                                         ,  NULL                          -- request_id
                                         ,  NULL                          -- program_application_id
                                         ,  NULL                          -- program_id
                                         ,  NULL                          -- program_update_date
                                         ,  ln_customer_id                -- party_id
                                         ,  pr_new.invoice_to_org_id      -- party_site_id
                                         ,  jai_constants.party_type_customer
                                         ,  ld_creation_date
                                         ,  ln_created_by
                                         ,  ld_last_update_date
                                         ,  ln_last_update_login
                                         ,  ln_last_updated_by
                                          );

      END IF; -- (nvl(ln_vat_cnt,0) > 0 OR ......
    ELSE
      UPDATE    JAI_OM_WSH_LINES_ALL
      SET       quantity                        = ln_fulfilled_quantity,
                tax_amount                      = ln_tot_tax_amount,
                order_line_id                   = ln_order_line_id,
                excise_amount                   = NULL,
                basic_excise_duty_amount        = NULL,
                add_excise_duty_amount          = NULL,
                oth_excise_duty_amount          = NULL,
                last_update_date                = ld_last_update_date,
                last_updated_by                 = ln_last_updated_by,
                last_update_login               = ln_last_update_login,
                VAT_EXEMPTION_FLAG              = lv_vat_exemption_flag,
                VAT_EXEMPTION_TYPE              = lv_vat_exemption_type,
                VAT_EXEMPTION_DATE              = ld_vat_exemption_date,
                VAT_EXEMPTION_REFNO             = lv_vat_exemption_refno
      WHERE     order_line_id                   = ln_order_line_id;
    END IF;  -- ln_fulfill_line_count = 0

    -- log for debug
    IF( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.String(ln_proc_level
                   , lv_module_prefix || '.' || lv_procedure_name || '.end'
                   , 'Exit procedure'
                    );
    END IF;  --( lv_proc_level >= ln_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      pv_return_code := jai_constants.expected_error ;
      pv_return_message := substr(sqlerrm,1,200) ;
      RETURN ;
  END ARIU_T2;

  /*
REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OE_OLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OE_OLA_ARU_T2
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_row_id                                      ROWID;
  v_sid                                 NUMBER;
  v_line_id                             NUMBER; --File.Sql.35 Cbabu   := pr_new.line_id;
  v_header_id                           NUMBER; --File.Sql.35 Cbabu   := pr_new.header_id;
  v_warehouse_id                                NUMBER ; --File.Sql.35 Cbabu  := pr_new.SHIP_FROM_ORG_ID;
  v_quantity                            NUMBER ; --File.Sql.35 Cbabu          :=NVL(pr_new.ordered_quantity,0);
  v_last_update_date                    DATE ; --File.Sql.35 Cbabu            := pr_new.last_update_date;
  v_last_updated_by                     NUMBER ; --File.Sql.35 Cbabu  := pr_new.last_updated_by;
  v_last_update_login                   NUMBER ; --File.Sql.35 Cbabu  := pr_new.last_update_login;
  v_line_amount                         NUMBER; --File.Sql.35 Cbabu   :=  NVL(v_quantity,0)   *  NVL(pr_new.UNIT_selling_price,0);
  v_ato_line_id                         NUMBER ; --File.Sql.35 Cbabu  :=  NVL(pr_new.ato_line_id,pr_new.TOP_MODEL_LINE_ID);
  v_inventory_item_id                   NUMBER; --File.Sql.35 Cbabu   := pr_new.inventory_item_id;
  v_uom_code                            VARCHAR2(3); --File.Sql.35 Cbabu  := pr_new.ORDER_QUANTITY_UOM;
  v_ship_to_site_use_id                 NUMBER; --File.Sql.35 Cbabu   :=  NVL(pr_new.SHIP_TO_ORG_ID,0);
  v_selling_price                               NUMBER; --File.Sql.35 Cbabu   := pr_new.UNIT_SELLING_PRICE;
  v_ato_assessable_value                NUMBER; --File.Sql.35 Cbabu   := 0;
  v_old_assessable_value                NUMBER; --File.Sql.35 Cbabu   := 0;
  v_tax_amount                          NUMBER; --File.Sql.35 Cbabu   := 0;
  v_line_tax_amount                     NUMBER; --File.Sql.35 Cbabu   := 0;
  v_func_tax_amount                     NUMBER; --File.Sql.35 Cbabu   := 0;
  v_assessable_amount                   NUMBER; --File.Sql.35 Cbabu   := 0;
  v_conversion_rate                     NUMBER; --File.Sql.35 Cbabu   := 0;
  v_ato_line_amount                     NUMBER; --File.Sql.35 Cbabu   := 0;
  v_ato_old_assessable_value            NUMBER; --File.Sql.35 Cbabu   := 0;
  v_line_flag                           NUMBER; --File.Sql.35 Cbabu   := 0;
  v_diff_selling_price          NUMBER; --File.Sql.35 Cbabu   := 0;
  v_date_ordered                                DATE;
  v_assessable_value                    NUMBER;
  v_price_list_uom_code                 VARCHAR2(10);
  v_org_id                                      NUMBER;
  v_set_of_books_id                     NUMBER;
  v_conv_type_code                      VARCHAR2(30);
  v_conv_rate                           NUMBER;
  v_conv_date                           DATE;
  v_conv_factor                         NUMBER;
  v_old_quantity                                NUMBER;
  v_price_list_id                               NUMBER;
  v_customer_id                         NUMBER;
  v_address_id                          NUMBER;
  ln_inventory_item_id                  NUMBER;  --added for bug#9067808
  ln_line_id                            NUMBER;  --added for bug#9067808


  /* Bug 5095812. Added by Lakshmi Gopalsami */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

  CURSOR JAI_OM_OE_SO_LINES_cur(p_line_id NUMBER) IS
  SELECT        quantity,
                --selling_price,
                assessable_value,
                --line_amount
                excise_exempt_type,
                excise_exempt_refno,
    vat_reversal_price --Date 14/06/2007 by sacsethi for bug 6072461
  FROM          JAI_OM_OE_SO_LINES
  WHERE         line_id = p_line_id;

  CURSOR c_ja_in_rma_lines (p_line_id NUMBER) IS
  SELECT        quantity,
                assessable_value
  FROM          JAI_OM_OE_RMA_LINES
  WHERE         rma_line_id = p_line_id;



  CURSOR bind_cur(p_header_id NUMBER) IS
  SELECT        org_id,
                ROWID,
                TRANSACTIONAL_CURR_CODE,
                conversion_type_code,
                conversion_rate,
                CONVERSION_RATE_DATE,
                SOLD_TO_ORG_ID,
                price_list_id,
                NVL(ORDERED_DATE, creation_date)
    FROM  OE_ORDER_HEADERS_ALL
   WHERE  header_id = p_header_id;

  CURSOR address_cur(p_ship_to_org_id IN NUMBER) IS
  SELECT   NVL(cust_acct_site_id, 0) address_id
  FROM     HZ_CUST_SITE_USES_ALL A /*Removed ra_site_uses_all for Bug# 4434287 */
  WHERE    A.site_use_id = p_ship_to_org_id; /* Modified by Ramananda for removal of SQL LITERALs */
--  WHERE  A.site_use_id = NVL(p_ship_to_org_id,0);

-- to get assesable_value

CURSOR Get_Assessable_Value_Cur (p_customer_id          NUMBER,
        p_address_id            NUMBER,
        p_inventory_item_id     NUMBER,
        p_uom_code                      VARCHAR2,
        p_ordered_date          DATE     )IS
  SELECT        b.operand list_price,
                c.product_uom_code list_price_uom_code
    FROM        JAI_CMN_CUS_ADDRESSES a,
                QP_LIST_LINES b,
                qp_pricing_attributes c
   WHERE        a.customer_id           = p_customer_id
     AND        a.address_id            = p_address_id
     AND        a.price_list_id                 = b.LIST_header_ID
     AND        c.list_line_id          = b.list_line_id
     AND        c.PRODUCT_ATTR_VALUE    = TO_CHAR(p_inventory_item_id)
--   AND        c.product_uom_code      = p_uom_code                               --2001/10/09 Anuradha Parthasarathy
     AND        (b.end_date_active is null
                 OR
    b.end_date_active >= p_ordered_date);  /* Modified by Ramananda for removal of SQL LITERALs */
--   AND        NVL(b.end_date_active,SYSDATE) >= p_ordered_date;

    /* Bug 5095812. Added by Lakshmi Gopalsami
       Removed the cursor set_of_books_cur and implemented
       the same using plsql cache.
    */


  CURSOR order_tax_amount_Cur IS
  SELECT        SUM(a.tax_amount)
  FROM          JAI_OM_OE_SO_TAXES a,
                JAI_CMN_TAXES_ALL b
  WHERE         a.Header_ID = v_header_id
        AND     a.line_id = v_line_id
        AND     b.tax_id = a.tax_id
        AND     b.tax_type <> 'TDS';

  CURSOR Ato_line_info_cur IS
  SELECT      assessable_value,
              quantity
  FROM        JAI_OM_OE_SO_LINES
  WHERE       shipment_schedule_line_id = v_line_id; /* Modified by Ramananda for removal of SQL LITERALs */
--  WHERE       NVL(shipment_schedule_line_id,0) = v_line_id;

  CURSOR   so_lines_count IS
  SELECT COUNT(*)
  FROM   JAI_OM_OE_SO_LINES
  WHERE   header_id = v_header_id;

  v_count    NUMBER;

 v_operating_id                     NUMBER; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
 v_gl_set_of_bks_id                 gl_sets_of_books.set_of_books_id%TYPE;
 v_currency_code                    gl_sets_of_books.currency_code%TYPE;

  v_excise_exempt_type   varchar2(60); -- sriram - bug # 2672114
  v_excise_exempt_refno  varchar2(30); -- sriram - bug # 2672114

 -- cursor added by sriram for ato support during partial shipment - Bug # 2806274

 Cursor c_get_loc_record is
 select selling_price , assessable_value
 from   JAI_OM_OE_SO_LINES
 where  header_id = pr_new.header_id
 and    line_id = pr_new.line_id ;

 v_loc_selling_price     Number;
 v_loc_assessable_value  Number;

 ln_vat_assessable_value JAI_OM_OE_SO_LINES.VAT_ASSESSABLE_VALUE%TYPE;

 ln_vat_reversal_price JAI_OM_OE_SO_LINES.vat_reversal_price%TYPE; --Date 14/06/2007 by sacsethi for bug 6072461
 --added for bug#9067808,start
 ln_ordered_qty NUMBER ;

 PROCEDURE calc_price_tax_for_config_item (p_header_id number, p_line_id number)
 is
   CURSOR c_get_line_tax_amt is
   SELECT  line_amount, tax_amount, selling_price,
           assessable_value, decode(quantity,0,1,quantity) quantity, vat_assessable_value
   FROM    JAI_OM_OE_SO_LINES
   WHERE   header_id = p_header_id
   AND     shipment_schedule_line_id  = pr_new.ato_line_id
   AND     line_id <> p_line_id ;
 BEGIN

   v_selling_price         := 0 ;
   v_assessable_value      := 0 ;
   ln_vat_assessable_value := 0 ;
   v_ato_line_amount       := 0 ;

   IF nvl(pr_new.ordered_quantity,0) = 0 THEN
     ln_ordered_qty := 1 ;
   ELSE
     ln_ordered_qty := pr_new.ordered_quantity ;
   END IF ;

   FOR so_lines_rec in c_get_line_tax_amt
   LOOP
      v_ato_line_amount           := NVL(v_ato_line_amount,0) + NVL(so_lines_rec.line_amount,0);

      v_selling_price         := NVL(v_selling_price,0)
                                  + (( NVL(so_lines_rec.selling_price,0) * so_lines_rec.quantity ) / ln_ordered_qty) ;

      v_assessable_value      := NVL(v_assessable_value,0)
                                  + (( NVL(so_lines_rec.assessable_value,so_lines_rec.selling_price) * so_lines_rec.quantity ) / ln_ordered_qty) ;

      ln_vat_assessable_value := NVL(ln_vat_assessable_value,0)
                                  + (( NVL(so_lines_rec.vat_assessable_value,so_lines_rec.selling_price) * so_lines_rec.quantity ) / ln_ordered_qty) ;
   END LOOP;
 END;
 /* Added for bug#6164511, Ends */

 /*added for bug#7194468,start*/
 PROCEDURE get_config_item(p_line_id OUT NOCOPY NUMBER,
                           p_inventory_item_id OUT NOCOPY NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   CURSOR cur_get_line_id IS
   SELECT
          line_id, inventory_item_id
   FROM
          oe_order_lines_all
   WHERE
          header_id = pr_new.Header_id
     and  top_model_line_id = pr_new.top_model_line_id
     and  item_type_code = 'CONFIG';

 BEGIN

   OPEN  cur_get_line_id ;
   FETCH cur_get_line_id INTO p_line_id,  p_inventory_item_id;
   CLOSE cur_get_line_id ;

 END get_config_item ;
 --bug#9067808,end

--2001/06/14    Jagdish,Gadde
  BEGIN
    pv_return_code := jai_constants.successful ;
  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_OE_ORDER_LINES_AU_TRG'   ,
  --                 p_org_id              =>  pr_new.org_id
  --                               )  = FALSE
  --THEN
    /*
  || return as the current set of books is NON-INR based
  */
   -- RETURN;
  --END IF;

  --File.Sql.35 Cbabu
  v_line_id                             := pr_new.line_id;
  v_header_id                           := pr_new.header_id;
  v_warehouse_id                        := pr_new.SHIP_FROM_ORG_ID;
  v_quantity                            :=NVL(pr_new.ordered_quantity,0);
  v_last_update_date                    := pr_new.last_update_date;
  v_last_updated_by                     := pr_new.last_updated_by;
  v_last_update_login                   := pr_new.last_update_login;
  v_line_amount                         :=  NVL(v_quantity,0) * NVL(pr_new.UNIT_selling_price,0);
  v_ato_line_id                         :=  NVL(pr_new.ato_line_id,pr_new.TOP_MODEL_LINE_ID);
  v_inventory_item_id                   := pr_new.inventory_item_id;
  v_uom_code                            := pr_new.ORDER_QUANTITY_UOM;
  v_ship_to_site_use_id                 :=  NVL(pr_new.SHIP_TO_ORG_ID,0);
  v_selling_price                       := pr_new.UNIT_SELLING_PRICE;
  v_ato_assessable_value               := 0;
  v_old_assessable_value               := 0;
  v_tax_amount                         := 0;
  v_line_tax_amount                    := 0;
  v_func_tax_amount                    := 0;
  v_assessable_amount                  := 0;
  v_conversion_rate                    := 0;
  v_ato_line_amount                    := 0;
  v_ato_old_assessable_value           := 0;
  v_line_flag                          := 0;
  v_diff_selling_price                 := 0;
  v_operating_id                       :=pr_new.ORG_ID;



    --IF v_ato_line_id IS NULL   COMMENTED BY SRIRAM BUG # 2436438
    -- THEN                                               --1

    -- the following if condition "   if pr_new.LINE_CATEGORY_CODE  = 'RETURN' then " added by sriram
    -- for the fix of bug # 3181926
    -- When a Legacy return order is created and line saved and if quantity is changed , this trigger was throwing up
    -- an exception - DIVIDE BY ZERO .The reason for this is that the cursor which fetches the old quantity and old
    -- assessable value fetched the values from the JAI_OM_OE_SO_LINES table. For a return order , this is not relevant
    -- as the JAI_OM_OE_SO_LINES has no records for a return order and instead records are present in the JAI_OM_OE_RMA_LINES
    -- table.
    -- code added by sriram includes adding the if statement below , adding the elsif condition and opening the cursor
    -- c_ja_in_rma_lines  . This cursor definition also has been added by sriram.
/*bduvarag for the bug#5256498 start*/
/*Commented by nprashar for bug # 7313479
  If pr_new.line_category_code = 'RETURN' AND pr_new.return_context IS NOT NULL THEN --Bgowrava, for Bug#6126581, added IS NOT NULL
    return;
  end if; */
/*bduvarag for the bug#5256948 end*/

    if pr_new.LINE_CATEGORY_CODE  = 'RETURN' then
        OPEN  c_ja_in_rma_lines (v_line_id);
        FETCH c_ja_in_rma_lines  INTO v_old_quantity, v_old_assessable_value;
        CLOSE c_ja_in_rma_lines ;
    else
        OPEN  JAI_OM_OE_SO_LINES_cur(v_line_id);
        FETCH JAI_OM_OE_SO_LINES_cur INTO v_old_quantity, v_old_assessable_value,
        v_excise_exempt_type,  -- added by sriram - bug # 2672114
        v_excise_exempt_refno, -- added by sriram - bug # 2672114
  ln_vat_reversal_price ;  --Date 14/06/2007 by sacsethi for bug 6072461
        CLOSE JAI_OM_OE_SO_LINES_cur;
    end if;

    --END IF;                                              --1

    OPEN Bind_Cur(v_header_id);
    FETCH Bind_Cur INTO v_org_id, v_row_id, v_currency_code, v_conv_type_code,
    v_conv_rate, v_conv_date, v_customer_id, v_price_list_id, v_date_ordered;
    CLOSE Bind_Cur;

    IF v_conv_date IS NULL THEN                                    --2
        v_conv_date := v_date_ordered;
    END IF;                                        --2

    /*
       Bug 5095812. Added by Lakshmi Gopalsami
       Removed the cursor set_of_books_cur and added the following check
       using plsql caching for performance issues reported.
    */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_warehouse_id);
    v_set_of_books_id := l_func_curr_det.ledger_id;

    v_conv_factor := jai_cmn_utils_pkg.currency_conversion( v_set_of_books_id ,
                                   v_currency_code   ,
                                   v_conv_date       ,
                                   v_conv_type_code  ,
                                   v_conv_rate
                                 );
    -- End, cbabu for Bug# 2767520

    OPEN address_cur( v_ship_to_site_use_id);
    FETCH address_cur INTO v_address_id;
    CLOSE address_cur;

    --The Logic of Fetching the Assessable Value is written in the Function jai_om_utils_pkg.get_oe_assessable_value.
    --Incorporated this by Nagaraj.s for Bug3700249
    v_assessable_value := jai_om_utils_pkg.get_oe_assessable_value
                            (
                                p_customer_id         => v_customer_id,
                                p_ship_to_site_use_id => v_ship_to_site_use_id,
                                p_inventory_item_id   => v_inventory_item_id,
                                p_uom_code            => v_uom_code,
                                p_default_price       => pr_new.unit_selling_price,
                                p_ass_value_date      => v_date_ordered,
        /* Bug 5096787. Added by Lakshmi Gopalsami */
        p_sob_id              => v_set_of_books_id ,
        p_curr_conv_code      => v_conv_type_code  ,
        p_conv_rate           => v_conv_factor
                            );

    ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                (
                                 p_party_id           => v_customer_id          ,
                                 p_party_site_id      => v_ship_to_site_use_id  ,
                                 p_inventory_item_id  => v_inventory_item_id    ,
                                 p_uom_code           => v_uom_code             ,
                                 p_default_price      => pr_new.unit_selling_price,
                                 p_ass_value_date     => v_date_ordered         ,
                                 p_party_type         => 'C'
                                );

   ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * NVL(v_quantity,0);
   ln_vat_reversal_price   := nvl(ln_vat_reversal_price,0) * NVL(v_quantity,0); --Date 14/06/2007 by sacsethi for bug 6072461

        -- additions by sriram for ato Bug # 2806274
        if NVL(pr_new.item_type_code,'$$$') = 'CONFIG' then

            open  c_get_loc_record;
            fetch c_get_loc_record into v_loc_selling_price, v_loc_assessable_value;
            close c_get_loc_record;
            v_assessable_value := v_loc_assessable_value;
        else

            /*
            This code has been added by aiyer for the fix of the bug #2895512. File Version 615.7

            Functional Description:-
            During partial shipment, if the assessable price list setup has been removed after booking an order then
            during the excise duty recalculation, the assessable value (which would be found as null in the setup ) should be taken from the
            JAI_OM_OE_SO_LINES table and if this too happens to be null then only should it be assigned as nvl(pr_new.unit_selling_price).

            Technical Description:-
            Check whether the assessable value is null in the table JAI_OM_OE_SO_LINES
            IF
            no then assign this value to the v_assessable_value variable
            ELSE
            Assign the assign the nvl(pr_new.unit_selling_price) to the v_assessable_value variable.
            */

            IF NVL(pr_new.Ordered_Quantity,0) <> NVL(pr_old.Ordered_quantity,0) AND
               pr_new.flow_status_code = 'AWAITING_SHIPPING'
            THEN -- bug # 3168589
                 /*
                only when there is a partial shipment , do the calculation of assessable value based on
                price of the actual price list.
                */

                DECLARE

                    CURSOR rec_get_assessable_value
                    IS
                    SELECT
                    assessable_value
                    FROM
                    JAI_OM_OE_SO_LINES
                    WHERE
                    line_id = v_line_id;

                    cur_rec_get_assessable_value rec_get_assessable_value%ROWTYPE;
                BEGIN
    pv_return_code := jai_constants.successful ;


                    if v_assessable_value IS NOT NULL THEN -- added by sriram - 1/9/03 - bug # 3123141

                        OPEN  rec_get_assessable_value;
                        FETCH rec_get_assessable_value INTO cur_rec_get_assessable_value;

                        IF cur_rec_get_assessable_value.assessable_value IS NOT NULL THEN
                            v_assessable_value  := cur_rec_get_assessable_value.assessable_value;
                        ELSE
                            v_assessable_value  := NVL(pr_new.UNIT_SELLING_PRICE,0);
                        END IF;

                        CLOSE rec_get_assessable_value;
                    end if; -- added by sriram -- 1/9/03 - bug # 3123141
                END;

            end if;

        end if; -- added by sriram - bug # 3168589
               -- additions by sriram for ato ends here Bug # 2806274

        v_assessable_amount := NVL(v_assessable_value,0) * NVL(v_quantity,0);
        --              END IF;                                                                 --13
        IF v_assessable_amount = 0
        THEN                                                                            --14

            v_assessable_amount := NVL(v_line_Amount,0);
        END IF;                                                                 --14

        -- additions by sriram for ato starts here
        if NVL(v_line_Amount,0) = 0 then
            v_line_amount := v_quantity * v_loc_selling_price;
        end if;
        -- additions by sriram for ato ends here

        v_line_tax_amount:=v_line_amount;-- 2001/04/15  Manohar Mishra

        -- added by sriram - bug # 2672114
        if v_excise_exempt_refno is not null and v_excise_exempt_type is not null then
            v_assessable_amount :=0;
        end if;

        --added for bug#9067808, start
        IF upper(pr_new.item_type_code) = 'CONFIG' AND
           pr_new.line_category_code   <> 'RETURN'
        THEN
           calc_price_tax_for_config_item(pr_new.header_id, pr_new.line_id );
        END IF ;
        --bug#9067808, end


        jai_om_tax_pkg.calculate_ato_taxes('OE_LINES_UPDATE' ,
            NULL,
            v_header_id,
            v_line_id,
            v_assessable_amount,
            v_line_tax_amount,
            v_conv_factor,
            v_inventory_item_id ,
            NVL(v_old_quantity,0),
            v_quantity,
            v_uom_code ,
            NULL ,
            NULL ,
            NULL ,
            NULL,
            v_last_update_date ,
            v_last_updated_by ,
            v_last_update_login ,
            ln_vat_assessable_value ,
            ln_vat_reversal_price   -- Date 14/06/2007 by sacsethi for bug 6072461
            );
        /* Commented by aiyer for the bug 5401180
        --if nvl(pr_new.Return_context, 'XXX') <> 'LEGACY' then             -- cbabu for Bug# 2794203
        */
          IF pr_new.line_category_code = 'ORDER' THEN /*added by aiyer for the bug 5401180. Replaced nvl(pr_new.return_context,'XXX') <> 'LEGACY' with this */
            /*
            || Start of bug 4566002
            || Code modified for bug 4566002
            || Added the VAT assessable value in the update to jai_om_oe_so_lines table
            */
            UPDATE  jai_om_oe_so_lines
            SET
                  quantity                  =   v_quantity                                ,
                  unit_code                 =   v_uom_code                                , --Added by Nagaraj.s for Bug#3402260
                  selling_price             =   v_selling_price                           ,
                  assessable_value          =   nvl(v_assessable_value,v_selling_price)   ,
                  vat_assessable_value      =   nvl(ln_vat_assessable_value,0)            ,
                  tax_amount                =   NVL(v_line_tax_amount,0)                  ,
                  line_amount               =   v_line_amount                             ,
                  line_tot_amount           =   v_line_amount + NVL(v_line_tax_amount,0)  ,
                  last_update_date          =   v_last_update_date                        ,
                  last_updated_by           =   v_last_updated_by                         ,
                  last_update_login         =   v_last_update_login
            WHERE
                  line_id                   =   v_line_id;
           /*
           || End of bug 4566002
           */

           -- bug#9067808,start
           IF (upper(pr_new.item_type_code) <> 'CONFIG' AND
               pr_new.unit_selling_price <> pr_old.unit_selling_price) THEN

              get_config_item ( ln_line_id, ln_inventory_item_id);

              IF ln_line_id is not null THEN
                calc_price_tax_for_config_item(pr_new.header_id, ln_line_id );
                v_line_tax_amount := v_ato_line_amount;
                v_assessable_amount := NVL(v_assessable_value,0) * NVL(v_quantity,0);
                jai_om_tax_pkg.calculate_ato_taxes('OE_LINES_UPDATE' ,
                                      NULL,
                                      v_header_id,
                                      ln_line_id,
                                      v_assessable_amount,
                                      v_line_tax_amount,
                                      v_conv_factor,
                                      ln_inventory_item_id ,
                                      NVL(v_quantity,0),
                                      v_quantity,
                                      v_uom_code ,
                                      NULL ,
                                      NULL ,
                                      NULL ,
                                      NULL,
                                      v_last_update_date ,
                                      v_last_updated_by ,
                                      v_last_update_login ,
                                      ln_vat_assessable_value,
                                      ln_vat_reversal_price
                                      );

                UPDATE JAI_OM_OE_SO_LINES
                   SET quantity                  = v_quantity,
                       unit_code                 = v_uom_code, --Added by Nagaraj.s for Bug#3402260
                       selling_price             = v_selling_price,
                       assessable_value          = nvl(v_assessable_value,v_selling_price),
                       vat_assessable_value      = nvl(ln_vat_assessable_value,0),
                       tax_amount                = NVL(v_line_tax_amount,0),
                       line_amount               = v_ato_line_amount,
                       line_tot_amount           = v_ato_line_amount + NVL(v_line_tax_amount,0),
                       last_update_date          = v_last_update_date,
                       last_updated_by           = v_last_updated_by,
                       last_update_login         = v_last_update_login
                 WHERE line_id             = ln_line_id;

              END IF;
           END IF;
           --bug#9067808,end

        ELSIF pr_new.line_category_code = 'RETURN' THEN /*added by aiyer for the bug 5401180. Replaced return_context = legacy with this */
          UPDATE
                jai_om_oe_rma_lines
          SET
                quantity            = v_quantity                ,
    uom                 = v_uom_code, --bug#8413915
                selling_price       = v_selling_price           ,
                assessable_value    = v_assessable_value        ,
                tax_amount          = NVL(v_line_tax_amount,0)  ,
                inventory_item_id   = v_inventory_item_id       ,   -- Added by Sanjikum for Bug #4029476, as Item was not getting updated
                last_update_date    = v_last_update_date        ,
                last_updated_by     = v_last_updated_by         ,
                last_update_login   = v_last_update_login
        WHERE
                rma_line_id         =     v_line_id;

        END IF;

        -- END IF; -- end if commented by sriram bug # 2436438 03-JUL-02
  /* Added an exception block by Ramananda for bug#4570303 */
  EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_OE_OLA_TRIGGER_PKG.ARU_T1 '  || substr(sqlerrm,1,1900);

  END ARU_T1 ;
--==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Model_line_Detail                    Private
  --
  --  DESCRIPTION:
  --    Return the ATO model line detail
  --
  --  PARAMETERS:
  --      In:   pn_header_id IN NUMBER
  --            pn_line_id   IN NUMBER
  --
  --      OUT:   xn_organization_id   OUT NUMBER
  --             xn_inventory_item_id OUT NUMBER
  --
  --  DESIGN REFERENCES:
  --
  --  CHANGE HISTORY:
  --
  --           04-June-2010   Eric Ma  created
  --==========================================================================


  PROCEDURE Get_Model_line_Detail
  ( pn_header_id IN NUMBER
  , pn_line_id   IN NUMBER
  , xn_organization_id   OUT NOCOPY NUMBER
  , xn_inventory_item_id OUT NOCOPY NUMBER
  )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR Get_model_line_dtls_cur
    IS
    SELECT
      ship_from_org_id, inventory_item_id
    FROM
      OE_ORDER_LINES_ALL
    WHERE header_id = pn_header_id
      AND line_id   = pn_line_id;
  BEGIN
    OPEN  Get_model_line_dtls_cur;
    FETCH Get_model_line_dtls_cur
     INTO xn_organization_id,xn_inventory_item_id;
    CLOSE Get_model_line_dtls_cur;
  EXCEPTION
  WHEN OTHERS
  THEN
    RAISE;
  END Get_Model_line_Detail;


  /*
  REM +======================================================================+
  REM NAME          BRIU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OE_OLA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OE_OLA_BRIU_T6
  REM
  REM +======================================================================+
  */
PROCEDURE BRIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_exist_ship                  NUMBER; --2002/03/08 Gadde Srinivas

  CURSOR get_count IS
  SELECT COUNT(*)
  FROM JAI_OM_WSH_LINES_ALL
  WHERE order_line_id = pr_new.reference_line_id;

/*
  This code has been added by aiyer for the fix of the bug #2855855
  get the delivery_detail_id from wsh_delivery_details table
*/

CURSOR cur_get_delivery_detail_id
IS
SELECT
        delivery_detail_id
FROM
        wsh_delivery_details
WHERE
        source_header_id   = pr_new.reference_header_id       AND
        source_line_id     = pr_new.reference_line_id        AND
        inventory_item_id  = pr_new.inventory_item_id        AND
        shipped_quantity   IS NOT NULL;

l_new_delivery_detail_id WSH_DELIVERY_DETAILS.DELIVERY_DETAIL_ID%TYPE;

-- code added by sriram - bug # 2993645

Cursor c_ordered_date_cur is
select
  ordered_date
from
  oe_order_headers_all
where
  header_id = pr_new.header_id;

-- following cursor is used to get the ship confirm date based on the delivery detail id

cursor c_confirmed_date (p_delivery_Detail_id Number) is
select
  confirm_date
FROM
  wsh_delivery_details     wdd,
  wsh_delivery_assignments wda,
  wsh_new_deliveries       wnd
WHERE
  wdd.delivery_detail_id = (p_delivery_Detail_id)
AND
  wda.delivery_detail_id = wdd.delivery_detail_id
AND
  wnd.delivery_id = wda.delivery_id;

Cursor c_hr_organizations_cur is
SELECT
   excise_return_days,
   sales_return_days
FROM
   JAI_CMN_INVENTORY_ORGS
WHERE
   organization_id = pr_new.ship_from_org_id
AND location_id = 0;

/*added for bug#8485149,start*/
Cursor cur_chk_item_dtls ( cp_organization_id IN NUMBER,
                           cp_inventory_item_id IN NUMBER)
IS
  SELECT 1
  FROM JAI_INV_ITM_SETUPS
  WHERE ORGANIZATION_ID = cp_organization_id
  AND   inventory_item_id = cp_inventory_item_id;

/*
CURSOR cur_get_model_line_dtls (cp_header_id IN NUMBER,
                                cp_line_id IN NUMBER)
IS
  SELECT ship_from_org_id, inventory_item_id
  FROM OE_ORDER_LINES_ALL
  WHERE header_id = cp_header_id
  AND   line_id = cp_line_id;
*/

ln_organization_id NUMBER;
ln_inventory_item_id NUMBER;
ln_item_exists NUMBER;
/*bug#8485149,end*/

v_ordered_Date  oe_order_headers_all.ordered_date%type;
v_confirm_date  wsh_new_deliveries.confirm_date%type;
v_excise_return_days Number;
v_sales_return_days  Number;

-- ends here additions by sriram - bug # 2993645

/* Added by Brathod for bug# 4244829 */
CURSOR get_order_source_type(cp_source_document_type_id NUMBER) IS
  SELECT name
  FROM oe_order_sources
  WHERE order_source_id = cp_source_document_type_id;

  V_Order_Source_Type OE_ORDER_SOURCES.NAME%TYPE;
/* End Bug# 4244829 */

/* Added for DFF Elimination by Ramananda. Bug#4348749 */
  cursor c_rma_line_dtls(cp_rma_line_id in number) is
    select delivery_detail_id, nvl(allow_excise_credit_flag, 'N') allow_excise_credit_flag  , nvl(allow_sales_credit_flag, 'N') allow_sales_credit_flag,
        rate_per_unit, excise_duty_rate
    from JAI_OM_OE_RMA_LINES
    where rma_line_id = cp_rma_line_id;

  ln_delivery_detail_id number;
  lv_allow_excise_flag  varchar2(1);
  lv_allow_sales_flag  varchar2(1);
  ln_excise_duty_per_unit  number;
  ln_excise_duty_rate number;
  BEGIN
    pv_return_code := jai_constants.successful ;

  OPEN  Get_Count;
  FETCH Get_Count INTO v_exist_ship;
  CLOSE Get_Count;
  /*added for bug#8485149,start*/
  If pr_new.item_type_code = 'CONFIG' and pr_new.ato_line_id is not null THEN
    OPEN cur_chk_item_dtls (pr_new.SHIP_from_ORG_ID, pr_new.inventory_item_id);
    FETCH cur_chk_item_dtls INTO ln_item_exists;
    CLOSE cur_chk_item_dtls;

    IF nvl(ln_item_exists,0) <> 1 THEN
    /*  Commented out the below section of code by Eric Ma for bug 9768133 on Jun-02
     *  The firing table is on OE_ORDER_LINES_ALL. The firing table accessing in the
     *  trigger in the enven of UPDATING will cause table mutating error. So use an
     *  AUTONOMOUS transaction to resolve the issue.
     */

    /*
      OPEN cur_get_model_line_dtls(pr_new.header_id, pr_new.ato_line_id);
      FETCH cur_get_model_line_dtls INTO ln_organization_id,ln_inventory_item_id;
      CLOSE cur_get_model_line_dtls;
    */


      --Added by eric ma for bug 9768133 on Jun-04,begin
      ---------------------------------------------------
      Get_Model_line_Detail ( pn_header_id         => pr_new.header_id
                            , pn_line_id           => pr_new.ato_line_id
                            , xn_organization_id   => ln_organization_id
                            , xn_inventory_item_id => ln_inventory_item_id
                            );
      ---------------------------------------------------
      --Added by eric ma for bug 9768133 on Jun-04,End


      --this is for excise attributes
      jai_inv_items_pkg.copy_items(pn_organization_id           =>  pr_new.SHIP_from_ORG_ID,
                                   pn_inventory_item_id         =>  pr_new.inventory_item_id,
                                   pn_source_organization_id    =>  ln_organization_id,
                                   pn_source_inventory_item_id  =>  ln_inventory_item_id);
      --for VAT attributes, bug#9191274, start
      jai_inv_items_pkg.copy_items(pn_organization_id           =>  pr_new.SHIP_from_ORG_ID,
                                   pn_inventory_item_id         =>  pr_new.inventory_item_id,
                                   pn_source_organization_id    =>  ln_organization_id,
                                   pn_source_inventory_item_id  =>  ln_inventory_item_id,
                                   pn_regime_code               =>  jai_constants.vat_regime);
      -- bug#9191274, end
    END IF;
  END IF;
  /*bug#8485149,end*/

  IF NVL(v_exist_ship,0) = 0 THEN
    RETURN;
  END IF;


/*
  This code has been added by aiyer for the fix of the bug #2855855
  Before inserting a record in the oe_order_lines_all table for a return order, check if the delivery detail_id i.e pr_new.attribute2 is null.
  IF yes then
   1. pick up the delivery_detail_id from the wsh_delivery_details table for records corresponding to the reference_header_id and
      reference_line_id in this table and populate the pr_new.attibute2 dff field
   2.Set the pr_new.attribute3 = 'Y' and pr_new.attribute4 = 'Y'
   3. Populate the context with the following information
       if  pr_new.return_context         pr_new.Context
       ----------------------          -------------------
               'ORDER'                   'Sales Order India'
               'INVOICE'                 'Invoice India'
               'PO'                      'Customer PO India'

*/

  --added jai_constants.UPDATING for bug#7568194
  IF pv_action IN (jai_constants.INSERTING, jai_constants.UPDATING) AND  pr_new.reference_header_id IS NOT NULL THEN

    OPEN cur_get_delivery_detail_id;
    FETCH cur_get_delivery_detail_id INTO l_new_delivery_detail_id;

    if cur_get_delivery_detail_id%FOUND then

      open  c_ordered_date_cur;
      fetch c_ordered_date_cur into v_ordered_date;
      close c_ordered_date_cur;

      open  c_confirmed_date(l_new_delivery_detail_id);
      fetch c_confirmed_date into v_confirm_date;
      close c_confirmed_date;

      open  c_hr_organizations_cur;
      fetch c_hr_organizations_cur into v_excise_return_days,v_sales_return_days;
      close c_hr_organizations_cur;

      ln_delivery_detail_id := l_new_delivery_detail_id;

      ---modified the IF condition for bug#7316234
      if (v_excise_return_days IS NULL
         OR
         (v_ordered_date - v_confirm_date) <= v_excise_return_days) then
        lv_allow_excise_flag := 'Y';
      else
        lv_allow_excise_flag := 'N';
      end if;
      ---modified the IF condition for bug#7316234
      if (v_sales_return_days IS NULL
         OR
         (v_ordered_date - v_confirm_date) <= v_sales_return_days ) then -- bug # 2993645
        lv_allow_sales_flag := 'Y';
      else
        lv_allow_sales_flag := 'N';
      end if;

     end if;

     CLOSE cur_get_delivery_detail_id;

  else

    open c_rma_line_dtls(pr_new.line_id);
    fetch c_rma_line_dtls into ln_delivery_detail_id, lv_allow_excise_flag, lv_allow_sales_flag,
                               ln_excise_duty_per_unit, ln_excise_duty_rate;
    close c_rma_line_dtls;

  end if;


  /* Added by Brathod , For Bug# 4244829 */
  /* If the v_order_source_type is Copy then this trigger should not insert the taxes */

  OPEN  Get_Order_Source_Type(pr_new.SOURCE_DOCUMENT_TYPE_ID);
  FETCH Get_Order_Source_Type INTO V_Order_Source_Type;
  CLOSE Get_Order_Source_Type;
  IF (
                       pr_new.SPLIT_FROM_LINE_ID IS NULL
                AND    pr_new.SOURCE_DOCUMENT_TYPE_ID IS NOT NULL
                AND    pr_new.SOURCE_DOCUMENT_LINE_ID IS NOT NULL
                AND     V_Order_Source_Type='Copy'
     )
  THEN
    RETURN;
  END IF;
  /* End Bug# 4244829 */

-- Start of bug #3306419
 /*
   The following if condition has been modified by aiyer for the bug #3306419
   Added the clause p_line_category_code = 'RETURN' so that this piece of code would always
   execute in case of an RMA irrespective of how the return order has been created.
 */

  jai_om_rma_pkg.default_taxes_onto_line (pr_new.header_id,
                      pr_new.line_id,
                      pr_new.inventory_item_id,
                      pr_new.ship_from_org_id,
                      -- pr_new.context,
                      pr_new.reference_line_id,
                      pr_new.reference_customer_trx_line_id,
                      pr_new.line_number,
         /* Commented for DFF Elimination by Ramananda. Bug#4348749  */
              --        pr_old.attribute2,
              --        pr_old.attribute3,
              --        pr_old.attribute4,
              --        pr_old.attribute5,
              --        pr_old.attribute14,
              --        pr_new.attribute2,
              --        pr_new.attribute3,
              --        pr_new.attribute4,
              --        pr_new.attribute5,
              --        pr_new.attribute14,
              --        pr_new.attribute15,
                        pr_old.return_context,
                    /* Added for DFF Elimination by Ramananda. Bug#4348749  */
                        ln_delivery_detail_id,
                        lv_allow_excise_flag,
                        lv_allow_sales_flag,
                        ln_excise_duty_per_unit,
                        ln_excise_duty_rate,
                      pr_old.reference_line_id,
                      pr_old.reference_customer_trx_line_id,
                      pr_old.ordered_quantity,
                      pr_old.cancelled_quantity,
                      pr_new.return_context,
                      pr_new.ordered_quantity,
                      pr_new.cancelled_quantity,
                      pr_new.order_quantity_uom,
                      pr_old.unit_selling_price,
                      pr_new.unit_selling_price,
                      pr_new.item_type_code,
                       NULL,
                      pr_new.creation_date,
                      pr_new.created_by,
                      pr_new.last_update_date,
                      pr_new.last_updated_by,
                      pr_new.last_update_login,
                      pr_new.source_document_type_id,
                      pr_new.line_category_code /* Parameter added by Aiyer for the bug #3306419
                                                 because the new parameter p_line_category_code has been added
                                                to the existing parameter list of the procedure jai_om_rma_pkg.default_taxes_onto_line
                                              */
              );--2001/10/03 Anuradha Parthasarathy

        -- End of bug #3306419

 /* Commented for DFF Elimination by Ramananda. Bug#4348749  */
 --  pr_new.attribute15 := NULL;
  /* Added an exception block by Ramananda for bug#4570303 */
  EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_OE_OLA_TRIGGER_PKG.BRIU_T1 '  || substr(sqlerrm,1,1900);

  END BRIU_T1 ;

END JAI_OE_OLA_TRIGGER_PKG ;

/
