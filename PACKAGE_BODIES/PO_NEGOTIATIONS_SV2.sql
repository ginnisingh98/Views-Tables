--------------------------------------------------------
--  DDL for Package Body PO_NEGOTIATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NEGOTIATIONS_SV2" AS
/* $Header: POXNEG3B.pls 120.13.12010000.8 2012/06/29 09:16:57 spapana ship $ */

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

g_cat_TO_SUPPLIER CONSTANT NUMBER := 33;  -- <Complex Work R12>


/********************************************************************
  PROCEDURE NAME: default_po_dist_interface()

  DESCRIPTION:    This API defaults the distribution in
		  po_distributions_interface table. This uses account
		  generator to build the accounts.
  Referenced by:  This is called from po_interface_s.setup_interface_tables.
		  from the file POXBWP1B.pls

  CHANGE History: Created      12-Feb-2002     Toju George
********************************************************************/

PROCEDURE default_po_dist_interface(
			x_interface_header_id 		IN     NUMBER,
			x_interface_line_id 		IN     NUMBER,
			x_item_id 			IN     NUMBER,
			x_category_id 			IN     NUMBER,
			x_ship_to_organization_id 	IN     NUMBER,
			x_ship_to_location_id 		IN     NUMBER,
			x_deliver_to_person_id 		IN     NUMBER,
			x_def_sob_id 			IN     NUMBER,
			x_chart_of_accounts_id 		IN     NUMBER,
			x_line_type_id 			IN     NUMBER,
			x_quantity 			IN     number,
            x_amount                IN     NUMBER,            -- <SERVICES FPJ>
			x_rate 				IN     NUMBER,
			x_rate_date 			IN     DATE,
			x_vendor_id 			IN     NUMBER,
			x_vendor_site_id 		IN     NUMBER,
			x_agent_id 			IN     NUMBER,
			x_po_encumbrance_flag 		IN     VARCHAR2,
			x_ussgl_transaction_code 	IN     VARCHAR2,
			x_type_lookup_code 		IN     VARCHAR2,
			x_expenditure_organization_id 	IN     NUMBER,
			x_project_id 			IN     NUMBER,
			x_task_id 			IN     NUMBER,
			x_bom_resource_id 		IN     NUMBER,
			x_wip_entity_id 		IN     NUMBER,
			x_wip_line_id 			IN     NUMBER,
			x_wip_repetitive_schedule_id 	IN     NUMBER,
			x_gl_encumbered_date 		IN     DATE,
			x_gl_encumbered_period 		IN     VARCHAR2,
			x_destination_subinventory 	IN     VARCHAR2,
			x_expenditure_type 		IN     VARCHAR2,
			x_expenditure_item_date 	IN     DATE,
			x_wip_operation_seq_num 	IN     NUMBER,
			x_wip_resource_seq_num 		IN     NUMBER,
			x_project_accounting_context  	IN     VARCHAR2,
                        p_purchasing_ou_id              IN     NUMBER, --< Shared Proc FPJ >
                        p_unit_price                    IN     NUMBER  --<BUG 3407630>
			) IS

X_progress 	        VARCHAR2(3) := NULL;
x_inventory_organization_id number;
x_receipt_required_flag varchar2(1);
x_item_status		varchar2(2);
x_gl_date		date;
l_ship_to_organization_id NUMBER;
x_expense_accrual_code po_system_parameters.expense_accrual_code%type;
x_destination_type_code varchar2(25);
l_gl_encumbered_date  date;
x_destination_context varchar2(30);
x_accrue_on_receipt_flag varchar2(1);
x_prevent_encumbrance_flag varchar2(1);
l_gl_encumbered_period  varchar2(15);
l_destination_subinventory varchar2(10);
x_inv_install_status varchar2(1);
--variables to default the accounts
x_success     	   BOOLEAN;-- If this is TRUE, it means the
			   --call to build all accounts was successful
x_charge_success   BOOLEAN := TRUE;
x_budget_success   BOOLEAN := TRUE;
x_accrual_success  BOOLEAN := TRUE;
x_variance_success BOOLEAN := TRUE;
x_charge_account_id   number;
x_budget_account_id   number;
x_accrual_account_id  number;
x_variance_account_id number;
x_charge_account_flex	 VARCHAR2(2000);
x_budget_account_flex    VARCHAR2(2000);
x_accrual_account_flex	 VARCHAR2(2000);
x_variance_account_flex  VARCHAR2(2000);
x_charge_account_desc	 VARCHAR2(2000);
x_budget_account_desc    VARCHAR2(2000);
x_accrual_account_desc	 VARCHAR2(2000);
x_variance_account_desc  VARCHAR2(2000);
wf_itemkey	  	VARCHAR2(80) := NULL;
x_new_ccid_generated BOOLEAN := FALSE;
FB_ERROR_MSG 	VARCHAR2(2000);

   x_bom_cost_element_id          NUMBER := NULL;
   x_result_billable_flag varchar2(5) := NULL;
   x_from_type_lookup_code  varchar2(5) := NULL;
   x_from_header_id  NUMBER := NULL;
   x_from_line_id  NUMBER := NULL;
   x_wip_entity_type varchar2(25) := NULL;
   x_end_item_unit_number varchar2(30):=null;

   header_att1  VARCHAR2(150) := NULL; header_att2  VARCHAR2(150) := NULL;
   header_att3  VARCHAR2(150) := NULL; header_att4  VARCHAR2(150) := NULL;
   header_att5  VARCHAR2(150) := NULL; header_att6  VARCHAR2(150) := NULL;
   header_att7  VARCHAR2(150) := NULL; header_att8  VARCHAR2(150) := NULL;
   header_att9  VARCHAR2(150) := NULL; header_att10 VARCHAR2(150) := NULL;
   header_att11 VARCHAR2(150) := NULL; header_att12 VARCHAR2(150) := NULL;
   header_att13 VARCHAR2(150) := NULL; header_att14 VARCHAR2(150) := NULL;
   header_att15 VARCHAR2(150) := NULL;

   line_att1  VARCHAR2(150) := NULL; line_att2  VARCHAR2(150) := NULL;
   line_att3  VARCHAR2(150) := NULL; line_att4  VARCHAR2(150) := NULL;
   line_att5  VARCHAR2(150) := NULL; line_att6  VARCHAR2(150) := NULL;
   line_att7  VARCHAR2(150) := NULL; line_att8  VARCHAR2(150) := NULL;
   line_att9  VARCHAR2(150) := NULL; line_att10 VARCHAR2(150) := NULL;
   line_att11 VARCHAR2(150) := NULL; line_att12 VARCHAR2(150) := NULL;
   line_att13 VARCHAR2(150) := NULL; line_att14 VARCHAR2(150) := NULL;
   line_att15 VARCHAR2(150) := NULL;

   shipment_att1  VARCHAR2(150) := NULL; shipment_att2  VARCHAR2(150) := NULL;
   shipment_att3  VARCHAR2(150) := NULL; shipment_att4  VARCHAR2(150) := NULL;
   shipment_att5  VARCHAR2(150) := NULL; shipment_att6  VARCHAR2(150) := NULL;
   shipment_att7  VARCHAR2(150) := NULL; shipment_att8  VARCHAR2(150) := NULL;
   shipment_att9  VARCHAR2(150) := NULL; shipment_att10 VARCHAR2(150) := NULL;
   shipment_att11 VARCHAR2(150) := NULL; shipment_att12 VARCHAR2(150) := NULL;
   shipment_att13 VARCHAR2(150) := NULL; shipment_att14 VARCHAR2(150) := NULL;
   shipment_att15 VARCHAR2(150) := NULL;

   distribution_att1  VARCHAR2(150) := NULL;
   distribution_att2  VARCHAR2(150) := NULL;
   distribution_att3  VARCHAR2(150) := NULL;
   distribution_att4  VARCHAR2(150) := NULL;
   distribution_att5  VARCHAR2(150) := NULL;
   distribution_att6  VARCHAR2(150) := NULL;
   distribution_att7  VARCHAR2(150) := NULL;
   distribution_att8  VARCHAR2(150) := NULL;
   distribution_att9  VARCHAR2(150) := NULL;
   distribution_att10 VARCHAR2(150) := NULL;
   distribution_att11 VARCHAR2(150) := NULL;
   distribution_att12 VARCHAR2(150) := NULL;
   distribution_att13 VARCHAR2(150) := NULL;
   distribution_att14 VARCHAR2(150) := NULL;
   distribution_att15 VARCHAR2(150) := NULL;

   --< Shared Proc FPJ Start >
   l_transaction_flow_header_id NUMBER;
   l_dest_charge_success        BOOLEAN;
   l_dest_variance_success      BOOLEAN;
   l_dest_charge_account_id     NUMBER;
   l_dest_variance_account_id   NUMBER;
   l_dest_charge_account_desc   VARCHAR2(2000);
   l_dest_variance_account_desc VARCHAR2(2000);
   l_dest_charge_account_flex   VARCHAR2(2000);
   l_dest_variance_account_flex VARCHAR2(2000);
   --< Shared Proc FPJ End >

   l_func_unit_price  PO_LINES_ALL.unit_price%TYPE; -- Bug 3463242
