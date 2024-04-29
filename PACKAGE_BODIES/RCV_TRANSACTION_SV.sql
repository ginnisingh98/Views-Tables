--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTION_SV" AS
/* $Header: RCVTXPQB.pls 120.5.12010000.5 2010/02/02 09:39:26 honwei ship $ */

PROCEDURE DISTRIBUTION_DETAIL( x_rcv_transaction_id           IN NUMBER,
                               x_destination_type_code       OUT NOCOPY VARCHAR2,
                               x_destination_context         OUT NOCOPY VARCHAR2,
                               x_destination_type_dsp        OUT NOCOPY VARCHAR2,
                               x_wip_entity_id               OUT NOCOPY NUMBER,
                               x_wip_line_id                 OUT NOCOPY NUMBER,
                               x_wip_repetitive_schedule_id  OUT NOCOPY NUMBER,
                               x_deliver_to_person_id        OUT NOCOPY NUMBER,
                               x_deliver_to_location_id      OUT NOCOPY NUMBER,
                               x_po_distribution_id          OUT NOCOPY NUMBER,
                               v_currency_conv_rate          IN OUT NOCOPY NUMBER,
                               v_currency_conv_date          IN OUT NOCOPY DATE,
-- <RCV ENH FPI START>
                               x_kanban_card_number     OUT NOCOPY VARCHAR2,
                               x_project_number         OUT NOCOPY VARCHAR2,
                               x_task_number            OUT NOCOPY VARCHAR2,
                               x_charge_account         OUT NOCOPY VARCHAR2) is
-- <RCV ENH FPI END>


  x_progress  VARCHAR2(3) := NULL;

-- <RCV ENH FPI START>
  l_code_combination_id PO_DISTRIBUTIONS.code_combination_id%TYPE;
-- <RCV ENH FPI END>

x_project_id   PO_DISTRIBUTIONS.project_id%type; -- bug 5220069
x_task_id      PO_DISTRIBUTIONS.task_id%type;    -- bug 5220069
begin
  x_progress := 10;

  /* Bug 4753498: Replaced pa_tasks_expend_v with pa_tasks in following query */

  select pod.destination_type_code,
         pod.destination_type_code,
         plc.displayed_field,
         pod.wip_entity_id,
         pod.wip_line_id,
         pod.wip_repetitive_schedule_id,
         pod.deliver_to_person_id,
         pod.deliver_to_location_id,
         pod.po_distribution_id,
         round(pod.rate,28),   -- Bug 409020
         pod.rate_date, -- Bug 409020
         mkc.kanban_card_number,  -- <RCV ENH FPI>
         pod.project_id,          -- bug 5220069
         pod.task_id,             -- bug 5220069
         pod.code_combination_id
  into   x_destination_type_code,
         x_destination_context,
         x_destination_type_dsp,
         x_wip_entity_id,
         x_wip_line_id,
         x_wip_repetitive_schedule_id,
         x_deliver_to_person_id,
         x_deliver_to_location_id,
         x_po_distribution_id,
         v_currency_conv_rate,
         v_currency_conv_date,
         x_kanban_card_number,   -- <RCV ENH FPI>
         x_project_id,       -- bug 5220069
         x_task_id,          -- bug 5220069
         l_code_combination_id   -- <RCV ENH FPI>
  from   po_distributions pod,
         po_lookup_codes plc,
         mtl_supply ms,
         mtl_kanban_cards mkc   -- <RCV ENH FPI>
  where  ms.supply_type_code    = 'RECEIVING'
  and    ms.supply_source_id    = x_rcv_transaction_id
  and    pod.po_distribution_id = ms.po_distribution_id
  and    plc.lookup_type        = 'RCV DESTINATION TYPE'
  and    plc.lookup_code        = pod.destination_type_code
  AND    pod.kanban_card_id = mkc.kanban_card_id (+);    -- <RCV ENH FPI>

-- <RCV ENH FPI START>
  x_progress := 20;
   /* Bug 5220069 START
      Due to performance problems because of outer joins on project_id and
      task_id related conditions in the above sql, writing a separate select
      to retrieve the project and task numbers. This sql will be executed
      only when project/task references are there in the PO distribution.
   */

   x_project_number  := NULL;
   x_task_number     := NULL;
   IF (x_project_id is not null AND x_task_id is not null) THEN
      BEGIN
         x_progress  := 21;
         select PPA.SEGMENT1 PROJECT_NUMBER ,
                PT.TASK_NUMBER
         into   x_project_number,
                x_task_number
         from   PA_PROJECTS_ALL PPA,
                PA_TASKS PT
         where PPA.PROJECT_ID = PT.PROJECT_ID
              and PPA.project_id = x_project_id
              and PT.task_id = x_task_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_project_number  := NULL;
            x_task_number     := NULL;
       END;
   --Bug  9080608 When the project_id is not null but task id is null we should retieve only project info.
 	ELSIF (  X_project_id IS NOT NULL AND X_task_id IS NULL ) THEN

 	       Begin
 	          select SEGMENT1 PROJECT_NUMBER
 	           into x_project_number
 	           from PA_PROJECTS_ALL
 	          where project_id = X_project_id;
 	       Exception
 	          when no_data_found then
 	             x_project_number  := NULL;
 	       End;
  END IF;

  x_progress  := 23;
  IF x_project_id is not null AND x_project_number is null THEN --if x_project_number is still null then it could be in PJM_SEIBAN_NUMBERS
     BEGIN
        x_progress  := 25;
        select PSN.PROJECT_NUMBER ,
               NULL
        into   x_project_number,
               x_task_number
        from   PJM_SEIBAN_NUMBERS PSN
        where  PSN.project_id = x_project_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_project_number  := NULL;
            x_task_number     := NULL;
       END;
  END IF;
  x_progress  := 30;
   /* Bug 5220069 END */

  x_charge_account :=
      PO_COMPARE_REVISIONS.get_charge_account(l_code_combination_id);
-- <RCV ENH FPI END>

  EXCEPTION
    when others then
      po_message_s.sql_error('DISTRIBUTION_DETAIL',x_progress,sqlcode);
      raise;
end DISTRIBUTION_DETAIL;

