--------------------------------------------------------
--  DDL for Package Body OKL_PSY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PSY_PVT_W" as
  /* $Header: OKLIPSYB.pls 120.1 2005/07/14 11:58:16 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_psy_pvt.psyv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).accrual_yn := a4(indx);
          t(ddindx).sty_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_psy_pvt.psyv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).from_date;
          a2(indx) := t(ddindx).to_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a4(indx) := t(ddindx).accrual_yn;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_psy_pvt.psy_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).accrual_yn := a2(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_psy_pvt.psy_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).to_date;
          a2(indx) := t(ddindx).accrual_yn;
          a3(indx) := t(ddindx).from_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := t(ddindx).last_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
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
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddx_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p6_a1 := ddx_psyv_rec.from_date;
    p6_a2 := ddx_psyv_rec.to_date;
    p6_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p6_a4 := ddx_psyv_rec.accrual_yn;
    p6_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p6_a8 := ddx_psyv_rec.creation_date;
    p6_a9 := ddx_psyv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p6_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_DATE_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddx_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl,
      ddx_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_psy_pvt_w.rosetta_table_copy_out_p2(ddx_psyv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddx_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p6_a1 := ddx_psyv_rec.from_date;
    p6_a2 := ddx_psyv_rec.to_date;
    p6_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p6_a4 := ddx_psyv_rec.accrual_yn;
    p6_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p6_a8 := ddx_psyv_rec.creation_date;
    p6_a9 := ddx_psyv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p6_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_DATE_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddx_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl,
      ddx_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_psy_pvt_w.rosetta_table_copy_out_p2(ddx_psyv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_psy_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_psy_pvt.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_psy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_psy_pvt_w;

/
