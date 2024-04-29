--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_PVT_W" as
  /* $Header: OKLOSUBB.pls 120.4 2005/10/30 04:19:34 appldev noship $ */
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

  procedure create_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddx_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.create_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec,
      ddx_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_subv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_subv_rec.object_version_number);
    p6_a2 := ddx_subv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_subv_rec.org_id);
    p6_a4 := ddx_subv_rec.name;
    p6_a5 := ddx_subv_rec.short_description;
    p6_a6 := ddx_subv_rec.description;
    p6_a7 := ddx_subv_rec.effective_from_date;
    p6_a8 := ddx_subv_rec.effective_to_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_subv_rec.expire_after_days);
    p6_a10 := ddx_subv_rec.currency_code;
    p6_a11 := ddx_subv_rec.exclusive_yn;
    p6_a12 := ddx_subv_rec.applicable_to_release_yn;
    p6_a13 := ddx_subv_rec.subsidy_calc_basis;
    p6_a14 := rosetta_g_miss_num_map(ddx_subv_rec.amount);
    p6_a15 := rosetta_g_miss_num_map(ddx_subv_rec.percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_subv_rec.formula_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_subv_rec.rate_points);
    p6_a18 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_term);
    p6_a19 := rosetta_g_miss_num_map(ddx_subv_rec.vendor_id);
    p6_a20 := ddx_subv_rec.accounting_method_code;
    p6_a21 := ddx_subv_rec.recourse_yn;
    p6_a22 := ddx_subv_rec.termination_refund_basis;
    p6_a23 := rosetta_g_miss_num_map(ddx_subv_rec.refund_formula_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_subv_rec.stream_type_id);
    p6_a25 := ddx_subv_rec.receipt_method_code;
    p6_a26 := ddx_subv_rec.customer_visible_yn;
    p6_a27 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_financed_amount);
    p6_a28 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_subsidy_amount);
    p6_a29 := ddx_subv_rec.transfer_basis_code;
    p6_a30 := ddx_subv_rec.attribute_category;
    p6_a31 := ddx_subv_rec.attribute1;
    p6_a32 := ddx_subv_rec.attribute2;
    p6_a33 := ddx_subv_rec.attribute3;
    p6_a34 := ddx_subv_rec.attribute4;
    p6_a35 := ddx_subv_rec.attribute5;
    p6_a36 := ddx_subv_rec.attribute6;
    p6_a37 := ddx_subv_rec.attribute7;
    p6_a38 := ddx_subv_rec.attribute8;
    p6_a39 := ddx_subv_rec.attribute9;
    p6_a40 := ddx_subv_rec.attribute10;
    p6_a41 := ddx_subv_rec.attribute11;
    p6_a42 := ddx_subv_rec.attribute12;
    p6_a43 := ddx_subv_rec.attribute13;
    p6_a44 := ddx_subv_rec.attribute14;
    p6_a45 := ddx_subv_rec.attribute15;
    p6_a46 := rosetta_g_miss_num_map(ddx_subv_rec.created_by);
    p6_a47 := ddx_subv_rec.creation_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_subv_rec.last_updated_by);
    p6_a49 := ddx_subv_rec.last_update_date;
    p6_a50 := rosetta_g_miss_num_map(ddx_subv_rec.last_update_login);
    p6_a51 := rosetta_g_miss_num_map(ddx_subv_rec.subsidy_pool_id);
  end;

  procedure create_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddx_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.create_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl,
      ddx_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sub_pvt_w.rosetta_table_copy_out_p2(ddx_subv_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      );
  end;

  procedure update_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddx_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.update_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec,
      ddx_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_subv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_subv_rec.object_version_number);
    p6_a2 := ddx_subv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_subv_rec.org_id);
    p6_a4 := ddx_subv_rec.name;
    p6_a5 := ddx_subv_rec.short_description;
    p6_a6 := ddx_subv_rec.description;
    p6_a7 := ddx_subv_rec.effective_from_date;
    p6_a8 := ddx_subv_rec.effective_to_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_subv_rec.expire_after_days);
    p6_a10 := ddx_subv_rec.currency_code;
    p6_a11 := ddx_subv_rec.exclusive_yn;
    p6_a12 := ddx_subv_rec.applicable_to_release_yn;
    p6_a13 := ddx_subv_rec.subsidy_calc_basis;
    p6_a14 := rosetta_g_miss_num_map(ddx_subv_rec.amount);
    p6_a15 := rosetta_g_miss_num_map(ddx_subv_rec.percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_subv_rec.formula_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_subv_rec.rate_points);
    p6_a18 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_term);
    p6_a19 := rosetta_g_miss_num_map(ddx_subv_rec.vendor_id);
    p6_a20 := ddx_subv_rec.accounting_method_code;
    p6_a21 := ddx_subv_rec.recourse_yn;
    p6_a22 := ddx_subv_rec.termination_refund_basis;
    p6_a23 := rosetta_g_miss_num_map(ddx_subv_rec.refund_formula_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_subv_rec.stream_type_id);
    p6_a25 := ddx_subv_rec.receipt_method_code;
    p6_a26 := ddx_subv_rec.customer_visible_yn;
    p6_a27 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_financed_amount);
    p6_a28 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_subsidy_amount);
    p6_a29 := ddx_subv_rec.transfer_basis_code;
    p6_a30 := ddx_subv_rec.attribute_category;
    p6_a31 := ddx_subv_rec.attribute1;
    p6_a32 := ddx_subv_rec.attribute2;
    p6_a33 := ddx_subv_rec.attribute3;
    p6_a34 := ddx_subv_rec.attribute4;
    p6_a35 := ddx_subv_rec.attribute5;
    p6_a36 := ddx_subv_rec.attribute6;
    p6_a37 := ddx_subv_rec.attribute7;
    p6_a38 := ddx_subv_rec.attribute8;
    p6_a39 := ddx_subv_rec.attribute9;
    p6_a40 := ddx_subv_rec.attribute10;
    p6_a41 := ddx_subv_rec.attribute11;
    p6_a42 := ddx_subv_rec.attribute12;
    p6_a43 := ddx_subv_rec.attribute13;
    p6_a44 := ddx_subv_rec.attribute14;
    p6_a45 := ddx_subv_rec.attribute15;
    p6_a46 := rosetta_g_miss_num_map(ddx_subv_rec.created_by);
    p6_a47 := ddx_subv_rec.creation_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_subv_rec.last_updated_by);
    p6_a49 := ddx_subv_rec.last_update_date;
    p6_a50 := rosetta_g_miss_num_map(ddx_subv_rec.last_update_login);
    p6_a51 := rosetta_g_miss_num_map(ddx_subv_rec.subsidy_pool_id);
  end;

  procedure update_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddx_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.update_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl,
      ddx_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sub_pvt_w.rosetta_table_copy_out_p2(ddx_subv_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      );
  end;

  procedure delete_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.delete_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.delete_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.lock_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.lock_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_subsidy_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.validate_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_subsidy_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.validate_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddx_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sucv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sucv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sucv_rec.subsidy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_sucv_rec.display_sequence := rosetta_g_miss_num_map(p5_a3);
    ddp_sucv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sucv_rec.organization_id := rosetta_g_miss_num_map(p5_a5);
    ddp_sucv_rec.credit_classification_code := p5_a6;
    ddp_sucv_rec.sales_territory_code := p5_a7;
    ddp_sucv_rec.product_id := rosetta_g_miss_num_map(p5_a8);
    ddp_sucv_rec.industry_code_type := p5_a9;
    ddp_sucv_rec.industry_code := p5_a10;
    ddp_sucv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_sucv_rec.sales_territory_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sucv_rec.attribute_category := p5_a13;
    ddp_sucv_rec.attribute1 := p5_a14;
    ddp_sucv_rec.attribute2 := p5_a15;
    ddp_sucv_rec.attribute3 := p5_a16;
    ddp_sucv_rec.attribute4 := p5_a17;
    ddp_sucv_rec.attribute5 := p5_a18;
    ddp_sucv_rec.attribute6 := p5_a19;
    ddp_sucv_rec.attribute7 := p5_a20;
    ddp_sucv_rec.attribute8 := p5_a21;
    ddp_sucv_rec.attribute9 := p5_a22;
    ddp_sucv_rec.attribute10 := p5_a23;
    ddp_sucv_rec.attribute11 := p5_a24;
    ddp_sucv_rec.attribute12 := p5_a25;
    ddp_sucv_rec.attribute13 := p5_a26;
    ddp_sucv_rec.attribute14 := p5_a27;
    ddp_sucv_rec.attribute15 := p5_a28;
    ddp_sucv_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_sucv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_sucv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_sucv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_sucv_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.create_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_rec,
      ddx_sucv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sucv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sucv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_sucv_rec.subsidy_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_sucv_rec.display_sequence);
    p6_a4 := rosetta_g_miss_num_map(ddx_sucv_rec.inventory_item_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_sucv_rec.organization_id);
    p6_a6 := ddx_sucv_rec.credit_classification_code;
    p6_a7 := ddx_sucv_rec.sales_territory_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_sucv_rec.product_id);
    p6_a9 := ddx_sucv_rec.industry_code_type;
    p6_a10 := ddx_sucv_rec.industry_code;
    p6_a11 := rosetta_g_miss_num_map(ddx_sucv_rec.maximum_financed_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_sucv_rec.sales_territory_id);
    p6_a13 := ddx_sucv_rec.attribute_category;
    p6_a14 := ddx_sucv_rec.attribute1;
    p6_a15 := ddx_sucv_rec.attribute2;
    p6_a16 := ddx_sucv_rec.attribute3;
    p6_a17 := ddx_sucv_rec.attribute4;
    p6_a18 := ddx_sucv_rec.attribute5;
    p6_a19 := ddx_sucv_rec.attribute6;
    p6_a20 := ddx_sucv_rec.attribute7;
    p6_a21 := ddx_sucv_rec.attribute8;
    p6_a22 := ddx_sucv_rec.attribute9;
    p6_a23 := ddx_sucv_rec.attribute10;
    p6_a24 := ddx_sucv_rec.attribute11;
    p6_a25 := ddx_sucv_rec.attribute12;
    p6_a26 := ddx_sucv_rec.attribute13;
    p6_a27 := ddx_sucv_rec.attribute14;
    p6_a28 := ddx_sucv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_sucv_rec.created_by);
    p6_a30 := ddx_sucv_rec.creation_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_sucv_rec.last_updated_by);
    p6_a32 := ddx_sucv_rec.last_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_sucv_rec.last_update_login);
  end;

  procedure create_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddx_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_suc_pvt_w.rosetta_table_copy_in_p2(ddp_sucv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.create_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_tbl,
      ddx_sucv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_suc_pvt_w.rosetta_table_copy_out_p2(ddx_sucv_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      );
  end;

  procedure update_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddx_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sucv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sucv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sucv_rec.subsidy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_sucv_rec.display_sequence := rosetta_g_miss_num_map(p5_a3);
    ddp_sucv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sucv_rec.organization_id := rosetta_g_miss_num_map(p5_a5);
    ddp_sucv_rec.credit_classification_code := p5_a6;
    ddp_sucv_rec.sales_territory_code := p5_a7;
    ddp_sucv_rec.product_id := rosetta_g_miss_num_map(p5_a8);
    ddp_sucv_rec.industry_code_type := p5_a9;
    ddp_sucv_rec.industry_code := p5_a10;
    ddp_sucv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_sucv_rec.sales_territory_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sucv_rec.attribute_category := p5_a13;
    ddp_sucv_rec.attribute1 := p5_a14;
    ddp_sucv_rec.attribute2 := p5_a15;
    ddp_sucv_rec.attribute3 := p5_a16;
    ddp_sucv_rec.attribute4 := p5_a17;
    ddp_sucv_rec.attribute5 := p5_a18;
    ddp_sucv_rec.attribute6 := p5_a19;
    ddp_sucv_rec.attribute7 := p5_a20;
    ddp_sucv_rec.attribute8 := p5_a21;
    ddp_sucv_rec.attribute9 := p5_a22;
    ddp_sucv_rec.attribute10 := p5_a23;
    ddp_sucv_rec.attribute11 := p5_a24;
    ddp_sucv_rec.attribute12 := p5_a25;
    ddp_sucv_rec.attribute13 := p5_a26;
    ddp_sucv_rec.attribute14 := p5_a27;
    ddp_sucv_rec.attribute15 := p5_a28;
    ddp_sucv_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_sucv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_sucv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_sucv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_sucv_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.update_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_rec,
      ddx_sucv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sucv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sucv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_sucv_rec.subsidy_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_sucv_rec.display_sequence);
    p6_a4 := rosetta_g_miss_num_map(ddx_sucv_rec.inventory_item_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_sucv_rec.organization_id);
    p6_a6 := ddx_sucv_rec.credit_classification_code;
    p6_a7 := ddx_sucv_rec.sales_territory_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_sucv_rec.product_id);
    p6_a9 := ddx_sucv_rec.industry_code_type;
    p6_a10 := ddx_sucv_rec.industry_code;
    p6_a11 := rosetta_g_miss_num_map(ddx_sucv_rec.maximum_financed_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_sucv_rec.sales_territory_id);
    p6_a13 := ddx_sucv_rec.attribute_category;
    p6_a14 := ddx_sucv_rec.attribute1;
    p6_a15 := ddx_sucv_rec.attribute2;
    p6_a16 := ddx_sucv_rec.attribute3;
    p6_a17 := ddx_sucv_rec.attribute4;
    p6_a18 := ddx_sucv_rec.attribute5;
    p6_a19 := ddx_sucv_rec.attribute6;
    p6_a20 := ddx_sucv_rec.attribute7;
    p6_a21 := ddx_sucv_rec.attribute8;
    p6_a22 := ddx_sucv_rec.attribute9;
    p6_a23 := ddx_sucv_rec.attribute10;
    p6_a24 := ddx_sucv_rec.attribute11;
    p6_a25 := ddx_sucv_rec.attribute12;
    p6_a26 := ddx_sucv_rec.attribute13;
    p6_a27 := ddx_sucv_rec.attribute14;
    p6_a28 := ddx_sucv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_sucv_rec.created_by);
    p6_a30 := ddx_sucv_rec.creation_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_sucv_rec.last_updated_by);
    p6_a32 := ddx_sucv_rec.last_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_sucv_rec.last_update_login);
  end;

  procedure update_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddx_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_suc_pvt_w.rosetta_table_copy_in_p2(ddp_sucv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.update_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_tbl,
      ddx_sucv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_suc_pvt_w.rosetta_table_copy_out_p2(ddx_sucv_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      );
  end;

  procedure delete_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sucv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sucv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sucv_rec.subsidy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_sucv_rec.display_sequence := rosetta_g_miss_num_map(p5_a3);
    ddp_sucv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sucv_rec.organization_id := rosetta_g_miss_num_map(p5_a5);
    ddp_sucv_rec.credit_classification_code := p5_a6;
    ddp_sucv_rec.sales_territory_code := p5_a7;
    ddp_sucv_rec.product_id := rosetta_g_miss_num_map(p5_a8);
    ddp_sucv_rec.industry_code_type := p5_a9;
    ddp_sucv_rec.industry_code := p5_a10;
    ddp_sucv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_sucv_rec.sales_territory_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sucv_rec.attribute_category := p5_a13;
    ddp_sucv_rec.attribute1 := p5_a14;
    ddp_sucv_rec.attribute2 := p5_a15;
    ddp_sucv_rec.attribute3 := p5_a16;
    ddp_sucv_rec.attribute4 := p5_a17;
    ddp_sucv_rec.attribute5 := p5_a18;
    ddp_sucv_rec.attribute6 := p5_a19;
    ddp_sucv_rec.attribute7 := p5_a20;
    ddp_sucv_rec.attribute8 := p5_a21;
    ddp_sucv_rec.attribute9 := p5_a22;
    ddp_sucv_rec.attribute10 := p5_a23;
    ddp_sucv_rec.attribute11 := p5_a24;
    ddp_sucv_rec.attribute12 := p5_a25;
    ddp_sucv_rec.attribute13 := p5_a26;
    ddp_sucv_rec.attribute14 := p5_a27;
    ddp_sucv_rec.attribute15 := p5_a28;
    ddp_sucv_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_sucv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_sucv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_sucv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_sucv_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.delete_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
  )

  as
    ddp_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_suc_pvt_w.rosetta_table_copy_in_p2(ddp_sucv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.delete_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sucv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sucv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sucv_rec.subsidy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_sucv_rec.display_sequence := rosetta_g_miss_num_map(p5_a3);
    ddp_sucv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sucv_rec.organization_id := rosetta_g_miss_num_map(p5_a5);
    ddp_sucv_rec.credit_classification_code := p5_a6;
    ddp_sucv_rec.sales_territory_code := p5_a7;
    ddp_sucv_rec.product_id := rosetta_g_miss_num_map(p5_a8);
    ddp_sucv_rec.industry_code_type := p5_a9;
    ddp_sucv_rec.industry_code := p5_a10;
    ddp_sucv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_sucv_rec.sales_territory_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sucv_rec.attribute_category := p5_a13;
    ddp_sucv_rec.attribute1 := p5_a14;
    ddp_sucv_rec.attribute2 := p5_a15;
    ddp_sucv_rec.attribute3 := p5_a16;
    ddp_sucv_rec.attribute4 := p5_a17;
    ddp_sucv_rec.attribute5 := p5_a18;
    ddp_sucv_rec.attribute6 := p5_a19;
    ddp_sucv_rec.attribute7 := p5_a20;
    ddp_sucv_rec.attribute8 := p5_a21;
    ddp_sucv_rec.attribute9 := p5_a22;
    ddp_sucv_rec.attribute10 := p5_a23;
    ddp_sucv_rec.attribute11 := p5_a24;
    ddp_sucv_rec.attribute12 := p5_a25;
    ddp_sucv_rec.attribute13 := p5_a26;
    ddp_sucv_rec.attribute14 := p5_a27;
    ddp_sucv_rec.attribute15 := p5_a28;
    ddp_sucv_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_sucv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_sucv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_sucv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_sucv_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.lock_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
  )

  as
    ddp_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_suc_pvt_w.rosetta_table_copy_in_p2(ddp_sucv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.lock_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_sucv_rec okl_subsidy_pvt.sucv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sucv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sucv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sucv_rec.subsidy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_sucv_rec.display_sequence := rosetta_g_miss_num_map(p5_a3);
    ddp_sucv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sucv_rec.organization_id := rosetta_g_miss_num_map(p5_a5);
    ddp_sucv_rec.credit_classification_code := p5_a6;
    ddp_sucv_rec.sales_territory_code := p5_a7;
    ddp_sucv_rec.product_id := rosetta_g_miss_num_map(p5_a8);
    ddp_sucv_rec.industry_code_type := p5_a9;
    ddp_sucv_rec.industry_code := p5_a10;
    ddp_sucv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_sucv_rec.sales_territory_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sucv_rec.attribute_category := p5_a13;
    ddp_sucv_rec.attribute1 := p5_a14;
    ddp_sucv_rec.attribute2 := p5_a15;
    ddp_sucv_rec.attribute3 := p5_a16;
    ddp_sucv_rec.attribute4 := p5_a17;
    ddp_sucv_rec.attribute5 := p5_a18;
    ddp_sucv_rec.attribute6 := p5_a19;
    ddp_sucv_rec.attribute7 := p5_a20;
    ddp_sucv_rec.attribute8 := p5_a21;
    ddp_sucv_rec.attribute9 := p5_a22;
    ddp_sucv_rec.attribute10 := p5_a23;
    ddp_sucv_rec.attribute11 := p5_a24;
    ddp_sucv_rec.attribute12 := p5_a25;
    ddp_sucv_rec.attribute13 := p5_a26;
    ddp_sucv_rec.attribute14 := p5_a27;
    ddp_sucv_rec.attribute15 := p5_a28;
    ddp_sucv_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_sucv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_sucv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_sucv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_sucv_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.validate_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_subsidy_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
  )

  as
    ddp_sucv_tbl okl_subsidy_pvt.sucv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_suc_pvt_w.rosetta_table_copy_in_p2(ddp_sucv_tbl, p5_a0
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
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pvt.validate_subsidy_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sucv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_subsidy_pvt_w;

/
