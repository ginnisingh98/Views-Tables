--------------------------------------------------------
--  DDL for Package Body CSP_PART_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PART_SEARCH_PVT" as
/*$Header: cspvsrcb.pls 120.0.12010000.105 2013/08/20 09:57:05 vmandava noship $*/

  l_return_status varchar2(30) := FND_API.G_RET_STS_SUCCESS;
  l_msg_data varchar2(2000);
  l_msg_count number;

procedure log(p_procedure in varchar2,p_message in varchar2) as
begin
    dbms_output.put_line(p_procedure||' - '||p_message);
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'csp.plsql.csp_part_search_pvt.'||p_procedure,
                   p_message);
    end if;
end;

procedure search(p_required_parts IN required_parts_tbl,
                 p_search_params  IN search_params_rec,
                 x_return_status  OUT NOCOPY varchar2,
                 x_msg_data       OUT NOCOPY varchar2,
                 x_msg_count      OUT NOCOPY varchar2
)   AS
  l_organization_id number;
  l_subinventory_code varchar2(30);
  l_enough number := -1;
  l_open_or_closed varchar2(30) := 'OPEN';
  l_my_location    sdo_geometry;
  l_distance_uom varchar2(30) := 'unit=km';
  l_server_timezone_id number := fnd_profile.value('SERVER_TIMEZONE_ID');
  l_search_method varchar2(30):= nvl(p_search_params.search_method,
                                 fnd_profile.value('CSP_PART_SEARCH_METHOD'));
  l_called_from_charges varchar2(1) := 'N';

  procedure ship_set as

  cursor c_parts is
  select capt.organization_id,
         capt.subinventory_code,
         capt.required_item_id,
         sum(nvl(supplied_quantity,0)) supplied_quantity,
         crpt.quantity required_quantity
  from   csp_available_parts_temp capt,csp_required_parts_temp crpt
  where  crpt.inventory_item_id = capt.required_item_id
  and    item_type = 'BASE'
  group by capt.organization_id,
         capt.subinventory_code,
         capt.required_item_id,
         crpt.quantity;

  begin
    log('ship_set','Begin');
    if p_search_params.ship_set then
      for cr in c_parts loop
        log('ship_set',
            'cr.supplied_quantity:'||cr.supplied_quantity||
            'cr.required_quantity:'||cr.required_quantity);
        if cr.supplied_quantity < cr.required_quantity then
          log('ship_set','deleting');
          delete from csp_available_parts_temp
          where organization_id = cr.organization_id
          and   nvl(subinventory_code,'-1') = nvl(cr.subinventory_code,'-1');
          log('ship_set','Records deleted:'||sql%rowcount);
        end if;
      end loop;
    end if;
    log('ship_set','End');
  end;

  procedure print_capt_contents as
    cursor capt is
      SELECT organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        open_or_closed,
        geometry
      from csp_available_parts_temp;
    org_id csp_available_parts_temp.organization_id%type;
    sub_code csp_available_parts_temp.subinventory_code%type;
    src_typ_cd csp_available_parts_temp.source_type_code%type;
    req_item_id csp_available_parts_temp.required_item_id%type;
    req_item_rev csp_available_parts_temp.required_item_rev%type;
    req_qty csp_available_parts_temp.required_quantity%type;
    sup_item_id csp_available_parts_temp.supplied_item_id%type;
    sup_item_rev csp_available_parts_temp.supplied_item_rev%type;
    sup_qty csp_available_parts_temp.supplied_quantity%type;
    sup_item_typ csp_available_parts_temp.supplied_item_type%type;
    ship_dt csp_available_parts_temp.shipping_date%type;
    ship_meth csp_available_parts_temp.shipping_method%type;
    ship_cost csp_available_parts_temp.shipping_cost%type;
    arr_dt csp_available_parts_temp.arrival_date%type;
    dist csp_available_parts_temp.distance%type;
    op_or_c csp_available_parts_temp.open_or_closed%type;
    geo csp_available_parts_temp.geometry%type;
  begin
    /*
    open capt;
    fetch capt into org_id, sub_code, src_typ_cd, req_item_id, req_item_rev, req_qty, sup_item_id, sup_item_rev, sup_qty, sup_item_typ, ship_dt, ship_meth, ship_cost, arr_dt, dist, op_or_c, geo;
    close capt;

    log('print_capt_contents','organization_id: '||org_id);
    log('print_capt_contents','subinventory_code: '||sub_code);
    log('print_capt_contents','source_type_code: '||src_typ_cd);
    log('print_capt_contents','required_item_id: '||req_item_id);
    log('print_capt_contents','required_item_rev: '||req_item_rev);
    log('print_capt_contents','required_quantity: '||req_qty);
    log('print_capt_contents','supplied_item_id: '||sup_item_id);
    log('print_capt_contents','supplied_item_rev: '||sup_item_rev);
    log('print_capt_contents','supplied_quantity: '||sup_qty);
    log('print_capt_contents','supplied_item_type: '||sup_item_typ);
    log('print_capt_contents','shipping_date: '||ship_dt);
    log('print_capt_contents','shipping_method: '||ship_meth);
    log('print_capt_contents','shipping_cost: '||ship_cost);
    log('print_capt_contents','arrival_date: '||arr_dt);
    log('print_capt_contents','distance: '||dist);
    log('print_capt_contents','open_or_closed: '||op_or_c);
    --log('print_capt_contents','geometry: '||geo);
    */
    log('print_capt_contents', 'Printing existing rows in CAPT...');
    for capt_rec in capt loop
      log('print_capt_contents','organization_id: '||capt_rec.organization_id);
      log('print_capt_contents','subinventory_code: '||capt_rec.subinventory_code);
      log('print_capt_contents','source_type_code: '||capt_rec.source_type_code);
      log('print_capt_contents','required_item_id: '||capt_rec.required_item_id);
      log('print_capt_contents','required_item_rev: '||capt_rec.required_item_rev);
      log('print_capt_contents','required_quantity: '||capt_rec.required_quantity);
      log('print_capt_contents','supplied_item_id: '||capt_rec.supplied_item_id);
      log('print_capt_contents','supplied_item_rev: '||capt_rec.supplied_item_rev);
      log('print_capt_contents','supplied_quantity: '||capt_rec.supplied_quantity);
      log('print_capt_contents','supplied_item_type: '||capt_rec.supplied_item_type);
      log('print_capt_contents','shipping_date: '||capt_rec.shipping_date);
      log('print_capt_contents','shipping_method: '||capt_rec.shipping_method);
      log('print_capt_contents','shipping_cost: '||capt_rec.shipping_cost);
      log('print_capt_contents','arrival_date: '||capt_rec.arrival_date);
      log('print_capt_contents','distance: '||capt_rec.distance);
      log('print_capt_contents','open_or_closed: '||capt_rec.open_or_closed);
    end loop;
  end print_capt_contents;

  procedure clean_up as
  begin
    log('clean_up','Begin');
    delete from csp_available_parts_temp
    where nvl(supplied_quantity,-1) <= 0;
    log('clean_up','Records deleted:'||sql%rowcount);
    log('clean_up','End');
  end;

  procedure update_shipping_info as

  l_shipping_method   varchar2(60);
  l_shipping_cost     number;
  l_arrival_date      date;
  l_distance_uom_code varchar2(30);

  cursor c_sources is
  select distinct organization_id, subinventory_code,
      decode(l_distance_uom_code,'MILE',distance,'KM',distance/1.609344) distance
  from   csp_available_parts_temp
  where  source_type_code not in ('DEDICATED','MYSELF','UNMANNED','TECHNICIAN');

  cursor c_shipping_info(p_organization_id number,
                         p_subinventory_code varchar2) is
  select shipping_method,
         shipping_cost,
         arrival_date,
         decode(distance_uom,'MILE',distance,'KM',distance/1.609344) distance
  from   csp_shipping_details_v
  where  organization_id = p_organization_id
  and    nvl(subinventory_code,-1) = nvl(p_subinventory_code,-1)
  and    to_location_id = nvl(p_search_params.to_location_id,
                              p_search_params.to_hz_location_id)
  and    location_source = decode(p_search_params.to_location_id,null,'HZ','HR')
  order by shipping_cost,arrival_date;

  begin
    log('update_shipping_info','Begin');
    log('update_shipping_info','p_search_params.need_by_date:'||
         to_char(p_search_params.need_by_date,'ddmmyy hh24:MI'));
    if l_distance_uom = 'unit=km' then
      l_distance_uom_code := 'KM';
    elsif l_distance_uom = 'unit=mile' then
      l_distance_uom_code := 'MILE';
    end if;
    log('update_shipping_info','l_distance_uom_code:'||l_distance_uom_code);

    if p_search_params.need_by_date is null or  p_search_params.called_from = 'CHARGES' then --Return all shipping methods
      begin
      insert into csp_available_parts_temp(
             organization_id,
             subinventory_code,
             source_type_code,
             required_item_id,
             required_item_rev,
             required_quantity,
             supplied_item_id,
             supplied_item_rev,
             supplied_quantity,
             supplied_item_type,
             shipping_date,
             shipping_method,
             shipping_cost,
             arrival_date,
             distance,
             open_or_closed,
             geometry)
      select capt.organization_id,
             capt.subinventory_code,
             capt.source_type_code,
             capt.required_item_id,
             capt.required_item_rev,
             capt.required_quantity,
             capt.supplied_item_id,
             capt.supplied_item_rev,
             capt.supplied_quantity,
             capt.supplied_item_type,
             capt.shipping_date,
             csdv.shipping_method,
             csdv.shipping_cost,
             csdv.arrival_date,
             capt.distance,
             capt.open_or_closed,
             capt.geometry
      from   csp_shipping_details_v csdv,
             csp_available_parts_temp capt
      where  csdv.organization_id = capt.organization_id
      and    to_location_id = nvl(p_search_params.to_location_id,
                                  p_search_params.to_hz_location_id)
      and    location_source = decode(p_search_params.to_location_id,
                                      null,'HZ','HR')
      and    ( nvl(decode(l_distance_uom_code,'MILE',capt.distance,
                                            'KM',capt.distance/1.609344),0) <=
             nvl(decode(csdv.distance_uom,'MILE',csdv.distance,
                                          'KM',csdv.distance/1.609344),
               nvl(decode(l_distance_uom_code,'MILE',capt.distance,
                                            'KM',capt.distance/1.609344),0))
                or (capt.distance is null and csdv.distance is not null
              and nvl(p_search_params.called_from,'SEARCH') <> 'SCHEDULER'
              ) )
      and capt.source_type_code not in ('DEDICATED','MYSELF','UNMANNED','TECHNICIAN')
      and csdv.arrival_date <= nvl(p_search_params.need_by_date,
                                          csdv.arrival_date)
      order by csdv.shipping_cost,csdv.arrival_date;
      log('update_shipping_info','Records inserted:'||sql%rowcount);

      exception
      when others then
        log('unmanned_warehouses','when others exception');
        log('unmanned_warehouses','sqlcode:'||sqlcode);
        log('unmanned_warehouses','sqlerrm:'||sqlerrm);
      end;
    else
      for cr in c_sources loop
        log('update_shipping_info','looping c_sources');
        log('update_shipping_info','cr.organization_id:'||cr.organization_id);
        log('update_shipping_info','cr.subinventory_code:'||
             cr.subinventory_code);
        log('update_shipping_info','p_search_params.to_location_id:'||
             p_search_params.to_location_id);
        log('update_shipping_info','p_search_params.to_hz_location_id:'||
             p_search_params.to_hz_location_id);
        l_shipping_method := null;
        for csinfo in c_shipping_info(cr.organization_id,
                                      cr.subinventory_code) loop
          log('update_shipping_info','csinfo.distance:'||csinfo.distance);
          log('update_shipping_info','cr.distance:'||cr.distance);
          log('update_shipping_info','p_search_params.called_from:'||
               p_search_params.called_from);
          if csinfo.distance is null or
            cr.distance <= csinfo.distance or
            (cr.distance is null and
             csinfo.distance is not null and
             p_search_params.called_from <> 'SCHEDULER') then
            log('update_shipping_info','looping csinfo');
            l_shipping_method := 'N';
            log('update_shipping_info','l_shipping_method:'||l_shipping_method);
            log('update_shipping_info','csinfo.arrival_date:'||
                 csinfo.arrival_date);
            log('update_shipping_info','csinfo.shipping_cost:'||
                 csinfo.shipping_cost);

            if csinfo.arrival_date <= nvl(p_search_params.need_by_date,
                                          csinfo.arrival_date) then
              log('update_shipping_info','update csp_available_parts_temp');

              update csp_available_parts_temp
              set    shipping_method = csinfo.shipping_method,
                     shipping_cost = csinfo.shipping_cost,
                     arrival_date = csinfo.arrival_date
              where  organization_id = cr.organization_id
              and    nvl(subinventory_code,'-1') = nvl(cr.subinventory_code,'-1');
              log('update_shipping_info','Records updated:'||sql%rowcount);
              l_shipping_method := csinfo.shipping_method;
              log('update_shipping_info','l_shipping_method:'||l_shipping_method);
              exit;
            end if;
          end if;
        end loop;
        log('update_shipping_info','l_shipping_method:'||l_shipping_method);
        if l_shipping_method = 'N' then --No shipping method could meet need by
            log('update_shipping_info','delete from csp_available_parts_temp');
          delete from csp_available_parts_temp
          where  organization_id = cr.organization_id
          and    nvl(subinventory_code,'-1') = nvl(cr.subinventory_code,'-1');
          log('update_shipping_info','Records deleted:'||sql%rowcount);
        end if;
      end loop;
    end if;
    if l_search_method = 'SPARES' and
       l_called_from_charges <> 'Y' then
      log('update_shipping_info','search method SPARES deleting 1');
      delete from csp_available_parts_temp capt
      where  not exists (select 'x' from mtl_interorg_parameters mip
                         where  mip.from_organization_id = capt.organization_id
                         and    mip.to_organization_id = l_organization_id)
      and    capt.organization_id <> l_organization_id
      and    source_type_code not in ('DEDICATED','MYSELF');
      log('update_shipping_info','Records deleted:'||sql%rowcount);
      log('update_shipping_info','search method SPARES deleting 2');
    end if;
    delete from csp_available_parts_temp
    where  shipping_method is null
    and    source_type_code not in ('DEDICATED','MYSELF','UNMANNED','TECHNICIAN');
    log('update_shipping_info','Records deleted:'||sql%rowcount);
    log('update_shipping_info','End');
  end;

  procedure site_dedicated_spares as
  cursor  c_sites is
  select  cpp.organization_id,
          cpp.secondary_inventory,
          hl.geometry
  from    csp_planning_parameters cpp,
          csp_dedicated_sites cds,
          jtf_tasks_b jtb,
          csp_requirement_headers crh,
          hz_party_sites hps,
          hz_locations hl
  where   cds.planning_parameters_id = cpp.planning_parameters_id
  and     nvl(cpp.stocking_site_excl,'N') = 'N'
  and     cpp.stocking_site_type = 'DEDICATED'
  and     jtb.address_id = cds.party_site_id
  and     jtb.task_id = crh.task_id
  and     hps.party_site_id = jtb.address_id
  and     hl.location_id = hps.location_id
  and     crh.requirement_header_id = p_search_params.requirement_header_id;

  cursor c_enough is
  select sum(capt.supplied_quantity)-min(crpt.quantity)
  from csp_required_parts_temp crpt,
       csp_available_parts_temp capt
  where crpt.item_type = 'BASE'
  and   capt.source_type_code = 'DEDICATED'
  and   capt.required_item_id = crpt.inventory_item_id
  order by 1 asc;

  begin
    log('site_dedicated_spares','Begin');
    for csites in c_sites loop
      log('site_dedicated_spares','In c_sites loop');
      log('site_dedicated_spares','Inserting into csp_available_parts_temp');
      insert into csp_available_parts_temp(
        organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        geometry,
        open_or_closed)
      select
        csites.organization_id,
        csites.secondary_inventory,
        'DEDICATED',
        crpt.inventory_item_id,
        crpt.revision,
        crpt.quantity,
        crpt.alternate_item_id,
        null supplied_item_rev,
        csp_part_search_pvt.get_avail_qty(csites.organization_id,
                                          csites.secondary_inventory,
                                          crpt.alternate_item_id,
                                          crpt.revision,
                                          p_search_params.quantity_type),
        crpt.item_type,
        null shipping_date,
        null shipping_method,
        0 shipping_cost,
        sysdate arrival_date,
        0 distance,
        csites.geometry,
        'OPEN'
      from  csp_required_parts_temp crpt;
      log('site_dedicated_spares','Records inserted:'||sql%rowcount);
    end loop;
    open  c_enough;
    fetch c_enough into l_enough;
    log('site_dedicated_spares','l_enough_a:'||l_enough);
    close c_enough;
    l_enough := nvl(l_enough,-1);
    log('site_dedicated_spares','l_enough_b:'||l_enough);
  end;

  procedure my_inventory as
  begin
    log('my_inventory','begin');
    if p_search_params.my_inventory then
      log('my_inventory','insert into csp_available_parts');
      insert into csp_available_parts_temp(
        organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        geometry,
        open_or_closed)
      select
        l_organization_id,
        l_subinventory_code,
        'MYSELF',
        crpt.inventory_item_id,
        crpt.revision,
        crpt.quantity,
        crpt.alternate_item_id,
        null supplied_item_rev,
        csp_part_search_pvt.get_avail_qty(l_organization_id,
                                          l_subinventory_code,
                                          crpt.alternate_item_id,
                                          crpt.revision,
                                          p_search_params.quantity_type),
        crpt.item_type,
        null shipping_date,
        null shipping_method,
        0 shipping_cost,
        sysdate arrival_date,
        0 distance,
        l_my_location,
        'OPEN'
      from  csp_required_parts_temp crpt;
      log('my_inventory','inserted records:'||sql%rowcount);
    end if;
  end;

  procedure technicians as
  cursor c_geocode is
  select hl.geometry geometry,
         csf_gps_pub.get_location(
           null,csi.owner_resource_id,csi.owner_resource_type,sysdate) point,
         cpp.organization_id,
         cpp.secondary_inventory,
         csi.condition_type,
         csi.owner_resource_type,
         csi.owner_resource_id
  from   csp_sec_inventories csi,
         csp_planning_parameters cpp,
         hz_locations hl
  where  cpp.organization_id = csi.organization_id
  and   cpp.secondary_inventory = csi.secondary_inventory_name
  and   cpp.stocking_site_type = 'TECHNICIAN'
  and   hl.location_id(+) = cpp.hz_location_id
  and   (csi.organization_id <> l_organization_id
      or nvl(csi.secondary_inventory_name,'-1') <> l_subinventory_code)
  and   csi.condition_type = 'G'
  and exists
  (select 'x'
   from   mtl_onhand_quantities moq,
          csp_required_parts_temp crpt
   where  moq.organization_id = csi.organization_id
   and    moq.subinventory_code = csi.secondary_inventory_name
   and    moq.inventory_item_id = crpt.alternate_item_id);

  l_geometry   mdsys.sdo_geometry;
  l_point      mdsys.sdo_point_type := mdsys.sdo_point_type(-9999,-9999,0);
  l_test       number := 0;
  cursor c_compare(p_point mdsys.sdo_point_type) is
  select 1 from dual
  where  l_point <> nvl(p_point,l_point);

  begin
    log('technicians','begin');
    if p_search_params.technicians then
      for cr in c_geocode loop
        log('technicians','in c_geocode loop');
      -- Check to see if GPS returns valid point
        open  c_compare(cr.point);
        fetch c_compare into l_test;
        close c_compare;
        log('technicians','l_test:'||l_test);
        if l_test = 1 then
          l_geometry := MDSYS.SDO_GEOMETRY(2001,8307,cr.point,null,null);
        else
          l_geometry := cr.geometry;
        end if;
        l_test := 0;
        log('technicians','insert into CAPT');
        insert into csp_available_parts_temp(
          organization_id,
          subinventory_code,
          source_type_code,
          required_item_id,
          required_item_rev,
          required_quantity,
          supplied_item_id,
          supplied_item_rev,
          supplied_quantity,
          supplied_item_type,
          shipping_date,
          shipping_method,
          shipping_cost,
          arrival_date,
          distance,
          geometry,
          open_or_closed)
        select
          cr.organization_id,
          cr.secondary_inventory,
          'TECHNICIAN',
          crpt.inventory_item_id,
          crpt.revision,
          crpt.quantity,
          crpt.alternate_item_id,
          null supplied_item_rev,
          csp_part_search_pvt.get_avail_qty(cr.organization_id,
                                            cr.secondary_inventory,
                                            crpt.alternate_item_id,
                                            crpt.revision,
                                            p_search_params.quantity_type),
          crpt.item_type,
          null shipping_date,
          null shipping_method,
          0 shipping_cost,
          sysdate arrival_date,
          round(sdo_geom.sdo_distance(l_my_location,l_geometry,
                                1000,l_distance_uom),1) distance,
          l_geometry,
          case nvl(csoc.object_type,'CLOSED')
            when 'CLOSED' then 'CLOSED'
            else 'OPEN'
          end
        from
          csp_required_parts_temp crpt,
          cac_sr_object_capacity csoc,
          csp_sec_inventories csi
        where (cr.organization_id <> l_organization_id
            or nvl(cr.secondary_inventory,'-1') <> l_subinventory_code)
        and   csi.organization_id = cr.organization_id
        and   csi.secondary_inventory_name = cr.secondary_inventory
        and   cr.condition_type = 'G'
        and   decode(p_search_params.distance,null,-1,
              round(sdo_geom.sdo_distance(
                l_my_location,
                l_geometry,
                1000,
                l_distance_uom),1)) <= nvl(p_search_params.distance,-1)
        and   csoc.object_type(+) = csi.owner_resource_type
        and   csoc.object_id(+) = csi.owner_resource_id
        and   sysdate between csoc.start_date_time(+) and csoc.end_date_time(+)
        and   decode(csoc.object_type,null,'CLOSED','OPEN')
               in ('OPEN',l_open_or_closed);
        log('technicians','Records inserted:'||sql%rowcount);
      end loop;
    end if;
    log('technicians','end');
  end;

  procedure unmanned_warehouses as
  begin
    log('unmanned_warehouses','begin');
    if p_search_params.unmanned_warehouses then
      log('unmanned_warehouses','insert into CAPT');
      insert into csp_available_parts_temp(
        organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        geometry,
        open_or_closed)
      select
        cpp.organization_id,
        cpp.secondary_inventory,
        cpp.stocking_site_type,
        crpt.inventory_item_id,
        crpt.revision,
        crpt.quantity,
        crpt.alternate_item_id,
        null supplied_item_rev,
        csp_part_search_pvt.get_avail_qty(cpp.organization_id,
                                          cpp.secondary_inventory,
                                          crpt.alternate_item_id,
                                          crpt.revision,
                                          p_search_params.quantity_type),
        crpt.item_type,
        null shipping_date,
        null shipping_method,
        0 shipping_cost,
        sysdate arrival_date,
        round(sdo_geom.sdo_distance(l_my_location,hl.geometry,
                              1000,l_distance_uom),1) distance,
        hl.geometry,
        decode(sign(hz_timezone_pub.convert_datetime(
                                      l_server_timezone_id,
                                      cpp.timezone_id,
                                      sysdate)-nvl(cocv.start_time,sysdate-1))+
             sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                      l_server_timezone_id,
                                      cpp.timezone_id,
                                      sysdate)),2,'OPEN','CLOSED')
      from
        csp_required_parts_temp crpt,
        csp_planning_parameters cpp,
        csp_open_closed_v cocv,
        hz_locations hl
      where cpp.stocking_site_type = 'UNMANNED'
      and   nvl(cpp.stocking_site_excl,'N') = 'N'
      and   decode(p_search_params.distance,null,-1,
            round(sdo_geom.sdo_distance(
              l_my_location,
              hl.geometry,
              1000,
              l_distance_uom),1)) <= nvl(p_search_params.distance,-1)
      and   hl.location_id (+) = cpp.hz_location_id
      and   (cpp.organization_id <> l_organization_id
          or nvl(cpp.secondary_inventory,'-1') <> l_subinventory_code)
      and   cocv.calendar_id(+) = cpp.calendar_id
      and   decode(sign(hz_timezone_pub.convert_datetime(
                                       l_server_timezone_id,
                                       cpp.timezone_id,
                                       sysdate)-nvl(cocv.start_time,sysdate-1))+
             sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                       l_server_timezone_id,
                                       cpp.timezone_id,
                                       sysdate)),2,'OPEN','CLOSED')
             in ('OPEN',l_open_or_closed);
      log('unmanned_warehouses','Records inserted:'||sql%rowcount);
    end if;
    log('unmanned_warehouses','end');
    exception
    when others then
      log('unmanned_warehouses','when others exception');
      log('unmanned_warehouses','sqlcode:'||sqlcode);
      log('unmanned_warehouses','sqlerrm:'||sqlerrm);
  end;

  procedure manned_warehouses as
  cursor c_shipping is
  select distinct organization_id
  from   csp_shipping_details_v
  where  ((to_location_id = p_search_params.to_location_id
      and location_source = 'HR')
  or     (to_location_id = p_search_params.to_hz_location_id
      and location_source = 'HZ'));
  begin
    log('manned_warehouses','begin');
    if p_search_params.manned_warehouses then
      for cr in c_shipping loop
        log('manned_warehouses','insert into CAPT');
        insert into csp_available_parts_temp(
          organization_id,
          subinventory_code,
          source_type_code,
          required_item_id,
          required_item_rev,
          required_quantity,
          supplied_item_id,
          supplied_item_rev,
          supplied_quantity,
          supplied_item_type,
          shipping_date,
          shipping_method,
          shipping_cost,
          arrival_date,
          distance,
          geometry,
          open_or_closed)
        select
          cpp.organization_id,
          cpp.secondary_inventory,
          cpp.stocking_site_type,
          crpt.inventory_item_id,
          crpt.revision,
          crpt.quantity,
          crpt.alternate_item_id,
          null supplied_item_rev,
          csp_part_search_pvt.get_avail_qty(cpp.organization_id,
                                            cpp.secondary_inventory,
                                            crpt.alternate_item_id,
                                            crpt.revision,
                                            p_search_params.quantity_type),
          crpt.item_type,
          null shipping_date,
          null shipping_method,
          null shipping_cost,
          null arrival_date,
          round(sdo_geom.sdo_distance(l_my_location,hl.geometry,
                                      1000,l_distance_uom),1),
          hl.geometry,
          decode(sign(hz_timezone_pub.convert_datetime(
                                        l_server_timezone_id,
                                        cpp.timezone_id,
                                        sysdate)-nvl(cocv.start_time,sysdate-1))+
               sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                        l_server_timezone_id,
                                        cpp.timezone_id,
                                        sysdate)),2,'OPEN','CLOSED')
        from
          csp_required_parts_temp crpt,
          csp_planning_parameters cpp,
          csp_open_closed_v cocv,
          hz_locations hl
        where cpp.stocking_site_type = 'MANNED'
        and   cpp.organization_id = cr.organization_id
        and   nvl(cpp.stocking_site_excl,'N') = 'N'
        and   hl.location_id (+) = cpp.hz_location_id
        and   decode(p_search_params.distance,null,-1,
              round(sdo_geom.sdo_distance(
                l_my_location,
                hl.geometry,
                1000,
                l_distance_uom),1)) <= nvl(p_search_params.distance,-1)
        and   (cpp.organization_id <> nvl(l_organization_id, -999)
            or nvl(cpp.secondary_inventory,'-1') <> l_subinventory_code)
        and   cocv.calendar_id(+) = cpp.calendar_id
        and   exists (select 'x'
               from   mtl_onhand_quantities moq
               where  moq.organization_id = cpp.organization_id
               and    moq.subinventory_code = nvl(cpp.secondary_inventory,
                                                  moq.subinventory_code)
               and    moq.inventory_item_id = crpt.alternate_item_id)
        and   decode(sign(hz_timezone_pub.convert_datetime(
                                         l_server_timezone_id,
                                         cpp.timezone_id,
                                         sysdate)-nvl(cocv.start_time,sysdate-1))+
               sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                         l_server_timezone_id,
                                         cpp.timezone_id,
                                         sysdate)),2,'OPEN','CLOSED')
               in ('OPEN',l_open_or_closed);
        log('manned_warehouses','Inserted records:'||sql%rowcount);
      end loop;
    end if;
    log('manned_warehouses','end');
    exception
    when others then
      log('manned_warehouses','when others exception');
      log('manned_warehouses','sqlcode:'||sqlcode);
      log('manned_warehouses','sqlerrm:'||sqlerrm);
  end;

  procedure specific_warehouse as
  begin
    log('specific_warehouse','begin');
    insert into csp_available_parts_temp(
        organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        geometry,
        open_or_closed)
    select
        cpp.organization_id,
        cpp.secondary_inventory,
        cpp.stocking_site_type,
        crpt.inventory_item_id,
        crpt.revision,
        crpt.quantity,
        crpt.alternate_item_id,
        null supplied_item_rev,
        csp_part_search_pvt.get_avail_qty(cpp.organization_id,
                                          cpp.secondary_inventory,
                                          crpt.alternate_item_id,
                                          crpt.revision,
                                          p_search_params.quantity_type),
        crpt.item_type,
        null shipping_date,
        null shipping_method,
        null shipping_cost,
        null arrival_date,
        round(sdo_geom.sdo_distance(l_my_location,hl.geometry,
              1000,l_distance_uom),1),
        hl.geometry,
        decode(sign(hz_timezone_pub.convert_datetime(
                                      l_server_timezone_id,
                                      cpp.timezone_id,
                                      sysdate)-nvl(cocv.start_time,sysdate-1))+
             sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                      l_server_timezone_id,
                                      cpp.timezone_id,
                                      sysdate)),2,'OPEN','CLOSED')
      from
        csp_required_parts_temp crpt,
        csp_planning_parameters cpp,
        csp_open_closed_v cocv,
        hz_locations hl
      where cpp.organization_id = p_search_params.source_organization_id
      and   nvl(cpp.stocking_site_excl,'N') = 'N'
      and   hl.location_id (+) = cpp.hz_location_id
      and   decode(p_search_params.distance,null,-1,
            round(sdo_geom.sdo_distance(
              l_my_location,
              hl.geometry,
              1000,
              l_distance_uom),1)) <= nvl(p_search_params.distance,-1)
      and   nvl(cpp.secondary_inventory,'-1') =
            nvl(p_search_params.source_subinventory,'-1')
      and   cocv.calendar_id(+) = cpp.calendar_id
      and   decode(sign(hz_timezone_pub.convert_datetime(
                                       l_server_timezone_id,
                                       cpp.timezone_id,
                                       sysdate)-nvl(cocv.start_time,sysdate-1))+
             sign(nvl(cocv.end_time,sysdate+1)-hz_timezone_pub.convert_datetime(
                                       l_server_timezone_id,
                                       cpp.timezone_id,
                                       sysdate)),2,'OPEN','CLOSED')
             in ('OPEN',l_open_or_closed);
    log('specific_warehouse','Records inserted:'||sql%rowcount);
  end;

  procedure replenishment_source as
    l_repl_org  number;
    l_repl_sub  varchar2(30);
    cursor c_required_parts is
    select crpt.inventory_item_id,
           crpt.alternate_item_id,
           crpt.item_type item_type,
           crpt.revision,
           crpt.quantity
    from   csp_required_parts_temp crpt;

  begin
    log('replenishment_source','Begin');
    if p_search_params.manned_warehouses then
      for cr in c_required_parts loop
        log('replenishment_source','In c_required_parts loop');
        csp_parts_requirement.get_source_organization(
          cr.alternate_item_id,
          l_organization_id,
          l_subinventory_code,
          l_repl_org,
          l_repl_sub);
        log('replenishment_source','cr.alternate_item_id:'||
             cr.alternate_item_id);
        log('replenishment_source','l_organization_id:'||l_organization_id);
        log('replenishment_source','l_subinventory_code:'||l_subinventory_code);
        log('replenishment_source','l_repl_org:'||l_repl_org);
        log('replenishment_source','l_repl_sub:'||l_repl_sub);
        log('replenishment_source','inserting into CAPT');
        insert into csp_available_parts_temp(
          organization_id,
          subinventory_code,
          source_type_code,
          required_item_id,
          required_item_rev,
          required_quantity,
          supplied_item_id,
          supplied_item_rev,
          supplied_quantity,
          supplied_item_type,
          shipping_date,
          shipping_method,
          shipping_cost,
          arrival_date,
          distance,
          geometry,
          open_or_closed)
        select
          l_repl_org,
          l_repl_sub,
          'MANNED',
          cr.inventory_item_id,
          cr.revision,
          cr.quantity,
          cr.alternate_item_id,
          null supplied_item_rev,
          csp_part_search_pvt.get_avail_qty(l_repl_org,
                                            l_repl_sub,
                                            cr.alternate_item_id,
                                            cr.revision,
                                            p_search_params.quantity_type),
          cr.item_type,
          null shipping_date,
          null shipping_method,
          null shipping_cost,
          null arrival_date,
          null distance,
          null geometry,
          'OPEN'
        from dual;
        log('replenishment_source','Inserted records:'||sql%rowcount);
      end loop;
    end if;
    log('replenishment_source','End');
  end;

  procedure atp as
    cursor c_required_parts is
    select crl.requirement_line_id,
           crl.inventory_item_id,
           crl.revision,
           crl.uom_code,
           crl.required_quantity,
           crl.ship_complete_flag,
           crh.destination_organization_id,
           crh.destination_subinventory,
           crh.need_by_date,
           crh.timezone_id,
           crh.ship_to_location_id
    from   csp_requirement_lines crl,
           csp_requirement_headers crh
    where  crh.requirement_header_id = p_search_params.requirement_header_id
    and    crl.requirement_header_id = crh.requirement_header_id;

    l_resource_rec               csp_sch_int_pvt.csp_sch_resources_rec_typ;
    l_destination_organization_id number;
    l_timezone_id                 number;
    l_ship_to_location_id         number;
    l_destination_subinventory    varchar2(10);
    l_need_by_date                date;
    l_parts_list_rec              csp_sch_int_pvt.csp_parts_rec_type;
    l_parts_list_tbl              csp_sch_int_pvt.csp_parts_tbl_typ1;
    l_avail_list_tbl              csp_sch_int_pvt.available_parts_tbl_typ1;
    i                             number := 0;
  begin
    log('atp','Begin');
    for cr in c_required_parts loop
      log('atp','in c_required_parts loop');
      i := i + 1;
      l_parts_list_Rec.line_id := cr.requirement_line_id;
      l_parts_list_rec.item_id := cr.inventory_item_id;
      l_parts_list_rec.revision := cr.revision;
      l_parts_list_rec.item_uom := cr.uom_code;
      l_parts_list_rec.quantity := cr.required_quantity;
      l_parts_list_rec.ship_set_name := cr.ship_complete_flag;
      l_parts_list_tbl(i) := l_parts_list_rec;
      l_destination_organization_id := cr.destination_organization_id;
      l_destination_subinventory := cr.destination_subinventory;
      l_need_by_date := cr.need_by_date;
      l_timezone_id := cr.timezone_id;
      l_ship_to_location_id := cr.ship_to_location_id;
      log('atp','l_parts_list_rec.line_id:'||l_parts_list_rec.line_id);
      log('atp','l_parts_list_rec.item_id:'||l_parts_list_rec.item_id);
      log('atp','l_parts_list_rec.revision:'||l_parts_list_rec.revision);
      log('atp','l_parts_list_rec.item_uom:'||l_parts_list_rec.item_uom);
      log('atp','l_parts_list_rec.quantity:'||l_parts_list_rec.quantity);
      log('atp','l_parts_list_rec.ship_set_name:'||l_parts_list_rec.ship_set_name);
      log('atp','l_destination_organization_id:'||l_destination_organization_id);
      log('atp','l_destination_subinventory:'||l_destination_subinventory);
      log('atp','l_need_by_date:'||l_need_by_date);
      log('atp','l_timezone_id:'||l_timezone_id);
      log('atp','l_ship_to_location_id:'||l_ship_to_location_id);
    end loop;
    l_resource_rec.resource_id := p_search_params.resource_id;
    l_resource_rec.resource_type := p_search_params.resource_type;
    log('atp','calling csp_sch_int_pvt.check_parts_availability');
    csp_sch_int_pvt.check_parts_availability(
                p_resource              => l_resource_rec,
                p_organization_id       => l_destination_organization_id,
                p_subinv_code           => l_destination_subinventory,
                p_need_by_date          => l_need_by_date,
                p_parts_list            => l_parts_list_tbl,
                p_timezone_id           => l_timezone_id,
                x_availability          => l_avail_list_tbl,
                x_return_status         => l_return_status,
                x_msg_data              => l_msg_data,
                x_msg_count             => l_msg_count,
                p_location_id           => l_ship_to_location_id,
                p_include_alternates    => p_search_params.include_alternates
       );
    log('atp','after csp_sch_int_pvt.check_parts_availability');
    log('atp','x_return_status:'||x_return_status);
    for i in 1..l_avail_list_tbl.count loop
      log('atp','insert into CAPT');
      insert into csp_available_parts_temp(
        organization_id,
        subinventory_code,
        source_type_code,
        required_item_id,
        required_item_rev,
        required_quantity,
        supplied_item_id,
        supplied_item_rev,
        supplied_quantity,
        supplied_item_type,
        shipping_date,
        shipping_method,
        shipping_cost,
        arrival_date,
        distance,
        open_or_closed,
        geometry)
      select
        l_avail_list_tbl(i).source_org_id,
        l_avail_list_tbl(i).sub_inventory_code,
        'MANNED',
        l_avail_list_tbl(i).item_id,
        l_avail_list_tbl(i).revision,
        l_avail_list_tbl(i).ordered_quantity,  -- replaced required_quantity with ordered_quantity
        l_avail_list_tbl(i).item_id,
        l_avail_list_tbl(i).revision,
        l_avail_list_tbl(i).available_quantity,
        decode(l_avail_list_tbl(i).item_type, 2, 'SUBSTITUTE', 8, 'SUPERSEDED', 'BASE'),  -- used decode as item_type here is a number
        null,
        l_avail_list_tbl(i).shipping_methode,
        null,
        l_avail_list_tbl(i).arraival_date,
        null,
        'OPEN',
        null
      from dual;
      log('atp','Inserted records:'||sql%rowcount);
    end loop;
    log('atp','End');
  end;

    procedure get_my_location as

    l_to_hz_location_id number := null;
    l_result_array    csf_lf_pub.csf_lf_resultarray;

    cursor c_my_location is
    select hl.geometry
    from   hz_locations hl,
           csp_planning_parameters cpp
    where  cpp.organization_id = l_organization_id
    and    cpp.secondary_inventory = l_subinventory_code
    and    hl.location_id = cpp.hz_location_id;

    cursor c_to_location is
    select geometry
    from   hz_locations
    where  location_id = l_to_hz_location_id;

    cursor c_address is
    select hl.address1,hl.address2,hl.address3,hl.address4,
           hl.city,hl.postal_code,hl.state,ftt.territory_short_name,
           hl.province,hl.county
    from   hz_locations hl, fnd_territories_tl ftt
    where  hl.location_id = l_to_hz_location_id
    and    ftt.territory_code = hl.country
    and    ftt.language = 'US';

    cursor c_hz_address is
    select hps.location_id
    from   hz_cust_site_uses_all hcsua,
           po_location_associations_all plaa,
           hz_cust_acct_sites_all hcasa,
           hz_party_sites hps
    where  plaa.location_id = p_search_params.to_location_id
    and    hcsua.site_use_id = plaa.site_use_id
    and    hcsua.site_use_code = 'SHIP_TO'
    and    hcsua.status = 'A'
    and    hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
    and    hps.party_site_id = hcasa.party_site_id;

    l_array           hz_geocode_pkg.loc_array := hz_geocode_pkg.loc_array();
    l_rec             hz_location_v2pub.location_rec_type;
    l_http_ad         VARCHAR2(200);
    cpt               number;
    l_distance_uom_code varchar2(30);


  begin
    l_to_hz_location_id := p_search_params.to_hz_location_id;
    if l_to_hz_location_id is null then
      open  c_hz_address;
      fetch c_hz_address into l_to_hz_location_id;
      close c_hz_address;
    end if;
    log('get_my_location','Begin');
    log('get_my_location','l_return_status:'||l_return_status);
  -- Get center point
    if p_search_params.current_location then
      log('get_my_location','p_search_params.current_location = true');
      open  c_my_location;
      fetch c_my_location into l_my_location;
      close c_my_location;
    elsif nvl(l_to_hz_location_id,0) > 0 then
      log('get_my_location','l_to_hz_location_id:'||l_to_hz_location_id);
      open  c_to_location;
      fetch c_to_location into l_my_location;
      close c_to_location;
 -- Geocode address
      if l_my_location is null then
        log('get_my_location','l_my_location is null');
        cpt := 1;
        l_array.EXTEND;
        log('get_my_location','Fetch address');
        open  c_address;
        fetch c_address into l_array(cpt).address1,
                             l_array(cpt).address2,
                             l_array(cpt).address3,
                             l_array(cpt).address4,
                             l_array(cpt).city,
                             l_array(cpt).postal_code,
                             l_array(cpt).state,
                             l_array(cpt).country,
                             l_array(cpt).province,
                             l_array(cpt).county;
        close c_address;
        log('get_my_location','calling resolve_address');
        csf_resource_address_pvt.resolve_address (
          p_api_version => 1.0,
          p_init_msg_list => fnd_api.g_false,
          p_country       => nvl (l_array(cpt).country, '_'),
          p_state         => nvl (l_array(cpt).state,'_'),
          p_city          => nvl (l_array(cpt).city, '_'),
          p_county        => nvl (l_array(cpt).county,'_'),
          p_province      => nvl (l_array(cpt).province, '_' ),
          p_postalcode    => nvl (l_array(cpt).postal_code, '_' ),
          p_address1      => nvl (l_array(cpt).address1, '_' ),
          p_address2      => nvl (l_array(cpt).address2, '_' ),
          p_address3      => nvl (l_array(cpt).address3, '_' ),
          p_address4      => nvl (l_array(cpt).address4, '_' ),
          p_building_num  => '_',
          p_alternate     => '_',
          p_location_id   => nvl (l_to_hz_location_id, -1 ),
          p_country_code  => '_',
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data,
          x_geometry      => l_my_location );
