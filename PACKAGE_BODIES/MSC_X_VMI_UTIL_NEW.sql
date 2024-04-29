--------------------------------------------------------
--  DDL for Package Body MSC_X_VMI_UTIL_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_VMI_UTIL_NEW" AS
/* $Header: MSCXVMIB.pls 120.6 2005/11/06 22:25:35 pragarwa ship $ */

TP_MAP_TYPE_ORG  CONSTANT NUMBER := 2;
TP_MAP_TYPE_SITE CONSTANT NUMBER := 3;
ASCP_TP_MAP_TYPE_ORG CONSTANT NUMBER := 3;

INTERNAL_FLAG_SET CONSTANT NUMBER := 1;
INTERNAL_FLAG_NOT_SET CONSTANT NUMBER := 0;

CONSIGNED CONSTANT NUMBER := 1;
UNCONSIGNED CONSTANT NUMBER := 2;
NOT_EXISTS CONSTANT NUMBER:=-1;




TYPE Graph IS TABLE OF MSC_VMI_GRAPH%ROWTYPE;

--TYPE t_table_add_data IS TABLE OF NUMBER
   -- INDEX BY BINARY_INTEGER;
    --    t_table_add t_table_add_data  ;


---------------------------------------------------------------------------
-- the function returns details of relevent order types in string format --
-- Do not change the string format. It will impact several UI objects.   --
-- (VO/CO classes) which decode the string and render the table cells.   --
-- The string is of the format "1#2#3#4#5" where # is delimiter and      --
-- the data elements are:                                                --
-- REPLENISHMENT:                                                        --
-- 1  quantity                       38                                  --
-- 2  date                           10                                  --
-- REQUISITION:                                                          --
-- 3  total quantity                 38                                  --
-- ONHAND:                                                               --
-- 4  current onhand quantity        38                                  --
-- 5  onhand last update date        10                                  --
-- IN TRANSIT:                                                           --
-- 6  count of ASNs                  38                                  --
-- 7  total quantity                 38                                  --
-- 8  next ASN's order number       240                                  --
-- 9  next ASN's date                10                                  --
-- 10 next ASN's quantity            38                                  --
-- SHIPMENT RECEIPT:                                                     --
-- 11 last receipt's  date           10                                  --
-- 12 last receipt's quantity        38                                  --
-- OTHER:                                                                --
-- 13 what graph (gif name)          12                                  --
--    gif file name                                                      --
-- ITEM ATTRIBUTES from msc_item_suppliers/msc_system_items              --
-- 14 inventory_planning_code        38                                  --
-- 15 reorder_point                  38                                  --
-- 16 economic_order_quantity        38                                  --
-- 17 average_daily_usage            38                                  --
-- 18 customer_item_name             38                                  --
-- 19 customer_item_desc             38                                  --
-- 20 supplier_item_name             38                                  --
-- 21 supplier_item_desc             38                                  --
-- 22 inv_status(implemented quantity)38                                  --
-- 23 available_release_quantity     38                                  --
-- 24 quantity in process            38                                  --
-- 25 total receipt quantity         38                                  --
-- 26 item name
-- 27 item desc
-- 28 owner item name
-- 29 owner item desc
-- 30 min
-- 31 max
-- 32 uom conversion rate
-- 33 vmi auto repl flag
-- 34 release method flag

-- 35 ASN auto expire                1
-- 36 consigned flag                 1
-- 37 Planner User Name
---------------------------------------------------------------------------
function  vmi_details_supplier (p_sr_instance_id         in number default null
                          , p_inventory_item_id       in number default null
                          , p_customer_id             in number default null
                          , p_customer_site_id             in number default null
                          , p_supplier_id             in number default null
                          , p_supplier_site_id             in number default null
                          , p_organization_id             in number default null
                          , p_tp_supplier_id             in number default null
                          , p_tp_supplier_site_id             in number default null
                          ) return varchar2 as

  return_string         varchar2(3000);
  l_onhand_type         number := 0;
  l_onhand_quantity     number := 0;
  l_intransit_quantity  number := 0;
  l_implemented_quantity number := 0;
  l_quantity_in_process number :=0;
  l_asn_count           number := 0;
  l_available_release_quantity number;
  l_total_receipt_quantity number;
  l_on_order_quantity number;
  l_requisition_quantity number;
  l_graph_name          varchar2(30);

  l_min_minmax_quantity     number;
  l_max_minmax_quantity     number;
  l_min_minmax_days     number;
  l_max_minmax_days     number;
  l_min_minmax_quantity_vmi     number;
  l_max_minmax_quantity_vmi     number;
  l_inventory_planning_code number;
  l_reorder_point           number;
  l_economic_order_quantity number;
  l_average_daily_usage     number;

  l_owner_item_name varchar2(250);
  l_owner_item_desc varchar2(240);

  l_customer_item_name varchar2(250);
  l_customer_item_desc varchar2(240);
  l_supplier_item_name varchar2(250);
  l_supplier_item_desc varchar2(240);

  l_auto_replenish_flag varchar2(1);
  l_vmi_replenishment_approval varchar2(30);
  l_release_method number := 0;
  l_using_organization_id number;
  l_company_id number := -99;
  l_vmi_uom_code varchar2(3);
  l_vmi_unit_of_measure varchar2(25);
  l_customer_uom_code varchar2(3);
  l_customer_unit_of_measure  varchar2(25);
  l_supplier_uom_code varchar2(3);
  --l_supplier_unit_of_measure varchar2(25);
  l_conv_found boolean;
  l_conv_rate number;
  l_supplier_to_customer_rate number :=1;
  l_rtf_start_date date;
  l_rtf_end_date date;
  l_inv_status number := 0;
  l_fixed_order_quantity number;

  -- For VMI w/Customers: Not used here
  l_asn_auto_expire VARCHAR2(1);
  l_consigned       VARCHAR2(1);

  -- For VMI Suppliers
  l_replenishment_method    number;

    ------------------------------------------------
    -- check which onhand type to use
    -- onhand logic: if allocated onhand exists,  --
    -- use it (only). else use unallocated onhand --
    -- only. they are mutually exclusive.         --
    ------------------------------------------------
    cursor oh_cur is
    select 'exists'
    from   msc_sup_dem_entries
    where
    plan_id = -1
    and publisher_order_type = ALLOCATED_ONHAND
    and    customer_id = p_customer_id
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    vmi_flag = 1;

      -- replenishment details
    cursor replenish_cur is
    select round(nvl(primary_quantity,0),6) primary_quantity,
           round(nvl(tp_quantity,0),6) tp_quantity,
           --(quantity - nvl(quantity_in_process,0) - nvl(implemented_quantity,0)) available_quantity,
           to_char(receipt_date, dformat) receipt_date,
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           customer_item_name,
           customer_item_description,
           supplier_item_name,
           supplier_item_description,
           new_order_placement_date rtf_start_date,
           receipt_date rtf_end_date
    from   msc_sup_dem_entries
    where      plan_id = -1
    and    publisher_order_type = REPLENISHMENT
    and    customer_id = p_customer_id
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    release_status in (0,1)
    and    vmi_flag = 1;


-- QIP,IP in replenishment orders with release_status = 1
    cursor qip_cur is
    select round(nvl(quantity_in_process,0), 6) qip, round(implemented_quantity,6) ip
    from   msc_sup_dem_entries
    where    plan_id = -1
    and    publisher_order_type = REPLENISHMENT
    and    customer_id = p_customer_id
    and    customer_site_id = p_customer_site_id
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    release_status = 1
    and    vmi_flag = 1;
    --and    receipt_date > sysdate ;

    -- requisition details
    cursor requisition_cur is
    select round(sum(primary_quantity),6) primary_quantity,
           round(sum(tp_quantity),6) tp_quantity
    from   msc_sup_dem_entries
    where      plan_id = -1
    and      publisher_order_type in (REQUISITION, PO)
    and    customer_id = p_customer_id
    and    customer_site_id = p_customer_site_id
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    receipt_date <= nvl(l_rtf_end_date, receipt_date)
    and    vmi_flag = 1;

    -- onhand details
    cursor onhand_cur (c_onhand_type in number) is
    select nvl(round(primary_quantity,6),0) primary_quantity,
           nvl(round(tp_quantity,6),0) tp_quantity,
           to_char(new_schedule_date, dformat ) last_update_date,
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           customer_item_name,
           customer_item_description,
           supplier_item_name,
           supplier_item_description
    from   msc_sup_dem_entries
    where      plan_id = -1
    and      publisher_order_type = c_onhand_type
    and    customer_id = p_customer_id
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    vmi_flag = 1
    order  by new_schedule_date desc;

-- unallocated onhand

cursor unallocated_onhand_cur is
    select ((a.quantity * src_org.allocation_percent)/100) quantity1,
           to_char(a.new_schedule_date, dformat ) last_update_date,
           a.item_name,
           a.item_description,
           a.owner_item_name,
           a.owner_item_description,
           a.customer_item_name,
           a.customer_item_description,
           a.supplier_item_name,
           a.supplier_item_description
from
  msc_sup_dem_entries a,
  msc_trading_partner_maps map,
  msc_trading_partners tp,
  msc_assignment_sets assignmentset,
  msc_sr_assignments assignment,
  msc_sr_receipt_org rec_org,
  msc_sr_source_org  src_org,
  msc_trading_partner_maps map1,
  msc_trading_partner_maps map2,
  msc_company_sites site,
  msc_companies cp,
  msc_company_relationships rel
