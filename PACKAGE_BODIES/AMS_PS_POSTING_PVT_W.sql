--------------------------------------------------------
--  DDL for Package Body AMS_PS_POSTING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_POSTING_PVT_W" as
  /* $Header: amswpstb.pls 115.5 2002/12/19 04:17:09 ryedator ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_ps_posting_pvt.ps_posting_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
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
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).created_by := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).posting_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).max_no_contents := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).posting_type := a8(indx);
          t(ddindx).content_type := a9(indx);
          t(ddindx).default_content_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).status_code := a11(indx);
          t(ddindx).posting_name := a12(indx);
          t(ddindx).display_name := a13(indx);
          t(ddindx).posting_description := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).attribute1 := a16(indx);
          t(ddindx).attribute2 := a17(indx);
          t(ddindx).attribute3 := a18(indx);
          t(ddindx).attribute4 := a19(indx);
          t(ddindx).attribute5 := a20(indx);
          t(ddindx).attribute6 := a21(indx);
          t(ddindx).attribute7 := a22(indx);
          t(ddindx).attribute8 := a23(indx);
          t(ddindx).attribute9 := a24(indx);
          t(ddindx).attribute10 := a25(indx);
          t(ddindx).attribute11 := a26(indx);
          t(ddindx).attribute12 := a27(indx);
          t(ddindx).attribute13 := a28(indx);
          t(ddindx).attribute14 := a29(indx);
          t(ddindx).attribute15 := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_ps_posting_pvt.ps_posting_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_4000();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
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
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_4000();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
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
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_1000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a1(indx) := t(ddindx).creation_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).posting_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).max_no_contents);
          a8(indx) := t(ddindx).posting_type;
          a9(indx) := t(ddindx).content_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).default_content_id);
          a11(indx) := t(ddindx).status_code;
          a12(indx) := t(ddindx).posting_name;
          a13(indx) := t(ddindx).display_name;
          a14(indx) := t(ddindx).posting_description;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := t(ddindx).attribute1;
          a17(indx) := t(ddindx).attribute2;
          a18(indx) := t(ddindx).attribute3;
          a19(indx) := t(ddindx).attribute4;
          a20(indx) := t(ddindx).attribute5;
          a21(indx) := t(ddindx).attribute6;
          a22(indx) := t(ddindx).attribute7;
          a23(indx) := t(ddindx).attribute8;
          a24(indx) := t(ddindx).attribute9;
          a25(indx) := t(ddindx).attribute10;
          a26(indx) := t(ddindx).attribute11;
          a27(indx) := t(ddindx).attribute12;
          a28(indx) := t(ddindx).attribute13;
          a29(indx) := t(ddindx).attribute14;
          a30(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_ps_posting(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_posting_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_posting_rec.posting_type := p7_a8;
    ddp_ps_posting_rec.content_type := p7_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_posting_rec.status_code := p7_a11;
    ddp_ps_posting_rec.posting_name := p7_a12;
    ddp_ps_posting_rec.display_name := p7_a13;
    ddp_ps_posting_rec.posting_description := p7_a14;
    ddp_ps_posting_rec.attribute_category := p7_a15;
    ddp_ps_posting_rec.attribute1 := p7_a16;
    ddp_ps_posting_rec.attribute2 := p7_a17;
    ddp_ps_posting_rec.attribute3 := p7_a18;
    ddp_ps_posting_rec.attribute4 := p7_a19;
    ddp_ps_posting_rec.attribute5 := p7_a20;
    ddp_ps_posting_rec.attribute6 := p7_a21;
    ddp_ps_posting_rec.attribute7 := p7_a22;
    ddp_ps_posting_rec.attribute8 := p7_a23;
    ddp_ps_posting_rec.attribute9 := p7_a24;
    ddp_ps_posting_rec.attribute10 := p7_a25;
    ddp_ps_posting_rec.attribute11 := p7_a26;
    ddp_ps_posting_rec.attribute12 := p7_a27;
    ddp_ps_posting_rec.attribute13 := p7_a28;
    ddp_ps_posting_rec.attribute14 := p7_a29;
    ddp_ps_posting_rec.attribute15 := p7_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.create_ps_posting(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_posting_rec,
      x_posting_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ps_posting(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_posting_rec.posting_type := p7_a8;
    ddp_ps_posting_rec.content_type := p7_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_posting_rec.status_code := p7_a11;
    ddp_ps_posting_rec.posting_name := p7_a12;
    ddp_ps_posting_rec.display_name := p7_a13;
    ddp_ps_posting_rec.posting_description := p7_a14;
    ddp_ps_posting_rec.attribute_category := p7_a15;
    ddp_ps_posting_rec.attribute1 := p7_a16;
    ddp_ps_posting_rec.attribute2 := p7_a17;
    ddp_ps_posting_rec.attribute3 := p7_a18;
    ddp_ps_posting_rec.attribute4 := p7_a19;
    ddp_ps_posting_rec.attribute5 := p7_a20;
    ddp_ps_posting_rec.attribute6 := p7_a21;
    ddp_ps_posting_rec.attribute7 := p7_a22;
    ddp_ps_posting_rec.attribute8 := p7_a23;
    ddp_ps_posting_rec.attribute9 := p7_a24;
    ddp_ps_posting_rec.attribute10 := p7_a25;
    ddp_ps_posting_rec.attribute11 := p7_a26;
    ddp_ps_posting_rec.attribute12 := p7_a27;
    ddp_ps_posting_rec.attribute13 := p7_a28;
    ddp_ps_posting_rec.attribute14 := p7_a29;
    ddp_ps_posting_rec.attribute15 := p7_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.update_ps_posting(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_posting_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_ps_posting(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p3_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p3_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p3_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p3_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p3_a7);
    ddp_ps_posting_rec.posting_type := p3_a8;
    ddp_ps_posting_rec.content_type := p3_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p3_a10);
    ddp_ps_posting_rec.status_code := p3_a11;
    ddp_ps_posting_rec.posting_name := p3_a12;
    ddp_ps_posting_rec.display_name := p3_a13;
    ddp_ps_posting_rec.posting_description := p3_a14;
    ddp_ps_posting_rec.attribute_category := p3_a15;
    ddp_ps_posting_rec.attribute1 := p3_a16;
    ddp_ps_posting_rec.attribute2 := p3_a17;
    ddp_ps_posting_rec.attribute3 := p3_a18;
    ddp_ps_posting_rec.attribute4 := p3_a19;
    ddp_ps_posting_rec.attribute5 := p3_a20;
    ddp_ps_posting_rec.attribute6 := p3_a21;
    ddp_ps_posting_rec.attribute7 := p3_a22;
    ddp_ps_posting_rec.attribute8 := p3_a23;
    ddp_ps_posting_rec.attribute9 := p3_a24;
    ddp_ps_posting_rec.attribute10 := p3_a25;
    ddp_ps_posting_rec.attribute11 := p3_a26;
    ddp_ps_posting_rec.attribute12 := p3_a27;
    ddp_ps_posting_rec.attribute13 := p3_a28;
    ddp_ps_posting_rec.attribute14 := p3_a29;
    ddp_ps_posting_rec.attribute15 := p3_a30;




    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.validate_ps_posting(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ps_posting_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_ps_posting_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p0_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p0_a7);
    ddp_ps_posting_rec.posting_type := p0_a8;
    ddp_ps_posting_rec.content_type := p0_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p0_a10);
    ddp_ps_posting_rec.status_code := p0_a11;
    ddp_ps_posting_rec.posting_name := p0_a12;
    ddp_ps_posting_rec.display_name := p0_a13;
    ddp_ps_posting_rec.posting_description := p0_a14;
    ddp_ps_posting_rec.attribute_category := p0_a15;
    ddp_ps_posting_rec.attribute1 := p0_a16;
    ddp_ps_posting_rec.attribute2 := p0_a17;
    ddp_ps_posting_rec.attribute3 := p0_a18;
    ddp_ps_posting_rec.attribute4 := p0_a19;
    ddp_ps_posting_rec.attribute5 := p0_a20;
    ddp_ps_posting_rec.attribute6 := p0_a21;
    ddp_ps_posting_rec.attribute7 := p0_a22;
    ddp_ps_posting_rec.attribute8 := p0_a23;
    ddp_ps_posting_rec.attribute9 := p0_a24;
    ddp_ps_posting_rec.attribute10 := p0_a25;
    ddp_ps_posting_rec.attribute11 := p0_a26;
    ddp_ps_posting_rec.attribute12 := p0_a27;
    ddp_ps_posting_rec.attribute13 := p0_a28;
    ddp_ps_posting_rec.attribute14 := p0_a29;
    ddp_ps_posting_rec.attribute15 := p0_a30;



    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.check_ps_posting_items(ddp_ps_posting_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_ps_posting_req_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p1_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p1_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p1_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p1_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p1_a7);
    ddp_ps_posting_rec.posting_type := p1_a8;
    ddp_ps_posting_rec.content_type := p1_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p1_a10);
    ddp_ps_posting_rec.status_code := p1_a11;
    ddp_ps_posting_rec.posting_name := p1_a12;
    ddp_ps_posting_rec.display_name := p1_a13;
    ddp_ps_posting_rec.posting_description := p1_a14;
    ddp_ps_posting_rec.attribute_category := p1_a15;
    ddp_ps_posting_rec.attribute1 := p1_a16;
    ddp_ps_posting_rec.attribute2 := p1_a17;
    ddp_ps_posting_rec.attribute3 := p1_a18;
    ddp_ps_posting_rec.attribute4 := p1_a19;
    ddp_ps_posting_rec.attribute5 := p1_a20;
    ddp_ps_posting_rec.attribute6 := p1_a21;
    ddp_ps_posting_rec.attribute7 := p1_a22;
    ddp_ps_posting_rec.attribute8 := p1_a23;
    ddp_ps_posting_rec.attribute9 := p1_a24;
    ddp_ps_posting_rec.attribute10 := p1_a25;
    ddp_ps_posting_rec.attribute11 := p1_a26;
    ddp_ps_posting_rec.attribute12 := p1_a27;
    ddp_ps_posting_rec.attribute13 := p1_a28;
    ddp_ps_posting_rec.attribute14 := p1_a29;
    ddp_ps_posting_rec.attribute15 := p1_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.check_ps_posting_req_items(p_validation_mode,
      ddp_ps_posting_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_ps_posting_fk_items(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p0_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p0_a7);
    ddp_ps_posting_rec.posting_type := p0_a8;
    ddp_ps_posting_rec.content_type := p0_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p0_a10);
    ddp_ps_posting_rec.status_code := p0_a11;
    ddp_ps_posting_rec.posting_name := p0_a12;
    ddp_ps_posting_rec.display_name := p0_a13;
    ddp_ps_posting_rec.posting_description := p0_a14;
    ddp_ps_posting_rec.attribute_category := p0_a15;
    ddp_ps_posting_rec.attribute1 := p0_a16;
    ddp_ps_posting_rec.attribute2 := p0_a17;
    ddp_ps_posting_rec.attribute3 := p0_a18;
    ddp_ps_posting_rec.attribute4 := p0_a19;
    ddp_ps_posting_rec.attribute5 := p0_a20;
    ddp_ps_posting_rec.attribute6 := p0_a21;
    ddp_ps_posting_rec.attribute7 := p0_a22;
    ddp_ps_posting_rec.attribute8 := p0_a23;
    ddp_ps_posting_rec.attribute9 := p0_a24;
    ddp_ps_posting_rec.attribute10 := p0_a25;
    ddp_ps_posting_rec.attribute11 := p0_a26;
    ddp_ps_posting_rec.attribute12 := p0_a27;
    ddp_ps_posting_rec.attribute13 := p0_a28;
    ddp_ps_posting_rec.attribute14 := p0_a29;
    ddp_ps_posting_rec.attribute15 := p0_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.check_ps_posting_fk_items(ddp_ps_posting_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure validate_ps_posting_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ps_posting_rec ams_ps_posting_pvt.ps_posting_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ps_posting_rec.created_by := rosetta_g_miss_num_map(p5_a0);
    ddp_ps_posting_rec.creation_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_ps_posting_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_ps_posting_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_ps_posting_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_ps_posting_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_ps_posting_rec.posting_id := rosetta_g_miss_num_map(p5_a6);
    ddp_ps_posting_rec.max_no_contents := rosetta_g_miss_num_map(p5_a7);
    ddp_ps_posting_rec.posting_type := p5_a8;
    ddp_ps_posting_rec.content_type := p5_a9;
    ddp_ps_posting_rec.default_content_id := rosetta_g_miss_num_map(p5_a10);
    ddp_ps_posting_rec.status_code := p5_a11;
    ddp_ps_posting_rec.posting_name := p5_a12;
    ddp_ps_posting_rec.display_name := p5_a13;
    ddp_ps_posting_rec.posting_description := p5_a14;
    ddp_ps_posting_rec.attribute_category := p5_a15;
    ddp_ps_posting_rec.attribute1 := p5_a16;
    ddp_ps_posting_rec.attribute2 := p5_a17;
    ddp_ps_posting_rec.attribute3 := p5_a18;
    ddp_ps_posting_rec.attribute4 := p5_a19;
    ddp_ps_posting_rec.attribute5 := p5_a20;
    ddp_ps_posting_rec.attribute6 := p5_a21;
    ddp_ps_posting_rec.attribute7 := p5_a22;
    ddp_ps_posting_rec.attribute8 := p5_a23;
    ddp_ps_posting_rec.attribute9 := p5_a24;
    ddp_ps_posting_rec.attribute10 := p5_a25;
    ddp_ps_posting_rec.attribute11 := p5_a26;
    ddp_ps_posting_rec.attribute12 := p5_a27;
    ddp_ps_posting_rec.attribute13 := p5_a28;
    ddp_ps_posting_rec.attribute14 := p5_a29;
    ddp_ps_posting_rec.attribute15 := p5_a30;

    -- here's the delegated call to the old PL/SQL routine
    ams_ps_posting_pvt.validate_ps_posting_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_posting_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_ps_posting_pvt_w;

/
