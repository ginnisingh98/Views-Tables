--------------------------------------------------------
--  DDL for Package Body AMS_VENUE_RATES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUE_RATES_PVT_W" as
  /* $Header: amswvrtb.pls 115.5 2002/12/24 18:59:49 mukumar ship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_venue_rates_pvt.venue_rates_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).active_flag := a7(indx);
          t(ddindx).venue_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).metric_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transactional_value := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).transactional_currency_code := a11(indx);
          t(ddindx).functional_value := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).functional_currency_code := a13(indx);
          t(ddindx).uom_code := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).rate_code := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).description := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_venue_rates_pvt.venue_rates_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_200
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
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
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
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
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
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rate_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).active_flag;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).venue_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).metric_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).transactional_value);
          a11(indx) := t(ddindx).transactional_currency_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).functional_value);
          a13(indx) := t(ddindx).functional_currency_code;
          a14(indx) := t(ddindx).uom_code;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := t(ddindx).rate_code;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_venue_rates(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_rate_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
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
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_venue_rates_rec ams_venue_rates_pvt.venue_rates_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rates_rec.rate_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rates_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_venue_rates_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_venue_rates_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_venue_rates_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_venue_rates_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rates_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rates_rec.active_flag := p7_a7;
    ddp_venue_rates_rec.venue_id := rosetta_g_miss_num_map(p7_a8);
    ddp_venue_rates_rec.metric_id := rosetta_g_miss_num_map(p7_a9);
    ddp_venue_rates_rec.transactional_value := rosetta_g_miss_num_map(p7_a10);
    ddp_venue_rates_rec.transactional_currency_code := p7_a11;
    ddp_venue_rates_rec.functional_value := rosetta_g_miss_num_map(p7_a12);
    ddp_venue_rates_rec.functional_currency_code := p7_a13;
    ddp_venue_rates_rec.uom_code := p7_a14;
    ddp_venue_rates_rec.attribute_category := p7_a15;
    ddp_venue_rates_rec.rate_code := p7_a16;
    ddp_venue_rates_rec.attribute1 := p7_a17;
    ddp_venue_rates_rec.attribute2 := p7_a18;
    ddp_venue_rates_rec.attribute3 := p7_a19;
    ddp_venue_rates_rec.attribute4 := p7_a20;
    ddp_venue_rates_rec.attribute5 := p7_a21;
    ddp_venue_rates_rec.attribute6 := p7_a22;
    ddp_venue_rates_rec.attribute7 := p7_a23;
    ddp_venue_rates_rec.attribute8 := p7_a24;
    ddp_venue_rates_rec.attribute9 := p7_a25;
    ddp_venue_rates_rec.attribute10 := p7_a26;
    ddp_venue_rates_rec.attribute11 := p7_a27;
    ddp_venue_rates_rec.attribute12 := p7_a28;
    ddp_venue_rates_rec.attribute13 := p7_a29;
    ddp_venue_rates_rec.attribute14 := p7_a30;
    ddp_venue_rates_rec.attribute15 := p7_a31;
    ddp_venue_rates_rec.description := p7_a32;


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_rates_pvt.create_venue_rates(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rates_rec,
      x_rate_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_venue_rates(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
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
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_venue_rates_rec ams_venue_rates_pvt.venue_rates_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rates_rec.rate_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rates_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_venue_rates_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_venue_rates_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_venue_rates_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_venue_rates_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rates_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rates_rec.active_flag := p7_a7;
    ddp_venue_rates_rec.venue_id := rosetta_g_miss_num_map(p7_a8);
    ddp_venue_rates_rec.metric_id := rosetta_g_miss_num_map(p7_a9);
    ddp_venue_rates_rec.transactional_value := rosetta_g_miss_num_map(p7_a10);
    ddp_venue_rates_rec.transactional_currency_code := p7_a11;
    ddp_venue_rates_rec.functional_value := rosetta_g_miss_num_map(p7_a12);
    ddp_venue_rates_rec.functional_currency_code := p7_a13;
    ddp_venue_rates_rec.uom_code := p7_a14;
    ddp_venue_rates_rec.attribute_category := p7_a15;
    ddp_venue_rates_rec.rate_code := p7_a16;
    ddp_venue_rates_rec.attribute1 := p7_a17;
    ddp_venue_rates_rec.attribute2 := p7_a18;
    ddp_venue_rates_rec.attribute3 := p7_a19;
    ddp_venue_rates_rec.attribute4 := p7_a20;
    ddp_venue_rates_rec.attribute5 := p7_a21;
    ddp_venue_rates_rec.attribute6 := p7_a22;
    ddp_venue_rates_rec.attribute7 := p7_a23;
    ddp_venue_rates_rec.attribute8 := p7_a24;
    ddp_venue_rates_rec.attribute9 := p7_a25;
    ddp_venue_rates_rec.attribute10 := p7_a26;
    ddp_venue_rates_rec.attribute11 := p7_a27;
    ddp_venue_rates_rec.attribute12 := p7_a28;
    ddp_venue_rates_rec.attribute13 := p7_a29;
    ddp_venue_rates_rec.attribute14 := p7_a30;
    ddp_venue_rates_rec.attribute15 := p7_a31;
    ddp_venue_rates_rec.description := p7_a32;


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_rates_pvt.update_venue_rates(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rates_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_venue_rates(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  NUMBER := 0-1962.0724
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
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_venue_rates_rec ams_venue_rates_pvt.venue_rates_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_venue_rates_rec.rate_id := rosetta_g_miss_num_map(p3_a0);
    ddp_venue_rates_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_venue_rates_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_venue_rates_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_venue_rates_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_venue_rates_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_venue_rates_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_venue_rates_rec.active_flag := p3_a7;
    ddp_venue_rates_rec.venue_id := rosetta_g_miss_num_map(p3_a8);
    ddp_venue_rates_rec.metric_id := rosetta_g_miss_num_map(p3_a9);
    ddp_venue_rates_rec.transactional_value := rosetta_g_miss_num_map(p3_a10);
    ddp_venue_rates_rec.transactional_currency_code := p3_a11;
    ddp_venue_rates_rec.functional_value := rosetta_g_miss_num_map(p3_a12);
    ddp_venue_rates_rec.functional_currency_code := p3_a13;
    ddp_venue_rates_rec.uom_code := p3_a14;
    ddp_venue_rates_rec.attribute_category := p3_a15;
    ddp_venue_rates_rec.rate_code := p3_a16;
    ddp_venue_rates_rec.attribute1 := p3_a17;
    ddp_venue_rates_rec.attribute2 := p3_a18;
    ddp_venue_rates_rec.attribute3 := p3_a19;
    ddp_venue_rates_rec.attribute4 := p3_a20;
    ddp_venue_rates_rec.attribute5 := p3_a21;
    ddp_venue_rates_rec.attribute6 := p3_a22;
    ddp_venue_rates_rec.attribute7 := p3_a23;
    ddp_venue_rates_rec.attribute8 := p3_a24;
    ddp_venue_rates_rec.attribute9 := p3_a25;
    ddp_venue_rates_rec.attribute10 := p3_a26;
    ddp_venue_rates_rec.attribute11 := p3_a27;
    ddp_venue_rates_rec.attribute12 := p3_a28;
    ddp_venue_rates_rec.attribute13 := p3_a29;
    ddp_venue_rates_rec.attribute14 := p3_a30;
    ddp_venue_rates_rec.attribute15 := p3_a31;
    ddp_venue_rates_rec.description := p3_a32;





    -- here's the delegated call to the old PL/SQL routine
    ams_venue_rates_pvt.validate_venue_rates(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_venue_rates_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_venue_rates_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
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
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_venue_rates_rec ams_venue_rates_pvt.venue_rates_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_venue_rates_rec.rate_id := rosetta_g_miss_num_map(p0_a0);
    ddp_venue_rates_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_venue_rates_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_venue_rates_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_venue_rates_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_venue_rates_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_venue_rates_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_venue_rates_rec.active_flag := p0_a7;
    ddp_venue_rates_rec.venue_id := rosetta_g_miss_num_map(p0_a8);
    ddp_venue_rates_rec.metric_id := rosetta_g_miss_num_map(p0_a9);
    ddp_venue_rates_rec.transactional_value := rosetta_g_miss_num_map(p0_a10);
    ddp_venue_rates_rec.transactional_currency_code := p0_a11;
    ddp_venue_rates_rec.functional_value := rosetta_g_miss_num_map(p0_a12);
    ddp_venue_rates_rec.functional_currency_code := p0_a13;
    ddp_venue_rates_rec.uom_code := p0_a14;
    ddp_venue_rates_rec.attribute_category := p0_a15;
    ddp_venue_rates_rec.rate_code := p0_a16;
    ddp_venue_rates_rec.attribute1 := p0_a17;
    ddp_venue_rates_rec.attribute2 := p0_a18;
    ddp_venue_rates_rec.attribute3 := p0_a19;
    ddp_venue_rates_rec.attribute4 := p0_a20;
    ddp_venue_rates_rec.attribute5 := p0_a21;
    ddp_venue_rates_rec.attribute6 := p0_a22;
    ddp_venue_rates_rec.attribute7 := p0_a23;
    ddp_venue_rates_rec.attribute8 := p0_a24;
    ddp_venue_rates_rec.attribute9 := p0_a25;
    ddp_venue_rates_rec.attribute10 := p0_a26;
    ddp_venue_rates_rec.attribute11 := p0_a27;
    ddp_venue_rates_rec.attribute12 := p0_a28;
    ddp_venue_rates_rec.attribute13 := p0_a29;
    ddp_venue_rates_rec.attribute14 := p0_a30;
    ddp_venue_rates_rec.attribute15 := p0_a31;
    ddp_venue_rates_rec.description := p0_a32;



    -- here's the delegated call to the old PL/SQL routine
    ams_venue_rates_pvt.check_venue_rates_items(ddp_venue_rates_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_venue_rates_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
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
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_venue_rates_rec ams_venue_rates_pvt.venue_rates_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_venue_rates_rec.rate_id := rosetta_g_miss_num_map(p5_a0);
    ddp_venue_rates_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_venue_rates_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_venue_rates_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_venue_rates_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_venue_rates_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_venue_rates_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_venue_rates_rec.active_flag := p5_a7;
    ddp_venue_rates_rec.venue_id := rosetta_g_miss_num_map(p5_a8);
    ddp_venue_rates_rec.metric_id := rosetta_g_miss_num_map(p5_a9);
    ddp_venue_rates_rec.transactional_value := rosetta_g_miss_num_map(p5_a10);
    ddp_venue_rates_rec.transactional_currency_code := p5_a11;
    ddp_venue_rates_rec.functional_value := rosetta_g_miss_num_map(p5_a12);
    ddp_venue_rates_rec.functional_currency_code := p5_a13;
    ddp_venue_rates_rec.uom_code := p5_a14;
    ddp_venue_rates_rec.attribute_category := p5_a15;
    ddp_venue_rates_rec.rate_code := p5_a16;
    ddp_venue_rates_rec.attribute1 := p5_a17;
    ddp_venue_rates_rec.attribute2 := p5_a18;
    ddp_venue_rates_rec.attribute3 := p5_a19;
    ddp_venue_rates_rec.attribute4 := p5_a20;
    ddp_venue_rates_rec.attribute5 := p5_a21;
    ddp_venue_rates_rec.attribute6 := p5_a22;
    ddp_venue_rates_rec.attribute7 := p5_a23;
    ddp_venue_rates_rec.attribute8 := p5_a24;
    ddp_venue_rates_rec.attribute9 := p5_a25;
    ddp_venue_rates_rec.attribute10 := p5_a26;
    ddp_venue_rates_rec.attribute11 := p5_a27;
    ddp_venue_rates_rec.attribute12 := p5_a28;
    ddp_venue_rates_rec.attribute13 := p5_a29;
    ddp_venue_rates_rec.attribute14 := p5_a30;
    ddp_venue_rates_rec.attribute15 := p5_a31;
    ddp_venue_rates_rec.description := p5_a32;

    -- here's the delegated call to the old PL/SQL routine
    ams_venue_rates_pvt.validate_venue_rates_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rates_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_venue_rates_pvt_w;

/
