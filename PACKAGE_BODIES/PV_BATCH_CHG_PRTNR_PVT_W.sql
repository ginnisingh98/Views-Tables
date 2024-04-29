--------------------------------------------------------
--  DDL for Package Body PV_BATCH_CHG_PRTNR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BATCH_CHG_PRTNR_PVT_W" as
  /* $Header: pvxwchpb.pls 120.1 2005/09/05 23:06 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_id := a0(indx);
          t(ddindx).vad_partner_id := a1(indx);
          t(ddindx).last_update_date := a2(indx);
          t(ddindx).last_update_by := a3(indx);
          t(ddindx).creation_date := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).request_id := a8(indx);
          t(ddindx).program_application_id := a9(indx);
          t(ddindx).program_id := a10(indx);
          t(ddindx).program_update_date := a11(indx);
          t(ddindx).processed_flag := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    a12 := JTF_VARCHAR2_TABLE_100();
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
      a12 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).partner_id;
          a1(indx) := t(ddindx).vad_partner_id;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_update_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).request_id;
          a9(indx) := t(ddindx).program_application_id;
          a10(indx) := t(ddindx).program_id;
          a11(indx) := t(ddindx).program_update_date;
          a12(indx) := t(ddindx).processed_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_batch_chg_partners(p_api_version_number  NUMBER
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
    , p7_a12  VARCHAR2
    , x_partner_id out nocopy  NUMBER
  )

  as
    ddp_batch_chg_prtnrs_rec pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_batch_chg_prtnrs_rec.partner_id := p7_a0;
    ddp_batch_chg_prtnrs_rec.vad_partner_id := p7_a1;
    ddp_batch_chg_prtnrs_rec.last_update_date := p7_a2;
    ddp_batch_chg_prtnrs_rec.last_update_by := p7_a3;
    ddp_batch_chg_prtnrs_rec.creation_date := p7_a4;
    ddp_batch_chg_prtnrs_rec.created_by := p7_a5;
    ddp_batch_chg_prtnrs_rec.last_update_login := p7_a6;
    ddp_batch_chg_prtnrs_rec.object_version_number := p7_a7;
    ddp_batch_chg_prtnrs_rec.request_id := p7_a8;
    ddp_batch_chg_prtnrs_rec.program_application_id := p7_a9;
    ddp_batch_chg_prtnrs_rec.program_id := p7_a10;
    ddp_batch_chg_prtnrs_rec.program_update_date := p7_a11;
    ddp_batch_chg_prtnrs_rec.processed_flag := p7_a12;


    -- here's the delegated call to the old PL/SQL routine
    pv_batch_chg_prtnr_pvt.create_batch_chg_partners(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_chg_prtnrs_rec,
      x_partner_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_batch_chg_partners(p_api_version_number  NUMBER
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
    , p7_a12  VARCHAR2
  )

  as
    ddp_batch_chg_prtnrs_rec pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_batch_chg_prtnrs_rec.partner_id := p7_a0;
    ddp_batch_chg_prtnrs_rec.vad_partner_id := p7_a1;
    ddp_batch_chg_prtnrs_rec.last_update_date := p7_a2;
    ddp_batch_chg_prtnrs_rec.last_update_by := p7_a3;
    ddp_batch_chg_prtnrs_rec.creation_date := p7_a4;
    ddp_batch_chg_prtnrs_rec.created_by := p7_a5;
    ddp_batch_chg_prtnrs_rec.last_update_login := p7_a6;
    ddp_batch_chg_prtnrs_rec.object_version_number := p7_a7;
    ddp_batch_chg_prtnrs_rec.request_id := p7_a8;
    ddp_batch_chg_prtnrs_rec.program_application_id := p7_a9;
    ddp_batch_chg_prtnrs_rec.program_id := p7_a10;
    ddp_batch_chg_prtnrs_rec.program_update_date := p7_a11;
    ddp_batch_chg_prtnrs_rec.processed_flag := p7_a12;

    -- here's the delegated call to the old PL/SQL routine
    pv_batch_chg_prtnr_pvt.update_batch_chg_partners(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_chg_prtnrs_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_batch_chg_partners(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  DATE
    , p3_a12  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_batch_chg_prtnrs_rec pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_batch_chg_prtnrs_rec.partner_id := p3_a0;
    ddp_batch_chg_prtnrs_rec.vad_partner_id := p3_a1;
    ddp_batch_chg_prtnrs_rec.last_update_date := p3_a2;
    ddp_batch_chg_prtnrs_rec.last_update_by := p3_a3;
    ddp_batch_chg_prtnrs_rec.creation_date := p3_a4;
    ddp_batch_chg_prtnrs_rec.created_by := p3_a5;
    ddp_batch_chg_prtnrs_rec.last_update_login := p3_a6;
    ddp_batch_chg_prtnrs_rec.object_version_number := p3_a7;
    ddp_batch_chg_prtnrs_rec.request_id := p3_a8;
    ddp_batch_chg_prtnrs_rec.program_application_id := p3_a9;
    ddp_batch_chg_prtnrs_rec.program_id := p3_a10;
    ddp_batch_chg_prtnrs_rec.program_update_date := p3_a11;
    ddp_batch_chg_prtnrs_rec.processed_flag := p3_a12;





    -- here's the delegated call to the old PL/SQL routine
    pv_batch_chg_prtnr_pvt.validate_batch_chg_partners(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_batch_chg_prtnrs_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_batch_chg_prtnrs_items(p0_a0  NUMBER
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
    , p0_a12  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_batch_chg_prtnrs_rec pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_batch_chg_prtnrs_rec.partner_id := p0_a0;
    ddp_batch_chg_prtnrs_rec.vad_partner_id := p0_a1;
    ddp_batch_chg_prtnrs_rec.last_update_date := p0_a2;
    ddp_batch_chg_prtnrs_rec.last_update_by := p0_a3;
    ddp_batch_chg_prtnrs_rec.creation_date := p0_a4;
    ddp_batch_chg_prtnrs_rec.created_by := p0_a5;
    ddp_batch_chg_prtnrs_rec.last_update_login := p0_a6;
    ddp_batch_chg_prtnrs_rec.object_version_number := p0_a7;
    ddp_batch_chg_prtnrs_rec.request_id := p0_a8;
    ddp_batch_chg_prtnrs_rec.program_application_id := p0_a9;
    ddp_batch_chg_prtnrs_rec.program_id := p0_a10;
    ddp_batch_chg_prtnrs_rec.program_update_date := p0_a11;
    ddp_batch_chg_prtnrs_rec.processed_flag := p0_a12;



    -- here's the delegated call to the old PL/SQL routine
    pv_batch_chg_prtnr_pvt.check_batch_chg_prtnrs_items(ddp_batch_chg_prtnrs_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_batch_chg_prtnrs_rec(p_api_version_number  NUMBER
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
    , p5_a12  VARCHAR2
  )

  as
    ddp_batch_chg_prtnrs_rec pv_batch_chg_prtnr_pvt.batch_chg_prtnrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_batch_chg_prtnrs_rec.partner_id := p5_a0;
    ddp_batch_chg_prtnrs_rec.vad_partner_id := p5_a1;
    ddp_batch_chg_prtnrs_rec.last_update_date := p5_a2;
    ddp_batch_chg_prtnrs_rec.last_update_by := p5_a3;
    ddp_batch_chg_prtnrs_rec.creation_date := p5_a4;
    ddp_batch_chg_prtnrs_rec.created_by := p5_a5;
    ddp_batch_chg_prtnrs_rec.last_update_login := p5_a6;
    ddp_batch_chg_prtnrs_rec.object_version_number := p5_a7;
    ddp_batch_chg_prtnrs_rec.request_id := p5_a8;
    ddp_batch_chg_prtnrs_rec.program_application_id := p5_a9;
    ddp_batch_chg_prtnrs_rec.program_id := p5_a10;
    ddp_batch_chg_prtnrs_rec.program_update_date := p5_a11;
    ddp_batch_chg_prtnrs_rec.processed_flag := p5_a12;

    -- here's the delegated call to the old PL/SQL routine
    pv_batch_chg_prtnr_pvt.validate_batch_chg_prtnrs_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_chg_prtnrs_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_batch_chg_prtnr_pvt_w;

/
