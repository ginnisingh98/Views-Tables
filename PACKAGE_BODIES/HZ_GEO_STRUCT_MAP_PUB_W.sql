--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCT_MAP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCT_MAP_PUB_W" as
  /* $Header: ARHGNRJB.pls 120.3 2005/10/25 14:16:07 baianand noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).loc_seq_num := a0(indx);
          t(ddindx).loc_comp := a1(indx);
          t(ddindx).geo_type := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).loc_seq_num;
          a1(indx) := t(ddindx).loc_comp;
          a2(indx) := t(ddindx).geo_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_geo_struct_mapping(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_map_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_geo_struct_map_rec hz_geo_struct_map_pub.geo_struct_map_rec_type;
    ddp_geo_struct_map_dtl_tbl hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_geo_struct_map_rec.country_code := p0_a0;
    ddp_geo_struct_map_rec.loc_tbl_name := p0_a1;
    ddp_geo_struct_map_rec.address_style := p0_a2;

    hz_geo_struct_map_pub_w.rosetta_table_copy_in_p2(ddp_geo_struct_map_dtl_tbl, p1_a0
      , p1_a1
      , p1_a2
      );






    -- here's the delegated call to the old PL/SQL routine
    hz_geo_struct_map_pub.create_geo_struct_mapping(ddp_geo_struct_map_rec,
      ddp_geo_struct_map_dtl_tbl,
      p_init_msg_list,
      x_map_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure delete_geo_struct_mapping(p_map_id  NUMBER
    , p_location_table_name  VARCHAR2
    , p_country  VARCHAR2
    , p_address_style  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_geo_struct_map_dtl_tbl hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    hz_geo_struct_map_pub_w.rosetta_table_copy_in_p2(ddp_geo_struct_map_dtl_tbl, p4_a0
      , p4_a1
      , p4_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_geo_struct_map_pub.delete_geo_struct_mapping(p_map_id,
      p_location_table_name,
      p_country,
      p_address_style,
      ddp_geo_struct_map_dtl_tbl,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_geo_struct_map_dtls(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_geo_struct_map_dtl_tbl hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    hz_geo_struct_map_pub_w.rosetta_table_copy_in_p2(ddp_geo_struct_map_dtl_tbl, p1_a0
      , p1_a1
      , p1_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_geo_struct_map_pub.create_geo_struct_map_dtls(p_map_id,
      ddp_geo_struct_map_dtl_tbl,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_geo_struct_map_dtls(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_geo_struct_map_dtl_tbl hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    hz_geo_struct_map_pub_w.rosetta_table_copy_in_p2(ddp_geo_struct_map_dtl_tbl, p1_a0
      , p1_a1
      , p1_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_geo_struct_map_pub.update_geo_struct_map_dtls(p_map_id,
      ddp_geo_struct_map_dtl_tbl,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end hz_geo_struct_map_pub_w;

/
