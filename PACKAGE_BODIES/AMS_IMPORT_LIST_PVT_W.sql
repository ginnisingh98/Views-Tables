--------------------------------------------------------
--  DDL for Package Body AMS_IMPORT_LIST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORT_LIST_PVT_W" as
  /* $Header: amswimpb.pls 120.1 2006/01/02 01:28 rmbhanda noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_import_list_pvt.ams_import_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_4000
    , a29 JTF_VARCHAR2_TABLE_4000
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_1000
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
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
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_1000
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).import_list_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).view_application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).name := a8(indx);
          t(ddindx).version := a9(indx);
          t(ddindx).import_type := a10(indx);
          t(ddindx).owner_user_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).list_source_type_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).status_code := a13(indx);
          t(ddindx).status_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).user_status_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).source_system := a16(indx);
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).pin_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).scheduled_time := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).loaded_no_of_rows := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).loaded_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).rows_to_skip := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).processed_rows := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).headings_flag := a25(indx);
          t(ddindx).expiry_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).purge_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).description := a28(indx);
          t(ddindx).keywords := a29(indx);
          t(ddindx).transactional_cost := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).transactional_currency_code := a31(indx);
          t(ddindx).functional_cost := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).functional_currency_code := a33(indx);
          t(ddindx).terminated_by := a34(indx);
          t(ddindx).enclosed_by := a35(indx);
          t(ddindx).data_filename := a36(indx);
          t(ddindx).process_immed_flag := a37(indx);
          t(ddindx).dedupe_flag := a38(indx);
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
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).country := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).usage := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).number_of_records := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).data_file_name := a59(indx);
          t(ddindx).b2b_flag := a60(indx);
          t(ddindx).rented_list_flag := a61(indx);
          t(ddindx).server_flag := a62(indx);
          t(ddindx).log_file_name := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).number_of_failed_records := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).number_of_duplicate_records := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).enable_word_replacement_flag := a66(indx);
          t(ddindx).validate_file := a67(indx);
          t(ddindx).server_name := a68(indx);
          t(ddindx).user_name := a69(indx);
          t(ddindx).password := a70(indx);
          t(ddindx).upload_flag := a71(indx);
          t(ddindx).parent_imp_header_id := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).record_update_flag := a73(indx);
          t(ddindx).error_threshold := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).charset := a75(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_import_list_pvt.ams_import_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_1000
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_1000
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_VARCHAR2_TABLE_4000();
    a29 := JTF_VARCHAR2_TABLE_4000();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_1000();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
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
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_1000();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_VARCHAR2_TABLE_4000();
      a29 := JTF_VARCHAR2_TABLE_4000();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_1000();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
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
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_1000();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
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
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).import_list_header_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).view_application_id);
          a8(indx) := t(ddindx).name;
          a9(indx) := t(ddindx).version;
          a10(indx) := t(ddindx).import_type;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).owner_user_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).list_source_type_id);
          a13(indx) := t(ddindx).status_code;
          a14(indx) := t(ddindx).status_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).user_status_id);
          a16(indx) := t(ddindx).source_system;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).pin_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a20(indx) := t(ddindx).scheduled_time;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).loaded_no_of_rows);
          a22(indx) := t(ddindx).loaded_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).rows_to_skip);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).processed_rows);
          a25(indx) := t(ddindx).headings_flag;
          a26(indx) := t(ddindx).expiry_date;
          a27(indx) := t(ddindx).purge_date;
          a28(indx) := t(ddindx).description;
          a29(indx) := t(ddindx).keywords;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).transactional_cost);
          a31(indx) := t(ddindx).transactional_currency_code;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).functional_cost);
          a33(indx) := t(ddindx).functional_currency_code;
          a34(indx) := t(ddindx).terminated_by;
          a35(indx) := t(ddindx).enclosed_by;
          a36(indx) := t(ddindx).data_filename;
          a37(indx) := t(ddindx).process_immed_flag;
          a38(indx) := t(ddindx).dedupe_flag;
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
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).country);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).usage);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_records);
          a59(indx) := t(ddindx).data_file_name;
          a60(indx) := t(ddindx).b2b_flag;
          a61(indx) := t(ddindx).rented_list_flag;
          a62(indx) := t(ddindx).server_flag;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).log_file_name);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_failed_records);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_duplicate_records);
          a66(indx) := t(ddindx).enable_word_replacement_flag;
          a67(indx) := t(ddindx).validate_file;
          a68(indx) := t(ddindx).server_name;
          a69(indx) := t(ddindx).user_name;
          a70(indx) := t(ddindx).password;
          a71(indx) := t(ddindx).upload_flag;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).parent_imp_header_id);
          a73(indx) := t(ddindx).record_update_flag;
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).error_threshold);
          a75(indx) := t(ddindx).charset;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure duplicate_import_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  DATE
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  DATE
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  DATE
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  NUMBER
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  NUMBER
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  NUMBER
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  NUMBER
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  NUMBER
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  NUMBER
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  VARCHAR2
    , p8_a68 out nocopy  VARCHAR2
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  VARCHAR2
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  VARCHAR2
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , x_file_type out nocopy  VARCHAR2
  )

  as
    ddx_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.duplicate_import_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_import_list_header_id,
      ddx_ams_import_rec,
      x_file_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_ams_import_rec.import_list_header_id);
    p8_a1 := ddx_ams_import_rec.last_update_date;
    p8_a2 := rosetta_g_miss_num_map(ddx_ams_import_rec.last_updated_by);
    p8_a3 := ddx_ams_import_rec.creation_date;
    p8_a4 := rosetta_g_miss_num_map(ddx_ams_import_rec.created_by);
    p8_a5 := rosetta_g_miss_num_map(ddx_ams_import_rec.last_update_login);
    p8_a6 := rosetta_g_miss_num_map(ddx_ams_import_rec.object_version_number);
    p8_a7 := rosetta_g_miss_num_map(ddx_ams_import_rec.view_application_id);
    p8_a8 := ddx_ams_import_rec.name;
    p8_a9 := ddx_ams_import_rec.version;
    p8_a10 := ddx_ams_import_rec.import_type;
    p8_a11 := rosetta_g_miss_num_map(ddx_ams_import_rec.owner_user_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_ams_import_rec.list_source_type_id);
    p8_a13 := ddx_ams_import_rec.status_code;
    p8_a14 := ddx_ams_import_rec.status_date;
    p8_a15 := rosetta_g_miss_num_map(ddx_ams_import_rec.user_status_id);
    p8_a16 := ddx_ams_import_rec.source_system;
    p8_a17 := rosetta_g_miss_num_map(ddx_ams_import_rec.vendor_id);
    p8_a18 := rosetta_g_miss_num_map(ddx_ams_import_rec.pin_id);
    p8_a19 := rosetta_g_miss_num_map(ddx_ams_import_rec.org_id);
    p8_a20 := ddx_ams_import_rec.scheduled_time;
    p8_a21 := rosetta_g_miss_num_map(ddx_ams_import_rec.loaded_no_of_rows);
    p8_a22 := ddx_ams_import_rec.loaded_date;
    p8_a23 := rosetta_g_miss_num_map(ddx_ams_import_rec.rows_to_skip);
    p8_a24 := rosetta_g_miss_num_map(ddx_ams_import_rec.processed_rows);
    p8_a25 := ddx_ams_import_rec.headings_flag;
    p8_a26 := ddx_ams_import_rec.expiry_date;
    p8_a27 := ddx_ams_import_rec.purge_date;
    p8_a28 := ddx_ams_import_rec.description;
    p8_a29 := ddx_ams_import_rec.keywords;
    p8_a30 := rosetta_g_miss_num_map(ddx_ams_import_rec.transactional_cost);
    p8_a31 := ddx_ams_import_rec.transactional_currency_code;
    p8_a32 := rosetta_g_miss_num_map(ddx_ams_import_rec.functional_cost);
    p8_a33 := ddx_ams_import_rec.functional_currency_code;
    p8_a34 := ddx_ams_import_rec.terminated_by;
    p8_a35 := ddx_ams_import_rec.enclosed_by;
    p8_a36 := ddx_ams_import_rec.data_filename;
    p8_a37 := ddx_ams_import_rec.process_immed_flag;
    p8_a38 := ddx_ams_import_rec.dedupe_flag;
    p8_a39 := ddx_ams_import_rec.attribute_category;
    p8_a40 := ddx_ams_import_rec.attribute1;
    p8_a41 := ddx_ams_import_rec.attribute2;
    p8_a42 := ddx_ams_import_rec.attribute3;
    p8_a43 := ddx_ams_import_rec.attribute4;
    p8_a44 := ddx_ams_import_rec.attribute5;
    p8_a45 := ddx_ams_import_rec.attribute6;
    p8_a46 := ddx_ams_import_rec.attribute7;
    p8_a47 := ddx_ams_import_rec.attribute8;
    p8_a48 := ddx_ams_import_rec.attribute9;
    p8_a49 := ddx_ams_import_rec.attribute10;
    p8_a50 := ddx_ams_import_rec.attribute11;
    p8_a51 := ddx_ams_import_rec.attribute12;
    p8_a52 := ddx_ams_import_rec.attribute13;
    p8_a53 := ddx_ams_import_rec.attribute14;
    p8_a54 := ddx_ams_import_rec.attribute15;
    p8_a55 := rosetta_g_miss_num_map(ddx_ams_import_rec.custom_setup_id);
    p8_a56 := rosetta_g_miss_num_map(ddx_ams_import_rec.country);
    p8_a57 := rosetta_g_miss_num_map(ddx_ams_import_rec.usage);
    p8_a58 := rosetta_g_miss_num_map(ddx_ams_import_rec.number_of_records);
    p8_a59 := ddx_ams_import_rec.data_file_name;
    p8_a60 := ddx_ams_import_rec.b2b_flag;
    p8_a61 := ddx_ams_import_rec.rented_list_flag;
    p8_a62 := ddx_ams_import_rec.server_flag;
    p8_a63 := rosetta_g_miss_num_map(ddx_ams_import_rec.log_file_name);
    p8_a64 := rosetta_g_miss_num_map(ddx_ams_import_rec.number_of_failed_records);
    p8_a65 := rosetta_g_miss_num_map(ddx_ams_import_rec.number_of_duplicate_records);
    p8_a66 := ddx_ams_import_rec.enable_word_replacement_flag;
    p8_a67 := ddx_ams_import_rec.validate_file;
    p8_a68 := ddx_ams_import_rec.server_name;
    p8_a69 := ddx_ams_import_rec.user_name;
    p8_a70 := ddx_ams_import_rec.password;
    p8_a71 := ddx_ams_import_rec.upload_flag;
    p8_a72 := rosetta_g_miss_num_map(ddx_ams_import_rec.parent_imp_header_id);
    p8_a73 := ddx_ams_import_rec.record_update_flag;
    p8_a74 := rosetta_g_miss_num_map(ddx_ams_import_rec.error_threshold);
    p8_a75 := ddx_ams_import_rec.charset;

  end;

  procedure create_import_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_import_list_header_id out nocopy  NUMBER
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
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
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
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  NUMBER := 0-1962.0724
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  NUMBER := 0-1962.0724
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_import_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_import_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ams_import_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ams_import_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ams_import_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_ams_import_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_ams_import_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_ams_import_rec.view_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ams_import_rec.name := p7_a8;
    ddp_ams_import_rec.version := p7_a9;
    ddp_ams_import_rec.import_type := p7_a10;
    ddp_ams_import_rec.owner_user_id := rosetta_g_miss_num_map(p7_a11);
    ddp_ams_import_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a12);
    ddp_ams_import_rec.status_code := p7_a13;
    ddp_ams_import_rec.status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_ams_import_rec.user_status_id := rosetta_g_miss_num_map(p7_a15);
    ddp_ams_import_rec.source_system := p7_a16;
    ddp_ams_import_rec.vendor_id := rosetta_g_miss_num_map(p7_a17);
    ddp_ams_import_rec.pin_id := rosetta_g_miss_num_map(p7_a18);
    ddp_ams_import_rec.org_id := rosetta_g_miss_num_map(p7_a19);
    ddp_ams_import_rec.scheduled_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_ams_import_rec.loaded_no_of_rows := rosetta_g_miss_num_map(p7_a21);
    ddp_ams_import_rec.loaded_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_ams_import_rec.rows_to_skip := rosetta_g_miss_num_map(p7_a23);
    ddp_ams_import_rec.processed_rows := rosetta_g_miss_num_map(p7_a24);
    ddp_ams_import_rec.headings_flag := p7_a25;
    ddp_ams_import_rec.expiry_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_ams_import_rec.purge_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_ams_import_rec.description := p7_a28;
    ddp_ams_import_rec.keywords := p7_a29;
    ddp_ams_import_rec.transactional_cost := rosetta_g_miss_num_map(p7_a30);
    ddp_ams_import_rec.transactional_currency_code := p7_a31;
    ddp_ams_import_rec.functional_cost := rosetta_g_miss_num_map(p7_a32);
    ddp_ams_import_rec.functional_currency_code := p7_a33;
    ddp_ams_import_rec.terminated_by := p7_a34;
    ddp_ams_import_rec.enclosed_by := p7_a35;
    ddp_ams_import_rec.data_filename := p7_a36;
    ddp_ams_import_rec.process_immed_flag := p7_a37;
    ddp_ams_import_rec.dedupe_flag := p7_a38;
    ddp_ams_import_rec.attribute_category := p7_a39;
    ddp_ams_import_rec.attribute1 := p7_a40;
    ddp_ams_import_rec.attribute2 := p7_a41;
    ddp_ams_import_rec.attribute3 := p7_a42;
    ddp_ams_import_rec.attribute4 := p7_a43;
    ddp_ams_import_rec.attribute5 := p7_a44;
    ddp_ams_import_rec.attribute6 := p7_a45;
    ddp_ams_import_rec.attribute7 := p7_a46;
    ddp_ams_import_rec.attribute8 := p7_a47;
    ddp_ams_import_rec.attribute9 := p7_a48;
    ddp_ams_import_rec.attribute10 := p7_a49;
    ddp_ams_import_rec.attribute11 := p7_a50;
    ddp_ams_import_rec.attribute12 := p7_a51;
    ddp_ams_import_rec.attribute13 := p7_a52;
    ddp_ams_import_rec.attribute14 := p7_a53;
    ddp_ams_import_rec.attribute15 := p7_a54;
    ddp_ams_import_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a55);
    ddp_ams_import_rec.country := rosetta_g_miss_num_map(p7_a56);
    ddp_ams_import_rec.usage := rosetta_g_miss_num_map(p7_a57);
    ddp_ams_import_rec.number_of_records := rosetta_g_miss_num_map(p7_a58);
    ddp_ams_import_rec.data_file_name := p7_a59;
    ddp_ams_import_rec.b2b_flag := p7_a60;
    ddp_ams_import_rec.rented_list_flag := p7_a61;
    ddp_ams_import_rec.server_flag := p7_a62;
    ddp_ams_import_rec.log_file_name := rosetta_g_miss_num_map(p7_a63);
    ddp_ams_import_rec.number_of_failed_records := rosetta_g_miss_num_map(p7_a64);
    ddp_ams_import_rec.number_of_duplicate_records := rosetta_g_miss_num_map(p7_a65);
    ddp_ams_import_rec.enable_word_replacement_flag := p7_a66;
    ddp_ams_import_rec.validate_file := p7_a67;
    ddp_ams_import_rec.server_name := p7_a68;
    ddp_ams_import_rec.user_name := p7_a69;
    ddp_ams_import_rec.password := p7_a70;
    ddp_ams_import_rec.upload_flag := p7_a71;
    ddp_ams_import_rec.parent_imp_header_id := rosetta_g_miss_num_map(p7_a72);
    ddp_ams_import_rec.record_update_flag := p7_a73;
    ddp_ams_import_rec.error_threshold := rosetta_g_miss_num_map(p7_a74);
    ddp_ams_import_rec.charset := p7_a75;


    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.create_import_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_import_rec,
      x_import_list_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_import_list(p_api_version_number  NUMBER
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
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
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
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  NUMBER := 0-1962.0724
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  NUMBER := 0-1962.0724
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_import_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_import_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ams_import_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ams_import_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ams_import_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_ams_import_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_ams_import_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_ams_import_rec.view_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ams_import_rec.name := p7_a8;
    ddp_ams_import_rec.version := p7_a9;
    ddp_ams_import_rec.import_type := p7_a10;
    ddp_ams_import_rec.owner_user_id := rosetta_g_miss_num_map(p7_a11);
    ddp_ams_import_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a12);
    ddp_ams_import_rec.status_code := p7_a13;
    ddp_ams_import_rec.status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_ams_import_rec.user_status_id := rosetta_g_miss_num_map(p7_a15);
    ddp_ams_import_rec.source_system := p7_a16;
    ddp_ams_import_rec.vendor_id := rosetta_g_miss_num_map(p7_a17);
    ddp_ams_import_rec.pin_id := rosetta_g_miss_num_map(p7_a18);
    ddp_ams_import_rec.org_id := rosetta_g_miss_num_map(p7_a19);
    ddp_ams_import_rec.scheduled_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_ams_import_rec.loaded_no_of_rows := rosetta_g_miss_num_map(p7_a21);
    ddp_ams_import_rec.loaded_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_ams_import_rec.rows_to_skip := rosetta_g_miss_num_map(p7_a23);
    ddp_ams_import_rec.processed_rows := rosetta_g_miss_num_map(p7_a24);
    ddp_ams_import_rec.headings_flag := p7_a25;
    ddp_ams_import_rec.expiry_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_ams_import_rec.purge_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_ams_import_rec.description := p7_a28;
    ddp_ams_import_rec.keywords := p7_a29;
    ddp_ams_import_rec.transactional_cost := rosetta_g_miss_num_map(p7_a30);
    ddp_ams_import_rec.transactional_currency_code := p7_a31;
    ddp_ams_import_rec.functional_cost := rosetta_g_miss_num_map(p7_a32);
    ddp_ams_import_rec.functional_currency_code := p7_a33;
    ddp_ams_import_rec.terminated_by := p7_a34;
    ddp_ams_import_rec.enclosed_by := p7_a35;
    ddp_ams_import_rec.data_filename := p7_a36;
    ddp_ams_import_rec.process_immed_flag := p7_a37;
    ddp_ams_import_rec.dedupe_flag := p7_a38;
    ddp_ams_import_rec.attribute_category := p7_a39;
    ddp_ams_import_rec.attribute1 := p7_a40;
    ddp_ams_import_rec.attribute2 := p7_a41;
    ddp_ams_import_rec.attribute3 := p7_a42;
    ddp_ams_import_rec.attribute4 := p7_a43;
    ddp_ams_import_rec.attribute5 := p7_a44;
    ddp_ams_import_rec.attribute6 := p7_a45;
    ddp_ams_import_rec.attribute7 := p7_a46;
    ddp_ams_import_rec.attribute8 := p7_a47;
    ddp_ams_import_rec.attribute9 := p7_a48;
    ddp_ams_import_rec.attribute10 := p7_a49;
    ddp_ams_import_rec.attribute11 := p7_a50;
    ddp_ams_import_rec.attribute12 := p7_a51;
    ddp_ams_import_rec.attribute13 := p7_a52;
    ddp_ams_import_rec.attribute14 := p7_a53;
    ddp_ams_import_rec.attribute15 := p7_a54;
    ddp_ams_import_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a55);
    ddp_ams_import_rec.country := rosetta_g_miss_num_map(p7_a56);
    ddp_ams_import_rec.usage := rosetta_g_miss_num_map(p7_a57);
    ddp_ams_import_rec.number_of_records := rosetta_g_miss_num_map(p7_a58);
    ddp_ams_import_rec.data_file_name := p7_a59;
    ddp_ams_import_rec.b2b_flag := p7_a60;
    ddp_ams_import_rec.rented_list_flag := p7_a61;
    ddp_ams_import_rec.server_flag := p7_a62;
    ddp_ams_import_rec.log_file_name := rosetta_g_miss_num_map(p7_a63);
    ddp_ams_import_rec.number_of_failed_records := rosetta_g_miss_num_map(p7_a64);
    ddp_ams_import_rec.number_of_duplicate_records := rosetta_g_miss_num_map(p7_a65);
    ddp_ams_import_rec.enable_word_replacement_flag := p7_a66;
    ddp_ams_import_rec.validate_file := p7_a67;
    ddp_ams_import_rec.server_name := p7_a68;
    ddp_ams_import_rec.user_name := p7_a69;
    ddp_ams_import_rec.password := p7_a70;
    ddp_ams_import_rec.upload_flag := p7_a71;
    ddp_ams_import_rec.parent_imp_header_id := rosetta_g_miss_num_map(p7_a72);
    ddp_ams_import_rec.record_update_flag := p7_a73;
    ddp_ams_import_rec.error_threshold := rosetta_g_miss_num_map(p7_a74);
    ddp_ams_import_rec.charset := p7_a75;


    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.update_import_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_import_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_import_list(p_api_version_number  NUMBER
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
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  DATE := fnd_api.g_miss_date
    , p3_a21  NUMBER := 0-1962.0724
    , p3_a22  DATE := fnd_api.g_miss_date
    , p3_a23  NUMBER := 0-1962.0724
    , p3_a24  NUMBER := 0-1962.0724
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  DATE := fnd_api.g_miss_date
    , p3_a27  DATE := fnd_api.g_miss_date
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  NUMBER := 0-1962.0724
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  NUMBER := 0-1962.0724
    , p3_a33  VARCHAR2 := fnd_api.g_miss_char
    , p3_a34  VARCHAR2 := fnd_api.g_miss_char
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  VARCHAR2 := fnd_api.g_miss_char
    , p3_a37  VARCHAR2 := fnd_api.g_miss_char
    , p3_a38  VARCHAR2 := fnd_api.g_miss_char
    , p3_a39  VARCHAR2 := fnd_api.g_miss_char
    , p3_a40  VARCHAR2 := fnd_api.g_miss_char
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
    , p3_a42  VARCHAR2 := fnd_api.g_miss_char
    , p3_a43  VARCHAR2 := fnd_api.g_miss_char
    , p3_a44  VARCHAR2 := fnd_api.g_miss_char
    , p3_a45  VARCHAR2 := fnd_api.g_miss_char
    , p3_a46  VARCHAR2 := fnd_api.g_miss_char
    , p3_a47  VARCHAR2 := fnd_api.g_miss_char
    , p3_a48  VARCHAR2 := fnd_api.g_miss_char
    , p3_a49  VARCHAR2 := fnd_api.g_miss_char
    , p3_a50  VARCHAR2 := fnd_api.g_miss_char
    , p3_a51  VARCHAR2 := fnd_api.g_miss_char
    , p3_a52  VARCHAR2 := fnd_api.g_miss_char
    , p3_a53  VARCHAR2 := fnd_api.g_miss_char
    , p3_a54  VARCHAR2 := fnd_api.g_miss_char
    , p3_a55  NUMBER := 0-1962.0724
    , p3_a56  NUMBER := 0-1962.0724
    , p3_a57  NUMBER := 0-1962.0724
    , p3_a58  NUMBER := 0-1962.0724
    , p3_a59  VARCHAR2 := fnd_api.g_miss_char
    , p3_a60  VARCHAR2 := fnd_api.g_miss_char
    , p3_a61  VARCHAR2 := fnd_api.g_miss_char
    , p3_a62  VARCHAR2 := fnd_api.g_miss_char
    , p3_a63  NUMBER := 0-1962.0724
    , p3_a64  NUMBER := 0-1962.0724
    , p3_a65  NUMBER := 0-1962.0724
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  VARCHAR2 := fnd_api.g_miss_char
    , p3_a68  VARCHAR2 := fnd_api.g_miss_char
    , p3_a69  VARCHAR2 := fnd_api.g_miss_char
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
    , p3_a71  VARCHAR2 := fnd_api.g_miss_char
    , p3_a72  NUMBER := 0-1962.0724
    , p3_a73  VARCHAR2 := fnd_api.g_miss_char
    , p3_a74  NUMBER := 0-1962.0724
    , p3_a75  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ams_import_rec.import_list_header_id := rosetta_g_miss_num_map(p3_a0);
    ddp_ams_import_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_ams_import_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_ams_import_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_ams_import_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_ams_import_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_ams_import_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_ams_import_rec.view_application_id := rosetta_g_miss_num_map(p3_a7);
    ddp_ams_import_rec.name := p3_a8;
    ddp_ams_import_rec.version := p3_a9;
    ddp_ams_import_rec.import_type := p3_a10;
    ddp_ams_import_rec.owner_user_id := rosetta_g_miss_num_map(p3_a11);
    ddp_ams_import_rec.list_source_type_id := rosetta_g_miss_num_map(p3_a12);
    ddp_ams_import_rec.status_code := p3_a13;
    ddp_ams_import_rec.status_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_ams_import_rec.user_status_id := rosetta_g_miss_num_map(p3_a15);
    ddp_ams_import_rec.source_system := p3_a16;
    ddp_ams_import_rec.vendor_id := rosetta_g_miss_num_map(p3_a17);
    ddp_ams_import_rec.pin_id := rosetta_g_miss_num_map(p3_a18);
    ddp_ams_import_rec.org_id := rosetta_g_miss_num_map(p3_a19);
    ddp_ams_import_rec.scheduled_time := rosetta_g_miss_date_in_map(p3_a20);
    ddp_ams_import_rec.loaded_no_of_rows := rosetta_g_miss_num_map(p3_a21);
    ddp_ams_import_rec.loaded_date := rosetta_g_miss_date_in_map(p3_a22);
    ddp_ams_import_rec.rows_to_skip := rosetta_g_miss_num_map(p3_a23);
    ddp_ams_import_rec.processed_rows := rosetta_g_miss_num_map(p3_a24);
    ddp_ams_import_rec.headings_flag := p3_a25;
    ddp_ams_import_rec.expiry_date := rosetta_g_miss_date_in_map(p3_a26);
    ddp_ams_import_rec.purge_date := rosetta_g_miss_date_in_map(p3_a27);
    ddp_ams_import_rec.description := p3_a28;
    ddp_ams_import_rec.keywords := p3_a29;
    ddp_ams_import_rec.transactional_cost := rosetta_g_miss_num_map(p3_a30);
    ddp_ams_import_rec.transactional_currency_code := p3_a31;
    ddp_ams_import_rec.functional_cost := rosetta_g_miss_num_map(p3_a32);
    ddp_ams_import_rec.functional_currency_code := p3_a33;
    ddp_ams_import_rec.terminated_by := p3_a34;
    ddp_ams_import_rec.enclosed_by := p3_a35;
    ddp_ams_import_rec.data_filename := p3_a36;
    ddp_ams_import_rec.process_immed_flag := p3_a37;
    ddp_ams_import_rec.dedupe_flag := p3_a38;
    ddp_ams_import_rec.attribute_category := p3_a39;
    ddp_ams_import_rec.attribute1 := p3_a40;
    ddp_ams_import_rec.attribute2 := p3_a41;
    ddp_ams_import_rec.attribute3 := p3_a42;
    ddp_ams_import_rec.attribute4 := p3_a43;
    ddp_ams_import_rec.attribute5 := p3_a44;
    ddp_ams_import_rec.attribute6 := p3_a45;
    ddp_ams_import_rec.attribute7 := p3_a46;
    ddp_ams_import_rec.attribute8 := p3_a47;
    ddp_ams_import_rec.attribute9 := p3_a48;
    ddp_ams_import_rec.attribute10 := p3_a49;
    ddp_ams_import_rec.attribute11 := p3_a50;
    ddp_ams_import_rec.attribute12 := p3_a51;
    ddp_ams_import_rec.attribute13 := p3_a52;
    ddp_ams_import_rec.attribute14 := p3_a53;
    ddp_ams_import_rec.attribute15 := p3_a54;
    ddp_ams_import_rec.custom_setup_id := rosetta_g_miss_num_map(p3_a55);
    ddp_ams_import_rec.country := rosetta_g_miss_num_map(p3_a56);
    ddp_ams_import_rec.usage := rosetta_g_miss_num_map(p3_a57);
    ddp_ams_import_rec.number_of_records := rosetta_g_miss_num_map(p3_a58);
    ddp_ams_import_rec.data_file_name := p3_a59;
    ddp_ams_import_rec.b2b_flag := p3_a60;
    ddp_ams_import_rec.rented_list_flag := p3_a61;
    ddp_ams_import_rec.server_flag := p3_a62;
    ddp_ams_import_rec.log_file_name := rosetta_g_miss_num_map(p3_a63);
    ddp_ams_import_rec.number_of_failed_records := rosetta_g_miss_num_map(p3_a64);
    ddp_ams_import_rec.number_of_duplicate_records := rosetta_g_miss_num_map(p3_a65);
    ddp_ams_import_rec.enable_word_replacement_flag := p3_a66;
    ddp_ams_import_rec.validate_file := p3_a67;
    ddp_ams_import_rec.server_name := p3_a68;
    ddp_ams_import_rec.user_name := p3_a69;
    ddp_ams_import_rec.password := p3_a70;
    ddp_ams_import_rec.upload_flag := p3_a71;
    ddp_ams_import_rec.parent_imp_header_id := rosetta_g_miss_num_map(p3_a72);
    ddp_ams_import_rec.record_update_flag := p3_a73;
    ddp_ams_import_rec.error_threshold := rosetta_g_miss_num_map(p3_a74);
    ddp_ams_import_rec.charset := p3_a75;




    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.validate_import_list(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ams_import_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_ams_import_items(p_validation_mode  VARCHAR2
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
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  DATE := fnd_api.g_miss_date
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
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
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  NUMBER := 0-1962.0724
    , p0_a56  NUMBER := 0-1962.0724
    , p0_a57  NUMBER := 0-1962.0724
    , p0_a58  NUMBER := 0-1962.0724
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  NUMBER := 0-1962.0724
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  NUMBER := 0-1962.0724
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  NUMBER := 0-1962.0724
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  NUMBER := 0-1962.0724
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ams_import_rec.import_list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_ams_import_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_ams_import_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_ams_import_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_ams_import_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_ams_import_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_ams_import_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_ams_import_rec.view_application_id := rosetta_g_miss_num_map(p0_a7);
    ddp_ams_import_rec.name := p0_a8;
    ddp_ams_import_rec.version := p0_a9;
    ddp_ams_import_rec.import_type := p0_a10;
    ddp_ams_import_rec.owner_user_id := rosetta_g_miss_num_map(p0_a11);
    ddp_ams_import_rec.list_source_type_id := rosetta_g_miss_num_map(p0_a12);
    ddp_ams_import_rec.status_code := p0_a13;
    ddp_ams_import_rec.status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_ams_import_rec.user_status_id := rosetta_g_miss_num_map(p0_a15);
    ddp_ams_import_rec.source_system := p0_a16;
    ddp_ams_import_rec.vendor_id := rosetta_g_miss_num_map(p0_a17);
    ddp_ams_import_rec.pin_id := rosetta_g_miss_num_map(p0_a18);
    ddp_ams_import_rec.org_id := rosetta_g_miss_num_map(p0_a19);
    ddp_ams_import_rec.scheduled_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_ams_import_rec.loaded_no_of_rows := rosetta_g_miss_num_map(p0_a21);
    ddp_ams_import_rec.loaded_date := rosetta_g_miss_date_in_map(p0_a22);
    ddp_ams_import_rec.rows_to_skip := rosetta_g_miss_num_map(p0_a23);
    ddp_ams_import_rec.processed_rows := rosetta_g_miss_num_map(p0_a24);
    ddp_ams_import_rec.headings_flag := p0_a25;
    ddp_ams_import_rec.expiry_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_ams_import_rec.purge_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_ams_import_rec.description := p0_a28;
    ddp_ams_import_rec.keywords := p0_a29;
    ddp_ams_import_rec.transactional_cost := rosetta_g_miss_num_map(p0_a30);
    ddp_ams_import_rec.transactional_currency_code := p0_a31;
    ddp_ams_import_rec.functional_cost := rosetta_g_miss_num_map(p0_a32);
    ddp_ams_import_rec.functional_currency_code := p0_a33;
    ddp_ams_import_rec.terminated_by := p0_a34;
    ddp_ams_import_rec.enclosed_by := p0_a35;
    ddp_ams_import_rec.data_filename := p0_a36;
    ddp_ams_import_rec.process_immed_flag := p0_a37;
    ddp_ams_import_rec.dedupe_flag := p0_a38;
    ddp_ams_import_rec.attribute_category := p0_a39;
    ddp_ams_import_rec.attribute1 := p0_a40;
    ddp_ams_import_rec.attribute2 := p0_a41;
    ddp_ams_import_rec.attribute3 := p0_a42;
    ddp_ams_import_rec.attribute4 := p0_a43;
    ddp_ams_import_rec.attribute5 := p0_a44;
    ddp_ams_import_rec.attribute6 := p0_a45;
    ddp_ams_import_rec.attribute7 := p0_a46;
    ddp_ams_import_rec.attribute8 := p0_a47;
    ddp_ams_import_rec.attribute9 := p0_a48;
    ddp_ams_import_rec.attribute10 := p0_a49;
    ddp_ams_import_rec.attribute11 := p0_a50;
    ddp_ams_import_rec.attribute12 := p0_a51;
    ddp_ams_import_rec.attribute13 := p0_a52;
    ddp_ams_import_rec.attribute14 := p0_a53;
    ddp_ams_import_rec.attribute15 := p0_a54;
    ddp_ams_import_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a55);
    ddp_ams_import_rec.country := rosetta_g_miss_num_map(p0_a56);
    ddp_ams_import_rec.usage := rosetta_g_miss_num_map(p0_a57);
    ddp_ams_import_rec.number_of_records := rosetta_g_miss_num_map(p0_a58);
    ddp_ams_import_rec.data_file_name := p0_a59;
    ddp_ams_import_rec.b2b_flag := p0_a60;
    ddp_ams_import_rec.rented_list_flag := p0_a61;
    ddp_ams_import_rec.server_flag := p0_a62;
    ddp_ams_import_rec.log_file_name := rosetta_g_miss_num_map(p0_a63);
    ddp_ams_import_rec.number_of_failed_records := rosetta_g_miss_num_map(p0_a64);
    ddp_ams_import_rec.number_of_duplicate_records := rosetta_g_miss_num_map(p0_a65);
    ddp_ams_import_rec.enable_word_replacement_flag := p0_a66;
    ddp_ams_import_rec.validate_file := p0_a67;
    ddp_ams_import_rec.server_name := p0_a68;
    ddp_ams_import_rec.user_name := p0_a69;
    ddp_ams_import_rec.password := p0_a70;
    ddp_ams_import_rec.upload_flag := p0_a71;
    ddp_ams_import_rec.parent_imp_header_id := rosetta_g_miss_num_map(p0_a72);
    ddp_ams_import_rec.record_update_flag := p0_a73;
    ddp_ams_import_rec.error_threshold := rosetta_g_miss_num_map(p0_a74);
    ddp_ams_import_rec.charset := p0_a75;



    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.check_ams_import_items(ddp_ams_import_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_ams_import_rec(p_api_version_number  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ams_import_rec ams_import_list_pvt.ams_import_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ams_import_rec.import_list_header_id := rosetta_g_miss_num_map(p5_a0);
    ddp_ams_import_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_ams_import_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_ams_import_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_ams_import_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_ams_import_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_ams_import_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_ams_import_rec.view_application_id := rosetta_g_miss_num_map(p5_a7);
    ddp_ams_import_rec.name := p5_a8;
    ddp_ams_import_rec.version := p5_a9;
    ddp_ams_import_rec.import_type := p5_a10;
    ddp_ams_import_rec.owner_user_id := rosetta_g_miss_num_map(p5_a11);
    ddp_ams_import_rec.list_source_type_id := rosetta_g_miss_num_map(p5_a12);
    ddp_ams_import_rec.status_code := p5_a13;
    ddp_ams_import_rec.status_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_ams_import_rec.user_status_id := rosetta_g_miss_num_map(p5_a15);
    ddp_ams_import_rec.source_system := p5_a16;
    ddp_ams_import_rec.vendor_id := rosetta_g_miss_num_map(p5_a17);
    ddp_ams_import_rec.pin_id := rosetta_g_miss_num_map(p5_a18);
    ddp_ams_import_rec.org_id := rosetta_g_miss_num_map(p5_a19);
    ddp_ams_import_rec.scheduled_time := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ams_import_rec.loaded_no_of_rows := rosetta_g_miss_num_map(p5_a21);
    ddp_ams_import_rec.loaded_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ams_import_rec.rows_to_skip := rosetta_g_miss_num_map(p5_a23);
    ddp_ams_import_rec.processed_rows := rosetta_g_miss_num_map(p5_a24);
    ddp_ams_import_rec.headings_flag := p5_a25;
    ddp_ams_import_rec.expiry_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ams_import_rec.purge_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_ams_import_rec.description := p5_a28;
    ddp_ams_import_rec.keywords := p5_a29;
    ddp_ams_import_rec.transactional_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_ams_import_rec.transactional_currency_code := p5_a31;
    ddp_ams_import_rec.functional_cost := rosetta_g_miss_num_map(p5_a32);
    ddp_ams_import_rec.functional_currency_code := p5_a33;
    ddp_ams_import_rec.terminated_by := p5_a34;
    ddp_ams_import_rec.enclosed_by := p5_a35;
    ddp_ams_import_rec.data_filename := p5_a36;
    ddp_ams_import_rec.process_immed_flag := p5_a37;
    ddp_ams_import_rec.dedupe_flag := p5_a38;
    ddp_ams_import_rec.attribute_category := p5_a39;
    ddp_ams_import_rec.attribute1 := p5_a40;
    ddp_ams_import_rec.attribute2 := p5_a41;
    ddp_ams_import_rec.attribute3 := p5_a42;
    ddp_ams_import_rec.attribute4 := p5_a43;
    ddp_ams_import_rec.attribute5 := p5_a44;
    ddp_ams_import_rec.attribute6 := p5_a45;
    ddp_ams_import_rec.attribute7 := p5_a46;
    ddp_ams_import_rec.attribute8 := p5_a47;
    ddp_ams_import_rec.attribute9 := p5_a48;
    ddp_ams_import_rec.attribute10 := p5_a49;
    ddp_ams_import_rec.attribute11 := p5_a50;
    ddp_ams_import_rec.attribute12 := p5_a51;
    ddp_ams_import_rec.attribute13 := p5_a52;
    ddp_ams_import_rec.attribute14 := p5_a53;
    ddp_ams_import_rec.attribute15 := p5_a54;
    ddp_ams_import_rec.custom_setup_id := rosetta_g_miss_num_map(p5_a55);
    ddp_ams_import_rec.country := rosetta_g_miss_num_map(p5_a56);
    ddp_ams_import_rec.usage := rosetta_g_miss_num_map(p5_a57);
    ddp_ams_import_rec.number_of_records := rosetta_g_miss_num_map(p5_a58);
    ddp_ams_import_rec.data_file_name := p5_a59;
    ddp_ams_import_rec.b2b_flag := p5_a60;
    ddp_ams_import_rec.rented_list_flag := p5_a61;
    ddp_ams_import_rec.server_flag := p5_a62;
    ddp_ams_import_rec.log_file_name := rosetta_g_miss_num_map(p5_a63);
    ddp_ams_import_rec.number_of_failed_records := rosetta_g_miss_num_map(p5_a64);
    ddp_ams_import_rec.number_of_duplicate_records := rosetta_g_miss_num_map(p5_a65);
    ddp_ams_import_rec.enable_word_replacement_flag := p5_a66;
    ddp_ams_import_rec.validate_file := p5_a67;
    ddp_ams_import_rec.server_name := p5_a68;
    ddp_ams_import_rec.user_name := p5_a69;
    ddp_ams_import_rec.password := p5_a70;
    ddp_ams_import_rec.upload_flag := p5_a71;
    ddp_ams_import_rec.parent_imp_header_id := rosetta_g_miss_num_map(p5_a72);
    ddp_ams_import_rec.record_update_flag := p5_a73;
    ddp_ams_import_rec.error_threshold := rosetta_g_miss_num_map(p5_a74);
    ddp_ams_import_rec.charset := p5_a75;

    -- here's the delegated call to the old PL/SQL routine
    ams_import_list_pvt.validate_ams_import_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_import_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_import_list_pvt_w;

/
