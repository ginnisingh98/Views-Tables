--------------------------------------------------------
--  DDL for Package Body PO_CREATE_ISO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CREATE_ISO" AS
/* $Header: POXCISOB.pls 120.5.12010000.17 2012/09/25 00:29:53 chihchan ship $*/
/*===========================================================================
  PACKAGE NAME:         PO_CREATE_ISO

  DESCRIPTION:          Create Internal Sales Orders Concurrent program
			subroutine.
       			This routine will take Approved requisitions which are
       			to be sourced from Inventory and create corresponding
      		        Internal Sales Orders in the OrderImport interface
			tables of Oracle Order Entry. This routine will be run
			on a cyclic basis to pick up all requisitions ready for
			transfer to OrderImport

  CLIENT/SERVER:        Server

  LIBRARY NAME          NONE

  OWNER:

  PUBLIC FUNCTIONS

  NOTES

==============================================================================*/


/*=============================================================================
  Procedure Name: LOAD_OM_INTERFACE()
  Desc: Create Internal Sales Orders Subroutine
  Args: None
  Reqs:
  Mods:
  Algr:
        Step 1: Set transferred_to_oe_flag to 'I' in po_requisition_lines
                for all Reqs that are approved and have atleast one line with
                source_type as INVENTORY.
        Step 2: Open the Cursor that has all headers with TRANSFERRED_TO_OE_FLAG
                as I.
        Step 3: For every operating unit change, get the OPUNIT details.
                If no detail found, set the transferred_to_oe_flag to 'E'
                for those headers.
        Step 4: insert into oe_headers_iface_all from po_requisition_headers
        Step 5: For each row
                    insert into oe_lines_iface_all from po_requisition_lines
        Step 6: Update the transferred_to_oe_flag to 'Y' for all 'I' ones and
                to 'N' for all 'E' ones.
        Step 7: return
==============================================================================*/
PROCEDURE LOAD_OM_INTERFACE(
  errbuf  out	NOCOPY varchar2,
  retcode out	NOCOPY number,
  p_req_header_id number default null)
IS
	l_currency_code		VARCHAR2(16);
	l_ot_id			NUMBER;
	l_os_id			NUMBER;
	l_pr_id			NUMBER;
	l_ac_id			NUMBER;
	l_ir_id			NUMBER;
        l_req_hdr_id  		NUMBER;
        l_req_hdr_id_prev	NUMBER;
        l_req_line_id 		NUMBER;
      	l_op_unit_id  		NUMBER;
       	l_op_unit_id_prev  	NUMBER;
        l_error_flag            VARCHAR2(1) ;
        x_pjm_status           VARCHAR2(1) := 'N';

        --Bug 12576879
        l_req_line_number NUMBER;

        -- Bug 2873877 START
        l_val_proj_result     VARCHAR(1);
        l_val_proj_error_code VARCHAR2(80);
        l_dest_type_code      PO_REQUISITION_LINES.destination_type_code%TYPE;
        l_source_org_id       PO_REQUISITION_LINES.source_organization_id%TYPE;
        l_need_by_date        PO_REQUISITION_LINES.need_by_date%TYPE;
        l_project_id          PO_REQ_DISTRIBUTIONS.project_id%TYPE;
        l_task_id             PO_REQ_DISTRIBUTIONS.task_id%TYPE;
        -- Bug 2873877 END

        --<INVCONV R12 START>
        l_dest_secondary_quantity   PO_REQUISITION_LINES.SECONDARY_QUANTITY%TYPE   := NULL;
        l_dest_secondary_unit       PO_REQUISITION_LINES.SECONDARY_UNIT_OF_MEASURE%TYPE := NULL;
        l_item_id                   PO_REQUISITION_LINES.ITEM_ID%TYPE      := NULL;
        l_source_secondary_quantity PO_REQUISITION_LINES.SECONDARY_QUANTITY%TYPE   := NULL;
        l_source_secondary_uom      MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE  := NULL;
        l_source_secondary_unit     PO_REQUISITION_LINES.SECONDARY_UNIT_OF_MEASURE%TYPE := NULL;
        --<INVCONV R12 END>

        l_pjm_ou_id FINANCIALS_SYSTEM_PARAMS_ALL.org_id%TYPE;  --< Bug 3265539 >

        -- begin Bug 3249134
        l_prec_currency_code varchar2(15) := NULL;
        l_precision number := NULL;
        l_ext_precision number := NULL;
        l_min_unit number := NULL;
        -- end Bug 3249134

        l_customer_id  number := NULL;   -- Bug 3365408
        l_sold_to_org_id NUMBER :=NULL;
        l_prev_sold_to_org_id  NUMBER :=NULL;
	--bug7699084 Defined a table to hold all the req header id's that gets processed,
	--So that the transferred_to_oe_flag of the line can be quickly processed
	l_req_hdr_id_tbl po_tbl_number := PO_TBL_NUMBER();
        tbl_index NUMBER :=0;
	--bug7699084

	--BUG10037733 variable definitions.
	l_unit_list_price number;
	l_unit_selling_price number;
	l_conversion_date PO_REQ_DISTRIBUTIONS.gl_encumbered_date%TYPE;
	l_sob_id FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
	l_conversion_type PO_SYSTEM_PARAMETERS.default_rate_type%TYPE;
	l_rate NUMBER;
	l_source_currency_code VARCHAR2(15);
	l_dest_currency_code VARCHAR2(15);
	--BUG10037733

	--#bug 12816938 variable definitions.
	l_org_id       PO_REQUISITION_LINES.org_id%TYPE;

