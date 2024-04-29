--------------------------------------------------------
--  DDL for Package Body JAI_CMN_MTAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_MTAX_PKG" AS
/* $Header: jai_cmn_mtax.plb 120.11.12010000.13 2010/03/18 11:39:13 nprashar ship $ */

/*START, Added the following procedures by Bgowrava for the forward porting bug#5724855*/

  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - ja_in_mass_tax_changes_p.sql
  S.No  Date  Author and Details
  -------------------------------------------------

  1. 18-jun-2007 Sacsethi for bug 6130025 file version 120.4

         R12RUP03-ST1: CONCURRENT INDIA - MASS TAX RECALCULATION RESULTS IN ERROR

         Problem -
                 1. Procedure route_request , Parameter of p_from_date , P_to_date was of date type where it should be varchar
                       2. FP of Budget 2007 (5989740 ) FP

         Soln - 1 change it from date to varchar2
                2. Budget 2007 (5989740 ) Forward porting

  2. 15-Sep-2008  JMEENA for bug#7351304
      Added code to assign default dates if p_from_date and p_to_date are NULL in the procedure do_tax_redefaultation.
  3. 10-Jun-2009 Add code by Xiao for Advance Pricing

  4. 28-Jul-2009 Xiao Lv for IL Advanced Pricing.
                 Add if condition control for specific release version, code as:
                 IF lv_release_name NOT LIKE '12.0%' THEN
                    Advanced Pricing code;
                 END IF;

   -------------------------------------------------------------------------------------------------------------------------*/


procedure route_request
    (
         p_err_buf                 OUT NOCOPY VARCHAR2
        ,p_ret_code                OUT NOCOPY VARCHAR2
        ,p_org_id                  IN NUMBER             --1
        ,p_document_type           IN VARCHAR2  default null      --2
        ,p_from_date               IN varchar2  default null      --3   -- Date 18/06/2007 by sacsethi for bug 6130025
        ,p_to_date                 IN varchar2  default null        --4 -- Date 18/06/2007 by sacsethi for bug 6130025
        ,p_supplier_id             IN NUMBER    default null      --5
        ,p_supplier_site_id        IN NUMBER    default null   --6
        ,p_customer_id             IN NUMBER    default null      --7
        ,p_customer_site_id        IN NUMBER    default null   --8
        ,p_old_tax_category        IN NUMBER       --9
        ,p_new_tax_category        IN NUMBER       --10
        ,p_document_no             IN VARCHAR2  default null        --11
        ,p_release_no              IN NUMBER    default null       --12
        ,p_document_line_no        IN NUMBER    default null   --13
        ,p_shipment_no             IN NUMBER    default null      --14
        ,p_override_manual_taxes   IN CHAR      default 'N'--15
        ,p_commit_interval         IN NUMBER    default 50   --16
        ,p_process_partial         IN CHAR      default 'N'    --17
        ,p_debug                   IN CHAR      default 'N'        --18
        ,p_trace                   IN CHAR      default 'N'         --19
        ,p_dbms_output             IN CHAR      default 'N' -- this can be used when developer tests this from backened to get dbms output at important points
        ,p_called_from             IN VARCHAR2  default null
        ,p_source_id               IN NUMBER    default null -- this can be used to pass identifier based on which routing can be done
    )
  is
  begin

    if p_called_from is null then
      /*  Called from concurrent JAINMTCH */
      jai_cmn_mtax_pkg.do_tax_redefaultation
      (
         p_err_buf                 =>   p_err_buf
        ,p_ret_code                =>   p_ret_code
        ,p_org_id                  =>   p_org_id
        ,p_document_type           =>   p_document_type
        ,pv_from_date               =>   p_from_date
        ,pv_to_date                 =>   p_to_date
        ,p_supplier_id             =>   p_supplier_id
        ,p_supplier_site_id        =>   p_supplier_site_id
        ,p_customer_id             =>   p_customer_id
        ,p_customer_site_id        =>   p_customer_site_id
        ,p_old_tax_category        =>   p_old_tax_category
        ,p_new_tax_category        =>   p_new_tax_category
        ,p_document_no             =>   p_document_no
        ,p_release_no              =>   p_release_no
        ,p_document_line_no        =>   p_document_line_no
        ,p_shipment_no             =>   p_shipment_no
        ,pv_override_manual_taxes   =>   p_override_manual_taxes
        ,pn_commit_interval         =>   p_commit_interval
        ,pv_process_partial         =>   p_process_partial
        ,pv_debug                   =>   p_debug
        ,pv_trace                   =>   p_trace
        --,p_dbms_output             =>   p_dbms_output
      );

    elsif p_called_from = 'JAINUCTG' then
      /*  Called from Update Tax Categories form */
      jai_cmn_mtax_pkg.process_tax_cat_update
       (
         p_err_buf                 =>   p_err_buf
        ,p_ret_code                =>   p_ret_code
        ,p_org_id                  =>   p_org_id
        ,p_document_type           =>   p_document_type
        ,p_from_date               =>   p_from_date
        ,p_to_date                 =>   p_to_date
        ,p_supplier_id             =>   p_supplier_id
        ,p_supplier_site_id        =>   p_supplier_site_id
        ,p_customer_id             =>   p_customer_id
        ,p_customer_site_id        =>   p_customer_site_id
        ,p_old_tax_category        =>   p_old_tax_category
        ,p_new_tax_category        =>   p_new_tax_category
        ,p_document_no             =>   p_document_no
        ,p_release_no              =>   p_release_no
        ,p_document_line_no        =>   p_document_line_no
        ,p_shipment_no             =>   p_shipment_no
        ,p_override_manual_taxes   =>   p_override_manual_taxes
        ,p_commit_interval         =>   p_commit_interval
        ,p_process_partial         =>   p_process_partial
        ,p_debug                   =>   p_debug
        ,p_trace                   =>   p_trace
        ,p_dbms_output             =>   p_dbms_output
        ,p_tax_cat_update_id       =>   p_source_id
      );
    end if;

  end route_request;

  /*------------------------------------------------------------------------------------------------------------*/

  procedure process_tax_cat_update
    (
         p_err_buf                 OUT NOCOPY VARCHAR2
        ,p_ret_code                OUT NOCOPY VARCHAR2
        ,p_org_id                  IN NUMBER             --1
        ,p_document_type           IN VARCHAR2  default null      --2
        ,p_from_date               IN DATE            --3
        ,p_to_date                 IN DATE              --4
        ,p_supplier_id             IN NUMBER          --5
        ,p_supplier_site_id        IN NUMBER       --6
        ,p_customer_id             IN NUMBER          --7
        ,p_customer_site_id        IN NUMBER       --8
        ,p_old_tax_category        IN NUMBER       --9
        ,p_new_tax_category        IN NUMBER       --10
        ,p_document_no             IN VARCHAR2          --11
        ,p_release_no              IN NUMBER           --12
        ,p_document_line_no        IN NUMBER       --13
        ,p_shipment_no             IN NUMBER          --14
        ,p_override_manual_taxes   IN CHAR DEFAULT 'N'--15
        ,p_commit_interval         IN NUMBER DEFAULT 50   --16
        ,p_process_partial         IN CHAR DEFAULT 'N'    --17
        ,p_debug                   IN CHAR DEFAULT 'N'        --18
        ,p_trace                   IN CHAR DEFAULT 'N'         --19
        ,p_dbms_output             IN CHAR DEFAULT 'N' -- this can be used when developer tests this from backened to get dbms output at important points
        ,p_tax_cat_update_id       IN jai_cmn_taxctg_updates.tax_category_update_id%type
    )
  is
  begin
    /* For all supported document types do mass tax changes */
    for r_doc_type in (  select flex_value document_type
                         from   fnd_flex_values_vl flxvals
                              , fnd_flex_value_sets flxvsets
                         where  flxvsets.flex_value_set_id = flxvals.flex_value_set_id
                         and    flxvsets.flex_value_set_name = 'JAINMTCH_PO_DOCUMENT_TYPES'
                       )
    loop
      fnd_file.put_line( fnd_file.log, 'Processing mass update for document type='|| r_doc_type.document_type);

      /* For each tax category where invoice mass tax flag is set, call mass tax changes procedure*/
      for r_tax_cat in (select tax_category_id
                        from   jai_cmn_taxctg_updates
                        where  tax_category_update_id = p_tax_cat_update_id
                        and    invoke_mass_tax_update_flag = 'Y'
                       )
      loop
        do_tax_redefaultation
        (
           p_err_buf                 =>   p_err_buf
          ,p_ret_code                =>   p_ret_code
          ,p_org_id                  =>   p_org_id
          ,p_document_type           =>   r_doc_type.document_type
          ,pv_from_date               =>   p_from_date
          ,pv_to_date                 =>   p_to_date
          ,p_supplier_id             =>   p_supplier_id
          ,p_supplier_site_id        =>   p_supplier_site_id
          ,p_customer_id             =>   p_customer_id
          ,p_customer_site_id        =>   p_customer_site_id
          ,p_old_tax_category        =>   r_tax_cat.tax_category_id
          ,p_new_tax_category        =>   r_tax_cat.tax_category_id
          ,p_document_no             =>   p_document_no
          ,p_release_no              =>   p_release_no
          ,p_document_line_no        =>   p_document_line_no
          ,p_shipment_no             =>   p_shipment_no
          ,pv_override_manual_taxes   =>   p_override_manual_taxes
          ,pn_commit_interval         =>   p_commit_interval
          ,pv_process_partial         =>   p_process_partial
          ,pv_debug                   =>   p_debug
          ,pv_trace                   =>   p_trace
          --,p_dbms_output             =>   p_dbms_output
        );
      end loop; /* r_tax_cat */

      fnd_file.put_line( fnd_file.log, 'Mass update completed for document type='|| r_doc_type.document_type);

    end loop; /*r_doc_type*/

  end process_tax_cat_update;
/*------------------------------------------------------------------------------------------------------------*/


/*END, Added the following procedures by Bgowrava for the forward porting bug#5724855*/

PROCEDURE do_tax_redefaultation
  (
    p_err_buf OUT NOCOPY VARCHAR2,
    p_ret_code  OUT NOCOPY VARCHAR2,
    p_org_id IN NUMBER,             --1/* This parameter would no more be used after application of the bug 5490479- Aiyer, */
    p_document_type IN VARCHAR2,        --2
    pv_from_date IN VARCHAR2,            --3 Ramananda for bug# 4336482 changed from DATE to VARCHAR2
    pv_to_date IN VARCHAR2,              --4 Ramananda for bug# 4336482 changed from DATE to VARCHAR2
    p_supplier_id IN NUMBER,          --5
    p_supplier_site_id IN NUMBER,       --6
    p_customer_id IN NUMBER,          --7
    p_customer_site_id IN NUMBER,       --8
    p_old_tax_category IN NUMBER,       --9
    p_new_tax_category IN NUMBER,       --10
    p_document_no IN VARCHAR2,          --11
    p_release_no IN NUMBER,           --12
    p_document_line_no IN NUMBER,       --13
    p_shipment_no IN NUMBER,          --14
    pv_override_manual_taxes IN VARCHAR2,  -- DEFAULT 'N',--15      -- Use jai_constants.no in the call of this procedure. Ramananda for for File.Sql.35
    pn_commit_interval IN NUMBER,           -- DEFAULT 50,   --16    -- Added global variable gn_commit_interval in package spec. by Ramananda for File.Sql.35
    pv_process_partial IN VARCHAR2,        -- DEFAULT 'N',    --17  -- Use jai_constants.no in the call of this procedure. Ramananda for for File.Sql.35
    pv_debug IN VARCHAR2,                  -- DEFAULT 'N',    --18  -- Use jai_constants.no in the call of this procedure. Ramananda for for File.Sql.35
    pv_trace IN VARCHAR2                  -- DEFAULT 'N'     --19  -- Use jai_constants.no in the call of this procedure. Ramananda for for File.Sql.35
  ) IS

    /* Ramananda for bug# 4336482 */
    p_from_date DATE; -- DEFAULT fnd_date.canonical_to_date(pv_from_date);  --Ramananda for File.Sql.35
    p_to_date   DATE; -- DEFAULT fnd_date.canonical_to_date(pv_to_date);   --Ramananda for File.Sql.35
    /* Ramananda for bug# 4336482 */

    p_override_manual_taxes VARCHAR2(1);
    p_commit_interval NUMBER(9);
    p_process_partial VARCHAR2(1);
    p_debug  VARCHAR2(1);
    p_trace  VARCHAR2(1);
                --********* GLOBAL Variables ***********
    v_batch_id        NUMBER; -- used as unique key in JAI_CMN_MTAX_HDRS_ALL table

    /* --Ramananda for File.Sql.35*/
    v_today           DATE;   -- := trunc(sysdate);
    v_created_by      NUMBER; -- := nvl(FND_GLOBAL.USER_ID,-1);
    v_login_id        NUMBER; -- := nvl(FND_GLOBAL.LOGIN_ID,-1);
    v_user_id         NUMBER; -- := nvl(FND_GLOBAL.USER_ID,-1);

    --********* Modified Input Variables ***********
    v_org_id        NUMBER;

    --********* GLOBAL Messages ***********

    v_message_01      VARCHAR2(128); -- := 'There is no defaulting tax category in the set up';  --Ramananda for File.Sql.35

    v_success         NUMBER(3);
    v_message       VARCHAR2(512);

  --//~~~~~~~~ Declaration Section for Trace and Log files ~~~~~~~~~~//
    -- used for trace

    CURSOR c_enable_trace(cp_conc_name fnd_concurrent_programs.concurrent_program_name%type) IS
      SELECT enable_trace
      FROM fnd_concurrent_programs a, fnd_application b
      WHERE b.application_short_name = 'PO'
      AND b.application_id = a.application_id
      AND a.concurrent_program_name = cp_conc_name; --'JAINMTCH';

    /*
    || Start of bug 4517919
    */
    CURSOR get_audsid IS
    SELECT a.sid, a.serial#, b.spid
    FROM v$session a, v$process b
    WHERE audsid = userenv('SESSIONID')
    AND a.paddr = b.addr;

    CURSOR get_dbname IS SELECT name FROM v$database;

    v_sid                     v$session.sid%type;
    v_serial                  v$session.serial#%type;
    v_spid                    v$process.spid%type;
    v_name1                   v$database.name%type;

    /*
    || End of bug 4517919
    */

    -- v_debug CHAR(1) := p_debug;  -- 'Y';
    v_debug BOOLEAN; --  := FALSE;  --Ramananda for File.Sql.35
    v_enable_trace FND_CONCURRENT_PROGRAMS.enable_trace%TYPE;


    -- used for log file Generation
    v_log_file_name VARCHAR2(50); -- := 'jai_cmn_mtax_pkg.do_tax_redefaultation.log'; --Ramananda for File.Sql.35
    v_utl_location  VARCHAR2(512);
    v_myfilehandle    UTL_FILE.FILE_TYPE;

  --//~~~~~~~~ Declaration Section for Preprocessing of the variables ~~~~~~~~~~//

    CURSOR c_po_header( p_document_type IN VARCHAR2, p_document_no IN VARCHAR2, p_org_id IN NUMBER) IS
      SELECT po_header_id
      FROM po_headers_all
      WHERE segment1 = p_document_no
      AND type_lookup_code = p_document_type
      AND (p_org_id IS NULL OR org_id = p_org_id);

    CURSOR c_po_line( p_po_header_id IN NUMBER, p_document_line_no IN NUMBER) IS
      SELECT po_line_id
      FROM po_lines_all
      WHERE po_header_id = p_po_header_id AND line_num = p_document_line_no;

    CURSOR c_shipment_line( p_po_line_id IN NUMBER, p_shipment_no IN NUMBER,
        p_shipment_type IN VARCHAR2, p_release_id IN NUMBER) IS
      SELECT line_location_id
      FROM po_line_locations_all
      WHERE po_line_id = p_po_line_id
      AND shipment_num = p_shipment_no
      AND shipment_type = p_shipment_type
      AND ( (p_release_id IS NULL) OR (p_release_id IS NOT NULL AND po_release_id = p_release_id));

    CURSOR c_po_release( p_po_header_id IN NUMBER, p_release_no IN NUMBER) IS
      SELECT po_release_id
      FROM po_releases_all
      WHERE po_header_id = p_po_header_id AND release_num = p_release_no;

    CURSOR c_so_header( p_order_number IN NUMBER, p_org_id IN NUMBER) IS
      SELECT header_id
      FROM oe_order_headers_all
      WHERE order_number = p_order_number
      AND (p_org_id IS NULL OR org_id = p_org_id);

    CURSOR c_so_line( p_header_id IN NUMBER, p_line_no IN NUMBER) IS
      SELECT line_id
      FROM oe_order_lines_all
      WHERE header_id = p_header_id AND line_number = p_line_no;

    CURSOR c_requisition_header( p_document_type IN VARCHAR2, p_requisition_no IN VARCHAR2, p_org_id IN NUMBER) IS
      SELECT requisition_header_id
      FROM po_requisition_headers_all
      WHERE segment1 = p_requisition_no
      AND type_lookup_code = p_document_type
      AND (p_org_id IS NULL OR org_id = p_org_id);

    CURSOR c_requisition_line( p_requisition_header_id IN NUMBER, p_requisition_line_no IN NUMBER) IS
      SELECT requisition_line_id
      FROM po_requisition_lines_all
      WHERE requisition_header_id = p_requisition_header_id AND line_num = p_requisition_line_no;

    v_document_find_failed CHAR(1); -- := 'N'; --Ramananda for File.Sql.35
    v_failed      CHAR(1); -- := 'N'; --Ramananda for File.Sql.35
    v_po_header_id    NUMBER;
    v_po_line_id    NUMBER;
    v_shipment_id   NUMBER;
    v_po_release_id   NUMBER;
    v_line_location_id  NUMBER;

    v_reqn_header_id  NUMBER;
    v_reqn_line_id    NUMBER;

    v_so_header_id    NUMBER;
    v_so_line_id    NUMBER;
    ln_org_id       NUMBER;       /*Added by aiyer for the bug 5490479 */
  --//~~~~~~~~~ Declaration Section for Main business logic ~~~~~~~~~~//

    CURSOR c_uom_code( p_uom IN VARCHAR2 ) IS
      SELECT uom_code
      FROM mtl_units_of_measure
      WHERE unit_of_measure = p_uom;

          /* Added by LGOPALSA. Bug 4210102.
           * Commented tax_typoe_cal as per Babu's comments */
    CURSOR c_tax_category_taxes(p_tax_category_id IN NUMBER) IS
      select a.tax_category_id, a.tax_id, a.line_no lno,
           a.precedence_1 p_1,
     a.precedence_2 p_2,
     a.precedence_3 p_3,
           a.precedence_4 p_4,
     a.precedence_5 p_5,
           a.precedence_6 p_6,-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
     a.precedence_7 p_7,
     a.precedence_8 p_8,
           a.precedence_9 p_9,
     a.precedence_10 p_10,
           b.tax_rate, b.tax_amount, b.uom_code, b.end_date valid_date,
           -- DECODE(UPPER(b.tax_type), 'EXCISE', 1, 'ADDL. EXCISE', 1,  'OTHER EXCISE', 1, 'CVD', 1, jai_constants.tax_type_exc_edu_cess,1, 'TDS', 2, 0) tax_type_val,
           b.mod_cr_percentage, b.vendor_id, b.tax_type, nvl(b.rounding_factor,0) rounding_factor
            from JAI_CMN_TAX_CTG_LINES a, JAI_CMN_TAXES_ALL b
      WHERE a.tax_category_id = p_tax_category_id
      AND a.tax_id = b.tax_id
      ORDER BY a.line_no;

    CURSOR c_manual_taxes_up(p_line_location_id IN NUMBER, p_line_focus_id IN NUMBER) IS
      SELECT rowid, tax_line_no
      FROM JAI_PO_TAXES
      WHERE line_focus_id = p_line_focus_id
      AND tax_category_id IS NULL
      ORDER BY tax_line_no;

    CURSOR c_manual_so_taxes_up(p_line_id IN NUMBER) IS
      SELECT rowid, tax_line_no
      FROM JAI_OM_OE_SO_TAXES
      WHERE line_id = p_line_id
      AND tax_category_id IS NULL
      ORDER BY tax_line_no;

    CURSOR c_manual_reqn_taxes_up(p_requisition_line_id IN NUMBER) IS
      SELECT rowid, tax_line_no
      FROM JAI_PO_REQ_LINE_TAXES
      WHERE requisition_line_id = p_requisition_line_id
      AND tax_category_id IS NULL
      ORDER BY tax_line_no;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the reference to cursor c_inv_set_of_books_id
     * and c_opr_set_of_books_id and implemented using caching logic.
     */

    CURSOR c_inv_organization(p_location_id IN NUMBER) IS
      SELECT inventory_organization_id
      FROM   hr_locations
      WHERE  location_id = p_location_id;

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Removed the reference to c_func_curr as the functional
    * currency will be derived via caching logic.
    */


    --********* FOR SALES ORDERS
    CURSOR c_address(p_ship_to_site_use_id IN NUMBER) IS
      SELECT nvl(cust_acct_site_id , 0) address_id
      FROM hz_cust_site_uses_all A -- Removed ra_site_uses_all for Bug# 4434287
      WHERE A.site_use_id = p_ship_to_site_use_id;    /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
      --WHERE A.site_use_id = NVL(p_ship_to_site_use_id,0);

    CURSOR c_get_assessable_value(p_customer_id NUMBER, p_address_id NUMBER,
        p_inventory_item_id VARCHAR2, p_uom_code VARCHAR2, p_ordered_date DATE )IS
      SELECT b.operand list_price
      FROM JAI_CMN_CUS_ADDRESSES a, qp_list_lines b, qp_pricing_attributes c
      WHERE a.customer_id = p_customer_id
      AND a.address_id = p_address_id
      AND a.price_list_id = b.list_header_id
      AND c.list_line_id = b.list_line_id
      AND c.product_attr_value = p_inventory_item_id
      AND c.product_uom_code = p_uom_code
      AND p_ordered_date BETWEEN TRUNC(NVL(b.start_date_active, v_today))
        AND TRUNC(NVL(b.end_date_active, v_today));
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
-------------------------------------------------------------------------------
    -- Get category_set_name
    CURSOR category_set_name_cur
    IS
    SELECT
      category_set_name
    FROM
      mtl_default_category_sets_fk_v
    WHERE functional_area_desc = 'Order Entry';

    lv_category_set_name  VARCHAR2(30);

    -- Get the Excise Assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, Ordered date.
    CURSOR cust_ass_value_category_cur
    ( pn_party_id          NUMBER
    , pn_address_id        NUMBER
    , pn_inventory_item_id NUMBER
    , pv_uom_code          VARCHAR2
    , pd_ordered_date      DATE
    )
    IS
    SELECT
      b.operand          list_price
    --, c.product_uom_code list_price_uom_code
    FROM
      jai_cmn_cus_addresses a
    , qp_list_lines         b
    , qp_pricing_attributes c
    WHERE a.customer_id        = pn_party_id
      AND a.address_id         = pn_address_id
      AND a.price_list_id      = b.list_header_id
      AND c.list_line_id       = b.list_line_id
      AND c.product_uom_code   = pv_uom_code
      AND pd_ordered_date BETWEEN NVL( b.start_date_active, pd_ordered_date)
                              AND NVL( b.end_date_active, SYSDATE)
      AND EXISTS ( SELECT
                     'x'
                   FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );


