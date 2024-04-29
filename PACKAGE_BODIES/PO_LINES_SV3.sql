--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV3" as
/* $Header: POXPOL3B.pls 120.12 2006/09/07 22:48:38 togeorge noship $ */

g_chktype_TRACKING_QTY_IND_S CONSTANT
   MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND%TYPE
   := 'PS'; --<INVCONV R12>
/*=============================  PO_LINES_SV3  ==============================*/

/*===========================================================================
 PROCEDURE : Insert_line()

**===========================================================================*/

 procedure insert_line(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Line_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Item_Revision                  VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Item_Description               VARCHAR2,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Quantity_Committed             NUMBER,
                       X_Committed_Amount               NUMBER,
                       X_Allow_Price_Override_Flag      VARCHAR2,
                       X_Not_To_Exceed_Price            NUMBER,
                       X_List_Price_Per_Unit            NUMBER,
                       X_Unit_Price                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Un_Number_Id                   NUMBER,
                       X_Hazard_Class_Id                NUMBER,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       x_from_line_location_id          NUMBER,  -- <SERVICES FPJ>
                       X_Min_Order_Quantity             NUMBER,
                       X_Max_Order_Quantity             NUMBER,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Over_Tolerance_Error_Flag      VARCHAR2,
                       X_Market_Price                   NUMBER,
                       X_Unordered_Flag                 VARCHAR2,
                       X_Closed_Flag                    VARCHAR2,
                       X_User_Hold_Flag                 VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Firm_Date                      DATE,
                       X_Vendor_Product_Num             VARCHAR2,
                       X_Contract_Num                   VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
                       X_Type_1099                      VARCHAR2,
                       X_Capital_Expense_Flag           VARCHAR2,
                       X_Negotiated_By_Preparer_Flag    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Reference_Num                  VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Min_Release_Amount             NUMBER,
                       X_Price_Type_Lookup_Code         VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Price_Break_Lookup_Code        VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_By                      NUMBER,
                       X_Transaction_Reason_Code        VARCHAR2,
                       X_revise_header                  BOOLEAN,
                       X_revision_num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_revised_date                   VARCHAR2,
                       X_revised_date                   DATE,
                       X_approved_flag                  VARCHAR2,
                       X_header_row_id                  VARCHAR2,
                       X_type_lookup_code               VARCHAR2,
                       X_ship_to_location_id            NUMBER,
                       X_ship_org_id                    NUMBER,
                       X_need_by_date                   DATE,
                       X_promised_date                  DATE,
                       X_receipt_required_flag          VARCHAR2,
                       X_invoice_close_tolerance        NUMBER,
                       X_receive_close_tolerance        NUMBER,
                       X_planned_item_flag              VARCHAR2,
                       X_outside_operation_flag         VARCHAR2,
                       X_destination_type_code          VARCHAR2,
                       X_expense_accrual_code           VARCHAR2,
                       X_dist_blk_status                VARCHAR2,
                       X_accrue_on_receipt_flag IN OUT NOCOPY  VARCHAR2,
                       X_ok_to_autocreate_ship          VARCHAR2,
                       X_autocreated_ship       IN OUT NOCOPY  BOOLEAN,
                       X_line_location_id       IN OUT NOCOPY  NUMBER,
                       X_vendor_id                      NUMBER,
                       X_Global_Attribute_Category          VARCHAR2,
                       X_Global_Attribute1                  VARCHAR2,
                       X_Global_Attribute2                  VARCHAR2,
                       X_Global_Attribute3                  VARCHAR2,
                       X_Global_Attribute4                  VARCHAR2,
                       X_Global_Attribute5                  VARCHAR2,
                       X_Global_Attribute6                  VARCHAR2,
                       X_Global_Attribute7                  VARCHAR2,
                       X_Global_Attribute8                  VARCHAR2,
                       X_Global_Attribute9                  VARCHAR2,
                       X_Global_Attribute10                 VARCHAR2,
                       X_Global_Attribute11                 VARCHAR2,
                       X_Global_Attribute12                 VARCHAR2,
                       X_Global_Attribute13                 VARCHAR2,
                       X_Global_Attribute14                 VARCHAR2,
                       X_Global_Attribute15                 VARCHAR2,
                       X_Global_Attribute16                 VARCHAR2,
                       X_Global_Attribute17                 VARCHAR2,
                       X_Global_Attribute18                 VARCHAR2,
                       X_Global_Attribute19                 VARCHAR2,
                       X_Global_Attribute20                 VARCHAR2,
                       X_Expiration_Date                    DATE,
-- Mahesh Chandak(GML-OPM).bug# 1548597.Add secondary_unit_of_measure,secondary_ quantity,preferred_grade for CR.base_uom and base_qty won't be used in future..
-- Preetam Bamb (GML-OPM) Added the following fields to replace PO_LINES flexfield
-- Bug# 1056597
                     X_Base_Uom                           VARCHAR2,
                     X_Base_Qty                           NUMBER,
                     X_Secondary_Uom                    VARCHAR2,
                     X_Secondary_Qty                    NUMBER,
                     X_Qc_Grade                         VARCHAR2,
                       --togeorge 10/03/2000
                       --added oke columns
                       X_oke_contract_header_id             NUMBER default null,
                       X_oke_contract_version_id            NUMBER default null,
 --mchandak 1548597
                     X_Secondary_Unit_Of_Measure          VARCHAR2 default null,
                     X_Secondary_Quantity                 NUMBER default null,
                     X_Preferred_Grade                    VARCHAR2 default null,
                     p_contract_id                      IN NUMBER DEFAULT NULL, -- <GC FPJ>
                     X_job_id                    IN        NUMBER   default null, -- <SERVICES FPJ>
                     X_contractor_first_name     IN        VARCHAR2 default null, -- <SERVICES FPJ>
                     X_contractor_last_name      IN        VARCHAR2 default null, -- <SERVICES FPJ>
                     X_assignment_start_date     IN        DATE     default null, -- <SERVICES FPJ>
                     X_amount_db                 IN        NUMBER   default null, -- <SERVICES FPJ>
                     X_order_type_lookup_code    IN        VARCHAR2 default null, -- <SERVICES FPJ>
                     X_purchase_basis            IN        VARCHAR2 default null, -- <SERVICES FPJ>
                     X_matching_basis            IN        VARCHAR2 default null,  -- <SERVICES FPJ>
                     -- <FPJ Advanced Price START>
                     X_Base_Unit_Price                NUMBER  DEFAULT NULL,
                     -- <FPJ Advanced Price END>
                     p_manual_price_change_flag  IN        VARCHAR2 default null,  -- <Manual Price Override FPJ>
                     p_consigned_from_supplier_flag IN        VARCHAR2 default null,  --bug 3523348
                     p_org_id                     IN     NUMBER   default null     -- <R12 MOAC>
                     )    is

 X_Progress          varchar2(3)  := NULL;
 X_item_valid        varchar2(1) ;
 X_valid_loc         boolean := FALSE;
 X_ship_row_id       varchar2(18);
 X_enforce_ship_to_location       varchar2(25);
 X_allow_substitute_receipts      varchar2(1);
 X_qty_rcv_exception_code         varchar2(25);
 X_qty_rcv_tol                    number;
 X_days_early_receipt_allowed     number;
 X_days_late_receipt_allowed      number;
 X_receipt_days_exception_code    varchar2(25);
 X_receiving_routing_id           number;
 X_inspection_required_flag       varchar2(1);
 X_item_status                    VARCHAR2(1);
 X_receipt_required_flag_tmp    varchar2(1);


