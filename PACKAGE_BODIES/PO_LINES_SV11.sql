--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV11" as
/* $Header: POXPOL6B.pls 120.8.12010000.14 2014/03/24 05:18:25 linlilin ship $ */

 /*===========================================================================

  PROCEDURE NAME:	update_line()

  Preetam B.(OPM-GML)	21-feb-2000 Bug# 1056597 added 5 columns to update line.
  Preetam B.(OPM-GML)   21-nov-2003 Bug# 3274039 derive sec qty for shipment.

 ===========================================================================*/


  PROCEDURE update_line(X_Rowid                          VARCHAR2,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_From_Line_Location_Id          NUMBER,   -- <SERVICES FPJ>
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
                       X_unapprove_doc           IN OUT NOCOPY BOOLEAN,
                       X_authorization_status    IN OUT NOCOPY VARCHAR2,
                       X_approved_flag           IN OUT NOCOPY VARCHAR2,
                       --< NBD TZ/Timestamp FPJ Start >
                       --X_combined_param          IN     VARCHAR2,
                       -- The following 5 parameters were being combined
                       -- into one due to the historic reasons. That is not
                       -- required now.
                       p_ship_window_open IN VARCHAR2,
                       p_type_lookup_code IN VARCHAR2,
                       p_change_date      IN VARCHAR2,
                       p_promised_date    IN DATE,
                       p_need_by_date     IN DATE,
                       --< NBD TZ/Timestamp FPJ End >
                       p_shipment_block_status   IN VARCHAR2, -- bug 4042434
                       X_orig_unit_price         IN     NUMBER,
                       X_orig_quantity           IN     NUMBER,
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
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
                       X_Base_Uom                           VARCHAR2,
                       X_Base_Qty                           NUMBER,
                       X_Secondary_Uom                      VARCHAR2,
                       X_Secondary_Qty                      NUMBER,
                       X_Qc_Grade                           VARCHAR2,
		       --togeorge 10/03/2000
		       --added oke columns
		       X_oke_contract_header_id   	    NUMBER default null,
		       X_oke_contract_version_id   	    NUMBER default null,
-- 1548597.. added 3 fields for process item..
                       X_Secondary_Unit_of_measure       VARCHAR2 default null,
                       X_Secondary_Quantity              NUMBER default null,
                       X_preferred_Grade                 VARCHAR2 default null,
                       p_contract_id                   IN NUMBER DEFAULT NULL,  -- <GC FPJ>
                       X_job_id                         NUMBER   default null, -- <SERVICES FPJ>
                       X_contractor_first_name          VARCHAR2 default null, -- <SERVICES FPJ>
                       X_contractor_last_name           VARCHAR2 default null, -- <SERVICES FPJ>
                       X_assignment_start_date          DATE     default null, -- <SERVICES FPJ>
                       X_amount_db                      NUMBER   default null,  -- <SERVICES FPJ>
                       -- <FPJ Advanced Price START>
                       X_Base_Unit_Price                NUMBER DEFAULT NULL,
                       -- <FPJ Advanced Price END>
                       p_manual_price_change_flag       VARCHAR2 DEFAULT NULL, --<Manual Price Override FPJ>
                       p_planned_item_flag		VARCHAR2 DEFAULT NULL --bug 5533267
) IS

     X_progress VARCHAR2(3) := NULL;

     X_num_of_shipments        number;
     X_num_of_distributions    number;

     --< NBD TZ/Timestamp FPJ Start >
     --X_type_lookup_code        varchar2(25);
     --X_ship_window_open        varchar2(1);
     --X_change_date             varchar2(1);
     --X_promised_date           date;
     --X_need_by_date            date;
     --X_promised_date_char      varchar2(30);
     --X_need_by_date_char       varchar2(30);
     --< NBD TZ/Timestamp FPJ End >

     X_days_late_receipt_allowed   number;


     -- PB Bug# 3274039
     l_opm_item_id                  number := NULL;
     l_item_um2                     varchar2(4) := NULL;
     l_dualum_ind                   number := NULL;
     l_opm_order_um                 varchar2(4) := NULL;
     X_ship_org_id                  NUMBER := NULL;
     X_secondary_quantity_ship      NUMBER := NULL;
     X_secondary_quantity_ship_new  NUMBER := NULL;

     l_orig_amount                  po_lines_all.amount%TYPE;   -- Bug 3262883
     l_line_type                    po_lines_all.order_type_lookup_code%TYPE; -- Bug 3262883
     l_purchase_basis               po_lines_all.purchase_basis%TYPE; -- Bug 3262883
     l_ip_category_id               PO_LINES_ALL.ip_category_id%TYPE; -- Bug 7577670


     --OPM bug3455686
     CURSOR opm_fetch_quantity IS
     SELECT line_location_id,
            quantity,
            ship_to_organization_id
       FROM po_line_locations
      WHERE po_line_id  = X_po_line_id
        AND nvl(cancel_flag,'N') = 'N'
        AND unit_meas_lookup_code <> X_unit_meas_lookup_code
        AND shipment_type in ('STANDARD','PLANNED')
        AND secondary_unit_of_measure is NOT NULL;

     l_shipment_quantity      number;
     l_shipment_sec_quantity  number;
     l_line_location_id       number;
     -- End bug3455686


     l_orig_category_id      number;      --Bug 13067295

     l_orig_uom              varchar2(25); --bug 16626254
     l_count                 number; --bug 16626254

   BEGIN

        X_progress := '010';

