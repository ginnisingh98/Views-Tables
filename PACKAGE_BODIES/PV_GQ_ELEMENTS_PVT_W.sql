--------------------------------------------------------
--  DDL for Package Body PV_GQ_ELEMENTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GQ_ELEMENTS_PVT_W" as
  /* $Header: pvxwgqeb.pls 120.1 2008/03/20 22:18:17 hekkiral ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_gq_elements_pvt.qsnr_element_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_1600
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qsnr_element_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).arc_used_by_entity_code := a2(indx);
          t(ddindx).used_by_entity_id := a3(indx);
          t(ddindx).qsnr_elmt_seq_num := a4(indx);
          t(ddindx).qsnr_elmt_type := a5(indx);
          t(ddindx).entity_attr_id := a6(indx);
          t(ddindx).qsnr_elmt_page_num := a7(indx);
          t(ddindx).is_required_flag := a8(indx);
          t(ddindx).created_by := a9(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := a11(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_update_login := a13(indx);
          t(ddindx).elmt_content := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_gq_elements_pvt.qsnr_element_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_1600
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_1600();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_1600();
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
          a0(indx) := t(ddindx).qsnr_element_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).arc_used_by_entity_code;
          a3(indx) := t(ddindx).used_by_entity_id;
          a4(indx) := t(ddindx).qsnr_elmt_seq_num;
          a5(indx) := t(ddindx).qsnr_elmt_type;
          a6(indx) := t(ddindx).entity_attr_id;
          a7(indx) := t(ddindx).qsnr_elmt_page_num;
          a8(indx) := t(ddindx).is_required_flag;
          a9(indx) := t(ddindx).created_by;
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := t(ddindx).last_updated_by;
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := t(ddindx).last_update_login;
          a14(indx) := t(ddindx).elmt_content;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_gq_elements(p_api_version_number  NUMBER
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
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , x_qsnr_element_id out nocopy  NUMBER
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_qsnr_element_rec.qsnr_element_id := p7_a0;
    ddp_qsnr_element_rec.object_version_number := p7_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p7_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p7_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p7_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p7_a5;
    ddp_qsnr_element_rec.entity_attr_id := p7_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p7_a7;
    ddp_qsnr_element_rec.is_required_flag := p7_a8;
    ddp_qsnr_element_rec.created_by := p7_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_qsnr_element_rec.last_updated_by := p7_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_qsnr_element_rec.last_update_login := p7_a13;
    ddp_qsnr_element_rec.elmt_content := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.create_gq_elements(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qsnr_element_rec,
      x_qsnr_element_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_gq_elements(p_api_version_number  NUMBER
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
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_qsnr_element_rec.qsnr_element_id := p7_a0;
    ddp_qsnr_element_rec.object_version_number := p7_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p7_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p7_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p7_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p7_a5;
    ddp_qsnr_element_rec.entity_attr_id := p7_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p7_a7;
    ddp_qsnr_element_rec.is_required_flag := p7_a8;
    ddp_qsnr_element_rec.created_by := p7_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_qsnr_element_rec.last_updated_by := p7_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_qsnr_element_rec.last_update_login := p7_a13;
    ddp_qsnr_element_rec.elmt_content := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.update_gq_elements(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qsnr_element_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_gq_elements(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  VARCHAR2
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  VARCHAR2
    , p3_a9  NUMBER
    , p3_a10  DATE
    , p3_a11  NUMBER
    , p3_a12  DATE
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_qsnr_element_rec.qsnr_element_id := p3_a0;
    ddp_qsnr_element_rec.object_version_number := p3_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p3_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p3_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p3_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p3_a5;
    ddp_qsnr_element_rec.entity_attr_id := p3_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p3_a7;
    ddp_qsnr_element_rec.is_required_flag := p3_a8;
    ddp_qsnr_element_rec.created_by := p3_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p3_a10);
    ddp_qsnr_element_rec.last_updated_by := p3_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_qsnr_element_rec.last_update_login := p3_a13;
    ddp_qsnr_element_rec.elmt_content := p3_a14;





    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.validate_gq_elements(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_qsnr_element_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_qsnr_element_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_qsnr_element_rec.qsnr_element_id := p0_a0;
    ddp_qsnr_element_rec.object_version_number := p0_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p0_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p0_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p0_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p0_a5;
    ddp_qsnr_element_rec.entity_attr_id := p0_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p0_a7;
    ddp_qsnr_element_rec.is_required_flag := p0_a8;
    ddp_qsnr_element_rec.created_by := p0_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_qsnr_element_rec.last_updated_by := p0_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_qsnr_element_rec.last_update_login := p0_a13;
    ddp_qsnr_element_rec.elmt_content := p0_a14;



    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.check_qsnr_element_items(ddp_qsnr_element_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_qsnr_element_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qsnr_element_rec.qsnr_element_id := p5_a0;
    ddp_qsnr_element_rec.object_version_number := p5_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p5_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p5_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p5_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p5_a5;
    ddp_qsnr_element_rec.entity_attr_id := p5_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p5_a7;
    ddp_qsnr_element_rec.is_required_flag := p5_a8;
    ddp_qsnr_element_rec.created_by := p5_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qsnr_element_rec.last_updated_by := p5_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_qsnr_element_rec.last_update_login := p5_a13;
    ddp_qsnr_element_rec.elmt_content := p5_a14;

    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.validate_qsnr_element_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qsnr_element_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure move_qsnr_element(p_api_version_number  NUMBER
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
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p_movement  VARCHAR2
  )

  as
    ddp_qsnr_element_rec pv_gq_elements_pvt.qsnr_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_qsnr_element_rec.qsnr_element_id := p7_a0;
    ddp_qsnr_element_rec.object_version_number := p7_a1;
    ddp_qsnr_element_rec.arc_used_by_entity_code := p7_a2;
    ddp_qsnr_element_rec.used_by_entity_id := p7_a3;
    ddp_qsnr_element_rec.qsnr_elmt_seq_num := p7_a4;
    ddp_qsnr_element_rec.qsnr_elmt_type := p7_a5;
    ddp_qsnr_element_rec.entity_attr_id := p7_a6;
    ddp_qsnr_element_rec.qsnr_elmt_page_num := p7_a7;
    ddp_qsnr_element_rec.is_required_flag := p7_a8;
    ddp_qsnr_element_rec.created_by := p7_a9;
    ddp_qsnr_element_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_qsnr_element_rec.last_updated_by := p7_a11;
    ddp_qsnr_element_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_qsnr_element_rec.last_update_login := p7_a13;
    ddp_qsnr_element_rec.elmt_content := p7_a14;


    -- here's the delegated call to the old PL/SQL routine
    pv_gq_elements_pvt.move_qsnr_element(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qsnr_element_rec,
      p_movement);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end pv_gq_elements_pvt_w;

/
