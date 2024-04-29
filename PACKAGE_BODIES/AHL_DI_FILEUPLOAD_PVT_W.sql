--------------------------------------------------------
--  DDL for Package Body AHL_DI_FILEUPLOAD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_FILEUPLOAD_PVT_W" as
		 /* $Header: AHLWFUPB.pls 115.2 2003/09/04 14:08:40 rroy noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure upload_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  NUMBER
  )

  as
    ddp_x_ahl_fileupload_rec ahl_di_fileupload_pvt.ahl_fileupload_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_ahl_fileupload_rec.p_association_id := p7_a0;
    ddp_x_ahl_fileupload_rec.p_file_id := p7_a1;
    ddp_x_ahl_fileupload_rec.p_file_name := p7_a2;
    ddp_x_ahl_fileupload_rec.p_file_description := p7_a3;
    ddp_x_ahl_fileupload_rec.p_revision_id := p7_a4;
    ddp_x_ahl_fileupload_rec.p_datatype_code := p7_a5;
    ddp_x_ahl_fileupload_rec.p_attribute_category := p7_a6;
    ddp_x_ahl_fileupload_rec.p_attribute1 := p7_a7;
    ddp_x_ahl_fileupload_rec.p_attribute2 := p7_a8;
    ddp_x_ahl_fileupload_rec.p_attribute3 := p7_a9;
    ddp_x_ahl_fileupload_rec.p_attribute4 := p7_a10;
    ddp_x_ahl_fileupload_rec.p_attribute5 := p7_a11;
    ddp_x_ahl_fileupload_rec.p_attribute6 := p7_a12;
    ddp_x_ahl_fileupload_rec.p_attribute7 := p7_a13;
    ddp_x_ahl_fileupload_rec.p_attribute8 := p7_a14;
    ddp_x_ahl_fileupload_rec.p_attribute9 := p7_a15;
    ddp_x_ahl_fileupload_rec.p_attribute10 := p7_a16;
    ddp_x_ahl_fileupload_rec.p_attribute11 := p7_a17;
    ddp_x_ahl_fileupload_rec.p_attribute12 := p7_a18;
    ddp_x_ahl_fileupload_rec.p_attribute13 := p7_a19;
    ddp_x_ahl_fileupload_rec.p_attribute14 := p7_a20;
    ddp_x_ahl_fileupload_rec.p_attribute15 := p7_a21;
    ddp_x_ahl_fileupload_rec.p_x_object_version_number := p7_a22;

    -- here's the delegated call to the old PL/SQL routine
    ahl_di_fileupload_pvt.upload_item(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ahl_fileupload_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_ahl_fileupload_rec.p_association_id;
    p7_a1 := ddp_x_ahl_fileupload_rec.p_file_id;
    p7_a2 := ddp_x_ahl_fileupload_rec.p_file_name;
    p7_a3 := ddp_x_ahl_fileupload_rec.p_file_description;
    p7_a4 := ddp_x_ahl_fileupload_rec.p_revision_id;
    p7_a5 := ddp_x_ahl_fileupload_rec.p_datatype_code;
    p7_a6 := ddp_x_ahl_fileupload_rec.p_attribute_category;
    p7_a7 := ddp_x_ahl_fileupload_rec.p_attribute1;
    p7_a8 := ddp_x_ahl_fileupload_rec.p_attribute2;
    p7_a9 := ddp_x_ahl_fileupload_rec.p_attribute3;
    p7_a10 := ddp_x_ahl_fileupload_rec.p_attribute4;
    p7_a11 := ddp_x_ahl_fileupload_rec.p_attribute5;
    p7_a12 := ddp_x_ahl_fileupload_rec.p_attribute6;
    p7_a13 := ddp_x_ahl_fileupload_rec.p_attribute7;
    p7_a14 := ddp_x_ahl_fileupload_rec.p_attribute8;
    p7_a15 := ddp_x_ahl_fileupload_rec.p_attribute9;
    p7_a16 := ddp_x_ahl_fileupload_rec.p_attribute10;
    p7_a17 := ddp_x_ahl_fileupload_rec.p_attribute11;
    p7_a18 := ddp_x_ahl_fileupload_rec.p_attribute12;
    p7_a19 := ddp_x_ahl_fileupload_rec.p_attribute13;
    p7_a20 := ddp_x_ahl_fileupload_rec.p_attribute14;
    p7_a21 := ddp_x_ahl_fileupload_rec.p_attribute15;
    p7_a22 := ddp_x_ahl_fileupload_rec.p_x_object_version_number;
  end;

  procedure delete_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
  )

  as
    ddp_x_ahl_fileupload_rec ahl_di_fileupload_pvt.ahl_fileupload_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_ahl_fileupload_rec.p_association_id := p7_a0;
    ddp_x_ahl_fileupload_rec.p_file_id := p7_a1;
    ddp_x_ahl_fileupload_rec.p_file_name := p7_a2;
    ddp_x_ahl_fileupload_rec.p_file_description := p7_a3;
    ddp_x_ahl_fileupload_rec.p_revision_id := p7_a4;
    ddp_x_ahl_fileupload_rec.p_datatype_code := p7_a5;
    ddp_x_ahl_fileupload_rec.p_attribute_category := p7_a6;
    ddp_x_ahl_fileupload_rec.p_attribute1 := p7_a7;
    ddp_x_ahl_fileupload_rec.p_attribute2 := p7_a8;
    ddp_x_ahl_fileupload_rec.p_attribute3 := p7_a9;
    ddp_x_ahl_fileupload_rec.p_attribute4 := p7_a10;
    ddp_x_ahl_fileupload_rec.p_attribute5 := p7_a11;
    ddp_x_ahl_fileupload_rec.p_attribute6 := p7_a12;
    ddp_x_ahl_fileupload_rec.p_attribute7 := p7_a13;
    ddp_x_ahl_fileupload_rec.p_attribute8 := p7_a14;
    ddp_x_ahl_fileupload_rec.p_attribute9 := p7_a15;
    ddp_x_ahl_fileupload_rec.p_attribute10 := p7_a16;
    ddp_x_ahl_fileupload_rec.p_attribute11 := p7_a17;
    ddp_x_ahl_fileupload_rec.p_attribute12 := p7_a18;
    ddp_x_ahl_fileupload_rec.p_attribute13 := p7_a19;
    ddp_x_ahl_fileupload_rec.p_attribute14 := p7_a20;
    ddp_x_ahl_fileupload_rec.p_attribute15 := p7_a21;
    ddp_x_ahl_fileupload_rec.p_x_object_version_number := p7_a22;

    -- here's the delegated call to the old PL/SQL routine
    ahl_di_fileupload_pvt.delete_item(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ahl_fileupload_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  NUMBER
    , p_delete_flag  VARCHAR2
  )

  as
    ddp_x_ahl_fileupload_rec ahl_di_fileupload_pvt.ahl_fileupload_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_ahl_fileupload_rec.p_association_id := p7_a0;
    ddp_x_ahl_fileupload_rec.p_file_id := p7_a1;
    ddp_x_ahl_fileupload_rec.p_file_name := p7_a2;
    ddp_x_ahl_fileupload_rec.p_file_description := p7_a3;
    ddp_x_ahl_fileupload_rec.p_revision_id := p7_a4;
    ddp_x_ahl_fileupload_rec.p_datatype_code := p7_a5;
    ddp_x_ahl_fileupload_rec.p_attribute_category := p7_a6;
    ddp_x_ahl_fileupload_rec.p_attribute1 := p7_a7;
    ddp_x_ahl_fileupload_rec.p_attribute2 := p7_a8;
    ddp_x_ahl_fileupload_rec.p_attribute3 := p7_a9;
    ddp_x_ahl_fileupload_rec.p_attribute4 := p7_a10;
    ddp_x_ahl_fileupload_rec.p_attribute5 := p7_a11;
    ddp_x_ahl_fileupload_rec.p_attribute6 := p7_a12;
    ddp_x_ahl_fileupload_rec.p_attribute7 := p7_a13;
    ddp_x_ahl_fileupload_rec.p_attribute8 := p7_a14;
    ddp_x_ahl_fileupload_rec.p_attribute9 := p7_a15;
    ddp_x_ahl_fileupload_rec.p_attribute10 := p7_a16;
    ddp_x_ahl_fileupload_rec.p_attribute11 := p7_a17;
    ddp_x_ahl_fileupload_rec.p_attribute12 := p7_a18;
    ddp_x_ahl_fileupload_rec.p_attribute13 := p7_a19;
    ddp_x_ahl_fileupload_rec.p_attribute14 := p7_a20;
    ddp_x_ahl_fileupload_rec.p_attribute15 := p7_a21;
    ddp_x_ahl_fileupload_rec.p_x_object_version_number := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    ahl_di_fileupload_pvt.process_item(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ahl_fileupload_rec,
      p_delete_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_ahl_fileupload_rec.p_association_id;
    p7_a1 := ddp_x_ahl_fileupload_rec.p_file_id;
    p7_a2 := ddp_x_ahl_fileupload_rec.p_file_name;
    p7_a3 := ddp_x_ahl_fileupload_rec.p_file_description;
    p7_a4 := ddp_x_ahl_fileupload_rec.p_revision_id;
    p7_a5 := ddp_x_ahl_fileupload_rec.p_datatype_code;
    p7_a6 := ddp_x_ahl_fileupload_rec.p_attribute_category;
    p7_a7 := ddp_x_ahl_fileupload_rec.p_attribute1;
    p7_a8 := ddp_x_ahl_fileupload_rec.p_attribute2;
    p7_a9 := ddp_x_ahl_fileupload_rec.p_attribute3;
    p7_a10 := ddp_x_ahl_fileupload_rec.p_attribute4;
    p7_a11 := ddp_x_ahl_fileupload_rec.p_attribute5;
    p7_a12 := ddp_x_ahl_fileupload_rec.p_attribute6;
    p7_a13 := ddp_x_ahl_fileupload_rec.p_attribute7;
    p7_a14 := ddp_x_ahl_fileupload_rec.p_attribute8;
    p7_a15 := ddp_x_ahl_fileupload_rec.p_attribute9;
    p7_a16 := ddp_x_ahl_fileupload_rec.p_attribute10;
    p7_a17 := ddp_x_ahl_fileupload_rec.p_attribute11;
    p7_a18 := ddp_x_ahl_fileupload_rec.p_attribute12;
    p7_a19 := ddp_x_ahl_fileupload_rec.p_attribute13;
    p7_a20 := ddp_x_ahl_fileupload_rec.p_attribute14;
    p7_a21 := ddp_x_ahl_fileupload_rec.p_attribute15;
    p7_a22 := ddp_x_ahl_fileupload_rec.p_x_object_version_number;

  end;

end ahl_di_fileupload_pvt_w;

/