--Bug 13067295, added one more variable to retrieve the category_id from the db.
--Bug 13536036, retrieving the ip_category_id from the po_lines_all tbale for that line_id.
--In case if the po_category_id gets updated then we will over ride l_ip_Category_id value later.

  select order_type_lookup_code,purchase_basis,amount,category_id, ip_category_id
       into l_line_type,l_purchase_basis ,l_orig_amount,l_orig_category_id,l_ip_category_id
       from po_lines_all
       where po_line_id = X_po_line_id;

   if ( (p_type_lookup_code = 'STANDARD') OR
        (p_type_lookup_code = 'PLANNED' ) OR
        (p_type_lookup_code = 'BLANKET' ))  then

        /* Check if the document has to be unapproved */

        if (X_Approved_Flag = 'Y') THEN

            /* ER- 1260356 - Added expiration_date so that any change to expiration_date
   at the Line Level of the blanket can also be archived  */

            -- <GC FPJ>
            -- Pass in contract_id and remove contract_num

            X_unapprove_doc := po_lines_sv.val_approval_status(
                                X_po_line_id			,
	                        p_type_lookup_code		,
	                        X_unit_price			,
	                        X_line_num			,
	                        X_item_id			,
	                        X_item_description		,
	                        X_quantity			,
	                        X_unit_meas_lookup_code	        ,
	                        X_from_header_id		,
	                        X_from_line_id			,
	                        X_hazard_class_id		,
	                        X_vendor_product_num		,
	                        X_un_number_id			,
	                        X_note_to_vendor		,
	                        X_item_revision		        ,
	                        X_category_id			,
	                        X_price_type_lookup_code	,
	                        X_not_to_exceed_price		,
	                        X_quantity_committed		,
	                        X_committed_amount	,
                                X_Expiration_Date ,
                                p_contract_id,                -- <GC FPJ>
                                X_contractor_first_name,  -- <SERVICES FPJ>
                                X_contractor_last_name,   -- <SERVICES FPJ>
                                X_assignment_start_date,  -- <SERVICES FPJ>
                                X_amount_db               -- <SERVICES FPJ>
                              );

          /* If the document has to be unapproved, set the approved_flag to be 'R' */
           if X_unapprove_doc then
              -- No changes and no need to change the header's approval status

              X_Approved_Flag := 'X';
           else
              -- Found changes and need to change the header's approval status

 	      X_Approved_Flag := 'Z';
           end if;

       else
          X_Approved_Flag := 'U';

       end if; /* end of testing x_approved_flag */


       if ( (p_type_lookup_code = 'STANDARD') OR
            (p_type_lookup_code = 'PLANNED' ) ) then

       /* If the Unit Price on the line has changed, update every shipment of SHIPMENT/PLANNED
       ** shipment type and that is not cancelled,  with this price.
       ** DEBUG : Move this to POXPOSHB.pls
       */

       if X_orig_unit_price <> X_unit_price then

          X_progress := '030';
	/* Bug 1916593, Commenting the Cancel Flag condition, so that the
	  canceled shipments can also be updated. Pl. refer the bug for further
 	  info */

          UPDATE po_line_locations
          SET    price_override   = X_unit_price,
		 calculate_tax_flag = 'Y',
                 approved_flag    = decode(approved_flag, NULL, 'N', 'N','N','R'),
                 last_update_date = sysdate,
    	         last_updated_by    = X_last_updated_by,
                 last_update_login  = X_last_update_login
          WHERE  po_line_id           = X_po_line_id
          AND    shipment_type in ('STANDARD','PLANNED') ;


          -- set document status to be requires reapproval
          if X_approved_flag IN ( 'Y', 'X') then
             X_approved_flag := 'Z';
          end if;

       end if;

      --OPM bug3455686
      -- For OPM, If the primary unit of measure has changed on the line/shipment, recompute the
      -- secondary quantity for the shipments.
      OPEN  opm_fetch_quantity;
      LOOP
       Begin
        FETCH opm_fetch_quantity into l_line_location_id, l_shipment_quantity, x_ship_org_id;
        EXIT WHEN opm_fetch_quantity%NOTFOUND;
          --Get opm attributes to derive secondary quantity
          --We derive the OPM attributes only once since they will
          --be the same for the item across orgs.
          IF (l_opm_item_id is NULL) THEN
           BEGIN
            SELECT  oi.item_id , oi.item_um2, oi.dualum_ind
              INTO  l_opm_item_id, l_item_um2, l_dualum_ind
              FROM  ic_item_mst oi,
                    mtl_system_items ai
             WHERE  ai.organization_id      = x_ship_org_id
               AND  ai.inventory_item_id    = x_item_id
               AND  ai.segment1             = oi.item_no;

            EXCEPTION WHEN OTHERS THEN
              l_dualum_ind := 0;
              l_shipment_sec_quantity := NULL;
            END;
          END IF;

       IF nvl(l_dualum_ind,0) <> 0 THEN
          --Get corresponding opm uom code
          l_opm_order_um := PO_GML_DB_COMMON.get_opm_uom_code(X_Unit_Meas_Lookup_Code);

          PO_GML_DB_COMMON.validate_quantity( l_opm_item_id,
                                              l_dualum_ind,
                                              l_shipment_quantity,
                                              l_opm_order_um,
                                              l_item_um2,
                                              l_shipment_sec_quantity);

          /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

          UPDATE po_line_locations
          SET    secondary_quantity = l_shipment_sec_quantity,
                 last_update_date   = X_last_update_date,
                 last_updated_by    = X_last_updated_by,
                 last_update_login  = X_last_update_login
          WHERE  po_line_id         = X_po_line_id
            AND  line_location_id   = l_line_location_id;

        END IF;
       EXCEPTION WHEN OTHERS THEN
        IF (opm_fetch_quantity%FOUND) THEN
          CLOSE opm_fetch_quantity;
        END IF;
       END;
      END LOOP;
      CLOSE opm_fetch_quantity;
      -- End bug3455686



       -- Bug 731564
       -- Update all shipments if Unit has changed too.

      /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

       UPDATE po_line_locations
       SET    unit_meas_lookup_code = X_unit_meas_lookup_code,
              last_update_date = sysdate,
	      last_updated_by    = X_last_updated_by,
              last_update_login  = X_last_update_login
       WHERE  po_line_id           = X_po_line_id
       AND    nvl(cancel_flag,'N') = 'N'
       AND    unit_meas_lookup_code <> X_unit_meas_lookup_code
       AND    shipment_type in ('STANDARD','PLANNED') ;


        /* If there is only one shipment for this location, and the quantity is changed,
        ** update the shipment. SImilarly, if there is only one distribution, we need to
        ** update that too.
        ** DEBUG Move this to the appropriate packages ( POXPOSHB for shipments ..)
        */
       -- Bug 3262883

       ---Bug 13067295, Moved the below query to the begining of this procedure.

      /* select order_type_lookup_code,purchase_basis,amount
       into l_line_type,l_purchase_basis ,l_orig_amount
       from po_lines_all
       where po_line_id = X_po_line_id;*/

       if ((X_orig_quantity <> X_quantity ) or (l_orig_amount <> X_amount_db))
       then