/* Bug# 1644637
   Added conditions in where clause to check if the Line is INVENTORY sourced
   and the line is not Cancelled or FINALLY CLOSED.
*/

       CURSOR REQ_LINES IS
         select /*+ leading(HDR) index(HDR PO_REQUISITION_HEADERS_N4) USE_NL(HDR LIN PLA)*/
                NVL( (SELECT /*+ index(ORG.HOI1 HR_ORGANIZATION_INFORMATIO_FK2)
*/ ORG.OPERATING_UNIT
       FROM   ORG_ORGANIZATION_DEFINITIONS ORG
       WHERE LIN.SOURCE_ORGANIZATION_ID = ORG.ORGANIZATION_ID
       AND NVL(PLA.ORG_ID, -1) = NVL(ORG.OPERATING_UNIT,-1) ),-1)
       OPERATING_UNIT,
		hdr.requisition_header_id,
                lin.requisition_line_id
                ,Nvl(PLA.CUSTOMER_ID,-1)            --bug 8692047
         from   po_requisition_lines lin,
                po_requisition_headers hdr,
 	                 PO_LOCATION_ASSOCIATIONS_ALL PLA
         where  lin.requisition_header_id = hdr.requisition_header_id
         and    hdr.transferred_to_oe_flag = 'I'
         and    lin.source_type_code = 'INVENTORY'
         and    nvl(lin.cancel_flag,'N') = 'N'
         and    nvl(lin.closed_code,'OPEN') <> 'FINALLY CLOSED'
         AND    lin.DELIVER_TO_LOCATION_ID = PLA.LOCATION_ID
         order by operating_unit,
	  hdr.requisition_header_id,
	 PLA.CUSTOMER_ID,
		  lin.line_num;

BEGIN

	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Begin create internal sales order');

  	BEGIN

	/* Select all requisition headers which have been approved since
        last run (or =req_id)
        We are setting the transferred_to_oe_flag to N for externally
        sourced reqs as well
        so that the program does not have to sort through these rows
        again next time */

   	Fnd_File.Put_Line(FND_FILE.LOG, 'Updating Req Headers');

	IF p_req_header_id is null then

        /* Bug 2630523 Performance of the following SQL will be good if it choose
           Hash Join. So added the HASH_SJ hint to improve the performance */

      	  /*UPDATE PO_REQUISITION_HEADERS PRH
          SET    PRH.TRANSFERRED_TO_OE_FLAG = 'I'
          WHERE  nvl(PRH.TRANSFERRED_TO_OE_FLAG,'N') = 'N'
          AND    PRH.AUTHORIZATION_STATUS = 'APPROVED'
          AND   exists (select /*+ HASH_SJ  */ /*'At least one inventory sourced line'
                        from   po_requisition_lines prl
                        where  prh.requisition_header_id =
                                         prl.requisition_header_id
                        and    prl.source_type_code = 'INVENTORY'
                        and    nvl(prl.cancel_flag,'N') = 'N'
                        and    nvl(prl.closed_code,'OPEN') <> 'FINALLY CLOSED');*/

 /* Bug 7699084 Commented the above sql and introduced the below sql for performance gains
	    Added an Nvl around the transferred_to_oe_flag check*/

	  UPDATE po_requisition_headers prh
	     SET prh.transferred_to_oe_flag = 'I'
	   WHERE prh.authorization_status = 'APPROVED'
	     AND prh.requisition_header_id IN (SELECT /*+ index ( PRL  po_requisition_lines_f5 ) */
													DISTINCT prl.requisition_header_id
		                                         FROM   po_requisition_lines prl
		                                         WHERE  Nvl(prl.line_location_id,- 999) = - 999
		                                                AND prl.source_type_code = 'INVENTORY'
		                                                AND Nvl(prl.transferred_to_oe_flag,'N') = 'N' --Bug7699084
		                                                AND Nvl(prl.cancel_flag,'N') = 'N'
		                                                AND Nvl(prl.closed_code,'OPEN') <> 'FINALLY CLOSED');

          Fnd_File.Put_Line(FND_FILE.LOG,to_char(SQL%ROWCOUNT)||' Reqs selected for processing');

	ELSE

      	  UPDATE PO_REQUISITION_HEADERS PRH
          SET    PRH.TRANSFERRED_TO_OE_FLAG = 'I'
          WHERE  /*nvl(PRH.TRANSFERRED_TO_OE_FLAG,'N') = 'N' AND  Bug 7699084*/
	  PRH.AUTHORIZATION_STATUS = 'APPROVED'
          AND    PRH.REQUISITION_HEADER_ID = p_req_header_id
          AND    exists (select 'At least one inventory sourced line'
                         from   po_requisition_lines prl
                         where  prh.requisition_header_id =
                                      prl.requisition_header_id
                         and  prl.source_type_code = 'INVENTORY'
			 and  Nvl(prl.transferred_to_oe_flag,'N') = 'N' /*Bug 7699084*/
                         and  nvl(prl.cancel_flag,'N') = 'N'
                         and  nvl(prl.closed_code,'OPEN') <> 'FINALLY CLOSED');

           Fnd_File.Put_Line(FND_FILE.LOG,to_char(SQL%ROWCOUNT)||' Reqs selected for processing');

        END IF;

 	EXCEPTION
	  WHEN NO_DATA_FOUND THEN /* there are no reqs to process */
            Fnd_File.Put_Line(FND_FILE.LOG, 'No reqs selected for processing');
            return;
	  WHEN OTHERS THEN
 	    Fnd_File.Put_Line(FND_FILE.LOG, 'Error updating req headers');
            return;
 	END;

 	Fnd_File.Put_Line(FND_FILE.LOG, '-----');

        /*  2034580 - Check if PJM is installed    */

        x_pjm_status := po_core_s.get_product_install_status('PJM');

