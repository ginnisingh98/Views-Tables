--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV4" as
/* $Header: POXPOS4B.pls 120.10.12010000.3 2012/05/21 09:19:41 dtoshniw ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_SHIPMENTS_SV4';
/*===========================================================================

  PROCEDURE NAME: delete_all_shipments

===========================================================================*/
   PROCEDURE delete_all_shipments
          (X_delete_id        IN     NUMBER,
           X_entity_level     IN     VARCHAR2,
           X_type_lookup_code IN   VARCHAR2) IS

      X_progress          VARCHAR2(3)  := '';
      x_line_location_id  NUMBER := '';
      x_po_line_id        NUMBER := '';
      x_quantity          NUMBER := '';
      x_original_quantity NUMBER := '';
      x_shipment_type   VARCHAR2(15) :=''; --1560839

    --<R12 eTax Integration Start>
      TYPE l_shipment_type  IS TABLE OF PO_LINE_LOCATIONS_ALL.SHIPMENT_TYPE%TYPE;
      l_shipment_type_tbl         l_shipment_type;
      l_transaction_line_rec_type ZX_API_PUB.transaction_line_rec_type;
      l_return_status             VARCHAR2(1);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);
      l_po_header_id_tbl          PO_TBL_NUMBER;
      l_po_release_id_tbl         PO_TBL_NUMBER;
      l_line_location_id_tbl      PO_TBL_NUMBER;
      l_line_location_org_id_tbl  PO_TBL_NUMBER;
      --<R12 eTax Integration End>

      CURSOR C_LINE is
         SELECT line_location_id
         FROM   po_line_locations_all                      /*Bug6632095: using base table instead of view */
         WHERE  po_line_id = X_delete_id;

      CURSOR C_RELEASE is
         SELECT line_location_id,
    po_line_id,
    quantity
         FROM   po_line_locations_all                      /*Bug6632095: using base table instead of view */
         WHERE  po_release_id = X_delete_id;

      CURSOR C_HEADER is
         SELECT line_location_id
         FROM   po_line_locations_all                      /*Bug6632095: using base table instead of view */
         WHERE  po_header_id = X_delete_id;

      BEGIN

         IF (X_entity_level = 'LINE') THEN

     if (X_type_lookup_code NOT IN ('RFQ', 'QUOTATION')) THEN

                -- delete attachements associated with shipment.
                OPEN C_LINE;

                LOOP

                   FETCH C_LINE INTO x_line_location_id;
                   EXIT WHEN C_LINE%notfound;

                   fnd_attached_documents2_pkg.delete_attachments('PO_SHIPMENTS',
                                      x_line_location_id,
                                      '', '', '', '', 'Y');
                   --<HTML Agreements R12 Start>
                   --Delete the Price differentials entity type for the given Shipment
                    PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff(
                                           p_doc_level => PO_CORE_S.g_doc_level_SHIPMENT
                                          ,p_doc_level_id => x_line_location_id);
                   --<HTML Agreements R12 End>

                END LOOP;

                CLOSE C_LINE;

          -- remove the req lnik
                po_req_lines_sv.remove_req_from_po(X_delete_id,'LINE');

      end if;  /* X_type_lookup_code not in RFQ and QUOTATION */

            X_progress := '010';

      -- Delete the shipments
      BEGIN
               DELETE FROM PO_LINE_LOCATIONS
               WHERE  po_line_id = X_delete_id
         AND    shipment_type in ('PLANNED', 'STANDARD', 'PRICE BREAK',
          'RFQ', 'QUOTATION')
         --<R12 eTax Integration Start>
         RETURNING
         shipment_type,
         po_header_id,
         po_release_id,
         line_location_id,
         org_id
         BULK COLLECT INTO
         l_shipment_type_tbl,
         l_po_header_id_tbl,
         l_po_release_id_tbl,
         l_line_location_id_tbl,
         l_line_location_org_id_tbl
         ;
         --<R12 eTax Integration End>

      EXCEPTION
         WHEN NO_DATA_FOUND then null;
         WHEN OTHERS then raise;

      END;

           -- bug 424099
           -- skip Blanket PO

     if (X_type_lookup_code NOT IN ('BLANKET','RFQ', 'QUOTATION')) THEN

              -- delete the distributions associated with the line.
              po_distributions_sv.delete_distributions(X_delete_id,
                                'LINE');

     end if;  /* X_type_lookup_code not in RFQ and QUOTATION */

   ELSIF (X_entity_level = 'HEADER') THEN

     if (X_type_lookup_code NOT IN ('RFQ', 'QUOTATION')) THEN

        -- Delete the attachments associated with the shipments.
              OPEN C_HEADER;

              LOOP

                FETCH C_HEADER INTO x_line_location_id;
                EXIT WHEN C_HEADER%notfound;

                fnd_attached_documents2_pkg.delete_attachments('PO_SHIPMENTS',
                                     x_line_location_id,
                                     '', '', '', '', 'Y');
	       --<HTML Agreements R12 Start>
               --Delete the Price differentials entity type for the given Shipment
                PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff(
                                       p_doc_level => PO_CORE_S.g_doc_level_SHIPMENT
                                      ,p_doc_level_id => x_line_location_id);
                --<HTML Agreements R12 End>
              END LOOP;

              CLOSE C_HEADER;

        -- Remove the req link
              po_req_lines_sv.remove_req_from_po(X_delete_id,'PURCHASE ORDER');

        X_progress := '020';

     end if;  /* X_type_lookup_code not in RFQ and QUOTATION */

      -- Delete the shipments.
      BEGIN
           DELETE FROM PO_LINE_LOCATIONS_ALL         /*Bug6632095: using base table instead of view */
               WHERE  po_header_id = X_delete_id
         AND    shipment_type in ('PLANNED', 'STANDARD', 'PRICE BREAK',
          'RFQ', 'QUOTATION')
         --<R12 eTax Integration Start>
         RETURNING
         shipment_type,
         po_header_id,
         po_release_id,
         line_location_id,
         org_id
         BULK COLLECT INTO
         l_shipment_type_tbl,
         l_po_header_id_tbl,
         l_po_release_id_tbl,
         l_line_location_id_tbl,
         l_line_location_org_id_tbl
         ;
         --<R12 eTax Integration End>

      EXCEPTION
         WHEN NO_DATA_FOUND then null;
         WHEN OTHERS then raise;
      END;

           -- bug 424099
           -- Skip Blanket PO

     if (X_type_lookup_code NOT IN ('BLANKET', 'RFQ', 'QUOTATION')) THEN

              -- delete the distributions associated with the header
              po_distributions_sv.delete_distributions(X_delete_id,
                                'HEADER');

     end if;  /* X_type_lookup_code not in RFQ and QUOTATION */

   ELSIF (X_entity_level = 'RELEASE') THEN

      -- Delete all the attachements associated with the shipments.
      -- Update the quantity on the blanket line.
            OPEN C_RELEASE;

            LOOP

               FETCH C_RELEASE INTO x_line_location_id,
            x_po_line_id,
            x_original_quantity;
               EXIT WHEN C_RELEASE%notfound;

               fnd_attached_documents2_pkg.delete_attachments('PO_SHIPMENTS',
                                     x_line_location_id,
                                     '', '', '', '', 'Y');

              /* Bug 1560839 - Released quantity should be updated only when
                 the shipment_type is BLANKET */

                SELECT shipment_type
                INTO   x_shipment_type
                FROM   po_line_locations
                WHERE  line_location_id = x_line_location_id;

                IF (X_shipment_type = 'BLANKET' ) then

                    po_lines_sv.update_released_quantity('DELETE',
                                        'BLANKET',
                                        x_po_line_id,
                                        x_original_quantity,
                                        x_quantity);
                END IF;

            END LOOP;

            CLOSE C_RELEASE;

      -- Remove the req link
            po_req_lines_sv.remove_req_from_po(X_delete_id,'RELEASE');