--------------------------------------------------------------------------------
 -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

  /*
    CURSOR c_price_list_ass_value(p_price_list_id NUMBER, p_inventory_item_id NUMBER,
        p_uom_code VARCHAR2, p_ordered_date DATE) IS
      SELECT list_price, unit_code
      FROM so_price_list_lines
      WHERE price_list_id = p_price_list_id
      AND inventory_item_id  = p_inventory_item_id
      AND unit_code = p_uom_code
      AND trunc(p_ordered_date) BETWEEN trunc(nvl( start_date_active, p_ordered_date))
      AND trunc(nvl( end_date_active, SYSDATE));
  */
    --********* for REQUISITIONS
    CURSOR c_vendor_name( p_vendor_id IN VARCHAR2) IS
      SELECT vendor_name
      FROM Po_Vendors
      WHERE Vendor_Name = p_vendor_id;

    CURSOR c_vendor_site_code( p_vendor_site_id IN VARCHAR2) IS
      SELECT Vendor_Site_Code
      FROM po_vendor_sites_all A
      WHERE a.vendor_site_id = p_vendor_site_id;

    CURSOR c_vendor_id( p_sugg_vendor_name IN VARCHAR2) IS
      SELECT Vendor_Id
      FROM Po_Vendors
      WHERE Vendor_Name = p_sugg_vendor_name;

    CURSOR c_vendor_site_id( p_sugg_vendor_loc IN VARCHAR2, p_vendor_id IN NUMBER, p_org_id IN NUMBER) IS
      SELECT Vendor_Site_Id
      FROM Po_Vendor_Sites_All A
      WHERE A.Vendor_Id = p_vendor_id
      AND A.Vendor_Site_Code = p_sugg_vendor_loc
      AND (p_org_id IS NULL OR a.org_id = p_org_id);

    /****************************************
    PURCHASE ORDERS Fetching Main Cursor for
    STANDARD, PLANNED_PA, BLANKET_PA, QUOTATION, RFQ
    ****************************************/

    /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    CURSOR c_main_po( p_org_id IN NUMBER, p_document_type IN VARCHAR2, p_shipment_type IN VARCHAR2,
        p_from_date IN DATE, p_to_date IN DATE,
        p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_old_tax_category_id IN NUMBER,
        p_document_no VARCHAR2, p_document_line_no IN NUMBER, p_shipment_no IN NUMBER ) IS
      SELECT 1 source, jipll.rowid,
        jipll.line_focus_id, jipll.line_location_id, jipll.po_line_id, jipll.po_header_id, jipll.tax_category_id,
        pha.type_lookup_code, pha.vendor_id, pha.vendor_site_id, pha.currency_code,
        pha.rate, pha.rate_date, pha.rate_type, pha.ship_to_location_id hdr_ship_to_location_id,
        nvl(plla.quantity_billed,0) quantity_billed, nvl(plla.quantity,0) shipment_qty,
        nvl(plla.quantity_received,0) quantity_received, nvl(plla.quantity_accepted,0) quantity_accepted,
        nvl(plla.quantity_rejected,0) quantity_rejected, nvl(plla.quantity_cancelled,0) quantity_cancelled,
        plla.ship_to_organization_id, plla.ship_to_location_id,
        plla.unit_meas_lookup_code, plla.price_override, plla.shipment_type,
        pla.item_id, pla.unit_meas_lookup_code line_uom,
        pha.segment1 document_no, pla.line_num, plla.shipment_num
      FROM po_headers_all pha, po_lines_all pla, po_line_locations_all plla, JAI_PO_LINE_LOCATIONS jipll
      WHERE pha.po_header_id = pla.po_header_id
      AND pla.po_line_id = plla.po_line_id
      AND plla.line_location_id = jipll.line_location_id
      AND plla.shipment_type = p_shipment_type
      AND ((p_document_no is null) OR (p_document_no is not null and pha.segment1=p_document_no ))
      AND pha.type_lookup_code = p_document_type
      AND ((p_document_line_no IS NULL) OR (p_document_line_no IS NOT NULL AND pla.line_num = p_document_line_no ))
      AND ((p_shipment_no IS NULL) OR (p_shipment_no IS NOT NULL AND plla.shipment_num = p_shipment_no ))
      AND v_today BETWEEN nvl( pha.start_date, v_today) AND nvl(pha.end_date, v_today)
      AND ( (p_vendor_id IS NULL)
        OR (p_vendor_id IS NOT NULL AND pha.vendor_id = p_vendor_id) )
      AND ( (p_vendor_site_id IS NULL)
        OR (p_vendor_site_id IS NOT NULL AND pha.vendor_site_id = p_vendor_site_id) )
      AND ( (p_old_tax_category_id IS NULL)
        OR (p_old_tax_category_id IS NOT NULL AND jipll.tax_category_id = p_old_tax_category_id) )
      AND (p_org_id IS NULL OR pha.org_id = p_org_id)
      AND (plla.cancel_flag IS NULL OR plla.cancel_flag <> 'Y' )
      AND trunc(plla.creation_date) BETWEEN p_from_date AND p_to_date
      AND ( plla.closed_code IS NULL OR plla.closed_code IN (
            jai_constants.closed_code_open        ,
            jai_constants.closed_code_inporcess    ,
            jai_constants.closed_code_approved      ,
            jai_constants.closed_code_preapproved    ,
            jai_constants.closed_code_req_appr      ,
            jai_constants.closed_code_incomplete     ))
            --'OPEN', 'IN PROCESS', 'APPROVED', 'PRE-APPROVED', 'REQUIRES REAPPROVAL',  'INCOMPLETE') )
    UNION   -- if there are no base records in po_line_locations_all but JAI_PO_LINE_LOCATIONS have
      SELECT 2 source, jipll.rowid,
        jipll.line_focus_id, jipll.line_location_id, jipll.po_line_id,  jipll.po_header_id, jipll.tax_category_id,
        pha.type_lookup_code, pha.vendor_id, pha.vendor_site_id, pha.currency_code,
        pha.rate, pha.rate_date, pha.rate_type, pha.ship_to_location_id hdr_ship_to_location_id,
        0 quantity_billed, 0 shipment_qty,
        0 quantity_received, 0 quantity_accepted,
        0 quantity_rejected, 0 quantity_cancelled,
        -1 ship_to_organization_id, -1 ship_to_location_id,
        null unit_meas_lookup_code, 0  price_override, null shipment_type,
        pla.item_id, pla.unit_meas_lookup_code line_uom,
        pha.segment1 document_no, pla.line_num, -1 shipment_num
      FROM po_headers_all pha, po_lines_all pla, JAI_PO_LINE_LOCATIONS jipll
      WHERE pha.po_header_id = pla.po_header_id
      AND pla.po_line_id = jipll.po_line_id
      AND ((p_document_no IS NULL) or (p_document_no is NOT NULL and pha.segment1 = p_document_no ))
      AND pha.type_lookup_code = p_document_type
      AND ((p_document_line_no IS NULL) OR (p_document_line_no IS NOT NULL AND pla.line_num = p_document_line_no ))
      AND v_today BETWEEN nvl( pha.start_date, v_today) AND nvl(pha.end_date, v_today)
      AND ( (p_vendor_id IS NULL)
        OR (p_vendor_id IS NOT NULL AND pha.vendor_id = p_vendor_id) )
      AND ( (p_vendor_site_id IS NULL)
        OR (p_vendor_site_id IS NOT NULL AND pha.vendor_site_id = p_vendor_site_id) )
      AND ( (p_old_tax_category_id IS NULL)
        OR (p_old_tax_category_id IS NOT NULL AND jipll.tax_category_id = p_old_tax_category_id) )
      AND (p_org_id IS NULL OR pha.org_id = p_org_id)
      AND (pla.cancel_flag IS NULL OR pla.cancel_flag <> 'Y' )
      AND trunc(pla.creation_date) BETWEEN p_from_date AND p_to_date
      AND ( pla.closed_code IS NULL OR pla.closed_code IN (
      jai_constants.closed_code_open        ,
            jai_constants.closed_code_inporcess    ,
            jai_constants.closed_code_approved      ,
            jai_constants.closed_code_preapproved    ,
            jai_constants.closed_code_req_appr      ,
            jai_constants.closed_code_incomplete     ))
            --'OPEN', 'IN PROCESS', 'APPROVED', 'PRE-APPROVED', 'REQUIRES REAPPROVAL',  'INCOMPLETE') )
      and (jipll.line_location_id IS NULL OR jipll.line_location_id = 0);

    /****************************************
    RELEASES Fetching Main Cursor for
    BLANKET and SCHEDULED RELEASES
    ****************************************/
    CURSOR c_main_releases(p_org_id IN NUMBER, p_document_type IN VARCHAR2, p_shipment_type IN VARCHAR2,
        p_from_date IN DATE, p_to_date IN DATE,
        p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_old_tax_category_id IN NUMBER,
        p_document_no VARCHAR2, p_release_no IN NUMBER, p_document_line_no IN NUMBER,
        p_shipment_no IN NUMBER ) IS
      SELECT 3 src, pra.po_release_id, jipll.rowid,
        jipll.line_focus_id, jipll.line_location_id, jipll.po_line_id, jipll.po_header_id, jipll.tax_category_id,
        pha.type_lookup_code, pha.vendor_id, pha.vendor_site_id, pha.currency_code,
        pha.rate, pha.rate_date, pha.rate_type, pha.ship_to_location_id hdr_ship_to_location_id,
        plla.quantity_billed, plla.quantity shipment_qty,
        plla.quantity_received, plla.quantity_accepted,
        plla.quantity_rejected, plla.quantity_cancelled,
        plla.ship_to_organization_id, plla.ship_to_location_id,
        plla.unit_meas_lookup_code, plla.price_override, plla.shipment_type,
        pla.item_id, pla.unit_meas_lookup_code line_uom,
        pra.release_num, pha.segment1 document_no, pla.line_num, plla.shipment_num
      FROM po_headers_all pha, po_lines_all pla,
        po_line_locations_all plla, JAI_PO_LINE_LOCATIONS jipll, po_releases_all pra
      WHERE pha.po_header_id = pla.po_header_id
      AND pla.po_line_id = plla.po_line_id
      AND pla.po_line_id = jipll.po_line_id
      AND plla.line_location_id = jipll.line_location_id
      AND pra.po_header_id = pha.po_header_id
      AND plla.po_release_id = pra.po_release_id
      AND plla.shipment_type = p_shipment_type
      AND ((p_document_no IS NULL) OR (p_document_no IS NOT NULL and pha.segment1 = p_document_no ))
      AND pha.type_lookup_code = p_document_type
      AND ((p_release_no is null) OR (p_release_no is not null and pra.release_num = p_release_no ))
      AND ((p_document_line_no IS NULL) OR (p_document_line_no IS NOT NULL AND pla.line_num = p_document_line_no ))
      AND ((p_shipment_no IS NULL) OR (p_shipment_no IS NOT NULL AND plla.shipment_num = p_shipment_no ))
      AND v_today BETWEEN nvl( pha.start_date, v_today) AND nvl(pha.end_date, v_today)
      AND ( (p_vendor_id IS NULL)
        OR (p_vendor_id IS NOT NULL AND pha.vendor_id = p_vendor_id) )
      AND ( (p_vendor_site_id IS NULL)
        OR (p_vendor_site_id IS NOT NULL AND pha.vendor_site_id = p_vendor_site_id) )
      AND ( (p_old_tax_category_id IS NULL)
        OR (p_old_tax_category_id IS NOT NULL AND jipll.tax_category_id = p_old_tax_category_id) )
      AND (p_org_id IS NULL OR plla.org_id = p_org_id)
      AND (plla.cancel_flag IS NULL OR plla.cancel_flag <> 'Y' )
      AND trunc(pra.creation_date) BETWEEN p_from_date AND p_to_date
      AND ( plla.closed_code IS NULL OR plla.closed_code IN
                               (jai_constants.closed_code_open        ,
            jai_constants.closed_code_inporcess    ,
            jai_constants.closed_code_approved      ,
            jai_constants.closed_code_preapproved    ,
            jai_constants.closed_code_req_appr      ,
            jai_constants.closed_code_incomplete     ));
            --'OPEN', 'IN PROCESS', 'APPROVED', 'PRE-APPROVED', 'REQUIRES REAPPROVAL',  'INCOMPLETE') );

    /****************
    REQUISITIONS Cursor
    ****************/
    CURSOR c_main_reqn(p_org_id IN NUMBER, p_document_type IN VARCHAR2,
        p_from_date IN DATE, p_to_date IN DATE,
        p_suggested_vendor_name IN VARCHAR2, p_suggested_vendor_location IN VARCHAR2, p_old_tax_category_id IN NUMBER,
        p_document_no VARCHAR2, p_document_line_no IN NUMBER) IS
      SELECT jirl.rowid,
        jirl.requisition_line_id, jirl.requisition_header_id, jirl.tax_category_id,
        prha.type_lookup_code,    --, prha.currency_code hdr_currency_code,
        prla.quantity, -- plla.quantity_received, plla.quantity_delivered, plla.quantity_cancelled,
        prla.item_id, prla.unit_meas_lookup_code line_uom, prla.unit_price,
        prla.currency_unit_price, prla.currency_code, prla.rate, prla.rate_date, prla.rate_type,
        prla.suggested_vendor_name, prla.suggested_vendor_location,
        prla.destination_organization_id, prla.deliver_to_location_id, prla.source_organization_id,
        prla.source_type_code,  -- this tells whether source is VENDOR or INVENTORY. If vendor then suggested vendor will be there
        prha.segment1 document_no, prla.line_num
      FROM po_requisition_headers_all prha, po_requisition_lines_all prla, JAI_PO_REQ_LINES jirl
      WHERE prha.requisition_header_id = prla.requisition_header_id
      AND prla.requisition_line_id = jirl.requisition_line_id
      AND ((p_document_no is null) OR (p_document_no is not null and prha.segment1 = p_document_no ))
      AND prha.type_lookup_code = p_document_type
      AND ((p_document_line_no IS NULL) OR (p_document_line_no IS NOT NULL AND prla.line_num = p_document_line_no ))
      AND ( (p_suggested_vendor_name IS NULL) OR (p_suggested_vendor_name IS NOT NULL
        AND prla.suggested_vendor_name = p_suggested_vendor_name) )
      AND ( (p_suggested_vendor_location IS NULL) OR (p_suggested_vendor_location IS NOT NULL
        AND prla.suggested_vendor_location = p_suggested_vendor_location))
      AND ( (p_old_tax_category_id IS NULL)
        OR (p_old_tax_category_id IS NOT NULL AND jirl.tax_category_id = p_old_tax_category_id) )
      AND (p_org_id IS NULL OR prla.org_id = p_org_id)
      AND (prla.cancel_flag IS NULL OR prla.cancel_flag <> 'Y' )
      AND trunc(prla.creation_date) BETWEEN p_from_date AND p_to_date
      AND ((prla.closed_date IS NULL) OR (prla.closed_date <= v_today))
      AND ( prla.closed_code IS NULL OR prla.closed_code IN (
      jai_constants.closed_code_open        ,
            jai_constants.closed_code_inporcess    ,
            jai_constants.closed_code_approved      ,
            jai_constants.closed_code_preapproved    ,
            jai_constants.closed_code_req_appr      ,
            jai_constants.closed_code_incomplete     ));
            --'OPEN', 'IN PROCESS', 'APPROVED', 'PRE-APPROVED', 'REQUIRES REAPPROVAL',  'INCOMPLETE') )

    /****************
    SALES ORDERS Cursor
    ****************/
    CURSOR c_main_so( p_org_id IN NUMBER, p_from_date IN DATE, p_to_date IN DATE,
        p_customer_id IN NUMBER, p_customer_site_id IN NUMBER, p_old_tax_category_id IN NUMBER,
        p_document_no NUMBER, p_document_line_no IN NUMBER) IS
      SELECT jisl.rowid, jisl.tax_category_id,
        oola.header_id, oola.line_id, oola.ship_to_org_id,
        oola.inventory_item_id, nvl(oola.ordered_quantity,0) ordered_quantity,
        nvl(oola.shipped_quantity,0) shipped_quantity,  -- oola.cancelled_quantity,
        oola.order_quantity_uom, oola.ship_from_org_id warehouse_id,
        jisl.selling_price, jisl.assessable_value,
        -- NVL(ooha.org_id,0) org_id,
        ooha.sold_to_org_id customer_id,
        ooha.source_document_id, ooha.order_number,
        ooha.price_list_id,   -- ooha.order_category,
        ooha.transactional_curr_code currency_code, ooha.conversion_type_code, ooha.conversion_rate,
        ooha.conversion_rate_date conversion_date,
        ooha.ordered_date date_ordered, ooha.creation_date,
        ooha.order_type_id, ooha.order_number document_no, oola.line_number
      FROM oe_order_headers_all ooha, oe_order_lines_all oola, JAI_OM_OE_SO_LINES jisl
      WHERE ooha.header_id = oola.header_id
      AND oola.line_id = jisl.line_id
      AND oola.open_flag  = 'Y'
      AND ((p_document_no is null) OR (p_document_no is not null and ooha.order_number = p_document_no ))
      AND ((p_document_line_no IS NULL) OR (p_document_line_no IS NOT NULL AND oola.line_number = p_document_line_no ))
      AND ((ooha.cancelled_flag IS NULL) OR (ooha.cancelled_flag <> 'Y'))
      AND ( oola.cancelled_quantity IS NULL OR oola.cancelled_quantity = 0 )
      AND oola.line_category_code IN ('ORDER', 'MIXED') --  = 'R'
      AND oola.flow_status_code not in ('CLOSED','CANCELLED','SHIPPED')  --added by ssawant for bug 5604272
      AND ((p_customer_id IS NULL)
        OR (p_customer_id IS NOT NULL AND oola.sold_to_org_id = p_customer_id))
      AND ((p_customer_site_id IS NULL)
        OR (p_customer_site_id IS NOT NULL AND oola.ship_to_org_id = p_customer_site_id))
      AND ((p_old_tax_category_id IS NULL)
        OR (p_old_tax_category_id IS NOT NULL AND jisl.tax_category_id = p_old_tax_category_id))
      AND (p_org_id IS NULL OR oola.org_id = p_org_id)
      AND trunc( nvl(ooha.ordered_date, ooha.creation_date)) BETWEEN p_from_date AND p_to_date
      ORDER BY oola.header_id, oola.line_id;

  --//~~~~~~~~~ End of Declaration Section for Actual Concurrent Program ~~~~~~~~~~//

    v_commit_interval   NUMBER(5) := 0;
    v_document_type     VARCHAR2(25);
    v_shipment_type     VARCHAR2(25);
    v_dflt_tax_category_id  NUMBER(15);

    v_vendor_id       NUMBER;
    v_vendor_site_id    NUMBER;
    v_tax_vendor_id     NUMBER;
    v_tax_vendor_site_id  NUMBER;
    v_inventory_item_id   NUMBER;
    v_line_uom        VARCHAR2(25);
    v_uom_code        VARCHAR2(4);
    v_assessable_value    NUMBER;
    ln_vat_assess_value   NUMBER; -- added, Harshita for bug #4245062
    v_modvat        CHAR(1);
    v_tax_amount      NUMBER;
    v_sob_id        NUMBER;
    v_organization_id   NUMBER;
    v_func_curr       VARCHAR2(5);
    v_curr_conv_rate    NUMBER;
    v_ship_to_organization_id NUMBER(15);
    v_ship_to_location_id NUMBER(15);

    --*********** for SO
    v_customer_id     NUMBER(15);
    v_customer_site_id    NUMBER(15);
    v_address_id      NUMBER(15);
    v_price_list_uom_code VARCHAR2(4);
    v_uom_conversion_rate NUMBER;
    v_assessable_amount   NUMBER;
    ln_vat_assess_amount  NUMBER;  -- added, Harshita for bug #4245062
    v_line_tax_amount   NUMBER;
    v_line_amount     NUMBER;
    v_date_ordered      DATE;
    v_converted_rate    NUMBER;
    v_qty_remaining     NUMBER;

    --*********** for REQUISITION
    v_currency_code     VARCHAR2(4);
    v_unit_price      NUMBER;
    v_supplier_location   PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE;
    v_supplier_name     PO_VENDORS.VENDOR_NAME%TYPE;

    j             NUMBER; -- used as a temperory variable

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors c_inv_set_of_books_id and c_opr_set_of_books_id
     * and implemented caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;


 -- add by Xiao for recording down the release version on 24-Jul-2009
  lv_release_name VARCHAR2(30);
  lv_other_release_info VARCHAR2(30);
  lb_result BOOLEAN := FALSE ;


  --//~~~~~~~~~ Definitions of Functions and Procedures required for this Concurrent ~~~~~~~~~~//
    FUNCTION ja_in_po_assessable_value RETURN NUMBER IS
      CURSOR c_get_price_list( p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
        SELECT price_list_id
        FROM JAI_CMN_VENDOR_SITES
        WHERE Vendor_Id = p_vendor_id
        AND Vendor_Site_Id = p_vendor_site_id;

      CURSOR c_get_assessable_value(p_price_list_id IN NUMBER, p_inv_item_id IN NUMBER, p_line_uom IN VARCHAR2) IS
        SELECT operand
        FROM qp_List_Lines_v
        WHERE list_header_id = p_price_list_id
        AND product_Id = p_inv_item_id
        AND product_uom_code = p_line_uom
        AND NVL( start_date_active, v_today - 1 ) <= v_today
        AND NVL( end_date_active, v_today + 1 ) >= v_today;

      v_price_list_id   NUMBER;
      v_assessable_val  NUMBER;
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
------------------------------------------------------------------------------------------
      -- Get category_set_name
      CURSOR category_set_name_cur
      IS
      SELECT
        category_set_name
      FROM
        mtl_default_category_sets_fk_v
      WHERE functional_area_desc = 'Order Entry';

      lv_category_set_name  VARCHAR2(30);

      -- Get the Excise Assessable Value based on the Excise price list Id, Inventory_item_id, uom code.
       CURSOR vend_ass_value_category_cur
       ( pn_price_list_id     NUMBER
       , pn_inventory_item_id NUMBER
       , pv_uom_code          VARCHAR2
       )
       IS
       SELECT
         b.operand          list_price
       FROM
         qp_list_lines         b
       , qp_pricing_attributes c
       WHERE b.list_header_id        = pn_price_list_id
         AND c.list_line_id          = b.list_line_id
         AND c.product_uom_code      = pv_uom_code
         AND NVL( start_date_active, SYSDATE- 1 ) <= SYSDATE
         AND NVL( end_date_active, SYSDATE +1 )>= SYSDATE
         AND EXISTS ( SELECT
                        'x'
                      FROM
                       mtl_item_categories_v d
                     WHERE d.category_set_name  = lv_category_set_name
                       AND d.inventory_item_id  = pn_inventory_item_id
                       AND c.product_attr_value = TO_CHAR(d.category_id)
                    );


--------------------------------------------------------------------------------------------
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, end


    BEGIN


-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
----------------------------------------------------------------------------------

      -- Get category_set_name
      OPEN category_set_name_cur;
      FETCH category_set_name_cur INTO lv_category_set_name;
      CLOSE category_set_name_cur;

      -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
      -- in the transaction. If yes, give an exception error message to stop transaction.

      -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
      IF lv_release_name NOT LIKE '12.0%' THEN

      Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => v_vendor_id
                                                     , pn_party_site_id     => v_vendor_site_id
                                                     , pn_inventory_item_id => v_inventory_item_id
                                                     , pd_ordered_date      => SYSDATE
                                                     , pv_party_type        => 'V'
                                                     , pn_pricing_list_id  => NULL
                                                     );
      END IF; -- lv_release_name NOT LIKE '12.0%'