/* Bug# 1672814
   We are now initialising the Previous Operating Unit to -99 instead
   of 0  as we can have Operating Unit with Value of 0 which results in
   Operating Unit Details not getting Fetched */

        l_op_unit_id_prev := -99;
        l_req_hdr_id_prev := 0;
        l_req_line_number := 1;    --Bug #12576879
        l_prev_sold_to_org_id := -1;
        Open REQ_LINES;
        LOOP
	 Fnd_File.Put_Line(FND_FILE.LOG, 'Top of Fetch Loop');
         fetch REQ_LINES into
                   	l_op_unit_id,
		            l_req_hdr_id,
		   	    l_req_line_id, l_sold_to_org_id;

         EXIT WHEN REQ_LINES%NOTFOUND;

         --Bug 7699084 Populating the table with req header id fetched by the cursor
	  tbl_index := tbl_index + 1;
          l_req_hdr_id_tbl.extend;
          l_req_hdr_id_tbl(tbl_index) := l_req_hdr_id;

         l_error_flag := 'N';

	 IF l_op_unit_id_prev <> l_op_unit_id then

            /* Bug# 1523554 : When the Source organization changes, the
            Headers must be created in the Source Organization Operating Unit.
            This was not happening when a requisition had lines from
            2 different Source Organizations which in Turn had different
            Operating Units. Now initialising l_req_hdr_id_prev to 0 so that
            it creates a new header in the Source Organization Operating Unit
            every time the Source Organization Operating Unit Changes. */

            l_req_hdr_id_prev := 0;

 	    Fnd_File.Put_Line(FND_FILE.LOG, '-----');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Source Operating Unit: ' || to_char(l_op_unit_id));

             GET_OPUNIT_DETAILS(l_op_unit_id,
                                l_error_flag,
                                l_currency_code,
                                l_ot_id,
                                l_pr_id,
                                l_ac_id,
                                l_ir_id);

              IF (l_error_flag = 'Y') then
                 UPDATE PO_REQUISITION_HEADERS
                 SET TRANSFERRED_TO_OE_FLAG = 'E'
                 WHERE REQUISITION_HEADER_ID = l_req_hdr_id
                 and TRANSFERRED_TO_OE_FLAG = 'I';
              ELSE
                 l_op_unit_id_prev := l_op_unit_id;
              END IF;

         END IF;
	 IF l_sold_to_org_id <> l_prev_sold_to_org_id then
               		l_prev_sold_to_org_id :=l_sold_to_org_id;
	                    l_req_hdr_id_prev := 0;
	                    l_req_line_number := 1;    --Bug #12576879
 	                    Fnd_File.Put_Line(FND_FILE.LOG, '-----');
 	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Customer id: ' || to_char(l_sold_to_org_id));

 	 END IF; /*--7716682*/
         IF (l_error_flag <> 'Y') then

            IF(l_req_hdr_id <> l_req_hdr_id_prev) then
--Bug 7662103:  The order_date_type_code needs to be populated 'ARRIVAL'
-- to enable planned IR to get synced wih the scheduled Arrival date in internal sales order


	       INSERT INTO OE_HEADERS_IFACE_ALL
                    (creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     orig_sys_document_ref,
                     sold_to_org_id,
                     order_type_id,
                     order_source_id,
                     order_category,
                     ordered_date,
                     transactional_curr_code,
	       	     request_date,
                     price_list_id,
                     accounting_rule_id,
 		     invoicing_rule_id,
                     ship_to_org_id,
                     org_id,
                     ORDER_DATE_TYPE_CODE)
              SELECT
                     SYSDATE,
                     RH.CREATED_BY,
                     SYSDATE,
                     RH.LAST_UPDATED_BY,
                     RH.LAST_UPDATE_LOGIN,
                     RH.REQUISITION_HEADER_ID,  /* Requisition Header Id */
                     PLA.CUSTOMER_ID,
                     l_ot_id,
                     10,         -- seeded order source for internal reqs
                     'P',
                     RH.CREATION_DATE,
                     l_currency_code,
                     RL.NEED_BY_DATE,
                     l_pr_id,
                     l_ac_id,
		     l_ir_id,
                     PLA.SITE_USE_ID,
                     decode(l_op_unit_id, -1, NULL, l_op_unit_id) ,
                     'ARRIVAL'    --Bug 7662103:
              FROM PO_REQUISITION_HEADERS RH,
                   PO_REQUISITION_LINES RL,
                   PO_LOCATION_ASSOCIATIONS_ALL PLA
              WHERE RH.REQUISITION_HEADER_ID = RL.REQUISITION_HEADER_ID
              AND   RL.DELIVER_TO_LOCATION_ID = PLA.LOCATION_ID
              AND   nvl(PLA.ORG_ID,-1) = l_op_unit_id
              AND   RL.REQUISITION_LINE_ID   = l_req_line_id;

              l_req_hdr_id_prev := l_req_hdr_id;
	      --Bug 13889095 reset the counter when enter a new order
	      l_req_line_number := 1;

/* Bug # 1653150
   Added the if to Insert in to OE_ACTIONS_IFACE_ALL only when the Header
   was inserted. */

              IF SQL%ROWCOUNT>0 then

 	         Fnd_File.Put_Line(FND_FILE.LOG, '-----');
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting Header : '||to_char(l_req_hdr_id));