/*
        if l_my_location is null then
          fnd_profile.get('HZ_GEOCODE_WEBSITE', l_http_ad);
          log('get_my_location','l_http_ad:'||l_http_ad);
          l_array(cpt).location_id := l_to_hz_location_id;
          log('get_my_location','calling hz_geocode_pkg.get_spatial_coords');
          hz_geocode_pkg.get_spatial_coords(
              p_loc_array            => l_array,
              p_name                 => null,
              p_http_ad              => l_http_ad,
              p_proxy                => null,
              p_port                 => null,
              p_retry                => 5,
              x_return_status        => l_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data);
          l_my_location := l_array(cpt).geometry;
        end if;
*/
      end if;
    end if;
    l_distance_uom_code := nvl(p_search_params.distance_uom,
                               fnd_profile.value('CSFW_DEFAULT_DISTANCE_UNIT'));
    log('get_my_location','l_distance_uom_code:'||l_distance_uom_code);
    if l_distance_uom_code = 'KM' then
      l_distance_uom := 'unit=km';
    elsif l_distance_uom_code = 'METER' then
      l_distance_uom := 'unit=m';
    elsif l_distance_uom_code = 'MILE' then
      l_distance_uom := 'unit=mile';
    end if;
    log('get_my_location','l_distance_uom:'||l_distance_uom);
    log('get_my_location','l_return_status:'||l_return_status);

    --ignore errors from geo-coding process
    l_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    log('get_my_location','End');
    exception
    when others then
      log('get_my_location','when others exception');
      log('get_my_location','sqlcode:'||sqlcode);
      log('get_my_location','sqlerrm:'||sqlerrm);
      l_return_status := fnd_api.g_ret_sts_success;
      FND_MSG_PUB.initialize;
  end;

  function get_organization_id return number as
    cursor c_organization_id is
    select organization_id, subinventory_code
    from   csp_inv_loc_assignments
    where  resource_type = p_search_params.resource_type
    and    resource_id   = p_search_params.resource_id
    and    default_code  = 'IN';
  begin
    log('get_organization_id','Begin');
    if p_search_params.resource_id is not null then
      log('get_organization_id',
          'p_search_params.resource_id:'||p_search_params.resource_id);
      open  c_organization_id;
      fetch c_organization_id into l_organization_id,l_subinventory_code;
      close c_organization_id;
      log('get_organization_id','l_organization_id:'||l_organization_id);
      log('get_organization_id','l_subinventory_code:'||l_subinventory_code);
    else
      log('get_organization_id','p_search_params.resource_id is null');
      l_organization_id := fnd_profile.value('CS_INV_VALIDATION_ORG');
      l_subinventory_code := fnd_api.g_miss_char;
      l_called_from_charges := 'Y';
    end if;
    log('get_organization_id','l_organization_id:'||l_organization_id);
    log('get_organization_id','End');
    return l_organization_id;
  end;

  procedure insert_parts as
    i number :=0;
    l_supersede_items csp_supersessions_pvt.number_arr;
    l_required_parts  required_parts_tbl;
    l_quantity        number := 0;
    l_total_quantity  number := 0;

    cursor c_requirement is
    select inventory_item_id,revision,required_quantity, requirement_line_id
    from   csp_requirement_lines crl
    where  requirement_header_id = p_search_params.requirement_header_id;

    cursor c_req_line_details(p_requirement_line_id number) is
    select source_type, source_id
    from   csp_req_line_details
    where  requirement_line_id = p_requirement_line_id;

    cursor c_reservations(p_reservation_id number) is
    select reservation_quantity
    from   mtl_reservations
    where  reservation_id = p_reservation_id;

    cursor c_move_orders(p_mo_line_id number) is
    select quantity
    from mtl_txn_request_lines
    where  line_id = p_mo_line_id;

    cursor c_internal_orders(p_io_line_id number) is
    select ordered_quantity
    from oe_order_lines_all
    where  line_id = p_io_line_id;

    cursor c_purchase_reqs(p_po_line_id number) is
    select quantity
    from   po_lines_all
    where  po_line_id = p_po_line_id;

    -- bug # 12554921
    cursor c_get_temp_items is
    select inventory_item_id, revision, quantity
    from csp_required_parts_temp;

    l_master_org_id number;
    l_insert_rec_c number;

    cursor c_get_master_org is
    select master_organization_id
    from mtl_parameters
    where organization_id = l_organization_id;

    cursor c_get_sup_items (v_inventory_item_id number, v_organization_id number, v_rel_type number) is
    SELECT related_item_id
    FROM mtl_related_items
    WHERE organization_id = v_organization_id
    AND TRUNC(sysdate) BETWEEN TRUNC(NVL(start_date,sysdate)) AND TRUNC(NVL(end_date,sysdate))
    AND relationship_type_id           = v_rel_type
      start with inventory_item_id     = v_inventory_item_id
      CONNECT BY nocycle prior related_item_id = inventory_item_id
    UNION
    SELECT inventory_item_id    AS related_item_id
    FROM mtl_related_items
    WHERE organization_id    = v_organization_id
    AND relationship_type_id = v_rel_type
    AND TRUNC(sysdate) BETWEEN TRUNC(NVL(start_date,sysdate)) AND TRUNC(NVL(end_date,sysdate))
      START WITH related_item_id         = v_inventory_item_id
    and reciprocal_flag                  = 'Y'
      CONNECT BY nocycle prior inventory_item_id||prior reciprocal_flag = related_item_id||reciprocal_flag;

  begin
    log('insert_parts','Begin');
    if p_search_params.requirement_header_id is not null then
      log('insert_parts',
          'p_search_params.requirement_header_id:'||
           p_search_params.requirement_header_id);
      for cr in c_requirement loop
        log('insert_parts','in c_requirement loop');
        for cord in c_req_line_details(cr.requirement_line_id) loop
          log('insert_parts','in c_req_line_details loop');
          log('insert_parts','cr.requirement_line_id:'||cr.requirement_line_id);
          if cord.source_type = 'RES' then
            open  c_reservations(cord.source_id);
            fetch c_reservations into l_quantity;
            close c_reservations;
            log('insert_parts','RES l_quantity:'||l_quantity);
            l_total_quantity := l_total_quantity + l_quantity;
            log('insert_parts','RES l_total_quantity:'||l_total_quantity);
          elsif cord.source_type = 'MO' then
            open  c_move_orders(cord.source_id);
            fetch c_move_orders into l_quantity;
            close c_move_orders;
            log('insert_parts','MO l_quantity:'||l_quantity);
            l_total_quantity := l_total_quantity + l_quantity;
            log('insert_parts','MO l_total_quantity:'||l_total_quantity);
          elsif cord.source_type = 'IO' then
            open  c_internal_orders(cord.source_id);
            fetch c_internal_orders into l_quantity;
            close c_internal_orders;
            log('insert_parts','IO l_quantity:'||l_quantity);
            l_total_quantity := l_total_quantity + l_quantity;
            log('insert_parts','IO l_total_quantity:'||l_total_quantity);
          elsif cord.source_type = 'POREQ' then
            open  c_purchase_reqs(cord.source_id);
            fetch c_purchase_reqs into l_quantity;
            close c_purchase_reqs;
            log('insert_parts','POREQ l_quantity:'||l_quantity);
            l_total_quantity := l_total_quantity + l_quantity;
            log('insert_parts','POREQ l_total_quantity:'||l_total_quantity);
          end if;
        end loop;

        log('insert_parts','cr.required_quantity:'||cr.required_quantity);
        if cr.required_quantity - l_total_quantity > 0 then
          i := i+1;
          l_required_parts(i).inventory_item_id := cr.inventory_item_id;
          l_required_parts(i).revision := cr.revision;
          l_required_parts(i).quantity := cr.required_quantity-l_total_quantity;
          log('insert_parts',
              'l_required_parts.inventory_item_id:'||
              l_required_parts(i).inventory_item_id);
          log('insert_parts',
              'l_required_parts.revision:'||l_required_parts(i).revision);
          log('insert_parts',
              'l_required_parts.quantity:'||l_required_parts(i).quantity);
        end if;
        l_quantity := 0;
        l_total_quantity := 0;
      end loop;
    else
      log('insert_parts','p_search_params.requirement_header_id is null');
      l_required_parts := p_required_parts;
    end if;
    for i in 1..l_required_parts.count loop
      log('insert_parts','In l_required_parts.count loop i:'||i);
      log('insert_parts','Insert into csp_required_parts_temp');
      insert into csp_required_parts_temp(inventory_item_id,
                                          revision,
                                          alternate_item_id,
                                          quantity,item_type)
      values (l_required_parts(i).inventory_item_id,
              l_required_parts(i).revision,
              l_required_parts(i).inventory_item_id,
              l_required_parts(i).quantity,
              'BASE');
      log('insert_parts','Inserted records:'||sql%rowcount);
    end loop;