BEGIN

l_ship_to_organization_id :=x_ship_to_organization_id;
l_gl_encumbered_date   := x_gl_encumbered_date;
l_gl_encumbered_period :=x_gl_encumbered_period;
l_destination_subinventory := x_destination_subinventory;


  x_progress := '010';
  /*******************************************************************
   Get master inventory org from fsp.

  *******************************************************************/
   begin
     select fsp.inventory_organization_id
       into x_inventory_organization_id
       from financials_system_parameters fsp;
   exception
     when no_data_found then
     raise;
   end;
  /******************************************************************/


  x_progress := '020';
  /*******************************************************************
   --default the ship_to_organization_id
   --if the interface line level ship_to_organization_id is null get it
   --from the location's organization, if not successful then from fsp.
   --And use this as the destination organization.
  ********************************************************************/
   if l_ship_to_organization_id is null then
      begin
         SELECT inventory_organization_id
	   INTO l_ship_to_organization_id
	   FROM hr_locations_all
	  WHERE location_id = x_ship_to_location_id
	    AND ship_to_site_flag = 'Y';
      x_progress := '021';
         -- Bug 3419480
         IF (l_ship_to_organization_id IS NULL) THEN
  	   --Bug# 2315130
           l_ship_to_organization_id :=x_inventory_organization_id;
	   --
         -- Bug 3419480
         END IF; /*IF (l_ship_to_organization_id IS NULL)*/
      exception
      when no_data_found then
           x_progress := '022';
           l_ship_to_organization_id :=x_inventory_organization_id;
      end;
   end if;
  /*******************************************************************/


  x_progress := '030';
  /*******************************************************************
   Default expense accrual code from psp.
  *******************************************************************/
   SELECT expense_accrual_code
     INTO x_expense_accrual_code
     FROM po_system_parameters;

  /******************************************************************/


  x_progress := '040';
  /*******************************************************************
   Get the item_status.
   item_status values:
    'O' =  osp item item_status
    'E' =  item stockable in the org
    'D' =  item defined but not stockable in org
    null =  item not defined in org
  *******************************************************************/
   if x_item_id is not null then
      po_items_sv2.get_item_status(x_item_id,
                                   l_ship_to_organization_id,
                                   x_item_status );
   end if;
  /******************************************************************/


   x_progress := '050';
  /*******************************************************************
   Determine receipt required flag
   Receipt_required_flag is not accepted as a parameter as it is always
   defaulted from item/destorg,item/invorg, line type, vendor, psp
   in the respective order, overriding the interface value.
   At this point receipt_required_flag we have in interface table is the
   value defaulted from po_line_types in setup_interface_tables procedure.
  *******************************************************************/
    if x_item_id is not null then
       --get from item level for destination org
       begin
        select msi.receipt_required_flag
          into x_receipt_required_flag
          from mtl_system_items msi
         where msi.inventory_item_id = x_item_id
           and msi.organization_id   = l_ship_to_organization_id;
       exception
        when no_data_found then
    	  null;
        when others then
   	  raise;
       end;
       --get from item level for master org
       if x_receipt_required_flag is null then
          begin
           select msi.receipt_required_flag
             into x_receipt_required_flag
             from mtl_system_items msi
            where msi.inventory_item_id = x_item_id
              and msi.organization_id   = x_inventory_organization_id;
          exception
           when no_data_found then
       	     null;
           when others then
   	     po_message_s.sql_error('default_po_dist_interface',x_progress,
   				     sqlcode);
   	     raise;
          end;
       end if;
    end if; --if item_id is not null
    --get from line type level
    if x_receipt_required_flag is null then
       begin
        select plt.receiving_flag
	  into x_receipt_required_flag
	  from po_line_types plt
         where plt.line_type_id=x_line_type_id;
       exception
        when no_data_found then
       	     null;
        when others then
   	     po_message_s.sql_error('default_po_dist_interface',x_progress,
   				     sqlcode);
   	     raise;
       end;
    end if;
    --get from vendor level
    if x_receipt_required_flag is null then
       if x_vendor_id is not null then
           begin
            select pov.receipt_required_flag
    	      into x_receipt_required_flag
    	      from po_vendors pov
             where pov.vendor_id=x_vendor_id;
           exception
            when no_data_found then
           	     null;
            when others then
       	     po_message_s.sql_error('default_po_dist_interface',x_progress,
       				     sqlcode);
       	     raise;
           end;
       end if;
    end if;
    --get from psp
    if x_receipt_required_flag is null then
       begin
        select psp.receiving_flag
	  into x_receipt_required_flag
	  from po_system_parameters psp;
       exception
        when no_data_found then
       	     null;
        when others then
   	     po_message_s.sql_error('default_po_dist_interface',x_progress,
   				     sqlcode);
   	     raise;
       end;
    end if;

  /******************************************************************/


   x_progress := '060';
  /*******************************************************************
   Determine accrue on receipt flag

  *******************************************************************/
      IF x_item_status = 'O' THEN
             X_accrue_on_receipt_flag := 'Y';
      ELSE
         IF X_item_status = 'E' THEN
	    x_inv_install_status := po_core_s.get_product_install_status('INV');
            IF nvl(x_inv_install_status,'N')='I' then
	       --if inventory is installed then
               X_accrue_on_receipt_flag := 'Y';
            ELSE
               IF x_expense_accrual_code = 'RECEIPT' THEN
                  X_accrue_on_receipt_flag := 'Y';
		--		NAME_IN('po_lines.receipt_required_flag');
               ELSIF x_expense_accrual_code = 'PERIOD END' THEN
                  X_accrue_on_receipt_flag := 'N';
               END IF;
            END IF;
         ELSE  -- Item status != 'E'(including null)
            IF x_expense_accrual_code = 'RECEIPT' THEN
               X_accrue_on_receipt_flag :=  x_receipt_required_flag;
            ELSIF x_expense_accrual_code = 'PERIOD END' THEN
               X_accrue_on_receipt_flag := 'N';
            END IF;
         END IF;
      END IF;
  /*******************************************************************/


   x_progress := '070';
  /*******************************************************************
   Default destination_type_code from the item status and
   accrue on receipt flag.
  *******************************************************************/
      if x_destination_type_code is null then
         IF x_item_id is NULL  THEN
            x_destination_type_code := 'EXPENSE';
            x_destination_context := 'EXPENSE';
         ELSE

          if x_item_status = 'O' THEN
             x_destination_type_code := 'SHOP FLOOR';
             x_destination_context := 'SHOP FLOOR';
          elsif (x_item_status= 'E') AND (x_accrue_on_receipt_flag = 'Y') THEN
             x_destination_type_code := 'INVENTORY';
             x_destination_context := 'INVENTORY';
          ELSE
             x_destination_type_code := 'EXPENSE';
             x_destination_context := 'EXPENSE';
             l_destination_subinventory := NULL;
          END IF;
         END IF; /* Item is Null */
      end if; --if dest type is null
  /*******************************************************************/


   x_progress := '080';
  /*******************************************************************
   Default gl_period and encumbrance related info.

  *******************************************************************/
      IF x_destination_type_code = 'SHOP FLOOR'  THEN
         x_Prevent_Encumbrance_Flag := 'Y';
      ELSE
         x_Prevent_Encumbrance_Flag := 'N';
      END IF;
      x_progress := '081';

       IF x_po_encumbrance_flag = 'Y' THEN
         IF l_gl_encumbered_date is NULL THEN
            x_gl_date := sysdate;
	    l_gl_encumbered_date := sysdate;
         ELSE
            x_gl_date := l_gl_encumbered_date;
         END IF;
         po_periods_sv.get_period_name(x_def_sob_id,
                                       x_gl_date,
                                       l_gl_encumbered_period);
         IF l_gl_encumbered_period is NULL THEN
            --po_message_s.sql_error('default_po_dist_interface',x_progress,sqlcode);
	    null;--raise;
         END IF;
       ELSE
           l_gl_encumbered_date := NULL;
           l_gl_encumbered_period := NULL;
       END IF;
  /*******************************************************************/


  x_progress := '090';
  /*******************************************************************
   Call account generator.
  *******************************************************************/
     -- Bug 3463242 START
     -- Need to pass price to PO Account Generator in functional currency.
     l_func_unit_price := p_unit_price * NVL(x_rate, 1);
     -- Bug 3463242 END

     IF (g_po_pdoi_write_to_file = 'Y') THEN
        PO_DEBUG.put_line('before workflow');
        -- Bug 3463242 START
        PO_DEBUG.put_line('rate='||x_rate);
        PO_DEBUG.put_line('unit_price passed to account generator workflow '||
                          'in functional currency='||l_func_unit_price);
        -- Bug 3463242 END
     END IF;
     -- get the account ids
     -- we dont need to call account gen. for a blanket as we dont
     -- need a distribution record. We still insert a  distribution
     -- record into po_distributions_interface for a blanket to
     -- help programming.
     -- Bug 5050208: Removed the item id condition as account generator
     -- also generates accounts for 1 time items
     if x_type_lookup_code <>'BLANKET' and
	(not(x_po_encumbrance_flag = 'Y'
	  and l_gl_encumbered_period is NULL))
	then

        --< Shared Proc FPJ Start >
       -- Make the transaction flow header id null because SPS is not supported
       -- with Sourcing in FPJ.
       l_transaction_flow_header_id := NULL;
       --< Shared Proc FPJ Start >

       x_success := PO_WF_BUILD_ACCOUNT_INIT.Start_Workflow (

          --< Shared Proc FPJ Start >
          -- SPS is not being supported with Sourcing in FPJ. The extra
          -- parameters being added to the Start_Workflow function are just
          -- because of the signature change. These variables would never get
          -- populated by the workflow and will never be used in the Sourcing
          -- process.
          p_purchasing_ou_id,           -- IN
          l_transaction_flow_header_id, -- IN
          l_dest_charge_success,        -- IN OUT
          l_dest_variance_success,      -- IN OUT
          l_dest_charge_account_id,     -- IN OUT
          l_dest_variance_account_id,   -- IN OUT
          l_dest_charge_account_desc,   -- IN OUT
          l_dest_variance_account_desc, -- IN OUT
          l_dest_charge_account_flex,   -- IN OUT
          l_dest_variance_account_flex, -- IN OUT
          --< Shared Proc FPJ End >

		  x_charge_success, 		x_budget_success,
		  x_accrual_success,		x_variance_success,
		  x_charge_account_id,		x_budget_account_id,
		  x_accrual_account_id,		x_variance_account_id,
		  x_charge_account_flex,	x_budget_account_flex,
		  x_accrual_account_flex,	x_variance_account_flex,
		  x_charge_account_desc,	x_budget_account_desc,
		  x_accrual_account_desc,	x_variance_account_desc,
                  x_chart_of_accounts_id,       x_bom_resource_id,
                  x_bom_cost_element_id,        x_category_id,
                  x_destination_type_code,      x_ship_to_location_id,
                  l_ship_to_organization_id,l_destination_subinventory,
                  x_expenditure_type,
                  x_expenditure_organization_id,x_expenditure_item_date,
                  x_item_id ,                   x_line_type_id,
                  x_result_billable_flag,       x_agent_id,
                  x_project_id,                 x_from_type_lookup_code,
                  x_from_header_id,             x_from_line_id,
                  x_task_id,                    x_deliver_to_person_id,
                  x_type_lookup_code,           x_vendor_id,
                  x_wip_entity_id,              x_wip_entity_type,
                  x_wip_line_id,                x_wip_repetitive_schedule_id,
                  x_wip_operation_seq_num,      x_wip_resource_seq_num,
                  x_po_encumbrance_flag,         l_gl_encumbered_date,
                  wf_itemkey,			x_new_ccid_generated,
		  header_att1, header_att2, header_att3, header_att4,
		  header_att5, header_att6, header_att7, header_att8,
		  header_att9, header_att10, header_att11,header_att12,
		  header_att13, header_att14, header_att15,
		  line_att1, line_att2, line_att3, line_att4, line_att5,
		  line_att6, line_att7, line_att8, line_att9, line_att10,
		  line_att11, line_att12, line_att13, line_att14, line_att15,
		  shipment_att1, shipment_att2, shipment_att3, shipment_att4,
		  shipment_att5, shipment_att6, shipment_att7, shipment_att8,
		  shipment_att9, shipment_att10,shipment_att11, shipment_att12,
		  shipment_att13, shipment_att14, shipment_att15,
		  distribution_att1, distribution_att2, distribution_att3,
		  distribution_att4, distribution_att5, distribution_att6,
		  distribution_att7, distribution_att8, distribution_att9,
		  distribution_att10,distribution_att11,distribution_att12,
		  distribution_att13, distribution_att14, distribution_att15,
		  FB_ERROR_MSG,
                  --<BUG 3407630 START>
                  NULL, --x_award_id
                  NULL, --x_vendor_site_id
                  l_func_unit_price -- Bug 3463242
                  --<BUG 3407630 END>
                  );

          --<bug#4101202> We need to clear the cache after the call to
          --account generator because it normally runs in SYNCHRONOUS mode.
          --However the calling program is normally ASYNCHRONOUS as in case
          --of the Sourcing Complete Auction Workflow(PONCOMPL).
          --In such a case if the account generator returns an error it would
          --get propagated to the sourcing workflow and would result in an error.
          --To prevent this we would have to clear the cache.

                 WF_ENGINE_UTIL.CLEARCACHE;
                 WF_ACTIVITY.CLEARCACHE;
                 WF_ITEM_ACTIVITY_STATUS.CLEARCACHE;
                 WF_ITEM.CLEARCACHE;
                 WF_PROCESS_ACTIVITY.CLEARCACHE;

          --<bug#4101202>

     end if;
     --Insert a distribution record into the interface table even if the
     --accounts are not built. We would handle it when we insert the record
     --into po_distributions table. in create_distributions procedure.
	x_progress := '091';
        --budget account is defaulted only if encumbrance is on
	if x_po_encumbrance_flag = 'N' then
	   x_budget_account_id := null;
	end if;
  /*******************************************************************/

  -- Let the tax defaulting and recovery rate calculation happen at
  --the time we create the PO, not at the interface level.


   x_progress := '100';
  /*******************************************************************
   Insert into po_distributions_interface table.
  *******************************************************************/

       INSERT INTO po_distributions_interface
          (interface_header_id,
           interface_line_id,
           interface_distribution_id,
           distribution_num,
           charge_account_id,
           set_of_books_id,
           quantity_ordered,
           amount_ordered,                                    -- <SERVICES FPJ>
           rate,
           rate_date,
           req_distribution_id,
           deliver_to_location_id,
           deliver_to_person_id,
           encumbered_flag,
	   gl_encumbered_date,
           gl_encumbered_period_name,
           destination_type_code,
           destination_organization_id,
           destination_subinventory,
           budget_account_id,
           accrual_account_id,
           variance_account_id,
           wip_entity_id,
           wip_line_id,
           wip_repetitive_schedule_id,
           wip_operation_seq_num,
           wip_resource_seq_num,
           bom_resource_id,
           prevent_encumbrance_flag,
           project_id,
           task_id,
           end_item_unit_number,
           expenditure_type,
           project_accounting_context,
           destination_context,
           expenditure_organization_id,
           expenditure_item_date
	   )
       values(x_interface_header_id,
           x_interface_line_id,
           po_distributions_interface_s.nextval,
           1,  --prd.distribution_num,
           x_charge_account_id, --prd.code_combination_id,
           x_def_sob_id, --prd.set_of_books_id,
           x_quantity,
           x_amount,                                          -- <SERVICES FPJ>
           x_rate,
           x_rate_date,
           null, --prd.distribution_id, no ref to a req.
           x_ship_to_location_id,--x_destination_locatin_id
           x_deliver_to_person_id,
           x_po_encumbrance_flag, --prd.encumbered_flag,
	   l_gl_encumbered_date,
           l_gl_encumbered_period,
           x_destination_type_code,
           l_ship_to_organization_id, --prl.destination_organization_id,
           l_destination_subinventory,
           x_budget_account_id,
           x_accrual_account_id,
           x_variance_account_id,
           x_wip_entity_id,
           x_wip_line_id,
           x_wip_repetitive_schedule_id,
           x_wip_operation_seq_num,
           x_wip_resource_seq_num,
           x_bom_resource_id,
           x_prevent_encumbrance_flag,
           x_project_id,
           x_task_id,
           x_end_item_unit_number,
           x_expenditure_type,
           x_project_accounting_context,
           x_destination_context,
           x_expenditure_organization_id,
           x_expenditure_item_date
	   );
  /*******************************************************************/
   x_progress := '110';