FUNCTION GET_RECEIVING_DISPLAY_VALUE RETURN VARCHAR2 IS
  x_receiving VARCHAR2(80);
  x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;
  select displayed_field
  into   x_receiving
  from   po_lookup_codes
  where  lookup_type = 'RCV DESTINATION TYPE'
  and    lookup_code = 'RECEIVING';

  RETURN(x_receiving);

  EXCEPTION
   when others then
     po_message_s.sql_error('GET_RECEIVING_DISPLAY_VALUE ',x_progress,sqlcode);
     raise;
end GET_RECEIVING_DISPLAY_VALUE;

FUNCTION GET_LOCATION (x_location_id  IN NUMBER, x_line_location_id IN NUMBER) RETURN VARCHAR2 IS

  x_progress      VARCHAR2(3) := NULL;

/** PO UTF8 Column Expansion Project 9/23/2002 tpoon **/
/** Changed x_location_code to use %TYPE **/
--  x_location_code VARCHAR2(30);
  x_location_code hr_locations_all.location_code%TYPE;

/* bug2199615 */
  x_oe_line_id    NUMBER;
BEGIN


/* bug fix : 2199615 - regression from 2288234
   fix for 2288234 caused regression - removed lot of code from version 115.13
   for clarity. Replaced bad code that caused regression with call to OE api to
   check if drop_ship
*/

  x_progress := 10;

  x_oe_line_id := OE_DROP_SHIP_GRP.PO_Line_Location_Is_Drop_Ship(x_line_location_id);

  IF (x_oe_line_id IS NOT NULL) THEN          /* drop ship */
    SELECT substr(rtrim(address1) || '-' || rtrim(city),1,20)
    INTO   x_location_code
    FROM   hz_locations
    WHERE  location_id = x_location_id;
  ELSE                                   /* not a drop ship */
    SELECT location_code
    INTO   x_location_code
    FROM   hr_locations
    WHERE  location_id = x_location_id;
  END IF;

  RETURN (x_location_code);
EXCEPTION
/*Begin Bug 3284237. Added the exception part.Drop ship created in 11.0 and then
  customer upgraded to 11i*/
  when no_data_found then
    BEGIN
     if (x_oe_line_id IS NOT NULL) THEN
      select location_code
      into  x_location_code
      from  hr_locations
      where  location_id               = x_location_id;
       RETURN(x_location_code);
     end if;
    END;
/*End Bug 3284237*/
  WHEN OTHERS THEN
    po_message_s.sql_error('GET_LOCATION',x_progress,sqlcode);

END GET_LOCATION;

FUNCTION GET_DELIVER_PERSON (x_employee_id  IN NUMBER) RETURN VARCHAR2 IS

  x_progress      VARCHAR2(3) := NULL;
  x_name          VARCHAR2(240);

BEGIN
  x_progress := 10;

  -- Bug 8270296

  /*select full_name
  into   x_name
  from   per_employees_current_x    -- Bug 7257731: Changed the view name from hr_employees to per_employees_current_x
  where  employee_id = x_employee_id; */

  SELECT full_name
    INTO x_name
    FROM per_workforce_current_x   -- Changed the view name from per_employees_current_x to per_workforce_current_x
   WHERE person_id = x_employee_id
     AND ROWNUM = 1;

  -- End of Bug 8270296

  RETURN(x_name);

  EXCEPTION
    when others then
    po_message_s.sql_error('GET_DELIVER_PERSON',x_progress,sqlcode);
    raise;
end GET_DELIVER_PERSON;

PROCEDURE HAZARD_CLASS_INFO (x_hazard_id    IN  NUMBER,
                             x_hazard_class OUT NOCOPY VARCHAR2) is
  x_progress VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;
  select hazard_class
  into   x_hazard_class
  from   po_hazard_classes
  where  hazard_class_id = x_hazard_id;
  EXCEPTION
   when others then
     po_message_s.sql_error('HAZARD_CLASS_INFO',x_progress,sqlcode);
     raise;
end HAZARD_CLASS_INFO;

PROCEDURE UN_NUMBER_INFO (x_un_number_id   IN NUMBER,
                          x_un_number     OUT NOCOPY VARCHAR2) is
  x_progress VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;
  select un_number
  into   x_un_number
  from   po_un_numbers
  where  un_number_id = x_un_number_id;
  EXCEPTION
  when others then
     po_message_s.sql_error('UN_NUMBER_INFO',x_progress,sqlcode);
     raise;
end UN_NUMBER_INFO;

PROCEDURE  DEFAULT_SUBINV_LOCATOR (x_subinventory  IN OUT NOCOPY VARCHAR2 ,
                                   x_item_id       IN     NUMBER,
                                   x_org_id        IN     NUMBER,
                                   x_po_distribution_id IN NUMBER,
                                   x_oe_order_line_id IN NUMBER,
                                   x_locator_id   OUT NOCOPY     NUMBER ) is
  x_progress   VARCHAR2(3) := NULL;
begin
  if x_subinventory is null then
    x_progress := 10;

    -- Need this if condition for rma receipts

    if X_po_distribution_id is not null then
      select destination_subinventory
      into   x_subinventory
      from   po_distributions
      where  po_distribution_id = X_po_distribution_id;

    -- Bug 3378162: for rma receipts, default subinventory from oe line.
    elsif x_oe_order_line_id is not null then
        select subinventory
        into   x_subinventory
        from   oe_order_lines_all
        where  line_id = x_oe_order_line_id;
    end if;

    IF  x_subinventory is null then

       x_progress := 20;

       select subinventory_code
       into   x_subinventory
       from   mtl_item_sub_defaults
       where  inventory_item_id = x_item_id
       and    organization_id   = x_org_id
       and    default_type      = 2;

   END IF;

  end if;
  if x_subinventory is not null then
    select locator_id
    into   x_locator_id
    from   mtl_item_loc_defaults
    where  inventory_item_id = x_item_id
    and    organization_id   = x_org_id
    and    subinventory_code = x_subinventory
    and    default_type      = 2;
  end if;

  EXCEPTION
   when no_data_found then
      null;
   when others then
     po_message_s.sql_error('DEFAULT_SUBINV_LOCATOR',x_progress,sqlcode);
     raise;
end DEFAULT_SUBINV_LOCATOR;