-- Supersessions
    if p_search_params.include_alternates then
      log('insert_parts','insert supersessions into CRPT');
      open c_get_master_org;
      fetch c_get_master_org into l_master_org_id;
      close c_get_master_org;

      l_insert_rec_c := 0;
      for r_req_items in c_get_temp_items
      loop
        for r_rel_item in c_get_sup_items(r_req_items.inventory_item_id, l_master_org_id, 8)
        loop
            if r_rel_item.related_item_id <> r_req_items.inventory_item_id then
                insert into csp_required_parts_temp(inventory_item_id,
                                                  revision,
                                                  alternate_item_id,
                                                  quantity,
                                                  item_type)
                values (r_req_items.inventory_item_id,
                    r_req_items.revision,
                    r_rel_item.related_item_id,
                    r_req_items.quantity,
                    'SUPERSEDED');
                l_insert_rec_c := l_insert_rec_c + 1;
            end if;
        end loop;
      end loop;

      log('insert_parts','Inserted records:' || l_insert_rec_c);

-- Substitutes
      log('insert_parts','insert substitutes into CRPT');
      insert into csp_required_parts_temp(inventory_item_id,
                                          revision,
                                          alternate_item_id,
                                          quantity,item_type)
      select crpt.inventory_item_id,
             crpt.revision,
             mriv.related_item_id,
             crpt.quantity,
             'SUBSTITUTE'
      from mtl_related_items_view mriv,
           mtl_parameters mp,
           csp_required_parts_temp crpt
      where mp.organization_id = l_organization_id
      and   mriv.organization_id =  mp.master_organization_id
      and   mriv.inventory_item_id = crpt.inventory_item_id
      and   mriv.relationship_type_id = 2
      and   crpt.item_type = 'BASE'
      and   trunc(sysdate) between trunc(nvl(mriv.start_date,sysdate))
                               and trunc(nvl(mriv.end_date,sysdate))
      and   not exists(
        select 'x'
        from   csp_required_parts_temp
        where  alternate_item_id = mriv.related_item_id);

    log('insert_parts','Inserted records:'||sql%rowcount);

      /*
      -- not sure if this is a valid case for SUBSTITUTE

      l_insert_rec_c := 0;
      for r_req_items in c_get_temp_items
      loop
        for r_rel_item in c_get_sup_items(r_req_items.inventory_item_id, l_master_org_id, 2)
        loop
            if r_rel_item.related_item_id <> r_req_items.inventory_item_id then
                insert into csp_required_parts_temp(inventory_item_id,
                                                  revision,
                                                  alternate_item_id,
                                                  quantity,
                                                  item_type)
                values (r_req_items.inventory_item_id,
                    r_req_items.revision,
                    r_rel_item.related_item_id,
                    r_req_items.quantity,
                    'SUBSTITUTE');
                l_insert_rec_c := l_insert_rec_c + 1;
            end if;
        end loop;
      end loop;

      log('insert_parts','Inserted records:'||l_insert_rec_c);
      */
    end if;
    log('insert_parts','End');
  end;
  begin
    if p_search_params.resource_id is null then
      l_called_from_charges := 'Y';
      delete from csp_required_parts_temp;
      delete from csp_available_parts_temp;
    end if;
    log('main','Begin');
    log('main','p_search_params.search_method:'||p_search_params.search_method);
    log('main','p_search_params.quantity_type:'||p_search_params.quantity_type);
    log('main','p_search_params.need_by_date:'||
                to_char(p_search_params.need_by_date,'dd-mon-yyyy hh24:mi:ss'));
    log('main','p_search_params.resource_type:'||p_search_params.resource_type);
    log('main','p_search_params.resource_id:'||p_search_params.resource_id);
    log('main','p_search_params.distance:'||p_search_params.distance);
    log('main','p_search_params.distance_uom:'||p_search_params.distance_uom);
    log('main','p_search_params.source_organization_id:'||
                p_search_params.source_organization_id);
    log('main','p_search_params.source_subinventory:'||
                p_search_params.source_subinventory);
    log('main','p_search_params.to_location_id:'||
                p_search_params.to_location_id);
    log('main','p_search_params.to_hz_location_id:'||
                p_search_params.to_hz_location_id);
    log('main','p_search_params.requirement_header_id:'||
                p_search_params.requirement_header_id);
    if p_search_params.my_inventory then
      log('main','my_inventory=true');
    else log('main','my_inventory=false');
    end if;
    if p_search_params.technicians then
      log('main','technicians=true');
    else log('main','technicians=false'); end if;
    if p_search_params.manned_warehouses then
      log('main','manned_warehouses=true');
    else log('main','manned_warehouses=false'); end if;
    if p_search_params.unmanned_warehouses then
      log('main','unmanned_warehouses=true');
    else log('main','unmanned_warehouses=false'); end if;
    if p_search_params.include_alternates then
      log('main','include_alternates=true');
    else log('main','include_alternates=false'); end if;
    if p_search_params.include_closed then log('main','include_closed=true');
    else log('main','include_closed=false'); end if;
    if p_search_params.ship_set then log('main','ship_set=true');
    else log('main','ship_set=false'); end if;
    if p_search_params.current_location then
      log('main','current_location=true');
    else log('main','current_location=false'); end if;
    log('main','l_search_method:'||l_search_method);
    if l_search_method = 'INVENTORY' then
      l_organization_id := get_organization_id;
      log('main','l_organization_id:'||l_organization_id);
      log('main','calling insert_parts');
      insert_parts;
      --log('main','calling site_dedicated_spares');
      --site_dedicated_spares;
      log('main','l_enough:'||l_enough);
      if l_enough < 0 then
        log('main','calling my_inventory');
        my_inventory;
        log('main','calling replenishment_source');
        replenishment_source;
        --log('main','calling ship_set');
        --ship_set;
        --log('main','calling clean_up');
        --clean_up;
        --log('main','calling update_shipping_info');
        --update_shipping_info;
      else
        log('main','calling clean_up');
        clean_up;
      end if;
    elsif l_search_method = 'ATP' then
      l_organization_id := get_organization_id;
      log('main','l_organization_id:'||l_organization_id);
      log('main','calling insert_parts');
      insert_parts;
      log('main','calling site_dedicated_spares');
      site_dedicated_spares;
      log('main','l_enough:'||l_enough);
      if l_enough < 0 then
        log('main','calling my_inventory');
        my_inventory;
        print_capt_contents;
        log('main','calling atp');
        atp;
        print_capt_contents;
        log('main','calling ship_set');
        ship_set;
        print_capt_contents;
        log('main','calling clean_up');
        clean_up;
        print_capt_contents;
        log('main','calling update_shipping_info');
        update_shipping_info;
        print_capt_contents;
      else
        log('main','calling clean_up');
        clean_up;
      end if;
    else
      l_organization_id := get_organization_id;
      log('main','l_organization_id:'||l_organization_id);
      log('main','calling get_my_location');
      get_my_location;
      if p_search_params.include_closed then
        log('main','p_search_params.include_closed=true');
        l_open_or_closed := 'CLOSED';
        log('main','l_open_or_closed:'||l_open_or_closed);
      end if;
      log('main','calling insert_parts');
      insert_parts;

      log('main','p_search_params.source_organization_id'||
                  p_search_params.source_organization_id);
      if p_search_params.source_organization_id is not null then
        log('main','calling specific_warehouse');
        specific_warehouse;
      else
        log('main','calling site_dedicated_spares');
        site_dedicated_spares;
        log('main','l_enough:'||l_enough);
        if l_enough < 0 then
          log('main','calling my_inventory');
          my_inventory;
          log('main','calling technicians');
          technicians;
          log('main','calling unmanned_warehouses');
          unmanned_warehouses;
          log('main','calling manned_warehouses');
          manned_warehouses;
        end if;
      end if;
      log('main','l_enough:'||l_enough);
      if l_enough < 0 then
        log('main','calling ship_set');
        ship_set;
        log('main','calling clean_up');
        clean_up;
        log('main','calling update_shipping_info');
        update_shipping_info;
      else
        log('main','calling clean_up');
        clean_up;
      end if;
    end if;
    x_return_status := l_return_status;
    x_msg_data := l_msg_data;
    x_msg_count := l_msg_count;
    log('main','x_return_status:'||x_return_status);
    log('main','x_msg_data:'||x_msg_data);
    log('main','x_msg_count:'||x_msg_count);
    log('main','End');
  END search;

  function get_avail_qty (
             p_organization_id   number,
             p_subinventory_code varchar2,
             p_inventory_item_id number,
             p_revision          varchar2,
             p_quantity_type     varchar2)
  return number is
    l_api_version       constant number := 1.00;
    l_serial                     number;
    l_b_serial                   boolean;
    l_revision                   number;
    l_b_revision                 boolean;
    l_qoh                        number := 0;
    l_att                        number := 0;
    l_dummy                      number := 0;
    l_excess                     number := 0;
    d_att                        number := 0;
    v_att                        number := 0;
    d_qoh                        number := 0;
    v_qoh                        number := 0;
    l_r_qoh                        number := 0;
    l_r_att                      number := 0;

  cursor c_revisions is
  select revision
  from   mtl_item_revisions
  where  organization_id = p_organization_id
  and    inventory_item_id = p_inventory_item_id
  and    revision = nvl(p_revision,revision);

  cursor c_excess is
  select sum(nvl(excess_quantity,0) - nvl(returned_quantity,0))
  from   csp_excess_lists
  where  organization_id = p_organization_id
  and    nvl(subinventory_code,'-1') = nvl(p_subinventory_code,'-1')
  and    inventory_item_id = p_inventory_item_id;

  cursor c_item_attributes is
  select serial_number_control_code,
         revision_qty_control_code
  from   mtl_system_items
  where  organization_id   = p_organization_id
  and    inventory_item_id = p_inventory_item_id;

  cursor c_defective_sub is
  select secondary_inventory_name
  from   csp_sec_inventories
  where  organization_id = p_organization_id
  and    condition_type = 'B';

  -- bug 9724125
  l_TRANSACTIONS_ENABLED varchar2(1);

  BEGIN
    log('get_avail_qty','Begin');
    log('get_avail_qty','p_organization_id:'||p_organization_id);
    log('get_avail_qty','p_subinventory_code:'||p_subinventory_code);
    log('get_avail_qty','p_inventory_item_id:'||p_inventory_item_id);
    log('get_avail_qty','p_revision:'||p_revision);
    log('get_avail_qty','p_quantity_type:'||p_quantity_type);
        -- bug 9724125
        -- if the MTL_TRANSACTIONS_ENABLED_FLAG is not Y no need to search for qty
        l_TRANSACTIONS_ENABLED := 'N';                -- closed world assumption
        select nvl(MTL_TRANSACTIONS_ENABLED_FLAG, 'N')
        into l_TRANSACTIONS_ENABLED
        from mtl_system_items_b
        where inventory_item_id = p_inventory_item_id
        and organization_id = p_organization_id;
  log('get_avail_qty','l_transactions_enabled:'||l_transactions_enabled);
        if l_TRANSACTIONS_ENABLED = 'N' then
    log('get_avail_qty','return = 0');
                return 0;
        end if;

    if p_quantity_type = 'EXCESS' then
      open  c_excess;
      fetch c_excess into l_excess;
      close c_excess;
      log('get_avail_qty','return ='||l_excess);
      return l_excess;
    else
      open  c_item_attributes;
      fetch c_item_attributes into l_serial, l_revision;
      close c_item_attributes;
      log('get_avail_qty','l_serial:'||l_serial);
      log('get_avail_qty','l_revision:'||l_revision);

      if l_serial <> 1 then
        l_b_serial := TRUE;
      else
        l_b_serial := FALSE;
      end if;
      if l_revision <> 1 then
        l_b_revision := TRUE;
      else
        l_b_revision := FALSE;
      end if;
      log('get_avail_qty','calling inv_quantity_tree_pub.clear_quantity_cache');
      inv_quantity_tree_pub.clear_quantity_cache;
      log('get_avail_qty','calling inv_quantity_tree_pub.query_quantities');
      if not l_b_revision then
        inv_quantity_tree_pub.query_quantities(
          p_api_version_number       => l_api_version
        , p_init_msg_lst             => fnd_api.g_false
        , x_return_status            => l_return_status
        , x_msg_count                => l_msg_count
        , x_msg_data                 => l_msg_data
        , p_organization_id          => p_organization_id
        , p_inventory_item_id        => p_inventory_item_id
        , p_tree_mode                => inv_quantity_tree_pvt.g_reservation_mode
        , p_is_revision_control      => l_b_revision
        , p_is_lot_control           => false
        , p_is_serial_control        => l_b_serial
        , p_onhand_source            => inv_quantity_tree_pvt.g_all_subs
        , p_demand_source_type_id    => null
        , p_demand_source_header_id  => null
        , p_demand_source_line_id    => null
        , p_demand_source_name       => null
        , p_lot_expiration_date      => null
        , p_revision                    => p_revision
        , p_lot_number                  => null
        , p_subinventory_code           => p_subinventory_code
        , p_locator_id                  => null
        , x_qoh                         => l_qoh
        , x_rqoh                        => l_dummy
        , x_qr                          => l_dummy
        , x_qs                          => l_dummy
        , x_att                         => l_att
        , x_atr                         => l_dummy);
      else
        for crr in c_revisions loop
          log('get_avail_qty','crr.revision'||crr.revision);
          inv_quantity_tree_pub.query_quantities(
            p_api_version_number       => l_api_version
          , p_init_msg_lst             => fnd_api.g_false
          , x_return_status            => l_return_status
          , x_msg_count                => l_msg_count
          , x_msg_data                 => l_msg_data
          , p_organization_id          => p_organization_id
          , p_inventory_item_id        => p_inventory_item_id
          , p_tree_mode                => inv_quantity_tree_pvt.g_reservation_mode
          , p_is_revision_control      => l_b_revision
          , p_is_lot_control           => false
          , p_is_serial_control        => l_b_serial
          , p_onhand_source            => inv_quantity_tree_pvt.g_all_subs
          , p_demand_source_type_id    => null
          , p_demand_source_header_id  => null
          , p_demand_source_line_id    => null
          , p_demand_source_name       => null
          , p_lot_expiration_date      => null
          , p_revision                  => crr.revision
          , p_lot_number                => null
          , p_subinventory_code         => p_subinventory_code
          , p_locator_id                => null
          , x_qoh                       => l_r_qoh
          , x_rqoh                      => l_dummy
          , x_qr                        => l_dummy
          , x_qs                        => l_dummy
          , x_att                       => l_r_att
          , x_atr                       => l_dummy);
          l_qoh := l_qoh + l_r_qoh;
          l_att := l_att + l_r_att;
          log('get_avail_qty','l_r_qoh'||l_r_qoh);
          log('get_avail_qty','l_r_att'||l_r_att);
        end loop;
      end if;
      log('get_avail_qty','l_qoh'||l_qoh);
      log('get_avail_qty','l_att'||l_att);