/* Bug # 1653150
   Used OE_ACTIONS_IFACE_ALL rather than OE_ACTIONS_INTERFACE as it was
   inserting with the Org_id of the Destination Org. This resulted in Sales
   Order not getting Created in a Booked State.  */

               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting the customer id');

               -- Bug 3365408: We need to insert the customer id into
               -- the sold to org column in the actions interface
               Begin
                 SELECT PLA.CUSTOMER_ID
                 INTO   l_customer_id
                 FROM   PO_REQUISITION_LINES RL,
                        PO_LOCATION_ASSOCIATIONS_ALL PLA
                 WHERE  RL.DELIVER_TO_LOCATION_ID = PLA.LOCATION_ID
                 AND    nvl(PLA.ORG_ID,-1) = l_op_unit_id
                 AND    RL.REQUISITION_LINE_ID   = l_req_line_id;
                Exception
                   When others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting the customer id Exception :' || to_char(sqlcode));
                    l_customer_id:= null;
                End;

               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting the customer id: ' || l_customer_id);

                 INSERT INTO OE_ACTIONS_IFACE_ALL
             	    (ORDER_SOURCE_ID,
              	     ORIG_SYS_DOCUMENT_REF,
      		     OPERATION_CODE,
                     ORG_ID,
                     SOLD_TO_ORG_ID)    -- Bug 3365408
                  values
                     (10,
            	      l_req_hdr_id,
             	      'BOOK_ORDER',
                      decode(l_op_unit_id, -1, NULL, l_op_unit_id) ,
                      l_customer_id      -- Bug 3365408
                      );
              ELSE

 	         Fnd_File.Put_Line(FND_FILE.LOG, '-----');
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Header not Inserted : '||to_char(l_req_hdr_id));

              END IF;

	    END IF; /* end of if it is a new header */

            -- Bug 2873877 START
            -- The Project and Task on the Internal Req should only be passed
            -- to the OM Interface if all of the following conditions are met:
            --   1. The destination type is Inventory.
            --   2. The project and task pass PJM validation in the source org.
            --
            -- Otherwise, we will null out the project and task.

            SELECT PRL.destination_type_code,
                   PRL.source_organization_id,
                   PRL.org_id,
                   PRL.need_by_date,
                   PRD.project_id,
                   PRD.task_id,
                   --<INVCONV R12 START>
                   PRL.secondary_quantity,
                   PRL.secondary_unit_of_measure,
                   PRL.item_id
                   --<INVCONV R12 END>
            INTO l_dest_type_code,
                 l_source_org_id,
                 l_org_id,
                 l_need_by_date,
                 l_project_id,
                 l_task_id,
                 l_dest_secondary_quantity ,
                 l_dest_secondary_unit ,
                 l_item_id
            FROM po_requisition_lines PRL, po_req_distributions PRD
            WHERE PRL.requisition_line_id = l_req_line_id
            AND PRL.requisition_line_id = PRD.requisition_line_id; -- JOIN

            -- Note: Internal lines can only have one distribution. This
            -- is ensured by the PO Submission Checks.

            IF (l_project_id IS NULL AND l_task_id IS NULL) THEN
              null; -- Do nothing if project and task are not specified.

            ELSIF (l_dest_type_code <> 'INVENTORY') THEN
              -- Check #1: Destination type is not Inventory, so null out
              -- the project and task.
              l_project_id := NULL;
              l_task_id := NULL;
              FND_FILE.put_line(FND_FILE.LOG, 'Destination type is not Inventory - nulling out the project and task.');

            ELSE -- destation type is Inventory
              -- Check #2: Call the PJM validation API with the source org.
                --< Bug 3265539 Start >
                -- The PJM OU is the OU of the inventory org, which is selected
                -- in the REQ_LINES cursor
                IF (l_op_unit_id = -1) THEN
                    -- Cannot pass in a -1 to the validation API
                    l_pjm_ou_id := NULL;
                ELSE
                    l_pjm_ou_id := l_op_unit_id;
                END IF;

                -- Call PO wrapper procedure to validate the PJM project
                PO_PROJECT_DETAILS_SV.validate_proj_references_wpr
                  (p_inventory_org_id => l_source_org_id,
                   p_operating_unit   => l_pjm_ou_id,
                   p_project_id       => l_project_id,
                   p_task_id          => l_task_id,
                   p_date1            => l_need_by_date,
                   p_date2            => NULL,
                   p_calling_function => 'POXCISOB',
                   x_error_code       => l_val_proj_error_code,
                   x_return_code      => l_val_proj_result);

                IF ( l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_failure ) THEN
                    -- PJM validation failed, so null out the project and task.
                    l_project_id := NULL;
                    l_task_id := NULL;
                    FND_FILE.put_line(FND_FILE.LOG, 'PJM validation failed in the source org - nulling out the project and task. Error message follows:');
                    FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.get);
                END IF;
                --< Bug 3265539 End >

            END IF; -- project and task are null
            -- Bug 2873877 END

        /* Bug: 1888361 - Modified the code to take care of unit_price. The problem was
when the source Org currency is different from destination org currency, In Enter Req
form, the unit_price was converted to the destination org's currency price as the Req is
always created in Functional currency. But when we populate the interface table, we populate
the currency as Source Org currency as the Sales Order has to be in Source Org's currency
but the unit price was destination org's currency unit price as the conversion took place
already. This was a mismatch when the Sales Order was created. Hence we revert the
unit price to the cost price of source org, before we populate the interface table.
Hence added a new function get_cst_price and this is called while inserting the unit_price
columns in so_oe_lines_iface_all table  */

/* 1906141 -Subinventory was not populated in oe_lines_iface_all.
Populating the source subinventory from  requisition lines */

