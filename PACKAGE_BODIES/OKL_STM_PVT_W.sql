--------------------------------------------------------
--  DDL for Package Body OKL_STM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STM_PVT_W" as
  /* $Header: OKLISTMB.pls 120.2 2005/10/30 04:18:37 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy okl_stm_pvt.stm_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).sty_id := a1(indx);
          t(ddindx).khr_id := a2(indx);
          t(ddindx).kle_id := a3(indx);
          t(ddindx).sgn_code := a4(indx);
          t(ddindx).say_code := a5(indx);
          t(ddindx).transaction_number := a6(indx);
          t(ddindx).active_yn := a7(indx);
          t(ddindx).object_version_number := a8(indx);
          t(ddindx).created_by := a9(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := a11(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).date_current := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).date_working := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).date_history := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).comments := a16(indx);
          t(ddindx).program_id := a17(indx);
          t(ddindx).request_id := a18(indx);
          t(ddindx).program_application_id := a19(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_update_login := a21(indx);
          t(ddindx).purpose_code := a22(indx);
          t(ddindx).stm_id := a23(indx);
          t(ddindx).source_id := a24(indx);
          t(ddindx).source_table := a25(indx);
          t(ddindx).trx_id := a26(indx);
          t(ddindx).link_hist_stream_id := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_stm_pvt.stm_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).sty_id;
          a2(indx) := t(ddindx).khr_id;
          a3(indx) := t(ddindx).kle_id;
          a4(indx) := t(ddindx).sgn_code;
          a5(indx) := t(ddindx).say_code;
          a6(indx) := t(ddindx).transaction_number;
          a7(indx) := t(ddindx).active_yn;
          a8(indx) := t(ddindx).object_version_number;
          a9(indx) := t(ddindx).created_by;
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := t(ddindx).last_updated_by;
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := t(ddindx).date_current;
          a14(indx) := t(ddindx).date_working;
          a15(indx) := t(ddindx).date_history;
          a16(indx) := t(ddindx).comments;
          a17(indx) := t(ddindx).program_id;
          a18(indx) := t(ddindx).request_id;
          a19(indx) := t(ddindx).program_application_id;
          a20(indx) := t(ddindx).program_update_date;
          a21(indx) := t(ddindx).last_update_login;
          a22(indx) := t(ddindx).purpose_code;
          a23(indx) := t(ddindx).stm_id;
          a24(indx) := t(ddindx).source_id;
          a25(indx) := t(ddindx).source_table;
          a26(indx) := t(ddindx).trx_id;
          a27(indx) := t(ddindx).link_hist_stream_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_stm_pvt.stmv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).sty_id := a1(indx);
          t(ddindx).khr_id := a2(indx);
          t(ddindx).kle_id := a3(indx);
          t(ddindx).sgn_code := a4(indx);
          t(ddindx).say_code := a5(indx);
          t(ddindx).transaction_number := a6(indx);
          t(ddindx).active_yn := a7(indx);
          t(ddindx).object_version_number := a8(indx);
          t(ddindx).created_by := a9(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := a11(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).date_current := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).date_working := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).date_history := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).comments := a16(indx);
          t(ddindx).program_id := a17(indx);
          t(ddindx).request_id := a18(indx);
          t(ddindx).program_application_id := a19(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_update_login := a21(indx);
          t(ddindx).purpose_code := a22(indx);
          t(ddindx).stm_id := a23(indx);
          t(ddindx).source_id := a24(indx);
          t(ddindx).source_table := a25(indx);
          t(ddindx).trx_id := a26(indx);
          t(ddindx).link_hist_stream_id := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_stm_pvt.stmv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).sty_id;
          a2(indx) := t(ddindx).khr_id;
          a3(indx) := t(ddindx).kle_id;
          a4(indx) := t(ddindx).sgn_code;
          a5(indx) := t(ddindx).say_code;
          a6(indx) := t(ddindx).transaction_number;
          a7(indx) := t(ddindx).active_yn;
          a8(indx) := t(ddindx).object_version_number;
          a9(indx) := t(ddindx).created_by;
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := t(ddindx).last_updated_by;
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := t(ddindx).date_current;
          a14(indx) := t(ddindx).date_working;
          a15(indx) := t(ddindx).date_history;
          a16(indx) := t(ddindx).comments;
          a17(indx) := t(ddindx).program_id;
          a18(indx) := t(ddindx).request_id;
          a19(indx) := t(ddindx).program_application_id;
          a20(indx) := t(ddindx).program_update_date;
          a21(indx) := t(ddindx).last_update_login;
          a22(indx) := t(ddindx).purpose_code;
          a23(indx) := t(ddindx).stm_id;
          a24(indx) := t(ddindx).source_id;
          a25(indx) := t(ddindx).source_table;
          a26(indx) := t(ddindx).trx_id;
          a27(indx) := t(ddindx).link_hist_stream_id;
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
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
  )

  as
    ddp_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddx_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := p5_a0;
    ddp_stmv_rec.sty_id := p5_a1;
    ddp_stmv_rec.khr_id := p5_a2;
    ddp_stmv_rec.kle_id := p5_a3;
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := p5_a6;
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := p5_a8;
    ddp_stmv_rec.created_by := p5_a9;
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := p5_a11;
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := p5_a17;
    ddp_stmv_rec.request_id := p5_a18;
    ddp_stmv_rec.program_application_id := p5_a19;
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := p5_a21;
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := p5_a23;
    ddp_stmv_rec.source_id := p5_a24;
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := p5_a26;
    ddp_stmv_rec.link_hist_stream_id := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddx_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_stmv_rec.id;
    p6_a1 := ddx_stmv_rec.sty_id;
    p6_a2 := ddx_stmv_rec.khr_id;
    p6_a3 := ddx_stmv_rec.kle_id;
    p6_a4 := ddx_stmv_rec.sgn_code;
    p6_a5 := ddx_stmv_rec.say_code;
    p6_a6 := ddx_stmv_rec.transaction_number;
    p6_a7 := ddx_stmv_rec.active_yn;
    p6_a8 := ddx_stmv_rec.object_version_number;
    p6_a9 := ddx_stmv_rec.created_by;
    p6_a10 := ddx_stmv_rec.creation_date;
    p6_a11 := ddx_stmv_rec.last_updated_by;
    p6_a12 := ddx_stmv_rec.last_update_date;
    p6_a13 := ddx_stmv_rec.date_current;
    p6_a14 := ddx_stmv_rec.date_working;
    p6_a15 := ddx_stmv_rec.date_history;
    p6_a16 := ddx_stmv_rec.comments;
    p6_a17 := ddx_stmv_rec.program_id;
    p6_a18 := ddx_stmv_rec.request_id;
    p6_a19 := ddx_stmv_rec.program_application_id;
    p6_a20 := ddx_stmv_rec.program_update_date;
    p6_a21 := ddx_stmv_rec.last_update_login;
    p6_a22 := ddx_stmv_rec.purpose_code;
    p6_a23 := ddx_stmv_rec.stm_id;
    p6_a24 := ddx_stmv_rec.source_id;
    p6_a25 := ddx_stmv_rec.source_table;
    p6_a26 := ddx_stmv_rec.trx_id;
    p6_a27 := ddx_stmv_rec.link_hist_stream_id;
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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddx_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
      , p5_a25
      , p5_a26
      , p5_a27
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddx_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p6_a0
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
      , p6_a25
      , p6_a26
      , p6_a27
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
  )

  as
    ddp_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := p5_a0;
    ddp_stmv_rec.sty_id := p5_a1;
    ddp_stmv_rec.khr_id := p5_a2;
    ddp_stmv_rec.kle_id := p5_a3;
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := p5_a6;
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := p5_a8;
    ddp_stmv_rec.created_by := p5_a9;
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := p5_a11;
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := p5_a17;
    ddp_stmv_rec.request_id := p5_a18;
    ddp_stmv_rec.program_application_id := p5_a19;
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := p5_a21;
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := p5_a23;
    ddp_stmv_rec.source_id := p5_a24;
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := p5_a26;
    ddp_stmv_rec.link_hist_stream_id := p5_a27;

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
      , p5_a25
      , p5_a26
      , p5_a27
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
  )

  as
    ddp_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddx_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := p5_a0;
    ddp_stmv_rec.sty_id := p5_a1;
    ddp_stmv_rec.khr_id := p5_a2;
    ddp_stmv_rec.kle_id := p5_a3;
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := p5_a6;
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := p5_a8;
    ddp_stmv_rec.created_by := p5_a9;
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := p5_a11;
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := p5_a17;
    ddp_stmv_rec.request_id := p5_a18;
    ddp_stmv_rec.program_application_id := p5_a19;
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := p5_a21;
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := p5_a23;
    ddp_stmv_rec.source_id := p5_a24;
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := p5_a26;
    ddp_stmv_rec.link_hist_stream_id := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddx_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_stmv_rec.id;
    p6_a1 := ddx_stmv_rec.sty_id;
    p6_a2 := ddx_stmv_rec.khr_id;
    p6_a3 := ddx_stmv_rec.kle_id;
    p6_a4 := ddx_stmv_rec.sgn_code;
    p6_a5 := ddx_stmv_rec.say_code;
    p6_a6 := ddx_stmv_rec.transaction_number;
    p6_a7 := ddx_stmv_rec.active_yn;
    p6_a8 := ddx_stmv_rec.object_version_number;
    p6_a9 := ddx_stmv_rec.created_by;
    p6_a10 := ddx_stmv_rec.creation_date;
    p6_a11 := ddx_stmv_rec.last_updated_by;
    p6_a12 := ddx_stmv_rec.last_update_date;
    p6_a13 := ddx_stmv_rec.date_current;
    p6_a14 := ddx_stmv_rec.date_working;
    p6_a15 := ddx_stmv_rec.date_history;
    p6_a16 := ddx_stmv_rec.comments;
    p6_a17 := ddx_stmv_rec.program_id;
    p6_a18 := ddx_stmv_rec.request_id;
    p6_a19 := ddx_stmv_rec.program_application_id;
    p6_a20 := ddx_stmv_rec.program_update_date;
    p6_a21 := ddx_stmv_rec.last_update_login;
    p6_a22 := ddx_stmv_rec.purpose_code;
    p6_a23 := ddx_stmv_rec.stm_id;
    p6_a24 := ddx_stmv_rec.source_id;
    p6_a25 := ddx_stmv_rec.source_table;
    p6_a26 := ddx_stmv_rec.trx_id;
    p6_a27 := ddx_stmv_rec.link_hist_stream_id;
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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddx_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
      , p5_a25
      , p5_a26
      , p5_a27
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddx_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p6_a0
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
      , p6_a25
      , p6_a26
      , p6_a27
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
  )

  as
    ddp_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := p5_a0;
    ddp_stmv_rec.sty_id := p5_a1;
    ddp_stmv_rec.khr_id := p5_a2;
    ddp_stmv_rec.kle_id := p5_a3;
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := p5_a6;
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := p5_a8;
    ddp_stmv_rec.created_by := p5_a9;
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := p5_a11;
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := p5_a17;
    ddp_stmv_rec.request_id := p5_a18;
    ddp_stmv_rec.program_application_id := p5_a19;
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := p5_a21;
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := p5_a23;
    ddp_stmv_rec.source_id := p5_a24;
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := p5_a26;
    ddp_stmv_rec.link_hist_stream_id := p5_a27;

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
      , p5_a25
      , p5_a26
      , p5_a27
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
  )

  as
    ddp_stmv_rec okl_stm_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := p5_a0;
    ddp_stmv_rec.sty_id := p5_a1;
    ddp_stmv_rec.khr_id := p5_a2;
    ddp_stmv_rec.kle_id := p5_a3;
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := p5_a6;
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := p5_a8;
    ddp_stmv_rec.created_by := p5_a9;
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := p5_a11;
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := p5_a17;
    ddp_stmv_rec.request_id := p5_a18;
    ddp_stmv_rec.program_application_id := p5_a19;
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := p5_a21;
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := p5_a23;
    ddp_stmv_rec.source_id := p5_a24;
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := p5_a26;
    ddp_stmv_rec.link_hist_stream_id := p5_a27;

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_stm_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
      , p5_a25
      , p5_a26
      , p5_a27
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_stm_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_stm_pvt_w;

/
