--------------------------------------------------------
--  DDL for Package Body CN_IMP_MAPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_MAPS_PVT_W" as
  /* $Header: cnwimmpb.pls 120.4 2006/03/23 00:42 hanaraya noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy cn_imp_maps_pvt.v_tbl_type, a0 JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t cn_imp_maps_pvt.v_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p6(t out nocopy cn_imp_maps_pvt.map_field_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).value := a0(indx);
          t(ddindx).text := a1(indx);
          t(ddindx).colname := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t cn_imp_maps_pvt.map_field_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).value;
          a1(indx) := t(ddindx).text;
          a2(indx) := t(ddindx).colname;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_header_id  NUMBER
    , p_src_column_num  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  NUMBER
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , p9_a16  VARCHAR2
    , p9_a17  VARCHAR2
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  DATE
    , p9_a21  NUMBER
    , p9_a22  DATE
    , p9_a23  NUMBER
    , p9_a24  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_200
    , p10_a1 JTF_VARCHAR2_TABLE_200
    , p10_a2 JTF_VARCHAR2_TABLE_200
    , p_target_fields JTF_VARCHAR2_TABLE_200
    , x_imp_map_id out nocopy  NUMBER
    , p_org_id  NUMBER
  )

  as
    ddp_imp_map cn_imp_maps_pvt.imp_maps_rec_type;
    ddp_source_fields cn_imp_maps_pvt.map_field_tbl_type;
    ddp_target_fields cn_imp_maps_pvt.v_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_imp_map.imp_map_id := p9_a0;
    ddp_imp_map.name := p9_a1;
    ddp_imp_map.import_type_code := p9_a2;
    ddp_imp_map.object_version_number := p9_a3;
    ddp_imp_map.attribute_category := p9_a4;
    ddp_imp_map.attribute1 := p9_a5;
    ddp_imp_map.attribute2 := p9_a6;
    ddp_imp_map.attribute3 := p9_a7;
    ddp_imp_map.attribute4 := p9_a8;
    ddp_imp_map.attribute5 := p9_a9;
    ddp_imp_map.attribute6 := p9_a10;
    ddp_imp_map.attribute7 := p9_a11;
    ddp_imp_map.attribute8 := p9_a12;
    ddp_imp_map.attribute9 := p9_a13;
    ddp_imp_map.attribute10 := p9_a14;
    ddp_imp_map.attribute11 := p9_a15;
    ddp_imp_map.attribute12 := p9_a16;
    ddp_imp_map.attribute13 := p9_a17;
    ddp_imp_map.attribute14 := p9_a18;
    ddp_imp_map.attribute15 := p9_a19;
    ddp_imp_map.creation_date := rosetta_g_miss_date_in_map(p9_a20);
    ddp_imp_map.created_by := p9_a21;
    ddp_imp_map.last_update_date := rosetta_g_miss_date_in_map(p9_a22);
    ddp_imp_map.last_updated_by := p9_a23;
    ddp_imp_map.last_update_login := p9_a24;

    cn_imp_maps_pvt_w.rosetta_table_copy_in_p6(ddp_source_fields, p10_a0
      , p10_a1
      , p10_a2
      );

    cn_imp_maps_pvt_w.rosetta_table_copy_in_p0(ddp_target_fields, p_target_fields);



    -- here's the delegated call to the old PL/SQL routine
    cn_imp_maps_pvt.create_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_imp_header_id,
      p_src_column_num,
      ddp_imp_map,
      ddp_source_fields,
      ddp_target_fields,
      x_imp_map_id,
      p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure retrieve_fields(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_map_id  NUMBER
    , p_import_type_code  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , x_map_obj_num out nocopy  NUMBER
    , p_org_id  NUMBER
  )

  as
    ddx_source_fields cn_imp_maps_pvt.map_field_tbl_type;
    ddx_target_fields cn_imp_maps_pvt.map_field_tbl_type;
    ddx_mapped_fields cn_imp_maps_pvt.map_field_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    cn_imp_maps_pvt.retrieve_fields(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_imp_map_id,
      p_import_type_code,
      ddx_source_fields,
      ddx_target_fields,
      ddx_mapped_fields,
      x_map_obj_num,
      p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    cn_imp_maps_pvt_w.rosetta_table_copy_out_p6(ddx_source_fields, p9_a0
      , p9_a1
      , p9_a2
      );

    cn_imp_maps_pvt_w.rosetta_table_copy_out_p6(ddx_target_fields, p10_a0
      , p10_a1
      , p10_a2
      );

    cn_imp_maps_pvt_w.rosetta_table_copy_out_p6(ddx_mapped_fields, p11_a0
      , p11_a1
      , p11_a2
      );


  end;

  procedure create_imp_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
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
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , x_imp_map_id out nocopy  NUMBER
  )

  as
    ddp_imp_map cn_imp_maps_pvt.imp_maps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_map.imp_map_id := p7_a0;
    ddp_imp_map.name := p7_a1;
    ddp_imp_map.import_type_code := p7_a2;
    ddp_imp_map.object_version_number := p7_a3;
    ddp_imp_map.attribute_category := p7_a4;
    ddp_imp_map.attribute1 := p7_a5;
    ddp_imp_map.attribute2 := p7_a6;
    ddp_imp_map.attribute3 := p7_a7;
    ddp_imp_map.attribute4 := p7_a8;
    ddp_imp_map.attribute5 := p7_a9;
    ddp_imp_map.attribute6 := p7_a10;
    ddp_imp_map.attribute7 := p7_a11;
    ddp_imp_map.attribute8 := p7_a12;
    ddp_imp_map.attribute9 := p7_a13;
    ddp_imp_map.attribute10 := p7_a14;
    ddp_imp_map.attribute11 := p7_a15;
    ddp_imp_map.attribute12 := p7_a16;
    ddp_imp_map.attribute13 := p7_a17;
    ddp_imp_map.attribute14 := p7_a18;
    ddp_imp_map.attribute15 := p7_a19;
    ddp_imp_map.creation_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_imp_map.created_by := p7_a21;
    ddp_imp_map.last_update_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_imp_map.last_updated_by := p7_a23;
    ddp_imp_map.last_update_login := p7_a24;


    -- here's the delegated call to the old PL/SQL routine
    cn_imp_maps_pvt.create_imp_map(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_map,
      x_imp_map_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_imp_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
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
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
  )

  as
    ddp_imp_map cn_imp_maps_pvt.imp_maps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_map.imp_map_id := p7_a0;
    ddp_imp_map.name := p7_a1;
    ddp_imp_map.import_type_code := p7_a2;
    ddp_imp_map.object_version_number := p7_a3;
    ddp_imp_map.attribute_category := p7_a4;
    ddp_imp_map.attribute1 := p7_a5;
    ddp_imp_map.attribute2 := p7_a6;
    ddp_imp_map.attribute3 := p7_a7;
    ddp_imp_map.attribute4 := p7_a8;
    ddp_imp_map.attribute5 := p7_a9;
    ddp_imp_map.attribute6 := p7_a10;
    ddp_imp_map.attribute7 := p7_a11;
    ddp_imp_map.attribute8 := p7_a12;
    ddp_imp_map.attribute9 := p7_a13;
    ddp_imp_map.attribute10 := p7_a14;
    ddp_imp_map.attribute11 := p7_a15;
    ddp_imp_map.attribute12 := p7_a16;
    ddp_imp_map.attribute13 := p7_a17;
    ddp_imp_map.attribute14 := p7_a18;
    ddp_imp_map.attribute15 := p7_a19;
    ddp_imp_map.creation_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_imp_map.created_by := p7_a21;
    ddp_imp_map.last_update_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_imp_map.last_updated_by := p7_a23;
    ddp_imp_map.last_update_login := p7_a24;

    -- here's the delegated call to the old PL/SQL routine
    cn_imp_maps_pvt.delete_imp_map(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_map);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end cn_imp_maps_pvt_w;

/