/*Bug no 776261
  When a release is deleted, then the shipments,distributions should also
  be deleted.
  The deletion of distributions is based on the line_location_id
  and prior to the fix we were deleting shipment first and then trying to
  delete the distributions based on the line_location_id which did
  not delete any records and thereby we ended up having orphan
  distribution records.
  Moved the po_distributions_sv_delete_distributions before deletion
  of shipment lines
*/

            -- delete the distributions associated with the release
            po_distributions_sv.delete_distributions(X_delete_id,
                              'RELEASE');

            X_progress := '030';

      -- Delete the shipments.
      BEGIN
           DELETE FROM PO_LINE_LOCATIONS
               WHERE  po_release_id = X_delete_id
         AND    shipment_type in ('SCHEDULED', 'BLANKET')
         --<R12 eTax Integration Start>
         RETURNING
         shipment_type,
         po_header_id,
         po_release_id,
         line_location_id,
         org_id
         BULK COLLECT INTO
         l_shipment_type_tbl,
         l_po_header_id_tbl,
         l_po_release_id_tbl,
         l_line_location_id_tbl,
         l_line_location_org_id_tbl
         ;
         --<R12 eTax Integration End>


      EXCEPTION
         WHEN NO_DATA_FOUND then null;
         WHEN OTHERS then raise;
      END;


   END IF;

   --<eTax Integration R12 Start>
     FOR i in 1..l_shipment_type_tbl.COUNT
     LOOP
       IF l_shipment_type_tbl(i) IN ('STANDARD','PLANNED','BLANKET','SCHEDULED')
       THEN
         l_transaction_line_rec_type.internal_organization_id := l_line_location_org_id_tbl(i);
         l_transaction_line_rec_type.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
        /* Bug 14004400: Applicaton id being passed to EB Tax was responsibility id rather than 201 which
               is pased when the tax lines are created. Same should be passed when they are deleted.  */
         l_transaction_line_rec_type.entity_code              := PO_CONSTANTS_SV.PO_ENTITY_CODE ;
         l_transaction_line_rec_type.event_class_code     := PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
         l_transaction_line_rec_type.event_type_code      := PO_CONSTANTS_SV.PO_ADJUSTED;
        if l_po_release_id_tbl(i) is not null then
              l_transaction_line_rec_type.trx_id  := l_po_release_id_tbl(i);
        else
              l_transaction_line_rec_type.trx_id  := l_po_header_id_tbl(i);
        end if;
         l_transaction_line_rec_type.trx_level_type :='SHIPMENT';
         l_transaction_line_rec_type.trx_line_id   := l_line_location_id_tbl(i);

           ZX_API_PUB.del_tax_line_and_distributions(
               p_api_version             =>  1.0,
               p_init_msg_list           =>  FND_API.G_TRUE,
               p_commit                  =>  FND_API.G_FALSE,
               p_validation_level        =>  FND_API.G_VALID_LEVEL_FULL,
               x_return_status           =>  l_return_status,
               x_msg_count               =>  l_msg_count,
               x_msg_data                =>  l_msg_data,
               p_transaction_line_rec    =>  l_transaction_line_rec_type
           );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

       END IF;
     END LOOP;
   --<eTax Integration R12 End>



EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    --dbms_output.put_line('In UPDATE exception');
    po_message_s.sql_error('update_shipment_price', X_progress, sqlcode);
          raise;
END delete_all_shipments;

/*===========================================================================

  PROCEDURE NAME: delete_shipment

===========================================================================*/
   PROCEDURE delete_shipment
          (X_line_location_id IN NUMBER,
                 X_row_id           IN VARCHAR2,
                       X_doc_header_id    IN NUMBER,
                       X_shipment_type    IN VARCHAR2 ) IS

      X_progress                VARCHAR2(3)  := '';

      BEGIN

         X_progress := '010';


         /*
         ** Call the cover routine to delete children if the
         ** shipment type is NOT 'PRICE BREAK'.
         */
         IF (X_shipment_type IN ('PRICE BREAK', 'RFQ', 'QUOTATION')) then
            null;
            -- Have implemented it like this as this may be used by
            -- RFQs and Quotes.. I am not sure. Can modify this if stmt.
            -- appropriately later.
         ELSE
      po_shipments_sv4.delete_children(X_line_location_id, X_doc_header_id,
                                         X_shipment_type);
         END IF;
              x_progress := '020';

   --<HTML Agreements R12 Start>
   --Delete the Price differentials entity type for the given Line
    PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff(
                           p_doc_level => PO_CORE_S.g_doc_level_SHIPMENT
                          ,p_doc_level_id => x_line_location_id);
   --<HTML Agreements R12 End>

   --dbms_output.put_line('after call to delete children');

         /*
         ** Call the Shipments table handler delete row
   */
   po_line_locations_pkg_s2.delete_row(X_row_id);
   --dbms_output.put_line('after call to delete row');

      EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('delete_shipment', X_progress, sqlcode);
          raise;
      END delete_shipment;

/*===========================================================================

  PROCEDURE NAME: delete_children

===========================================================================*/
   PROCEDURE delete_children
          (X_line_location_id IN NUMBER,
                       X_doc_header_id  IN NUMBER,
                       X_shipment_type  IN VARCHAR2) IS

      X_progress                VARCHAR2(3)  := '';
      x_po_line_id NUMBER := '';
      x_original_quantity NUMBER := '';
      x_quantity NUMBER := '';


      BEGIN

         X_progress := '010';

   --dbms_output.put_line('In call to delete children');

         -- delete the distributions associated with the shipment
         po_distributions_sv.delete_distributions(X_line_location_id,
                              'SHIPMENT');

         -- Remove the req link
         po_req_lines_sv.remove_req_from_po(X_line_location_id,'SHIPMENT');

   -- Update the quantity on the blanket line
         IF (X_shipment_type = 'BLANKET' ) then

      SELECT quantity,
       po_line_id
      INTO   x_original_quantity,
       x_po_line_id
      FROM   po_line_locations
      WHERE  line_location_id = X_line_location_id;

            po_lines_sv.update_released_quantity('DELETE',
                                        'BLANKET',
                                        x_po_line_id,
                                        x_original_quantity,
                                        x_quantity);

         END IF;


   -- Delete attachements.
         fnd_attached_documents2_pkg.delete_attachments('PO_SHIPMENTS',
                                     X_line_location_id,
                                     '', '', '', '', 'Y');

      EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('delete_children', X_progress, sqlcode);
          raise;
      END delete_children;

