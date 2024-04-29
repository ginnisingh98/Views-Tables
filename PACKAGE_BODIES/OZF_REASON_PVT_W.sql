--------------------------------------------------------
--  DDL for Package Body OZF_REASON_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REASON_PVT_W" as
  /* $Header: ozfwreab.pls 120.3 2006/05/17 01:16:17 sshivali ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_reason_pvt.action_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_reason_pvt.action_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_reason_pvt.action_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).reason_type_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).reason_code_id := a2(indx);
          t(ddindx).task_template_group_id := a3(indx);
          t(ddindx).active_flag := a4(indx);
          t(ddindx).default_flag := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_reason_pvt.action_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
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
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).reason_type_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).reason_code_id;
          a3(indx) := t(ddindx).task_template_group_id;
          a4(indx) := t(ddindx).active_flag;
          a5(indx) := t(ddindx).default_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy ozf_reason_pvt.reason_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
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
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_reason_pvt.reason_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_reason_pvt.reason_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).reason_code_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).reason_code := a7(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).name := a26(indx);
          t(ddindx).description := a27(indx);
          t(ddindx).org_id := a28(indx);
          t(ddindx).reason_type := a29(indx);
          t(ddindx).adjustment_reason_code := a30(indx);
          t(ddindx).invoicing_reason_code := a31(indx);
          t(ddindx).order_type_id := a32(indx);
          t(ddindx).partner_access_flag := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ozf_reason_pvt.reason_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
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
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_2000();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
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
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_2000();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).reason_code_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).reason_code;
          a8(indx) := t(ddindx).start_date_active;
          a9(indx) := t(ddindx).end_date_active;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).name;
          a27(indx) := t(ddindx).description;
          a28(indx) := t(ddindx).org_id;
          a29(indx) := t(ddindx).reason_type;
          a30(indx) := t(ddindx).adjustment_reason_code;
          a31(indx) := t(ddindx).invoicing_reason_code;
          a32(indx) := t(ddindx).order_type_id;
          a33(indx) := t(ddindx).partner_access_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure create_reason(p_api_version_number  NUMBER
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
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
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
    , p7_a28  NUMBER
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , x_reason_code_id out nocopy  NUMBER
  )

  as
    ddp_reason_rec ozf_reason_pvt.reason_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_reason_rec.reason_code_id := p7_a0;
    ddp_reason_rec.object_version_number := p7_a1;
    ddp_reason_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_reason_rec.last_updated_by := p7_a3;
    ddp_reason_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_reason_rec.created_by := p7_a5;
    ddp_reason_rec.last_update_login := p7_a6;
    ddp_reason_rec.reason_code := p7_a7;
    ddp_reason_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a8);
    ddp_reason_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a9);
    ddp_reason_rec.attribute_category := p7_a10;
    ddp_reason_rec.attribute1 := p7_a11;
    ddp_reason_rec.attribute2 := p7_a12;
    ddp_reason_rec.attribute3 := p7_a13;
    ddp_reason_rec.attribute4 := p7_a14;
    ddp_reason_rec.attribute5 := p7_a15;
    ddp_reason_rec.attribute6 := p7_a16;
    ddp_reason_rec.attribute7 := p7_a17;
    ddp_reason_rec.attribute8 := p7_a18;
    ddp_reason_rec.attribute9 := p7_a19;
    ddp_reason_rec.attribute10 := p7_a20;
    ddp_reason_rec.attribute11 := p7_a21;
    ddp_reason_rec.attribute12 := p7_a22;
    ddp_reason_rec.attribute13 := p7_a23;
    ddp_reason_rec.attribute14 := p7_a24;
    ddp_reason_rec.attribute15 := p7_a25;
    ddp_reason_rec.name := p7_a26;
    ddp_reason_rec.description := p7_a27;
    ddp_reason_rec.org_id := p7_a28;
    ddp_reason_rec.reason_type := p7_a29;
    ddp_reason_rec.adjustment_reason_code := p7_a30;
    ddp_reason_rec.invoicing_reason_code := p7_a31;
    ddp_reason_rec.order_type_id := p7_a32;
    ddp_reason_rec.partner_access_flag := p7_a33;


    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.create_reason(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_reason_rec,
      x_reason_code_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_reason(p_api_version_number  NUMBER
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
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
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
    , p7_a28  NUMBER
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_reason_rec ozf_reason_pvt.reason_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_reason_rec.reason_code_id := p7_a0;
    ddp_reason_rec.object_version_number := p7_a1;
    ddp_reason_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_reason_rec.last_updated_by := p7_a3;
    ddp_reason_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_reason_rec.created_by := p7_a5;
    ddp_reason_rec.last_update_login := p7_a6;
    ddp_reason_rec.reason_code := p7_a7;
    ddp_reason_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a8);
    ddp_reason_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a9);
    ddp_reason_rec.attribute_category := p7_a10;
    ddp_reason_rec.attribute1 := p7_a11;
    ddp_reason_rec.attribute2 := p7_a12;
    ddp_reason_rec.attribute3 := p7_a13;
    ddp_reason_rec.attribute4 := p7_a14;
    ddp_reason_rec.attribute5 := p7_a15;
    ddp_reason_rec.attribute6 := p7_a16;
    ddp_reason_rec.attribute7 := p7_a17;
    ddp_reason_rec.attribute8 := p7_a18;
    ddp_reason_rec.attribute9 := p7_a19;
    ddp_reason_rec.attribute10 := p7_a20;
    ddp_reason_rec.attribute11 := p7_a21;
    ddp_reason_rec.attribute12 := p7_a22;
    ddp_reason_rec.attribute13 := p7_a23;
    ddp_reason_rec.attribute14 := p7_a24;
    ddp_reason_rec.attribute15 := p7_a25;
    ddp_reason_rec.name := p7_a26;
    ddp_reason_rec.description := p7_a27;
    ddp_reason_rec.org_id := p7_a28;
    ddp_reason_rec.reason_type := p7_a29;
    ddp_reason_rec.adjustment_reason_code := p7_a30;
    ddp_reason_rec.invoicing_reason_code := p7_a31;
    ddp_reason_rec.order_type_id := p7_a32;
    ddp_reason_rec.partner_access_flag := p7_a33;


    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.update_reason(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_reason_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_actions(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_action_tbl ozf_reason_pvt.action_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_reason_pvt_w.rosetta_table_copy_in_p3(ddp_action_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      );

    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.update_actions(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_action_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_unique_action(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_action_rec ozf_reason_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_action_rec.reason_type_id := p0_a0;
    ddp_action_rec.object_version_number := p0_a1;
    ddp_action_rec.reason_code_id := p0_a2;
    ddp_action_rec.task_template_group_id := p0_a3;
    ddp_action_rec.active_flag := p0_a4;
    ddp_action_rec.default_flag := p0_a5;



    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.check_unique_action(ddp_action_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_reason_rec(p_api_version_number  NUMBER
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
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
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
    , p5_a28  NUMBER
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
  )

  as
    ddp_reason_rec ozf_reason_pvt.reason_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_reason_rec.reason_code_id := p5_a0;
    ddp_reason_rec.object_version_number := p5_a1;
    ddp_reason_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_reason_rec.last_updated_by := p5_a3;
    ddp_reason_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_reason_rec.created_by := p5_a5;
    ddp_reason_rec.last_update_login := p5_a6;
    ddp_reason_rec.reason_code := p5_a7;
    ddp_reason_rec.start_date_active := rosetta_g_miss_date_in_map(p5_a8);
    ddp_reason_rec.end_date_active := rosetta_g_miss_date_in_map(p5_a9);
    ddp_reason_rec.attribute_category := p5_a10;
    ddp_reason_rec.attribute1 := p5_a11;
    ddp_reason_rec.attribute2 := p5_a12;
    ddp_reason_rec.attribute3 := p5_a13;
    ddp_reason_rec.attribute4 := p5_a14;
    ddp_reason_rec.attribute5 := p5_a15;
    ddp_reason_rec.attribute6 := p5_a16;
    ddp_reason_rec.attribute7 := p5_a17;
    ddp_reason_rec.attribute8 := p5_a18;
    ddp_reason_rec.attribute9 := p5_a19;
    ddp_reason_rec.attribute10 := p5_a20;
    ddp_reason_rec.attribute11 := p5_a21;
    ddp_reason_rec.attribute12 := p5_a22;
    ddp_reason_rec.attribute13 := p5_a23;
    ddp_reason_rec.attribute14 := p5_a24;
    ddp_reason_rec.attribute15 := p5_a25;
    ddp_reason_rec.name := p5_a26;
    ddp_reason_rec.description := p5_a27;
    ddp_reason_rec.org_id := p5_a28;
    ddp_reason_rec.reason_type := p5_a29;
    ddp_reason_rec.adjustment_reason_code := p5_a30;
    ddp_reason_rec.invoicing_reason_code := p5_a31;
    ddp_reason_rec.order_type_id := p5_a32;
    ddp_reason_rec.partner_access_flag := p5_a33;

    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.validate_reason_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_reason_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_reason(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  VARCHAR2
    , p3_a8  DATE
    , p3_a9  DATE
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
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
    , p3_a28  NUMBER
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_reason_rec ozf_reason_pvt.reason_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_reason_rec.reason_code_id := p3_a0;
    ddp_reason_rec.object_version_number := p3_a1;
    ddp_reason_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_reason_rec.last_updated_by := p3_a3;
    ddp_reason_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_reason_rec.created_by := p3_a5;
    ddp_reason_rec.last_update_login := p3_a6;
    ddp_reason_rec.reason_code := p3_a7;
    ddp_reason_rec.start_date_active := rosetta_g_miss_date_in_map(p3_a8);
    ddp_reason_rec.end_date_active := rosetta_g_miss_date_in_map(p3_a9);
    ddp_reason_rec.attribute_category := p3_a10;
    ddp_reason_rec.attribute1 := p3_a11;
    ddp_reason_rec.attribute2 := p3_a12;
    ddp_reason_rec.attribute3 := p3_a13;
    ddp_reason_rec.attribute4 := p3_a14;
    ddp_reason_rec.attribute5 := p3_a15;
    ddp_reason_rec.attribute6 := p3_a16;
    ddp_reason_rec.attribute7 := p3_a17;
    ddp_reason_rec.attribute8 := p3_a18;
    ddp_reason_rec.attribute9 := p3_a19;
    ddp_reason_rec.attribute10 := p3_a20;
    ddp_reason_rec.attribute11 := p3_a21;
    ddp_reason_rec.attribute12 := p3_a22;
    ddp_reason_rec.attribute13 := p3_a23;
    ddp_reason_rec.attribute14 := p3_a24;
    ddp_reason_rec.attribute15 := p3_a25;
    ddp_reason_rec.name := p3_a26;
    ddp_reason_rec.description := p3_a27;
    ddp_reason_rec.org_id := p3_a28;
    ddp_reason_rec.reason_type := p3_a29;
    ddp_reason_rec.adjustment_reason_code := p3_a30;
    ddp_reason_rec.invoicing_reason_code := p3_a31;
    ddp_reason_rec.order_type_id := p3_a32;
    ddp_reason_rec.partner_access_flag := p3_a33;




    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.validate_reason(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_reason_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_reason_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  DATE
    , p0_a9  DATE
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
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
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  DATE
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_reason_rec ozf_reason_pvt.reason_rec_type;
    ddx_complete_rec ozf_reason_pvt.reason_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_reason_rec.reason_code_id := p0_a0;
    ddp_reason_rec.object_version_number := p0_a1;
    ddp_reason_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_reason_rec.last_updated_by := p0_a3;
    ddp_reason_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_reason_rec.created_by := p0_a5;
    ddp_reason_rec.last_update_login := p0_a6;
    ddp_reason_rec.reason_code := p0_a7;
    ddp_reason_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a8);
    ddp_reason_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a9);
    ddp_reason_rec.attribute_category := p0_a10;
    ddp_reason_rec.attribute1 := p0_a11;
    ddp_reason_rec.attribute2 := p0_a12;
    ddp_reason_rec.attribute3 := p0_a13;
    ddp_reason_rec.attribute4 := p0_a14;
    ddp_reason_rec.attribute5 := p0_a15;
    ddp_reason_rec.attribute6 := p0_a16;
    ddp_reason_rec.attribute7 := p0_a17;
    ddp_reason_rec.attribute8 := p0_a18;
    ddp_reason_rec.attribute9 := p0_a19;
    ddp_reason_rec.attribute10 := p0_a20;
    ddp_reason_rec.attribute11 := p0_a21;
    ddp_reason_rec.attribute12 := p0_a22;
    ddp_reason_rec.attribute13 := p0_a23;
    ddp_reason_rec.attribute14 := p0_a24;
    ddp_reason_rec.attribute15 := p0_a25;
    ddp_reason_rec.name := p0_a26;
    ddp_reason_rec.description := p0_a27;
    ddp_reason_rec.org_id := p0_a28;
    ddp_reason_rec.reason_type := p0_a29;
    ddp_reason_rec.adjustment_reason_code := p0_a30;
    ddp_reason_rec.invoicing_reason_code := p0_a31;
    ddp_reason_rec.order_type_id := p0_a32;
    ddp_reason_rec.partner_access_flag := p0_a33;



    -- here's the delegated call to the old PL/SQL routine
    ozf_reason_pvt.complete_reason_rec(ddp_reason_rec,
      ddx_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.reason_code_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := ddx_complete_rec.last_updated_by;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.reason_code;
    p1_a8 := ddx_complete_rec.start_date_active;
    p1_a9 := ddx_complete_rec.end_date_active;
    p1_a10 := ddx_complete_rec.attribute_category;
    p1_a11 := ddx_complete_rec.attribute1;
    p1_a12 := ddx_complete_rec.attribute2;
    p1_a13 := ddx_complete_rec.attribute3;
    p1_a14 := ddx_complete_rec.attribute4;
    p1_a15 := ddx_complete_rec.attribute5;
    p1_a16 := ddx_complete_rec.attribute6;
    p1_a17 := ddx_complete_rec.attribute7;
    p1_a18 := ddx_complete_rec.attribute8;
    p1_a19 := ddx_complete_rec.attribute9;
    p1_a20 := ddx_complete_rec.attribute10;
    p1_a21 := ddx_complete_rec.attribute11;
    p1_a22 := ddx_complete_rec.attribute12;
    p1_a23 := ddx_complete_rec.attribute13;
    p1_a24 := ddx_complete_rec.attribute14;
    p1_a25 := ddx_complete_rec.attribute15;
    p1_a26 := ddx_complete_rec.name;
    p1_a27 := ddx_complete_rec.description;
    p1_a28 := ddx_complete_rec.org_id;
    p1_a29 := ddx_complete_rec.reason_type;
    p1_a30 := ddx_complete_rec.adjustment_reason_code;
    p1_a31 := ddx_complete_rec.invoicing_reason_code;
    p1_a32 := ddx_complete_rec.order_type_id;
    p1_a33 := ddx_complete_rec.partner_access_flag;

  end;

end ozf_reason_pvt_w;

/
