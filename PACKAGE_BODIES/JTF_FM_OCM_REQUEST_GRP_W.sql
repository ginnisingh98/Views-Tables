--------------------------------------------------------
--  DDL for Package Body JTF_FM_OCM_REQUEST_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_OCM_REQUEST_GRP_W" as
  /* $Header: jtfgfmowb.pls 120.1 2005/07/02 00:43:47 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure create_fulfillment(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  NUMBER
    , p5_a18  VARCHAR2
    , p5_a19  JTF_NUMBER_TABLE
    , p5_a20  JTF_VARCHAR2_TABLE_1000
    , p5_a21  JTF_VARCHAR2_TABLE_1000
    , p5_a22  JTF_VARCHAR2_TABLE_1000
    , p5_a23  JTF_VARCHAR2_TABLE_1000
    , p5_a24  JTF_VARCHAR2_TABLE_1000
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p_request_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  VARCHAR2
    , x_request_history_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_order_header_rec jtf_fulfillment_pub.order_header_rec_type;
    ddp_order_line_tbl jtf_fulfillment_pub.order_line_tbl_type;
    ddp_fulfill_electronic_rec jtf_fm_ocm_request_grp.fulfill_electronic_rec_type;
    ddx_order_header_rec aso_order_int.order_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_order_header_rec.cust_party_id := rosetta_g_miss_num_map(p3_a0);
    ddp_order_header_rec.cust_account_id := rosetta_g_miss_num_map(p3_a1);
    ddp_order_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p3_a2);
    ddp_order_header_rec.inv_party_id := rosetta_g_miss_num_map(p3_a3);
    ddp_order_header_rec.inv_party_site_id := rosetta_g_miss_num_map(p3_a4);
    ddp_order_header_rec.ship_party_site_id := rosetta_g_miss_num_map(p3_a5);
    ddp_order_header_rec.quote_source_code := p3_a6;
    ddp_order_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p3_a7);
    ddp_order_header_rec.order_type_id := rosetta_g_miss_num_map(p3_a8);
    ddp_order_header_rec.employee_id := rosetta_g_miss_num_map(p3_a9);
    ddp_order_header_rec.collateral_id := rosetta_g_miss_num_map(p3_a10);
    ddp_order_header_rec.cover_letter_id := rosetta_g_miss_num_map(p3_a11);
    ddp_order_header_rec.uom_code := p3_a12;
    ddp_order_header_rec.line_category_code := p3_a13;
    ddp_order_header_rec.inv_organization_id := rosetta_g_miss_num_map(p3_a14);

    jtf_fulfillment_pub_w.rosetta_table_copy_in_p2(ddp_order_line_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      );

    ddp_fulfill_electronic_rec.template_id := rosetta_g_miss_num_map(p5_a0);
    ddp_fulfill_electronic_rec.version_id := rosetta_g_miss_num_map(p5_a1);
    ddp_fulfill_electronic_rec.object_type := p5_a2;
    ddp_fulfill_electronic_rec.object_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fulfill_electronic_rec.source_code := p5_a4;
    ddp_fulfill_electronic_rec.source_code_id := rosetta_g_miss_num_map(p5_a5);
    ddp_fulfill_electronic_rec.requestor_type := p5_a6;
    ddp_fulfill_electronic_rec.requestor_id := rosetta_g_miss_num_map(p5_a7);
    ddp_fulfill_electronic_rec.server_group := rosetta_g_miss_num_map(p5_a8);
    ddp_fulfill_electronic_rec.schedule_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_fulfill_electronic_rec.media_types := p5_a10;
    ddp_fulfill_electronic_rec.archive := p5_a11;
    ddp_fulfill_electronic_rec.log_user_ih := p5_a12;
    ddp_fulfill_electronic_rec.request_type := p5_a13;
    ddp_fulfill_electronic_rec.language_code := p5_a14;
    ddp_fulfill_electronic_rec.profile_id := rosetta_g_miss_num_map(p5_a15);
    ddp_fulfill_electronic_rec.order_id := rosetta_g_miss_num_map(p5_a16);
    ddp_fulfill_electronic_rec.collateral_id := rosetta_g_miss_num_map(p5_a17);
    ddp_fulfill_electronic_rec.subject := p5_a18;
    jtf_fm_request_grp_w.rosetta_table_copy_in_p5(ddp_fulfill_electronic_rec.party_id, p5_a19);
    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fulfill_electronic_rec.email, p5_a20);
    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fulfill_electronic_rec.fax, p5_a21);
    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fulfill_electronic_rec.printer, p5_a22);
    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fulfill_electronic_rec.bind_values, p5_a23);
    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fulfill_electronic_rec.bind_names, p5_a24);
    ddp_fulfill_electronic_rec.email_text := p5_a25;
    ddp_fulfill_electronic_rec.content_name := p5_a26;
    ddp_fulfill_electronic_rec.content_type := p5_a27;
    ddp_fulfill_electronic_rec.extended_header := p5_a28;
    ddp_fulfill_electronic_rec.stop_list_bypass := p5_a29;
    ddp_fulfill_electronic_rec.email_format := p5_a30;







    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_ocm_request_grp.create_fulfillment(p_init_msg_list,
      p_api_version,
      p_commit,
      ddp_order_header_rec,
      ddp_order_line_tbl,
      ddp_fulfill_electronic_rec,
      p_request_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_order_header_rec,
      x_request_history_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_order_header_rec.order_number);
    p10_a1 := rosetta_g_miss_num_map(ddx_order_header_rec.order_header_id);
    p10_a2 := rosetta_g_miss_num_map(ddx_order_header_rec.quote_header_id);
    p10_a3 := ddx_order_header_rec.status;

  end;

end jtf_fm_ocm_request_grp_w;

/