where      plan_id = -1
    and     a.publisher_order_type = UNALLOCATED_ONHAND
    and a.customer_id = p_customer_id
    and a.customer_site_id = p_customer_site_id
    and a.inventory_item_id = p_inventory_item_id
    and a.customer_site_id = map.company_key
    and map.map_type = 2
    and map.tp_key = tp.partner_id
    and assignmentset.assignment_set_name = 'dmt:Supplier Scheduling'
    and assignmentset.assignment_set_id = assignment.assignment_set_id
    and assignment.organization_id = tp.sr_tp_id
    and assignment.sr_instance_id = tp.sr_instance_id
    and assignment.inventory_item_id = a.inventory_item_id
    and assignment.sourcing_rule_id = rec_org.sourcing_rule_id
    and rec_org.sr_receipt_id = src_org.sr_receipt_id -- one to many: one item may have multiple suppliers
    and src_org.source_partner_id = map1.tp_key
    and map1.map_type = 1
    and map1.company_key = rel.relationship_id
    and rel.relationship_type = 2
    and rel.object_id = cp.company_id --supplier company id in MSC_COMPANIES
    and cp.company_id = p_supplier_id
    and src_org.source_partner_site_id = map2.tp_key
    and map2.map_type = 3
    and map2.company_key = site.company_site_id
    and site.company_site_id = p_supplier_site_id
    order  by a.new_schedule_date desc;

    -- in transit details (summary info)
    cursor intransit_cur is
      SELECT count(*) count,
             round(SUM(primary_quantity),6) primary_quantity,
             round(SUM(decode(publisher_id, supplier_id, tp_quantity, primary_quantity)),6) tp_quantity
    from   msc_sup_dem_entries
    where  plan_id = -1
    and    publisher_order_type = ASN
    and    supplier_id = p_supplier_id
    and    nvl(supplier_site_id, -99) = nvl(p_supplier_site_id, -99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(customer_id,-99) = nvl(p_customer_id,-99)
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    receipt_date <= nvl(l_rtf_end_date, receipt_date)
    and    vmi_flag = 1;

    -- more in transit details (next asn info)
    cursor intransit_2_cur is
    select order_number,
           to_char(receipt_date, dformat) next_asn_date,
           nvl(round(primary_quantity,6),0) primary_quantity,
           nvl(round(decode(publisher_id, supplier_id, tp_quantity, primary_quantity),6),0) tp_quantity,
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           customer_item_name,
           customer_item_description,
           supplier_item_name,
           supplier_item_description
    from   msc_sup_dem_entries
    where  plan_id = -1
    and    publisher_order_type = ASN
    and    supplier_id = p_supplier_id
    and    nvl(supplier_site_id, -99) = nvl(p_supplier_site_id, -99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(customer_id,-99) = nvl(p_customer_id,-99)
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    receipt_date <= nvl(l_rtf_end_date, receipt_date)
    and    vmi_flag = 1
    order  by receipt_date asc;

    -- shipment receipt details
    cursor receipt_cur is
    select to_char(new_schedule_date, dformat) last_delivery_date ,
           nvl(round(primary_quantity,6),0) primary_quantity,
           nvl(round(tp_quantity, 6),0) tp_quantity,
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           customer_item_name,
           customer_item_description,
           supplier_item_name,
           supplier_item_description
    from   msc_sup_dem_entries
    where  plan_id = -1
    and    publisher_order_type = SHIPMENT_RECEIPT
    and    customer_id = p_customer_id
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    receipt_date <= nvl(l_rtf_end_date, receipt_date)
    and    vmi_flag = 1
    order  by receipt_date desc;

    cursor total_receipt_cur is
    select round(sum(primary_quantity),6) primary_quantity,
           round(sum(tp_quantity),6) tp_quantity
    from   msc_sup_dem_entries
    where  plan_id = -1
    and    publisher_order_type = SHIPMENT_RECEIPT
    and    customer_id = p_customer_id
    and    nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
    and    inventory_item_id = p_inventory_item_id
    and    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    and    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99)
    and    receipt_date <= nvl(l_rtf_end_date, receipt_date)
    and    vmi_flag = 1;

    cursor item_suppliers_cur is
    SELECT min_minmax_quantity,min_minmax_days,
     max_minmax_quantity, max_minmax_days, enable_vmi_auto_replenish_flag, vmi_replenishment_approval,
        using_organization_id, uom_code,
        --vmi_uom_code,
        supplier_item_name,
        --purchasing_unit_of_measure,
        --vmi_unit_of_measure,
        processing_lead_time,
        --average_daily_demand AS average_daily_usage,
        replenishment_method,fixed_order_quantity
    FROM msc_item_suppliers
    WHERE plan_id = -1
    and   sr_instance_id = p_sr_instance_id
    and   organization_id = p_organization_id
    and   inventory_item_id = p_inventory_item_id
    and   supplier_id = p_tp_supplier_id
    and   supplier_site_id = p_tp_supplier_site_id
    and   vmi_flag = 1
    order by using_organization_id desc;

    cursor system_items_cur is
    SELECT  min_minmax_quantity, max_minmax_quantity,
            inventory_planning_code, reorder_point, economic_order_quantity,
            --decode(round(item.average_annual_demand/365), 0, -1,
            --round(item.average_annual_demand/365))
            --average_daily_usage,
            uom_code,
            item_name
    FROM
        msc_system_items item
    WHERE plan_id = -1
    and   sr_instance_id = p_sr_instance_id
    and   organization_id = p_organization_id
    and   inventory_item_id = p_inventory_item_id;

    cursor company_cur is
    select company_id
    from msc_company_users
    where
         user_id = FND_GLOBAL.user_id;

    cursor uom_cur is
    select unit_of_measure
    from msc_units_of_measure
    where uom_code = l_customer_uom_code;


  oh_rec                oh_cur%ROWTYPE;
  replenish_rec         replenish_cur%ROWTYPE;
  requisition_rec       requisition_cur%ROWTYPE;
  qip_rec               qip_cur%ROWTYPE;
  onhand_rec            onhand_cur%ROWTYPE;
  unallocated_onhand_rec  unallocated_onhand_cur%ROWTYPE;
  intransit_rec         intransit_cur%ROWTYPE;
  intransit_2_rec       intransit_2_cur%ROWTYPE;
  receipt_rec           receipt_cur%ROWTYPE;
  total_receipt_rec     total_receipt_cur%ROWTYPE;
  item_suppliers_rec    item_suppliers_cur%ROWTYPE;
  system_items_rec      system_items_cur%ROWTYPE;
  company_rec           company_cur%ROWTYPE;
  uom_rec               uom_cur%ROWTYPE;


begin
  dformat := fnd_profile.value('ICX_DATE_FORMAT_MASK');
  if l_company_id = -99 then
    open oh_cur;
    fetch oh_cur into oh_rec;
    if oh_cur%FOUND then
      l_onhand_type := ALLOCATED_ONHAND;
    else
      l_onhand_type := UNALLOCATED_ONHAND;
    end if;
    close oh_cur;


    if l_onhand_type = ALLOCATED_ONHAND then
      open item_suppliers_cur;
      fetch item_suppliers_cur into item_suppliers_rec;
      if item_suppliers_cur%found then
        l_min_minmax_quantity_vmi := item_suppliers_rec.min_minmax_quantity;
        l_min_minmax_days := item_suppliers_rec.min_minmax_days;
        l_max_minmax_quantity_vmi := item_suppliers_rec.max_minmax_quantity;
        l_max_minmax_days := item_suppliers_rec.max_minmax_days;
        l_auto_replenish_flag := item_suppliers_rec.enable_vmi_auto_replenish_flag;
        l_vmi_replenishment_approval := item_suppliers_rec.vmi_replenishment_approval;
        l_using_organization_id := item_suppliers_rec.using_organization_id;
        --l_vmi_uom_code := item_suppliers_rec.vmi_uom_code;
        --l_vmi_unit_of_measure := item_suppliers_rec.vmi_unit_of_measure;
        l_supplier_uom_code := item_suppliers_rec.uom_code;
        --l_supplier_unit_of_measure := item_suppliers_rec.purchasing_unit_of_measure;
        l_supplier_item_name := item_suppliers_rec.supplier_item_name;
       -- l_average_daily_usage := item_suppliers_rec.average_daily_usage;
        l_replenishment_method := item_suppliers_rec.replenishment_method;
	l_fixed_order_quantity:=item_suppliers_rec.fixed_order_quantity;

        --l_rtf_end_date := nvl(item_suppliers_rec.processing_lead_time, 0) + sysdate;
      end if;
      close item_suppliers_cur;


      l_average_daily_usage:=supplier_avg_daily_usage(	 p_inventory_item_id
							, p_organization_id
							, p_sr_instance_id
							, p_tp_supplier_id
							, p_tp_supplier_site_id
							) ;

      open system_items_cur;
      fetch system_items_cur into system_items_rec;
      if system_items_cur%found then
        l_inventory_planning_code := system_items_rec.inventory_planning_code;
        l_reorder_point := system_items_rec.reorder_point;
        l_economic_order_quantity := system_items_rec.economic_order_quantity;
        --l_average_daily_usage := system_items_rec.average_daily_usage;
        l_customer_uom_code := system_items_rec.uom_code;
        l_customer_item_name := system_items_rec.item_name;
      end if;
      close  system_items_cur;
    else
      open item_suppliers_cur;
      fetch item_suppliers_cur into item_suppliers_rec;
      if item_suppliers_cur%found then
        l_min_minmax_quantity_vmi := item_suppliers_rec.min_minmax_quantity;
        l_min_minmax_days := item_suppliers_rec.min_minmax_days;
        l_max_minmax_quantity_vmi := item_suppliers_rec.max_minmax_quantity;
        l_max_minmax_days := item_suppliers_rec.max_minmax_days;
        l_auto_replenish_flag := item_suppliers_rec.enable_vmi_auto_replenish_flag;
        l_vmi_replenishment_approval := item_suppliers_rec.vmi_replenishment_approval;
        l_using_organization_id := item_suppliers_rec.using_organization_id;
        --l_vmi_uom_code := item_suppliers_rec.vmi_uom_code;
        --l_vmi_unit_of_measure := item_suppliers_rec.vmi_unit_of_measure;
        l_supplier_uom_code := item_suppliers_rec.uom_code;
        --l_supplier_unit_of_measure := item_suppliers_rec.purchasing_unit_of_measure;
        l_supplier_item_name := item_suppliers_rec.supplier_item_name;
        --l_average_daily_usage := item_suppliers_rec.average_daily_usage;
        l_replenishment_method := item_suppliers_rec.replenishment_method;
	l_fixed_order_quantity:=item_suppliers_rec.fixed_order_quantity;

        --l_rtf_end_date := nvl(item_suppliers_rec.processing_lead_time, 0) + sysdate;
      end if;
      close item_suppliers_cur;

      l_average_daily_usage:=supplier_avg_daily_usage(	 p_inventory_item_id
							, p_organization_id
							, p_sr_instance_id
							, p_tp_supplier_id
							, p_tp_supplier_site_id
							) ;

      open system_items_cur;
      fetch system_items_cur into system_items_rec;
      if system_items_cur%found then
        --l_min_minmax_quantity := system_items_rec.min_minmax_quantity;
        --l_max_minmax_quantity := system_items_rec.max_minmax_quantity;
        l_inventory_planning_code := system_items_rec.inventory_planning_code;
        l_reorder_point := system_items_rec.reorder_point;
        l_economic_order_quantity := system_items_rec.economic_order_quantity;
        --l_average_daily_usage := system_items_rec.average_daily_usage;
        l_customer_uom_code := system_items_rec.uom_code;
        l_customer_item_name := system_items_rec.item_name;
      end if;
      close  system_items_cur;
    end if;

    open replenish_cur;
    fetch replenish_cur into replenish_rec;
    if replenish_cur%found then
      return_string :=
            return_string                   ||
            nvl(to_char(replenish_rec.primary_quantity, '999999999.999999'),0)          ||delim||
            replenish_rec.receipt_date ||delim ;
      l_rtf_start_date := replenish_rec.rtf_start_date;
      l_rtf_end_date := replenish_rec.rtf_end_date;
    else
      return_string := return_string||'0'||delim||delim;
    end if;
    close replenish_cur;


    open qip_cur;
    fetch qip_cur into qip_rec;
    if qip_cur%found then
      l_quantity_in_process := nvl(qip_rec.qip,0);
      l_implemented_quantity := qip_rec.ip;
    end if;
    close qip_cur;

    open requisition_cur;
    fetch requisition_cur into requisition_rec;
    if requisition_cur%found then
      return_string :=
            return_string                     ||
            nvl(to_char(requisition_rec.primary_quantity, '999999999.999999'),0)          ||delim;
      l_requisition_quantity := nvl(requisition_rec.primary_quantity,0);

    else
      return_string := return_string||'0'||delim;
      l_requisition_quantity := 0;
    end if;
    close requisition_cur;

    if l_onhand_type = ALLOCATED_ONHAND then
        open onhand_cur(l_onhand_type);
        fetch onhand_cur into onhand_rec;
        if onhand_cur%found then
        --dbms_output.put_line('vdbg2');
          return_string :=
                return_string                ||
                nvl(to_char(onhand_rec.primary_quantity, '999999999.999999'),0)          ||delim||
                onhand_rec.last_update_date  ||delim ;
          l_onhand_quantity := nvl(onhand_rec.primary_quantity,0);
          --dbms_output.put_line('vdbg3 ' ||nvl(l_onhand_quantity,789));
        else
          return_string := return_string||'0'||delim||delim;
          l_onhand_quantity := 0;
        end if;
        close onhand_cur;
    else
        open unallocated_onhand_cur;
        fetch unallocated_onhand_cur into unallocated_onhand_rec;
        if unallocated_onhand_cur%found then
        --dbms_output.put_line('vdbg2');
          return_string :=
                return_string                ||
                unallocated_onhand_rec.quantity1          ||delim||
                unallocated_onhand_rec.last_update_date  ||delim ;
          l_onhand_quantity := unallocated_onhand_rec.quantity1;
        else
          return_string := return_string||'0'||delim||delim;
          l_onhand_quantity := 0;
        end if;
        close unallocated_onhand_cur;
    end if;

    open intransit_cur;
    fetch intransit_cur into intransit_rec;
    if intransit_cur%found then
      return_string :=
            return_string          ||
            intransit_rec.count    ||delim||
            nvl(to_char(intransit_rec.tp_quantity, '999999999.999999'),0) ||delim ;
      l_intransit_quantity := nvl(intransit_rec.tp_quantity,0);
      l_asn_count := intransit_rec.count;


    else
      return_string := return_string||'0'||delim||delim;
      l_intransit_quantity := 0;
    end if;
    close intransit_cur;

    open intransit_2_cur;
    fetch intransit_2_cur into intransit_2_rec;
    if intransit_2_cur%found then
      return_string :=
            return_string                   ||
            intransit_2_rec.order_number    ||delim||
            intransit_2_rec.next_asn_date   ||delim||
            nvl(to_char(intransit_2_rec.tp_quantity, '999999999.999999'),0)        ||delim ;
    else
      return_string := return_string||delim||delim||'0'||delim;
    end if;
    close intransit_2_cur;

    open receipt_cur;
    fetch receipt_cur into receipt_rec;
    if receipt_cur%found then
      return_string :=
            return_string                   ||
            receipt_rec.last_delivery_date  ||delim||
            nvl(to_char(receipt_rec.primary_quantity, '999999999.999999'),0)            ;

    else
      return_string := return_string||delim||'0';
    end if;
    close receipt_cur;

    open total_receipt_cur;
    fetch total_receipt_cur into total_receipt_rec;
    if total_receipt_cur%found then
      l_total_receipt_quantity := nvl(total_receipt_rec.primary_quantity,0);
    end if;
    close total_receipt_cur;

    if l_vmi_replenishment_approval = 'NONE' then
      l_release_method := 1;
    else
      if l_vmi_replenishment_approval = 'SUPPLIER_OR_BUYER' then
        l_release_method := 2;
      else
        if l_vmi_replenishment_approval = 'BUYER' then
            l_release_method := 3;
        end if;
      end if;
    end if;


    l_min_minmax_quantity :=  l_min_minmax_quantity_vmi;
    l_max_minmax_quantity :=  l_max_minmax_quantity_vmi;


    IF l_fixed_order_quantity IS NOT NULL THEN
         l_max_minmax_quantity := nvl(l_onhand_quantity,0) + l_fixed_order_quantity;
    END IF;


    IF l_average_daily_usage IS NOT NULL AND l_min_minmax_days IS NOT NULL AND l_min_minmax_quantity IS NULL THEN
         l_min_minmax_quantity := l_min_minmax_days * l_average_daily_usage;
      END IF;

      IF l_average_daily_usage IS NOT NULL AND l_max_minmax_days IS NOT NULL AND l_max_minmax_quantity IS NULL THEN
         l_max_minmax_quantity := l_max_minmax_days * l_average_daily_usage;
      END IF;

      IF l_average_daily_usage <> 0 AND l_min_minmax_quantity IS NOT NULL AND l_min_minmax_days IS NULL THEN
         l_min_minmax_days := l_min_minmax_quantity / l_average_daily_usage;
      END IF;

      IF l_average_daily_usage <> 0 AND l_max_minmax_quantity IS NOT NULL AND l_max_minmax_days IS NULL THEN
         l_max_minmax_days := l_max_minmax_quantity / l_average_daily_usage;
      END IF;


    --------------------------------------------------------
    --  gif name mscx1234.gif [for 1234 see legend below] --
    --  color codes:                                      --
    --  r red                                             --
    --  h hatched yellow                                  --
    --  i hatched green                                   --
    --  g green                                           --
    --  w white                                           --
    --------------------------------------------------------
  l_on_order_quantity := nvl(l_total_receipt_quantity, 0) + nvl(l_requisition_quantity, 0) + nvl(l_intransit_quantity, 0) +
                         nvl(l_quantity_in_process,0);

  -- check if inventory status: 1-shortage, 2-excess, 0-OK
  if l_on_order_quantity + nvl(l_onhand_quantity,0) <= nvl(l_min_minmax_quantity,0) then
    l_inv_status := 1;
  end if;
  if nvl(l_onhand_quantity,0) = 0 then
    if l_on_order_quantity > nvl(l_max_minmax_quantity,0) then
      l_graph_name := 'MscXVmiGraph15';
    elsif l_on_order_quantity = nvl(l_max_minmax_quantity,0) then
      l_graph_name := 'MscXVmiGraph23';
    else
      if l_on_order_quantity > nvl(l_min_minmax_quantity,0) then
        l_graph_name := 'MscXVmiGraph17';
      elsif l_on_order_quantity = nvl(l_min_minmax_quantity,0) then
        l_graph_name := 'MscXVmiGraph21';
      else
        if l_on_order_quantity = 0 then
          l_graph_name := 'MscXVmiGraph18';
        else
          l_graph_name := 'MscXVmiGraph16';
        end if;
      end if;
    end if;
  else
    if nvl(l_onhand_quantity,0) < nvl(l_min_minmax_quantity,0) then
      if nvl(l_on_order_quantity, 0) = 0 then
        l_graph_name := 'MscXVmiGraph1';
      else
          if nvl((l_onhand_quantity + l_on_order_quantity),0) < nvl(l_min_minmax_quantity,0) then
            l_graph_name := 'MscXVmiGraph2';
          elsif nvl((l_onhand_quantity + l_on_order_quantity),0) = nvl(l_min_minmax_quantity,0) then
            l_graph_name := 'MscXVmiGraph22';
          else
            if nvl((l_onhand_quantity + l_on_order_quantity),0) < nvl(l_max_minmax_quantity,0) then
              l_graph_name := 'MscXVmiGraph4';
            elsif nvl((l_onhand_quantity + l_on_order_quantity),0) = nvl(l_max_minmax_quantity,0) then
              l_graph_name := 'MscXVmiGraph26';
            else
              l_graph_name := 'MscXVmiGraph7';
            end if;
          end if;
      end if;
    elsif nvl(l_onhand_quantity,0) = nvl(l_min_minmax_quantity,0) then
      if nvl(l_on_order_quantity, 0) = 0 then
        l_graph_name := 'MscXVmiGraph20';
      elsif nvl((l_onhand_quantity + l_on_order_quantity),0) = nvl(l_max_minmax_quantity,0) then
        l_graph_name := 'MscXVmiGraph27';
      elsif nvl((l_onhand_quantity + l_on_order_quantity),0) > nvl(l_max_minmax_quantity,0) then
        l_graph_name := 'MscXVmiGraph28';
      end if;
    elsif nvl((l_onhand_quantity),0) < nvl(l_max_minmax_quantity,0) then
        if nvl(l_on_order_quantity, 0) = 0 then
          l_graph_name := 'MscXVmiGraph3';
        else
          if nvl((l_onhand_quantity + l_on_order_quantity),0) < nvl(l_max_minmax_quantity,0) then
            l_graph_name := 'MscXVmiGraph5';
          elsif nvl((l_onhand_quantity + l_on_order_quantity),0) = nvl(l_max_minmax_quantity,0) then
            l_graph_name := 'MscXVmiGraph25';
          else
            l_graph_name := 'MscXVmiGraph8';
          end if;
        end if;
    elsif nvl((l_onhand_quantity),0) = nvl(l_max_minmax_quantity,0) then
        if nvl(l_on_order_quantity, 0) = 0 then
          l_graph_name := 'MscXVmiGraph24';
        else
            l_graph_name := 'MscXVmiGraph29';
        end if;
    elsif nvl((l_onhand_quantity),0) > nvl(l_max_minmax_quantity,0) then
        if nvl(l_on_order_quantity, 0) = 0 then
          l_graph_name := 'MscXVmiGraph6';
        else
            l_graph_name := 'MscXVmiGraph9';
        end if;
    end if;
  end if;

      IF NVL(l_onhand_quantity, 0) = 0 AND NVL(l_on_order_quantity, 0) = 0 AND NVL(l_min_minmax_quantity, 0) = 0 AND NVL(l_max_minmax_quantity, 0) = 0 THEN
         l_graph_name := 'MscXVmiGraph18';
      END IF;

  --BUG 4589370
   --If the item name or the item description contains # then temporarily
   --we would convert this to '$_-'.

 if ( instr(l_customer_item_name,'#') <> 0) then
	l_customer_item_name := replace(l_customer_item_name,'#','$_-');
end if;

 if ( instr(l_customer_item_desc,'#') <> 0) then
	l_customer_item_desc := replace(l_customer_item_desc,'#','$_-');
end if;

 if ( instr(l_supplier_item_name,'#') <> 0) then
	l_supplier_item_name := replace(l_supplier_item_name,'#','$_-');
end if;

 if ( instr(l_supplier_item_desc,'#') <> 0) then
	l_supplier_item_desc := replace(l_supplier_item_desc,'#','$_-');
end if;

 if ( instr(l_owner_item_name,'#') <> 0) then
	l_owner_item_name := replace(l_owner_item_name,'#','$_-');
end if;

 if ( instr(l_owner_item_desc,'#') <> 0) then
	l_owner_item_desc := replace(l_owner_item_desc,'#','$_-');
end if;



    return_string := return_string || delim || l_graph_name
                        || delim || l_inventory_planning_code
                        || delim || to_char(l_reorder_point, '9999999999.999999') --added because of NLS issues
                        || delim || to_char(l_economic_order_quantity, '9999999999.999999')
                        || delim || to_char(l_average_daily_usage, '9999999999.999999')
                        || delim || l_customer_item_name
                        || delim || l_customer_item_desc
                        || delim || l_supplier_item_name
                        || delim || l_supplier_item_desc
                        || delim || l_inv_status
                        || delim || l_customer_uom_code
                        || delim || to_char(l_quantity_in_process, '9999999999.999999')
                        || delim || nvl(to_char(l_total_receipt_quantity, '9999999999.999999'),0)
                        || delim || l_owner_item_name
                        || delim || l_owner_item_desc
                        || delim || to_char(l_min_minmax_quantity, '9999999999.999999')
                        || delim || to_char(l_max_minmax_quantity, '9999999999.999999')
                        || delim || to_char(l_supplier_to_customer_rate, '9999999999.999999')
                        || delim || l_min_minmax_days          -- later change it in char for NLS issues
                        || delim || l_max_minmax_days
                        || delim || l_auto_replenish_flag
                        || delim || l_release_method
                        || delim || l_asn_auto_expire
                        || delim || l_consigned
                         || delim || l_replenishment_method ;

----------------------------------------------------------------------------------------------------------
      end if;  --END of "if l_company_id = p_customer_id then  "
    return return_string;

exception
when others then
  --dbms_output.put_line(substr(sqlerrm,1,255));
  return empty_string;
end;

   /*
    * VMI with Customers:
    *    Sales Order Quantity
    */
   PROCEDURE vmiCustomerReceiptQty
      (p_inventory_item_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER,
       p_supplier_id NUMBER, p_time_fence_end_date DATE, p_uom_code VARCHAR2,
       l_sum_receipt_qty OUT NOCOPY NUMBER, l_last_receipt_qty OUT NOCOPY NUMBER, l_last_receipt_date OUT NOCOPY DATE)
   IS
      CURSOR c1 IS
      SELECT nvl(msde.primary_quantity, 0.0), msde.receipt_date, msde.primary_uom
        FROM msc_sup_dem_entries msde
       WHERE msde.customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND msde.supplier_id = p_supplier_id
         AND msde.inventory_item_id = p_inventory_item_id
         AND msde.publisher_order_type = SHIPMENT_RECEIPT
         AND msde.receipt_date <= nvl(p_time_fence_end_date, msde.receipt_date)
         AND msde.plan_id = -1
      ORDER BY msde.receipt_date DESC;

      CURSOR c2 IS
      SELECT nvl(msde.primary_quantity, 0.0), msde.primary_uom
        FROM msc_sup_dem_entries msde
       WHERE customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
         AND inventory_item_id = p_inventory_item_id
         AND publisher_order_type = SHIPMENT_RECEIPT
         AND plan_id = -1;

      l_primary_uom VARCHAR2(3);
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
      l_receipt_qty NUMBER;

   BEGIN
      l_sum_receipt_qty := 0;
      -- summed up receipt quantity
      OPEN c2;
      LOOP
         FETCH c2 INTO l_receipt_qty, l_primary_uom;
         EXIT WHEN c2%NOTFOUND;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_receipt_qty := l_sum_receipt_qty + l_receipt_qty * l_conv_rate;
      END LOOP;
      CLOSE c2;

      -- get the most recent(receipt_date) receipt record
      OPEN c1;
      FETCH c1 INTO l_last_receipt_qty, l_last_receipt_date, l_primary_uom;
      IF C1%NOTFOUND THEN
        l_last_receipt_qty := 0.0;
        l_last_receipt_date := NULL;
      END IF;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_last_receipt_qty := l_last_receipt_qty * l_conv_rate;
      CLOSE c1;

   EXCEPTION
   WHEN OTHERS THEN
      l_receipt_qty := 0.0;
      l_last_receipt_qty := 0.0;
      l_last_receipt_date := NULL;
   END vmiCustomerReceiptQty;

   /*
    * VMI with Customers:
    *    Sales Order Quantity
    */
   PROCEDURE vmiCustomerOrderQtyConsigned
      (p_inventory_item_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER, p_supplier_id NUMBER,
       p_time_fence_end_date DATE, p_uom_code VARCHAR2, l_order_qty OUT NOCOPY NUMBER)
   IS
      l_so_qty NUMBER;
      l_req_qty NUMBER;
      l_sum_so_qty NUMBER := 0;
      l_sum_req_qty NUMBER := 0;
      l_primary_uom VARCHAR2(3);
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;

      CURSOR c1 IS
      SELECT nvl(so.primary_quantity, 0), primary_uom
        FROM msc_sup_dem_entries so
       WHERE so.publisher_order_type = SALES_ORDER
         AND so.customer_id = p_customer_id
         AND so.customer_site_id = p_customer_site_id
         AND so.supplier_id = p_supplier_id
         AND so.inventory_item_id = p_inventory_item_id
         AND so.internal_flag = INTERNAL_FLAG_SET
         AND so.plan_id = -1
         AND trunc(nvl(so.receipt_date,so.key_date)) <= trunc(nvl(p_time_fence_end_date,nvl(so.receipt_date,so.key_date)));


      CURSOR c2 IS
      SELECT nvl(req.primary_quantity, 0), primary_uom
        FROM msc_sup_dem_entries req
       WHERE req.publisher_order_type = REQUISITION
         AND req.customer_id = p_customer_id
         AND req.customer_site_id = p_customer_site_id
         AND req.supplier_id = p_supplier_id
         AND req.inventory_item_id = p_inventory_item_id
         AND req.internal_flag = INTERNAL_FLAG_SET
         AND req.link_trans_id IS NULL
         AND req.plan_id = -1
         AND req.receipt_date <= nvl(p_time_fence_end_date, req.receipt_date);

   BEGIN

      -- All internal SO's
      OPEN c1;
      LOOP
         FETCH c1 INTO l_so_qty, l_primary_uom;
         EXIT WHEN c1%NOTFOUND;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_so_qty := l_sum_so_qty + l_so_qty * l_conv_rate;
      END LOOP;
      CLOSE c1;

      -- All internal REQs that don't point to an internal so
      OPEN c2;
      LOOP
         FETCH c2 INTO l_req_qty, l_primary_uom;
         EXIT WHEN c2%NOTFOUND;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_req_qty := l_sum_req_qty + l_req_qty * l_conv_rate;
      END LOOP;
      CLOSE c2;

      l_order_qty := l_sum_so_qty + l_sum_req_qty;

   EXCEPTION
   WHEN OTHERS THEN
      l_order_qty := 0.0;
   END vmiCustomerOrderQtyConsigned;

   /*
    * VMI with Customers Unconsigned
    *    Sales Order/Req Quantity
    */
   PROCEDURE vmiCustomerOrderQtyUnconsigned
      (p_inventory_item_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER, p_supplier_id NUMBER,
       p_time_fence_end_date DATE, p_uom_code VARCHAR2, l_sum_order_qty OUT NOCOPY NUMBER)
   IS
      l_primary_uom VARCHAR2(3);
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
      l_order_qty NUMBER;

      CURSOR c1 IS
      SELECT nvl(msde.primary_quantity, 0.0), primary_uom
        FROM msc_sup_dem_entries msde
       WHERE customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
         AND inventory_item_id = p_inventory_item_id
         AND publisher_order_type = SALES_ORDER
         AND internal_flag is null
         AND trunc(nvl(receipt_date,key_date)) <= trunc(nvl(p_time_fence_end_date,nvl(receipt_date,key_date)))
         AND plan_id = -1;
   BEGIN
      l_sum_order_qty := 0;
      OPEN c1;
      LOOP
         FETCH c1 INTO l_order_qty, l_primary_uom;
         EXIT WHEN c1%NOTFOUND;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_order_qty := l_sum_order_qty + l_order_qty * l_conv_rate;
      END LOOP;
      CLOSE c1;

   EXCEPTION
   WHEN OTHERS THEN
      l_sum_order_qty := 0.0;
   END vmiCustomerOrderQtyUnconsigned;

   /*
    * VMI with Customers:
    *    Replenishment Qty
    *    Replenishment Date
    */
   PROCEDURE vmiCustomerIntransit
      (p_inventory_item_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER, p_supplier_id NUMBER,
       p_asn_auto_expire NUMBER, p_time_fence_end_date DATE, p_uom_code VARCHAR2,
       r_intransit_qty OUT NOCOPY NUMBER, r_intransit_count OUT NOCOPY NUMBER,r_intransit_nextasn_ordernum OUT NOCOPY VARCHAR2,
       r_intransit_nextdate OUT NOCOPY DATE, r_intransit_nextasn_qty OUT NOCOPY NUMBER)
   IS
    CURSOR c1 IS
    SELECT order_number,
           receipt_date AS next_asn_date,
           primary_quantity AS primary_quantity, primary_uom
      FROM msc_sup_dem_entries msde
     WHERE msde.plan_id = -1
       AND msde.publisher_order_type = ASN
       AND msde.supplier_id = p_supplier_id
       AND msde.inventory_item_id = p_inventory_item_id
       AND msde.customer_id = p_customer_id
       AND msde.customer_site_id = p_customer_site_id
       AND trunc(nvl(msde.receipt_date,msde.key_date)) <= trunc(nvl(p_time_fence_end_date, nvl(msde.receipt_date,msde.key_date)))
    ORDER BY msde.receipt_date DESC;


    CURSOR c2 IS
      SELECT nvl(msde.primary_quantity, 0.0), primary_uom
        FROM msc_sup_dem_entries msde
       WHERE customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
         AND inventory_item_id = p_inventory_item_id
         AND publisher_order_type = ASN
         AND plan_id = -1
         AND trunc(nvl(msde.receipt_date,msde.key_date)) <= trunc(nvl(p_time_fence_end_date, nvl(msde.receipt_date,msde.key_date)))
         AND (p_asn_auto_expire = ASN_AUTO_EXPIRE_YES AND SYSDATE <= receipt_date OR
              p_asn_auto_expire = ASN_AUTO_EXPIRE_NO);

      l_primary_uom VARCHAR2(3);
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
      l_intransit_quantity NUMBER := 0;

   BEGIN
      r_intransit_count := 1;
      r_intransit_nextasn_qty := 0;
      r_intransit_qty := 0;
      OPEN c2;
      LOOP
         FETCH c2 INTO l_intransit_quantity, l_primary_uom;
         EXIT WHEN c2%NOTFOUND;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         r_intransit_qty := r_intransit_qty + l_intransit_quantity * l_conv_rate;
         r_intransit_count := r_intransit_count + 1;
      END LOOP;
      CLOSE c2;

      -- get the most recent(receipt_date) ASN record
      OPEN c1;
      FETCH c1 INTO r_intransit_nextasn_ordernum, r_intransit_nextdate, r_intransit_nextasn_qty, l_primary_uom;
      IF C1%NOTFOUND THEN
        r_intransit_nextasn_ordernum := NULL;
        r_intransit_nextdate := NULL;
        r_intransit_nextasn_qty := 0.0;
      END IF;
      l_conv_rate := 1;
      IF l_primary_uom <> p_uom_code THEN
         MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
            l_primary_uom
            , p_uom_code
            , p_inventory_item_id
            , l_conv_found
            , l_conv_rate);
      END IF;
      r_intransit_nextasn_qty := r_intransit_nextasn_qty * l_conv_rate;
      CLOSE c1;

   EXCEPTION
   WHEN OTHERS THEN
      r_intransit_qty := 0.0;
      r_intransit_count := 0;
      r_intransit_nextasn_ordernum := NULL;
      r_intransit_nextdate := NULL;
      r_intransit_nextasn_qty := 0.0;
   END vmiCustomerIntransit;

   PROCEDURE vmiCustomerReplenishment
      (p_inventory_item_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER, p_supplier_id NUMBER,
       l_replenishment_quantity OUT NOCOPY NUMBER, l_replenishment_date OUT NOCOPY DATE,
       l_quantity_in_process OUT NOCOPY NUMBER)
   IS
   BEGIN
      -- Never mind, lets just assume the passed parameters are correct
      -- There should only be one replenishment record for the intersection of
      -- customer/-site/supplier/item.

      SELECT msde.primary_quantity, msde.receipt_date, msde.quantity_in_process
        INTO l_replenishment_quantity, l_replenishment_date, l_quantity_in_process
        FROM msc_sup_dem_entries msde
       WHERE customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
         AND inventory_item_id = p_inventory_item_id
         AND publisher_order_type = REPLENISHMENT
         AND plan_id = -1;

   EXCEPTION
   WHEN OTHERS THEN
      l_replenishment_quantity := NULL;
      l_replenishment_date := NULL;
      l_quantity_in_process := NULL;
   END vmiCustomerReplenishment;


    /*
    * VMI with Customers:
    *  Time_fence_end_date
    */

    PROCEDURE vmiCustomerTimeFenceEndDate(
      p_source_org_id IN NUMBER,
      p_modeled_org_id IN NUMBER,
      p_customer_id NUMBER,
      p_customer_site_id NUMBER,
      p_supplier_id NUMBER,
      p_supplier_site_id NUMBER,
      p_lead_time NUMBER,
      p_sr_instance_id NUMBER,
      p_consigned_flag NUMBER,
      l_time_fence_end_date OUT NOCOPY DATE)
   IS

   l_calendar_code VARCHAR2(14);
   l_calendar_inst_id NUMBER;
   l_offset_days   NUMBER;
   l_total_lead_time NUMBER;
   l_transit_time NUMBER;


   BEGIN

	msc_x_util.get_calendar_code(p_supplier_id,
				p_supplier_site_id,
				p_customer_id,
				p_customer_site_id,
				l_calendar_code,
				l_calendar_inst_id);

	--dbms_output.put_line('calendar code is    ' ||l_calendar_code);


	l_transit_time :=intransit_lead_time(  p_source_org_id,
								p_modeled_org_id,
							        p_customer_id,
							        p_customer_site_id,
								p_supplier_id,
								p_sr_instance_id,
								p_consigned_flag);

	--dbms_output.put_line('ui in transit time is    ' ||l_transit_time);
	--dbms_output.put_line('ui process full leadtime is     ' ||p_lead_time);


	/* total intransit time */

	l_total_lead_time:= p_lead_time+l_transit_time;

	l_time_fence_end_date := msc_calendar.date_offset(l_calendar_code,
						     l_calendar_inst_id,
						     sysdate, l_total_lead_time,
						     99999);
	--dbms_output.put_line('time fence end date is   ' ||l_time_fence_end_date);

	exception
	 when others then

	 l_time_fence_end_date := sysdate + l_total_lead_time;



 END vmiCustomerTimeFenceEndDate;


   /*
    * VMI with Customers:
    *    Min Qty
    *    Max Qty
    *    Sales Order Authorization Flag
    *    Average Daily Demand
    *    ASN Auto Expire Flag
    *    Consigned
    */
   PROCEDURE vmiCustomerSetupvalues(
      p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER, p_sr_instance_id IN NUMBER,
      l_min_minmax_qty OUT NOCOPY NUMBER, l_min_minmax_days OUT NOCOPY NUMBER, l_max_minmax_qty OUT NOCOPY NUMBER, l_max_minmax_days OUT NOCOPY NUMBER,
      l_so_authorization_flag OUT NOCOPY NUMBER,
      l_asn_auto_expire OUT NOCOPY NUMBER, l_consigned OUT NOCOPY NUMBER, l_fixed_order_quantity OUT NOCOPY NUMBER,
      l_supplier_uom_code OUT NOCOPY VARCHAR2, l_item_name OUT NOCOPY VARCHAR2, l_lead_time OUT NOCOPY NUMBER,
      l_forecast_horizon OUT NOCOPY NUMBER, l_source_org_id OUT NOCOPY NUMBER)
   IS
   BEGIN

      SELECT msi.vmi_minimum_units, msi.vmi_minimum_days, msi.vmi_maximum_units, msi.vmi_maximum_days,
             msi.so_authorization_flag,  msi.asn_autoexpire_flag,
             msi.consigned_flag,msi.vmi_fixed_order_quantity, msi.uom_code, msi.item_name,
             NVL(msi.preprocessing_lead_time, 0) + NVL(msi.full_lead_time, 0) + nvl(postprocessing_lead_time, 0) AS lead_time,
             msi.forecast_horizon, NVL(msi.source_org_id,NOT_EXISTS)
        INTO l_min_minmax_qty, l_min_minmax_days, l_max_minmax_qty, l_max_minmax_days,
             l_so_authorization_flag,  l_asn_auto_expire, l_consigned,
             l_fixed_order_quantity,l_supplier_uom_code, l_item_name, l_lead_time,l_forecast_horizon,
             l_source_org_id
        FROM msc_system_items msi
       WHERE msi.inventory_item_id = p_inventory_item_id
         AND msi.organization_id = p_organization_id
         AND msi.sr_instance_id = p_sr_instance_id
         AND msi.plan_id = -1;

   EXCEPTION
   WHEN OTHERS THEN
      l_min_minmax_qty := NULL;
      l_max_minmax_qty := NULL;
      l_min_minmax_days := NULL;
      l_max_minmax_days := NULL;
      l_fixed_order_quantity :=NULL;
      l_so_authorization_flag := 0;
      l_asn_auto_expire := ASN_AUTO_EXPIRE_NO;
      l_consigned := UNCONSIGNED;
      l_supplier_uom_code:=NULL;
      l_lead_time := NULL;
      l_source_org_id:=NOT_EXISTS;
   END;

   /*
    * VMI with Customers:
    *    Onhand Qty
    *    Onhand Date
    */

   PROCEDURE vmiCustomerCurrentOnhand(
      p_inventory_item_id NUMBER,
      p_customer_id NUMBER,
      p_customer_site_id NUMBER,
      p_supplier_id NUMBER,
      p_uom_code VARCHAR2,
      p_consigned NUMBER,
      r_onhand_qty OUT NOCOPY NUMBER,
      r_onhand_date OUT NOCOPY DATE)
   IS
      CURSOR c1 IS
      SELECT nvl(primary_quantity, 0), new_schedule_date, primary_uom
        FROM msc_sup_dem_entries
       WHERE plan_id = -1
         AND publisher_order_type = ALLOCATED_ONHAND
         AND inventory_item_id = p_inventory_item_id
         AND customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
         AND plan_id = -1;

      l_sum_unallocated_qty NUMBER := 0;
      l_unallocated_date DATE := NULL;
      l_allocated_qty NUMBER := 0;
      l_sum_allocated_qty NUMBER := 0;
      l_allocated_date DATE;
      l_primary_uom VARCHAR2(3);
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
   BEGIN

      IF p_consigned = UNCONSIGNED THEN
         BEGIN
         -- Unallocated
         SELECT primary_quantity, new_schedule_date, primary_uom
           INTO l_sum_unallocated_qty, l_unallocated_date, l_primary_uom
           FROM msc_sup_dem_entries
          WHERE plan_id = -1
            AND publisher_order_type = UNALLOCATED_ONHAND
            AND inventory_item_id = p_inventory_item_id
            AND publisher_id = p_customer_id
            AND publisher_site_id = p_customer_site_id
            AND plan_id = -1
            AND rownum = 1
         ORDER BY new_schedule_date DESC;

         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_unallocated_qty := l_sum_unallocated_qty * l_conv_rate;

         EXCEPTION
         WHEN no_data_found THEN
            l_sum_unallocated_qty := 0;
            l_unallocated_date := NULL;
         END;
      ELSE
         l_sum_unallocated_qty := 0;
         l_unallocated_date := NULL;
      END IF;
 /**	Due to data descripency in systest l_allocate_date and primary quantity are
 *	selected in separate cursors. At present for different allocated onhands we have different dates
 *      ( one of them is null at present in systest)
 */

      -- Allocated Onhand
      OPEN c1;
      LOOP
         FETCH c1 INTO l_allocated_qty, l_allocated_date, l_primary_uom;
         EXIT WHEN c1%NOTFOUND;
         IF l_allocated_date IS NOT NULL AND l_allocated_date > r_onhand_date THEN
            r_onhand_date := l_allocated_date;
         END IF;
         l_conv_rate := 1;
         IF l_primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               l_primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         l_sum_allocated_qty := l_sum_allocated_qty + l_allocated_qty * l_conv_rate;
      END LOOP;
      CLOSE c1;

      -- Add quantities and set date to NULL if both found
      r_onhand_qty := l_sum_allocated_qty + l_sum_unallocated_qty;
      r_onhand_date := nvl(l_unallocated_date, l_allocated_date);
      IF l_unallocated_date Is NOT NULL AND l_allocated_date IS NOT NULL THEN
         r_onhand_date := greatest(l_unallocated_date, l_allocated_date);
      END IF;
   END;


   FUNCTION vmiCustomerGraphName(p_onhand_qty NUMBER, p_onorder_qty NUMBER, p_min NUMBER, p_max NUMBER)
   RETURN VARCHAR2
   IS
      l_graph_name VARCHAR2(255);
   BEGIN

      IF NVL(p_onhand_qty, 0) = 0 AND NVL(p_onorder_qty, 0) = 0 AND NVL(p_min, 0) = 0 AND NVL(p_max, 0) = 0 THEN
         RETURN 'MscXVmiGraph18';
      END IF;

      if nvl(p_onhand_qty,0) = 0 then
        if p_onorder_qty > nvl(p_max,0) then
          l_graph_name := 'MscXVmiGraph15';
        elsif p_onorder_qty = nvl(p_max,0) then
         l_graph_name := 'MscXVmiGraph23';
        else
           if p_onorder_qty > nvl(p_min,0) then
              l_graph_name := 'MscXVmiGraph17';
           elsif p_onorder_qty = nvl(p_min,0) then
              l_graph_name := 'MscXVmiGraph21';
           else
              if p_onorder_qty = 0 then
                 l_graph_name := 'MscXVmiGraph18';
              else
                 l_graph_name := 'MscXVmiGraph16';
              end if;
           end if;
        end if;
  else
    if nvl(p_onhand_qty,0) < nvl(p_min,0) then
      if nvl(p_onorder_qty, 0) = 0 then
        l_graph_name := 'MscXVmiGraph1';
      else
          if nvl((p_onhand_qty + p_onorder_qty),0) < nvl(p_min,0) then
            l_graph_name := 'MscXVmiGraph2';
          elsif nvl((p_onhand_qty + p_onorder_qty),0) = nvl(p_min,0) then
            l_graph_name := 'MscXVmiGraph22';
          else
            if nvl((p_onhand_qty + p_onorder_qty),0) < nvl(p_max,0) then
              l_graph_name := 'MscXVmiGraph4';
            elsif nvl((p_onhand_qty + p_onorder_qty),0) = nvl(p_max,0) then
              l_graph_name := 'MscXVmiGraph26';
            else
              l_graph_name := 'MscXVmiGraph7';
            end if;
          end if;
      end if;
    elsif nvl(p_onhand_qty,0) = nvl(p_min,0) then
      if nvl(p_onorder_qty, 0) = 0 then
        l_graph_name := 'MscXVmiGraph20';
      elsif nvl((p_onhand_qty + p_onorder_qty),0) = nvl(p_max,0) then
        l_graph_name := 'MscXVmiGraph27';
      elsif nvl((p_onhand_qty + p_onorder_qty),0) > nvl(p_max,0) then
        l_graph_name := 'MscXVmiGraph28';
      end if;
    elsif nvl((p_onhand_qty),0) < nvl(p_max,0) then
        if nvl(p_onorder_qty, 0) = 0 then
          l_graph_name := 'MscXVmiGraph3';
        else
          if nvl((p_onhand_qty + p_onorder_qty),0) < nvl(p_max,0) then
            l_graph_name := 'MscXVmiGraph5';
          elsif nvl((p_onhand_qty + p_onorder_qty),0) = nvl(p_max,0) then
            l_graph_name := 'MscXVmiGraph25';
          else
            l_graph_name := 'MscXVmiGraph8';
          end if;
        end if;
    elsif nvl((p_onhand_qty),0) = nvl(p_max,0) then
        if nvl(p_onorder_qty, 0) = 0 then
          l_graph_name := 'MscXVmiGraph24';
        else
            l_graph_name := 'MscXVmiGraph29';
        end if;
    elsif nvl((p_onhand_qty),0) > nvl(p_max,0) then
        if nvl(p_onorder_qty, 0) = 0 then
          l_graph_name := 'MscXVmiGraph6';
        else
            l_graph_name := 'MscXVmiGraph9';
        end if;
    end if;
  end if;

      RETURN l_graph_name;

   END;

   PROCEDURE convertDaysUnits(l_average_daily_usage IN OUT NOCOPY NUMBER, l_min_minmax_days IN OUT NOCOPY NUMBER, l_max_minmax_days IN OUT NOCOPY NUMBER,
      l_min_minmax_quantity IN OUT NOCOPY NUMBER, l_max_minmax_quantity IN OUT NOCOPY NUMBER)
   IS
   BEGIN
      IF l_average_daily_usage IS NOT NULL AND l_min_minmax_days IS NOT NULL AND l_min_minmax_quantity IS NULL THEN
         l_min_minmax_quantity := l_min_minmax_days * l_average_daily_usage;
      END IF;

      IF l_average_daily_usage IS NOT NULL AND l_max_minmax_days IS NOT NULL AND l_max_minmax_quantity IS NULL THEN
         l_max_minmax_quantity := l_max_minmax_days * l_average_daily_usage;
      END IF;

      IF l_average_daily_usage <> 0 AND l_min_minmax_quantity IS NOT NULL AND l_min_minmax_days IS NULL THEN
         l_min_minmax_days := l_min_minmax_quantity / l_average_daily_usage;
      END IF;

      IF l_average_daily_usage <> 0 AND l_max_minmax_quantity IS NOT NULL AND l_max_minmax_days IS NULL THEN
         l_max_minmax_days := l_max_minmax_quantity / l_average_daily_usage;
      END IF;
   END;

   FUNCTION  vmi_details_customer(
                            p_inventory_item_id   in number
                          , p_organization_id     IN NUMBER
                          , p_sr_instance_id      IN NUMBER
                          , p_customer_id         in number default null
                          , p_customer_site_id    in number default null
                          , p_supplier_id         in number default null
                          , p_supplier_site_id    in number default null
                          )
   RETURN VARCHAR2
   AS

      return_string         varchar2(3000);

      l_replenishment_quantity NUMBER;
      l_replenishment_date DATE;
      l_order_qty NUMBER;
      -- ONHAND
      l_current_onhand_quantity NUMBER;
      l_onhand_last_update_date DATE;
      -- IN TRANSIT
      l_intransit_count NUMBER;
      l_intransit_qty NUMBER;
      l_intransit_nextasn_ordernum VARCHAR2(255);
      l_intransit_nextdate DATE;
      l_intransit_nextasn_qty NUMBER;
      -- SHIPMENT RECEIPT
      l_last_receipt_date DATE;
      l_last_receipt_qty NUMBER;
      -- OTHER
      l_graph_name VARCHAR2(20);
      -- ITEM ATTRIBUTES from msc_item_suppliers/msc_system_items
      l_inventory_planning_code VARCHAR2(20);

      l_reorder_point NUMBER;
      l_economic_order_quantity NUMBER;

      l_average_daily_usage NUMBER;
      l_customer_item_name VARCHAR2(255);

      l_customer_item_desc VARCHAR2(255);
      l_supplier_item_name VARCHAR2(255);
      l_supplier_item_desc VARCHAR2(255);
      l_implemented_quantity NUMBER;
      l_supplier_uom_code VARCHAR2(255);
      l_quantity_in_process NUMBER;
      l_total_receipt_quantity NUMBER;
      l_owner_item_name VARCHAR2(255);
      l_owner_item_desc VARCHAR2(2550);
      l_min_minmax_quantity NUMBER;
      l_max_minmax_quantity NUMBER;
      l_min_minmax_days NUMBER;
      l_max_minmax_days NUMBER;
      l_supplier_to_customer_rate NUMBER;
      l_auto_replenish_flag VARCHAR2(255);
      l_release_method NUMBER;
      l_onorder_quantity NUMBER;

      -- New for VMI w/Customers
      l_asn_auto_expire NUMBER;
      l_consigned       NUMBER;
      l_forecast_horizon NUMBER;
        -- New for VMI w/Suppliers
     l_replenishment_method  NUMBER;
     l_fixed_order_quantity  NUMBER;
     l_lead_time NUMBER;
     l_source_org_id NUMBER;
     l_time_fence_end_date DATE;

   BEGIN

      vmiCustomerSetupvalues(p_inventory_item_id, p_organization_id, p_sr_instance_id,
                             l_min_minmax_quantity, l_min_minmax_days, l_max_minmax_quantity, l_max_minmax_days,
                             l_release_method,
                             l_asn_auto_expire, l_consigned,
                             l_fixed_order_quantity,l_supplier_uom_code, l_owner_item_name,
                             l_lead_time, l_forecast_horizon, l_source_org_id);

      l_average_daily_usage:=customer_avg_daily_usage(p_inventory_item_id
						      , p_organization_id
						      , p_sr_instance_id    ) ;

      l_supplier_item_name := l_owner_item_name;





      vmiCustomerCurrentOnhand(p_inventory_item_id,
                               p_customer_id, p_customer_site_id, p_supplier_id,
                               l_supplier_uom_code, l_consigned,
                               l_current_onhand_quantity, l_onhand_last_update_date);


      vmiCustomerReplenishment(p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id,
                               l_replenishment_quantity, l_replenishment_date, l_quantity_in_process);

     /*if l_replenishment_date is null then
      vmiCustomerTimeFenceEndDate(l_source_org_id,p_organization_id,p_customer_id, p_customer_site_id,
				 p_supplier_id,p_supplier_site_id,l_lead_time,p_sr_instance_id,l_consigned,
				 l_time_fence_end_date);
     else
     l_time_fence_end_date:=l_replenishment_date;
     end if;*/

      vmiCustomerIntransit
         (p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id, l_asn_auto_expire,
          l_replenishment_date,l_supplier_uom_code,
          l_intransit_qty, l_intransit_count,
          l_intransit_nextasn_ordernum,
          l_intransit_nextdate,
          l_intransit_nextasn_qty);

      IF l_consigned = CONSIGNED THEN
         vmiCustomerOrderQtyConsigned
         (p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id,
          l_replenishment_date,l_supplier_uom_code,
          l_order_qty);
      ELSE
         vmiCustomerOrderQtyUnconsigned
         (p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id,
          l_replenishment_date, l_supplier_uom_code,
          l_order_qty);
      END IF;

      vmiCustomerReceiptQty
      (p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id,
       l_replenishment_date, l_supplier_uom_code, l_total_receipt_quantity, l_last_receipt_qty, l_last_receipt_date);

      l_onorder_quantity := nvl(l_total_receipt_quantity,0) + nvl(l_order_qty,0) + nvl(l_intransit_qty,0) +
                            nvl(l_quantity_in_process,0);

      IF l_min_minmax_days IS NOT NULL OR l_max_minmax_days IS NOT NULL THEN
         IF l_fixed_order_quantity IS NULL THEN
            l_replenishment_method := 2;
         ELSE
            l_replenishment_method := 4;
         END IF ;
      ELSE
         IF l_fixed_order_quantity IS NULL THEN
            l_replenishment_method := 1;
         ELSE
            l_replenishment_method := 3;
         END IF ;
      END IF;

      IF l_fixed_order_quantity IS NOT NULL THEN
         l_max_minmax_quantity := l_current_onhand_quantity + l_fixed_order_quantity;
      END IF;

      convertDaysUnits(l_average_daily_usage,
         l_min_minmax_days, l_max_minmax_days,
         l_min_minmax_quantity, l_max_minmax_quantity);

      l_graph_name := vmiCustomerGraphName(l_current_onhand_quantity, l_onorder_quantity, l_min_minmax_quantity, l_max_minmax_quantity);


   --BUG 4589370
   --If the item name or the item description contains # then temporarily
   --we would convert this to '$_-'.

	if ( instr(l_customer_item_name,'#') <> 0) then
		l_customer_item_name := replace(l_customer_item_name,'#','$_-');
	end if;

	 if ( instr(l_customer_item_desc,'#') <> 0) then
		l_customer_item_desc := replace(l_customer_item_desc,'#','$_-');
	end if;

	 if ( instr(l_supplier_item_name,'#') <> 0) then
		l_supplier_item_name := replace(l_supplier_item_name,'#','$_-');
	end if;

	 if ( instr(l_supplier_item_desc,'#') <> 0) then
		l_supplier_item_desc := replace(l_supplier_item_desc,'#','$_-');
	end if;

	 if ( instr(l_owner_item_name,'#') <> 0) then
		l_owner_item_name := replace(l_owner_item_name,'#','$_-');
	end if;

	 if ( instr(l_owner_item_desc,'#') <> 0) then
		l_owner_item_desc := replace(l_owner_item_desc,'#','$_-');
	end if;

      return_string := l_replenishment_quantity
           || delim || l_replenishment_date
           || delim || l_order_qty
           || delim || nvl(l_current_onhand_quantity, 0)
           || delim || l_onhand_last_update_date
           || delim || l_intransit_count
           || delim || l_intransit_qty
           || delim || l_intransit_nextasn_ordernum
           || delim || l_intransit_nextdate
           || delim || l_intransit_nextasn_qty
           || delim || l_last_receipt_date
           || delim || l_last_receipt_qty
           || delim || l_graph_name
           || delim || l_inventory_planning_code
           || delim || l_reorder_point
           || delim || l_economic_order_quantity
           || delim || l_average_daily_usage
           || delim || l_customer_item_name
           || delim || l_customer_item_desc
           || delim || l_supplier_item_name
           || delim || l_supplier_item_desc
           || delim || l_implemented_quantity
           || delim || l_supplier_uom_code
           || delim || l_quantity_in_process
           || delim || l_total_receipt_quantity
           || delim || l_owner_item_name
           || delim || l_owner_item_desc
           || delim || nvl(l_min_minmax_quantity, 0)
           || delim || nvl(l_max_minmax_quantity, 0)
           || delim || l_supplier_to_customer_rate
           || delim || nvl(l_min_minmax_days, 0)
           || delim || nvl(l_max_minmax_days, 0)
           || delim || l_auto_replenish_flag
           || delim || l_release_method
           || delim || l_asn_auto_expire
           || delim || l_consigned
           || delim || l_replenishment_method;

      RETURN return_string;
   END;

    --- XXX
    ------------------------------------------------
    -- check which onhand type to use
    -- onhand logic: if allocated onhand exists,  --
    -- use it (only). else use unallocated onhand --
    -- only. they are mutually exclusive.         --
    ------------------------------------------------
   FUNCTION use_allocated
      (  p_inventory_item_id       in number default null
       , p_customer_id             in number default null
       , p_customer_site_id             in number default null
       , p_supplier_id             in number default null
       , p_supplier_site_id             in number default null
       )
   RETURN BOOLEAN
   IS
       l_exists VARCHAR2(20);

       CURSOR oh_cur is
       SELECT 'exists'
       FROM   msc_sup_dem_entries
       WHERE plan_id = -1
       AND publisher_order_type = ALLOCATED_ONHAND
       AND customer_id = p_customer_id
       AND nvl(customer_site_id,-99) = nvl(p_customer_site_id,-99)
       AND inventory_item_id = p_inventory_item_id
       AND nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
       AND nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99);
     --  AND vmi_flag = 1;
   BEGIN
      open oh_cur;
      fetch oh_cur INTO l_exists;
      close oh_cur;
      IF l_exists = 'exists' THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
   END;

   FUNCTION vmiCustomerGraphInit(l_start_date DATE, l_end_date DATE)
   RETURN Graph
   AS
      l_graph_horizon NUMBER := 0;
      l_graph         Graph;
      l_current_index NUMBER;
      l_data_point    MSC_VMI_GRAPH%ROWTYPE;
      l_current_date  DATE;

   BEGIN

      l_graph := Graph();
      l_graph.EXTEND(l_end_date - l_start_date + 1);

      -- insert days until forecast horizon
      FOR l_current_index IN 1..l_end_date-l_start_date+1 LOOP
         l_current_date := l_start_date + l_current_index -1 ;
         l_data_point.graph_date := l_current_date;
         l_data_point.order_forecast := 0;
         l_data_point.req := 0;
         l_data_point.onhand := 0;
         l_data_point.projected_onhand := 0;
         l_data_point.min := 0;
         l_data_point.max := 0;
         l_data_point.safety_stock := 0;
         l_data_point.asn := 0;
         l_data_point.po := 0;
         l_data_point.receipt := 0;
         l_graph(l_current_index) := l_data_point;
      END LOOP;

      RETURN l_graph;

   END;

   PROCEDURE retrieve_vmi_setup_info
      (  p_graph IN OUT NOCOPY Graph
       , p_inventory_item_id IN NUMBER DEFAULT NULL
       , p_customer_id       IN NUMBER DEFAULT NULL
       , p_customer_site_id  IN NUMBER DEFAULT NULL
       , p_supplier_id       IN NUMBER DEFAULT NULL
       , p_supplier_site_id  IN NUMBER DEFAULT NULL
           , p_min               OUT NOCOPY NUMBER
           , p_max               OUT NOCOPY NUMBER
           , P_lead_time         OUT NOCOPY NUMBER
       )
   IS

    CURSOR item_suppliers_cur is
      SELECT nvl(i.min_minmax_quantity,0) min_minmax_quantity, nvl(i.max_minmax_quantity,0) max_minmax_quantity,
              i.processing_lead_time AS processing_lead_time
      FROM msc_item_suppliers i, msc_items s, msc_trading_partners tp, msc_trading_partner_maps map_cust, msc_company_sites cust_site,
      msc_trading_partner_maps map_supp, msc_company_sites supp_site, msc_trading_partner_maps map_rel,
      msc_company_relationships rel
      WHERE i.plan_id = -1
     -- AND i.vmi_flag = 1
      AND i.inventory_item_id = s.inventory_item_id
      AND i.inventory_item_id = p_inventory_item_id
      AND tp.sr_instance_id = i.sr_instance_id
      AND tp.sr_tp_id = i.organization_id
      AND tp.partner_id = map_cust.tp_key
      AND map_cust.map_type = 2
      AND map_cust.company_key = cust_site.company_site_Id
      AND cust_site.company_id = p_customer_id
      AND cust_site.company_site_id = p_customer_site_id
      AND map_supp.tp_key = i.supplier_site_id
      AND map_supp.map_type = 3
      AND map_supp.company_key = supp_site.company_site_id
      AND supp_site.company_site_id = p_supplier_site_id
      AND supp_site.company_id = p_supplier_id
      AND i.supplier_id = map_rel.tp_key
      AND map_rel.map_type = 1
      AND map_rel.company_key = rel.relationship_id
      AND rel.relationship_type = 2
      AND rel.subject_id = p_customer_id
      AND rel.object_id = p_supplier_id;

      item_suppliers_rec    item_suppliers_cur%ROWTYPE;

   BEGIN

      OPEN item_suppliers_cur;
      fetch item_suppliers_cur into item_suppliers_rec;
      if item_suppliers_cur%found then
         p_min := item_suppliers_rec.min_minmax_quantity;
         p_max := item_suppliers_rec.max_minmax_quantity;
         p_lead_time := item_suppliers_rec.processing_lead_time;
      else
         p_min := 0;
         p_max := 0;
         p_lead_time := 0;
      end if;
      close item_suppliers_cur;

   END;


   PROCEDURE vmiCustomerGraphOnhand
      (  p_graph IN OUT NOCOPY Graph
       , p_inventory_item_id   IN NUMBER DEFAULT NULL
       , p_customer_id         IN NUMBER DEFAULT NULL
       , p_customer_site_id    IN NUMBER DEFAULT NULL
       , p_supplier_id         IN NUMBER DEFAULT NULL
       , p_uom_code            IN VARCHAR2
       , p_consigned           IN NUMBER DEFAULT NULL
       , p_average_daily_usage IN NUMBER
       )
   IS
      l_onhand_quantity NUMBER := 0;
      l_onhand_date DATE := NULL;
      l_current_index NUMBER;
   BEGIN

      vmiCustomerCurrentOnhand(
         p_inventory_item_id,
         p_customer_id,
         p_customer_site_id,
         p_supplier_id,
         p_uom_code,
         p_consigned,
         l_onhand_quantity,
         l_onhand_date);

      IF p_average_daily_usage IS NOT NULL THEN
         l_onhand_quantity := l_onhand_quantity / p_average_daily_usage;
      END IF;

      p_graph(1).onhand := l_onhand_quantity;
      FOR l_current_index IN 2..p_graph.COUNT LOOP
         p_graph(l_current_index).onhand := 0;
      END LOOP;

   END;

   PROCEDURE vmiCustomerGraphOrderForecast
      (  p_graph IN OUT NOCOPY Graph
       , p_inventory_item_id   IN NUMBER
       , p_customer_id         IN NUMBER
       , p_customer_site_id    IN NUMBER
       , p_supplier_id         IN NUMBER
       , p_supplier_site_id    IN NUMBER DEFAULT NULL
       , p_uom_code            IN VARCHAR2
       , p_average_daily_usage IN NUMBER
       )
   IS

      /* For a item only one of following order types will exist order_forecast,sales_forecast or historical_sales */

      CURSOR order_forecast_cur is
      SELECT sum(primary_quantity) as primary_quantity, trunc(key_date) as key_date, primary_uom
        FROM msc_sup_dem_entries
       WHERE plan_id = -1
         AND publisher_order_type IN (ORDER_FORECAST,SALES_FORECAST,HISTORICAL_SALES)
         AND inventory_item_id = p_inventory_item_id
         AND customer_id = p_customer_id
         AND customer_site_id = p_customer_site_id
         AND supplier_id = p_supplier_id
	 group by key_date,primary_uom;

      order_forecast_rec  order_forecast_cur%ROWTYPE;
      l_order_forecast_quantity NUMBER := 0;

      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
   BEGIN

      OPEN order_forecast_cur;
      LOOP
         FETCH order_forecast_cur INTO order_forecast_rec;
         EXIT WHEN order_forecast_cur%NOTFOUND;

         l_conv_rate := 1;
         IF order_forecast_rec.primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               order_forecast_rec.primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         order_forecast_rec.primary_quantity := nvl(order_forecast_rec.primary_quantity, 0) * l_conv_rate;
         FOR l_current_record IN 1..p_graph.COUNT LOOP
            l_order_forecast_quantity := order_forecast_rec.primary_quantity;
            IF p_average_daily_usage IS NOT NULL THEN
               l_order_forecast_quantity := l_order_forecast_quantity / p_average_daily_usage;
            END IF;
            IF p_graph(l_current_record).graph_date = order_forecast_rec.key_date THEN
               p_graph(l_current_record).order_forecast := p_graph(l_current_record).order_forecast + l_order_forecast_quantity;
            END IF;
         END LOOP;

      END LOOP;
      CLOSE order_forecast_cur;

   END;

   FUNCTION getSupplyWithinLeadTime(p_graph IN OUT NOCOPY Graph, l_current_record NUMBER, p_lead_time NUMBER, p_calendar_code VARCHAR2, p_calendar_inst_id NUMBER)
   RETURN NUMBER
   IS
      l_index NUMBER;
      l_quantity NUMBER := 0;
      l_time_fence_end_date DATE;
   BEGIN
      l_time_fence_end_date := msc_calendar.date_offset(p_calendar_code, p_calendar_inst_id, p_graph(l_current_record).graph_date, p_lead_time, 99999);
      FOR l_index IN l_current_record..p_graph.LAST LOOP
         IF p_graph(l_index).graph_date <= l_time_fence_end_date THEN
            l_quantity := l_quantity + p_graph(l_index).req;
         END IF;
      END LOOP;

      RETURN l_quantity;
   END;

   PROCEDURE  vmiCustomerGraphProjOnhand(p_graph IN OUT NOCOPY Graph, p_lead_time NUMBER, p_calendar_code VARCHAR2, p_calendar_inst_id NUMBER)
   IS
      l_current_record NUMBER;
      l_previous_onhand NUMBER;
      l_demands NUMBER;
      l_supplies NUMBER;
      l_replenish NUMBER;
      l_supply_within_lead_time NUMBER;
      l_time_fence_end_date DATE;
      l_nr_of_days NUMBER;

   BEGIN
      l_previous_onhand := p_graph(1).onhand;
      FOR l_current_record IN 2..p_graph.COUNT LOOP
         l_demands := p_graph(l_current_record).order_forecast;
         l_supplies := p_graph(l_current_record).req;
         p_graph(l_current_record).projected_onhand := l_previous_onhand - l_demands + l_supplies;
        --IF p_graph(l_current_record).projected_onhand < 0 THEN
        --    p_graph(l_current_record).projected_onhand := 0;
        -- END IF;
         l_previous_onhand := p_graph(l_current_record).projected_onhand;

         l_supply_within_lead_time := getSupplyWithinLeadTime(p_graph, l_current_record, p_lead_time, p_calendar_code, p_calendar_inst_id);
         -- Refuel
         IF p_graph(l_current_record).projected_onhand + l_supply_within_lead_time <= p_graph(l_current_record).MIN THEN
            l_replenish := p_graph(l_current_record).max - (l_supply_within_lead_time + p_graph(l_current_record).projected_onhand);
            l_time_fence_end_date := msc_calendar.date_offset(p_calendar_code, p_calendar_inst_id, p_graph(l_current_record).graph_date, p_lead_time, 99999);
            IF l_time_fence_end_date <= p_graph(p_graph.LAST).graph_date THEN
               l_nr_of_days := l_time_fence_end_date - p_graph(l_current_record).graph_date;
               p_graph(l_current_record + l_nr_of_days).req := p_graph(l_current_record + l_nr_of_days).req + l_replenish;
            END IF;
         END IF;
      END LOOP;

   END;

   PROCEDURE vmiCustomerGraphFixedOrderMax
      (  p_graph IN OUT NOCOPY Graph
       , p_fixed_order_qty     IN NUMBER
       )
   IS
      l_current_record NUMBER;
   BEGIN
      FOR l_current_record IN p_graph.FIRST..p_graph.LAST LOOP
         p_graph(l_current_record).max := p_graph(l_current_record).projected_onhand + p_fixed_order_qty;
      END LOOP;
   END;


   PROCEDURE vmiCustomerGraphMinMax
      (  p_graph IN OUT NOCOPY Graph
       , p_min IN NUMBER
       , p_max IN NUMBER
       )
   IS
      l_current_record NUMBER;
   BEGIN
      FOR l_current_record IN p_graph.FIRST..p_graph.LAST LOOP
         p_graph(l_current_record).min := nvl(p_min, 0);
         p_graph(l_current_record).max := nvl(p_max, 0);
      END LOOP;
   END;

   PROCEDURE vmiCustomerGraphSafetyStock
      (  p_graph IN OUT NOCOPY Graph
       , p_inventory_item_id   IN NUMBER
       , p_customer_id         IN NUMBER
       , p_customer_site_id    IN NUMBER
       , p_average_daily_usage IN NUMBER
       , p_uom_code IN VARCHAR2
       )
   IS

      CURSOR safety_stock_cur is
      SELECT primary_quantity AS primary_quantity,
             trunc(key_date) AS key_date,
             bucket_type as bucket_type, primary_uom
      FROM   msc_sup_dem_entries
      WHERE  plan_id = -1
      AND    publisher_order_type = SAFETY_STOCK
      AND    publisher_id = p_customer_id
      AND    publisher_site_id = p_customer_site_id
      AND    inventory_item_id = p_inventory_item_id
      ORDER BY trunc(key_date);

      safety_stock_rec  safety_stock_cur%ROWTYPE;
      key_date          DATE;
      graph_start_date  DATE;
      graph_end_date    DATE;
      l_safety_stock    NUMBER;
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
   BEGIN

      IF p_graph.COUNT = 0 THEN
         RETURN;
      END IF;

      graph_start_date := p_graph(p_graph.FIRST).graph_date;
      graph_end_date := p_graph(p_graph.LAST).graph_date;

      OPEN safety_stock_cur;
      LOOP
         FETCH safety_stock_cur INTO safety_stock_rec;
         EXIT WHEN safety_stock_cur%NOTFOUND;
         l_conv_rate := 1;
         IF safety_stock_rec.primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               safety_stock_rec.primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         safety_stock_rec.primary_uom := safety_stock_rec.primary_uom * l_conv_rate;
         key_date := safety_stock_rec.key_date;
         IF key_date < graph_start_date THEN
             key_date := graph_start_date;
         END IF;
         IF key_date <= graph_end_date THEN
            l_safety_stock := safety_stock_rec.primary_quantity;
            IF p_average_daily_usage IS NOT NULL THEN
               l_safety_stock := l_safety_stock / p_average_daily_usage;
            END IF;
            FOR i IN key_date-graph_start_date+1..graph_end_date-graph_start_date+1 LOOP
               p_graph(i).safety_stock := l_safety_stock;
            END LOOP;
         END IF;
      END LOOP;
      CLOSE safety_stock_cur;
   END;

   PROCEDURE vmiCustomerGraphRequisition
      (  p_graph IN OUT NOCOPY Graph
       , p_inventory_item_id   IN NUMBER
       , p_customer_id         IN NUMBER
       , p_customer_site_id    IN NUMBER
       , p_supplier_id         IN NUMBER
       , p_supplier_site_id    IN NUMBER DEFAULT NULL
       , p_average_daily_usage IN NUMBER
       , p_uom_code VARCHAR2
       )
   IS
    CURSOR requisition_cur is
    SELECT primary_quantity AS primary_quantity,
           tp_quantity AS tp_quantity, trunc(key_date) AS key_date, primary_uom
    FROM   msc_sup_dem_entries
    WHERE  plan_id = -1
    AND    publisher_order_type = REQUISITION
    AND    customer_id = p_customer_id
    AND    customer_site_id = p_customer_site_id
    AND    inventory_item_id = p_inventory_item_id
    AND    nvl(supplier_id,-99) = nvl(p_supplier_id,-99)
    AND    nvl(supplier_site_id,-99) = nvl(p_supplier_site_id,-99);

      requisition_rec  requisition_cur%ROWTYPE;
      l_quantity NUMBER;
      l_conv_rate NUMBER;
      l_conv_found BOOLEAN;
   BEGIN

      OPEN requisition_cur;
      LOOP
      FETCH requisition_cur INTO requisition_rec;
         EXIT WHEN requisition_cur%NOTFOUND;
         l_conv_rate := 1;
         IF requisition_rec.primary_uom <> p_uom_code THEN
            MSC_X_UTIL.GET_UOM_CONVERSION_RATES(
               requisition_rec.primary_uom
               , p_uom_code
               , p_inventory_item_id
               , l_conv_found
               , l_conv_rate);
         END IF;
         requisition_rec.primary_quantity := requisition_rec.primary_quantity * l_conv_rate;
         FOR l_current_record IN 1..p_graph.COUNT LOOP
            IF p_graph(l_current_record).graph_date = requisition_rec.key_date THEN
               l_quantity := requisition_rec.primary_quantity;
               IF p_average_daily_usage IS NOT NULL THEN
                  l_quantity := l_quantity / p_average_daily_usage;
               END IF;
               p_graph(l_current_record).req := p_graph(l_current_record).req + l_quantity;
            END IF;
         END LOOP;

      END LOOP;
      CLOSE requisition_cur;

   END;

   PROCEDURE vmiCustomerGraphSave(p_graph IN OUT NOCOPY Graph, p_query_id OUT NOCOPY NUMBER)
   IS
      l_query_id NUMBER;
      l_current_record NUMBER;
      l_debug_flag BOOLEAN := FALSE;
   BEGIN
      IF l_debug_flag = FALSE THEN
         -- get the query id first
         SELECT msc_x_hz_ui_query_id_s.nextval INTO l_query_id FROM Dual;
         FOR l_current_record IN p_graph.FIRST..p_graph.LAST LOOP
            INSERT INTO MSC_VMI_GRAPH
               (query_id, graph_date, onhand, order_forecast, req, po, asn, receipt,
                projected_onhand, supply_within_lead_time,
                MIN, max, safety_stock, recommended_replenishment)
            VALUES (l_query_id,p_graph(l_current_record).graph_date,p_graph(l_current_record).onhand,
                p_graph(l_current_record).order_forecast,p_graph(l_current_record).req,p_graph(l_current_record).po,
                p_graph(l_current_record).asn,p_graph(l_current_record).receipt,
                p_graph(l_current_record).projected_onhand,p_graph(l_current_record).supply_within_lead_time,
                p_graph(l_current_record).min,p_graph(l_current_record).max,p_graph(l_current_record).safety_stock,
                p_graph(l_current_record).recommended_replenishment);
         END LOOP;
    /* ELSE
         -- Excel output
      --   DBMS_OUTPUT.put_line('Graph has ' || p_graph.COUNT || ' entries.');
      --  DBMS_OUTPUT.put_line('"Date", "OH", "OF", "REQ", "PO", "ASN", "REC", "POH", "LT", "MN", "MX", "SS"');
       --  FOR l_current_record IN 1..p_graph.COUNT LOOP
        --  dbms_output.put('"' || p_graph(l_current_record).graph_date || '","' || p_graph(l_current_record).onhand || '",');
          --  dbms_output.put('"' || p_graph(l_current_record).order_forecast || '","' || p_graph(l_current_record).req || '","' || p_graph(l_current_record).po || '",');
          --  dbms_output.put('"' || p_graph(l_current_record).asn || '","' || p_graph(l_current_record).receipt || '",');
          --  dbms_output.put('"' || p_graph(l_current_record).projected_onhand || '","' || p_graph(l_current_record).supply_within_lead_time ||'",');
          --  dbms_output.put_line('"' || nvl(p_graph(l_current_record).MIN, -1) || '","' || nvl(p_graph(l_current_record).MAX, -1) || '","' || p_graph(l_current_record).safety_stock || '"');
         END LOOP; */
      END IF;
      p_query_id := l_query_id;
   END;

   PROCEDURE vmiCustomerGraphTest
   IS
      l_graph Graph;
      l_query_id NUMBER;
      l_index BINARY_INTEGER;
   BEGIN
      l_graph := vmiCustomerGraphInit(SYSDATE + 5, SYSDATE + 40);
      l_graph(1).onhand := 30;
      l_graph(8).req := 150;
      vmiCustomerGraphMinMax(l_graph, 200, 800);
      FOR l_index IN l_graph.FIRST+1..l_graph.LAST LOOP
         l_graph(l_index).order_forecast := 15;
      END LOOP;
      vmiCustomerGraphProjOnhand(l_graph, 5, 'LIDAB01', 121);

      vmiCustomerGraphSave(l_graph, l_query_id);
   END;

   FUNCTION get_start_date
   RETURN DATE
   IS
      l_start_date DATE := NULL;
   BEGIN
      SELECT status_date
        INTO l_start_date
        FROM msc_plan_org_status
       WHERE plan_id = -1
         AND organization_id = -1
         AND sr_instance_id = -1;

      RETURN nvl(l_start_date, SYSDATE);

   EXCEPTION
      WHEN OTHERS THEN
             RETURN SYSDATE;
   END;

   FUNCTION getIntransitLeadTime(p_supplier_id NUMBER, p_org_id NUMBER, p_sr_instance_id NUMBER, p_source_org_id NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER, p_consigned NUMBER)
   RETURN NUMBER
   IS
      l_source_site_id NUMBER := 0;
      l_session_id     NUMBER;
      l_return_status  VARCHAR2(1);
      l_ship_method    varchar2(30);
      l_intransit_lead_time NUMBER := 0;
   BEGIN
      IF p_consigned = UNCONSIGNED AND p_source_org_id IS NOT NULL THEN
         BEGIN
         SELECT maps.company_key
           INTO l_source_site_id
           FROM msc_trading_partner_maps maps, msc_trading_partners tp
          WHERE tp.partner_type = ASCP_TP_MAP_TYPE_ORG
            AND tp.sr_instance_id = p_sr_instance_id
            AND tp.sr_tp_id = p_source_org_id
            AND tp.partner_id = maps.tp_key
            AND maps.map_type = TP_MAP_TYPE_ORG;
         EXCEPTION WHEN OTHERS THEN NULL;
         END;

         l_intransit_lead_time := msc_x_util.get_customer_transit_time(p_supplier_id, l_source_site_id, p_customer_id, p_customer_site_id);
      ELSIF p_consigned = CONSIGNED AND p_source_org_id IS NOT NULL THEN
         BEGIN

            select mrp_atp_schedule_temp_s.nextval
              into l_session_id
              from dual;

          msc_atp_proc.atp_intransit_lt(
              2,                       --- Destination
              l_session_id,            -- session_id
              p_source_org_id,         -- from_org_id
              null,                    -- from_loc_id
              null,                    -- from_vendor_site_id
              p_sr_instance_id,           -- p_from_instance_id
              p_org_id,                -- p_to_org_id
              null,                    -- p_to_loc_id
              null,                    -- p_to_customer_site_id
              p_sr_instance_id,           -- p_to_instance_id
              l_ship_method,           -- p_ship_method
              l_intransit_lead_time,   -- x_intransit_lead_time
              l_return_status          -- x_return_status
          );

          if (l_intransit_lead_time is null) then
             l_intransit_lead_time := 0;
          end if;

         EXCEPTION WHEN OTHERS THEN NULL;
         END;

      END IF;
      RETURN l_intransit_lead_time;
   END;

   PROCEDURE  vmiCustomerGraphCreate
      (  p_inventory_item_id IN NUMBER
       , p_organization_id   IN NUMBER
       , p_sr_instance_id    IN NUMBER
       , p_customer_id       IN NUMBER
       , p_customer_site_id  IN NUMBER
       , p_supplier_id       IN NUMBER
       , p_supplier_site_id  IN NUMBER
       , p_query_id          OUT NOCOPY NUMBER
       )
   IS
      l_graph Graph;
      l_query_id NUMBER;
      l_lead_time NUMBER;
      l_start_date DATE;
      l_forecast_horizon NUMBER;
      l_consigned NUMBER := NULL;
      l_min_minmax_qty NUMBER;
      l_max_minmax_qty NUMBER;
      l_min_minmax_days NUMBER;
      l_max_minmax_days NUMBER;
      l_asn_auto_expire NUMBER;
      l_supplier_uom_code VARCHAR2(255);
      l_release_method NUMBER;
      l_average_daily_usage NUMBER;
      l_fixed_order_quantity  NUMBER;
      l_item_name VARCHAR2(255);
      l_intransit_lead_time NUMBER := 0;
      l_source_org_id NUMBER;

      l_calendar_code VARCHAR2(14);
      l_calendar_inst_id NUMBER;
      l_time_fence_end_date DATE;
   BEGIN
      vmiCustomerSetupvalues(p_inventory_item_id, p_organization_id, p_sr_instance_id,
         l_min_minmax_qty, l_min_minmax_days, l_max_minmax_qty, l_max_minmax_days,
         l_release_method,  l_asn_auto_expire,
         l_consigned, l_fixed_order_quantity,
         l_supplier_uom_code, l_item_name, l_lead_time, l_forecast_horizon, l_source_org_id);

      l_start_date := trunc(get_start_date);

      l_average_daily_usage:=customer_avg_daily_usage(p_inventory_item_id
						      , p_organization_id
						      , p_sr_instance_id    ) ;


      msc_x_util.get_calendar_code(p_supplier_id,p_supplier_site_id,p_customer_id,p_customer_site_id,l_calendar_code,l_calendar_inst_id);
      l_time_fence_end_date := msc_calendar.date_offset(l_calendar_code, l_calendar_inst_id, l_start_date, l_forecast_horizon, 99999);

      l_graph := vmiCustomerGraphInit(l_start_date, l_time_fence_end_date);

      IF l_min_minmax_days IS NOT NULL OR l_max_minmax_days IS NOT NULL THEN
         IF l_average_daily_usage IS NULL OR l_average_daily_usage = 0 THEN
            p_query_id := -1;
            RETURN;
         END IF;
      ELSE
         l_average_daily_usage := NULL;
      END IF;

      convertDaysUnits(l_average_daily_usage,
         l_min_minmax_days, l_max_minmax_days,
         l_min_minmax_qty, l_max_minmax_qty);

      vmiCustomerGraphOnhand(l_graph, p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id, l_supplier_uom_code, l_consigned, l_average_daily_usage);
      vmiCustomerGraphOrderForecast(l_graph, p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id, p_supplier_site_id, l_supplier_uom_code, l_average_daily_usage);
      vmiCustomerGraphRequisition(l_graph, p_inventory_item_id, p_customer_id, p_customer_site_id, p_supplier_id, p_supplier_site_id, l_average_daily_usage, l_supplier_uom_code);
      vmiCustomerGraphSafetyStock(l_graph, p_inventory_item_id, p_customer_id, p_customer_site_id, l_average_daily_usage, l_supplier_uom_code);

      IF l_average_daily_usage IS NOT NULL THEN
         vmiCustomerGraphMinMax(l_graph, l_min_minmax_days, l_max_minmax_days);
      ELSE
         vmiCustomerGraphMinMax(l_graph, l_min_minmax_qty, l_max_minmax_qty);
      END IF;

      IF l_fixed_order_quantity IS NOT NULL THEN
         IF l_average_daily_usage IS NOT NULL THEN
            vmiCustomerGraphFixedOrderMax(l_graph, l_fixed_order_quantity / l_average_daily_usage);
         ELSE
            vmiCustomerGraphFixedOrderMax(l_graph, l_fixed_order_quantity);
         END IF;
      END IF;

      l_intransit_lead_time := getIntransitLeadTime(p_supplier_id , p_organization_id , p_sr_instance_id , l_source_org_id , p_customer_id , p_customer_site_id , l_consigned );
      vmiCustomerGraphProjOnhand(l_graph, l_lead_time + l_intransit_lead_time, l_calendar_code, l_calendar_inst_id);

      vmiCustomerGraphSave(l_graph, l_query_id);
      p_query_id := l_query_id;

   END;