/*===========================================================================

  PROCEDURE NAME: update_shipment

===========================================================================*/
   PROCEDURE update_shipment
          (X_Rowid                          VARCHAR2,
                       X_Line_Location_Id               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Quantity                       NUMBER,
                       X_Quantity_Received              NUMBER,
                       X_Quantity_Accepted              NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Need_By_Date                   DATE,
                       X_Promised_Date                  DATE,
                       X_Last_Accept_Date               DATE,
                       X_Price_Override                 NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Date                DATE,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
           X_Tax_User_Override_Flag   VARCHAR2,
           X_Calculate_Tax_Flag   VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Lead_Time                      NUMBER,
                       X_Lead_Time_Unit                 VARCHAR2,
                       X_Price_Discount                 NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Approved_Flag       IN OUT NOCOPY     VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Closed_Flag                    VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Inspection_Required_Flag       VARCHAR2,
                       X_Receipt_Required_Flag          VARCHAR2,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Location       VARCHAR2,
                       X_Allow_Substitute_Receipts      VARCHAR2,
                       X_Days_Early_Receipt_Allowed     NUMBER,
                       X_Days_Late_Receipt_Allowed      NUMBER,
                       X_Receipt_Days_Exception_Code    VARCHAR2,
                       X_Invoice_Close_Tolerance        NUMBER,
                       X_Receive_Close_Tolerance        NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
                       X_Shipment_Num                   NUMBER,
                       X_Source_Shipment_Id             NUMBER,
                       X_Shipment_Type                  VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_By                      NUMBER,
                       X_need_to_approve         IN OUT NOCOPY NUMBER,
                       X_increment_revision             BOOLEAN,
                       X_new_rev_num                    NUMBER,
                       X_po_rel_Rowid                  VARCHAR2,
           X_dist_window_open              VARCHAR2,
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
           X_Country_of_Origin_Code       VARCHAR2,
           X_Invoice_Match_Option       VARCHAR2, --bgu, Dec. 7, 98
           --togeorge 10/03/2000
           --added note to receiver
           X_note_to_receiver       VARCHAR2,
-- Mahesh Chandak(GML) Add 7 process related fields.
-- start of Bug# 1548597
                       X_Secondary_Unit_Of_Measure        VARCHAR2,
                       X_Secondary_Quantity               NUMBER,
                       X_Preferred_Grade                  VARCHAR2,
                       X_Secondary_Quantity_Received      NUMBER,
                       X_Secondary_Quantity_Accepted      NUMBER,
                       X_Secondary_Quantity_Rejected      NUMBER,
                       X_Secondary_Quantity_Cancelled     NUMBER,
-- end of Bug# 1548597
                       X_Consigned_Flag                   VARCHAR2,  /* CONSIGNED FPI */
                       X_amount                           NUMBER,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id       NUMBER,  --< Shared Proc FPJ >
                       p_manual_price_change_flag         VARCHAR2 default null  --< Manual Price Override FPJ >
) IS

      X_progress                VARCHAR2(3)  := '';
      X_num_of_distributions    number := 0;
      X_revised_date            varchar2(20);

      X_orig_quantity   number :=0;

      BEGIN

         X_progress := '010';

   -- Check if Shipment should be unapproved.
         IF X_approved_flag = 'Y' THEN

      --  Check if shipment needs to be unapproved.
            /* <TIMEPHASED FPI> */
            /*
               Added parameters X_start_date and X_end_date in the call
               to val_approval_status()
            */
      X_need_to_approve :=
         po_shipments_sv10.val_approval_status(
           X_Line_location_Id,
           X_Shipment_Type,
           X_Quantity,
           X_amount,  -- Bug 5409088
           X_Ship_To_Location_Id,
           X_Promised_Date,
           X_Need_By_Date,
           X_Shipment_Num,
           X_Last_Accept_Date,
           X_Taxable_Flag,
           X_Ship_To_Organization_Id,
           X_Price_Discount,
           X_Price_Override,
           X_Tax_Code_Id,
                       X_start_date,   /* <TIMEPHASED FPI> */
                       X_end_date,     /* <TIMEPHASED FPI> */
                       X_Days_Early_Receipt_Allowed);  -- <INBOUND LOGISTICS FPJ>

           IF (X_need_to_approve = 2) THEN

        -- unapprove the shipment.
              X_approved_flag := 'R';

     END IF;

         END IF;

  /* Bug 482679 ecso 4/28/97
   * Maintain the property that po_lines.quantity = quantity_released
   * even we are not displaying it.
   */
         IF (X_shipment_type = 'BLANKET' ) THEN

      SELECT quantity
      INTO   x_orig_quantity
      FROM   po_line_locations
      WHERE  line_location_id = X_line_location_id;

            po_lines_sv.update_released_quantity('UPDATE',
                                        'BLANKET',
                                        x_po_line_id,
                                        x_orig_quantity,
                                        x_quantity);
         END IF;

         /*
         ** Call the update row routine with all parameters.
         */
   po_line_locations_pkg_s2.update_row(
           X_Rowid,
                       X_Line_Location_Id,
                       X_Last_Update_Date,
                       X_Last_Updated_By,
                       X_Po_Header_Id,
                       X_Po_Line_Id,
                       X_Last_Update_Login,
                       X_Quantity,
                       X_Quantity_Received,
                       X_Quantity_Accepted,
                       X_Quantity_Rejected,
                       X_Quantity_Billed,
                       X_Quantity_Cancelled,
                       X_Unit_Meas_Lookup_Code,
                       X_Po_Release_Id,
                       X_Ship_To_Location_Id,
                       X_Ship_Via_Lookup_Code,
                       X_Need_By_Date,
                       X_Promised_Date,
                       X_Last_Accept_Date,
                       X_Price_Override,
                       X_Encumbered_Flag,
                       X_Encumbered_Date,
                       X_Fob_Lookup_Code,
                       X_Freight_Terms_Lookup_Code,
                       X_Taxable_Flag,
                       X_Tax_Code_Id,
           X_Tax_User_Override_Flag,
           X_Calculate_Tax_Flag,
                       X_From_Header_Id,
                       X_From_Line_Id,
                       X_From_Line_Location_Id,
                       X_Start_Date,
                       X_End_Date,
                       X_Lead_Time,
                       X_Lead_Time_Unit,
                       X_Price_Discount,
                       X_Terms_Id,
                       X_Approved_Flag,
                       X_Approved_Date,
                       X_Closed_Flag,
                       X_Cancel_Flag,
                       X_Cancelled_By,
                       X_Cancel_Date,
                       X_Cancel_Reason,
                       X_Firm_Status_Lookup_Code,
                       X_Attribute_Category,
                       X_Attribute1,
                       X_Attribute2,
                       X_Attribute3,
                       X_Attribute4,
                       X_Attribute5,
                       X_Attribute6,
                       X_Attribute7,
                       X_Attribute8,
                       X_Attribute9,
                       X_Attribute10,
                       X_Attribute11,
                       X_Attribute12,
                       X_Attribute13,
                       X_Attribute14,
                       X_Attribute15,
                       X_Inspection_Required_Flag,
                       X_Receipt_Required_Flag,
                       X_Qty_Rcv_Tolerance,
                       X_Qty_Rcv_Exception_Code,
                       X_Enforce_Ship_To_Location,
                       X_Allow_Substitute_Receipts,
                       X_Days_Early_Receipt_Allowed,
                       X_Days_Late_Receipt_Allowed,
                       X_Receipt_Days_Exception_Code,
                       X_Invoice_Close_Tolerance,
                       X_Receive_Close_Tolerance,
                       X_Ship_To_Organization_Id,
                       X_Shipment_Num,
                       X_Source_Shipment_Id,
                       X_Shipment_Type,
                       X_Closed_Code,
                       NULL, --<R12 SLA>
                       X_Government_Context,
                       X_Receiving_Routing_Id,
                       X_Accrue_On_Receipt_Flag,
                       X_Closed_Reason,
                       X_Closed_Date,
                       X_Closed_By,
                 X_Global_Attribute_Category,
                 X_Global_Attribute1,
                 X_Global_Attribute2,
                 X_Global_Attribute3,
                 X_Global_Attribute4,
                 X_Global_Attribute5,
                 X_Global_Attribute6,
                 X_Global_Attribute7,
                 X_Global_Attribute8,
                 X_Global_Attribute9,
                 X_Global_Attribute10,
                 X_Global_Attribute11,
                 X_Global_Attribute12,
                 X_Global_Attribute13,
                 X_Global_Attribute14,
                 X_Global_Attribute15,
                 X_Global_Attribute16,
                 X_Global_Attribute17,
                 X_Global_Attribute18,
                 X_Global_Attribute19,
                 X_Global_Attribute20,
           X_Country_of_Origin_Code,
           X_Invoice_Match_Option, --bgu, Dec. 7, 98
           --togeorge 10/03/2000
           --added note to receiver
           X_note_to_receiver,
--Start of Bug# 1548597.
                       X_Secondary_Unit_Of_Measure,
                       X_Secondary_Quantity,
                       X_Preferred_Grade,
                       X_Secondary_Quantity_Received,
                       X_Secondary_Quantity_Accepted,
                       X_Secondary_Quantity_Rejected,
                       X_Secondary_Quantity_Cancelled,
-- end of Bug# 1548597
                       X_Consigned_Flag,  /* CONSIGNED FPI */
                       X_amount,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id, --< Shared Proc FPJ >
                       p_manual_price_change_flag  --< Manual Price Override FPJ >
             );

