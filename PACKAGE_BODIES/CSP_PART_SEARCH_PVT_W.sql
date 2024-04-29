--------------------------------------------------------
--  DDL for Package Body CSP_PART_SEARCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PART_SEARCH_PVT_W" as
  /* $Header: cspvsrcwb.pls 120.0.12010000.3 2013/08/20 09:52:04 vmandava noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy csp_part_search_pvt.required_parts_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).revision := a1(indx);
          t(ddindx).quantity := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t csp_part_search_pvt.required_parts_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure search(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p1_a0  VARCHAR2
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  VARCHAR2
  )

  as
    ddp_required_parts csp_part_search_pvt.required_parts_tbl;
    ddp_search_params csp_part_search_pvt.search_params_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csp_part_search_pvt_w.rosetta_table_copy_in_p2(ddp_required_parts, p0_a0
      , p0_a1
      , p0_a2
      );

    ddp_search_params.search_method := p1_a0;
    if p1_a1 is null
      then ddp_search_params.my_inventory := null;
    elsif p1_a1 = 0
      then ddp_search_params.my_inventory := false;
    else ddp_search_params.my_inventory := true;
    end if;
    if p1_a2 is null
      then ddp_search_params.technicians := null;
    elsif p1_a2 = 0
      then ddp_search_params.technicians := false;
    else ddp_search_params.technicians := true;
    end if;
    if p1_a3 is null
      then ddp_search_params.manned_warehouses := null;
    elsif p1_a3 = 0
      then ddp_search_params.manned_warehouses := false;
    else ddp_search_params.manned_warehouses := true;
    end if;
    if p1_a4 is null
      then ddp_search_params.unmanned_warehouses := null;
    elsif p1_a4 = 0
      then ddp_search_params.unmanned_warehouses := false;
    else ddp_search_params.unmanned_warehouses := true;
    end if;
    if p1_a5 is null
      then ddp_search_params.include_alternates := null;
    elsif p1_a5 = 0
      then ddp_search_params.include_alternates := false;
    else ddp_search_params.include_alternates := true;
    end if;
    if p1_a6 is null
      then ddp_search_params.include_closed := null;
    elsif p1_a6 = 0
      then ddp_search_params.include_closed := false;
    else ddp_search_params.include_closed := true;
    end if;
    ddp_search_params.quantity_type := p1_a7;
    if p1_a8 is null
      then ddp_search_params.ship_set := null;
    elsif p1_a8 = 0
      then ddp_search_params.ship_set := false;
    else ddp_search_params.ship_set := true;
    end if;
    ddp_search_params.need_by_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_search_params.resource_type := p1_a10;
    ddp_search_params.resource_id := p1_a11;
    ddp_search_params.distance := p1_a12;
    ddp_search_params.distance_uom := p1_a13;
    ddp_search_params.source_organization_id := p1_a14;
    ddp_search_params.source_subinventory := p1_a15;
    ddp_search_params.to_location_id := p1_a16;
    ddp_search_params.to_hz_location_id := p1_a17;
    if p1_a18 is null
      then ddp_search_params.current_location := null;
    elsif p1_a18 = 0
      then ddp_search_params.current_location := false;
    else ddp_search_params.current_location := true;
    end if;
    ddp_search_params.requirement_header_id := p1_a19;
    ddp_search_params.called_from := p1_a20;




    -- here's the delegated call to the old PL/SQL routine
    csp_part_search_pvt.search(ddp_required_parts,
      ddp_search_params,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  function get_arrival_time(p_cutoff  date
    , p_cutoff_tz  NUMBER
    , p_lead_time  NUMBER
    , p_lead_time_uom  VARCHAR2
    , p_intransit_time  NUMBER
    , p_delivery_time  date
    , p_safety_zone  NUMBER
    , p_location_id  NUMBER
    , p_location_source  VARCHAR2
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
  ) return date

  as
    ddp_cutoff date;
    ddp_delivery_time date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cutoff := rosetta_g_miss_date_in_map(p_cutoff);





    ddp_delivery_time := rosetta_g_miss_date_in_map(p_delivery_time);






    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csp_part_search_pvt.get_arrival_time(ddp_cutoff,
      p_cutoff_tz,
      p_lead_time,
      p_lead_time_uom,
      p_intransit_time,
      ddp_delivery_time,
      p_safety_zone,
      p_location_id,
      p_location_source,
      p_organization_id,
      p_subinventory_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    return ddrosetta_retval;
  end;

  function get_cutoff_time(p_cutoff  date
    , p_cutoff_tz  NUMBER
  ) return date

  as
    ddp_cutoff date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cutoff := rosetta_g_miss_date_in_map(p_cutoff);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csp_part_search_pvt.get_cutoff_time(ddp_cutoff,
      p_cutoff_tz);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

end csp_part_search_pvt_w;

/