----------------------------------------------------------------------------
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

      OPEN  c_get_price_list(v_vendor_id, v_vendor_site_id);
      FETCH c_get_price_list INTO v_price_list_id;
      CLOSE c_get_price_list;
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
----------------------------------------------------------------------------------
    IF lv_release_name NOT LIKE '12.0%' THEN --add condition for specific release version
      IF v_price_list_id IS NOT NULL
      THEN
        OPEN  c_get_assessable_value(v_price_list_id, v_inventory_item_id, v_uom_code);
        FETCH c_get_assessable_value INTO v_assessable_val;
        CLOSE c_get_assessable_value;

        IF v_assessable_val IS NULL
        THEN
          -- Get Excise assessable value of item category base on inventory_item_id and line_uom.
          OPEN vend_ass_value_category_cur(v_price_list_id, v_inventory_item_id, v_uom_code);
          FETCH vend_ass_value_category_cur INTO v_assessable_val;
          CLOSE vend_ass_value_category_cur;
        END IF;  -- v_assessable_val IS NULL
      END IF;  -- v_price_list_id IS NOT NULL
    END IF; --IF lv_release_name NOT LIKE '12.0%' THEN
----------------------------------------------------------------------------
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, end


-- Modified by Xiao for Advanced Pricing on 10-Jun-2009, begin
----------------------------------------------------------------------------------
      --IF v_price_list_id IS NULL THEN
     IF v_assessable_val IS NULL
     THEN
----------------------------------------------------------------------------------
-- Modified by Xiao for Advanced Pricing on 10-Jun-2009, end
        OPEN  c_get_price_list(v_vendor_id, 0);
        FETCH c_get_price_list INTO v_price_list_id;
        CLOSE c_get_price_list;
      END IF;

      IF v_price_list_id IS NOT NULL THEN
        OPEN  c_get_assessable_value(v_price_list_id, v_inventory_item_id, v_uom_code);
        FETCH c_get_assessable_value INTO v_assessable_val;
        CLOSE c_get_assessable_value;
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
------------------------------------------------------------------------------------------

     IF lv_release_name NOT LIKE '12.0%' THEN --add condition for specific release version

        IF v_assessable_val IS NULL
        THEN
          -- Get Excise assessable value of item category base on inventory_item_id and line_uom.
          OPEN vend_ass_value_category_cur(v_price_list_id, v_inventory_item_id, v_uom_code);
          FETCH vend_ass_value_category_cur INTO v_assessable_val;
          CLOSE vend_ass_value_category_cur;
        END IF;
     END IF; --lv_release_name NOT LIKE '12.0%'
--------------------------------------------------------------------------------------------
-- Added by Xiao for Advanced Pricing on 10-Jun-2009, end
      END IF;

      RETURN( v_assessable_val );
    END ja_in_po_assessable_value;



  BEGIN
  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - ja_in_mass_tax_changes_p.sql
  S.No  Date  Author and Details
  -------------------------------------------------
  1.  30/12/2002  cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                    This Procedure that is invoked by the concurrent request
                    'India - Mass Tax Recalculation' (JAINMTCH)

                      There are mainly FOUR program blocks in this procedure
                        1. Purchasing documents Block
                        2. Releases Block ( Processes releases created from Blanket or Planned Purchase Agreement)
                        3. Requisitions Block
                        4. Sales Order Block
                    This procedure processess one of the program blocks specified. Each block fetches the data that needs to be
                    applied with tax rate changes based on tax category id given in the setups or given in the input parameters.
                    Each program block does the following coding: Looks at the setups for the defaulting tax category and replaces
                    the old tax category with new tax category taxes and then recalculates the taxes. If there are any errors, then
                    related message or error message is updated in the records processed table( JAI_CMN_MTAX_UPD_DTLS)

  2.     27/01/2005 Harshita J for Bug #3765133 .  FileVersion# 115.1
            Changes made in the Procedure to capture tax_amounts for adhoc taxes.


  3.  12/03/2005   Bug 4210102. Added by LGOPALSA - Version 115.2
                   (1) Added Check file syntax in dbdrv
       (2) Added NOCOPY for OUT Parameter
       (3) Added CVD and Customs education cess


  4.  17-Mar-2005  hjujjuru - bug #4245062  File version 115.3
                    The Assessable Value is calculated for the transaction. For this, a call is
                    made to the function ja_in_vat_assessable_value_f.sql with the parameters
                    relevant for the transaction. This assessable value is again passed to the
                    procedure that calucates the taxes.

                    Base bug - #4245089

5. 28/04/2005  rallamse for Bug#4336482, Version 116.1
            For SEED there is a change in concurrent "JAINMTCH" to use FND_STANDARD_DATE with STANDARD_DATE format
            Procedure ja_in_mass_tax_changes signature modified by converting p_from_date, p_to_date of DATE datatype
            to pv_to_date, pv_to_date of varchar2 datatype. The varchar2 values are converted to DATE fromat
            using fnd_date.canonical_to_date function.

6. 08-Jun-2005  Version 116.2 jai_cmn_mtax -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

7. 13-Jun-2005 File Version: 116.3
                Ramananda for bug#4428980. Removal of SQL LITERALs is done

8. 25-Aug-2005 Aiyer bug 4565665,File Version 120.3
               Issue : Concurrent program India- Mass Tax REcalculation (JAINMTCH) was throwing the following errors
                      1. Wrong Number of arguments or types to do_tax_redefaultation .
                      2. Cannot insert null into JAI_CMN_MTAX_HDRS_ALL.
               Reason and Fix:-
                   1. As the concurrent program JAINMCTH does not have the parameter pv_dbms_output hence the reported error.
                      This parameter was previously added to debug from backend with dbms_output.
                      However as dbms_out.put_line is not standards compliant hence was modified to fnd_file.put_line
                      Now as the parameter pv_debug is already present both in the concurrent program registration and the current procedure
                      hence removed the pv_dbms_output from both spec and body and instead used the pv_debug for capturing the debug info.
                      This can now be also enabled from conc program.

                   2. Last_update_date and last_updated_by are not nulls in table JAI_CMN_MTAX_HDRS_ALL however the current procedure
                      was not inserting any value in this columnns, hence the reported error. Fixed this issue by adding these columns in the insert
                      statement.
              Dependency Due to this bug:-
               jai_cmn_mtax.pls (120.2)
9 25-Aug-2006  Bug 5490479, Added by aiyer, File version 120.7
               Issue:-
                Org_id parameter in all MOAC related Concurrent programs is getting derived from the profile org_id
                As this parameter is hidden hence not visible to users and so users cannot choose any other org_id from the security profile.

               Fix:-
                1. The Multi_org_category field for all MOAC related concurrent programs should be set to 'S' (indicating single org reports).
                   This would enable the SRS Operating Unit field. User would then be able to select operating unit values related to the
                   security profile.
                2. Remove the default value for the parameter p_org_id and make it Required false, Display false. This would ensure that null value gets passed
                   to the called procedures/ reports.
                3. Change the called procedures/reports. Remove the use of p_org_id and instead derive the org_id using the function mo_global.get_current_org_id
               This change has been made many procedures and reports.
               In the current procedure use of p_org_id is removed and instead ln_org_id a new local variable is defined . Value for it is derived as mentioend above
               and replaced at all places where p_org_id was being used.

10       18-05-2007  added by ssawant for bug 5604272
                    Cursor " CURSOR c_main_so" is modified.
                     It currently checks the status of a line thru a field called open_flag.
                     The correct way is to check the flow_Status_code field in the
                     oe_order_lines_all table . For a closed / Cancelled / SHIPPED order line the
                     values would be CLOSED CANCELLED SHIPPED respectively. So "AND oola.flow_status_code not in
                     ('CLOSED','CANCELLED','SHIPPED')" condition is added.
11. 05-Feb-2009   CSahoo for bug#8229357, File Version 120.5.12000000.4
                  Issue: INDIA "MASS-TAX RECALCULATION" ENDS IN WARNING
                  FIX: modified the code in the do_tax_redefaultation. Commented the check
                       for the value of release no.
12. 12-May-2009   JMEENA for bug#6335001
          Issue: VAT ASSESSABLE PRICE IN SO CHANGES AFTER RUNNING INDIA MASS TAX CALCULATION
          Fix:  Modified code to update the correct VAT Assessable Value in the table JAI_OM_OE_SO_LINES.