PROCEDURE VALIDATE_ID ( x_deliver_to_location_id IN OUT NOCOPY NUMBER,
                        x_location_id            IN OUT NOCOPY NUMBER,
                        x_deliver_to_person_id   IN OUT NOCOPY NUMBER,
                        x_subinventory           IN OUT NOCOPY VARCHAR2,
                        x_org_id                 IN     NUMBER,
                        x_date                   IN     DATE) is
  x_del_loc_val VARCHAR2(60);
  x_loc_val     VARCHAR2(60);
  x_del_per_val VARCHAR2(60);
  x_subinv      VARCHAR2(60);
  x_progress    VARCHAR2(3) := NULL;
begin
  x_progress := 10;
  begin

   /* 1942696*/

/** Bug#6497729:
 **  When NO_DATA_FOUND exception occurs, we are setting 'deliver to person'/'deliver to location'
 **  to Zero and this Zero is getting stored in rcv_transactions table for deliver_to_person_id
 **  and deliver_to_location_id and causes data corruption.
 **  So, we have set 'null' instead of setting it to Zero and we have to fire queries,
 **  only if 'deliver to person'/'deliver to location' is not null.
 */
   begin
      if x_deliver_to_location_id is not null then--Bug#6497729
       select 'Check to see if deliver_to_location_id is valid'
       INTO   x_del_loc_val
       from   hr_locations
       WHERE  nvl(inventory_organization_id,x_org_id) =  x_org_id
       AND    (inactive_date IS NULL
              OR
              inactive_date > x_date)
       AND    location_id = x_deliver_to_location_id;
      end if;--Bug#6497729
   exception
   when NO_DATA_FOUND then
       select 'Check to see if deliver_to_location_id is valid'
       INTO   x_del_loc_val
       from   hz_locations
       WHERE    (address_expiration_date IS NULL
         OR
         address_expiration_date > x_date)
       AND    location_id = x_deliver_to_location_id;

   end;

    EXCEPTION
      when no_data_found then
        x_deliver_to_location_id := null;--Bug#6497729
      when others then
        po_message_s.sql_error('VALIDATE_ID',x_progress,sqlcode);
        raise;
  END;

  x_progress := 20;

  /* 1942696*/
  begin
   begin
      if x_location_id is not null then--Bug#6497729
        select 'Check to see if location_id is valid'
        into   x_loc_val
        from   hr_locations
        WHERE  nvl(inventory_organization_id,x_org_id) =  x_org_id
        AND    receiving_site_flag = 'Y'
        AND    (inactive_date IS NULL
               OR
              inactive_date > x_date)
        AND    location_id = x_location_id;
      end if;--Bug#6497729
   exception
   when NO_DATA_FOUND then
       select 'Check to see if location_id is valid'
       into   x_loc_val
       from   hz_locations
       WHERE    (address_expiration_date IS NULL
         OR
       address_expiration_date > x_date)
       AND    location_id = x_location_id;
   end;

  EXCEPTION
    when no_data_found then
      x_location_id := null;--Bug#6497729
    when others then
      po_message_s.sql_error('VALIDATE_ID',x_progress,sqlcode);
      raise;
  END;

  x_progress := 30;
  BEGIN

      /* Replace view hr_employees_current_v with view
         per_workforce_current_x to enable requester from
	 another BG for bug 9157396
      */
    if x_deliver_to_person_id is not null then--Bug#6497729
       select 'Check to see if deliver_to_person_id is valid'
       into   x_del_per_val
       from   per_workforce_current_x
       WHERE (termination_date IS NULL
              OR
              termination_date > x_date)
       AND    person_id = x_deliver_to_person_id;
    end if;--Bug#6497729
    EXCEPTION
      when no_data_found then
        x_deliver_to_person_id := null;--Bug#6497729
      when others then
        po_message_s.sql_error('VALIDATE_ID',x_progress,sqlcode);
        raise;
  END;

  BEGIN
    x_progress := 40;
    select 'Check to see if subinventory is valid'
    into   x_subinv
    from   mtl_secondary_inventories
    WHERE (disable_date IS NULL
         OR
           disable_date > x_date)
    AND    organization_id = x_org_id
    AND    secondary_inventory_name = x_subinventory;

    EXCEPTION
      when no_data_found then
        x_subinventory := '';
      when others then
        po_message_s.sql_error('VALIDATE_ID',x_progress,sqlcode);
        raise;
  END;


end VALIDATE_ID;

FUNCTION LOCATOR_TYPE (x_org_id IN NUMBER ,
                       x_subinv IN VARCHAR2) RETURN VARCHAR2 is
  x_progress     VARCHAR2(3) := NULL;
  x_locator_type VARCHAR2(30);
begin
  x_progress := 10;
  select locator_type
  into   x_locator_type
  from   mtl_secondary_inventories
  where  organization_id = x_org_id
  and    secondary_inventory_name = x_subinv;
  RETURN(x_locator_type);
  EXCEPTION
    when no_data_found then
    RETURN(NULL);
    when others then
    po_message_s.sql_error('LOCATOR_TYPE',x_progress,sqlcode);
    raise;
end LOCATOR_TYPE;

