--------------------------------------------------------
--  DDL for Package Body CSI_PRICING_ATTRIBS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PRICING_ATTRIBS_PUB_W" as
  /* $Header: csippawb.pls 120.11 2008/01/15 03:38:09 devijay ship $ */
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

  procedure get_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a78 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a79 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a80 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a83 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a84 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a93 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a94 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a95 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a99 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a100 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a101 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a102 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a103 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a104 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a106 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a107 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a108 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a109 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a110 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a111 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a112 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a113 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a114 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a115 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a116 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a117 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a118 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a119 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a120 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a121 out nocopy JTF_NUMBER_TABLE
    , p6_a122 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
  )

  as
    ddp_pricing_attribs_query_rec csi_datastructures_pub.pricing_attribs_query_rec;
    ddp_time_stamp date;
    ddx_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_pricing_attribs_query_rec.pricing_attribute_id := rosetta_g_miss_num_map(p4_a0);
    ddp_pricing_attribs_query_rec.instance_id := rosetta_g_miss_num_map(p4_a1);

    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);





    -- here's the delegated call to the old PL/SQL routine
    csi_pricing_attribs_pub.get_pricing_attribs(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_pricing_attribs_query_rec,
      ddp_time_stamp,
      ddx_pricing_attribs_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csi_datastructures_pub_w.rosetta_table_copy_out_p46(ddx_pricing_attribs_tbl, p6_a0
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
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      , p6_a99
      , p6_a100
      , p6_a101
      , p6_a102
      , p6_a103
      , p6_a104
      , p6_a105
      , p6_a106
      , p6_a107
      , p6_a108
      , p6_a109
      , p6_a110
      , p6_a111
      , p6_a112
      , p6_a113
      , p6_a114
      , p6_a115
      , p6_a116
      , p6_a117
      , p6_a118
      , p6_a119
      , p6_a120
      , p6_a121
      , p6_a122
      );



  end;

  procedure create_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_DATE_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_300
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
    , p4_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a121 in out nocopy JTF_NUMBER_TABLE
    , p4_a122 in out nocopy JTF_NUMBER_TABLE
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
    ddp_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p46(ddp_pricing_attribs_tbl, p4_a0
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
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      , p4_a82
      , p4_a83
      , p4_a84
      , p4_a85
      , p4_a86
      , p4_a87
      , p4_a88
      , p4_a89
      , p4_a90
      , p4_a91
      , p4_a92
      , p4_a93
      , p4_a94
      , p4_a95
      , p4_a96
      , p4_a97
      , p4_a98
      , p4_a99
      , p4_a100
      , p4_a101
      , p4_a102
      , p4_a103
      , p4_a104
      , p4_a105
      , p4_a106
      , p4_a107
      , p4_a108
      , p4_a109
      , p4_a110
      , p4_a111
      , p4_a112
      , p4_a113
      , p4_a114
      , p4_a115
      , p4_a116
      , p4_a117
      , p4_a118
      , p4_a119
      , p4_a120
      , p4_a121
      , p4_a122
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_pricing_attribs_pub.create_pricing_attribs(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_pricing_attribs_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p46(ddp_pricing_attribs_tbl, p4_a0
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
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      , p4_a82
      , p4_a83
      , p4_a84
      , p4_a85
      , p4_a86
      , p4_a87
      , p4_a88
      , p4_a89
      , p4_a90
      , p4_a91
      , p4_a92
      , p4_a93
      , p4_a94
      , p4_a95
      , p4_a96
      , p4_a97
      , p4_a98
      , p4_a99
      , p4_a100
      , p4_a101
      , p4_a102
      , p4_a103
      , p4_a104
      , p4_a105
      , p4_a106
      , p4_a107
      , p4_a108
      , p4_a109
      , p4_a110
      , p4_a111
      , p4_a112
      , p4_a113
      , p4_a114
      , p4_a115
      , p4_a116
      , p4_a117
      , p4_a118
      , p4_a119
      , p4_a120
      , p4_a121
      , p4_a122
      );

    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

  procedure update_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_VARCHAR2_TABLE_200
    , p4_a72 JTF_VARCHAR2_TABLE_200
    , p4_a73 JTF_VARCHAR2_TABLE_200
    , p4_a74 JTF_VARCHAR2_TABLE_200
    , p4_a75 JTF_VARCHAR2_TABLE_200
    , p4_a76 JTF_VARCHAR2_TABLE_200
    , p4_a77 JTF_VARCHAR2_TABLE_200
    , p4_a78 JTF_VARCHAR2_TABLE_200
    , p4_a79 JTF_VARCHAR2_TABLE_200
    , p4_a80 JTF_VARCHAR2_TABLE_200
    , p4_a81 JTF_VARCHAR2_TABLE_200
    , p4_a82 JTF_VARCHAR2_TABLE_200
    , p4_a83 JTF_VARCHAR2_TABLE_200
    , p4_a84 JTF_VARCHAR2_TABLE_200
    , p4_a85 JTF_VARCHAR2_TABLE_200
    , p4_a86 JTF_VARCHAR2_TABLE_200
    , p4_a87 JTF_VARCHAR2_TABLE_200
    , p4_a88 JTF_VARCHAR2_TABLE_200
    , p4_a89 JTF_VARCHAR2_TABLE_200
    , p4_a90 JTF_VARCHAR2_TABLE_200
    , p4_a91 JTF_VARCHAR2_TABLE_200
    , p4_a92 JTF_VARCHAR2_TABLE_200
    , p4_a93 JTF_VARCHAR2_TABLE_200
    , p4_a94 JTF_VARCHAR2_TABLE_200
    , p4_a95 JTF_VARCHAR2_TABLE_200
    , p4_a96 JTF_VARCHAR2_TABLE_200
    , p4_a97 JTF_VARCHAR2_TABLE_200
    , p4_a98 JTF_VARCHAR2_TABLE_200
    , p4_a99 JTF_VARCHAR2_TABLE_200
    , p4_a100 JTF_VARCHAR2_TABLE_200
    , p4_a101 JTF_VARCHAR2_TABLE_200
    , p4_a102 JTF_VARCHAR2_TABLE_200
    , p4_a103 JTF_VARCHAR2_TABLE_200
    , p4_a104 JTF_VARCHAR2_TABLE_200
    , p4_a105 JTF_VARCHAR2_TABLE_100
    , p4_a106 JTF_VARCHAR2_TABLE_200
    , p4_a107 JTF_VARCHAR2_TABLE_200
    , p4_a108 JTF_VARCHAR2_TABLE_200
    , p4_a109 JTF_VARCHAR2_TABLE_200
    , p4_a110 JTF_VARCHAR2_TABLE_200
    , p4_a111 JTF_VARCHAR2_TABLE_200
    , p4_a112 JTF_VARCHAR2_TABLE_200
    , p4_a113 JTF_VARCHAR2_TABLE_200
    , p4_a114 JTF_VARCHAR2_TABLE_200
    , p4_a115 JTF_VARCHAR2_TABLE_200
    , p4_a116 JTF_VARCHAR2_TABLE_200
    , p4_a117 JTF_VARCHAR2_TABLE_200
    , p4_a118 JTF_VARCHAR2_TABLE_200
    , p4_a119 JTF_VARCHAR2_TABLE_200
    , p4_a120 JTF_VARCHAR2_TABLE_200
    , p4_a121 JTF_NUMBER_TABLE
    , p4_a122 JTF_NUMBER_TABLE
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
    ddp_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p46(ddp_pricing_attribs_tbl, p4_a0
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
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      , p4_a82
      , p4_a83
      , p4_a84
      , p4_a85
      , p4_a86
      , p4_a87
      , p4_a88
      , p4_a89
      , p4_a90
      , p4_a91
      , p4_a92
      , p4_a93
      , p4_a94
      , p4_a95
      , p4_a96
      , p4_a97
      , p4_a98
      , p4_a99
      , p4_a100
      , p4_a101
      , p4_a102
      , p4_a103
      , p4_a104
      , p4_a105
      , p4_a106
      , p4_a107
      , p4_a108
      , p4_a109
      , p4_a110
      , p4_a111
      , p4_a112
      , p4_a113
      , p4_a114
      , p4_a115
      , p4_a116
      , p4_a117
      , p4_a118
      , p4_a119
      , p4_a120
      , p4_a121
      , p4_a122
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_pricing_attribs_pub.update_pricing_attribs(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_pricing_attribs_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

  procedure expire_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_VARCHAR2_TABLE_200
    , p4_a72 JTF_VARCHAR2_TABLE_200
    , p4_a73 JTF_VARCHAR2_TABLE_200
    , p4_a74 JTF_VARCHAR2_TABLE_200
    , p4_a75 JTF_VARCHAR2_TABLE_200
    , p4_a76 JTF_VARCHAR2_TABLE_200
    , p4_a77 JTF_VARCHAR2_TABLE_200
    , p4_a78 JTF_VARCHAR2_TABLE_200
    , p4_a79 JTF_VARCHAR2_TABLE_200
    , p4_a80 JTF_VARCHAR2_TABLE_200
    , p4_a81 JTF_VARCHAR2_TABLE_200
    , p4_a82 JTF_VARCHAR2_TABLE_200
    , p4_a83 JTF_VARCHAR2_TABLE_200
    , p4_a84 JTF_VARCHAR2_TABLE_200
    , p4_a85 JTF_VARCHAR2_TABLE_200
    , p4_a86 JTF_VARCHAR2_TABLE_200
    , p4_a87 JTF_VARCHAR2_TABLE_200
    , p4_a88 JTF_VARCHAR2_TABLE_200
    , p4_a89 JTF_VARCHAR2_TABLE_200
    , p4_a90 JTF_VARCHAR2_TABLE_200
    , p4_a91 JTF_VARCHAR2_TABLE_200
    , p4_a92 JTF_VARCHAR2_TABLE_200
    , p4_a93 JTF_VARCHAR2_TABLE_200
    , p4_a94 JTF_VARCHAR2_TABLE_200
    , p4_a95 JTF_VARCHAR2_TABLE_200
    , p4_a96 JTF_VARCHAR2_TABLE_200
    , p4_a97 JTF_VARCHAR2_TABLE_200
    , p4_a98 JTF_VARCHAR2_TABLE_200
    , p4_a99 JTF_VARCHAR2_TABLE_200
    , p4_a100 JTF_VARCHAR2_TABLE_200
    , p4_a101 JTF_VARCHAR2_TABLE_200
    , p4_a102 JTF_VARCHAR2_TABLE_200
    , p4_a103 JTF_VARCHAR2_TABLE_200
    , p4_a104 JTF_VARCHAR2_TABLE_200
    , p4_a105 JTF_VARCHAR2_TABLE_100
    , p4_a106 JTF_VARCHAR2_TABLE_200
    , p4_a107 JTF_VARCHAR2_TABLE_200
    , p4_a108 JTF_VARCHAR2_TABLE_200
    , p4_a109 JTF_VARCHAR2_TABLE_200
    , p4_a110 JTF_VARCHAR2_TABLE_200
    , p4_a111 JTF_VARCHAR2_TABLE_200
    , p4_a112 JTF_VARCHAR2_TABLE_200
    , p4_a113 JTF_VARCHAR2_TABLE_200
    , p4_a114 JTF_VARCHAR2_TABLE_200
    , p4_a115 JTF_VARCHAR2_TABLE_200
    , p4_a116 JTF_VARCHAR2_TABLE_200
    , p4_a117 JTF_VARCHAR2_TABLE_200
    , p4_a118 JTF_VARCHAR2_TABLE_200
    , p4_a119 JTF_VARCHAR2_TABLE_200
    , p4_a120 JTF_VARCHAR2_TABLE_200
    , p4_a121 JTF_NUMBER_TABLE
    , p4_a122 JTF_NUMBER_TABLE
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
    ddp_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p46(ddp_pricing_attribs_tbl, p4_a0
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
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      , p4_a82
      , p4_a83
      , p4_a84
      , p4_a85
      , p4_a86
      , p4_a87
      , p4_a88
      , p4_a89
      , p4_a90
      , p4_a91
      , p4_a92
      , p4_a93
      , p4_a94
      , p4_a95
      , p4_a96
      , p4_a97
      , p4_a98
      , p4_a99
      , p4_a100
      , p4_a101
      , p4_a102
      , p4_a103
      , p4_a104
      , p4_a105
      , p4_a106
      , p4_a107
      , p4_a108
      , p4_a109
      , p4_a110
      , p4_a111
      , p4_a112
      , p4_a113
      , p4_a114
      , p4_a115
      , p4_a116
      , p4_a117
      , p4_a118
      , p4_a119
      , p4_a120
      , p4_a121
      , p4_a122
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_pricing_attribs_pub.expire_pricing_attribs(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_pricing_attribs_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

end csi_pricing_attribs_pub_w;

/
