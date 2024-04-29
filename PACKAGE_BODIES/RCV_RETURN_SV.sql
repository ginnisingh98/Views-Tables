--------------------------------------------------------
--  DDL for Package Body RCV_RETURN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RETURN_SV" AS
/* $Header: RCVTXREB.pls 120.0.12010000.3 2010/07/09 23:21:36 vthevark ship $*/

/*===========================================================================

  PROCEDURE NAME:	post_query()

===========================================================================*/

PROCEDURE  POST_QUERY (  x_transaction_id                IN NUMBER,
			 x_parent_transaction_type	 IN VARCHAR2,
                         x_destination_type_code         IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_wip_entity_id                 IN NUMBER,
                         x_wip_repetitive_schd_id        IN NUMBER,
                         x_wip_operation_seq_num         IN NUMBER,
                         x_wip_resource_seq_num          IN NUMBER,
                         x_wip_line_id                   IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_primary_uom                   IN VARCHAR2,
                         x_transaction_uom               IN VARCHAR2,
                         x_primary_transaction_qty       IN NUMBER,
                         x_item_id                       IN NUMBER,
                         x_final_location_id             IN NUMBER,
                         x_receiving_location_id         IN NUMBER,
                         x_deliver_to_person_id          IN NUMBER,
                         x_vendor_id                     IN NUMBER,
                         x_subinventory                  IN VARCHAR2,

                         x_source_document_code          IN VARCHAR2,
                         --x_inspection_status_code        IN VARCHAR2,
                         x_secondary_ordered_uom         IN VARCHAR2,
                         x_lpn_id                        IN VARCHAR2,
                         x_transfer_lpn_id               IN VARCHAR2,
                         x_po_type_code                  IN VARCHAR2,
                         x_ordered_uom                   IN VARCHAR2,
                         x_customer_id                   IN VARCHAR2,

                         x_subinv_locator_type          OUT NOCOPY VARCHAR2,
                         x_final_location               OUT NOCOPY VARCHAR2,
                         x_receiving_location           OUT NOCOPY VARCHAR2,
                         x_person                       OUT NOCOPY VARCHAR2,
                         x_supply_qty                   OUT NOCOPY NUMBER,
                         x_wip_entity_name              OUT NOCOPY VARCHAR2,
                         x_operation_seq_num            OUT NOCOPY VARCHAR2,
                         x_department_code              OUT NOCOPY VARCHAR2,
                         x_line_code                    OUT NOCOPY VARCHAR2,
                         x_hazard_class                 OUT NOCOPY VARCHAR2,
                         x_un_number                    OUT NOCOPY VARCHAR2,
                         x_vendor_name                  OUT NOCOPY VARCHAR2,

                         x_parent_transaction_type_dsp  OUT NOCOPY VARCHAR2,
                         --x_inspection_status_dsp        OUT NOCOPY VARCHAR2,
                         x_destination_type_dsp         OUT NOCOPY VARCHAR2,
                         --x_primary_uom_class            OUT NOCOPY VARCHAR2,
                         x_transaction_uom_class        OUT NOCOPY VARCHAR2,
                         x_secondary_ordered_uom_out    OUT NOCOPY VARCHAR2,
                         x_license_plate_number         OUT NOCOPY VARCHAR2,
                         x_transfer_license_plate_num   OUT NOCOPY VARCHAR2,
                         x_order_type                   OUT NOCOPY VARCHAR2,
                         x_ordered_uom_out              OUT NOCOPY VARCHAR2,
                         x_customer                     OUT NOCOPY VARCHAR2
                         ) is

   x_progress 	                VARCHAR2(3) := NULL;
   x_primary_child_qty          NUMBER;
   x_primary_child_qty_correct  NUMBER;
   x_primary_interface_qty      NUMBER;
   x_primary_supply_qty         NUMBER;
   x_primary_qty                NUMBER;

   cursor get_po_lookup_code(p_lookup_type in varchar2,p_lookup_code in varchar2) is
     select displayed_field
     from   po_lookup_codes
     where  lookup_type = p_lookup_type
     and    lookup_code = p_lookup_code
     AND    ROWNUM<=1;

   cursor get_uom_class(p_uom in varchar2) is
     select uom_class
     from   mtl_units_of_measure
     where  unit_of_measure = p_uom
     AND    ROWNUM<=1;

   cursor get_uom(p_uom_code in varchar2) is
     select unit_of_measure
     from   mtl_units_of_measure
     where  uom_code = p_uom_code
     AND    ROWNUM<=1;