--Bug#2109106. This function has been overloaded.
  procedure POST_QUERY ( x_transaction_id                IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_shipment_header_id            IN NUMBER,
                         x_shipment_line_id              IN NUMBER,
                         x_po_line_location_id           IN NUMBER,
                         x_po_line_id                    IN NUMBER,
                         x_po_header_id                  IN NUMBER,
                         x_po_release_id                 IN NUMBER,
                         x_vendor_id                     IN NUMBER,
                         x_item_id                       IN NUMBER,
                         x_item_revision                 IN VARCHAR2,
                         x_transaction_date              IN DATE,
                         x_creation_date                 IN DATE,
                         x_location_id                   IN NUMBER,
                         x_subinventory                  IN VARCHAR2,
                         x_destination_type_code         IN VARCHAR2,
                         x_destination_type_dsp          IN VARCHAR2,
                         x_primary_uom                   IN VARCHAR2,
                         x_routing_id                   IN NUMBER,
          x_po_distribution_id           IN OUT NOCOPY NUMBER,
                         x_final_dest_type_code         IN OUT NOCOPY VARCHAR2,
                         x_final_dest_type_dsp          IN OUT NOCOPY VARCHAR2,
                         x_final_location_id            IN OUT NOCOPY NUMBER,
                         x_final_subinventory           IN OUT NOCOPY VARCHAR2,
                         x_destination_context          IN OUT NOCOPY VARCHAR2,
                         x_wip_entity_id                IN OUT NOCOPY NUMBER,
                         x_wip_line_id                  IN OUT NOCOPY NUMBER,
                         x_wip_repetitive_schedule_id   IN OUT NOCOPY NUMBER,
                         x_outside_processing           IN OUT NOCOPY VARCHAR2,
                         x_job_schedule_dsp             IN OUT NOCOPY VARCHAR2,
                         x_op_seq_num_dsp               IN OUT NOCOPY VARCHAR2,
                         x_department_code              IN OUT NOCOPY VARCHAR2 ,
                         x_production_line_dsp          IN OUT NOCOPY VARCHAR2,
                         x_bom_resource_id              IN OUT NOCOPY NUMBER,
                         x_final_deliver_to_person_id   IN OUT NOCOPY NUMBER,
                         x_final_deliver_to_location_id IN OUT NOCOPY NUMBER,
                         x_person                       IN OUT NOCOPY VARCHAR2,
                         x_location                     IN OUT NOCOPY VARCHAR2,
                         x_hazard_class                 IN OUT NOCOPY VARCHAR2,
                         x_un_number                    IN OUT NOCOPY VARCHAR2,
                         x_sub_locator_control          IN OUT NOCOPY VARCHAR2 ,
                         x_count                        IN OUT NOCOPY NUMBER ,
                         x_locator_id                   IN OUT NOCOPY NUMBER ,
                         x_available_qty                IN OUT NOCOPY NUMBER,
                         x_primary_available_qty        IN OUT NOCOPY NUMBER,
                         x_tolerable_qty                IN OUT NOCOPY NUMBER ,
                         x_uom                          IN OUT NOCOPY VARCHAR2,
                         x_count_po_distribution        IN OUT NOCOPY NUMBER,
                         x_receiving_dsp_value          IN OUT NOCOPY VARCHAR2,
          x_po_operation_seq_num    IN OUT NOCOPY NUMBER,
          x_po_resource_seq_num     IN OUT NOCOPY NUMBER,
                         x_currency_conv_rate           IN OUT NOCOPY NUMBER,
                         x_currency_conv_date           IN OUT NOCOPY DATE,
                         x_oe_order_line_id             IN NUMBER ,
         /* Bug# 1548597 */
                         x_secondary_available_qty      IN OUT NOCOPY NUMBER,
-- <RCV ENH FPI START>
                         p_req_line_id               IN NUMBER,
                         p_req_distribution_id       IN NUMBER,
                         x_kanban_card_number        OUT NOCOPY VARCHAR2,
                         x_project_number            OUT NOCOPY VARCHAR2,
                         x_task_number               OUT NOCOPY VARCHAR2,
                         x_charge_account            OUT NOCOPY VARCHAR2
-- <RCV ENH FPI END>
                       ) is

  x_progress               VARCHAR2(3) ;
  l_creation_date          DATE;
  l_destination_type_code  VARCHAR2(30);
  l_destination_type_dsp   VARCHAR2(80);
  l_subinventory           VARCHAR2(30);
  l_deliver_to_person_id   NUMBER;
  l_po_distribution_id     NUMBER;
  l_location_id            NUMBER;
  l_deliver_to_location_id NUMBER;
  l_wip_entity_id          NUMBER;
  l_available_qty          NUMBER;
  l_primary_available_qty  NUMBER;
  l_tolerable_qty          NUMBER;
  l_locator_id             NUMBER;
  l_uom                    VARCHAR2(30);
  X_success                BOOLEAN := FALSE;
  X_project_id                 NUMBER ; -- bug 1662321
  X_task_id       NUMBER ; -- bug 1662321


-- <RCV ENH FPI START>
  l_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_dest_subinv PO_DISTRIBUTIONS.destination_subinventory%TYPE;
  l_dummy_rate PO_DISTRIBUTIONS.rate%TYPE;
  l_dummy_rate_date PO_DISTRIBUTIONS.rate_date%TYPE;
  l_dummy_person HR_EMPLOYEES.full_name%TYPE;
  l_dummy_subinv PO_REQUISITION_LINES.destination_subinventory%TYPE;
-- <RCV ENH FPI END>

  BEGIN

    /* Chk avaliable qty for the transaction */
    RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY ('TRANSFER',
                                             x_transaction_id,
                                             x_receipt_source_code,
                                             null,
                                             x_transaction_id,
                                             null,
                                             l_available_qty,
                                             l_tolerable_qty,
                                             l_uom,
                  /*Bug# 1548597 */
                                              x_secondary_available_qty);

    /* Chk if available qty greater than 0 */
    if nvl(l_available_qty,0) > 0 then

      /* Get the available qty in PRIMARY UOM */
      PO_UOM_S.UOM_CONVERT (l_available_qty,
                            l_uom,
                            x_item_id,
                            x_primary_uom,
                            l_primary_available_qty );

      /* Copy initial destination type code and destination type dsp item
         into local variables so that final updated values could be returned
      */
      l_destination_type_code := x_destination_type_code;
      l_destination_type_dsp  := x_destination_type_dsp;
      l_location_id           := x_location_id;
      l_subinventory          := x_subinventory;
      if x_receipt_source_code = 'VENDOR' then
        if l_destination_type_code = 'SINGLE' then
          x_progress := 20;
          DISTRIBUTION_DETAIL( x_transaction_id,
                               l_destination_type_code,
                               x_destination_context,
                               l_destination_type_dsp,
                               l_wip_entity_id,
                               x_wip_line_id,
                               x_wip_repetitive_schedule_id,
                               l_deliver_to_person_id,
                               l_deliver_to_location_id,
                               l_po_distribution_id,
                               x_currency_conv_rate,
                               x_currency_conv_date,
-- <RCV ENH FPI START>
                               x_kanban_card_number,
                               x_project_number,
                               x_task_number,
                               x_charge_account );
-- <RCV ENH FPI END>

          /* Get outside processing details, only if valid wip_entity_id
             has been entered
          */
          if nvl(l_wip_entity_id,0) <> 0 then
            x_progress := 30;
            RCV_CORE_S.GET_OUTSIDE_PROCESSING_INFO(l_po_distribution_id,
                                                   x_organization_id,
                                                   x_job_schedule_dsp,
                                                   x_op_seq_num_dsp,
                                                   x_department_code,
                                                   x_production_line_dsp,
                                                   x_bom_resource_id,
                             x_po_operation_seq_num,
                          x_po_resource_seq_num);
            x_outside_processing := 'Y';
          else
            x_outside_processing := 'N';
          end if;
