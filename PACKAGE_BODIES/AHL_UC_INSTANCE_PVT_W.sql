--------------------------------------------------------
--  DDL for Package Body AHL_UC_INSTANCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_INSTANCE_PVT_W" as
  /* $Header: AHLWUCIB.pls 120.2.12010000.4 2008/11/20 11:47:49 sathapli ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_uc_instance_pvt.uc_child_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
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
          t(ddindx).node_type := a0(indx);
          t(ddindx).instance_id := a1(indx);
          t(ddindx).relationship_id := a2(indx);
          t(ddindx).leaf_node_flag := a3(indx);
          t(ddindx).with_subunit_flag := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_uc_instance_pvt.uc_child_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).node_type;
          a1(indx) := t(ddindx).instance_id;
          a2(indx) := t(ddindx).relationship_id;
          a3(indx) := t(ddindx).leaf_node_flag;
          a4(indx) := t(ddindx).with_subunit_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_uc_instance_pvt.uc_descendant_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).node_type := a0(indx);
          t(ddindx).instance_id := a1(indx);
          t(ddindx).parent_instance_id := a2(indx);
          t(ddindx).relationship_id := a3(indx);
          t(ddindx).parent_rel_id := a4(indx);
          t(ddindx).leaf_node_flag := a5(indx);
          t(ddindx).with_submc_flag := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_uc_instance_pvt.uc_descendant_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).node_type;
          a1(indx) := t(ddindx).instance_id;
          a2(indx) := t(ddindx).parent_instance_id;
          a3(indx) := t(ddindx).relationship_id;
          a4(indx) := t(ddindx).parent_rel_id;
          a5(indx) := t(ddindx).leaf_node_flag;
          a6(indx) := t(ddindx).with_submc_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_uc_instance_pvt.available_instance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_400
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).csi_item_instance_id := a0(indx);
          t(ddindx).csi_object_version_number := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).inventory_org_id := a3(indx);
          t(ddindx).organization_code := a4(indx);
          t(ddindx).item_number := a5(indx);
          t(ddindx).item_description := a6(indx);
          t(ddindx).csi_instance_number := a7(indx);
          t(ddindx).serial_number := a8(indx);
          t(ddindx).lot_number := a9(indx);
          t(ddindx).revision := a10(indx);
          t(ddindx).uom_code := a11(indx);
          t(ddindx).quantity := a12(indx);
          t(ddindx).priority := a13(indx);
          t(ddindx).install_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).mfg_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).location_description := a16(indx);
          t(ddindx).party_type := a17(indx);
          t(ddindx).owner_id := a18(indx);
          t(ddindx).owner_number := a19(indx);
          t(ddindx).owner_name := a20(indx);
          t(ddindx).owner_site_id := a21(indx);
          t(ddindx).owner_site_number := a22(indx);
          t(ddindx).csi_party_object_version_num := a23(indx);
          t(ddindx).status := a24(indx);
          t(ddindx).condition := a25(indx);
          t(ddindx).uc_header_id := a26(indx);
          t(ddindx).uc_name := a27(indx);
          t(ddindx).uc_status := a28(indx);
          t(ddindx).mc_header_id := a29(indx);
          t(ddindx).mc_name := a30(indx);
          t(ddindx).mc_revision := a31(indx);
          t(ddindx).mc_status := a32(indx);
          t(ddindx).position_ref := a33(indx);
          t(ddindx).wip_entity_name := a34(indx);
          t(ddindx).csi_ii_relationship_ovn := a35(indx);
          t(ddindx).subinventory_code := a36(indx);
          t(ddindx).inventory_locator_id := a37(indx);
          t(ddindx).locator_segments := a38(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ahl_uc_instance_pvt.available_instance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    , a20 out nocopy JTF_VARCHAR2_TABLE_400
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_400();
    a20 := JTF_VARCHAR2_TABLE_400();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_400();
      a20 := JTF_VARCHAR2_TABLE_400();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_300();
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
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).csi_item_instance_id;
          a1(indx) := t(ddindx).csi_object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).inventory_org_id;
          a4(indx) := t(ddindx).organization_code;
          a5(indx) := t(ddindx).item_number;
          a6(indx) := t(ddindx).item_description;
          a7(indx) := t(ddindx).csi_instance_number;
          a8(indx) := t(ddindx).serial_number;
          a9(indx) := t(ddindx).lot_number;
          a10(indx) := t(ddindx).revision;
          a11(indx) := t(ddindx).uom_code;
          a12(indx) := t(ddindx).quantity;
          a13(indx) := t(ddindx).priority;
          a14(indx) := t(ddindx).install_date;
          a15(indx) := t(ddindx).mfg_date;
          a16(indx) := t(ddindx).location_description;
          a17(indx) := t(ddindx).party_type;
          a18(indx) := t(ddindx).owner_id;
          a19(indx) := t(ddindx).owner_number;
          a20(indx) := t(ddindx).owner_name;
          a21(indx) := t(ddindx).owner_site_id;
          a22(indx) := t(ddindx).owner_site_number;
          a23(indx) := t(ddindx).csi_party_object_version_num;
          a24(indx) := t(ddindx).status;
          a25(indx) := t(ddindx).condition;
          a26(indx) := t(ddindx).uc_header_id;
          a27(indx) := t(ddindx).uc_name;
          a28(indx) := t(ddindx).uc_status;
          a29(indx) := t(ddindx).mc_header_id;
          a30(indx) := t(ddindx).mc_name;
          a31(indx) := t(ddindx).mc_revision;
          a32(indx) := t(ddindx).mc_status;
          a33(indx) := t(ddindx).position_ref;
          a34(indx) := t(ddindx).wip_entity_name;
          a35(indx) := t(ddindx).csi_ii_relationship_ovn;
          a36(indx) := t(ddindx).subinventory_code;
          a37(indx) := t(ddindx).inventory_locator_id;
          a38(indx) := t(ddindx).locator_segments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure update_instance_attr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  DATE
    , p8_a14  DATE
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p_prod_user_flag  VARCHAR2
  )

  as
    ddp_uc_instance_rec ahl_uc_instance_pvt.uc_instance_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_uc_instance_rec.inventory_item_id := p8_a0;
    ddp_uc_instance_rec.inventory_org_id := p8_a1;
    ddp_uc_instance_rec.inventory_org_code := p8_a2;
    ddp_uc_instance_rec.item_number := p8_a3;
    ddp_uc_instance_rec.instance_id := p8_a4;
    ddp_uc_instance_rec.instance_number := p8_a5;
    ddp_uc_instance_rec.serial_number := p8_a6;
    ddp_uc_instance_rec.sn_tag_code := p8_a7;
    ddp_uc_instance_rec.sn_tag_meaning := p8_a8;
    ddp_uc_instance_rec.lot_number := p8_a9;
    ddp_uc_instance_rec.quantity := p8_a10;
    ddp_uc_instance_rec.uom_code := p8_a11;
    ddp_uc_instance_rec.revision := p8_a12;
    ddp_uc_instance_rec.mfg_date := rosetta_g_miss_date_in_map(p8_a13);
    ddp_uc_instance_rec.install_date := rosetta_g_miss_date_in_map(p8_a14);
    ddp_uc_instance_rec.relationship_id := p8_a15;
    ddp_uc_instance_rec.object_version_number := p8_a16;
    ddp_uc_instance_rec.context := p8_a17;
    ddp_uc_instance_rec.attribute1 := p8_a18;
    ddp_uc_instance_rec.attribute2 := p8_a19;
    ddp_uc_instance_rec.attribute3 := p8_a20;
    ddp_uc_instance_rec.attribute4 := p8_a21;
    ddp_uc_instance_rec.attribute5 := p8_a22;
    ddp_uc_instance_rec.attribute6 := p8_a23;
    ddp_uc_instance_rec.attribute7 := p8_a24;
    ddp_uc_instance_rec.attribute8 := p8_a25;
    ddp_uc_instance_rec.attribute9 := p8_a26;
    ddp_uc_instance_rec.attribute10 := p8_a27;
    ddp_uc_instance_rec.attribute11 := p8_a28;
    ddp_uc_instance_rec.attribute12 := p8_a29;
    ddp_uc_instance_rec.attribute13 := p8_a30;
    ddp_uc_instance_rec.attribute14 := p8_a31;
    ddp_uc_instance_rec.attribute15 := p8_a32;
    ddp_uc_instance_rec.attribute16 := p8_a33;
    ddp_uc_instance_rec.attribute17 := p8_a34;
    ddp_uc_instance_rec.attribute18 := p8_a35;
    ddp_uc_instance_rec.attribute19 := p8_a36;
    ddp_uc_instance_rec.attribute20 := p8_a37;
    ddp_uc_instance_rec.attribute21 := p8_a38;
    ddp_uc_instance_rec.attribute22 := p8_a39;
    ddp_uc_instance_rec.attribute23 := p8_a40;
    ddp_uc_instance_rec.attribute24 := p8_a41;
    ddp_uc_instance_rec.attribute25 := p8_a42;
    ddp_uc_instance_rec.attribute26 := p8_a43;
    ddp_uc_instance_rec.attribute27 := p8_a44;
    ddp_uc_instance_rec.attribute28 := p8_a45;
    ddp_uc_instance_rec.attribute29 := p8_a46;
    ddp_uc_instance_rec.attribute30 := p8_a47;


    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.update_instance_attr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_uc_header_id,
      ddp_uc_instance_rec,
      p_prod_user_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure install_new_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_prod_user_flag  VARCHAR2
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  VARCHAR2
    , p10_a3 in out nocopy  VARCHAR2
    , p10_a4 in out nocopy  NUMBER
    , p10_a5 in out nocopy  VARCHAR2
    , p10_a6 in out nocopy  VARCHAR2
    , p10_a7 in out nocopy  VARCHAR2
    , p10_a8 in out nocopy  VARCHAR2
    , p10_a9 in out nocopy  VARCHAR2
    , p10_a10 in out nocopy  NUMBER
    , p10_a11 in out nocopy  VARCHAR2
    , p10_a12 in out nocopy  VARCHAR2
    , p10_a13 in out nocopy  DATE
    , p10_a14 in out nocopy  DATE
    , p10_a15 in out nocopy  NUMBER
    , p10_a16 in out nocopy  NUMBER
    , p10_a17 in out nocopy  VARCHAR2
    , p10_a18 in out nocopy  VARCHAR2
    , p10_a19 in out nocopy  VARCHAR2
    , p10_a20 in out nocopy  VARCHAR2
    , p10_a21 in out nocopy  VARCHAR2
    , p10_a22 in out nocopy  VARCHAR2
    , p10_a23 in out nocopy  VARCHAR2
    , p10_a24 in out nocopy  VARCHAR2
    , p10_a25 in out nocopy  VARCHAR2
    , p10_a26 in out nocopy  VARCHAR2
    , p10_a27 in out nocopy  VARCHAR2
    , p10_a28 in out nocopy  VARCHAR2
    , p10_a29 in out nocopy  VARCHAR2
    , p10_a30 in out nocopy  VARCHAR2
    , p10_a31 in out nocopy  VARCHAR2
    , p10_a32 in out nocopy  VARCHAR2
    , p10_a33 in out nocopy  VARCHAR2
    , p10_a34 in out nocopy  VARCHAR2
    , p10_a35 in out nocopy  VARCHAR2
    , p10_a36 in out nocopy  VARCHAR2
    , p10_a37 in out nocopy  VARCHAR2
    , p10_a38 in out nocopy  VARCHAR2
    , p10_a39 in out nocopy  VARCHAR2
    , p10_a40 in out nocopy  VARCHAR2
    , p10_a41 in out nocopy  VARCHAR2
    , p10_a42 in out nocopy  VARCHAR2
    , p10_a43 in out nocopy  VARCHAR2
    , p10_a44 in out nocopy  VARCHAR2
    , p10_a45 in out nocopy  VARCHAR2
    , p10_a46 in out nocopy  VARCHAR2
    , p10_a47 in out nocopy  VARCHAR2
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  VARCHAR2
    , p11_a2 in out nocopy  NUMBER
    , p11_a3 in out nocopy  VARCHAR2
    , p11_a4 in out nocopy  VARCHAR2
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  VARCHAR2
    , p11_a8 in out nocopy  NUMBER
    , p11_a9 in out nocopy  VARCHAR2
    , p11_a10 in out nocopy  DATE
    , p11_a11 in out nocopy  DATE
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  VARCHAR2
    , p11_a14 in out nocopy  VARCHAR2
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  VARCHAR2
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  VARCHAR2
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_x_uc_instance_rec ahl_uc_instance_pvt.uc_instance_rec_type;
    ddp_x_sub_uc_rec ahl_uc_instance_pvt.uc_header_rec_type;
    ddx_warning_msg_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_x_uc_instance_rec.inventory_item_id := p10_a0;
    ddp_x_uc_instance_rec.inventory_org_id := p10_a1;
    ddp_x_uc_instance_rec.inventory_org_code := p10_a2;
    ddp_x_uc_instance_rec.item_number := p10_a3;
    ddp_x_uc_instance_rec.instance_id := p10_a4;
    ddp_x_uc_instance_rec.instance_number := p10_a5;
    ddp_x_uc_instance_rec.serial_number := p10_a6;
    ddp_x_uc_instance_rec.sn_tag_code := p10_a7;
    ddp_x_uc_instance_rec.sn_tag_meaning := p10_a8;
    ddp_x_uc_instance_rec.lot_number := p10_a9;
    ddp_x_uc_instance_rec.quantity := p10_a10;
    ddp_x_uc_instance_rec.uom_code := p10_a11;
    ddp_x_uc_instance_rec.revision := p10_a12;
    ddp_x_uc_instance_rec.mfg_date := rosetta_g_miss_date_in_map(p10_a13);
    ddp_x_uc_instance_rec.install_date := rosetta_g_miss_date_in_map(p10_a14);
    ddp_x_uc_instance_rec.relationship_id := p10_a15;
    ddp_x_uc_instance_rec.object_version_number := p10_a16;
    ddp_x_uc_instance_rec.context := p10_a17;
    ddp_x_uc_instance_rec.attribute1 := p10_a18;
    ddp_x_uc_instance_rec.attribute2 := p10_a19;
    ddp_x_uc_instance_rec.attribute3 := p10_a20;
    ddp_x_uc_instance_rec.attribute4 := p10_a21;
    ddp_x_uc_instance_rec.attribute5 := p10_a22;
    ddp_x_uc_instance_rec.attribute6 := p10_a23;
    ddp_x_uc_instance_rec.attribute7 := p10_a24;
    ddp_x_uc_instance_rec.attribute8 := p10_a25;
    ddp_x_uc_instance_rec.attribute9 := p10_a26;
    ddp_x_uc_instance_rec.attribute10 := p10_a27;
    ddp_x_uc_instance_rec.attribute11 := p10_a28;
    ddp_x_uc_instance_rec.attribute12 := p10_a29;
    ddp_x_uc_instance_rec.attribute13 := p10_a30;
    ddp_x_uc_instance_rec.attribute14 := p10_a31;
    ddp_x_uc_instance_rec.attribute15 := p10_a32;
    ddp_x_uc_instance_rec.attribute16 := p10_a33;
    ddp_x_uc_instance_rec.attribute17 := p10_a34;
    ddp_x_uc_instance_rec.attribute18 := p10_a35;
    ddp_x_uc_instance_rec.attribute19 := p10_a36;
    ddp_x_uc_instance_rec.attribute20 := p10_a37;
    ddp_x_uc_instance_rec.attribute21 := p10_a38;
    ddp_x_uc_instance_rec.attribute22 := p10_a39;
    ddp_x_uc_instance_rec.attribute23 := p10_a40;
    ddp_x_uc_instance_rec.attribute24 := p10_a41;
    ddp_x_uc_instance_rec.attribute25 := p10_a42;
    ddp_x_uc_instance_rec.attribute26 := p10_a43;
    ddp_x_uc_instance_rec.attribute27 := p10_a44;
    ddp_x_uc_instance_rec.attribute28 := p10_a45;
    ddp_x_uc_instance_rec.attribute29 := p10_a46;
    ddp_x_uc_instance_rec.attribute30 := p10_a47;

    ddp_x_sub_uc_rec.uc_header_id := p11_a0;
    ddp_x_sub_uc_rec.uc_name := p11_a1;
    ddp_x_sub_uc_rec.mc_header_id := p11_a2;
    ddp_x_sub_uc_rec.mc_name := p11_a3;
    ddp_x_sub_uc_rec.mc_revision := p11_a4;
    ddp_x_sub_uc_rec.parent_uc_header_id := p11_a5;
    ddp_x_sub_uc_rec.unit_config_status_code := p11_a6;
    ddp_x_sub_uc_rec.active_uc_status_code := p11_a7;
    ddp_x_sub_uc_rec.instance_id := p11_a8;
    ddp_x_sub_uc_rec.instance_number := p11_a9;
    ddp_x_sub_uc_rec.active_start_date := rosetta_g_miss_date_in_map(p11_a10);
    ddp_x_sub_uc_rec.active_end_date := rosetta_g_miss_date_in_map(p11_a11);
    ddp_x_sub_uc_rec.object_version_number := p11_a12;
    ddp_x_sub_uc_rec.attribute_category := p11_a13;
    ddp_x_sub_uc_rec.attribute1 := p11_a14;
    ddp_x_sub_uc_rec.attribute2 := p11_a15;
    ddp_x_sub_uc_rec.attribute3 := p11_a16;
    ddp_x_sub_uc_rec.attribute4 := p11_a17;
    ddp_x_sub_uc_rec.attribute5 := p11_a18;
    ddp_x_sub_uc_rec.attribute6 := p11_a19;
    ddp_x_sub_uc_rec.attribute7 := p11_a20;
    ddp_x_sub_uc_rec.attribute8 := p11_a21;
    ddp_x_sub_uc_rec.attribute9 := p11_a22;
    ddp_x_sub_uc_rec.attribute10 := p11_a23;
    ddp_x_sub_uc_rec.attribute11 := p11_a24;
    ddp_x_sub_uc_rec.attribute12 := p11_a25;
    ddp_x_sub_uc_rec.attribute13 := p11_a26;
    ddp_x_sub_uc_rec.attribute14 := p11_a27;
    ddp_x_sub_uc_rec.attribute15 := p11_a28;


    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.install_new_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_uc_header_id,
      p_parent_instance_id,
      p_prod_user_flag,
      ddp_x_uc_instance_rec,
      ddp_x_sub_uc_rec,
      ddx_warning_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddp_x_uc_instance_rec.inventory_item_id;
    p10_a1 := ddp_x_uc_instance_rec.inventory_org_id;
    p10_a2 := ddp_x_uc_instance_rec.inventory_org_code;
    p10_a3 := ddp_x_uc_instance_rec.item_number;
    p10_a4 := ddp_x_uc_instance_rec.instance_id;
    p10_a5 := ddp_x_uc_instance_rec.instance_number;
    p10_a6 := ddp_x_uc_instance_rec.serial_number;
    p10_a7 := ddp_x_uc_instance_rec.sn_tag_code;
    p10_a8 := ddp_x_uc_instance_rec.sn_tag_meaning;
    p10_a9 := ddp_x_uc_instance_rec.lot_number;
    p10_a10 := ddp_x_uc_instance_rec.quantity;
    p10_a11 := ddp_x_uc_instance_rec.uom_code;
    p10_a12 := ddp_x_uc_instance_rec.revision;
    p10_a13 := ddp_x_uc_instance_rec.mfg_date;
    p10_a14 := ddp_x_uc_instance_rec.install_date;
    p10_a15 := ddp_x_uc_instance_rec.relationship_id;
    p10_a16 := ddp_x_uc_instance_rec.object_version_number;
    p10_a17 := ddp_x_uc_instance_rec.context;
    p10_a18 := ddp_x_uc_instance_rec.attribute1;
    p10_a19 := ddp_x_uc_instance_rec.attribute2;
    p10_a20 := ddp_x_uc_instance_rec.attribute3;
    p10_a21 := ddp_x_uc_instance_rec.attribute4;
    p10_a22 := ddp_x_uc_instance_rec.attribute5;
    p10_a23 := ddp_x_uc_instance_rec.attribute6;
    p10_a24 := ddp_x_uc_instance_rec.attribute7;
    p10_a25 := ddp_x_uc_instance_rec.attribute8;
    p10_a26 := ddp_x_uc_instance_rec.attribute9;
    p10_a27 := ddp_x_uc_instance_rec.attribute10;
    p10_a28 := ddp_x_uc_instance_rec.attribute11;
    p10_a29 := ddp_x_uc_instance_rec.attribute12;
    p10_a30 := ddp_x_uc_instance_rec.attribute13;
    p10_a31 := ddp_x_uc_instance_rec.attribute14;
    p10_a32 := ddp_x_uc_instance_rec.attribute15;
    p10_a33 := ddp_x_uc_instance_rec.attribute16;
    p10_a34 := ddp_x_uc_instance_rec.attribute17;
    p10_a35 := ddp_x_uc_instance_rec.attribute18;
    p10_a36 := ddp_x_uc_instance_rec.attribute19;
    p10_a37 := ddp_x_uc_instance_rec.attribute20;
    p10_a38 := ddp_x_uc_instance_rec.attribute21;
    p10_a39 := ddp_x_uc_instance_rec.attribute22;
    p10_a40 := ddp_x_uc_instance_rec.attribute23;
    p10_a41 := ddp_x_uc_instance_rec.attribute24;
    p10_a42 := ddp_x_uc_instance_rec.attribute25;
    p10_a43 := ddp_x_uc_instance_rec.attribute26;
    p10_a44 := ddp_x_uc_instance_rec.attribute27;
    p10_a45 := ddp_x_uc_instance_rec.attribute28;
    p10_a46 := ddp_x_uc_instance_rec.attribute29;
    p10_a47 := ddp_x_uc_instance_rec.attribute30;

    p11_a0 := ddp_x_sub_uc_rec.uc_header_id;
    p11_a1 := ddp_x_sub_uc_rec.uc_name;
    p11_a2 := ddp_x_sub_uc_rec.mc_header_id;
    p11_a3 := ddp_x_sub_uc_rec.mc_name;
    p11_a4 := ddp_x_sub_uc_rec.mc_revision;
    p11_a5 := ddp_x_sub_uc_rec.parent_uc_header_id;
    p11_a6 := ddp_x_sub_uc_rec.unit_config_status_code;
    p11_a7 := ddp_x_sub_uc_rec.active_uc_status_code;
    p11_a8 := ddp_x_sub_uc_rec.instance_id;
    p11_a9 := ddp_x_sub_uc_rec.instance_number;
    p11_a10 := ddp_x_sub_uc_rec.active_start_date;
    p11_a11 := ddp_x_sub_uc_rec.active_end_date;
    p11_a12 := ddp_x_sub_uc_rec.object_version_number;
    p11_a13 := ddp_x_sub_uc_rec.attribute_category;
    p11_a14 := ddp_x_sub_uc_rec.attribute1;
    p11_a15 := ddp_x_sub_uc_rec.attribute2;
    p11_a16 := ddp_x_sub_uc_rec.attribute3;
    p11_a17 := ddp_x_sub_uc_rec.attribute4;
    p11_a18 := ddp_x_sub_uc_rec.attribute5;
    p11_a19 := ddp_x_sub_uc_rec.attribute6;
    p11_a20 := ddp_x_sub_uc_rec.attribute7;
    p11_a21 := ddp_x_sub_uc_rec.attribute8;
    p11_a22 := ddp_x_sub_uc_rec.attribute9;
    p11_a23 := ddp_x_sub_uc_rec.attribute10;
    p11_a24 := ddp_x_sub_uc_rec.attribute11;
    p11_a25 := ddp_x_sub_uc_rec.attribute12;
    p11_a26 := ddp_x_sub_uc_rec.attribute13;
    p11_a27 := ddp_x_sub_uc_rec.attribute14;
    p11_a28 := ddp_x_sub_uc_rec.attribute15;

    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_warning_msg_tbl, x_warning_msg_tbl);
  end;

  procedure install_existing_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_instance_id  NUMBER
    , p_instance_number  VARCHAR2
    , p_relationship_id  NUMBER
    , p_csi_ii_ovn  NUMBER
    , p_prod_user_flag  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_warning_msg_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.install_existing_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_uc_header_id,
      p_parent_instance_id,
      p_instance_id,
      p_instance_number,
      p_relationship_id,
      p_csi_ii_ovn,
      p_prod_user_flag,
      ddx_warning_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_warning_msg_tbl, x_warning_msg_tbl);
  end;

  procedure swap_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_old_instance_id  NUMBER
    , p_new_instance_id  NUMBER
    , p_new_instance_number  VARCHAR2
    , p_relationship_id  NUMBER
    , p_csi_ii_ovn  NUMBER
    , p_prod_user_flag  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_warning_msg_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.swap_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_uc_header_id,
      p_parent_instance_id,
      p_old_instance_id,
      p_new_instance_id,
      p_new_instance_number,
      p_relationship_id,
      p_csi_ii_ovn,
      p_prod_user_flag,
      ddx_warning_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_warning_msg_tbl, x_warning_msg_tbl);
  end;

  procedure get_available_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_parent_instance_id  NUMBER
    , p_relationship_id  NUMBER
    , p_item_number  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_instance_number  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row_index  NUMBER
    , p_max_rows  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_NUMBER_TABLE
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_DATE_TABLE
    , p14_a15 out nocopy JTF_DATE_TABLE
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_NUMBER_TABLE
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_400
    , p14_a21 out nocopy JTF_NUMBER_TABLE
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a26 out nocopy JTF_NUMBER_TABLE
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , p14_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a35 out nocopy JTF_NUMBER_TABLE
    , p14_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a37 out nocopy JTF_NUMBER_TABLE
    , p14_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , x_tbl_count out nocopy  NUMBER
  )

  as
    ddx_available_instance_tbl ahl_uc_instance_pvt.available_instance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.get_available_instances(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_parent_instance_id,
      p_relationship_id,
      p_item_number,
      p_serial_number,
      p_instance_number,
      p_workorder_id,
      p_start_row_index,
      p_max_rows,
      ddx_available_instance_tbl,
      x_tbl_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    ahl_uc_instance_pvt_w.rosetta_table_copy_out_p7(ddx_available_instance_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      , p14_a27
      , p14_a28
      , p14_a29
      , p14_a30
      , p14_a31
      , p14_a32
      , p14_a33
      , p14_a34
      , p14_a35
      , p14_a36
      , p14_a37
      , p14_a38
      );

  end;

  procedure get_avail_subinv_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_relationship_id  NUMBER
    , p_item_number  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_instance_number  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row_index  NUMBER
    , p_max_rows  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_NUMBER_TABLE
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_DATE_TABLE
    , p13_a15 out nocopy JTF_DATE_TABLE
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p13_a20 out nocopy JTF_VARCHAR2_TABLE_400
    , p13_a21 out nocopy JTF_NUMBER_TABLE
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a26 out nocopy JTF_NUMBER_TABLE
    , p13_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a35 out nocopy JTF_NUMBER_TABLE
    , p13_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a37 out nocopy JTF_NUMBER_TABLE
    , p13_a38 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_avail_subinv_instance_tbl ahl_uc_instance_pvt.available_instance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.get_avail_subinv_instances(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_relationship_id,
      p_item_number,
      p_serial_number,
      p_instance_number,
      p_workorder_id,
      p_start_row_index,
      p_max_rows,
      ddx_avail_subinv_instance_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    ahl_uc_instance_pvt_w.rosetta_table_copy_out_p7(ddx_avail_subinv_instance_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      , p13_a27
      , p13_a28
      , p13_a29
      , p13_a30
      , p13_a31
      , p13_a32
      , p13_a33
      , p13_a34
      , p13_a35
      , p13_a36
      , p13_a37
      , p13_a38
      );
  end;

  procedure create_unassigned_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  VARCHAR2
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  DATE
    , p8_a14 in out nocopy  DATE
    , p8_a15 in out nocopy  NUMBER
    , p8_a16 in out nocopy  NUMBER
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p8_a30 in out nocopy  VARCHAR2
    , p8_a31 in out nocopy  VARCHAR2
    , p8_a32 in out nocopy  VARCHAR2
    , p8_a33 in out nocopy  VARCHAR2
    , p8_a34 in out nocopy  VARCHAR2
    , p8_a35 in out nocopy  VARCHAR2
    , p8_a36 in out nocopy  VARCHAR2
    , p8_a37 in out nocopy  VARCHAR2
    , p8_a38 in out nocopy  VARCHAR2
    , p8_a39 in out nocopy  VARCHAR2
    , p8_a40 in out nocopy  VARCHAR2
    , p8_a41 in out nocopy  VARCHAR2
    , p8_a42 in out nocopy  VARCHAR2
    , p8_a43 in out nocopy  VARCHAR2
    , p8_a44 in out nocopy  VARCHAR2
    , p8_a45 in out nocopy  VARCHAR2
    , p8_a46 in out nocopy  VARCHAR2
    , p8_a47 in out nocopy  VARCHAR2
  )

  as
    ddp_x_uc_instance_rec ahl_uc_instance_pvt.uc_instance_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_uc_instance_rec.inventory_item_id := p8_a0;
    ddp_x_uc_instance_rec.inventory_org_id := p8_a1;
    ddp_x_uc_instance_rec.inventory_org_code := p8_a2;
    ddp_x_uc_instance_rec.item_number := p8_a3;
    ddp_x_uc_instance_rec.instance_id := p8_a4;
    ddp_x_uc_instance_rec.instance_number := p8_a5;
    ddp_x_uc_instance_rec.serial_number := p8_a6;
    ddp_x_uc_instance_rec.sn_tag_code := p8_a7;
    ddp_x_uc_instance_rec.sn_tag_meaning := p8_a8;
    ddp_x_uc_instance_rec.lot_number := p8_a9;
    ddp_x_uc_instance_rec.quantity := p8_a10;
    ddp_x_uc_instance_rec.uom_code := p8_a11;
    ddp_x_uc_instance_rec.revision := p8_a12;
    ddp_x_uc_instance_rec.mfg_date := rosetta_g_miss_date_in_map(p8_a13);
    ddp_x_uc_instance_rec.install_date := rosetta_g_miss_date_in_map(p8_a14);
    ddp_x_uc_instance_rec.relationship_id := p8_a15;
    ddp_x_uc_instance_rec.object_version_number := p8_a16;
    ddp_x_uc_instance_rec.context := p8_a17;
    ddp_x_uc_instance_rec.attribute1 := p8_a18;
    ddp_x_uc_instance_rec.attribute2 := p8_a19;
    ddp_x_uc_instance_rec.attribute3 := p8_a20;
    ddp_x_uc_instance_rec.attribute4 := p8_a21;
    ddp_x_uc_instance_rec.attribute5 := p8_a22;
    ddp_x_uc_instance_rec.attribute6 := p8_a23;
    ddp_x_uc_instance_rec.attribute7 := p8_a24;
    ddp_x_uc_instance_rec.attribute8 := p8_a25;
    ddp_x_uc_instance_rec.attribute9 := p8_a26;
    ddp_x_uc_instance_rec.attribute10 := p8_a27;
    ddp_x_uc_instance_rec.attribute11 := p8_a28;
    ddp_x_uc_instance_rec.attribute12 := p8_a29;
    ddp_x_uc_instance_rec.attribute13 := p8_a30;
    ddp_x_uc_instance_rec.attribute14 := p8_a31;
    ddp_x_uc_instance_rec.attribute15 := p8_a32;
    ddp_x_uc_instance_rec.attribute16 := p8_a33;
    ddp_x_uc_instance_rec.attribute17 := p8_a34;
    ddp_x_uc_instance_rec.attribute18 := p8_a35;
    ddp_x_uc_instance_rec.attribute19 := p8_a36;
    ddp_x_uc_instance_rec.attribute20 := p8_a37;
    ddp_x_uc_instance_rec.attribute21 := p8_a38;
    ddp_x_uc_instance_rec.attribute22 := p8_a39;
    ddp_x_uc_instance_rec.attribute23 := p8_a40;
    ddp_x_uc_instance_rec.attribute24 := p8_a41;
    ddp_x_uc_instance_rec.attribute25 := p8_a42;
    ddp_x_uc_instance_rec.attribute26 := p8_a43;
    ddp_x_uc_instance_rec.attribute27 := p8_a44;
    ddp_x_uc_instance_rec.attribute28 := p8_a45;
    ddp_x_uc_instance_rec.attribute29 := p8_a46;
    ddp_x_uc_instance_rec.attribute30 := p8_a47;

    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_instance_pvt.create_unassigned_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_uc_header_id,
      ddp_x_uc_instance_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_uc_instance_rec.inventory_item_id;
    p8_a1 := ddp_x_uc_instance_rec.inventory_org_id;
    p8_a2 := ddp_x_uc_instance_rec.inventory_org_code;
    p8_a3 := ddp_x_uc_instance_rec.item_number;
    p8_a4 := ddp_x_uc_instance_rec.instance_id;
    p8_a5 := ddp_x_uc_instance_rec.instance_number;
    p8_a6 := ddp_x_uc_instance_rec.serial_number;
    p8_a7 := ddp_x_uc_instance_rec.sn_tag_code;
    p8_a8 := ddp_x_uc_instance_rec.sn_tag_meaning;
    p8_a9 := ddp_x_uc_instance_rec.lot_number;
    p8_a10 := ddp_x_uc_instance_rec.quantity;
    p8_a11 := ddp_x_uc_instance_rec.uom_code;
    p8_a12 := ddp_x_uc_instance_rec.revision;
    p8_a13 := ddp_x_uc_instance_rec.mfg_date;
    p8_a14 := ddp_x_uc_instance_rec.install_date;
    p8_a15 := ddp_x_uc_instance_rec.relationship_id;
    p8_a16 := ddp_x_uc_instance_rec.object_version_number;
    p8_a17 := ddp_x_uc_instance_rec.context;
    p8_a18 := ddp_x_uc_instance_rec.attribute1;
    p8_a19 := ddp_x_uc_instance_rec.attribute2;
    p8_a20 := ddp_x_uc_instance_rec.attribute3;
    p8_a21 := ddp_x_uc_instance_rec.attribute4;
    p8_a22 := ddp_x_uc_instance_rec.attribute5;
    p8_a23 := ddp_x_uc_instance_rec.attribute6;
    p8_a24 := ddp_x_uc_instance_rec.attribute7;
    p8_a25 := ddp_x_uc_instance_rec.attribute8;
    p8_a26 := ddp_x_uc_instance_rec.attribute9;
    p8_a27 := ddp_x_uc_instance_rec.attribute10;
    p8_a28 := ddp_x_uc_instance_rec.attribute11;
    p8_a29 := ddp_x_uc_instance_rec.attribute12;
    p8_a30 := ddp_x_uc_instance_rec.attribute13;
    p8_a31 := ddp_x_uc_instance_rec.attribute14;
    p8_a32 := ddp_x_uc_instance_rec.attribute15;
    p8_a33 := ddp_x_uc_instance_rec.attribute16;
    p8_a34 := ddp_x_uc_instance_rec.attribute17;
    p8_a35 := ddp_x_uc_instance_rec.attribute18;
    p8_a36 := ddp_x_uc_instance_rec.attribute19;
    p8_a37 := ddp_x_uc_instance_rec.attribute20;
    p8_a38 := ddp_x_uc_instance_rec.attribute21;
    p8_a39 := ddp_x_uc_instance_rec.attribute22;
    p8_a40 := ddp_x_uc_instance_rec.attribute23;
    p8_a41 := ddp_x_uc_instance_rec.attribute24;
    p8_a42 := ddp_x_uc_instance_rec.attribute25;
    p8_a43 := ddp_x_uc_instance_rec.attribute26;
    p8_a44 := ddp_x_uc_instance_rec.attribute27;
    p8_a45 := ddp_x_uc_instance_rec.attribute28;
    p8_a46 := ddp_x_uc_instance_rec.attribute29;
    p8_a47 := ddp_x_uc_instance_rec.attribute30;
  end;

end ahl_uc_instance_pvt_w;

/
