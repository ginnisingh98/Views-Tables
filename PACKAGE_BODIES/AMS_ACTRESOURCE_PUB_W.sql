--------------------------------------------------------
--  DDL for Package Body AMS_ACTRESOURCE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTRESOURCE_PUB_W" as
  /* $Header: amswrscb.pls 115.8 2002/11/16 01:47:19 dbiswas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_actresource_pub.act_resource_rec_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_4000
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
          t(ddindx).activity_resource_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).act_resource_used_by_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).arc_act_resource_used_by := a8(indx);
          t(ddindx).resource_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).role_cd := a10(indx);
          t(ddindx).user_status_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).system_status_code := a12(indx);
          t(ddindx).start_date_time := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).end_date_time := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).primary_flag := a15(indx);
          t(ddindx).description := a16(indx);
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_actresource_pub.act_resource_rec_tbl, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_NUMBER_TABLE
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_DATE_TABLE
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a28 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a29 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_200
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
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_4000();
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
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).activity_resource_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).act_resource_used_by_id);
          a8(indx) := t(ddindx).arc_act_resource_used_by;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a10(indx) := t(ddindx).role_cd;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).user_status_id);
          a12(indx) := t(ddindx).system_status_code;
          a13(indx) := t(ddindx).start_date_time;
          a14(indx) := t(ddindx).end_date_time;
          a15(indx) := t(ddindx).primary_flag;
          a16(indx) := t(ddindx).description;
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
  end rosetta_table_copy_out_p3;

  procedure create_act_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_act_resource_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
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
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_resource_rec ams_actresource_pub.act_resource_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_resource_rec.activity_resource_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_resource_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_resource_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_resource_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_resource_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_resource_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_resource_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_resource_rec.act_resource_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_resource_rec.arc_act_resource_used_by := p7_a8;
    ddp_act_resource_rec.resource_id := rosetta_g_miss_num_map(p7_a9);
    ddp_act_resource_rec.role_cd := p7_a10;
    ddp_act_resource_rec.user_status_id := rosetta_g_miss_num_map(p7_a11);
    ddp_act_resource_rec.system_status_code := p7_a12;
    ddp_act_resource_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_act_resource_rec.end_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_act_resource_rec.primary_flag := p7_a15;
    ddp_act_resource_rec.description := p7_a16;
    ddp_act_resource_rec.attribute_category := p7_a17;
    ddp_act_resource_rec.attribute1 := p7_a18;
    ddp_act_resource_rec.attribute2 := p7_a19;
    ddp_act_resource_rec.attribute3 := p7_a20;
    ddp_act_resource_rec.attribute4 := p7_a21;
    ddp_act_resource_rec.attribute5 := p7_a22;
    ddp_act_resource_rec.attribute6 := p7_a23;
    ddp_act_resource_rec.attribute7 := p7_a24;
    ddp_act_resource_rec.attribute8 := p7_a25;
    ddp_act_resource_rec.attribute9 := p7_a26;
    ddp_act_resource_rec.attribute10 := p7_a27;
    ddp_act_resource_rec.attribute11 := p7_a28;
    ddp_act_resource_rec.attribute12 := p7_a29;
    ddp_act_resource_rec.attribute13 := p7_a30;
    ddp_act_resource_rec.attribute14 := p7_a31;
    ddp_act_resource_rec.attribute15 := p7_a32;


    -- here's the delegated call to the old PL/SQL routine
    ams_actresource_pub.create_act_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_resource_rec,
      x_act_resource_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_act_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
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
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_resource_rec ams_actresource_pub.act_resource_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_resource_rec.activity_resource_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_resource_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_resource_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_resource_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_resource_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_resource_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_resource_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_resource_rec.act_resource_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_resource_rec.arc_act_resource_used_by := p7_a8;
    ddp_act_resource_rec.resource_id := rosetta_g_miss_num_map(p7_a9);
    ddp_act_resource_rec.role_cd := p7_a10;
    ddp_act_resource_rec.user_status_id := rosetta_g_miss_num_map(p7_a11);
    ddp_act_resource_rec.system_status_code := p7_a12;
    ddp_act_resource_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_act_resource_rec.end_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_act_resource_rec.primary_flag := p7_a15;
    ddp_act_resource_rec.description := p7_a16;
    ddp_act_resource_rec.attribute_category := p7_a17;
    ddp_act_resource_rec.attribute1 := p7_a18;
    ddp_act_resource_rec.attribute2 := p7_a19;
    ddp_act_resource_rec.attribute3 := p7_a20;
    ddp_act_resource_rec.attribute4 := p7_a21;
    ddp_act_resource_rec.attribute5 := p7_a22;
    ddp_act_resource_rec.attribute6 := p7_a23;
    ddp_act_resource_rec.attribute7 := p7_a24;
    ddp_act_resource_rec.attribute8 := p7_a25;
    ddp_act_resource_rec.attribute9 := p7_a26;
    ddp_act_resource_rec.attribute10 := p7_a27;
    ddp_act_resource_rec.attribute11 := p7_a28;
    ddp_act_resource_rec.attribute12 := p7_a29;
    ddp_act_resource_rec.attribute13 := p7_a30;
    ddp_act_resource_rec.attribute14 := p7_a31;
    ddp_act_resource_rec.attribute15 := p7_a32;

    -- here's the delegated call to the old PL/SQL routine
    ams_actresource_pub.update_act_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_resource_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_act_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_resource_rec ams_actresource_pub.act_resource_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_resource_rec.activity_resource_id := rosetta_g_miss_num_map(p6_a0);
    ddp_act_resource_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_resource_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_act_resource_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_resource_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_act_resource_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_act_resource_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_act_resource_rec.act_resource_used_by_id := rosetta_g_miss_num_map(p6_a7);
    ddp_act_resource_rec.arc_act_resource_used_by := p6_a8;
    ddp_act_resource_rec.resource_id := rosetta_g_miss_num_map(p6_a9);
    ddp_act_resource_rec.role_cd := p6_a10;
    ddp_act_resource_rec.user_status_id := rosetta_g_miss_num_map(p6_a11);
    ddp_act_resource_rec.system_status_code := p6_a12;
    ddp_act_resource_rec.start_date_time := rosetta_g_miss_date_in_map(p6_a13);
    ddp_act_resource_rec.end_date_time := rosetta_g_miss_date_in_map(p6_a14);
    ddp_act_resource_rec.primary_flag := p6_a15;
    ddp_act_resource_rec.description := p6_a16;
    ddp_act_resource_rec.attribute_category := p6_a17;
    ddp_act_resource_rec.attribute1 := p6_a18;
    ddp_act_resource_rec.attribute2 := p6_a19;
    ddp_act_resource_rec.attribute3 := p6_a20;
    ddp_act_resource_rec.attribute4 := p6_a21;
    ddp_act_resource_rec.attribute5 := p6_a22;
    ddp_act_resource_rec.attribute6 := p6_a23;
    ddp_act_resource_rec.attribute7 := p6_a24;
    ddp_act_resource_rec.attribute8 := p6_a25;
    ddp_act_resource_rec.attribute9 := p6_a26;
    ddp_act_resource_rec.attribute10 := p6_a27;
    ddp_act_resource_rec.attribute11 := p6_a28;
    ddp_act_resource_rec.attribute12 := p6_a29;
    ddp_act_resource_rec.attribute13 := p6_a30;
    ddp_act_resource_rec.attribute14 := p6_a31;
    ddp_act_resource_rec.attribute15 := p6_a32;

    -- here's the delegated call to the old PL/SQL routine
    ams_actresource_pub.validate_act_resource(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_resource_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end ams_actresource_pub_w;

/
