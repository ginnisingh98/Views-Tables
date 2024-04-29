--------------------------------------------------------
--  DDL for Package Body AMS_ACT_LIST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_LIST_PVT_W" as
  /* $Header: amswalsb.pls 120.1 2005/06/27 05:42:33 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_act_list_pvt.child_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_act_list_pvt.child_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY ams_act_list_pvt.act_list_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).act_list_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).group_code := a8(indx);
          t(ddindx).list_used_by_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).list_used_by := a10(indx);
          t(ddindx).list_act_type := a11(indx);
          t(ddindx).list_action_type := a12(indx);
          t(ddindx).order_number := rosetta_g_miss_num_map(a13(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ams_act_list_pvt.act_list_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
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
        a12.extend(t.count);
        a13.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).act_list_header_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a8(indx) := t(ddindx).group_code;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).list_used_by_id);
          a10(indx) := t(ddindx).list_used_by;
          a11(indx) := t(ddindx).list_act_type;
          a12(indx) := t(ddindx).list_action_type;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).order_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure create_act_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_act_list_header_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_list_rec.group_code := p7_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a9);
    ddp_act_list_rec.list_used_by := p7_a10;
    ddp_act_list_rec.list_act_type := p7_a11;
    ddp_act_list_rec.list_action_type := p7_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p7_a13);


    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.create_act_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_list_rec,
      x_act_list_header_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_act_list(p_api_version_number  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_list_rec.group_code := p7_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a9);
    ddp_act_list_rec.list_used_by := p7_a10;
    ddp_act_list_rec.list_act_type := p7_a11;
    ddp_act_list_rec.list_action_type := p7_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p7_a13);


    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.update_act_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_list_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_act_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
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
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p3_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p3_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p3_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_act_list_rec.group_code := p3_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p3_a9);
    ddp_act_list_rec.list_used_by := p3_a10;
    ddp_act_list_rec.list_act_type := p3_a11;
    ddp_act_list_rec.list_action_type := p3_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p3_a13);




    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.validate_act_list(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_act_list_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_act_list_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_list_rec.group_code := p0_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a9);
    ddp_act_list_rec.list_used_by := p0_a10;
    ddp_act_list_rec.list_act_type := p0_a11;
    ddp_act_list_rec.list_action_type := p0_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p0_a13);



    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.check_act_list_items(ddp_act_list_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_act_list_rec(p_api_version_number  NUMBER
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
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p5_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p5_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p5_a7);
    ddp_act_list_rec.group_code := p5_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p5_a9);
    ddp_act_list_rec.list_used_by := p5_a10;
    ddp_act_list_rec.list_act_type := p5_a11;
    ddp_act_list_rec.list_action_type := p5_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.validate_act_list_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_list_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure init_act_list_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  NUMBER
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  NUMBER
  )
  as
    ddx_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.init_act_list_rec(ddx_act_list_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_act_list_rec.act_list_header_id);
    p0_a1 := ddx_act_list_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_act_list_rec.last_updated_by);
    p0_a3 := ddx_act_list_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_act_list_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_act_list_rec.object_version_number);
    p0_a6 := rosetta_g_miss_num_map(ddx_act_list_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_act_list_rec.list_header_id);
    p0_a8 := ddx_act_list_rec.group_code;
    p0_a9 := rosetta_g_miss_num_map(ddx_act_list_rec.list_used_by_id);
    p0_a10 := ddx_act_list_rec.list_used_by;
    p0_a11 := ddx_act_list_rec.list_act_type;
    p0_a12 := ddx_act_list_rec.list_action_type;
    p0_a13 := rosetta_g_miss_num_map(ddx_act_list_rec.order_number);
  end;

  procedure complete_act_list_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  NUMBER
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
  )
  as
    ddp_act_list_rec ams_act_list_pvt.act_list_rec_type;
    ddx_complete_rec ams_act_list_pvt.act_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_list_rec.act_list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_list_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_list_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_list_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_list_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_list_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_act_list_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_act_list_rec.list_header_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_list_rec.group_code := p0_a8;
    ddp_act_list_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a9);
    ddp_act_list_rec.list_used_by := p0_a10;
    ddp_act_list_rec.list_act_type := p0_a11;
    ddp_act_list_rec.list_action_type := p0_a12;
    ddp_act_list_rec.order_number := rosetta_g_miss_num_map(p0_a13);


    -- here's the delegated call to the old PL/SQL routine
    ams_act_list_pvt.complete_act_list_rec(ddp_act_list_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.act_list_header_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.list_header_id);
    p1_a8 := ddx_complete_rec.group_code;
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.list_used_by_id);
    p1_a10 := ddx_complete_rec.list_used_by;
    p1_a11 := ddx_complete_rec.list_act_type;
    p1_a12 := ddx_complete_rec.list_action_type;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.order_number);
  end;

end ams_act_list_pvt_w;

/