-- <RCV ENH FPI START>
        ELSIF (l_destination_type_code = 'MULTIPLE') THEN
          x_progress := 35;

          RCV_DISTRIBUTIONS_S.get_misc_distr_info(
            x_return_status => l_status,
            p_line_location_id => x_po_line_location_id,
            p_po_distribution_id => NULL,
            x_kanban_card_number => x_kanban_card_number,
            x_project_number => x_project_number,
            x_task_number => x_task_number,
            x_charge_account => x_charge_account,
            x_deliver_to_person => x_person,
            x_job => x_job_schedule_dsp,
            x_outside_line_num => x_production_line_dsp,
            x_sequence => x_op_seq_num_dsp,
            x_department => x_department_code,
            x_dest_subinv => l_dest_subinv,
            x_rate => l_dummy_rate,
            x_rate_date => l_dummy_rate_date);

          IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

-- <RCV ENH FPI END>
        end if;

      elsif x_receipt_source_code = 'CUSTOMER' then
        -- Final destination is always inventory for rma receitps.
   x_outside_processing := 'N';
   l_destination_type_code := 'INVENTORY';
   x_destination_context := 'INVENTORY';

   select plc.displayed_field
   into l_destination_type_dsp
   from po_lookup_codes plc
   where plc.lookup_type = 'RCV DESTINATION TYPE'
   and   plc.lookup_code = l_destination_type_code;

        /* Bug#4684017.Project and task info was not getting defaulted for a RMA.
      Fix is to get the project information from OM tables */

        IF (x_oe_order_line_id IS NOT NULL) THEN

             SELECT project_id, task_id
             INTO   X_project_id,X_task_id
             FROM   oe_order_lines_all
             WHERE  line_id = x_oe_order_line_id;

                IF ( X_project_id IS NOT NULL AND
                     X_task_id IS NOT NULL ) THEN

                   Begin

                     select pa.project_number,pt.task_number
                       into x_project_number,x_task_number
                       from pjm_projects_all_v pa,
                            pa_tasks_expend_v pt
                      where pa.project_id = X_project_id
                        and pt.task_id = X_task_id
                        and pa.project_id=pt.project_id;


                     Exception
                        when no_data_found then
                        null;
                   End;

                ELSIF (  X_project_id IS NOT NULL AND
                         X_task_id IS NULL ) THEN

                     Begin
                        select project_number
                         into x_project_number
                         from pjm_projects_all_v
                        where project_id = X_project_id;

                       Exception
                          when no_data_found then
                          null;
                     End;

                END IF;

        END IF;

     /* Bug#4684017 END */

-- <RCV ENH FPI START>
      ELSIF x_receipt_source_code = 'INTERNAL ORDER' THEN

-- We do not need subinv from this procedure because it will be provided
-- from the view for this case.
        RCV_DISTRIBUTIONS_S.get_misc_req_distr_info(
          x_return_status => l_status,
          p_requisition_line_id => p_req_line_id,
          p_req_distribution_id => p_req_distribution_id,
          x_kanban_card_number => x_kanban_card_number,
          x_project_number => x_project_number,
          x_task_number => x_task_number,
          x_charge_account => x_charge_account,
          x_deliver_to_person => l_dummy_person,
          x_dest_subinv => l_dummy_subinv);

        IF (x_final_deliver_to_person_id IS NOT NULL) THEN
          l_deliver_to_person_id := x_final_deliver_to_person_id;
        END IF;

        IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

-- <RCV ENH FPI END>

      end if;

     /* Bug 2436516 - The hazard class was not getting displayed for
         multiple distributions in the Receiving Transactions form.
         The hazard class was retrieved only for single distributions.
         Modified the code to get hazard class for multiple distributions also
     */

       if nvl(x_hazard_class_id,0) <> 0 then
          x_progress := 40;
          HAZARD_CLASS_INFO (x_hazard_class_id,
                             x_hazard_class );
        end if;

      if l_destination_type_code <> 'MULTIPLE' then
        if nvl(x_un_number_id,0) <> 0 then
          x_progress := 50;
          UN_NUMBER_INFO (x_un_number_id,
                          x_un_number);
        end if;
        x_progress := 60;

   if x_receipt_source_code <> 'CUSTOMER' then

         x_count := RCV_CORE_S.GET_NOTE_COUNT (x_shipment_header_id,
                                                x_shipment_line_id,
                                                 x_po_line_location_id,
                                               x_po_line_id,
                                                x_po_release_id,
                                                x_po_header_id,
                                                      x_item_id );
   end if;

        if l_destination_type_code = 'INVENTORY' then
          x_progress := 70;
          DEFAULT_SUBINV_LOCATOR (l_subinventory,
                                  x_item_id,
                                  x_organization_id,
              l_po_distribution_id,
                                  x_oe_order_line_id,
                                  x_locator_id );

     /* Bug 3537022.
      * Get locator_id from rcv_shipment_lines for intransit
      * shipments.
     */
          x_progress := 80;

     if (x_receipt_source_code = 'INVENTORY') then
         select locator_id
         into x_locator_id
         from rcv_shipment_lines
         where shipment_line_id = x_shipment_line_id;
     end if;

    x_progress := 90;

          -- default deliver_to_location_id for rma deliver
          if x_receipt_source_code = 'CUSTOMER' then

             select haou.location_id
             into   l_deliver_to_location_id
             from   hr_all_organization_units haou
             where  haou.organization_id = (select ship_from_org_id
                                            from   oe_order_lines_all
                                            where  line_id = x_oe_order_line_id);

          end if;
        elsif x_destination_type_code = 'RECEIVING' then
          po_message_s.app_error(x_destination_type_code);
          l_subinventory := '';
          x_locator_id := NULL;

        end if;
        /* l_creation_date := x_creation_date;
        if x_transaction_date is not null then
          l_creation_date := x_transaction_date;
        end if; */
        l_creation_date := sysdate;
        x_progress := 80;
        VALIDATE_ID (l_deliver_to_location_id,
                     l_location_id,
                     l_deliver_to_person_id,
                     l_subinventory,
                     x_organization_id,
                     l_creation_date );
        x_progress := 90;
        x_sub_locator_control := LOCATOR_TYPE (x_organization_id,
                                               l_subinventory );

        --get deliver to location name
        if nvl(l_deliver_to_location_id,0) <> 0 then
          x_progress := 100;