/* bug 8606457 */
   IF X_shipment_type in ('BLANKET', 'SCHEDULED') then

            UPDATE po_distributions
             SET    po_line_id = X_Po_Line_Id
            WHERE  line_location_id = X_line_location_id;

   END IF;
/*bug 8606457*/


     -- Value of 1, means header should be unapproved.
     -- Value of 2, means header and shipment should be unapproved.
     -- Value of 0, means nothing should be unapproved.
     IF (X_need_to_approve > 0  ) THEN

        -- Unapprove the PO or Release Header
              IF X_shipment_type in ('BLANKET', 'SCHEDULED') then

                    X_progress := '030';

--                    UPDATE po_releases
--                    SET   approved_flag        = 'R',
--                          authorization_status = 'REQUIRES REAPPROVAL'
--                    WHERE rowid = X_po_rel_rowid;

              ELSIF  X_shipment_type in ('STANDARD', 'PLANNED', 'PRICE BREAK')
       THEN

                    X_progress := '050';

--                    UPDATE po_headers
--                    SET    approved_flag        = 'R',
--                           authorization_status = 'REQUIRES REAPPROVAL'
--                    WHERE  rowid = X_po_rel_rowid;


              END IF;  /* End of shipment_type */
           END IF; /* End of approve > 0 */

  /*
        ** This distribution processing is not necessary for RFQs
  ** and Quotations or Price Breaks
  ** If the distributions window is open, we will not automatically
        ** update the distributions quantity.  The user must
        ** manually update the quantity.  There are to many issues
        ** with this depending on window coordination.
        ** Only update the distributions quantity if there is one
  ** distriubtion and the distribution is not encumbered.
  */
  IF (X_Shipment_Type not in ('RFQ', 'QUOTATION', 'PRICE BREAK') AND
      X_dist_window_open = 'FALSE') THEN

          BEGIN

          X_Progress := '080';

            SELECT COUNT(po_distribution_id)
            INTO   X_num_of_distributions
            FROM   po_distributions pd
            WHERE  pd.line_location_id = X_line_location_id
            AND NOT EXISTS (SELECT 'there are encumbered distributions'
                 FROM   po_distributions pd2
                 WHERE  pd2.line_location_id =
                        X_line_location_id
                 AND    NVL(pd2.encumbered_flag, 'N') <> 'N') ;

          EXCEPTION
                  when no_data_found then
                       X_num_of_distributions := 0;
                  when others then
                      po_message_s.sql_error('update_shipment', X_progress, sqlcode);
                      raise;
          END;

          IF X_num_of_distributions = 1 THEN

             X_Progress := '090';

             UPDATE po_distributions
             SET    quantity_ordered = X_quantity,
                    last_update_date = X_last_update_date,
                    last_updated_by  = X_last_updated_by
             WHERE  line_location_id = X_line_location_id;

          END IF;
  END IF;  /* X_Shipment_type is not in RFQ or QUOTATION */

/*Bug 782650
  The following update is done for standard po and releases.
  to have the accrue on receipt flag in distributions in sync. with
  shipments accrue on receipt.
*/

