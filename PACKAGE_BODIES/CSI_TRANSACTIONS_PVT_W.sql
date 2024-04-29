--------------------------------------------------------
--  DDL for Package Body CSI_TRANSACTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TRANSACTIONS_PVT_W" as
  /* $Header: csivtxwb.pls 120.12 2008/01/15 03:38:26 devijay ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy csi_transactions_pvt.util_order_by_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).col_choice := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).col_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t csi_transactions_pvt.util_order_by_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).col_choice);
          a1(indx) := t(ddindx).col_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure get_transactions(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_rec_requested  NUMBER
    , p_start_rec_prt  NUMBER
    , p_return_tot_count  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_DATE_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_NUMBER_TABLE
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_NUMBER_TABLE
    , p12_a12 out nocopy JTF_NUMBER_TABLE
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_NUMBER_TABLE
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_NUMBER_TABLE
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , x_returned_rec_count out nocopy  NUMBER
    , x_next_rec_ptr out nocopy  NUMBER
    , x_tot_rec_count out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_txnfind_rec csi_datastructures_pub.transaction_query_rec;
    ddp_order_by_rec csi_datastructures_pub.transaction_sort_rec;
    ddx_transaction_tbl csi_datastructures_pub.transaction_header_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_txnfind_rec.transaction_id := rosetta_g_miss_num_map(p4_a0);
    ddp_txnfind_rec.transaction_type_id := rosetta_g_miss_num_map(p4_a1);
    ddp_txnfind_rec.txn_sub_type_id := rosetta_g_miss_num_map(p4_a2);
    ddp_txnfind_rec.source_group_ref_id := rosetta_g_miss_num_map(p4_a3);
    ddp_txnfind_rec.source_group_ref := p4_a4;
    ddp_txnfind_rec.source_header_ref_id := rosetta_g_miss_num_map(p4_a5);
    ddp_txnfind_rec.source_header_ref := p4_a6;
    ddp_txnfind_rec.source_line_ref_id := rosetta_g_miss_num_map(p4_a7);
    ddp_txnfind_rec.source_line_ref := p4_a8;
    ddp_txnfind_rec.source_transaction_date := rosetta_g_miss_date_in_map(p4_a9);
    ddp_txnfind_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p4_a10);
    ddp_txnfind_rec.message_id := rosetta_g_miss_num_map(p4_a11);
    ddp_txnfind_rec.transaction_start_date := rosetta_g_miss_date_in_map(p4_a12);
    ddp_txnfind_rec.transaction_end_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_txnfind_rec.instance_id := rosetta_g_miss_num_map(p4_a14);
    ddp_txnfind_rec.transaction_status_code := p4_a15;




    ddp_order_by_rec.transaction_date := p8_a0;
    ddp_order_by_rec.transaction_type_id := p8_a1;








    -- here's the delegated call to the old PL/SQL routine
    csi_transactions_pvt.get_transactions(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_txnfind_rec,
      p_rec_requested,
      p_start_rec_prt,
      p_return_tot_count,
      ddp_order_by_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_transaction_tbl,
      x_returned_rec_count,
      x_next_rec_ptr,
      x_tot_rec_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    csi_datastructures_pub_w.rosetta_table_copy_out_p75(ddx_transaction_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      , p12_a35
      , p12_a36
      , p12_a37
      , p12_a38
      , p12_a39
      , p12_a40
      , p12_a41
      , p12_a42
      , p12_a43
      );



  end;

  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_success_if_exists_flag  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_transaction_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_transaction_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_transaction_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_transaction_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_transaction_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_transaction_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_transaction_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_transaction_rec.source_group_ref := p5_a6;
    ddp_transaction_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_transaction_rec.source_header_ref := p5_a8;
    ddp_transaction_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_transaction_rec.source_line_ref := p5_a10;
    ddp_transaction_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_transaction_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_transaction_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_transaction_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_transaction_rec.transaction_uom_code := p5_a15;
    ddp_transaction_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_transaction_rec.transaction_status_code := p5_a17;
    ddp_transaction_rec.transaction_action_code := p5_a18;
    ddp_transaction_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_transaction_rec.context := p5_a20;
    ddp_transaction_rec.attribute1 := p5_a21;
    ddp_transaction_rec.attribute2 := p5_a22;
    ddp_transaction_rec.attribute3 := p5_a23;
    ddp_transaction_rec.attribute4 := p5_a24;
    ddp_transaction_rec.attribute5 := p5_a25;
    ddp_transaction_rec.attribute6 := p5_a26;
    ddp_transaction_rec.attribute7 := p5_a27;
    ddp_transaction_rec.attribute8 := p5_a28;
    ddp_transaction_rec.attribute9 := p5_a29;
    ddp_transaction_rec.attribute10 := p5_a30;
    ddp_transaction_rec.attribute11 := p5_a31;
    ddp_transaction_rec.attribute12 := p5_a32;
    ddp_transaction_rec.attribute13 := p5_a33;
    ddp_transaction_rec.attribute14 := p5_a34;
    ddp_transaction_rec.attribute15 := p5_a35;
    ddp_transaction_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_transaction_rec.split_reason_code := p5_a37;
    ddp_transaction_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_transaction_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_transactions_pvt.create_transaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_success_if_exists_flag,
      ddp_transaction_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddp_transaction_rec.transaction_id);
    p5_a1 := ddp_transaction_rec.transaction_date;
    p5_a2 := ddp_transaction_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_transaction_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_transaction_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_transaction_rec.source_group_ref_id);
    p5_a6 := ddp_transaction_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_transaction_rec.source_header_ref_id);
    p5_a8 := ddp_transaction_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_transaction_rec.source_line_ref_id);
    p5_a10 := ddp_transaction_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_transaction_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_transaction_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_transaction_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_transaction_rec.transaction_quantity);
    p5_a15 := ddp_transaction_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_transaction_rec.transacted_by);
    p5_a17 := ddp_transaction_rec.transaction_status_code;
    p5_a18 := ddp_transaction_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_transaction_rec.message_id);
    p5_a20 := ddp_transaction_rec.context;
    p5_a21 := ddp_transaction_rec.attribute1;
    p5_a22 := ddp_transaction_rec.attribute2;
    p5_a23 := ddp_transaction_rec.attribute3;
    p5_a24 := ddp_transaction_rec.attribute4;
    p5_a25 := ddp_transaction_rec.attribute5;
    p5_a26 := ddp_transaction_rec.attribute6;
    p5_a27 := ddp_transaction_rec.attribute7;
    p5_a28 := ddp_transaction_rec.attribute8;
    p5_a29 := ddp_transaction_rec.attribute9;
    p5_a30 := ddp_transaction_rec.attribute10;
    p5_a31 := ddp_transaction_rec.attribute11;
    p5_a32 := ddp_transaction_rec.attribute12;
    p5_a33 := ddp_transaction_rec.attribute13;
    p5_a34 := ddp_transaction_rec.attribute14;
    p5_a35 := ddp_transaction_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_transaction_rec.object_version_number);
    p5_a37 := ddp_transaction_rec.split_reason_code;
    p5_a38 := ddp_transaction_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_transaction_rec.gl_interface_status_code);



  end;

  procedure update_transactions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  DATE := fnd_api.g_miss_date
    , p4_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_transaction_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_transaction_rec.transaction_id := rosetta_g_miss_num_map(p4_a0);
    ddp_transaction_rec.transaction_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_transaction_rec.source_transaction_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_transaction_rec.transaction_type_id := rosetta_g_miss_num_map(p4_a3);
    ddp_transaction_rec.txn_sub_type_id := rosetta_g_miss_num_map(p4_a4);
    ddp_transaction_rec.source_group_ref_id := rosetta_g_miss_num_map(p4_a5);
    ddp_transaction_rec.source_group_ref := p4_a6;
    ddp_transaction_rec.source_header_ref_id := rosetta_g_miss_num_map(p4_a7);
    ddp_transaction_rec.source_header_ref := p4_a8;
    ddp_transaction_rec.source_line_ref_id := rosetta_g_miss_num_map(p4_a9);
    ddp_transaction_rec.source_line_ref := p4_a10;
    ddp_transaction_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p4_a11);
    ddp_transaction_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p4_a12);
    ddp_transaction_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p4_a13);
    ddp_transaction_rec.transaction_quantity := rosetta_g_miss_num_map(p4_a14);
    ddp_transaction_rec.transaction_uom_code := p4_a15;
    ddp_transaction_rec.transacted_by := rosetta_g_miss_num_map(p4_a16);
    ddp_transaction_rec.transaction_status_code := p4_a17;
    ddp_transaction_rec.transaction_action_code := p4_a18;
    ddp_transaction_rec.message_id := rosetta_g_miss_num_map(p4_a19);
    ddp_transaction_rec.context := p4_a20;
    ddp_transaction_rec.attribute1 := p4_a21;
    ddp_transaction_rec.attribute2 := p4_a22;
    ddp_transaction_rec.attribute3 := p4_a23;
    ddp_transaction_rec.attribute4 := p4_a24;
    ddp_transaction_rec.attribute5 := p4_a25;
    ddp_transaction_rec.attribute6 := p4_a26;
    ddp_transaction_rec.attribute7 := p4_a27;
    ddp_transaction_rec.attribute8 := p4_a28;
    ddp_transaction_rec.attribute9 := p4_a29;
    ddp_transaction_rec.attribute10 := p4_a30;
    ddp_transaction_rec.attribute11 := p4_a31;
    ddp_transaction_rec.attribute12 := p4_a32;
    ddp_transaction_rec.attribute13 := p4_a33;
    ddp_transaction_rec.attribute14 := p4_a34;
    ddp_transaction_rec.attribute15 := p4_a35;
    ddp_transaction_rec.object_version_number := rosetta_g_miss_num_map(p4_a36);
    ddp_transaction_rec.split_reason_code := p4_a37;
    ddp_transaction_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p4_a38);
    ddp_transaction_rec.gl_interface_status_code := rosetta_g_miss_num_map(p4_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_transactions_pvt.update_transactions(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_transaction_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_txn_error(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_transaction_error_id out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  DATE := fnd_api.g_miss_date
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_txn_error_rec csi_datastructures_pub.transaction_error_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_txn_error_rec.transaction_error_id := rosetta_g_miss_num_map(p4_a0);
    ddp_txn_error_rec.transaction_id := rosetta_g_miss_num_map(p4_a1);
    ddp_txn_error_rec.message_id := rosetta_g_miss_num_map(p4_a2);
    ddp_txn_error_rec.error_text := p4_a3;
    ddp_txn_error_rec.source_type := p4_a4;
    ddp_txn_error_rec.source_id := rosetta_g_miss_num_map(p4_a5);
    ddp_txn_error_rec.processed_flag := p4_a6;
    ddp_txn_error_rec.created_by := rosetta_g_miss_num_map(p4_a7);
    ddp_txn_error_rec.creation_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_txn_error_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_txn_error_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_txn_error_rec.last_update_login := rosetta_g_miss_num_map(p4_a11);
    ddp_txn_error_rec.object_version_number := rosetta_g_miss_num_map(p4_a12);
    ddp_txn_error_rec.transaction_type_id := rosetta_g_miss_num_map(p4_a13);
    ddp_txn_error_rec.source_group_ref := p4_a14;
    ddp_txn_error_rec.source_group_ref_id := rosetta_g_miss_num_map(p4_a15);
    ddp_txn_error_rec.source_header_ref := p4_a16;
    ddp_txn_error_rec.source_header_ref_id := rosetta_g_miss_num_map(p4_a17);
    ddp_txn_error_rec.source_line_ref := p4_a18;
    ddp_txn_error_rec.source_line_ref_id := rosetta_g_miss_num_map(p4_a19);
    ddp_txn_error_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p4_a20);
    ddp_txn_error_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p4_a21);
    ddp_txn_error_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p4_a22);
    ddp_txn_error_rec.error_stage := p4_a23;
    ddp_txn_error_rec.message_string := p4_a24;
    ddp_txn_error_rec.instance_id := rosetta_g_miss_num_map(p4_a25);
    ddp_txn_error_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a26);
    ddp_txn_error_rec.serial_number := p4_a27;
    ddp_txn_error_rec.lot_number := p4_a28;
    ddp_txn_error_rec.transaction_error_date := rosetta_g_miss_date_in_map(p4_a29);
    ddp_txn_error_rec.src_serial_num_ctrl_code := rosetta_g_miss_num_map(p4_a30);
    ddp_txn_error_rec.src_location_ctrl_code := rosetta_g_miss_num_map(p4_a31);
    ddp_txn_error_rec.src_lot_ctrl_code := rosetta_g_miss_num_map(p4_a32);
    ddp_txn_error_rec.src_rev_qty_ctrl_code := rosetta_g_miss_num_map(p4_a33);
    ddp_txn_error_rec.dst_serial_num_ctrl_code := rosetta_g_miss_num_map(p4_a34);
    ddp_txn_error_rec.dst_location_ctrl_code := rosetta_g_miss_num_map(p4_a35);
    ddp_txn_error_rec.dst_lot_ctrl_code := rosetta_g_miss_num_map(p4_a36);
    ddp_txn_error_rec.dst_rev_qty_ctrl_code := rosetta_g_miss_num_map(p4_a37);
    ddp_txn_error_rec.comms_nl_trackable_flag := p4_a38;





    -- here's the delegated call to the old PL/SQL routine
    csi_transactions_pvt.create_txn_error(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_txn_error_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_transaction_error_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end csi_transactions_pvt_w;

/