/* bug2199615 */
          x_location := GET_LOCATION (l_deliver_to_location_id, x_po_line_location_id );
        end if;

        --get person name
        if nvl(l_deliver_to_person_id,0) <> 0 then
          x_progress := 110;
          x_person   := GET_DELIVER_PERSON (l_deliver_to_person_id);
        end if;
      else   /* Destination type = 'Multiple' */
        --retreive no_of_distributions for the shipment
        x_progress := 115;
        select count(*)
        into   x_count_po_distribution
        from   po_distributions
        where  line_location_id   = x_po_line_location_id;

      end if;

      x_progress := 120;
      x_receiving_dsp_value := GET_RECEIVING_DISPLAY_VALUE;

    end if;

    /* copy the local values to final parameters */
    x_final_dest_type_code         := l_destination_type_code;
    x_final_dest_type_dsp          := l_destination_type_dsp;
    x_final_deliver_to_person_id   := l_deliver_to_person_id;
    x_final_deliver_to_location_id := l_deliver_to_location_id;
    x_final_location_id            := l_location_id;
    x_final_subinventory           := l_subinventory;
    x_available_qty                := l_available_qty;
    x_tolerable_qty                := l_tolerable_qty;
    x_uom                          := l_uom;
    x_primary_available_qty        := l_primary_available_qty;
    x_wip_entity_id                := l_wip_entity_id;
    x_po_distribution_id           := l_po_distribution_id;

    l_subinventory := x_final_subinventory;
    l_locator_id   := x_locator_id;

    X_success := rcv_sub_locator_sv.put_away_api (
       x_po_line_location_id  ,
                 l_po_distribution_id   ,
       x_shipment_line_id     ,
                 x_receipt_source_code  ,
                 x_organization_id      ,
                 x_organization_id      ,
       x_item_id     ,
       x_item_revision  ,
       x_vendor_id               ,
       x_location_id ,
          l_deliver_to_location_id,
          l_deliver_to_person_id ,
                 x_available_qty        ,
                 l_primary_available_qty,
       x_primary_uom    ,
            x_tolerable_qty   ,
                 x_uom             ,
       x_routing_id           ,
                 l_subinventory         ,
                 l_locator_id           ,
                 x_final_subinventory   ,
                 x_locator_id);

-- <RCV ENH FPI START>
-- Want to skip all validations fro fields coming out from get_misc_distr_info.
-- Therefore the assignment are put here.

   IF (l_dest_subinv IS NOT NULL) THEN
     x_final_subinventory := l_dest_subinv;
   END IF;

-- <RCV ENH FPI END>

   IF (x_receipt_source_code <> 'CUSTOMER') THEN

      IF (l_po_distribution_id IS NOT NULL AND
          x_locator_id IS NOT NULL) THEN

          X_progress := '133';

          SELECT project_id, task_id
          INTO   X_project_id, X_task_id
          FROM   po_distributions
          WHERE  po_distribution_id = l_po_distribution_id;
      END IF;

   ELSE
             X_progress := '135';
         /* Locator field defaulting for rma's */
         IF (x_oe_order_line_id IS NOT NULL AND
           x_locator_id IS NOT NULL) THEN

           SELECT project_id, task_id
           INTO   X_project_id,X_task_id
           FROM   oe_order_lines_all
           WHERE  line_id = x_oe_order_line_id;

         END IF;

        /* Bug# 1717095 - Need to get the Currency details for the Order */

        SELECT currency_conversion_rate,currency_conversion_date
        INTO   x_currency_conv_rate,x_currency_conv_date
        FROM   rcv_transactions
        WHERE  transaction_id = x_transaction_id;

   END IF;
          /*
          ** Set the default values for the locator based on a
          ** project manufacturing call.  If the default locator
          ** does not have the project and task that is specified
          ** on the po and the locator control is dynamic then
          ** project manufacturing will create a new locator row
          ** copying all values from the existing locator row while
          ** adding the new project and task is values
          */
    /*bug 1349864 added begin and end statement. This fix was
     * made as part of the bug fix 1662321
    */
          IF X_project_id IS NOT NULL then
--                 x_sub_locator_control = 3) THEN  - fixed bug: 588172

        begin
        x_progress := '150';
             l_locator_id := X_locator_id; -- Bug 2772050
             PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(
                        X_organization_id,
                   l_locator_id, -- Bug 2772050
                        X_project_id,
                        X_task_id,
                        X_locator_id);
        exception
      when others then
         null;
        end;

           END IF;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('POST_QUERY',x_progress,sqlcode);
      raise;
  END POST_QUERY;