EXCEPTION
  WHEN others THEN
      po_message_s.sql_error('default_po_dist_interface', X_progress, sqlcode);
      raise;
END default_po_dist_interface;


PROCEDURE handle_sourcing_attachments(
			x_auction_header_id   	IN NUMBER,
			x_auction_line_number 	IN NUMBER,
			x_bid_number   IN NUMBER,
			x_bid_line_number   	IN NUMBER,
			x_requisition_header_id IN NUMBER,
			x_requisition_line_id   IN NUMBER,
			x_po_line_id   	    	IN NUMBER,
			x_column1		IN VARCHAR2,
			x_attch_suppress_flag	IN VARCHAR2,
			X_created_by 		IN NUMBER DEFAULT NULL,
			X_last_update_login 	IN NUMBER DEFAULT NULL)
			IS

x_progress	varchar2(4);
BEGIN


IF x_attch_suppress_flag <>'Y' then

--<RENEG BLANKET FPI START>
-- Following code is commented out as the header level attchments are now
-- copied to po_header.
/*
   --copy attachment from negotiation header to the po line
   x_progress	:='001';
   po_negotiations_sv2.
	  copy_attachments('PON_AUCTION_HEADERS_ALL',
			    x_auction_header_id,
				null,
				null,
				null,
				null,
				'PO_LINES',
				x_po_line_id,
				null,
				null,
				null,
				null,
				x_created_by,
				x_last_update_login,
				null,
				null,
				null,
				'NEG');
*/
--<RENEG BLANKET FPI END>

   --copy attachment from negotiation line to the po line
   x_progress	:='002';
   po_negotiations_sv2.
	  copy_attachments('PON_AUCTION_ITEM_PRICES_ALL',
			    x_auction_header_id,
			    x_auction_line_number,
				'',
				'',
				'',
				'PO_LINES',
				x_po_line_id,
				'',
				'',
				'',
				'',
				x_created_by,
				x_last_update_login,
				'',
				'',
				null,
				'NEG');


   --copy attachment from bid header to the po line
   x_progress	:='003';
   po_negotiations_sv2.
	  copy_attachments('PON_BID_HEADERS',
			    x_auction_header_id,
			    x_bid_number,
				'',
				'',
				'',
				'PO_LINES',
				x_po_line_id,
				'',
				'',
				'',
				'',
				x_created_by,
				x_last_update_login,
				'',
				'',
				null,
				'NEG');
   --copy attachment from bid line to the po line
   x_progress	:='004';
   po_negotiations_sv2.
	  copy_attachments('PON_BID_ITEM_PRICES',
			    x_auction_header_id,
			    x_bid_number,
			    x_auction_line_number,
                            -- Bug 3400627, in Sourcing the bid line attachments
                            -- are stored with the first three primary keys
                            -- (auction header id, bid number, auction line number).
				'',
			    -- x_bid_line_number,
				'',
				'PO_LINES',
				x_po_line_id,
				'',
				'',
				'',
				'',
				x_created_by,
				x_last_update_login,
				'',
				'',
				null,
				'NEG');


