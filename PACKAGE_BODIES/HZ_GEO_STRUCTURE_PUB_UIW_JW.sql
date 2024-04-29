--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCTURE_PUB_UIW_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCTURE_PUB_UIW_JW" as
  /* $Header: ARHGSTJB.pls 120.1 2005/08/26 15:22:37 dmmehta noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy hz_geo_structure_pub_uiw.incl_geo_type_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t hz_geo_structure_pub_uiw.incl_geo_type_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure create_geography_type(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
  )
  as
    ddp_geography_type_rec hz_geo_structure_pub_uiw.geography_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geography_type_rec.geography_type := p1_a0;
    ddp_geography_type_rec.geography_type_name := p1_a1;
    ddp_geography_type_rec.created_by_module := p1_a2;
    ddp_geography_type_rec.application_id := rosetta_g_miss_num_map(p1_a3);




    -- here's the delegated call to the old PL/SQL routine
    hz_geo_structure_pub_uiw.create_geography_type(p_init_msg_list,
      ddp_geography_type_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure create_geo_structure(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
  )
  as
    ddp_geo_structure_rec hz_geo_structure_pub_uiw.geo_structure_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_structure_rec.geography_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geo_structure_rec.geography_type := p1_a1;
    ddp_geo_structure_rec.parent_geography_type := p1_a2;
    ddp_geo_structure_rec.created_by_module := p1_a3;
    ddp_geo_structure_rec.application_id := rosetta_g_miss_num_map(p1_a4);




    -- here's the delegated call to the old PL/SQL routine
    hz_geo_structure_pub_uiw.create_geo_structure(p_init_msg_list,
      ddp_geo_structure_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure create_geo_rel_type(p_init_msg_list  VARCHAR2
    , x_relationship_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
  )
  as
    ddp_geo_rel_type_rec hz_geo_structure_pub_uiw.geo_rel_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_rel_type_rec.geography_type := p1_a0;
    ddp_geo_rel_type_rec.parent_geography_type := p1_a1;
    ddp_geo_rel_type_rec.status := p1_a2;
    ddp_geo_rel_type_rec.created_by_module := p1_a3;
    ddp_geo_rel_type_rec.application_id := rosetta_g_miss_num_map(p1_a4);





    -- here's the delegated call to the old PL/SQL routine
    hz_geo_structure_pub_uiw.create_geo_rel_type(p_init_msg_list,
      ddp_geo_rel_type_rec,
      x_relationship_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_zone_type(p_init_msg_list  VARCHAR2
    , p_included_geography_type JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := 'N'
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  )
  as
    ddp_zone_type_rec hz_geo_structure_pub_uiw.zone_type_rec_type;
    ddp_included_geography_type hz_geo_structure_pub_uiw.incl_geo_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_zone_type_rec.geography_type := p1_a0;
    ddp_zone_type_rec.geography_type_name := p1_a1;
    ddp_zone_type_rec.geography_use := p1_a2;
    ddp_zone_type_rec.limited_by_geography_id := rosetta_g_miss_num_map(p1_a3);
    ddp_zone_type_rec.postal_code_range_flag := p1_a4;
    ddp_zone_type_rec.created_by_module := p1_a5;
    ddp_zone_type_rec.application_id := rosetta_g_miss_num_map(p1_a6);

    hz_geo_structure_pub_uiw_jw.rosetta_table_copy_in_p0(ddp_included_geography_type, p_included_geography_type);




    -- here's the delegated call to the old PL/SQL routine
    hz_geo_structure_pub_uiw.create_zone_type(p_init_msg_list,
      ddp_zone_type_rec,
      ddp_included_geography_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_zone_type(p_init_msg_list  VARCHAR2
    , p_included_geography_type JTF_VARCHAR2_TABLE_100
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  )
  as
    ddp_zone_type_rec hz_geo_structure_pub_uiw.zone_type_rec_type;
    ddp_included_geography_type hz_geo_structure_pub_uiw.incl_geo_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_zone_type_rec.geography_type := p1_a0;
    ddp_zone_type_rec.geography_type_name := p1_a1;
    ddp_zone_type_rec.geography_use := p1_a2;
    ddp_zone_type_rec.limited_by_geography_id := rosetta_g_miss_num_map(p1_a3);
    ddp_zone_type_rec.postal_code_range_flag := p1_a4;
    ddp_zone_type_rec.created_by_module := p1_a5;
    ddp_zone_type_rec.application_id := rosetta_g_miss_num_map(p1_a6);

    hz_geo_structure_pub_uiw_jw.rosetta_table_copy_in_p0(ddp_included_geography_type, p_included_geography_type);





    -- here's the delegated call to the old PL/SQL routine
    hz_geo_structure_pub_uiw.update_zone_type(p_init_msg_list,
      ddp_zone_type_rec,
      ddp_included_geography_type,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end hz_geo_structure_pub_uiw_jw;

/
