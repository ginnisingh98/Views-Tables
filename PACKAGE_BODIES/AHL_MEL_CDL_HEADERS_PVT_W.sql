--------------------------------------------------------
--  DDL for Package Body AHL_MEL_CDL_HEADERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MEL_CDL_HEADERS_PVT_W" as
  /* $Header: AHLWMEHB.pls 120.0 2005/07/04 03:56 tamdas noship $ */
  procedure create_mel_cdl(p_api_version  NUMBER
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
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  DATE
    , p9_a10 in out nocopy  DATE
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
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
  )

  as
    ddp_x_mel_cdl_header_rec ahl_mel_cdl_headers_pvt.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_mel_cdl_header_rec.mel_cdl_header_id := p9_a0;
    ddp_x_mel_cdl_header_rec.object_version_number := p9_a1;
    ddp_x_mel_cdl_header_rec.pc_node_id := p9_a2;
    ddp_x_mel_cdl_header_rec.mel_cdl_type_code := p9_a3;
    ddp_x_mel_cdl_header_rec.mel_cdl_type_meaning := p9_a4;
    ddp_x_mel_cdl_header_rec.status_code := p9_a5;
    ddp_x_mel_cdl_header_rec.status_meaning := p9_a6;
    ddp_x_mel_cdl_header_rec.revision := p9_a7;
    ddp_x_mel_cdl_header_rec.version_number := p9_a8;
    ddp_x_mel_cdl_header_rec.revision_date := p9_a9;
    ddp_x_mel_cdl_header_rec.expired_date := p9_a10;
    ddp_x_mel_cdl_header_rec.attribute_category := p9_a11;
    ddp_x_mel_cdl_header_rec.attribute1 := p9_a12;
    ddp_x_mel_cdl_header_rec.attribute2 := p9_a13;
    ddp_x_mel_cdl_header_rec.attribute3 := p9_a14;
    ddp_x_mel_cdl_header_rec.attribute4 := p9_a15;
    ddp_x_mel_cdl_header_rec.attribute5 := p9_a16;
    ddp_x_mel_cdl_header_rec.attribute6 := p9_a17;
    ddp_x_mel_cdl_header_rec.attribute7 := p9_a18;
    ddp_x_mel_cdl_header_rec.attribute8 := p9_a19;
    ddp_x_mel_cdl_header_rec.attribute9 := p9_a20;
    ddp_x_mel_cdl_header_rec.attribute10 := p9_a21;
    ddp_x_mel_cdl_header_rec.attribute11 := p9_a22;
    ddp_x_mel_cdl_header_rec.attribute12 := p9_a23;
    ddp_x_mel_cdl_header_rec.attribute13 := p9_a24;
    ddp_x_mel_cdl_header_rec.attribute14 := p9_a25;
    ddp_x_mel_cdl_header_rec.attribute15 := p9_a26;

    -- here's the delegated call to the old PL/SQL routine
    ahl_mel_cdl_headers_pvt.create_mel_cdl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mel_cdl_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_mel_cdl_header_rec.mel_cdl_header_id;
    p9_a1 := ddp_x_mel_cdl_header_rec.object_version_number;
    p9_a2 := ddp_x_mel_cdl_header_rec.pc_node_id;
    p9_a3 := ddp_x_mel_cdl_header_rec.mel_cdl_type_code;
    p9_a4 := ddp_x_mel_cdl_header_rec.mel_cdl_type_meaning;
    p9_a5 := ddp_x_mel_cdl_header_rec.status_code;
    p9_a6 := ddp_x_mel_cdl_header_rec.status_meaning;
    p9_a7 := ddp_x_mel_cdl_header_rec.revision;
    p9_a8 := ddp_x_mel_cdl_header_rec.version_number;
    p9_a9 := ddp_x_mel_cdl_header_rec.revision_date;
    p9_a10 := ddp_x_mel_cdl_header_rec.expired_date;
    p9_a11 := ddp_x_mel_cdl_header_rec.attribute_category;
    p9_a12 := ddp_x_mel_cdl_header_rec.attribute1;
    p9_a13 := ddp_x_mel_cdl_header_rec.attribute2;
    p9_a14 := ddp_x_mel_cdl_header_rec.attribute3;
    p9_a15 := ddp_x_mel_cdl_header_rec.attribute4;
    p9_a16 := ddp_x_mel_cdl_header_rec.attribute5;
    p9_a17 := ddp_x_mel_cdl_header_rec.attribute6;
    p9_a18 := ddp_x_mel_cdl_header_rec.attribute7;
    p9_a19 := ddp_x_mel_cdl_header_rec.attribute8;
    p9_a20 := ddp_x_mel_cdl_header_rec.attribute9;
    p9_a21 := ddp_x_mel_cdl_header_rec.attribute10;
    p9_a22 := ddp_x_mel_cdl_header_rec.attribute11;
    p9_a23 := ddp_x_mel_cdl_header_rec.attribute12;
    p9_a24 := ddp_x_mel_cdl_header_rec.attribute13;
    p9_a25 := ddp_x_mel_cdl_header_rec.attribute14;
    p9_a26 := ddp_x_mel_cdl_header_rec.attribute15;
  end;

  procedure update_mel_cdl(p_api_version  NUMBER
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
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  DATE
    , p9_a10 in out nocopy  DATE
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
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
  )

  as
    ddp_x_mel_cdl_header_rec ahl_mel_cdl_headers_pvt.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_mel_cdl_header_rec.mel_cdl_header_id := p9_a0;
    ddp_x_mel_cdl_header_rec.object_version_number := p9_a1;
    ddp_x_mel_cdl_header_rec.pc_node_id := p9_a2;
    ddp_x_mel_cdl_header_rec.mel_cdl_type_code := p9_a3;
    ddp_x_mel_cdl_header_rec.mel_cdl_type_meaning := p9_a4;
    ddp_x_mel_cdl_header_rec.status_code := p9_a5;
    ddp_x_mel_cdl_header_rec.status_meaning := p9_a6;
    ddp_x_mel_cdl_header_rec.revision := p9_a7;
    ddp_x_mel_cdl_header_rec.version_number := p9_a8;
    ddp_x_mel_cdl_header_rec.revision_date := p9_a9;
    ddp_x_mel_cdl_header_rec.expired_date := p9_a10;
    ddp_x_mel_cdl_header_rec.attribute_category := p9_a11;
    ddp_x_mel_cdl_header_rec.attribute1 := p9_a12;
    ddp_x_mel_cdl_header_rec.attribute2 := p9_a13;
    ddp_x_mel_cdl_header_rec.attribute3 := p9_a14;
    ddp_x_mel_cdl_header_rec.attribute4 := p9_a15;
    ddp_x_mel_cdl_header_rec.attribute5 := p9_a16;
    ddp_x_mel_cdl_header_rec.attribute6 := p9_a17;
    ddp_x_mel_cdl_header_rec.attribute7 := p9_a18;
    ddp_x_mel_cdl_header_rec.attribute8 := p9_a19;
    ddp_x_mel_cdl_header_rec.attribute9 := p9_a20;
    ddp_x_mel_cdl_header_rec.attribute10 := p9_a21;
    ddp_x_mel_cdl_header_rec.attribute11 := p9_a22;
    ddp_x_mel_cdl_header_rec.attribute12 := p9_a23;
    ddp_x_mel_cdl_header_rec.attribute13 := p9_a24;
    ddp_x_mel_cdl_header_rec.attribute14 := p9_a25;
    ddp_x_mel_cdl_header_rec.attribute15 := p9_a26;

    -- here's the delegated call to the old PL/SQL routine
    ahl_mel_cdl_headers_pvt.update_mel_cdl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mel_cdl_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_mel_cdl_header_rec.mel_cdl_header_id;
    p9_a1 := ddp_x_mel_cdl_header_rec.object_version_number;
    p9_a2 := ddp_x_mel_cdl_header_rec.pc_node_id;
    p9_a3 := ddp_x_mel_cdl_header_rec.mel_cdl_type_code;
    p9_a4 := ddp_x_mel_cdl_header_rec.mel_cdl_type_meaning;
    p9_a5 := ddp_x_mel_cdl_header_rec.status_code;
    p9_a6 := ddp_x_mel_cdl_header_rec.status_meaning;
    p9_a7 := ddp_x_mel_cdl_header_rec.revision;
    p9_a8 := ddp_x_mel_cdl_header_rec.version_number;
    p9_a9 := ddp_x_mel_cdl_header_rec.revision_date;
    p9_a10 := ddp_x_mel_cdl_header_rec.expired_date;
    p9_a11 := ddp_x_mel_cdl_header_rec.attribute_category;
    p9_a12 := ddp_x_mel_cdl_header_rec.attribute1;
    p9_a13 := ddp_x_mel_cdl_header_rec.attribute2;
    p9_a14 := ddp_x_mel_cdl_header_rec.attribute3;
    p9_a15 := ddp_x_mel_cdl_header_rec.attribute4;
    p9_a16 := ddp_x_mel_cdl_header_rec.attribute5;
    p9_a17 := ddp_x_mel_cdl_header_rec.attribute6;
    p9_a18 := ddp_x_mel_cdl_header_rec.attribute7;
    p9_a19 := ddp_x_mel_cdl_header_rec.attribute8;
    p9_a20 := ddp_x_mel_cdl_header_rec.attribute9;
    p9_a21 := ddp_x_mel_cdl_header_rec.attribute10;
    p9_a22 := ddp_x_mel_cdl_header_rec.attribute11;
    p9_a23 := ddp_x_mel_cdl_header_rec.attribute12;
    p9_a24 := ddp_x_mel_cdl_header_rec.attribute13;
    p9_a25 := ddp_x_mel_cdl_header_rec.attribute14;
    p9_a26 := ddp_x_mel_cdl_header_rec.attribute15;
  end;

end ahl_mel_cdl_headers_pvt_w;

/
