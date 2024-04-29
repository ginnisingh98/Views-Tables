--------------------------------------------------------
--  DDL for Package Body PO_PDOI_DISTRIBUTIONS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_DISTRIBUTIONS_SV3" AS
/* $Header: POXPIDVB.pls 120.2.12010000.6 2012/10/16 06:05:21 jozhong ship $ */

/*================================================================

  PROCEDURE NAME: 	validate_po_dist()

==================================================================*/

/**
* Private Procedure: validate_po_dist
* Requires: none
* Modifies: PO_INTERFACE_ERRORS
* Effects: Validates the given PO distribution information. Writes
*  any validation errors to the PO_INTERFACE_ERRORS table.
* Returns: none
*/
PROCEDURE validate_po_dist(x_interface_header_id in NUMBER,
			x_interface_line_id in NUMBER,
			x_interface_distribution_id in NUMBER,
			x_po_distribution_id IN NUMBER,
			x_charge_account_id IN NUMBER,
			x_destination_organization_id IN NUMBER,
			x_sob_id IN NUMBER,
			x_item_id IN NUMBER,
			x_ship_to_organization_id IN NUMBER,
			x_deliver_to_person_id IN NUMBER,
			x_deliver_to_location_id IN NUMBER,
			x_header_processable_flag in out NOCOPY varchar2,
			x_quantity_ordered IN NUMBER,
			x_distribution_num IN NUMBER,
			x_quantity_delivered IN NUMBER,
			x_quantity_billed IN NUMBER,
			x_quantity_cancelled IN NUMBER,
			x_destination_type_code IN VARCHAR2,
			x_accrue_on_receipt_flag IN VARCHAR2,
                        p_transaction_flow_header_id IN NUMBER, --<Shared Proc FPJ>
			x_destination_subinventory IN VARCHAR2,
			x_wip_entity_id IN NUMBER,
			x_wip_repetitive_schedule_id IN NUMBER,
			x_prevent_encumbrance_flag IN VARCHAR2,
			x_budget_account_id IN NUMBER,
			x_accrual_account_id IN NUMBER,
			x_variance_account_id IN NUMBER,
	-- Bug 2137906 fixed. added ussgl_transaction_code.
			x_ussgl_transaction_code IN VARCHAR2,
			x_gl_date IN DATE,
			x_chart_of_accounts_id IN NUMBER,
			x_project_account_context IN VARCHAR2,
			x_project_id IN NUMBER,
			x_task_id IN NUMBER,
			x_expenditure_type IN VARCHAR2,
			x_expenditure_organization_id IN NUMBER,
                        p_order_type_lookup_code IN VARCHAR2, --<SERVICES FPJ>
                        p_amount IN NUMBER, --<SERVICES FPJ>
                        -- <PO_PJM_VALIDATION FPI START>
                        x_need_by_date IN DATE,
                        x_promised_date IN DATE,
                        x_expenditure_item_date  IN DATE, --Bug 2892199
                        -- <PO_PJM_VALIDATION FPI END>
                        p_ship_to_ou_id IN NUMBER        --< Bug 3265539 >
)
IS

X_progress varchar2(3) := NULL;
x_valid varchar2(1) := NULL;
x_item_status		varchar2(2);
x_enc_flag              varchar2(1);
x_temp_val              BOOLEAN ;
x_msg_name  varchar2(100);  -- bug 14662559
BEGIN

