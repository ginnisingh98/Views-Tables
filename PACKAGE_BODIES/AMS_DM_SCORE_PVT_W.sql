--------------------------------------------------------
--  DDL for Package Body AMS_DM_SCORE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_SCORE_PVT_W" as
  /* $Header: amswdmsb.pls 120.1 2005/06/15 23:58:32 appldev  $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_dm_score_pvt.dm_score_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_1000
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).model_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).user_status_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).status_code := a10(indx);
          t(ddindx).status_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).owner_user_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).results_flag := a13(indx);
          t(ddindx).logs_flag := a14(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).scheduled_timezone_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).score_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).total_records := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).total_positives := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).min_records := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).max_records := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).row_selection_type := a23(indx);
          t(ddindx).every_nth_row := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).pct_random := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).country_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).wf_itemkey := a28(indx);
          t(ddindx).score_name := a29(indx);
          t(ddindx).description := a30(indx);
          t(ddindx).attribute_category := a31(indx);
          t(ddindx).attribute1 := a32(indx);
          t(ddindx).attribute2 := a33(indx);
          t(ddindx).attribute3 := a34(indx);
          t(ddindx).attribute4 := a35(indx);
          t(ddindx).attribute5 := a36(indx);
          t(ddindx).attribute6 := a37(indx);
          t(ddindx).attribute7 := a38(indx);
          t(ddindx).attribute8 := a39(indx);
          t(ddindx).attribute9 := a40(indx);
          t(ddindx).attribute10 := a41(indx);
          t(ddindx).attribute11 := a42(indx);
          t(ddindx).attribute12 := a43(indx);
          t(ddindx).attribute13 := a44(indx);
          t(ddindx).attribute14 := a45(indx);
          t(ddindx).attribute15 := a46(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_dm_score_pvt.dm_score_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_DATE_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_DATE_TABLE
    , a18 OUT NOCOPY JTF_DATE_TABLE
    , a19 OUT NOCOPY JTF_NUMBER_TABLE
    , a20 OUT NOCOPY JTF_NUMBER_TABLE
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_NUMBER_TABLE
    , a25 OUT NOCOPY JTF_NUMBER_TABLE
    , a26 OUT NOCOPY JTF_NUMBER_TABLE
    , a27 OUT NOCOPY JTF_NUMBER_TABLE
    , a28 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a29 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_1000
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a33 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a34 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a35 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a36 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a38 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a39 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a40 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a41 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a42 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a43 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a44 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a45 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a46 OUT NOCOPY JTF_VARCHAR2_TABLE_200
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_1000();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_1000();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
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
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).score_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).model_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).user_status_id);
          a10(indx) := t(ddindx).status_code;
          a11(indx) := t(ddindx).status_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).owner_user_id);
          a13(indx) := t(ddindx).results_flag;
          a14(indx) := t(ddindx).logs_flag;
          a15(indx) := t(ddindx).scheduled_date;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).scheduled_timezone_id);
          a17(indx) := t(ddindx).score_date;
          a18(indx) := t(ddindx).expiration_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).total_records);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).total_positives);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).min_records);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).max_records);
          a23(indx) := t(ddindx).row_selection_type;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).every_nth_row);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).pct_random);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).country_id);
          a28(indx) := t(ddindx).wf_itemkey;
          a29(indx) := t(ddindx).score_name;
          a30(indx) := t(ddindx).description;
          a31(indx) := t(ddindx).attribute_category;
          a32(indx) := t(ddindx).attribute1;
          a33(indx) := t(ddindx).attribute2;
          a34(indx) := t(ddindx).attribute3;
          a35(indx) := t(ddindx).attribute4;
          a36(indx) := t(ddindx).attribute5;
          a37(indx) := t(ddindx).attribute6;
          a38(indx) := t(ddindx).attribute7;
          a39(indx) := t(ddindx).attribute8;
          a40(indx) := t(ddindx).attribute9;
          a41(indx) := t(ddindx).attribute10;
          a42(indx) := t(ddindx).attribute11;
          a43(indx) := t(ddindx).attribute12;
          a44(indx) := t(ddindx).attribute13;
          a45(indx) := t(ddindx).attribute14;
          a46(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure check_score_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_score_rec ams_dm_score_pvt.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_score_rec.score_id := rosetta_g_miss_num_map(p0_a0);
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_score_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_score_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_score_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_score_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_score_rec.org_id := rosetta_g_miss_num_map(p0_a7);
    ddp_score_rec.model_id := rosetta_g_miss_num_map(p0_a8);
    ddp_score_rec.user_status_id := rosetta_g_miss_num_map(p0_a9);
    ddp_score_rec.status_code := p0_a10;
    ddp_score_rec.status_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_score_rec.owner_user_id := rosetta_g_miss_num_map(p0_a12);
    ddp_score_rec.results_flag := p0_a13;
    ddp_score_rec.logs_flag := p0_a14;
    ddp_score_rec.scheduled_date := rosetta_g_miss_date_in_map(p0_a15);
    ddp_score_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p0_a16);
    ddp_score_rec.score_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_score_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_score_rec.total_records := rosetta_g_miss_num_map(p0_a19);
    ddp_score_rec.total_positives := rosetta_g_miss_num_map(p0_a20);
    ddp_score_rec.min_records := rosetta_g_miss_num_map(p0_a21);
    ddp_score_rec.max_records := rosetta_g_miss_num_map(p0_a22);
    ddp_score_rec.row_selection_type := p0_a23;
    ddp_score_rec.every_nth_row := rosetta_g_miss_num_map(p0_a24);
    ddp_score_rec.pct_random := rosetta_g_miss_num_map(p0_a25);
    ddp_score_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a26);
    ddp_score_rec.country_id := rosetta_g_miss_num_map(p0_a27);
    ddp_score_rec.wf_itemkey := p0_a28;
    ddp_score_rec.score_name := p0_a29;
    ddp_score_rec.description := p0_a30;
    ddp_score_rec.attribute_category := p0_a31;
    ddp_score_rec.attribute1 := p0_a32;
    ddp_score_rec.attribute2 := p0_a33;
    ddp_score_rec.attribute3 := p0_a34;
    ddp_score_rec.attribute4 := p0_a35;
    ddp_score_rec.attribute5 := p0_a36;
    ddp_score_rec.attribute6 := p0_a37;
    ddp_score_rec.attribute7 := p0_a38;
    ddp_score_rec.attribute8 := p0_a39;
    ddp_score_rec.attribute9 := p0_a40;
    ddp_score_rec.attribute10 := p0_a41;
    ddp_score_rec.attribute11 := p0_a42;
    ddp_score_rec.attribute12 := p0_a43;
    ddp_score_rec.attribute13 := p0_a44;
    ddp_score_rec.attribute14 := p0_a45;
    ddp_score_rec.attribute15 := p0_a46;



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.check_score_items(ddp_score_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure create_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_custom_setup_id OUT NOCOPY  NUMBER
    , x_score_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_score_rec ams_dm_score_pvt.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_score_rec.score_id := rosetta_g_miss_num_map(p7_a0);
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_score_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_score_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_score_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_score_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_score_rec.org_id := rosetta_g_miss_num_map(p7_a7);
    ddp_score_rec.model_id := rosetta_g_miss_num_map(p7_a8);
    ddp_score_rec.user_status_id := rosetta_g_miss_num_map(p7_a9);
    ddp_score_rec.status_code := p7_a10;
    ddp_score_rec.status_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_score_rec.owner_user_id := rosetta_g_miss_num_map(p7_a12);
    ddp_score_rec.results_flag := p7_a13;
    ddp_score_rec.logs_flag := p7_a14;
    ddp_score_rec.scheduled_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_score_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p7_a16);
    ddp_score_rec.score_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_score_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_score_rec.total_records := rosetta_g_miss_num_map(p7_a19);
    ddp_score_rec.total_positives := rosetta_g_miss_num_map(p7_a20);
    ddp_score_rec.min_records := rosetta_g_miss_num_map(p7_a21);
    ddp_score_rec.max_records := rosetta_g_miss_num_map(p7_a22);
    ddp_score_rec.row_selection_type := p7_a23;
    ddp_score_rec.every_nth_row := rosetta_g_miss_num_map(p7_a24);
    ddp_score_rec.pct_random := rosetta_g_miss_num_map(p7_a25);
    ddp_score_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a26);
    ddp_score_rec.country_id := rosetta_g_miss_num_map(p7_a27);
    ddp_score_rec.wf_itemkey := p7_a28;
    ddp_score_rec.score_name := p7_a29;
    ddp_score_rec.description := p7_a30;
    ddp_score_rec.attribute_category := p7_a31;
    ddp_score_rec.attribute1 := p7_a32;
    ddp_score_rec.attribute2 := p7_a33;
    ddp_score_rec.attribute3 := p7_a34;
    ddp_score_rec.attribute4 := p7_a35;
    ddp_score_rec.attribute5 := p7_a36;
    ddp_score_rec.attribute6 := p7_a37;
    ddp_score_rec.attribute7 := p7_a38;
    ddp_score_rec.attribute8 := p7_a39;
    ddp_score_rec.attribute9 := p7_a40;
    ddp_score_rec.attribute10 := p7_a41;
    ddp_score_rec.attribute11 := p7_a42;
    ddp_score_rec.attribute12 := p7_a43;
    ddp_score_rec.attribute13 := p7_a44;
    ddp_score_rec.attribute14 := p7_a45;
    ddp_score_rec.attribute15 := p7_a46;



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.create_score(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_score_rec,
      x_custom_setup_id,
      x_score_id);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_score(p_api_version  NUMBER
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
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_score_rec ams_dm_score_pvt.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_score_rec.score_id := rosetta_g_miss_num_map(p7_a0);
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_score_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_score_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_score_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_score_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_score_rec.org_id := rosetta_g_miss_num_map(p7_a7);
    ddp_score_rec.model_id := rosetta_g_miss_num_map(p7_a8);
    ddp_score_rec.user_status_id := rosetta_g_miss_num_map(p7_a9);
    ddp_score_rec.status_code := p7_a10;
    ddp_score_rec.status_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_score_rec.owner_user_id := rosetta_g_miss_num_map(p7_a12);
    ddp_score_rec.results_flag := p7_a13;
    ddp_score_rec.logs_flag := p7_a14;
    ddp_score_rec.scheduled_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_score_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p7_a16);
    ddp_score_rec.score_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_score_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_score_rec.total_records := rosetta_g_miss_num_map(p7_a19);
    ddp_score_rec.total_positives := rosetta_g_miss_num_map(p7_a20);
    ddp_score_rec.min_records := rosetta_g_miss_num_map(p7_a21);
    ddp_score_rec.max_records := rosetta_g_miss_num_map(p7_a22);
    ddp_score_rec.row_selection_type := p7_a23;
    ddp_score_rec.every_nth_row := rosetta_g_miss_num_map(p7_a24);
    ddp_score_rec.pct_random := rosetta_g_miss_num_map(p7_a25);
    ddp_score_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a26);
    ddp_score_rec.country_id := rosetta_g_miss_num_map(p7_a27);
    ddp_score_rec.wf_itemkey := p7_a28;
    ddp_score_rec.score_name := p7_a29;
    ddp_score_rec.description := p7_a30;
    ddp_score_rec.attribute_category := p7_a31;
    ddp_score_rec.attribute1 := p7_a32;
    ddp_score_rec.attribute2 := p7_a33;
    ddp_score_rec.attribute3 := p7_a34;
    ddp_score_rec.attribute4 := p7_a35;
    ddp_score_rec.attribute5 := p7_a36;
    ddp_score_rec.attribute6 := p7_a37;
    ddp_score_rec.attribute7 := p7_a38;
    ddp_score_rec.attribute8 := p7_a39;
    ddp_score_rec.attribute9 := p7_a40;
    ddp_score_rec.attribute10 := p7_a41;
    ddp_score_rec.attribute11 := p7_a42;
    ddp_score_rec.attribute12 := p7_a43;
    ddp_score_rec.attribute13 := p7_a44;
    ddp_score_rec.attribute14 := p7_a45;
    ddp_score_rec.attribute15 := p7_a46;


    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.update_score(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_score_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_score_rec(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_mode  VARCHAR2
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
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  DATE := fnd_api.g_miss_date
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_score_rec ams_dm_score_pvt.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_score_rec.score_id := rosetta_g_miss_num_map(p6_a0);
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_score_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_score_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_score_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_score_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_score_rec.org_id := rosetta_g_miss_num_map(p6_a7);
    ddp_score_rec.model_id := rosetta_g_miss_num_map(p6_a8);
    ddp_score_rec.user_status_id := rosetta_g_miss_num_map(p6_a9);
    ddp_score_rec.status_code := p6_a10;
    ddp_score_rec.status_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_score_rec.owner_user_id := rosetta_g_miss_num_map(p6_a12);
    ddp_score_rec.results_flag := p6_a13;
    ddp_score_rec.logs_flag := p6_a14;
    ddp_score_rec.scheduled_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_score_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p6_a16);
    ddp_score_rec.score_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_score_rec.expiration_date := rosetta_g_miss_date_in_map(p6_a18);
    ddp_score_rec.total_records := rosetta_g_miss_num_map(p6_a19);
    ddp_score_rec.total_positives := rosetta_g_miss_num_map(p6_a20);
    ddp_score_rec.min_records := rosetta_g_miss_num_map(p6_a21);
    ddp_score_rec.max_records := rosetta_g_miss_num_map(p6_a22);
    ddp_score_rec.row_selection_type := p6_a23;
    ddp_score_rec.every_nth_row := rosetta_g_miss_num_map(p6_a24);
    ddp_score_rec.pct_random := rosetta_g_miss_num_map(p6_a25);
    ddp_score_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a26);
    ddp_score_rec.country_id := rosetta_g_miss_num_map(p6_a27);
    ddp_score_rec.wf_itemkey := p6_a28;
    ddp_score_rec.score_name := p6_a29;
    ddp_score_rec.description := p6_a30;
    ddp_score_rec.attribute_category := p6_a31;
    ddp_score_rec.attribute1 := p6_a32;
    ddp_score_rec.attribute2 := p6_a33;
    ddp_score_rec.attribute3 := p6_a34;
    ddp_score_rec.attribute4 := p6_a35;
    ddp_score_rec.attribute5 := p6_a36;
    ddp_score_rec.attribute6 := p6_a37;
    ddp_score_rec.attribute7 := p6_a38;
    ddp_score_rec.attribute8 := p6_a39;
    ddp_score_rec.attribute9 := p6_a40;
    ddp_score_rec.attribute10 := p6_a41;
    ddp_score_rec.attribute11 := p6_a42;
    ddp_score_rec.attribute12 := p6_a43;
    ddp_score_rec.attribute13 := p6_a44;
    ddp_score_rec.attribute14 := p6_a45;
    ddp_score_rec.attribute15 := p6_a46;

    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.validate_score_rec(p_api_version,
      p_init_msg_list,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_score_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure validate_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  DATE := fnd_api.g_miss_date
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  DATE := fnd_api.g_miss_date
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  DATE := fnd_api.g_miss_date
    , p4_a18  DATE := fnd_api.g_miss_date
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_score_rec ams_dm_score_pvt.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_score_rec.score_id := rosetta_g_miss_num_map(p4_a0);
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_score_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_score_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_score_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_score_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_score_rec.org_id := rosetta_g_miss_num_map(p4_a7);
    ddp_score_rec.model_id := rosetta_g_miss_num_map(p4_a8);
    ddp_score_rec.user_status_id := rosetta_g_miss_num_map(p4_a9);
    ddp_score_rec.status_code := p4_a10;
    ddp_score_rec.status_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_score_rec.owner_user_id := rosetta_g_miss_num_map(p4_a12);
    ddp_score_rec.results_flag := p4_a13;
    ddp_score_rec.logs_flag := p4_a14;
    ddp_score_rec.scheduled_date := rosetta_g_miss_date_in_map(p4_a15);
    ddp_score_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p4_a16);
    ddp_score_rec.score_date := rosetta_g_miss_date_in_map(p4_a17);
    ddp_score_rec.expiration_date := rosetta_g_miss_date_in_map(p4_a18);
    ddp_score_rec.total_records := rosetta_g_miss_num_map(p4_a19);
    ddp_score_rec.total_positives := rosetta_g_miss_num_map(p4_a20);
    ddp_score_rec.min_records := rosetta_g_miss_num_map(p4_a21);
    ddp_score_rec.max_records := rosetta_g_miss_num_map(p4_a22);
    ddp_score_rec.row_selection_type := p4_a23;
    ddp_score_rec.every_nth_row := rosetta_g_miss_num_map(p4_a24);
    ddp_score_rec.pct_random := rosetta_g_miss_num_map(p4_a25);
    ddp_score_rec.custom_setup_id := rosetta_g_miss_num_map(p4_a26);
    ddp_score_rec.country_id := rosetta_g_miss_num_map(p4_a27);
    ddp_score_rec.wf_itemkey := p4_a28;
    ddp_score_rec.score_name := p4_a29;
    ddp_score_rec.description := p4_a30;
    ddp_score_rec.attribute_category := p4_a31;
    ddp_score_rec.attribute1 := p4_a32;
    ddp_score_rec.attribute2 := p4_a33;
    ddp_score_rec.attribute3 := p4_a34;
    ddp_score_rec.attribute4 := p4_a35;
    ddp_score_rec.attribute5 := p4_a36;
    ddp_score_rec.attribute6 := p4_a37;
    ddp_score_rec.attribute7 := p4_a38;
    ddp_score_rec.attribute8 := p4_a39;
    ddp_score_rec.attribute9 := p4_a40;
    ddp_score_rec.attribute10 := p4_a41;
    ddp_score_rec.attribute11 := p4_a42;
    ddp_score_rec.attribute12 := p4_a43;
    ddp_score_rec.attribute13 := p4_a44;
    ddp_score_rec.attribute14 := p4_a45;
    ddp_score_rec.attribute15 := p4_a46;




    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.validate_score(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_score_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure copy_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id OUT NOCOPY  NUMBER
    , x_custom_setup_id OUT NOCOPY  NUMBER
  )
  as
    ddp_attributes_table ams_cpyutility_pvt.copy_attributes_table_type;
    ddp_copy_columns_table ams_cpyutility_pvt.copy_columns_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_cpyutility_pvt_w.rosetta_table_copy_in_p0(ddp_attributes_table, p_attributes_table);

    ams_cpyutility_pvt_w.rosetta_table_copy_in_p2(ddp_copy_columns_table, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_score_pvt.copy_score(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id,
      ddp_attributes_table,
      ddp_copy_columns_table,
      x_new_object_id,
      x_custom_setup_id);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

end ams_dm_score_pvt_w;

/