-- bug 5856760 For a single shipment and distribution, if the status of shipment is
-- finally closed we shld not update the shipment and distribution. For this the
-- status is checked in the below sql, so that updation not occur for finally closed shipment.
          X_progress := '040';
          SELECT count(pll.po_line_id)
          INTO   X_num_of_shipments
          FROM   po_line_locations pll
          WHERE  pll.po_line_id = X_po_line_id
          AND    pll.shipment_type IN ('STANDARD','PLANNED') --Bug 17983165
          AND NOT EXISTS (SELECT 'there are encumbered or cancelled or drop shipments'
                          FROM   po_line_locations pll2
                          WHERE  pll2.po_line_id = X_po_line_id
                          AND    pll2.shipment_type IN ('STANDARD','PLANNED')
                          AND    ( nvl(pll2.encumbered_flag, 'N') <> 'N'
                                   OR  nvl(pll2.cancel_flag,'N')  <> 'N'
				   OR  nvl(pll2.closed_code,'OPEN') = 'FINALLY CLOSED' --bug 5856760
                                   OR  nvl(pll2.drop_ship_flag,'N')  <> 'N') --bug 3359011
                          );

          if X_num_of_shipments = 1 then

             X_progress := '050';

             -- PB Bug# 3274039
             --In case where the financial option purchasing org is discrete
             --then the line secondary quantity will be null. But if the shipment has a
             --process org the sec qty will be present. Updating the shipment with the
             --sec qty(which is null) from the line will nullify it. Hence recomupte it before updating.
             IF X_item_id is NOT NULL AND X_Secondary_Quantity IS NULL THEN

                SELECT secondary_quantity,
                       ship_to_organization_id
                INTO   X_secondary_quantity_ship,
                       X_ship_org_id
                FROM   po_line_locations pll
                WHERE  pll.po_line_id = X_po_line_id
                AND    pll.shipment_type IN ('STANDARD','PLANNED')
                AND    nvl(pll.cancel_flag,'N')  <> 'Y';

                IF X_secondary_quantity_ship IS NOT NULL THEN

                   BEGIN
                      --Get opm attributes to derive secondary quantity.
                      SELECT  oi.item_id , oi.item_um2, oi.dualum_ind
                      INTO    l_opm_item_id, l_item_um2, l_dualum_ind
                      FROM    ic_item_mst oi,
                              mtl_system_items ai
                      WHERE   ai.organization_id      = X_ship_org_id
                      AND     ai.inventory_item_id    = X_item_id
                      AND     ai.segment1             = oi.item_no;

                      EXCEPTION WHEN OTHERS THEN
                         l_dualum_ind := 0;
                         X_secondary_quantity_ship_new := NULL;
                   END;

                   IF nvl(l_dualum_ind,0) <> 0 THEN
                      --Get corresponding opm uom code
                      l_opm_order_um := PO_GML_DB_COMMON.get_opm_uom_code(X_Unit_Meas_Lookup_Code);


                      PO_GML_DB_COMMON.validate_quantity(     l_opm_item_id,
                                                              l_dualum_ind,
                                                              X_Quantity,
                                                              l_opm_order_um,
                                                              l_item_um2,
                                                              X_secondary_quantity_ship_new);
                   END IF;
                END IF;
             ELSIF X_item_id is NOT NULL AND X_Secondary_Quantity IS NOT NULL THEN
                X_secondary_quantity_ship_new := X_Secondary_Quantity;
             END IF; -- IF X_item_id is NOT null
             -- End PB Bug# 3274039

            /* Bug - 1101939 - Need to update the calculate_tax_flag to 'Y' so
            that the tax is recalculated when the shipment quantity is changed
            automatically    */

            IF l_line_type in ('RATE','FIXED PRICE') THEN  -- Bug 3262883

            -- bug 4042434: Add check for p_shipment_block_status.  In
            -- prior versions, this update would erroneously occur if
            -- the line amount was changed before the contents of
            -- the shipment block were analyzed when saving a PO line.

             IF ((p_ship_window_open = 'N') and (p_shipment_block_status <> 'C')) or
                ((p_ship_window_open = 'Y') and (l_purchase_basis = 'TEMP LABOR')) THEN

           /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

                 UPDATE po_line_locations
                 SET    amount = X_amount_db,
                        calculate_tax_flag = 'Y',
                        last_update_date = sysdate,
			last_updated_by    = X_last_updated_by,
                        last_update_login  = X_last_update_login,
                        approved_flag    = decode(approved_flag, NULL, 'N', 'N','N', 'R'),
                        -- Bug 5227695. Recalculate tax if tax attributes on
                        -- shipment are being updated
                        tax_attribute_update_code = nvl(tax_attribute_update_code, 'UPDATE')
                 WHERE  po_line_id            = X_po_line_id
                 AND    nvl(cancel_flag,'N') <> 'Y'
                 AND    shipment_type = 'STANDARD';

             END IF;

            ELSE

             -- bug 4042434: Add check for p_shipment_block_status.  In
             -- prior versions, this update would erroneously occur if
             -- the line quantity was changed before the contents of
             -- the shipment block were analyzed when saving a PO line.

             IF ((p_ship_window_open = 'N') and (p_shipment_block_status <> 'C')) THEN

           /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

              UPDATE po_line_locations
              SET    quantity         = X_quantity,
               -- start of 1548597 --PB Bug# 3274039 changed the variable to X_secondary_quantity_ship_new
                    secondary_quantity = decode(secondary_quantity,null,null,X_secondary_quantity_ship_new),
              -- end of 1548597
                    calculate_tax_flag = 'Y',
                    last_update_date = sysdate,
       	            last_updated_by    = X_last_updated_by,
                    last_update_login  = X_last_update_login,
                    approved_flag    = decode(approved_flag, NULL, 'N', 'N','N', 'R'),
                    -- Bug 5227695. Recalculate tax if tax attributes on
                    -- shipment are being updated
                    tax_attribute_update_code = nvl(tax_attribute_update_code, 'UPDATE')
             WHERE  po_line_id            = X_po_line_id
             AND    nvl(cancel_flag,'N') <> 'Y'
             AND    shipment_type IN ('STANDARD','PLANNED');

           END IF;

           END IF;

             -- set document status to be requires reapproval
             if X_approved_flag IN ('Y','X') then
                X_approved_flag := 'Z';
             end if;

             X_progress := '060';

             SELECT count(po_distribution_id)
             INTO   X_num_of_distributions
             FROM   po_distributions pd
             WHERE  pd.po_line_id = X_po_line_id
             AND pd.distribution_type in ('STANDARD','PLANNED') --Bug 17983165
             AND NOT EXISTS (SELECT 'there are encumbered distributions'
                             FROM   po_distributions pd2
                             WHERE  pd2.po_line_id = X_po_line_id
                             AND    nvl(pd2.encumbered_flag, 'N') <> 'N');


             if X_num_of_distributions = 1 AND  (p_ship_window_open = 'N') then
                                         -- Bug 6321268. Added the condition p_ship_window_open = 'N'.
                X_progress := '070';
                IF l_line_type in ('RATE','FIXED PRICE') THEN  -- Bug 3262883

          /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

                  UPDATE po_distributions
                  SET    amount_ordered = X_amount_db,
                         last_update_date = sysdate,
       	                 last_updated_by    = X_last_updated_by,
                         last_update_login  = X_last_update_login
                  WHERE  po_line_id = X_po_line_id;

                ELSE

         /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

                  UPDATE po_distributions
                  SET    quantity_ordered = X_quantity,
                         last_update_date = sysdate,
   		         last_updated_by    = X_last_updated_by,
                         last_update_login  = X_last_update_login
                  WHERE  po_line_id = X_po_line_id;

                END IF;
             end if;

          end if;

        end if; /* Quantity/amount Changed */

        if (p_change_date = 'Y') and (p_ship_window_open = 'N') then

          X_progress := '080';

          SELECT count(pll.po_line_id), max(days_late_receipt_allowed)
          INTO   X_num_of_shipments,
                 X_days_late_receipt_allowed
          FROM   po_line_locations pll
          WHERE  pll.po_line_id = X_po_line_id
          AND    nvl(pll.cancel_flag,'N') <> 'Y'
          AND    pll.shipment_type IN ('STANDARD','PLANNED');


          if X_num_of_shipments = 1 then

             X_progress := '090';
