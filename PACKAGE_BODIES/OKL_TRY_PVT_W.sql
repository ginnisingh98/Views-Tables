--------------------------------------------------------
--  DDL for Package Body OKL_TRY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRY_PVT_W" as
  /* $Header: OKLITRYB.pls 120.2 2005/07/15 07:40:21 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_try_pvt.try_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).try_id_for := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).ilc_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).aep_code := a4(indx);
          t(ddindx).try_type := a5(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).trx_type_class := a13(indx);
          t(ddindx).tax_upfront_yn := a14(indx);
          t(ddindx).tax_invoice_yn := a15(indx);
          t(ddindx).tax_schedule_yn := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_try_pvt.try_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).try_id_for);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).ilc_id);
          a4(indx) := t(ddindx).aep_code;
          a5(indx) := t(ddindx).try_type;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a13(indx) := t(ddindx).trx_type_class;
          a14(indx) := t(ddindx).tax_upfront_yn;
          a15(indx) := t(ddindx).tax_invoice_yn;
          a16(indx) := t(ddindx).tax_schedule_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_try_pvt.okl_trx_types_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).name := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).contract_header_line_flag := a6(indx);
          t(ddindx).transaction_header_line_detail := a7(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_try_pvt.okl_trx_types_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).name;
          a5(indx) := t(ddindx).description;
          a6(indx) := t(ddindx).contract_header_line_flag;
          a7(indx) := t(ddindx).transaction_header_line_detail;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_try_pvt.tryv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).aep_code := a3(indx);
          t(ddindx).ilc_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).try_id_for := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).try_type := a7(indx);
          t(ddindx).name := a8(indx);
          t(ddindx).description := a9(indx);
          t(ddindx).contract_header_line_flag := a10(indx);
          t(ddindx).transaction_header_line_detail := a11(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).trx_type_class := a18(indx);
          t(ddindx).tax_upfront_yn := a19(indx);
          t(ddindx).tax_invoice_yn := a20(indx);
          t(ddindx).tax_schedule_yn := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_try_pvt.tryv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).aep_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).ilc_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).try_id_for);
          a7(indx) := t(ddindx).try_type;
          a8(indx) := t(ddindx).name;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).contract_header_line_flag;
          a11(indx) := t(ddindx).transaction_header_line_detail;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a18(indx) := t(ddindx).trx_type_class;
          a19(indx) := t(ddindx).tax_upfront_yn;
          a20(indx) := t(ddindx).tax_invoice_yn;
          a21(indx) := t(ddindx).tax_schedule_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tryv_rec okl_try_pvt.tryv_rec_type;
    ddx_tryv_rec okl_try_pvt.tryv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tryv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tryv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tryv_rec.sfwt_flag := p5_a2;
    ddp_tryv_rec.aep_code := p5_a3;
    ddp_tryv_rec.ilc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tryv_rec.try_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tryv_rec.try_id_for := rosetta_g_miss_num_map(p5_a6);
    ddp_tryv_rec.try_type := p5_a7;
    ddp_tryv_rec.name := p5_a8;
    ddp_tryv_rec.description := p5_a9;
    ddp_tryv_rec.contract_header_line_flag := p5_a10;
    ddp_tryv_rec.transaction_header_line_detail := p5_a11;
    ddp_tryv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tryv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_tryv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tryv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_tryv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tryv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_tryv_rec.trx_type_class := p5_a18;
    ddp_tryv_rec.tax_upfront_yn := p5_a19;
    ddp_tryv_rec.tax_invoice_yn := p5_a20;
    ddp_tryv_rec.tax_schedule_yn := p5_a21;


    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_rec,
      ddx_tryv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tryv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tryv_rec.object_version_number);
    p6_a2 := ddx_tryv_rec.sfwt_flag;
    p6_a3 := ddx_tryv_rec.aep_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tryv_rec.ilc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tryv_rec.try_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tryv_rec.try_id_for);
    p6_a7 := ddx_tryv_rec.try_type;
    p6_a8 := ddx_tryv_rec.name;
    p6_a9 := ddx_tryv_rec.description;
    p6_a10 := ddx_tryv_rec.contract_header_line_flag;
    p6_a11 := ddx_tryv_rec.transaction_header_line_detail;
    p6_a12 := rosetta_g_miss_num_map(ddx_tryv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tryv_rec.created_by);
    p6_a14 := ddx_tryv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_tryv_rec.last_updated_by);
    p6_a16 := ddx_tryv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_tryv_rec.last_update_login);
    p6_a18 := ddx_tryv_rec.trx_type_class;
    p6_a19 := ddx_tryv_rec.tax_upfront_yn;
    p6_a20 := ddx_tryv_rec.tax_invoice_yn;
    p6_a21 := ddx_tryv_rec.tax_schedule_yn;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddx_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_try_pvt_w.rosetta_table_copy_in_p8(ddp_tryv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_tbl,
      ddx_tryv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_try_pvt_w.rosetta_table_copy_out_p8(ddx_tryv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tryv_rec okl_try_pvt.tryv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tryv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tryv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tryv_rec.sfwt_flag := p5_a2;
    ddp_tryv_rec.aep_code := p5_a3;
    ddp_tryv_rec.ilc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tryv_rec.try_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tryv_rec.try_id_for := rosetta_g_miss_num_map(p5_a6);
    ddp_tryv_rec.try_type := p5_a7;
    ddp_tryv_rec.name := p5_a8;
    ddp_tryv_rec.description := p5_a9;
    ddp_tryv_rec.contract_header_line_flag := p5_a10;
    ddp_tryv_rec.transaction_header_line_detail := p5_a11;
    ddp_tryv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tryv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_tryv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tryv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_tryv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tryv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_tryv_rec.trx_type_class := p5_a18;
    ddp_tryv_rec.tax_upfront_yn := p5_a19;
    ddp_tryv_rec.tax_invoice_yn := p5_a20;
    ddp_tryv_rec.tax_schedule_yn := p5_a21;

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_try_pvt_w.rosetta_table_copy_in_p8(ddp_tryv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tryv_rec okl_try_pvt.tryv_rec_type;
    ddx_tryv_rec okl_try_pvt.tryv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tryv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tryv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tryv_rec.sfwt_flag := p5_a2;
    ddp_tryv_rec.aep_code := p5_a3;
    ddp_tryv_rec.ilc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tryv_rec.try_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tryv_rec.try_id_for := rosetta_g_miss_num_map(p5_a6);
    ddp_tryv_rec.try_type := p5_a7;
    ddp_tryv_rec.name := p5_a8;
    ddp_tryv_rec.description := p5_a9;
    ddp_tryv_rec.contract_header_line_flag := p5_a10;
    ddp_tryv_rec.transaction_header_line_detail := p5_a11;
    ddp_tryv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tryv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_tryv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tryv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_tryv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tryv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_tryv_rec.trx_type_class := p5_a18;
    ddp_tryv_rec.tax_upfront_yn := p5_a19;
    ddp_tryv_rec.tax_invoice_yn := p5_a20;
    ddp_tryv_rec.tax_schedule_yn := p5_a21;


    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_rec,
      ddx_tryv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tryv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tryv_rec.object_version_number);
    p6_a2 := ddx_tryv_rec.sfwt_flag;
    p6_a3 := ddx_tryv_rec.aep_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tryv_rec.ilc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tryv_rec.try_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tryv_rec.try_id_for);
    p6_a7 := ddx_tryv_rec.try_type;
    p6_a8 := ddx_tryv_rec.name;
    p6_a9 := ddx_tryv_rec.description;
    p6_a10 := ddx_tryv_rec.contract_header_line_flag;
    p6_a11 := ddx_tryv_rec.transaction_header_line_detail;
    p6_a12 := rosetta_g_miss_num_map(ddx_tryv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tryv_rec.created_by);
    p6_a14 := ddx_tryv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_tryv_rec.last_updated_by);
    p6_a16 := ddx_tryv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_tryv_rec.last_update_login);
    p6_a18 := ddx_tryv_rec.trx_type_class;
    p6_a19 := ddx_tryv_rec.tax_upfront_yn;
    p6_a20 := ddx_tryv_rec.tax_invoice_yn;
    p6_a21 := ddx_tryv_rec.tax_schedule_yn;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddx_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_try_pvt_w.rosetta_table_copy_in_p8(ddp_tryv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_tbl,
      ddx_tryv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_try_pvt_w.rosetta_table_copy_out_p8(ddx_tryv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tryv_rec okl_try_pvt.tryv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tryv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tryv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tryv_rec.sfwt_flag := p5_a2;
    ddp_tryv_rec.aep_code := p5_a3;
    ddp_tryv_rec.ilc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tryv_rec.try_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tryv_rec.try_id_for := rosetta_g_miss_num_map(p5_a6);
    ddp_tryv_rec.try_type := p5_a7;
    ddp_tryv_rec.name := p5_a8;
    ddp_tryv_rec.description := p5_a9;
    ddp_tryv_rec.contract_header_line_flag := p5_a10;
    ddp_tryv_rec.transaction_header_line_detail := p5_a11;
    ddp_tryv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tryv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_tryv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tryv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_tryv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tryv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_tryv_rec.trx_type_class := p5_a18;
    ddp_tryv_rec.tax_upfront_yn := p5_a19;
    ddp_tryv_rec.tax_invoice_yn := p5_a20;
    ddp_tryv_rec.tax_schedule_yn := p5_a21;

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_try_pvt_w.rosetta_table_copy_in_p8(ddp_tryv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tryv_rec okl_try_pvt.tryv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tryv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tryv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tryv_rec.sfwt_flag := p5_a2;
    ddp_tryv_rec.aep_code := p5_a3;
    ddp_tryv_rec.ilc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tryv_rec.try_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tryv_rec.try_id_for := rosetta_g_miss_num_map(p5_a6);
    ddp_tryv_rec.try_type := p5_a7;
    ddp_tryv_rec.name := p5_a8;
    ddp_tryv_rec.description := p5_a9;
    ddp_tryv_rec.contract_header_line_flag := p5_a10;
    ddp_tryv_rec.transaction_header_line_detail := p5_a11;
    ddp_tryv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tryv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_tryv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tryv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_tryv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tryv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_tryv_rec.trx_type_class := p5_a18;
    ddp_tryv_rec.tax_upfront_yn := p5_a19;
    ddp_tryv_rec.tax_invoice_yn := p5_a20;
    ddp_tryv_rec.tax_schedule_yn := p5_a21;

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tryv_tbl okl_try_pvt.tryv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_try_pvt_w.rosetta_table_copy_in_p8(ddp_tryv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_try_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tryv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_try_pvt_w;

/