/* Changed for Bug 6761395
 * Replaced Substr with Substrb to handle the conversion of bytes
 * into char in different languages.
 */
   cursor get_customer(p_customer_id in varchar2) is
     select SUBSTRB(HZP.PARTY_NAME,1,50)
     from   HZ_CUST_ACCOUNTS HZCA,
            HZ_PARTIES HZP
     where  HZCA.CUST_ACCOUNT_ID = p_customer_id
     and    HZCA.PARTY_ID = HZP.PARTY_ID
     AND    ROWNUM<=1;

   cursor get_license_plate_number(p_license_plate_id in varchar2) is
     select LICENSE_PLATE_NUMBER
     from   WMS_LICENSE_PLATE_NUMBERS
     where  LPN_ID = p_license_plate_id
     AND    ROWNUM<=1;

 x_create_shipment_flag VARCHAR2(1) := NVL(FND_PROFILE.VALUE('RCV_CREATE_SHIPMENT_FOR_RETURNS'),'N'); -- rtv project
BEGIN

   if (x_parent_transaction_type is not null) then
     open  get_po_lookup_code('RCV TRANSACTION TYPE',x_parent_transaction_type);
     fetch get_po_lookup_code into x_parent_transaction_type_dsp;
     close get_po_lookup_code;
   end if;

   /*
   if (x_inspection_status_code is not null) then
     open  get_po_lookup_code('INSPECTION STATUS',x_inspection_status_code);
     fetch get_po_lookup_code into x_inspection_status_dsp;
     close get_po_lookup_code;
   end if;
   */

   if (x_destination_type_code is not null) then
     open  get_po_lookup_code('RCV DESTINATION TYPE',x_destination_type_code);
     fetch get_po_lookup_code into x_destination_type_dsp;
     close get_po_lookup_code;
   end if;

   /*
   if (x_primary_uom is not null) then
     open  get_uom_class(x_primary_uom);
     fetch get_uom_class into x_primary_uom_class;
     close get_uom_class;
   end if;
   */

   if (x_transaction_uom is not null) then
     open  get_uom_class(x_transaction_uom);
     fetch get_uom_class into x_transaction_uom_class;
     close get_uom_class;
   end if;

   if (x_lpn_id is not null) then
     open  get_license_plate_number(x_lpn_id);
     fetch get_license_plate_number into x_license_plate_number;
     close get_license_plate_number;
   end if;

   if (x_transfer_lpn_id is not null) then
     open  get_license_plate_number(x_transfer_lpn_id);
     fetch get_license_plate_number into x_transfer_license_plate_num;
     close get_license_plate_number;
   end if;

   if (x_source_document_code = 'PO') then

     if (x_po_type_code is not null) then
       if (x_parent_transaction_type = 'UNORDERED') then
         open  get_po_lookup_code('PO TYPE','STANDARD');
       else
         open  get_po_lookup_code('PO TYPE',x_po_type_code);
       end if;
       fetch get_po_lookup_code into x_order_type;
       close get_po_lookup_code;
     end if;

     /* do not overwrite p_order_uom for PO */
     x_ordered_uom_out := x_ordered_uom;

     /* do not overwrite p_secondary_ordered_uom */
     x_secondary_ordered_uom_out := x_secondary_ordered_uom;

     /* leave customer null for PO */
     x_customer := null;

   else --x_source_document_type = 'RMA'

     /* do not overwrite x_order_type for RMA */
     x_order_type := x_po_type_code;

     if (x_ordered_uom is not null) then
       open  get_uom(x_ordered_uom);
       fetch get_uom into x_ordered_uom_out;
       close get_uom;
     end if;

     if (x_secondary_ordered_uom is not null) then
       open  get_uom(x_secondary_ordered_uom);
       fetch get_uom into x_secondary_ordered_uom_out;
       close get_uom;
     end if;

     if (x_customer_id is not null) then
       open  get_customer(x_customer_id);
       fetch get_customer into x_customer;
       close get_customer;
     end if;

   end if; --x_source_document_type = 'PO'

   /*
   ** Based on the transaction type, get maximum supply qty agst each
   ** transaction
   ** Should be using Sanjay's RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY
   ** package, but for the time being calling our own logic
   */

   if x_parent_transaction_type = 'DELIVER' then

     x_progress := 10;
     /*
     ** Sum the total of the children transactions that are not corrections.
     */
     SELECT nvl(sum(rt.primary_quantity), 0)
     INTO   x_primary_child_qty
     FROM   rcv_transactions rt
     WHERE  rt.parent_transaction_id = x_transaction_id
     AND    rt.transaction_type <> 'CORRECT';

     x_progress := 20;
     /*
     ** Sum the total of the children transactions that are corrections.
     */
     SELECT nvl(sum(rt.primary_quantity), 0)
     INTO   x_primary_child_qty_correct
     FROM   rcv_transactions rt
     WHERE  rt.parent_transaction_id = x_transaction_id
     AND    rt.transaction_type =  'CORRECT';

     x_progress := 30;
     /*
     **  must hit this table for any unprocessed transactions
     */
     SELECT nvl(sum(decode(rti.transaction_type,'CORRECT',
                                           rti.primary_quantity * -1,
                                           rti.primary_quantity )
              ),0)
     INTO   x_primary_interface_qty
     FROM   rcv_transactions_interface rti
     WHERE  rti.parent_transaction_id   = x_transaction_id
     AND    rti.processing_status_code  in ('PENDING' , 'WSH_INTERFACED') -- rtv vidya
     AND    rti.transaction_status_code = 'PENDING'
     -- rtv project : start
     AND    NOT EXISTS (select 1 from wsh_delivery_details wdd
                        where  wdd.delivery_detail_id = rti.interface_source_line_id
                        and    wdd.source_code = 'RTV'
                        and    rti.transaction_type = 'RETURN TO VENDOR'
                        and    rti.processing_status_code = 'PENDING');
     -- rtv project : end
     /*
     ** Modified on 09-20-1995 based on talk with George Kellner

     AND    rti.transaction_type NOT IN
           ('RETURN TO VENDOR', 'RETURN TO RECEIVING');
     */

     x_progress := 40;
     /*
     ** Calculate the final primary quantity
     */
     x_primary_qty := x_primary_transaction_qty - x_primary_child_qty
                    + x_primary_child_qty_correct
                    - x_primary_interface_qty;

   else

     x_progress := 50;
     /*
     **  Determine the receiving supply for the current transaction.
     */
     SELECT nvl(rs.to_org_primary_quantity,0)
     INTO   x_primary_supply_qty
     FROM   rcv_supply rs
     WHERE  rs.rcv_transaction_id = x_transaction_id;

     x_progress := 60;
     /*
     ** Determine the sum of the transactions in the interface table
     */
     SELECT nvl(sum(rti.primary_quantity),0)
     INTO   x_primary_interface_qty
     FROM   rcv_transactions_interface rti
     WHERE  rti.parent_transaction_id   = x_transaction_id
     AND    rti.processing_status_code  = 'PENDING'
     AND    rti.transaction_status_code = 'PENDING';
     /*
     ** Modified on 09-20-1995 based on talk with G.Kellner
     AND    rti.transaction_type NOT IN
           ('RETURN TO VENDOR', 'RETURN TO RECEIVING');
     */

     /*
     ** Reduce supply by the quantity in the interface table. This is
     ** the quantity that has not been transacted but should be taken
     ** into account during the return.
     */
     x_progress := 70;
     x_primary_qty := x_primary_supply_qty - x_primary_interface_qty;

   end if; /* End of transaction type */

   /*
   ** Return the available qty in transaction UOM
   */

