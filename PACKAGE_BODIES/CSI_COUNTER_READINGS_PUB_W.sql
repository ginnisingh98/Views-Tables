--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_READINGS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_READINGS_PUB_W" as
  /* $Header: csipcrwb.pls 120.10 2008/03/26 09:10:02 ngoutam ship $ */
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

  procedure capture_counter_reading(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_NUMBER_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 in out nocopy JTF_NUMBER_TABLE
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_NUMBER_TABLE
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a38 in out nocopy JTF_DATE_TABLE
    , p4_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_DATE_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_DATE_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
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
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a47 in out nocopy JTF_NUMBER_TABLE
    , p5_a48 in out nocopy JTF_NUMBER_TABLE
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 in out nocopy JTF_NUMBER_TABLE
    , p5_a52 in out nocopy JTF_NUMBER_TABLE
    , p5_a53 in out nocopy JTF_NUMBER_TABLE
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a56 in out nocopy JTF_NUMBER_TABLE
    , p5_a57 in out nocopy JTF_NUMBER_TABLE
    , p5_a58 in out nocopy JTF_NUMBER_TABLE
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 in out nocopy JTF_DATE_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_DATE_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_txn_tbl csi_datastructures_pub.transaction_tbl;
    ddp_ctr_rdg_tbl csi_ctr_datastructures_pub.counter_readings_tbl;
    ddp_ctr_prop_rdg_tbl csi_ctr_datastructures_pub.ctr_property_readings_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p27(ddp_txn_tbl, p4_a0
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
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p24(ddp_ctr_rdg_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p26(ddp_ctr_prop_rdg_tbl, p6_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_readings_pub.capture_counter_reading(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_txn_tbl,
      ddp_ctr_rdg_tbl,
      ddp_ctr_prop_rdg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p27(ddp_txn_tbl, p4_a0
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
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p24(ddp_ctr_rdg_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      );

    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p26(ddp_ctr_prop_rdg_tbl, p6_a0
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
      );



  end;

  procedure update_counter_reading(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_NUMBER_TABLE
    , p4_a9 in out nocopy JTF_DATE_TABLE
    , p4_a10 in out nocopy JTF_NUMBER_TABLE
    , p4_a11 in out nocopy JTF_DATE_TABLE
    , p4_a12 in out nocopy JTF_NUMBER_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a46 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a47 in out nocopy JTF_NUMBER_TABLE
    , p4_a48 in out nocopy JTF_NUMBER_TABLE
    , p4_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a51 in out nocopy JTF_NUMBER_TABLE
    , p4_a52 in out nocopy JTF_NUMBER_TABLE
    , p4_a53 in out nocopy JTF_NUMBER_TABLE
    , p4_a54 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a55 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a56 in out nocopy JTF_NUMBER_TABLE
    , p4_a57 in out nocopy JTF_NUMBER_TABLE
    , p4_a58 in out nocopy JTF_NUMBER_TABLE
    , p4_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_rdg_tbl csi_ctr_datastructures_pub.counter_readings_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_in_p24(ddp_ctr_rdg_tbl, p4_a0
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
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_counter_readings_pub.update_counter_reading(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ctr_rdg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_ctr_datastructures_pub_w.rosetta_table_copy_out_p24(ddp_ctr_rdg_tbl, p4_a0
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
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      );



  end;

end csi_counter_readings_pub_w;

/
