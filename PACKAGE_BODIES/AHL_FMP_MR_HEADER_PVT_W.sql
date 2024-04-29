--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_HEADER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_HEADER_PVT_W" as
  /* $Header: AHLWMRHB.pls 120.1.12010000.2 2008/12/29 01:06:14 sracha ship $ */
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

  procedure create_mr_header(p_api_version  NUMBER
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
    , p9_a2 in out nocopy  DATE
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  DATE
    , p9_a23 in out nocopy  DATE
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  NUMBER
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  VARCHAR2
    , p9_a38 in out nocopy  NUMBER
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  VARCHAR2
    , p9_a41 in out nocopy  NUMBER
    , p9_a42 in out nocopy  VARCHAR2
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  VARCHAR2
    , p9_a45 in out nocopy  NUMBER
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
  )

  as
    ddp_x_mr_header_rec ahl_fmp_mr_header_pvt.mr_header_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_mr_header_rec.mr_header_id := p9_a0;
    ddp_x_mr_header_rec.object_version_number := p9_a1;
    ddp_x_mr_header_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a2);
    ddp_x_mr_header_rec.last_updated_by := p9_a3;
    ddp_x_mr_header_rec.creation_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_x_mr_header_rec.created_by := p9_a5;
    ddp_x_mr_header_rec.last_update_login := p9_a6;
    ddp_x_mr_header_rec.title := p9_a7;
    ddp_x_mr_header_rec.revision := p9_a8;
    ddp_x_mr_header_rec.version_number := p9_a9;
    ddp_x_mr_header_rec.category_code := p9_a10;
    ddp_x_mr_header_rec.category := p9_a11;
    ddp_x_mr_header_rec.program_type_code := p9_a12;
    ddp_x_mr_header_rec.program_type := p9_a13;
    ddp_x_mr_header_rec.program_subtype_code := p9_a14;
    ddp_x_mr_header_rec.program_subtype := p9_a15;
    ddp_x_mr_header_rec.service_type_code := p9_a16;
    ddp_x_mr_header_rec.service_type := p9_a17;
    ddp_x_mr_header_rec.mr_status_code := p9_a18;
    ddp_x_mr_header_rec.mr_status := p9_a19;
    ddp_x_mr_header_rec.implement_status_code := p9_a20;
    ddp_x_mr_header_rec.implement_status := p9_a21;
    ddp_x_mr_header_rec.effective_from := rosetta_g_miss_date_in_map(p9_a22);
    ddp_x_mr_header_rec.effective_to := rosetta_g_miss_date_in_map(p9_a23);
    ddp_x_mr_header_rec.repetitive_flag := p9_a24;
    ddp_x_mr_header_rec.repetitive := p9_a25;
    ddp_x_mr_header_rec.show_repetitive_code := p9_a26;
    ddp_x_mr_header_rec.show_repetitive := p9_a27;
    ddp_x_mr_header_rec.whichever_first_code := p9_a28;
    ddp_x_mr_header_rec.whichever_first := p9_a29;
    ddp_x_mr_header_rec.copy_accomplishment_flag := p9_a30;
    ddp_x_mr_header_rec.copy_accomplishment := p9_a31;
    ddp_x_mr_header_rec.preceding_mr_header_id := p9_a32;
    ddp_x_mr_header_rec.preceding_mr_title := p9_a33;
    ddp_x_mr_header_rec.preceding_mr_revision := p9_a34;
    ddp_x_mr_header_rec.description := p9_a35;
    ddp_x_mr_header_rec.comments := p9_a36;
    ddp_x_mr_header_rec.superuser_role := p9_a37;
    ddp_x_mr_header_rec.service_request_template_id := p9_a38;
    ddp_x_mr_header_rec.type_code := p9_a39;
    ddp_x_mr_header_rec.type_code_meaning := p9_a40;
    ddp_x_mr_header_rec.down_time := p9_a41;
    ddp_x_mr_header_rec.uom_code := p9_a42;
    ddp_x_mr_header_rec.uom_meaning := p9_a43;
    ddp_x_mr_header_rec.billing_item := p9_a44;
    ddp_x_mr_header_rec.billing_item_id := p9_a45;
    ddp_x_mr_header_rec.qa_inspection_type := p9_a46;
    ddp_x_mr_header_rec.qa_inspection_type_code := p9_a47;
    ddp_x_mr_header_rec.space_category := p9_a48;
    ddp_x_mr_header_rec.space_category_code := p9_a49;
    ddp_x_mr_header_rec.auto_signoff_flag := p9_a50;
    ddp_x_mr_header_rec.copy_init_accompl_flag := p9_a51;
    ddp_x_mr_header_rec.copy_deferrals_flag := p9_a52;
    ddp_x_mr_header_rec.attribute_category := p9_a53;
    ddp_x_mr_header_rec.attribute1 := p9_a54;
    ddp_x_mr_header_rec.attribute2 := p9_a55;
    ddp_x_mr_header_rec.attribute3 := p9_a56;
    ddp_x_mr_header_rec.attribute4 := p9_a57;
    ddp_x_mr_header_rec.attribute5 := p9_a58;
    ddp_x_mr_header_rec.attribute6 := p9_a59;
    ddp_x_mr_header_rec.attribute7 := p9_a60;
    ddp_x_mr_header_rec.attribute8 := p9_a61;
    ddp_x_mr_header_rec.attribute9 := p9_a62;
    ddp_x_mr_header_rec.attribute10 := p9_a63;
    ddp_x_mr_header_rec.attribute11 := p9_a64;
    ddp_x_mr_header_rec.attribute12 := p9_a65;
    ddp_x_mr_header_rec.attribute13 := p9_a66;
    ddp_x_mr_header_rec.attribute14 := p9_a67;
    ddp_x_mr_header_rec.attribute15 := p9_a68;
    ddp_x_mr_header_rec.dml_operation := p9_a69;

    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_mr_header_pvt.create_mr_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mr_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_mr_header_rec.mr_header_id;
    p9_a1 := ddp_x_mr_header_rec.object_version_number;
    p9_a2 := ddp_x_mr_header_rec.last_update_date;
    p9_a3 := ddp_x_mr_header_rec.last_updated_by;
    p9_a4 := ddp_x_mr_header_rec.creation_date;
    p9_a5 := ddp_x_mr_header_rec.created_by;
    p9_a6 := ddp_x_mr_header_rec.last_update_login;
    p9_a7 := ddp_x_mr_header_rec.title;
    p9_a8 := ddp_x_mr_header_rec.revision;
    p9_a9 := ddp_x_mr_header_rec.version_number;
    p9_a10 := ddp_x_mr_header_rec.category_code;
    p9_a11 := ddp_x_mr_header_rec.category;
    p9_a12 := ddp_x_mr_header_rec.program_type_code;
    p9_a13 := ddp_x_mr_header_rec.program_type;
    p9_a14 := ddp_x_mr_header_rec.program_subtype_code;
    p9_a15 := ddp_x_mr_header_rec.program_subtype;
    p9_a16 := ddp_x_mr_header_rec.service_type_code;
    p9_a17 := ddp_x_mr_header_rec.service_type;
    p9_a18 := ddp_x_mr_header_rec.mr_status_code;
    p9_a19 := ddp_x_mr_header_rec.mr_status;
    p9_a20 := ddp_x_mr_header_rec.implement_status_code;
    p9_a21 := ddp_x_mr_header_rec.implement_status;
    p9_a22 := ddp_x_mr_header_rec.effective_from;
    p9_a23 := ddp_x_mr_header_rec.effective_to;
    p9_a24 := ddp_x_mr_header_rec.repetitive_flag;
    p9_a25 := ddp_x_mr_header_rec.repetitive;
    p9_a26 := ddp_x_mr_header_rec.show_repetitive_code;
    p9_a27 := ddp_x_mr_header_rec.show_repetitive;
    p9_a28 := ddp_x_mr_header_rec.whichever_first_code;
    p9_a29 := ddp_x_mr_header_rec.whichever_first;
    p9_a30 := ddp_x_mr_header_rec.copy_accomplishment_flag;
    p9_a31 := ddp_x_mr_header_rec.copy_accomplishment;
    p9_a32 := ddp_x_mr_header_rec.preceding_mr_header_id;
    p9_a33 := ddp_x_mr_header_rec.preceding_mr_title;
    p9_a34 := ddp_x_mr_header_rec.preceding_mr_revision;
    p9_a35 := ddp_x_mr_header_rec.description;
    p9_a36 := ddp_x_mr_header_rec.comments;
    p9_a37 := ddp_x_mr_header_rec.superuser_role;
    p9_a38 := ddp_x_mr_header_rec.service_request_template_id;
    p9_a39 := ddp_x_mr_header_rec.type_code;
    p9_a40 := ddp_x_mr_header_rec.type_code_meaning;
    p9_a41 := ddp_x_mr_header_rec.down_time;
    p9_a42 := ddp_x_mr_header_rec.uom_code;
    p9_a43 := ddp_x_mr_header_rec.uom_meaning;
    p9_a44 := ddp_x_mr_header_rec.billing_item;
    p9_a45 := ddp_x_mr_header_rec.billing_item_id;
    p9_a46 := ddp_x_mr_header_rec.qa_inspection_type;
    p9_a47 := ddp_x_mr_header_rec.qa_inspection_type_code;
    p9_a48 := ddp_x_mr_header_rec.space_category;
    p9_a49 := ddp_x_mr_header_rec.space_category_code;
    p9_a50 := ddp_x_mr_header_rec.auto_signoff_flag;
    p9_a51 := ddp_x_mr_header_rec.copy_init_accompl_flag;
    p9_a52 := ddp_x_mr_header_rec.copy_deferrals_flag;
    p9_a53 := ddp_x_mr_header_rec.attribute_category;
    p9_a54 := ddp_x_mr_header_rec.attribute1;
    p9_a55 := ddp_x_mr_header_rec.attribute2;
    p9_a56 := ddp_x_mr_header_rec.attribute3;
    p9_a57 := ddp_x_mr_header_rec.attribute4;
    p9_a58 := ddp_x_mr_header_rec.attribute5;
    p9_a59 := ddp_x_mr_header_rec.attribute6;
    p9_a60 := ddp_x_mr_header_rec.attribute7;
    p9_a61 := ddp_x_mr_header_rec.attribute8;
    p9_a62 := ddp_x_mr_header_rec.attribute9;
    p9_a63 := ddp_x_mr_header_rec.attribute10;
    p9_a64 := ddp_x_mr_header_rec.attribute11;
    p9_a65 := ddp_x_mr_header_rec.attribute12;
    p9_a66 := ddp_x_mr_header_rec.attribute13;
    p9_a67 := ddp_x_mr_header_rec.attribute14;
    p9_a68 := ddp_x_mr_header_rec.attribute15;
    p9_a69 := ddp_x_mr_header_rec.dml_operation;
  end;

  procedure update_mr_header(p_api_version  NUMBER
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
    , p9_a2 in out nocopy  DATE
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  DATE
    , p9_a23 in out nocopy  DATE
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  NUMBER
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  VARCHAR2
    , p9_a38 in out nocopy  NUMBER
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  VARCHAR2
    , p9_a41 in out nocopy  NUMBER
    , p9_a42 in out nocopy  VARCHAR2
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  VARCHAR2
    , p9_a45 in out nocopy  NUMBER
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
  )

  as
    ddp_x_mr_header_rec ahl_fmp_mr_header_pvt.mr_header_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_mr_header_rec.mr_header_id := p9_a0;
    ddp_x_mr_header_rec.object_version_number := p9_a1;
    ddp_x_mr_header_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a2);
    ddp_x_mr_header_rec.last_updated_by := p9_a3;
    ddp_x_mr_header_rec.creation_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_x_mr_header_rec.created_by := p9_a5;
    ddp_x_mr_header_rec.last_update_login := p9_a6;
    ddp_x_mr_header_rec.title := p9_a7;
    ddp_x_mr_header_rec.revision := p9_a8;
    ddp_x_mr_header_rec.version_number := p9_a9;
    ddp_x_mr_header_rec.category_code := p9_a10;
    ddp_x_mr_header_rec.category := p9_a11;
    ddp_x_mr_header_rec.program_type_code := p9_a12;
    ddp_x_mr_header_rec.program_type := p9_a13;
    ddp_x_mr_header_rec.program_subtype_code := p9_a14;
    ddp_x_mr_header_rec.program_subtype := p9_a15;
    ddp_x_mr_header_rec.service_type_code := p9_a16;
    ddp_x_mr_header_rec.service_type := p9_a17;
    ddp_x_mr_header_rec.mr_status_code := p9_a18;
    ddp_x_mr_header_rec.mr_status := p9_a19;
    ddp_x_mr_header_rec.implement_status_code := p9_a20;
    ddp_x_mr_header_rec.implement_status := p9_a21;
    ddp_x_mr_header_rec.effective_from := rosetta_g_miss_date_in_map(p9_a22);
    ddp_x_mr_header_rec.effective_to := rosetta_g_miss_date_in_map(p9_a23);
    ddp_x_mr_header_rec.repetitive_flag := p9_a24;
    ddp_x_mr_header_rec.repetitive := p9_a25;
    ddp_x_mr_header_rec.show_repetitive_code := p9_a26;
    ddp_x_mr_header_rec.show_repetitive := p9_a27;
    ddp_x_mr_header_rec.whichever_first_code := p9_a28;
    ddp_x_mr_header_rec.whichever_first := p9_a29;
    ddp_x_mr_header_rec.copy_accomplishment_flag := p9_a30;
    ddp_x_mr_header_rec.copy_accomplishment := p9_a31;
    ddp_x_mr_header_rec.preceding_mr_header_id := p9_a32;
    ddp_x_mr_header_rec.preceding_mr_title := p9_a33;
    ddp_x_mr_header_rec.preceding_mr_revision := p9_a34;
    ddp_x_mr_header_rec.description := p9_a35;
    ddp_x_mr_header_rec.comments := p9_a36;
    ddp_x_mr_header_rec.superuser_role := p9_a37;
    ddp_x_mr_header_rec.service_request_template_id := p9_a38;
    ddp_x_mr_header_rec.type_code := p9_a39;
    ddp_x_mr_header_rec.type_code_meaning := p9_a40;
    ddp_x_mr_header_rec.down_time := p9_a41;
    ddp_x_mr_header_rec.uom_code := p9_a42;
    ddp_x_mr_header_rec.uom_meaning := p9_a43;
    ddp_x_mr_header_rec.billing_item := p9_a44;
    ddp_x_mr_header_rec.billing_item_id := p9_a45;
    ddp_x_mr_header_rec.qa_inspection_type := p9_a46;
    ddp_x_mr_header_rec.qa_inspection_type_code := p9_a47;
    ddp_x_mr_header_rec.space_category := p9_a48;
    ddp_x_mr_header_rec.space_category_code := p9_a49;
    ddp_x_mr_header_rec.auto_signoff_flag := p9_a50;
    ddp_x_mr_header_rec.copy_init_accompl_flag := p9_a51;
    ddp_x_mr_header_rec.copy_deferrals_flag := p9_a52;
    ddp_x_mr_header_rec.attribute_category := p9_a53;
    ddp_x_mr_header_rec.attribute1 := p9_a54;
    ddp_x_mr_header_rec.attribute2 := p9_a55;
    ddp_x_mr_header_rec.attribute3 := p9_a56;
    ddp_x_mr_header_rec.attribute4 := p9_a57;
    ddp_x_mr_header_rec.attribute5 := p9_a58;
    ddp_x_mr_header_rec.attribute6 := p9_a59;
    ddp_x_mr_header_rec.attribute7 := p9_a60;
    ddp_x_mr_header_rec.attribute8 := p9_a61;
    ddp_x_mr_header_rec.attribute9 := p9_a62;
    ddp_x_mr_header_rec.attribute10 := p9_a63;
    ddp_x_mr_header_rec.attribute11 := p9_a64;
    ddp_x_mr_header_rec.attribute12 := p9_a65;
    ddp_x_mr_header_rec.attribute13 := p9_a66;
    ddp_x_mr_header_rec.attribute14 := p9_a67;
    ddp_x_mr_header_rec.attribute15 := p9_a68;
    ddp_x_mr_header_rec.dml_operation := p9_a69;

    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_mr_header_pvt.update_mr_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mr_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_mr_header_rec.mr_header_id;
    p9_a1 := ddp_x_mr_header_rec.object_version_number;
    p9_a2 := ddp_x_mr_header_rec.last_update_date;
    p9_a3 := ddp_x_mr_header_rec.last_updated_by;
    p9_a4 := ddp_x_mr_header_rec.creation_date;
    p9_a5 := ddp_x_mr_header_rec.created_by;
    p9_a6 := ddp_x_mr_header_rec.last_update_login;
    p9_a7 := ddp_x_mr_header_rec.title;
    p9_a8 := ddp_x_mr_header_rec.revision;
    p9_a9 := ddp_x_mr_header_rec.version_number;
    p9_a10 := ddp_x_mr_header_rec.category_code;
    p9_a11 := ddp_x_mr_header_rec.category;
    p9_a12 := ddp_x_mr_header_rec.program_type_code;
    p9_a13 := ddp_x_mr_header_rec.program_type;
    p9_a14 := ddp_x_mr_header_rec.program_subtype_code;
    p9_a15 := ddp_x_mr_header_rec.program_subtype;
    p9_a16 := ddp_x_mr_header_rec.service_type_code;
    p9_a17 := ddp_x_mr_header_rec.service_type;
    p9_a18 := ddp_x_mr_header_rec.mr_status_code;
    p9_a19 := ddp_x_mr_header_rec.mr_status;
    p9_a20 := ddp_x_mr_header_rec.implement_status_code;
    p9_a21 := ddp_x_mr_header_rec.implement_status;
    p9_a22 := ddp_x_mr_header_rec.effective_from;
    p9_a23 := ddp_x_mr_header_rec.effective_to;
    p9_a24 := ddp_x_mr_header_rec.repetitive_flag;
    p9_a25 := ddp_x_mr_header_rec.repetitive;
    p9_a26 := ddp_x_mr_header_rec.show_repetitive_code;
    p9_a27 := ddp_x_mr_header_rec.show_repetitive;
    p9_a28 := ddp_x_mr_header_rec.whichever_first_code;
    p9_a29 := ddp_x_mr_header_rec.whichever_first;
    p9_a30 := ddp_x_mr_header_rec.copy_accomplishment_flag;
    p9_a31 := ddp_x_mr_header_rec.copy_accomplishment;
    p9_a32 := ddp_x_mr_header_rec.preceding_mr_header_id;
    p9_a33 := ddp_x_mr_header_rec.preceding_mr_title;
    p9_a34 := ddp_x_mr_header_rec.preceding_mr_revision;
    p9_a35 := ddp_x_mr_header_rec.description;
    p9_a36 := ddp_x_mr_header_rec.comments;
    p9_a37 := ddp_x_mr_header_rec.superuser_role;
    p9_a38 := ddp_x_mr_header_rec.service_request_template_id;
    p9_a39 := ddp_x_mr_header_rec.type_code;
    p9_a40 := ddp_x_mr_header_rec.type_code_meaning;
    p9_a41 := ddp_x_mr_header_rec.down_time;
    p9_a42 := ddp_x_mr_header_rec.uom_code;
    p9_a43 := ddp_x_mr_header_rec.uom_meaning;
    p9_a44 := ddp_x_mr_header_rec.billing_item;
    p9_a45 := ddp_x_mr_header_rec.billing_item_id;
    p9_a46 := ddp_x_mr_header_rec.qa_inspection_type;
    p9_a47 := ddp_x_mr_header_rec.qa_inspection_type_code;
    p9_a48 := ddp_x_mr_header_rec.space_category;
    p9_a49 := ddp_x_mr_header_rec.space_category_code;
    p9_a50 := ddp_x_mr_header_rec.auto_signoff_flag;
    p9_a51 := ddp_x_mr_header_rec.copy_init_accompl_flag;
    p9_a52 := ddp_x_mr_header_rec.copy_deferrals_flag;
    p9_a53 := ddp_x_mr_header_rec.attribute_category;
    p9_a54 := ddp_x_mr_header_rec.attribute1;
    p9_a55 := ddp_x_mr_header_rec.attribute2;
    p9_a56 := ddp_x_mr_header_rec.attribute3;
    p9_a57 := ddp_x_mr_header_rec.attribute4;
    p9_a58 := ddp_x_mr_header_rec.attribute5;
    p9_a59 := ddp_x_mr_header_rec.attribute6;
    p9_a60 := ddp_x_mr_header_rec.attribute7;
    p9_a61 := ddp_x_mr_header_rec.attribute8;
    p9_a62 := ddp_x_mr_header_rec.attribute9;
    p9_a63 := ddp_x_mr_header_rec.attribute10;
    p9_a64 := ddp_x_mr_header_rec.attribute11;
    p9_a65 := ddp_x_mr_header_rec.attribute12;
    p9_a66 := ddp_x_mr_header_rec.attribute13;
    p9_a67 := ddp_x_mr_header_rec.attribute14;
    p9_a68 := ddp_x_mr_header_rec.attribute15;
    p9_a69 := ddp_x_mr_header_rec.dml_operation;
  end;

end ahl_fmp_mr_header_pvt_w;

/
