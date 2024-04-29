--------------------------------------------------------
--  DDL for Package Body OKL_PERD_STATUS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PERD_STATUS_PVT_W" as
  /* $Header: OKLEPSMB.pls 120.1 2005/07/11 14:19:25 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_perd_status_pvt.period_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).application_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).period_name := a2(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).closing_status := a5(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).period_type := a8(indx);
          t(ddindx).period_year := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).period_num := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).quarter_num := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).adjustment_period_flag := a12(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).attribute1 := a16(indx);
          t(ddindx).attribute2 := a17(indx);
          t(ddindx).attribute3 := a18(indx);
          t(ddindx).attribute4 := a19(indx);
          t(ddindx).attribute5 := a20(indx);
          t(ddindx).context := a21(indx);
          t(ddindx).year_start_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).quarter_start_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).effective_period_num := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).elimination_confirmed_flag := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_perd_status_pvt.period_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a2(indx) := t(ddindx).period_name;
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a5(indx) := t(ddindx).closing_status;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          a8(indx) := t(ddindx).period_type;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).period_year);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).period_num);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).quarter_num);
          a12(indx) := t(ddindx).adjustment_period_flag;
          a13(indx) := t(ddindx).creation_date;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a16(indx) := t(ddindx).attribute1;
          a17(indx) := t(ddindx).attribute2;
          a18(indx) := t(ddindx).attribute3;
          a19(indx) := t(ddindx).attribute4;
          a20(indx) := t(ddindx).attribute5;
          a21(indx) := t(ddindx).context;
          a22(indx) := t(ddindx).year_start_date;
          a23(indx) := t(ddindx).quarter_start_date;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).effective_period_num);
          a25(indx) := t(ddindx).elimination_confirmed_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure search_period_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_period_rec okl_perd_status_pvt.period_rec_type;
    ddx_period_tbl okl_perd_status_pvt.period_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_period_rec.application_id := rosetta_g_miss_num_map(p5_a0);
    ddp_period_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a1);
    ddp_period_rec.period_name := p5_a2;
    ddp_period_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_period_rec.last_updated_by := rosetta_g_miss_num_map(p5_a4);
    ddp_period_rec.closing_status := p5_a5;
    ddp_period_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_period_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_period_rec.period_type := p5_a8;
    ddp_period_rec.period_year := rosetta_g_miss_num_map(p5_a9);
    ddp_period_rec.period_num := rosetta_g_miss_num_map(p5_a10);
    ddp_period_rec.quarter_num := rosetta_g_miss_num_map(p5_a11);
    ddp_period_rec.adjustment_period_flag := p5_a12;
    ddp_period_rec.creation_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_period_rec.created_by := rosetta_g_miss_num_map(p5_a14);
    ddp_period_rec.last_update_login := rosetta_g_miss_num_map(p5_a15);
    ddp_period_rec.attribute1 := p5_a16;
    ddp_period_rec.attribute2 := p5_a17;
    ddp_period_rec.attribute3 := p5_a18;
    ddp_period_rec.attribute4 := p5_a19;
    ddp_period_rec.attribute5 := p5_a20;
    ddp_period_rec.context := p5_a21;
    ddp_period_rec.year_start_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_period_rec.quarter_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_period_rec.effective_period_num := rosetta_g_miss_num_map(p5_a24);
    ddp_period_rec.elimination_confirmed_flag := p5_a25;


    -- here's the delegated call to the old PL/SQL routine
    okl_perd_status_pvt.search_period_status(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_period_rec,
      ddx_period_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_perd_status_pvt_w.rosetta_table_copy_out_p1(ddx_period_tbl, p6_a0
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
      );
  end;

  procedure update_period_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_period_tbl okl_perd_status_pvt.period_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_perd_status_pvt_w.rosetta_table_copy_in_p1(ddp_period_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_perd_status_pvt.update_period_status(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_period_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_perd_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_period_rec okl_perd_status_pvt.period_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_period_rec.application_id := rosetta_g_miss_num_map(p5_a0);
    ddp_period_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a1);
    ddp_period_rec.period_name := p5_a2;
    ddp_period_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_period_rec.last_updated_by := rosetta_g_miss_num_map(p5_a4);
    ddp_period_rec.closing_status := p5_a5;
    ddp_period_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_period_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_period_rec.period_type := p5_a8;
    ddp_period_rec.period_year := rosetta_g_miss_num_map(p5_a9);
    ddp_period_rec.period_num := rosetta_g_miss_num_map(p5_a10);
    ddp_period_rec.quarter_num := rosetta_g_miss_num_map(p5_a11);
    ddp_period_rec.adjustment_period_flag := p5_a12;
    ddp_period_rec.creation_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_period_rec.created_by := rosetta_g_miss_num_map(p5_a14);
    ddp_period_rec.last_update_login := rosetta_g_miss_num_map(p5_a15);
    ddp_period_rec.attribute1 := p5_a16;
    ddp_period_rec.attribute2 := p5_a17;
    ddp_period_rec.attribute3 := p5_a18;
    ddp_period_rec.attribute4 := p5_a19;
    ddp_period_rec.attribute5 := p5_a20;
    ddp_period_rec.context := p5_a21;
    ddp_period_rec.year_start_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_period_rec.quarter_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_period_rec.effective_period_num := rosetta_g_miss_num_map(p5_a24);
    ddp_period_rec.elimination_confirmed_flag := p5_a25;

    -- here's the delegated call to the old PL/SQL routine
    okl_perd_status_pvt.update_perd_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_period_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_perd_status_pvt_w;

/