--  VMI Suppliers Onhand Graph

Procedure     VMISUPPLIERGRAPHONHAND
   ( p_inventory_item_id	IN NUMBER,
     p_customer_id		IN NUMBER,
     p_customer_site_id		IN NUMBER,
     p_supplier_id		IN NUMBER,
     p_supplier_site_id IN NUMBER,
     p_organization_id  IN NUMBER,
     p_tp_supplier_id    IN NUMBER,
     p_tp_supplier_site_id IN NUMBER,
     p_sr_instance_id   IN NUMBER,
     p_plan_id			IN NUMBER,
     p_return_code      OUT NOCOPY NUMBER,
     p_err_msg          OUT NOCOPY VARCHAR2
     )
     IS




    --   local variables for given inputs

    l_item_id               NUMBER;
    l_customer_id           NUMBER;
    l_customer_site_id      NUMBER;
    l_supplier_id           NUMBER;
    l_supplier_site_id      NUMBER;


    -- other variables

    l_total_supplies	    NUMBER;
    l_total_demands	        NUMBER;
    l_onhand		        NUMBER;

    l_forecast_horizon      NUMBER;
    l_avg_daily_demand      NUMBER;
    l_min_quantity	    NUMBER;
    l_min_days		        NUMBER;
    l_max_quantity	        NUMBER;
    l_max_days		        NUMBER;
    l_fix_quantity          NUMBER;
    l_fix_days              NUMBER;
    l_replenishment_method  NUMBER;

    l_lead_time		    NUMBER;
    l_customer_transit_time NUMBER;
    l_total_lead_time    NUMBER;

    l_req_length	    NUMBER;
    l_sim_req_sum       NUMBER;
    l_key_date          DATE;
    l_date_diff         NUMBER;

    lv_calendar_code    varchar2(14);
    lv_instance_id      number;
    l_offset_days       number;
    l_time_fence_end_date DATE;
    l_time_fence_lead_time number :=0;
    l_time_fence_multiplier number;

    l_debug_msg         VARCHAR2(1000);

    -- pl/sql tables forstroing graphical data

    TYPE t_table_graph_data IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;


    t_table_sim_pab t_table_graph_data;
    t_table_pab t_table_graph_data  ;
    t_table_pab_days t_table_graph_data  ;
    t_table_req t_table_graph_data  ;
    t_table_supplies t_table_graph_data  ;
    t_table_demands t_table_graph_data  ;
    t_table_avg_daily_demand t_table_add_data;



  /**
  *  Cursor sums the total supplies between sysdate and sysdate+horizon
  *  Requisition,Purchase Order+ASN+Receipts
  */


    CURSOR c_total_supplies (l_forecast_horizon number)
    IS
    SELECT sum(primary_quantity),key_date
    FROM   msc_sup_dem_entries supdem
    WHERE supdem.publisher_order_type in (20,13,15,16)
    AND	  supdem.inventory_item_id = p_inventory_item_id
    AND   supdem.customer_id=p_customer_id
    AND   supdem.customer_site_id=p_customer_site_id
    AND   supdem.supplier_id=p_supplier_id
    AND   supdem.supplier_site_id=p_supplier_site_id
    AND   supdem.plan_id=p_plan_id
    group by key_date
    having (trunc(key_date)>trunc(sysdate) and trunc(key_date)<=trunc(sysdate+l_forecast_horizon) );

  /**
  *  Cursor sums the total supplies between sysdate and sysdate+horizon
  *  Order Forecast
  */

    CURSOR c_total_demands(forecast_horizon IN NUMBER)
    IS
       SELECT sum(primary_quantity),key_date
	   FROM   msc_sup_dem_entries supdem
	   WHERE publisher_order_type =2
	   AND    supdem.inventory_item_id=p_inventory_item_id
	   AND   supdem.customer_id=p_customer_id
       AND   supdem.customer_site_id=p_customer_site_id
       AND   supdem.supplier_id=p_supplier_id
       AND   supdem.supplier_site_id=p_supplier_site_id
       AND   supdem.plan_id=p_plan_id
       group by key_date
       having (trunc(key_date)>trunc(sysdate) and trunc(key_date)<=trunc(sysdate+l_forecast_horizon) );



    CURSOR c_asl_attributes
      IS
       SELECT  nvl(forecast_horizon,0) forecast_horizon, nvl(min_minmax_quantity,0) min_minmax_quantity, nvl(max_minmax_quantity,
       0) max_minmax_quantity,nvl(min_minmax_days,0) min_minmax_days ,nvl(max_minmax_days,0) max_minmax_days,nvl(fixed_order_quantity,0) fixed_order_quantity, replenishment_method,
       nvl(processing_lead_time,0) processing_lead_time
       FROM  msc_item_suppliers mis
       WHERE mis.inventory_item_id = p_inventory_item_id
       AND  mis.plan_id = p_plan_id
       AND  mis.sr_instance_id = p_sr_instance_id
       AND  mis.organization_id = p_organization_id
       AND  mis. supplier_id = p_tp_supplier_id
       AND  mis. supplier_site_id = p_tp_supplier_site_id
       and   vmi_flag = 1
       order by using_organization_id desc;

       asl_attributes_rec    c_asl_attributes%ROWTYPE;