-- build and attach bid attributes as supplier type attachments on
--po/blanket line.
   x_progress	:='005';
   add_attch_dynamic('PON_BID_ATTRIBUTES' ,
			x_auction_header_id,
			x_auction_line_number,
			x_bid_number,
			x_bid_line_number,
		    	'PO_LINES',
		    	x_po_line_id,
			X_created_by,
			X_last_update_login ,
			null,
			null,
			null);
-- build and attach bid notes as internal to PO attachments on po/blanket line .
   x_progress	:='006';
   add_attch_dynamic('PON_BID_BUYER_NOTES' ,
			x_auction_header_id,
			x_auction_line_number,
			x_bid_number,
			x_bid_line_number,
		    	'PO_LINES',
		    	x_po_line_id,
			X_created_by,
			X_last_update_login ,
			null,
			null,
			null);

-- build and attach negotiation notes as to supplier attachments on
--po/blanket line.
   x_progress	:='007';

--<RENEG BLANKET FPI START>
/* Earlier both header and line level supplier notes were copied onto
   on po/blanket line. Changing this so that only LINE level supplier notes
   are copied over as attachments on po/blanket LINES
*/
   add_attch_dynamic('PON_AUC_SUPPLIER_LINE_NOTES' ,
			x_auction_header_id,
			x_auction_line_number,
			x_bid_number,
			x_bid_line_number,
		    	'PO_LINES',
		    	x_po_line_id,
			X_created_by,
			X_last_update_login ,
			null,
			null,
			null);
--<RENEG BLANKET FPI END>

-- build and attach bid price elements as to supplier attachments on
--po/blanket line.
   x_progress	:='008';
   add_attch_dynamic('PON_BID_TOTAL_COST' ,
			x_auction_header_id,
			x_auction_line_number,
			x_bid_number,
			x_bid_line_number,
		    	'PO_LINES',
		    	x_po_line_id,
			X_created_by,
			X_last_update_login ,
			null,
			null,
			null);

    -- <SERVICES FPJ START> Call to convert Job Long Description from
    -- Negotiations Table to PO Line Attachment.
    --
    add_attch_dynamic
    (   x_from_entity_name       => 'PON_JOB_DETAILS'
    ,   x_auction_header_id      => x_auction_header_id
    ,   x_auction_line_number    => x_auction_line_number
    ,   x_bid_number             => x_bid_number
    ,   x_bid_line_number        => x_bid_line_number
    ,   x_to_entity_name         => 'PO_LINES'
    ,   x_to_pk1_value           => x_po_line_id
    ,   x_created_by             => x_created_by
    ,   x_last_update_login      => x_last_update_login
    ,   x_program_application_id => NULL
    ,   x_program_id             => NULL
    ,   x_request_id             => NULL
    );
    -- <SERVICES FPJ END>

end if;
   --copy attachment from requisition header/line to the po line,
   --when backed by a req.
   If x_column1='NEGREQ' then
   x_progress	:='009';
      po_negotiations_sv2.
	  copy_attachments('REQ_HEADERS',
			    x_requisition_header_id,
				'',
				'',
				'',
				'',
				'PO_LINES',
				x_po_line_id,
				'',
				'',
				'',
				'',
				x_created_by,
				x_last_update_login,
				'',
				'',
				null,
				x_column1);
   x_progress	:='010';
   po_negotiations_sv2.
	  copy_attachments('REQ_LINES',
			    x_requisition_line_id,
				'',
				'',
				'',
				'',
				'PO_LINES',
				x_po_line_id,
				'',
				'',
				'',
				'',
				x_created_by,
				x_last_update_login,
				'',
				'',
				null,
				x_column1);
   end if;
exception
   when others then
       po_message_s.sql_error('handle_sourcing_attachments',x_progress,sqlcode);
       raise;
end handle_sourcing_attachments;


--  API to copy attachments from one record to another
PROCEDURE copy_attachments(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_column1 IN VARCHAR2 DEFAULT NULL) IS

/*
      Bug 5938614 : UNABLE TO CREATE STANDARD PO FROM SOURCING RFQ WHEN MULTIPLE REQUISITIONS USED ,
      This is because when we create a sourcing RFQ that combines 2 req lines from 2 different requisitions
      which are having the one time attachement , and if we publish a negotiation then it is inserting 2 lines
      into fnd_attached_documents with pk1_value as negotiation number,and pk2_value
      as requisition line number.
      Before this fix , At the time of PO Creation ,the one time address is being copied from
      entity type 'PON_AUCTION_ITEM_PRICES_ALL' which is causing the problem.
      For a single req line it is inserting two rows into fnd_attached_documents because
      the below cursor returning two rows while selecting from entity type 'PON_AUCTION_ITEM_PRICES_ALL'.

      Modified the query so that the one time attachments will be copied from entity type 'REQ_LINES' .

   */

  CURSOR doclist IS
   	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fdvl.datatype_id, fdvl.category_id, fdvl.security_type, fdvl.security_id,
		fdvl.publish_flag, fdvl.image_type, fdvl.storage_type,
		fdvl.usage_type, fdvl.start_date_active, fdvl.end_date_active,
		userenv('LANG') language, fdvl.description, fdvl.file_name,
		fdvl.media_id, --bug 4620207: get media_id from fd table
    fdvl.doc_attribute_category dattr_cat,
		fdvl.doc_attribute1 dattr1, fdvl.doc_attribute2 dattr2,
		fdvl.doc_attribute3 dattr3, fdvl.doc_attribute4 dattr4,
		fdvl.doc_attribute5 dattr5, fdvl.doc_attribute6 dattr6,
		fdvl.doc_attribute7 dattr7, fdvl.doc_attribute8 dattr8,
		fdvl.doc_attribute9 dattr9, fdvl.doc_attribute10 dattr10,
		fdvl.doc_attribute11 dattr11, fdvl.doc_attribute12 dattr12,
		fdvl.doc_attribute13 dattr13, fdvl.doc_attribute14 dattr14,
		fdvl.doc_attribute15 dattr15,
                fdvl.title, fdvl.url -- Bug 5000065
	  FROM 	fnd_attached_documents fad,
		fnd_documents_vl fdvl
	  WHERE	fad.document_id = fdvl.document_id
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND (X_from_pk2_value IS NULL
		 OR fad.pk2_value = X_from_pk2_value)
	    AND (X_from_pk3_value IS NULL
		 OR fad.pk3_value = X_from_pk3_value)
	    AND (X_from_pk4_value IS NULL
		 OR fad.pk4_value = X_from_pk4_value)
	    AND (X_from_pk5_value IS NULL
		 OR fad.pk5_value = X_from_pk5_value)
   --5938614
	    AND ((X_column1 = 'NEGREQ' and (nvl(fdvl.category_id,-99) <> g_cat_TO_SUPPLIER or fdvl.description LIKE 'POR:%'))
		 or (X_column1='NEG' AND nvl(fdvl.description,'*') NOT LIKE 'POR:%'))
             --Bug 9842483 Added nvl condition in description to handle attachments with null description.
   --5938614
	    AND ((X_column1 = 'NEGREQ')
		 or
		  ((X_column1='NEG') and
		    nvl(fad.column1,'NOVAL') <> 'MTL_SYSTEM_ITEMS'
		  ));

   CURSOR shorttext (mid NUMBER) IS
	SELECT short_text
	  FROM fnd_documents_short_text
	 WHERE media_id = mid;

   CURSOR longtext (mid NUMBER) IS
	SELECT long_text
	  FROM fnd_documents_long_text
	 WHERE media_id = mid;

   CURSOR fnd_lobs_cur (mid NUMBER) IS
        SELECT file_id,
               file_name,
               file_content_type,
               upload_date,
               expiration_date,
               program_name,
               program_tag,
               file_data,
               language,
               oracle_charset,
               file_format
        FROM fnd_lobs
        WHERE file_id = mid;

   media_id_tmp NUMBER;
   document_id_tmp NUMBER;
   row_id_tmp VARCHAR2(30);
   short_text_tmp Fnd_Documents_Short_Text.short_text%type ;   /* Bug 4522511 */
   long_text_tmp LONG;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
   x_category_id_tmp fnd_documents.category_id%TYPE;
   x_language_temp   fnd_documents_tl.language%TYPE;
   x_progress	varchar2(4);

   --<RENEG BLANKET FPI>
   l_intern_sourcing_cat_id fnd_documents.category_id%TYPE;

