--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_USAGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_USAGE_PVT_W" as
  /* $Header: pvxwatub.pls 115.3 2002/12/10 19:34:34 amaram ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_attribute_usage_pvt.attribute_usage_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_usage_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).attribute_usage_type := a11(indx);
          t(ddindx).attribute_usage_code := a12(indx);
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).enabled_flag := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_attribute_usage_pvt.attribute_usage_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
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
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
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
        a14.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_usage_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a11(indx) := t(ddindx).attribute_usage_type;
          a12(indx) := t(ddindx).attribute_usage_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a14(indx) := t(ddindx).enabled_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_attribute_usage(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_attribute_usage_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_attribute_usage_rec pv_attribute_usage_pvt.attribute_usage_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_attribute_usage_rec.attribute_usage_id := rosetta_g_miss_num_map(p7_a0);
    ddp_attribute_usage_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_attribute_usage_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_attribute_usage_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_attribute_usage_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_attribute_usage_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_attribute_usage_rec.request_id := rosetta_g_miss_num_map(p7_a6);
    ddp_attribute_usage_rec.program_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_attribute_usage_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_attribute_usage_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_attribute_usage_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_attribute_usage_rec.attribute_usage_type := p7_a11;
    ddp_attribute_usage_rec.attribute_usage_code := p7_a12;
    ddp_attribute_usage_rec.attribute_id := rosetta_g_miss_num_map(p7_a13);
    ddp_attribute_usage_rec.enabled_flag := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_usage_pvt.create_attribute_usage(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_usage_rec,
      x_attribute_usage_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_attribute_usage(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_attribute_usage_rec pv_attribute_usage_pvt.attribute_usage_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_attribute_usage_rec.attribute_usage_id := rosetta_g_miss_num_map(p7_a0);
    ddp_attribute_usage_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_attribute_usage_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_attribute_usage_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_attribute_usage_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_attribute_usage_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_attribute_usage_rec.request_id := rosetta_g_miss_num_map(p7_a6);
    ddp_attribute_usage_rec.program_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_attribute_usage_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_attribute_usage_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_attribute_usage_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_attribute_usage_rec.attribute_usage_type := p7_a11;
    ddp_attribute_usage_rec.attribute_usage_code := p7_a12;
    ddp_attribute_usage_rec.attribute_id := rosetta_g_miss_num_map(p7_a13);
    ddp_attribute_usage_rec.enabled_flag := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_usage_pvt.update_attribute_usage(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_usage_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_attribute_usage(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_attribute_usage_rec pv_attribute_usage_pvt.attribute_usage_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_attribute_usage_rec.attribute_usage_id := rosetta_g_miss_num_map(p4_a0);
    ddp_attribute_usage_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_attribute_usage_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_attribute_usage_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_attribute_usage_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_attribute_usage_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_attribute_usage_rec.request_id := rosetta_g_miss_num_map(p4_a6);
    ddp_attribute_usage_rec.program_application_id := rosetta_g_miss_num_map(p4_a7);
    ddp_attribute_usage_rec.program_id := rosetta_g_miss_num_map(p4_a8);
    ddp_attribute_usage_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a9);
    ddp_attribute_usage_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_attribute_usage_rec.attribute_usage_type := p4_a11;
    ddp_attribute_usage_rec.attribute_usage_code := p4_a12;
    ddp_attribute_usage_rec.attribute_id := rosetta_g_miss_num_map(p4_a13);
    ddp_attribute_usage_rec.enabled_flag := p4_a14;




    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_usage_pvt.validate_attribute_usage(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_attribute_usage_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_attr_usage_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_attribute_usage_rec pv_attribute_usage_pvt.attribute_usage_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_attribute_usage_rec.attribute_usage_id := rosetta_g_miss_num_map(p0_a0);
    ddp_attribute_usage_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_attribute_usage_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_attribute_usage_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_attribute_usage_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_attribute_usage_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_attribute_usage_rec.request_id := rosetta_g_miss_num_map(p0_a6);
    ddp_attribute_usage_rec.program_application_id := rosetta_g_miss_num_map(p0_a7);
    ddp_attribute_usage_rec.program_id := rosetta_g_miss_num_map(p0_a8);
    ddp_attribute_usage_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_attribute_usage_rec.object_version_number := rosetta_g_miss_num_map(p0_a10);
    ddp_attribute_usage_rec.attribute_usage_type := p0_a11;
    ddp_attribute_usage_rec.attribute_usage_code := p0_a12;
    ddp_attribute_usage_rec.attribute_id := rosetta_g_miss_num_map(p0_a13);
    ddp_attribute_usage_rec.enabled_flag := p0_a14;



    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_usage_pvt.check_attr_usage_items(ddp_attribute_usage_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_attr_usage_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_attribute_usage_rec pv_attribute_usage_pvt.attribute_usage_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_attribute_usage_rec.attribute_usage_id := rosetta_g_miss_num_map(p5_a0);
    ddp_attribute_usage_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_attribute_usage_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_attribute_usage_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_attribute_usage_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_attribute_usage_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_attribute_usage_rec.request_id := rosetta_g_miss_num_map(p5_a6);
    ddp_attribute_usage_rec.program_application_id := rosetta_g_miss_num_map(p5_a7);
    ddp_attribute_usage_rec.program_id := rosetta_g_miss_num_map(p5_a8);
    ddp_attribute_usage_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_attribute_usage_rec.object_version_number := rosetta_g_miss_num_map(p5_a10);
    ddp_attribute_usage_rec.attribute_usage_type := p5_a11;
    ddp_attribute_usage_rec.attribute_usage_code := p5_a12;
    ddp_attribute_usage_rec.attribute_id := rosetta_g_miss_num_map(p5_a13);
    ddp_attribute_usage_rec.enabled_flag := p5_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_usage_pvt.validate_attr_usage_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_usage_rec,
      p_validation_mode);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end pv_attribute_usage_pvt_w;

/
