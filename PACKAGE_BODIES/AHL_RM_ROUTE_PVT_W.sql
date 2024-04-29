--------------------------------------------------------
--  DDL for Package Body AHL_RM_ROUTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ROUTE_PVT_W" as
  /* $Header: AHLWROMB.pls 120.1.12010000.3 2008/11/23 14:31:55 bachandr ship $ */
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

  procedure process_route(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  DATE
    , p9_a11 in out nocopy  NUMBER
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  NUMBER
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  NUMBER
    , p9_a23 in out nocopy  NUMBER
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  NUMBER
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  NUMBER
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  NUMBER
    , p9_a33 in out nocopy  DATE
    , p9_a34 in out nocopy  DATE
    , p9_a35 in out nocopy  NUMBER
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  VARCHAR2
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  VARCHAR2
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  VARCHAR2
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  VARCHAR2
    , p9_a45 in out nocopy  VARCHAR2
    , p9_a46 in out nocopy  VARCHAR2
    , p9_a47 in out nocopy  VARCHAR2
    , p9_a48 in out nocopy  VARCHAR2
    , p9_a49 in out nocopy  VARCHAR2
    , p9_a50 in out nocopy  VARCHAR2
    , p9_a51 in out nocopy  VARCHAR2
    , p9_a52 in out nocopy  VARCHAR2
    , p9_a53 in out nocopy  VARCHAR2
    , p9_a54 in out nocopy  VARCHAR2
    , p9_a55 in out nocopy  VARCHAR2
    , p9_a56 in out nocopy  VARCHAR2
    , p9_a57 in out nocopy  VARCHAR2
    , p9_a58 in out nocopy  VARCHAR2
    , p9_a59 in out nocopy  VARCHAR2
    , p9_a60 in out nocopy  VARCHAR2
    , p9_a61 in out nocopy  VARCHAR2
    , p9_a62 in out nocopy  VARCHAR2
    , p9_a63 in out nocopy  VARCHAR2
    , p9_a64 in out nocopy  VARCHAR2
    , p9_a65 in out nocopy  VARCHAR2
    , p9_a66 in out nocopy  VARCHAR2
    , p9_a67 in out nocopy  VARCHAR2
    , p9_a68 in out nocopy  VARCHAR2
    , p9_a69 in out nocopy  VARCHAR2
    , p9_a70 in out nocopy  VARCHAR2
    , p9_a71 in out nocopy  VARCHAR2
    , p9_a72 in out nocopy  VARCHAR2
    , p9_a73 in out nocopy  DATE
    , p9_a74 in out nocopy  NUMBER
    , p9_a75 in out nocopy  DATE
    , p9_a76 in out nocopy  NUMBER
    , p9_a77 in out nocopy  NUMBER
    , p9_a78 in out nocopy  VARCHAR2
  )

  as
    ddp_x_route_rec ahl_rm_route_pvt.route_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_route_rec.route_id := p9_a0;
    ddp_x_route_rec.object_version_number := p9_a1;
    ddp_x_route_rec.route_no := p9_a2;
    ddp_x_route_rec.title := p9_a3;
    ddp_x_route_rec.route_type_code := p9_a4;
    ddp_x_route_rec.route_type := p9_a5;
    ddp_x_route_rec.model_code := p9_a6;
    ddp_x_route_rec.model_meaning := p9_a7;
    ddp_x_route_rec.enigma_doc_id := p9_a8;
    ddp_x_route_rec.enigma_route_id := p9_a9;
    ddp_x_route_rec.enigma_publish_date := rosetta_g_miss_date_in_map(p9_a10);
    ddp_x_route_rec.file_id := p9_a11;
    ddp_x_route_rec.process_code := p9_a12;
    ddp_x_route_rec.process := p9_a13;
    ddp_x_route_rec.product_type_code := p9_a14;
    ddp_x_route_rec.product_type := p9_a15;
    ddp_x_route_rec.operator_party_id := p9_a16;
    ddp_x_route_rec.operator_name := p9_a17;
    ddp_x_route_rec.zone_code := p9_a18;
    ddp_x_route_rec.zone := p9_a19;
    ddp_x_route_rec.sub_zone_code := p9_a20;
    ddp_x_route_rec.sub_zone := p9_a21;
    ddp_x_route_rec.service_item_id := p9_a22;
    ddp_x_route_rec.service_item_org_id := p9_a23;
    ddp_x_route_rec.service_item_number := p9_a24;
    ddp_x_route_rec.accounting_class_code := p9_a25;
    ddp_x_route_rec.accounting_class_org_id := p9_a26;
    ddp_x_route_rec.accounting_class := p9_a27;
    ddp_x_route_rec.task_template_group_id := p9_a28;
    ddp_x_route_rec.task_template_group := p9_a29;
    ddp_x_route_rec.qa_inspection_type := p9_a30;
    ddp_x_route_rec.qa_inspection_type_desc := p9_a31;
    ddp_x_route_rec.time_span := p9_a32;
    ddp_x_route_rec.active_start_date := rosetta_g_miss_date_in_map(p9_a33);
    ddp_x_route_rec.active_end_date := rosetta_g_miss_date_in_map(p9_a34);
    ddp_x_route_rec.revision_number := p9_a35;
    ddp_x_route_rec.revision_status_code := p9_a36;
    ddp_x_route_rec.revision_status := p9_a37;
    ddp_x_route_rec.unit_receipt_update_flag := p9_a38;
    ddp_x_route_rec.unit_receipt_update := p9_a39;
    ddp_x_route_rec.remarks := p9_a40;
    ddp_x_route_rec.revision_notes := p9_a41;
    ddp_x_route_rec.segment1 := p9_a42;
    ddp_x_route_rec.segment2 := p9_a43;
    ddp_x_route_rec.segment3 := p9_a44;
    ddp_x_route_rec.segment4 := p9_a45;
    ddp_x_route_rec.segment5 := p9_a46;
    ddp_x_route_rec.segment6 := p9_a47;
    ddp_x_route_rec.segment7 := p9_a48;
    ddp_x_route_rec.segment8 := p9_a49;
    ddp_x_route_rec.segment9 := p9_a50;
    ddp_x_route_rec.segment10 := p9_a51;
    ddp_x_route_rec.segment11 := p9_a52;
    ddp_x_route_rec.segment12 := p9_a53;
    ddp_x_route_rec.segment13 := p9_a54;
    ddp_x_route_rec.segment14 := p9_a55;
    ddp_x_route_rec.segment15 := p9_a56;
    ddp_x_route_rec.attribute_category := p9_a57;
    ddp_x_route_rec.attribute1 := p9_a58;
    ddp_x_route_rec.attribute2 := p9_a59;
    ddp_x_route_rec.attribute3 := p9_a60;
    ddp_x_route_rec.attribute4 := p9_a61;
    ddp_x_route_rec.attribute5 := p9_a62;
    ddp_x_route_rec.attribute6 := p9_a63;
    ddp_x_route_rec.attribute7 := p9_a64;
    ddp_x_route_rec.attribute8 := p9_a65;
    ddp_x_route_rec.attribute9 := p9_a66;
    ddp_x_route_rec.attribute10 := p9_a67;
    ddp_x_route_rec.attribute11 := p9_a68;
    ddp_x_route_rec.attribute12 := p9_a69;
    ddp_x_route_rec.attribute13 := p9_a70;
    ddp_x_route_rec.attribute14 := p9_a71;
    ddp_x_route_rec.attribute15 := p9_a72;
    ddp_x_route_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a73);
    ddp_x_route_rec.last_updated_by := p9_a74;
    ddp_x_route_rec.creation_date := rosetta_g_miss_date_in_map(p9_a75);
    ddp_x_route_rec.created_by := p9_a76;
    ddp_x_route_rec.last_update_login := p9_a77;
    ddp_x_route_rec.dml_operation := p9_a78;

    -- here's the delegated call to the old PL/SQL routine
    ahl_rm_route_pvt.process_route(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_route_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_route_rec.route_id;
    p9_a1 := ddp_x_route_rec.object_version_number;
    p9_a2 := ddp_x_route_rec.route_no;
    p9_a3 := ddp_x_route_rec.title;
    p9_a4 := ddp_x_route_rec.route_type_code;
    p9_a5 := ddp_x_route_rec.route_type;
    p9_a6 := ddp_x_route_rec.model_code;
    p9_a7 := ddp_x_route_rec.model_meaning;
    p9_a8 := ddp_x_route_rec.enigma_doc_id;
    p9_a9 := ddp_x_route_rec.enigma_route_id;
    p9_a10 := ddp_x_route_rec.enigma_publish_date;
    p9_a11 := ddp_x_route_rec.file_id;
    p9_a12 := ddp_x_route_rec.process_code;
    p9_a13 := ddp_x_route_rec.process;
    p9_a14 := ddp_x_route_rec.product_type_code;
    p9_a15 := ddp_x_route_rec.product_type;
    p9_a16 := ddp_x_route_rec.operator_party_id;
    p9_a17 := ddp_x_route_rec.operator_name;
    p9_a18 := ddp_x_route_rec.zone_code;
    p9_a19 := ddp_x_route_rec.zone;
    p9_a20 := ddp_x_route_rec.sub_zone_code;
    p9_a21 := ddp_x_route_rec.sub_zone;
    p9_a22 := ddp_x_route_rec.service_item_id;
    p9_a23 := ddp_x_route_rec.service_item_org_id;
    p9_a24 := ddp_x_route_rec.service_item_number;
    p9_a25 := ddp_x_route_rec.accounting_class_code;
    p9_a26 := ddp_x_route_rec.accounting_class_org_id;
    p9_a27 := ddp_x_route_rec.accounting_class;
    p9_a28 := ddp_x_route_rec.task_template_group_id;
    p9_a29 := ddp_x_route_rec.task_template_group;
    p9_a30 := ddp_x_route_rec.qa_inspection_type;
    p9_a31 := ddp_x_route_rec.qa_inspection_type_desc;
    p9_a32 := ddp_x_route_rec.time_span;
    p9_a33 := ddp_x_route_rec.active_start_date;
    p9_a34 := ddp_x_route_rec.active_end_date;
    p9_a35 := ddp_x_route_rec.revision_number;
    p9_a36 := ddp_x_route_rec.revision_status_code;
    p9_a37 := ddp_x_route_rec.revision_status;
    p9_a38 := ddp_x_route_rec.unit_receipt_update_flag;
    p9_a39 := ddp_x_route_rec.unit_receipt_update;
    p9_a40 := ddp_x_route_rec.remarks;
    p9_a41 := ddp_x_route_rec.revision_notes;
    p9_a42 := ddp_x_route_rec.segment1;
    p9_a43 := ddp_x_route_rec.segment2;
    p9_a44 := ddp_x_route_rec.segment3;
    p9_a45 := ddp_x_route_rec.segment4;
    p9_a46 := ddp_x_route_rec.segment5;
    p9_a47 := ddp_x_route_rec.segment6;
    p9_a48 := ddp_x_route_rec.segment7;
    p9_a49 := ddp_x_route_rec.segment8;
    p9_a50 := ddp_x_route_rec.segment9;
    p9_a51 := ddp_x_route_rec.segment10;
    p9_a52 := ddp_x_route_rec.segment11;
    p9_a53 := ddp_x_route_rec.segment12;
    p9_a54 := ddp_x_route_rec.segment13;
    p9_a55 := ddp_x_route_rec.segment14;
    p9_a56 := ddp_x_route_rec.segment15;
    p9_a57 := ddp_x_route_rec.attribute_category;
    p9_a58 := ddp_x_route_rec.attribute1;
    p9_a59 := ddp_x_route_rec.attribute2;
    p9_a60 := ddp_x_route_rec.attribute3;
    p9_a61 := ddp_x_route_rec.attribute4;
    p9_a62 := ddp_x_route_rec.attribute5;
    p9_a63 := ddp_x_route_rec.attribute6;
    p9_a64 := ddp_x_route_rec.attribute7;
    p9_a65 := ddp_x_route_rec.attribute8;
    p9_a66 := ddp_x_route_rec.attribute9;
    p9_a67 := ddp_x_route_rec.attribute10;
    p9_a68 := ddp_x_route_rec.attribute11;
    p9_a69 := ddp_x_route_rec.attribute12;
    p9_a70 := ddp_x_route_rec.attribute13;
    p9_a71 := ddp_x_route_rec.attribute14;
    p9_a72 := ddp_x_route_rec.attribute15;
    p9_a73 := ddp_x_route_rec.last_update_date;
    p9_a74 := ddp_x_route_rec.last_updated_by;
    p9_a75 := ddp_x_route_rec.creation_date;
    p9_a76 := ddp_x_route_rec.created_by;
    p9_a77 := ddp_x_route_rec.last_update_login;
    p9_a78 := ddp_x_route_rec.dml_operation;
  end;

end ahl_rm_route_pvt_w;

/