--  Note Other part of leadtime will be provided by pragnesh and
--  then also include the time*fence factor

   CURSOR c_onhand
    IS
       SELECT primary_quantity
	   FROM   msc_sup_dem_entries supdem
	   WHERE publisher_order_type =9
	   AND   supdem.inventory_item_id=p_inventory_item_id
	   AND   supdem.customer_id=p_customer_id
       AND   supdem.customer_site_id=p_customer_site_id
       AND   supdem.supplier_id=p_supplier_id
       AND   supdem.supplier_site_id=p_supplier_site_id
       AND   supdem.plan_id=p_plan_id;

--   To get the time fence multiplier

     CURSOR c_tf_multiplier
     IS
       SELECT distinct number1
       FROM  msc_plan_org_status
       WHERE plan_id=-1
       AND   sr_instance_id=-1
       AND   organization_id=-1 ;


    BEGIN

     p_return_code:=0;
    -- dbms_output.put_line('the initial date is');

       BEGIN

            open c_asl_attributes;
	      fetch c_asl_attributes into asl_attributes_rec;
	      if c_asl_attributes%found then
		l_forecast_horizon:= asl_attributes_rec.forecast_horizon;
		l_min_quantity:= asl_attributes_rec.min_minmax_quantity;
		l_max_quantity:= asl_attributes_rec.max_minmax_quantity;
		l_min_days:= asl_attributes_rec.min_minmax_days;
		l_max_days:= asl_attributes_rec.max_minmax_days;
		l_fix_quantity:= asl_attributes_rec.fixed_order_quantity;
		l_replenishment_method:= asl_attributes_rec.replenishment_method;
		l_lead_time:= asl_attributes_rec.processing_lead_time;
	     end if;
           close c_asl_attributes;

           exception when others then
                l_debug_msg:= l_debug_msg ||' '|| 'asl error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
               -- dbms_output.put_line('l_debug_msg:=' ||l_debug_msg);


       END;
       l_avg_daily_demand:=supplier_avg_daily_usage(	 p_inventory_item_id
							, p_organization_id
							, p_sr_instance_id
							, p_tp_supplier_id
							, p_tp_supplier_site_id
							) ;

        -- open c_onhand and assign them to variables
    BEGIN

        OPEN c_onhand;
        FETCH c_onhand INTO l_onhand;
            IF c_onhand%NOTFOUND THEN
                l_onhand:=0;
            END IF;

        CLOSE c_onhand;

        exception when others then
                --l_onhand:=0;
                l_debug_msg:= l_debug_msg ||' '|| 'onhand error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
                --dbms_output.put_line('l_debug_msg:=' ||l_debug_msg);

    END;



    -- populate the supplies data in supplies table and initilize it appropriately
    -- l_forecast_horizon:=100;
    BEGIN

        FOR v_counter IN 1..l_forecast_horizon
        LOOP
            t_table_supplies(v_counter):=0;
        END LOOP;
        --t_table_supplies(2):=60;
    END;


    BEGIN
    OPEN c_total_supplies(l_forecast_horizon);
     LOOP
      fetch c_total_supplies into l_total_supplies,l_key_date;
      IF c_total_supplies%FOUND THEN
        l_date_diff:=trunc(l_key_date)-trunc(sysdate);
       -- dbms_output.put_line('l_err_msg date diff is :=' ||l_date_diff);
        t_table_supplies(l_date_diff):=l_total_supplies;
      ELSE
        EXIT;
      END IF;
    END LOOP ;
    CLOSE c_total_supplies;

    exception when others then

                l_debug_msg:= l_debug_msg ||' '|| 'total supplies error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
               -- dbms_output.put_line('l_debug_msg:=' ||l_debug_msg);
    END;

    BEGIN
    OPEN c_tf_multiplier;
    fetch c_tf_multiplier into l_time_fence_multiplier;
    CLOSE c_tf_multiplier;

            exception when others then
                l_debug_msg:= l_debug_msg ||' '|| 'time fence error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
		l_time_fence_multiplier:=1;
               -- dbms_output.put_line('l_debug_msg:=' ||l_debug_msg);


       END;





     -- populate the supplies data in demands table and initilize it appropriately


    BEGIN
        FOR v_counter IN 1..l_forecast_horizon
        LOOP
        t_table_demands(v_counter):=0;
        END LOOP;
    END;
       --t_table_demands(2):=40;
      -- t_table_demands(4):=40;
      -- t_table_demands(6):=40;
      -- t_table_demands(8):=40;

     BEGIN

        OPEN c_total_demands(l_forecast_horizon);
        LOOP
            fetch c_total_demands into l_total_demands,l_key_date;
            IF  c_total_demands%FOUND THEN
                l_date_diff:=trunc(l_key_date)-trunc(sysdate);
                t_table_demands(l_date_diff):=l_total_demands;
            ELSE
                EXIT;

            END IF;
       END LOOP ;
       CLOSE c_total_demands;





       exception when others then
                l_debug_msg:= l_debug_msg ||' '|| 'demands error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
               -- dbms_output.put_line('l_debug_msg:=' ||l_debug_msg);
      END;

    BEGIN




  /**	 total lead time calculated using appropriate
   *     calendar code
   */

     l_customer_transit_time :=MSC_X_UTIL.GET_CUSTOMER_TRANSIT_TIME
     ( p_supplier_id, -- CP ids
     p_supplier_site_id,
     p_customer_id,
     p_customer_site_id );

    --dbms_output.put_line('intransit time for customer is  ' ||l_customer_transit_time);

    l_total_lead_time:=l_time_fence_multiplier*(l_lead_time +  l_customer_transit_time) ;


    --dbms_output.put_line(' total lead time with time fence multiplier is  ' ||l_total_lead_time);
    --dbms_output.put_line('  time fence multiplier is  ' ||l_time_fence_multiplier);

   -- dbms_output.put_line(' l_lead time  ' ||l_lead_time);
   -- dbms_output.put_line(' avg daily demand is   ' ||l_avg_daily_demand);


     /* Call the API to get the correct Calendar */
    msc_x_util.get_calendar_code(
     p_supplier_id,
     p_supplier_site_id,
     p_customer_id ,                --- OEM
     p_customer_site_id,  -- oem Org
     lv_calendar_code,
     lv_instance_id
     );

   -- dbms_output.put_line('calendar code is   ' ||lv_calendar_code);





    l_req_length:=l_total_lead_time*7 + l_forecast_horizon;

    FOR v_counter IN 1..l_req_length+1
    LOOP
       t_table_req(v_counter):=0;
    END LOOP;

    /**
     *   convert min_days in quantity
     */

     IF l_replenishment_method=2 OR l_replenishment_method=4
     THEN
        l_min_quantity:=l_avg_daily_demand*l_min_days;
     END IF;



    /**
     *  logic for simulating the requisition
     */

    FOR v_index IN 1 ..(l_forecast_horizon+1)
    LOOP

       IF v_index=1
       THEN
          t_table_pab(v_index):=l_onhand ;
       ELSE
	       t_table_pab(v_index):=t_table_pab(v_index-1) +t_table_supplies(v_index-1)-t_table_demands(v_index-1);
           t_table_pab(v_index):= t_table_pab(v_index)+ t_table_req(v_index);
       END IF;



       l_sim_req_sum:=0;
       for v_leadtime_index IN v_index..v_index+l_time_fence_lead_time
       LOOP
          l_sim_req_sum:=l_sim_req_sum+t_table_req(v_leadtime_index);
       END LOOP;
       t_table_sim_pab(v_index):=t_table_pab(v_index)+l_sim_req_sum;

       IF t_table_sim_pab(v_index)<l_min_quantity
       THEN

	   l_time_fence_end_date:=MSC_CALENDAR.DATE_OFFSET(
					  lv_calendar_code -- arg_calendar_code IN varchar2,
					, lv_instance_id -- arg_instance_id IN NUMBER,
					, SYSDATE+v_index-1 -- arg_date IN DATE,
					, l_total_lead_time -- arg_offset IN NUMBER
					, 99999  --arg_offset_type
					);

      --    dbms_output.put_line('end date is    ' ||l_time_fence_end_date);
          l_time_fence_lead_time:=l_time_fence_end_date-(sysdate+v_index-1);
       --   dbms_output.put_line('time fence lead time is     ' ||l_time_fence_lead_time);
           -- calculation of req in quantity depending upon the replenishment method


           IF l_replenishment_method=1
           THEN
                t_table_req(v_index+l_time_fence_lead_time):=l_max_quantity-t_table_pab(v_index);
              --  dbms_output.put_line('the value of lmax is ' ||l_max_quantity);

           ELSIF l_replenishment_method=3 or l_replenishment_method=4
           THEN
                t_table_req(v_index+l_time_fence_lead_time):=l_fix_quantity;
           ELSIF l_replenishment_method=2
           THEN
                t_table_req(v_index+l_time_fence_lead_time):=(l_max_days*l_avg_daily_demand)-t_table_pab(v_index);
           END IF;
             --   t_table_pab(v_index):=t_table_pab(v_index)+t_table_req(v_index);
	  --   dbms_output.put_line('the value of v_index is  is' || v_index);
           --  dbms_output.put_line('the value of lrequisition created is' || t_table_req(v_index+l_time_fence_lead_time));
       END IF;

    END LOOP;



    IF l_replenishment_method=2 OR l_replenishment_method=4
    THEN
       t_table_avg_daily_demand:= AVG_DAILY_DEMAND(p_inventory_item_id,p_customer_id,
        p_customer_site_id,p_supplier_id,p_supplier_site_id,p_plan_id,l_forecast_horizon);

         FOR v_index IN 1 ..(l_forecast_horizon+1)
	    LOOP
       -- dbms_output.put_line('the value of avg daily demand is ' || t_table_avg_daily_demand(v_index));
        IF t_table_avg_daily_demand(v_index) <> 0
        THEN
             t_table_pab_days(v_index):=t_table_pab(v_index)/t_table_avg_daily_demand(v_index);
            -- dbms_output.put_line('the value of PAB in days is  ' || t_table_pab_days(v_index));
        ELSE
            t_table_pab_days(v_index):=0;
          --  dbms_output.put_line('the value of PAB in days is  ' || t_table_pab_days(v_index));
        END IF;
        END LOOP;
    END IF;



    IF l_replenishment_method=4
    THEN
        IF l_avg_daily_demand <> 0
        THEN
            l_fix_days:=l_fix_quantity/l_avg_daily_demand;
         ELSE
            l_fix_days:=0;
         END IF;
    END IF;



    /**
    *   Prior to populating the data delete all the records
    */

    delete from msc_vmi_graph;

    /**
     *Check the value of replenishment code and populate the data accordingly
    */


    IF l_replenishment_method=1
    THEN
        FOR v_index IN 1 ..(l_forecast_horizon+1)
        LOOP
            INSERT INTO msc_vmi_graph(query_id,graph_date,projected_onhand,min,max)
            VALUES( v_index,(sysdate+v_index-1),t_table_pab(v_index), l_min_quantity,l_max_quantity);
	   -- dbms_output.put_line('the graph PABS are method type1  agoel  ' || t_table_pab(v_index));
        END LOOP;

    ELSIF l_replenishment_method=3
    THEN
        FOR v_index IN 1 ..(l_forecast_horizon+1)
        LOOP
            INSERT INTO msc_vmi_graph(query_id,graph_date,projected_onhand,min,max)
            VALUES(v_index,(sysdate+v_index-1), t_table_pab(v_index),l_min_quantity,l_fix_quantity);
	  --  dbms_output.put_line('the graph PABS are method type 3  agoel  ' || t_table_pab(v_index));
        END LOOP;
    ELSIF l_replenishment_method=2
    THEN
        FOR v_index IN 1 ..(l_forecast_horizon+1)
        LOOP
            INSERT INTO msc_vmi_graph(query_id,graph_date,projected_onhand,min,max)
            VALUES(v_index, (sysdate+v_index-1),t_table_pab_days(v_index),l_min_days,l_max_days);
	  --  dbms_output.put_line('the graph PABS are method type2  agoel  ' || t_table_pab_days(v_index));
        END LOOP;
    ELSIF l_replenishment_method=4
    THEN
        FOR v_index IN 1 ..(l_forecast_horizon+1)
        LOOP
            INSERT INTO msc_vmi_graph(query_id,graph_date,projected_onhand,min,max)
            VALUES(v_index,(sysdate+v_index-1), t_table_pab_days(v_index),l_min_days,l_fix_days);
	   -- dbms_output.put_line('the graph PABS are method type4  agoel  ' || t_table_pab_days(v_index));

        END LOOP;
    END IF;

    exception when others then

                l_debug_msg:= l_debug_msg ||' '|| 'req error';
                p_return_code:=-1;
                p_err_msg:= 'Invalid Data';
               --dbms_output.put_line('l_debug_msg:=' ||l_debug_msg ||sqlerrm);

  END;



 END VMISUPPLIERGRAPHONHAND;