x_progress := '010';
   if x_po_distribution_id is null then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_NO_DIST_ID',
				'PO_DISTRIBUTIONS_INTERFACE',
				'PO_DISTRIBUTION_ID' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '020';

   if x_charge_account_id is null then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_NO_CHG_ACCT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'CHARGE_ACCOUNT_ID' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '030';

   --<SERVICES FPJ START>
   IF (p_order_type_lookup_code IN ('RATE', 'FIXED PRICE')) THEN
      IF (NVL(p_amount, 0) <= 0) THEN
	 PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_MUST_AMT',
               X_Table_name              => 'PO_DISTRIBUTIONS_INTERFACE',
               X_Column_name             => 'AMOUNT',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
      END IF;

      IF (NVL(x_quantity_ordered, 0)  <> 0) THEN
	 PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NO_QTY',
               X_Table_name              => 'PO_DISTRIBUTIONS_INTERFACE',
               X_Column_name             => 'QUANTITY_ORDERED',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
      END IF; --IF (NVL(x_quantity_ordered, 0)  <> 0)

   ELSE --if p_order_type_lookup_code not in ('RATE', 'FIXED PRICE')
   --<SERVICES FPJ END>
      if (x_quantity_ordered <= 0) OR (x_quantity_ordered is null) then
	 po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
                                 --need to create this message
 				'PO_PDOI_INVALID_QTY',
				'PO_DISTRIBUTIONS_INTERFACE',
				'QUANTITY_ORDERED' ,
				 'QUANTITY_ORDERED',null,null,null,null,null,
				 x_QUANTITY_ORDERED,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;

      --<SERVICES FPJ START>
      IF (NVL(p_amount,0) <> 0) THEN
	 PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NO_AMT',
               X_Table_name              => 'PO_DISTRIBUTIONS_INTERFACE',
               X_Column_name             => 'AMOUNT_ORDERED',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
      END IF;
   END IF; --IF (p_order_type_lookup_code IN ('RATE', 'FIXED PRICE')
   --<SERVICES FPJ END>

x_progress := '040';

   if (x_distribution_num is null) then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_NO_DIST_NUM',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DISTRIBUTION_NUM' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '060';

--  Fixed Bug 2681256 draising
--  if (x_quantity_delivered <> 0) OR (x_quantity_delivered is not null) then

         if nvl(x_quantity_delivered,0) <> 0 then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_QTY_DEL',
				'PO_DISTRIBUTIONS_INTERFACE',
				'QUANTITY_DELIVERED' ,
				 'QUANTITY_DELIVERED',null,null,null,null,null,
				 x_QUANTITY_DELIVERED,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '070';

--   if (x_quantity_billed <> 0) OR (x_quantity_billed is not null) then
          if nvl(x_quantity_billed,0) <> 0 then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_QTY_BILL',
				'PO_DISTRIBUTIONS_INTERFACE',
				'QUANTITY_BILLED' ,
				 'QUANTITY_BILLED',null,null,null,null,null,
				 x_QUANTITY_BILLED,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '080';

--   if (x_quantity_cancelled <> 0) OR (x_quantity_cancelled is not null) then

         if nvl(x_quantity_cancelled,0) <> 0 then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_QTY_CANCELLED',
				'PO_DISTRIBUTIONS_INTERFACE',
				'QUANTITY_CANCELLED' ,
				 'QUANTITY_CANCELLED',null,null,null,null,null,
				 x_QUANTITY_CANCELLED,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   end if;

x_progress := '090';

   --< Shared Proc FPJ Start>
   -- The only validation needed for destination org is to ensure it is the same
   -- as the Ship-to org, which has already been validated.
   --
   --< Bug 3022783 Start >
   -- Destination org must be equal to ship-to org.
   IF NVL(x_destination_organization_id, -11) <>
      NVL(x_ship_to_organization_id, -99)
   THEN
       po_interface_errors_sv1.handle_interface_errors(
           'PO_DOCS_OPEN_INTERFACE',
           'FATAL',
           null,
           x_interface_header_id,
           x_interface_line_id,
           'PO_PDOI_INVALID_DEST_ORG',
           'PO_DISTRIBUTIONS_INTERFACE',
           'DESTINATION_ORGANIZATION_ID' ,
           'DESTINATION_ORGANIZATION',null,null,null,null,null,
           x_DESTINATION_ORGANIZATION_ID,null,null,null,null,null,
           x_header_processable_flag, x_interface_distribution_id);
   end if;
   --< Bug 3022783 End >
   --< Shared Proc FPJ End >

x_progress := '100';

   if x_destination_type_code is not null then
      po_items_sv2.get_item_status(x_item_id,
                                         x_ship_to_organization_id,
                                         x_item_status );
      x_valid := validate_destination_type_code(x_destination_type_code, x_item_status,
                   x_accrue_on_receipt_flag, p_transaction_flow_header_id); --<Shared Proc FPJ>
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEST_TYPE',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DESTINATION_TYPE_CODE' ,
				 'DESTINATION_TYPE',null,null,null,null,null,
				 x_DESTINATION_TYPE_CODE,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
       end if;
   end if;

x_progress := '110';

   if x_deliver_to_location_id is not null then
      x_valid := validate_deliver_to_loc_id(x_deliver_to_location_id, x_ship_to_organization_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEL_LOCATION',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DELIVER_TO_LOCATION_ID' ,
				 'DELIVER_TO_LOCATION',null,null,null,null,null,
				 x_DELIVER_TO_LOCATION_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   end if;

x_progress := '115';

   if x_deliver_to_person_id is not null then
      x_valid := validate_deliver_to_person_id(x_deliver_to_person_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEL_PERSON',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DELIVER_TO_PERSON_ID' ,
				 'DELIVER_TO_PERSON',null,null,null,null,null,
				 x_DELIVER_TO_PERSON_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   end if;

x_progress := '120';

   IF (x_item_id is NULL) AND ( x_destination_type_code = 'INVENTORY' )  THEN
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEST_TYPE',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DESTINATION_TYPE_CODE' ,
				 'DESTINATION_TYPE',null,null,null,null,null,
				 x_DESTINATION_TYPE_CODE,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
   END IF;

x_progress := '130';

   if (x_destination_TYPE_CODE = 'INVENTORY') and (x_destination_subinventory is not null) then
      x_valid := validate_dest_subinventory(x_destination_subinventory, x_ship_to_organization_id, x_item_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEST_SUBINV',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DESTINATION_SUBINVENTORY' ,
				 'DESTINATION_SUBINVENTORY',null,null,null,null,null,
				 x_DESTINATION_SUBINVENTORY,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   END IF;

x_progress := '140';

   if (x_destination_type_code in ('SHOP FLOOR','EXPENSE')) and (x_destination_subinventory is not null) then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_DEST_SUBINV',
				'PO_DISTRIBUTIONS_INTERFACE',
				'DESTINATION_SUBINVENTORY' ,
				 'DESTINATION_SUBINVENTORY',null,null,null,null,null,
				 x_DESTINATION_SUBINVENTORY,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);

   end if;

x_progress := '150';

  /* Bug 3083961 x_wip_repetitive_schedule_id can be null. So check only x_wip_entity_id. Fail the
     Distribution if it is null and x_destination_type_code is SHOP FLOOR */

   if (x_destination_type_code = 'SHOP FLOOR') then
     if (x_wip_entity_id is not null) then
      x_valid := validate_wip(x_wip_entity_id, x_destination_organization_id, x_wip_repetitive_schedule_id);
      if x_valid <> 'Y' then
        if x_wip_repetitive_schedule_id is not null then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_WIP_SCHED',
				'PO_DISTRIBUTIONS_INTERFACE',
				'WIP_REPETITIVE_SCHEDULE_ID' ,
				 'WIP_REPETITIVE_SCHEDULE_ID',null,null,null,null,null,
				 x_WIP_REPETITIVE_SCHEDULE_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
         else
            /* Bug 3083961 */
                            po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
                                 null,
                                 x_interface_header_id,
                                 x_interface_line_id,
                                'PO_PDOI_INVALID_WIP_ENTITY',
                                'PO_DISTRIBUTIONS_INTERFACE',
                                'WIP_ENTITY_ID',
                                'WIP_ENTITY',null,null,null,null,null,
                                 x_wip_entity_id,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
         end if;
      end if; /* x_valid */
    else -- x_wip_entity_id is null
     /* Bug 3083961 */
                          po_interface_errors_sv1.handle_interface_errors(
                               'PO_DOCS_OPEN_INTERFACE',
                               'FATAL',
                                null,
                                X_interface_header_id,
                                X_interface_line_id,
                               'PO_PDOI_COLUMN_NOT_NULL',
                               'PO_DISTRIBUTIONS_INTERFACE',
                               'WIP_ENTITY_ID',
                               'COLUMN_NAME',
                                null,null,null,null,null,
                               'WIP_ENTITY_ID',
                                null,null, null,null,null,
                                X_header_processable_flag);
     end if;
   end if;

   x_progress := '160';

   IF x_destination_type_code = 'SHOP FLOOR'  THEN

      if x_Prevent_Encumbrance_Flag = 'N' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INV_PREV_ENCUM_FLAG',
				'PO_DISTRIBUTIONS_INTERFACE',
				'PREVENT_ENCUMBRANCE_FLAG' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   else --other dest
      if x_Prevent_Encumbrance_Flag = 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INV_PREV_ENCUM_FLAG',
				'PO_DISTRIBUTIONS_INTERFACE',
				'PREVENT_ENCUMBRANCE_FLAG' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   END IF;

x_progress := '180';

   if x_charge_account_id is not null then
      x_valid := validate_account(x_charge_account_id, x_gl_date, x_chart_of_accounts_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_CHG_ACCOUNT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'CHARGE_ACCOUNT_ID' ,
				 'CHARGE_ACCOUNT',null,null,null,null,null,
				 x_CHARGE_ACCOUNT_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   end if;

x_progress := '190';

   if x_budget_account_id is not null then
      x_valid := validate_account(x_budget_account_id, x_gl_date, x_chart_of_accounts_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_BUDGET_ACCT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'BUDGET_ACCOUNT_ID' ,
				 'BUDGET_ACCOUNT',null,null,null,null,null,
				 x_BUDGET_ACCOUNT_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);

      end if;

   else

      /* Bug 2098833   */
      /* If budget account is null and encumbrance is on, then it is an error   */

        select nvl(purch_encumbrance_flag,'N')
           into x_enc_flag
           from financials_system_parameters ;

        if (x_enc_flag = 'Y') then

                po_interface_errors_sv1.handle_interface_errors(
                               'PO_DOCS_OPEN_INTERFACE',
                               'FATAL',
                                null,
                                x_interface_header_id,
                                x_interface_line_id,
                                'PO_PDOI_INVALID_BUDGET_ACCT',
                                'PO_DISTRIBUTIONS_INTERFACE',
                                'BUDGET_ACCOUNT_ID' ,
                                'BUDGET_ACCOUNT',null,null,null,null,null,
                                NULL,null,null,null,null,null,
                                x_header_processable_flag, x_interface_distribution_id);
        end if;

   end if;

x_progress := '200';

   if x_variance_account_id is not null then
      x_valid := validate_account(x_variance_account_id, x_gl_date, x_chart_of_accounts_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_VAR_ACCT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'VARIANCE_ACCOUNT_ID' ,
				 'VARIANCE_ACCOUNT',null,null,null,null,null,
				 x_VARIANCE_ACCOUNT_ID,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   end if;

x_progress := '210';

   if x_accrual_account_id is not null then
      x_valid := validate_account(x_accrual_account_id, x_gl_date, x_chart_of_accounts_id);
      if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_ACCRUAL_ACCT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'ACCRUAL_ACCOUNT_ID' ,
				 'ACCRUAL_ACCOUNT',null,null,null,null,null,
				 x_accrual_account_id,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
      end if;
   end if;

x_progress := '220';

    if (x_project_account_context = 'N' or x_project_account_context is null)
	and (x_project_id is not null) and (x_task_id is not null)
	 and (x_expenditure_type is not null)
	and (x_expenditure_organization_id is not null) then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_PROJ_ACCT_CONTEXT',
				'PO_DISTRIBUTIONS_INTERFACE',
				'PROJECT_ACCOUNT_CONTEXT' ,
				 null,null,null,null,null,null,
				 null,null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
    end if;

x_progress := '230';

   if (x_project_account_context = 'Y') then

        -- <PO_PJM_VALIDATION FPI>
        -- Make sure that there is no message on the stack.
        fnd_message.clear;

        validate_project_info
                        (x_destination_type_code,
                         x_project_id,
                         x_task_id,
                         x_expenditure_type,
                         x_expenditure_organization_id,
                         -- <PO_PJM_VALIDATION FPI> added 3 parameters:
                         x_ship_to_organization_id,
                         x_need_by_date,
                         x_promised_date,
                         x_expenditure_item_date,
                         p_ship_to_ou_id,          --< Bug 3265539 >
                         x_deliver_to_person_id,
                         x_valid,
                         x_msg_name
                         );  --<Bug 14662559>
-- Bug 2892199 Added expenditure_item_date
        if x_valid <> 'Y' then
			   po_interface_errors_sv1.handle_interface_errors(
                                'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
				 null,
				 x_interface_header_id,
                                 x_interface_line_id,
--need to create this message
 				'PO_PDOI_INVALID_PROJ_INFO',
				'PO_DISTRIBUTIONS_INTERFACE',
				'PROJECT_ID' ,
	       	      /*null,*/ 'PJM_ERROR_MSG', -- <PO_PJM_VALIDATION FPI>
                                 null,null,null,null,null,
                              -- Pass in the PJM error message, if one exists
		       /*null,*/ NVL(fnd_message.get,''), -- <PO_PJM_VALIDATION FPI>
                                 null,null,null,null,null,
                                 x_header_processable_flag, x_interface_distribution_id);
	end if;
   end if;

  -- Bug 3379488 Start: When there is a transaction flow between POU and ROU
  -- and exists a project information on the distribution for expense
  -- destination, prevent creation of the PO

  x_progress := '235';
  IF (x_destination_type_code = 'EXPENSE')
     AND (p_transaction_flow_header_id IS NOT NULL)
     AND (x_project_id IS NOT NULL) THEN
     PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
        x_interface_type         => 'PO_DOCS_OPEN_INTERFACE',
        x_error_type             => 'FATAL',
        x_batch_id               => null,
        x_interface_header_id    => x_interface_header_id,
        x_interface_line_id      => x_interface_line_id,
        x_error_message_name     => 'PO_CROSS_OU_PA_PROJECT_CHECK',
        x_table_name		 => 'PO_DISTRIBUTIONS_INTERFACE',
	x_column_name		 => 'PROJECT_ID',
	x_tokenname1       	 => NULL,
        x_tokenname2       	 => NULL,
        x_tokenname3       	 => NULL,
        x_tokenname4       	 => NULL,
        x_tokenname5       	 => NULL,
        x_tokenname6       	 => NULL,
        x_tokenvalue1            => NULL,
        x_tokenvalue2            => NULL,
        x_tokenvalue3            => NULL,
        x_tokenvalue4            => NULL,
        x_tokenvalue5            => NULL,
        x_tokenvalue6            => NULL,
        x_header_processable_flag=> x_header_processable_flag,
        x_interface_dist_id     => x_interface_distribution_id);
  END IF;

  -- Bug 3379488 End

x_progress := '240';


EXCEPTION
  WHEN others THEN
      po_message_s.sql_error('validate_po_dist', X_progress, sqlcode);
      raise;

END validate_po_dist;

/*================================================================

  FUNCTION NAME: 	validate_destination_type_code()

==================================================================*/

FUNCTION validate_destination_type_code(
  x_destination_type_code    IN  varchar2,
  x_item_status in varchar2,
  x_accrue_on_receipt_flag   IN      varchar2,
  p_transaction_flow_header_id IN NUMBER --<Shared Proc FPJ>
) RETURN VARCHAR2 IS

  x_valid_flag           VARCHAR2(2);
  x_expense_accrual_code po_system_parameters.expense_accrual_code%TYPE;
  x_progress             VARCHAR(4) := NULL;

BEGIN

  x_progress := '001';

  SELECT expense_accrual_code
  INTO   x_expense_accrual_code
  FROM   po_system_parameters;

  -- Business Rules
  -- item status
  -- 'O'  =  outside processing item
  --         - destination type must be SHOP FLOOR
  -- 'E'  =  item stockable in the org
  --         - destination type cannot be SHOP FLOOR
  -- 'D'  =  item defined but not stockable in org
  --         - destination type must be EXPENSE
  -- null =  item not defined in org
  --
  -- accrual on receipt
  -- 'N'     - destination type must be expense
  -- 'Y'     - if expense_accrual = PERIOD END
  --           then destination type code cannot be EXPENSE
  --

  x_progress := '002';

  select distinct 'Y' valid
  into   x_valid_flag
  from   po_lookup_codes
  where  lookup_type = 'DESTINATION TYPE'
  and ( ( nvl( x_item_status,'D') = 'D'
          and lookup_code = 'EXPENSE')
     or ( nvl( x_item_status,'D') = 'E'
          and lookup_code <> 'SHOP FLOOR')
     or ( nvl( x_item_status,'D') = 'O'
          and lookup_code = 'SHOP FLOOR') )
  and ( ( nvl( x_accrue_on_receipt_flag,'Y') = 'N'
          and lookup_code = 'EXPENSE')
      OR  p_transaction_flow_header_id is NOT NULL --<Shared Proc FPJ>
      or (nvl( x_accrue_on_receipt_flag,'Y') = 'Y'
          and (( x_expense_accrual_code = 'PERIOD END'
             and lookup_code <> 'EXPENSE')
          or  x_expense_accrual_code <> 'PERIOD END')))
  and    lookup_code= x_destination_type_code;

return x_valid_flag;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid_flag := 'N';
	return x_valid_flag;
   WHEN OTHERS THEN
	x_valid_flag := 'N';
	return x_valid_flag;
        po_message_s.sql_error('validate_destination_type_code',X_progress, sqlcode);
        RAISE;

END validate_destination_type_code;

/*================================================================

  FUNCTION NAME: 	validate_deliver_to_person_id()

==================================================================*/

FUNCTION validate_deliver_to_person_id(
  x_deliver_to_person_id     IN NUMBER
) RETURN VARCHAR2 IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN
  x_progress := '001';

  -- validation
  -- R12 CWK: removed where clause based on inactive_date
  --          as it would taken care in the view itself.
  SELECT distinct 'Y'
  INTO   x_valid_flag
  FROM   hr_employees_current_v
  WHERE  employee_id = x_deliver_to_person_id;

return x_valid_flag;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid_flag := 'N';
	return x_valid_flag;
   WHEN OTHERS THEN
	x_valid_flag := 'N';
	return x_valid_flag;
        po_message_s.sql_error('validate_deliver_to_person_id',X_progress, sqlcode);
        RAISE;

END validate_deliver_to_person_id;

/*================================================================

  FUNCTION NAME: 	validate_deliver_to_loc_id()

==================================================================*/

FUNCTION validate_deliver_to_loc_id(
  x_deliver_to_location_id   IN      varchar2,
  x_ship_to_organization_id  IN      NUMBER
) RETURN VARCHAR2 IS

  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  x_progress := '001';
  --Bug# 1942696 togeorge 08/16/2001
  --HR removes hz_locations from hr_locations; added exception
  Begin
  -- validation
  SELECT distinct 'Y'
  INTO   x_valid_flag
  FROM   HR_LOCATIONS
  WHERE  nvl(inventory_organization_id,x_ship_to_organization_id) = x_ship_to_organization_id
  AND    nvl(inactive_date, trunc(sysdate + 1)) > trunc(sysdate)
  AND    location_id = x_deliver_to_location_id;

  return x_valid_flag;
  exception
   WHEN NO_DATA_FOUND then
    SELECT distinct 'Y'
      INTO x_valid_flag
      FROM HZ_LOCATIONS
     WHERE nvl(address_expiration_date, trunc(sysdate + 1)) > trunc(sysdate)
       AND location_id = x_deliver_to_location_id;

    return x_valid_flag;
  end;
  --
EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid_flag := 'N';
	return x_valid_flag;
   WHEN OTHERS THEN
	x_valid_flag := 'N';
	return x_valid_flag;
        po_message_s.sql_error('validate_deliver_to_loc_id',X_progress, sqlcode);
        RAISE;

END validate_deliver_to_loc_id;

/*================================================================

  FUNCTION NAME: 	validate_dest_subinventory()

==================================================================*/

FUNCTION validate_dest_subinventory(
  x_destination_subinventory IN      varchar2,
  x_ship_to_organization_id  IN      NUMBER,
  x_item_id                  IN      NUMBER
) RETURN VARCHAR2 IS

  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  x_progress := '001';

  -- validation
  select  distinct 'Y'
  into    x_valid_flag
  from    mtl_secondary_inventories msub
  where   msub.organization_id = nvl(x_ship_to_organization_id, msub.organization_id)
  and     nvl(msub.disable_date, trunc(sysdate+1)) > trunc(sysdate)
  and     (x_item_id is null
           or
          (x_item_id is not null
           and exists (select null
                       from   mtl_system_items msi
                       where  msi.organization_id = nvl(x_ship_to_organization_id, msi.organization_id)
                       and msi.inventory_item_id = x_item_id
                       and (msi.restrict_subinventories_code = 2
                       or (msi.restrict_subinventories_code = 1
                           and exists (select null
                                       from mtl_item_sub_inventories mis
                                       where mis.organization_id = nvl(x_ship_to_organization_id , mis.organization_id)
                                       and mis.inventory_item_id = msi.inventory_item_id
                                       and mis.secondary_inventory = msub.secondary_inventory_name))))))
  and msub.secondary_inventory_name =  x_destination_subinventory;

return x_valid_flag;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid_flag := 'N';
	return x_valid_flag;
   WHEN OTHERS THEN
	x_valid_flag := 'N';
	return x_valid_flag;
        po_message_s.sql_error('validate_dest_subinventory',X_progress, sqlcode);
        RAISE;

END validate_dest_subinventory;

/*================================================================

  FUNCTION NAME: 	validate_org()

==================================================================*/

FUNCTION validate_org(x_org_id in NUMBER, x_sob_id in NUMBER)
RETURN VARCHAR2 IS

  x_valid  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

x_progress := '001';

SELECT distinct 'Y' INTO x_valid
FROM org_organization_definitions ood
WHERE x_org_id = ood.organization_id
AND ood.set_of_books_id = x_sob_id;

return x_valid;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid := 'N';
	return x_valid;
   WHEN OTHERS THEN
	x_valid := 'N';
	return x_valid;
        po_message_s.sql_error('validate_org',X_progress, sqlcode);
        RAISE;

END validate_org;

/*================================================================

  FUNCTION NAME: 	validate_wip()

==================================================================*/

FUNCTION validate_wip(x_wip_entity_id in NUMBER, x_destination_organization_id in NUMBER, x_wip_repetitive_schedule_id in NUMBER) RETURN VARCHAR2 IS

  x_valid   VARCHAR2(2);
  x_valid1  VARCHAR2(2);
  x_valid2  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

x_progress := '001';

      /* If the destination_type_code = 'SHOP FLOOR', then if                */
      /* WIP_REPETITIVE_SCHEDULE_ID is not null then the record must be a    */
      /* repetitive_schedule. If WIP_REPETITIVE_SCHEDULE_ID is NULL, then it */
      /* must be a discrete job                                              */
     -- Bug 3083961. If x_wip_repetitive_schedule_id is not null check in wip_repetitive_schedules.
     -- else check in wip_discrete_jobs

     if x_wip_repetitive_schedule_id is not null then
       begin
                    SELECT distinct 'Y' into x_valid
                      FROM wip_repetitive_schedules wrs
                     WHERE wrs.organization_id=x_destination_organization_id
                       AND wrs.wip_entity_id = x_wip_entity_id
                       AND wrs.repetitive_schedule_id =
                                             x_wip_repetitive_schedule_id
                       AND wrs.status_type IN (3,4,6)
	               AND x_wip_repetitive_schedule_id is not null;
       exception
        WHEN NO_DATA_FOUND then
           x_valid := 'N';
           return x_valid;
       end;
    else
      begin
                    SELECT distinct 'Y' into x_valid
                      FROM wip_discrete_jobs wdj
                     WHERE wdj.organization_id=x_destination_organization_id
                       AND wdj.wip_entity_id = x_wip_entity_id
                       AND wdj.status_type IN (3,4,6)
                       AND x_wip_repetitive_schedule_id is NULL;
       exception
        WHEN NO_DATA_FOUND then
           x_valid := 'N';
           return x_valid;
       end;
    end if;

    return x_valid;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid := 'N';
	return x_valid;
   WHEN OTHERS THEN
	x_valid := 'N';
	return x_valid;
        po_message_s.sql_error('validate_wip',X_progress, sqlcode);
        RAISE;

END validate_wip;

/*================================================================

  FUNCTION NAME: 	validate_account()

==================================================================*/

FUNCTION validate_account(x_account_id in NUMBER, x_gl_date in date, x_chart_of_accounts_id in NUMBER) RETURN VARCHAR2 IS

  x_valid  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

x_progress := '001';

SELECT distinct 'Y' into x_valid
                      FROM  gl_code_combinations gcc
                     WHERE  gcc.code_combination_id = x_account_id
                       AND  gcc.enabled_flag = 'Y'
		       AND  trunc(nvl(x_gl_date,SYSDATE)) BETWEEN
			      	trunc(nvl(start_date_active,
                                            nvl(x_gl_date,SYSDATE) ))
                                AND
				trunc(nvl (end_date_active,
                                            nvl(x_gl_date,SYSDATE) ))
		       AND gcc.detail_posting_allowed_flag = 'Y'
                       AND gcc.chart_of_accounts_id=
                                      x_chart_of_accounts_id
		       AND gcc.summary_flag = 'N';

return x_valid;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid := 'N';
	return x_valid;
   WHEN OTHERS THEN
	x_valid := 'N';
	return x_valid;
        po_message_s.sql_error('validate_account',X_progress, sqlcode);
        RAISE;

END validate_account;

/*================================================================

  PROCEDURE NAME: 	validate_project_info()

==================================================================*/

/**
* Private PROCEDURE: validate_project_info
* Requires: none
* Modifies: concurrent program log
* Effects: Calls the PJM validation API with the given project, task,
*  etc. Writes validation warnings to the concurrent program log.
* Returns:
*  'N' if validation failed. This distribution becomes invalid.
*  'Y' if the validation result is success or warning. Processing should
*   continue on this distribution.
* bug 14662559: Change this function to procedure to get the specific
*   message name for different project info validation error.
*/
PROCEDURE validate_project_info
(
    x_destination_type_code IN VARCHAR2,
    x_project_id IN NUMBER,
    x_task_id IN NUMBER,
    x_expenditure_type IN VARCHAR2,
    x_expenditure_organization_id IN NUMBER ,
    -- <PO_PJM_VALIDATION FPI START>
    x_ship_to_organization_id IN NUMBER,
    x_need_by_date IN DATE,
    x_promised_date IN DATE,
    x_expenditure_item_date IN DATE,  -- Bug 2892199
    -- <PO_PJM_VALIDATION FPI END>
    p_ship_to_ou_id IN NUMBER,        --< Bug 3265539 >
    p_deliver_to_person_id IN NUMBER,  --<Bug 3793395>
    x_valid                OUT NOCOPY VARCHAR2,  --<Bug 14662559>
    x_msg_name             OUT NOCOPY VARCHAR2   --<Bug 14662559>
)  IS

--  x_valid  VARCHAR2(2);  --<Bug 14662559>
  x_valid1  VARCHAR2(2);
  x_valid2  VARCHAR2(2);
  x_valid3  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

-- <PO_PJM_VALIDATION FPI START>
l_val_proj_result     VARCHAR(1);
l_val_proj_error_code VARCHAR2(80);
-- <PO_PJM_VALIDATION FPI END>

--<Bug 3793395 mbhargav START>
x_msg_application varchar2(30);
x_msg_type varchar2(1);
x_msg_token1 varchar2(30);
x_msg_token2 varchar2(30);
x_msg_token3 varchar2(30);
x_msg_count number;
x_msg_data varchar2(30);
x_billable_flag varchar2(1);
--<Bug 3793395 mbhargav END>

BEGIN

x_progress := '001';

/* Bug: 1786105  For all the following three validation select, the table/views:
                           mtl_projects_v
                           pa_expenditure_types
                           per_organization_units
needs to be replaced with
                           pa_projects_expend_v
                           pa_expenditure_types_expend_v
                           pa_organizations_expend_v
or else the projects validation would fail.
*/
/* Bug 2892199 Added expenditure item date validation */
IF x_destination_type_code = 'EXPENSE' then
--bug 14662559: set 3 different message name for these 3 validation.
  	begin
                    SELECT 'Y' into x_valid1
                      FROM pa_projects_expend_v pap,
                           pa_tasks_expend_v pat
                     WHERE pap.project_id = x_project_id
                       AND pap.project_id = pat.project_id
                       AND pat.task_id = x_task_id
                       AND pat.chargeable_flag = 'Y'
                       AND x_expenditure_item_date BETWEEN
                           nvl(pap.start_date,x_expenditure_item_date)
                       AND nvl(pap.completion_date,x_expenditure_item_date)
                       AND x_expenditure_item_date BETWEEN
                           nvl(pat.start_date,x_expenditure_item_date)
                       AND nvl(pat.completion_date,x_expenditure_item_date) ;
	exception
   		when no_data_found then
      		 x_valid1 := 'N';
	end;

	begin
          SELECT 'Y' into x_valid2
		      FROM pa_expenditure_types_expend_v pet
                     WHERE pet.expenditure_type = x_expenditure_type
		       AND pet.system_linkage_function = 'VI';
	exception
   		when no_data_found then
      		 x_valid2 := 'N';
	end;

	begin
		    SELECT 'Y' into x_valid3
		      FROM pa_organizations_expend_v pou
           	     WHERE pou.organization_id=x_expenditure_organization_id;
	exception
   		when no_data_found then
      		 x_valid3 := 'N';
	end;

   if x_valid1 = 'Y' and x_valid2 = 'Y' and x_valid3 = 'Y' then
      --<Bug 3793395 mbhargav START>
      --Call the PA API to validate project related information
      pa_transactions_pub.validate_transaction( X_project_id => x_project_id
		, X_task_id => x_task_id
		, X_ei_date => x_expenditure_item_date
		, X_expenditure_type => x_expenditure_type
		, X_non_labor_resource => ''
		, X_person_id => p_deliver_to_person_id
		, X_quantity => ''
		, X_denom_currency_code => ''
		, X_acct_currency_code => ''
		, X_denom_raw_cost => ''
		, X_acct_raw_cost => ''
		, X_acct_rate_type => ''
		, X_acct_rate_date => ''
		, X_acct_exchange_rate => ''
		, X_transfer_ei => ''
		, X_incurred_by_org_id => x_expenditure_organization_id
		, X_nl_resource_org_id => ''
		, X_transaction_source => ''
		, X_calling_module => 'POXPOEPO'
		, X_vendor_id => ''
		, X_entered_by_user_id => ''
		, X_attribute_category => ''
		, X_attribute1 => ''
		, X_attribute2 => ''
		, X_attribute3 => ''
		, X_attribute4 => ''
		, X_attribute5 => ''
		, X_attribute6 => ''
		, X_attribute7 => ''
		, X_attribute8 => ''
		, X_attribute9 => ''
		, X_attribute10 => ''
		, X_attribute11 => ''
		, X_attribute12 => ''
		, X_attribute13 => ''
		, X_attribute14 => ''
		, X_attribute15 => ''
		, X_msg_application => X_msg_application
		, X_msg_type => X_msg_type
		, X_msg_token1 => X_msg_token1
		, X_msg_token2 => X_msg_token2
		, X_msg_token3 => X_msg_token3
		, X_msg_count => X_msg_count
		, X_msg_data =>  X_msg_data
		, X_billable_flag => X_billable_flag);

       x_msg_name := x_msg_data;  --<Bug 14662559>

      IF x_msg_type = 'E' and x_msg_data is not NULL THEN
        --Project related info causes error. Stop processing
        FND_FILE.put_line(FND_FILE.LOG, x_msg_data);
        x_valid := 'N';
      ELSIF x_msg_type = 'W' and x_msg_data is not NULL THEN
        /* Write the warning to the concurrent program log and then */
        /* set x_valid to 'Y' to allow processing to continue.*/
        FND_FILE.put_line(FND_FILE.LOG, x_msg_data);
        x_valid := 'Y';
      ELSE
        x_valid := 'Y';
      END IF;
      --<Bug 3793395 mbhargav END>

   else
      x_valid := 'N';
      --bug 14662559: set 3 different message name for these 3 validation.
      if x_valid2 = 'N' then
      x_msg_name := 'PO_PDOI_INVALID_EXPEND_TYPE';
      elsif x_valid3 = 'N' then
      x_msg_name := 'PO_PDOI_INVALID_EXPEND_ORG';
      elsif x_valid1 = 'N' then
      x_msg_name := 'PA_EXP_TASK_EFF';
      end if;

   end if;
else
-- <PO_PJM_VALIDATION FPI START>
    --< Bug 3265539 Start >
    -- Call PO wrapper procedure to validate the PJM project
    PO_PROJECT_DETAILS_SV.validate_proj_references_wpr
        (p_inventory_org_id => x_ship_to_organization_id,
         p_operating_unit   => p_ship_to_ou_id,
         p_project_id       => x_project_id,
         p_task_id          => x_task_id,
         p_date1            => x_need_by_date,
         p_date2            => x_promised_date,
         p_calling_function => 'PDOI',
         x_error_code       => l_val_proj_error_code,
         x_return_code      => l_val_proj_result);

   IF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_failure) THEN
      x_valid1 := 'N';
   ELSIF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_warning) THEN
      /* Write the warning to the concurrent program log and then */
      /* set x_valid to 'Y' to allow processing to continue.*/
      FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.get);
      x_valid1 := 'Y';
   ELSE /* Success */
      x_valid1 := 'Y';
   END IF;
   --< Bug 3265539 End >
-- <PO_PJM_VALIDATION FPI END>
   IF x_destination_type_code = 'INVENTORY' then

		/* bug 9412338 The expenditure_type was being validated with
		respect to the pa_expenditure_types, However it should be validated
		with respect to  pa_expend_typ_sys_links.Because of this the project
		validations were failing.Added the table pa_expend_typ_sys_links to the
		from clause ,join condition in the where clause.System_linkage_function
		should be validated with the value in pa_expend_typ_sys_links table.*/

                SELECT 'Y' into x_valid2
		FROM sys.dual
		WHERE x_expenditure_type IS NULL
		OR EXISTS ( SELECT 'Valid Expenditure Type'
			    FROM pa_expenditure_types pet, pa_expend_typ_sys_links sl --bug 9412338
			    WHERE pet.expenditure_type = x_expenditure_type
			    AND pet.expenditure_type = sl.expenditure_type --bug 9412338
			    AND sl.system_linkage_function = 'VI' --bug 9412338
			  );


/* Bug # 1609762
  When the Destination Type is INVENTORY then the expenditure Org can
  be NULL.  */

		    SELECT 'Y' into x_valid3
                    FROM   sys.dual
                    WHERE  x_expenditure_organization_id IS NULL
                           OR EXISTS( SELECT 'Valid Expenditure Org'
		                        FROM per_organization_units pou
                                       WHERE pou.organization_id=
                                             x_expenditure_organization_id
                                    );

     if x_valid1 = 'Y' and x_valid2 = 'Y' and x_valid3 = 'Y' then
        x_valid := 'Y';
     else
        x_valid := 'N';
     end if;
  end if;
end if;

-- return x_valid;

EXCEPTION
   WHEN NO_DATA_FOUND then
        x_valid := 'N';
--	return x_valid;
   WHEN OTHERS THEN
	x_valid := 'N';
--	return x_valid;
        po_message_s.sql_error('validate_project_info',X_progress, sqlcode);
        RAISE;

end validate_project_info;

END PO_PDOI_DISTRIBUTIONS_SV3;

/