BEGIN
	--  Use cursor loop to get all attachments associated with
	--  the from_entity
        x_progress  :='001';
	FOR docrec IN doclist LOOP

	    --<RENEG BLANKET FPI START>
	    --Get the category id of Internal attachments to Sourcing
	    select category_id
	      into l_intern_sourcing_cat_id
	    from fnd_document_categories
	    where name='InternaltoSourcing';
            --<RENEG BLANKET FPI END>

	   -- Added the IF clause: Need not copy attachments that
	   -- are internal to Sourcing
            --<RENEG BLANKET FPI>
	   if (docrec.category_id <> l_intern_sourcing_cat_id) then

		--  One-Time docs that Short Text or Long Text will have
		--  to be copied into a new document (Long Text will be
		--  truncated to 32K).  Create the new document records
		--  before creating the attachment record
		--
		IF (docrec.usage_type = 'O'
		    AND docrec.datatype_id IN (1,2,5,6) ) THEN
			--  Create Documents records
			x_language_temp   := docrec.language;

            --<RENEG BLANKET FPI START>
            /* The category_id should be taken from document except for bid
               items which are copied as Internal to PO line */
            -- <Complex Work R12> : Copy bid payitem attachments as internal.
            if  X_from_entity_name in ('PON_BID_HEADERS',
					                             'PON_BID_ITEM_PRICES',
                                       'PON_BID_PAYMENTS_SHIPMENTS') then
			   x_category_id_tmp:=39;
	    else
			  x_category_id_tmp:=docrec.category_id;
	    end if;

            -- Code prior to FPI where Sourcing did not support category_id
	    -- so commenting it out
	   /*
			if X_from_entity_name in ('PON_AUCTION_HEADERS_ALL',
					'PON_AUCTION_ITEM_PRICES_ALL') then
			   x_category_id_tmp:= g_cat_TO_SUPPLIER -- <Complex Work R12>;
                        elsif X_from_entity_name in ('PON_BID_HEADERS',
					'PON_BID_ITEM_PRICES') then
			   x_category_id_tmp:=39;
			else
			  x_category_id_tmp:=docrec.category_id;
			end if;
            */
            --<RENEG BLANKET FPI END>

            x_progress  :='002';
			FND_DOCUMENTS_PKG.Insert_Row(row_id_tmp,
		                document_id_tmp,
				SYSDATE,
				NVL(X_created_by,0),
				SYSDATE,
				NVL(X_created_by,0),
				X_last_update_login,
				docrec.datatype_id,
			--	docrec.category_id,
				x_category_id_tmp,
				docrec.security_type,
				docrec.security_id,
				docrec.publish_flag,
				docrec.image_type,
				docrec.storage_type,
				docrec.usage_type,
				docrec.start_date_active,
				docrec.end_date_active,
				X_request_id,
				X_program_application_id,
				X_program_id,
				SYSDATE,
				x_language_temp, --docrec.language,
				docrec.description,--x_description_tmp
				docrec.file_name,
				media_id_tmp,
				docrec.dattr_cat, docrec.dattr1,
				docrec.dattr2, docrec.dattr3,
				docrec.dattr4, docrec.dattr5,
				docrec.dattr6, docrec.dattr7,
				docrec.dattr8, docrec.dattr9,
				docrec.dattr10, docrec.dattr11,
				docrec.dattr12, docrec.dattr13,
				docrec.dattr14, docrec.dattr15,
                                -- Bug 5000065 START
                                -- Copy the URL/title (for web page attachments)
                                'N', -- x_create_doc
                                docrec.url,
                                docrec.title
                                -- Bug 5000065 END
                                );

			--  overwrite document_id from original
			--  cursor for later insert into
			--  fnd_attached_documents
			docrec.document_id := document_id_tmp;

			--  Duplicate short or long text
			IF (docrec.datatype_id = 1) THEN
				--  Handle short Text
				--  get original data
                                x_progress  :='003';
				OPEN shorttext(docrec.media_id);
				FETCH shorttext INTO short_text_tmp;
				CLOSE shorttext;

                		x_progress  :='004';
				INSERT INTO fnd_documents_short_text (
					media_id,
					short_text)
				 VALUES (
					media_id_tmp,
					short_text_tmp);
			ELSIF (docrec.datatype_id = 2) THEN
				--  Handle long text
				--  get original data
                                x_progress  :='005';
				OPEN longtext(docrec.media_id);
				FETCH longtext INTO long_text_tmp;
				CLOSE longtext;

                                x_progress  :='006';
				INSERT INTO fnd_documents_long_text (
					media_id,
					long_text)
				 VALUES (
					media_id_tmp,
					long_text_tmp);

		        ELSIF (docrec.datatype_id=6) THEN

                         x_progress  :='007';
                         OPEN fnd_lobs_cur(docrec.media_id);
                         FETCH fnd_lobs_cur
                           INTO fnd_lobs_rec.file_id,
                                fnd_lobs_rec.file_name,
                                fnd_lobs_rec.file_content_type,
                                fnd_lobs_rec.upload_date,
                                fnd_lobs_rec.expiration_date,
                                fnd_lobs_rec.program_name,
                                fnd_lobs_rec.program_tag,
                                fnd_lobs_rec.file_data,
                                fnd_lobs_rec.language,
                                fnd_lobs_rec.oracle_charset,
                                fnd_lobs_rec.file_format;
                         CLOSE fnd_lobs_cur;

             x_progress  :='008';
             INSERT INTO fnd_lobs (
                                 file_id,
                                 file_name,
                                 file_content_type,
                                 upload_date,
                                 expiration_date,
                                 program_name,
                                 program_tag,
                                 file_data,
                                 language,
                                 oracle_charset,
                                 file_format)
               VALUES  (
                       media_id_tmp,
                       fnd_lobs_rec.file_name,
                       fnd_lobs_rec.file_content_type,
                       fnd_lobs_rec.upload_date,
                       fnd_lobs_rec.expiration_date,
                       fnd_lobs_rec.program_name,
                       fnd_lobs_rec.program_tag,
                       fnd_lobs_rec.file_data,
                       fnd_lobs_rec.language,
                       fnd_lobs_rec.oracle_charset,
                       fnd_lobs_rec.file_format);

                       media_id_tmp := '';

		  END IF;  -- end of duplicating text
		END IF;   --  end if usage_type = 'O' and datatype in (1,2,6)

		--  Create attachment record
                x_progress  :='009';
		INSERT INTO fnd_attached_documents
		(attached_document_id,
		document_id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		seq_num,
		entity_name,
		pk1_value, pk2_value, pk3_value,
		pk4_value, pk5_value,
		automatically_added_flag,
		program_application_id, program_id,
		program_update_date, request_id,
		attribute_category, attribute1,
		attribute2, attribute3, attribute4,
		attribute5, attribute6, attribute7,
		attribute8, attribute9, attribute10,
		attribute11, attribute12, attribute13,
		attribute14, attribute15, column1) VALUES
		(fnd_attached_documents_s.nextval,
		docrec.document_id,
		sysdate,
		NVL(X_created_by,0),
		sysdate,
		NVL(X_created_by,0),
		X_last_update_login,
		docrec.seq_num,
		X_to_entity_name,
		X_to_pk1_value, X_to_pk2_value, X_to_pk3_value,
		X_to_pk4_value, X_to_pk5_value,
		docrec.automatically_added_flag,
		X_program_application_id, X_program_id,
		sysdate, X_request_id,
		docrec.attribute_category, docrec.attribute1,
		docrec.attribute2, docrec.attribute3,
		docrec.attribute4, docrec.attribute5,
		docrec.attribute6, docrec.attribute7,
		docrec.attribute8, docrec.attribute9,
		docrec.attribute10, docrec.attribute11,
		docrec.attribute12, docrec.attribute13,
		docrec.attribute14, docrec.attribute15,
		docrec.column1);

		--  Update the document to be a std document if it
		--  was an ole or image that wasn't already a std doc
		--  (images should be created as Std, but just in case)
		IF (docrec.datatype_id IN (3,4)
		    AND docrec.usage_type <> 'S') THEN
			UPDATE fnd_documents
			   SET usage_type = 'S'
			WHERE document_id = docrec.document_id;
		END IF;
	  --<RENEG BLANKET FPI>
	  END IF; -- end of not including 'Internal to Sourcing' attachments
	END LOOP;  --  end of working through all attachments

       EXCEPTION WHEN OTHERS THEN

       CLOSE shorttext;
       CLOSE longtext;
       CLOSE fnd_lobs_cur;
       po_message_s.sql_error('copy_attachments',x_progress, sqlcode);
       raise;
