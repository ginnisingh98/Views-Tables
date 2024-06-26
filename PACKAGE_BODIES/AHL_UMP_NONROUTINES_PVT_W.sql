--------------------------------------------------------
--  DDL for Package Body AHL_UMP_NONROUTINES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_NONROUTINES_PVT_W" as
  /* $Header: AHLWNRTB.pls 120.0.12010000.2 2010/03/24 10:30:47 ajprasan ship $ */
  procedure create_sr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  NUMBER
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  DATE
    , p9_a28 in out nocopy  DATE
    , p9_a29 in out nocopy  NUMBER
    , p9_a30 in out nocopy  NUMBER
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  NUMBER
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  NUMBER
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  NUMBER
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  NUMBER
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  NUMBER
    , p9_a45 in out nocopy  VARCHAR2
    , p9_a46 in out nocopy  NUMBER
    , p9_a47 in out nocopy  VARCHAR2
    , p9_a48 in out nocopy  VARCHAR2
    , p9_a49 in out nocopy  NUMBER
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
  )

  as
    ddp_x_nonroutine_rec ahl_ump_nonroutines_pvt.nonroutine_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_nonroutine_rec.incident_id := p9_a0;
    ddp_x_nonroutine_rec.incident_number := p9_a1;
    ddp_x_nonroutine_rec.incident_object_version_number := p9_a2;
    ddp_x_nonroutine_rec.incident_date := p9_a3;
    ddp_x_nonroutine_rec.type_id := p9_a4;
    ddp_x_nonroutine_rec.type_name := p9_a5;
    ddp_x_nonroutine_rec.status_id := p9_a6;
    ddp_x_nonroutine_rec.status_name := p9_a7;
    ddp_x_nonroutine_rec.severity_id := p9_a8;
    ddp_x_nonroutine_rec.severity_name := p9_a9;
    ddp_x_nonroutine_rec.urgency_id := p9_a10;
    ddp_x_nonroutine_rec.urgency_name := p9_a11;
    ddp_x_nonroutine_rec.customer_type := p9_a12;
    ddp_x_nonroutine_rec.customer_id := p9_a13;
    ddp_x_nonroutine_rec.customer_number := p9_a14;
    ddp_x_nonroutine_rec.customer_name := p9_a15;
    ddp_x_nonroutine_rec.contact_type := p9_a16;
    ddp_x_nonroutine_rec.contact_id := p9_a17;
    ddp_x_nonroutine_rec.contact_number := p9_a18;
    ddp_x_nonroutine_rec.contact_name := p9_a19;
    ddp_x_nonroutine_rec.instance_id := p9_a20;
    ddp_x_nonroutine_rec.instance_number := p9_a21;
    ddp_x_nonroutine_rec.problem_code := p9_a22;
    ddp_x_nonroutine_rec.problem_meaning := p9_a23;
    ddp_x_nonroutine_rec.problem_summary := p9_a24;
    ddp_x_nonroutine_rec.resolution_code := p9_a25;
    ddp_x_nonroutine_rec.resolution_meaning := p9_a26;
    ddp_x_nonroutine_rec.expected_resolution_date := p9_a27;
    ddp_x_nonroutine_rec.actual_resolution_date := p9_a28;
    ddp_x_nonroutine_rec.unit_effectivity_id := p9_a29;
    ddp_x_nonroutine_rec.ue_object_version_number := p9_a30;
    ddp_x_nonroutine_rec.log_series_code := p9_a31;
    ddp_x_nonroutine_rec.log_series_meaning := p9_a32;
    ddp_x_nonroutine_rec.log_series_number := p9_a33;
    ddp_x_nonroutine_rec.flight_number := p9_a34;
    ddp_x_nonroutine_rec.mel_cdl_type_code := p9_a35;
    ddp_x_nonroutine_rec.mel_cdl_type_meaning := p9_a36;
    ddp_x_nonroutine_rec.position_path_id := p9_a37;
    ddp_x_nonroutine_rec.ata_code := p9_a38;
    ddp_x_nonroutine_rec.ata_meaning := p9_a39;
    ddp_x_nonroutine_rec.clear_station_org_id := p9_a40;
    ddp_x_nonroutine_rec.clear_station_org := p9_a41;
    ddp_x_nonroutine_rec.clear_station_dept_id := p9_a42;
    ddp_x_nonroutine_rec.clear_station_dept := p9_a43;
    ddp_x_nonroutine_rec.unit_config_header_id := p9_a44;
    ddp_x_nonroutine_rec.unit_name := p9_a45;
    ddp_x_nonroutine_rec.inventory_item_id := p9_a46;
    ddp_x_nonroutine_rec.item_number := p9_a47;
    ddp_x_nonroutine_rec.serial_number := p9_a48;
    ddp_x_nonroutine_rec.ata_sequence_id := p9_a49;
    ddp_x_nonroutine_rec.mel_cdl_qual_flag := p9_a50;
    ddp_x_nonroutine_rec.request_context := p9_a51;
    ddp_x_nonroutine_rec.request_attribute1 := p9_a52;
    ddp_x_nonroutine_rec.request_attribute2 := p9_a53;
    ddp_x_nonroutine_rec.request_attribute3 := p9_a54;
    ddp_x_nonroutine_rec.request_attribute4 := p9_a55;
    ddp_x_nonroutine_rec.request_attribute5 := p9_a56;
    ddp_x_nonroutine_rec.request_attribute6 := p9_a57;
    ddp_x_nonroutine_rec.request_attribute7 := p9_a58;
    ddp_x_nonroutine_rec.request_attribute8 := p9_a59;
    ddp_x_nonroutine_rec.request_attribute9 := p9_a60;
    ddp_x_nonroutine_rec.request_attribute10 := p9_a61;
    ddp_x_nonroutine_rec.request_attribute11 := p9_a62;
    ddp_x_nonroutine_rec.request_attribute12 := p9_a63;
    ddp_x_nonroutine_rec.request_attribute13 := p9_a64;
    ddp_x_nonroutine_rec.request_attribute14 := p9_a65;
    ddp_x_nonroutine_rec.request_attribute15 := p9_a66;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_nonroutines_pvt.create_sr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_nonroutine_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_nonroutine_rec.incident_id;
    p9_a1 := ddp_x_nonroutine_rec.incident_number;
    p9_a2 := ddp_x_nonroutine_rec.incident_object_version_number;
    p9_a3 := ddp_x_nonroutine_rec.incident_date;
    p9_a4 := ddp_x_nonroutine_rec.type_id;
    p9_a5 := ddp_x_nonroutine_rec.type_name;
    p9_a6 := ddp_x_nonroutine_rec.status_id;
    p9_a7 := ddp_x_nonroutine_rec.status_name;
    p9_a8 := ddp_x_nonroutine_rec.severity_id;
    p9_a9 := ddp_x_nonroutine_rec.severity_name;
    p9_a10 := ddp_x_nonroutine_rec.urgency_id;
    p9_a11 := ddp_x_nonroutine_rec.urgency_name;
    p9_a12 := ddp_x_nonroutine_rec.customer_type;
    p9_a13 := ddp_x_nonroutine_rec.customer_id;
    p9_a14 := ddp_x_nonroutine_rec.customer_number;
    p9_a15 := ddp_x_nonroutine_rec.customer_name;
    p9_a16 := ddp_x_nonroutine_rec.contact_type;
    p9_a17 := ddp_x_nonroutine_rec.contact_id;
    p9_a18 := ddp_x_nonroutine_rec.contact_number;
    p9_a19 := ddp_x_nonroutine_rec.contact_name;
    p9_a20 := ddp_x_nonroutine_rec.instance_id;
    p9_a21 := ddp_x_nonroutine_rec.instance_number;
    p9_a22 := ddp_x_nonroutine_rec.problem_code;
    p9_a23 := ddp_x_nonroutine_rec.problem_meaning;
    p9_a24 := ddp_x_nonroutine_rec.problem_summary;
    p9_a25 := ddp_x_nonroutine_rec.resolution_code;
    p9_a26 := ddp_x_nonroutine_rec.resolution_meaning;
    p9_a27 := ddp_x_nonroutine_rec.expected_resolution_date;
    p9_a28 := ddp_x_nonroutine_rec.actual_resolution_date;
    p9_a29 := ddp_x_nonroutine_rec.unit_effectivity_id;
    p9_a30 := ddp_x_nonroutine_rec.ue_object_version_number;
    p9_a31 := ddp_x_nonroutine_rec.log_series_code;
    p9_a32 := ddp_x_nonroutine_rec.log_series_meaning;
    p9_a33 := ddp_x_nonroutine_rec.log_series_number;
    p9_a34 := ddp_x_nonroutine_rec.flight_number;
    p9_a35 := ddp_x_nonroutine_rec.mel_cdl_type_code;
    p9_a36 := ddp_x_nonroutine_rec.mel_cdl_type_meaning;
    p9_a37 := ddp_x_nonroutine_rec.position_path_id;
    p9_a38 := ddp_x_nonroutine_rec.ata_code;
    p9_a39 := ddp_x_nonroutine_rec.ata_meaning;
    p9_a40 := ddp_x_nonroutine_rec.clear_station_org_id;
    p9_a41 := ddp_x_nonroutine_rec.clear_station_org;
    p9_a42 := ddp_x_nonroutine_rec.clear_station_dept_id;
    p9_a43 := ddp_x_nonroutine_rec.clear_station_dept;
    p9_a44 := ddp_x_nonroutine_rec.unit_config_header_id;
    p9_a45 := ddp_x_nonroutine_rec.unit_name;
    p9_a46 := ddp_x_nonroutine_rec.inventory_item_id;
    p9_a47 := ddp_x_nonroutine_rec.item_number;
    p9_a48 := ddp_x_nonroutine_rec.serial_number;
    p9_a49 := ddp_x_nonroutine_rec.ata_sequence_id;
    p9_a50 := ddp_x_nonroutine_rec.mel_cdl_qual_flag;
    p9_a51 := ddp_x_nonroutine_rec.request_context;
    p9_a52 := ddp_x_nonroutine_rec.request_attribute1;
    p9_a53 := ddp_x_nonroutine_rec.request_attribute2;
    p9_a54 := ddp_x_nonroutine_rec.request_attribute3;
    p9_a55 := ddp_x_nonroutine_rec.request_attribute4;
    p9_a56 := ddp_x_nonroutine_rec.request_attribute5;
    p9_a57 := ddp_x_nonroutine_rec.request_attribute6;
    p9_a58 := ddp_x_nonroutine_rec.request_attribute7;
    p9_a59 := ddp_x_nonroutine_rec.request_attribute8;
    p9_a60 := ddp_x_nonroutine_rec.request_attribute9;
    p9_a61 := ddp_x_nonroutine_rec.request_attribute10;
    p9_a62 := ddp_x_nonroutine_rec.request_attribute11;
    p9_a63 := ddp_x_nonroutine_rec.request_attribute12;
    p9_a64 := ddp_x_nonroutine_rec.request_attribute13;
    p9_a65 := ddp_x_nonroutine_rec.request_attribute14;
    p9_a66 := ddp_x_nonroutine_rec.request_attribute15;
  end;

  procedure update_sr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  NUMBER
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  DATE
    , p9_a28 in out nocopy  DATE
    , p9_a29 in out nocopy  NUMBER
    , p9_a30 in out nocopy  NUMBER
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  NUMBER
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  NUMBER
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  NUMBER
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  NUMBER
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  NUMBER
    , p9_a45 in out nocopy  VARCHAR2
    , p9_a46 in out nocopy  NUMBER
    , p9_a47 in out nocopy  VARCHAR2
    , p9_a48 in out nocopy  VARCHAR2
    , p9_a49 in out nocopy  NUMBER
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
  )

  as
    ddp_x_nonroutine_rec ahl_ump_nonroutines_pvt.nonroutine_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_nonroutine_rec.incident_id := p9_a0;
    ddp_x_nonroutine_rec.incident_number := p9_a1;
    ddp_x_nonroutine_rec.incident_object_version_number := p9_a2;
    ddp_x_nonroutine_rec.incident_date := p9_a3;
    ddp_x_nonroutine_rec.type_id := p9_a4;
    ddp_x_nonroutine_rec.type_name := p9_a5;
    ddp_x_nonroutine_rec.status_id := p9_a6;
    ddp_x_nonroutine_rec.status_name := p9_a7;
    ddp_x_nonroutine_rec.severity_id := p9_a8;
    ddp_x_nonroutine_rec.severity_name := p9_a9;
    ddp_x_nonroutine_rec.urgency_id := p9_a10;
    ddp_x_nonroutine_rec.urgency_name := p9_a11;
    ddp_x_nonroutine_rec.customer_type := p9_a12;
    ddp_x_nonroutine_rec.customer_id := p9_a13;
    ddp_x_nonroutine_rec.customer_number := p9_a14;
    ddp_x_nonroutine_rec.customer_name := p9_a15;
    ddp_x_nonroutine_rec.contact_type := p9_a16;
    ddp_x_nonroutine_rec.contact_id := p9_a17;
    ddp_x_nonroutine_rec.contact_number := p9_a18;
    ddp_x_nonroutine_rec.contact_name := p9_a19;
    ddp_x_nonroutine_rec.instance_id := p9_a20;
    ddp_x_nonroutine_rec.instance_number := p9_a21;
    ddp_x_nonroutine_rec.problem_code := p9_a22;
    ddp_x_nonroutine_rec.problem_meaning := p9_a23;
    ddp_x_nonroutine_rec.problem_summary := p9_a24;
    ddp_x_nonroutine_rec.resolution_code := p9_a25;
    ddp_x_nonroutine_rec.resolution_meaning := p9_a26;
    ddp_x_nonroutine_rec.expected_resolution_date := p9_a27;
    ddp_x_nonroutine_rec.actual_resolution_date := p9_a28;
    ddp_x_nonroutine_rec.unit_effectivity_id := p9_a29;
    ddp_x_nonroutine_rec.ue_object_version_number := p9_a30;
    ddp_x_nonroutine_rec.log_series_code := p9_a31;
    ddp_x_nonroutine_rec.log_series_meaning := p9_a32;
    ddp_x_nonroutine_rec.log_series_number := p9_a33;
    ddp_x_nonroutine_rec.flight_number := p9_a34;
    ddp_x_nonroutine_rec.mel_cdl_type_code := p9_a35;
    ddp_x_nonroutine_rec.mel_cdl_type_meaning := p9_a36;
    ddp_x_nonroutine_rec.position_path_id := p9_a37;
    ddp_x_nonroutine_rec.ata_code := p9_a38;
    ddp_x_nonroutine_rec.ata_meaning := p9_a39;
    ddp_x_nonroutine_rec.clear_station_org_id := p9_a40;
    ddp_x_nonroutine_rec.clear_station_org := p9_a41;
    ddp_x_nonroutine_rec.clear_station_dept_id := p9_a42;
    ddp_x_nonroutine_rec.clear_station_dept := p9_a43;
    ddp_x_nonroutine_rec.unit_config_header_id := p9_a44;
    ddp_x_nonroutine_rec.unit_name := p9_a45;
    ddp_x_nonroutine_rec.inventory_item_id := p9_a46;
    ddp_x_nonroutine_rec.item_number := p9_a47;
    ddp_x_nonroutine_rec.serial_number := p9_a48;
    ddp_x_nonroutine_rec.ata_sequence_id := p9_a49;
    ddp_x_nonroutine_rec.mel_cdl_qual_flag := p9_a50;
    ddp_x_nonroutine_rec.request_context := p9_a51;
    ddp_x_nonroutine_rec.request_attribute1 := p9_a52;
    ddp_x_nonroutine_rec.request_attribute2 := p9_a53;
    ddp_x_nonroutine_rec.request_attribute3 := p9_a54;
    ddp_x_nonroutine_rec.request_attribute4 := p9_a55;
    ddp_x_nonroutine_rec.request_attribute5 := p9_a56;
    ddp_x_nonroutine_rec.request_attribute6 := p9_a57;
    ddp_x_nonroutine_rec.request_attribute7 := p9_a58;
    ddp_x_nonroutine_rec.request_attribute8 := p9_a59;
    ddp_x_nonroutine_rec.request_attribute9 := p9_a60;
    ddp_x_nonroutine_rec.request_attribute10 := p9_a61;
    ddp_x_nonroutine_rec.request_attribute11 := p9_a62;
    ddp_x_nonroutine_rec.request_attribute12 := p9_a63;
    ddp_x_nonroutine_rec.request_attribute13 := p9_a64;
    ddp_x_nonroutine_rec.request_attribute14 := p9_a65;
    ddp_x_nonroutine_rec.request_attribute15 := p9_a66;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_nonroutines_pvt.update_sr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_nonroutine_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_nonroutine_rec.incident_id;
    p9_a1 := ddp_x_nonroutine_rec.incident_number;
    p9_a2 := ddp_x_nonroutine_rec.incident_object_version_number;
    p9_a3 := ddp_x_nonroutine_rec.incident_date;
    p9_a4 := ddp_x_nonroutine_rec.type_id;
    p9_a5 := ddp_x_nonroutine_rec.type_name;
    p9_a6 := ddp_x_nonroutine_rec.status_id;
    p9_a7 := ddp_x_nonroutine_rec.status_name;
    p9_a8 := ddp_x_nonroutine_rec.severity_id;
    p9_a9 := ddp_x_nonroutine_rec.severity_name;
    p9_a10 := ddp_x_nonroutine_rec.urgency_id;
    p9_a11 := ddp_x_nonroutine_rec.urgency_name;
    p9_a12 := ddp_x_nonroutine_rec.customer_type;
    p9_a13 := ddp_x_nonroutine_rec.customer_id;
    p9_a14 := ddp_x_nonroutine_rec.customer_number;
    p9_a15 := ddp_x_nonroutine_rec.customer_name;
    p9_a16 := ddp_x_nonroutine_rec.contact_type;
    p9_a17 := ddp_x_nonroutine_rec.contact_id;
    p9_a18 := ddp_x_nonroutine_rec.contact_number;
    p9_a19 := ddp_x_nonroutine_rec.contact_name;
    p9_a20 := ddp_x_nonroutine_rec.instance_id;
    p9_a21 := ddp_x_nonroutine_rec.instance_number;
    p9_a22 := ddp_x_nonroutine_rec.problem_code;
    p9_a23 := ddp_x_nonroutine_rec.problem_meaning;
    p9_a24 := ddp_x_nonroutine_rec.problem_summary;
    p9_a25 := ddp_x_nonroutine_rec.resolution_code;
    p9_a26 := ddp_x_nonroutine_rec.resolution_meaning;
    p9_a27 := ddp_x_nonroutine_rec.expected_resolution_date;
    p9_a28 := ddp_x_nonroutine_rec.actual_resolution_date;
    p9_a29 := ddp_x_nonroutine_rec.unit_effectivity_id;
    p9_a30 := ddp_x_nonroutine_rec.ue_object_version_number;
    p9_a31 := ddp_x_nonroutine_rec.log_series_code;
    p9_a32 := ddp_x_nonroutine_rec.log_series_meaning;
    p9_a33 := ddp_x_nonroutine_rec.log_series_number;
    p9_a34 := ddp_x_nonroutine_rec.flight_number;
    p9_a35 := ddp_x_nonroutine_rec.mel_cdl_type_code;
    p9_a36 := ddp_x_nonroutine_rec.mel_cdl_type_meaning;
    p9_a37 := ddp_x_nonroutine_rec.position_path_id;
    p9_a38 := ddp_x_nonroutine_rec.ata_code;
    p9_a39 := ddp_x_nonroutine_rec.ata_meaning;
    p9_a40 := ddp_x_nonroutine_rec.clear_station_org_id;
    p9_a41 := ddp_x_nonroutine_rec.clear_station_org;
    p9_a42 := ddp_x_nonroutine_rec.clear_station_dept_id;
    p9_a43 := ddp_x_nonroutine_rec.clear_station_dept;
    p9_a44 := ddp_x_nonroutine_rec.unit_config_header_id;
    p9_a45 := ddp_x_nonroutine_rec.unit_name;
    p9_a46 := ddp_x_nonroutine_rec.inventory_item_id;
    p9_a47 := ddp_x_nonroutine_rec.item_number;
    p9_a48 := ddp_x_nonroutine_rec.serial_number;
    p9_a49 := ddp_x_nonroutine_rec.ata_sequence_id;
    p9_a50 := ddp_x_nonroutine_rec.mel_cdl_qual_flag;
    p9_a51 := ddp_x_nonroutine_rec.request_context;
    p9_a52 := ddp_x_nonroutine_rec.request_attribute1;
    p9_a53 := ddp_x_nonroutine_rec.request_attribute2;
    p9_a54 := ddp_x_nonroutine_rec.request_attribute3;
    p9_a55 := ddp_x_nonroutine_rec.request_attribute4;
    p9_a56 := ddp_x_nonroutine_rec.request_attribute5;
    p9_a57 := ddp_x_nonroutine_rec.request_attribute6;
    p9_a58 := ddp_x_nonroutine_rec.request_attribute7;
    p9_a59 := ddp_x_nonroutine_rec.request_attribute8;
    p9_a60 := ddp_x_nonroutine_rec.request_attribute9;
    p9_a61 := ddp_x_nonroutine_rec.request_attribute10;
    p9_a62 := ddp_x_nonroutine_rec.request_attribute11;
    p9_a63 := ddp_x_nonroutine_rec.request_attribute12;
    p9_a64 := ddp_x_nonroutine_rec.request_attribute13;
    p9_a65 := ddp_x_nonroutine_rec.request_attribute14;
    p9_a66 := ddp_x_nonroutine_rec.request_attribute15;
  end;

end ahl_ump_nonroutines_pvt_w;

/
