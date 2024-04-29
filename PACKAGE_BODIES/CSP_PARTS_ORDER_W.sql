--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_ORDER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_ORDER_W" as
  /* $Header: csprqordwb.pls 120.0.12010000.4 2012/02/13 17:29:46 htank noship $ */
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

  procedure process_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p_process_type  VARCHAR2
    , p_book_order  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_table, p4_a0
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
      );






    -- here's the delegated call to the old PL/SQL routine
    csp_parts_order.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_table,
      p_process_type,
      p_book_order,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_table, p4_a0
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
      );





  end;

  procedure process_purchase_req(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_table, p4_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_parts_order.process_purchase_req(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_table, p4_a0
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
      );



  end;

  procedure cancel_order(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_VARCHAR2_TABLE_300
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_DATE_TABLE
    , p1_a16 JTF_DATE_TABLE
    , p1_a17 JTF_DATE_TABLE
    , p1_a18 JTF_NUMBER_TABLE
    , p1_a19 JTF_NUMBER_TABLE
    , p1_a20 JTF_VARCHAR2_TABLE_100
    , p1_a21 JTF_VARCHAR2_TABLE_100
    , p1_a22 JTF_VARCHAR2_TABLE_100
    , p1_a23 JTF_VARCHAR2_TABLE_100
    , p1_a24 JTF_VARCHAR2_TABLE_100
    , p1_a25 JTF_VARCHAR2_TABLE_100
    , p1_a26 JTF_VARCHAR2_TABLE_200
    , p1_a27 JTF_VARCHAR2_TABLE_200
    , p1_a28 JTF_VARCHAR2_TABLE_200
    , p1_a29 JTF_VARCHAR2_TABLE_200
    , p1_a30 JTF_VARCHAR2_TABLE_200
    , p1_a31 JTF_VARCHAR2_TABLE_200
    , p1_a32 JTF_VARCHAR2_TABLE_200
    , p1_a33 JTF_VARCHAR2_TABLE_200
    , p1_a34 JTF_VARCHAR2_TABLE_200
    , p1_a35 JTF_VARCHAR2_TABLE_200
    , p1_a36 JTF_VARCHAR2_TABLE_200
    , p1_a37 JTF_VARCHAR2_TABLE_200
    , p1_a38 JTF_VARCHAR2_TABLE_200
    , p1_a39 JTF_VARCHAR2_TABLE_200
    , p1_a40 JTF_VARCHAR2_TABLE_200
    , p_process_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_header_rec csp_parts_requirement.header_rec_type;
    ddp_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_header_rec.requisition_header_id := p0_a0;
    ddp_header_rec.requisition_number := p0_a1;
    ddp_header_rec.description := p0_a2;
    ddp_header_rec.order_header_id := p0_a3;
    ddp_header_rec.order_type_id := p0_a4;
    ddp_header_rec.ship_to_location_id := p0_a5;
    ddp_header_rec.shipping_method_code := p0_a6;
    ddp_header_rec.task_id := p0_a7;
    ddp_header_rec.task_assignment_id := p0_a8;
    ddp_header_rec.need_by_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_header_rec.dest_organization_id := p0_a10;
    ddp_header_rec.dest_subinventory := p0_a11;
    ddp_header_rec.operation := p0_a12;
    ddp_header_rec.requirement_header_id := p0_a13;
    ddp_header_rec.change_reason := p0_a14;
    ddp_header_rec.change_comments := p0_a15;
    ddp_header_rec.resource_type := p0_a16;
    ddp_header_rec.resource_id := p0_a17;
    ddp_header_rec.incident_id := p0_a18;
    ddp_header_rec.address_type := p0_a19;
    ddp_header_rec.justification := p0_a20;
    ddp_header_rec.note_to_buyer := p0_a21;
    ddp_header_rec.note1_id := p0_a22;
    ddp_header_rec.note1_title := p0_a23;
    ddp_header_rec.called_from := p0_a24;
    ddp_header_rec.suggested_vendor_id := p0_a25;
    ddp_header_rec.suggested_vendor_name := p0_a26;
    ddp_header_rec.attribute_category := p0_a27;
    ddp_header_rec.attribute1 := p0_a28;
    ddp_header_rec.attribute2 := p0_a29;
    ddp_header_rec.attribute3 := p0_a30;
    ddp_header_rec.attribute4 := p0_a31;
    ddp_header_rec.attribute5 := p0_a32;
    ddp_header_rec.attribute6 := p0_a33;
    ddp_header_rec.attribute7 := p0_a34;
    ddp_header_rec.attribute8 := p0_a35;
    ddp_header_rec.attribute9 := p0_a36;
    ddp_header_rec.attribute10 := p0_a37;
    ddp_header_rec.attribute11 := p0_a38;
    ddp_header_rec.attribute12 := p0_a39;
    ddp_header_rec.attribute13 := p0_a40;
    ddp_header_rec.attribute14 := p0_a41;
    ddp_header_rec.attribute15 := p0_a42;
    ddp_header_rec.ship_to_contact_id := p0_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddp_line_table, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      );





    -- here's the delegated call to the old PL/SQL routine
    csp_parts_order.cancel_order(ddp_header_rec,
      ddp_line_table,
      p_process_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end csp_parts_order_w;

/