/* Bug 1988404 - Removed the insert of value to schedule_ship_date. If this is
populated, when Order Import calls Scheduling that fails if the on hand inventory
is not available on that date. We expect MRP to populate the proper date when
scheduling is called based on the request_date provided, which is the need_by_date */

    /* 2034580 - Pass project and task id only if PJM is installed for
    destination type EXPENSE   */

   /* Bug2357247 if PJM is installed in shared product  do not pass project_id
 and task_id for destination type EXPENSE */

  --begin bug 3249134, forward port of 3122219

         --Bug 10037733
 	 SELECT currency_code
 	 INTO   l_Source_Currency_Code
 	 FROM   gl_sets_of_books glsob,
 	        org_organization_definitions ood
 	 WHERE  glsob.set_of_books_id = ood.set_of_books_id
 	   AND  ood.organization_id   = l_source_org_id;

  --get the currency_code functional currency from gl
  select currency_code
  into l_dest_currency_code
  from
  financials_system_parameters fsp,
  gl_sets_of_books gl
  where gl.set_of_books_id = fsp.set_of_books_id
  --#bug 12816938 add org condition to return single row for multi org.
    and fsp.org_id = l_org_id;

  /*Find the extended precision
    of the currency so that the unit price may be rounded off
    to the same precision*/
  --bug10037733 round with the source org currency 's extended precision.
  fnd_currency.get_info (l_Source_Currency_Code,
                        l_precision,
                        l_ext_precision,
                        l_min_unit);
 /*rounding the value of the unit_selling_price
   and unit_list_price to extended precision while inserting data into
   oe_lines_iface_all*/

   --end bug 3249134

   --<INVCONV R12 START>
   IF l_dest_secondary_quantity IS NOT NULL THEN

      -- get source secondary uom
      PO_UOM_S.get_secondary_uom( l_item_id,
                                  l_source_org_id,
                                  l_source_secondary_uom,
                                  l_source_secondary_unit);

      IF l_source_secondary_unit IS NOT NULL THEN
         IF l_source_secondary_unit <> l_dest_secondary_unit THEN
            PO_UOM_S.uom_convert (l_dest_secondary_quantity,
                                  l_dest_secondary_unit,
                                  l_item_id,
                                  l_source_secondary_unit,
                                  l_source_secondary_quantity);
         ELSE
            l_source_secondary_quantity := l_dest_secondary_quantity;
         END IF;
      ELSE
         l_source_secondary_quantity := NULL;
         l_source_secondary_uom := NULL;
      END IF;
   ELSE
      /** No need to derive secondary qty even if  item in source org. is dual uom control. Order Import
          would do the defaulting. **/
      l_source_secondary_quantity := NULL;
      l_source_secondary_uom := NULL;
   END IF;
   --<INVCONV R12 END>

   /*bug10037733 if the source and destination orgs are of different currencies then
 	   convert the unit price to the source orgs currency before populating the
 	   order lines interface. */

 	 IF (NVL(l_Source_Currency_Code,-1) = NVL(l_dest_Currency_Code,-1)) THEN
 	 -- if the source and destination org currencies are the same, populate the
 	 -- interface directly.
 	         SELECT rl.unit_price,
 	                rl.unit_price
 	         INTO   l_unit_selling_price,
 	                l_unit_list_price
 	         FROM   po_requisition_lines rl
 	         WHERE  requisition_line_id = l_req_line_id;

 	 ELSE
 	 -- if the source and destination org currencies are not same, then populate the
 	 -- interface after converting to the source org currency
 	         --convert price into source org currency
 	         SELECT set_of_books_id
 	         INTO   l_sob_id
 	         FROM   financials_system_parameters
			 --#bug 12816938 add org condition to return single row for multi org.
            WHERE  org_id = l_org_id;

 	         SELECT default_rate_type
 	         INTO   l_conversion_type
 	         FROM   po_system_parameters
			 --#bug 12816938 add org condition to return single row for multi org.
            WHERE  org_id = l_org_id;

 	         --the conversion date is sysdate
 	         l_conversion_date := sysdate;
 	         l_rate            := gl_currency_api.get_closest_rate_sql ( l_sob_id,
 	                                                                     l_Source_Currency_Code,
 	                                                                     l_conversion_date,
 	                                                                     l_conversion_type,
 	                                                                     30);
 	         IF (l_rate < 0 OR l_rate IS NULL) THEN
 	                 l_rate    := 1;
 	         END IF;

 	         SELECT rl.unit_price/l_rate,
 	                rl.unit_price/l_rate
 	         INTO   l_unit_selling_price,
 	                l_unit_list_price
 	         FROM   po_requisition_lines rl
 	         WHERE  requisition_line_id = l_req_line_id;


 	 END IF; -- source_curr = dest_curr
 --<Bug10037733 end>

    /* Bug 5280573, Reverted the fix done in Bug # 3365408.
    OM was validating if the same Customer details were
    Entered in sold_to_org_id fields of Header and Lines.
    If there were Lines which had different Customers for
    headers Order Import was Erroring out. To insert different
    OM Headers for OU+customer combination is not possible
    as a Bugfix.
    As a workaround we are just popuating the same Customer
    information as the header for the all the sales Order
    lines for the same OU to by pass OM Validation. */

            INSERT INTO OE_LINES_IFACE_ALL
               	(CREATION_DATE,
               	CREATED_BY,
               	LAST_UPDATE_DATE,
               	LAST_UPDATED_BY,
               	LAST_UPDATE_LOGIN,
               	ORIG_SYS_DOCUMENT_REF,
               	ORIG_SYS_LINE_REF,
                SOLD_TO_ORG_ID,  -- Bug 3365408
               	LINE_NUMBER,
               	ORDER_QUANTITY_UOM,
               	ORDERED_QUANTITY,
               	UNIT_LIST_PRICE,
               	UNIT_SELLING_PRICE,
               	INVENTORY_ITEM_ID,
               	SHIP_FROM_ORG_ID,
               	REQUEST_DATE,
               	ITEM_TYPE_CODE,
               	OPTION_FLAG,
               	ORDER_SOURCE_ID,
               	CALCULATE_PRICE_FLAG,
               	SHIP_TO_ORG_ID,
	 	PROJECT_ID,
	 	TASK_ID,
		END_ITEM_UNIT_NUMBER,
                SUBINVENTORY,
		ORG_ID,
		ORDERED_QUANTITY_UOM2,
		ORDERED_QUANTITY2,
		PREFERRED_GRADE,
 	             SHIPMENT_PRIORITY_CODE
 	 )  /* B1548597 OPM */
            SELECT SYSDATE,
                   RL.CREATED_BY,
                   SYSDATE,
                   RL.LAST_UPDATED_BY,
                   RL.LAST_UPDATE_LOGIN,
                   RH.REQUISITION_HEADER_ID,
                   RL.REQUISITION_LINE_ID,
                   l_customer_id,  -- Bug 5280573
                   --RL.LINE_NUM,
                   l_req_line_number, --Bug 12576879 Commented above added the variable to get from counter
                   MUM.UOM_CODE,
                   round(RL.QUANTITY,9),
                   --begin bug 3249134: changed the following values to be rounded
                   --< INVCONV R12 START> umoogala: Added Dest. OrgId and qty parameters
                   decode (fnd_profile.value('PO_CUSTOM_UNIT_PRICE'),'Y',round(l_unit_list_price,l_ext_precision),round(PO_CREATE_ISO.GET_CST_PRICE(RL.ITEM_ID,
                                                     RL.SOURCE_ORGANIZATION_ID,
                                                     RL.UNIT_MEAS_LOOKUP_CODE,
                                                     RL.DESTINATION_ORGANIZATION_ID,
                                                     RL.QUANTITY),
                         l_ext_precision)), --Bug10037733
	           decode (fnd_profile.value('PO_CUSTOM_UNIT_PRICE'),'Y',round(l_unit_selling_price,l_ext_precision),round(PO_CREATE_ISO.GET_CST_PRICE(RL.ITEM_ID,
                                                     RL.SOURCE_ORGANIZATION_ID,
                                                     RL.UNIT_MEAS_LOOKUP_CODE,
                                                     RL.DESTINATION_ORGANIZATION_ID,
                                                     RL.QUANTITY),
                         l_ext_precision)), --Bug10037733
                   --end bug 3249134
                   RL.ITEM_ID,
                   RL.SOURCE_ORGANIZATION_ID,
                   RL.NEED_BY_DATE,
                   DECODE(SI.PICK_COMPONENTS_FLAG,
                          'N','STANDARD',
                          'Y','KIT',
                           'STANDARD'),
                   'N',
                   10,
                   'N',
                   LA.SITE_USE_ID,
                   -- Bug 2873877 START
                   -- Only pass project and task for Inventory lines that
                   -- pass the PJM validations in the source org. See above.
                   l_project_id,
                   l_task_id,
                   -- Bug 2873877 END
                   RD.END_ITEM_UNIT_NUMBER,
                   RL.SOURCE_SUBINVENTORY,
                   decode(l_op_unit_id, -1, NULL, l_op_unit_id),
                   l_source_secondary_uom,      --<INVCONV R12 START>MUM1.UOM_CODE,
                  round( l_source_secondary_quantity,9), --<INVCONV R12 START>RL.SECONDARY_QUANTITY,
                   decode(si.grade_control_flag,'Y',RL.preferred_grade,NULL) --<INVCONV R12 START> RL.PREFERRED_GRADE
	, decode(RL.URGENT_FLAG,'Y', fnd_profile.value('POR_URGENT_FLAG_SHIPMENT_PRIORITY_CODE'),null)
              FROM   PO_REQUISITION_LINES   RL,
                     PO_REQUISITION_HEADERS RH,
                     PO_REQ_DISTRIBUTIONS RD,  --only one distribution allowed!
                     MTL_SYSTEM_ITEMS         SI,
                     PO_LOCATION_ASSOCIATIONS_ALL LA,
                     MTL_UNITS_OF_MEASURE MUM
                     --<INVCONV R12 START>,MTL_UNITS_OF_MEASURE MUM1
              WHERE RL.REQUISITION_LINE_ID   =  RD.REQUISITION_LINE_ID
              AND   RL.REQUISITION_HEADER_ID = RH.REQUISITION_HEADER_ID
              AND   RL.ITEM_ID               =  SI.INVENTORY_ITEM_ID
              AND   RL.SOURCE_ORGANIZATION_ID = SI.ORGANIZATION_ID
              AND   RL.UNIT_MEAS_LOOKUP_CODE = MUM.UNIT_OF_MEASURE
              --<INVCONV R12 START>AND   RL.SECONDARY_UNIT_OF_MEASURE = MUM1.UNIT_OF_MEASURE(+) /* B1548597 OPM */
              AND   RL.DELIVER_TO_LOCATION_ID = LA.LOCATION_ID
              AND   RL.REQUISITION_LINE_ID = l_req_line_id
              AND   nvl(LA.ORG_ID, -1) = l_op_unit_id;

              l_req_line_number := l_req_line_number+1 ; --Bug #12576879

          END IF;  /* END if for l_error_flag <> 'Y'     */

        END LOOP;
        CLOSE REQ_LINES;

 	Fnd_File.Put_Line(FND_FILE.LOG, '-----');

 /* Update transferred_to_oe_flag for all rows processed  */

      UPDATE PO_REQUISITION_HEADERS
         SET TRANSFERRED_TO_OE_FLAG =
              DECODE(TRANSFERRED_TO_OE_FLAG,'I','Y','E','N')
         WHERE  TRANSFERRED_TO_OE_FLAG IN ('I', 'E');