/* Bug: 2194604 Added the SCHEDULED also to make aor in sync with dist for release of
planned po
*/

       IF (X_Shipment_Type in ('STANDARD','BLANKET','SCHEDULED')) then
           X_Progress := '091';
           update   po_distributions
           set      accrue_on_receipt_flag = X_accrue_on_receipt_flag
           where    line_location_id       = X_line_location_id;
       END IF;

      EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('update_shipment', X_progress, sqlcode);
          raise;
      END update_shipment;

-----------------------------------------------------------------------------
--Start of Comments
--Name: validate_delete_line_loc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Validates whether the Shipment whose ID has been passed can be deleted
--  or not
--Parameters:
--IN:
--p_line_loc_id
--  Line Location ID for the Po Shipment to be deleted
--p_po_line_id
--  Line ID for the Po line to which the entity being deleted belongs
--p_doc_type
--  Document type of the PO [PO/PA]
--p_style_disp_name
--  Display Name of the document style
--OUT:
--x_message_text
--  Will hold the error message in case the header cannot be deleted
--Notes:
--  Rules for checking whether deletion of shipment is valid or not
--  > Do not allow delete if shipment is approved or already approved once
--  > Do not allow delete if any distributions are reserved.
--  > Do not allow delete if only shipment
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE validate_delete_line_loc(p_line_loc_id     IN NUMBER
                                  ,p_po_line_id      IN NUMBER
                                  ,p_doc_type        IN VARCHAR2
                                  ,p_style_disp_name IN VARCHAR2
                                  ,x_message_text      OUT NOCOPY VARCHAR2) IS
  l_some_dists_reserved_flag VARCHAR2(1) := 'N';
  l_approved_flag            PO_LINE_LOCATIONS_ALL.approved_flag%TYPE := NULL;
  l_shipment_type            PO_LINE_LOCATIONS_ALL.shipment_type%TYPE := NULL;
  l_dummy                    NUMBER := 0;
  d_pos                      NUMBER := 0;
  l_api_name CONSTANT        VARCHAR2(30) := 'validate_delete_line_loc';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_SHIPMENTS_SV4.validate_delete_line_loc';
BEGIN
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_line_loc_id', p_line_loc_id); PO_LOG.proc_begin(d_module,'p_po_line_id', p_po_line_id); PO_LOG.proc_begin(d_module,'p_doc_type', p_doc_type);
      PO_LOG.proc_begin(d_module,'p_style_disp_name', p_style_disp_name);
  END IF;

  SELECT shipment_type,
         approved_flag
  INTO   l_shipment_type,
         l_approved_flag
  FROM   po_line_locations_all
  WHERE  line_location_id = p_line_loc_id;

  d_pos := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_shipment_type',l_shipment_type); PO_LOG.stmt(d_module,d_pos,'l_approved_flag', l_approved_flag);
  END IF;

  -- Do not allow deletion for Approved PO/PA
  IF (l_approved_flag IN ('Y', 'R'))
  THEN
      IF (l_shipment_type = 'PRICE BREAK')
      THEN
          x_message_text := PO_CORE_S.get_translated_text('PO_CANT_DELETE_PB_ON_APRVD_PO');
          RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
      ELSE
          x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_APRVD_PO3'
                                                          ,'DOCUMENT_TYPE'
                                                          , p_style_disp_name);
          RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
      END IF;
  END IF;

  d_pos := 20;
  -- Disallow a delete if any distributions are reserved.
  PO_CORE_S.are_any_dists_reserved(
                   p_doc_type                 => p_doc_type,
                   p_doc_level                => PO_CORE_S.g_doc_level_SHIPMENT,
                   p_doc_level_id             => p_line_loc_id,
                   x_some_dists_reserved_flag => l_some_dists_reserved_flag);

  IF l_some_dists_reserved_flag = 'Y'
  THEN
      x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_ENCUMB_PO');
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;
  d_pos := 30;

 --<Bug#4515762 Start>
 -- If there is only one single viable shipment then we should not allow to
 -- to delete the shipment
  BEGIN
     SELECT line_location_id
     INTO l_dummy
     FROM po_line_locations_all
     WHERE po_line_id = p_po_line_id
     AND nvl(closed_code, PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN) <> PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED
     AND nvl(cancel_flag, 'N') <> 'Y';

     --If we reach here then we have only one valid shipment and shopuld not allow its deletion
     x_message_text := PO_CORE_S.get_translated_text('PO_CANT_DELETE_ONLY_SCHEDULE');
     RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  --<Bug#4515762 End>
  EXCEPTION
   WHEN TOO_MANY_ROWS THEN
     --If there are multiple viable shipments then we can allow the deletion of this shipment
     NULL;
  END ;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN PO_CORE_S.G_EARLY_RETURN_EXC THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_message_text',x_message_text);
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END validate_delete_line_loc;

-----------------------------------------------------------------------------
--Start of Comments
--Name: process_delete_line_loc
--Pre-reqs:
--  Before calling this procedure one must call validate_delete_line_loc
--  to ensure that deletion of the line location is a valid action
--Modifies:
--  PO_LINES_ALL
--  PO_LINE_LOCATIONS_ALL
--Locks:
--  None
--Function:
--  Deletes the selected Line Location from the Database and
--  calls the pricing APIs to calculate the new price if a Standard PO
-- shipment with a source reference is deleted
--Parameters:
--IN:
--p_line_loc_id
--  Line Location ID for the Po Shipment to be deleted
--p_line_loc_row_id
--  Row ID for the Po Shipment record to be deleted
--p_po_line_id
--  Line ID for the Po line to be deleted
--p_po_header_id
--  Header ID of the PO to which the PO line being deleted belongs
--p_doc_subtype
--  Document Sub type of the PO [STANDARD/BLANKET]
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
-- Before calling pricing, we need not make the check whether the line price has
-- not been manually updated. As this API will be invoked when the changes are
-- being done from backend.
--End of Comments
-----------------------------------------------------------------------------