--START Bug 5533266
       /*This is to enforce the user to enter either a promise by date or need by date before updating the record.
       The previous related bugs had the fix at the W-V-R for the PO_LINES block and the same are reverted as a part of this fix */

		  IF p_type_lookup_code IN ('STANDARD',
					    'PLANNED') THEN
		    IF p_planned_item_flag = 'Y'
		       AND p_promised_date IS NULL
		       AND p_need_by_date IS NULL  THEN
		      po_message_s.app_error('PO_PO_PLANNED_ITEM_DATE_REQ');
		    END IF;
		  END IF;
--END Bug 5533266

        /*Bug4906693 who columns like last_updated_by and last_update_login
           also needs to be updated.*/

             UPDATE po_line_locations
             SET    promised_date    = p_promised_date,
                    need_by_date     = p_need_by_date,
                    last_accept_date = decode(p_promised_date,NULL,NULL,
                                              p_promised_date+nvl(X_days_late_receipt_allowed,0)),
                    last_update_date = sysdate,
	            last_updated_by    = X_last_updated_by,
                    last_update_login  = X_last_update_login,
                    approved_flag    = decode(approved_flag, NULL, 'N', 'N','N', 'R'),
                    -- Bug 5227695. Recalculate tax if tax attributes on
                    -- shipment are being updated
                    -- bug#16685178: set tax_attribute_update_code to
                    -- UPDATE only if need_by_date was changed by user
                    --tax_attribute_update_code = nvl(tax_attribute_update_code, 'UPDATE')
                    tax_attribute_update_code =
                              DECODE ( TRUNC (NVL(need_by_date,
                                                  to_date('1901/01/01', 'YYYY/MM/DD')) ),
                                        TRUNC(NVL(p_need_by_date,
                                                  to_date('1901/01/01', 'YYYY/MM/DD')) ),
                                       tax_attribute_update_code,
                                       'UPDATE'
                                     )
             WHERE  po_line_id            = X_po_line_id
             AND    nvl(cancel_flag,'N') <> 'Y'
             AND    shipment_type IN ('STANDARD','PLANNED');

             -- set document status to be requires reapproval
             if X_approved_flag IN ('Y','X') then
                X_approved_flag := 'Z';
             end if;

           end if;

         end if;     /* Change Promised and need by dates at shipment level */


       end if; /* End of If Standard/Planned     */

       --Bug 16626254 begin
       IF p_type_lookup_code = 'BLANKET' And
	  X_Unit_Meas_Lookup_Code IS NOT NULL AND
          X_Unit_Price <> 0 THEN

	  SELECT pol.unit_meas_lookup_code
	  INTO l_orig_uom
	  FROM PO_LINES pol
	  WHERE pol.PO_LINE_ID = X_po_line_id;

          SELECT count(*)
          INTO l_count
          FROM po_line_locations_all poll
          WHERE poll.PO_LINE_ID = X_po_line_id;

	  IF l_orig_uom <> X_unit_meas_lookup_code and
             l_count > 0 THEN
	     UPDATE po_line_locations
	     SET unit_meas_lookup_code  = X_unit_meas_lookup_code,
		 last_update_date         = sysdate,
	         last_updated_by          = X_last_updated_by,
		 last_update_login        = X_last_update_login
	     WHERE po_line_id           = X_po_line_id
	     AND   NVL(cancel_flag,'N')   = 'N'
	     AND   unit_meas_lookup_code <> X_unit_meas_lookup_code
	     AND   shipment_type          = 'PRICE BREAK';
	   END IF;
	END IF;
	--end of bug 16626254
 end if; /* End of If Standard/Planned/Blanket */