-- Bug#2109106. This function has been overloaded.This has been done because
--  the change done for OPM to include the parameter x_secondary_available_qty
--  breaks the inventory api call to this procedure.x_secondary_available_qty
--  has been removed from the parameters.
--  This change has been done for WMS only.

  procedure POST_QUERY ( x_transaction_id                IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_shipment_header_id            IN NUMBER,
                         x_shipment_line_id              IN NUMBER,
                         x_po_line_location_id           IN NUMBER,
                         x_po_line_id                    IN NUMBER,
                         x_po_header_id                  IN NUMBER,
                         x_po_release_id                 IN NUMBER,
                         x_vendor_id                     IN NUMBER,
                         x_item_id                       IN NUMBER,
                         x_item_revision                 IN VARCHAR2,
                         x_transaction_date              IN DATE,
                         x_creation_date                 IN DATE,
                         x_location_id                   IN NUMBER,
                         x_subinventory                  IN VARCHAR2,
                         x_destination_type_code         IN VARCHAR2,
                         x_destination_type_dsp          IN VARCHAR2,
                         x_primary_uom                   IN VARCHAR2,
                         x_routing_id                   IN NUMBER,
          x_po_distribution_id           IN OUT NOCOPY NUMBER,
                         x_final_dest_type_code         IN OUT NOCOPY VARCHAR2,
                         x_final_dest_type_dsp          IN OUT NOCOPY VARCHAR2,
                         x_final_location_id            IN OUT NOCOPY NUMBER,
                         x_final_subinventory           IN OUT NOCOPY VARCHAR2,
                         x_destination_context          IN OUT NOCOPY VARCHAR2,
                         x_wip_entity_id                IN OUT NOCOPY NUMBER,
                         x_wip_line_id                  IN OUT NOCOPY NUMBER,
                         x_wip_repetitive_schedule_id   IN OUT NOCOPY NUMBER,
                         x_outside_processing           IN OUT NOCOPY VARCHAR2,
                         x_job_schedule_dsp             IN OUT NOCOPY VARCHAR2,
                         x_op_seq_num_dsp               IN OUT NOCOPY VARCHAR2,
                         x_department_code              IN OUT NOCOPY VARCHAR2 ,
                         x_production_line_dsp          IN OUT NOCOPY VARCHAR2,
                         x_bom_resource_id              IN OUT NOCOPY NUMBER,
                         x_final_deliver_to_person_id   IN OUT NOCOPY NUMBER,
                         x_final_deliver_to_location_id IN OUT NOCOPY NUMBER,
                         x_person                       IN OUT NOCOPY VARCHAR2,
                         x_location                     IN OUT NOCOPY VARCHAR2,
                         x_hazard_class                 IN OUT NOCOPY VARCHAR2,
                         x_un_number                    IN OUT NOCOPY VARCHAR2,
                         x_sub_locator_control          IN OUT NOCOPY VARCHAR2 ,
                         x_count                        IN OUT NOCOPY NUMBER ,
                         x_locator_id                   IN OUT NOCOPY NUMBER ,
                         x_available_qty                IN OUT NOCOPY NUMBER,
                         x_primary_available_qty        IN OUT NOCOPY NUMBER,
                         x_tolerable_qty                IN OUT NOCOPY NUMBER ,
                         x_uom                          IN OUT NOCOPY VARCHAR2,
                         x_count_po_distribution        IN OUT NOCOPY NUMBER,
                         x_receiving_dsp_value          IN OUT NOCOPY VARCHAR2,
          x_po_operation_seq_num    IN OUT NOCOPY NUMBER,
          x_po_resource_seq_num     IN OUT NOCOPY NUMBER,
                         x_currency_conv_rate           IN OUT NOCOPY NUMBER,
                         x_currency_conv_date           IN OUT NOCOPY DATE,
                         x_oe_order_line_id             IN NUMBER ) IS

  x_progress               VARCHAR2(3) ;
  l_creation_date          DATE;
  l_destination_type_code  VARCHAR2(30);
  l_destination_type_dsp   VARCHAR2(80);
  l_subinventory           VARCHAR2(30);
  l_deliver_to_person_id   NUMBER;
  l_po_distribution_id     NUMBER;
  l_location_id            NUMBER;
  l_deliver_to_location_id NUMBER;
  l_wip_entity_id          NUMBER;
  l_available_qty          NUMBER;
  l_primary_available_qty  NUMBER;
  l_tolerable_qty          NUMBER;
  l_locator_id             NUMBER;
  l_uom                    VARCHAR2(30);
  X_success                BOOLEAN := FALSE;
  X_project_id             NUMBER ; -- bug 1662321
  X_task_id       NUMBER ; -- bug 1662321

-- <RCV ENH FPI START>
  l_po_kanban_card_number MTL_KANBAN_CARDS.kanban_card_number%TYPE;
  l_po_project_number PJM_PROJECTS_ALL_V.project_number%TYPE;
  l_po_task_number PA_TASKS_EXPEND_V.task_number%TYPE;
  l_po_charge_account GL_CODE_COMBINATIONS_KFV.concatenated_segments%TYPE;
-- <RCV ENH FPI END>

  BEGIN
    /* Chk avaliable qty for the transaction */

-- Bug#2109106  The parameter x_secondary_available_qty has been removed.
    RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY ('TRANSFER',
                                             x_transaction_id,
                                             x_receipt_source_code,
                                             null,
                                             x_transaction_id,
                                             null,
                                             l_available_qty,
                                             l_tolerable_qty,
                                             l_uom);

    /* Chk if available qty greater than 0 */
    if nvl(l_available_qty,0) > 0 then

      /* Get the available qty in PRIMARY UOM */
      PO_UOM_S.UOM_CONVERT (l_available_qty,
                            l_uom,
                            x_item_id,
                            x_primary_uom,
                            l_primary_available_qty );

      /* Copy initial destination type code and destination type dsp item
         into local variables so that final updated values could be returned
      */
      l_destination_type_code := x_destination_type_code;
      l_destination_type_dsp  := x_destination_type_dsp;
      l_location_id           := x_location_id;
      l_subinventory          := x_subinventory;
      if x_receipt_source_code = 'VENDOR' then
        if l_destination_type_code = 'SINGLE' then
          x_progress := 20;
          DISTRIBUTION_DETAIL( x_transaction_id,
                               l_destination_type_code,
                               x_destination_context,
                               l_destination_type_dsp,
                               l_wip_entity_id,
                               x_wip_line_id,
                               x_wip_repetitive_schedule_id,
                               l_deliver_to_person_id,
                               l_deliver_to_location_id,
                               l_po_distribution_id,
                               x_currency_conv_rate,
                               x_currency_conv_date,
-- <RCV ENH FPI START>
                               l_po_kanban_card_number,
                               l_po_project_number,
                               l_po_task_number,
                               l_po_charge_account);
