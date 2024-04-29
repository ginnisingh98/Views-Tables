--------------------------------------------------------
--  DDL for Package Body AMS_DM_IMP_ATTRIBUTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_IMP_ATTRIBUTE_PVT_W" as
  /* $Header: amswdiab.pls 115.3 2002/12/09 11:05:17 choang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_dm_imp_attribute_pvt.imp_attribute_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).imp_attribute_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).model_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).source_field_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).rank := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).value := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).source_field_name := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_dm_imp_attribute_pvt.imp_attribute_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).imp_attribute_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).model_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).source_field_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).rank);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).value);
          a11(indx) := t(ddindx).source_field_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_imp_attribute(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_dm_imp_attribute_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_attribute_rec ams_dm_imp_attribute_pvt.imp_attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_attribute_rec.imp_attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_imp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_imp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_imp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_imp_attribute_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_imp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_imp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_imp_attribute_rec.model_id := rosetta_g_miss_num_map(p7_a7);
    ddp_imp_attribute_rec.source_field_id := rosetta_g_miss_num_map(p7_a8);
    ddp_imp_attribute_rec.rank := rosetta_g_miss_num_map(p7_a9);
    ddp_imp_attribute_rec.value := rosetta_g_miss_num_map(p7_a10);
    ddp_imp_attribute_rec.source_field_name := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    ams_dm_imp_attribute_pvt.create_imp_attribute(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_attribute_rec,
      x_dm_imp_attribute_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_imp_attribute(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_attribute_rec ams_dm_imp_attribute_pvt.imp_attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_attribute_rec.imp_attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_imp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_imp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_imp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_imp_attribute_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_imp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_imp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_imp_attribute_rec.model_id := rosetta_g_miss_num_map(p7_a7);
    ddp_imp_attribute_rec.source_field_id := rosetta_g_miss_num_map(p7_a8);
    ddp_imp_attribute_rec.rank := rosetta_g_miss_num_map(p7_a9);
    ddp_imp_attribute_rec.value := rosetta_g_miss_num_map(p7_a10);
    ddp_imp_attribute_rec.source_field_name := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    ams_dm_imp_attribute_pvt.update_imp_attribute(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_attribute_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_imp_attribute(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_attribute_rec ams_dm_imp_attribute_pvt.imp_attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_imp_attribute_rec.imp_attribute_id := rosetta_g_miss_num_map(p3_a0);
    ddp_imp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_imp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_imp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_imp_attribute_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_imp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_imp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_imp_attribute_rec.model_id := rosetta_g_miss_num_map(p3_a7);
    ddp_imp_attribute_rec.source_field_id := rosetta_g_miss_num_map(p3_a8);
    ddp_imp_attribute_rec.rank := rosetta_g_miss_num_map(p3_a9);
    ddp_imp_attribute_rec.value := rosetta_g_miss_num_map(p3_a10);
    ddp_imp_attribute_rec.source_field_name := p3_a11;





    -- here's the delegated call to the old PL/SQL routine
    ams_dm_imp_attribute_pvt.validate_imp_attribute(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_imp_attribute_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_imp_attribute_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_attribute_rec ams_dm_imp_attribute_pvt.imp_attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_imp_attribute_rec.imp_attribute_id := rosetta_g_miss_num_map(p0_a0);
    ddp_imp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_imp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_imp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_imp_attribute_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_imp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_imp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_imp_attribute_rec.model_id := rosetta_g_miss_num_map(p0_a7);
    ddp_imp_attribute_rec.source_field_id := rosetta_g_miss_num_map(p0_a8);
    ddp_imp_attribute_rec.rank := rosetta_g_miss_num_map(p0_a9);
    ddp_imp_attribute_rec.value := rosetta_g_miss_num_map(p0_a10);
    ddp_imp_attribute_rec.source_field_name := p0_a11;



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_imp_attribute_pvt.check_imp_attribute_items(ddp_imp_attribute_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_imp_attribute_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_attribute_rec ams_dm_imp_attribute_pvt.imp_attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_imp_attribute_rec.imp_attribute_id := rosetta_g_miss_num_map(p5_a0);
    ddp_imp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_imp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_imp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_imp_attribute_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_imp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_imp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_imp_attribute_rec.model_id := rosetta_g_miss_num_map(p5_a7);
    ddp_imp_attribute_rec.source_field_id := rosetta_g_miss_num_map(p5_a8);
    ddp_imp_attribute_rec.rank := rosetta_g_miss_num_map(p5_a9);
    ddp_imp_attribute_rec.value := rosetta_g_miss_num_map(p5_a10);
    ddp_imp_attribute_rec.source_field_name := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    ams_dm_imp_attribute_pvt.validate_imp_attribute_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_attribute_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_dm_imp_attribute_pvt_w;

/