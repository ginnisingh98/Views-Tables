--------------------------------------------------------
--  DDL for Package Body OKL_STRM_GEN_TEMPLATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STRM_GEN_TEMPLATE_PVT_W" as
  /* $Header: OKLETSGB.pls 120.9 2007/10/15 15:52:35 dpsingh ship $ */
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

  procedure rosetta_table_copy_in_p72(t out nocopy okl_strm_gen_template_pvt.error_msgs_tbl_type, a0 JTF_VARCHAR2_TABLE_2500
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).error_message := a0(indx);
          t(ddindx).error_type_code := a1(indx);
          t(ddindx).error_type_meaning := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p72;
  procedure rosetta_table_copy_out_p72(t okl_strm_gen_template_pvt.error_msgs_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2500
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2500();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_2500();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).error_message;
          a1(indx) := t(ddindx).error_type_code;
          a2(indx) := t(ddindx).error_type_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p72;

  procedure create_strm_gen_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_200
    , p7_a3 JTF_VARCHAR2_TABLE_2000
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_200
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_DATE_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  DATE
    , p9_a5 out nocopy  DATE
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  NUMBER
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  NUMBER
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  NUMBER
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
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_gtsv_rec okl_strm_gen_template_pvt.gtsv_rec_type;
    ddp_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddp_gtpv_tbl okl_strm_gen_template_pvt.gtpv_tbl_type;
    ddp_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddx_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtsv_rec.name := p5_a2;
    ddp_gtsv_rec.description := p5_a3;
    ddp_gtsv_rec.product_type := p5_a4;
    ddp_gtsv_rec.tax_owner := p5_a5;
    ddp_gtsv_rec.deal_type := p5_a6;
    ddp_gtsv_rec.pricing_engine := p5_a7;
    ddp_gtsv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtsv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtsv_rec.interest_calc_meth_code := p5_a14;
    ddp_gtsv_rec.revenue_recog_meth_code := p5_a15;
    ddp_gtsv_rec.days_in_month_code := p5_a16;
    ddp_gtsv_rec.days_in_yr_code := p5_a17;
    ddp_gtsv_rec.isg_arrears_pay_dates_option := p5_a18;

    ddp_gttv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_gttv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_gttv_rec.gts_id := rosetta_g_miss_num_map(p6_a2);
    ddp_gttv_rec.version := p6_a3;
    ddp_gttv_rec.start_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_gttv_rec.end_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_gttv_rec.tmpt_status := p6_a6;
    ddp_gttv_rec.attribute_category := p6_a7;
    ddp_gttv_rec.attribute1 := p6_a8;
    ddp_gttv_rec.attribute2 := p6_a9;
    ddp_gttv_rec.attribute3 := p6_a10;
    ddp_gttv_rec.attribute4 := p6_a11;
    ddp_gttv_rec.attribute5 := p6_a12;
    ddp_gttv_rec.attribute6 := p6_a13;
    ddp_gttv_rec.attribute7 := p6_a14;
    ddp_gttv_rec.attribute8 := p6_a15;
    ddp_gttv_rec.attribute9 := p6_a16;
    ddp_gttv_rec.attribute10 := p6_a17;
    ddp_gttv_rec.attribute11 := p6_a18;
    ddp_gttv_rec.attribute12 := p6_a19;
    ddp_gttv_rec.attribute13 := p6_a20;
    ddp_gttv_rec.attribute14 := p6_a21;
    ddp_gttv_rec.attribute15 := p6_a22;
    ddp_gttv_rec.org_id := rosetta_g_miss_num_map(p6_a23);
    ddp_gttv_rec.created_by := rosetta_g_miss_num_map(p6_a24);
    ddp_gttv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_gttv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a26);
    ddp_gttv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_gttv_rec.last_update_login := rosetta_g_miss_num_map(p6_a28);

    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      );

    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_gtlv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.create_strm_gen_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtsv_rec,
      ddp_gttv_rec,
      ddp_gtpv_tbl,
      ddp_gtlv_tbl,
      ddx_gttv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_gttv_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_gttv_rec.object_version_number);
    p9_a2 := rosetta_g_miss_num_map(ddx_gttv_rec.gts_id);
    p9_a3 := ddx_gttv_rec.version;
    p9_a4 := ddx_gttv_rec.start_date;
    p9_a5 := ddx_gttv_rec.end_date;
    p9_a6 := ddx_gttv_rec.tmpt_status;
    p9_a7 := ddx_gttv_rec.attribute_category;
    p9_a8 := ddx_gttv_rec.attribute1;
    p9_a9 := ddx_gttv_rec.attribute2;
    p9_a10 := ddx_gttv_rec.attribute3;
    p9_a11 := ddx_gttv_rec.attribute4;
    p9_a12 := ddx_gttv_rec.attribute5;
    p9_a13 := ddx_gttv_rec.attribute6;
    p9_a14 := ddx_gttv_rec.attribute7;
    p9_a15 := ddx_gttv_rec.attribute8;
    p9_a16 := ddx_gttv_rec.attribute9;
    p9_a17 := ddx_gttv_rec.attribute10;
    p9_a18 := ddx_gttv_rec.attribute11;
    p9_a19 := ddx_gttv_rec.attribute12;
    p9_a20 := ddx_gttv_rec.attribute13;
    p9_a21 := ddx_gttv_rec.attribute14;
    p9_a22 := ddx_gttv_rec.attribute15;
    p9_a23 := rosetta_g_miss_num_map(ddx_gttv_rec.org_id);
    p9_a24 := rosetta_g_miss_num_map(ddx_gttv_rec.created_by);
    p9_a25 := ddx_gttv_rec.creation_date;
    p9_a26 := rosetta_g_miss_num_map(ddx_gttv_rec.last_updated_by);
    p9_a27 := ddx_gttv_rec.last_update_date;
    p9_a28 := rosetta_g_miss_num_map(ddx_gttv_rec.last_update_login);
  end;

  procedure update_strm_gen_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_200
    , p7_a3 JTF_VARCHAR2_TABLE_2000
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_200
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_DATE_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  DATE
    , p9_a5 out nocopy  DATE
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  NUMBER
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  NUMBER
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  NUMBER
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
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_gtsv_rec okl_strm_gen_template_pvt.gtsv_rec_type;
    ddp_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddp_gtpv_tbl okl_strm_gen_template_pvt.gtpv_tbl_type;
    ddp_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddx_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtsv_rec.name := p5_a2;
    ddp_gtsv_rec.description := p5_a3;
    ddp_gtsv_rec.product_type := p5_a4;
    ddp_gtsv_rec.tax_owner := p5_a5;
    ddp_gtsv_rec.deal_type := p5_a6;
    ddp_gtsv_rec.pricing_engine := p5_a7;
    ddp_gtsv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtsv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtsv_rec.interest_calc_meth_code := p5_a14;
    ddp_gtsv_rec.revenue_recog_meth_code := p5_a15;
    ddp_gtsv_rec.days_in_month_code := p5_a16;
    ddp_gtsv_rec.days_in_yr_code := p5_a17;
    ddp_gtsv_rec.isg_arrears_pay_dates_option := p5_a18;

    ddp_gttv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_gttv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_gttv_rec.gts_id := rosetta_g_miss_num_map(p6_a2);
    ddp_gttv_rec.version := p6_a3;
    ddp_gttv_rec.start_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_gttv_rec.end_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_gttv_rec.tmpt_status := p6_a6;
    ddp_gttv_rec.attribute_category := p6_a7;
    ddp_gttv_rec.attribute1 := p6_a8;
    ddp_gttv_rec.attribute2 := p6_a9;
    ddp_gttv_rec.attribute3 := p6_a10;
    ddp_gttv_rec.attribute4 := p6_a11;
    ddp_gttv_rec.attribute5 := p6_a12;
    ddp_gttv_rec.attribute6 := p6_a13;
    ddp_gttv_rec.attribute7 := p6_a14;
    ddp_gttv_rec.attribute8 := p6_a15;
    ddp_gttv_rec.attribute9 := p6_a16;
    ddp_gttv_rec.attribute10 := p6_a17;
    ddp_gttv_rec.attribute11 := p6_a18;
    ddp_gttv_rec.attribute12 := p6_a19;
    ddp_gttv_rec.attribute13 := p6_a20;
    ddp_gttv_rec.attribute14 := p6_a21;
    ddp_gttv_rec.attribute15 := p6_a22;
    ddp_gttv_rec.org_id := rosetta_g_miss_num_map(p6_a23);
    ddp_gttv_rec.created_by := rosetta_g_miss_num_map(p6_a24);
    ddp_gttv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_gttv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a26);
    ddp_gttv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_gttv_rec.last_update_login := rosetta_g_miss_num_map(p6_a28);

    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      );

    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_gtlv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.update_strm_gen_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtsv_rec,
      ddp_gttv_rec,
      ddp_gtpv_tbl,
      ddp_gtlv_tbl,
      ddx_gttv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_gttv_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_gttv_rec.object_version_number);
    p9_a2 := rosetta_g_miss_num_map(ddx_gttv_rec.gts_id);
    p9_a3 := ddx_gttv_rec.version;
    p9_a4 := ddx_gttv_rec.start_date;
    p9_a5 := ddx_gttv_rec.end_date;
    p9_a6 := ddx_gttv_rec.tmpt_status;
    p9_a7 := ddx_gttv_rec.attribute_category;
    p9_a8 := ddx_gttv_rec.attribute1;
    p9_a9 := ddx_gttv_rec.attribute2;
    p9_a10 := ddx_gttv_rec.attribute3;
    p9_a11 := ddx_gttv_rec.attribute4;
    p9_a12 := ddx_gttv_rec.attribute5;
    p9_a13 := ddx_gttv_rec.attribute6;
    p9_a14 := ddx_gttv_rec.attribute7;
    p9_a15 := ddx_gttv_rec.attribute8;
    p9_a16 := ddx_gttv_rec.attribute9;
    p9_a17 := ddx_gttv_rec.attribute10;
    p9_a18 := ddx_gttv_rec.attribute11;
    p9_a19 := ddx_gttv_rec.attribute12;
    p9_a20 := ddx_gttv_rec.attribute13;
    p9_a21 := ddx_gttv_rec.attribute14;
    p9_a22 := ddx_gttv_rec.attribute15;
    p9_a23 := rosetta_g_miss_num_map(ddx_gttv_rec.org_id);
    p9_a24 := rosetta_g_miss_num_map(ddx_gttv_rec.created_by);
    p9_a25 := ddx_gttv_rec.creation_date;
    p9_a26 := rosetta_g_miss_num_map(ddx_gttv_rec.last_updated_by);
    p9_a27 := ddx_gttv_rec.last_update_date;
    p9_a28 := rosetta_g_miss_num_map(ddx_gttv_rec.last_update_login);
  end;

  procedure update_dep_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_gtt_id  NUMBER
    , p_pri_sty_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_200
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_DATE_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , x_missing_deps out nocopy  VARCHAR2
    , x_show_warn_flag out nocopy  VARCHAR2
  )

  as
    ddp_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_gtlv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.update_dep_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_gtt_id,
      p_pri_sty_id,
      ddp_gtlv_tbl,
      x_missing_deps,
      x_show_warn_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure create_version_duplicate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_gtt_id  NUMBER
    , p_mode  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  DATE
    , p7_a28 out nocopy  NUMBER
  )

  as
    ddx_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.create_version_duplicate(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_gtt_id,
      p_mode,
      ddx_gttv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_gttv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_gttv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_gttv_rec.gts_id);
    p7_a3 := ddx_gttv_rec.version;
    p7_a4 := ddx_gttv_rec.start_date;
    p7_a5 := ddx_gttv_rec.end_date;
    p7_a6 := ddx_gttv_rec.tmpt_status;
    p7_a7 := ddx_gttv_rec.attribute_category;
    p7_a8 := ddx_gttv_rec.attribute1;
    p7_a9 := ddx_gttv_rec.attribute2;
    p7_a10 := ddx_gttv_rec.attribute3;
    p7_a11 := ddx_gttv_rec.attribute4;
    p7_a12 := ddx_gttv_rec.attribute5;
    p7_a13 := ddx_gttv_rec.attribute6;
    p7_a14 := ddx_gttv_rec.attribute7;
    p7_a15 := ddx_gttv_rec.attribute8;
    p7_a16 := ddx_gttv_rec.attribute9;
    p7_a17 := ddx_gttv_rec.attribute10;
    p7_a18 := ddx_gttv_rec.attribute11;
    p7_a19 := ddx_gttv_rec.attribute12;
    p7_a20 := ddx_gttv_rec.attribute13;
    p7_a21 := ddx_gttv_rec.attribute14;
    p7_a22 := ddx_gttv_rec.attribute15;
    p7_a23 := rosetta_g_miss_num_map(ddx_gttv_rec.org_id);
    p7_a24 := rosetta_g_miss_num_map(ddx_gttv_rec.created_by);
    p7_a25 := ddx_gttv_rec.creation_date;
    p7_a26 := rosetta_g_miss_num_map(ddx_gttv_rec.last_updated_by);
    p7_a27 := ddx_gttv_rec.last_update_date;
    p7_a28 := rosetta_g_miss_num_map(ddx_gttv_rec.last_update_login);
  end;

  procedure delete_tmpt_prc_params(p_api_version  NUMBER
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
    ddp_gtpv_tbl okl_strm_gen_template_pvt.gtpv_tbl_type;
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
    okl_strm_gen_template_pvt.delete_tmpt_prc_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_pri_tmpt_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
  )

  as
    ddp_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_gtlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.delete_pri_tmpt_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_dep_tmpt_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
  )

  as
    ddp_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_gtlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.delete_dep_tmpt_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_gtt_id  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_2500
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_tmpt_status out nocopy  VARCHAR2
    , p_during_upd_flag  VARCHAR2
  )

  as
    ddx_error_msgs_tbl okl_strm_gen_template_pvt.error_msgs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.validate_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_gtt_id,
      ddx_error_msgs_tbl,
      x_return_tmpt_status,
      p_during_upd_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_strm_gen_template_pvt_w.rosetta_table_copy_out_p72(ddx_error_msgs_tbl, p6_a0
      , p6_a1
      , p6_a2
      );


  end;

  procedure validate_for_warnings(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_gtt_id  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_2500
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p_during_upd_flag  VARCHAR
    , x_pri_purpose_list out nocopy  VARCHAR
  )

  as
    ddx_wrn_msgs_tbl okl_strm_gen_template_pvt.error_msgs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.validate_for_warnings(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_gtt_id,
      ddx_wrn_msgs_tbl,
      p_during_upd_flag,
      x_pri_purpose_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_strm_gen_template_pvt_w.rosetta_table_copy_out_p72(ddx_wrn_msgs_tbl, p6_a0
      , p6_a1
      , p6_a2
      );


  end;

  procedure update_pri_dep_of_sgt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_200
    , p7_a3 JTF_VARCHAR2_TABLE_2000
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_200
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_DATE_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_200
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_VARCHAR2_TABLE_200
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_NUMBER_TABLE
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  DATE
    , p11_a5 out nocopy  DATE
    , p11_a6 out nocopy  VARCHAR2
    , p11_a7 out nocopy  VARCHAR2
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  VARCHAR2
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  VARCHAR2
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  VARCHAR2
    , p11_a20 out nocopy  VARCHAR2
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  NUMBER
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  DATE
    , p11_a26 out nocopy  NUMBER
    , p11_a27 out nocopy  DATE
    , p11_a28 out nocopy  NUMBER
    , x_pri_purpose_list out nocopy  VARCHAR2
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
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_gtsv_rec okl_strm_gen_template_pvt.gtsv_rec_type;
    ddp_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddp_gtpv_tbl okl_strm_gen_template_pvt.gtpv_tbl_type;
    ddp_pri_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddp_del_dep_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddp_ins_dep_gtlv_tbl okl_strm_gen_template_pvt.gtlv_tbl_type;
    ddx_gttv_rec okl_strm_gen_template_pvt.gttv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gtsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gtsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_gtsv_rec.name := p5_a2;
    ddp_gtsv_rec.description := p5_a3;
    ddp_gtsv_rec.product_type := p5_a4;
    ddp_gtsv_rec.tax_owner := p5_a5;
    ddp_gtsv_rec.deal_type := p5_a6;
    ddp_gtsv_rec.pricing_engine := p5_a7;
    ddp_gtsv_rec.org_id := rosetta_g_miss_num_map(p5_a8);
    ddp_gtsv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gtsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gtsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gtsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gtsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_gtsv_rec.interest_calc_meth_code := p5_a14;
    ddp_gtsv_rec.revenue_recog_meth_code := p5_a15;
    ddp_gtsv_rec.days_in_month_code := p5_a16;
    ddp_gtsv_rec.days_in_yr_code := p5_a17;
    ddp_gtsv_rec.isg_arrears_pay_dates_option := p5_a18;

    ddp_gttv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_gttv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_gttv_rec.gts_id := rosetta_g_miss_num_map(p6_a2);
    ddp_gttv_rec.version := p6_a3;
    ddp_gttv_rec.start_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_gttv_rec.end_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_gttv_rec.tmpt_status := p6_a6;
    ddp_gttv_rec.attribute_category := p6_a7;
    ddp_gttv_rec.attribute1 := p6_a8;
    ddp_gttv_rec.attribute2 := p6_a9;
    ddp_gttv_rec.attribute3 := p6_a10;
    ddp_gttv_rec.attribute4 := p6_a11;
    ddp_gttv_rec.attribute5 := p6_a12;
    ddp_gttv_rec.attribute6 := p6_a13;
    ddp_gttv_rec.attribute7 := p6_a14;
    ddp_gttv_rec.attribute8 := p6_a15;
    ddp_gttv_rec.attribute9 := p6_a16;
    ddp_gttv_rec.attribute10 := p6_a17;
    ddp_gttv_rec.attribute11 := p6_a18;
    ddp_gttv_rec.attribute12 := p6_a19;
    ddp_gttv_rec.attribute13 := p6_a20;
    ddp_gttv_rec.attribute14 := p6_a21;
    ddp_gttv_rec.attribute15 := p6_a22;
    ddp_gttv_rec.org_id := rosetta_g_miss_num_map(p6_a23);
    ddp_gttv_rec.created_by := rosetta_g_miss_num_map(p6_a24);
    ddp_gttv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_gttv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a26);
    ddp_gttv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_gttv_rec.last_update_login := rosetta_g_miss_num_map(p6_a28);

    okl_gtp_pvt_w.rosetta_table_copy_in_p5(ddp_gtpv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      );

    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_pri_gtlv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      );

    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_del_dep_gtlv_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      );

    okl_gtl_pvt_w.rosetta_table_copy_in_p5(ddp_ins_dep_gtlv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_strm_gen_template_pvt.update_pri_dep_of_sgt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gtsv_rec,
      ddp_gttv_rec,
      ddp_gtpv_tbl,
      ddp_pri_gtlv_tbl,
      ddp_del_dep_gtlv_tbl,
      ddp_ins_dep_gtlv_tbl,
      ddx_gttv_rec,
      x_pri_purpose_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_gttv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_gttv_rec.object_version_number);
    p11_a2 := rosetta_g_miss_num_map(ddx_gttv_rec.gts_id);
    p11_a3 := ddx_gttv_rec.version;
    p11_a4 := ddx_gttv_rec.start_date;
    p11_a5 := ddx_gttv_rec.end_date;
    p11_a6 := ddx_gttv_rec.tmpt_status;
    p11_a7 := ddx_gttv_rec.attribute_category;
    p11_a8 := ddx_gttv_rec.attribute1;
    p11_a9 := ddx_gttv_rec.attribute2;
    p11_a10 := ddx_gttv_rec.attribute3;
    p11_a11 := ddx_gttv_rec.attribute4;
    p11_a12 := ddx_gttv_rec.attribute5;
    p11_a13 := ddx_gttv_rec.attribute6;
    p11_a14 := ddx_gttv_rec.attribute7;
    p11_a15 := ddx_gttv_rec.attribute8;
    p11_a16 := ddx_gttv_rec.attribute9;
    p11_a17 := ddx_gttv_rec.attribute10;
    p11_a18 := ddx_gttv_rec.attribute11;
    p11_a19 := ddx_gttv_rec.attribute12;
    p11_a20 := ddx_gttv_rec.attribute13;
    p11_a21 := ddx_gttv_rec.attribute14;
    p11_a22 := ddx_gttv_rec.attribute15;
    p11_a23 := rosetta_g_miss_num_map(ddx_gttv_rec.org_id);
    p11_a24 := rosetta_g_miss_num_map(ddx_gttv_rec.created_by);
    p11_a25 := ddx_gttv_rec.creation_date;
    p11_a26 := rosetta_g_miss_num_map(ddx_gttv_rec.last_updated_by);
    p11_a27 := ddx_gttv_rec.last_update_date;
    p11_a28 := rosetta_g_miss_num_map(ddx_gttv_rec.last_update_login);

  end;

end okl_strm_gen_template_pvt_w;

/