-- <RCV ENH FPI END>

          /* Get outside processing details, only if valid wip_entity_id
             has been entered
          */
          if nvl(l_wip_entity_id,0) <> 0 then
            x_progress := 30;
            RCV_CORE_S.GET_OUTSIDE_PROCESSING_INFO(l_po_distribution_id,
                                                   x_organization_id,
                                                   x_job_schedule_dsp,
                                                   x_op_seq_num_dsp,
                                                   x_department_code,
                                                   x_production_line_dsp,
                                                   x_bom_resource_id,
                             x_po_operation_seq_num,
                          x_po_resource_seq_num);
            x_outside_processing := 'Y';
          else
            x_outside_processing := 'N';
          end if;
        end if;

      elsif x_receipt_source_code = 'CUSTOMER' then

   x_outside_processing := 'N';
   l_destination_type_code := 'RECEIVING';
   x_destination_context := 'RECEIVING';

   select plc.displayed_field
   into l_destination_type_dsp
   from po_lookup_codes plc
   where plc.lookup_type = 'RCV DESTINATION TYPE'
   and   plc.lookup_code = l_destination_type_code;


      end if;

      if l_destination_type_code <> 'MULTIPLE' then
        if nvl(x_hazard_class_id,0) <> 0 then
          x_progress := 40;
          HAZARD_CLASS_INFO (x_hazard_class_id,
                             x_hazard_class );
        end if;
        if nvl(x_un_number_id,0) <> 0 then
          x_progress := 50;
          UN_NUMBER_INFO (x_un_number_id,
                          x_un_number);
        end if;
        x_progress := 60;

   if x_receipt_source_code <> 'CUSTOMER' then

         x_count := RCV_CORE_S.GET_NOTE_COUNT (x_shipment_header_id,
                                                x_shipment_line_id,
                                                 x_po_line_location_id,
                                               x_po_line_id,
                                                x_po_release_id,
                                                x_po_header_id,
                                                      x_item_id );
   end if;

        if l_destination_type_code = 'INVENTORY' then

          x_progress := 70;
           DEFAULT_SUBINV_LOCATOR (l_subinventory,
                                   x_item_id,
                                   x_organization_id,
                              l_po_distribution_id,
                                   x_oe_order_line_id,
                                   x_locator_id );

     /* Bug 3537022.
      * Get locator_id from rcv_shipment_lines for intransit
      * shipments.
     */
          x_progress := 80;

     if (x_receipt_source_code = 'INVENTORY') then
         select locator_id
         into x_locator_id
         from rcv_shipment_lines
         where shipment_line_id = x_shipment_line_id;
     end if;

    x_progress := 90;
        end if;

        /* l_creation_date := x_creation_date;
        if x_transaction_date is not null then
          l_creation_date := x_transaction_date;
        end if; */
        l_creation_date := sysdate;
        x_progress := 80;
        VALIDATE_ID (l_deliver_to_location_id,
                     l_location_id,
                     l_deliver_to_person_id,
                     l_subinventory,
                     x_organization_id,
                     l_creation_date );
        x_progress := 90;
        x_sub_locator_control := LOCATOR_TYPE (x_organization_id,
                                               l_subinventory );

        --get deliver to location name
        if nvl(l_deliver_to_location_id,0) <> 0 then
          x_progress := 100;

/* bug2199615 */
          x_location := GET_LOCATION (l_deliver_to_location_id, x_po_line_location_id );
        end if;

        --get person name
        if nvl(l_deliver_to_person_id,0) <> 0 then
          x_progress := 110;
          x_person   := GET_DELIVER_PERSON (l_deliver_to_person_id);
        end if;
      else   /* Destination type = 'Multiple' */
        --retreive no_of_distributions for the shipment
        x_progress := 115;
        select count(*)
        into   x_count_po_distribution
        from   po_distributions
        where  line_location_id   = x_po_line_location_id;

      end if;

      x_progress := 120;
      x_receiving_dsp_value := GET_RECEIVING_DISPLAY_VALUE;

    end if;

    /* copy the local values to final parameters */
    x_final_dest_type_code         := l_destination_type_code;
    x_final_dest_type_dsp          := l_destination_type_dsp;
    x_final_deliver_to_person_id   := l_deliver_to_person_id;
    x_final_deliver_to_location_id := l_deliver_to_location_id;
    x_final_location_id            := l_location_id;
    x_final_subinventory           := l_subinventory;
    x_available_qty                := l_available_qty;
    x_tolerable_qty                := l_tolerable_qty;
    x_uom                          := l_uom;
    x_primary_available_qty        := l_primary_available_qty;
    x_wip_entity_id                := l_wip_entity_id;
    x_po_distribution_id           := l_po_distribution_id;

    l_subinventory := x_final_subinventory;
    l_locator_id   := x_locator_id;

    X_success := rcv_sub_locator_sv.put_away_api (
       x_po_line_location_id  ,
                 l_po_distribution_id   ,
       x_shipment_line_id     ,
                 x_receipt_source_code  ,
                 x_organization_id      ,
                 x_organization_id      ,
       x_item_id     ,
       x_item_revision  ,
       x_vendor_id               ,
       x_location_id ,
          l_deliver_to_location_id,
          l_deliver_to_person_id ,
                 x_available_qty        ,
                 l_primary_available_qty,
       x_primary_uom    ,
            x_tolerable_qty   ,
                 x_uom             ,
       x_routing_id           ,
                 l_subinventory         ,
                 l_locator_id           ,
                 x_final_subinventory   ,
                 x_locator_id);

   IF (x_receipt_source_code <> 'CUSTOMER') THEN

      IF (l_po_distribution_id IS NOT NULL AND
          x_locator_id IS NOT NULL) THEN

          X_progress := '133';

          SELECT project_id, task_id
          INTO   X_project_id, X_task_id
          FROM   po_distributions
          WHERE  po_distribution_id = l_po_distribution_id;
      END IF;

   ELSE
             X_progress := '135';
         /* Locator field defaulting for rma's */
         IF (x_oe_order_line_id IS NOT NULL AND
           x_locator_id IS NOT NULL) THEN

           SELECT project_id, task_id
           INTO   X_project_id,X_task_id
           FROM   oe_order_lines_all
           WHERE  line_id = x_oe_order_line_id;

         END IF;

        /* Bug# 1717095 - Need to get the Currency details for the Order */

        SELECT currency_conversion_rate,currency_conversion_date
        INTO   x_currency_conv_rate,x_currency_conv_date
        FROM   rcv_transactions
        WHERE  transaction_id = x_transaction_id;

   END IF;
          /*
          ** Set the default values for the locator based on a
          ** project manufacturing call.  If the default locator
          ** does not have the project and task that is specified
          ** on the po and the locator control is dynamic then
          ** project manufacturing will create a new locator row
          ** copying all values from the existing locator row while
          ** adding the new project and task is values
          */
    /*bug 1349864 added begin and end statement. This fix was
     * made as part of the bug fix 1662321
    */
          IF X_project_id IS NOT NULL then
--                 x_sub_locator_control = 3) THEN  - fixed bug: 588172

        begin
        x_progress := '150';
             l_locator_id := X_locator_id; -- Bug 2772050
             PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(
                        X_organization_id,
                   l_locator_id, -- Bug 2772050
                        X_project_id,
                        X_task_id,
                        X_locator_id);
        exception
      when others then
         null;
        end;

           END IF;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('POST_QUERY',x_progress,sqlcode);
      raise;
  END POST_QUERY;
End rcv_transaction_sv;


/
