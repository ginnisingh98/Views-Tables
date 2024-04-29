--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_PUB_W" as
  /* $Header: asxwintb.pls 115.14 2003/11/06 13:58:30 gbatra ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy as_interest_pub.interest_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).interest_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).customer_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).address_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).contact_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).interest_type_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).interest_type := a11(indx);
          t(ddindx).primary_interest_code_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).primary_interest_code := a13(indx);
          t(ddindx).secondary_interest_code_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).secondary_interest_code := a15(indx);
          t(ddindx).status_code := a16(indx);
          t(ddindx).status := a17(indx);
          t(ddindx).description := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).product_category_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).product_cat_set_id := rosetta_g_miss_num_map(a36(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t as_interest_pub.interest_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).interest_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).interest_type_id);
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := t(ddindx).interest_type;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).primary_interest_code_id);
          a13(indx) := t(ddindx).primary_interest_code;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).secondary_interest_code_id);
          a15(indx) := t(ddindx).secondary_interest_code;
          a16(indx) := t(ddindx).status_code;
          a17(indx) := t(ddindx).status;
          a18(indx) := t(ddindx).description;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).product_category_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).product_cat_set_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy as_interest_pub.interest_code_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).interest_code_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).code := a1(indx);
          t(ddindx).interest_type_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).revenue_class_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).enabled_flag := a4(indx);
          t(ddindx).parent_interest_code_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).description := a6(indx);
          t(ddindx).category_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).category_set_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).pf_item_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).pf_organization_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).price := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).currency_code := a13(indx);
          t(ddindx).attribute_category := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          t(ddindx).product_category_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).product_cat_set_id := rosetta_g_miss_num_map(a31(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t as_interest_pub.interest_code_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).interest_code_id);
          a1(indx) := t(ddindx).code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).interest_type_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).revenue_class_id);
          a4(indx) := t(ddindx).enabled_flag;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).parent_interest_code_id);
          a6(indx) := t(ddindx).description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).category_set_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).pf_item_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).pf_organization_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).price);
          a13(indx) := t(ddindx).currency_code;
          a14(indx) := t(ddindx).attribute_category;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).product_category_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).product_cat_set_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_contact_id  NUMBER
    , p_lead_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_return_status out nocopy  VARCHAR2
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_interest_out_id out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p14_a0  VARCHAR2 := fnd_api.g_miss_char
    , p14_a1  VARCHAR2 := fnd_api.g_miss_char
    , p14_a2  VARCHAR2 := fnd_api.g_miss_char
    , p14_a3  VARCHAR2 := fnd_api.g_miss_char
    , p14_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_interest_rec as_interest_pub.interest_rec_type;
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_interest_rec.interest_id := rosetta_g_miss_num_map(p4_a0);
    ddp_interest_rec.customer_id := rosetta_g_miss_num_map(p4_a1);
    ddp_interest_rec.address_id := rosetta_g_miss_num_map(p4_a2);
    ddp_interest_rec.contact_id := rosetta_g_miss_num_map(p4_a3);
    ddp_interest_rec.lead_id := rosetta_g_miss_num_map(p4_a4);
    ddp_interest_rec.interest_type_id := rosetta_g_miss_num_map(p4_a5);
    ddp_interest_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_interest_rec.last_updated_by := rosetta_g_miss_num_map(p4_a7);
    ddp_interest_rec.creation_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_interest_rec.created_by := rosetta_g_miss_num_map(p4_a9);
    ddp_interest_rec.last_update_login := rosetta_g_miss_num_map(p4_a10);
    ddp_interest_rec.interest_type := p4_a11;
    ddp_interest_rec.primary_interest_code_id := rosetta_g_miss_num_map(p4_a12);
    ddp_interest_rec.primary_interest_code := p4_a13;
    ddp_interest_rec.secondary_interest_code_id := rosetta_g_miss_num_map(p4_a14);
    ddp_interest_rec.secondary_interest_code := p4_a15;
    ddp_interest_rec.status_code := p4_a16;
    ddp_interest_rec.status := p4_a17;
    ddp_interest_rec.description := p4_a18;
    ddp_interest_rec.attribute_category := p4_a19;
    ddp_interest_rec.attribute1 := p4_a20;
    ddp_interest_rec.attribute2 := p4_a21;
    ddp_interest_rec.attribute3 := p4_a22;
    ddp_interest_rec.attribute4 := p4_a23;
    ddp_interest_rec.attribute5 := p4_a24;
    ddp_interest_rec.attribute6 := p4_a25;
    ddp_interest_rec.attribute7 := p4_a26;
    ddp_interest_rec.attribute8 := p4_a27;
    ddp_interest_rec.attribute9 := p4_a28;
    ddp_interest_rec.attribute10 := p4_a29;
    ddp_interest_rec.attribute11 := p4_a30;
    ddp_interest_rec.attribute12 := p4_a31;
    ddp_interest_rec.attribute13 := p4_a32;
    ddp_interest_rec.attribute14 := p4_a33;
    ddp_interest_rec.attribute15 := p4_a34;
    ddp_interest_rec.product_category_id := rosetta_g_miss_num_map(p4_a35);
    ddp_interest_rec.product_cat_set_id := rosetta_g_miss_num_map(p4_a36);










    ddp_access_profile_rec.cust_access_profile_value := p14_a0;
    ddp_access_profile_rec.lead_access_profile_value := p14_a1;
    ddp_access_profile_rec.opp_access_profile_value := p14_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p14_a3;
    ddp_access_profile_rec.admin_update_profile_value := p14_a4;





    -- here's the delegated call to the old PL/SQL routine
    as_interest_pub.create_interest(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_interest_rec,
      p_customer_id,
      p_address_id,
      p_contact_id,
      p_lead_id,
      p_interest_use_code,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_access_profile_rec,
      p_return_status,
      p_msg_count,
      p_msg_data,
      p_interest_out_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















  end;

  procedure update_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interest_id out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_interest_rec as_interest_pub.interest_rec_type;
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_interest_rec.interest_id := rosetta_g_miss_num_map(p5_a0);
    ddp_interest_rec.customer_id := rosetta_g_miss_num_map(p5_a1);
    ddp_interest_rec.address_id := rosetta_g_miss_num_map(p5_a2);
    ddp_interest_rec.contact_id := rosetta_g_miss_num_map(p5_a3);
    ddp_interest_rec.lead_id := rosetta_g_miss_num_map(p5_a4);
    ddp_interest_rec.interest_type_id := rosetta_g_miss_num_map(p5_a5);
    ddp_interest_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_interest_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_interest_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_interest_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_interest_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);
    ddp_interest_rec.interest_type := p5_a11;
    ddp_interest_rec.primary_interest_code_id := rosetta_g_miss_num_map(p5_a12);
    ddp_interest_rec.primary_interest_code := p5_a13;
    ddp_interest_rec.secondary_interest_code_id := rosetta_g_miss_num_map(p5_a14);
    ddp_interest_rec.secondary_interest_code := p5_a15;
    ddp_interest_rec.status_code := p5_a16;
    ddp_interest_rec.status := p5_a17;
    ddp_interest_rec.description := p5_a18;
    ddp_interest_rec.attribute_category := p5_a19;
    ddp_interest_rec.attribute1 := p5_a20;
    ddp_interest_rec.attribute2 := p5_a21;
    ddp_interest_rec.attribute3 := p5_a22;
    ddp_interest_rec.attribute4 := p5_a23;
    ddp_interest_rec.attribute5 := p5_a24;
    ddp_interest_rec.attribute6 := p5_a25;
    ddp_interest_rec.attribute7 := p5_a26;
    ddp_interest_rec.attribute8 := p5_a27;
    ddp_interest_rec.attribute9 := p5_a28;
    ddp_interest_rec.attribute10 := p5_a29;
    ddp_interest_rec.attribute11 := p5_a30;
    ddp_interest_rec.attribute12 := p5_a31;
    ddp_interest_rec.attribute13 := p5_a32;
    ddp_interest_rec.attribute14 := p5_a33;
    ddp_interest_rec.attribute15 := p5_a34;
    ddp_interest_rec.product_category_id := rosetta_g_miss_num_map(p5_a35);
    ddp_interest_rec.product_cat_set_id := rosetta_g_miss_num_map(p5_a36);





    ddp_access_profile_rec.cust_access_profile_value := p10_a0;
    ddp_access_profile_rec.lead_access_profile_value := p10_a1;
    ddp_access_profile_rec.opp_access_profile_value := p10_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p10_a3;
    ddp_access_profile_rec.admin_update_profile_value := p10_a4;





    -- here's the delegated call to the old PL/SQL routine
    as_interest_pub.update_interest(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_interest_rec,
      p_interest_use_code,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      ddp_access_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_interest_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure delete_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_interest_rec as_interest_pub.interest_rec_type;
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_interest_rec.interest_id := rosetta_g_miss_num_map(p5_a0);
    ddp_interest_rec.customer_id := rosetta_g_miss_num_map(p5_a1);
    ddp_interest_rec.address_id := rosetta_g_miss_num_map(p5_a2);
    ddp_interest_rec.contact_id := rosetta_g_miss_num_map(p5_a3);
    ddp_interest_rec.lead_id := rosetta_g_miss_num_map(p5_a4);
    ddp_interest_rec.interest_type_id := rosetta_g_miss_num_map(p5_a5);
    ddp_interest_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_interest_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_interest_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_interest_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_interest_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);
    ddp_interest_rec.interest_type := p5_a11;
    ddp_interest_rec.primary_interest_code_id := rosetta_g_miss_num_map(p5_a12);
    ddp_interest_rec.primary_interest_code := p5_a13;
    ddp_interest_rec.secondary_interest_code_id := rosetta_g_miss_num_map(p5_a14);
    ddp_interest_rec.secondary_interest_code := p5_a15;
    ddp_interest_rec.status_code := p5_a16;
    ddp_interest_rec.status := p5_a17;
    ddp_interest_rec.description := p5_a18;
    ddp_interest_rec.attribute_category := p5_a19;
    ddp_interest_rec.attribute1 := p5_a20;
    ddp_interest_rec.attribute2 := p5_a21;
    ddp_interest_rec.attribute3 := p5_a22;
    ddp_interest_rec.attribute4 := p5_a23;
    ddp_interest_rec.attribute5 := p5_a24;
    ddp_interest_rec.attribute6 := p5_a25;
    ddp_interest_rec.attribute7 := p5_a26;
    ddp_interest_rec.attribute8 := p5_a27;
    ddp_interest_rec.attribute9 := p5_a28;
    ddp_interest_rec.attribute10 := p5_a29;
    ddp_interest_rec.attribute11 := p5_a30;
    ddp_interest_rec.attribute12 := p5_a31;
    ddp_interest_rec.attribute13 := p5_a32;
    ddp_interest_rec.attribute14 := p5_a33;
    ddp_interest_rec.attribute15 := p5_a34;
    ddp_interest_rec.product_category_id := rosetta_g_miss_num_map(p5_a35);
    ddp_interest_rec.product_cat_set_id := rosetta_g_miss_num_map(p5_a36);





    ddp_access_profile_rec.cust_access_profile_value := p10_a0;
    ddp_access_profile_rec.lead_access_profile_value := p10_a1;
    ddp_access_profile_rec.opp_access_profile_value := p10_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p10_a3;
    ddp_access_profile_rec.admin_update_profile_value := p10_a4;




    -- here's the delegated call to the old PL/SQL routine
    as_interest_pub.delete_interest(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_interest_rec,
      p_interest_use_code,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      ddp_access_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

end as_interest_pub_w;

/