FUNCTION AVG_DAILY_DEMAND ( p_inventory_item_id IN NUMBER,
     p_customer_id  IN NUMBER,
     p_customer_site_id  IN NUMBER,
     p_supplier_id  IN NUMBER,
     p_supplier_site_id IN NUMBER,
     p_plan_id   IN NUMBER,
     p_forecast_horizon  IN NUMBER
     )
RETURN t_table_add_data
As
  l_total_demands number;

 --TYPE t_table_add1_data IS TABLE OF NUMBER
    --  INDEX BY BINARY_INTEGER;
      t_table_add t_table_add_data ;


     CURSOR c_total_demands(forecast_horizon IN NUMBER, v_index IN NUMBER)
    IS
       SELECT nvl(sum(primary_quantity),0)
    FROM   msc_sup_dem_entries supdem
    WHERE publisher_order_type =2
    AND    supdem.inventory_item_id=p_inventory_item_id
    AND   supdem.customer_id=p_customer_id
       AND   supdem.customer_site_id=p_customer_site_id
       AND   supdem.supplier_id=p_supplier_id
       AND   supdem.supplier_site_id=p_supplier_site_id
       AND   supdem.plan_id=p_plan_id
       AND (trunc(key_date)>=trunc(sysdate +v_index-1) and trunc(key_date)<trunc(sysdate+p_forecast_horizon+v_index-1) );


 begin
    --dbms_output.put_line('the initial is as follows');


    FOR v_index IN 1..p_forecast_horizon+1
    LOOP


    OPEN c_total_demands(p_forecast_horizon,v_index);
     LOOP
     fetch c_total_demands into l_total_demands;
     IF  c_total_demands%FOUND THEN
         t_table_add(v_index):=l_total_demands/p_forecast_horizon;
     ELSE
         EXIT;
     END IF;
       END LOOP ;
    CLOSE c_total_demands;
    --dbms_output.put_line('the  is '||l_total_demands||'    '||t_table_add(v_index) );
    END LOOP;
    return t_table_add;

    EXCEPTION
    when others then
    return t_table_add;