--Bug7699084 Update the transferred to oe flag of the corresponding line too

FOR i IN 1..l_req_hdr_id_tbl.Count
LOOP
        UPDATE po_requisition_lines prl
        SET    prl.transferred_to_oe_flag =
               (SELECT prh.transferred_to_oe_flag
               FROM   po_requisition_headers prh
               WHERE  prh.requisition_header_id = l_req_hdr_id_tbl(i)
               )
        WHERE  prl.requisition_header_id = l_req_hdr_id_tbl(i)
and    prl.source_type_code = 'INVENTORY'
 	          and    nvl(prl.cancel_flag,'N') = 'N'
 	          and    nvl(prl.closed_code,'OPEN') <> 'FINALLY CLOSED';

END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updated the TRANSFERRED_TO_OE_FLAG of the corresponding lines');

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating TRANSFERRED_TO_OE_FLAG of '||to_char(SQL%ROWCOUNT)|| ' Requisitions');

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Create Internal Sales Order');

EXCEPTION
	WHEN OTHERS THEN
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unhandled Exception : '||sqlerrm);
/* Bug # 1653150
   Raised a Exception if the process fails for Some reason */
            raise;
END;

/*-----------------------------------------------------------------------------
PROCEDURE NAME: GET_OPUNIT_DETAILS
Beginning procedure get_curr_opunit_details
This procedure gets the details of the currency_code, order type
and the price list details for every operating unit
---------------------------------------------------------------------------*/

