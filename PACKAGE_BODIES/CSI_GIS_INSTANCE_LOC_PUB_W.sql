--------------------------------------------------------
--  DDL for Package Body CSI_GIS_INSTANCE_LOC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GIS_INSTANCE_LOC_PUB_W" as
  /* $Header: csiwgilb.pls 120.0.12010000.2 2008/11/13 11:28:51 somitra noship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy csi_gis_instance_loc_pub.csi_instance_geoloc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inst_latitude := a1(indx);
          t(ddindx).inst_longitude := a2(indx);
          t(ddindx).valid_flag := a3(indx);
          t(ddindx).geocode_format := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t csi_gis_instance_loc_pub.csi_instance_geoloc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).inst_latitude;
          a2(indx) := t(ddindx).inst_longitude;
          a3(indx) := t(ddindx).valid_flag;
          a4(indx) := t(ddindx).geocode_format;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure createupdate_inst_geoloc_info(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p_asset_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_csi_instance_geoloc_tbl csi_gis_instance_loc_pub.csi_instance_geoloc_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csi_gis_instance_loc_pub_w.rosetta_table_copy_in_p1(ddp_csi_instance_geoloc_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );





    -- here's the delegated call to the old PL/SQL routine
    csi_gis_instance_loc_pub.createupdate_inst_geoloc_info(p_api_version,
      p_commit,
      ddp_csi_instance_geoloc_tbl,
      p_asset_context,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end csi_gis_instance_loc_pub_w;

/