-- dbms_output.put_line('the error message is'||SQLERRM);

     END AVG_DAILY_DEMAND;

/*-------------------------------------------------------+
| Get the intransit lead time for shipping the material  |
| from the shipping org to the customer location	 |
+--------------------------------------------------------*/

     FUNCTION  INTRANSIT_LEAD_TIME
     (p_source_org_id IN NUMBER,
     p_modeled_org_id IN NUMBER,
     p_customer_id  IN NUMBER,
     p_customer_site_id  IN NUMBER,
     p_supplier_id  IN NUMBER,
     p_sr_instance_id   IN NUMBER,
     p_consigned_flag  IN NUMBER)
     return NUMBER

     AS

     l_intransit_lead_time NUMBER ;
     l_source_site_id NUMBER;
     l_session_id     NUMBER;
     l_return_status  VARCHAR2(1);
     l_ship_method    varchar2(30);

    BEGIN

     l_intransit_lead_time := 0;

     if((p_consigned_flag = UNCONSIGNED) AND (p_source_org_id <> NOT_EXISTS)) then

		   BEGIN

		   select maps.company_key
		   into l_source_site_id
		   from msc_trading_partner_maps maps,
			msc_trading_partners tp
		   where tp.partner_type = 3
		   and tp.sr_instance_id = p_sr_instance_id
		   and tp.sr_tp_id = p_source_org_id
		   and tp.partner_id = maps.tp_key
		   and maps.map_type = 2;
		   exception when others then null;


		   END;

		   l_intransit_lead_time :=MSC_X_UTIL.GET_CUSTOMER_TRANSIT_TIME(
						p_supplier_id,
						l_source_site_id,
						p_customer_id,
						p_customer_site_id);

		 /*  dbms_output.put_line('  for unconsigned  source site ID/in transit lead time/consigned flag = '
			  || l_source_site_id
			  || '/' || l_intransit_lead_time|| '/' || p_consigned_flag
			  ); */



        elsif ((p_consigned_flag = CONSIGNED) AND (p_source_org_id <> NOT_EXISTS)) then

		   BEGIN
		       select mrp_atp_schedule_temp_s.nextval
			 into l_session_id
			 from dual;

			MSC_ATP_PROC.ATP_Intransit_LT(
				2,                       --- Destination
				l_session_id,            -- session_id
				p_source_org_id,         -- from source org
				null,                    -- from_loc_id
				null,                    -- from_vendor_site_id
				p_sr_instance_id,     -- p_from_instance_id
				p_modeled_org_id,    -- to modeled org
				null,                    -- p_to_loc_id
				null,                    -- p_to_customer_site_id
				p_sr_instance_id,     -- p_to_instance_id
				l_ship_method,           -- p_ship_method
				l_intransit_lead_time,   -- x_intransit_lead_time
				l_return_status          -- x_return_status
			);

			if (l_intransit_lead_time is null) then
			     l_intransit_lead_time := 0;
			end if;

			--dbms_output.put_line(' consigned in transit lead time = ' || l_intransit_lead_time);
			--dbms_output.put_line(' consignd source_org_id is  = ' || p_source_org_id||'  modeled org id'||p_modeled_org_id);
		   EXCEPTION
		       when others then
		-- dbms_output.put_line('Error in getting Lead Time: '||SQLERRM);
			null ;
		    END;


		end if;
		return l_intransit_lead_time;

    EXCEPTION
    when others then
    return l_intransit_lead_time;

    END;

   /* get avg dail usage from new table msc_vmi_temp reason collections full refresh*/



     FUNCTION  supplier_avg_daily_usage(
	  p_inventory_item_id   in number
	, p_organization_id      IN NUMBER
	, p_sr_instance_id      IN NUMBER
	, p_tp_supplier_id         in number default null
	, p_tp_supplier_site_id    in number default null
	) return number

    AS

    l_average_daily_usage number:=0;

    cursor vmi_temp_cur is
    SELECT using_organization_id,
        nvl(average_daily_demand,0.0) average_daily_usage
    FROM msc_vmi_temp
    WHERE plan_id = -1
    and   sr_instance_id = p_sr_instance_id
    and   organization_id = p_organization_id
    and   inventory_item_id = p_inventory_item_id
    and   supplier_id = p_tp_supplier_id
    and   supplier_site_id = p_tp_supplier_site_id
    and   vmi_type = 1
    order by using_organization_id desc;

    vmi_temp_rec    vmi_temp_cur%ROWTYPE;

    BEGIN

    open vmi_temp_cur;
      fetch vmi_temp_cur into vmi_temp_rec;
      if vmi_temp_cur%found then
        l_average_daily_usage := vmi_temp_rec.average_daily_usage;
      end if;
    close vmi_temp_cur;

    return l_average_daily_usage;

    EXCEPTION
    when others then
    l_average_daily_usage := 0.0;
    return l_average_daily_usage;

    END;


    FUNCTION  customer_avg_daily_usage(
	  p_inventory_item_id   in number
	, p_organization_id      IN NUMBER
	, p_sr_instance_id      IN NUMBER
	) return number

    AS

    l_average_daily_usage number:=0;

    cursor vmi_temp_cur is
    SELECT nvl(average_daily_demand,0.0) average_daily_usage
    FROM msc_vmi_temp
    WHERE plan_id = -1
    and   sr_instance_id = p_sr_instance_id
    and   organization_id = p_organization_id
    and   inventory_item_id = p_inventory_item_id
    and   vmi_type = 2;

    vmi_temp_rec    vmi_temp_cur%ROWTYPE;


    BEGIN

    open vmi_temp_cur;
      fetch vmi_temp_cur into vmi_temp_rec;
      if vmi_temp_cur%found then
        l_average_daily_usage := vmi_temp_rec.average_daily_usage ;
      end if;
    close vmi_temp_cur;

    return l_average_daily_usage;

    EXCEPTION
    when others then
    l_average_daily_usage := 0.0;
    return l_average_daily_usage;

    END;









END MSC_X_VMI_UTIL_NEW;

/
