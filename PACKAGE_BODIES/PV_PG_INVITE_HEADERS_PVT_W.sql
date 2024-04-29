--------------------------------------------------------
--  DDL for Package Body PV_PG_INVITE_HEADERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_INVITE_HEADERS_PVT_W" as
  /* $Header: pvxwpihb.pls 120.1 2005/08/29 14:19 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_pg_invite_headers_pvt.invite_headers_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).invite_header_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).qp_list_header_id := a2(indx);
          t(ddindx).invite_type_code := a3(indx);
          t(ddindx).invite_for_program_id := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := a9(indx);
          t(ddindx).partner_id := a10(indx);
          t(ddindx).invite_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).order_header_id := a12(indx);
          t(ddindx).invited_by_partner_id := a13(indx);
          t(ddindx).trxn_extension_id := a14(indx);
          t(ddindx).email_content := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_pg_invite_headers_pvt.invite_headers_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_4000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).invite_header_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).qp_list_header_id;
          a3(indx) := t(ddindx).invite_type_code;
          a4(indx) := t(ddindx).invite_for_program_id;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
          a10(indx) := t(ddindx).partner_id;
          a11(indx) := t(ddindx).invite_end_date;
          a12(indx) := t(ddindx).order_header_id;
          a13(indx) := t(ddindx).invited_by_partner_id;
          a14(indx) := t(ddindx).trxn_extension_id;
          a15(indx) := t(ddindx).email_content;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , x_invite_header_id out nocopy  NUMBER
  )

  as
    ddp_invite_headers_rec pv_pg_invite_headers_pvt.invite_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_invite_headers_rec.invite_header_id := p7_a0;
    ddp_invite_headers_rec.object_version_number := p7_a1;
    ddp_invite_headers_rec.qp_list_header_id := p7_a2;
    ddp_invite_headers_rec.invite_type_code := p7_a3;
    ddp_invite_headers_rec.invite_for_program_id := p7_a4;
    ddp_invite_headers_rec.created_by := p7_a5;
    ddp_invite_headers_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_invite_headers_rec.last_updated_by := p7_a7;
    ddp_invite_headers_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_invite_headers_rec.last_update_login := p7_a9;
    ddp_invite_headers_rec.partner_id := p7_a10;
    ddp_invite_headers_rec.invite_end_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_invite_headers_rec.order_header_id := p7_a12;
    ddp_invite_headers_rec.invited_by_partner_id := p7_a13;
    ddp_invite_headers_rec.trxn_extension_id := p7_a14;
    ddp_invite_headers_rec.email_content := p7_a15;


    -- here's the delegated call to the old PL/SQL routine
    pv_pg_invite_headers_pvt.create_invite_headers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_invite_headers_rec,
      x_invite_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
  )

  as
    ddp_invite_headers_rec pv_pg_invite_headers_pvt.invite_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_invite_headers_rec.invite_header_id := p7_a0;
    ddp_invite_headers_rec.object_version_number := p7_a1;
    ddp_invite_headers_rec.qp_list_header_id := p7_a2;
    ddp_invite_headers_rec.invite_type_code := p7_a3;
    ddp_invite_headers_rec.invite_for_program_id := p7_a4;
    ddp_invite_headers_rec.created_by := p7_a5;
    ddp_invite_headers_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_invite_headers_rec.last_updated_by := p7_a7;
    ddp_invite_headers_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_invite_headers_rec.last_update_login := p7_a9;
    ddp_invite_headers_rec.partner_id := p7_a10;
    ddp_invite_headers_rec.invite_end_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_invite_headers_rec.order_header_id := p7_a12;
    ddp_invite_headers_rec.invited_by_partner_id := p7_a13;
    ddp_invite_headers_rec.trxn_extension_id := p7_a14;
    ddp_invite_headers_rec.email_content := p7_a15;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_invite_headers_pvt.update_invite_headers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_invite_headers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  DATE
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  NUMBER
    , p3_a15  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_invite_headers_rec pv_pg_invite_headers_pvt.invite_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_invite_headers_rec.invite_header_id := p3_a0;
    ddp_invite_headers_rec.object_version_number := p3_a1;
    ddp_invite_headers_rec.qp_list_header_id := p3_a2;
    ddp_invite_headers_rec.invite_type_code := p3_a3;
    ddp_invite_headers_rec.invite_for_program_id := p3_a4;
    ddp_invite_headers_rec.created_by := p3_a5;
    ddp_invite_headers_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_invite_headers_rec.last_updated_by := p3_a7;
    ddp_invite_headers_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_invite_headers_rec.last_update_login := p3_a9;
    ddp_invite_headers_rec.partner_id := p3_a10;
    ddp_invite_headers_rec.invite_end_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_invite_headers_rec.order_header_id := p3_a12;
    ddp_invite_headers_rec.invited_by_partner_id := p3_a13;
    ddp_invite_headers_rec.trxn_extension_id := p3_a14;
    ddp_invite_headers_rec.email_content := p3_a15;





    -- here's the delegated call to the old PL/SQL routine
    pv_pg_invite_headers_pvt.validate_invite_headers(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_invite_headers_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_invite_headers_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_invite_headers_rec pv_pg_invite_headers_pvt.invite_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_invite_headers_rec.invite_header_id := p0_a0;
    ddp_invite_headers_rec.object_version_number := p0_a1;
    ddp_invite_headers_rec.qp_list_header_id := p0_a2;
    ddp_invite_headers_rec.invite_type_code := p0_a3;
    ddp_invite_headers_rec.invite_for_program_id := p0_a4;
    ddp_invite_headers_rec.created_by := p0_a5;
    ddp_invite_headers_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_invite_headers_rec.last_updated_by := p0_a7;
    ddp_invite_headers_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_invite_headers_rec.last_update_login := p0_a9;
    ddp_invite_headers_rec.partner_id := p0_a10;
    ddp_invite_headers_rec.invite_end_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_invite_headers_rec.order_header_id := p0_a12;
    ddp_invite_headers_rec.invited_by_partner_id := p0_a13;
    ddp_invite_headers_rec.trxn_extension_id := p0_a14;
    ddp_invite_headers_rec.email_content := p0_a15;



    -- here's the delegated call to the old PL/SQL routine
    pv_pg_invite_headers_pvt.check_invite_headers_items(ddp_invite_headers_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_invite_headers_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
  )

  as
    ddp_invite_headers_rec pv_pg_invite_headers_pvt.invite_headers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_invite_headers_rec.invite_header_id := p5_a0;
    ddp_invite_headers_rec.object_version_number := p5_a1;
    ddp_invite_headers_rec.qp_list_header_id := p5_a2;
    ddp_invite_headers_rec.invite_type_code := p5_a3;
    ddp_invite_headers_rec.invite_for_program_id := p5_a4;
    ddp_invite_headers_rec.created_by := p5_a5;
    ddp_invite_headers_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_invite_headers_rec.last_updated_by := p5_a7;
    ddp_invite_headers_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_invite_headers_rec.last_update_login := p5_a9;
    ddp_invite_headers_rec.partner_id := p5_a10;
    ddp_invite_headers_rec.invite_end_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_invite_headers_rec.order_header_id := p5_a12;
    ddp_invite_headers_rec.invited_by_partner_id := p5_a13;
    ddp_invite_headers_rec.trxn_extension_id := p5_a14;
    ddp_invite_headers_rec.email_content := p5_a15;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_invite_headers_pvt.validate_invite_headers_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_invite_headers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_pg_invite_headers_pvt_w;

/
