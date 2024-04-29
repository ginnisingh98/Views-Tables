--------------------------------------------------------
--  DDL for Package Body OKL_BCT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BCT_PVT_W" as
  /* $Header: OKLEBCTB.pls 120.0 2007/05/17 16:55:53 hariven noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_bct_pvt.okl_bct_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).user_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).batch_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).processing_srl_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).program_name := a5(indx);
          t(ddindx).prog_short_name := a6(indx);
          t(ddindx).conc_req_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).progress_status := a8(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).active_flag := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_bct_pvt.okl_bct_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).user_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).batch_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).processing_srl_number);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a5(indx) := t(ddindx).program_name;
          a6(indx) := t(ddindx).prog_short_name;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).conc_req_id);
          a8(indx) := t(ddindx).progress_status;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a14(indx) := t(ddindx).active_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_bct_rec okl_bct_pvt.okl_bct_rec;
    ddx_bct_rec okl_bct_pvt.okl_bct_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_bct_rec.user_id := rosetta_g_miss_num_map(p5_a0);
    ddp_bct_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_bct_rec.batch_number := rosetta_g_miss_num_map(p5_a2);
    ddp_bct_rec.processing_srl_number := rosetta_g_miss_num_map(p5_a3);
    ddp_bct_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_bct_rec.program_name := p5_a5;
    ddp_bct_rec.prog_short_name := p5_a6;
    ddp_bct_rec.conc_req_id := rosetta_g_miss_num_map(p5_a7);
    ddp_bct_rec.progress_status := p5_a8;
    ddp_bct_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_bct_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_bct_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_bct_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_bct_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_bct_rec.active_flag := p5_a14;


    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_rec,
      ddx_bct_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_bct_rec.user_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_bct_rec.org_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_bct_rec.batch_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_bct_rec.processing_srl_number);
    p6_a4 := rosetta_g_miss_num_map(ddx_bct_rec.khr_id);
    p6_a5 := ddx_bct_rec.program_name;
    p6_a6 := ddx_bct_rec.prog_short_name;
    p6_a7 := rosetta_g_miss_num_map(ddx_bct_rec.conc_req_id);
    p6_a8 := ddx_bct_rec.progress_status;
    p6_a9 := rosetta_g_miss_num_map(ddx_bct_rec.created_by);
    p6_a10 := ddx_bct_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_bct_rec.last_updated_by);
    p6_a12 := ddx_bct_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_bct_rec.last_update_login);
    p6_a14 := ddx_bct_rec.active_flag;
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_bct_tbl okl_bct_pvt.okl_bct_tbl;
    ddx_bct_tbl okl_bct_pvt.okl_bct_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_bct_pvt_w.rosetta_table_copy_in_p1(ddp_bct_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_tbl,
      ddx_bct_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_bct_pvt_w.rosetta_table_copy_out_p1(ddx_bct_tbl, p6_a0
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
      );
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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_bct_rec okl_bct_pvt.okl_bct_rec;
    ddx_bct_rec okl_bct_pvt.okl_bct_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_bct_rec.user_id := rosetta_g_miss_num_map(p5_a0);
    ddp_bct_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_bct_rec.batch_number := rosetta_g_miss_num_map(p5_a2);
    ddp_bct_rec.processing_srl_number := rosetta_g_miss_num_map(p5_a3);
    ddp_bct_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_bct_rec.program_name := p5_a5;
    ddp_bct_rec.prog_short_name := p5_a6;
    ddp_bct_rec.conc_req_id := rosetta_g_miss_num_map(p5_a7);
    ddp_bct_rec.progress_status := p5_a8;
    ddp_bct_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_bct_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_bct_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_bct_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_bct_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_bct_rec.active_flag := p5_a14;


    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_rec,
      ddx_bct_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_bct_rec.user_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_bct_rec.org_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_bct_rec.batch_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_bct_rec.processing_srl_number);
    p6_a4 := rosetta_g_miss_num_map(ddx_bct_rec.khr_id);
    p6_a5 := ddx_bct_rec.program_name;
    p6_a6 := ddx_bct_rec.prog_short_name;
    p6_a7 := rosetta_g_miss_num_map(ddx_bct_rec.conc_req_id);
    p6_a8 := ddx_bct_rec.progress_status;
    p6_a9 := rosetta_g_miss_num_map(ddx_bct_rec.created_by);
    p6_a10 := ddx_bct_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_bct_rec.last_updated_by);
    p6_a12 := ddx_bct_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_bct_rec.last_update_login);
    p6_a14 := ddx_bct_rec.active_flag;
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_bct_tbl okl_bct_pvt.okl_bct_tbl;
    ddx_bct_tbl okl_bct_pvt.okl_bct_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_bct_pvt_w.rosetta_table_copy_in_p1(ddp_bct_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_tbl,
      ddx_bct_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_bct_pvt_w.rosetta_table_copy_out_p1(ddx_bct_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_bct_rec okl_bct_pvt.okl_bct_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_bct_rec.user_id := rosetta_g_miss_num_map(p5_a0);
    ddp_bct_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_bct_rec.batch_number := rosetta_g_miss_num_map(p5_a2);
    ddp_bct_rec.processing_srl_number := rosetta_g_miss_num_map(p5_a3);
    ddp_bct_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_bct_rec.program_name := p5_a5;
    ddp_bct_rec.prog_short_name := p5_a6;
    ddp_bct_rec.conc_req_id := rosetta_g_miss_num_map(p5_a7);
    ddp_bct_rec.progress_status := p5_a8;
    ddp_bct_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_bct_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_bct_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_bct_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_bct_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_bct_rec.active_flag := p5_a14;

    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_bct_tbl okl_bct_pvt.okl_bct_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_bct_pvt_w.rosetta_table_copy_in_p1(ddp_bct_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_bct_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bct_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_bct_pvt_w;

/