13. 28-Jul-2009  Xiao Lv for IL Advanced Pricing.
                 Add if condition control for specific release version, code as:
                 IF lv_release_name NOT LIKE '12.0%' THEN
                    Advanced Pricing code;
                 END IF;

  ===============================================================================
  Future  Dependencies

  Version  Author     Dependencies    Comments
  115.2    LGOPALSA    IN60106 +        Added Cess tax code
                        4146708

  115.3   hjujjuru    4245089         VAT Implelentationfnd_file.put_line(fnd_file.log,
  120.3   Aiyer       R12 JAI A      Changed for bug 4565665. Spec and body change in jai_cmn_mtax_pkg
  --------------------------------------------------------------------------------------------------------------------------*/

  -- Add code by Xiao to get release version on 24-Jul-2009
  lb_result := fnd_release.get_release(lv_release_name, lv_other_release_info);


    /*  Ramananda for File.Sql.35 */
        p_override_manual_taxes := nvl(pv_override_manual_taxes, jai_constants.no);
        p_commit_interval := nvl(pn_commit_interval,50);
        p_process_partial := nvl(pv_process_partial, jai_constants.no);
        p_debug := nvl(pv_debug,jai_constants.no);
        p_trace :=nvl(pv_trace, jai_constants.no) ;
        v_today           := trunc(sysdate);
        v_created_by      := nvl(FND_GLOBAL.USER_ID,-1);
        v_login_id        := nvl(FND_GLOBAL.LOGIN_ID,-1);
        v_user_id         := nvl(FND_GLOBAL.USER_ID,-1);
        v_message_01      := 'There is no defaulting tax category in the set up';
        v_debug           := FALSE;
        v_document_find_failed  := 'N';
        v_failed                := 'N';
        p_from_date       := fnd_date.canonical_to_date(pv_from_date);
        p_to_date         := fnd_date.canonical_to_date(pv_to_date);
        v_log_file_name   := 'jai_cmn_mtax_pkg.do_tax_redefaultation.log';
    /* Added below code for bug#7351304  by JMEENA*/
  IF p_from_date IS NULL THEN
    p_from_date := to_date('01/01/1940','DD-MM-YYYY');
  END IF;

  IF p_to_date IS NULL THEN
    p_to_date := SYSDATE+1;
  END IF;
   /*End Bug#7351304 */
   /*
        || Start of bug 5490479
        || Added by aiyer for the bug 5490479
        || Get the operating unit (org_id)
        */
        ln_org_id := mo_global.get_current_org_id;
        fnd_file.put_line(fnd_file.log, 'Operating unit ln_org_id is -> '||ln_org_id ||','|| p_from_date||','||p_to_date );
        /*End of bug 5490479 */

    /*  Ramananda for File.Sql.35 */

    IF p_debug = 'Y' THEN
      v_debug := TRUE;
    ELSE
      v_debug := FALSE;
    END IF;

    IF ln_org_id IS NULL OR ln_org_id = 0 THEN
      v_org_id := NULL;
    ELSE
      v_org_id := ln_org_id;
    END IF;

    --//~~~~~~~~~ Code for Trace and Log file generation ~~~~~~~~~//
    OPEN c_enable_trace('JAINMTCH');  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    FETCH c_enable_trace INTO v_enable_trace;
    CLOSE c_enable_trace;

    IF nvl(v_enable_trace, 'N') = 'Y' THEN

      /*
      || Start of bug 4517919
      ||Opened the existing cursor to get the database name
      || and called fnd_file.put_line to register the info
      || also changed the dbms_support.start and stop trace to execute immediate alter session code
      */
      OPEN get_audsid;
      FETCH get_audsid INTO v_sid, v_serial, v_spid;
      CLOSE get_audsid;

      OPEN get_dbname;
      FETCH get_dbname INTO v_name1;
      CLOSE get_dbname;

      FND_FILE.PUT_LINE( FND_FILE.log, 'TraceFile Name = '||lower(v_name1)||'_ora_'||v_spid||'.trc');

      EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';

    /*
    || End of bug 4517919
    */
    END IF;

    IF v_debug THEN
      BEGIN
        SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
          Value,SUBSTR (value,1,INSTR(value,',') -1)) INTO v_utl_location
        FROM v$parameter
        WHERE name = 'utl_file_dir';

      EXCEPTION
        WHEN OTHERS THEN
          v_debug := FALSE;
          -- RAISE_APPLICATION_ERROR(-20000, 'ERROR: WHEN OTHERS in UTL_FILE_DIR Query');
      END;
    END IF;

    IF v_debug THEN
      v_myfilehandle := UTL_FILE.FOPEN(v_utl_location, v_log_file_name ,'A');
      UTL_FILE.PUT_LINE(v_myfilehandle, '********* Start Mass Changes ('||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||') *********');
      UTL_FILE.PUT_LINE(v_myfilehandle, 'Input Parameters. ln_org_id -> '|| ln_org_id||
        ', p_document_type -> '||p_document_type || ', p_from_date -> '||p_from_date || ', p_to_date -> '||p_to_date ||
        ', p_supplier_id -> '||p_supplier_id || ', p_supplier_site_id -> '||p_supplier_site_id ||
        ', p_customer_id -> '||p_customer_id || ', p_customer_site_id -> '||p_customer_site_id ||
        ', p_old_tax_category -> '||p_old_tax_category || ', p_new_tax_category -> '||p_new_tax_category ||
        ', p_document_no -> '||p_document_no || ', p_release_no -> '||p_release_no ||
        ', p_document_line_no -> '||p_document_line_no || ', p_shipment_no -> '||p_shipment_no ||
        ', p_commit_interval -> '||p_commit_interval || ', p_override_manual_taxes -> '||p_override_manual_taxes ||
        ', p_process_partial -> '||p_process_partial
      );

    END IF;

    IF v_debug THEN
      fnd_file.put_line(fnd_file.log,'Input Parameters1. ln_org_id -> '|| ln_org_id||
        ', p_document_type -> '||p_document_type || ', p_from_date -> '||p_from_date || ', p_to_date -> '||p_to_date ||
        ', p_supplier_id -> '||p_supplier_id || ', p_supplier_site_id -> '||p_supplier_site_id ||
        ', p_customer_id -> '||p_customer_id || ', p_customer_site_id -> '||p_customer_site_id ||
        ', p_old_tax_category -> '||p_old_tax_category || ', p_new_tax_category -> '||p_new_tax_category
      );
      fnd_file.put_line(fnd_file.log,', p_document_no -> '||p_document_no || ', p_release_no -> '||p_release_no ||
        ', p_document_line_no -> '||p_document_line_no || ', p_shipment_no -> '||p_shipment_no ||
        ', p_commit_interval -> '||p_commit_interval || ', p_override_manual_taxes -> '||p_override_manual_taxes ||
        ', p_process_partial -> '||p_process_partial
      );
    END IF;

    --SELECT JAI_CMN_MTAX_HDRS_ALL_S.nextval INTO v_batch_id FROM dual;

    -- Entry into mass tax change requests table.
    INSERT INTO JAI_CMN_MTAX_HDRS_ALL
    (
      batch_id,
      org_id,
      document_type,
      from_date,
      to_date,
      supplier_id,
      supplier_site_id,
      customer_id,
      customer_site_id,
      old_tax_category,
      new_tax_category,
      process_partial,
      document_no,
      release_no,
      document_line_no,
      shipment_no,
      commit_interval,
      override_manual_taxes,
      error_message,
      creation_date,
      created_by,
      last_update_date, /* Aiyer for the bug 4565665. Added the columns last_update_date and last_updated_by */
      last_updated_by,
      program_application_id,
      program_id,
      program_login_id,
      request_id
    )
    VALUES
    (
      --v_batch_id,
      JAI_CMN_MTAX_HDRS_ALL_S.nextval,
      ln_org_id,
      p_document_type,
      p_from_date,
      p_to_date,
      p_supplier_id,
      p_supplier_site_id,
      p_customer_id,
      p_customer_site_id,
      p_old_tax_category,
      p_new_tax_category,
      p_process_partial,
      p_document_no,
      p_release_no,
      p_document_line_no,
      p_shipment_no,
      p_commit_interval,
      p_override_manual_taxes,
      null,
      SYSDATE,
      v_created_by,/* Aiyer for the bug 4565665. Added the columns last_update_date and last_updated_by */
      SYSDATE,
      v_created_by,
      FND_GLOBAL.PROG_APPL_ID,
      FND_GLOBAL.CONC_PROGRAM_ID,
      FND_GLOBAL.CONC_LOGIN_ID,
      FND_GLOBAL.CONC_REQUEST_ID
      /*fnd_profile.value('PROG_APPL_ID'),
      fnd_profile.value('CONC_PROGRAM_ID'),
      fnd_profile.value('CONC_LOGIN_ID'),
      fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
    )returning batch_id into v_batch_id;   /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

    COMMIT;

    IF v_debug THEN
      fnd_file.put_line( fnd_file.log, 'Batch ID -> '|| v_batch_id );
      utl_file.put_line( v_myfilehandle, 'Batch ID -> '|| v_batch_id );
    END IF;

    IF v_debug THEN
      fnd_file.put_line(fnd_file.log, 'Batch ID -> '|| v_batch_id );
    END IF;

  --//~~~~~~~~~ Actual Code of Tax Recalculation starts from here ~~~~~~~~~//

      -- Validation of the Input Variables.
    IF ( (p_old_tax_category IS NOT NULL AND p_new_tax_category IS NULL)
         OR
         (p_old_tax_category IS NULL AND p_new_tax_category IS NOT NULL)
       )
       THEN
      p_ret_code := 1;
      v_message := 'Both old and new tax category must be provided';
      p_err_buf := v_message;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, v_message);
        UTL_FILE.fclose(v_myfilehandle);
      END IF;

      UPDATE JAI_CMN_MTAX_HDRS_ALL SET error_message = v_message WHERE batch_id = v_batch_id;

      COMMIT;
      RETURN;
    END IF;

    -- PreProcessing of the Input Variables
    IF p_document_type = 'STANDARD_PO' THEN
      v_document_type := 'STANDARD';
      v_shipment_type := 'STANDARD';
    ELSIF p_document_type = 'PLANNED_PA' THEN
      v_document_type := 'PLANNED';
      v_shipment_type := 'PLANNED';
    ELSIF p_document_type = 'BLANKET_PA' THEN
      v_document_type := 'BLANKET';
      v_shipment_type := 'PRICE BREAK';
    ELSIF p_document_type = 'SCHEDULED_RELEASES' THEN
      v_document_type := 'PLANNED';
      v_shipment_type := 'SCHEDULED';
    ELSIF p_document_type = 'QUOTATION' THEN
      v_document_type := 'QUOTATION';
      v_shipment_type := 'QUOTATION';
    ELSIF p_document_type = 'RFQ' THEN
      v_document_type := 'RFQ';
      v_shipment_type := 'RFQ';
    ELSIF p_document_type = 'BLANKET_RELEASES' THEN
      v_document_type := 'BLANKET';
      v_shipment_type := 'BLANKET';
    ELSIF p_document_type = 'REQUISITION_IN' THEN
      v_document_type := 'INTERNAL';
      v_shipment_type := 'INTERNAL';
    ELSIF p_document_type = 'REQUISITION_PO' THEN
      v_document_type := 'PURCHASE';
      v_shipment_type := 'PURCHASE';
    ELSIF p_document_type = 'SALES_ORDERS' THEN
      v_document_type := 'SALES_ORDERS';
      v_shipment_type := 'SALES_ORDERS';
    END IF;

    -- hierarchy validation of the document numbers given
    IF p_shipment_no IS NULL THEN
      IF p_document_line_no IS NULL THEN
        IF v_document_type IN ( 'BLANKET', 'SCHEDULED') AND p_release_no IS NOT NULL THEN
          IF p_document_no IS NULL THEN
            v_failed := 'Y';
            v_message := 'Document Number should be given';
          END IF;
        END IF;
      ELSE    -- if the execution comes here it means line number is not null

        IF v_document_type IN ( /*'BLANKET',*/ 'SCHEDULED') AND p_release_no IS NULL THEN --Commented the Blanket Condition , for bug 8903890 FP from 8838321
          v_failed := 'Y';
          v_message := 'Release Number should be given';
        ELSIF v_document_type IN ( 'BLANKET', 'SCHEDULED') AND p_release_no IS NOT NULL THEN
          IF p_document_no IS NULL THEN
            v_failed := 'Y';
            v_message := 'Document Number should be given';
          END IF;
        ELSIF p_release_no IS NOT NULL THEN
          v_failed := 'Y';
          v_message := 'Release Number connot be given for '||v_document_type;
        ELSIF p_document_no IS NULL THEN
          v_failed := 'Y';
          v_message := 'Document Number should be given';
        END IF;
      END IF;
    ELSE

      IF p_document_line_no IS NULL THEN
        v_failed := 'Y';
        v_message := 'Document Line Number should be given';
      ELSE
        IF v_document_type IN ( /*'BLANKET', */'SCHEDULED') AND p_release_no IS NULL THEN  --Commented the Blanket Condition , for bug 8903890 FP from 8838321
          v_failed := 'Y';
          v_message := 'Release Number should be given';
        ELSIF v_document_type IN ( 'BLANKET', 'SCHEDULED') AND p_release_no IS NOT NULL THEN
          IF p_document_no IS NULL THEN
            v_failed := 'Y';
            v_message := 'Document Number should be given';
          END IF;
        ELSIF p_release_no IS NOT NULL THEN
          v_failed := 'Y';
          v_message := 'Release Number connot be given for '||v_document_type;
        ELSIF p_document_no IS NULL THEN
          v_failed := 'Y';
          v_message := 'Document Number should be given';
        END IF;
      END IF;
    END IF;

    If v_failed = 'Y' THEN
      p_ret_code := 1;
      p_err_buf := v_message;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, v_message);
        UTL_FILE.fclose(v_myfilehandle);
      END IF;

      UPDATE JAI_CMN_MTAX_HDRS_ALL SET error_message = v_message WHERE batch_id = v_batch_id;

      COMMIT;
      RETURN;
    END IF;

    -- This is for document_type in ('STANDARD', 'QUOTATION', 'RFQ', 'BLANKET' )

    IF p_document_no IS NOT NULL THEN
        -- The mass tax change is being run for one(1) PO or SO or RFQ document

      IF p_document_type IN ('BLANKET_RELEASES', 'RFQ', 'QUOTATION', 'SCHEDULED_RELEASES',
          'STANDARD_PO', 'PLANNED_PA', 'BLANKET_PA' )
      THEN
        OPEN c_po_header( v_document_type, p_document_no, v_org_id);
        FETCH c_po_header INTO v_po_header_id;
        CLOSE c_po_header;

        IF v_po_header_id IS NULL THEN
          -- Through the corresponding message
          v_document_find_failed := 'Y';
          v_message := 'The given document does not exist';

        ELSIF p_document_line_no IS NOT NULL THEN

          OPEN c_po_line( v_po_header_id, p_document_line_no);
          FETCH c_po_line INTO v_po_line_id;
          CLOSE c_po_line;

          IF v_po_line_id IS NULL THEN

            -- Through the corresponding message
            v_document_find_failed := 'Y';
            v_message := 'The given document line does not exist for the specified document';

          ELSIF p_shipment_no IS NOT NULL THEN

            IF p_release_no IS NOT NULL THEN
              OPEN c_po_release( v_po_header_id, p_release_no);
              FETCH c_po_release INTO v_po_release_id;
              CLOSE c_po_release;
            --added this else block for bug#8229357
            ELSE
              v_po_release_id := NULL;
            END IF;
            --commented this IF clause for bug#8229357
            --IF p_release_no IS NOT NULL AND v_po_release_id IS NOT NULL THEN

              OPEN c_shipment_line( v_po_line_id, p_shipment_no, v_shipment_type, v_po_release_id);
              FETCH c_shipment_line INTO v_shipment_id;
              CLOSE c_shipment_line;

              IF v_shipment_id IS NULL THEN
                -- Through the corresponding message
                v_document_find_failed := 'Y';
                v_message := 'The given shipment number does not exist';
              END IF;
           --commented this else clause for bug#8229357
           /* ELSE
              v_document_find_failed := 'Y';
              v_message := 'The given release number does not exist';

            END IF; */

          END IF;

        END IF;

      ELSIF p_document_type IN ('REQUISITION_IN', 'REQUISITION_PO' ) THEN
        OPEN c_requisition_header( v_document_type, p_document_no, v_org_id);
        FETCH c_requisition_header INTO v_reqn_header_id;
        CLOSE c_requisition_header;

        IF v_reqn_header_id IS NULL THEN
          v_document_find_failed := 'Y';
          v_message := 'The given document header could not be found';
        ELSIF p_document_line_no IS NOT NULL THEN
          OPEN c_requisition_line( v_reqn_header_id, p_document_line_no);
          FETCH c_requisition_line INTO v_reqn_line_id;
          CLOSE c_requisition_line;
          IF v_reqn_line_id IS NULL THEN
            v_document_find_failed := 'Y';
            v_message := 'The given document line could not be found';
          END IF;
        END IF;
      ELSE  -- 'SALES_ORDERS'
        OPEN c_so_header( to_number(p_document_no), v_org_id);
        FETCH c_so_header INTO v_so_header_id;
        CLOSE c_so_header;

        IF v_so_header_id IS NULL THEN
          v_document_find_failed := 'Y';
          v_message := 'The given document header could not be found';
        ELSIF p_document_line_no IS NOT NULL THEN
          OPEN c_so_line( v_so_header_id, p_document_line_no);
          FETCH c_so_line INTO v_so_line_id;
          CLOSE c_so_line;
          IF v_so_line_id IS NULL THEN
            v_document_find_failed := 'Y';
            v_message := 'The given document line could not be found';
          END IF;
        END IF;
      END IF;
    END IF;

    IF v_document_find_failed = 'Y' THEN

      UPDATE JAI_CMN_MTAX_HDRS_ALL
      SET error_message = v_message
      WHERE batch_id = v_batch_id;

      p_ret_code := 1;
      p_err_buf := v_message;

      COMMIT;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, v_message );
        UTL_FILE.fclose(v_myfilehandle);
      END IF;

      RETURN;

    END IF;

    IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, 'before Forloop 1'||', v_org_id -> '||v_org_id
        ||', v_document_type -> '||v_document_type ||', p_from_date -> '||p_from_date ||', p_to_date -> '||p_to_date
        ||', p_supplier_id -> '||p_supplier_id ||', p_supplier_site_id -> '||p_supplier_site_id
      );
    END IF;

  -- PURCHASING DOCUMENTS BLOCK
  /************
  STANDARD, PLANNED, BLANKET_PA, QUOTATION, RFQ
  ************/
  IF v_shipment_type IN ('STANDARD', 'PRICE BREAK', 'QUOTATION', 'RFQ', 'PLANNED' ) THEN
    FOR shipment_rec IN c_main_po( v_org_id, v_document_type, v_shipment_type,
        trunc(p_from_date), trunc(p_to_date),
        p_supplier_id, p_supplier_site_id, p_old_tax_category,
        p_document_no, p_document_line_no, p_shipment_no)  --***
    LOOP

    BEGIN

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Forloop 1');
      END IF;

      IF shipment_rec.line_location_id IS NOT NULL AND shipment_rec.line_location_id > 0 THEN
        v_line_location_id := shipment_rec.line_location_id;
      ELSE
        v_line_location_id := null;
      END IF;

      -- Check for Partially reveived or not, if partial then skip the PO line location processing
      IF shipment_rec.quantity_received > 0 AND
        shipment_rec.shipment_qty <> shipment_rec.quantity_received AND p_process_partial = 'N'
      THEN

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'Partilly received Shipment line cannot be processed. PO No. '||shipment_rec.document_no||
            ', PO header id -> '||shipment_rec.po_header_id||
            ', line id -> '|| shipment_rec.po_line_id||
            ', line location id -> '|| v_line_location_id||
            ', line focus id -> '|| shipment_rec.line_focus_id||
            ', quantity -> '||shipment_rec.shipment_qty||
            ', quantity_received -> '||shipment_rec.quantity_received
          );
        END IF;

        IF v_debug THEN
          fnd_file.put_line(fnd_file.log, 'Partilly received Shipment line cannot be processed. PO No. '||shipment_rec.document_no||
            ', PO header id -> '||shipment_rec.po_header_id||
            ', line id -> '|| shipment_rec.po_line_id||
            ', line location id -> '|| v_line_location_id||
            ', line focus id -> '|| shipment_rec.line_focus_id||
            ', quantity -> '||shipment_rec.shipment_qty||
            ', quantity_received -> '||shipment_rec.quantity_received
          );
        END IF;

        GOTO skip_record;
      END IF;

      -- ENTRY INTO Request Details table that contains the shipment records processed during Mass Tax Changes
      -- If any error occurs while processing the record, the error_reason column is updated with corresponding error message
      -- later in the code
      INSERT INTO JAI_CMN_MTAX_UPD_DTLS ( MTAX_DTL_ID,
                                          batch_id,
                                          detail_id,
                                          document_type,
                                          document_no,
                                          document_line_no,
                                          shipment_no,
                                          old_tax_category_id,
                                          program_application_id,
                                          program_id,
                                          program_login_id,
                                          request_id,
                                          created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                          creation_date   ,
                                          last_updated_by  ,
                                          last_update_date
                                         )
                                 VALUES  (
                                          jai_cmn_mtax_upd_dtls_s.nextval,
                                          v_batch_id,
                                          shipment_rec.line_focus_id,
                                          shipment_rec.shipment_type,
                                          shipment_rec.document_no,
                                          shipment_rec.line_num,
                                          shipment_rec.shipment_num,
                                          shipment_rec.tax_category_id,
                                          FND_GLOBAL.PROG_APPL_ID,
                                          FND_GLOBAL.CONC_PROGRAM_ID,
                                          FND_GLOBAL.CONC_LOGIN_ID,
                                          FND_GLOBAL.CONC_REQUEST_ID,
                                         /*fnd_profile.value('PROG_APPL_ID'),
                                           fnd_profile.value('CONC_PROGRAM_ID'),
                                           fnd_profile.value('CONC_LOGIN_ID'),
                                           fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                          v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                          sysdate,
                                          v_created_by,
                                          sysdate
                                        );

      --************************** SAVEPOINT  **************************

      SAVEPOINT point1;

      --****************************************************************
      --* Code to get the GL_Set_of_Books_id *

      /* Bug 5243532. Added by Lakshmi Gopalsami
         Removed the cursor c_inv_set_of_books_id and implemented
   caching logic to get SOB
       */
      IF shipment_rec.ship_to_organization_id IS NOT NULL AND shipment_rec.ship_to_organization_id <> -1 THEN
        v_organization_id := shipment_rec.ship_to_organization_id;

      ELSIF shipment_rec.ship_to_location_id IS NOT NULL AND shipment_rec.ship_to_location_id <> -1 THEN
        OPEN c_inv_organization( shipment_rec.ship_to_location_id );
        FETCH c_inv_organization INTO v_organization_id;
        CLOSE c_inv_organization;

      ELSIF shipment_rec.hdr_ship_to_location_id IS NOT NULL THEN
        OPEN c_inv_organization( shipment_rec.hdr_ship_to_location_id );
        FETCH c_inv_organization INTO v_organization_id;
        CLOSE c_inv_organization;

      END IF;

      /* Bug 5243532. Added by Lakshmi Gopalsami
        Removed the reference to cursor c_inv_set_of_books_id
  and implemented using caching logic.
      */
      l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr (p_org_id  => v_organization_id );
      v_sob_id    := l_func_curr_det.ledger_id;
      v_func_curr := l_func_curr_det.currency_code;
      -- end for bug 5243532


      IF v_sob_id IS NULL THEN
       /*  Bug 5243532. Added by Lakshmi Gopalsami
           Removed the reference to cursor c_opr_set_of_books_id
     and implemented using caching logic.

        */
  l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr (p_org_id  => v_org_id );
        v_sob_id := l_func_curr_det.ledger_id;
        v_func_curr := l_func_curr_det.currency_code;

      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||shipment_rec.ship_to_organization_id ||', '||shipment_rec.vendor_id
          ||', '||shipment_rec.vendor_site_id ||', '|| shipment_rec.item_id ||', '||shipment_rec.po_header_id
          ||', '||shipment_rec.po_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;

      IF v_debug THEN
        fnd_file.put_line(fnd_file.log, 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||shipment_rec.ship_to_organization_id ||', '||shipment_rec.vendor_id
          ||', '||shipment_rec.vendor_site_id ||', '|| shipment_rec.item_id ||', '||shipment_rec.po_header_id
          ||', '||shipment_rec.po_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;

      -- finding out the tax category that will be used for defaulting.
      IF p_old_tax_category IS NULL THEN
        jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes( shipment_rec.ship_to_organization_id,
          shipment_rec.vendor_id, shipment_rec.vendor_site_id, shipment_rec.item_id,
          shipment_rec.po_header_id, shipment_rec.po_line_id, v_dflt_tax_category_id);
      ELSE
        v_dflt_tax_category_id := p_new_tax_category;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log,'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;

      IF v_dflt_tax_category_id IS NOT NULL THEN

        /*Validation whether the taxes can be modified or not based on Tax Dependencies and if they can removed,
        then remove the lines that are defaulted during the Shipment Creation and keep the others.
        If there is any discrepency, then the function should return with corresponding errcode based on which the
        taxes recalculation to be done or not will be decided
        */

        -- The adhoc data is preserved to capture the tax_amount later.
        -- added by Harshita for Bug #3765133

          insert into JAI_PO_TAXES
              (tax_line_no,po_line_id,po_header_id,
              line_focus_id,tax_id, tax_amount,
              creation_date,created_by,
              last_update_date, last_updated_by,last_update_login)
           SELECT
              A.tax_line_no,A.po_line_id,A.po_header_id,
              -A.line_focus_id,A.tax_id, A.tax_amount,
              A.creation_date,A.created_by,
              A.last_update_date, A.last_updated_by,A.last_update_login
           FROM
              JAI_PO_TAXES A,
              JAI_CMN_TAXES_ALL B
           WHERE
              A.tax_id = B.tax_id AND
              line_focus_id  = shipment_rec.line_focus_id AND
              NVL(adhoc_flag,'N') = 'Y';

        -- end, Harshita for Bug #3765133

        IF p_override_manual_taxes = 'Y' THEN
          DELETE FROM JAI_PO_TAXES
          WHERE line_focus_id = shipment_rec.line_focus_id;

          v_success := 5; -- means the override manual taxes is selected by user and all the attached taxes with the shipment are removed to default the new taxes
        ELSE
          jai_cmn_mtax_pkg.del_taxes_after_validate
          ( 'PO', shipment_rec.line_focus_id, v_line_location_id, shipment_rec.po_line_id,
            v_success, v_message
           );
        END IF;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,  'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;

        IF v_success IN (1, 3, 5) THEN

          -- Now go to the line location and add the taxes as per the new tax category
          j := 0;
          FOR tax_rec IN c_tax_category_taxes(v_dflt_tax_category_id) LOOP
            j := j + 1;
                  /* Added by LGOPALSA. Bu g4210102.
             * Added CVD and Customs education cess */
            IF upper(tax_rec.tax_type) IN (
            'CVD',
      jai_constants.tax_type_add_cvd ,      -- Date 31/10/2006 Bug 5228046 added by SACSETHI
      'CUSTOMS',
       jai_constants.tax_type_cvd_Edu_cess,
                   jai_constants.tax_type_customs_edu_cess  ,
       jai_constants.tax_type_sh_customs_edu_cess,   -- Date 18/06/2007 Bug 6130025 added by SACSETHI
       jai_constants.tax_type_sh_cvd_edu_cess
                   )
            THEN
              v_vendor_id := NULL;
            ELSIF UPPER( tax_rec.tax_type ) LIKE UPPER( '%EXCISE%' ) THEN
              v_vendor_id := shipment_rec.vendor_id;
            ELSIF tax_rec.tax_type = 'TDS' THEN
              v_vendor_id := tax_rec.vendor_id;
            ELSE
              v_vendor_id := NVL( tax_rec.vendor_id, shipment_rec.vendor_id );
            END IF;

            IF tax_rec.mod_cr_percentage IS NOT NULL AND tax_rec.mod_cr_percentage > 0 THEN
              v_modvat := 'Y';
            ELSE
              v_modvat := 'N';
            END IF;

            IF v_debug THEN
              -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        fnd_file.put_line(fnd_file.log,'tax_id -> '||tax_rec.tax_id||', tax_rec.p_1 -> '||tax_rec.p_1
                ||', tax_rec.p_2 -> '||tax_rec.p_2||', tax_rec.p_3 -> '||tax_rec.p_3
                ||', tax_rec.p_4 -> '||tax_rec.p_4||', tax_rec.p_5 -> '||tax_rec.p_5
                ||', tax_rec.p_6 -> '||tax_rec.p_6||', tax_rec.p_7 -> '||tax_rec.p_7
                ||', tax_rec.p_8 -> '||tax_rec.p_8||', tax_rec.p_9 -> '||tax_rec.p_9
                ||', tax_rec.p_10 -> '||tax_rec.p_10 );
            END IF;


            INSERT INTO JAI_PO_TAXES(
              line_location_id, tax_line_no, po_line_id, po_header_id,
              precedence_1,
        precedence_2,
        precedence_3,
        precedence_4,
        precedence_5,
              precedence_6,
        precedence_7,
        precedence_8,
        precedence_9,
        precedence_10,
              tax_id, currency, tax_rate, qty_rate, uom,
              tax_amount, tax_type, vendor_id, modvat_flag,
              tax_target_amount, line_focus_id, creation_date,
              created_by, last_update_date, last_updated_by,
              last_update_login, tax_category_id
            ) VALUES (
              v_line_location_id, j, shipment_rec.po_line_id, shipment_rec.po_header_id,
              tax_rec.p_1,
        tax_rec.p_2,
        tax_rec.p_3,
        tax_rec.p_4,
        tax_rec.p_5,
              tax_rec.p_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        tax_rec.p_7,
        tax_rec.p_8,
        tax_rec.p_9,
        tax_rec.p_10,
              tax_rec.tax_id, shipment_rec.currency_code, tax_rec.tax_rate, tax_rec.tax_amount, tax_rec.uom_code,
              0, tax_rec.tax_type, v_vendor_id, v_modvat,
              0, shipment_rec.line_focus_id, SYSDATE,
              v_created_by, SYSDATE, v_user_id,
              v_login_id, v_dflt_tax_category_id
            );

           END LOOP;


          /* Harshita - Update the tax_amount in the latest records
             to the previous tax amounts for all adhoc tax types.  -- Bug #3765133*/

          UPDATE
            JAI_PO_TAXES a
          SET
            tax_amount = (SELECT tax_amount
              FROM JAI_PO_TAXES
              where tax_id = a.tax_id
              and line_focus_id = -shipment_rec.line_focus_id)
          WHERE
            line_focus_id = shipment_rec.line_focus_id
            and tax_id in (SELECT tax_id
              FROM JAI_PO_TAXES
              where line_focus_id = -shipment_rec.line_focus_id);

          -- ended, Harshita for Bug #3765133


          UPDATE JAI_CMN_MTAX_UPD_DTLS SET new_tax_category_id = v_dflt_tax_category_id
          WHERE batch_id = v_batch_id AND detail_id = shipment_rec.line_focus_id;

          IF p_override_manual_taxes <> 'Y' THEN
            --* modifying the tax line number of the manual taxes starting from 1..n manual taxes *
            FOR tax_rec IN c_manual_taxes_up(v_line_location_id, shipment_rec.line_focus_id) LOOP
              j := j + 1;
              UPDATE JAI_PO_TAXES SET tax_line_no = j
              WHERE rowid = tax_rec.rowid;
            END LOOP;
          END IF;

          -- tax recalculation is not needed if line_location is null
          IF v_line_location_id IS NOT NULL THEN
      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Removed the reference to c_func_curr as the functional
       * currency is already derived via caching logic.
       */
            IF v_func_curr <> shipment_rec.currency_code THEN
              v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion
                                    (v_sob_id, shipment_rec.currency_code, shipment_rec.rate_date,
                                     shipment_rec.rate_type, 1
                                     );
            ELSE
              v_curr_conv_rate := 1;
            END IF;

            -- get the assessable value as of the date for the tax calculation *
            -- Following parameters should be set before calling JA_IN_PO_ASSESSABLE_VALUE function
            v_vendor_id := shipment_rec.vendor_id;
            v_vendor_site_id := shipment_rec.vendor_site_id;
            v_inventory_item_id := shipment_rec.item_id;

            v_line_uom := nvl(shipment_rec.unit_meas_lookup_code, shipment_rec.line_uom);
            OPEN c_uom_code(v_line_uom);
            FETCH c_uom_code INTO v_uom_code;
            CLOSE c_uom_code;

            v_assessable_value := ja_in_po_assessable_value;  -- internal function call.

            IF NVL( v_assessable_value, 0 ) <= 0 THEN
              v_assessable_value := shipment_rec.price_override * shipment_rec.shipment_qty;
            ELSE
              v_assessable_value := v_assessable_value * shipment_rec.shipment_qty;
            END IF;

            -- added, Harshita for bug #4245062
            ln_vat_assess_value :=
              jai_general_pkg.ja_in_vat_assessable_value
              ( p_party_id => v_vendor_id,
                p_party_site_id => v_vendor_site_id,
                p_inventory_item_id => v_inventory_item_id,
                p_uom_code => v_uom_code,
                p_default_price => shipment_rec.price_override,
                p_ass_value_date => trunc(SYSDATE),
                p_party_type => 'V'
              ) ;

            ln_vat_assess_value := ln_vat_assess_value * shipment_rec.shipment_qty;

            --ended, Harshita for bug #4245062

            --recalculate the taxes based on the tax lines that are replaced along with the assessable value of the item
            jai_po_tax_pkg.calc_tax
            (
              p_type => 'STANDARDPO',
              p_header_id => shipment_rec.po_header_id,
              P_line_id => shipment_rec.po_line_id,
              p_line_location_id => v_line_location_id,
              p_line_focus_id => shipment_rec.line_focus_id,
              p_line_quantity => shipment_rec.shipment_qty,
              p_base_value => shipment_rec.price_override * shipment_rec.shipment_qty,
              p_line_uom_code => v_uom_code,
              p_tax_amount => v_tax_amount,
              p_assessable_value => v_assessable_value,
              p_vat_assess_value => ln_vat_assess_value,    -- added, Harshita for bug #4245062
              p_item_id => shipment_rec.item_id,
              p_conv_rate => v_curr_conv_rate,
              p_po_curr => shipment_rec.currency_code,
              p_func_curr => v_func_curr
            );

          END IF;

          UPDATE JAI_PO_LINE_LOCATIONS
          SET tax_category_id = v_dflt_tax_category_id
          WHERE rowid = shipment_rec.rowid;

        ELSE  -- Failed to remove old taxes and insert new taxes because of some reason(will be shown in the LOG)

            -- v_message := v_message_01;
          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = shipment_rec.line_focus_id;

          -- Write the details of the Shipment Details to the log file why the taxes were not recalculated *
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, 'No Tax Changes for Order No. '||shipment_rec.document_no||', -> '|| shipment_rec.po_line_id||
              ', PO hdr_id -> '||shipment_rec.po_header_id||
              ', line_id -> '|| shipment_rec.po_line_id||', shipment_id -> '|| v_line_location_id ||
              ', vendor_id -> '||shipment_rec.vendor_id||
              ', vendor_site_id -> '||shipment_rec.vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;
          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, 'No Tax Changes for Order No. '||shipment_rec.document_no||', -> '|| shipment_rec.po_line_id||
              ', PO hdr_id -> '||shipment_rec.po_header_id||
              ', line_id -> '|| shipment_rec.po_line_id||', shipment_id -> '|| v_line_location_id ||
              ', vendor_id -> '||shipment_rec.vendor_id||
              ', vendor_site_id -> '||shipment_rec.vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;

        END IF;

        --added, Harshita for Bug#3765133
        /* Temporary data stored previously will be flushed using following DELETE */
          DELETE FROM JAI_PO_TAXES
          WHERE line_focus_id = -shipment_rec.line_focus_id;
        --ended, Harshita for Bug#3765133

      ELSE  -- IF v_dflt_tax_category_id IS NOT NULL THEN

        v_message := v_message_01;
        UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
        WHERE batch_id = v_batch_id AND detail_id = shipment_rec.line_focus_id;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'v_dflt_tax_category_id is null for : Order No. '||shipment_rec.document_no||', -> '|| shipment_rec.po_line_id||
            ', PO hdr_id -> '||shipment_rec.po_header_id||
            ', line_id -> '|| shipment_rec.po_line_id||', shipment_id -> '|| v_line_location_id ||
            ', vendor_id -> '||shipment_rec.vendor_id||
            ', vendor_site_id -> '||shipment_rec.vendor_site_id
           );
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'v_dflt_tax_category_id is null for : Order No. '||shipment_rec.document_no||', -> '|| shipment_rec.po_line_id||
            ', PO hdr_id -> '||shipment_rec.po_header_id||
            ', line_id -> '|| shipment_rec.po_line_id||', shipment_id -> '|| v_line_location_id ||
            ', vendor_id -> '||shipment_rec.vendor_id||
            ', vendor_site_id -> '||shipment_rec.vendor_site_id
           );
        END IF;
      END IF;

      IF v_commit_interval < p_commit_interval THEN
        v_commit_interval := v_commit_interval + 1;
      ELSE
        COMMIT;
        v_commit_interval := 0;
      END IF;


      <<skip_record>>
      null;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO point1;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log,'ROLLBACK to point1, error ->'||SQLERRM );
          END IF;

          IF v_message IS NULL THEN
            v_message := 'Dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          ELSE
            v_message := v_message||', dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          END IF;

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = shipment_rec.line_focus_id;


          IF SQL%NOTFOUND THEN
            INSERT INTO jai_cmn_mtax_upd_dtls (
                                                mtax_dtl_id,
                                                batch_id,
                                                detail_id,
                                                document_type,
                                                document_no,
                                                document_line_no,
                                                shipment_no,
                                                old_tax_category_id,
                                                new_tax_category_id,
                                                error_reason,
                                                program_application_id,
                                                program_id,
                                                program_login_id,
                                                request_id    ,
                                                created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                                creation_date   ,
                                                last_updated_by  ,
                                                last_update_date

                                              )
                                      VALUES (  jai_cmn_mtax_upd_dtls_s.nextval,
                                                v_batch_id,
                                                shipment_rec.line_focus_id,
                                                shipment_rec.shipment_type,
                                                shipment_rec.document_no,
                                                shipment_rec.line_num,
                                                shipment_rec.shipment_num,
                                                shipment_rec.tax_category_id,
                                                v_dflt_tax_category_id,
                                                v_message,
                                                FND_GLOBAL.PROG_APPL_ID,
                                                FND_GLOBAL.CONC_PROGRAM_ID,
                                                FND_GLOBAL.CONC_LOGIN_ID,
                                                FND_GLOBAL.CONC_REQUEST_ID,
                                               /*fnd_profile.value('PROG_APPL_ID'),
                                                 fnd_profile.value('CONC_PROGRAM_ID'),
                                                 fnd_profile.value('CONC_LOGIN_ID'),
                                                 fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                                v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                                sysdate,
                                                v_created_by,
                                                sysdate
                                            );

          END IF;
      END;

      v_dflt_tax_category_id := null;
      v_vendor_id := null;
      v_vendor_site_id := null;
      v_inventory_item_id := null;
      v_line_uom := null;
      v_uom_code := null;
      v_assessable_value := null;
      ln_vat_assess_value := null; -- added, Harshita for bug #4245062
      v_modvat := 'N';
      v_tax_amount := null;
      v_sob_id := null;
      v_organization_id := null;
      v_func_curr := null;
      v_curr_conv_rate := null;
      v_ship_to_organization_id := null;
      v_ship_to_location_id := null;
      j := null;

      v_success := null;
      v_message := null;

    END LOOP;

  -- RELEASES BLOCK
  /************************
  BLANKET, SCHEDULED RELEASES
  ************************/
    ELSIF v_shipment_type IN ('BLANKET', 'SCHEDULED') THEN

    FOR releases_rec IN c_main_releases( v_org_id, v_document_type, v_shipment_type,
        trunc(p_from_date), trunc(p_to_date),
        p_supplier_id, p_supplier_site_id, p_old_tax_category,
        p_document_no, p_release_no, p_document_line_no, p_shipment_no )
    LOOP

      BEGIN

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Forloop 2');
      END IF;

      -- v_qty_remaining := releases_rec.shipment_qty - releases_rec.quantity_received;
      -- Check for Partially received or not, if partial then skip the PO line location processing
      IF releases_rec.quantity_received > 0 AND
        releases_rec.shipment_qty <> releases_rec.quantity_received AND p_process_partial = 'N'
      THEN
        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'Partilly received Shipment line cannot be processed. PO No. '||releases_rec.document_no||
            ', PO header id -> '||releases_rec.po_header_id||
            ', line id -> '|| releases_rec.po_line_id||
            ', line location id -> '|| releases_rec.line_location_id||
            ', line focus id -> '|| releases_rec.line_focus_id||
            ', quantity -> '||releases_rec.shipment_qty||
            ', quantity_received -> '||releases_rec.quantity_received
          );
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log, 'Partilly received Shipment line cannot be processed. PO No. '||releases_rec.document_no||
            ', PO header id -> '||releases_rec.po_header_id||
            ', line id -> '|| releases_rec.po_line_id||
            ', line location id -> '|| releases_rec.line_location_id||
            ', line focus id -> '|| releases_rec.line_focus_id||
            ', quantity -> '||releases_rec.shipment_qty||
            ', quantity_received -> '||releases_rec.quantity_received
          );
        END IF;

        GOTO skip_record;
      END IF;

      -- ENTRY INTO Request Details table that contains the shipment records processed during Mass Tax Changes
      -- If any error occurs while processing the record, the error_reason column is updated with corresponding error message
      -- later in the code
      INSERT INTO jai_cmn_mtax_upd_dtls ( mtax_dtl_id,
                                          batch_id,
                                          detail_id,
                                          document_type,
                                          document_no,
                                          release_no,
                                          document_line_no,
                                          shipment_no,
                                          old_tax_category_id,
                                          program_application_id,
                                          program_id,
                                          program_login_id,
                                          request_id,
                                          created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                          creation_date   ,
                                          last_updated_by  ,
                                          last_update_date
                                        )
                                VALUES  (
                                          jai_cmn_mtax_upd_dtls_s.nextval,
                                          v_batch_id,
                                          releases_rec.line_focus_id,
                                          releases_rec.shipment_type,
                                          releases_rec.document_no,
                                          releases_rec.release_num,
                                          releases_rec.line_num,
                                          releases_rec.shipment_num,
                                          releases_rec.tax_category_id,
                                          FND_GLOBAL.PROG_APPL_ID,
                                          FND_GLOBAL.CONC_PROGRAM_ID,
                                          FND_GLOBAL.CONC_LOGIN_ID,
                                          FND_GLOBAL.CONC_REQUEST_ID,
                                         /*fnd_profile.value('PROG_APPL_ID'),
                                           fnd_profile.value('CONC_PROGRAM_ID'),
                                           fnd_profile.value('CONC_LOGIN_ID'),
                                           fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                          v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                          sysdate,
                                          v_created_by,
                                          sysdate
                                         );

      --************************** SAVEPOINT  **************************
      SAVEPOINT point2;
      --****************************************************************

      -- WHEN there are no price breaks attached for BPO, then line_location_id will be null
      IF releases_rec.line_location_id IS NULL OR releases_rec.shipment_type IS NULL THEN
        v_ship_to_location_id := releases_rec.hdr_ship_to_location_id;
      ELSE
        v_ship_to_location_id := releases_rec.ship_to_location_id;
        v_organization_id := releases_rec.ship_to_organization_id;
      END IF;

      -- IF releases_rec.ship_to_organization_id IS NOT NULL THEN
      /* Bug 5243532. Added by Lakshmi Gopalsami
        Removed the reference to cursor c_inv_set_of_books_id
  and implemented using caching logic. Go to get_sob_id
  after getting organization_id.
      */
      IF v_organization_id IS NOT NULL THEN
        -- OPEN c_inv_set_of_books_id( releases_rec.ship_to_organization_id );
         GOTO get_sob_id;
      ELSIF v_ship_to_location_id IS NOT NULL THEN
        OPEN c_inv_organization( v_ship_to_location_id );
        FETCH c_inv_organization INTO v_organization_id;
        CLOSE c_inv_organization;

      ELSIF releases_rec.hdr_ship_to_location_id IS NOT NULL THEN
        OPEN c_inv_organization( releases_rec.hdr_ship_to_location_id );
        FETCH c_inv_organization INTO v_organization_id;
        CLOSE c_inv_organization;

      END IF;

      /*  Bug 5243532. Added by Lakshmi Gopalsami
          Implemented caching logic
       */
      <<get_sob_id>>
      l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_organization_id );
      v_sob_id := l_func_curr_det.ledger_id;
      v_func_curr := l_func_curr_det.currency_code;

      /*  Bug 5243532. Added by Lakshmi Gopalsami
           Removed the reference to cursor c_opr_set_of_books_id
     and implemented using caching logic.

      */
      IF v_sob_id IS NULL THEN
  l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_org_id );
        v_sob_id := l_func_curr_det.ledger_id;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||v_organization_id ||', '||releases_rec.vendor_id
          ||', '||releases_rec.vendor_site_id ||', '|| releases_rec.item_id ||', '||releases_rec.po_header_id
          ||', '||releases_rec.po_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log, 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||v_organization_id ||', '||releases_rec.vendor_id
          ||', '||releases_rec.vendor_site_id ||', '|| releases_rec.item_id ||', '||releases_rec.po_header_id
          ||', '||releases_rec.po_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;


      IF p_old_tax_category IS NULL THEN
        jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes( v_organization_id,
          releases_rec.vendor_id, releases_rec.vendor_site_id, releases_rec.item_id,
          releases_rec.po_header_id, releases_rec.po_line_id, v_dflt_tax_category_id);
      ELSE
        v_dflt_tax_category_id := p_new_tax_category;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id );
      END IF;

      IF v_dflt_tax_category_id IS NOT NULL THEN

        /* Validation whether the taxes can be modified or not based on Tax Dependencies and if they can,
        then remove the lines that are defaulted during the Shipment Creation and keep the others as it is
        If there is any discrepency, then the function should return corresponding value based on which the
        taxes recalculation or Not will be decided */

        -- The adhoc data is preserved to capture the tax_amount later.
        -- added by Harshita for Bug #3765133

          insert into JAI_PO_TAXES
              (tax_line_no,po_line_id,po_header_id,
              line_focus_id,tax_id, tax_amount,
              creation_date,created_by,
              last_update_date, last_updated_by,last_update_login)
           SELECT
              A.tax_line_no,A.po_line_id,A.po_header_id,
              -A.line_focus_id,A.tax_id, A.tax_amount,
              A.creation_date,A.created_by,
              A.last_update_date, A.last_updated_by,A.last_update_login
           FROM
              JAI_PO_TAXES A,
              JAI_CMN_TAXES_ALL B
           WHERE
              A.tax_id = B.tax_id AND
              line_focus_id  = releases_rec.line_focus_id AND
              NVL(adhoc_flag,'N') = 'Y';
        -- end, Harshita for Bug #3765133

        IF p_override_manual_taxes = 'Y' THEN
          DELETE FROM JAI_PO_TAXES
          WHERE line_focus_id = releases_rec.line_focus_id;

          v_success := 5; -- means the override manual taxes is selected by user and all the attached taxes with the shipment are removed to default the new taxes
        ELSE
          jai_cmn_mtax_pkg.del_taxes_after_validate
          ( 'PO', releases_rec.line_focus_id, releases_rec.line_location_id, releases_rec.po_line_id,
            v_success, v_message
           );
        END IF;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,  'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log, 'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;

        IF v_success IN (1, 3, 5) THEN

          -- Now go to the line location and add the taxes as per the new tax category
          j := 0;
          FOR tax_rec IN c_tax_category_taxes(v_dflt_tax_category_id) LOOP
            j := j + 1;
            /* Added by LGOPALSA. Bug 4210102.
             * Added CVD and customs edu cess */

            IF upper(tax_rec.tax_type) IN (
                                      'CVD',
              jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
              'CUSTOMS',
                                            jai_constants.tax_type_customs_edu_Cess,
                                            jai_constants.tax_type_cvd_edu_cess  ,
                                            jai_constants.tax_type_sh_customs_edu_cess, -- Date 18/06/2007 Bug 6130025 added by SACSETHI
                                jai_constants.tax_type_sh_cvd_edu_cess  -- Date 18/06/2007 Bug 6130025 added by SACSETHI
                                          )
            THEN
              v_vendor_id := NULL;
            ELSIF UPPER( tax_rec.tax_type ) LIKE UPPER( '%EXCISE%' ) THEN
              v_vendor_id := releases_rec.vendor_id;
            ELSIF tax_rec.tax_type = 'TDS' THEN
              v_vendor_id := tax_rec.vendor_id;
            ELSE
              v_vendor_id := NVL( tax_rec.vendor_id, releases_rec.vendor_id );
            END IF;

            IF tax_rec.mod_cr_percentage IS NOT NULL AND tax_rec.mod_cr_percentage > 0 THEN
              v_modvat := 'Y';
            ELSE
              v_modvat := 'N';
            END IF;

            IF v_debug THEN
      -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              fnd_file.put_line(fnd_file.log,'tax_id -> '||tax_rec.tax_id||', tax_rec.p_1 -> '||tax_rec.p_1
                ||', tax_rec.p_2 -> '||tax_rec.p_2||', tax_rec.p_3 -> '||tax_rec.p_3
                ||', tax_rec.p_4 -> '||tax_rec.p_4||', tax_rec.p_5 -> '||tax_rec.p_5
                ||', tax_rec.p_6 -> '||tax_rec.p_6||', tax_rec.p_7 -> '||tax_rec.p_7
                ||', tax_rec.p_8 -> '||tax_rec.p_8||', tax_rec.p_9 -> '||tax_rec.p_9
                ||', tax_rec.p_10 -> '||tax_rec.p_10 );
            END IF;

            INSERT INTO JAI_PO_TAXES(
              line_location_id, tax_line_no, po_line_id, po_header_id,
              precedence_1,
        precedence_2,
        precedence_3,
        precedence_4,
        precedence_5,
              precedence_6,
        precedence_7,
        precedence_8,
        precedence_9,
        precedence_10,
        tax_id, currency, tax_rate, qty_rate, uom,
              tax_amount, tax_type, vendor_id, modvat_flag,
              tax_target_amount, line_focus_id, creation_date,
              created_by, last_update_date, last_updated_by,
              last_update_login, tax_category_id
            ) VALUES (
              releases_rec.line_location_id, j, releases_rec.po_line_id, releases_rec.po_header_id,
              tax_rec.p_1,
        tax_rec.p_2,
        tax_rec.p_3,
        tax_rec.p_4,
        tax_rec.p_5,
              tax_rec.p_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        tax_rec.p_7,
        tax_rec.p_8,
        tax_rec.p_9,
        tax_rec.p_10,
              tax_rec.tax_id, releases_rec.currency_code, tax_rec.tax_rate, tax_rec.tax_amount, tax_rec.uom_code,
              0, tax_rec.tax_type, v_vendor_id, v_modvat,
              0, releases_rec.line_focus_id, SYSDATE,
              v_created_by, SYSDATE, v_user_id,
              v_login_id, v_dflt_tax_category_id
            );




          END LOOP;

          /* Harshita - Update the tax_amount in the latest records
             to the previous tax amounts for all adhoc tax types.  -- Bug #3765133*/

          UPDATE
            JAI_PO_TAXES a
          SET
            tax_amount = (SELECT tax_amount
              FROM JAI_PO_TAXES
              where tax_id = a.tax_id
              and line_focus_id = -releases_rec.line_focus_id)
          WHERE
            line_focus_id = releases_rec.line_focus_id
            and tax_id in (SELECT tax_id
              FROM JAI_PO_TAXES
              WHERE line_focus_id = -releases_rec.line_focus_id);

          -- ended, Harshita for Bug #3765133

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET new_tax_category_id = v_dflt_tax_category_id
          WHERE batch_id = v_batch_id AND detail_id = releases_rec.line_focus_id;

          IF p_override_manual_taxes <> 'Y' THEN
            -- modifying the tax line number of the manual taxes starting from 1..n manual taxes *
            FOR tax_rec IN c_manual_taxes_up(releases_rec.line_location_id, releases_rec.line_focus_id) LOOP
              j := j + 1;
              UPDATE JAI_PO_TAXES SET tax_line_no = j
              WHERE rowid = tax_rec.rowid;
            END LOOP;
          END IF;

          -- if the shipment line is not a PRICE BREAK line do the following
          IF releases_rec.line_location_id IS NOT NULL AND releases_rec.line_location_id <> 0 THEN

            /* Bug 5243532. Added by Lakshmi Gopalsami
       * Removed the reference to c_func_curr as the functional
       * currency is already derived via caching logic.
       */

            IF v_func_curr <> releases_rec.currency_code THEN
              v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion(v_sob_id, releases_rec.currency_code, releases_rec.rate_date, releases_rec.rate_type, 1);
            ELSE
              v_curr_conv_rate := 1;
            END IF;

            --*XYZ get the assessable value as of the date for the tax calculation
            -- Following parameters should be set before calling JA_IN_PO_ASSESSABLE_VALUE function
            v_vendor_id := releases_rec.vendor_id;
            v_vendor_site_id := releases_rec.vendor_site_id;
            v_inventory_item_id := releases_rec.item_id;

            v_line_uom := nvl(releases_rec.unit_meas_lookup_code, releases_rec.line_uom);
            OPEN c_uom_code(v_line_uom);
            FETCH c_uom_code INTO v_uom_code;
            CLOSE c_uom_code;

            v_assessable_value := ja_in_po_assessable_value;  -- internal function call.

            IF NVL( v_assessable_value, 0 ) <= 0 THEN
              v_assessable_value := releases_rec.price_override * releases_rec.shipment_qty;
            ELSE
              v_assessable_value := v_assessable_value * releases_rec.shipment_qty;
            END IF;

            -- added, Harshita for bug #4245062
            ln_vat_assess_value :=
              jai_general_pkg.ja_in_vat_assessable_value
              ( p_party_id => v_vendor_id,
                p_party_site_id => v_vendor_site_id,
                p_inventory_item_id => v_inventory_item_id,
                p_uom_code => v_uom_code,
                p_default_price => releases_rec.price_override,
                p_ass_value_date => trunc(SYSDATE),
                p_party_type => 'V'
              ) ;


            ln_vat_assess_value :=  ln_vat_assess_value * releases_rec.shipment_qty;

            --ended, Harshita for bug #4245062

            --recalculate the taxes based on the tax lines that are replaced along with the assessable value of the item
            jai_po_tax_pkg.calc_tax(
              p_type => 'RELEASE',
              p_header_id => releases_rec.po_header_id,
              P_line_id => releases_rec.po_line_id,
              p_line_location_id => releases_rec.line_location_id,
              p_line_focus_id => releases_rec.line_focus_id,
              p_line_quantity => releases_rec.shipment_qty,
              p_base_value => releases_rec.price_override * releases_rec.shipment_qty,
              p_line_uom_code => v_uom_code,
              p_tax_amount => v_tax_amount,
              p_assessable_value => v_assessable_value,
              p_vat_assess_value => ln_vat_assess_value,    -- added, Harshita for bug #4245062
              p_item_id => releases_rec.item_id,
              p_conv_rate => v_curr_conv_rate,
              p_po_curr => releases_rec.currency_code,
              p_func_curr => v_func_curr
            );

          END IF;

          UPDATE JAI_PO_LINE_LOCATIONS
          SET tax_category_id = v_dflt_tax_category_id
          WHERE rowid = releases_rec.rowid;

        ELSE  -- Failed to remove old taxes and insert new taxes because of some reason(will be shown in the LOG)
            -- v_message := v_message_01;
          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = releases_rec.line_focus_id;

          -- Write the details of the Shipment Details to the log file why the taxes were not recalculated
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, 'No Tax Changes for Order No. '||releases_rec.document_no||', -> '|| releases_rec.po_line_id||
              ', PO hdr_id -> '||releases_rec.po_header_id||
              ', line_id -> '|| releases_rec.po_line_id||', shipment_id -> '|| releases_rec.line_location_id ||
              ', vendor_id -> '||releases_rec.vendor_id||
              ', vendor_site_id -> '||releases_rec.vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;
          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, 'No Tax Changes for Order No. '||releases_rec.document_no||', -> '|| releases_rec.po_line_id||
              ', PO hdr_id -> '||releases_rec.po_header_id||
              ', line_id -> '|| releases_rec.po_line_id||', shipment_id -> '|| releases_rec.line_location_id ||
              ', vendor_id -> '||releases_rec.vendor_id||
              ', vendor_site_id -> '||releases_rec.vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;

        END IF;

        -- added, Harshita for Bug #3765133
        /* Temporary data stored previously will be flushed using following DELETE */
          DELETE FROM JAI_PO_TAXES
          WHERE line_focus_id = -releases_rec.line_focus_id;
        -- ended, Harshita for Bug #3765133

      ELSE  -- IF v_dflt_tax_category_id IS NOT NULL
        v_message := v_message_01;
        UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
        WHERE batch_id = v_batch_id AND detail_id = releases_rec.line_focus_id;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'Default tax_category_id IS Null - Order No. '||releases_rec.document_no||', -> '|| releases_rec.po_line_id||
            ', PO hdr_id -> '||releases_rec.po_header_id||
            ', line_id -> '|| releases_rec.po_line_id||', shipment_id -> '|| releases_rec.line_location_id ||
            ', vendor_id -> '||releases_rec.vendor_id||
            ', vendor_site_id -> '||releases_rec.vendor_site_id
           );
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log, 'Default tax_category_id IS Null - Order No. '||releases_rec.document_no||', -> '|| releases_rec.po_line_id||
            ', PO hdr_id -> '||releases_rec.po_header_id||
            ', line_id -> '|| releases_rec.po_line_id||', shipment_id -> '|| releases_rec.line_location_id ||
            ', vendor_id -> '||releases_rec.vendor_id||
            ', vendor_site_id -> '||releases_rec.vendor_site_id
           );
        END IF;

      END IF;

      IF v_commit_interval < p_commit_interval THEN
        v_commit_interval := v_commit_interval + 1;
      ELSE
        COMMIT;
        v_commit_interval := 0;
      END IF;

      <<skip_record>>
      null;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO point2;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log,'Rollback to point2, error -> '||SQLERRM);
          END IF;

          IF v_message IS NULL THEN
            v_message := 'Dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          ELSE
            v_message := v_message||', dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          END IF;

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = releases_rec.line_focus_id;

          -- as advised by APARAJITA
          IF sql%notfound THEN
            INSERT INTO JAI_CMN_MTAX_UPD_DTLS
                                       (
                                          mtax_dtl_id,
                                          batch_id,
                                          detail_id,
                                          document_type,
                                          document_no,
                                          release_no,
                                          document_line_no,
                                          shipment_no,
                                          old_tax_category_id,
                                          new_tax_category_id,
                                          error_reason,
                                          program_application_id,
                                          program_id,
                                          program_login_id,
                                          request_id,
                                          created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                          creation_date   ,
                                          last_updated_by  ,
                                          last_update_date
                                        )
                               VALUES  (  JAI_CMN_MTAX_UPD_DTLS_S.nextval,
                                          v_batch_id,
                                          releases_rec.line_focus_id,
                                          releases_rec.shipment_type,
                                          releases_rec.document_no,
                                          releases_rec.release_num,
                                          releases_rec.line_num,
                                          releases_rec.shipment_num,
                                          releases_rec.tax_category_id,
                                          v_dflt_tax_category_id,
                                          v_message,
                                          FND_GLOBAL.PROG_APPL_ID,
                                          FND_GLOBAL.CONC_PROGRAM_ID,
                                          FND_GLOBAL.CONC_LOGIN_ID,
                                          FND_GLOBAL.CONC_REQUEST_ID,
                                         /*fnd_profile.value('PROG_APPL_ID'),
                                           fnd_profile.value('CONC_PROGRAM_ID'),
                                           fnd_profile.value('CONC_LOGIN_ID'),
                                           fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                          v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                          sysdate,
                                          v_created_by,
                                          sysdate
                                       );

          END IF;

      END;

      v_dflt_tax_category_id := null;
      v_vendor_id := null;
      v_vendor_site_id := null;
      v_inventory_item_id := null;
      v_line_uom := null;
      v_uom_code := null;
      v_assessable_value := null;
      ln_vat_assess_value := null; -- added, Harshita for bug #4245062
      v_modvat := 'N';
      v_tax_amount := null;
      v_sob_id := null;
      v_organization_id := null;
      v_func_curr := null;
      v_curr_conv_rate := null;
      v_ship_to_organization_id := null;
      v_ship_to_location_id := null;
      j := null;

      v_success := null;
      v_message := null;

    END LOOP;

  -- REQUISITIONS BLOCK
  /***** REQUISITIONS, there wont be anything like PARTIAL in this case *****/
    ELSIF v_shipment_type IN ( 'INTERNAL', 'PURCHASE' ) THEN  -- this is for REQUISITIONS

    IF p_supplier_id IS NOT NULL THEN
      OPEN c_vendor_name( p_supplier_id );
      FETCH c_vendor_name INTO v_supplier_name;
      CLOSE c_vendor_name;
    END IF;

    IF p_supplier_site_id IS NOT NULL THEN
      OPEN c_vendor_site_code( p_supplier_site_id );
      FETCH c_vendor_site_code INTO v_supplier_location;
      CLOSE c_vendor_site_code;
    END IF;

    FOR reqn_rec IN c_main_reqn( v_org_id, v_document_type,
        trunc(p_from_date), trunc(p_to_date),
        v_supplier_name, v_supplier_location, p_old_tax_category,
        p_document_no, p_document_line_no )
    LOOP
      BEGIN

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Forloop 4');
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log, 'For loop 4' );
      END IF;

      -- There wont be any partial receipts in this case, so No partial Case

      -- ENTRY INTO Request Details table that contains the shipment records processed during Mass Tax Changes
      INSERT INTO JAI_CMN_MTAX_UPD_DTLS (
                                          mtax_dtl_id,
                                          batch_id,
                                          detail_id,
                                          document_type,
                                          document_no,
                                          document_line_no,
                                          old_tax_category_id,
                                          program_application_id,
                                          program_id,
                                          program_login_id,
                                          request_id,
                                          created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                          creation_date   ,
                                          last_updated_by  ,
                                          last_update_date
                                        )
                                VALUES  (
                                          jai_cmn_mtax_upd_dtls_s.nextval,
                                          v_batch_id,
                                          reqn_rec.requisition_line_id,
                                          reqn_rec.type_lookup_code,
                                          reqn_rec.document_no,
                                          reqn_rec.line_num,
                                          reqn_rec.tax_category_id,
                                          FND_GLOBAL.PROG_APPL_ID,
                                          FND_GLOBAL.CONC_PROGRAM_ID,
                                          FND_GLOBAL.CONC_LOGIN_ID,
                                          FND_GLOBAL.CONC_REQUEST_ID,
                                         /*fnd_profile.value('PROG_APPL_ID'),
                                           fnd_profile.value('CONC_PROGRAM_ID'),
                                           fnd_profile.value('CONC_LOGIN_ID'),
                                           fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                          v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                          sysdate,
                                          v_created_by,
                                          sysdate
                                        );

      --************************** SAVEPOINT  **************************
      SAVEPOINT point3;
      --****************************************************************

      IF p_supplier_id IS NOT NULL THEN
        v_vendor_id := p_supplier_id;

        IF p_supplier_site_id IS NOT NULL THEN
          v_vendor_site_id := p_supplier_site_id;
        ELSE
          OPEN c_vendor_site_id( reqn_rec.suggested_vendor_location, v_vendor_id, v_org_id );
          FETCH c_vendor_site_id INTO v_vendor_site_id;
          CLOSE c_vendor_site_id;
        END IF;

      ELSIF reqn_rec.suggested_vendor_name IS NOT NULL THEN
        OPEN c_vendor_id( reqn_rec.suggested_vendor_name );
        FETCH c_vendor_id INTO v_vendor_id;
        CLOSE c_vendor_id;

        OPEN c_vendor_site_id( reqn_rec.suggested_vendor_location, v_vendor_id, v_org_id );
        FETCH c_vendor_site_id INTO v_vendor_site_id;
        CLOSE c_vendor_site_id;
      ELSE
        v_vendor_id := null;
        v_vendor_site_id := null;
      END IF;

      --* Code to get the GL_Set_of_Books_id *

      /* Bug 5243532. Added by Lakshmi Gopalsami
        Removed the reference to cursor c_inv_set_of_books_id
  and implemented using caching logic.
      */

      IF reqn_rec.destination_organization_id IS NOT NULL THEN
        v_organization_id := reqn_rec.destination_organization_id;

      ELSIF reqn_rec.deliver_to_location_id IS NOT NULL THEN
        OPEN c_inv_organization( reqn_rec.deliver_to_location_id );
        FETCH c_inv_organization INTO v_organization_id;
        CLOSE c_inv_organization;

      END IF;

      /* Bug 5243532. Added by Lakshmi Gopalsami
         Implemented caching logic.
       */

      l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_organization_id );
      v_sob_id := l_func_curr_det.ledger_id;
      v_func_curr := l_func_curr_det.currency_code;

      /*  Bug 5243532. Added by Lakshmi Gopalsami
           Removed the reference to cursor c_opr_set_of_books_id
     and implemented using caching logic.

      */
      IF v_sob_id IS NULL THEN
  l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_org_id );
        v_sob_id := l_func_curr_det.ledger_id;
        v_func_curr := l_func_curr_det.currency_code;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||v_organization_id ||', '||v_vendor_id
          ||', '||v_vendor_site_id ||', '|| reqn_rec.item_id ||', '||reqn_rec.requisition_header_id
          ||', '||reqn_rec.requisition_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log,'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes('
          ||v_organization_id ||', '||v_vendor_id
          ||', '||v_vendor_site_id ||', '|| reqn_rec.item_id ||', '||reqn_rec.requisition_header_id
          ||', '||reqn_rec.requisition_line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;

      IF p_old_tax_category IS NULL THEN

        IF v_document_type = 'PURCHASE' THEN
          -- last but 2 and 1 parameter in the following procedure are useless
          jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes( v_organization_id,
            v_vendor_id, v_vendor_site_id, reqn_rec.item_id,
            reqn_rec.requisition_header_id, reqn_rec.requisition_line_id, v_dflt_tax_category_id);

        -- v_document_type = 'INTERNAL' THEN
        ELSE
          jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes( reqn_rec.source_organization_id, reqn_rec.item_id, v_dflt_tax_category_id );
        END IF;

      ELSE
        v_dflt_tax_category_id := p_new_tax_category;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;


      IF v_dflt_tax_category_id IS NOT NULL THEN

        /*XYZ Validation whether the taxes can be modified or not based on Tax Dependencies and if they can,
        then remove the lines that are defaulted during the Requisition Creation and keep the others as it is
        If there is any discrepency, then the function should return corresponding value based on which the
        taxes recalculation or Not will be decided
        */

        -- The adhoc data is preserved to capture the tax_amount later.
        -- added by Harshita for Bug #3765133


         insert into JAI_PO_REQ_LINE_TAXES
            (requisition_line_id,tax_line_no,
            tax_id, tax_amount,
            creation_date,created_by,
            last_update_date, last_updated_by,last_update_login)
         SELECT
            -A.requisition_line_id,A.tax_line_no,
            A.tax_id, A.tax_amount,
            A.creation_date,A.created_by,
            A.last_update_date, A.last_updated_by,A.last_update_login
         FROM
            JAI_PO_REQ_LINE_TAXES A,
            JAI_CMN_TAXES_ALL B
         WHERE
            A.tax_id = B.tax_id AND
            requisition_line_id = reqn_rec.requisition_line_id AND
            NVL(adhoc_flag,'N') = 'Y' ;

        -- end, Harshita for Bug #3765133

        IF p_override_manual_taxes = 'Y' THEN
          DELETE FROM JAI_PO_REQ_LINE_TAXES
          WHERE requisition_line_id = reqn_rec.requisition_line_id;

          v_success := 5; -- means the override manual taxes is selected by user and all the attached taxes with the shipment are removed to default the new taxes
        ELSE
          jai_cmn_mtax_pkg.del_taxes_after_validate( 'REQUISITION', null, null, reqn_rec.requisition_line_id,
            v_success, v_message );
        END IF;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,  'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;


        IF v_success IN (1, 3, 5) THEN

          v_currency_code :=  reqn_rec.currency_code; -- ABC
          v_unit_price := nvl(reqn_rec.currency_unit_price, reqn_rec.unit_price);

          -- Now go to the line location and add the taxes as per the new tax category
          j := 0;
          FOR tax_rec IN c_tax_category_taxes(v_dflt_tax_category_id) LOOP
            j := j + 1;
            /* Added by LGOPALSa. Bug 4210102.
             * Added CVD and Cusotms education cess */

            IF upper(tax_rec.tax_type) IN (
                                      'CVD',
              jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                    'CUSTOMS',
                                            jai_constants.tax_type_cvd_edu_Cess,
                                            jai_constants.tax_type_customs_edu_cess  ,
                                            jai_constants.tax_type_sh_customs_edu_cess, -- Date 18/06/2007 Bug 6130025 added by SACSETHI
                                jai_constants.tax_type_sh_cvd_edu_cess
                                            )
            THEN
              v_tax_vendor_id := NULL;
            -- ABC
            -- ELSIF UPPER( tax_rec.tax_type ) LIKE UPPER( '%EXCISE%' ) THEN
            --  v_vendor_id := reqn_rec.vendor_id;
            ELSIF tax_rec.tax_type = 'TDS' THEN
              v_tax_vendor_id := tax_rec.vendor_id;
            ELSE
              v_tax_vendor_id := NVL( tax_rec.vendor_id, v_vendor_id );
            END IF;

            IF tax_rec.mod_cr_percentage IS NOT NULL AND tax_rec.mod_cr_percentage > 0 THEN
              v_modvat := 'Y';
            ELSE
              v_modvat := 'N';
            END IF;

            IF v_debug THEN
              -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        fnd_file.put_line(fnd_file.log,'tax_id -> '||tax_rec.tax_id||', tax_rec.p_1 -> '||tax_rec.p_1
                ||', tax_rec.p_2 -> '||tax_rec.p_2||', tax_rec.p_3 -> '||tax_rec.p_3
                ||', tax_rec.p_4 -> '||tax_rec.p_4||', tax_rec.p_5 -> '||tax_rec.p_5
                ||', tax_rec.p_6 -> '||tax_rec.p_6||', tax_rec.p_7 -> '||tax_rec.p_7
    ||', tax_rec.p_8 -> '||tax_rec.p_8||', tax_rec.p_9 -> '||tax_rec.p_9
                ||', tax_rec.p_10 -> '||tax_rec.p_10   );
            END IF;

            INSERT INTO JAI_PO_REQ_LINE_TAXES(
              requisition_line_id, requisition_header_id, tax_line_no,
              precedence_1,
        precedence_2,
        precedence_3,
        precedence_4,
        precedence_5,
              precedence_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        precedence_7,
        precedence_8,
        precedence_9,
        precedence_10,
              tax_id, tax_rate, qty_rate, uom,
              tax_amount, tax_target_amount, tax_type, modvat_flag, vendor_id, currency,
              creation_date, created_by, last_update_date,
              last_updated_by, last_update_login, tax_category_id
            ) VALUES (
              reqn_rec.requisition_line_id, reqn_rec.requisition_header_id, j,
              tax_rec.p_1, tax_rec.p_2, tax_rec.p_3, tax_rec.p_4, tax_rec.p_5,
              tax_rec.p_6, tax_rec.p_7, tax_rec.p_8, tax_rec.p_9, tax_rec.p_10,
              tax_rec.tax_id, tax_rec.tax_rate, tax_rec.tax_amount, tax_rec.uom_code,
              0, 0, tax_rec.tax_type, v_modvat, v_tax_vendor_id, v_currency_code,
              SYSDATE, v_created_by, SYSDATE,
              v_created_by, v_login_id, v_dflt_tax_category_id
            );



          END LOOP;

          /* Harshita - Update the tax_amount in the latest records
          to the previous tax amounts for all adhoc tax types.  -- Bug #3765133*/

          UPDATE
            JAI_PO_REQ_LINE_TAXES a
          SET
            tax_amount = (SELECT tax_amount
              FROM JAI_PO_REQ_LINE_TAXES
              where tax_id = a.tax_id
              and requisition_line_id = -reqn_rec.requisition_line_id)
          WHERE
            requisition_line_id = reqn_rec.requisition_line_id
            and tax_id in (SELECT tax_id
              FROM JAI_PO_REQ_LINE_TAXES
          WHERE requisition_line_id = -reqn_rec.requisition_line_id);

          -- ended, Harshita for Bug #3765133

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET new_tax_category_id = v_dflt_tax_category_id
          WHERE batch_id = v_batch_id AND detail_id = reqn_rec.requisition_line_id;

          IF p_override_manual_taxes <> 'Y' THEN
            --* modifying the tax line number of the manual taxes starting from 1..n manual taxes *
            FOR tax_rec IN c_manual_reqn_taxes_up(reqn_rec.requisition_line_id) LOOP
              j := j + 1;
              UPDATE JAI_PO_REQ_LINE_TAXES SET tax_line_no = j
              WHERE rowid = tax_rec.rowid;
            END LOOP;
          END IF;

          /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the reference to c_func_curr as the functional
     * currency is already derived via caching logic.
     */

          IF v_func_curr <> v_currency_code THEN
            v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion(v_sob_id, v_currency_code, reqn_rec.rate_date, reqn_rec.rate_type, 1);
          ELSE
            v_curr_conv_rate := 1;
          END IF;

          --*XYZ get the assessable value as of the date for the tax calculation *
          -- Following parameters should be set before calling JA_IN_PO_ASSESSABLE_VALUE function
          -- v_vendor_id := reqn_rec.vendor_id; v_vendor_site_id := reqn_rec.vendor_site_id;
          v_inventory_item_id := reqn_rec.item_id;

          -- v_line_uom := nvl(reqn_rec.unit_meas_lookup_code, reqn_rec.line_uom);
          v_line_uom := reqn_rec.line_uom;
          OPEN c_uom_code(v_line_uom);
          FETCH c_uom_code INTO v_uom_code;
          CLOSE c_uom_code;

          v_assessable_value := ja_in_po_assessable_value;  -- internal function call.

          IF NVL( v_assessable_value, 0 ) <= 0 THEN
            v_assessable_value := v_unit_price * reqn_rec.quantity;
          ELSE
            v_assessable_value := v_assessable_value * reqn_rec.quantity;
          END IF;

          -- added, Harshita for bug #4245062
          ln_vat_assess_value :=
            jai_general_pkg.ja_in_vat_assessable_value
            ( p_party_id => v_vendor_id,
              p_party_site_id => v_vendor_site_id,
              p_inventory_item_id => v_inventory_item_id,
              p_uom_code => v_uom_code,
              p_default_price => v_unit_price,
              p_ass_value_date => trunc(SYSDATE),
              p_party_type => 'V'
            ) ;

          ln_vat_assess_value := ln_vat_assess_value * reqn_rec.quantity;

          --ended, Harshita for bug #4245062



          --recalculate the taxes based on the tax lines that are replaced along with the assessable value of the item
          jai_po_tax_pkg.calc_tax(
            p_type => 'REQUISITION',
            p_header_id => reqn_rec.requisition_header_id,
            P_line_id => reqn_rec.requisition_line_id,
            p_line_location_id => null,
            p_line_focus_id => null,
            p_line_quantity => reqn_rec.quantity,
            p_base_value => v_unit_price * reqn_rec.quantity,
            p_line_uom_code => v_uom_code,
            p_tax_amount => v_tax_amount,
            p_assessable_value => v_assessable_value,
            p_vat_assess_value => ln_vat_assess_value,    -- added, Harshita for bug #4245062
            p_item_id => reqn_rec.item_id,
            p_conv_rate => v_curr_conv_rate,
            p_po_curr => reqn_rec.currency_code,
            p_func_curr => v_func_curr
          );

          UPDATE JAI_PO_REQ_LINES
          SET tax_category_id = v_dflt_tax_category_id
          WHERE rowid = reqn_rec.rowid;
          -- WHERE requisition_line_id = reqn_rec.requisition_line_id;

        ELSE  -- Failed to remove old taxes and insert new taxes because of some reason(will be shown in the LOG)
          -- v_message := v_message_01;
          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = reqn_rec.requisition_line_id;

          --*XYZ Write the details of the Requisition Details to the log file why the taxes were not recalculated *
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, 'No Tax Changes for Requisition No. '||reqn_rec.document_no||
              ', PO hdr_id -> '||reqn_rec.requisition_header_id||
              ', line_id -> '|| reqn_rec.requisition_line_id||
              ', vendor_id -> '||v_vendor_id||
              ', vendor_site_id -> '||v_vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;
          IF v_debug THEN
            fnd_file.put_line(fnd_file.log,'No Tax Changes for Requisition No. '||reqn_rec.document_no||
              ', PO hdr_id -> '||reqn_rec.requisition_header_id||
              ', line_id -> '|| reqn_rec.requisition_line_id||
              ', vendor_id -> '||v_vendor_id||
              ', vendor_site_id -> '||v_vendor_site_id ||
              ', Message -> '||v_message
             );
          END IF;

        END IF;

        -- added, Harshita for Bug #3765133
        /* Temporary data stored previously will be flushed using following DELETE */
          DELETE FROM JAI_PO_REQ_LINE_TAXES
          WHERE requisition_line_id = -reqn_rec.requisition_line_id;
        -- ended, Harshita for Bug #3765133

      ELSE
        v_message := v_message_01;
        UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
        WHERE batch_id = v_batch_id AND detail_id = reqn_rec.requisition_line_id;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'Default tax_category_id IS Null - Requisition No. '||reqn_rec.document_no||
            ', PO hdr_id -> '||reqn_rec.requisition_header_id||
            ', line_id -> '|| reqn_rec.requisition_line_id||
            ', vendor_id -> '||v_vendor_id||
            ', vendor_site_id -> '||v_vendor_site_id
           );
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'Default tax_category_id IS Null - Requisition No. '||reqn_rec.document_no||
            ', PO hdr_id -> '||reqn_rec.requisition_header_id||
            ', line_id -> '|| reqn_rec.requisition_line_id||
            ', vendor_id -> '||v_vendor_id||
            ', vendor_site_id -> '||v_vendor_site_id
           );
        END IF;

      END IF;

      IF v_commit_interval < p_commit_interval THEN
        v_commit_interval := v_commit_interval + 1;
      ELSE
        COMMIT;
        v_commit_interval := 0;
      END IF;

      <<skip_record>>
      null;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO point3;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log,'Rollback to POINT3, error -> '|| SQLERRM);
          END IF;

          IF v_message IS NULL THEN
            v_message := 'Dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          ELSE
            v_message := v_message||', dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          END IF;

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = reqn_rec.requisition_line_id;

          -- as advised by APARAJITA
          IF SQL%NOTFOUND THEN
            IF v_debug THEN
              fnd_file.put_line(fnd_file.log,'Ex. Record Not found so inserting record');
            END IF;

            INSERT INTO JAI_CMN_MTAX_UPD_DTLS (
                                                mtax_dtl_id,
                                                batch_id,
                                                detail_id,
                                                document_type,
                                                document_no,
                                                document_line_no,
                                                old_tax_category_id,
                                                new_tax_category_id,
                                                error_reason,
                                                program_application_id,
                                                program_id,
                                                program_login_id,
                                                request_id,
                                                created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                                creation_date   ,
                                                last_updated_by  ,
                                                last_update_date
                                              )
                                     VALUES  (
                                                jai_cmn_mtax_upd_dtls_s.nextval,
                                                v_batch_id,
                                                reqn_rec.requisition_line_id,
                                                reqn_rec.type_lookup_code,
                                                reqn_rec.document_no,
                                                reqn_rec.line_num,
                                                reqn_rec.tax_category_id,
                                                v_dflt_tax_category_id,
                                                v_message,
                                                FND_GLOBAL.PROG_APPL_ID,
                                                FND_GLOBAL.CONC_PROGRAM_ID,
                                                FND_GLOBAL.CONC_LOGIN_ID,
                                                FND_GLOBAL.CONC_REQUEST_ID,
                                               /*fnd_profile.value('PROG_APPL_ID'),
                                                 fnd_profile.value('CONC_PROGRAM_ID'),
                                                 fnd_profile.value('CONC_LOGIN_ID'),
                                                 fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                                v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                                sysdate,
                                                v_created_by,
                                                sysdate
                                            );

          END IF;

      END;

      v_dflt_tax_category_id := null;
      v_vendor_id := null;
      v_tax_vendor_id := null;
      v_vendor_site_id := null;
      v_inventory_item_id := null;
      v_line_uom := null;
      v_uom_code := null;
      v_assessable_value := null;
      ln_vat_assess_value := null; -- added, Harshita for bug #4245062
      v_modvat := 'N';
      v_tax_amount := null;
      v_sob_id := null;
      v_organization_id := null;
      v_func_curr := null;
      v_curr_conv_rate := null;
      v_ship_to_organization_id := null;
      v_ship_to_location_id := null;
      v_currency_code := null;
      v_supplier_location := null;
      v_supplier_name := null;
      v_unit_price := null;
      j := null;

      v_success := null;
      v_message := null;

    END LOOP;

  -- SALES ORDERS BLOCK
  /***** SALES ORDERS *****/
    ELSIF v_shipment_type IN ( 'SALES_ORDERS' ) THEN
    FOR so_rec IN c_main_so( v_org_id, trunc(p_from_date), trunc(p_to_date),
        p_customer_id, p_customer_site_id, p_old_tax_category,
        to_number(p_document_no), p_document_line_no)
    LOOP
      BEGIN

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Forloop 3');
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log,'For loop3' );
      END IF;

      -- v_qty_remaining := so_rec.ordered_quantity - so_rec.shipped_quantity ;
      -- check for Partially shipped or not. if partial then skip SO line processing
      IF so_rec.shipped_quantity > 0 AND
        so_rec.ordered_quantity <> so_rec.shipped_quantity AND p_process_partial = 'N'
      THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Partilly shipped Order cannot be processed. Order No. '||so_rec.order_number||
          ', SO hdr_id -> '||so_rec.header_id||
          ', line_id -> '|| so_rec.line_id||
          ', ordered_quantity -> '||so_rec.ordered_quantity||
          ', shipped_quantity -> '||so_rec.shipped_quantity
        );
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'Partilly shipped Order cannot be processed. Order No. '||so_rec.order_number||
            ', SO hdr_id -> '||so_rec.header_id||
            ', line_id -> '|| so_rec.line_id||
            ', ordered_quantity -> '||so_rec.ordered_quantity||
            ', shipped_quantity -> '||so_rec.shipped_quantity
          );
        END IF;

        GOTO skip_record;
      END IF;

      -- ENTRY INTO Request Details table that contains the shipment records processed during Mass Tax Changes
      -- If any error occurs while processing the record, the error_reason column is updated with corresponding error message
      -- later in the code
      INSERT INTO JAI_CMN_MTAX_UPD_DTLS (
                                          mtax_dtl_id,
                                          batch_id,
                                          detail_id,
                                          document_type,
                                          document_no,
                                          document_line_no,
                                          old_tax_category_id,
                                          program_application_id,
                                          program_id,
                                          program_login_id,
                                          request_id,
                                          created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                          creation_date   ,
                                          last_updated_by  ,
                                          last_update_date
                                         )
                                 VALUES  (
                                          jai_cmn_mtax_upd_dtls_s.nextval,
                                          v_batch_id,
                                          so_rec.line_id,
                                          'SO',
                                          so_rec.document_no,
                                          so_rec.line_number,
                                          so_rec.tax_category_id,
                                          FND_GLOBAL.PROG_APPL_ID,
                                          FND_GLOBAL.CONC_PROGRAM_ID,
                                          FND_GLOBAL.CONC_LOGIN_ID,
                                          FND_GLOBAL.CONC_REQUEST_ID,
                                         /*fnd_profile.value('PROG_APPL_ID'),
                                           fnd_profile.value('CONC_PROGRAM_ID'),
                                           fnd_profile.value('CONC_LOGIN_ID'),
                                           fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                          v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                          sysdate,
                                          v_created_by,
                                          sysdate
                                         );

      --************************** SAVEPOINT  **************************
      SAVEPOINT point4;
      --****************************************************************

      v_organization_id := so_rec.warehouse_id;
      v_line_amount := so_rec.ordered_quantity * so_rec.selling_price;

      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Removed the cursors c_inv_set_of_books_id and c_opr_set_of_books_id
       * and implemented caching logic.
       */

      IF v_organization_id IS NOT NULL THEN
         l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_organization_id );
      ELSE
        l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr(p_org_id  => v_org_id );
      END IF;

      v_sob_id := l_func_curr_det.ledger_id;
      v_func_curr := l_func_curr_det.currency_code;
      -- End for bug 5243532

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes('
          ||v_organization_id ||', '||so_rec.customer_id
          ||', '||so_rec.ship_to_org_id ||', '||so_rec.inventory_item_id ||', '||so_rec.header_id
          ||', '||so_rec.line_id ||', '||v_dflt_tax_category_id||' );'
        );

      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log,'jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes('
          ||v_organization_id ||', '||so_rec.customer_id
          ||', '||so_rec.ship_to_org_id ||', '||so_rec.inventory_item_id ||', '||so_rec.header_id
          ||', '||so_rec.line_id ||', '||v_dflt_tax_category_id||' );'
        );
      END IF;

      IF p_old_tax_category IS NULL THEN
        jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes( v_organization_id, so_rec.customer_id, so_rec.ship_to_org_id,
            so_rec.inventory_item_id, so_rec.header_id, so_rec.line_id, v_dflt_tax_category_id);
      ELSE
        v_dflt_tax_category_id := p_new_tax_category;
      END IF;

      IF v_debug THEN
        UTL_FILE.PUT_LINE(v_myfilehandle, 'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;
      IF v_debug THEN
        fnd_file.put_line(fnd_file.log,'v_dflt_tax_category_id -> ' ||v_dflt_tax_category_id);
      END IF;

      IF v_dflt_tax_category_id IS NOT NULL THEN

        /*XYZ Validation whether the taxes can be modified or not based on Tax Dependencies and if they can,
        then remove the lines that are defaulted during the Shipment Creation and keep the others as it is
        If there is any discrepency, then the function should return corresponding value based on which the
        taxes recalculation or Not will be decided
        */

        -- The adhoc data is preserved to capture the tax_amount later.
        -- added by Harshita for Bug #3765133
         insert into JAI_OM_OE_SO_TAXES
            (line_id,tax_line_no,header_id,
            tax_id, tax_amount,
            creation_date,created_by,
            last_update_date, last_updated_by,last_update_login)
         SELECT
            -A.line_id,A.tax_line_no,A.header_id,
            A.tax_id, A.tax_amount,
            A.creation_date,A.created_by,
            A.last_update_date, A.last_updated_by,A.last_update_login
         FROM
            JAI_OM_OE_SO_TAXES A,
            JAI_CMN_TAXES_ALL B
         WHERE
            A.tax_id = B.tax_id AND
            line_id = so_rec.line_id AND
            NVL(adhoc_flag,'N') = 'Y';
        -- end, Harshita for Bug #3765133

        IF p_override_manual_taxes = 'Y' THEN
          DELETE FROM JAI_OM_OE_SO_TAXES
          WHERE line_id = so_rec.line_id;

          v_success := 5; -- means the override manual taxes is selected by user and all the attached taxes with the shipment are removed to default the new taxes
        ELSE
          jai_cmn_mtax_pkg.del_taxes_after_validate( 'SO', null, null, so_rec.line_id, v_success, v_message );
        END IF;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,  'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log, 'v_success -> '||v_success||', v_message -> '||v_message);
        END IF;


        IF v_success IN (1, 3, 5) THEN

          -- *XYZ Now go to the line location and add the taxes as per the new tax category them as per the blackbox *
          j := 0;
          FOR tax_rec IN c_tax_category_taxes(v_dflt_tax_category_id) LOOP
            j := j + 1;

            IF v_debug THEN
    -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        fnd_file.put_line(fnd_file.log,'tax_id -> '||tax_rec.tax_id||', tax_rec.p_1 -> '||tax_rec.p_1
                ||', tax_rec.p_2 -> '||tax_rec.p_2||', tax_rec.p_3 -> '||tax_rec.p_3
                ||', tax_rec.p_4 -> '||tax_rec.p_4||', tax_rec.p_5 -> '||tax_rec.p_5
                ||', tax_rec.p_6 -> '||tax_rec.p_6||', tax_rec.p_7 -> '||tax_rec.p_7
                ||', tax_rec.p_8 -> '||tax_rec.p_8||', tax_rec.p_9 -> '||tax_rec.p_9
                ||', tax_rec.p_10 -> '||tax_rec.p_10
              );
            END IF;

            INSERT INTO JAI_OM_OE_SO_TAXES(
              tax_line_no, line_id, header_id,
              precedence_1,
        precedence_2,
        precedence_3,
        precedence_4,
        precedence_5,
              precedence_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        precedence_7,
        precedence_8,
        precedence_9,
        precedence_10,
        tax_id, tax_rate, qty_rate, uom,
              tax_amount, base_tax_amount, func_tax_amount,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login, tax_category_id
            ) VALUES (
              j, so_rec.line_id, so_rec.header_id,
              tax_rec.p_1, tax_rec.p_2, tax_rec.p_3, tax_rec.p_4, tax_rec.p_5,
              tax_rec.p_6, tax_rec.p_7, tax_rec.p_8, tax_rec.p_9, tax_rec.p_10,
              tax_rec.tax_id, tax_rec.tax_rate, tax_rec.tax_amount, tax_rec.uom_code,
              0, null, null,
              SYSDATE, v_created_by, SYSDATE, v_user_id,
              v_login_id, v_dflt_tax_category_id
            );

          END LOOP;

          /* Harshita - Update the tax_amount in the latest records
          to the previous tax amounts for all adhoc tax types.  -- Bug #3765133*/

          UPDATE
            JAI_OM_OE_SO_TAXES a
          SET
            tax_amount = (SELECT tax_amount
              FROM JAI_OM_OE_SO_TAXES
              where tax_id = a.tax_id
              and line_id = -so_rec.line_id)
          WHERE
            line_id = so_rec.line_id
            and tax_id in (SELECT tax_id
              FROM JAI_PO_REQ_LINE_TAXES
              WHERE line_id = -so_rec.line_id);


          -- ended, Harshita for Bug #3765133


          UPDATE JAI_CMN_MTAX_UPD_DTLS SET new_tax_category_id = v_dflt_tax_category_id
          WHERE batch_id = v_batch_id AND detail_id = so_rec.line_id;

          IF p_override_manual_taxes <> 'Y' THEN
            --* modifying the tax line number of the manual taxes starting from 1..n manual taxes *
            FOR tax_rec IN c_manual_so_taxes_up(so_rec.line_id) LOOP
              j := j + 1;
              UPDATE JAI_OM_OE_SO_TAXES SET tax_line_no = j
              WHERE rowid = tax_rec.rowid;
            END LOOP;
          END IF;

          -------Assessable Value Calculation and Taxes recalculation---------------------
          v_date_ordered := nvl(so_rec.date_ordered, so_rec.creation_date);

          v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_sob_id , so_rec.currency_code,
              v_date_ordered , so_rec.conversion_type_code, so_rec.conversion_rate);

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' v_converted_rate -> '||v_converted_rate);
          END IF;

          OPEN c_address(so_rec.ship_to_org_id);
          FETCH c_address INTO v_address_id;
          CLOSE c_address;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' v_address_id -> '||v_address_id
              || ', customer_id -> '|| so_rec.customer_id
              || ', inventory_item_id -> '|| so_rec.inventory_item_id
              || ', order_quantity_uom -> '|| so_rec.order_quantity_uom
              || ', v_date_ordered -> '|| v_date_ordered
            );
          END IF;
     -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
     ----------------------------------------------------------------------------------

          -- Get category_set_name
          OPEN category_set_name_cur;
          FETCH category_set_name_cur INTO lv_category_set_name;
          CLOSE category_set_name_cur;

          -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
          -- in the transaction. If yes, give an exception error message to stop transaction.

          -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
          IF lv_release_name NOT LIKE '12.0%' THEN

          Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => so_rec.customer_id
                                                         , pn_party_site_id     => v_address_id
                                                         , pn_inventory_item_id => so_rec.inventory_item_id
                                                         , pd_ordered_date      => trunc(v_date_ordered)
                                                         , pv_party_type        => 'C'
                                                         , pn_pricing_list_id  => NULL
                                                         );
          END IF;

     -----------------------------------------------------------------------------------
     -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

          OPEN c_get_assessable_value(so_rec.customer_id, v_address_id, so_rec.inventory_item_id,
              so_rec.order_quantity_uom, trunc(v_date_ordered) );
          FETCH c_get_assessable_value INTO v_assessable_value;   --, v_price_list_uom_code;
          CLOSE c_get_assessable_value;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' 1 v_assessable_value -> '|| nvl(v_assessable_value,-1) );
          END IF;
      -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
      --------------------------------------------------------------------------
        -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN

          IF v_assessable_value IS NULL
          THEN
            -- Fetch Excise Assessable Value of item category for the given Customer, Site, Inventory Item and UOM Combination
            OPEN cust_ass_value_category_cur( so_rec.customer_id
                                            , v_address_id
                                            , so_rec.inventory_item_id
                                            , so_rec.order_quantity_uom
                                            , TRUNC(v_date_ordered)
                                            );
            FETCH cust_ass_value_category_cur INTO v_assessable_value; --, v_price_list_uom_code;
            CLOSE cust_ass_value_category_cur;
          END IF; -- v_assessable_value is null for given customer/site/inventory_item_id/UOM

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' 1.1 item category v_assessable_value -> '|| nvl(v_assessable_value,-1) );
          END IF;

         END IF;  -- lv_release_name NOT LIKE '12.0%'
      ------------------------------------------------------------------------
      -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

          IF v_assessable_value IS NULL THEN
            OPEN c_get_assessable_value(so_rec.customer_id, 0, so_rec.inventory_item_id,
                so_rec.order_quantity_uom, trunc(v_date_ordered) );
            FETCH c_get_assessable_value INTO v_assessable_value; --, v_price_list_uom_code;
            CLOSE c_get_assessable_value;
          END IF;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' 2 v_assessable_value -> '||v_assessable_value);
          END IF;

      -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
      ----------------------------------------------------------------------------------

        -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN

          IF v_assessable_value IS NULL
          THEN
            -- Fetch Excise Assessable Value of item category for the given Customer, null Site, Inventory Item and UOM Combination
            OPEN cust_ass_value_category_cur( so_rec.customer_id
                                            , 0
                                            , so_rec.inventory_item_id
                                            , so_rec.order_quantity_uom
                                            , TRUNC(v_date_ordered)
                                            );
            FETCH cust_ass_value_category_cur INTO v_assessable_value; --, v_price_list_uom_code;
            CLOSE cust_ass_value_category_cur;
          END IF; -- v_assessable_value is null for given customer/null site/inventory_item_id/UOM

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' 2.1 item category v_assessable_value -> '|| nvl(v_assessable_value,-1) );
          END IF;

        END IF;  -- lv_release_name NOT LIKE '12.0%'
      --------------------------------------------------------------------------------
      -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end
        /*
          IF v_assessable_value IS NULL THEN
            OPEN c_price_list_ass_value(so_rec.price_list_id, so_rec.inventory_item_id, so_rec.unit_code, v_date_ordered);
            FETCH c_price_list_ass_value INTO v_assessable_value, v_price_list_uom_code;
            CLOSE c_price_list_ass_value;
          END IF;
        */

          -- if there is no change in assessable value, then the following if block defaults selling price for assessable value
          IF v_assessable_value IS NULL THEN
            v_assessable_value := so_rec.selling_price;
          END IF;

        /* this is not required because Customer has to define the price for each UOM of the item he is going to use
          -- IF v_price_list_uom_code IS NOT NULL THEN
          IF v_assessable_value IS NOT NULL THEN
            INV_CONVERT.inv_um_conversion(so_rec.order_quantity_uom, v_price_list_uom_code, so_rec.inventory_item_id, v_uom_conversion_rate);
            IF nvl(v_uom_conversion_rate, 0) <= 0 THEN
              INV_CONVERT.inv_um_conversion(so_rec.unit_code, v_price_list_uom_code, 0, v_uom_conversion_rate);
              IF nvl(v_uom_conversion_rate, 0) <= 0  THEN
                v_uom_conversion_rate := 0;
              END IF;
            END IF;
          END IF;
        */

          -- this is redundant as assessable value should not be multiplied with conversion rate
          -- v_assessable_value := NVL(1/v_converted_rate,0) * nvl(v_assessable_value,0); -- * v_uom_conversion_rate;
          v_assessable_amount := v_assessable_value * so_rec.ordered_quantity;

          -- added, Harshita for bug #4245062
          ln_vat_assess_value :=
                      jai_general_pkg.ja_in_vat_assessable_value
                      ( p_party_id => so_rec.customer_id,
                        p_party_site_id => so_rec.ship_to_org_id, --Replaced v_address_id with so_rec.ship_to_org_id by JMEENA for bug#6335001
                        p_inventory_item_id => so_rec.inventory_item_id,
                        p_uom_code => so_rec.order_quantity_uom,
                        p_default_price => so_rec.selling_price,
                        p_ass_value_date => trunc(v_date_ordered),
                        p_party_type => 'C' --Changed from V to C for bug#6335001 by JMEENA
              ) ;


          IF v_debug THEN
              fnd_file.put_line(fnd_file.log, ' ln_vat_assess_value -> '||ln_vat_assess_value);
          END IF;

          ln_vat_assess_amount := ln_vat_assess_value * so_rec.ordered_quantity;
          --ended, Harshita for bug #4245062

          v_line_tax_amount := v_line_amount;
          jai_om_tax_pkg.recalculate_oe_taxes(
            so_rec.header_id, so_rec.line_id, v_assessable_amount,ln_vat_assess_amount, -- added, Harshita for bug #4245062
            v_line_tax_amount, so_rec.inventory_item_id, so_rec.ordered_quantity,
            so_rec.order_quantity_uom, v_converted_rate,
            SYSDATE, v_user_id, v_login_id
          );
          -- Now v_line_tax_amount contains the total tax amount that should be kept at line level

          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle ,' line tax = ' || v_line_tax_amount );
            UTL_FILE.PUT_LINE(v_myfilehandle, '33 assessable_value = '||v_assessable_value||', line tax_amount = '||v_line_tax_amount );
          END IF;
          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, ' line tax = ' || v_line_tax_amount||
              ', 33 assessable_value = '||v_assessable_value||', line tax_amount = '||v_line_tax_amount );
          END IF;


          UPDATE JAI_OM_OE_SO_LINES
          SET assessable_value  = v_assessable_value,
            vat_assessable_value = ln_vat_assess_amount, --Replaced ln_vat_assess_value with ln_vat_assess_amount by JMEENA for bug#6335001
            tax_amount      = nvl(v_line_tax_amount,0),
            line_amount     =   v_line_amount,
            line_tot_amount   =   v_line_amount + nvl(v_line_tax_amount,0),
            last_update_date  = SYSDATE,
            last_updated_by   = v_user_id,
            last_update_login = v_login_id,
            tax_category_id     =   v_dflt_tax_category_id
          WHERE rowid = so_rec.rowid;
          -- WHERE line_id = so_rec.line_id;
          --------------------------------------------------------------------------------------------

        ELSE  -- Failed to remove old taxes and insert new taxes because of some reason(will be shown in the LOG)

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = so_rec.line_id;

          --*XYZ Write the details of the Shipment Details to the log file why the taxes were not recalculated *
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, 'No Tax Changes for Order No. '||so_rec.order_number||
              ', SO hdr_id -> '||so_rec.header_id||
              ', line_id -> '|| so_rec.line_id||
              ', customer_id -> '||so_rec.customer_id||
              ', site_use_id -> '||so_rec.ship_to_org_id ||
              ', Message -> '||v_message
             );
          END IF;
          IF v_debug THEN
            fnd_file.put_line(fnd_file.log, 'No Tax Changes for Order No. '||so_rec.order_number||
              ', SO hdr_id -> '||so_rec.header_id||
              ', line_id -> '|| so_rec.line_id||
              ', customer_id -> '||so_rec.customer_id||
              ', site_use_id -> '||so_rec.ship_to_org_id ||
              ', Message -> '||v_message
             );
          END IF;

        END IF;
        -- added, Harshita for Bug #3765133
        /* Temporary data stored previously will be flushed using following DELETE */
          DELETE FROM JAI_OM_OE_SO_TAXES
          WHERE line_id = -so_rec.line_id;
        -- ended, Harshita for Bug #3765133

      ELSE

        v_message := v_message_01;
        UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
        WHERE batch_id = v_batch_id AND detail_id = so_rec.line_id;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, 'Default tax_category_id IS Null - Sales Order No. '||so_rec.order_number||
            ', SO hdr_id -> '||so_rec.header_id||
            ', line_id -> '|| so_rec.line_id||
            ', customer_id -> '||so_rec.customer_id||
            ', site_use_id -> '||so_rec.ship_to_org_id ||
            ', Message -> '||v_message
           );
        END IF;
        IF v_debug THEN
          fnd_file.put_line(fnd_file.log,'Default tax_category_id IS Null - Sales Order No. '||so_rec.order_number||
            ', SO hdr_id -> '||so_rec.header_id||
            ', line_id -> '|| so_rec.line_id||
            ', customer_id -> '||so_rec.customer_id||
            ', site_use_id -> '||so_rec.ship_to_org_id ||
            ', Message -> '||v_message
           );
        END IF;
      END IF;

      IF v_commit_interval < p_commit_interval THEN
        v_commit_interval := v_commit_interval + 1;
      ELSE
        COMMIT;
        v_commit_interval := 0;
      END IF;

      <<skip_record>>
      null;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO point4;

          IF v_debug THEN
            fnd_file.put_line(fnd_file.log,'ROLLBACK to point4, error -> '|| SQLERRM);
          END IF;

          IF v_message IS NULL THEN
            v_message := 'Dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          ELSE
            v_message := v_message||', dflt_tax_category -> '||v_dflt_tax_category_id||', SQLERRM -> '||SQLERRM;
          END IF;

          UPDATE JAI_CMN_MTAX_UPD_DTLS SET error_reason = v_message
          WHERE batch_id = v_batch_id AND detail_id = so_rec.line_id;

          -- as advised by APARAJITA
          IF sql%notfound THEN
            INSERT INTO JAI_CMN_MTAX_UPD_DTLS (
                                                MTAX_DTL_ID,
                                                batch_id,
                                                detail_id,
                                                document_type,
                                                document_no,
                                                document_line_no,
                                                old_tax_category_id,
                                                new_tax_category_id,
                                                error_reason,
                                                program_application_id,
                                                program_id,
                                                program_login_id,
                                                request_id,
                                                created_by      ,/* Aiyer for the bug 4565665. Added the who columns */
                                                creation_date   ,
                                                last_updated_by  ,
                                                last_update_date
                                              )
                                       VALUES (
                                                jai_cmn_mtax_upd_dtls_s.nextval,
                                                v_batch_id, so_rec.line_id,
                                                'SO',
                                                so_rec.document_no,
                                                so_rec.line_number,
                                                so_rec.tax_category_id,
                                                v_dflt_tax_category_id,
                                                v_message,
                                                FND_GLOBAL.PROG_APPL_ID,
                                                FND_GLOBAL.CONC_PROGRAM_ID,
                                                FND_GLOBAL.CONC_LOGIN_ID,
                                                FND_GLOBAL.CONC_REQUEST_ID,
                                                /*fnd_profile.value('PROG_APPL_ID'),
                                                  fnd_profile.value('CONC_PROGRAM_ID'),
                                                  fnd_profile.value('CONC_LOGIN_ID'),
                                                  fnd_profile.value('CONC_REQUEST_ID') Replaced the call by fnd_global for bug # 9478377 */
                                                v_created_by,/* Aiyer for the bug 4565665. Added the who columns */
                                                sysdate,
                                                v_created_by,
                                                sysdate
                                              );

          END IF;

      END;

      v_dflt_tax_category_id := null;
      v_vendor_id := null;
      v_vendor_site_id := null;
      v_inventory_item_id := null;
      v_line_uom := null;
      v_uom_code := null;
      v_assessable_value := null;
      ln_vat_assess_value := null;  -- added, Harshita for bug #4245062
      v_modvat := 'N';
      v_tax_amount := null;
      v_sob_id := null;
      v_organization_id := null;
      v_func_curr := null;
      v_curr_conv_rate := null;
      v_ship_to_organization_id := null;
      v_ship_to_location_id := null;
      v_address_id := null;
      v_price_list_uom_code := null;
      v_uom_conversion_rate := null;
      v_assessable_amount := null;
      ln_vat_assess_amount := null ; -- added, Harshita for bug #4245062
      v_line_tax_amount := null;
      v_line_amount := null;
      v_date_ordered := null;
      v_converted_rate := null;

      j := null;

      v_success := null;
      v_message := null;

    END LOOP; -- FOR SALES ORDERS

    END IF;

    -- This the final commit
    COMMIT;

    IF v_debug THEN
      UTL_FILE.fclose(v_myfilehandle);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF v_debug THEN
        UTL_FILE.put_line(v_myfilehandle, ' Rollback Performed');
        UTL_FILE.fclose(v_myfilehandle);
        fnd_file.put_line(fnd_file.log, 'Main Rollback Performed, '||SQLERRM);
      END IF;
      v_message := SQLERRM;
      UPDATE JAI_CMN_MTAX_HDRS_ALL SET error_message = v_message WHERE batch_id = v_batch_id;

      p_ret_code := 1;
      p_err_buf := v_message;

      COMMIT;
      RAISE_APPLICATION_ERROR( -20101, 'Mass Changes Caught the exception and propagating the same', TRUE);

  END do_tax_redefaultation;


  PROCEDURE del_taxes_after_validate
  (
    p_document_type IN VARCHAR2,    -- eg. PO, SO, REQUISITION
    p_line_focus_id IN NUMBER,      -- IF 'PO' this should contain JAI_PO_LINE_LOCATIONS.line_focus_id and
    p_line_location_id IN NUMBER,
    p_line_id IN NUMBER,            -- if 'SO' then this should contain JAI_OM_OE_SO_LINES.line_id
    p_success OUT NOCOPY NUMBER,
    p_message OUT NOCOPY VARCHAR2
  ) IS

    TYPE tax_line_nos_small IS VARRAY(10) OF NUMBER(2);
    TYPE tax_line_nos_big IS VARRAY(40) OF NUMBER(2);

    v_manual_tax_line_nos   TAX_LINE_NOS_SMALL := tax_line_nos_small();
    v_dflt_tax_prec         TAX_LINE_NOS_BIG  := tax_line_nos_big();

    CURSOR c_shipment_taxes(p_line_focus_id IN NUMBER) IS
    SELECT tax_line_no,
             nvl(precedence_1, -1) p_1,
       nvl(precedence_2, -1) p_2,
       nvl(precedence_3, -1) p_3,
             nvl(precedence_4, -1) p_4,
       nvl(precedence_5, -1) p_5,
             nvl(precedence_6, -1) p_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       nvl(precedence_7, -1) p_7,
       nvl(precedence_8, -1) p_8,
             nvl(precedence_9, -1) p_9,
       nvl(precedence_10, -1) p_10,
       tax_id,
             tax_category_id
    FROM JAI_PO_TAXES
    WHERE line_focus_id = p_line_focus_id;

    CURSOR c_so_line_taxes(p_line_id NUMBER) IS
      SELECT tax_line_no,
             nvl(precedence_1, -1) p_1,
       nvl(precedence_2, -1) p_2,
       nvl(precedence_3, -1) p_3,
             nvl(precedence_4, -1) p_4,
       nvl(precedence_5, -1) p_5,
             nvl(precedence_6, -1) p_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       nvl(precedence_7, -1) p_7,
       nvl(precedence_8, -1) p_8,
             nvl(precedence_9, -1) p_9,
       nvl(precedence_10, -1) p_10,
       tax_id,
       tax_category_id
      FROM JAI_OM_OE_SO_TAXES
      WHERE line_id = p_line_id;

    CURSOR c_req_line_taxes(p_requisition_line_id NUMBER) IS
      SELECT tax_line_no,
             nvl(precedence_1, -1) p_1,
       nvl(precedence_2, -1) p_2,
       nvl(precedence_3, -1) p_3,
             nvl(precedence_4, -1) p_4,
       nvl(precedence_5, -1) p_5,
             nvl(precedence_6, -1) p_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       nvl(precedence_7, -1) p_7,
       nvl(precedence_8, -1) p_8,
             nvl(precedence_9, -1) p_9,
       nvl(precedence_10, -1) p_10,
       tax_id,   tax_category_id
      FROM JAI_PO_REQ_LINE_TAXES
      WHERE requisition_line_id = p_requisition_line_id;

    j NUMBER(4) := 0;
    v_manual VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35

    v_dflt_temp NUMBER;
    v_debug VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35

    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_mtax_pkg.del_taxes_after_validate'; /* Added by Ramananda for bug#4407165 */

  BEGIN

  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - jai_cmn_mtax_pkg.del_taxes_after_validate_p.sql
  S.No  Date    Author and Details
  -------------------------------------------------
  1.    30/12/2002  cbabu for EnhancementBug# 2427465, FileVersion# 615.1
          Procedure created to check whether the line passed to this procedure has no dependency problems related to
          defaulted and manual taxes. If there is no discrepency then this procedure will not delete any data and
          returns a number which signifies that the procedure failed because of some discrepency.
          If procedure is successful, then this returns a number greater than 0
           and if it returns number less than 0 then this indicates there occured some dependency problem and
           v_message variable will contain the error message.
  --------------------------------------------------------------------------------------------------------------------------*/

    p_success := 1;     -- FLAG that indicates the tax recalculation can be applied by deleting old taxes that are defaulted from tax category
    v_manual := jai_constants.no; --Ramananda for File.Sql.35
    v_debug  := jai_constants.no; --Ramananda for File.Sql.35

    IF p_document_type IN ( 'PO' ) THEN

      FOR processing_rec IN c_shipment_taxes(p_line_focus_id) LOOP
        j := j + 1;

        -- we have to identify the defaulted taxes that are not dependant on any other taxes and any
        -- manually added tax is not dependant on the defaulted taxes and then populate plsql table so that
        -- we can delete those

        IF processing_rec.tax_category_id IS NULL THEN
          -- manual tax
          v_manual_tax_line_nos.EXTEND;
          v_manual_tax_line_nos(v_manual_tax_line_nos.LAST) := processing_rec.tax_line_no;

          IF processing_rec.p_1 > 0 OR
       processing_rec.p_2 > 0 OR
       processing_rec.p_3 > 0 OR
       processing_rec.p_4 > 0 OR
       processing_rec.p_5 > 0 OR
       processing_rec.p_6 > 0 OR -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       processing_rec.p_7 > 0 OR
       processing_rec.p_8 > 0 OR
       processing_rec.p_9 > 0 OR
       processing_rec.p_10 > 0
          THEN
            p_success := -2;
            p_message := 'Lines having Manual taxes and that has precedence on other tax lines are not processed';
            RETURN;
          END IF;

          v_manual := 'Y';
        ELSE

          IF processing_rec.p_1 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_1;
          END IF;
          IF processing_rec.p_2 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_2;
          END IF;
          IF processing_rec.p_3 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_3;
          END IF;
          IF processing_rec.p_4 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_4;
          END IF;
          IF processing_rec.p_5 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_5;
          END IF;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    IF processing_rec.p_6 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_6;
          END IF;
          IF processing_rec.p_7 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_7;
          END IF;
          IF processing_rec.p_8 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_8;
          END IF;
          IF processing_rec.p_9 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_9;
          END IF;
          IF processing_rec.p_10 > 0 THEN
            v_dflt_tax_prec.EXTEND;
            v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_10;
          END IF;