/* Bug2794344 Uom_convert call is made only if primary uom is different
   from transaction uom to avoid quantity rounding problems
*/
   if nvl(x_primary_qty,0) > 0 then
        x_progress := 75;
	if (x_primary_uom <> x_transaction_uom ) then
     		PO_UOM_S.UOM_CONVERT ( x_primary_qty,
               		               x_primary_uom,
                                       x_item_id,
                                       x_transaction_uom,
                                       x_supply_qty);
        else
     	        x_supply_qty :=x_primary_qty;
        end if;
   end if;

   /*
   ** Check if destination type code = 'SHOP FLOOR'
   ** If shop floor, then retreive outside_processing details
   */
   if x_destination_type_code = 'SHOP FLOOR' then

     x_progress := 80;
     --Bug# 2000013 togeorge 09/18/2001
     --Eam: Split the following sql to 3 different sqls because eAM w/o would
     --     not have resource information and this sql will fail.
/*
     select we.wip_entity_name,
            wn.operation_seq_num,
            bd.department_code
     into   x_wip_entity_name,
            x_operation_seq_num,
            x_department_code
     from   wip_entities we,
            bom_departments bd,
            wip_operation_resources wr,
            wip_operations wn,
            wip_operations wo
     where  wo.wip_entity_id     = x_wip_entity_id
     and    wo.organization_id   = x_organization_id
     and    nvl(wo.repetitive_schedule_id, -1) =
            nvl(x_wip_repetitive_schd_id,-1)
     and    wo.operation_seq_num = x_wip_operation_seq_num
     and    wr.wip_entity_id     = x_wip_entity_id
     and    wr.organization_id   = x_organization_id
     and    nvl(wr.repetitive_schedule_id, -1) =
            nvl(x_wip_repetitive_schd_id,-1)
     and    wr.operation_seq_num = x_wip_operation_seq_num
     and    wr.resource_seq_num  = x_wip_resource_seq_num
     and    wn.wip_entity_id     = x_wip_entity_id
     and    wn.organization_id   = x_organization_id
     and    nvl(wn.repetitive_schedule_id, -1) =
            nvl(x_wip_repetitive_schd_id,-1)
     and    wn.operation_seq_num =
            decode(wr.autocharge_type,
                     4, nvl(wo.next_operation_seq_num, wo.operation_seq_num),
                     wo.operation_seq_num)
     and    bd.department_id     = wn.department_id
     and    we.wip_entity_id     = x_wip_entity_id
     and    we.organization_id   = x_organization_id;
*/

  if X_wip_entity_id is not null then
   x_progress := 81;
   begin
   SELECT we.wip_entity_name job
     INTO x_wip_entity_name
     FROM wip_entities we
    WHERE we.wip_entity_id = x_wip_entity_id
      AND we.organization_id = x_organization_id;
   exception
   when others then
   x_wip_entity_name := null;
   x_progress := 82;
   end;
  end if;

  if x_wip_entity_id is not null and x_wip_operation_seq_num is not null then
   x_progress := 83;
   begin
   SELECT  wn.operation_seq_num sequence,
           bd.department_code   department
     INTO  x_operation_seq_num, x_department_code
     FROM  bom_departments bd,
           wip_operation_resources wr,
           wip_operations wn,
           wip_operations wo
    WHERE  wo.wip_entity_id = x_wip_entity_id
      AND  wo.organization_id = x_organization_id
      AND  nvl(wo.repetitive_schedule_id, -1) =
           nvl(x_wip_repetitive_schd_id, -1)
      AND  wo.operation_seq_num = x_wip_operation_seq_num
      AND  wr.wip_entity_id = x_wip_entity_id
      AND  wr.organization_id = x_organization_id
      AND  nvl(wr.repetitive_schedule_id, -1) =
           nvl(x_wip_repetitive_schd_id, -1)
      AND  wr.operation_seq_num = x_wip_operation_seq_num
      AND  wr.resource_seq_num = x_wip_resource_seq_num
      AND  wn.wip_entity_id = x_wip_entity_id
      AND  wn.organization_id = x_organization_id
      AND  nvl(wn.repetitive_schedule_id, -1) =
           nvl(x_wip_repetitive_schd_id, -1)
      AND  wn.operation_seq_num =
           decode(wr.autocharge_type,  4,
               nvl(wo.next_operation_seq_num, wo.operation_seq_num),
                  wo.operation_seq_num)
      AND  bd.department_id = wn.department_id;
   exception
      when no_data_found then
       --for EAM workorders the above sql would raise no_data_found.
       --find department code and sequence with out touching resource table.
       x_progress := 84;
       begin
       select bd.department_code department
         into X_department_code
         from bom_departments bd,wip_operations wn
        where wn.wip_entity_id = x_wip_entity_id
          and wn.organization_id = x_organization_id
          and nvl(wn.repetitive_schedule_id, -1) =
    	  nvl(x_wip_repetitive_schd_id, -1)
          and bd.department_id = wn.department_id;
          exception
          when others then
          x_department_code :=null;
          x_progress := 85;
       end;

	begin
        SELECT  wo.operation_seq_num sequence
          INTO  x_operation_seq_num
          FROM  wip_operations wo
         WHERE  wo.wip_entity_id = x_wip_entity_id
           AND  wo.organization_id = x_organization_id
           AND  nvl(wo.repetitive_schedule_id, -1) =
               nvl(x_wip_repetitive_schd_id, -1)
           AND  wo.operation_seq_num = x_wip_operation_seq_num;
        exception
	 when others then
	  x_operation_seq_num := null;
          x_progress := 86;
	end;
   when others then
	 x_operation_seq_num := null;
         x_department_code :=null;
         x_progress := 87;
   end;
  end if;
  --

   end if;

   if (NVL(x_wip_line_id, -1) <> -1) then
     x_progress := 90;

     SELECT line_code
     INTO   x_line_code
     FROM   wip_lines
     WHERE  line_id         = x_wip_line_id
     AND    organization_id = x_organization_id;
  end if;

   /*
   ** Get the hazard class information if the hazard class id is
   ** not null
   */

   IF (x_hazard_class_id is NOT NULL) THEN

	x_progress := 100;

	SELECT 	hazard_class
    	INTO   	x_hazard_class
    	FROM   	po_hazard_classes
    	WHERE  	hazard_class_id = x_hazard_class_id;

   END IF;

   /*
   ** Get the UN Number info if the un number id is not null
   */

   IF (x_un_number_id is NOT NULL) THEN

	x_progress := 110;

	SELECT 	un_number
    	INTO   	x_un_number
    	FROM   	po_un_numbers
    	WHERE  	un_number_id = x_un_number_id;

   END IF;

   /*
   ** Depending on the destination type code, get the appropraite values
   */
   if NVL(x_receiving_location_id, 0) <> 0 then
    begin
     x_progress := 120;
     select location_code
     into   x_receiving_location
     from   hr_locations
     where  location_id = x_receiving_location_id;
   --Bug#2253273. Added this exception as the hr_locations view which
   --was a join of hr_locations_all and hz_locations has been changed.
   --Now hr_locations dose not contain hz_locations table.So added the
   --following condition to take care of the RMA.
     exception
      WHEN NO_DATA_FOUND then
        PO_SHIPMENTS_SV2.get_drop_ship_cust_locations(x_receiving_location_id,
x_receiving_location);
    end;
   end if;

   if NVL(x_final_location_id,0) <> 0 then
    begin
     x_progress := 130;
     select location_code
     into   x_final_location
     from   hr_locations
     where  location_id = x_final_location_id;
   --Bug#2253273.
      exception
      WHEN NO_DATA_FOUND then
        PO_SHIPMENTS_SV2.get_drop_ship_cust_locations(x_final_location_id,
x_final_location);
    end;
   end if;
