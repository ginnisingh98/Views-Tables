--------------------------------------------------------
--  DDL for Package Body OZF_PROCESS_SETUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PROCESS_SETUP_PVT_W" as
  /* $Header: ozfwpseb.pls 120.0 2007/12/21 07:19:36 gdeepika noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_process_setup_pvt.process_setup_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_process_setup_pvt.process_setup_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_process_setup_pvt.process_setup_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).process_setup_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).request_id := a7(indx);
          t(ddindx).program_application_id := a8(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).program_id := a10(indx);
          t(ddindx).created_from := a11(indx);
          t(ddindx).org_id := a12(indx);
          t(ddindx).supp_trade_profile_id := a13(indx);
          t(ddindx).process_code := a14(indx);
          t(ddindx).enabled_flag := a15(indx);
          t(ddindx).automatic_flag := a16(indx);
          t(ddindx).attribute_category := a17(indx);
          t(ddindx).attribute1 := a18(indx);
          t(ddindx).attribute2 := a19(indx);
          t(ddindx).attribute3 := a20(indx);
          t(ddindx).attribute4 := a21(indx);
          t(ddindx).attribute5 := a22(indx);
          t(ddindx).attribute6 := a23(indx);
          t(ddindx).attribute7 := a24(indx);
          t(ddindx).attribute8 := a25(indx);
          t(ddindx).attribute9 := a26(indx);
          t(ddindx).attribute10 := a27(indx);
          t(ddindx).attribute11 := a28(indx);
          t(ddindx).attribute12 := a29(indx);
          t(ddindx).attribute13 := a30(indx);
          t(ddindx).attribute14 := a31(indx);
          t(ddindx).attribute15 := a32(indx);
          t(ddindx).security_group_id := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_process_setup_pvt.process_setup_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
    a16 := null;
    a17 := null;
    a18 := null;
    a19 := null;
    a20 := null;
    a21 := null;
    a22 := null;
    a23 := null;
    a24 := null;
    a25 := null;
    a26 := null;
    a27 := null;
    a28 := null;
    a29 := null;
    a30 := null;
    a31 := null;
    a32 := null;
    a33 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_NUMBER_TABLE();
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
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_NUMBER_TABLE();
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
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).process_setup_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).request_id;
          a8(indx) := t(ddindx).program_application_id;
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := t(ddindx).program_id;
          a11(indx) := t(ddindx).created_from;
          a12(indx) := t(ddindx).org_id;
          a13(indx) := t(ddindx).supp_trade_profile_id;
          a14(indx) := t(ddindx).process_code;
          a15(indx) := t(ddindx).enabled_flag;
          a16(indx) := t(ddindx).automatic_flag;
          a17(indx) := t(ddindx).attribute_category;
          a18(indx) := t(ddindx).attribute1;
          a19(indx) := t(ddindx).attribute2;
          a20(indx) := t(ddindx).attribute3;
          a21(indx) := t(ddindx).attribute4;
          a22(indx) := t(ddindx).attribute5;
          a23(indx) := t(ddindx).attribute6;
          a24(indx) := t(ddindx).attribute7;
          a25(indx) := t(ddindx).attribute8;
          a26(indx) := t(ddindx).attribute9;
          a27(indx) := t(ddindx).attribute10;
          a28(indx) := t(ddindx).attribute11;
          a29(indx) := t(ddindx).attribute12;
          a30(indx) := t(ddindx).attribute13;
          a31(indx) := t(ddindx).attribute14;
          a32(indx) := t(ddindx).attribute15;
          a33(indx) := t(ddindx).security_group_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure update_process_setup_tbl(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_NUMBER_TABLE
  )

  as
    ddp_process_setup_tbl ozf_process_setup_pvt.process_setup_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_process_setup_pvt_w.rosetta_table_copy_in_p3(ddp_process_setup_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      );

    -- here's the delegated call to the old PL/SQL routine
    ozf_process_setup_pvt.update_process_setup_tbl(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_setup_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_uniq_process_setup(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_process_setup_rec ozf_process_setup_pvt.process_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_process_setup_rec.process_setup_id := p0_a0;
    ddp_process_setup_rec.object_version_number := p0_a1;
    ddp_process_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_process_setup_rec.last_updated_by := p0_a3;
    ddp_process_setup_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_process_setup_rec.created_by := p0_a5;
    ddp_process_setup_rec.last_update_login := p0_a6;
    ddp_process_setup_rec.request_id := p0_a7;
    ddp_process_setup_rec.program_application_id := p0_a8;
    ddp_process_setup_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_process_setup_rec.program_id := p0_a10;
    ddp_process_setup_rec.created_from := p0_a11;
    ddp_process_setup_rec.org_id := p0_a12;
    ddp_process_setup_rec.supp_trade_profile_id := p0_a13;
    ddp_process_setup_rec.process_code := p0_a14;
    ddp_process_setup_rec.enabled_flag := p0_a15;
    ddp_process_setup_rec.automatic_flag := p0_a16;
    ddp_process_setup_rec.attribute_category := p0_a17;
    ddp_process_setup_rec.attribute1 := p0_a18;
    ddp_process_setup_rec.attribute2 := p0_a19;
    ddp_process_setup_rec.attribute3 := p0_a20;
    ddp_process_setup_rec.attribute4 := p0_a21;
    ddp_process_setup_rec.attribute5 := p0_a22;
    ddp_process_setup_rec.attribute6 := p0_a23;
    ddp_process_setup_rec.attribute7 := p0_a24;
    ddp_process_setup_rec.attribute8 := p0_a25;
    ddp_process_setup_rec.attribute9 := p0_a26;
    ddp_process_setup_rec.attribute10 := p0_a27;
    ddp_process_setup_rec.attribute11 := p0_a28;
    ddp_process_setup_rec.attribute12 := p0_a29;
    ddp_process_setup_rec.attribute13 := p0_a30;
    ddp_process_setup_rec.attribute14 := p0_a31;
    ddp_process_setup_rec.attribute15 := p0_a32;
    ddp_process_setup_rec.security_group_id := p0_a33;



    -- here's the delegated call to the old PL/SQL routine
    ozf_process_setup_pvt.check_uniq_process_setup(ddp_process_setup_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_process_setup(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_DATE_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_VARCHAR2_TABLE_100
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_process_setup_tbl ozf_process_setup_pvt.process_setup_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ozf_process_setup_pvt_w.rosetta_table_copy_in_p3(ddp_process_setup_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_process_setup_pvt.validate_process_setup(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_process_setup_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_process_setup_pvt_w;

/
