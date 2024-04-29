--------------------------------------------------------
--  DDL for Package Body PV_TAP_ACCESS_TERRS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TAP_ACCESS_TERRS_PVT_W" as
  /* $Header: pvxwtrab.pls 115.0 2003/10/15 04:23:10 rdsharma noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_tap_access_terrs_pvt.tap_access_terrs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_access_id := a0(indx);
          t(ddindx).terr_id := a1(indx);
          t(ddindx).last_update_date := a2(indx);
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).request_id := a8(indx);
          t(ddindx).program_application_id := a9(indx);
          t(ddindx).program_id := a10(indx);
          t(ddindx).program_update_date := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_tap_access_terrs_pvt.tap_access_terrs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).partner_access_id;
          a1(indx) := t(ddindx).terr_id;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).request_id;
          a9(indx) := t(ddindx).program_application_id;
          a10(indx) := t(ddindx).program_id;
          a11(indx) := t(ddindx).program_update_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_tap_access_terrs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
  )

  as
    ddp_tap_access_terrs_rec pv_tap_access_terrs_pvt.tap_access_terrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_tap_access_terrs_rec.partner_access_id := p7_a0;
    ddp_tap_access_terrs_rec.terr_id := p7_a1;
    ddp_tap_access_terrs_rec.last_update_date := p7_a2;
    ddp_tap_access_terrs_rec.last_updated_by := p7_a3;
    ddp_tap_access_terrs_rec.creation_date := p7_a4;
    ddp_tap_access_terrs_rec.created_by := p7_a5;
    ddp_tap_access_terrs_rec.last_update_login := p7_a6;
    ddp_tap_access_terrs_rec.object_version_number := p7_a7;
    ddp_tap_access_terrs_rec.request_id := p7_a8;
    ddp_tap_access_terrs_rec.program_application_id := p7_a9;
    ddp_tap_access_terrs_rec.program_id := p7_a10;
    ddp_tap_access_terrs_rec.program_update_date := p7_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_tap_access_terrs_pvt.create_tap_access_terrs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tap_access_terrs_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_tap_access_terrs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
  )

  as
    ddp_tap_access_terrs_rec pv_tap_access_terrs_pvt.tap_access_terrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_tap_access_terrs_rec.partner_access_id := p7_a0;
    ddp_tap_access_terrs_rec.terr_id := p7_a1;
    ddp_tap_access_terrs_rec.last_update_date := p7_a2;
    ddp_tap_access_terrs_rec.last_updated_by := p7_a3;
    ddp_tap_access_terrs_rec.creation_date := p7_a4;
    ddp_tap_access_terrs_rec.created_by := p7_a5;
    ddp_tap_access_terrs_rec.last_update_login := p7_a6;
    ddp_tap_access_terrs_rec.object_version_number := p7_a7;
    ddp_tap_access_terrs_rec.request_id := p7_a8;
    ddp_tap_access_terrs_rec.program_application_id := p7_a9;
    ddp_tap_access_terrs_rec.program_id := p7_a10;
    ddp_tap_access_terrs_rec.program_update_date := p7_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_tap_access_terrs_pvt.update_tap_access_terrs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tap_access_terrs_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_tap_access_terrs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tap_access_terrs_rec pv_tap_access_terrs_pvt.tap_access_terrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_tap_access_terrs_rec.partner_access_id := p4_a0;
    ddp_tap_access_terrs_rec.terr_id := p4_a1;
    ddp_tap_access_terrs_rec.last_update_date := p4_a2;
    ddp_tap_access_terrs_rec.last_updated_by := p4_a3;
    ddp_tap_access_terrs_rec.creation_date := p4_a4;
    ddp_tap_access_terrs_rec.created_by := p4_a5;
    ddp_tap_access_terrs_rec.last_update_login := p4_a6;
    ddp_tap_access_terrs_rec.object_version_number := p4_a7;
    ddp_tap_access_terrs_rec.request_id := p4_a8;
    ddp_tap_access_terrs_rec.program_application_id := p4_a9;
    ddp_tap_access_terrs_rec.program_id := p4_a10;
    ddp_tap_access_terrs_rec.program_update_date := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    pv_tap_access_terrs_pvt.validate_tap_access_terrs(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_tap_access_terrs_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure chk_tap_access_terrs_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_tap_access_terrs_rec pv_tap_access_terrs_pvt.tap_access_terrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_tap_access_terrs_rec.partner_access_id := p0_a0;
    ddp_tap_access_terrs_rec.terr_id := p0_a1;
    ddp_tap_access_terrs_rec.last_update_date := p0_a2;
    ddp_tap_access_terrs_rec.last_updated_by := p0_a3;
    ddp_tap_access_terrs_rec.creation_date := p0_a4;
    ddp_tap_access_terrs_rec.created_by := p0_a5;
    ddp_tap_access_terrs_rec.last_update_login := p0_a6;
    ddp_tap_access_terrs_rec.object_version_number := p0_a7;
    ddp_tap_access_terrs_rec.request_id := p0_a8;
    ddp_tap_access_terrs_rec.program_application_id := p0_a9;
    ddp_tap_access_terrs_rec.program_id := p0_a10;
    ddp_tap_access_terrs_rec.program_update_date := p0_a11;



    -- here's the delegated call to the old PL/SQL routine
    pv_tap_access_terrs_pvt.chk_tap_access_terrs_items(ddp_tap_access_terrs_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_tap_access_terrs_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  DATE
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
  )

  as
    ddp_tap_access_terrs_rec pv_tap_access_terrs_pvt.tap_access_terrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tap_access_terrs_rec.partner_access_id := p5_a0;
    ddp_tap_access_terrs_rec.terr_id := p5_a1;
    ddp_tap_access_terrs_rec.last_update_date := p5_a2;
    ddp_tap_access_terrs_rec.last_updated_by := p5_a3;
    ddp_tap_access_terrs_rec.creation_date := p5_a4;
    ddp_tap_access_terrs_rec.created_by := p5_a5;
    ddp_tap_access_terrs_rec.last_update_login := p5_a6;
    ddp_tap_access_terrs_rec.object_version_number := p5_a7;
    ddp_tap_access_terrs_rec.request_id := p5_a8;
    ddp_tap_access_terrs_rec.program_application_id := p5_a9;
    ddp_tap_access_terrs_rec.program_id := p5_a10;
    ddp_tap_access_terrs_rec.program_update_date := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_tap_access_terrs_pvt.validate_tap_access_terrs_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tap_access_terrs_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_tap_access_terrs_pvt_w;

/
