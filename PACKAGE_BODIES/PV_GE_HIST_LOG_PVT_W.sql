--------------------------------------------------------
--  DDL for Package Body PV_GE_HIST_LOG_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_HIST_LOG_PVT_W" as
  /* $Header: pvxwghlb.pls 115.4 2003/08/08 23:57:49 ktsao ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_ge_hist_log_pvt.ge_hist_log_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entity_history_log_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).arc_history_for_entity_code := a2(indx);
          t(ddindx).history_for_entity_id := a3(indx);
          t(ddindx).message_code := a4(indx);
          t(ddindx).history_category_code := a5(indx);
          t(ddindx).created_by := a6(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := a8(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_update_login := a10(indx);
          t(ddindx).partner_id := a11(indx);
          t(ddindx).access_level_flag := a12(indx);
          t(ddindx).interaction_level := a13(indx);
          t(ddindx).comments := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_ge_hist_log_pvt.ge_hist_log_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := t(ddindx).entity_history_log_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).arc_history_for_entity_code;
          a3(indx) := t(ddindx).history_for_entity_id;
          a4(indx) := t(ddindx).message_code;
          a5(indx) := t(ddindx).history_category_code;
          a6(indx) := t(ddindx).created_by;
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := t(ddindx).last_updated_by;
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := t(ddindx).last_update_login;
          a11(indx) := t(ddindx).partner_id;
          a12(indx) := t(ddindx).access_level_flag;
          a13(indx) := t(ddindx).interaction_level;
          a14(indx) := t(ddindx).comments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_ge_hist_log(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , x_entity_history_log_id out nocopy  NUMBER
  )

  as
    ddp_ge_hist_log_rec pv_ge_hist_log_pvt.ge_hist_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_hist_log_rec.entity_history_log_id := p7_a0;
    ddp_ge_hist_log_rec.object_version_number := p7_a1;
    ddp_ge_hist_log_rec.arc_history_for_entity_code := p7_a2;
    ddp_ge_hist_log_rec.history_for_entity_id := p7_a3;
    ddp_ge_hist_log_rec.message_code := p7_a4;
    ddp_ge_hist_log_rec.history_category_code := p7_a5;
    ddp_ge_hist_log_rec.created_by := p7_a6;
    ddp_ge_hist_log_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ge_hist_log_rec.last_updated_by := p7_a8;
    ddp_ge_hist_log_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_ge_hist_log_rec.last_update_login := p7_a10;
    ddp_ge_hist_log_rec.partner_id := p7_a11;
    ddp_ge_hist_log_rec.access_level_flag := p7_a12;
    ddp_ge_hist_log_rec.interaction_level := p7_a13;
    ddp_ge_hist_log_rec.comments := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hist_log_pvt.create_ge_hist_log(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hist_log_rec,
      x_entity_history_log_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ge_hist_log(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
  )

  as
    ddp_ge_hist_log_rec pv_ge_hist_log_pvt.ge_hist_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_hist_log_rec.entity_history_log_id := p7_a0;
    ddp_ge_hist_log_rec.object_version_number := p7_a1;
    ddp_ge_hist_log_rec.arc_history_for_entity_code := p7_a2;
    ddp_ge_hist_log_rec.history_for_entity_id := p7_a3;
    ddp_ge_hist_log_rec.message_code := p7_a4;
    ddp_ge_hist_log_rec.history_category_code := p7_a5;
    ddp_ge_hist_log_rec.created_by := p7_a6;
    ddp_ge_hist_log_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ge_hist_log_rec.last_updated_by := p7_a8;
    ddp_ge_hist_log_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_ge_hist_log_rec.last_update_login := p7_a10;
    ddp_ge_hist_log_rec.partner_id := p7_a11;
    ddp_ge_hist_log_rec.access_level_flag := p7_a12;
    ddp_ge_hist_log_rec.interaction_level := p7_a13;
    ddp_ge_hist_log_rec.comments := p7_a14;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hist_log_pvt.update_ge_hist_log(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hist_log_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_ge_hist_log(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ge_hist_log_rec pv_ge_hist_log_pvt.ge_hist_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ge_hist_log_rec.entity_history_log_id := p3_a0;
    ddp_ge_hist_log_rec.object_version_number := p3_a1;
    ddp_ge_hist_log_rec.arc_history_for_entity_code := p3_a2;
    ddp_ge_hist_log_rec.history_for_entity_id := p3_a3;
    ddp_ge_hist_log_rec.message_code := p3_a4;
    ddp_ge_hist_log_rec.history_category_code := p3_a5;
    ddp_ge_hist_log_rec.created_by := p3_a6;
    ddp_ge_hist_log_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_ge_hist_log_rec.last_updated_by := p3_a8;
    ddp_ge_hist_log_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_ge_hist_log_rec.last_update_login := p3_a10;
    ddp_ge_hist_log_rec.partner_id := p3_a11;
    ddp_ge_hist_log_rec.access_level_flag := p3_a12;
    ddp_ge_hist_log_rec.interaction_level := p3_a13;
    ddp_ge_hist_log_rec.comments := p3_a14;





    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hist_log_pvt.validate_ge_hist_log(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ge_hist_log_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_ge_hist_log_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_ge_hist_log_rec pv_ge_hist_log_pvt.ge_hist_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ge_hist_log_rec.entity_history_log_id := p0_a0;
    ddp_ge_hist_log_rec.object_version_number := p0_a1;
    ddp_ge_hist_log_rec.arc_history_for_entity_code := p0_a2;
    ddp_ge_hist_log_rec.history_for_entity_id := p0_a3;
    ddp_ge_hist_log_rec.message_code := p0_a4;
    ddp_ge_hist_log_rec.history_category_code := p0_a5;
    ddp_ge_hist_log_rec.created_by := p0_a6;
    ddp_ge_hist_log_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_ge_hist_log_rec.last_updated_by := p0_a8;
    ddp_ge_hist_log_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_ge_hist_log_rec.last_update_login := p0_a10;
    ddp_ge_hist_log_rec.partner_id := p0_a11;
    ddp_ge_hist_log_rec.access_level_flag := p0_a12;
    ddp_ge_hist_log_rec.interaction_level := p0_a13;
    ddp_ge_hist_log_rec.comments := p0_a14;



    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hist_log_pvt.check_ge_hist_log_items(ddp_ge_hist_log_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_ge_hist_log_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
  )

  as
    ddp_ge_hist_log_rec pv_ge_hist_log_pvt.ge_hist_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ge_hist_log_rec.entity_history_log_id := p5_a0;
    ddp_ge_hist_log_rec.object_version_number := p5_a1;
    ddp_ge_hist_log_rec.arc_history_for_entity_code := p5_a2;
    ddp_ge_hist_log_rec.history_for_entity_id := p5_a3;
    ddp_ge_hist_log_rec.message_code := p5_a4;
    ddp_ge_hist_log_rec.history_category_code := p5_a5;
    ddp_ge_hist_log_rec.created_by := p5_a6;
    ddp_ge_hist_log_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_ge_hist_log_rec.last_updated_by := p5_a8;
    ddp_ge_hist_log_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_ge_hist_log_rec.last_update_login := p5_a10;
    ddp_ge_hist_log_rec.partner_id := p5_a11;
    ddp_ge_hist_log_rec.access_level_flag := p5_a12;
    ddp_ge_hist_log_rec.interaction_level := p5_a13;
    ddp_ge_hist_log_rec.comments := p5_a14;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hist_log_pvt.validate_ge_hist_log_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hist_log_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_ge_hist_log_pvt_w;

/
