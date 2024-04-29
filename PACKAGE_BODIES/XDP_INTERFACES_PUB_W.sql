--------------------------------------------------------
--  DDL for Package Body XDP_INTERFACES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_INTERFACES_PUB_W" as
  /* $Header: XDPINPWB.pls 120.1 2005/06/22 07:11:58 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  g_date_fmtStr varchar2(30) := 'YYYY.MM.DD HH24:MI:SS';
  --lg_delimiter varchar2(4) := chr(5)||chr(30);
  lg_delimiter varchar2(4) := fnd_global.local_chr(5)||fnd_global.local_chr(30);
  --lg_inline_delimiter varchar2(4) := chr(5)||chr(31);
  lg_inline_delimiter varchar2(4) := fnd_global.local_chr(5)||fnd_global.local_chr(31);

  lg_line_clob CLOB;
  lg_line_param_clob CLOB;
  lg_order_param_clob CLOB;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure process_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_4000
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_DATE_TABLE
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_DATE_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_NUMBER_TABLE
    , p9_a22 JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_VARCHAR2_TABLE_4000
    , p10_a3 JTF_VARCHAR2_TABLE_4000
    , x_sdp_order_id OUT NOCOPY  NUMBER
  )
  as
    ddp_order_header xdp_types.order_header;
    ddp_order_parameter xdp_types.order_parameter_list;
    ddp_order_line_list xdp_types.order_line_list;
    ddp_line_parameter_list xdp_types.line_param_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_order_header.order_number := p7_a0;
    ddp_order_header.order_version := p7_a1;
    ddp_order_header.provisioning_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_order_header.priority := p7_a3;
    ddp_order_header.due_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_order_header.customer_required_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_order_header.order_type := p7_a6;
    ddp_order_header.order_action := p7_a7;
    ddp_order_header.order_source := p7_a8;
    ddp_order_header.related_order_id := p7_a9;
    ddp_order_header.org_id := p7_a10;
    ddp_order_header.customer_name := p7_a11;
    ddp_order_header.customer_id := p7_a12;
    ddp_order_header.service_provider_id := p7_a13;
    ddp_order_header.telephone_number := p7_a14;
    ddp_order_header.order_status := p7_a15;
    ddp_order_header.order_state := p7_a16;
    ddp_order_header.actual_provisioning_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_order_header.completion_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_order_header.previous_order_id := p7_a19;
    ddp_order_header.next_order_id := p7_a20;
    ddp_order_header.sdp_order_id := p7_a21;
    ddp_order_header.jeopardy_enabled_flag := p7_a22;
    ddp_order_header.order_ref_name := p7_a23;
    ddp_order_header.order_ref_value := p7_a24;
    ddp_order_header.sp_order_number := p7_a25;
    ddp_order_header.sp_userid := p7_a26;

    xdp_types_w.rosetta_table_copy_in_p3(ddp_order_parameter, p8_a0
      , p8_a1
      );

    xdp_types_w.rosetta_table_copy_in_p5(ddp_order_line_list, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      );

    xdp_types_w.rosetta_table_copy_in_p7(ddp_line_parameter_list, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    xdp_interfaces_pub.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_order_header,
      ddp_order_parameter,
      ddp_order_line_list,
      ddp_line_parameter_list,
      x_sdp_order_id);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

  procedure process_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  DATE
    , p8_a3  NUMBER
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  DATE
    , p8_a9  DATE
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  NUMBER
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
    , p8_a48  VARCHAR2
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_VARCHAR2_TABLE_100
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p10_a13 JTF_VARCHAR2_TABLE_100
    , p10_a14 JTF_NUMBER_TABLE
    , p10_a15 JTF_NUMBER_TABLE
    , p10_a16 JTF_NUMBER_TABLE
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_DATE_TABLE
    , p10_a19 JTF_VARCHAR2_TABLE_100
    , p10_a20 JTF_DATE_TABLE
    , p10_a21 JTF_NUMBER_TABLE
    , p10_a22 JTF_NUMBER_TABLE
    , p10_a23 JTF_NUMBER_TABLE
    , p10_a24 JTF_NUMBER_TABLE
    , p10_a25 JTF_VARCHAR2_TABLE_100
    , p10_a26 JTF_DATE_TABLE
    , p10_a27 JTF_DATE_TABLE
    , p10_a28 JTF_NUMBER_TABLE
    , p10_a29 JTF_VARCHAR2_TABLE_100
    , p10_a30 JTF_VARCHAR2_TABLE_100
    , p10_a31 JTF_VARCHAR2_TABLE_300
    , p10_a32 JTF_VARCHAR2_TABLE_300
    , p10_a33 JTF_VARCHAR2_TABLE_300
    , p10_a34 JTF_VARCHAR2_TABLE_300
    , p10_a35 JTF_VARCHAR2_TABLE_300
    , p10_a36 JTF_VARCHAR2_TABLE_300
    , p10_a37 JTF_VARCHAR2_TABLE_300
    , p10_a38 JTF_VARCHAR2_TABLE_300
    , p10_a39 JTF_VARCHAR2_TABLE_300
    , p10_a40 JTF_VARCHAR2_TABLE_300
    , p10_a41 JTF_VARCHAR2_TABLE_300
    , p10_a42 JTF_VARCHAR2_TABLE_300
    , p10_a43 JTF_VARCHAR2_TABLE_300
    , p10_a44 JTF_VARCHAR2_TABLE_300
    , p10_a45 JTF_VARCHAR2_TABLE_300
    , p10_a46 JTF_VARCHAR2_TABLE_300
    , p10_a47 JTF_VARCHAR2_TABLE_300
    , p10_a48 JTF_VARCHAR2_TABLE_300
    , p10_a49 JTF_VARCHAR2_TABLE_300
    , p10_a50 JTF_VARCHAR2_TABLE_300
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p11_a2 JTF_VARCHAR2_TABLE_4000
    , p11_a3 JTF_VARCHAR2_TABLE_4000
    , x_order_id OUT NOCOPY  NUMBER
  )
  as
    ddp_order_header xdp_types.service_order_header;
    ddp_order_param_list xdp_types.service_order_param_list;
    ddp_order_line_list xdp_types.service_order_line_list;
    ddp_line_param_list xdp_types.service_line_param_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_order_header.order_number := p8_a0;
    ddp_order_header.order_version := p8_a1;
    ddp_order_header.required_fulfillment_date := rosetta_g_miss_date_in_map(p8_a2);
    ddp_order_header.priority := p8_a3;
    ddp_order_header.jeopardy_enabled_flag := p8_a4;
    ddp_order_header.execution_mode := p8_a5;
    ddp_order_header.account_number := p8_a6;
    ddp_order_header.cust_account_id := p8_a7;
    ddp_order_header.due_date := rosetta_g_miss_date_in_map(p8_a8);
    ddp_order_header.customer_required_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_order_header.order_type := p8_a10;
    ddp_order_header.order_source := p8_a11;
    ddp_order_header.org_id := p8_a12;
    ddp_order_header.related_order_id := p8_a13;
    ddp_order_header.previous_order_id := p8_a14;
    ddp_order_header.next_order_id := p8_a15;
    ddp_order_header.order_ref_name := p8_a16;
    ddp_order_header.order_ref_value := p8_a17;
    ddp_order_header.order_comments := p8_a18;
    ddp_order_header.order_id := p8_a19;
    ddp_order_header.order_status := p8_a20;
    ddp_order_header.fulfillment_status := p8_a21;
    ddp_order_header.fulfillment_result := p8_a22;
    ddp_order_header.completion_date := rosetta_g_miss_date_in_map(p8_a23);
    ddp_order_header.actual_fulfillment_date := rosetta_g_miss_date_in_map(p8_a24);
    ddp_order_header.customer_id := p8_a25;
    ddp_order_header.customer_name := p8_a26;
    ddp_order_header.telephone_number := p8_a27;
    ddp_order_header.attribute_category := p8_a28;
    ddp_order_header.attribute1 := p8_a29;
    ddp_order_header.attribute2 := p8_a30;
    ddp_order_header.attribute3 := p8_a31;
    ddp_order_header.attribute4 := p8_a32;
    ddp_order_header.attribute5 := p8_a33;
    ddp_order_header.attribute6 := p8_a34;
    ddp_order_header.attribute7 := p8_a35;
    ddp_order_header.attribute8 := p8_a36;
    ddp_order_header.attribute9 := p8_a37;
    ddp_order_header.attribute10 := p8_a38;
    ddp_order_header.attribute11 := p8_a39;
    ddp_order_header.attribute12 := p8_a40;
    ddp_order_header.attribute13 := p8_a41;
    ddp_order_header.attribute14 := p8_a42;
    ddp_order_header.attribute15 := p8_a43;
    ddp_order_header.attribute16 := p8_a44;
    ddp_order_header.attribute17 := p8_a45;
    ddp_order_header.attribute18 := p8_a46;
    ddp_order_header.attribute19 := p8_a47;
    ddp_order_header.attribute20 := p8_a48;

    xdp_types_w.rosetta_table_copy_in_p15(ddp_order_param_list, p9_a0
      , p9_a1
      );

    xdp_types_w.rosetta_table_copy_in_p11(ddp_order_line_list, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      );

    xdp_types_w.rosetta_table_copy_in_p19(ddp_line_param_list, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    xdp_interfaces_pub.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_error_code,
      ddp_order_header,
      ddp_order_param_list,
      ddp_order_line_list,
      ddp_line_param_list,
      x_order_id);

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

  procedure get_order_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  VARCHAR2
    , p_order_number  VARCHAR2
    , p_order_version  VARCHAR2
    , p_order_id  NUMBER
    , p11_a0 OUT NOCOPY  VARCHAR2
    , p11_a1 OUT NOCOPY  VARCHAR2
    , p11_a2 OUT NOCOPY  DATE
    , p11_a3 OUT NOCOPY  NUMBER
    , p11_a4 OUT NOCOPY  VARCHAR2
    , p11_a5 OUT NOCOPY  VARCHAR2
    , p11_a6 OUT NOCOPY  VARCHAR2
    , p11_a7 OUT NOCOPY  NUMBER
    , p11_a8 OUT NOCOPY  DATE
    , p11_a9 OUT NOCOPY  DATE
    , p11_a10 OUT NOCOPY  VARCHAR2
    , p11_a11 OUT NOCOPY  VARCHAR2
    , p11_a12 OUT NOCOPY  NUMBER
    , p11_a13 OUT NOCOPY  NUMBER
    , p11_a14 OUT NOCOPY  NUMBER
    , p11_a15 OUT NOCOPY  NUMBER
    , p11_a16 OUT NOCOPY  VARCHAR2
    , p11_a17 OUT NOCOPY  VARCHAR2
    , p11_a18 OUT NOCOPY  VARCHAR2
    , p11_a19 OUT NOCOPY  NUMBER
    , p11_a20 OUT NOCOPY  VARCHAR2
    , p11_a21 OUT NOCOPY  VARCHAR2
    , p11_a22 OUT NOCOPY  VARCHAR2
    , p11_a23 OUT NOCOPY  DATE
    , p11_a24 OUT NOCOPY  DATE
    , p11_a25 OUT NOCOPY  NUMBER
    , p11_a26 OUT NOCOPY  VARCHAR2
    , p11_a27 OUT NOCOPY  VARCHAR2
    , p11_a28 OUT NOCOPY  VARCHAR2
    , p11_a29 OUT NOCOPY  VARCHAR2
    , p11_a30 OUT NOCOPY  VARCHAR2
    , p11_a31 OUT NOCOPY  VARCHAR2
    , p11_a32 OUT NOCOPY  VARCHAR2
    , p11_a33 OUT NOCOPY  VARCHAR2
    , p11_a34 OUT NOCOPY  VARCHAR2
    , p11_a35 OUT NOCOPY  VARCHAR2
    , p11_a36 OUT NOCOPY  VARCHAR2
    , p11_a37 OUT NOCOPY  VARCHAR2
    , p11_a38 OUT NOCOPY  VARCHAR2
    , p11_a39 OUT NOCOPY  VARCHAR2
    , p11_a40 OUT NOCOPY  VARCHAR2
    , p11_a41 OUT NOCOPY  VARCHAR2
    , p11_a42 OUT NOCOPY  VARCHAR2
    , p11_a43 OUT NOCOPY  VARCHAR2
    , p11_a44 OUT NOCOPY  VARCHAR2
    , p11_a45 OUT NOCOPY  VARCHAR2
    , p11_a46 OUT NOCOPY  VARCHAR2
    , p11_a47 OUT NOCOPY  VARCHAR2
    , p11_a48 OUT NOCOPY  VARCHAR2
    , p12_a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p12_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , p13_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a2 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a5 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a7 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a8 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a10 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a11 OUT NOCOPY JTF_DATE_TABLE
    , p13_a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a14 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a15 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a16 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a17 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a18 OUT NOCOPY JTF_DATE_TABLE
    , p13_a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a20 OUT NOCOPY JTF_DATE_TABLE
    , p13_a21 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a22 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a23 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a24 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a26 OUT NOCOPY JTF_DATE_TABLE
    , p13_a27 OUT NOCOPY JTF_DATE_TABLE
    , p13_a28 OUT NOCOPY JTF_NUMBER_TABLE
    , p13_a29 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a30 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p13_a31 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a32 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a33 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a34 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a35 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a36 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a37 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a38 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a39 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a40 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a41 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a42 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a43 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a44 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a45 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a46 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a47 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a48 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a49 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p13_a50 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p14_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p14_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , p14_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
  )
  as
    ddx_order_header xdp_types.service_order_header;
    ddx_order_param_list xdp_types.service_order_param_list;
    ddx_line_item_list xdp_types.service_order_line_list;
    ddx_line_param_list xdp_types.service_line_param_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    xdp_interfaces_pub.get_order_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_error_code,
      p_order_number,
      p_order_version,
      p_order_id,
      ddx_order_header,
      ddx_order_param_list,
      ddx_line_item_list,
      ddx_line_param_list);

    -- copy data back from the local OUT or IN-OUT args, if any











    p11_a0 := ddx_order_header.order_number;
    p11_a1 := ddx_order_header.order_version;
    p11_a2 := ddx_order_header.required_fulfillment_date;
    p11_a3 := ddx_order_header.priority;
    p11_a4 := ddx_order_header.jeopardy_enabled_flag;
    p11_a5 := ddx_order_header.execution_mode;
    p11_a6 := ddx_order_header.account_number;
    p11_a7 := ddx_order_header.cust_account_id;
    p11_a8 := ddx_order_header.due_date;
    p11_a9 := ddx_order_header.customer_required_date;
    p11_a10 := ddx_order_header.order_type;
    p11_a11 := ddx_order_header.order_source;
    p11_a12 := ddx_order_header.org_id;
    p11_a13 := ddx_order_header.related_order_id;
    p11_a14 := ddx_order_header.previous_order_id;
    p11_a15 := ddx_order_header.next_order_id;
    p11_a16 := ddx_order_header.order_ref_name;
    p11_a17 := ddx_order_header.order_ref_value;
    p11_a18 := ddx_order_header.order_comments;
    p11_a19 := ddx_order_header.order_id;
    p11_a20 := ddx_order_header.order_status;
    p11_a21 := ddx_order_header.fulfillment_status;
    p11_a22 := ddx_order_header.fulfillment_result;
    p11_a23 := ddx_order_header.completion_date;
    p11_a24 := ddx_order_header.actual_fulfillment_date;
    p11_a25 := ddx_order_header.customer_id;
    p11_a26 := ddx_order_header.customer_name;
    p11_a27 := ddx_order_header.telephone_number;
    p11_a28 := ddx_order_header.attribute_category;
    p11_a29 := ddx_order_header.attribute1;
    p11_a30 := ddx_order_header.attribute2;
    p11_a31 := ddx_order_header.attribute3;
    p11_a32 := ddx_order_header.attribute4;
    p11_a33 := ddx_order_header.attribute5;
    p11_a34 := ddx_order_header.attribute6;
    p11_a35 := ddx_order_header.attribute7;
    p11_a36 := ddx_order_header.attribute8;
    p11_a37 := ddx_order_header.attribute9;
    p11_a38 := ddx_order_header.attribute10;
    p11_a39 := ddx_order_header.attribute11;
    p11_a40 := ddx_order_header.attribute12;
    p11_a41 := ddx_order_header.attribute13;
    p11_a42 := ddx_order_header.attribute14;
    p11_a43 := ddx_order_header.attribute15;
    p11_a44 := ddx_order_header.attribute16;
    p11_a45 := ddx_order_header.attribute17;
    p11_a46 := ddx_order_header.attribute18;
    p11_a47 := ddx_order_header.attribute19;
    p11_a48 := ddx_order_header.attribute20;

    xdp_types_w.rosetta_table_copy_out_p15(ddx_order_param_list, p12_a0
      , p12_a1
      );

    xdp_types_w.rosetta_table_copy_out_p11(ddx_line_item_list, p13_a0
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
      , p13_a39
      , p13_a40
      , p13_a41
      , p13_a42
      , p13_a43
      , p13_a44
      , p13_a45
      , p13_a46
      , p13_a47
      , p13_a48
      , p13_a49
      , p13_a50
      );

    xdp_types_w.rosetta_table_copy_out_p19(ddx_line_param_list, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      );
  end;

  procedure get_order_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  VARCHAR2
    , p_order_number  VARCHAR2
    , p_order_version  VARCHAR2
    , p_order_id  NUMBER
    , p11_a0 OUT NOCOPY  NUMBER
    , p11_a1 OUT NOCOPY  VARCHAR2
    , p11_a2 OUT NOCOPY  VARCHAR2
    , p11_a3 OUT NOCOPY  VARCHAR2
    , p11_a4 OUT NOCOPY  VARCHAR2
    , p11_a5 OUT NOCOPY  VARCHAR2
    , p11_a6 OUT NOCOPY  DATE
    , p11_a7 OUT NOCOPY  DATE
  )
  as
    ddx_order_status xdp_types.service_order_status;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    xdp_interfaces_pub.get_order_status(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_error_code,
      p_order_number,
      p_order_version,
      p_order_id,
      ddx_order_status);

    -- copy data back from the local OUT or IN-OUT args, if any











    p11_a0 := ddx_order_status.order_id;
    p11_a1 := ddx_order_status.order_status;
    p11_a2 := ddx_order_status.order_number;
    p11_a3 := ddx_order_status.order_version;
    p11_a4 := ddx_order_status.fulfillment_status;
    p11_a5 := ddx_order_status.fulfillment_result;
    p11_a6 := ddx_order_status.completion_date;
    p11_a7 := ddx_order_status.actual_fulfillment_date;
  end;

--------------------------------------------------------
--This section is hand coded for pl/sql call
--------------------------------------------------------

 FUNCTION STR2DATE(dateStr VARCHAR2)
 RETURN DATE
 AS
 BEGIN
        IF dateStr IS NULL THEN
            RETURN NULL;
        END IF;
        IF LENGTH(dateStr) = 0 THEN
            RETURN NULL;
        END IF;

        RETURN TO_DATE(dateStr,g_date_fmtStr);
 END STR2DATE;

 FUNCTION GET_FIRST_STR(p_inStr IN OUT NOCOPY VARCHAR2,p_delimiter IN VARCHAR2) RETURN VARCHAR2
 AS
        l_index NUMBER;
        l_first_str VARCHAR2(32000);
 BEGIN
        l_index := INSTR(p_inStr,p_delimiter);
        IF l_index = -1 THEN
            l_first_str := p_inStr;
            p_inStr := '';
        ELSE
            l_first_str := substr(p_inStr,1,l_index-1);
            p_inStr := substr(p_inStr,l_index+length(p_delimiter));
        END IF;

        IF length(l_first_str)=0 THEN
            l_first_str := NULL;
        END IF;

        RETURN l_first_str;
 END GET_FIRST_STR;

 FUNCTION GET_STR_IN_CLOB(p_inStr IN CLOB,p_start_index IN OUT NOCOPY NUMBER,p_delimiter IN VARCHAR2) RETURN VARCHAR2
 AS
        l_index NUMBER;
        l_first_str VARCHAR2(32000);
 BEGIN
        l_index := dbms_lob.INSTR(p_inStr,p_delimiter,p_start_index);
        IF l_index = 0 THEN
            l_first_str := dbms_lob.substr(p_inStr);
            p_start_index := dbms_lob.GETLENGTH(p_instr);
        ELSE
            l_first_str := dbms_lob.substr(p_inStr,l_index-p_start_index,p_start_index);
            p_start_index := l_index+length(p_delimiter);
        END IF;

        IF length(l_first_str)=0 THEN
            l_first_str := NULL;
        END IF;
        RETURN l_first_str;
 END GET_STR_IN_CLOB;

 FUNCTION GET_ORDER_PARAM(l_encoded_str IN OUT NOCOPY VARCHAR2) RETURN xdp_types.SERVICE_ORDER_PARAM
 AS
        l_order_param xdp_types.SERVICE_ORDER_PARAM;
        l_param_pair VARCHAR2(32000);
        l_clob CLOB;
        l_index number := 1;
 BEGIN
        l_param_pair := get_first_str(l_encoded_str,lg_delimiter);
        l_order_param.parameter_name := get_first_str(l_param_pair,lg_inline_delimiter);
        l_order_param.parameter_value := get_first_str(l_param_pair,lg_inline_delimiter);
        RETURN l_order_param;
 END GET_ORDER_PARAM;

 FUNCTION GET_ORDER_PARAM(p_clob IN CLOB, p_index in OUT NOCOPY NUMBER) RETURN xdp_types.SERVICE_ORDER_PARAM
 AS
        l_order_param xdp_types.SERVICE_ORDER_PARAM;
        l_param_pair VARCHAR2(32024);
        l_index number := 1;
 BEGIN
        l_param_pair := GET_STR_IN_CLOB(p_clob,p_index,lg_delimiter);
        IF (l_param_pair) is NULL THEN
            RETURN NULL;
        END IF;
        l_order_param.parameter_name := get_first_str(l_param_pair,lg_inline_delimiter);--||'_'||p_index;
        l_order_param.parameter_value := get_first_str(l_param_pair,lg_inline_delimiter);
        RETURN l_order_param;
 END GET_ORDER_PARAM;

 FUNCTION GET_ORDER_LINE_PARAM(p_clob IN CLOB, p_index in OUT NOCOPY NUMBER) RETURN xdp_types.SERVICE_LINE_PARAM
 AS
        l_line_param xdp_types.SERVICE_LINE_PARAM;
        l_param_pair VARCHAR2(32000);
 BEGIN
        l_param_pair := GET_STR_IN_CLOB(p_clob,p_index,lg_delimiter);
        IF (l_param_pair) is NULL THEN
            RETURN NULL;
        END IF;
        l_line_param.line_number := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_name := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_value := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_ref_value := get_first_str(l_param_pair,lg_inline_delimiter);
        RETURN l_line_param;
 END;

 FUNCTION get_order_line_param(l_encoded_str IN OUT NOCOPY varchar2) RETURN xdp_types.SERVICE_LINE_PARAM
 AS
        l_line_param xdp_types.SERVICE_LINE_PARAM;
        l_param_pair VARCHAR2(32000);
 BEGIN
        l_param_pair := get_first_str(l_encoded_str,lg_delimiter);
        IF (l_param_pair) is NULL THEN
            RETURN NULL;
        END IF;
        l_line_param.line_number := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_name := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_value := get_first_str(l_param_pair,lg_inline_delimiter);
        l_line_param.parameter_ref_value := get_first_str(l_param_pair,lg_inline_delimiter);
        RETURN l_line_param;
 END;

 FUNCTION CREATE_ORDER_LINE(l_line_details IN OUT NOCOPY VARCHAR2) RETURN xdp_types.SERVICE_LINE_ITEM
 AS
        l_line_item xdp_types.SERVICE_LINE_ITEM;
 BEGIN
        l_line_item.line_number := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.line_source := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.inventory_item_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.service_item_name := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.version := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.action_code := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.organization_code := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.organization_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.site_use_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.ib_source := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.ib_source_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.required_fulfillment_date := STR2DATE(get_first_str(l_line_details,lg_inline_delimiter));
        l_line_item.fulfillment_required_flag := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.is_package_flag := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.fulfillment_sequence := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.bundle_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.bundle_sequence := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.priority := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.due_date := STR2DATE(get_first_str(l_line_details,lg_inline_delimiter));
        l_line_item.jeopardy_enabled_flag := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.customer_required_date := STR2DATE(get_first_str(l_line_details,lg_inline_delimiter));
        l_line_item.starting_number := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.ending_number := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.line_item_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.workitem_id := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.line_status := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.completion_date := STR2DATE(get_first_str(l_line_details,lg_inline_delimiter));
        l_line_item.actual_fulfillment_date := STR2DATE(get_first_str(l_line_details,lg_inline_delimiter));
        l_line_item.parent_line_number := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.is_virtual_line_flag := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute_category := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute1 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute2 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute3 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute4 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute5 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute6 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute7 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute8 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute9 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute10 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute11 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute12 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute13 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute14 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute15 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute16 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute17 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute18 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute19 := get_first_str(l_line_details,lg_inline_delimiter);
        l_line_item.attribute20 := get_first_str(l_line_details,lg_inline_delimiter);
        RETURN l_line_item;
 END CREATE_ORDER_LINE;

 FUNCTION CREATE_ORDER(l_encoded_str IN OUT NOCOPY VARCHAR2) RETURN XDP_TYPES.SERVICE_ORDER_HEADER
 AS
        ddp_order_header XDP_TYPES.SERVICE_ORDER_HEADER;
 BEGIN
        ddp_order_header.order_number := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_version := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.required_fulfillment_date := STR2DATE(get_first_str(l_encoded_str,lg_inline_delimiter));
        ddp_order_header.priority := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.jeopardy_enabled_flag := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.execution_mode := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.account_number := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.cust_account_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.due_date := STR2DATE(get_first_str(l_encoded_str,lg_inline_delimiter));
        ddp_order_header.customer_required_date := STR2DATE(get_first_str(l_encoded_str,lg_inline_delimiter));
        ddp_order_header.order_type := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_source := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.org_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.related_order_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.previous_order_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.next_order_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_ref_name := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_ref_value := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_comments := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.order_status := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.fulfillment_status := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.fulfillment_result := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.completion_date := STR2DATE(get_first_str(l_encoded_str,lg_inline_delimiter));
        ddp_order_header.actual_fulfillment_date := STR2DATE(get_first_str(l_encoded_str,lg_inline_delimiter));
        ddp_order_header.customer_id := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.customer_name := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.telephone_number := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute_category := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute1 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute2 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute3 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute4 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute5 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute6 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute7 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute8 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute9 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute10 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute11 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute12 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute13 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute14 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute15 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute16 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute17 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute18 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute19 := get_first_str(l_encoded_str,lg_inline_delimiter);
        ddp_order_header.attribute20 := get_first_str(l_encoded_str,lg_inline_delimiter);
        RETURN ddp_order_header;
 END CREATE_ORDER;


 FUNCTION GET_ORDER_LINE(l_encoded_str IN OUT NOCOPY VARCHAR2) RETURN xdp_types.SERVICE_LINE_ITEM
 AS
        l_line_item xdp_types.SERVICE_LINE_ITEM;
        l_line_details VARCHAR2(32000);
 BEGIN
        l_line_details := get_first_str(l_encoded_str,lg_delimiter);
        IF(l_line_details IS NULL) THEN
            RETURN NULL;
        END IF;

        RETURN CREATE_ORDER_LINE(l_line_details);
 END GET_ORDER_LINE;

 FUNCTION GET_ORDER_LINE(p_clob IN CLOB, p_index in OUT NOCOPY NUMBER) RETURN xdp_types.SERVICE_LINE_ITEM
 AS
        l_line_item xdp_types.SERVICE_LINE_ITEM;
        l_line_details VARCHAR2(32000);
 BEGIN
        l_line_details := GET_STR_IN_CLOB(p_clob,p_index,lg_delimiter);
        IF (l_line_details) is NULL THEN
            RETURN NULL;
        END IF;
        RETURN CREATE_ORDER_LINE(l_line_details);
 END GET_ORDER_LINE;

 PROCEDURE PROCESS_ORDER(
    p_api_version  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  VARCHAR2
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  NUMBER
    , p_order_header in VARCHAR2
    , p_order_line in VARCHAR2
    , p_order_params in VARCHAR2
    , p_order_line_params in VARCHAR2
    , x_order_id OUT NOCOPY  NUMBER
  )
  AS
    ddp_order_header xdp_types.service_order_header;
    ddp_order_param_list xdp_types.service_order_param_list;
    ddp_order_line_list xdp_types.service_order_line_list;
    ddp_line_param_list xdp_types.service_line_param_list;
    ddindx BINARY_INTEGER;
    indx BINARY_INTEGER;
    l_pointer BINARY_INTEGER := 1;
    l_index number := 1;
    l_encoded_str VARCHAR2(32000);
 BEGIN

    l_encoded_str := p_order_header;
    ddp_order_header := create_order(l_encoded_str);
    l_pointer := 1;
    IF length(p_order_params) > 0 THEN
        l_encoded_str := p_order_params;
        LOOP
            ddp_order_param_list(l_pointer) := get_order_param(l_encoded_str);
            l_pointer := l_pointer+1;
            IF(length(l_encoded_str) = 0) OR (l_encoded_str is null)THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    l_pointer := 1;
    IF length(p_order_line_params) > 0 THEN
        l_encoded_str := p_order_line_params;
        LOOP
            ddp_line_param_list(l_pointer) := get_order_line_param(l_encoded_str);
            l_pointer := l_pointer+1;
            IF(length(l_encoded_str) = 0) OR (l_encoded_str IS NULL) THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    l_pointer := 1;
    IF length(p_order_line) > 0 THEN
        l_encoded_str := p_order_line;
        LOOP
            ddp_order_line_list(l_pointer) := get_order_line(l_encoded_str);
            l_pointer := l_pointer+1;
            IF(length(l_encoded_str) = 0) OR (l_encoded_str IS NULL) THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    xdp_interfaces_pub.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_error_code,
      ddp_order_header,
      ddp_order_param_list,
      ddp_order_line_list,
      ddp_line_param_list,
      x_order_id);
    -- copy data back from the local OUT or IN-OUT args, if any
  END PROCESS_ORDER;

 PROCEDURE PROCESS_ORDER(
    p_api_version  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  VARCHAR2
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  NUMBER
    , p_order_header in VARCHAR2
    , x_order_id OUT NOCOPY  NUMBER
  )
  AS
 BEGIN
     PROCESS_ORDER(
        p_api_version
        , p_init_msg_list
        , p_commit
        , p_validation_level
        , x_return_status
        , x_msg_count
        , x_msg_data
        , x_error_code
        , p_order_header
        , lg_line_clob
        , lg_order_param_clob
        , lg_line_param_clob
        , x_order_id
      );
 END;

 PROCEDURE GET_CLOBS(
    x_line OUT NOCOPY CLOB,
    x_order_param OUT NOCOPY CLOB,
    x_line_param OUT NOCOPY CLOB
 ) AS
 BEGIN
    dbms_lob.createtemporary(lg_order_param_clob,true);
    dbms_lob.open(lg_order_param_clob,dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(lg_line_clob,true);
    dbms_lob.open(lg_line_clob,dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(lg_line_param_clob,true);
    dbms_lob.open(lg_line_param_clob,dbms_lob.lob_readwrite);
    x_line := lg_line_clob;
    x_order_param := lg_order_param_clob;
    x_line_param := lg_line_param_clob;
 END GET_CLOBS;

 PROCEDURE FREE_CLOBS AS
 BEGIN
      dbms_lob.freetemporary(lg_order_param_clob);
      dbms_lob.freetemporary(lg_line_clob);
      dbms_lob.freetemporary(lg_line_param_clob);
 END FREE_CLOBS;

 PROCEDURE PROCESS_ORDER(
    p_api_version  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  VARCHAR2
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_error_code OUT NOCOPY  NUMBER
    , p_order_header in VARCHAR2
    , p_order_line in CLOB
    , p_order_params in CLOB
    , p_order_line_params in CLOB
    , x_order_id OUT NOCOPY  NUMBER
  )
  AS
    ddp_order_header xdp_types.service_order_header;
    ddp_order_param_list xdp_types.service_order_param_list;
    ddp_order_line_list xdp_types.service_order_line_list;
    ddp_line_param_list xdp_types.service_line_param_list;
    ddindx BINARY_INTEGER;
    indx BINARY_INTEGER;
    l_pointer BINARY_INTEGER := 1;
    l_clob CLOB;
    l_index number := 1;
    l_encoded_str VARCHAR2(32000);
    l_clob_length NUMBER;
 BEGIN
    l_encoded_str := p_order_header;
    ddp_order_header := create_order(l_encoded_str);
    l_pointer := 1;
    l_clob_length := DBMS_LOB.GETLENGTH(p_order_params);
    IF l_clob_length > 0 THEN
        l_index := 1;
        LOOP
            ddp_order_param_list(l_pointer) := get_order_param(p_order_params,l_index);
            l_pointer := l_pointer+1;
            IF l_index >= l_clob_length THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    l_pointer := 1;
    l_clob_length := DBMS_LOB.GETLENGTH(p_order_line_params);
    IF l_clob_length > 0 THEN
        l_index := 1;
        LOOP
            ddp_line_param_list(l_pointer) := get_order_line_param(p_order_line_params,l_index);
            l_pointer := l_pointer+1;
            IF(l_index >= l_clob_length) THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    l_pointer := 1;
    l_clob_length := DBMS_LOB.GETLENGTH(p_order_line);
    IF l_clob_length > 0 THEN
        l_index := 1;
        LOOP
            ddp_order_line_list(l_pointer) := get_order_line(p_order_line,l_index);
            l_pointer := l_pointer+1;
            IF(l_index >= l_clob_length) THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

    xdp_interfaces_pub.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_error_code,
      ddp_order_header,
      ddp_order_param_list,
      ddp_order_line_list,
      ddp_line_param_list,
      x_order_id);

    FREE_CLOBS();

 END PROCESS_ORDER;

end xdp_interfaces_pub_w;

/