END copy_attachments;

PROCEDURE add_attch_dynamic(
   x_from_entity_name 		      IN VARCHAR2
,  x_auction_header_id          IN NUMBER
,  x_auction_line_number        IN NUMBER
,  x_bid_number                 IN NUMBER
,  x_bid_line_number            IN NUMBER
,  x_to_entity_name             IN VARCHAR2
,  x_to_pk1_value               IN VARCHAR2
,  x_created_by                 IN NUMBER DEFAULT NULL
,  x_last_update_login          IN NUMBER DEFAULT NULL
,  x_program_application_id     IN NUMBER DEFAULT NULL
,  x_program_id                 IN NUMBER DEFAULT NULL
,  x_request_id                 IN NUMBER DEFAULT NULL
,  p_auction_payment_id         IN NUMBER DEFAULT NULL -- <Complex Work R12>
)
IS

   media_id_tmp 		NUMBER;
   document_id_tmp 		NUMBER;
   row_id_tmp 		        VARCHAR2(30);
   x_category_id_tmp 		fnd_documents.category_id%TYPE;
   x_security_id		NUMBER;
   x_seq_num 			NUMBER :=0;
   x_language_temp   		fnd_documents_tl.language%TYPE;
   x_datatype_id_tmp		NUMBER;
   x_description_tmp   		fnd_documents_tl.description%TYPE;
   l_text			long;
   l_who_rec            PO_NEGOTIATIONS_SV2.who_rec_type;
   c_text			CLOB;
   l_size                       NUMBER := 0;
   l_max_size                   NUMBER       := 30000;

   x_errorcode			varchar2(10);
   x_errormessage		varchar2(255);
   x_progress  			varchar2(4);
   pon_get_attachment_exception exception;

   d_module  VARCHAR2(70) := 'po.plsql.PO_NEGOTIATIONS_SV2.add_attch_dynamic';

BEGIN

  -- <Complex Work R12 Start>: Added logging
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'x_from_entity_name', x_from_entity_name);
    PO_LOG.proc_begin(d_module, 'x_auction_header_id', x_auction_header_id);
    PO_LOG.proc_begin(d_module, 'x_auction_line_number', x_auction_line_number);
    PO_LOG.proc_begin(d_module, 'x_bid_number', x_bid_number);
    PO_LOG.proc_begin(d_module, 'x_bid_line_number', x_bid_line_number);
    PO_LOG.proc_begin(d_module, 'x_to_entity_name', x_to_entity_name);
    PO_LOG.proc_begin(d_module, 'x_to_pk1_value', x_to_pk1_value);
    PO_LOG.proc_begin(d_module, 'p_auction_payment_id', p_auction_payment_id);
  END IF;
  -- <Complex Work R12 End>


--  One-Time docs that Short Text or Long Text will have
--  to be copied into a new document (Long Text will be
--  truncated to 32K).  Create the new document records
--  before creating the attachment record
--

    --  Create Documents records
    x_progress :='000';
    x_language_temp   := userenv('LANG');
    x_security_id     := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
    if X_from_entity_name in ('PON_BID_ATTRIBUTES') then
       x_progress :='001';
       x_category_id_tmp := g_cat_TO_SUPPLIER; -- <Complex Work R12>
       pon_auction_po_pkg.get_attachment( x_auction_header_id,
					x_bid_number,
					x_bid_line_number,
					X_from_entity_name,
					x_description_tmp,
					l_text,
					x_errorcode,
					x_errormessage);
    --<RENEG BLANKET FPI >
    elsif X_from_entity_name in ('PON_AUC_SUPPLIER_LINE_NOTES',
				 'PON_AUC_SUPPLIER_HEADER_NOTES') then
       x_progress :='002';
       x_category_id_tmp := g_cat_TO_SUPPLIER; -- <Complex Work R12>
       pon_auction_po_pkg.get_attachment( x_auction_header_id,
					x_bid_number,
					x_bid_line_number,
					X_from_entity_name,
					x_description_tmp,
					l_text,
					x_errorcode,
					x_errormessage);
    -- <Complex Work R12 Start>
    ELSIF (X_from_entity_name = 'PON_AUC_PYMNT_SHIP_SUPP_NOTES') THEN

      x_category_id_tmp := g_cat_TO_SUPPLIER;  -- to supplier

      pon_auction_po_pkg.get_attachment(
        pk1 => p_auction_payment_id
      , pk2 => NULL
      , pk3 => NULL
      , attachmenttype  => X_from_entity_name
      , attachmentdesc  => x_description_tmp
      , attachment      => l_text
      , error_code      => x_errorcode
      , error_msg       => x_errormessage
      );

    -- <Complex Work R12 End>
    elsif X_from_entity_name in ('PON_BID_BUYER_NOTES') then
       x_progress :='003';
       x_category_id_tmp :=39;--Internal to PO,to buyer from sourcing perspecti
       pon_auction_po_pkg.get_attachment( x_auction_header_id,
					x_bid_number,
					x_bid_line_number,
					X_from_entity_name,
					x_description_tmp,
					l_text,
					x_errorcode,
					x_errormessage);
    elsif X_from_entity_name in ('PON_BID_TOTAL_COST') then
       x_progress :='004';
       x_category_id_tmp := g_cat_TO_SUPPLIER; -- <Complex Work R12>
       pon_auction_po_pkg.get_attachment( x_auction_header_id,
					x_bid_number,
					x_bid_line_number,
					X_from_entity_name,
					x_description_tmp,
					l_text,
					x_errorcode,
					x_errormessage);

    -- <SERVICES FPJ START> Extract the Job Long Description from the
    -- Negotiations Table into a PO Line Attachment.
    --
    ELSIF ( x_from_entity_name = 'PON_JOB_DETAILS' ) THEN

        x_progress := '005';
        x_category_id_tmp := g_cat_TO_SUPPLIER; -- <Complex Work R12>

        PON_AUCTION_PO_PKG.get_attachment
        (   pk1            => x_auction_header_id       -- IN
        ,   pk2            => NULL                      -- IN
        ,   pk3            => x_auction_line_number     -- IN
        ,   attachmentType => x_from_entity_name        -- IN
        ,   attachmentDesc => x_description_tmp         -- OUT
        ,   attachment     => l_text                    -- OUT
        ,   error_code     => x_errorcode               -- OUT
        ,   error_msg      => x_errormessage            -- OUT
        );
    --
    -- <SERVICES FPJ END>

    --Bug# 3207840. Needs to copy Bid header attributes to PO headers from FPJ.
    -- Bug# 13618556 : Extended the functionlity to use attachemnet type as FILE
    --                 if size of header requirements exceeds 30K (~ max_size(long))
    --                 otherwise use attachemnet type as LONG_TEXT
    ELSIF ( x_from_entity_name = 'PON_BID_HEADER_ATTRIBUTES' ) THEN

        x_progress := '006';
        x_category_id_tmp := g_cat_TO_SUPPLIER; -- <Complex Work R12>
      -- Get the size of header requirements
      SELECT SUM(LENGTH(attr_name) + LENGTH(attr_value) )
      INTO l_size
      FROM
        (SELECT REPLACE(pbav.attribute_name, fnd_global.local_chr(13)) attr_name,
          pbav.Value attr_value,
          paa.sequence_number
        FROM pon_bid_attribute_values pbav,
          pon_auction_attributes paa
        WHERE pbav.auction_header_id         = x_auction_header_id
        AND pbav.bid_number                  = x_bid_number
        AND pbav.line_number                 = -1
        AND paa.auction_header_id            = pbav.auction_header_id
        AND paa.line_number                  = -1
        AND paa.sequence_number              = pbav.sequence_number
        AND NVL(paa.internal_attr_flag, 'N') = 'N'
        AND NVL(paa.display_only_flag, 'N')  = 'N'
        UNION
        SELECT REPLACE(paa.attribute_name, fnd_global.local_chr(13)),
          paa.value,
          paa.sequence_number
        FROM pon_auction_attributes paa
        WHERE paa.auction_header_id         = x_auction_header_id
        AND paa.line_number                 = -1
        AND NVL(paa.display_only_flag, 'N') = 'Y'
        ORDER BY 3
        );
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, 10, 'size of p_attachment is : ', l_size);
      END IF;
      /* If size of header attributes execeeds more than 30k(~MAX_SIZE(LONG),
      then we should use attachment type as CLOB
      otherwise, we should still continue use attachment type as LONG
      */

      IF l_size < l_max_size THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, 10, 'CALLING  PON_AUCTION_PO_PKG.get_attachment ');
        END IF;
        PON_AUCTION_PO_PKG.get_attachment ( pk1 => x_auction_header_id -- IN
        ,   pk2            => x_bid_number              -- IN
        ,   pk3            => NULL                      -- IN
        ,   attachmentType => x_from_entity_name        -- IN
        ,   attachmentDesc => x_description_tmp         -- OUT
        ,   attachment     => l_text                    -- OUT
        ,   error_code     => x_errorcode               -- OUT
        ,   error_msg      => x_errormessage            -- OUT
        );
        c_text := NULL;
      ELSE
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, 10, 'CALLING  PON_AUCTION_PO_PKG.GET_HDR_ATTRIBUTE_ATTACH_CLOB ');
        END IF;
        PON_AUCTION_PO_PKG.GET_HDR_ATTRIBUTE_ATTACH_CLOB ( p_auction_header_id => x_auction_header_id -- IN
        , p_bid_number => x_bid_number                                                                -- IN
        , p_line_number => NULL                                                                       -- IN
        , p_attachmentDesc => x_description_tmp                                                       -- IN
        , p_attachment => c_text                                                                      -- OUT
        , p_error_code => x_errorcode                                                                 -- OUT
        , p_error_msg => x_errormessage                                                               -- OUT
        );
        l_text := NULL;
      END IF;
    end if;

    -- <Complex Work R12 Start>: Added logging
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, 10, 'x_errorcode', x_errorcode);
      PO_LOG.stmt(d_module, 10, 'x_errormessage', x_errormessage);
    -- PO_LOG.stmt(d_module, 10, 'l_text', l_text);
    END IF;
    -- <Complex Work R12 End>

    --<Bug# 2288408> added checks to verify if the api returns failure raise
    --exception and dont process if l_text is null.
    if x_errorcode='FAILURE' then
       raise pon_get_attachment_exception;
    end if;
    IF ( x_errorcode='SUCCESS' AND ( l_text IS NOT NULL OR c_text IS NOT NULL ) ) THEN
       x_progress :='010';

        -- <SERVICES FPJ START>

        l_who_rec.creation_date := sysdate;
        l_who_rec.created_by := nvl(x_created_by, 0);
        l_who_rec.last_update_date := sysdate;
        l_who_rec.last_updated_by := nvl(x_created_by, 0);
        l_who_rec.last_update_login := x_last_update_login;

    /* If x_from_entity_name is PON_BID_HEADER_ATTRIBUTES  and size of header attributes
    execeeds more than 30k(~MAX_SIZE(LONG), then we should use attachment type as FILE
    otherwise, we should still continue use attachment type as LONG_TEXT
    */
    IF (x_from_entity_name = 'PON_BID_HEADER_ATTRIBUTES' AND l_size > l_max_size AND c_text IS NOT NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, 10, 'calling PO_NEGOTIATIONS_SV2.convert_text_to_attach_clob ');
      END IF;
	    PO_NEGOTIATIONS_SV2.convert_text_to_attach_clob
      (   p_clob_text      => c_text
      ,   p_description    => x_description_tmp
      ,   p_category_id    => x_category_id_tmp
      ,   p_to_entity_name => x_to_entity_name
      ,   p_from_entity_name => x_from_entity_name
      ,   p_to_pk1_value   => x_to_pk1_value
      ,   p_who_rec        => l_who_rec
      );
    ELSE
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, 10, 'calling PO_NEGOTIATIONS_SV2.convert_text_to_attachment ');
      END IF;
        PO_NEGOTIATIONS_SV2.convert_text_to_attachment
        (   p_long_text      => l_text
        ,   p_description    => x_description_tmp
        ,   p_category_id    => x_category_id_tmp
        ,   p_to_entity_name => x_to_entity_name
        ,   p_to_pk1_value   => x_to_pk1_value
        ,   p_who_rec        => l_who_rec
        );
    END IF;
        -- <SERVICES FPJ END>

    end if;

