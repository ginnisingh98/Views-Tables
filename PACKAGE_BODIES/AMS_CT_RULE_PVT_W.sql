--------------------------------------------------------
--  DDL for Package Body AMS_CT_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CT_RULE_PVT_W" as
  /* $Header: amswctrb.pls 120.2 2006/05/30 11:11:11 prageorg noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_ct_rule_pvt.ct_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).content_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_updated_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_type := a7(indx);
          t(ddindx).object_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).sender := a9(indx);
          t(ddindx).reply_to := a10(indx);
          t(ddindx).cover_letter_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).table_of_content_flag := a12(indx);
          t(ddindx).trigger_code := a13(indx);
          t(ddindx).enabled_flag := a14(indx);
          t(ddindx).subject := a15(indx);
          t(ddindx).sender_display_name := a16(indx);
          t(ddindx).delivery_mode := a17(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_ct_rule_pvt.ct_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_100();
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
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).content_rule_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a4(indx) := t(ddindx).last_updated_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).object_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a9(indx) := t(ddindx).sender;
          a10(indx) := t(ddindx).reply_to;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).cover_letter_id);
          a12(indx) := t(ddindx).table_of_content_flag;
          a13(indx) := t(ddindx).trigger_code;
          a14(indx) := t(ddindx).enabled_flag;
          a15(indx) := t(ddindx).subject;
          a16(indx) := t(ddindx).sender_display_name;
          a17(indx) := t(ddindx).delivery_mode;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_ct_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_content_rule_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ct_rule_rec ams_ct_rule_pvt.ct_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ct_rule_rec.content_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ct_rule_rec.created_by := rosetta_g_miss_num_map(p7_a1);
    ddp_ct_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_ct_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_ct_rule_rec.last_updated_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_ct_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_ct_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_ct_rule_rec.object_type := p7_a7;
    ddp_ct_rule_rec.object_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ct_rule_rec.sender := p7_a9;
    ddp_ct_rule_rec.reply_to := p7_a10;
    ddp_ct_rule_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a11);
    ddp_ct_rule_rec.table_of_content_flag := p7_a12;
    ddp_ct_rule_rec.trigger_code := p7_a13;
    ddp_ct_rule_rec.enabled_flag := p7_a14;
    ddp_ct_rule_rec.subject := p7_a15;
    ddp_ct_rule_rec.sender_display_name := p7_a16;
    ddp_ct_rule_rec.delivery_mode := p7_a17;


    -- here's the delegated call to the old PL/SQL routine
    ams_ct_rule_pvt.create_ct_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ct_rule_rec,
      x_content_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ct_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ct_rule_rec ams_ct_rule_pvt.ct_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ct_rule_rec.content_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ct_rule_rec.created_by := rosetta_g_miss_num_map(p7_a1);
    ddp_ct_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_ct_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_ct_rule_rec.last_updated_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_ct_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_ct_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_ct_rule_rec.object_type := p7_a7;
    ddp_ct_rule_rec.object_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ct_rule_rec.sender := p7_a9;
    ddp_ct_rule_rec.reply_to := p7_a10;
    ddp_ct_rule_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a11);
    ddp_ct_rule_rec.table_of_content_flag := p7_a12;
    ddp_ct_rule_rec.trigger_code := p7_a13;
    ddp_ct_rule_rec.enabled_flag := p7_a14;
    ddp_ct_rule_rec.subject := p7_a15;
    ddp_ct_rule_rec.sender_display_name := p7_a16;
    ddp_ct_rule_rec.delivery_mode := p7_a17;


    -- here's the delegated call to the old PL/SQL routine
    ams_ct_rule_pvt.update_ct_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ct_rule_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_ct_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ct_rule_rec ams_ct_rule_pvt.ct_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ct_rule_rec.content_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddp_ct_rule_rec.created_by := rosetta_g_miss_num_map(p3_a1);
    ddp_ct_rule_rec.creation_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_ct_rule_rec.last_updated_by := rosetta_g_miss_num_map(p3_a3);
    ddp_ct_rule_rec.last_updated_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_ct_rule_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_ct_rule_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_ct_rule_rec.object_type := p3_a7;
    ddp_ct_rule_rec.object_id := rosetta_g_miss_num_map(p3_a8);
    ddp_ct_rule_rec.sender := p3_a9;
    ddp_ct_rule_rec.reply_to := p3_a10;
    ddp_ct_rule_rec.cover_letter_id := rosetta_g_miss_num_map(p3_a11);
    ddp_ct_rule_rec.table_of_content_flag := p3_a12;
    ddp_ct_rule_rec.trigger_code := p3_a13;
    ddp_ct_rule_rec.enabled_flag := p3_a14;
    ddp_ct_rule_rec.subject := p3_a15;
    ddp_ct_rule_rec.sender_display_name := p3_a16;
    ddp_ct_rule_rec.delivery_mode := p3_a17;





    -- here's the delegated call to the old PL/SQL routine
    ams_ct_rule_pvt.validate_ct_rule(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ct_rule_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_ct_rule_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ct_rule_rec ams_ct_rule_pvt.ct_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ct_rule_rec.content_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_ct_rule_rec.created_by := rosetta_g_miss_num_map(p0_a1);
    ddp_ct_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_ct_rule_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_ct_rule_rec.last_updated_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_ct_rule_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_ct_rule_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_ct_rule_rec.object_type := p0_a7;
    ddp_ct_rule_rec.object_id := rosetta_g_miss_num_map(p0_a8);
    ddp_ct_rule_rec.sender := p0_a9;
    ddp_ct_rule_rec.reply_to := p0_a10;
    ddp_ct_rule_rec.cover_letter_id := rosetta_g_miss_num_map(p0_a11);
    ddp_ct_rule_rec.table_of_content_flag := p0_a12;
    ddp_ct_rule_rec.trigger_code := p0_a13;
    ddp_ct_rule_rec.enabled_flag := p0_a14;
    ddp_ct_rule_rec.subject := p0_a15;
    ddp_ct_rule_rec.sender_display_name := p0_a16;
    ddp_ct_rule_rec.delivery_mode := p0_a17;



    -- here's the delegated call to the old PL/SQL routine
    ams_ct_rule_pvt.check_ct_rule_items(ddp_ct_rule_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_ct_rule_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ct_rule_rec ams_ct_rule_pvt.ct_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ct_rule_rec.content_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_ct_rule_rec.created_by := rosetta_g_miss_num_map(p5_a1);
    ddp_ct_rule_rec.creation_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_ct_rule_rec.last_updated_by := rosetta_g_miss_num_map(p5_a3);
    ddp_ct_rule_rec.last_updated_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_ct_rule_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_ct_rule_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_ct_rule_rec.object_type := p5_a7;
    ddp_ct_rule_rec.object_id := rosetta_g_miss_num_map(p5_a8);
    ddp_ct_rule_rec.sender := p5_a9;
    ddp_ct_rule_rec.reply_to := p5_a10;
    ddp_ct_rule_rec.cover_letter_id := rosetta_g_miss_num_map(p5_a11);
    ddp_ct_rule_rec.table_of_content_flag := p5_a12;
    ddp_ct_rule_rec.trigger_code := p5_a13;
    ddp_ct_rule_rec.enabled_flag := p5_a14;
    ddp_ct_rule_rec.subject := p5_a15;
    ddp_ct_rule_rec.sender_display_name := p5_a16;
    ddp_ct_rule_rec.delivery_mode := p5_a17;

    -- here's the delegated call to the old PL/SQL routine
    ams_ct_rule_pvt.validate_ct_rule_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ct_rule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_ct_rule_pvt_w;

/
