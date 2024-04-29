--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_STYLESHEETS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_STYLESHEETS_PVT_W" as
  /* $Header: amswstyb.pls 120.0 2005/05/31 18:21:41 appldev noship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).stylesheet_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).content_type := a1(indx);
          t(ddindx).stylesheet_filename := a2(indx);
          t(ddindx).status_code := a3(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).name := a10(indx);
          t(ddindx).description := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_DATE_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).stylesheet_id);
          a1(indx) := t(ddindx).content_type;
          a2(indx) := t(ddindx).stylesheet_filename;
          a3(indx) := t(ddindx).status_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := t(ddindx).creation_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := t(ddindx).last_update_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := t(ddindx).name;
          a11(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_iba_pl_stylesheets(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_stylesheet_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_iba_pl_stylesheets_rec ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_iba_pl_stylesheets_rec.stylesheet_id := rosetta_g_miss_num_map(p7_a0);
    ddp_iba_pl_stylesheets_rec.content_type := p7_a1;
    ddp_iba_pl_stylesheets_rec.stylesheet_filename := p7_a2;
    ddp_iba_pl_stylesheets_rec.status_code := p7_a3;
    ddp_iba_pl_stylesheets_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_iba_pl_stylesheets_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_iba_pl_stylesheets_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_iba_pl_stylesheets_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_iba_pl_stylesheets_rec.last_update_login := rosetta_g_miss_num_map(p7_a8);
    ddp_iba_pl_stylesheets_rec.object_version_number := rosetta_g_miss_num_map(p7_a9);
    ddp_iba_pl_stylesheets_rec.name := p7_a10;
    ddp_iba_pl_stylesheets_rec.description := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    ams_iba_pl_stylesheets_pvt.create_iba_pl_stylesheets(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_pl_stylesheets_rec,
      x_stylesheet_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_iba_pl_stylesheets(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_iba_pl_stylesheets_rec ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_iba_pl_stylesheets_rec.stylesheet_id := rosetta_g_miss_num_map(p7_a0);
    ddp_iba_pl_stylesheets_rec.content_type := p7_a1;
    ddp_iba_pl_stylesheets_rec.stylesheet_filename := p7_a2;
    ddp_iba_pl_stylesheets_rec.status_code := p7_a3;
    ddp_iba_pl_stylesheets_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_iba_pl_stylesheets_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_iba_pl_stylesheets_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_iba_pl_stylesheets_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_iba_pl_stylesheets_rec.last_update_login := rosetta_g_miss_num_map(p7_a8);
    ddp_iba_pl_stylesheets_rec.object_version_number := rosetta_g_miss_num_map(p7_a9);
    ddp_iba_pl_stylesheets_rec.name := p7_a10;
    ddp_iba_pl_stylesheets_rec.description := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    ams_iba_pl_stylesheets_pvt.update_iba_pl_stylesheets(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_pl_stylesheets_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_iba_pl_stylesheets(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_iba_pl_stylesheets_rec ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_iba_pl_stylesheets_rec.stylesheet_id := rosetta_g_miss_num_map(p3_a0);
    ddp_iba_pl_stylesheets_rec.content_type := p3_a1;
    ddp_iba_pl_stylesheets_rec.stylesheet_filename := p3_a2;
    ddp_iba_pl_stylesheets_rec.status_code := p3_a3;
    ddp_iba_pl_stylesheets_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_iba_pl_stylesheets_rec.creation_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_iba_pl_stylesheets_rec.last_updated_by := rosetta_g_miss_num_map(p3_a6);
    ddp_iba_pl_stylesheets_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_iba_pl_stylesheets_rec.last_update_login := rosetta_g_miss_num_map(p3_a8);
    ddp_iba_pl_stylesheets_rec.object_version_number := rosetta_g_miss_num_map(p3_a9);
    ddp_iba_pl_stylesheets_rec.name := p3_a10;
    ddp_iba_pl_stylesheets_rec.description := p3_a11;





    -- here's the delegated call to the old PL/SQL routine
    ams_iba_pl_stylesheets_pvt.validate_iba_pl_stylesheets(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_iba_pl_stylesheets_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_validation_mode);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_iba_pl_style_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_iba_pl_stylesheets_rec ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_iba_pl_stylesheets_rec.stylesheet_id := rosetta_g_miss_num_map(p0_a0);
    ddp_iba_pl_stylesheets_rec.content_type := p0_a1;
    ddp_iba_pl_stylesheets_rec.stylesheet_filename := p0_a2;
    ddp_iba_pl_stylesheets_rec.status_code := p0_a3;
    ddp_iba_pl_stylesheets_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_iba_pl_stylesheets_rec.creation_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_iba_pl_stylesheets_rec.last_updated_by := rosetta_g_miss_num_map(p0_a6);
    ddp_iba_pl_stylesheets_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_iba_pl_stylesheets_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);
    ddp_iba_pl_stylesheets_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddp_iba_pl_stylesheets_rec.name := p0_a10;
    ddp_iba_pl_stylesheets_rec.description := p0_a11;



    -- here's the delegated call to the old PL/SQL routine
    ams_iba_pl_stylesheets_pvt.check_iba_pl_style_items(ddp_iba_pl_stylesheets_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_iba_pl_style_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_iba_pl_stylesheets_rec ams_iba_pl_stylesheets_pvt.iba_pl_stylesheets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iba_pl_stylesheets_rec.stylesheet_id := rosetta_g_miss_num_map(p5_a0);
    ddp_iba_pl_stylesheets_rec.content_type := p5_a1;
    ddp_iba_pl_stylesheets_rec.stylesheet_filename := p5_a2;
    ddp_iba_pl_stylesheets_rec.status_code := p5_a3;
    ddp_iba_pl_stylesheets_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_iba_pl_stylesheets_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_iba_pl_stylesheets_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_iba_pl_stylesheets_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_iba_pl_stylesheets_rec.last_update_login := rosetta_g_miss_num_map(p5_a8);
    ddp_iba_pl_stylesheets_rec.object_version_number := rosetta_g_miss_num_map(p5_a9);
    ddp_iba_pl_stylesheets_rec.name := p5_a10;
    ddp_iba_pl_stylesheets_rec.description := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    ams_iba_pl_stylesheets_pvt.validate_iba_pl_style_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_pl_stylesheets_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_iba_pl_stylesheets_pvt_w;

/