-- Check for defective subinventories in inventory organization
-- we should check defective subinv only if l_att or l_qoh are positive
-- otherwise no need to deduct defective qty and we can avoid unnecessary queries
      if (p_subinventory_code is null)
            and ((nvl(p_quantity_type,'AVAILABLE') = 'AVAILABLE' and l_att > 0)
                or (nvl(p_quantity_type,'AVAILABLE') <> 'AVAILABLE' and l_qoh > 0)) then
        for cr in c_defective_sub loop
          log('get_avail_qty','in c_defective_sub loop');
          log('get_avail_qty','calling inv_quantity_tree_pub.query_quantities');
          inv_quantity_tree_pub.query_quantities(
            p_api_version_number       => l_api_version
          , p_init_msg_lst             => fnd_api.g_false
          , x_return_status            => l_return_status
          , x_msg_count                => l_msg_count
          , x_msg_data                 => l_msg_data
          , p_organization_id          => p_organization_id
          , p_inventory_item_id        => p_inventory_item_id
          , p_tree_mode              => inv_quantity_tree_pvt.g_reservation_mode
          , p_is_revision_control      => l_b_revision
          , p_is_lot_control           => false
          , p_is_serial_control        => l_b_serial
          , p_onhand_source            => inv_quantity_tree_pvt.g_all_subs
          , p_demand_source_type_id    => null
          , p_demand_source_header_id  => null
          , p_demand_source_line_id    => null
          , p_demand_source_name       => null
          , p_lot_expiration_date      => null
          , p_revision                     => p_revision
          , p_lot_number                   => null
          , p_subinventory_code            => cr.secondary_inventory_name
          , p_locator_id                   => null
          , x_qoh                          => d_qoh
          , x_rqoh                         => l_dummy
          , x_qr                           => l_dummy
          , x_qs                           => l_dummy
          , x_att                          => d_att
          , x_atr                          => l_dummy);
          log('get_avail_qty','d_qoh'||d_qoh);
          log('get_avail_qty','d_att'||d_att);
          -- this is avoid case where l_qoh is 10 but defective qty is -12 which
          -- will again give 10-(-12) = 22 wrong qty
          if d_att < 0 then
            d_att := 0;
          end if;
          if d_qoh < 0 then
            d_qoh := 0;
          end if;
          log('get_avail_qty','d_qoh'||d_qoh);
          log('get_avail_qty','d_att'||d_att);
          v_qoh := v_qoh + d_qoh;
          v_att := v_att + d_att;
          log('get_avail_qty','v_qoh'||v_qoh);
          log('get_avail_qty','v_att'||v_att);
        end loop;
      end if;

      if nvl(p_quantity_type,'AVAILABLE') = 'AVAILABLE' then
        log('get_avail_qty','return l_att - v_att'||l_att||'-'||v_att);
        return l_att - v_att;
      else
        log('get_avail_qty','return l_qoh - v_qoh'||l_qoh||'-'||v_qoh);
        return l_qoh - v_qoh;
      end if;
    end if;
  end get_avail_qty;

  function get_arrival_time(
             p_cutoff            date,
             p_cutoff_tz         number,
             p_lead_time         number,
             p_lead_time_uom     varchar2,
             p_intransit_time    number,
             p_delivery_time     date,
             p_safety_zone       number,
             p_location_id       number,
             p_location_source   varchar2,
             p_organization_id   number,
             p_subinventory_code varchar2)
    return date is
    cursor business_days is
      select trunc(sysdate+flvv.lookup_code) bd_arrival_date
      FROM jtf_cal_shift_constructs jcsc,
        jtf_cal_shifts_b jcsb,
        jtf_cal_shift_assign jcsa,
        jtf_calendars_b jcb,
        fnd_lookup_values_vl flvv,
        csp_planning_parameters cpp
      WHERE jcsa.calendar_id = jcb.calendar_id
      AND jcsb.shift_id      = jcsa.shift_id
      AND jcsc.shift_id      = jcsa.shift_id
      and flvv.lookup_type   = 'NUMBERS'
      AND to_number(flvv.lookup_code) BETWEEN 0 AND 15
      and trunc(sysdate+flvv.lookup_code)
          between trunc(nvl(jcb.start_date_active,sysdate+flvv.lookup_code))
          AND     TRUNC(NVL(jcb.end_date_active,sysdate+flvv.lookup_code))
      and trunc(sysdate+flvv.lookup_code)
          between trunc(nvl(jcsa.shift_start_date,sysdate+flvv.lookup_code))
          AND     TRUNC(NVL(jcsa.shift_end_date,sysdate+flvv.lookup_code))
      and trunc(sysdate+flvv.lookup_code)
          between trunc(nvl(jcsb.start_date_active,sysdate+flvv.lookup_code))
          AND     TRUNC(NVL(jcsb.end_date_active,sysdate+flvv.lookup_code))
      and trunc(sysdate+flvv.lookup_code)
          between trunc(nvl(jcsc.start_date_active,sysdate+flvv.lookup_code))
          AND     TRUNC(NVL(jcsc.end_date_active,sysdate+flvv.lookup_code))
      and jcsc.unit_of_time_value = to_char(sysdate+flvv.lookup_code,'D')
      and not exists
        (SELECT 'x'
        FROM jtf_cal_exception_assign jcea,
          jtf_cal_exceptions_b jceb
        where jcea.calendar_id = jcb.calendar_id
        and sysdate+flvv.lookup_code
            between trunc(jceb.start_date_time) and trunc(jceb.end_date_time+1)
        and sysdate+flvv.lookup_code
            BETWEEN trunc(jcea.start_date_active) AND trunc(jcea.end_date_active+1)
        and jcea.exception_id = jceb.exception_id
        )
    and jcb.calendar_id = cpp.calendar_id
    and cpp.organization_id = p_organization_id
    and nvl(cpp.secondary_inventory,-1) = nvl(p_subinventory_code,-1)
    group by trunc(sysdate+flvv.lookup_code)
    order by trunc(sysdate+flvv.lookup_code);

    i number := 0;
    l_arrival_date date := sysdate;
    l_cutoff date;
    l_delivery_time date;
    p_hr_uom varchar2(60) := FND_PROFILE.VALUE('CSF_UOM_HOURS');
    p_client_timezone_id number := FND_PROFILE.VALUE('CLIENT_TIMEZONE_ID');
    p_server_timezone_id number := FND_PROFILE.VALUE('SERVER_TIMEZONE_ID');
  begin
    log('get_arrival_time',
        'p_cutoff:'||to_char(p_cutoff,'dd-mon-yyyy hh24:mi'));
    log('get_arrival_time','p_cutoff_tz:'||p_cutoff_tz);
    log('get_arrival_time','p_lead_time:'||p_lead_time);
    log('get_arrival_time','p_lead_time_uom:'||p_lead_time_uom);
    log('get_arrival_time','p_intransit_time:'||p_intransit_time);
    log('get_arrival_time',
        'p_delivery_time:'||to_char(p_delivery_time,'dd-mon-yyyy hh24:mi'));
    log('get_arrival_time','p_safety_zone:'||p_safety_zone);
    log('get_arrival_time',
        'l_arrival_date:'||to_char(l_arrival_date,'dd-mon-yyyy hh24:mi'));

    if p_cutoff is not null then
      l_cutoff := hz_timezone_pub.convert_datetime( p_cutoff_tz,
                                                    p_server_timezone_id,
                                                    p_cutoff);
      if (sysdate-trunc(sysdate)) > (l_cutoff-trunc(l_cutoff)) then
        l_arrival_date := sysdate+1;
      end if;
    end if;
    if p_lead_time is not null then
      log('get_arrival_time','in p_lead_time');
      l_arrival_date := l_arrival_date +
                        inv_convert.inv_um_convert(NULL,6,p_lead_time,
                             p_lead_time_uom,p_hr_uom,NULL,NULL)*1/24;
      log('get_arrival_time',
          'l_arrival_date:'||to_char(l_arrival_date,'dd-mon-yyyy hh24:mi'));
    elsif p_intransit_time is not null then
      l_arrival_date := l_arrival_date + p_intransit_time;
    end if;
    if p_delivery_time is not null then
      log('get_arrival_time','in p_delivery_time');
      l_delivery_time := p_delivery_time;
      log('get_arrival_time',
     'l_delivery_time before:'||to_char(l_delivery_time,'dd-mon-yyyy hh24:mi'));
      log('get_arrival_time','p_location_id:'||p_location_id||
                             'p_location_source:'||p_location_source);
      l_delivery_time := hz_timezone_pub.convert_datetime(
                           nvl(get_ship_to_tz(p_location_id,p_location_source),
                               p_client_timezone_id),
                           p_server_timezone_id,
                           p_delivery_time);
      log('get_arrival_time',
      'l_delivery_time after:'||to_char(l_delivery_time,'dd-mon-yyyy hh24:mi'));
      log('get_arrival_time',
       'trunc delivery time:'||to_char(l_delivery_time-trunc(l_delivery_time)));
      l_arrival_date := trunc(l_arrival_date) +
                        (l_delivery_time-trunc(l_delivery_time));
      log('get_arrival_time',
          'l_arrival_date:'||to_char(l_arrival_date,'dd-mon-yyyy hh24:mi'));
      log('get_arrival_time',
          'sysdate:'||to_char(sysdate,'dd-mon-yyyy hh24:mi'));
      if l_arrival_date < sysdate then
        log('get_arrival_time','l_arrival_date < sysdate');
        l_arrival_date := l_arrival_date + 1;
      end if;
      log('get_arrival_time',
          'l_arrival_date:'||to_char(l_arrival_date,'dd-mon-yyyy hh24:mi'));
    end if;
    l_arrival_date := l_arrival_date + nvl(p_safety_zone/24,0);
    log('get_arrival_time',
        'l_arrival_date:'||to_char(l_arrival_date,'dd-mon-yyyy hh24:mi'));

    i:= 0;
    for cr in business_days loop
      if i = trunc(l_arrival_date) - trunc(sysdate) then
        l_arrival_date := l_arrival_date + (trunc(cr.bd_arrival_date)
                                         - trunc(l_arrival_date));
                                                   exit;
      end if;
      i := i + 1;
    end loop;

    return l_arrival_date;
  end get_arrival_time;

  function get_ship_to_tz(
             p_location_id       number   default null,
             p_location_source   varchar2 default null)
  return number is
  l_ship_to_tz  number;
  l_postal_code varchar2(150);
  l_city        varchar2(150);
  l_state       varchar2(150);
  l_country     varchar2(150);

  cursor c_ship_to is
  select postal_code,city,decode(COUNTRY, 'CA', nvl(PROVINCE, STATE), STATE),country,nvl(timezone_id, -9999)
  from   hz_locations
  where  location_id = p_location_id
  and    p_location_source = 'HZ'
  union all
  select postal_code,town_or_city,upper(region_1),country,-9999
  from   hr_locations
  where  location_id = p_location_id
  and    p_location_source = 'HR';

  cursor c_get_hz_loc is
  SELECT hl.postal_code,
    hl.city,
    decode(hl.COUNTRY, 'CA', nvl(hl.PROVINCE, hl.STATE), hl.STATE),
    hl.country,
    hl.location_id,
    nvl(hl.timezone_id, -9999)
  FROM hz_locations hl,
    hz_party_sites hps,
    HZ_CUST_ACCT_SITES_ALL hcas,
    PO_LOCATION_ASSOCIATIONS_ALL pol
  WHERE hl.location_id   = hps.location_id
  AND hcas.party_site_id = hps.party_site_id
  AND pol.org_id         = hcas.org_id
  AND pol.address_id     = hcas.cust_acct_site_id
  AND pol.location_id    = p_location_id
  AND rownum             = 1;
  l_hz_location_id number;

  begin

  log('get_ship_to_tz', 'p_location_id:'||p_location_id);
  log('get_ship_to_tz', 'p_location_source:'||p_location_source);

    l_hz_location_id := -9999;
    l_ship_to_tz := -9999;

    if p_location_source = 'HR' then
      -- try to get information from hz_location
      open c_get_hz_loc;
      fetch c_get_hz_loc into l_postal_code, l_city, l_state, l_country, l_hz_location_id, l_ship_to_tz;
      close c_get_hz_loc;

    end if;

    if l_hz_location_id = -9999 then
      open  c_ship_to;
      fetch c_ship_to into l_postal_code,l_city,l_state,l_country,l_ship_to_tz;
      close c_ship_to;
    end if;

    log('get_ship_to_tz', 'l_ship_to_tz:' || l_ship_to_tz);

    if l_ship_to_tz = -9999 or l_ship_to_tz = fnd_api.g_miss_num then
      hz_timezone_pub.get_timezone_id (
        p_api_version   => 1.0,
        p_init_msg_list => fnd_api.g_false,
        p_postal_code   => l_postal_code,
        p_city          => l_city,
        p_state         => l_state,
        p_country       => l_country,
        x_timezone_id   => l_ship_to_tz,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data);
    end if;

    log('get_ship_to_tz', 'l_ship_to_tz:' || l_ship_to_tz);

    return l_ship_to_tz;
  end;

  function get_src_distance (
        p_req_header_id number,
        p_src_org_id number,
        p_src_subinv varchar2
      )
      return varchar2 is
    l_src_geo sdo_geometry;
    l_dest_geo sdo_geometry;
    l_distance_uom_code varchar2(10);
    l_distance_uom varchar2(100);
    l_distance varchar2(100) := '-';
    l_distance_uom_meaning varchar2(100);
  begin
    log('get_src_distance', 'p_req_header_id=' || p_req_header_id);
    log('get_src_distance', 'p_src_org_id=' || p_src_org_id);
    log('get_src_distance', 'p_src_subinv=' || p_src_subinv);

    -- first find out source geocode
    SELECT GEOMETRY
    INTO l_src_geo
    FROM HZ_LOCATIONS
    WHERE location_id =
      ( SELECT DISTINCT hz_location_id
      FROM csp_planning_parameters
      WHERE organization_id                = p_src_org_id
      AND NVL(SECONDARY_INVENTORY, 'NULL') = NVL(p_src_subinv, 'NULL')
      );

    -- now get destination ship_to address's geocode
    SELECT hloc.GEOMETRY
    INTO l_dest_geo
    FROM hz_locations hloc,
      hz_party_sites hps
    WHERE hloc.location_id = hps.location_id
    AND hps.party_site_id  =
      ( SELECT DISTINCT party_site_id
      FROM po_location_associations_all ploc,
        hz_cust_acct_sites_all hcsa,
        csp_requirement_headers crh
      WHERE crh.requirement_header_id = p_req_header_id
      AND ploc.location_id            = crh.ship_to_location_id
      --AND ploc.customer_id            = hcsa.cust_account_id
      AND ploc.address_id             = hcsa.cust_acct_site_id
      AND ploc.org_id                 = hcsa.org_id
      );

    l_distance_uom_code := fnd_profile.value('CSFW_DEFAULT_DISTANCE_UNIT');
    log('get_src_distance','l_distance_uom_code:'||l_distance_uom_code);

    if l_distance_uom_code = 'KM' then
      l_distance_uom := 'unit=km';
    elsif l_distance_uom_code = 'METER' then
      l_distance_uom := 'unit=m';
    elsif l_distance_uom_code = 'MILE' then
      l_distance_uom := 'unit=mile';
    end if;
    log('get_src_distance','l_distance_uom:'||l_distance_uom);

    SELECT ROUND(sdo_geom.sdo_distance(l_src_geo, l_dest_geo, 1000, l_distance_uom),1)
    INTO l_distance
    FROM dual;
    log('get_src_distance','l_distance:'||l_distance);

    if l_distance <> '-' then
      SELECT meaning
      INTO l_distance_uom_meaning
      FROM fnd_lookups
      WHERE lookup_type='CSFW_DISTANCE_UNIT'
      AND lookup_code  = l_distance_uom_code;
      log('get_src_distance','l_distance_uom_meaning:'||l_distance_uom_meaning);

      return l_distance || ' ' || l_distance_uom_meaning;
    else
      return l_distance;
    end if;

  end;

        function get_cutoff_time(
                p_cutoff        date,
                p_cutoff_tz     number
        ) return date is
                l_cutoff date;
                l_cutoff_date date := sysdate;
                p_server_timezone_id number := FND_PROFILE.VALUE('SERVER_TIMEZONE_ID');
        begin
                if p_cutoff is null or p_cutoff_tz is null then
                        return null;
                end if;

                log('get_cutoff_time', 'p_cutoff=' || to_char(p_cutoff, 'DD-MON-YYYY HH24:MI:SS'));
                log('get_cutoff_time','p_cutoff_tz=' || p_cutoff_tz);
                log('get_cutoff_time','p_server_timezone_id=' || p_server_timezone_id);

                l_cutoff := hz_timezone_pub.convert_datetime( p_cutoff_tz,
                                                                                                        p_server_timezone_id,
                                                                                                        p_cutoff);

                if (sysdate-trunc(sysdate)) > (l_cutoff-trunc(l_cutoff)) then
                        l_cutoff_date := sysdate+1;
                end if;

                l_cutoff_date := trunc(l_cutoff_date) +
                                                (l_cutoff - trunc(l_cutoff));
                return l_cutoff_date;
        end;
end;

/