EXCEPTION
 --Bug# 2288408
 WHEN pon_get_attachment_exception then
      po_message_s.sql_error('add_attch_dynamic',x_progress, sqlcode);
      raise;
 WHEN OTHERS THEN
      po_message_s.sql_error('add_attch_dynamic',x_progress, sqlcode);
      raise;
END add_attch_dynamic;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: convert_text_to_attachment
--Pre-reqs:
--  None.
--Modifies:
--  FND_DOCUMENTS, FND_DOCUMENTS_LONG_TEXT, FND_ATTACHED_DOCUMENTS
--Locks:
--  None.
--Function:
--  Converts a LONG text to an Attachment.
--Parameters:
--IN:
--p_long_text
--  LONG text to convert.
--p_description
--  Attachment description.
--p_category_id
--  Attachment category (i.e. 33 = 'To Supplier')
--p_to_entity_name
--  Entity to which the Attachment is attached (i.e. 'PO_LINES')
--p_to_pk1_value
--  ID of the entity to which the Attachment is attached.
--p_who_rec
--  Record of Standard WHO columns.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE convert_text_to_attachment
(   p_long_text        IN  LONG
,   p_description      IN  VARCHAR2
,   p_category_id      IN  NUMBER
,   p_to_entity_name   IN  VARCHAR2
,   p_to_pk1_value     IN  VARCHAR2
,   p_who_rec          IN  who_rec_type
)
IS
    l_rowid            VARCHAR2(30);
    l_document_id      NUMBER;
    l_security_id      NUMBER;
    l_media_id         NUMBER;
    l_seq_num          NUMBER;

BEGIN

    l_security_id      := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
    -- Insert into FND_DOCUMENTS ----------------------------------------------

    FND_DOCUMENTS_PKG.insert_row
    (   x_rowid               => l_rowid                -- IN/OUT
    ,   x_document_id         => l_document_id          -- IN/OUT
    ,   x_creation_date       => nvl(p_who_rec.creation_date, sysdate)
    ,   x_created_by          => nvl(p_who_rec.created_by, 0)
    ,   x_last_update_date    => nvl(p_who_rec.last_update_date, sysdate)
    ,   x_last_updated_by     => nvl(p_who_rec.last_updated_by, 0)
    ,   x_last_update_login   => nvl(p_who_rec.last_update_login, 0)
    ,   x_datatype_id         => 2
    ,   x_category_id         => p_category_id
    ,   x_security_type       => 1
    ,   x_security_id         => l_security_id
    ,   x_publish_flag        => 'Y'
    ,   x_usage_type          => 'O'
    ,   x_program_update_date => sysdate
    ,   x_language            => userenv('LANG')
    ,   x_description         => p_description
    ,   x_media_id            => l_media_id             -- IN/OUT
    );

    -- Insert into FND_DOCUMENTS_LONG_TEXT ------------------------------------

    INSERT INTO fnd_documents_long_text
    (   media_id
    ,   long_text
    )
    VALUES
    (   l_media_id
    ,   p_long_text
    );

    -- Insert into FND_ATTACHED_DOCUMENTS -------------------------------------

    SELECT max(seq_num)
    INTO   l_seq_num
    FROM   fnd_attached_documents
    WHERE  pk1_value = p_to_pk1_value
    AND    entity_name = p_to_entity_name;

    l_seq_num := nvl(l_seq_num, 0) + 10;

    INSERT INTO fnd_attached_documents
    (   attached_document_id
    ,   document_id
    ,   creation_date
    ,   created_by
    ,   last_update_date
    ,   last_updated_by
    ,   last_update_login
    ,   seq_num
    ,   entity_name
    ,   pk1_value
    ,   automatically_added_flag
    ,   program_update_date
    )
    VALUES
    (   FND_ATTACHED_DOCUMENTS_S.nextval
    ,   l_document_id
    ,   nvl(p_who_rec.creation_date, sysdate)
    ,   nvl(p_who_rec.created_by, 0)
    ,   nvl(p_who_rec.last_update_date, sysdate)
    ,   nvl(p_who_rec.last_updated_by, 0)
    ,   nvl(p_who_rec.last_update_login, 0)
    ,   l_seq_num
    ,   p_to_entity_name
    ,   p_to_pk1_value
    ,   'N'
    ,   sysdate
    );

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_NEGOTIATIONS_SV2.CONVERT_TEXT_TO_ATTACHMENT', '000', SQLCODE );
        RAISE;

