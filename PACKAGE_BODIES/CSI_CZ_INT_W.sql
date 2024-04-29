--------------------------------------------------------
--  DDL for Package Body CSI_CZ_INT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CZ_INT_W" as
  /* $Header: csigczwb.pls 120.9 2008/01/15 03:39:05 devijay ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy csi_cz_int.config_query_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).config_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).config_revision_number := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t csi_cz_int.config_query_table, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).config_header_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).config_revision_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy csi_cz_int.config_pair_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).subject_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).subject_revision_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).subject_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).object_header_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_revision_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_item_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).root_header_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).root_revision_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).root_item_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).source_application_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).source_txn_header_ref := a10(indx);
          t(ddindx).source_txn_line_ref1 := a11(indx);
          t(ddindx).source_txn_line_ref2 := a12(indx);
          t(ddindx).source_txn_line_ref3 := a13(indx);
          t(ddindx).lock_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).lock_status := rosetta_g_miss_num_map(a15(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t csi_cz_int.config_pair_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).subject_header_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).subject_revision_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).subject_item_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_header_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_revision_number);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_item_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).root_header_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).root_revision_number);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).root_item_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).source_application_id);
          a10(indx) := t(ddindx).source_txn_header_ref;
          a11(indx) := t(ddindx).source_txn_line_ref1;
          a12(indx) := t(ddindx).source_txn_line_ref2;
          a13(indx) := t(ddindx).source_txn_line_ref3;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).lock_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).lock_status);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy csi_cz_int.config_model_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).config_hdr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).config_rev_nbr := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).config_item_id := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csi_cz_int.config_model_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).config_hdr_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).config_rev_nbr);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).config_item_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy csi_cz_int.config_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).source_application_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).source_txn_header_ref := a1(indx);
          t(ddindx).source_txn_line_ref1 := a2(indx);
          t(ddindx).source_txn_line_ref2 := a3(indx);
          t(ddindx).source_txn_line_ref3 := a4(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).lock_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).lock_status := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).config_inst_hdr_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).config_inst_item_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).config_inst_rev_num := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t csi_cz_int.config_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).source_application_id);
          a1(indx) := t(ddindx).source_txn_header_ref;
          a2(indx) := t(ddindx).source_txn_line_ref1;
          a3(indx) := t(ddindx).source_txn_line_ref2;
          a4(indx) := t(ddindx).source_txn_line_ref3;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).lock_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).lock_status);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_hdr_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_item_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_rev_num);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_configuration_revision(p_config_header_id  NUMBER
    , p_target_commitment_date  date
    , px_instance_level in out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_return_message out nocopy  VARCHAR2
  )

  as
    ddp_target_commitment_date date;
    ddx_install_config_rec csi_cz_int.config_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_target_commitment_date := rosetta_g_miss_date_in_map(p_target_commitment_date);





    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.get_configuration_revision(p_config_header_id,
      ddp_target_commitment_date,
      px_instance_level,
      ddx_install_config_rec,
      x_return_status,
      x_return_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_install_config_rec.source_application_id);
    p3_a1 := ddx_install_config_rec.source_txn_header_ref;
    p3_a2 := ddx_install_config_rec.source_txn_line_ref1;
    p3_a3 := ddx_install_config_rec.source_txn_line_ref2;
    p3_a4 := ddx_install_config_rec.source_txn_line_ref3;
    p3_a5 := rosetta_g_miss_num_map(ddx_install_config_rec.instance_id);
    p3_a6 := rosetta_g_miss_num_map(ddx_install_config_rec.lock_id);
    p3_a7 := rosetta_g_miss_num_map(ddx_install_config_rec.lock_status);
    p3_a8 := rosetta_g_miss_num_map(ddx_install_config_rec.config_inst_hdr_id);
    p3_a9 := rosetta_g_miss_num_map(ddx_install_config_rec.config_inst_item_id);
    p3_a10 := rosetta_g_miss_num_map(ddx_install_config_rec.config_inst_rev_num);


  end;

  procedure get_connected_configurations(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p_instance_level  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p2_a5 out nocopy JTF_NUMBER_TABLE
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_NUMBER_TABLE
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p2_a9 out nocopy JTF_NUMBER_TABLE
    , p2_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a14 out nocopy JTF_NUMBER_TABLE
    , p2_a15 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_return_message out nocopy  VARCHAR2
  )

  as
    ddp_config_query_table csi_cz_int.config_query_table;
    ddx_config_pair_table csi_cz_int.config_pair_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_cz_int_w.rosetta_table_copy_in_p1(ddp_config_query_table, p0_a0
      , p0_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.get_connected_configurations(ddp_config_query_table,
      p_instance_level,
      ddx_config_pair_table,
      x_return_status,
      x_return_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    csi_cz_int_w.rosetta_table_copy_out_p3(ddx_config_pair_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      );


  end;

  procedure generate_config_trees(p_api_version  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p_tree_copy_mode  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_config_query_table csi_cz_int.config_query_table;
    ddx_cfg_model_tbl csi_cz_int.config_model_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    csi_cz_int_w.rosetta_table_copy_in_p1(ddp_config_query_table, p1_a0
      , p1_a1
      );






    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.generate_config_trees(p_api_version,
      ddp_config_query_table,
      p_tree_copy_mode,
      ddx_cfg_model_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csi_cz_int_w.rosetta_table_copy_out_p5(ddx_cfg_model_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      );



  end;

  procedure check_item_instance_lock(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_config_rec csi_cz_int.config_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_config_rec.source_application_id := rosetta_g_miss_num_map(p1_a0);
    ddp_config_rec.source_txn_header_ref := p1_a1;
    ddp_config_rec.source_txn_line_ref1 := p1_a2;
    ddp_config_rec.source_txn_line_ref2 := p1_a3;
    ddp_config_rec.source_txn_line_ref3 := p1_a4;
    ddp_config_rec.instance_id := rosetta_g_miss_num_map(p1_a5);
    ddp_config_rec.lock_id := rosetta_g_miss_num_map(p1_a6);
    ddp_config_rec.lock_status := rosetta_g_miss_num_map(p1_a7);
    ddp_config_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p1_a8);
    ddp_config_rec.config_inst_item_id := rosetta_g_miss_num_map(p1_a9);
    ddp_config_rec.config_inst_rev_num := rosetta_g_miss_num_map(p1_a10);




    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csi_cz_int.check_item_instance_lock(p_init_msg_list,
      ddp_config_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;




  end;

  procedure lock_item_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_NUMBER_TABLE
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_config_tbl csi_cz_int.config_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_cz_int_w.rosetta_table_copy_in_p7(ddpx_config_tbl, p4_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.lock_item_instances(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddpx_config_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_cz_int_w.rosetta_table_copy_out_p7(ddpx_config_tbl, p4_a0
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
      );



  end;

  procedure unlock_current_node(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_config_rec csi_cz_int.config_rec;
    ddx_conn_config_tbl csi_cz_int.config_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_config_rec.source_application_id := rosetta_g_miss_num_map(p4_a0);
    ddp_config_rec.source_txn_header_ref := p4_a1;
    ddp_config_rec.source_txn_line_ref1 := p4_a2;
    ddp_config_rec.source_txn_line_ref2 := p4_a3;
    ddp_config_rec.source_txn_line_ref3 := p4_a4;
    ddp_config_rec.instance_id := rosetta_g_miss_num_map(p4_a5);
    ddp_config_rec.lock_id := rosetta_g_miss_num_map(p4_a6);
    ddp_config_rec.lock_status := rosetta_g_miss_num_map(p4_a7);
    ddp_config_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a8);
    ddp_config_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a9);
    ddp_config_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a10);





    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.unlock_current_node(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_config_rec,
      ddx_conn_config_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    csi_cz_int_w.rosetta_table_copy_out_p7(ddx_conn_config_tbl, p5_a0
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
      );



  end;

  procedure unlock_item_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_config_tbl csi_cz_int.config_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_cz_int_w.rosetta_table_copy_in_p7(ddp_config_tbl, p4_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_cz_int.unlock_item_instances(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_config_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end csi_cz_int_w;

/
