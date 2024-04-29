--------------------------------------------------------
--  DDL for Package Body AMS_LIST_ASSOC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_ASSOC_PVT_W" as
  /* $Header: amswascb.pls 115.8 2002/11/22 08:56:47 jieli ship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_list_assoc_pvt.list_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).list_cont_restrictions_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).do_not_contact_flag := a8(indx);
          t(ddindx).media_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).list_used_by := a10(indx);
          t(ddindx).list_used_by_id := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_list_assoc_pvt.list_assoc_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_DATE_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).list_cont_restrictions_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).do_not_contact_flag;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).media_id);
          a10(indx) := t(ddindx).list_used_by;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).list_used_by_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_list_assoc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_cont_restrictions_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
  )
  as
    ddp_list_assoc_rec ams_list_assoc_pvt.list_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_assoc_rec.list_cont_restrictions_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_assoc_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_assoc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_list_assoc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_list_assoc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_list_assoc_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_list_assoc_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_list_assoc_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_list_assoc_rec.do_not_contact_flag := p7_a8;
    ddp_list_assoc_rec.media_id := rosetta_g_miss_num_map(p7_a9);
    ddp_list_assoc_rec.list_used_by := p7_a10;
    ddp_list_assoc_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a11);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_assoc_pvt.create_list_assoc(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_assoc_rec,
      x_list_cont_restrictions_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_list_assoc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
  )
  as
    ddp_list_assoc_rec ams_list_assoc_pvt.list_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_assoc_rec.list_cont_restrictions_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_assoc_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_assoc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_list_assoc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_list_assoc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_list_assoc_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_list_assoc_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_list_assoc_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_list_assoc_rec.do_not_contact_flag := p7_a8;
    ddp_list_assoc_rec.media_id := rosetta_g_miss_num_map(p7_a9);
    ddp_list_assoc_rec.list_used_by := p7_a10;
    ddp_list_assoc_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a11);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_assoc_pvt.update_list_assoc(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_assoc_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_list_assoc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  NUMBER := 0-1962.0724
  )
  as
    ddp_list_assoc_rec ams_list_assoc_pvt.list_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_list_assoc_rec.list_cont_restrictions_id := rosetta_g_miss_num_map(p3_a0);
    ddp_list_assoc_rec.list_header_id := rosetta_g_miss_num_map(p3_a1);
    ddp_list_assoc_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_list_assoc_rec.last_updated_by := rosetta_g_miss_num_map(p3_a3);
    ddp_list_assoc_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_list_assoc_rec.created_by := rosetta_g_miss_num_map(p3_a5);
    ddp_list_assoc_rec.last_update_login := rosetta_g_miss_num_map(p3_a6);
    ddp_list_assoc_rec.object_version_number := rosetta_g_miss_num_map(p3_a7);
    ddp_list_assoc_rec.do_not_contact_flag := p3_a8;
    ddp_list_assoc_rec.media_id := rosetta_g_miss_num_map(p3_a9);
    ddp_list_assoc_rec.list_used_by := p3_a10;
    ddp_list_assoc_rec.list_used_by_id := rosetta_g_miss_num_map(p3_a11);




    -- here's the delegated call to the old PL/SQL routine
    ams_list_assoc_pvt.validate_list_assoc(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_list_assoc_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_list_assoc_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
  )
  as
    ddp_list_assoc_rec ams_list_assoc_pvt.list_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_assoc_rec.list_cont_restrictions_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_assoc_rec.list_header_id := rosetta_g_miss_num_map(p0_a1);
    ddp_list_assoc_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_list_assoc_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_list_assoc_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_list_assoc_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_list_assoc_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_list_assoc_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_list_assoc_rec.do_not_contact_flag := p0_a8;
    ddp_list_assoc_rec.media_id := rosetta_g_miss_num_map(p0_a9);
    ddp_list_assoc_rec.list_used_by := p0_a10;
    ddp_list_assoc_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a11);



    -- here's the delegated call to the old PL/SQL routine
    ams_list_assoc_pvt.check_list_assoc_items(ddp_list_assoc_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_list_assoc_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
  )
  as
    ddp_list_assoc_rec ams_list_assoc_pvt.list_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_list_assoc_rec.list_cont_restrictions_id := rosetta_g_miss_num_map(p5_a0);
    ddp_list_assoc_rec.list_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_list_assoc_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_list_assoc_rec.last_updated_by := rosetta_g_miss_num_map(p5_a3);
    ddp_list_assoc_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_list_assoc_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_list_assoc_rec.last_update_login := rosetta_g_miss_num_map(p5_a6);
    ddp_list_assoc_rec.object_version_number := rosetta_g_miss_num_map(p5_a7);
    ddp_list_assoc_rec.do_not_contact_flag := p5_a8;
    ddp_list_assoc_rec.media_id := rosetta_g_miss_num_map(p5_a9);
    ddp_list_assoc_rec.list_used_by := p5_a10;
    ddp_list_assoc_rec.list_used_by_id := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    ams_list_assoc_pvt.validate_list_assoc_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_assoc_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_list_assoc_pvt_w;

/
