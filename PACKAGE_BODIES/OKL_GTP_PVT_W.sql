--------------------------------------------------------
--  DDL for Package Body OKL_GTP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GTP_PVT_W" as
  /* $Header: OKLIGTPB.pls 120.1 2005/10/30 04:00:46 appldev noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_gtp_pvt.gtp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
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
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).display_yn := a4(indx);
          t(ddindx).update_yn := a5(indx);
          t(ddindx).prc_eng_ident := a6(indx);
          t(ddindx).default_value := a7(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).gtt_id := rosetta_g_miss_num_map(a14(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_gtp_pvt.gtp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).display_yn;
          a5(indx) := t(ddindx).update_yn;
          a6(indx) := t(ddindx).prc_eng_ident;
          a7(indx) := t(ddindx).default_value;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).gtt_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_gtp_pvt.gtpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
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
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).display_yn := a4(indx);
          t(ddindx).update_yn := a5(indx);
          t(ddindx).prc_eng_ident := a6(indx);
          t(ddindx).default_value := a7(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).gtt_id := rosetta_g_miss_num_map(a14(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_gtp_pvt.gtpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).display_yn;
          a5(indx) := t(ddindx).update_yn;
          a6(indx) := t(ddindx).prc_eng_ident;
          a7(indx) := t(ddindx).default_value;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).gtt_id);
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
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_gtpv_rec okl_gtp_pvt.gtpv_rec_type;
    ddx_gtpv_rec okl_gtp_pvt.gtpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtpv_rec.name := p5_a2;
    ddp_gtpv_rec.description := p5_a3;
    ddp_gtpv_rec.display_yn := p5_a4;
    ddp_gtpv_rec.update_yn := p5_a5;
    ddp_gtpv_rec.prc_eng_ident := p5_a6;
    ddp_gtpv_rec.default_value := p5_a7;
    ddp_gtpv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtpv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtpv_rec.gtt_id := rosetta_g_miss_num_map(p5_a14);


    -- here's the delegated call to the old PL/SQL routine
    okl_gtp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_rec,
      ddx_gtpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_gtpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_gtpv_rec.object_version_number);
    p6_a2 := ddx_gtpv_rec.name;
    p6_a3 := ddx_gtpv_rec.description;
    p6_a4 := ddx_gtpv_rec.display_yn;
    p6_a5 := ddx_gtpv_rec.update_yn;
    p6_a6 := ddx_gtpv_rec.prc_eng_ident;
    p6_a7 := ddx_gtpv_rec.default_value;
    p6_a8 := rosetta_g_miss_num_map(ddx_gtpv_rec.org_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_gtpv_rec.created_by);
    p6_a10 := ddx_gtpv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_gtpv_rec.last_updated_by);
    p6_a12 := ddx_gtpv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_gtpv_rec.last_update_login);
    p6_a14 := rosetta_g_miss_num_map(ddx_gtpv_rec.gtt_id);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_gtpv_tbl okl_gtp_pvt.gtpv_tbl_type;
    ddx_gtpv_tbl okl_gtp_pvt.gtpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p5_a0
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
    okl_gtp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_tbl,
      ddx_gtpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_gtp_pvt_w.rosetta_table_copy_out_p5(ddx_gtpv_tbl, p6_a0
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
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_gtpv_rec okl_gtp_pvt.gtpv_rec_type;
    ddx_gtpv_rec okl_gtp_pvt.gtpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtpv_rec.name := p5_a2;
    ddp_gtpv_rec.description := p5_a3;
    ddp_gtpv_rec.display_yn := p5_a4;
    ddp_gtpv_rec.update_yn := p5_a5;
    ddp_gtpv_rec.prc_eng_ident := p5_a6;
    ddp_gtpv_rec.default_value := p5_a7;
    ddp_gtpv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtpv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtpv_rec.gtt_id := rosetta_g_miss_num_map(p5_a14);


    -- here's the delegated call to the old PL/SQL routine
    okl_gtp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_rec,
      ddx_gtpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_gtpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_gtpv_rec.object_version_number);
    p6_a2 := ddx_gtpv_rec.name;
    p6_a3 := ddx_gtpv_rec.description;
    p6_a4 := ddx_gtpv_rec.display_yn;
    p6_a5 := ddx_gtpv_rec.update_yn;
    p6_a6 := ddx_gtpv_rec.prc_eng_ident;
    p6_a7 := ddx_gtpv_rec.default_value;
    p6_a8 := rosetta_g_miss_num_map(ddx_gtpv_rec.org_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_gtpv_rec.created_by);
    p6_a10 := ddx_gtpv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_gtpv_rec.last_updated_by);
    p6_a12 := ddx_gtpv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_gtpv_rec.last_update_login);
    p6_a14 := rosetta_g_miss_num_map(ddx_gtpv_rec.gtt_id);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_gtpv_tbl okl_gtp_pvt.gtpv_tbl_type;
    ddx_gtpv_tbl okl_gtp_pvt.gtpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p5_a0
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
    okl_gtp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_tbl,
      ddx_gtpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_gtp_pvt_w.rosetta_table_copy_out_p5(ddx_gtpv_tbl, p6_a0
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
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_gtpv_rec okl_gtp_pvt.gtpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtpv_rec.name := p5_a2;
    ddp_gtpv_rec.description := p5_a3;
    ddp_gtpv_rec.display_yn := p5_a4;
    ddp_gtpv_rec.update_yn := p5_a5;
    ddp_gtpv_rec.prc_eng_ident := p5_a6;
    ddp_gtpv_rec.default_value := p5_a7;
    ddp_gtpv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtpv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtpv_rec.gtt_id := rosetta_g_miss_num_map(p5_a14);

    -- here's the delegated call to the old PL/SQL routine
    okl_gtp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
  )

  as
    ddp_gtpv_tbl okl_gtp_pvt.gtpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p5_a0
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
    okl_gtp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_gtp_pvt_w;

/
