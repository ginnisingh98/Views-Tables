--------------------------------------------------------
--  DDL for Package Body JTF_IH_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PUB_W" as
  /* $Header: JTFIHJWB.pls 115.32 2003/07/14 17:56:34 ialeshin ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_ih_pub.activity_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_1000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).activity_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).duration := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cust_account_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cust_org_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).role := a4(indx);
          t(ddindx).end_date_time := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).start_date_time := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).doc_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).doc_ref := a9(indx);
          t(ddindx).doc_source_object_name := a10(indx);
          t(ddindx).media_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).action_item_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).interaction_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).outcome_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).result_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).reason_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).description := a17(indx);
          t(ddindx).action_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).interaction_action_type := a19(indx);
          t(ddindx).object_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).object_type := a21(indx);
          t(ddindx).source_code_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).source_code := a23(indx);
          t(ddindx).script_trans_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).attribute1 := a25(indx);
          t(ddindx).attribute2 := a26(indx);
          t(ddindx).attribute3 := a27(indx);
          t(ddindx).attribute4 := a28(indx);
          t(ddindx).attribute5 := a29(indx);
          t(ddindx).attribute6 := a30(indx);
          t(ddindx).attribute7 := a31(indx);
          t(ddindx).attribute8 := a32(indx);
          t(ddindx).attribute9 := a33(indx);
          t(ddindx).attribute10 := a34(indx);
          t(ddindx).attribute11 := a35(indx);
          t(ddindx).attribute12 := a36(indx);
          t(ddindx).attribute13 := a37(indx);
          t(ddindx).attribute14 := a38(indx);
          t(ddindx).attribute15 := a39(indx);
          t(ddindx).attribute_category := a40(indx);
          t(ddindx).bulk_writer_code := a41(indx);
          t(ddindx).bulk_batch_type := a42(indx);
          t(ddindx).bulk_batch_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).bulk_interaction_id := rosetta_g_miss_num_map(a44(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_ih_pub.activity_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_1000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_1000();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_1000();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).activity_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).duration);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cust_account_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cust_org_id);
          a4(indx) := t(ddindx).role;
          a5(indx) := t(ddindx).end_date_time;
          a6(indx) := t(ddindx).start_date_time;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).doc_id);
          a9(indx) := t(ddindx).doc_ref;
          a10(indx) := t(ddindx).doc_source_object_name;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).media_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).action_item_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).interaction_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).outcome_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).result_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).reason_id);
          a17(indx) := t(ddindx).description;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).action_id);
          a19(indx) := t(ddindx).interaction_action_type;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a21(indx) := t(ddindx).object_type;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).source_code_id);
          a23(indx) := t(ddindx).source_code;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).script_trans_id);
          a25(indx) := t(ddindx).attribute1;
          a26(indx) := t(ddindx).attribute2;
          a27(indx) := t(ddindx).attribute3;
          a28(indx) := t(ddindx).attribute4;
          a29(indx) := t(ddindx).attribute5;
          a30(indx) := t(ddindx).attribute6;
          a31(indx) := t(ddindx).attribute7;
          a32(indx) := t(ddindx).attribute8;
          a33(indx) := t(ddindx).attribute9;
          a34(indx) := t(ddindx).attribute10;
          a35(indx) := t(ddindx).attribute11;
          a36(indx) := t(ddindx).attribute12;
          a37(indx) := t(ddindx).attribute13;
          a38(indx) := t(ddindx).attribute14;
          a39(indx) := t(ddindx).attribute15;
          a40(indx) := t(ddindx).attribute_category;
          a41(indx) := t(ddindx).bulk_writer_code;
          a42(indx) := t(ddindx).bulk_batch_type;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).bulk_batch_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).bulk_interaction_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p8(t out nocopy jtf_ih_pub.mlcs_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).start_date_time := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).type_type := a1(indx);
          t(ddindx).type_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).duration := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).end_date_time := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).milcs_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).milcs_type_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).media_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).handler_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).resource_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).milcs_code := a10(indx);
          t(ddindx).bulk_writer_code := a11(indx);
          t(ddindx).bulk_batch_type := a12(indx);
          t(ddindx).bulk_batch_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).bulk_interaction_id := rosetta_g_miss_num_map(a14(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t jtf_ih_pub.mlcs_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).start_date_time;
          a1(indx) := t(ddindx).type_type;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).type_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).duration);
          a4(indx) := t(ddindx).end_date_time;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).milcs_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).milcs_type_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).media_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).handler_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a10(indx) := t(ddindx).milcs_code;
          a11(indx) := t(ddindx).bulk_writer_code;
          a12(indx) := t(ddindx).bulk_batch_type;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).bulk_batch_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).bulk_interaction_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_VARCHAR2_TABLE_300
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_DATE_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_VARCHAR2_TABLE_100
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_NUMBER_TABLE
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_1000
    , p11_a18 JTF_NUMBER_TABLE
    , p11_a19 JTF_VARCHAR2_TABLE_300
    , p11_a20 JTF_NUMBER_TABLE
    , p11_a21 JTF_VARCHAR2_TABLE_100
    , p11_a22 JTF_NUMBER_TABLE
    , p11_a23 JTF_VARCHAR2_TABLE_100
    , p11_a24 JTF_NUMBER_TABLE
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_VARCHAR2_TABLE_200
    , p11_a36 JTF_VARCHAR2_TABLE_200
    , p11_a37 JTF_VARCHAR2_TABLE_200
    , p11_a38 JTF_VARCHAR2_TABLE_200
    , p11_a39 JTF_VARCHAR2_TABLE_200
    , p11_a40 JTF_VARCHAR2_TABLE_100
    , p11_a41 JTF_VARCHAR2_TABLE_300
    , p11_a42 JTF_VARCHAR2_TABLE_300
    , p11_a43 JTF_NUMBER_TABLE
    , p11_a44 JTF_NUMBER_TABLE
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  )

  as
    ddp_interaction_rec jtf_ih_pub.interaction_rec_type;
    ddp_activities jtf_ih_pub.activity_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_interaction_rec.interaction_id := rosetta_g_miss_num_map(p10_a0);
    ddp_interaction_rec.reference_form := p10_a1;
    ddp_interaction_rec.follow_up_action := p10_a2;
    ddp_interaction_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_interaction_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_interaction_rec.inter_interaction_duration := rosetta_g_miss_num_map(p10_a5);
    ddp_interaction_rec.non_productive_time_amount := rosetta_g_miss_num_map(p10_a6);
    ddp_interaction_rec.preview_time_amount := rosetta_g_miss_num_map(p10_a7);
    ddp_interaction_rec.productive_time_amount := rosetta_g_miss_num_map(p10_a8);
    ddp_interaction_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a9);
    ddp_interaction_rec.wrapup_time_amount := rosetta_g_miss_num_map(p10_a10);
    ddp_interaction_rec.handler_id := rosetta_g_miss_num_map(p10_a11);
    ddp_interaction_rec.script_id := rosetta_g_miss_num_map(p10_a12);
    ddp_interaction_rec.outcome_id := rosetta_g_miss_num_map(p10_a13);
    ddp_interaction_rec.result_id := rosetta_g_miss_num_map(p10_a14);
    ddp_interaction_rec.reason_id := rosetta_g_miss_num_map(p10_a15);
    ddp_interaction_rec.resource_id := rosetta_g_miss_num_map(p10_a16);
    ddp_interaction_rec.party_id := rosetta_g_miss_num_map(p10_a17);
    ddp_interaction_rec.parent_id := rosetta_g_miss_num_map(p10_a18);
    ddp_interaction_rec.object_id := rosetta_g_miss_num_map(p10_a19);
    ddp_interaction_rec.object_type := p10_a20;
    ddp_interaction_rec.source_code_id := rosetta_g_miss_num_map(p10_a21);
    ddp_interaction_rec.source_code := p10_a22;
    ddp_interaction_rec.attribute1 := p10_a23;
    ddp_interaction_rec.attribute2 := p10_a24;
    ddp_interaction_rec.attribute3 := p10_a25;
    ddp_interaction_rec.attribute4 := p10_a26;
    ddp_interaction_rec.attribute5 := p10_a27;
    ddp_interaction_rec.attribute6 := p10_a28;
    ddp_interaction_rec.attribute7 := p10_a29;
    ddp_interaction_rec.attribute8 := p10_a30;
    ddp_interaction_rec.attribute9 := p10_a31;
    ddp_interaction_rec.attribute10 := p10_a32;
    ddp_interaction_rec.attribute11 := p10_a33;
    ddp_interaction_rec.attribute12 := p10_a34;
    ddp_interaction_rec.attribute13 := p10_a35;
    ddp_interaction_rec.attribute14 := p10_a36;
    ddp_interaction_rec.attribute15 := p10_a37;
    ddp_interaction_rec.attribute_category := p10_a38;
    ddp_interaction_rec.touchpoint1_type := p10_a39;
    ddp_interaction_rec.touchpoint2_type := p10_a40;
    ddp_interaction_rec.method_code := p10_a41;
    ddp_interaction_rec.bulk_writer_code := p10_a42;
    ddp_interaction_rec.bulk_batch_type := p10_a43;
    ddp_interaction_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a44);
    ddp_interaction_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a45);
    ddp_interaction_rec.primary_party_id := rosetta_g_miss_num_map(p10_a46);
    ddp_interaction_rec.contact_rel_party_id := rosetta_g_miss_num_map(p10_a47);
    ddp_interaction_rec.contact_party_id := rosetta_g_miss_num_map(p10_a48);

    jtf_ih_pub_w.rosetta_table_copy_in_p3(ddp_activities, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.create_interaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interaction_rec,
      ddp_activities);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure create_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 JTF_DATE_TABLE
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_DATE_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_VARCHAR2_TABLE_100
    , p11_a11 JTF_VARCHAR2_TABLE_300
    , p11_a12 JTF_VARCHAR2_TABLE_300
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_media jtf_ih_pub.media_rec_type;
    ddp_mlcs jtf_ih_pub.mlcs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media.media_id := rosetta_g_miss_num_map(p10_a0);
    ddp_media.source_id := rosetta_g_miss_num_map(p10_a1);
    ddp_media.direction := p10_a2;
    ddp_media.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media.interaction_performed := p10_a5;
    ddp_media.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_media.media_data := p10_a7;
    ddp_media.source_item_create_date_time := rosetta_g_miss_date_in_map(p10_a8);
    ddp_media.source_item_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media.media_item_type := p10_a10;
    ddp_media.media_item_ref := p10_a11;
    ddp_media.media_abandon_flag := p10_a12;
    ddp_media.media_transferred_flag := p10_a13;
    ddp_media.server_group_id := rosetta_g_miss_num_map(p10_a14);
    ddp_media.dnis := p10_a15;
    ddp_media.ani := p10_a16;
    ddp_media.classification := p10_a17;
    ddp_media.bulk_writer_code := p10_a18;
    ddp_media.bulk_batch_type := p10_a19;
    ddp_media.bulk_batch_id := rosetta_g_miss_num_map(p10_a20);
    ddp_media.bulk_interaction_id := rosetta_g_miss_num_map(p10_a21);
    ddp_media.address := p10_a22;

    jtf_ih_pub_w.rosetta_table_copy_in_p8(ddp_mlcs, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.create_mediaitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media,
      ddp_mlcs);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure create_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_media_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_media_rec jtf_ih_pub.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_rec.media_id := rosetta_g_miss_num_map(p10_a0);
    ddp_media_rec.source_id := rosetta_g_miss_num_map(p10_a1);
    ddp_media_rec.direction := p10_a2;
    ddp_media_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_rec.interaction_performed := p10_a5;
    ddp_media_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_media_rec.media_data := p10_a7;
    ddp_media_rec.source_item_create_date_time := rosetta_g_miss_date_in_map(p10_a8);
    ddp_media_rec.source_item_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_rec.media_item_type := p10_a10;
    ddp_media_rec.media_item_ref := p10_a11;
    ddp_media_rec.media_abandon_flag := p10_a12;
    ddp_media_rec.media_transferred_flag := p10_a13;
    ddp_media_rec.server_group_id := rosetta_g_miss_num_map(p10_a14);
    ddp_media_rec.dnis := p10_a15;
    ddp_media_rec.ani := p10_a16;
    ddp_media_rec.classification := p10_a17;
    ddp_media_rec.bulk_writer_code := p10_a18;
    ddp_media_rec.bulk_batch_type := p10_a19;
    ddp_media_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a20);
    ddp_media_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a21);
    ddp_media_rec.address := p10_a22;


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.create_mediaitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec,
      x_media_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure create_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_media_lc_rec jtf_ih_pub.media_lc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_lc_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a0);
    ddp_media_lc_rec.type_type := p10_a1;
    ddp_media_lc_rec.type_id := rosetta_g_miss_num_map(p10_a2);
    ddp_media_lc_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_lc_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_lc_rec.milcs_id := rosetta_g_miss_num_map(p10_a5);
    ddp_media_lc_rec.milcs_type_id := rosetta_g_miss_num_map(p10_a6);
    ddp_media_lc_rec.media_id := rosetta_g_miss_num_map(p10_a7);
    ddp_media_lc_rec.handler_id := rosetta_g_miss_num_map(p10_a8);
    ddp_media_lc_rec.resource_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_lc_rec.milcs_code := p10_a10;
    ddp_media_lc_rec.bulk_writer_code := p10_a11;
    ddp_media_lc_rec.bulk_batch_type := p10_a12;
    ddp_media_lc_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a13);
    ddp_media_lc_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a14);

    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.create_medialifecycle(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_lc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure open_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  )

  as
    ddp_interaction_rec jtf_ih_pub.interaction_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_interaction_rec.interaction_id := rosetta_g_miss_num_map(p10_a0);
    ddp_interaction_rec.reference_form := p10_a1;
    ddp_interaction_rec.follow_up_action := p10_a2;
    ddp_interaction_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_interaction_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_interaction_rec.inter_interaction_duration := rosetta_g_miss_num_map(p10_a5);
    ddp_interaction_rec.non_productive_time_amount := rosetta_g_miss_num_map(p10_a6);
    ddp_interaction_rec.preview_time_amount := rosetta_g_miss_num_map(p10_a7);
    ddp_interaction_rec.productive_time_amount := rosetta_g_miss_num_map(p10_a8);
    ddp_interaction_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a9);
    ddp_interaction_rec.wrapup_time_amount := rosetta_g_miss_num_map(p10_a10);
    ddp_interaction_rec.handler_id := rosetta_g_miss_num_map(p10_a11);
    ddp_interaction_rec.script_id := rosetta_g_miss_num_map(p10_a12);
    ddp_interaction_rec.outcome_id := rosetta_g_miss_num_map(p10_a13);
    ddp_interaction_rec.result_id := rosetta_g_miss_num_map(p10_a14);
    ddp_interaction_rec.reason_id := rosetta_g_miss_num_map(p10_a15);
    ddp_interaction_rec.resource_id := rosetta_g_miss_num_map(p10_a16);
    ddp_interaction_rec.party_id := rosetta_g_miss_num_map(p10_a17);
    ddp_interaction_rec.parent_id := rosetta_g_miss_num_map(p10_a18);
    ddp_interaction_rec.object_id := rosetta_g_miss_num_map(p10_a19);
    ddp_interaction_rec.object_type := p10_a20;
    ddp_interaction_rec.source_code_id := rosetta_g_miss_num_map(p10_a21);
    ddp_interaction_rec.source_code := p10_a22;
    ddp_interaction_rec.attribute1 := p10_a23;
    ddp_interaction_rec.attribute2 := p10_a24;
    ddp_interaction_rec.attribute3 := p10_a25;
    ddp_interaction_rec.attribute4 := p10_a26;
    ddp_interaction_rec.attribute5 := p10_a27;
    ddp_interaction_rec.attribute6 := p10_a28;
    ddp_interaction_rec.attribute7 := p10_a29;
    ddp_interaction_rec.attribute8 := p10_a30;
    ddp_interaction_rec.attribute9 := p10_a31;
    ddp_interaction_rec.attribute10 := p10_a32;
    ddp_interaction_rec.attribute11 := p10_a33;
    ddp_interaction_rec.attribute12 := p10_a34;
    ddp_interaction_rec.attribute13 := p10_a35;
    ddp_interaction_rec.attribute14 := p10_a36;
    ddp_interaction_rec.attribute15 := p10_a37;
    ddp_interaction_rec.attribute_category := p10_a38;
    ddp_interaction_rec.touchpoint1_type := p10_a39;
    ddp_interaction_rec.touchpoint2_type := p10_a40;
    ddp_interaction_rec.method_code := p10_a41;
    ddp_interaction_rec.bulk_writer_code := p10_a42;
    ddp_interaction_rec.bulk_batch_type := p10_a43;
    ddp_interaction_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a44);
    ddp_interaction_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a45);
    ddp_interaction_rec.primary_party_id := rosetta_g_miss_num_map(p10_a46);
    ddp_interaction_rec.contact_rel_party_id := rosetta_g_miss_num_map(p10_a47);
    ddp_interaction_rec.contact_party_id := rosetta_g_miss_num_map(p10_a48);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.open_interaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interaction_rec,
      x_interaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  )

  as
    ddp_interaction_rec jtf_ih_pub.interaction_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_interaction_rec.interaction_id := rosetta_g_miss_num_map(p10_a0);
    ddp_interaction_rec.reference_form := p10_a1;
    ddp_interaction_rec.follow_up_action := p10_a2;
    ddp_interaction_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_interaction_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_interaction_rec.inter_interaction_duration := rosetta_g_miss_num_map(p10_a5);
    ddp_interaction_rec.non_productive_time_amount := rosetta_g_miss_num_map(p10_a6);
    ddp_interaction_rec.preview_time_amount := rosetta_g_miss_num_map(p10_a7);
    ddp_interaction_rec.productive_time_amount := rosetta_g_miss_num_map(p10_a8);
    ddp_interaction_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a9);
    ddp_interaction_rec.wrapup_time_amount := rosetta_g_miss_num_map(p10_a10);
    ddp_interaction_rec.handler_id := rosetta_g_miss_num_map(p10_a11);
    ddp_interaction_rec.script_id := rosetta_g_miss_num_map(p10_a12);
    ddp_interaction_rec.outcome_id := rosetta_g_miss_num_map(p10_a13);
    ddp_interaction_rec.result_id := rosetta_g_miss_num_map(p10_a14);
    ddp_interaction_rec.reason_id := rosetta_g_miss_num_map(p10_a15);
    ddp_interaction_rec.resource_id := rosetta_g_miss_num_map(p10_a16);
    ddp_interaction_rec.party_id := rosetta_g_miss_num_map(p10_a17);
    ddp_interaction_rec.parent_id := rosetta_g_miss_num_map(p10_a18);
    ddp_interaction_rec.object_id := rosetta_g_miss_num_map(p10_a19);
    ddp_interaction_rec.object_type := p10_a20;
    ddp_interaction_rec.source_code_id := rosetta_g_miss_num_map(p10_a21);
    ddp_interaction_rec.source_code := p10_a22;
    ddp_interaction_rec.attribute1 := p10_a23;
    ddp_interaction_rec.attribute2 := p10_a24;
    ddp_interaction_rec.attribute3 := p10_a25;
    ddp_interaction_rec.attribute4 := p10_a26;
    ddp_interaction_rec.attribute5 := p10_a27;
    ddp_interaction_rec.attribute6 := p10_a28;
    ddp_interaction_rec.attribute7 := p10_a29;
    ddp_interaction_rec.attribute8 := p10_a30;
    ddp_interaction_rec.attribute9 := p10_a31;
    ddp_interaction_rec.attribute10 := p10_a32;
    ddp_interaction_rec.attribute11 := p10_a33;
    ddp_interaction_rec.attribute12 := p10_a34;
    ddp_interaction_rec.attribute13 := p10_a35;
    ddp_interaction_rec.attribute14 := p10_a36;
    ddp_interaction_rec.attribute15 := p10_a37;
    ddp_interaction_rec.attribute_category := p10_a38;
    ddp_interaction_rec.touchpoint1_type := p10_a39;
    ddp_interaction_rec.touchpoint2_type := p10_a40;
    ddp_interaction_rec.method_code := p10_a41;
    ddp_interaction_rec.bulk_writer_code := p10_a42;
    ddp_interaction_rec.bulk_batch_type := p10_a43;
    ddp_interaction_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a44);
    ddp_interaction_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a45);
    ddp_interaction_rec.primary_party_id := rosetta_g_miss_num_map(p10_a46);
    ddp_interaction_rec.contact_rel_party_id := rosetta_g_miss_num_map(p10_a47);
    ddp_interaction_rec.contact_party_id := rosetta_g_miss_num_map(p10_a48);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.update_interaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interaction_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure close_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  )

  as
    ddp_interaction_rec jtf_ih_pub.interaction_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_interaction_rec.interaction_id := rosetta_g_miss_num_map(p10_a0);
    ddp_interaction_rec.reference_form := p10_a1;
    ddp_interaction_rec.follow_up_action := p10_a2;
    ddp_interaction_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_interaction_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_interaction_rec.inter_interaction_duration := rosetta_g_miss_num_map(p10_a5);
    ddp_interaction_rec.non_productive_time_amount := rosetta_g_miss_num_map(p10_a6);
    ddp_interaction_rec.preview_time_amount := rosetta_g_miss_num_map(p10_a7);
    ddp_interaction_rec.productive_time_amount := rosetta_g_miss_num_map(p10_a8);
    ddp_interaction_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a9);
    ddp_interaction_rec.wrapup_time_amount := rosetta_g_miss_num_map(p10_a10);
    ddp_interaction_rec.handler_id := rosetta_g_miss_num_map(p10_a11);
    ddp_interaction_rec.script_id := rosetta_g_miss_num_map(p10_a12);
    ddp_interaction_rec.outcome_id := rosetta_g_miss_num_map(p10_a13);
    ddp_interaction_rec.result_id := rosetta_g_miss_num_map(p10_a14);
    ddp_interaction_rec.reason_id := rosetta_g_miss_num_map(p10_a15);
    ddp_interaction_rec.resource_id := rosetta_g_miss_num_map(p10_a16);
    ddp_interaction_rec.party_id := rosetta_g_miss_num_map(p10_a17);
    ddp_interaction_rec.parent_id := rosetta_g_miss_num_map(p10_a18);
    ddp_interaction_rec.object_id := rosetta_g_miss_num_map(p10_a19);
    ddp_interaction_rec.object_type := p10_a20;
    ddp_interaction_rec.source_code_id := rosetta_g_miss_num_map(p10_a21);
    ddp_interaction_rec.source_code := p10_a22;
    ddp_interaction_rec.attribute1 := p10_a23;
    ddp_interaction_rec.attribute2 := p10_a24;
    ddp_interaction_rec.attribute3 := p10_a25;
    ddp_interaction_rec.attribute4 := p10_a26;
    ddp_interaction_rec.attribute5 := p10_a27;
    ddp_interaction_rec.attribute6 := p10_a28;
    ddp_interaction_rec.attribute7 := p10_a29;
    ddp_interaction_rec.attribute8 := p10_a30;
    ddp_interaction_rec.attribute9 := p10_a31;
    ddp_interaction_rec.attribute10 := p10_a32;
    ddp_interaction_rec.attribute11 := p10_a33;
    ddp_interaction_rec.attribute12 := p10_a34;
    ddp_interaction_rec.attribute13 := p10_a35;
    ddp_interaction_rec.attribute14 := p10_a36;
    ddp_interaction_rec.attribute15 := p10_a37;
    ddp_interaction_rec.attribute_category := p10_a38;
    ddp_interaction_rec.touchpoint1_type := p10_a39;
    ddp_interaction_rec.touchpoint2_type := p10_a40;
    ddp_interaction_rec.method_code := p10_a41;
    ddp_interaction_rec.bulk_writer_code := p10_a42;
    ddp_interaction_rec.bulk_batch_type := p10_a43;
    ddp_interaction_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a44);
    ddp_interaction_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a45);
    ddp_interaction_rec.primary_party_id := rosetta_g_miss_num_map(p10_a46);
    ddp_interaction_rec.contact_rel_party_id := rosetta_g_miss_num_map(p10_a47);
    ddp_interaction_rec.contact_party_id := rosetta_g_miss_num_map(p10_a48);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.close_interaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interaction_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure add_activity(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_activity_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  DATE := fnd_api.g_miss_date
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  NUMBER := 0-1962.0724
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  NUMBER := 0-1962.0724
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  NUMBER := 0-1962.0724
    , p10_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_activity_rec jtf_ih_pub.activity_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_activity_rec.activity_id := rosetta_g_miss_num_map(p10_a0);
    ddp_activity_rec.duration := rosetta_g_miss_num_map(p10_a1);
    ddp_activity_rec.cust_account_id := rosetta_g_miss_num_map(p10_a2);
    ddp_activity_rec.cust_org_id := rosetta_g_miss_num_map(p10_a3);
    ddp_activity_rec.role := p10_a4;
    ddp_activity_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a5);
    ddp_activity_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_activity_rec.task_id := rosetta_g_miss_num_map(p10_a7);
    ddp_activity_rec.doc_id := rosetta_g_miss_num_map(p10_a8);
    ddp_activity_rec.doc_ref := p10_a9;
    ddp_activity_rec.doc_source_object_name := p10_a10;
    ddp_activity_rec.media_id := rosetta_g_miss_num_map(p10_a11);
    ddp_activity_rec.action_item_id := rosetta_g_miss_num_map(p10_a12);
    ddp_activity_rec.interaction_id := rosetta_g_miss_num_map(p10_a13);
    ddp_activity_rec.outcome_id := rosetta_g_miss_num_map(p10_a14);
    ddp_activity_rec.result_id := rosetta_g_miss_num_map(p10_a15);
    ddp_activity_rec.reason_id := rosetta_g_miss_num_map(p10_a16);
    ddp_activity_rec.description := p10_a17;
    ddp_activity_rec.action_id := rosetta_g_miss_num_map(p10_a18);
    ddp_activity_rec.interaction_action_type := p10_a19;
    ddp_activity_rec.object_id := rosetta_g_miss_num_map(p10_a20);
    ddp_activity_rec.object_type := p10_a21;
    ddp_activity_rec.source_code_id := rosetta_g_miss_num_map(p10_a22);
    ddp_activity_rec.source_code := p10_a23;
    ddp_activity_rec.script_trans_id := rosetta_g_miss_num_map(p10_a24);
    ddp_activity_rec.attribute1 := p10_a25;
    ddp_activity_rec.attribute2 := p10_a26;
    ddp_activity_rec.attribute3 := p10_a27;
    ddp_activity_rec.attribute4 := p10_a28;
    ddp_activity_rec.attribute5 := p10_a29;
    ddp_activity_rec.attribute6 := p10_a30;
    ddp_activity_rec.attribute7 := p10_a31;
    ddp_activity_rec.attribute8 := p10_a32;
    ddp_activity_rec.attribute9 := p10_a33;
    ddp_activity_rec.attribute10 := p10_a34;
    ddp_activity_rec.attribute11 := p10_a35;
    ddp_activity_rec.attribute12 := p10_a36;
    ddp_activity_rec.attribute13 := p10_a37;
    ddp_activity_rec.attribute14 := p10_a38;
    ddp_activity_rec.attribute15 := p10_a39;
    ddp_activity_rec.attribute_category := p10_a40;
    ddp_activity_rec.bulk_writer_code := p10_a41;
    ddp_activity_rec.bulk_batch_type := p10_a42;
    ddp_activity_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a43);
    ddp_activity_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a44);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.add_activity(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_activity_rec,
      x_activity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_activity(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  DATE := fnd_api.g_miss_date
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  NUMBER := 0-1962.0724
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  NUMBER := 0-1962.0724
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  NUMBER := 0-1962.0724
    , p10_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_activity_rec jtf_ih_pub.activity_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_activity_rec.activity_id := rosetta_g_miss_num_map(p10_a0);
    ddp_activity_rec.duration := rosetta_g_miss_num_map(p10_a1);
    ddp_activity_rec.cust_account_id := rosetta_g_miss_num_map(p10_a2);
    ddp_activity_rec.cust_org_id := rosetta_g_miss_num_map(p10_a3);
    ddp_activity_rec.role := p10_a4;
    ddp_activity_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a5);
    ddp_activity_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_activity_rec.task_id := rosetta_g_miss_num_map(p10_a7);
    ddp_activity_rec.doc_id := rosetta_g_miss_num_map(p10_a8);
    ddp_activity_rec.doc_ref := p10_a9;
    ddp_activity_rec.doc_source_object_name := p10_a10;
    ddp_activity_rec.media_id := rosetta_g_miss_num_map(p10_a11);
    ddp_activity_rec.action_item_id := rosetta_g_miss_num_map(p10_a12);
    ddp_activity_rec.interaction_id := rosetta_g_miss_num_map(p10_a13);
    ddp_activity_rec.outcome_id := rosetta_g_miss_num_map(p10_a14);
    ddp_activity_rec.result_id := rosetta_g_miss_num_map(p10_a15);
    ddp_activity_rec.reason_id := rosetta_g_miss_num_map(p10_a16);
    ddp_activity_rec.description := p10_a17;
    ddp_activity_rec.action_id := rosetta_g_miss_num_map(p10_a18);
    ddp_activity_rec.interaction_action_type := p10_a19;
    ddp_activity_rec.object_id := rosetta_g_miss_num_map(p10_a20);
    ddp_activity_rec.object_type := p10_a21;
    ddp_activity_rec.source_code_id := rosetta_g_miss_num_map(p10_a22);
    ddp_activity_rec.source_code := p10_a23;
    ddp_activity_rec.script_trans_id := rosetta_g_miss_num_map(p10_a24);
    ddp_activity_rec.attribute1 := p10_a25;
    ddp_activity_rec.attribute2 := p10_a26;
    ddp_activity_rec.attribute3 := p10_a27;
    ddp_activity_rec.attribute4 := p10_a28;
    ddp_activity_rec.attribute5 := p10_a29;
    ddp_activity_rec.attribute6 := p10_a30;
    ddp_activity_rec.attribute7 := p10_a31;
    ddp_activity_rec.attribute8 := p10_a32;
    ddp_activity_rec.attribute9 := p10_a33;
    ddp_activity_rec.attribute10 := p10_a34;
    ddp_activity_rec.attribute11 := p10_a35;
    ddp_activity_rec.attribute12 := p10_a36;
    ddp_activity_rec.attribute13 := p10_a37;
    ddp_activity_rec.attribute14 := p10_a38;
    ddp_activity_rec.attribute15 := p10_a39;
    ddp_activity_rec.attribute_category := p10_a40;
    ddp_activity_rec.bulk_writer_code := p10_a41;
    ddp_activity_rec.bulk_batch_type := p10_a42;
    ddp_activity_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a43);
    ddp_activity_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a44);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.update_activity(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_activity_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_activityduration(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_activity_id  NUMBER
    , p_end_date_time  date
    , p_duration  NUMBER
    , p_object_version  NUMBER
  )

  as
    ddp_end_date_time date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_end_date_time := rosetta_g_miss_date_in_map(p_end_date_time);



    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.update_activityduration(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_activity_id,
      ddp_end_date_time,
      p_duration,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure open_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_media_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_media_rec jtf_ih_pub.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_rec.media_id := rosetta_g_miss_num_map(p10_a0);
    ddp_media_rec.source_id := rosetta_g_miss_num_map(p10_a1);
    ddp_media_rec.direction := p10_a2;
    ddp_media_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_rec.interaction_performed := p10_a5;
    ddp_media_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_media_rec.media_data := p10_a7;
    ddp_media_rec.source_item_create_date_time := rosetta_g_miss_date_in_map(p10_a8);
    ddp_media_rec.source_item_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_rec.media_item_type := p10_a10;
    ddp_media_rec.media_item_ref := p10_a11;
    ddp_media_rec.media_abandon_flag := p10_a12;
    ddp_media_rec.media_transferred_flag := p10_a13;
    ddp_media_rec.server_group_id := rosetta_g_miss_num_map(p10_a14);
    ddp_media_rec.dnis := p10_a15;
    ddp_media_rec.ani := p10_a16;
    ddp_media_rec.classification := p10_a17;
    ddp_media_rec.bulk_writer_code := p10_a18;
    ddp_media_rec.bulk_batch_type := p10_a19;
    ddp_media_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a20);
    ddp_media_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a21);
    ddp_media_rec.address := p10_a22;


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.open_mediaitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec,
      x_media_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_media_rec jtf_ih_pub.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_rec.media_id := rosetta_g_miss_num_map(p10_a0);
    ddp_media_rec.source_id := rosetta_g_miss_num_map(p10_a1);
    ddp_media_rec.direction := p10_a2;
    ddp_media_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_rec.interaction_performed := p10_a5;
    ddp_media_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_media_rec.media_data := p10_a7;
    ddp_media_rec.source_item_create_date_time := rosetta_g_miss_date_in_map(p10_a8);
    ddp_media_rec.source_item_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_rec.media_item_type := p10_a10;
    ddp_media_rec.media_item_ref := p10_a11;
    ddp_media_rec.media_abandon_flag := p10_a12;
    ddp_media_rec.media_transferred_flag := p10_a13;
    ddp_media_rec.server_group_id := rosetta_g_miss_num_map(p10_a14);
    ddp_media_rec.dnis := p10_a15;
    ddp_media_rec.ani := p10_a16;
    ddp_media_rec.classification := p10_a17;
    ddp_media_rec.bulk_writer_code := p10_a18;
    ddp_media_rec.bulk_batch_type := p10_a19;
    ddp_media_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a20);
    ddp_media_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a21);
    ddp_media_rec.address := p10_a22;


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.update_mediaitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure close_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_media_rec jtf_ih_pub.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_rec.media_id := rosetta_g_miss_num_map(p10_a0);
    ddp_media_rec.source_id := rosetta_g_miss_num_map(p10_a1);
    ddp_media_rec.direction := p10_a2;
    ddp_media_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_rec.interaction_performed := p10_a5;
    ddp_media_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a6);
    ddp_media_rec.media_data := p10_a7;
    ddp_media_rec.source_item_create_date_time := rosetta_g_miss_date_in_map(p10_a8);
    ddp_media_rec.source_item_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_rec.media_item_type := p10_a10;
    ddp_media_rec.media_item_ref := p10_a11;
    ddp_media_rec.media_abandon_flag := p10_a12;
    ddp_media_rec.media_transferred_flag := p10_a13;
    ddp_media_rec.server_group_id := rosetta_g_miss_num_map(p10_a14);
    ddp_media_rec.dnis := p10_a15;
    ddp_media_rec.ani := p10_a16;
    ddp_media_rec.classification := p10_a17;
    ddp_media_rec.bulk_writer_code := p10_a18;
    ddp_media_rec.bulk_batch_type := p10_a19;
    ddp_media_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a20);
    ddp_media_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a21);
    ddp_media_rec.address := p10_a22;


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.close_mediaitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure add_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_milcs_id out nocopy  NUMBER
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_media_lc_rec jtf_ih_pub.media_lc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_lc_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a0);
    ddp_media_lc_rec.type_type := p10_a1;
    ddp_media_lc_rec.type_id := rosetta_g_miss_num_map(p10_a2);
    ddp_media_lc_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_lc_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_lc_rec.milcs_id := rosetta_g_miss_num_map(p10_a5);
    ddp_media_lc_rec.milcs_type_id := rosetta_g_miss_num_map(p10_a6);
    ddp_media_lc_rec.media_id := rosetta_g_miss_num_map(p10_a7);
    ddp_media_lc_rec.handler_id := rosetta_g_miss_num_map(p10_a8);
    ddp_media_lc_rec.resource_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_lc_rec.milcs_code := p10_a10;
    ddp_media_lc_rec.bulk_writer_code := p10_a11;
    ddp_media_lc_rec.bulk_batch_type := p10_a12;
    ddp_media_lc_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a13);
    ddp_media_lc_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a14);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.add_medialifecycle(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_lc_rec,
      x_milcs_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_media_lc_rec jtf_ih_pub.media_lc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_media_lc_rec.start_date_time := rosetta_g_miss_date_in_map(p10_a0);
    ddp_media_lc_rec.type_type := p10_a1;
    ddp_media_lc_rec.type_id := rosetta_g_miss_num_map(p10_a2);
    ddp_media_lc_rec.duration := rosetta_g_miss_num_map(p10_a3);
    ddp_media_lc_rec.end_date_time := rosetta_g_miss_date_in_map(p10_a4);
    ddp_media_lc_rec.milcs_id := rosetta_g_miss_num_map(p10_a5);
    ddp_media_lc_rec.milcs_type_id := rosetta_g_miss_num_map(p10_a6);
    ddp_media_lc_rec.media_id := rosetta_g_miss_num_map(p10_a7);
    ddp_media_lc_rec.handler_id := rosetta_g_miss_num_map(p10_a8);
    ddp_media_lc_rec.resource_id := rosetta_g_miss_num_map(p10_a9);
    ddp_media_lc_rec.milcs_code := p10_a10;
    ddp_media_lc_rec.bulk_writer_code := p10_a11;
    ddp_media_lc_rec.bulk_batch_type := p10_a12;
    ddp_media_lc_rec.bulk_batch_id := rosetta_g_miss_num_map(p10_a13);
    ddp_media_lc_rec.bulk_interaction_id := rosetta_g_miss_num_map(p10_a14);


    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.update_medialifecycle(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_lc_rec,
      p_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end jtf_ih_pub_w;

/