/*Bug 2713129 hr_employees view doesn't contain terminated employees.Hence
  when quering the records in returns form if the deliver_to_person corresponding
  to a record is terminated the sql below is returning no data found Expection.
  Returns form should even show the records whose deliver to person
  is terminated.Hence getting the employee name from per_all_people_f.
*/
   if x_destination_type_code in ('EXPENSE','SHOP FLOOR','INVENTORY')  then

     if NVL(x_deliver_to_person_id,0) <> 0 then
       x_progress := 140;
       x_person := po_inq_sv.get_person_name(x_deliver_to_person_id);
/*
       select full_name
       into   x_person
       from   hr_employees
       where  employee_id = x_deliver_to_person_id;
*/
     end if;
  end if;

  if x_destination_type_code = 'INVENTORY'  then
     -- rtv project
     if (x_source_document_code = 'PO' AND
         x_create_shipment_flag = 'Y'  AND
         x_subinventory IS NULL) THEN
         x_progress := 143;
     else
         x_progress := 145;
         select locator_type
         into   x_subinv_locator_type
         from   mtl_secondary_inventories
         where  organization_id          = x_organization_id
         and    secondary_inventory_name = x_subinventory;
     end if;
  end if;

  if x_vendor_id is not null then
    x_progress := 150;
    SELECT v.vendor_name
    INTO   x_vendor_name
    from   po_vendors v
    where  v.vendor_id = x_vendor_id;
  end if;

EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('post_query', x_progress, sqlcode);
      RAISE;

END post_query;


END RCV_RETURN_SV;

/
