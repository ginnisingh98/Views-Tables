--------------------------------------------------------
--  DDL for Package Body AHL_UMP_SR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_SR_PVT_W" as
  /* $Header: AHLWUSRB.pls 120.0 2005/07/21 00:07 tamdas noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_ump_sr_pvt.sr_mr_association_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_flag := a0(indx);
          t(ddindx).mr_title := a1(indx);
          t(ddindx).mr_version := a2(indx);
          t(ddindx).mr_header_id := a3(indx);
          t(ddindx).ue_relationship_id := a4(indx);
          t(ddindx).unit_effectivity_id := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          t(ddindx).relationship_code := a7(indx);
          t(ddindx).csi_instance_id := a8(indx);
          t(ddindx).csi_instance_number := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_ump_sr_pvt.sr_mr_association_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).operation_flag;
          a1(indx) := t(ddindx).mr_title;
          a2(indx) := t(ddindx).mr_version;
          a3(indx) := t(ddindx).mr_header_id;
          a4(indx) := t(ddindx).ue_relationship_id;
          a5(indx) := t(ddindx).unit_effectivity_id;
          a6(indx) := t(ddindx).object_version_number;
          a7(indx) := t(ddindx).relationship_code;
          a8(indx) := t(ddindx).csi_instance_id;
          a9(indx) := t(ddindx).csi_instance_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_sr_mr_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_request_id  NUMBER
    , p_object_version_number  NUMBER
    , p_request_number  VARCHAR2
    , p12_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 in out nocopy JTF_NUMBER_TABLE
    , p12_a3 in out nocopy JTF_NUMBER_TABLE
    , p12_a4 in out nocopy JTF_NUMBER_TABLE
    , p12_a5 in out nocopy JTF_NUMBER_TABLE
    , p12_a6 in out nocopy JTF_NUMBER_TABLE
    , p12_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 in out nocopy JTF_NUMBER_TABLE
    , p12_a9 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_sr_mr_association_tbl ahl_ump_sr_pvt.sr_mr_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ahl_ump_sr_pvt_w.rosetta_table_copy_in_p1(ddp_x_sr_mr_association_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_sr_pvt.process_sr_mr_associations(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_user_id,
      p_login_id,
      p_request_id,
      p_object_version_number,
      p_request_number,
      ddp_x_sr_mr_association_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    ahl_ump_sr_pvt_w.rosetta_table_copy_out_p1(ddp_x_sr_mr_association_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      );
  end;

end ahl_ump_sr_pvt_w;

/
