--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_TEMPLATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_TEMPLATE_PUB_W" as
  /* $Header: csiptewb.pls 120.11 2008/03/26 09:11:07 ngoutam ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy csi_counter_template_pub.ctr_template_autoinst_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).counter_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).group_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t csi_counter_template_pub.ctr_template_autoinst_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).counter_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).group_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy csi_counter_template_pub.counter_autoinstantiate_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).counter_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).group_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csi_counter_template_pub.counter_autoinstantiate_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).counter_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).group_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_counter_group(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_NUMBER_TABLE
    , p5_a28 in out nocopy JTF_DATE_TABLE
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_groups_rec csi_ctr_datastructures_pub.counter_groups_rec;
    ddp_ctr_item_associations_tbl csi_ctr_datastructures_pub.ctr_item_associations_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_groups_rec.counter_group_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_groups_rec.name := p4_a1;
    ddp_counter_groups_rec.description := p4_a2;
    ddp_counter_groups_rec.template_flag := p4_a3;
    ddp_counter_groups_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_counter_groups_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_counter_groups_rec.creation_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_counter_groups_rec.created_by := rosetta_g_miss_num_map(p4_a7);
    ddp_counter_groups_rec.last_update_login := rosetta_g_miss_num_map(p4_a8);
    ddp_counter_groups_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_counter_groups_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a10);
    ddp_counter_groups_rec.attribute1 := p4_a11;
    ddp_counter_groups_rec.attribute2 := p4_a12;
    ddp_counter_groups_rec.attribute3 := p4_a13;
    ddp_counter_groups_rec.attribute4 := p4_a14;
    ddp_counter_groups_rec.attribute5 := p4_a15;
    ddp_counter_groups_rec.attribute6 := p4_a16;
    ddp_counter_groups_rec.attribute7 := p4_a17;
    ddp_counter_groups_rec.attribute8 := p4_a18;
    ddp_counter_groups_rec.attribute9 := p4_a19;
    ddp_counter_groups_rec.attribute10 := p4_a20;
    ddp_counter_groups_rec.attribute11 := p4_a21;
    ddp_counter_groups_rec.attribute12 := p4_a22;
    ddp_counter_groups_rec.attribute13 := p4_a23;
    ddp_counter_groups_rec.attribute14 := p4_a24;
    ddp_counter_groups_rec.attribute15 := p4_a25;
    ddp_counter_groups_rec.context := p4_a26;
    ddp_counter_groups_rec.object_version_number := rosetta_g_miss_num_map(p4_a27);
    ddp_counter_groups_rec.created_from_ctr_grp_tmpl_id := rosetta_g_miss_num_map(p4_a28);
    ddp_counter_groups_rec.association_type := p4_a29;
    ddp_counter_groups_rec.source_object_code := p4_a30;
    ddp_counter_groups_rec.source_object_id := rosetta_g_miss_num_map(p4_a31);
    ddp_counter_groups_rec.source_counter_group_id := rosetta_g_miss_num_map(p4_a32);
    ddp_counter_groups_rec.security_group_id := rosetta_g_miss_num_map(p4_a33);
    ddp_counter_groups_rec.upgraded_status_flag := p4_a34;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_counter_group(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_groups_rec,
      ddp_ctr_item_associations_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_groups_rec.counter_group_id);
    p4_a1 := ddp_counter_groups_rec.name;
    p4_a2 := ddp_counter_groups_rec.description;
    p4_a3 := ddp_counter_groups_rec.template_flag;
    p4_a4 := ddp_counter_groups_rec.last_update_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_counter_groups_rec.last_updated_by);
    p4_a6 := ddp_counter_groups_rec.creation_date;
    p4_a7 := rosetta_g_miss_num_map(ddp_counter_groups_rec.created_by);
    p4_a8 := rosetta_g_miss_num_map(ddp_counter_groups_rec.last_update_login);
    p4_a9 := ddp_counter_groups_rec.start_date_active;
    p4_a10 := ddp_counter_groups_rec.end_date_active;
    p4_a11 := ddp_counter_groups_rec.attribute1;
    p4_a12 := ddp_counter_groups_rec.attribute2;
    p4_a13 := ddp_counter_groups_rec.attribute3;
    p4_a14 := ddp_counter_groups_rec.attribute4;
    p4_a15 := ddp_counter_groups_rec.attribute5;
    p4_a16 := ddp_counter_groups_rec.attribute6;
    p4_a17 := ddp_counter_groups_rec.attribute7;
    p4_a18 := ddp_counter_groups_rec.attribute8;
    p4_a19 := ddp_counter_groups_rec.attribute9;
    p4_a20 := ddp_counter_groups_rec.attribute10;
    p4_a21 := ddp_counter_groups_rec.attribute11;
    p4_a22 := ddp_counter_groups_rec.attribute12;
    p4_a23 := ddp_counter_groups_rec.attribute13;
    p4_a24 := ddp_counter_groups_rec.attribute14;
    p4_a25 := ddp_counter_groups_rec.attribute15;
    p4_a26 := ddp_counter_groups_rec.context;
    p4_a27 := rosetta_g_miss_num_map(ddp_counter_groups_rec.object_version_number);
    p4_a28 := rosetta_g_miss_num_map(ddp_counter_groups_rec.created_from_ctr_grp_tmpl_id);
    p4_a29 := ddp_counter_groups_rec.association_type;
    p4_a30 := ddp_counter_groups_rec.source_object_code;
    p4_a31 := rosetta_g_miss_num_map(ddp_counter_groups_rec.source_object_id);
    p4_a32 := rosetta_g_miss_num_map(ddp_counter_groups_rec.source_counter_group_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_counter_groups_rec.security_group_id);
    p4_a34 := ddp_counter_groups_rec.upgraded_status_flag;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );



  end;

  procedure create_item_association(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  DATE
    , p4_a29 in out nocopy  DATE
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_item_associations_rec csi_ctr_datastructures_pub.ctr_item_associations_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_item_associations_rec.ctr_association_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_item_associations_rec.group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_item_associations_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a2);
    ddp_ctr_item_associations_rec.object_version_number := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_item_associations_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_ctr_item_associations_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_ctr_item_associations_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_ctr_item_associations_rec.creation_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_ctr_item_associations_rec.created_by := rosetta_g_miss_num_map(p4_a8);
    ddp_ctr_item_associations_rec.attribute1 := p4_a9;
    ddp_ctr_item_associations_rec.attribute2 := p4_a10;
    ddp_ctr_item_associations_rec.attribute3 := p4_a11;
    ddp_ctr_item_associations_rec.attribute4 := p4_a12;
    ddp_ctr_item_associations_rec.attribute5 := p4_a13;
    ddp_ctr_item_associations_rec.attribute6 := p4_a14;
    ddp_ctr_item_associations_rec.attribute7 := p4_a15;
    ddp_ctr_item_associations_rec.attribute8 := p4_a16;
    ddp_ctr_item_associations_rec.attribute9 := p4_a17;
    ddp_ctr_item_associations_rec.attribute10 := p4_a18;
    ddp_ctr_item_associations_rec.attribute11 := p4_a19;
    ddp_ctr_item_associations_rec.attribute12 := p4_a20;
    ddp_ctr_item_associations_rec.attribute13 := p4_a21;
    ddp_ctr_item_associations_rec.attribute14 := p4_a22;
    ddp_ctr_item_associations_rec.attribute15 := p4_a23;
    ddp_ctr_item_associations_rec.attribute_category := p4_a24;
    ddp_ctr_item_associations_rec.security_group_id := rosetta_g_miss_num_map(p4_a25);
    ddp_ctr_item_associations_rec.migrated_flag := p4_a26;
    ddp_ctr_item_associations_rec.counter_id := rosetta_g_miss_num_map(p4_a27);
    ddp_ctr_item_associations_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a28);
    ddp_ctr_item_associations_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a29);
    ddp_ctr_item_associations_rec.usage_rate := rosetta_g_miss_num_map(p4_a30);
    ddp_ctr_item_associations_rec.use_past_reading := rosetta_g_miss_num_map(p4_a31);
    ddp_ctr_item_associations_rec.associated_to_group := p4_a32;
    ddp_ctr_item_associations_rec.maint_organization_id := rosetta_g_miss_num_map(p4_a33);
    ddp_ctr_item_associations_rec.primary_failure_flag := p4_a34;




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_item_association(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_item_associations_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.ctr_association_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.group_id);
    p4_a2 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.inventory_item_id);
    p4_a3 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.object_version_number);
    p4_a4 := ddp_ctr_item_associations_rec.last_update_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.last_updated_by);
    p4_a6 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.last_update_login);
    p4_a7 := ddp_ctr_item_associations_rec.creation_date;
    p4_a8 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.created_by);
    p4_a9 := ddp_ctr_item_associations_rec.attribute1;
    p4_a10 := ddp_ctr_item_associations_rec.attribute2;
    p4_a11 := ddp_ctr_item_associations_rec.attribute3;
    p4_a12 := ddp_ctr_item_associations_rec.attribute4;
    p4_a13 := ddp_ctr_item_associations_rec.attribute5;
    p4_a14 := ddp_ctr_item_associations_rec.attribute6;
    p4_a15 := ddp_ctr_item_associations_rec.attribute7;
    p4_a16 := ddp_ctr_item_associations_rec.attribute8;
    p4_a17 := ddp_ctr_item_associations_rec.attribute9;
    p4_a18 := ddp_ctr_item_associations_rec.attribute10;
    p4_a19 := ddp_ctr_item_associations_rec.attribute11;
    p4_a20 := ddp_ctr_item_associations_rec.attribute12;
    p4_a21 := ddp_ctr_item_associations_rec.attribute13;
    p4_a22 := ddp_ctr_item_associations_rec.attribute14;
    p4_a23 := ddp_ctr_item_associations_rec.attribute15;
    p4_a24 := ddp_ctr_item_associations_rec.attribute_category;
    p4_a25 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.security_group_id);
    p4_a26 := ddp_ctr_item_associations_rec.migrated_flag;
    p4_a27 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.counter_id);
    p4_a28 := ddp_ctr_item_associations_rec.start_date_active;
    p4_a29 := ddp_ctr_item_associations_rec.end_date_active;
    p4_a30 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.usage_rate);
    p4_a31 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.use_past_reading);
    p4_a32 := ddp_ctr_item_associations_rec.associated_to_group;
    p4_a33 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.maint_organization_id);
    p4_a34 := ddp_ctr_item_associations_rec.primary_failure_flag;



  end;

  procedure create_counter_template(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  NUMBER
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  DATE
    , p4_a19 in out nocopy  DATE
    , p4_a20 in out nocopy  NUMBER
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  NUMBER
    , p4_a23 in out nocopy  DATE
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  VARCHAR2
    , p4_a40 in out nocopy  VARCHAR2
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  NUMBER
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  NUMBER
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  VARCHAR2
    , p4_a66 in out nocopy  NUMBER
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  NUMBER
    , p4_a70 in out nocopy  NUMBER
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  VARCHAR2
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  VARCHAR2
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  VARCHAR2
    , p4_a77 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_NUMBER_TABLE
    , p5_a28 in out nocopy JTF_DATE_TABLE
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_DATE_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_DATE_TABLE
    , p6_a12 in out nocopy JTF_NUMBER_TABLE
    , p6_a13 in out nocopy JTF_DATE_TABLE
    , p6_a14 in out nocopy JTF_NUMBER_TABLE
    , p6_a15 in out nocopy JTF_NUMBER_TABLE
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 in out nocopy JTF_NUMBER_TABLE
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_DATE_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_DATE_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_NUMBER_TABLE
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_DATE_TABLE
    , p8_a11 in out nocopy JTF_NUMBER_TABLE
    , p8_a12 in out nocopy JTF_DATE_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_DATE_TABLE
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_NUMBER_TABLE
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a33 in out nocopy JTF_NUMBER_TABLE
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_template_rec csi_ctr_datastructures_pub.counter_template_rec;
    ddp_ctr_item_associations_tbl csi_ctr_datastructures_pub.ctr_item_associations_tbl;
    ddp_ctr_property_template_tbl csi_ctr_datastructures_pub.ctr_property_template_tbl;
    ddp_counter_relationships_tbl csi_ctr_datastructures_pub.counter_relationships_tbl;
    ddp_ctr_derived_filters_tbl csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_template_rec.counter_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_template_rec.group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_counter_template_rec.counter_type := p4_a2;
    ddp_counter_template_rec.initial_reading := rosetta_g_miss_num_map(p4_a3);
    ddp_counter_template_rec.initial_reading_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_counter_template_rec.tolerance_plus := rosetta_g_miss_num_map(p4_a5);
    ddp_counter_template_rec.tolerance_minus := rosetta_g_miss_num_map(p4_a6);
    ddp_counter_template_rec.uom_code := p4_a7;
    ddp_counter_template_rec.derive_counter_id := rosetta_g_miss_num_map(p4_a8);
    ddp_counter_template_rec.derive_function := p4_a9;
    ddp_counter_template_rec.derive_property_id := rosetta_g_miss_num_map(p4_a10);
    ddp_counter_template_rec.valid_flag := p4_a11;
    ddp_counter_template_rec.formula_incomplete_flag := p4_a12;
    ddp_counter_template_rec.formula_text := p4_a13;
    ddp_counter_template_rec.rollover_last_reading := rosetta_g_miss_num_map(p4_a14);
    ddp_counter_template_rec.rollover_first_reading := rosetta_g_miss_num_map(p4_a15);
    ddp_counter_template_rec.usage_item_id := rosetta_g_miss_num_map(p4_a16);
    ddp_counter_template_rec.ctr_val_max_seq_no := rosetta_g_miss_num_map(p4_a17);
    ddp_counter_template_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a18);
    ddp_counter_template_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a19);
    ddp_counter_template_rec.object_version_number := rosetta_g_miss_num_map(p4_a20);
    ddp_counter_template_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_counter_template_rec.last_updated_by := rosetta_g_miss_num_map(p4_a22);
    ddp_counter_template_rec.creation_date := rosetta_g_miss_date_in_map(p4_a23);
    ddp_counter_template_rec.created_by := rosetta_g_miss_num_map(p4_a24);
    ddp_counter_template_rec.last_update_login := rosetta_g_miss_num_map(p4_a25);
    ddp_counter_template_rec.attribute1 := p4_a26;
    ddp_counter_template_rec.attribute2 := p4_a27;
    ddp_counter_template_rec.attribute3 := p4_a28;
    ddp_counter_template_rec.attribute4 := p4_a29;
    ddp_counter_template_rec.attribute5 := p4_a30;
    ddp_counter_template_rec.attribute6 := p4_a31;
    ddp_counter_template_rec.attribute7 := p4_a32;
    ddp_counter_template_rec.attribute8 := p4_a33;
    ddp_counter_template_rec.attribute9 := p4_a34;
    ddp_counter_template_rec.attribute10 := p4_a35;
    ddp_counter_template_rec.attribute11 := p4_a36;
    ddp_counter_template_rec.attribute12 := p4_a37;
    ddp_counter_template_rec.attribute13 := p4_a38;
    ddp_counter_template_rec.attribute14 := p4_a39;
    ddp_counter_template_rec.attribute15 := p4_a40;
    ddp_counter_template_rec.attribute16 := p4_a41;
    ddp_counter_template_rec.attribute17 := p4_a42;
    ddp_counter_template_rec.attribute18 := p4_a43;
    ddp_counter_template_rec.attribute19 := p4_a44;
    ddp_counter_template_rec.attribute20 := p4_a45;
    ddp_counter_template_rec.attribute21 := p4_a46;
    ddp_counter_template_rec.attribute22 := p4_a47;
    ddp_counter_template_rec.attribute23 := p4_a48;
    ddp_counter_template_rec.attribute24 := p4_a49;
    ddp_counter_template_rec.attribute25 := p4_a50;
    ddp_counter_template_rec.attribute26 := p4_a51;
    ddp_counter_template_rec.attribute27 := p4_a52;
    ddp_counter_template_rec.attribute28 := p4_a53;
    ddp_counter_template_rec.attribute29 := p4_a54;
    ddp_counter_template_rec.attribute30 := p4_a55;
    ddp_counter_template_rec.attribute_category := p4_a56;
    ddp_counter_template_rec.migrated_flag := p4_a57;
    ddp_counter_template_rec.customer_view := p4_a58;
    ddp_counter_template_rec.direction := p4_a59;
    ddp_counter_template_rec.filter_type := p4_a60;
    ddp_counter_template_rec.filter_reading_count := rosetta_g_miss_num_map(p4_a61);
    ddp_counter_template_rec.filter_time_uom := p4_a62;
    ddp_counter_template_rec.estimation_id := rosetta_g_miss_num_map(p4_a63);
    ddp_counter_template_rec.reading_type := rosetta_g_miss_num_map(p4_a64);
    ddp_counter_template_rec.automatic_rollover := p4_a65;
    ddp_counter_template_rec.default_usage_rate := rosetta_g_miss_num_map(p4_a66);
    ddp_counter_template_rec.use_past_reading := rosetta_g_miss_num_map(p4_a67);
    ddp_counter_template_rec.used_in_scheduling := p4_a68;
    ddp_counter_template_rec.defaulted_group_id := rosetta_g_miss_num_map(p4_a69);
    ddp_counter_template_rec.security_group_id := rosetta_g_miss_num_map(p4_a70);
    ddp_counter_template_rec.name := p4_a71;
    ddp_counter_template_rec.description := p4_a72;
    ddp_counter_template_rec.comments := p4_a73;
    ddp_counter_template_rec.association_type := p4_a74;
    ddp_counter_template_rec.step_value := rosetta_g_miss_num_map(p4_a75);
    ddp_counter_template_rec.time_based_manual_entry := p4_a76;
    ddp_counter_template_rec.eam_required_flag := p4_a77;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p12(ddp_ctr_property_template_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p10(ddp_counter_relationships_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p16(ddp_ctr_derived_filters_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_counter_template(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_template_rec,
      ddp_ctr_item_associations_tbl,
      ddp_ctr_property_template_tbl,
      ddp_counter_relationships_tbl,
      ddp_ctr_derived_filters_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_template_rec.counter_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_counter_template_rec.group_id);
    p4_a2 := ddp_counter_template_rec.counter_type;
    p4_a3 := rosetta_g_miss_num_map(ddp_counter_template_rec.initial_reading);
    p4_a4 := ddp_counter_template_rec.initial_reading_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_counter_template_rec.tolerance_plus);
    p4_a6 := rosetta_g_miss_num_map(ddp_counter_template_rec.tolerance_minus);
    p4_a7 := ddp_counter_template_rec.uom_code;
    p4_a8 := rosetta_g_miss_num_map(ddp_counter_template_rec.derive_counter_id);
    p4_a9 := ddp_counter_template_rec.derive_function;
    p4_a10 := rosetta_g_miss_num_map(ddp_counter_template_rec.derive_property_id);
    p4_a11 := ddp_counter_template_rec.valid_flag;
    p4_a12 := ddp_counter_template_rec.formula_incomplete_flag;
    p4_a13 := ddp_counter_template_rec.formula_text;
    p4_a14 := rosetta_g_miss_num_map(ddp_counter_template_rec.rollover_last_reading);
    p4_a15 := rosetta_g_miss_num_map(ddp_counter_template_rec.rollover_first_reading);
    p4_a16 := rosetta_g_miss_num_map(ddp_counter_template_rec.usage_item_id);
    p4_a17 := rosetta_g_miss_num_map(ddp_counter_template_rec.ctr_val_max_seq_no);
    p4_a18 := ddp_counter_template_rec.start_date_active;
    p4_a19 := ddp_counter_template_rec.end_date_active;
    p4_a20 := rosetta_g_miss_num_map(ddp_counter_template_rec.object_version_number);
    p4_a21 := ddp_counter_template_rec.last_update_date;
    p4_a22 := rosetta_g_miss_num_map(ddp_counter_template_rec.last_updated_by);
    p4_a23 := ddp_counter_template_rec.creation_date;
    p4_a24 := rosetta_g_miss_num_map(ddp_counter_template_rec.created_by);
    p4_a25 := rosetta_g_miss_num_map(ddp_counter_template_rec.last_update_login);
    p4_a26 := ddp_counter_template_rec.attribute1;
    p4_a27 := ddp_counter_template_rec.attribute2;
    p4_a28 := ddp_counter_template_rec.attribute3;
    p4_a29 := ddp_counter_template_rec.attribute4;
    p4_a30 := ddp_counter_template_rec.attribute5;
    p4_a31 := ddp_counter_template_rec.attribute6;
    p4_a32 := ddp_counter_template_rec.attribute7;
    p4_a33 := ddp_counter_template_rec.attribute8;
    p4_a34 := ddp_counter_template_rec.attribute9;
    p4_a35 := ddp_counter_template_rec.attribute10;
    p4_a36 := ddp_counter_template_rec.attribute11;
    p4_a37 := ddp_counter_template_rec.attribute12;
    p4_a38 := ddp_counter_template_rec.attribute13;
    p4_a39 := ddp_counter_template_rec.attribute14;
    p4_a40 := ddp_counter_template_rec.attribute15;
    p4_a41 := ddp_counter_template_rec.attribute16;
    p4_a42 := ddp_counter_template_rec.attribute17;
    p4_a43 := ddp_counter_template_rec.attribute18;
    p4_a44 := ddp_counter_template_rec.attribute19;
    p4_a45 := ddp_counter_template_rec.attribute20;
    p4_a46 := ddp_counter_template_rec.attribute21;
    p4_a47 := ddp_counter_template_rec.attribute22;
    p4_a48 := ddp_counter_template_rec.attribute23;
    p4_a49 := ddp_counter_template_rec.attribute24;
    p4_a50 := ddp_counter_template_rec.attribute25;
    p4_a51 := ddp_counter_template_rec.attribute26;
    p4_a52 := ddp_counter_template_rec.attribute27;
    p4_a53 := ddp_counter_template_rec.attribute28;
    p4_a54 := ddp_counter_template_rec.attribute29;
    p4_a55 := ddp_counter_template_rec.attribute30;
    p4_a56 := ddp_counter_template_rec.attribute_category;
    p4_a57 := ddp_counter_template_rec.migrated_flag;
    p4_a58 := ddp_counter_template_rec.customer_view;
    p4_a59 := ddp_counter_template_rec.direction;
    p4_a60 := ddp_counter_template_rec.filter_type;
    p4_a61 := rosetta_g_miss_num_map(ddp_counter_template_rec.filter_reading_count);
    p4_a62 := ddp_counter_template_rec.filter_time_uom;
    p4_a63 := rosetta_g_miss_num_map(ddp_counter_template_rec.estimation_id);
    p4_a64 := rosetta_g_miss_num_map(ddp_counter_template_rec.reading_type);
    p4_a65 := ddp_counter_template_rec.automatic_rollover;
    p4_a66 := rosetta_g_miss_num_map(ddp_counter_template_rec.default_usage_rate);
    p4_a67 := rosetta_g_miss_num_map(ddp_counter_template_rec.use_past_reading);
    p4_a68 := ddp_counter_template_rec.used_in_scheduling;
    p4_a69 := rosetta_g_miss_num_map(ddp_counter_template_rec.defaulted_group_id);
    p4_a70 := rosetta_g_miss_num_map(ddp_counter_template_rec.security_group_id);
    p4_a71 := ddp_counter_template_rec.name;
    p4_a72 := ddp_counter_template_rec.description;
    p4_a73 := ddp_counter_template_rec.comments;
    p4_a74 := ddp_counter_template_rec.association_type;
    p4_a75 := rosetta_g_miss_num_map(ddp_counter_template_rec.step_value);
    p4_a76 := ddp_counter_template_rec.time_based_manual_entry;
    p4_a77 := ddp_counter_template_rec.eam_required_flag;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p12(ddp_ctr_property_template_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p10(ddp_counter_relationships_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p16(ddp_ctr_derived_filters_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      );



  end;

  procedure create_ctr_property_template(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  DATE
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  DATE
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_property_template_rec csi_ctr_datastructures_pub.ctr_property_template_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_property_template_rec.counter_property_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_property_template_rec.counter_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_property_template_rec.property_data_type := p4_a2;
    ddp_ctr_property_template_rec.is_nullable := p4_a3;
    ddp_ctr_property_template_rec.default_value := p4_a4;
    ddp_ctr_property_template_rec.minimum_value := p4_a5;
    ddp_ctr_property_template_rec.maximum_value := p4_a6;
    ddp_ctr_property_template_rec.uom_code := p4_a7;
    ddp_ctr_property_template_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a8);
    ddp_ctr_property_template_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_ctr_property_template_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_ctr_property_template_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_ctr_property_template_rec.last_updated_by := rosetta_g_miss_num_map(p4_a12);
    ddp_ctr_property_template_rec.creation_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_ctr_property_template_rec.created_by := rosetta_g_miss_num_map(p4_a14);
    ddp_ctr_property_template_rec.last_update_login := rosetta_g_miss_num_map(p4_a15);
    ddp_ctr_property_template_rec.attribute1 := p4_a16;
    ddp_ctr_property_template_rec.attribute2 := p4_a17;
    ddp_ctr_property_template_rec.attribute3 := p4_a18;
    ddp_ctr_property_template_rec.attribute4 := p4_a19;
    ddp_ctr_property_template_rec.attribute5 := p4_a20;
    ddp_ctr_property_template_rec.attribute6 := p4_a21;
    ddp_ctr_property_template_rec.attribute7 := p4_a22;
    ddp_ctr_property_template_rec.attribute8 := p4_a23;
    ddp_ctr_property_template_rec.attribute9 := p4_a24;
    ddp_ctr_property_template_rec.attribute10 := p4_a25;
    ddp_ctr_property_template_rec.attribute11 := p4_a26;
    ddp_ctr_property_template_rec.attribute12 := p4_a27;
    ddp_ctr_property_template_rec.attribute13 := p4_a28;
    ddp_ctr_property_template_rec.attribute14 := p4_a29;
    ddp_ctr_property_template_rec.attribute15 := p4_a30;
    ddp_ctr_property_template_rec.attribute_category := p4_a31;
    ddp_ctr_property_template_rec.migrated_flag := p4_a32;
    ddp_ctr_property_template_rec.property_lov_type := p4_a33;
    ddp_ctr_property_template_rec.security_group_id := rosetta_g_miss_num_map(p4_a34);
    ddp_ctr_property_template_rec.name := p4_a35;
    ddp_ctr_property_template_rec.description := p4_a36;




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_ctr_property_template(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_property_template_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.counter_property_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.counter_id);
    p4_a2 := ddp_ctr_property_template_rec.property_data_type;
    p4_a3 := ddp_ctr_property_template_rec.is_nullable;
    p4_a4 := ddp_ctr_property_template_rec.default_value;
    p4_a5 := ddp_ctr_property_template_rec.minimum_value;
    p4_a6 := ddp_ctr_property_template_rec.maximum_value;
    p4_a7 := ddp_ctr_property_template_rec.uom_code;
    p4_a8 := ddp_ctr_property_template_rec.start_date_active;
    p4_a9 := ddp_ctr_property_template_rec.end_date_active;
    p4_a10 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.object_version_number);
    p4_a11 := ddp_ctr_property_template_rec.last_update_date;
    p4_a12 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.last_updated_by);
    p4_a13 := ddp_ctr_property_template_rec.creation_date;
    p4_a14 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.created_by);
    p4_a15 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.last_update_login);
    p4_a16 := ddp_ctr_property_template_rec.attribute1;
    p4_a17 := ddp_ctr_property_template_rec.attribute2;
    p4_a18 := ddp_ctr_property_template_rec.attribute3;
    p4_a19 := ddp_ctr_property_template_rec.attribute4;
    p4_a20 := ddp_ctr_property_template_rec.attribute5;
    p4_a21 := ddp_ctr_property_template_rec.attribute6;
    p4_a22 := ddp_ctr_property_template_rec.attribute7;
    p4_a23 := ddp_ctr_property_template_rec.attribute8;
    p4_a24 := ddp_ctr_property_template_rec.attribute9;
    p4_a25 := ddp_ctr_property_template_rec.attribute10;
    p4_a26 := ddp_ctr_property_template_rec.attribute11;
    p4_a27 := ddp_ctr_property_template_rec.attribute12;
    p4_a28 := ddp_ctr_property_template_rec.attribute13;
    p4_a29 := ddp_ctr_property_template_rec.attribute14;
    p4_a30 := ddp_ctr_property_template_rec.attribute15;
    p4_a31 := ddp_ctr_property_template_rec.attribute_category;
    p4_a32 := ddp_ctr_property_template_rec.migrated_flag;
    p4_a33 := ddp_ctr_property_template_rec.property_lov_type;
    p4_a34 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.security_group_id);
    p4_a35 := ddp_ctr_property_template_rec.name;
    p4_a36 := ddp_ctr_property_template_rec.description;



  end;

  procedure create_counter_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_relationships_rec csi_ctr_datastructures_pub.counter_relationships_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_relationships_rec.relationship_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_relationships_rec.ctr_association_id := rosetta_g_miss_num_map(p4_a1);
    ddp_counter_relationships_rec.relationship_type_code := p4_a2;
    ddp_counter_relationships_rec.source_counter_id := rosetta_g_miss_num_map(p4_a3);
    ddp_counter_relationships_rec.object_counter_id := rosetta_g_miss_num_map(p4_a4);
    ddp_counter_relationships_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_counter_relationships_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_counter_relationships_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_counter_relationships_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_counter_relationships_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_counter_relationships_rec.creation_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_counter_relationships_rec.created_by := rosetta_g_miss_num_map(p4_a11);
    ddp_counter_relationships_rec.last_update_login := rosetta_g_miss_num_map(p4_a12);
    ddp_counter_relationships_rec.attribute_category := p4_a13;
    ddp_counter_relationships_rec.attribute1 := p4_a14;
    ddp_counter_relationships_rec.attribute2 := p4_a15;
    ddp_counter_relationships_rec.attribute3 := p4_a16;
    ddp_counter_relationships_rec.attribute4 := p4_a17;
    ddp_counter_relationships_rec.attribute5 := p4_a18;
    ddp_counter_relationships_rec.attribute6 := p4_a19;
    ddp_counter_relationships_rec.attribute7 := p4_a20;
    ddp_counter_relationships_rec.attribute8 := p4_a21;
    ddp_counter_relationships_rec.attribute9 := p4_a22;
    ddp_counter_relationships_rec.attribute10 := p4_a23;
    ddp_counter_relationships_rec.attribute11 := p4_a24;
    ddp_counter_relationships_rec.attribute12 := p4_a25;
    ddp_counter_relationships_rec.attribute13 := p4_a26;
    ddp_counter_relationships_rec.attribute14 := p4_a27;
    ddp_counter_relationships_rec.attribute15 := p4_a28;
    ddp_counter_relationships_rec.security_group_id := rosetta_g_miss_num_map(p4_a29);
    ddp_counter_relationships_rec.migrated_flag := p4_a30;
    ddp_counter_relationships_rec.bind_variable_name := p4_a31;
    ddp_counter_relationships_rec.factor := rosetta_g_miss_num_map(p4_a32);




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_counter_relationship(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_relationships_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.relationship_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.ctr_association_id);
    p4_a2 := ddp_counter_relationships_rec.relationship_type_code;
    p4_a3 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.source_counter_id);
    p4_a4 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.object_counter_id);
    p4_a5 := ddp_counter_relationships_rec.active_start_date;
    p4_a6 := ddp_counter_relationships_rec.active_end_date;
    p4_a7 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.object_version_number);
    p4_a8 := ddp_counter_relationships_rec.last_update_date;
    p4_a9 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.last_updated_by);
    p4_a10 := ddp_counter_relationships_rec.creation_date;
    p4_a11 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.created_by);
    p4_a12 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.last_update_login);
    p4_a13 := ddp_counter_relationships_rec.attribute_category;
    p4_a14 := ddp_counter_relationships_rec.attribute1;
    p4_a15 := ddp_counter_relationships_rec.attribute2;
    p4_a16 := ddp_counter_relationships_rec.attribute3;
    p4_a17 := ddp_counter_relationships_rec.attribute4;
    p4_a18 := ddp_counter_relationships_rec.attribute5;
    p4_a19 := ddp_counter_relationships_rec.attribute6;
    p4_a20 := ddp_counter_relationships_rec.attribute7;
    p4_a21 := ddp_counter_relationships_rec.attribute8;
    p4_a22 := ddp_counter_relationships_rec.attribute9;
    p4_a23 := ddp_counter_relationships_rec.attribute10;
    p4_a24 := ddp_counter_relationships_rec.attribute11;
    p4_a25 := ddp_counter_relationships_rec.attribute12;
    p4_a26 := ddp_counter_relationships_rec.attribute13;
    p4_a27 := ddp_counter_relationships_rec.attribute14;
    p4_a28 := ddp_counter_relationships_rec.attribute15;
    p4_a29 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.security_group_id);
    p4_a30 := ddp_counter_relationships_rec.migrated_flag;
    p4_a31 := ddp_counter_relationships_rec.bind_variable_name;
    p4_a32 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.factor);



  end;

  procedure create_derived_filters(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_DATE_TABLE
    , p4_a10 in out nocopy JTF_DATE_TABLE
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_DATE_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_DATE_TABLE
    , p4_a15 in out nocopy JTF_NUMBER_TABLE
    , p4_a16 in out nocopy JTF_NUMBER_TABLE
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a33 in out nocopy JTF_NUMBER_TABLE
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_derived_filters_tbl csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p16(ddp_ctr_derived_filters_tbl, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_derived_filters(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_derived_filters_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p16(ddp_ctr_derived_filters_tbl, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      );



  end;

  procedure update_counter_group(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_NUMBER_TABLE
    , p5_a28 in out nocopy JTF_DATE_TABLE
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_groups_rec csi_ctr_datastructures_pub.counter_groups_rec;
    ddp_ctr_item_associations_tbl csi_ctr_datastructures_pub.ctr_item_associations_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_groups_rec.counter_group_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_groups_rec.name := p4_a1;
    ddp_counter_groups_rec.description := p4_a2;
    ddp_counter_groups_rec.template_flag := p4_a3;
    ddp_counter_groups_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_counter_groups_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_counter_groups_rec.creation_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_counter_groups_rec.created_by := rosetta_g_miss_num_map(p4_a7);
    ddp_counter_groups_rec.last_update_login := rosetta_g_miss_num_map(p4_a8);
    ddp_counter_groups_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_counter_groups_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a10);
    ddp_counter_groups_rec.attribute1 := p4_a11;
    ddp_counter_groups_rec.attribute2 := p4_a12;
    ddp_counter_groups_rec.attribute3 := p4_a13;
    ddp_counter_groups_rec.attribute4 := p4_a14;
    ddp_counter_groups_rec.attribute5 := p4_a15;
    ddp_counter_groups_rec.attribute6 := p4_a16;
    ddp_counter_groups_rec.attribute7 := p4_a17;
    ddp_counter_groups_rec.attribute8 := p4_a18;
    ddp_counter_groups_rec.attribute9 := p4_a19;
    ddp_counter_groups_rec.attribute10 := p4_a20;
    ddp_counter_groups_rec.attribute11 := p4_a21;
    ddp_counter_groups_rec.attribute12 := p4_a22;
    ddp_counter_groups_rec.attribute13 := p4_a23;
    ddp_counter_groups_rec.attribute14 := p4_a24;
    ddp_counter_groups_rec.attribute15 := p4_a25;
    ddp_counter_groups_rec.context := p4_a26;
    ddp_counter_groups_rec.object_version_number := rosetta_g_miss_num_map(p4_a27);
    ddp_counter_groups_rec.created_from_ctr_grp_tmpl_id := rosetta_g_miss_num_map(p4_a28);
    ddp_counter_groups_rec.association_type := p4_a29;
    ddp_counter_groups_rec.source_object_code := p4_a30;
    ddp_counter_groups_rec.source_object_id := rosetta_g_miss_num_map(p4_a31);
    ddp_counter_groups_rec.source_counter_group_id := rosetta_g_miss_num_map(p4_a32);
    ddp_counter_groups_rec.security_group_id := rosetta_g_miss_num_map(p4_a33);
    ddp_counter_groups_rec.upgraded_status_flag := p4_a34;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_counter_group(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_groups_rec,
      ddp_ctr_item_associations_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_groups_rec.counter_group_id);
    p4_a1 := ddp_counter_groups_rec.name;
    p4_a2 := ddp_counter_groups_rec.description;
    p4_a3 := ddp_counter_groups_rec.template_flag;
    p4_a4 := ddp_counter_groups_rec.last_update_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_counter_groups_rec.last_updated_by);
    p4_a6 := ddp_counter_groups_rec.creation_date;
    p4_a7 := rosetta_g_miss_num_map(ddp_counter_groups_rec.created_by);
    p4_a8 := rosetta_g_miss_num_map(ddp_counter_groups_rec.last_update_login);
    p4_a9 := ddp_counter_groups_rec.start_date_active;
    p4_a10 := ddp_counter_groups_rec.end_date_active;
    p4_a11 := ddp_counter_groups_rec.attribute1;
    p4_a12 := ddp_counter_groups_rec.attribute2;
    p4_a13 := ddp_counter_groups_rec.attribute3;
    p4_a14 := ddp_counter_groups_rec.attribute4;
    p4_a15 := ddp_counter_groups_rec.attribute5;
    p4_a16 := ddp_counter_groups_rec.attribute6;
    p4_a17 := ddp_counter_groups_rec.attribute7;
    p4_a18 := ddp_counter_groups_rec.attribute8;
    p4_a19 := ddp_counter_groups_rec.attribute9;
    p4_a20 := ddp_counter_groups_rec.attribute10;
    p4_a21 := ddp_counter_groups_rec.attribute11;
    p4_a22 := ddp_counter_groups_rec.attribute12;
    p4_a23 := ddp_counter_groups_rec.attribute13;
    p4_a24 := ddp_counter_groups_rec.attribute14;
    p4_a25 := ddp_counter_groups_rec.attribute15;
    p4_a26 := ddp_counter_groups_rec.context;
    p4_a27 := rosetta_g_miss_num_map(ddp_counter_groups_rec.object_version_number);
    p4_a28 := rosetta_g_miss_num_map(ddp_counter_groups_rec.created_from_ctr_grp_tmpl_id);
    p4_a29 := ddp_counter_groups_rec.association_type;
    p4_a30 := ddp_counter_groups_rec.source_object_code;
    p4_a31 := rosetta_g_miss_num_map(ddp_counter_groups_rec.source_object_id);
    p4_a32 := rosetta_g_miss_num_map(ddp_counter_groups_rec.source_counter_group_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_counter_groups_rec.security_group_id);
    p4_a34 := ddp_counter_groups_rec.upgraded_status_flag;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );



  end;

  procedure update_item_association(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  DATE
    , p4_a29 in out nocopy  DATE
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_item_associations_rec csi_ctr_datastructures_pub.ctr_item_associations_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_item_associations_rec.ctr_association_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_item_associations_rec.group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_item_associations_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a2);
    ddp_ctr_item_associations_rec.object_version_number := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_item_associations_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_ctr_item_associations_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_ctr_item_associations_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_ctr_item_associations_rec.creation_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_ctr_item_associations_rec.created_by := rosetta_g_miss_num_map(p4_a8);
    ddp_ctr_item_associations_rec.attribute1 := p4_a9;
    ddp_ctr_item_associations_rec.attribute2 := p4_a10;
    ddp_ctr_item_associations_rec.attribute3 := p4_a11;
    ddp_ctr_item_associations_rec.attribute4 := p4_a12;
    ddp_ctr_item_associations_rec.attribute5 := p4_a13;
    ddp_ctr_item_associations_rec.attribute6 := p4_a14;
    ddp_ctr_item_associations_rec.attribute7 := p4_a15;
    ddp_ctr_item_associations_rec.attribute8 := p4_a16;
    ddp_ctr_item_associations_rec.attribute9 := p4_a17;
    ddp_ctr_item_associations_rec.attribute10 := p4_a18;
    ddp_ctr_item_associations_rec.attribute11 := p4_a19;
    ddp_ctr_item_associations_rec.attribute12 := p4_a20;
    ddp_ctr_item_associations_rec.attribute13 := p4_a21;
    ddp_ctr_item_associations_rec.attribute14 := p4_a22;
    ddp_ctr_item_associations_rec.attribute15 := p4_a23;
    ddp_ctr_item_associations_rec.attribute_category := p4_a24;
    ddp_ctr_item_associations_rec.security_group_id := rosetta_g_miss_num_map(p4_a25);
    ddp_ctr_item_associations_rec.migrated_flag := p4_a26;
    ddp_ctr_item_associations_rec.counter_id := rosetta_g_miss_num_map(p4_a27);
    ddp_ctr_item_associations_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a28);
    ddp_ctr_item_associations_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a29);
    ddp_ctr_item_associations_rec.usage_rate := rosetta_g_miss_num_map(p4_a30);
    ddp_ctr_item_associations_rec.use_past_reading := rosetta_g_miss_num_map(p4_a31);
    ddp_ctr_item_associations_rec.associated_to_group := p4_a32;
    ddp_ctr_item_associations_rec.maint_organization_id := rosetta_g_miss_num_map(p4_a33);
    ddp_ctr_item_associations_rec.primary_failure_flag := p4_a34;




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_item_association(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_item_associations_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.ctr_association_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.group_id);
    p4_a2 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.inventory_item_id);
    p4_a3 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.object_version_number);
    p4_a4 := ddp_ctr_item_associations_rec.last_update_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.last_updated_by);
    p4_a6 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.last_update_login);
    p4_a7 := ddp_ctr_item_associations_rec.creation_date;
    p4_a8 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.created_by);
    p4_a9 := ddp_ctr_item_associations_rec.attribute1;
    p4_a10 := ddp_ctr_item_associations_rec.attribute2;
    p4_a11 := ddp_ctr_item_associations_rec.attribute3;
    p4_a12 := ddp_ctr_item_associations_rec.attribute4;
    p4_a13 := ddp_ctr_item_associations_rec.attribute5;
    p4_a14 := ddp_ctr_item_associations_rec.attribute6;
    p4_a15 := ddp_ctr_item_associations_rec.attribute7;
    p4_a16 := ddp_ctr_item_associations_rec.attribute8;
    p4_a17 := ddp_ctr_item_associations_rec.attribute9;
    p4_a18 := ddp_ctr_item_associations_rec.attribute10;
    p4_a19 := ddp_ctr_item_associations_rec.attribute11;
    p4_a20 := ddp_ctr_item_associations_rec.attribute12;
    p4_a21 := ddp_ctr_item_associations_rec.attribute13;
    p4_a22 := ddp_ctr_item_associations_rec.attribute14;
    p4_a23 := ddp_ctr_item_associations_rec.attribute15;
    p4_a24 := ddp_ctr_item_associations_rec.attribute_category;
    p4_a25 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.security_group_id);
    p4_a26 := ddp_ctr_item_associations_rec.migrated_flag;
    p4_a27 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.counter_id);
    p4_a28 := ddp_ctr_item_associations_rec.start_date_active;
    p4_a29 := ddp_ctr_item_associations_rec.end_date_active;
    p4_a30 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.usage_rate);
    p4_a31 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.use_past_reading);
    p4_a32 := ddp_ctr_item_associations_rec.associated_to_group;
    p4_a33 := rosetta_g_miss_num_map(ddp_ctr_item_associations_rec.maint_organization_id);
    p4_a34 := ddp_ctr_item_associations_rec.primary_failure_flag;



  end;

  procedure update_counter_template(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  NUMBER
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  DATE
    , p4_a19 in out nocopy  DATE
    , p4_a20 in out nocopy  NUMBER
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  NUMBER
    , p4_a23 in out nocopy  DATE
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  VARCHAR2
    , p4_a40 in out nocopy  VARCHAR2
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  NUMBER
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  NUMBER
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  VARCHAR2
    , p4_a66 in out nocopy  NUMBER
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  NUMBER
    , p4_a70 in out nocopy  NUMBER
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  VARCHAR2
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  VARCHAR2
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  VARCHAR2
    , p4_a77 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_NUMBER_TABLE
    , p5_a28 in out nocopy JTF_DATE_TABLE
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_DATE_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_DATE_TABLE
    , p6_a12 in out nocopy JTF_NUMBER_TABLE
    , p6_a13 in out nocopy JTF_DATE_TABLE
    , p6_a14 in out nocopy JTF_NUMBER_TABLE
    , p6_a15 in out nocopy JTF_NUMBER_TABLE
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 in out nocopy JTF_NUMBER_TABLE
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_DATE_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_DATE_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_NUMBER_TABLE
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_DATE_TABLE
    , p8_a11 in out nocopy JTF_NUMBER_TABLE
    , p8_a12 in out nocopy JTF_DATE_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_DATE_TABLE
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_NUMBER_TABLE
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a33 in out nocopy JTF_NUMBER_TABLE
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_template_rec csi_ctr_datastructures_pub.counter_template_rec;
    ddp_ctr_item_associations_tbl csi_ctr_datastructures_pub.ctr_item_associations_tbl;
    ddp_ctr_property_template_tbl csi_ctr_datastructures_pub.ctr_property_template_tbl;
    ddp_counter_relationships_tbl csi_ctr_datastructures_pub.counter_relationships_tbl;
    ddp_ctr_derived_filters_tbl csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_template_rec.counter_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_template_rec.group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_counter_template_rec.counter_type := p4_a2;
    ddp_counter_template_rec.initial_reading := rosetta_g_miss_num_map(p4_a3);
    ddp_counter_template_rec.initial_reading_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_counter_template_rec.tolerance_plus := rosetta_g_miss_num_map(p4_a5);
    ddp_counter_template_rec.tolerance_minus := rosetta_g_miss_num_map(p4_a6);
    ddp_counter_template_rec.uom_code := p4_a7;
    ddp_counter_template_rec.derive_counter_id := rosetta_g_miss_num_map(p4_a8);
    ddp_counter_template_rec.derive_function := p4_a9;
    ddp_counter_template_rec.derive_property_id := rosetta_g_miss_num_map(p4_a10);
    ddp_counter_template_rec.valid_flag := p4_a11;
    ddp_counter_template_rec.formula_incomplete_flag := p4_a12;
    ddp_counter_template_rec.formula_text := p4_a13;
    ddp_counter_template_rec.rollover_last_reading := rosetta_g_miss_num_map(p4_a14);
    ddp_counter_template_rec.rollover_first_reading := rosetta_g_miss_num_map(p4_a15);
    ddp_counter_template_rec.usage_item_id := rosetta_g_miss_num_map(p4_a16);
    ddp_counter_template_rec.ctr_val_max_seq_no := rosetta_g_miss_num_map(p4_a17);
    ddp_counter_template_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a18);
    ddp_counter_template_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a19);
    ddp_counter_template_rec.object_version_number := rosetta_g_miss_num_map(p4_a20);
    ddp_counter_template_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_counter_template_rec.last_updated_by := rosetta_g_miss_num_map(p4_a22);
    ddp_counter_template_rec.creation_date := rosetta_g_miss_date_in_map(p4_a23);
    ddp_counter_template_rec.created_by := rosetta_g_miss_num_map(p4_a24);
    ddp_counter_template_rec.last_update_login := rosetta_g_miss_num_map(p4_a25);
    ddp_counter_template_rec.attribute1 := p4_a26;
    ddp_counter_template_rec.attribute2 := p4_a27;
    ddp_counter_template_rec.attribute3 := p4_a28;
    ddp_counter_template_rec.attribute4 := p4_a29;
    ddp_counter_template_rec.attribute5 := p4_a30;
    ddp_counter_template_rec.attribute6 := p4_a31;
    ddp_counter_template_rec.attribute7 := p4_a32;
    ddp_counter_template_rec.attribute8 := p4_a33;
    ddp_counter_template_rec.attribute9 := p4_a34;
    ddp_counter_template_rec.attribute10 := p4_a35;
    ddp_counter_template_rec.attribute11 := p4_a36;
    ddp_counter_template_rec.attribute12 := p4_a37;
    ddp_counter_template_rec.attribute13 := p4_a38;
    ddp_counter_template_rec.attribute14 := p4_a39;
    ddp_counter_template_rec.attribute15 := p4_a40;
    ddp_counter_template_rec.attribute16 := p4_a41;
    ddp_counter_template_rec.attribute17 := p4_a42;
    ddp_counter_template_rec.attribute18 := p4_a43;
    ddp_counter_template_rec.attribute19 := p4_a44;
    ddp_counter_template_rec.attribute20 := p4_a45;
    ddp_counter_template_rec.attribute21 := p4_a46;
    ddp_counter_template_rec.attribute22 := p4_a47;
    ddp_counter_template_rec.attribute23 := p4_a48;
    ddp_counter_template_rec.attribute24 := p4_a49;
    ddp_counter_template_rec.attribute25 := p4_a50;
    ddp_counter_template_rec.attribute26 := p4_a51;
    ddp_counter_template_rec.attribute27 := p4_a52;
    ddp_counter_template_rec.attribute28 := p4_a53;
    ddp_counter_template_rec.attribute29 := p4_a54;
    ddp_counter_template_rec.attribute30 := p4_a55;
    ddp_counter_template_rec.attribute_category := p4_a56;
    ddp_counter_template_rec.migrated_flag := p4_a57;
    ddp_counter_template_rec.customer_view := p4_a58;
    ddp_counter_template_rec.direction := p4_a59;
    ddp_counter_template_rec.filter_type := p4_a60;
    ddp_counter_template_rec.filter_reading_count := rosetta_g_miss_num_map(p4_a61);
    ddp_counter_template_rec.filter_time_uom := p4_a62;
    ddp_counter_template_rec.estimation_id := rosetta_g_miss_num_map(p4_a63);
    ddp_counter_template_rec.reading_type := rosetta_g_miss_num_map(p4_a64);
    ddp_counter_template_rec.automatic_rollover := p4_a65;
    ddp_counter_template_rec.default_usage_rate := rosetta_g_miss_num_map(p4_a66);
    ddp_counter_template_rec.use_past_reading := rosetta_g_miss_num_map(p4_a67);
    ddp_counter_template_rec.used_in_scheduling := p4_a68;
    ddp_counter_template_rec.defaulted_group_id := rosetta_g_miss_num_map(p4_a69);
    ddp_counter_template_rec.security_group_id := rosetta_g_miss_num_map(p4_a70);
    ddp_counter_template_rec.name := p4_a71;
    ddp_counter_template_rec.description := p4_a72;
    ddp_counter_template_rec.comments := p4_a73;
    ddp_counter_template_rec.association_type := p4_a74;
    ddp_counter_template_rec.step_value := rosetta_g_miss_num_map(p4_a75);
    ddp_counter_template_rec.time_based_manual_entry := p4_a76;
    ddp_counter_template_rec.eam_required_flag := p4_a77;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p12(ddp_ctr_property_template_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p10(ddp_counter_relationships_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p16(ddp_ctr_derived_filters_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_counter_template(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_template_rec,
      ddp_ctr_item_associations_tbl,
      ddp_ctr_property_template_tbl,
      ddp_counter_relationships_tbl,
      ddp_ctr_derived_filters_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_template_rec.counter_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_counter_template_rec.group_id);
    p4_a2 := ddp_counter_template_rec.counter_type;
    p4_a3 := rosetta_g_miss_num_map(ddp_counter_template_rec.initial_reading);
    p4_a4 := ddp_counter_template_rec.initial_reading_date;
    p4_a5 := rosetta_g_miss_num_map(ddp_counter_template_rec.tolerance_plus);
    p4_a6 := rosetta_g_miss_num_map(ddp_counter_template_rec.tolerance_minus);
    p4_a7 := ddp_counter_template_rec.uom_code;
    p4_a8 := rosetta_g_miss_num_map(ddp_counter_template_rec.derive_counter_id);
    p4_a9 := ddp_counter_template_rec.derive_function;
    p4_a10 := rosetta_g_miss_num_map(ddp_counter_template_rec.derive_property_id);
    p4_a11 := ddp_counter_template_rec.valid_flag;
    p4_a12 := ddp_counter_template_rec.formula_incomplete_flag;
    p4_a13 := ddp_counter_template_rec.formula_text;
    p4_a14 := rosetta_g_miss_num_map(ddp_counter_template_rec.rollover_last_reading);
    p4_a15 := rosetta_g_miss_num_map(ddp_counter_template_rec.rollover_first_reading);
    p4_a16 := rosetta_g_miss_num_map(ddp_counter_template_rec.usage_item_id);
    p4_a17 := rosetta_g_miss_num_map(ddp_counter_template_rec.ctr_val_max_seq_no);
    p4_a18 := ddp_counter_template_rec.start_date_active;
    p4_a19 := ddp_counter_template_rec.end_date_active;
    p4_a20 := rosetta_g_miss_num_map(ddp_counter_template_rec.object_version_number);
    p4_a21 := ddp_counter_template_rec.last_update_date;
    p4_a22 := rosetta_g_miss_num_map(ddp_counter_template_rec.last_updated_by);
    p4_a23 := ddp_counter_template_rec.creation_date;
    p4_a24 := rosetta_g_miss_num_map(ddp_counter_template_rec.created_by);
    p4_a25 := rosetta_g_miss_num_map(ddp_counter_template_rec.last_update_login);
    p4_a26 := ddp_counter_template_rec.attribute1;
    p4_a27 := ddp_counter_template_rec.attribute2;
    p4_a28 := ddp_counter_template_rec.attribute3;
    p4_a29 := ddp_counter_template_rec.attribute4;
    p4_a30 := ddp_counter_template_rec.attribute5;
    p4_a31 := ddp_counter_template_rec.attribute6;
    p4_a32 := ddp_counter_template_rec.attribute7;
    p4_a33 := ddp_counter_template_rec.attribute8;
    p4_a34 := ddp_counter_template_rec.attribute9;
    p4_a35 := ddp_counter_template_rec.attribute10;
    p4_a36 := ddp_counter_template_rec.attribute11;
    p4_a37 := ddp_counter_template_rec.attribute12;
    p4_a38 := ddp_counter_template_rec.attribute13;
    p4_a39 := ddp_counter_template_rec.attribute14;
    p4_a40 := ddp_counter_template_rec.attribute15;
    p4_a41 := ddp_counter_template_rec.attribute16;
    p4_a42 := ddp_counter_template_rec.attribute17;
    p4_a43 := ddp_counter_template_rec.attribute18;
    p4_a44 := ddp_counter_template_rec.attribute19;
    p4_a45 := ddp_counter_template_rec.attribute20;
    p4_a46 := ddp_counter_template_rec.attribute21;
    p4_a47 := ddp_counter_template_rec.attribute22;
    p4_a48 := ddp_counter_template_rec.attribute23;
    p4_a49 := ddp_counter_template_rec.attribute24;
    p4_a50 := ddp_counter_template_rec.attribute25;
    p4_a51 := ddp_counter_template_rec.attribute26;
    p4_a52 := ddp_counter_template_rec.attribute27;
    p4_a53 := ddp_counter_template_rec.attribute28;
    p4_a54 := ddp_counter_template_rec.attribute29;
    p4_a55 := ddp_counter_template_rec.attribute30;
    p4_a56 := ddp_counter_template_rec.attribute_category;
    p4_a57 := ddp_counter_template_rec.migrated_flag;
    p4_a58 := ddp_counter_template_rec.customer_view;
    p4_a59 := ddp_counter_template_rec.direction;
    p4_a60 := ddp_counter_template_rec.filter_type;
    p4_a61 := rosetta_g_miss_num_map(ddp_counter_template_rec.filter_reading_count);
    p4_a62 := ddp_counter_template_rec.filter_time_uom;
    p4_a63 := rosetta_g_miss_num_map(ddp_counter_template_rec.estimation_id);
    p4_a64 := rosetta_g_miss_num_map(ddp_counter_template_rec.reading_type);
    p4_a65 := ddp_counter_template_rec.automatic_rollover;
    p4_a66 := rosetta_g_miss_num_map(ddp_counter_template_rec.default_usage_rate);
    p4_a67 := rosetta_g_miss_num_map(ddp_counter_template_rec.use_past_reading);
    p4_a68 := ddp_counter_template_rec.used_in_scheduling;
    p4_a69 := rosetta_g_miss_num_map(ddp_counter_template_rec.defaulted_group_id);
    p4_a70 := rosetta_g_miss_num_map(ddp_counter_template_rec.security_group_id);
    p4_a71 := ddp_counter_template_rec.name;
    p4_a72 := ddp_counter_template_rec.description;
    p4_a73 := ddp_counter_template_rec.comments;
    p4_a74 := ddp_counter_template_rec.association_type;
    p4_a75 := rosetta_g_miss_num_map(ddp_counter_template_rec.step_value);
    p4_a76 := ddp_counter_template_rec.time_based_manual_entry;
    p4_a77 := ddp_counter_template_rec.eam_required_flag;

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p8(ddp_ctr_item_associations_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p12(ddp_ctr_property_template_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p10(ddp_counter_relationships_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p16(ddp_ctr_derived_filters_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      );



  end;

  procedure update_ctr_property_template(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  DATE
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  DATE
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_property_template_rec csi_ctr_datastructures_pub.ctr_property_template_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_property_template_rec.counter_property_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_property_template_rec.counter_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_property_template_rec.property_data_type := p4_a2;
    ddp_ctr_property_template_rec.is_nullable := p4_a3;
    ddp_ctr_property_template_rec.default_value := p4_a4;
    ddp_ctr_property_template_rec.minimum_value := p4_a5;
    ddp_ctr_property_template_rec.maximum_value := p4_a6;
    ddp_ctr_property_template_rec.uom_code := p4_a7;
    ddp_ctr_property_template_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a8);
    ddp_ctr_property_template_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_ctr_property_template_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_ctr_property_template_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_ctr_property_template_rec.last_updated_by := rosetta_g_miss_num_map(p4_a12);
    ddp_ctr_property_template_rec.creation_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_ctr_property_template_rec.created_by := rosetta_g_miss_num_map(p4_a14);
    ddp_ctr_property_template_rec.last_update_login := rosetta_g_miss_num_map(p4_a15);
    ddp_ctr_property_template_rec.attribute1 := p4_a16;
    ddp_ctr_property_template_rec.attribute2 := p4_a17;
    ddp_ctr_property_template_rec.attribute3 := p4_a18;
    ddp_ctr_property_template_rec.attribute4 := p4_a19;
    ddp_ctr_property_template_rec.attribute5 := p4_a20;
    ddp_ctr_property_template_rec.attribute6 := p4_a21;
    ddp_ctr_property_template_rec.attribute7 := p4_a22;
    ddp_ctr_property_template_rec.attribute8 := p4_a23;
    ddp_ctr_property_template_rec.attribute9 := p4_a24;
    ddp_ctr_property_template_rec.attribute10 := p4_a25;
    ddp_ctr_property_template_rec.attribute11 := p4_a26;
    ddp_ctr_property_template_rec.attribute12 := p4_a27;
    ddp_ctr_property_template_rec.attribute13 := p4_a28;
    ddp_ctr_property_template_rec.attribute14 := p4_a29;
    ddp_ctr_property_template_rec.attribute15 := p4_a30;
    ddp_ctr_property_template_rec.attribute_category := p4_a31;
    ddp_ctr_property_template_rec.migrated_flag := p4_a32;
    ddp_ctr_property_template_rec.property_lov_type := p4_a33;
    ddp_ctr_property_template_rec.security_group_id := rosetta_g_miss_num_map(p4_a34);
    ddp_ctr_property_template_rec.name := p4_a35;
    ddp_ctr_property_template_rec.description := p4_a36;




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_ctr_property_template(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_property_template_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.counter_property_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.counter_id);
    p4_a2 := ddp_ctr_property_template_rec.property_data_type;
    p4_a3 := ddp_ctr_property_template_rec.is_nullable;
    p4_a4 := ddp_ctr_property_template_rec.default_value;
    p4_a5 := ddp_ctr_property_template_rec.minimum_value;
    p4_a6 := ddp_ctr_property_template_rec.maximum_value;
    p4_a7 := ddp_ctr_property_template_rec.uom_code;
    p4_a8 := ddp_ctr_property_template_rec.start_date_active;
    p4_a9 := ddp_ctr_property_template_rec.end_date_active;
    p4_a10 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.object_version_number);
    p4_a11 := ddp_ctr_property_template_rec.last_update_date;
    p4_a12 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.last_updated_by);
    p4_a13 := ddp_ctr_property_template_rec.creation_date;
    p4_a14 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.created_by);
    p4_a15 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.last_update_login);
    p4_a16 := ddp_ctr_property_template_rec.attribute1;
    p4_a17 := ddp_ctr_property_template_rec.attribute2;
    p4_a18 := ddp_ctr_property_template_rec.attribute3;
    p4_a19 := ddp_ctr_property_template_rec.attribute4;
    p4_a20 := ddp_ctr_property_template_rec.attribute5;
    p4_a21 := ddp_ctr_property_template_rec.attribute6;
    p4_a22 := ddp_ctr_property_template_rec.attribute7;
    p4_a23 := ddp_ctr_property_template_rec.attribute8;
    p4_a24 := ddp_ctr_property_template_rec.attribute9;
    p4_a25 := ddp_ctr_property_template_rec.attribute10;
    p4_a26 := ddp_ctr_property_template_rec.attribute11;
    p4_a27 := ddp_ctr_property_template_rec.attribute12;
    p4_a28 := ddp_ctr_property_template_rec.attribute13;
    p4_a29 := ddp_ctr_property_template_rec.attribute14;
    p4_a30 := ddp_ctr_property_template_rec.attribute15;
    p4_a31 := ddp_ctr_property_template_rec.attribute_category;
    p4_a32 := ddp_ctr_property_template_rec.migrated_flag;
    p4_a33 := ddp_ctr_property_template_rec.property_lov_type;
    p4_a34 := rosetta_g_miss_num_map(ddp_ctr_property_template_rec.security_group_id);
    p4_a35 := ddp_ctr_property_template_rec.name;
    p4_a36 := ddp_ctr_property_template_rec.description;



  end;

  procedure update_counter_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_counter_relationships_rec csi_ctr_datastructures_pub.counter_relationships_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_counter_relationships_rec.relationship_id := rosetta_g_miss_num_map(p4_a0);
    ddp_counter_relationships_rec.ctr_association_id := rosetta_g_miss_num_map(p4_a1);
    ddp_counter_relationships_rec.relationship_type_code := p4_a2;
    ddp_counter_relationships_rec.source_counter_id := rosetta_g_miss_num_map(p4_a3);
    ddp_counter_relationships_rec.object_counter_id := rosetta_g_miss_num_map(p4_a4);
    ddp_counter_relationships_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_counter_relationships_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_counter_relationships_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_counter_relationships_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_counter_relationships_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_counter_relationships_rec.creation_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_counter_relationships_rec.created_by := rosetta_g_miss_num_map(p4_a11);
    ddp_counter_relationships_rec.last_update_login := rosetta_g_miss_num_map(p4_a12);
    ddp_counter_relationships_rec.attribute_category := p4_a13;
    ddp_counter_relationships_rec.attribute1 := p4_a14;
    ddp_counter_relationships_rec.attribute2 := p4_a15;
    ddp_counter_relationships_rec.attribute3 := p4_a16;
    ddp_counter_relationships_rec.attribute4 := p4_a17;
    ddp_counter_relationships_rec.attribute5 := p4_a18;
    ddp_counter_relationships_rec.attribute6 := p4_a19;
    ddp_counter_relationships_rec.attribute7 := p4_a20;
    ddp_counter_relationships_rec.attribute8 := p4_a21;
    ddp_counter_relationships_rec.attribute9 := p4_a22;
    ddp_counter_relationships_rec.attribute10 := p4_a23;
    ddp_counter_relationships_rec.attribute11 := p4_a24;
    ddp_counter_relationships_rec.attribute12 := p4_a25;
    ddp_counter_relationships_rec.attribute13 := p4_a26;
    ddp_counter_relationships_rec.attribute14 := p4_a27;
    ddp_counter_relationships_rec.attribute15 := p4_a28;
    ddp_counter_relationships_rec.security_group_id := rosetta_g_miss_num_map(p4_a29);
    ddp_counter_relationships_rec.migrated_flag := p4_a30;
    ddp_counter_relationships_rec.bind_variable_name := p4_a31;
    ddp_counter_relationships_rec.factor := rosetta_g_miss_num_map(p4_a32);




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_counter_relationship(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_counter_relationships_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.relationship_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.ctr_association_id);
    p4_a2 := ddp_counter_relationships_rec.relationship_type_code;
    p4_a3 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.source_counter_id);
    p4_a4 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.object_counter_id);
    p4_a5 := ddp_counter_relationships_rec.active_start_date;
    p4_a6 := ddp_counter_relationships_rec.active_end_date;
    p4_a7 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.object_version_number);
    p4_a8 := ddp_counter_relationships_rec.last_update_date;
    p4_a9 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.last_updated_by);
    p4_a10 := ddp_counter_relationships_rec.creation_date;
    p4_a11 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.created_by);
    p4_a12 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.last_update_login);
    p4_a13 := ddp_counter_relationships_rec.attribute_category;
    p4_a14 := ddp_counter_relationships_rec.attribute1;
    p4_a15 := ddp_counter_relationships_rec.attribute2;
    p4_a16 := ddp_counter_relationships_rec.attribute3;
    p4_a17 := ddp_counter_relationships_rec.attribute4;
    p4_a18 := ddp_counter_relationships_rec.attribute5;
    p4_a19 := ddp_counter_relationships_rec.attribute6;
    p4_a20 := ddp_counter_relationships_rec.attribute7;
    p4_a21 := ddp_counter_relationships_rec.attribute8;
    p4_a22 := ddp_counter_relationships_rec.attribute9;
    p4_a23 := ddp_counter_relationships_rec.attribute10;
    p4_a24 := ddp_counter_relationships_rec.attribute11;
    p4_a25 := ddp_counter_relationships_rec.attribute12;
    p4_a26 := ddp_counter_relationships_rec.attribute13;
    p4_a27 := ddp_counter_relationships_rec.attribute14;
    p4_a28 := ddp_counter_relationships_rec.attribute15;
    p4_a29 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.security_group_id);
    p4_a30 := ddp_counter_relationships_rec.migrated_flag;
    p4_a31 := ddp_counter_relationships_rec.bind_variable_name;
    p4_a32 := rosetta_g_miss_num_map(ddp_counter_relationships_rec.factor);



  end;

  procedure update_derived_filters(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_DATE_TABLE
    , p4_a10 in out nocopy JTF_DATE_TABLE
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_DATE_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_DATE_TABLE
    , p4_a15 in out nocopy JTF_NUMBER_TABLE
    , p4_a16 in out nocopy JTF_NUMBER_TABLE
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a33 in out nocopy JTF_NUMBER_TABLE
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_derived_filters_tbl csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p16(ddp_ctr_derived_filters_tbl, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_derived_filters(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_derived_filters_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p16(ddp_ctr_derived_filters_tbl, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      );



  end;

  procedure create_estimation_method(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  DATE
    , p7_a7 in out nocopy  DATE
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  DATE
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  NUMBER
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
  )

  as
    ddp_ctr_estimation_rec csi_ctr_datastructures_pub.ctr_estimation_methods_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ctr_estimation_rec.estimation_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ctr_estimation_rec.estimation_type := p7_a1;
    ddp_ctr_estimation_rec.fixed_value := rosetta_g_miss_num_map(p7_a2);
    ddp_ctr_estimation_rec.usage_markup := rosetta_g_miss_num_map(p7_a3);
    ddp_ctr_estimation_rec.default_value := rosetta_g_miss_num_map(p7_a4);
    ddp_ctr_estimation_rec.estimation_avg_type := p7_a5;
    ddp_ctr_estimation_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ctr_estimation_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ctr_estimation_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_ctr_estimation_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_ctr_estimation_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_ctr_estimation_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_ctr_estimation_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);
    ddp_ctr_estimation_rec.attribute1 := p7_a13;
    ddp_ctr_estimation_rec.attribute2 := p7_a14;
    ddp_ctr_estimation_rec.attribute3 := p7_a15;
    ddp_ctr_estimation_rec.attribute4 := p7_a16;
    ddp_ctr_estimation_rec.attribute5 := p7_a17;
    ddp_ctr_estimation_rec.attribute6 := p7_a18;
    ddp_ctr_estimation_rec.attribute7 := p7_a19;
    ddp_ctr_estimation_rec.attribute8 := p7_a20;
    ddp_ctr_estimation_rec.attribute9 := p7_a21;
    ddp_ctr_estimation_rec.attribute10 := p7_a22;
    ddp_ctr_estimation_rec.attribute11 := p7_a23;
    ddp_ctr_estimation_rec.attribute12 := p7_a24;
    ddp_ctr_estimation_rec.attribute13 := p7_a25;
    ddp_ctr_estimation_rec.attribute14 := p7_a26;
    ddp_ctr_estimation_rec.attribute15 := p7_a27;
    ddp_ctr_estimation_rec.attribute_category := p7_a28;
    ddp_ctr_estimation_rec.object_version_number := rosetta_g_miss_num_map(p7_a29);
    ddp_ctr_estimation_rec.migrated_flag := p7_a30;
    ddp_ctr_estimation_rec.name := p7_a31;
    ddp_ctr_estimation_rec.description := p7_a32;

    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.create_estimation_method(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctr_estimation_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.estimation_id);
    p7_a1 := ddp_ctr_estimation_rec.estimation_type;
    p7_a2 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.fixed_value);
    p7_a3 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.usage_markup);
    p7_a4 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.default_value);
    p7_a5 := ddp_ctr_estimation_rec.estimation_avg_type;
    p7_a6 := ddp_ctr_estimation_rec.start_date_active;
    p7_a7 := ddp_ctr_estimation_rec.end_date_active;
    p7_a8 := ddp_ctr_estimation_rec.last_update_date;
    p7_a9 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.last_updated_by);
    p7_a10 := ddp_ctr_estimation_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.created_by);
    p7_a12 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.last_update_login);
    p7_a13 := ddp_ctr_estimation_rec.attribute1;
    p7_a14 := ddp_ctr_estimation_rec.attribute2;
    p7_a15 := ddp_ctr_estimation_rec.attribute3;
    p7_a16 := ddp_ctr_estimation_rec.attribute4;
    p7_a17 := ddp_ctr_estimation_rec.attribute5;
    p7_a18 := ddp_ctr_estimation_rec.attribute6;
    p7_a19 := ddp_ctr_estimation_rec.attribute7;
    p7_a20 := ddp_ctr_estimation_rec.attribute8;
    p7_a21 := ddp_ctr_estimation_rec.attribute9;
    p7_a22 := ddp_ctr_estimation_rec.attribute10;
    p7_a23 := ddp_ctr_estimation_rec.attribute11;
    p7_a24 := ddp_ctr_estimation_rec.attribute12;
    p7_a25 := ddp_ctr_estimation_rec.attribute13;
    p7_a26 := ddp_ctr_estimation_rec.attribute14;
    p7_a27 := ddp_ctr_estimation_rec.attribute15;
    p7_a28 := ddp_ctr_estimation_rec.attribute_category;
    p7_a29 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.object_version_number);
    p7_a30 := ddp_ctr_estimation_rec.migrated_flag;
    p7_a31 := ddp_ctr_estimation_rec.name;
    p7_a32 := ddp_ctr_estimation_rec.description;
  end;

  procedure update_estimation_method(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  DATE
    , p7_a7 in out nocopy  DATE
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  DATE
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  NUMBER
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
  )

  as
    ddp_ctr_estimation_rec csi_ctr_datastructures_pub.ctr_estimation_methods_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ctr_estimation_rec.estimation_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ctr_estimation_rec.estimation_type := p7_a1;
    ddp_ctr_estimation_rec.fixed_value := rosetta_g_miss_num_map(p7_a2);
    ddp_ctr_estimation_rec.usage_markup := rosetta_g_miss_num_map(p7_a3);
    ddp_ctr_estimation_rec.default_value := rosetta_g_miss_num_map(p7_a4);
    ddp_ctr_estimation_rec.estimation_avg_type := p7_a5;
    ddp_ctr_estimation_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ctr_estimation_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ctr_estimation_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_ctr_estimation_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_ctr_estimation_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_ctr_estimation_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_ctr_estimation_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);
    ddp_ctr_estimation_rec.attribute1 := p7_a13;
    ddp_ctr_estimation_rec.attribute2 := p7_a14;
    ddp_ctr_estimation_rec.attribute3 := p7_a15;
    ddp_ctr_estimation_rec.attribute4 := p7_a16;
    ddp_ctr_estimation_rec.attribute5 := p7_a17;
    ddp_ctr_estimation_rec.attribute6 := p7_a18;
    ddp_ctr_estimation_rec.attribute7 := p7_a19;
    ddp_ctr_estimation_rec.attribute8 := p7_a20;
    ddp_ctr_estimation_rec.attribute9 := p7_a21;
    ddp_ctr_estimation_rec.attribute10 := p7_a22;
    ddp_ctr_estimation_rec.attribute11 := p7_a23;
    ddp_ctr_estimation_rec.attribute12 := p7_a24;
    ddp_ctr_estimation_rec.attribute13 := p7_a25;
    ddp_ctr_estimation_rec.attribute14 := p7_a26;
    ddp_ctr_estimation_rec.attribute15 := p7_a27;
    ddp_ctr_estimation_rec.attribute_category := p7_a28;
    ddp_ctr_estimation_rec.object_version_number := rosetta_g_miss_num_map(p7_a29);
    ddp_ctr_estimation_rec.migrated_flag := p7_a30;
    ddp_ctr_estimation_rec.name := p7_a31;
    ddp_ctr_estimation_rec.description := p7_a32;

    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.update_estimation_method(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctr_estimation_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.estimation_id);
    p7_a1 := ddp_ctr_estimation_rec.estimation_type;
    p7_a2 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.fixed_value);
    p7_a3 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.usage_markup);
    p7_a4 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.default_value);
    p7_a5 := ddp_ctr_estimation_rec.estimation_avg_type;
    p7_a6 := ddp_ctr_estimation_rec.start_date_active;
    p7_a7 := ddp_ctr_estimation_rec.end_date_active;
    p7_a8 := ddp_ctr_estimation_rec.last_update_date;
    p7_a9 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.last_updated_by);
    p7_a10 := ddp_ctr_estimation_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.created_by);
    p7_a12 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.last_update_login);
    p7_a13 := ddp_ctr_estimation_rec.attribute1;
    p7_a14 := ddp_ctr_estimation_rec.attribute2;
    p7_a15 := ddp_ctr_estimation_rec.attribute3;
    p7_a16 := ddp_ctr_estimation_rec.attribute4;
    p7_a17 := ddp_ctr_estimation_rec.attribute5;
    p7_a18 := ddp_ctr_estimation_rec.attribute6;
    p7_a19 := ddp_ctr_estimation_rec.attribute7;
    p7_a20 := ddp_ctr_estimation_rec.attribute8;
    p7_a21 := ddp_ctr_estimation_rec.attribute9;
    p7_a22 := ddp_ctr_estimation_rec.attribute10;
    p7_a23 := ddp_ctr_estimation_rec.attribute11;
    p7_a24 := ddp_ctr_estimation_rec.attribute12;
    p7_a25 := ddp_ctr_estimation_rec.attribute13;
    p7_a26 := ddp_ctr_estimation_rec.attribute14;
    p7_a27 := ddp_ctr_estimation_rec.attribute15;
    p7_a28 := ddp_ctr_estimation_rec.attribute_category;
    p7_a29 := rosetta_g_miss_num_map(ddp_ctr_estimation_rec.object_version_number);
    p7_a30 := ddp_ctr_estimation_rec.migrated_flag;
    p7_a31 := ddp_ctr_estimation_rec.name;
    p7_a32 := ddp_ctr_estimation_rec.description;
  end;

  procedure autoinstantiate_counters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id_template  NUMBER
    , p_source_object_id_instance  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , x_ctr_grp_id_template in out nocopy  NUMBER
    , x_ctr_grp_id_instance in out nocopy  NUMBER
    , p_organization_id  NUMBER
  )

  as
    ddx_ctr_id_template csi_counter_template_pub.ctr_template_autoinst_tbl;
    ddx_ctr_id_instance csi_counter_template_pub.counter_autoinstantiate_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    csi_counter_template_pub_w.rosetta_table_copy_in_p3(ddx_ctr_id_template, p8_a0
      , p8_a1
      );

    csi_counter_template_pub_w.rosetta_table_copy_in_p5(ddx_ctr_id_instance, p9_a0
      , p9_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_template_pub.autoinstantiate_counters(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id_template,
      p_source_object_id_instance,
      ddx_ctr_id_template,
      ddx_ctr_id_instance,
      x_ctr_grp_id_template,
      x_ctr_grp_id_instance,
      p_organization_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    csi_counter_template_pub_w.rosetta_table_copy_out_p3(ddx_ctr_id_template, p8_a0
      , p8_a1
      );

    csi_counter_template_pub_w.rosetta_table_copy_out_p5(ddx_ctr_id_instance, p9_a0
      , p9_a1
      );



  end;

end csi_counter_template_pub_w;

/