-- END BUG 5228046
        END IF;

      END LOOP;

    ELSIF p_document_type IN ( 'SO' ) THEN
      FOR processing_rec IN c_so_line_taxes(p_line_id) LOOP     -- p_line_focus_id should contain JAI_OM_OE_SO_LINES.line_id
        j := j + 1;

        -- we have to identify the defaulted taxes that are not dependant on any other taxes and any
        -- manually added tax is not dependant on the defaulted taxes and then populate plsql table so that
        -- we can delete those

        IF processing_rec.tax_category_id IS NULL THEN
          v_manual_tax_line_nos.EXTEND;
          v_manual_tax_line_nos(v_manual_tax_line_nos.LAST) := processing_rec.tax_line_no;
          IF
       processing_rec.p_1 > 0 OR processing_rec.p_2 > 0 OR processing_rec.p_3 > 0 OR
       processing_rec.p_4 > 0 OR processing_rec.p_5 > 0 OR processing_rec.p_6 > 0 OR  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       processing_rec.p_7 > 0 OR processing_rec.p_8 > 0 OR processing_rec.p_9 > 0 OR
             processing_rec.p_10 > 0
          THEN
            p_success := -2;
            p_message := 'Lines having Manual taxes and that has precedence on other tax lines are not processed';
            RETURN;
          END IF;

          v_manual := 'Y';
        ELSE

          IF processing_rec.p_1 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_1; END IF;
          IF processing_rec.p_2 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_2; END IF;
          IF processing_rec.p_3 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_3; END IF;
          IF processing_rec.p_4 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_4; END IF;
    IF processing_rec.p_5 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_5; END IF;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    IF processing_rec.p_6 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_6; END IF;
          IF processing_rec.p_7 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_7; END IF;
          IF processing_rec.p_8 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_8; END IF;
          IF processing_rec.p_9 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_9; END IF;
          IF processing_rec.p_10 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_10; END IF;
