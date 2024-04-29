--------------------------------------------------------
--  DDL for Package Body CN_IMP_HEADERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_HEADERS_PVT_W" as
  /* $Header: cnwimhrb.pls 120.1 2006/03/22 23:04 hanaraya noship $ */
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

  procedure create_imp_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  DATE
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , x_imp_header_id out nocopy  NUMBER
  )

  as
    ddp_imp_header cn_imp_headers_pvt.imp_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_header.imp_header_id := p7_a0;
    ddp_imp_header.name := p7_a1;
    ddp_imp_header.description := p7_a2;
    ddp_imp_header.import_type_code := p7_a3;
    ddp_imp_header.operation := p7_a4;
    ddp_imp_header.server_flag := p7_a5;
    ddp_imp_header.user_filename := p7_a6;
    ddp_imp_header.data_filename := p7_a7;
    ddp_imp_header.terminated_by := p7_a8;
    ddp_imp_header.enclosed_by := p7_a9;
    ddp_imp_header.headings_flag := p7_a10;
    ddp_imp_header.staged_row := p7_a11;
    ddp_imp_header.processed_row := p7_a12;
    ddp_imp_header.failed_row := p7_a13;
    ddp_imp_header.status_code := p7_a14;
    ddp_imp_header.imp_map_id := p7_a15;
    ddp_imp_header.source_column_num := p7_a16;
    ddp_imp_header.object_version_number := p7_a17;
    ddp_imp_header.attribute_category := p7_a18;
    ddp_imp_header.attribute1 := p7_a19;
    ddp_imp_header.attribute2 := p7_a20;
    ddp_imp_header.attribute3 := p7_a21;
    ddp_imp_header.attribute4 := p7_a22;
    ddp_imp_header.attribute5 := p7_a23;
    ddp_imp_header.attribute6 := p7_a24;
    ddp_imp_header.attribute7 := p7_a25;
    ddp_imp_header.attribute8 := p7_a26;
    ddp_imp_header.attribute9 := p7_a27;
    ddp_imp_header.attribute10 := p7_a28;
    ddp_imp_header.attribute11 := p7_a29;
    ddp_imp_header.attribute12 := p7_a30;
    ddp_imp_header.attribute13 := p7_a31;
    ddp_imp_header.attribute14 := p7_a32;
    ddp_imp_header.attribute15 := p7_a33;
    ddp_imp_header.creation_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_imp_header.created_by := p7_a35;
    ddp_imp_header.last_update_date := rosetta_g_miss_date_in_map(p7_a36);
    ddp_imp_header.last_updated_by := p7_a37;
    ddp_imp_header.last_update_login := p7_a38;


    -- here's the delegated call to the old PL/SQL routine
    cn_imp_headers_pvt.create_imp_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_header,
      x_imp_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_imp_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  DATE
    , p7_a37  NUMBER
    , p7_a38  NUMBER
  )

  as
    ddp_imp_header cn_imp_headers_pvt.imp_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_header.imp_header_id := p7_a0;
    ddp_imp_header.name := p7_a1;
    ddp_imp_header.description := p7_a2;
    ddp_imp_header.import_type_code := p7_a3;
    ddp_imp_header.operation := p7_a4;
    ddp_imp_header.server_flag := p7_a5;
    ddp_imp_header.user_filename := p7_a6;
    ddp_imp_header.data_filename := p7_a7;
    ddp_imp_header.terminated_by := p7_a8;
    ddp_imp_header.enclosed_by := p7_a9;
    ddp_imp_header.headings_flag := p7_a10;
    ddp_imp_header.staged_row := p7_a11;
    ddp_imp_header.processed_row := p7_a12;
    ddp_imp_header.failed_row := p7_a13;
    ddp_imp_header.status_code := p7_a14;
    ddp_imp_header.imp_map_id := p7_a15;
    ddp_imp_header.source_column_num := p7_a16;
    ddp_imp_header.object_version_number := p7_a17;
    ddp_imp_header.attribute_category := p7_a18;
    ddp_imp_header.attribute1 := p7_a19;
    ddp_imp_header.attribute2 := p7_a20;
    ddp_imp_header.attribute3 := p7_a21;
    ddp_imp_header.attribute4 := p7_a22;
    ddp_imp_header.attribute5 := p7_a23;
    ddp_imp_header.attribute6 := p7_a24;
    ddp_imp_header.attribute7 := p7_a25;
    ddp_imp_header.attribute8 := p7_a26;
    ddp_imp_header.attribute9 := p7_a27;
    ddp_imp_header.attribute10 := p7_a28;
    ddp_imp_header.attribute11 := p7_a29;
    ddp_imp_header.attribute12 := p7_a30;
    ddp_imp_header.attribute13 := p7_a31;
    ddp_imp_header.attribute14 := p7_a32;
    ddp_imp_header.attribute15 := p7_a33;
    ddp_imp_header.creation_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_imp_header.created_by := p7_a35;
    ddp_imp_header.last_update_date := rosetta_g_miss_date_in_map(p7_a36);
    ddp_imp_header.last_updated_by := p7_a37;
    ddp_imp_header.last_update_login := p7_a38;

    -- here's the delegated call to the old PL/SQL routine
    cn_imp_headers_pvt.update_imp_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_header);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_imp_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_map_obj_num  NUMBER
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  DATE
    , p8_a35  NUMBER
    , p8_a36  DATE
    , p8_a37  NUMBER
    , p8_a38  NUMBER
  )

  as
    ddp_imp_header cn_imp_headers_pvt.imp_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_imp_header.imp_header_id := p8_a0;
    ddp_imp_header.name := p8_a1;
    ddp_imp_header.description := p8_a2;
    ddp_imp_header.import_type_code := p8_a3;
    ddp_imp_header.operation := p8_a4;
    ddp_imp_header.server_flag := p8_a5;
    ddp_imp_header.user_filename := p8_a6;
    ddp_imp_header.data_filename := p8_a7;
    ddp_imp_header.terminated_by := p8_a8;
    ddp_imp_header.enclosed_by := p8_a9;
    ddp_imp_header.headings_flag := p8_a10;
    ddp_imp_header.staged_row := p8_a11;
    ddp_imp_header.processed_row := p8_a12;
    ddp_imp_header.failed_row := p8_a13;
    ddp_imp_header.status_code := p8_a14;
    ddp_imp_header.imp_map_id := p8_a15;
    ddp_imp_header.source_column_num := p8_a16;
    ddp_imp_header.object_version_number := p8_a17;
    ddp_imp_header.attribute_category := p8_a18;
    ddp_imp_header.attribute1 := p8_a19;
    ddp_imp_header.attribute2 := p8_a20;
    ddp_imp_header.attribute3 := p8_a21;
    ddp_imp_header.attribute4 := p8_a22;
    ddp_imp_header.attribute5 := p8_a23;
    ddp_imp_header.attribute6 := p8_a24;
    ddp_imp_header.attribute7 := p8_a25;
    ddp_imp_header.attribute8 := p8_a26;
    ddp_imp_header.attribute9 := p8_a27;
    ddp_imp_header.attribute10 := p8_a28;
    ddp_imp_header.attribute11 := p8_a29;
    ddp_imp_header.attribute12 := p8_a30;
    ddp_imp_header.attribute13 := p8_a31;
    ddp_imp_header.attribute14 := p8_a32;
    ddp_imp_header.attribute15 := p8_a33;
    ddp_imp_header.creation_date := rosetta_g_miss_date_in_map(p8_a34);
    ddp_imp_header.created_by := p8_a35;
    ddp_imp_header.last_update_date := rosetta_g_miss_date_in_map(p8_a36);
    ddp_imp_header.last_updated_by := p8_a37;
    ddp_imp_header.last_update_login := p8_a38;

    -- here's the delegated call to the old PL/SQL routine
    cn_imp_headers_pvt.delete_imp_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_map_obj_num,
      ddp_imp_header);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end cn_imp_headers_pvt_w;

/
