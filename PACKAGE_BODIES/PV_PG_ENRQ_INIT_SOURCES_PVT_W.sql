--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRQ_INIT_SOURCES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRQ_INIT_SOURCES_PVT_W" as
  /* $Header: pvxwpeib.pls 115.1 2002/11/28 01:15:52 jkylee ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_pg_enrq_init_sources_pvt.enrq_init_sources_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).initiation_source_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).enrl_request_id := a2(indx);
          t(ddindx).prev_membership_id := a3(indx);
          t(ddindx).enrl_change_rule_id := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_pg_enrq_init_sources_pvt.enrq_init_sources_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).initiation_source_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).enrl_request_id;
          a3(indx) := t(ddindx).prev_membership_id;
          a4(indx) := t(ddindx).enrl_change_rule_id;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_pg_enrq_init_sources(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , x_initiation_source_id out nocopy  NUMBER
  )

  as
    ddp_enrq_init_sources_rec pv_pg_enrq_init_sources_pvt.enrq_init_sources_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enrq_init_sources_rec.initiation_source_id := p7_a0;
    ddp_enrq_init_sources_rec.object_version_number := p7_a1;
    ddp_enrq_init_sources_rec.enrl_request_id := p7_a2;
    ddp_enrq_init_sources_rec.prev_membership_id := p7_a3;
    ddp_enrq_init_sources_rec.enrl_change_rule_id := p7_a4;
    ddp_enrq_init_sources_rec.created_by := p7_a5;
    ddp_enrq_init_sources_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_enrq_init_sources_rec.last_updated_by := p7_a7;
    ddp_enrq_init_sources_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_enrq_init_sources_rec.last_update_login := p7_a9;


    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrq_init_sources_pvt.create_pg_enrq_init_sources(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrq_init_sources_rec,
      x_initiation_source_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_pg_enrq_init_sources(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
  )

  as
    ddp_enrq_init_sources_rec pv_pg_enrq_init_sources_pvt.enrq_init_sources_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enrq_init_sources_rec.initiation_source_id := p7_a0;
    ddp_enrq_init_sources_rec.object_version_number := p7_a1;
    ddp_enrq_init_sources_rec.enrl_request_id := p7_a2;
    ddp_enrq_init_sources_rec.prev_membership_id := p7_a3;
    ddp_enrq_init_sources_rec.enrl_change_rule_id := p7_a4;
    ddp_enrq_init_sources_rec.created_by := p7_a5;
    ddp_enrq_init_sources_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_enrq_init_sources_rec.last_updated_by := p7_a7;
    ddp_enrq_init_sources_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_enrq_init_sources_rec.last_update_login := p7_a9;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrq_init_sources_pvt.update_pg_enrq_init_sources(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrq_init_sources_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_pg_init_src(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_enrq_init_sources_rec pv_pg_enrq_init_sources_pvt.enrq_init_sources_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_enrq_init_sources_rec.initiation_source_id := p3_a0;
    ddp_enrq_init_sources_rec.object_version_number := p3_a1;
    ddp_enrq_init_sources_rec.enrl_request_id := p3_a2;
    ddp_enrq_init_sources_rec.prev_membership_id := p3_a3;
    ddp_enrq_init_sources_rec.enrl_change_rule_id := p3_a4;
    ddp_enrq_init_sources_rec.created_by := p3_a5;
    ddp_enrq_init_sources_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_enrq_init_sources_rec.last_updated_by := p3_a7;
    ddp_enrq_init_sources_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_enrq_init_sources_rec.last_update_login := p3_a9;





    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrq_init_sources_pvt.validate_pg_init_src(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_enrq_init_sources_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_init_src_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_enrq_init_sources_rec pv_pg_enrq_init_sources_pvt.enrq_init_sources_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_enrq_init_sources_rec.initiation_source_id := p0_a0;
    ddp_enrq_init_sources_rec.object_version_number := p0_a1;
    ddp_enrq_init_sources_rec.enrl_request_id := p0_a2;
    ddp_enrq_init_sources_rec.prev_membership_id := p0_a3;
    ddp_enrq_init_sources_rec.enrl_change_rule_id := p0_a4;
    ddp_enrq_init_sources_rec.created_by := p0_a5;
    ddp_enrq_init_sources_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_enrq_init_sources_rec.last_updated_by := p0_a7;
    ddp_enrq_init_sources_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_enrq_init_sources_rec.last_update_login := p0_a9;



    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrq_init_sources_pvt.check_init_src_items(ddp_enrq_init_sources_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_init_src_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_enrq_init_sources_rec pv_pg_enrq_init_sources_pvt.enrq_init_sources_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_enrq_init_sources_rec.initiation_source_id := p5_a0;
    ddp_enrq_init_sources_rec.object_version_number := p5_a1;
    ddp_enrq_init_sources_rec.enrl_request_id := p5_a2;
    ddp_enrq_init_sources_rec.prev_membership_id := p5_a3;
    ddp_enrq_init_sources_rec.enrl_change_rule_id := p5_a4;
    ddp_enrq_init_sources_rec.created_by := p5_a5;
    ddp_enrq_init_sources_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_enrq_init_sources_rec.last_updated_by := p5_a7;
    ddp_enrq_init_sources_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_enrq_init_sources_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrq_init_sources_pvt.validate_init_src_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrq_init_sources_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_pg_enrq_init_sources_pvt_w;

/
