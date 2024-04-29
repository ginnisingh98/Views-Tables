--------------------------------------------------------
--  DDL for Package Body PV_GE_HL_PARAM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_HL_PARAM_PVT_W" as
  /* $Header: pvxwghpb.pls 120.1 2005/09/06 04:57 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_ge_hl_param_pvt.ge_hl_param_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).history_log_param_id := a0(indx);
          t(ddindx).entity_history_log_id := a1(indx);
          t(ddindx).param_name := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          t(ddindx).param_value := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := a6(indx);
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := a8(indx);
          t(ddindx).last_update_login := a9(indx);
          t(ddindx).param_type := a10(indx);
          t(ddindx).lookup_type := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_ge_hl_param_pvt.ge_hl_param_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).history_log_param_id;
          a1(indx) := t(ddindx).entity_history_log_id;
          a2(indx) := t(ddindx).param_name;
          a3(indx) := t(ddindx).object_version_number;
          a4(indx) := t(ddindx).param_value;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
          a10(indx) := t(ddindx).param_type;
          a11(indx) := t(ddindx).lookup_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_ge_hl_param(p_api_version_number  NUMBER
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
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , x_history_log_param_id out nocopy  NUMBER
  )

  as
    ddp_ge_hl_param_rec pv_ge_hl_param_pvt.ge_hl_param_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_hl_param_rec.history_log_param_id := p7_a0;
    ddp_ge_hl_param_rec.entity_history_log_id := p7_a1;
    ddp_ge_hl_param_rec.param_name := p7_a2;
    ddp_ge_hl_param_rec.object_version_number := p7_a3;
    ddp_ge_hl_param_rec.param_value := p7_a4;
    ddp_ge_hl_param_rec.created_by := p7_a5;
    ddp_ge_hl_param_rec.creation_date := p7_a6;
    ddp_ge_hl_param_rec.last_updated_by := p7_a7;
    ddp_ge_hl_param_rec.last_update_date := p7_a8;
    ddp_ge_hl_param_rec.last_update_login := p7_a9;
    ddp_ge_hl_param_rec.param_type := p7_a10;
    ddp_ge_hl_param_rec.lookup_type := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hl_param_pvt.create_ge_hl_param(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hl_param_rec,
      x_history_log_param_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ge_hl_param(p_api_version_number  NUMBER
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
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
  )

  as
    ddp_ge_hl_param_rec pv_ge_hl_param_pvt.ge_hl_param_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_hl_param_rec.history_log_param_id := p7_a0;
    ddp_ge_hl_param_rec.entity_history_log_id := p7_a1;
    ddp_ge_hl_param_rec.param_name := p7_a2;
    ddp_ge_hl_param_rec.object_version_number := p7_a3;
    ddp_ge_hl_param_rec.param_value := p7_a4;
    ddp_ge_hl_param_rec.created_by := p7_a5;
    ddp_ge_hl_param_rec.creation_date := p7_a6;
    ddp_ge_hl_param_rec.last_updated_by := p7_a7;
    ddp_ge_hl_param_rec.last_update_date := p7_a8;
    ddp_ge_hl_param_rec.last_update_login := p7_a9;
    ddp_ge_hl_param_rec.param_type := p7_a10;
    ddp_ge_hl_param_rec.lookup_type := p7_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hl_param_pvt.update_ge_hl_param(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hl_param_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_ge_hl_param(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  VARCHAR2
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ge_hl_param_rec pv_ge_hl_param_pvt.ge_hl_param_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ge_hl_param_rec.history_log_param_id := p3_a0;
    ddp_ge_hl_param_rec.entity_history_log_id := p3_a1;
    ddp_ge_hl_param_rec.param_name := p3_a2;
    ddp_ge_hl_param_rec.object_version_number := p3_a3;
    ddp_ge_hl_param_rec.param_value := p3_a4;
    ddp_ge_hl_param_rec.created_by := p3_a5;
    ddp_ge_hl_param_rec.creation_date := p3_a6;
    ddp_ge_hl_param_rec.last_updated_by := p3_a7;
    ddp_ge_hl_param_rec.last_update_date := p3_a8;
    ddp_ge_hl_param_rec.last_update_login := p3_a9;
    ddp_ge_hl_param_rec.param_type := p3_a10;
    ddp_ge_hl_param_rec.lookup_type := p3_a11;





    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hl_param_pvt.validate_ge_hl_param(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ge_hl_param_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_ge_hl_param_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_ge_hl_param_rec pv_ge_hl_param_pvt.ge_hl_param_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ge_hl_param_rec.history_log_param_id := p0_a0;
    ddp_ge_hl_param_rec.entity_history_log_id := p0_a1;
    ddp_ge_hl_param_rec.param_name := p0_a2;
    ddp_ge_hl_param_rec.object_version_number := p0_a3;
    ddp_ge_hl_param_rec.param_value := p0_a4;
    ddp_ge_hl_param_rec.created_by := p0_a5;
    ddp_ge_hl_param_rec.creation_date := p0_a6;
    ddp_ge_hl_param_rec.last_updated_by := p0_a7;
    ddp_ge_hl_param_rec.last_update_date := p0_a8;
    ddp_ge_hl_param_rec.last_update_login := p0_a9;
    ddp_ge_hl_param_rec.param_type := p0_a10;
    ddp_ge_hl_param_rec.lookup_type := p0_a11;



    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hl_param_pvt.check_ge_hl_param_items(ddp_ge_hl_param_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_ge_hl_param_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
  )

  as
    ddp_ge_hl_param_rec pv_ge_hl_param_pvt.ge_hl_param_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ge_hl_param_rec.history_log_param_id := p5_a0;
    ddp_ge_hl_param_rec.entity_history_log_id := p5_a1;
    ddp_ge_hl_param_rec.param_name := p5_a2;
    ddp_ge_hl_param_rec.object_version_number := p5_a3;
    ddp_ge_hl_param_rec.param_value := p5_a4;
    ddp_ge_hl_param_rec.created_by := p5_a5;
    ddp_ge_hl_param_rec.creation_date := p5_a6;
    ddp_ge_hl_param_rec.last_updated_by := p5_a7;
    ddp_ge_hl_param_rec.last_update_date := p5_a8;
    ddp_ge_hl_param_rec.last_update_login := p5_a9;
    ddp_ge_hl_param_rec.param_type := p5_a10;
    ddp_ge_hl_param_rec.lookup_type := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_hl_param_pvt.validate_ge_hl_param_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_hl_param_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_ge_hl_param_pvt_w;

/