PROCEDURE GET_OPUNIT_DETAILS(l_op_unit_id IN number,
                             l_error_flag IN OUT NOCOPY varchar2,
                             l_currency_code OUT NOCOPY varchar2,
                             l_ot_id out NOCOPY number,
                             l_pr_id out NOCOPY number,
                             l_ac_id out NOCOPY number,
                             l_ir_id out NOCOPY number) IS

BEGIN
  /* get currency_code form GL sets of books,This should
     return one row, if not return error and exit subroutine */

   BEGIN

     Fnd_File.Put_Line(FND_FILE.LOG, 'Selecting Currency Code');

     SELECT  glsob.CURRENCY_CODE
     INTO    l_currency_code
     FROM    GL_SETS_OF_BOOKS GLSOB,
             FINANCIALS_SYSTEM_PARAMS_ALL FSP
     WHERE   GLSOB.SET_OF_BOOKS_ID=FSP.SET_OF_BOOKS_ID
     AND     nvl(FSP.org_id,-1) = l_op_unit_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,  'CURRENCY_CODE NOT SET');
       l_error_flag := 'Y';
       return;
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in Currency Code retrieval');
       l_error_flag := 'Y';
       return;

   END;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Currency Code : ' || l_currency_code);

   BEGIN

       Fnd_File.Put_Line(FND_FILE.LOG, 'Selecting Order Type');

       SELECT ORDER_TYPE_ID
       INTO l_ot_id
       FROM  PO_SYSTEM_PARAMETERS_ALL
       WHERE nvl(ORG_ID,-1) = l_op_unit_id;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,  'System Parameters not found');
          l_error_flag := 'Y';
          return;
       WHEN OTHERS THEN
          Fnd_File.Put_Line(FND_FILE.LOG, 'Error selecting order type');
          l_error_flag := 'Y';
          return;

   END;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Type ID:'||to_char(l_ot_id));

   BEGIN

      Fnd_File.Put_Line(FND_FILE.LOG, 'Selecting Price List from Order Type');

      SELECT  PRICE_LIST_ID,
              ACCOUNTING_RULE_ID,
              INVOICING_RULE_ID
      INTO
              l_pr_id,
              l_ac_id,
              l_ir_id
      FROM    OE_TRANSACTION_TYPES_ALL
      WHERE   transaction_type_id  = l_ot_id
      AND     nvl(ORG_ID, -1) = l_op_unit_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('PO', 'PO_CISO_NO_OE_INFO');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No OE Information');
 --       l_error_flag := 'Y';     Do not throw error  if the Order type is not set in Purchasing options
        return;
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error selecting OE Information');
        l_error_flag := 'Y';
        return;

   END;

END;

--<INVCONV R12 START>
--
-- OPM INVCONV  umoogala  Process-Discrete Transfers Enh.
-- Added x_dest_organization_id and qty parameters.
-- For these transfer, call new routine to get transfer price.
--
-- 14-Oct-2008 Uday Phadtare Bug 7462235: Changed org_information2
-- to org_information3 to fetch Operating Unit Id.

FUNCTION  GET_CST_PRICE(x_item_id              IN     NUMBER,
                        x_organization_id      IN     NUMBER,
                        x_unit_of_measure      IN     VARCHAR2,
                        x_dest_organization_id IN     NUMBER,
                        x_quantity             IN     NUMBER)
RETURN NUMBER IS

x_progress      VARCHAR2(3);
x_primary_cost  NUMBER      := NULL;
x_primary_uom   VARCHAR2(25);
x_cost_price    NUMBER;

v_opm_item_id	NUMBER := NULL;
--<INVCONV R12 START>
l_src_org_id 	              BINARY_INTEGER;
l_dest_org_id 	            BINARY_INTEGER;
l_from_ou   	              BINARY_INTEGER;
l_to_ou   	                BINARY_INTEGER;

l_src_process_enabled_flag  VARCHAR(1);
l_dest_process_enabled_flag VARCHAR(1);
l_transfer_type             VARCHAR2(10) := 'INTORD';

x_unit_price                NUMBER := 0;
x_unit_price_priuom         NUMBER := 0;
x_incr_transfer_price       NUMBER;
x_incr_currency_code        VARCHAR2(4);
x_currency_code             VARCHAR2(4);
x_return_status	            NUMBER;
x_msg_data                  VARCHAR2(4000);
x_msg_count                 NUMBER;

x_cost_method               VARCHAR2(10);
x_cost_component_class_id   NUMBER;
x_cost_analysis_code        VARCHAR2(10);
x_no_of_rows                NUMBER;
l_ret_val                   NUMBER;
l_uom_code                  mtl_material_transactions.transaction_uom%TYPE;
--<INVCONV R12 END>

l_return_status VARCHAR2(10);


