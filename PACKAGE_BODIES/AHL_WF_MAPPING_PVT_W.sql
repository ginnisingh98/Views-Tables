--------------------------------------------------------
--  DDL for Package Body AHL_WF_MAPPING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WF_MAPPING_PVT_W" as
  /* $Header: AHLWWFMB.pls 120.1 2006/05/02 07:23 sathapli noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_wf_mapping_pvt.wf_mapping_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wf_mapping_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).active_flag := a7(indx);
          t(ddindx).wf_process_name := a8(indx);
          t(ddindx).wf_display_name := a9(indx);
          t(ddindx).approval_object := a10(indx);
          t(ddindx).item_type := a11(indx);
          t(ddindx).application_usg_code := a12(indx);
          t(ddindx).application_usg := a13(indx);
          t(ddindx).operation_flag := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_wf_mapping_pvt.wf_mapping_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wf_mapping_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := t(ddindx).created_by;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).active_flag;
          a8(indx) := t(ddindx).wf_process_name;
          a9(indx) := t(ddindx).wf_display_name;
          a10(indx) := t(ddindx).approval_object;
          a11(indx) := t(ddindx).item_type;
          a12(indx) := t(ddindx).application_usg_code;
          a13(indx) := t(ddindx).application_usg;
          a14(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_wf_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_DATE_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_wf_mapping_tbl ahl_wf_mapping_pvt.wf_mapping_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ahl_wf_mapping_pvt_w.rosetta_table_copy_in_p1(ddp_x_wf_mapping_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.process_wf_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_x_wf_mapping_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    ahl_wf_mapping_pvt_w.rosetta_table_copy_out_p1(ddp_x_wf_mapping_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      );



  end;

  procedure create_wf_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_wf_mapping_id out nocopy  NUMBER
  )

  as
    ddp_wf_mapping_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_wf_mapping_rec.wf_mapping_id := p4_a0;
    ddp_wf_mapping_rec.object_version_number := p4_a1;
    ddp_wf_mapping_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_wf_mapping_rec.created_by := p4_a3;
    ddp_wf_mapping_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_wf_mapping_rec.last_updated_by := p4_a5;
    ddp_wf_mapping_rec.last_update_login := p4_a6;
    ddp_wf_mapping_rec.active_flag := p4_a7;
    ddp_wf_mapping_rec.wf_process_name := p4_a8;
    ddp_wf_mapping_rec.wf_display_name := p4_a9;
    ddp_wf_mapping_rec.approval_object := p4_a10;
    ddp_wf_mapping_rec.item_type := p4_a11;
    ddp_wf_mapping_rec.application_usg_code := p4_a12;
    ddp_wf_mapping_rec.application_usg := p4_a13;
    ddp_wf_mapping_rec.operation_flag := p4_a14;





    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.create_wf_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_wf_mapping_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_wf_mapping_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_wf_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_wf_mapping_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_wf_mapping_rec.wf_mapping_id := p4_a0;
    ddp_wf_mapping_rec.object_version_number := p4_a1;
    ddp_wf_mapping_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_wf_mapping_rec.created_by := p4_a3;
    ddp_wf_mapping_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_wf_mapping_rec.last_updated_by := p4_a5;
    ddp_wf_mapping_rec.last_update_login := p4_a6;
    ddp_wf_mapping_rec.active_flag := p4_a7;
    ddp_wf_mapping_rec.wf_process_name := p4_a8;
    ddp_wf_mapping_rec.wf_display_name := p4_a9;
    ddp_wf_mapping_rec.approval_object := p4_a10;
    ddp_wf_mapping_rec.item_type := p4_a11;
    ddp_wf_mapping_rec.application_usg_code := p4_a12;
    ddp_wf_mapping_rec.application_usg := p4_a13;
    ddp_wf_mapping_rec.operation_flag := p4_a14;




    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.update_wf_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_wf_mapping_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_wf_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
  )

  as
    ddp_wf_mapping_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_wf_mapping_rec.wf_mapping_id := p7_a0;
    ddp_wf_mapping_rec.object_version_number := p7_a1;
    ddp_wf_mapping_rec.creation_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_wf_mapping_rec.created_by := p7_a3;
    ddp_wf_mapping_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_wf_mapping_rec.last_updated_by := p7_a5;
    ddp_wf_mapping_rec.last_update_login := p7_a6;
    ddp_wf_mapping_rec.active_flag := p7_a7;
    ddp_wf_mapping_rec.wf_process_name := p7_a8;
    ddp_wf_mapping_rec.wf_display_name := p7_a9;
    ddp_wf_mapping_rec.approval_object := p7_a10;
    ddp_wf_mapping_rec.item_type := p7_a11;
    ddp_wf_mapping_rec.application_usg_code := p7_a12;
    ddp_wf_mapping_rec.application_usg := p7_a13;
    ddp_wf_mapping_rec.operation_flag := p7_a14;

    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.validate_wf_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_wf_mapping_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_wf_mapping_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_wf_mapping_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_wf_mapping_rec.wf_mapping_id := p0_a0;
    ddp_wf_mapping_rec.object_version_number := p0_a1;
    ddp_wf_mapping_rec.creation_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_wf_mapping_rec.created_by := p0_a3;
    ddp_wf_mapping_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_wf_mapping_rec.last_updated_by := p0_a5;
    ddp_wf_mapping_rec.last_update_login := p0_a6;
    ddp_wf_mapping_rec.active_flag := p0_a7;
    ddp_wf_mapping_rec.wf_process_name := p0_a8;
    ddp_wf_mapping_rec.wf_display_name := p0_a9;
    ddp_wf_mapping_rec.approval_object := p0_a10;
    ddp_wf_mapping_rec.item_type := p0_a11;
    ddp_wf_mapping_rec.application_usg_code := p0_a12;
    ddp_wf_mapping_rec.application_usg := p0_a13;
    ddp_wf_mapping_rec.operation_flag := p0_a14;



    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.check_wf_mapping_items(ddp_wf_mapping_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_wf_mapping_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
  )

  as
    ddp_wf_mapping_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddx_complete_rec ahl_wf_mapping_pvt.wf_mapping_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_wf_mapping_rec.wf_mapping_id := p0_a0;
    ddp_wf_mapping_rec.object_version_number := p0_a1;
    ddp_wf_mapping_rec.creation_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_wf_mapping_rec.created_by := p0_a3;
    ddp_wf_mapping_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_wf_mapping_rec.last_updated_by := p0_a5;
    ddp_wf_mapping_rec.last_update_login := p0_a6;
    ddp_wf_mapping_rec.active_flag := p0_a7;
    ddp_wf_mapping_rec.wf_process_name := p0_a8;
    ddp_wf_mapping_rec.wf_display_name := p0_a9;
    ddp_wf_mapping_rec.approval_object := p0_a10;
    ddp_wf_mapping_rec.item_type := p0_a11;
    ddp_wf_mapping_rec.application_usg_code := p0_a12;
    ddp_wf_mapping_rec.application_usg := p0_a13;
    ddp_wf_mapping_rec.operation_flag := p0_a14;


    -- here's the delegated call to the old PL/SQL routine
    ahl_wf_mapping_pvt.complete_wf_mapping_rec(ddp_wf_mapping_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.wf_mapping_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.creation_date;
    p1_a3 := ddx_complete_rec.created_by;
    p1_a4 := ddx_complete_rec.last_update_date;
    p1_a5 := ddx_complete_rec.last_updated_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.active_flag;
    p1_a8 := ddx_complete_rec.wf_process_name;
    p1_a9 := ddx_complete_rec.wf_display_name;
    p1_a10 := ddx_complete_rec.approval_object;
    p1_a11 := ddx_complete_rec.item_type;
    p1_a12 := ddx_complete_rec.application_usg_code;
    p1_a13 := ddx_complete_rec.application_usg;
    p1_a14 := ddx_complete_rec.operation_flag;
  end;

end ahl_wf_mapping_pvt_w;

/