PROCEDURE process_delete_line_loc(p_line_loc_id     IN NUMBER
                                 ,p_line_loc_row_id IN ROWID
                                 ,p_po_header_id    IN NUMBER
                                 ,p_po_line_id      IN NUMBER
                                 ,p_doc_subtype     IN VARCHAR2)
IS

  l_vendor_id              PO_HEADERS_ALL.vendor_id%TYPE;
  l_vendor_site_id         PO_HEADERS_ALL.vendor_site_id%TYPE;
  l_currency_code          PO_HEADERS_ALL.currency_code%TYPE;
  l_org_id                 PO_HEADERS_ALL.org_id%TYPE;
  l_po_lines_rec           PO_LINES_ALL%ROWTYPE;
  l_base_unit_price        PO_LINES_ALL.base_unit_price%TYPE;
  l_from_line_location_id  PO_LINES_ALL.from_line_location_id%TYPE := NULL;
  l_shipment_type          PO_LINE_LOCATIONS_ALL.shipment_type%TYPE := NULL;
  l_ga_entity_type         PO_PRICE_DIFFERENTIALS.entity_type%TYPE := NULL;
  l_ga_entity_id           PO_PRICE_DIFFERENTIALS.entity_id%TYPE := NULL;
  l_is_source_info_changed BOOLEAN := FALSE;
  l_price                  NUMBER := NULL;
  l_min_shipment_num       NUMBER := NULL;
  d_pos                    NUMBER := 0;
  l_api_name CONSTANT      VARCHAR2(30) := 'process_delete_line_loc';
  d_module   CONSTANT      VARCHAR2(70) := 'po.plsql.PO_SHIPMENTS_SV4.process_delete_line_loc';

