--------------------------------------------------------
--  DDL for Package Body OKL_SEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEL_PVT_W" as
  /* $Header: OKLISELB.pls 120.2 2005/06/24 03:14:44 hkpatel noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sel_pvt.sel_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).stm_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).stream_element_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).comments := a5(indx);
          t(ddindx).accrued_yn := a6(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).se_line_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).date_billed := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).sel_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).source_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).source_table := a20(indx);
          t(ddindx).bill_adj_flag := a21(indx);
          t(ddindx).accrual_adj_flag := a22(indx);
          t(ddindx).date_disbursed := rosetta_g_miss_date_in_map(a23(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sel_pvt.sel_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).stm_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).stream_element_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a5(indx) := t(ddindx).comments;
          a6(indx) := t(ddindx).accrued_yn;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a10(indx) := t(ddindx).program_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).se_line_number);
          a12(indx) := t(ddindx).date_billed;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).sel_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).source_id);
          a20(indx) := t(ddindx).source_table;
          a21(indx) := t(ddindx).bill_adj_flag;
          a22(indx) := t(ddindx).accrual_adj_flag;
          a23(indx) := t(ddindx).date_disbursed;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sel_pvt.selv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_DATE_TABLE
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
          t(ddindx).stm_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).comments := a4(indx);
          t(ddindx).accrued_yn := a5(indx);
          t(ddindx).stream_element_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).se_line_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).date_billed := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).parent_index := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).sel_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).source_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).source_table := a21(indx);
          t(ddindx).bill_adj_flag := a22(indx);
          t(ddindx).accrual_adj_flag := a23(indx);
          t(ddindx).date_disbursed := rosetta_g_miss_date_in_map(a24(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sel_pvt.selv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).stm_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a4(indx) := t(ddindx).comments;
          a5(indx) := t(ddindx).accrued_yn;
          a6(indx) := t(ddindx).stream_element_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a10(indx) := t(ddindx).program_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).se_line_number);
          a12(indx) := t(ddindx).date_billed;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).parent_index);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).sel_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).source_id);
          a21(indx) := t(ddindx).source_table;
          a22(indx) := t(ddindx).bill_adj_flag;
          a23(indx) := t(ddindx).accrual_adj_flag;
          a24(indx) := t(ddindx).date_disbursed;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_sel_pvt.selv_rec_type;
    ddx_selv_rec okl_sel_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);


    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec,
      ddx_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_selv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_selv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_selv_rec.stm_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_selv_rec.amount);
    p6_a4 := ddx_selv_rec.comments;
    p6_a5 := ddx_selv_rec.accrued_yn;
    p6_a6 := ddx_selv_rec.stream_element_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_selv_rec.program_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_selv_rec.request_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_selv_rec.program_application_id);
    p6_a10 := ddx_selv_rec.program_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_selv_rec.se_line_number);
    p6_a12 := ddx_selv_rec.date_billed;
    p6_a13 := rosetta_g_miss_num_map(ddx_selv_rec.created_by);
    p6_a14 := ddx_selv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_selv_rec.last_updated_by);
    p6_a16 := ddx_selv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_selv_rec.last_update_login);
    p6_a18 := rosetta_g_miss_num_map(ddx_selv_rec.parent_index);
    p6_a19 := rosetta_g_miss_num_map(ddx_selv_rec.sel_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_selv_rec.source_id);
    p6_a21 := ddx_selv_rec.source_table;
    p6_a22 := ddx_selv_rec.bill_adj_flag;
    p6_a23 := ddx_selv_rec.accrual_adj_flag;
    p6_a24 := ddx_selv_rec.date_disbursed;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddx_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      , p5_a22
      , p5_a23
      , p5_a24
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p6_a0
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
      , p6_a22
      , p6_a23
      , p6_a24
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_sel_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      , p5_a22
      , p5_a23
      , p5_a24
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_sel_pvt.selv_rec_type;
    ddx_selv_rec okl_sel_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);


    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec,
      ddx_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_selv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_selv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_selv_rec.stm_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_selv_rec.amount);
    p6_a4 := ddx_selv_rec.comments;
    p6_a5 := ddx_selv_rec.accrued_yn;
    p6_a6 := ddx_selv_rec.stream_element_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_selv_rec.program_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_selv_rec.request_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_selv_rec.program_application_id);
    p6_a10 := ddx_selv_rec.program_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_selv_rec.se_line_number);
    p6_a12 := ddx_selv_rec.date_billed;
    p6_a13 := rosetta_g_miss_num_map(ddx_selv_rec.created_by);
    p6_a14 := ddx_selv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_selv_rec.last_updated_by);
    p6_a16 := ddx_selv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_selv_rec.last_update_login);
    p6_a18 := rosetta_g_miss_num_map(ddx_selv_rec.parent_index);
    p6_a19 := rosetta_g_miss_num_map(ddx_selv_rec.sel_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_selv_rec.source_id);
    p6_a21 := ddx_selv_rec.source_table;
    p6_a22 := ddx_selv_rec.bill_adj_flag;
    p6_a23 := ddx_selv_rec.accrual_adj_flag;
    p6_a24 := ddx_selv_rec.date_disbursed;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddx_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      , p5_a22
      , p5_a23
      , p5_a24
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p6_a0
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
      , p6_a22
      , p6_a23
      , p6_a24
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_sel_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      , p5_a22
      , p5_a23
      , p5_a24
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_sel_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_sel_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      , p5_a22
      , p5_a23
      , p5_a24
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sel_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sel_pvt_w;

/