END convert_text_to_attachment;

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: convert_text_to_attach_clob
--Pre-reqs:
--  None.
--Modifies:
--  FND_DOCUMENTS, FND_LOBS, FND_ATTACHED_DOCUMENTS
--Locks:
--  None.
--Function:
--  Converts a CLOB to an Attachment.
--Parameters:
--IN:
--p_clob_text
--  CLOB text to convert.
--p_description
--  Attachment description.
--p_category_id
--  Attachment category (i.e. 33 = 'To Supplier')
--p_to_entity_name
--  Entity to which the Attachment is attached (i.e. 'PO_LINES')
--p_to_pk1_value
--  ID of the entity to which the Attachment is attached.
--p_who_rec
--  Record of Standard WHO columns.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE convert_text_to_attach_clob
(   p_clob_text        IN  CLOB
,   p_description      IN  VARCHAR2
,   p_category_id      IN  NUMBER
,   p_to_entity_name   IN  VARCHAR2
,   p_from_entity_name IN  VARCHAR2
,   p_to_pk1_value     IN  VARCHAR2
,   p_who_rec          IN  who_rec_type
)
IS
    l_rowid            VARCHAR2(30);
    l_document_id      NUMBER;
    l_security_id      NUMBER;
    l_media_id         NUMBER;
    l_seq_num          NUMBER;
    l_blob_text        BLOB;
    l_dest_offset      integer := 1;
    l_source_offset    integer := 1;
    l_lang_context     integer := DBMS_LOB.DEFAULT_LANG_CTX;
    l_warning          integer := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
    l_file_name        VARCHAR2(240);
    l_file_extn        VARCHAR2(5) := 'htm';
    l_file_charset     VARCHAR2(50) := 'UTF8';
    l_file_content_type VARCHAR2(50) := 'text/html';
    l_file_format      VARCHAR2(50) :=  'text';
BEGIN
    l_security_id      := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
    IF (p_from_entity_name = 'PON_BID_HEADER_ATTRIBUTES') THEN
	     l_file_name  := 'Requirements_And_Quote_Values' || '.' || l_file_extn;
    END IF;
    -- Insert into FND_DOCUMENTS ----------------------------------------------
    FND_DOCUMENTS_PKG.insert_row
    (   x_rowid               => l_rowid                -- IN/OUT
    ,   x_document_id         => l_document_id          -- IN/OUT
    ,   x_creation_date       => nvl(p_who_rec.creation_date, sysdate)
    ,   x_created_by          => nvl(p_who_rec.created_by, 0)
    ,   x_last_update_date    => nvl(p_who_rec.last_update_date, sysdate)
    ,   x_last_updated_by     => nvl(p_who_rec.last_updated_by, 0)
    ,   x_last_update_login   => nvl(p_who_rec.last_update_login, 0)
    ,   x_datatype_id         => 6
    ,   x_category_id         => p_category_id
    ,   x_security_type       => 1
    ,   x_security_id         => l_security_id
    ,   x_publish_flag        => 'Y'
    ,   x_usage_type          => 'O'
    ,   x_program_update_date => sysdate
    ,   x_language            => userenv('LANG')
    ,   x_description         => p_description
    ,   x_media_id            => l_media_id             -- IN/OUT
    ,   x_file_name           => l_file_name
    );
    -- Insert into FND_LOBS ------------------------------------
    DBMS_LOB.CREATETEMPORARY(l_blob_text,true);
    DBMS_LOB.CONVERTTOBLOB(l_blob_text,p_clob_text,DBMS_LOB.LOBMAXSIZE,l_dest_offset,l_source_offset,DBMS_LOB.DEFAULT_CSID,l_lang_context,l_warning);
     INSERT INTO fnd_lobs(file_id,
                          file_name,
                          file_content_type,
                          file_data,
                          upload_date,
                          LANGUAGE,
                          oracle_charset,
                          file_format)
                    VALUES(l_media_id,
                           l_file_name,
                           l_file_content_type,
                           l_blob_text,
                           SYSDATE,
                           userenv('LANG'),
                           l_file_charset,
                           l_file_format);
    -- Insert into FND_ATTACHED_DOCUMENTS -------------------------------------
    SELECT max(seq_num)
    INTO   l_seq_num
    FROM   fnd_attached_documents
    WHERE  pk1_value = p_to_pk1_value
    AND    entity_name = p_to_entity_name;
    l_seq_num := nvl(l_seq_num, 0) + 10;
    INSERT INTO fnd_attached_documents
    (   attached_document_id
    ,   document_id
    ,   creation_date
    ,   created_by
    ,   last_update_date
    ,   last_updated_by
    ,   last_update_login
    ,   seq_num
    ,   entity_name
    ,   pk1_value
    ,   automatically_added_flag
    ,   program_update_date
    )
    VALUES
    (   FND_ATTACHED_DOCUMENTS_S.nextval
    ,   l_document_id
    ,   nvl(p_who_rec.creation_date, sysdate)
    ,   nvl(p_who_rec.created_by, 0)
    ,   nvl(p_who_rec.last_update_date, sysdate)
    ,   nvl(p_who_rec.last_updated_by, 0)
    ,   nvl(p_who_rec.last_update_login, 0)
    ,   l_seq_num
    ,   p_to_entity_name
    ,   p_to_pk1_value
    ,   'N'
    ,   sysdate
    );
EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_NEGOTIATIONS_SV2.CONVERT_TEXT_TO_ATTACHMENT_CLOB', '000', SQLCODE );
        RAISE;
END convert_text_to_attach_clob;
-- <Complex Work R12 Start>
-- Bug 4620207: Take in more parameters
PROCEDURE copy_sourcing_payitem_atts(
  p_line_location_id           IN NUMBER
, p_created_by                 IN NUMBER
, p_last_update_login          IN NUMBER
, p_auction_header_id          IN NUMBER
, p_auction_line_number        IN NUMBER
, p_bid_number                 IN NUMBER
, p_bid_line_number            IN NUMBER
)
IS
  d_progress  NUMBER;
  d_module    VARCHAR2(70) := 'po.plsql.PO_NEGOTIATIONS_SV2.copy_sourcing_payitem_atts';

  l_bid_payment_id      PO_LINE_LOCATIONS_INTERFACE.bid_payment_id%TYPE;
  l_auction_payment_id  PO_LINE_LOCATIONS_INTERFACE.auction_payment_id%TYPE;

BEGIN

  d_progress := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_line_location_id', p_line_location_id);
    PO_LOG.proc_begin(d_module, 'p_created_by', p_created_by);
    PO_LOG.proc_begin(d_module, 'p_last_update_login', p_last_update_login);
  END IF;

  d_progress := 10;

  SELECT polli.bid_payment_id, polli.auction_payment_id
  INTO l_bid_payment_id, l_auction_payment_id
  FROM po_line_locations_interface polli
  WHERE polli.line_location_id = p_line_location_id;

  d_progress := 20;

  IF (l_auction_payment_id IS NOT NULL)
  THEN

    d_progress := 30;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling copy_attachments for auction payment attachments');
    END IF;

    -- Bug 4620207: pass new pk1/pk2/pk3 values to copy_attachments
    copy_attachments(
      X_from_entity_name   => 'PON_AUC_PAYMENTS_SHIPMENTS'
    , X_from_pk1_value     => p_auction_header_id
    , X_from_pk2_value     => p_auction_line_number
    , X_from_pk3_value     => l_auction_payment_id
    , X_to_entity_name     => 'PO_SHIPMENTS'
    , X_to_pk1_value       => p_line_location_id
    , X_created_by         => p_created_by
    , X_last_update_login  => p_last_update_login
    , X_column1            => 'NEG'
    );

    d_progress := 40;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling add_attch_dynamic for auction payment attachments');
    END IF;

    add_attch_dynamic(
      x_from_entity_name     =>  'PON_AUC_PYMNT_SHIP_SUPP_NOTES'
    , x_auction_header_id    =>  NULL
    , p_auction_payment_id   =>  l_auction_payment_id
    , x_auction_line_number  =>  NULL
    , x_bid_number           =>  NULL
    , x_bid_line_number      =>  NULL
    , x_to_entity_name       =>  'PO_SHIPMENTS'
    , x_to_pk1_value         =>  p_line_location_id
    , x_created_by           =>  p_created_by
    , x_last_update_login    =>  p_last_update_login
    , x_program_id           =>  NULL
    , x_request_id           =>  NULL
    );

  END IF;  -- if l_auction_payment_id IS NOT NULL

  IF (l_bid_payment_id IS NOT NULL)
  THEN

    d_progress := 50;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling copy_attachments for bid payment attachments');
    END IF;

    -- Bug 4620207: pass new pk1/pk2/pk3 values to copy_attachments
    copy_attachments(
     X_from_entity_name   => 'PON_BID_PAYMENTS_SHIPMENTS'
   , X_from_pk1_value     => p_bid_number
   , X_from_pk2_value     => p_bid_line_number
   , X_from_pk3_value     => l_bid_payment_id
   , X_to_entity_name     => 'PO_SHIPMENTS'
   , X_to_pk1_value       => p_line_location_id
   , X_created_by         => p_created_by
   , X_last_update_login  => p_last_update_login
   , X_column1            => 'NEG'
   );

  END IF;  -- if l_bid_payment_id IS NOT NULL

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END copy_sourcing_payitem_atts;
-- <Complex Work R12 End>

END PO_NEGOTIATIONS_SV2;

/
