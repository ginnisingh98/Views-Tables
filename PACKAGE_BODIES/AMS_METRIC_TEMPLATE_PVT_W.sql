--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_TEMPLATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_TEMPLATE_PVT_W" as
/* $Header: amswmthb.pls 115.4 2003/10/12 09:59:58 sunkumar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ams_metric_template_pvt.metric_tpl_header_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_4000
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
          t(ddindx).metric_tpl_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).enabled_flag := a8(indx);
          t(ddindx).metric_tpl_header_name := a9(indx);
          t(ddindx).description := a10(indx);
          t(ddindx).object_type := a11(indx);
          t(ddindx).association_type := a12(indx);
          t(ddindx).used_by_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).used_by_code := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_metric_template_pvt.metric_tpl_header_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_4000();
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
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).metric_tpl_header_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a8(indx) := t(ddindx).enabled_flag;
          a9(indx) := t(ddindx).metric_tpl_header_name;
          a10(indx) := t(ddindx).description;
          a11(indx) := t(ddindx).object_type;
          a12(indx) := t(ddindx).association_type;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).used_by_id);
          a14(indx) := t(ddindx).used_by_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_metric_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_metric_tpl_header_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_tpl_header_rec ams_metric_template_pvt.metric_tpl_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_metric_tpl_header_rec.metric_tpl_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_metric_tpl_header_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_metric_tpl_header_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_metric_tpl_header_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_metric_tpl_header_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_metric_tpl_header_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_metric_tpl_header_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_metric_tpl_header_rec.application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_metric_tpl_header_rec.enabled_flag := p7_a8;
    ddp_metric_tpl_header_rec.metric_tpl_header_name := p7_a9;
    ddp_metric_tpl_header_rec.description := p7_a10;
    ddp_metric_tpl_header_rec.object_type := p7_a11;
    ddp_metric_tpl_header_rec.association_type := p7_a12;
    ddp_metric_tpl_header_rec.used_by_id := rosetta_g_miss_num_map(p7_a13);
    ddp_metric_tpl_header_rec.used_by_code := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    ams_metric_template_pvt.create_metric_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_tpl_header_rec,
      x_metric_tpl_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_metric_template(p_api_version_number  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_tpl_header_rec ams_metric_template_pvt.metric_tpl_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_metric_tpl_header_rec.metric_tpl_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_metric_tpl_header_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_metric_tpl_header_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_metric_tpl_header_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_metric_tpl_header_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_metric_tpl_header_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_metric_tpl_header_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_metric_tpl_header_rec.application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_metric_tpl_header_rec.enabled_flag := p7_a8;
    ddp_metric_tpl_header_rec.metric_tpl_header_name := p7_a9;
    ddp_metric_tpl_header_rec.description := p7_a10;
    ddp_metric_tpl_header_rec.object_type := p7_a11;
    ddp_metric_tpl_header_rec.association_type := p7_a12;
    ddp_metric_tpl_header_rec.used_by_id := rosetta_g_miss_num_map(p7_a13);
    ddp_metric_tpl_header_rec.used_by_code := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    ams_metric_template_pvt.update_metric_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_tpl_header_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_metric_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_tpl_header_rec ams_metric_template_pvt.metric_tpl_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_metric_tpl_header_rec.metric_tpl_header_id := rosetta_g_miss_num_map(p3_a0);
    ddp_metric_tpl_header_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_metric_tpl_header_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_metric_tpl_header_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_metric_tpl_header_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_metric_tpl_header_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_metric_tpl_header_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_metric_tpl_header_rec.application_id := rosetta_g_miss_num_map(p3_a7);
    ddp_metric_tpl_header_rec.enabled_flag := p3_a8;
    ddp_metric_tpl_header_rec.metric_tpl_header_name := p3_a9;
    ddp_metric_tpl_header_rec.description := p3_a10;
    ddp_metric_tpl_header_rec.object_type := p3_a11;
    ddp_metric_tpl_header_rec.association_type := p3_a12;
    ddp_metric_tpl_header_rec.used_by_id := rosetta_g_miss_num_map(p3_a13);
    ddp_metric_tpl_header_rec.used_by_code := p3_a14;





    -- here's the delegated call to the old PL/SQL routine
    ams_metric_template_pvt.validate_metric_template(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_metric_tpl_header_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_met_tpl_hdr_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_tpl_header_rec ams_metric_template_pvt.metric_tpl_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_metric_tpl_header_rec.metric_tpl_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_metric_tpl_header_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_metric_tpl_header_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_metric_tpl_header_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_metric_tpl_header_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_metric_tpl_header_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_metric_tpl_header_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_metric_tpl_header_rec.application_id := rosetta_g_miss_num_map(p0_a7);
    ddp_metric_tpl_header_rec.enabled_flag := p0_a8;
    ddp_metric_tpl_header_rec.metric_tpl_header_name := p0_a9;
    ddp_metric_tpl_header_rec.description := p0_a10;
    ddp_metric_tpl_header_rec.object_type := p0_a11;
    ddp_metric_tpl_header_rec.association_type := p0_a12;
    ddp_metric_tpl_header_rec.used_by_id := rosetta_g_miss_num_map(p0_a13);
    ddp_metric_tpl_header_rec.used_by_code := p0_a14;



    -- here's the delegated call to the old PL/SQL routine
    ams_metric_template_pvt.check_met_tpl_hdr_items(ddp_metric_tpl_header_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_met_tpl_hdr_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_tpl_header_rec ams_metric_template_pvt.metric_tpl_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_metric_tpl_header_rec.metric_tpl_header_id := rosetta_g_miss_num_map(p5_a0);
    ddp_metric_tpl_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_metric_tpl_header_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_metric_tpl_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_metric_tpl_header_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_metric_tpl_header_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_metric_tpl_header_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_metric_tpl_header_rec.application_id := rosetta_g_miss_num_map(p5_a7);
    ddp_metric_tpl_header_rec.enabled_flag := p5_a8;
    ddp_metric_tpl_header_rec.metric_tpl_header_name := p5_a9;
    ddp_metric_tpl_header_rec.description := p5_a10;
    ddp_metric_tpl_header_rec.object_type := p5_a11;
    ddp_metric_tpl_header_rec.association_type := p5_a12;
    ddp_metric_tpl_header_rec.used_by_id := rosetta_g_miss_num_map(p5_a13);
    ddp_metric_tpl_header_rec.used_by_code := p5_a14;

    -- here's the delegated call to the old PL/SQL routine
    ams_metric_template_pvt.validate_met_tpl_hdr_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_tpl_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_metric_template_pvt_w;

/