---13067295, Added the if condition to check whether the category_id has changed or not.
---We will retrive the ip_category_id only when the po_category_id is changed.

         if l_orig_category_id <> x_category_id then
      -- Bug 7577670: Derive ip_category_id from po_category_id
      PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id(p_po_category_id => x_category_id,
                                                 x_ip_category_id => l_ip_category_id);
         end if;

      /* Update the PO LINE itself */

       po_lines_pkg_sud.update_row(
                       X_Rowid                          ,
                       X_Po_Line_Id                     ,
                       X_Last_Update_Date               ,
                       X_Last_Updated_By                ,
                       X_Po_Header_Id                   ,
                       X_Line_Type_Id                   ,
                       X_Line_Num                       ,
                       X_Last_Update_Login              ,
                       X_Item_Id                        ,
                       X_Item_Revision                  ,
                       X_Category_Id                    ,
                       X_Item_Description               ,
                       X_Unit_Meas_Lookup_Code          ,
                       X_Quantity_Committed             ,
                       X_Committed_Amount               ,
                       X_Allow_Price_Override_Flag      ,
                       X_Not_To_Exceed_Price            ,
                       X_List_Price_Per_Unit            ,
                       -- <FPJ Advanced Price START>
                       -- Bug 3417479
                       X_Base_Unit_Price,
                       -- <FPJ Advanced Price END>
                       X_Unit_Price                     ,
                       X_Quantity                       ,
                       X_Un_Number_Id                   ,
                       X_Hazard_Class_Id                ,
                       X_Note_To_Vendor                 ,
                       X_From_Header_Id                 ,
                       X_From_Line_Id                   ,
                       X_From_Line_Location_Id          ,     -- <SERVICES FPJ>
                       X_Min_Order_Quantity             ,
                       X_Max_Order_Quantity             ,
                       X_Qty_Rcv_Tolerance              ,
                       X_Over_Tolerance_Error_Flag      ,
                       X_Market_Price                   ,
                       X_Unordered_Flag                 ,
                       X_Closed_Flag                    ,
                       X_User_Hold_Flag                 ,
                       X_Cancel_Flag                    ,
                       X_Cancelled_By                   ,
                       X_Cancel_Date                    ,
                       X_Cancel_Reason                  ,
                       X_Firm_Status_Lookup_Code        ,
                       X_Firm_Date                      ,
                       X_Vendor_Product_Num             ,
                       X_Contract_Num                   ,
                       X_Taxable_Flag                   ,
                       X_Tax_Code_Id                    ,
                       X_Type_1099                      ,
                       X_Capital_Expense_Flag           ,
                       X_Negotiated_By_Preparer_Flag    ,
                       X_Attribute_Category             ,
                       X_Attribute1                     ,
                       X_Attribute2                     ,
                       X_Attribute3                     ,
                       X_Attribute4                     ,
                       X_Attribute5                     ,
                       X_Attribute6                     ,
                       X_Attribute7                     ,
                       X_Attribute8                     ,
                       X_Attribute9                     ,
                       X_Attribute10                    ,
                       X_Reference_Num                  ,
                       X_Attribute11                    ,
                       X_Attribute12                    ,
                       X_Attribute13                    ,
                       X_Attribute14                    ,
                       X_Attribute15                    ,
                       X_Min_Release_Amount             ,
                       X_Price_Type_Lookup_Code         ,
                       X_Closed_Code                    ,
                       X_Price_Break_Lookup_Code        ,
                       NULL                             , --<R12 SLA>
                       X_Government_Context             ,
                       X_Closed_Date                    ,
                       X_Closed_Reason                  ,
                       X_Closed_By                      ,
                       X_Transaction_Reason_Code        ,
	               X_Global_Attribute_Category	,
        	       X_Global_Attribute1		,
        	       X_Global_Attribute2		,
	               X_Global_Attribute3		,
	               X_Global_Attribute4		,
	               X_Global_Attribute5		,
	               X_Global_Attribute6		,
	               X_Global_Attribute7		,
	               X_Global_Attribute8		,
	               X_Global_Attribute9		,
	               X_Global_Attribute10		,
	               X_Global_Attribute11		,
	               X_Global_Attribute12		,
	               X_Global_Attribute13		,
	               X_Global_Attribute14		,
	               X_Global_Attribute15		,
	               X_Global_Attribute16		,
	               X_Global_Attribute17		,
	               X_Global_Attribute18		,
	               X_Global_Attribute19		,
	               X_Global_Attribute20             ,
                       X_Expiration_Date,
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
		       X_Base_Uom		,
		       X_Base_Qty		,
		       X_Secondary_Uom		,
		       X_Secondary_Qty		,
		       X_Qc_Grade		,
		       --togeorge 10/03/2000
		       --added oke columns
		       X_oke_contract_header_id ,
		       X_oke_contract_version_id,
-- start of 1548597.add 3 process fields..
                       X_secondary_unit_of_measure,
                       X_secondary_quantity,
                       X_preferred_grade,
-- end of 1548597
                       p_contract_id,               -- <GC FPJ>
                       X_job_id,                    -- <SERVICES FPJ>
                       X_contractor_first_name,     -- <SERVICES FPJ>
                       X_contractor_last_name,      -- <SERVICES FPJ>
                       X_assignment_start_date,     -- <SERVICES FPJ>
                       X_amount_db,                  -- <SERVICES FPJ>
                       p_manual_price_change_flag,   -- <Manual Price Override FPJ>
                       l_ip_category_id             -- Bug 7577670
		       );

	   -- Bug 18381792. Remove if added by bug 9845602, fix 9845602 by handle NO_DATA_FOUND in PO_ATTRIBUTE_VALUES_PVT.pls
       -- <Bug 7655719>
       -- update po_attribute_values and po_attribute_values_tlp tables also.
       PO_ATTRIBUTE_VALUES_PVT.update_attributes(
         p_doc_type              => p_type_lookup_code,
         p_po_line_id            => x_po_line_id,
         p_req_template_name     => NULL,
         p_req_template_line_num => NULL,
         p_org_id                => PO_MOAC_UTILS_PVT.get_current_org_id,
         p_ip_category_id        => l_ip_category_id,
         p_item_description      => x_item_description,
         p_language              => userenv('LANG'),
		 p_inventory_item_id     => X_Item_Id -- bug 18381792
       );


  EXCEPTION

       when others then
            po_message_s.sql_error('update_line', x_progress, sqlcode);
            raise;
  END  update_line;

END PO_LINES_SV11;

/