-- END BUG 5228046
  END IF;

      END LOOP;

    ELSIF p_document_type IN ( 'REQUISITION' ) THEN

      FOR processing_rec IN c_req_line_taxes(p_line_id) LOOP        -- p_line_id contains requistion_line_id
        j := j + 1;

        -- we have to identify the defaulted taxes that are not dependant on any other taxes and any
        -- manually added tax is not dependant on the defaulted taxes and then populate plsql table so that
        -- we can delete those

        IF processing_rec.tax_category_id IS NULL THEN
          v_manual_tax_line_nos.EXTEND;
          v_manual_tax_line_nos(v_manual_tax_line_nos.LAST) := processing_rec.tax_line_no;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    IF processing_rec.p_1 > 0 OR
             processing_rec.p_2 > 0 OR
       processing_rec.p_3 > 0 OR
       processing_rec.p_4 > 0 OR
       processing_rec.p_5 > 0 OR
       processing_rec.p_6 > 0 OR
       processing_rec.p_7 > 0 OR
       processing_rec.p_8 > 0 OR
       processing_rec.p_9 > 0 OR
       processing_rec.p_10 > 0
          THEN
            p_success := -2;
            p_message := 'Lines having Manual taxes and that has precedence on other tax lines are not processed';
            RETURN;
          END IF;
          v_manual := 'Y';
        ELSE


    IF processing_rec.p_1 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_1; END IF;
          IF processing_rec.p_2 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_2; END IF;
          IF processing_rec.p_3 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_3; END IF;
          IF processing_rec.p_4 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_4; END IF;
          IF processing_rec.p_5 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_5; END IF;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    IF processing_rec.p_6 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_6; END IF;
          IF processing_rec.p_7 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_7; END IF;
          IF processing_rec.p_8 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_8; END IF;
          IF processing_rec.p_9 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_9; END IF;
          IF processing_rec.p_10 > 0 THEN v_dflt_tax_prec.EXTEND; v_dflt_tax_prec(v_dflt_tax_prec.LAST) := processing_rec.p_10; END IF;