/*Bug 2632699 Added the variables */
 temp_receipt_required_flag     varchar2(1);
 temp_inspection_required_flag  varchar2(1);

 /* Bug 919204
  Added these two temp variables
  X_receive_close_tolerance_tmp,X_invoice_close_tolerance_tmp
 */

 X_receive_close_tolerance_tmp    number;
 X_invoice_close_tolerance_tmp    number;

 /** bug# 1548597 **/
 X_secondary_unit_of_measure_s    MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE := NULL;
 X_secondary_quantity_shipment    PO_LINE_LOCATIONS_ALL.SECONDARY_QUANTITY%TYPE := NULL;
 X_preferred_grade_shipment       MTL_GRADES.GRADE_CODE%TYPE := NULL;--<INVCONV R12> increased length to 150

 --<INVCONV R12 START>
 l_secondary_default_ind    MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;
 l_grade_control_flag           MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG%TYPE;
 l_secondary_uom_code             MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
 --<INVCONV R12 END>
 l_outsourced_assembly po_line_locations_all.outsourced_assembly%type; --<SHIKYU R12>

 l_ip_category_id PO_LINES_ALL.ip_category_id%TYPE; -- <Unified Catalog R12>

 begin

       -- verify that the line number is unique.
       -- Otherwise, display a message to the user and
       -- abort insert_row.

       X_Progress := '010';
       l_outsourced_assembly :=2; --<SHIKYU R12>
       po_lines_pkg_scu.check_unique (X_rowid,
                                      X_line_num,
                                      X_po_header_id);

       X_Progress := '015';

      -- <Unified Catalog R12 Start>
      -- Default the IP_CATEGORY_ID
      PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id
      (
        p_po_category_id => x_category_id
      , x_ip_category_id => l_ip_category_id -- OUT
      );
      -- <Unified Catalog R12 End>

       X_autocreated_ship := FALSE;

       /* Insert the PO Line */

       po_lines_pkg_si.insert_row(
                       X_Rowid                   ,
                       X_Po_Line_Id              ,
                       X_Last_Update_Date        ,
                       X_Last_Updated_By         ,
                       X_Po_Header_Id            ,
                       X_Line_Type_Id            ,
                       X_Line_Num                ,
                       X_Last_Update_Login       ,
                       X_Creation_Date           ,
                       X_Created_By              ,
                       X_Item_Id                 ,
                       X_Item_Revision           ,
                       X_Category_Id             ,
                       X_Item_Description        ,
                       X_Unit_Meas_Lookup_Code   ,
                       X_Quantity_Committed      ,
                       X_Committed_Amount        ,
                       X_Allow_Price_Override_Flag ,
                       X_Not_To_Exceed_Price       ,
                       X_List_Price_Per_Unit       ,
                       -- <FPJ Advanced Price START>
                       -- Bug 3417479
                       X_Base_Unit_Price,
                       -- <FPJ Advanced Price END>
                       X_Unit_Price                ,
                       X_Quantity                  ,
                       X_Un_Number_Id              ,
                       X_Hazard_Class_Id           ,
                       X_Note_To_Vendor            ,
                       X_From_Header_Id            ,
                       X_From_Line_Id              ,
                       x_from_line_location_id     ,          -- <SERVICES FPJ>
                       X_Min_Order_Quantity        ,
                       X_Max_Order_Quantity        ,
                       X_Qty_Rcv_Tolerance         ,
                       X_Over_Tolerance_Error_Flag ,
                       X_Market_Price              ,
                       X_Unordered_Flag            ,
                       X_Closed_Flag               ,
                       X_User_Hold_Flag            ,
                       X_Cancel_Flag               ,
                       X_Cancelled_By              ,
                       X_Cancel_Date               ,
                       X_Cancel_Reason             ,
                       X_Firm_Status_Lookup_Code   ,
                       X_Firm_Date                 ,
                       X_Vendor_Product_Num        ,
                       X_Contract_Num              ,
                       X_Taxable_Flag              ,
                       X_Tax_Code_Id               ,
                       X_Type_1099                 ,
                       X_Capital_Expense_Flag      ,
                       X_Negotiated_By_Preparer_Flag ,
                       X_Attribute_Category          ,
                       X_Attribute1                  ,
                       X_Attribute2                  ,
                       X_Attribute3                  ,
                       X_Attribute4                  ,
                       X_Attribute5                  ,
                       X_Attribute6                  ,
                       X_Attribute7                  ,
                       X_Attribute8                  ,
                       X_Attribute9                  ,
                       X_Attribute10                 ,
                       X_Reference_Num               ,
                       X_Attribute11                 ,
                       X_Attribute12                 ,
                       X_Attribute13                 ,
                       X_Attribute14                 ,
                       X_Attribute15                 ,
                       X_Min_Release_Amount          ,
                       X_Price_Type_Lookup_Code      ,
                       X_Closed_Code                 ,
                       X_Price_Break_Lookup_Code     ,
                       NULL                          , --<R12 SLA>
                       X_Government_Context          ,
                       X_Closed_Date                 ,
                       X_Closed_Reason               ,
                       X_Closed_By                   ,
                       X_Transaction_Reason_Code     ,
                       X_Global_Attribute_Category      ,
                       X_Global_Attribute1              ,
                       X_Global_Attribute2              ,
                       X_Global_Attribute3              ,
                       X_Global_Attribute4              ,
                       X_Global_Attribute5              ,
                       X_Global_Attribute6              ,
                       X_Global_Attribute7              ,
                       X_Global_Attribute8              ,
                       X_Global_Attribute9              ,
                       X_Global_Attribute10             ,
                       X_Global_Attribute11             ,
                       X_Global_Attribute12             ,
                       X_Global_Attribute13             ,
                       X_Global_Attribute14             ,
                       X_Global_Attribute15             ,
                       X_Global_Attribute16             ,
                       X_Global_Attribute17             ,
                       X_Global_Attribute18             ,
                       X_Global_Attribute19             ,
                       X_Global_Attribute20             ,
                       X_Expiration_Date                ,
/** Mahesh Chandak(GML)bug# 1548597 base_uom and base_qty won't be used
 in the  future.we are keeping secondary_uom,secondary_qty and qc_grade for
 supporting Common Purchasing. we will have 3 new fields secondary_unit_of_measu
re, secondary_quantity and  preferred_grade columns in the table **/
-- Preetam Bamb (GML-OPM) Added the following fields to replace PO_LINES flexfield
-- Bug# 1056597
                       X_Base_Uom                       ,
                       X_Base_Qty                       ,
                       X_Secondary_Uom,
                       X_Secondary_Qty,
                       X_Qc_Grade,
                       --togeorge 10/03/2000
                       --added oke columns
                       X_oke_contract_header_id         ,
                       X_oke_contract_version_id       ,
-- start of 1548597
                       X_Secondary_unit_of_measure      ,
                       X_Secondary_quantity             ,
                       X_preferred_grade                ,
-- end of 1548597
                       p_contract_id,              -- <GC FPJ>
                       X_job_id,                   -- <SERVICES FPJ>
                       X_contractor_first_name,    -- <SERVICES FPJ>
                       X_contractor_last_name,     -- <SERVICES FPJ>
                       X_assignment_start_date,    -- <SERVICES FPJ>
                       X_amount_db,                -- <SERVICES FPJ>
                       X_order_type_lookup_code,   -- <SERVICES FPJ>
                       X_purchase_basis,           -- <SERVICES FPJ>
                       X_matching_basis,           -- <SERVICES FPJ>
                       p_manual_price_change_flag, -- <Manual Price Override FPJ>
                       p_org_id,                   -- <R12 MOAC>
                       l_ip_category_id            -- <Unified Catalog R12>
                       );

    -- <Unified Catalog R12 Start>
    -- Create default Attr and TLP rows for this PO Line
    IF (x_type_lookup_code IN ('BLANKET', 'QUOTATION')) THEN
      PO_ATTRIBUTE_VALUES_PVT.create_default_attributes
      (
        p_doc_type              => x_type_lookup_code,
        p_po_line_id            => x_po_line_id,
        p_req_template_name     => NULL,
        p_req_template_line_num => NULL,
        p_ip_category_id        => l_ip_category_id,
        p_inventory_item_id     => x_item_id,
        p_org_id                => p_org_id,
        p_description           => x_item_description
      );
    END IF;
    -- <Unified Catalog R12 End>


     if (x_type_lookup_code not in ('CONTRACT','BLANKET','RFQ', 'QUOTATION')) then

      /* Check if a shipment can be autocreated */

      IF X_ok_to_autocreate_ship = 'Y' THEN

          if (X_ship_to_location_id is NULL) OR
             (X_ship_org_id is NULL) then
             /* Cannot Autocreate shipments AND distributions.
             ** Should probably return.with an appropriate message DEBUG */

             X_autocreated_ship := FALSE;

             return;

          elsif ( X_planned_item_flag = 'Y' ) then
               if (X_need_by_date is NULL) AND
                  (X_promised_date is NULL)  then
                  /* Cannot Autocreate shipments AND distributions.
                  ** Should probably return..with an appropriate msg. DEBUG */

                  X_autocreated_ship := FALSE;
                  return;

               end if;

          end if;

         /* Attempt to autocreate shipment */

            /* Validate the ship_to_location */
	    --<BUG 5506604> The following function call was happening only when x_item_id is null.
	    --removed the if clause around it to invoke irrespective of the item id.
            /* Check_loc_valid_in_org */
            X_valid_loc := po_locations_s.val_ship_to_site_in_org(
                             X_ship_to_location_id,
                             X_ship_org_id);

            if X_item_id is not null then
                /* The following procedure either validates
                ** an item within an org, OR the item revision within
                ** an org depending on the item_revision value */

                po_items_sv.val_item_org(X_item_revision,
                                         X_item_id,
                                         X_ship_org_id,
                                         X_outside_operation_flag,
                                         X_item_valid);
            end if;

          /* Get the item status */

           X_item_status := '';

           po_items_sv2.get_item_status(X_item_id,
                                        X_ship_org_id,
                                        X_item_status);

	    --<BUG 5506604> Changed OR to AND below as
	    --auto creation should be taking place if both the condition are true
           if ((nvl(X_item_valid,'Y') = 'Y') AND
               (X_valid_loc))  then

               /* rcv_core_s.get_receiving_controls;
               ** DEBUG Need to add the call.
               ** Currently the API does not duplicate the
               ** functionality of the userexit.
               ** Spoke to GKELLNER about it. 7/28 */
              rcv_core_s.get_receiving_controls(null,
                         X_item_id,
                         X_vendor_id,
                         X_ship_org_id,
                         X_enforce_ship_to_location,
                         X_allow_substitute_receipts,
                         X_receiving_routing_id,
                         X_qty_rcv_tol,
                         X_qty_rcv_exception_code,
                         X_days_early_receipt_allowed,
                         X_days_late_receipt_allowed,
                         X_receipt_days_exception_code);


        /* Bug 475621 ecso 4/23
         * Get default value for invoice matching
         */
            po_shipments_sv8.get_matching_controls(
                               X_vendor_id,
                               X_line_type_id,
                               X_item_id,
                               X_receipt_required_flag_tmp,
                               X_inspection_required_flag);
         IF X_receipt_required_flag_tmp IS NULL THEN
               X_receipt_required_flag_tmp  := 'N';
         END IF;
         IF X_inspection_required_flag IS NULL THEN
              X_inspection_required_flag  := 'N';
         END IF;