BEGIN

   x_progress := '010';

   --<INVCONV R12 START>
   /*
   ** Obtain the cost price for the specified
   ** item and organization. This price is
   ** in the primary unit of measure.
   */
 --============================================================
  -- OPM INVCONV  umoogala  10-Feb-2005
  -- For process-discrete and vice-versa internal orders
  -- (within/across OUs), call new transfer_price API and
  -- stamp it as unit_price.
  -- For process/process orders, call gmf_cmcommon routine
  -- to get unit price.
  -- No change for discrete/discrete orders.
  --============================================================

  l_src_org_id 	:= x_organization_id;
  l_dest_org_id := x_dest_organization_id;

  SELECT NVL(src.process_enabled_flag,'N'), NVL(dest.process_enabled_flag,'N')
    INTO l_src_process_enabled_flag, l_dest_process_enabled_flag
    FROM mtl_parameters src, mtl_parameters dest
   WHERE src.organization_id  = l_src_org_id
     AND dest.organization_id = l_dest_org_id;


  IF (l_src_process_enabled_flag <> l_dest_process_enabled_flag)
  OR (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y')
  THEN
    -- for process-discrete and vice-versa orders. Call get transfer price API
    -- for process-process orders. Call get cost API

    IF (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'N')
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVCONV: This is a process-to-discrete internal order transfer');
    ELSIF (l_src_process_enabled_flag = 'N' AND l_dest_process_enabled_flag = 'Y')
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVCONV: This is a discrete-to-process internal order transfer');
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVCONV: This is a process-to-process internal order transfer');
    END IF;

    -- get the from ou and to ou
    -- Bug 7462235 - Changed org_information2 to org_information3 to fetch OU Id
    SELECT to_number(src.org_information3) src_ou, to_number(dest.org_information3) dest_ou
      INTO l_from_ou, l_to_ou
      FROM hr_organization_information src, hr_organization_information dest
     WHERE src.organization_id = l_src_org_id
       AND src.org_information_context = 'Accounting Information'
       AND dest.organization_id = l_dest_org_id
       AND dest.org_information_context = 'Accounting Information';

    IF (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y') AND
       (l_from_ou = l_to_ou)
    THEN
    -- process/process within same OU

      l_ret_val := GMF_CMCOMMON.Get_Process_Item_Cost (
                       1.0
                     , 'T'
                     , l_return_status
                     , x_msg_count
                     , x_msg_data
                     , x_item_id
                     , l_src_org_id
                     , sysdate
                     , 1          -- return unit_price
                     , x_cost_method
                     , x_cost_component_class_id
                     , x_cost_analysis_code
                     , x_unit_price
                     , x_no_of_rows
                   );

      IF l_ret_val <> 1
      THEN
        RETURN 0;
      END IF;

      RETURN x_unit_price;

    ELSE

      -- process to discrete or descrete to process or process to process across OUs
      -- then invoke transfer price API
      -- pmarada bug 4687787

      SELECT uom_code
        INTO l_uom_code
        FROM mtl_units_of_measure
       WHERE unit_of_measure = x_unit_of_measure
      ;

      GMF_get_transfer_price_PUB.get_transfer_price (
          p_api_version             => 1.0
        , p_init_msg_list           => 'T'

        , p_inventory_item_id       => x_item_id
        , p_transaction_qty         => x_quantity
        , p_transaction_uom         => l_uom_code

        , p_transaction_id          => NULL
        , p_global_procurement_flag => 'N'
        , p_drop_ship_flag          => 'N'

        , p_from_organization_id    => l_src_org_id
        , p_from_ou                 => l_from_ou
        , p_to_organization_id      => l_dest_org_id
        , p_to_ou                   => l_to_ou

        , p_transfer_type           => 'INTORD'
        , p_transfer_source         => 'INTREQ'

        , x_return_status           => l_return_status
        , x_msg_data                => x_msg_data
        , x_msg_count               => x_msg_count

        , x_transfer_price          => x_unit_price
        , x_transfer_price_priuom   => x_unit_price_priuom
        , x_currency_code           => x_currency_code
        , x_incr_transfer_price     => x_incr_transfer_price  /* not used */
        , x_incr_currency_code      => x_incr_currency_code  /* not used */
        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR
         x_unit_price IS NULL
      THEN
        x_unit_price    := 0;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVCONV: Transfer Price = ' || x_unit_price);
      RETURN x_unit_price;

    END IF;
    --<INVCONV R12 END>
  ELSE

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVCONV: This is a discrete-discrete internal order transfer');
   po_items_sv2.get_item_cost (x_item_id,
                               x_organization_id,
                               x_primary_cost);
  END IF;

   /*
   ** If the primary cost is zero there is
   ** no need to continue with the conversion.
   */

   IF (x_primary_cost = 0) THEN

     x_cost_price := x_primary_cost;

   ELSE

     /*
     ** Obtain the primary unit of measure
     ** for the item.
     */

     x_progress := '020';

     SELECT primary_unit_of_measure
     INTO   x_primary_uom
     FROM   mtl_system_items
     WHERE  inventory_item_id = x_item_id
     AND    organization_id   = x_organization_id;

     /*
     ** If the primary unit of measure is
     ** the same as the unit of measure
     ** passed to this procedure then the cost
     ** does not have to be converted.
     */

      IF (x_primary_uom = x_unit_of_measure) THEN

          x_cost_price := x_primary_cost;

      ELSE

          IF (po_uom_sv2.convert_inv_cost(x_item_id,
                                    x_unit_of_measure,
                                    x_primary_uom,
                                    x_primary_cost,
                                    x_cost_price) = TRUE) then

             x_cost_price := x_cost_price;

          ELSE

             x_cost_price := 0;

          END IF;

      END IF;

   END IF;

   return(x_cost_price);


 EXCEPTION

    WHEN OTHERS THEN

       x_cost_price := 0;
       return(x_cost_price);


END GET_CST_PRICE;

END PO_CREATE_ISO;

/