-- END BUG 5228046
  END IF;

      END LOOP;

    END IF;

    IF j = 0 THEN
      p_message := 'No Taxes are attached to the shipment line';
      p_success := 3;
      RETURN;
    END IF;

    -- Dependency Check for Defaulted taxes on Manual taxes
    FOR ii IN 1..v_manual_tax_line_nos.COUNT LOOP
      v_dflt_temp := v_manual_tax_line_nos(ii);
      FOR jj IN 1..v_dflt_tax_prec.COUNT LOOP
        IF v_dflt_temp = v_dflt_tax_prec(jj) THEN
          p_success := -2;
          p_message := 'Defaulted Taxes are having dependency on the Manual taxes. So, cannot perform tax recalculation';
          RETURN;
        END IF;
      END LOOP;
    END LOOP;

    IF v_manual = 'N' AND p_success > 0 THEN
      IF p_document_type = 'PO' THEN
        DELETE FROM JAI_PO_TAXES
        WHERE line_focus_id = p_line_focus_id AND tax_category_id IS NOT NULL;
        p_message := 'No Manual taxes are attached to the shipment, so no problem is deleting the shipment taxes';
      ELSIF p_document_type = 'SO' THEN
        DELETE FROM JAI_OM_OE_SO_TAXES
        WHERE line_id = p_line_id AND tax_category_id IS NOT NULL;
        p_message := 'No Manual taxes are attached to the SO line, so no problem is deleting the line taxes';
      ELSIF p_document_type = 'REQUISITION' THEN
        DELETE FROM JAI_PO_REQ_LINE_TAXES
        WHERE requisition_line_id = p_line_id AND tax_category_id IS NOT NULL;
        p_message := 'No Manual taxes are attached to requisition line, so no problem is deleting the line taxes';
      END IF;

      IF v_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log,' 3.1');
      END IF;

      RETURN;
    ELSIF v_manual = 'Y' AND p_success > 0 THEN

      IF p_document_type = 'PO' THEN
        DELETE FROM JAI_PO_TAXES
        WHERE line_focus_id = p_line_focus_id
        AND tax_category_id IS NOT NULL;

        p_message := 'No Manual taxes are attached to the shipment, so no problem is deleting the shipment taxes';

      ELSIF p_document_type = 'SO' THEN
        DELETE FROM JAI_OM_OE_SO_TAXES
        WHERE line_id = p_line_id
        AND tax_category_id IS NOT NULL;

        p_message := 'No Manual taxes are attached to the SO line, so no problem is deleting the line taxes';

      ELSIF p_document_type = 'REQUISITION' THEN
        DELETE FROM JAI_PO_REQ_LINE_TAXES
        WHERE requisition_line_id = p_line_id
        AND tax_category_id IS NOT NULL;

        p_message := 'No Manual taxes are attached to requisition line, so no problem is deleting the line taxes';
      END IF;

      IF v_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log,' 3.2');
      END IF;

      p_message := 'Manual taxes are attached and there is no problem in deleting the taxes';

      RETURN;
    END IF;

    p_success := 0;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

  END del_taxes_after_validate;

END jai_cmn_mtax_pkg;

/
