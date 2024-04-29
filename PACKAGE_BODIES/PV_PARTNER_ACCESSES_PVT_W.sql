--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ACCESSES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ACCESSES_PVT_W" as
  /* $Header: pvxwprab.pls 120.1 2005/09/06 00:09 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_partner_accesses_pvt.partner_access_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_access_id := a0(indx);
          t(ddindx).partner_id := a1(indx);
          t(ddindx).resource_id := a2(indx);
          t(ddindx).keep_flag := a3(indx);
          t(ddindx).created_by_tap_flag := a4(indx);
          t(ddindx).access_type := a5(indx);
          t(ddindx).vad_partner_id := a6(indx);
          t(ddindx).last_update_date := a7(indx);
          t(ddindx).last_updated_by := a8(indx);
          t(ddindx).creation_date := a9(indx);
          t(ddindx).created_by := a10(indx);
          t(ddindx).last_update_login := a11(indx);
          t(ddindx).object_version_number := a12(indx);
          t(ddindx).request_id := a13(indx);
          t(ddindx).program_application_id := a14(indx);
          t(ddindx).program_id := a15(indx);
          t(ddindx).program_update_date := a16(indx);
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_partner_accesses_pvt.partner_access_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).partner_access_id;
          a1(indx) := t(ddindx).partner_id;
          a2(indx) := t(ddindx).resource_id;
          a3(indx) := t(ddindx).keep_flag;
          a4(indx) := t(ddindx).created_by_tap_flag;
          a5(indx) := t(ddindx).access_type;
          a6(indx) := t(ddindx).vad_partner_id;
          a7(indx) := t(ddindx).last_update_date;
          a8(indx) := t(ddindx).last_updated_by;
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := t(ddindx).created_by;
          a11(indx) := t(ddindx).last_update_login;
          a12(indx) := t(ddindx).object_version_number;
          a13(indx) := t(ddindx).request_id;
          a14(indx) := t(ddindx).program_application_id;
          a15(indx) := t(ddindx).program_id;
          a16(indx) := t(ddindx).program_update_date;
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
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_partner_accesses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , x_partner_access_id out nocopy  NUMBER
  )

  as
    ddp_partner_access_rec pv_partner_accesses_pvt.partner_access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_partner_access_rec.partner_access_id := p7_a0;
    ddp_partner_access_rec.partner_id := p7_a1;
    ddp_partner_access_rec.resource_id := p7_a2;
    ddp_partner_access_rec.keep_flag := p7_a3;
    ddp_partner_access_rec.created_by_tap_flag := p7_a4;
    ddp_partner_access_rec.access_type := p7_a5;
    ddp_partner_access_rec.vad_partner_id := p7_a6;
    ddp_partner_access_rec.last_update_date := p7_a7;
    ddp_partner_access_rec.last_updated_by := p7_a8;
    ddp_partner_access_rec.creation_date := p7_a9;
    ddp_partner_access_rec.created_by := p7_a10;
    ddp_partner_access_rec.last_update_login := p7_a11;
    ddp_partner_access_rec.object_version_number := p7_a12;
    ddp_partner_access_rec.request_id := p7_a13;
    ddp_partner_access_rec.program_application_id := p7_a14;
    ddp_partner_access_rec.program_id := p7_a15;
    ddp_partner_access_rec.program_update_date := p7_a16;
    ddp_partner_access_rec.attribute_category := p7_a17;
    ddp_partner_access_rec.attribute1 := p7_a18;
    ddp_partner_access_rec.attribute2 := p7_a19;
    ddp_partner_access_rec.attribute3 := p7_a20;
    ddp_partner_access_rec.attribute4 := p7_a21;
    ddp_partner_access_rec.attribute5 := p7_a22;
    ddp_partner_access_rec.attribute6 := p7_a23;
    ddp_partner_access_rec.attribute7 := p7_a24;
    ddp_partner_access_rec.attribute8 := p7_a25;
    ddp_partner_access_rec.attribute9 := p7_a26;
    ddp_partner_access_rec.attribute10 := p7_a27;
    ddp_partner_access_rec.attribute11 := p7_a28;
    ddp_partner_access_rec.attribute12 := p7_a29;
    ddp_partner_access_rec.attribute13 := p7_a30;
    ddp_partner_access_rec.attribute14 := p7_a31;
    ddp_partner_access_rec.attribute15 := p7_a32;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accesses_pvt.create_partner_accesses(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_partner_access_rec,
      x_partner_access_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_partner_accesses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
  )

  as
    ddp_partner_access_rec pv_partner_accesses_pvt.partner_access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_partner_access_rec.partner_access_id := p7_a0;
    ddp_partner_access_rec.partner_id := p7_a1;
    ddp_partner_access_rec.resource_id := p7_a2;
    ddp_partner_access_rec.keep_flag := p7_a3;
    ddp_partner_access_rec.created_by_tap_flag := p7_a4;
    ddp_partner_access_rec.access_type := p7_a5;
    ddp_partner_access_rec.vad_partner_id := p7_a6;
    ddp_partner_access_rec.last_update_date := p7_a7;
    ddp_partner_access_rec.last_updated_by := p7_a8;
    ddp_partner_access_rec.creation_date := p7_a9;
    ddp_partner_access_rec.created_by := p7_a10;
    ddp_partner_access_rec.last_update_login := p7_a11;
    ddp_partner_access_rec.object_version_number := p7_a12;
    ddp_partner_access_rec.request_id := p7_a13;
    ddp_partner_access_rec.program_application_id := p7_a14;
    ddp_partner_access_rec.program_id := p7_a15;
    ddp_partner_access_rec.program_update_date := p7_a16;
    ddp_partner_access_rec.attribute_category := p7_a17;
    ddp_partner_access_rec.attribute1 := p7_a18;
    ddp_partner_access_rec.attribute2 := p7_a19;
    ddp_partner_access_rec.attribute3 := p7_a20;
    ddp_partner_access_rec.attribute4 := p7_a21;
    ddp_partner_access_rec.attribute5 := p7_a22;
    ddp_partner_access_rec.attribute6 := p7_a23;
    ddp_partner_access_rec.attribute7 := p7_a24;
    ddp_partner_access_rec.attribute8 := p7_a25;
    ddp_partner_access_rec.attribute9 := p7_a26;
    ddp_partner_access_rec.attribute10 := p7_a27;
    ddp_partner_access_rec.attribute11 := p7_a28;
    ddp_partner_access_rec.attribute12 := p7_a29;
    ddp_partner_access_rec.attribute13 := p7_a30;
    ddp_partner_access_rec.attribute14 := p7_a31;
    ddp_partner_access_rec.attribute15 := p7_a32;

    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accesses_pvt.update_partner_accesses(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_partner_access_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_partner_accesses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  NUMBER
    , p3_a15  NUMBER
    , p3_a16  DATE
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_partner_access_rec pv_partner_accesses_pvt.partner_access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_partner_access_rec.partner_access_id := p3_a0;
    ddp_partner_access_rec.partner_id := p3_a1;
    ddp_partner_access_rec.resource_id := p3_a2;
    ddp_partner_access_rec.keep_flag := p3_a3;
    ddp_partner_access_rec.created_by_tap_flag := p3_a4;
    ddp_partner_access_rec.access_type := p3_a5;
    ddp_partner_access_rec.vad_partner_id := p3_a6;
    ddp_partner_access_rec.last_update_date := p3_a7;
    ddp_partner_access_rec.last_updated_by := p3_a8;
    ddp_partner_access_rec.creation_date := p3_a9;
    ddp_partner_access_rec.created_by := p3_a10;
    ddp_partner_access_rec.last_update_login := p3_a11;
    ddp_partner_access_rec.object_version_number := p3_a12;
    ddp_partner_access_rec.request_id := p3_a13;
    ddp_partner_access_rec.program_application_id := p3_a14;
    ddp_partner_access_rec.program_id := p3_a15;
    ddp_partner_access_rec.program_update_date := p3_a16;
    ddp_partner_access_rec.attribute_category := p3_a17;
    ddp_partner_access_rec.attribute1 := p3_a18;
    ddp_partner_access_rec.attribute2 := p3_a19;
    ddp_partner_access_rec.attribute3 := p3_a20;
    ddp_partner_access_rec.attribute4 := p3_a21;
    ddp_partner_access_rec.attribute5 := p3_a22;
    ddp_partner_access_rec.attribute6 := p3_a23;
    ddp_partner_access_rec.attribute7 := p3_a24;
    ddp_partner_access_rec.attribute8 := p3_a25;
    ddp_partner_access_rec.attribute9 := p3_a26;
    ddp_partner_access_rec.attribute10 := p3_a27;
    ddp_partner_access_rec.attribute11 := p3_a28;
    ddp_partner_access_rec.attribute12 := p3_a29;
    ddp_partner_access_rec.attribute13 := p3_a30;
    ddp_partner_access_rec.attribute14 := p3_a31;
    ddp_partner_access_rec.attribute15 := p3_a32;





    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accesses_pvt.validate_partner_accesses(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_partner_access_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure chk_partner_access_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  DATE
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
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_partner_access_rec pv_partner_accesses_pvt.partner_access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_partner_access_rec.partner_access_id := p0_a0;
    ddp_partner_access_rec.partner_id := p0_a1;
    ddp_partner_access_rec.resource_id := p0_a2;
    ddp_partner_access_rec.keep_flag := p0_a3;
    ddp_partner_access_rec.created_by_tap_flag := p0_a4;
    ddp_partner_access_rec.access_type := p0_a5;
    ddp_partner_access_rec.vad_partner_id := p0_a6;
    ddp_partner_access_rec.last_update_date := p0_a7;
    ddp_partner_access_rec.last_updated_by := p0_a8;
    ddp_partner_access_rec.creation_date := p0_a9;
    ddp_partner_access_rec.created_by := p0_a10;
    ddp_partner_access_rec.last_update_login := p0_a11;
    ddp_partner_access_rec.object_version_number := p0_a12;
    ddp_partner_access_rec.request_id := p0_a13;
    ddp_partner_access_rec.program_application_id := p0_a14;
    ddp_partner_access_rec.program_id := p0_a15;
    ddp_partner_access_rec.program_update_date := p0_a16;
    ddp_partner_access_rec.attribute_category := p0_a17;
    ddp_partner_access_rec.attribute1 := p0_a18;
    ddp_partner_access_rec.attribute2 := p0_a19;
    ddp_partner_access_rec.attribute3 := p0_a20;
    ddp_partner_access_rec.attribute4 := p0_a21;
    ddp_partner_access_rec.attribute5 := p0_a22;
    ddp_partner_access_rec.attribute6 := p0_a23;
    ddp_partner_access_rec.attribute7 := p0_a24;
    ddp_partner_access_rec.attribute8 := p0_a25;
    ddp_partner_access_rec.attribute9 := p0_a26;
    ddp_partner_access_rec.attribute10 := p0_a27;
    ddp_partner_access_rec.attribute11 := p0_a28;
    ddp_partner_access_rec.attribute12 := p0_a29;
    ddp_partner_access_rec.attribute13 := p0_a30;
    ddp_partner_access_rec.attribute14 := p0_a31;
    ddp_partner_access_rec.attribute15 := p0_a32;



    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accesses_pvt.chk_partner_access_items(ddp_partner_access_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_partner_access_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
  )

  as
    ddp_partner_access_rec pv_partner_accesses_pvt.partner_access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_partner_access_rec.partner_access_id := p5_a0;
    ddp_partner_access_rec.partner_id := p5_a1;
    ddp_partner_access_rec.resource_id := p5_a2;
    ddp_partner_access_rec.keep_flag := p5_a3;
    ddp_partner_access_rec.created_by_tap_flag := p5_a4;
    ddp_partner_access_rec.access_type := p5_a5;
    ddp_partner_access_rec.vad_partner_id := p5_a6;
    ddp_partner_access_rec.last_update_date := p5_a7;
    ddp_partner_access_rec.last_updated_by := p5_a8;
    ddp_partner_access_rec.creation_date := p5_a9;
    ddp_partner_access_rec.created_by := p5_a10;
    ddp_partner_access_rec.last_update_login := p5_a11;
    ddp_partner_access_rec.object_version_number := p5_a12;
    ddp_partner_access_rec.request_id := p5_a13;
    ddp_partner_access_rec.program_application_id := p5_a14;
    ddp_partner_access_rec.program_id := p5_a15;
    ddp_partner_access_rec.program_update_date := p5_a16;
    ddp_partner_access_rec.attribute_category := p5_a17;
    ddp_partner_access_rec.attribute1 := p5_a18;
    ddp_partner_access_rec.attribute2 := p5_a19;
    ddp_partner_access_rec.attribute3 := p5_a20;
    ddp_partner_access_rec.attribute4 := p5_a21;
    ddp_partner_access_rec.attribute5 := p5_a22;
    ddp_partner_access_rec.attribute6 := p5_a23;
    ddp_partner_access_rec.attribute7 := p5_a24;
    ddp_partner_access_rec.attribute8 := p5_a25;
    ddp_partner_access_rec.attribute9 := p5_a26;
    ddp_partner_access_rec.attribute10 := p5_a27;
    ddp_partner_access_rec.attribute11 := p5_a28;
    ddp_partner_access_rec.attribute12 := p5_a29;
    ddp_partner_access_rec.attribute13 := p5_a30;
    ddp_partner_access_rec.attribute14 := p5_a31;
    ddp_partner_access_rec.attribute15 := p5_a32;

    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accesses_pvt.validate_partner_access_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_partner_access_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_partner_accesses_pvt_w;

/
