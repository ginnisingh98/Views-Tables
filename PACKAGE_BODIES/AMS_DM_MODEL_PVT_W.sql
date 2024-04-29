--------------------------------------------------------
--  DDL for Package Body AMS_DM_MODEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_MODEL_PVT_W" as
  /* $Header: amswdmmb.pls 115.8 2002/11/16 00:07:07 nyostos noship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_dm_model_pvt.dm_model_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_4000
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_4000
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).model_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).model_type := a8(indx);
          t(ddindx).user_status_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).status_code := a10(indx);
          t(ddindx).status_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).owner_user_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).last_build_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).scheduled_timezone_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).results_flag := a17(indx);
          t(ddindx).logs_flag := a18(indx);
          t(ddindx).target_field := a19(indx);
          t(ddindx).target_type := a20(indx);
          t(ddindx).target_positive_value := a21(indx);
          t(ddindx).total_records := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).total_positives := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).min_records := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).max_records := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).row_selection_type := a26(indx);
          t(ddindx).every_nth_row := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).pct_random := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).performance := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).target_group_type := a30(indx);
          t(ddindx).darwin_model_ref := a31(indx);
          t(ddindx).model_name := a32(indx);
          t(ddindx).description := a33(indx);
          t(ddindx).best_subtree := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).country_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).wf_itemkey := a37(indx);
          t(ddindx).target_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).attribute_category := a39(indx);
          t(ddindx).attribute1 := a40(indx);
          t(ddindx).attribute2 := a41(indx);
          t(ddindx).attribute3 := a42(indx);
          t(ddindx).attribute4 := a43(indx);
          t(ddindx).attribute5 := a44(indx);
          t(ddindx).attribute6 := a45(indx);
          t(ddindx).attribute7 := a46(indx);
          t(ddindx).attribute8 := a47(indx);
          t(ddindx).attribute9 := a48(indx);
          t(ddindx).attribute10 := a49(indx);
          t(ddindx).attribute11 := a50(indx);
          t(ddindx).attribute12 := a51(indx);
          t(ddindx).attribute13 := a52(indx);
          t(ddindx).attribute14 := a53(indx);
          t(ddindx).attribute15 := a54(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_dm_model_pvt.dm_model_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
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
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_DATE_TABLE
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_DATE_TABLE
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    , a23 OUT NOCOPY JTF_NUMBER_TABLE
    , a24 OUT NOCOPY JTF_NUMBER_TABLE
    , a25 OUT NOCOPY JTF_NUMBER_TABLE
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a27 OUT NOCOPY JTF_NUMBER_TABLE
    , a28 OUT NOCOPY JTF_NUMBER_TABLE
    , a29 OUT NOCOPY JTF_NUMBER_TABLE
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a33 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a34 OUT NOCOPY JTF_NUMBER_TABLE
    , a35 OUT NOCOPY JTF_NUMBER_TABLE
    , a36 OUT NOCOPY JTF_NUMBER_TABLE
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY JTF_NUMBER_TABLE
    , a39 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a40 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a41 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a42 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a43 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a44 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a45 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a46 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a47 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a48 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a49 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a50 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a51 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a52 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a53 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a54 OUT NOCOPY JTF_VARCHAR2_TABLE_200
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
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_4000();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_4000();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
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
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_4000();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_4000();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
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
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).model_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).model_type;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).user_status_id);
          a10(indx) := t(ddindx).status_code;
          a11(indx) := t(ddindx).status_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).owner_user_id);
          a13(indx) := t(ddindx).last_build_date;
          a14(indx) := t(ddindx).scheduled_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).scheduled_timezone_id);
          a16(indx) := t(ddindx).expiration_date;
          a17(indx) := t(ddindx).results_flag;
          a18(indx) := t(ddindx).logs_flag;
          a19(indx) := t(ddindx).target_field;
          a20(indx) := t(ddindx).target_type;
          a21(indx) := t(ddindx).target_positive_value;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).total_records);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).total_positives);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).min_records);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).max_records);
          a26(indx) := t(ddindx).row_selection_type;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).every_nth_row);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).pct_random);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).performance);
          a30(indx) := t(ddindx).target_group_type;
          a31(indx) := t(ddindx).darwin_model_ref;
          a32(indx) := t(ddindx).model_name;
          a33(indx) := t(ddindx).description;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).best_subtree);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).country_id);
          a37(indx) := t(ddindx).wf_itemkey;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).target_id);
          a39(indx) := t(ddindx).attribute_category;
          a40(indx) := t(ddindx).attribute1;
          a41(indx) := t(ddindx).attribute2;
          a42(indx) := t(ddindx).attribute3;
          a43(indx) := t(ddindx).attribute4;
          a44(indx) := t(ddindx).attribute5;
          a45(indx) := t(ddindx).attribute6;
          a46(indx) := t(ddindx).attribute7;
          a47(indx) := t(ddindx).attribute8;
          a48(indx) := t(ddindx).attribute9;
          a49(indx) := t(ddindx).attribute10;
          a50(indx) := t(ddindx).attribute11;
          a51(indx) := t(ddindx).attribute12;
          a52(indx) := t(ddindx).attribute13;
          a53(indx) := t(ddindx).attribute14;
          a54(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure check_dm_model_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_dm_model_rec ams_dm_model_pvt.dm_model_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_dm_model_rec.model_id := rosetta_g_miss_num_map(p0_a0);
    ddp_dm_model_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_dm_model_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_dm_model_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_dm_model_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_dm_model_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_dm_model_rec.org_id := rosetta_g_miss_num_map(p0_a6);
    ddp_dm_model_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_dm_model_rec.model_type := p0_a8;
    ddp_dm_model_rec.user_status_id := rosetta_g_miss_num_map(p0_a9);
    ddp_dm_model_rec.status_code := p0_a10;
    ddp_dm_model_rec.status_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_dm_model_rec.owner_user_id := rosetta_g_miss_num_map(p0_a12);
    ddp_dm_model_rec.last_build_date := rosetta_g_miss_date_in_map(p0_a13);
    ddp_dm_model_rec.scheduled_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_dm_model_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p0_a15);
    ddp_dm_model_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_dm_model_rec.results_flag := p0_a17;
    ddp_dm_model_rec.logs_flag := p0_a18;
    ddp_dm_model_rec.target_field := p0_a19;
    ddp_dm_model_rec.target_type := p0_a20;
    ddp_dm_model_rec.target_positive_value := p0_a21;
    ddp_dm_model_rec.total_records := rosetta_g_miss_num_map(p0_a22);
    ddp_dm_model_rec.total_positives := rosetta_g_miss_num_map(p0_a23);
    ddp_dm_model_rec.min_records := rosetta_g_miss_num_map(p0_a24);
    ddp_dm_model_rec.max_records := rosetta_g_miss_num_map(p0_a25);
    ddp_dm_model_rec.row_selection_type := p0_a26;
    ddp_dm_model_rec.every_nth_row := rosetta_g_miss_num_map(p0_a27);
    ddp_dm_model_rec.pct_random := rosetta_g_miss_num_map(p0_a28);
    ddp_dm_model_rec.performance := rosetta_g_miss_num_map(p0_a29);
    ddp_dm_model_rec.target_group_type := p0_a30;
    ddp_dm_model_rec.darwin_model_ref := p0_a31;
    ddp_dm_model_rec.model_name := p0_a32;
    ddp_dm_model_rec.description := p0_a33;
    ddp_dm_model_rec.best_subtree := rosetta_g_miss_num_map(p0_a34);
    ddp_dm_model_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a35);
    ddp_dm_model_rec.country_id := rosetta_g_miss_num_map(p0_a36);
    ddp_dm_model_rec.wf_itemkey := p0_a37;
    ddp_dm_model_rec.target_id := rosetta_g_miss_num_map(p0_a38);
    ddp_dm_model_rec.attribute_category := p0_a39;
    ddp_dm_model_rec.attribute1 := p0_a40;
    ddp_dm_model_rec.attribute2 := p0_a41;
    ddp_dm_model_rec.attribute3 := p0_a42;
    ddp_dm_model_rec.attribute4 := p0_a43;
    ddp_dm_model_rec.attribute5 := p0_a44;
    ddp_dm_model_rec.attribute6 := p0_a45;
    ddp_dm_model_rec.attribute7 := p0_a46;
    ddp_dm_model_rec.attribute8 := p0_a47;
    ddp_dm_model_rec.attribute9 := p0_a48;
    ddp_dm_model_rec.attribute10 := p0_a49;
    ddp_dm_model_rec.attribute11 := p0_a50;
    ddp_dm_model_rec.attribute12 := p0_a51;
    ddp_dm_model_rec.attribute13 := p0_a52;
    ddp_dm_model_rec.attribute14 := p0_a53;
    ddp_dm_model_rec.attribute15 := p0_a54;



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_model_pvt.check_dm_model_items(ddp_dm_model_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure create_dm_model(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_custom_setup_id OUT NOCOPY  NUMBER
    , x_model_id OUT NOCOPY  NUMBER
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
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_dm_model_rec ams_dm_model_pvt.dm_model_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_dm_model_rec.model_id := rosetta_g_miss_num_map(p7_a0);
    ddp_dm_model_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_dm_model_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_dm_model_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_dm_model_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_dm_model_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_dm_model_rec.org_id := rosetta_g_miss_num_map(p7_a6);
    ddp_dm_model_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_dm_model_rec.model_type := p7_a8;
    ddp_dm_model_rec.user_status_id := rosetta_g_miss_num_map(p7_a9);
    ddp_dm_model_rec.status_code := p7_a10;
    ddp_dm_model_rec.status_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_dm_model_rec.owner_user_id := rosetta_g_miss_num_map(p7_a12);
    ddp_dm_model_rec.last_build_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_dm_model_rec.scheduled_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_dm_model_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p7_a15);
    ddp_dm_model_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_dm_model_rec.results_flag := p7_a17;
    ddp_dm_model_rec.logs_flag := p7_a18;
    ddp_dm_model_rec.target_field := p7_a19;
    ddp_dm_model_rec.target_type := p7_a20;
    ddp_dm_model_rec.target_positive_value := p7_a21;
    ddp_dm_model_rec.total_records := rosetta_g_miss_num_map(p7_a22);
    ddp_dm_model_rec.total_positives := rosetta_g_miss_num_map(p7_a23);
    ddp_dm_model_rec.min_records := rosetta_g_miss_num_map(p7_a24);
    ddp_dm_model_rec.max_records := rosetta_g_miss_num_map(p7_a25);
    ddp_dm_model_rec.row_selection_type := p7_a26;
    ddp_dm_model_rec.every_nth_row := rosetta_g_miss_num_map(p7_a27);
    ddp_dm_model_rec.pct_random := rosetta_g_miss_num_map(p7_a28);
    ddp_dm_model_rec.performance := rosetta_g_miss_num_map(p7_a29);
    ddp_dm_model_rec.target_group_type := p7_a30;
    ddp_dm_model_rec.darwin_model_ref := p7_a31;
    ddp_dm_model_rec.model_name := p7_a32;
    ddp_dm_model_rec.description := p7_a33;
    ddp_dm_model_rec.best_subtree := rosetta_g_miss_num_map(p7_a34);
    ddp_dm_model_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a35);
    ddp_dm_model_rec.country_id := rosetta_g_miss_num_map(p7_a36);
    ddp_dm_model_rec.wf_itemkey := p7_a37;
    ddp_dm_model_rec.target_id := rosetta_g_miss_num_map(p7_a38);
    ddp_dm_model_rec.attribute_category := p7_a39;
    ddp_dm_model_rec.attribute1 := p7_a40;
    ddp_dm_model_rec.attribute2 := p7_a41;
    ddp_dm_model_rec.attribute3 := p7_a42;
    ddp_dm_model_rec.attribute4 := p7_a43;
    ddp_dm_model_rec.attribute5 := p7_a44;
    ddp_dm_model_rec.attribute6 := p7_a45;
    ddp_dm_model_rec.attribute7 := p7_a46;
    ddp_dm_model_rec.attribute8 := p7_a47;
    ddp_dm_model_rec.attribute9 := p7_a48;
    ddp_dm_model_rec.attribute10 := p7_a49;
    ddp_dm_model_rec.attribute11 := p7_a50;
    ddp_dm_model_rec.attribute12 := p7_a51;
    ddp_dm_model_rec.attribute13 := p7_a52;
    ddp_dm_model_rec.attribute14 := p7_a53;
    ddp_dm_model_rec.attribute15 := p7_a54;



    -- here's the delegated call to the old PL/SQL routine
    ams_dm_model_pvt.create_dm_model(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dm_model_rec,
      x_custom_setup_id,
      x_model_id);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_dm_model(p_api_version_number  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_dm_model_rec ams_dm_model_pvt.dm_model_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_dm_model_rec.model_id := rosetta_g_miss_num_map(p7_a0);
    ddp_dm_model_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_dm_model_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_dm_model_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_dm_model_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_dm_model_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_dm_model_rec.org_id := rosetta_g_miss_num_map(p7_a6);
    ddp_dm_model_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_dm_model_rec.model_type := p7_a8;
    ddp_dm_model_rec.user_status_id := rosetta_g_miss_num_map(p7_a9);
    ddp_dm_model_rec.status_code := p7_a10;
    ddp_dm_model_rec.status_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_dm_model_rec.owner_user_id := rosetta_g_miss_num_map(p7_a12);
    ddp_dm_model_rec.last_build_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_dm_model_rec.scheduled_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_dm_model_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p7_a15);
    ddp_dm_model_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_dm_model_rec.results_flag := p7_a17;
    ddp_dm_model_rec.logs_flag := p7_a18;
    ddp_dm_model_rec.target_field := p7_a19;
    ddp_dm_model_rec.target_type := p7_a20;
    ddp_dm_model_rec.target_positive_value := p7_a21;
    ddp_dm_model_rec.total_records := rosetta_g_miss_num_map(p7_a22);
    ddp_dm_model_rec.total_positives := rosetta_g_miss_num_map(p7_a23);
    ddp_dm_model_rec.min_records := rosetta_g_miss_num_map(p7_a24);
    ddp_dm_model_rec.max_records := rosetta_g_miss_num_map(p7_a25);
    ddp_dm_model_rec.row_selection_type := p7_a26;
    ddp_dm_model_rec.every_nth_row := rosetta_g_miss_num_map(p7_a27);
    ddp_dm_model_rec.pct_random := rosetta_g_miss_num_map(p7_a28);
    ddp_dm_model_rec.performance := rosetta_g_miss_num_map(p7_a29);
    ddp_dm_model_rec.target_group_type := p7_a30;
    ddp_dm_model_rec.darwin_model_ref := p7_a31;
    ddp_dm_model_rec.model_name := p7_a32;
    ddp_dm_model_rec.description := p7_a33;
    ddp_dm_model_rec.best_subtree := rosetta_g_miss_num_map(p7_a34);
    ddp_dm_model_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a35);
    ddp_dm_model_rec.country_id := rosetta_g_miss_num_map(p7_a36);
    ddp_dm_model_rec.wf_itemkey := p7_a37;
    ddp_dm_model_rec.target_id := rosetta_g_miss_num_map(p7_a38);
    ddp_dm_model_rec.attribute_category := p7_a39;
    ddp_dm_model_rec.attribute1 := p7_a40;
    ddp_dm_model_rec.attribute2 := p7_a41;
    ddp_dm_model_rec.attribute3 := p7_a42;
    ddp_dm_model_rec.attribute4 := p7_a43;
    ddp_dm_model_rec.attribute5 := p7_a44;
    ddp_dm_model_rec.attribute6 := p7_a45;
    ddp_dm_model_rec.attribute7 := p7_a46;
    ddp_dm_model_rec.attribute8 := p7_a47;
    ddp_dm_model_rec.attribute9 := p7_a48;
    ddp_dm_model_rec.attribute10 := p7_a49;
    ddp_dm_model_rec.attribute11 := p7_a50;
    ddp_dm_model_rec.attribute12 := p7_a51;
    ddp_dm_model_rec.attribute13 := p7_a52;
    ddp_dm_model_rec.attribute14 := p7_a53;
    ddp_dm_model_rec.attribute15 := p7_a54;


    -- here's the delegated call to the old PL/SQL routine
    ams_dm_model_pvt.update_dm_model(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dm_model_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_dm_model_rec(p_api_version_number  NUMBER
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
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  DATE := fnd_api.g_miss_date
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_dm_model_rec ams_dm_model_pvt.dm_model_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_dm_model_rec.model_id := rosetta_g_miss_num_map(p6_a0);
    ddp_dm_model_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_dm_model_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_dm_model_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_dm_model_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_dm_model_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_dm_model_rec.org_id := rosetta_g_miss_num_map(p6_a6);
    ddp_dm_model_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_dm_model_rec.model_type := p6_a8;
    ddp_dm_model_rec.user_status_id := rosetta_g_miss_num_map(p6_a9);
    ddp_dm_model_rec.status_code := p6_a10;
    ddp_dm_model_rec.status_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_dm_model_rec.owner_user_id := rosetta_g_miss_num_map(p6_a12);
    ddp_dm_model_rec.last_build_date := rosetta_g_miss_date_in_map(p6_a13);
    ddp_dm_model_rec.scheduled_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_dm_model_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p6_a15);
    ddp_dm_model_rec.expiration_date := rosetta_g_miss_date_in_map(p6_a16);
    ddp_dm_model_rec.results_flag := p6_a17;
    ddp_dm_model_rec.logs_flag := p6_a18;
    ddp_dm_model_rec.target_field := p6_a19;
    ddp_dm_model_rec.target_type := p6_a20;
    ddp_dm_model_rec.target_positive_value := p6_a21;
    ddp_dm_model_rec.total_records := rosetta_g_miss_num_map(p6_a22);
    ddp_dm_model_rec.total_positives := rosetta_g_miss_num_map(p6_a23);
    ddp_dm_model_rec.min_records := rosetta_g_miss_num_map(p6_a24);
    ddp_dm_model_rec.max_records := rosetta_g_miss_num_map(p6_a25);
    ddp_dm_model_rec.row_selection_type := p6_a26;
    ddp_dm_model_rec.every_nth_row := rosetta_g_miss_num_map(p6_a27);
    ddp_dm_model_rec.pct_random := rosetta_g_miss_num_map(p6_a28);
    ddp_dm_model_rec.performance := rosetta_g_miss_num_map(p6_a29);
    ddp_dm_model_rec.target_group_type := p6_a30;
    ddp_dm_model_rec.darwin_model_ref := p6_a31;
    ddp_dm_model_rec.model_name := p6_a32;
    ddp_dm_model_rec.description := p6_a33;
    ddp_dm_model_rec.best_subtree := rosetta_g_miss_num_map(p6_a34);
    ddp_dm_model_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a35);
    ddp_dm_model_rec.country_id := rosetta_g_miss_num_map(p6_a36);
    ddp_dm_model_rec.wf_itemkey := p6_a37;
    ddp_dm_model_rec.target_id := rosetta_g_miss_num_map(p6_a38);
    ddp_dm_model_rec.attribute_category := p6_a39;
    ddp_dm_model_rec.attribute1 := p6_a40;
    ddp_dm_model_rec.attribute2 := p6_a41;
    ddp_dm_model_rec.attribute3 := p6_a42;
    ddp_dm_model_rec.attribute4 := p6_a43;
    ddp_dm_model_rec.attribute5 := p6_a44;
    ddp_dm_model_rec.attribute6 := p6_a45;
    ddp_dm_model_rec.attribute7 := p6_a46;
    ddp_dm_model_rec.attribute8 := p6_a47;
    ddp_dm_model_rec.attribute9 := p6_a48;
    ddp_dm_model_rec.attribute10 := p6_a49;
    ddp_dm_model_rec.attribute11 := p6_a50;
    ddp_dm_model_rec.attribute12 := p6_a51;
    ddp_dm_model_rec.attribute13 := p6_a52;
    ddp_dm_model_rec.attribute14 := p6_a53;
    ddp_dm_model_rec.attribute15 := p6_a54;

    -- here's the delegated call to the old PL/SQL routine
    ams_dm_model_pvt.validate_dm_model_rec(p_api_version_number,
      p_init_msg_list,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dm_model_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure validate_dm_model(p_api_version_number  NUMBER
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
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  DATE := fnd_api.g_miss_date
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  DATE := fnd_api.g_miss_date
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_dm_model_rec ams_dm_model_pvt.dm_model_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_dm_model_rec.model_id := rosetta_g_miss_num_map(p4_a0);
    ddp_dm_model_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_dm_model_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_dm_model_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_dm_model_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_dm_model_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_dm_model_rec.org_id := rosetta_g_miss_num_map(p4_a6);
    ddp_dm_model_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_dm_model_rec.model_type := p4_a8;
    ddp_dm_model_rec.user_status_id := rosetta_g_miss_num_map(p4_a9);
    ddp_dm_model_rec.status_code := p4_a10;
    ddp_dm_model_rec.status_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_dm_model_rec.owner_user_id := rosetta_g_miss_num_map(p4_a12);
    ddp_dm_model_rec.last_build_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_dm_model_rec.scheduled_date := rosetta_g_miss_date_in_map(p4_a14);
    ddp_dm_model_rec.scheduled_timezone_id := rosetta_g_miss_num_map(p4_a15);
    ddp_dm_model_rec.expiration_date := rosetta_g_miss_date_in_map(p4_a16);
    ddp_dm_model_rec.results_flag := p4_a17;
    ddp_dm_model_rec.logs_flag := p4_a18;
    ddp_dm_model_rec.target_field := p4_a19;
    ddp_dm_model_rec.target_type := p4_a20;
    ddp_dm_model_rec.target_positive_value := p4_a21;
    ddp_dm_model_rec.total_records := rosetta_g_miss_num_map(p4_a22);
    ddp_dm_model_rec.total_positives := rosetta_g_miss_num_map(p4_a23);
    ddp_dm_model_rec.min_records := rosetta_g_miss_num_map(p4_a24);
    ddp_dm_model_rec.max_records := rosetta_g_miss_num_map(p4_a25);
    ddp_dm_model_rec.row_selection_type := p4_a26;
    ddp_dm_model_rec.every_nth_row := rosetta_g_miss_num_map(p4_a27);
    ddp_dm_model_rec.pct_random := rosetta_g_miss_num_map(p4_a28);
    ddp_dm_model_rec.performance := rosetta_g_miss_num_map(p4_a29);
    ddp_dm_model_rec.target_group_type := p4_a30;
    ddp_dm_model_rec.darwin_model_ref := p4_a31;
    ddp_dm_model_rec.model_name := p4_a32;
    ddp_dm_model_rec.description := p4_a33;
    ddp_dm_model_rec.best_subtree := rosetta_g_miss_num_map(p4_a34);
    ddp_dm_model_rec.custom_setup_id := rosetta_g_miss_num_map(p4_a35);
    ddp_dm_model_rec.country_id := rosetta_g_miss_num_map(p4_a36);
    ddp_dm_model_rec.wf_itemkey := p4_a37;
    ddp_dm_model_rec.target_id := rosetta_g_miss_num_map(p4_a38);
    ddp_dm_model_rec.attribute_category := p4_a39;
    ddp_dm_model_rec.attribute1 := p4_a40;
    ddp_dm_model_rec.attribute2 := p4_a41;
    ddp_dm_model_rec.attribute3 := p4_a42;
    ddp_dm_model_rec.attribute4 := p4_a43;
    ddp_dm_model_rec.attribute5 := p4_a44;
    ddp_dm_model_rec.attribute6 := p4_a45;
    ddp_dm_model_rec.attribute7 := p4_a46;
    ddp_dm_model_rec.attribute8 := p4_a47;
    ddp_dm_model_rec.attribute9 := p4_a48;
    ddp_dm_model_rec.attribute10 := p4_a49;
    ddp_dm_model_rec.attribute11 := p4_a50;
    ddp_dm_model_rec.attribute12 := p4_a51;
    ddp_dm_model_rec.attribute13 := p4_a52;
    ddp_dm_model_rec.attribute14 := p4_a53;
    ddp_dm_model_rec.attribute15 := p4_a54;




    -- here's the delegated call to the old PL/SQL routine
    ams_dm_model_pvt.validate_dm_model(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_dm_model_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure copy_model(p_api_version  NUMBER
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
    ams_dm_model_pvt.copy_model(p_api_version,
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

end ams_dm_model_pvt_w;

/