/*Bug 2632699 Receipt required flag,Inspection required flag set for Item/destination Org
  is retrived. If they are null then they are derived from masfer Org.
  Also if Receipt required flag is N and  Inspection required flag is Y then
  Match option is showing as blank. Hence in the above case Inspection
  required flag is set to N */

        /* Bug 919204
        Fix to use the  invoice/receive close tolerance values
        defined at the item/destination org level.
        */
        X_invoice_close_tolerance_tmp := X_invoice_close_tolerance;
        X_receive_close_tolerance_tmp := X_receive_close_tolerance;
        begin
         SELECT nvl(msi.invoice_close_tolerance,X_invoice_close_tolerance_tmp),
                nvl(msi.receive_close_tolerance,X_receive_close_tolerance_tmp),
                msi.receipt_required_flag,
                msi.inspection_required_flag,
                --<INVCONV R12 START>
                decode(msi.tracking_quantity_ind,
                       g_chktype_TRACKING_QTY_IND_S,msi.secondary_default_ind,NULL),
                msi.grade_control_flag,
                decode(msi.tracking_quantity_ind,
                       g_chktype_TRACKING_QTY_IND_S,msi.secondary_uom_code,NULL)
                --<INVCONV R12 END>
         INTO   X_invoice_close_tolerance_tmp,
                X_receive_close_tolerance_tmp,
                temp_receipt_required_flag,
                temp_inspection_required_flag,
                l_secondary_default_ind, l_grade_control_flag, l_secondary_uom_code --<INVCONV R12>
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = X_item_id
             AND msi.organization_id =X_ship_org_id;

           exception
               when no_data_found then null;
               WHEN OTHERS THEN
           po_message_s.sql_error('Fetch receive/invoice tolerances', x_progress, sqlcode);
            raise;
        end;
        if temp_receipt_required_flag is not null then
              X_receipt_required_flag_tmp := temp_receipt_required_flag;
        end if;
        if temp_inspection_required_flag is not null then
           X_inspection_required_flag := temp_inspection_required_flag;
        end if;

        if X_receipt_required_flag_tmp = 'N' then
            X_inspection_required_flag := 'N';
        end if;

         -- SERVICES FPJ start: Need to null out certain receiving and matching
         -- controls for service lines.

               IF X_order_type_lookup_code in ('RATE', 'FIXED PRICE') THEN

                 X_allow_substitute_receipts := null;
                 X_receiving_routing_id := 3;
                 X_enforce_ship_to_location := 'NONE';

                 X_inspection_required_flag  := 'N';

                 IF X_purchase_basis = 'TEMP LABOR' THEN
                    X_days_early_receipt_allowed := null;
                    X_days_late_receipt_allowed := null;
                    X_receipt_days_exception_code := null;
                 END IF;

               END IF;

          -- SERVICES FPJ end

   IF l_grade_control_flag = 'Y' THEN
       X_preferred_grade_shipment := X_preferred_grade;
   ELSE
       X_preferred_grade_shipment := null;
   END IF;

   IF l_secondary_uom_code IS NOT NULL THEN  -- item is dual uom control
       SELECT unit_of_measure INTO x_secondary_unit_of_measure_s
       FROM mtl_units_of_measure
       WHERE uom_code = l_secondary_uom_code ;

    /** secondary quantity is specified on the lines. Validate the line secondary quantity
      with respect to ship to organization . Items in different organization can have different
      from and to deviation so we need to validate before copying the line secondary quantity to shipment **/

      IF X_secondary_quantity IS NOT NULL
         and X_secondary_unit_of_measure = X_secondary_unit_of_measure_s THEN

          IF ( INV_CONVERT.within_deviation(
                  p_organization_id     =>   X_ship_org_id ,
                  p_inventory_item_id         =>   x_item_id,
                  p_lot_number                =>  null ,
                  p_precision                 =>  5 ,
                  p_quantity                  =>  x_quantity,
                  p_unit_of_measure1          =>  X_Unit_Meas_Lookup_Code ,
                  p_quantity2                 =>  x_secondary_quantity ,
                  p_unit_of_measure2          =>  X_secondary_unit_of_measure_s,
                  p_uom_code1     => null,
                  p_uom_code2     => null) = 1 ) THEN

       X_secondary_quantity_shipment  := X_secondary_quantity;
          END IF;
      END IF;

      IF X_secondary_quantity_shipment IS NULL THEN -- derive secondary quantity
           X_secondary_quantity_shipment := INV_CONVERT.inv_um_convert(
            item_id             =>  x_item_id ,
            precision   => 5,
            from_quantity       =>  x_quantity,
            from_name   =>  X_Unit_Meas_Lookup_Code ,
            to_name           => X_secondary_unit_of_measure_s,
            from_unit   => null,
            to_unit     => null ) ;
       IF  X_secondary_quantity_shipment <=0 then
        X_autocreated_ship := FALSE;
            return;
       END IF;
      END IF;
   END IF; -- IF l_secondary_uom_code IS NOT NULL THEN


