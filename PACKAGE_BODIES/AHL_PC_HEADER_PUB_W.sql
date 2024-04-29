--------------------------------------------------------
--  DDL for Package Body AHL_PC_HEADER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_HEADER_PUB_W" as
  /* $Header: AHLWPCHB.pls 115.7 2002/12/02 14:57:18 pbarman noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure process_pc_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_pc_header_rec ahl_pc_header_pub.pc_header_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_pc_header_rec.pc_header_id := p5_a0;
    ddp_x_pc_header_rec.name := p5_a1;
    ddp_x_pc_header_rec.description := p5_a2;
    ddp_x_pc_header_rec.status := p5_a3;
    ddp_x_pc_header_rec.status_desc := p5_a4;
    ddp_x_pc_header_rec.product_type_code := p5_a5;
    ddp_x_pc_header_rec.product_type_desc := p5_a6;
    ddp_x_pc_header_rec.primary_flag := p5_a7;
    ddp_x_pc_header_rec.primary_flag_desc := p5_a8;
    ddp_x_pc_header_rec.association_type_flag := p5_a9;
    ddp_x_pc_header_rec.association_type_desc := p5_a10;
    ddp_x_pc_header_rec.draft_flag := p5_a11;
    ddp_x_pc_header_rec.link_to_pc_id := p5_a12;
    ddp_x_pc_header_rec.object_version_number := p5_a13;
    ddp_x_pc_header_rec.attribute_category := p5_a14;
    ddp_x_pc_header_rec.attribute1 := p5_a15;
    ddp_x_pc_header_rec.attribute2 := p5_a16;
    ddp_x_pc_header_rec.attribute3 := p5_a17;
    ddp_x_pc_header_rec.attribute4 := p5_a18;
    ddp_x_pc_header_rec.attribute5 := p5_a19;
    ddp_x_pc_header_rec.attribute6 := p5_a20;
    ddp_x_pc_header_rec.attribute7 := p5_a21;
    ddp_x_pc_header_rec.attribute8 := p5_a22;
    ddp_x_pc_header_rec.attribute9 := p5_a23;
    ddp_x_pc_header_rec.attribute10 := p5_a24;
    ddp_x_pc_header_rec.attribute11 := p5_a25;
    ddp_x_pc_header_rec.attribute12 := p5_a26;
    ddp_x_pc_header_rec.attribute13 := p5_a27;
    ddp_x_pc_header_rec.attribute14 := p5_a28;
    ddp_x_pc_header_rec.attribute15 := p5_a29;
    ddp_x_pc_header_rec.operation_flag := p5_a30;
    ddp_x_pc_header_rec.copy_assos_flag := p5_a31;
    ddp_x_pc_header_rec.copy_docs_flag := p5_a32;




    -- here's the delegated call to the old PL/SQL routine
    ahl_pc_header_pub.process_pc_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_pc_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_pc_header_rec.pc_header_id;
    p5_a1 := ddp_x_pc_header_rec.name;
    p5_a2 := ddp_x_pc_header_rec.description;
    p5_a3 := ddp_x_pc_header_rec.status;
    p5_a4 := ddp_x_pc_header_rec.status_desc;
    p5_a5 := ddp_x_pc_header_rec.product_type_code;
    p5_a6 := ddp_x_pc_header_rec.product_type_desc;
    p5_a7 := ddp_x_pc_header_rec.primary_flag;
    p5_a8 := ddp_x_pc_header_rec.primary_flag_desc;
    p5_a9 := ddp_x_pc_header_rec.association_type_flag;
    p5_a10 := ddp_x_pc_header_rec.association_type_desc;
    p5_a11 := ddp_x_pc_header_rec.draft_flag;
    p5_a12 := ddp_x_pc_header_rec.link_to_pc_id;
    p5_a13 := ddp_x_pc_header_rec.object_version_number;
    p5_a14 := ddp_x_pc_header_rec.attribute_category;
    p5_a15 := ddp_x_pc_header_rec.attribute1;
    p5_a16 := ddp_x_pc_header_rec.attribute2;
    p5_a17 := ddp_x_pc_header_rec.attribute3;
    p5_a18 := ddp_x_pc_header_rec.attribute4;
    p5_a19 := ddp_x_pc_header_rec.attribute5;
    p5_a20 := ddp_x_pc_header_rec.attribute6;
    p5_a21 := ddp_x_pc_header_rec.attribute7;
    p5_a22 := ddp_x_pc_header_rec.attribute8;
    p5_a23 := ddp_x_pc_header_rec.attribute9;
    p5_a24 := ddp_x_pc_header_rec.attribute10;
    p5_a25 := ddp_x_pc_header_rec.attribute11;
    p5_a26 := ddp_x_pc_header_rec.attribute12;
    p5_a27 := ddp_x_pc_header_rec.attribute13;
    p5_a28 := ddp_x_pc_header_rec.attribute14;
    p5_a29 := ddp_x_pc_header_rec.attribute15;
    p5_a30 := ddp_x_pc_header_rec.operation_flag;
    p5_a31 := ddp_x_pc_header_rec.copy_assos_flag;
    p5_a32 := ddp_x_pc_header_rec.copy_docs_flag;



  end;

end ahl_pc_header_pub_w;

/
