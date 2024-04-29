--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_PVT_W" as
  /* $Header: OKLESIPB.pls 120.1 2005/10/30 03:16:45 appldev noship $ */
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

  procedure create_sub_pool(p_api_version  NUMBER
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
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_sub_pool_rec okl_subsidy_pool_pvt.subsidy_pool_rec;
    ddx_sub_pool_rec okl_subsidy_pool_pvt.subsidy_pool_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sub_pool_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sub_pool_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sub_pool_rec.sfwt_flag := p5_a2;
    ddp_sub_pool_rec.pool_type_code := p5_a3;
    ddp_sub_pool_rec.subsidy_pool_name := p5_a4;
    ddp_sub_pool_rec.short_description := p5_a5;
    ddp_sub_pool_rec.description := p5_a6;
    ddp_sub_pool_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_sub_pool_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_sub_pool_rec.currency_code := p5_a9;
    ddp_sub_pool_rec.currency_conversion_type := p5_a10;
    ddp_sub_pool_rec.decision_status_code := p5_a11;
    ddp_sub_pool_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sub_pool_rec.reporting_pool_limit := rosetta_g_miss_num_map(p5_a13);
    ddp_sub_pool_rec.total_budgets := rosetta_g_miss_num_map(p5_a14);
    ddp_sub_pool_rec.total_subsidy_amount := rosetta_g_miss_num_map(p5_a15);
    ddp_sub_pool_rec.decision_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_sub_pool_rec.attribute_category := p5_a17;
    ddp_sub_pool_rec.attribute1 := p5_a18;
    ddp_sub_pool_rec.attribute2 := p5_a19;
    ddp_sub_pool_rec.attribute3 := p5_a20;
    ddp_sub_pool_rec.attribute4 := p5_a21;
    ddp_sub_pool_rec.attribute5 := p5_a22;
    ddp_sub_pool_rec.attribute6 := p5_a23;
    ddp_sub_pool_rec.attribute7 := p5_a24;
    ddp_sub_pool_rec.attribute8 := p5_a25;
    ddp_sub_pool_rec.attribute9 := p5_a26;
    ddp_sub_pool_rec.attribute10 := p5_a27;
    ddp_sub_pool_rec.attribute11 := p5_a28;
    ddp_sub_pool_rec.attribute12 := p5_a29;
    ddp_sub_pool_rec.attribute13 := p5_a30;
    ddp_sub_pool_rec.attribute14 := p5_a31;
    ddp_sub_pool_rec.attribute15 := p5_a32;
    ddp_sub_pool_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_sub_pool_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_sub_pool_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_sub_pool_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_sub_pool_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pool_pvt.create_sub_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sub_pool_rec,
      ddx_sub_pool_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sub_pool_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sub_pool_rec.object_version_number);
    p6_a2 := ddx_sub_pool_rec.sfwt_flag;
    p6_a3 := ddx_sub_pool_rec.pool_type_code;
    p6_a4 := ddx_sub_pool_rec.subsidy_pool_name;
    p6_a5 := ddx_sub_pool_rec.short_description;
    p6_a6 := ddx_sub_pool_rec.description;
    p6_a7 := ddx_sub_pool_rec.effective_from_date;
    p6_a8 := ddx_sub_pool_rec.effective_to_date;
    p6_a9 := ddx_sub_pool_rec.currency_code;
    p6_a10 := ddx_sub_pool_rec.currency_conversion_type;
    p6_a11 := ddx_sub_pool_rec.decision_status_code;
    p6_a12 := rosetta_g_miss_num_map(ddx_sub_pool_rec.subsidy_pool_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sub_pool_rec.reporting_pool_limit);
    p6_a14 := rosetta_g_miss_num_map(ddx_sub_pool_rec.total_budgets);
    p6_a15 := rosetta_g_miss_num_map(ddx_sub_pool_rec.total_subsidy_amount);
    p6_a16 := ddx_sub_pool_rec.decision_date;
    p6_a17 := ddx_sub_pool_rec.attribute_category;
    p6_a18 := ddx_sub_pool_rec.attribute1;
    p6_a19 := ddx_sub_pool_rec.attribute2;
    p6_a20 := ddx_sub_pool_rec.attribute3;
    p6_a21 := ddx_sub_pool_rec.attribute4;
    p6_a22 := ddx_sub_pool_rec.attribute5;
    p6_a23 := ddx_sub_pool_rec.attribute6;
    p6_a24 := ddx_sub_pool_rec.attribute7;
    p6_a25 := ddx_sub_pool_rec.attribute8;
    p6_a26 := ddx_sub_pool_rec.attribute9;
    p6_a27 := ddx_sub_pool_rec.attribute10;
    p6_a28 := ddx_sub_pool_rec.attribute11;
    p6_a29 := ddx_sub_pool_rec.attribute12;
    p6_a30 := ddx_sub_pool_rec.attribute13;
    p6_a31 := ddx_sub_pool_rec.attribute14;
    p6_a32 := ddx_sub_pool_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_sub_pool_rec.created_by);
    p6_a34 := ddx_sub_pool_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_sub_pool_rec.last_updated_by);
    p6_a36 := ddx_sub_pool_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_sub_pool_rec.last_update_login);
  end;

  procedure update_sub_pool(p_api_version  NUMBER
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
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_sub_pool_rec okl_subsidy_pool_pvt.subsidy_pool_rec;
    ddx_sub_pool_rec okl_subsidy_pool_pvt.subsidy_pool_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sub_pool_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sub_pool_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sub_pool_rec.sfwt_flag := p5_a2;
    ddp_sub_pool_rec.pool_type_code := p5_a3;
    ddp_sub_pool_rec.subsidy_pool_name := p5_a4;
    ddp_sub_pool_rec.short_description := p5_a5;
    ddp_sub_pool_rec.description := p5_a6;
    ddp_sub_pool_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_sub_pool_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_sub_pool_rec.currency_code := p5_a9;
    ddp_sub_pool_rec.currency_conversion_type := p5_a10;
    ddp_sub_pool_rec.decision_status_code := p5_a11;
    ddp_sub_pool_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sub_pool_rec.reporting_pool_limit := rosetta_g_miss_num_map(p5_a13);
    ddp_sub_pool_rec.total_budgets := rosetta_g_miss_num_map(p5_a14);
    ddp_sub_pool_rec.total_subsidy_amount := rosetta_g_miss_num_map(p5_a15);
    ddp_sub_pool_rec.decision_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_sub_pool_rec.attribute_category := p5_a17;
    ddp_sub_pool_rec.attribute1 := p5_a18;
    ddp_sub_pool_rec.attribute2 := p5_a19;
    ddp_sub_pool_rec.attribute3 := p5_a20;
    ddp_sub_pool_rec.attribute4 := p5_a21;
    ddp_sub_pool_rec.attribute5 := p5_a22;
    ddp_sub_pool_rec.attribute6 := p5_a23;
    ddp_sub_pool_rec.attribute7 := p5_a24;
    ddp_sub_pool_rec.attribute8 := p5_a25;
    ddp_sub_pool_rec.attribute9 := p5_a26;
    ddp_sub_pool_rec.attribute10 := p5_a27;
    ddp_sub_pool_rec.attribute11 := p5_a28;
    ddp_sub_pool_rec.attribute12 := p5_a29;
    ddp_sub_pool_rec.attribute13 := p5_a30;
    ddp_sub_pool_rec.attribute14 := p5_a31;
    ddp_sub_pool_rec.attribute15 := p5_a32;
    ddp_sub_pool_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_sub_pool_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_sub_pool_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_sub_pool_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_sub_pool_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pool_pvt.update_sub_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sub_pool_rec,
      ddx_sub_pool_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sub_pool_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sub_pool_rec.object_version_number);
    p6_a2 := ddx_sub_pool_rec.sfwt_flag;
    p6_a3 := ddx_sub_pool_rec.pool_type_code;
    p6_a4 := ddx_sub_pool_rec.subsidy_pool_name;
    p6_a5 := ddx_sub_pool_rec.short_description;
    p6_a6 := ddx_sub_pool_rec.description;
    p6_a7 := ddx_sub_pool_rec.effective_from_date;
    p6_a8 := ddx_sub_pool_rec.effective_to_date;
    p6_a9 := ddx_sub_pool_rec.currency_code;
    p6_a10 := ddx_sub_pool_rec.currency_conversion_type;
    p6_a11 := ddx_sub_pool_rec.decision_status_code;
    p6_a12 := rosetta_g_miss_num_map(ddx_sub_pool_rec.subsidy_pool_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sub_pool_rec.reporting_pool_limit);
    p6_a14 := rosetta_g_miss_num_map(ddx_sub_pool_rec.total_budgets);
    p6_a15 := rosetta_g_miss_num_map(ddx_sub_pool_rec.total_subsidy_amount);
    p6_a16 := ddx_sub_pool_rec.decision_date;
    p6_a17 := ddx_sub_pool_rec.attribute_category;
    p6_a18 := ddx_sub_pool_rec.attribute1;
    p6_a19 := ddx_sub_pool_rec.attribute2;
    p6_a20 := ddx_sub_pool_rec.attribute3;
    p6_a21 := ddx_sub_pool_rec.attribute4;
    p6_a22 := ddx_sub_pool_rec.attribute5;
    p6_a23 := ddx_sub_pool_rec.attribute6;
    p6_a24 := ddx_sub_pool_rec.attribute7;
    p6_a25 := ddx_sub_pool_rec.attribute8;
    p6_a26 := ddx_sub_pool_rec.attribute9;
    p6_a27 := ddx_sub_pool_rec.attribute10;
    p6_a28 := ddx_sub_pool_rec.attribute11;
    p6_a29 := ddx_sub_pool_rec.attribute12;
    p6_a30 := ddx_sub_pool_rec.attribute13;
    p6_a31 := ddx_sub_pool_rec.attribute14;
    p6_a32 := ddx_sub_pool_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_sub_pool_rec.created_by);
    p6_a34 := ddx_sub_pool_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_sub_pool_rec.last_updated_by);
    p6_a36 := ddx_sub_pool_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_sub_pool_rec.last_update_login);
  end;

  procedure validate_sub_pool(p_api_version  NUMBER
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
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_sub_pool_rec okl_subsidy_pool_pvt.subsidy_pool_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sub_pool_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sub_pool_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sub_pool_rec.sfwt_flag := p5_a2;
    ddp_sub_pool_rec.pool_type_code := p5_a3;
    ddp_sub_pool_rec.subsidy_pool_name := p5_a4;
    ddp_sub_pool_rec.short_description := p5_a5;
    ddp_sub_pool_rec.description := p5_a6;
    ddp_sub_pool_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_sub_pool_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_sub_pool_rec.currency_code := p5_a9;
    ddp_sub_pool_rec.currency_conversion_type := p5_a10;
    ddp_sub_pool_rec.decision_status_code := p5_a11;
    ddp_sub_pool_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sub_pool_rec.reporting_pool_limit := rosetta_g_miss_num_map(p5_a13);
    ddp_sub_pool_rec.total_budgets := rosetta_g_miss_num_map(p5_a14);
    ddp_sub_pool_rec.total_subsidy_amount := rosetta_g_miss_num_map(p5_a15);
    ddp_sub_pool_rec.decision_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_sub_pool_rec.attribute_category := p5_a17;
    ddp_sub_pool_rec.attribute1 := p5_a18;
    ddp_sub_pool_rec.attribute2 := p5_a19;
    ddp_sub_pool_rec.attribute3 := p5_a20;
    ddp_sub_pool_rec.attribute4 := p5_a21;
    ddp_sub_pool_rec.attribute5 := p5_a22;
    ddp_sub_pool_rec.attribute6 := p5_a23;
    ddp_sub_pool_rec.attribute7 := p5_a24;
    ddp_sub_pool_rec.attribute8 := p5_a25;
    ddp_sub_pool_rec.attribute9 := p5_a26;
    ddp_sub_pool_rec.attribute10 := p5_a27;
    ddp_sub_pool_rec.attribute11 := p5_a28;
    ddp_sub_pool_rec.attribute12 := p5_a29;
    ddp_sub_pool_rec.attribute13 := p5_a30;
    ddp_sub_pool_rec.attribute14 := p5_a31;
    ddp_sub_pool_rec.attribute15 := p5_a32;
    ddp_sub_pool_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_sub_pool_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_sub_pool_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_sub_pool_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_sub_pool_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    -- here's the delegated call to the old PL/SQL routine
    okl_subsidy_pool_pvt.validate_sub_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sub_pool_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_subsidy_pool_pvt_w;

/
