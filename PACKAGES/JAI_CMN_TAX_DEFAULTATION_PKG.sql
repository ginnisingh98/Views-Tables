--------------------------------------------------------
--  DDL for Package JAI_CMN_TAX_DEFAULTATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_TAX_DEFAULTATION_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_tax_dflt.pls 120.4.12010000.3 2009/04/15 06:13:06 mbremkum ship $ */

/*----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:             FILENAME: ja_in_tax_pkg.sql
S.No    Date        Author and Details
------------------------------------------------------------------------------------------------------------------------
1     04/07/2002    Aparajita for bug # 2381492
                    RMA without reference -- LEGACY changes

2     06/12/2002    cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                    tax_category_id column is populated into PO and SO localization tables, which will be used to
                    identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into the
                    tax table will be useful to identify whether the tax is a defaulted or a manual tax

3     25/03/2003    cbabu for Bug# 2837970, FileVersion# 615.2
                     Modified to include data population into JAI_CRM_QUOTE_TAXES table when ja_in_calc_prec_taxes procedure
                     is called with required parameters.
                     p_operation_flag parameter contains aso_shipments.shipment_id when invoked from ja_in_crm_quote_taxes (called
                     from JAINPQTEL.rdf report) procedure for quote taxes calculation

4.    08/05/2003    sriram - bug # 2812781  File Version 615.3
                    When a po is created with very large quantity , upon saving the purchase order
                    a numeric or value error . The reason for this behaviour is that because there were
                    two table of numbers wose width was (14,3) This has been changed to (30,3). This has solved the
                    issue.
5.    12/07/2003    Aiyer - Bug #3749294 File Version 115.1
                    Issue:-
                    Uom based taxes do not get calculated correctly if the transaction UOM is different from the
                    UOM setup in the tax definitions India Localization (JAI_CMN_TAXES_ALL table).

                    Fix:-
                    ----
                    Modified the procedure ja_in_calc_prec_taxes.For more details please refer the change history
                    section of the concerned procedure.

                    Dependency Due to This Bug:-
                    ----------------------------
                    None

6   22/09/2004      Aiyer for bug#3792765. Version#115.2
                    Issue:-
            Warehouse ID is not currently being allowed to be left null from the base apps sales order. When placing a order from 2
            different manufacturing organizations, it is required that customer temporarily leaves the warehouseid as Null and then
            updates the same before pick release. However this is currently not allowed by localization even though base
            apps allows this feature.

          Fix:-
                    ----
            Modified the procedure ja_in_tax_pkg.ja_in_org_default_taxes. For more details please refer the change history
                    section of the concerned procedure.

                    Dependency Due to this Bug:-
          ----------------------------
                    Functional dependency with the trigger ja_in_oe_order_lines_aiu_trg.sql version 115.4


7  27/01/2005     ssumaith - bug#4136981

                  In case of Bond Register Scenario taxes should not be defaulted to the Sales order or Manual Ar transaction.

                  This fix does not introduce dependency on this object , but this patch cannot be sent alone to the CT
                  because it relies on the alter done and the new tables created as part of the education cess enhancement
                  bug# 4146708 creates the objects


8.               08-Jun-2005  Version 116.1 jai_cmn_tax_dflt -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		 as required for CASE COMPLAINCE.


9   30/01/2007    Bgowrava for forward porting Bug#5631784,  Version 116.2
                    1.  Added a record type tax_rec_typ to fetch the record using reference cursor
                    2.  Added a REF CURSOR ref_cur_typ.  The cursor will refer to a active sql object
                        depending upon the value of p_action.  If it is DEFAULT then a normal cursor
                        will be used.  If it is RECALCULATE then a dynamic cursor will be used based on the
                        p_source_trx_type
                    3.  Added a procedure GET_TAX_CAT_TAXES_CUR.  The procedure is used to retrieve cursor object.
                        Procedure is also used in JAI_RGM_THHOLD_PROC_PKG.DEFAULT_THHOLD_TAXES

10  09/08/2007    rchandan for bug#6030615. File Version 120.3
                  Issue: Forward Porting of Inter Org
                    Fix : Uncommented adhoc_flag in pl/sql table
Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

11  04/09/2007    Jason Liu    Update the procedure ja_in_calc_prec_taxes
                               to handle the AP Standalone Invoice

12  01/15/2008  Kevin Cheng   Add a parameter in ja_in_calc_prec_taxes and get_tax_cat_taxes_cur to distinguish retroactive
                              price update action.
----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                              Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_tax_pkg
----------------------------------------------------------------------------------------------------------------------------------------------------
115.2                  3792765      IN60105D2             ja_in_oe_order_lines_aiu_trg.sql    115.4    Aiyer   22/09/2004   Functional dependency



----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------*/

		   /* bgowrava for forward porting bug#5631784, TCS Enh.
		      || Following record must be modified according to any modification done in select column list of curosr REFC_TAX_CUR
		      */
		type ref_cur_typ      is ref cursor;
		type tax_rec_typ is record
		(
		    tax_id            JAI_CMN_TAXES_ALL.tax_id%type
		    , lno               JAI_CMN_TAX_CTG_LINES.line_no%type
		    , p_1               JAI_CMN_TAX_CTG_LINES.precedence_1%type
		    , p_2               JAI_CMN_TAX_CTG_LINES.precedence_2%type
		    , p_3               JAI_CMN_TAX_CTG_LINES.precedence_3%type
		    , p_4               JAI_CMN_TAX_CTG_LINES.precedence_4%type
		    , p_5               JAI_CMN_TAX_CTG_LINES.precedence_5%type
		    , p_6               JAI_CMN_TAX_CTG_LINES.precedence_6%type
		    , p_7               JAI_CMN_TAX_CTG_LINES.precedence_7%type
		    , p_8               JAI_CMN_TAX_CTG_LINES.precedence_8%type
		    , p_9               JAI_CMN_TAX_CTG_LINES.precedence_9%type
		    , p_10              JAI_CMN_TAX_CTG_LINES.precedence_10%type
		    , tax_rate          JAI_CMN_TAXES_ALL.tax_rate%type
		    , tax_amount        JAI_CMN_TAXES_ALL.tax_amount%type
		    , uom_code          JAI_CMN_TAXES_ALL.uom_code%type
		    , valid_date        JAI_CMN_TAXES_ALL.end_date%type
		    , tax_type_val      number
		    , mod_cr_percentage JAI_CMN_TAXES_ALL.mod_cr_percentage%type
		    , vendor_id         JAI_CMN_TAXES_ALL.vendor_id%type
		    , tax_type          JAI_CMN_TAXES_ALL.tax_type%type
		    , rounding_factor   JAI_CMN_TAXES_ALL.rounding_factor%type
		    , adhoc_flag        JAI_CMN_TAXES_ALL.adhoc_flag%type
		    , tax_category_id   JAI_CMN_TAX_CTGS_ALL.tax_category_id%type
		    , inclusive_tax_flag JAI_CMN_TAXES_ALL.inclusive_tax_flag%type  --added by walton for inclusive tax
		);
    /*end of bug#5631784 */

    PROCEDURE ja_in_cust_default_taxes(
        p_org_id                NUMBER,
        p_customer_id           NUMBER,
        p_ship_to_site_use_id   NUMBER,
        p_inventory_item_id IN  NUMBER,
        p_header_id             NUMBER,
        p_line_id               NUMBER,
        p_tax_category_id IN OUT NOCOPY NUMBER
    );

    PROCEDURE ja_in_vendor_default_taxes(
        p_org_id                NUMBER,
        p_vendor_id             NUMBER,
        p_vendor_site_id        NUMBER,
        p_inventory_item_id IN  NUMBER,
        p_header_id             NUMBER,
        p_line_id               NUMBER,
        p_tax_category_id IN OUT NOCOPY NUMBER
    );

    PROCEDURE ja_in_org_default_taxes(
        p_org_id                    NUMBER,
        p_inventory_item_id IN      NUMBER,
        p_tax_category_id IN OUT NOCOPY NUMBER
    );

    PROCEDURE ja_in_calc_prec_taxes(
        transaction_name        VARCHAR2,
        P_tax_category_id       NUMBER,
        p_header_id             NUMBER,
        p_line_id               NUMBER,
        p_assessable_value      NUMBER DEFAULT 0,
        p_tax_amount IN OUT NOCOPY NUMBER,
        p_inventory_item_id     NUMBER,
        p_line_quantity         NUMBER,
        p_uom_code              VARCHAR2,
        p_vendor_id             NUMBER,
        p_currency              VARCHAR2,
        p_currency_conv_factor  NUMBER,
        p_creation_date         DATE,
        p_created_by            NUMBER,
        p_last_update_date      DATE,
        p_last_updated_by       NUMBER,
        p_last_update_login     NUMBER,
        p_operation_flag        NUMBER DEFAULT NULL,
        p_vat_assessable_value  NUMBER DEFAULT 0
        /** bgowrava for forward porting bug#5631784,Following parameters are added for TCS enh.*/
				, p_thhold_cat_base_tax_typ JAI_CMN_TAXES_ALL.tax_type%type default null  -- tax type to be considered as base when calculating threshold taxes
				, p_threshold_tax_cat_id    JAI_AP_TDS_THHOLD_TAXES.tax_category_id%type default null
				, p_source_trx_type         jai_cmn_document_taxes.source_doc_type%type default null
				, p_source_table_name       jai_cmn_document_taxes.source_table_name%type default null
				, p_action                 varchar2  default null
        /** End bug 5631784 */
        , pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
        , p_modified_by_agent_flag  po_requisition_lines_all.modified_by_agent_flag%type default NULL /*Added for Bug 8241905*/
        , p_parent_req_line_id      po_requisition_lines_all.parent_req_line_id%type default NULL /*Added for Bug 8241905*/
		, p_max_tax_line            NUMBER DEFAULT 0 /*Added for Bug 8371741*/
		, p_max_rgm_tax_line        NUMBER DEFAULT 0 /*Added for Bug 8371741*/
    );

/* bgowrava for forward porting bug#5631784, TCS Enh. */
procedure get_tax_cat_taxes_cur
                                (  p_tax_category_id        number
                                  ,p_threshold_tax_cat_id   number default null
                                  ,p_max_tax_line           number default 0
                                  ,p_max_rgm_tax_line       number default 0
                                  ,p_base                   number default 0
                                  ,p_refc_tax_cat_taxes_cur  out nocopy  ref_cur_typ
                                  , pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
                                );
/*end of bug#5631784 */

END jai_cmn_tax_defaultation_pkg;

/