--<INVCONV R12 END>



        /* AutoCreate the Shipment   */

        /* We are using the Qty_Rcv_Tol returned from get_receiving_controls()
        in order to create the shipment automatically. We are not using
        the value passed into this procedure insert_line() - Take a
        note of that. SI 02/16 */

                -- bug 451195
                -- Added USSGL transaction code in autocreate shipment
        --<SHIKYU R12 START>
        IF X_item_id is NOT NULL and X_ship_org_id is not NULL THEN
        l_outsourced_assembly := po_core_s.get_outsourced_assembly(X_item_id, X_ship_org_id);
        END IF;
        --<SHIKYU R12 END>
        po_shipments_sv8.autocreate_ship(
                     X_line_location_id               ,
                     X_last_update_date               ,
                     X_last_updated_by                ,
                     X_creation_date                  ,
                     X_created_by                     ,
                     X_last_update_login              ,
                     X_po_header_id                   ,
                     X_po_line_id                     ,
                     X_type_lookup_code               ,
                     X_quantity                       ,
                     X_ship_to_location_id            ,
                     X_ship_org_id                    ,
                     X_need_by_date                   ,
                     X_promised_date                  ,
                     X_unit_price                     ,
                     X_tax_code_id                    ,
                     X_taxable_flag                   ,
                     X_enforce_ship_to_location       ,
                     X_receiving_routing_id           ,
                     X_inspection_required_flag       ,
                     --X_receipt_required_flag        ,
                     X_receipt_required_flag_tmp      ,
                     X_qty_rcv_tol                    ,
                     X_qty_rcv_exception_code         ,
                     X_days_early_receipt_allowed     ,
                     X_days_late_receipt_allowed      ,
                     X_allow_substitute_receipts      ,
                     X_receipt_days_exception_code    ,
                     X_invoice_close_tolerance_tmp    ,
                     X_receive_close_tolerance_tmp    ,
                     X_item_status                    ,
                     X_outside_operation_flag         ,
                     X_destination_type_code          ,
                     X_expense_accrual_code           ,
                     X_item_id                        ,
                     NULL                             ,
                     X_accrue_on_receipt_flag         ,
                     X_autocreated_ship               ,
                     X_unit_meas_lookup_code,   -- Added Parameter Bug 731564
                     X_order_type_lookup_code,   -- <Complex Work R12>
                     X_matching_basis,           -- <Complex Work R12>
        -- start of bug# 1548597
                     X_secondary_unit_of_measure_s ,
                     X_secondary_quantity_shipment    ,
                     X_preferred_grade_shipment,
                     p_consigned_from_supplier_flag, --bug 3523348
        -- end of bug# 1548597
                     p_org_id,               -- <R12 MOAC>
                     l_outsourced_assembly --<SHIKYU R12>
                     );

              else

                            X_autocreated_ship  := FALSE;

              end if;

      end if; /* IF ok_to_autocreate_ship flag is Y  */

    end if; /* not 'CONTRACT', 'BLANKET', 'RFQ' and 'QUOTATION' */

 exception

       when others then
            po_message_s.sql_error('insert_line', x_progress, sqlcode);
            raise;
 end insert_line;

END PO_LINES_SV3;

/