BEGIN
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_line_loc_id', p_line_loc_id); PO_LOG.proc_begin(d_module,'p_line_loc_row_id', p_line_loc_row_id); PO_LOG.proc_begin(d_module,'p_po_header_id', p_po_header_id);
      PO_LOG.proc_begin(d_module,'p_doc_subtype', p_doc_subtype);
  END IF;

  d_pos := 10;
  --get the required data of shipment's header and line
  SELECT shipment_type
  INTO   l_shipment_type
  FROM   po_line_locations_all
  WHERE  line_location_id = p_line_loc_id;

  d_pos := 20;
  po_shipments_sv4.delete_shipment(p_line_loc_id,
                                   p_line_loc_row_id,
                                   p_po_header_id,
                                   l_shipment_type);

  d_pos := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_shipment_type',l_shipment_type);
  END IF;

  SELECT *
  INTO   l_po_lines_rec
  FROM   po_lines_all
  WHERE  po_line_id = p_po_line_id;

  d_pos := 40;
  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.price_break_lookup_code', l_po_lines_rec.price_break_lookup_code); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.base_unit_price', l_po_lines_rec.base_unit_price);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.category_id', l_po_lines_rec.category_id); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.contract_id', l_po_lines_rec.contract_id);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.creation_date', l_po_lines_rec.creation_date); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.from_header_id', l_po_lines_rec.from_header_id);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.from_line_id', l_po_lines_rec.from_line_id); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.item_id', l_po_lines_rec.item_id);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.item_revision', l_po_lines_rec.item_revision); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.line_type_id', l_po_lines_rec.line_type_id);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.po_header_id', l_po_lines_rec.po_header_id); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.po_line_id', l_po_lines_rec.po_line_id);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.quantity', l_po_lines_rec.quantity); PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.unit_meas_lookup_code', l_po_lines_rec.unit_meas_lookup_code);
      PO_LOG.stmt(d_module, d_pos, 'l_po_lines_rec.vendor_product_num', l_po_lines_rec.vendor_product_num);
  END IF;

  SELECT poh.vendor_id,
         poh.vendor_site_id,
         poh.currency_code
  INTO   l_vendor_id,
         l_vendor_site_id,
         l_currency_code
  FROM   po_headers_all poh
  WHERE  poh.po_header_id = l_po_lines_rec.po_header_id;

  d_pos := 50;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_vendor_id',l_vendor_id); PO_LOG.stmt(d_module,d_pos,'l_vendor_site_id',l_vendor_site_id); PO_LOG.stmt(d_module,d_pos,'l_currency_code',l_currency_code);
  END IF;

  --Deleting price break is a retroactive change. Call the
  -- API to update po_lines.retroactive_date. This needs to be
  --done for updated price breaks.
  d_pos := 60;
  IF (l_po_lines_rec.price_break_lookup_code = 'NON CUMULATIVE' AND
     l_shipment_type = 'PRICE BREAK')
  THEN
      po_lines_sv2.retroactive_change(l_po_lines_rec.po_line_id);
  END IF;

  d_pos := 70;
  -- Call the wrapper function to calculate the price when a shipment
  -- of a Standard PO with a source reference is deleted
  IF (p_doc_subtype = 'STANDARD' AND
     (l_po_lines_rec.from_header_id IS NOT NULL OR
     l_po_lines_rec.contract_id IS NOT NULL))
  THEN

      d_pos := 80;
      --Get the mininum shipment number from the database
      PO_SOURCING2_SV.get_min_shipment_num(l_po_lines_rec.po_line_id,
                                           l_min_shipment_num);

      d_pos := 90;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_pos,'l_min_shipment_num', l_min_shipment_num);
      END IF;
      -- Call the API to obtain the new price based on the 1st shipment of the
      -- standard PO.
      l_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;
      d_pos := 100;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_pos,'l_org_id', l_org_id);
      END IF;

      PO_SOURCING2_SV.get_shipment_price(
              p_po_line_id            => l_po_lines_rec.po_line_id,
              p_from_line_id          => l_po_lines_rec.from_line_id,
              p_min_shipment_num      => l_min_shipment_num,
              p_quantity              => l_po_lines_rec.quantity,
              p_contract_id           => l_po_lines_rec.contract_id,
              p_org_id                => l_org_id,
              p_supplier_id           => l_vendor_id,
              p_supplier_site_id      => l_vendor_site_id,
              p_creation_date         => l_po_lines_rec.creation_date,
              p_order_header_id       => l_po_lines_rec.po_header_id,
              p_order_line_id         => l_po_lines_rec.po_line_id,
              p_line_type_id          => l_po_lines_rec.line_type_id,
              p_item_revision         => l_po_lines_rec.item_revision,
              p_item_id               => l_po_lines_rec.item_id,
              p_category_id           => l_po_lines_rec.category_id,
              p_supplier_item_num     => l_po_lines_rec.vendor_product_num,
              p_in_price              => l_po_lines_rec.base_unit_price,
              p_uom                   => l_po_lines_rec.unit_meas_lookup_code,
              p_currency_code         => l_currency_code,
              x_base_unit_price       => l_base_unit_price,
              x_price                 => l_price,
              x_from_line_location_id => l_from_line_location_id);

              d_pos := 100;
              IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_module, 'l_base_unit_price', l_base_unit_price); PO_LOG.stmt(d_module, 'l_price', l_price); PO_LOG.stmt(d_module, 'l_from_line_location_id', l_from_line_location_id);
              END IF;

      -- Check whether the above call to the Pricing API returned a
      -- price break that is different than what is currently
      -- in the database.
      l_is_source_info_changed := PO_AUTOSOURCE_SV.has_source_changed(
                                                  l_po_lines_rec.po_line_id,
                                                  l_po_lines_rec.from_header_id,
                                                  l_po_lines_rec.from_line_id,
                                                  l_from_line_location_id);
      d_pos := 110;
      --Reinitialise the price values to original values if pricing
      --call returns null
      l_price           := nvl(l_price, l_po_lines_rec.unit_price);
      l_base_unit_price := nvl(l_price, l_po_lines_rec.base_unit_price);
      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, 'l_base_unit_price', l_base_unit_price); PO_LOG.stmt(d_module, 'l_price', l_price);
	  PO_LOG.stmt(d_module, 'boolean coverted to char: l_is_source_info_changed', PO_CORE_S.boolean_to_flag(l_is_source_info_changed));
      END IF;

      d_pos := 120;
      -- Update the line price and from_line_location_id in PO_LINES_ALL
      PO_SOURCING2_SV.update_line_price(
                           p_po_line_id            => l_po_lines_rec.po_line_id,
                           p_price                 => l_price,
                           p_base_unit_price       => l_base_unit_price,
                           p_from_line_location_id => l_from_line_location_id);

      d_pos := 120;
      -- If the price break was changed from the above Pricing API call,
      -- then the Price Differentials need to be redefaulted/cleared.
      IF (l_is_source_info_changed)
      THEN
          IF (l_po_lines_rec.order_type_lookup_code = 'RATE' AND
             p_doc_subtype = 'STANDARD')
          THEN

              IF (l_from_line_location_id IS NOT NULL)
              THEN
                  l_ga_entity_type := 'PRICE BREAK';
                  l_ga_entity_id   := l_from_line_location_id;
              ELSIF (l_po_lines_rec.from_line_id IS NOT NULL)
              THEN
                  l_ga_entity_type := 'BLANKET LINE';
                  l_ga_entity_id   := l_po_lines_rec.from_line_id;
              END IF;
              d_pos := 130;
              IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_module, 'l_ga_entity_type', l_ga_entity_type); PO_LOG.stmt(d_module, 'l_ga_entity_id', l_ga_entity_id);
              END IF;
              PO_PRICE_DIFFERENTIALS_PVT.delete_price_differentials(
                                 p_entity_type => 'PO LINE',
                                 p_entity_id   => l_po_lines_rec.po_line_id);
              d_pos := 140;
              -- Copy Price Differentials from GA to Standard PO
              PO_PRICE_DIFFERENTIALS_PVT.default_price_differentials(
                               p_from_entity_type => l_ga_entity_type,
                               p_from_entity_id   => l_ga_entity_id,
                               p_to_entity_type   => 'PO LINE',
                               p_to_entity_id     => l_po_lines_rec.po_line_id);
          END IF; --l_po_lines_rec.order_type_lookup_code = 'RATE'

      END IF; --l_is_source_info_changed
      d_pos := 140;
      -- For this line, update all its corresponding shipment records
      UPDATE po_line_locations_all
      SET    price_override   = l_price,
             last_update_date = SYSDATE,
             last_updated_by  = fnd_global.user_id
      WHERE  po_line_id = l_po_lines_rec.po_line_id;
  END IF; --l_type_lookup_code = 'STANDARD'

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END process_delete_line_loc;

END  PO_SHIPMENTS_SV4;


/
