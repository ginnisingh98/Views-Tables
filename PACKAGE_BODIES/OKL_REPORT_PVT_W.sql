--------------------------------------------------------
--  DDL for Package Body OKL_REPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REPORT_PVT_W" as
  /* $Header: OKLEREPB.pls 120.0 2007/12/10 18:27:42 dcshanmu noship $ */
  procedure create_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddx_repv_rec okl_report_pvt.repv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec,
      ddx_repv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_repv_rec.report_id;
    p6_a1 := ddx_repv_rec.name;
    p6_a2 := ddx_repv_rec.chart_of_accounts_id;
    p6_a3 := ddx_repv_rec.book_classification_code;
    p6_a4 := ddx_repv_rec.ledger_id;
    p6_a5 := ddx_repv_rec.report_category_code;
    p6_a6 := ddx_repv_rec.report_type_code;
    p6_a7 := ddx_repv_rec.activity_code;
    p6_a8 := ddx_repv_rec.status_code;
    p6_a9 := ddx_repv_rec.description;
    p6_a10 := ddx_repv_rec.effective_from_date;
    p6_a11 := ddx_repv_rec.effective_to_date;
    p6_a12 := ddx_repv_rec.created_by;
    p6_a13 := ddx_repv_rec.creation_date;
    p6_a14 := ddx_repv_rec.last_updated_by;
    p6_a15 := ddx_repv_rec.last_update_date;
    p6_a16 := ddx_repv_rec.last_update_login;
    p6_a17 := ddx_repv_rec.language;
    p6_a18 := ddx_repv_rec.source_lang;
    p6_a19 := ddx_repv_rec.sfwt_flag;
  end;

  procedure update_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddx_repv_rec okl_report_pvt.repv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec,
      ddx_repv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_repv_rec.report_id;
    p6_a1 := ddx_repv_rec.name;
    p6_a2 := ddx_repv_rec.chart_of_accounts_id;
    p6_a3 := ddx_repv_rec.book_classification_code;
    p6_a4 := ddx_repv_rec.ledger_id;
    p6_a5 := ddx_repv_rec.report_category_code;
    p6_a6 := ddx_repv_rec.report_type_code;
    p6_a7 := ddx_repv_rec.activity_code;
    p6_a8 := ddx_repv_rec.status_code;
    p6_a9 := ddx_repv_rec.description;
    p6_a10 := ddx_repv_rec.effective_from_date;
    p6_a11 := ddx_repv_rec.effective_to_date;
    p6_a12 := ddx_repv_rec.created_by;
    p6_a13 := ddx_repv_rec.creation_date;
    p6_a14 := ddx_repv_rec.last_updated_by;
    p6_a15 := ddx_repv_rec.last_update_date;
    p6_a16 := ddx_repv_rec.last_update_login;
    p6_a17 := ddx_repv_rec.language;
    p6_a18 := ddx_repv_rec.source_lang;
    p6_a19 := ddx_repv_rec.sfwt_flag;
  end;

  procedure delete_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_300
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_repv_tbl okl_report_pvt.repv_tbl_type;
    ddx_repv_tbl okl_report_pvt.repv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rep_pvt_w.rosetta_table_copy_in_p2(ddp_repv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_tbl,
      ddx_repv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rep_pvt_w.rosetta_table_copy_out_p2(ddx_repv_tbl, p6_a0
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
      );
  end;

  procedure update_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_300
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_repv_tbl okl_report_pvt.repv_tbl_type;
    ddx_repv_tbl okl_report_pvt.repv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rep_pvt_w.rosetta_table_copy_in_p2(ddp_repv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_tbl,
      ddx_repv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rep_pvt_w.rosetta_table_copy_out_p2(ddx_repv_tbl, p6_a0
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
      );
  end;

  procedure delete_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_300
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_repv_tbl okl_report_pvt.repv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rep_pvt_w.rosetta_table_copy_in_p2(ddp_repv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_300
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_repv_tbl okl_report_pvt.repv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rep_pvt_w.rosetta_table_copy_in_p2(ddp_repv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
  )

  as
    ddp_rpp_rec okl_report_pvt.rpp_rec_type;
    ddx_rpp_rec okl_report_pvt.rpp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpp_rec.parameter_id := p5_a0;
    ddp_rpp_rec.report_id := p5_a1;
    ddp_rpp_rec.parameter_type := p5_a2;
    ddp_rpp_rec.param_num_value1 := p5_a3;
    ddp_rpp_rec.param_char_value1 := p5_a4;
    ddp_rpp_rec.param_date_value1 := p5_a5;
    ddp_rpp_rec.created_by := p5_a6;
    ddp_rpp_rec.source_table := p5_a7;
    ddp_rpp_rec.creation_date := p5_a8;
    ddp_rpp_rec.last_updated_by := p5_a9;
    ddp_rpp_rec.last_update_date := p5_a10;
    ddp_rpp_rec.last_update_login := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_rec,
      ddx_rpp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rpp_rec.parameter_id;
    p6_a1 := ddx_rpp_rec.report_id;
    p6_a2 := ddx_rpp_rec.parameter_type;
    p6_a3 := ddx_rpp_rec.param_num_value1;
    p6_a4 := ddx_rpp_rec.param_char_value1;
    p6_a5 := ddx_rpp_rec.param_date_value1;
    p6_a6 := ddx_rpp_rec.created_by;
    p6_a7 := ddx_rpp_rec.source_table;
    p6_a8 := ddx_rpp_rec.creation_date;
    p6_a9 := ddx_rpp_rec.last_updated_by;
    p6_a10 := ddx_rpp_rec.last_update_date;
    p6_a11 := ddx_rpp_rec.last_update_login;
  end;

  procedure update_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
  )

  as
    ddp_rpp_rec okl_report_pvt.rpp_rec_type;
    ddx_rpp_rec okl_report_pvt.rpp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpp_rec.parameter_id := p5_a0;
    ddp_rpp_rec.report_id := p5_a1;
    ddp_rpp_rec.parameter_type := p5_a2;
    ddp_rpp_rec.param_num_value1 := p5_a3;
    ddp_rpp_rec.param_char_value1 := p5_a4;
    ddp_rpp_rec.param_date_value1 := p5_a5;
    ddp_rpp_rec.created_by := p5_a6;
    ddp_rpp_rec.source_table := p5_a7;
    ddp_rpp_rec.creation_date := p5_a8;
    ddp_rpp_rec.last_updated_by := p5_a9;
    ddp_rpp_rec.last_update_date := p5_a10;
    ddp_rpp_rec.last_update_login := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_rec,
      ddx_rpp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rpp_rec.parameter_id;
    p6_a1 := ddx_rpp_rec.report_id;
    p6_a2 := ddx_rpp_rec.parameter_type;
    p6_a3 := ddx_rpp_rec.param_num_value1;
    p6_a4 := ddx_rpp_rec.param_char_value1;
    p6_a5 := ddx_rpp_rec.param_date_value1;
    p6_a6 := ddx_rpp_rec.created_by;
    p6_a7 := ddx_rpp_rec.source_table;
    p6_a8 := ddx_rpp_rec.creation_date;
    p6_a9 := ddx_rpp_rec.last_updated_by;
    p6_a10 := ddx_rpp_rec.last_update_date;
    p6_a11 := ddx_rpp_rec.last_update_login;
  end;

  procedure delete_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
  )

  as
    ddp_rpp_rec okl_report_pvt.rpp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpp_rec.parameter_id := p5_a0;
    ddp_rpp_rec.report_id := p5_a1;
    ddp_rpp_rec.parameter_type := p5_a2;
    ddp_rpp_rec.param_num_value1 := p5_a3;
    ddp_rpp_rec.param_char_value1 := p5_a4;
    ddp_rpp_rec.param_date_value1 := p5_a5;
    ddp_rpp_rec.created_by := p5_a6;
    ddp_rpp_rec.source_table := p5_a7;
    ddp_rpp_rec.creation_date := p5_a8;
    ddp_rpp_rec.last_updated_by := p5_a9;
    ddp_rpp_rec.last_update_date := p5_a10;
    ddp_rpp_rec.last_update_login := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
  )

  as
    ddp_rpp_rec okl_report_pvt.rpp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpp_rec.parameter_id := p5_a0;
    ddp_rpp_rec.report_id := p5_a1;
    ddp_rpp_rec.parameter_type := p5_a2;
    ddp_rpp_rec.param_num_value1 := p5_a3;
    ddp_rpp_rec.param_char_value1 := p5_a4;
    ddp_rpp_rec.param_date_value1 := p5_a5;
    ddp_rpp_rec.created_by := p5_a6;
    ddp_rpp_rec.source_table := p5_a7;
    ddp_rpp_rec.creation_date := p5_a8;
    ddp_rpp_rec.last_updated_by := p5_a9;
    ddp_rpp_rec.last_update_date := p5_a10;
    ddp_rpp_rec.last_update_login := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddx_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p5_a0
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
    okl_report_pvt.create_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_tbl,
      ddx_rpp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rpp_pvt_w.rosetta_table_copy_out_p2(ddx_rpp_tbl, p6_a0
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

  procedure update_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddx_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p5_a0
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
    okl_report_pvt.update_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_tbl,
      ddx_rpp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rpp_pvt_w.rosetta_table_copy_out_p2(ddx_rpp_tbl, p6_a0
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

  procedure delete_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p5_a0
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
    okl_report_pvt.delete_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p5_a0
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
    okl_report_pvt.lock_report_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_rap_rec okl_report_pvt.rap_rec_type;
    ddx_rap_rec okl_report_pvt.rap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rap_rec.acc_parameter_id := p5_a0;
    ddp_rap_rec.report_id := p5_a1;
    ddp_rap_rec.acct_param_type_code := p5_a2;
    ddp_rap_rec.segment_range_from := p5_a3;
    ddp_rap_rec.segment_range_to := p5_a4;
    ddp_rap_rec.created_by := p5_a5;
    ddp_rap_rec.creation_date := p5_a6;
    ddp_rap_rec.last_updated_by := p5_a7;
    ddp_rap_rec.last_update_date := p5_a8;
    ddp_rap_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_rec,
      ddx_rap_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rap_rec.acc_parameter_id;
    p6_a1 := ddx_rap_rec.report_id;
    p6_a2 := ddx_rap_rec.acct_param_type_code;
    p6_a3 := ddx_rap_rec.segment_range_from;
    p6_a4 := ddx_rap_rec.segment_range_to;
    p6_a5 := ddx_rap_rec.created_by;
    p6_a6 := ddx_rap_rec.creation_date;
    p6_a7 := ddx_rap_rec.last_updated_by;
    p6_a8 := ddx_rap_rec.last_update_date;
    p6_a9 := ddx_rap_rec.last_update_login;
  end;

  procedure update_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_rap_rec okl_report_pvt.rap_rec_type;
    ddx_rap_rec okl_report_pvt.rap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rap_rec.acc_parameter_id := p5_a0;
    ddp_rap_rec.report_id := p5_a1;
    ddp_rap_rec.acct_param_type_code := p5_a2;
    ddp_rap_rec.segment_range_from := p5_a3;
    ddp_rap_rec.segment_range_to := p5_a4;
    ddp_rap_rec.created_by := p5_a5;
    ddp_rap_rec.creation_date := p5_a6;
    ddp_rap_rec.last_updated_by := p5_a7;
    ddp_rap_rec.last_update_date := p5_a8;
    ddp_rap_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_rec,
      ddx_rap_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rap_rec.acc_parameter_id;
    p6_a1 := ddx_rap_rec.report_id;
    p6_a2 := ddx_rap_rec.acct_param_type_code;
    p6_a3 := ddx_rap_rec.segment_range_from;
    p6_a4 := ddx_rap_rec.segment_range_to;
    p6_a5 := ddx_rap_rec.created_by;
    p6_a6 := ddx_rap_rec.creation_date;
    p6_a7 := ddx_rap_rec.last_updated_by;
    p6_a8 := ddx_rap_rec.last_update_date;
    p6_a9 := ddx_rap_rec.last_update_login;
  end;

  procedure delete_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_rap_rec okl_report_pvt.rap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rap_rec.acc_parameter_id := p5_a0;
    ddp_rap_rec.report_id := p5_a1;
    ddp_rap_rec.acct_param_type_code := p5_a2;
    ddp_rap_rec.segment_range_from := p5_a3;
    ddp_rap_rec.segment_range_to := p5_a4;
    ddp_rap_rec.created_by := p5_a5;
    ddp_rap_rec.creation_date := p5_a6;
    ddp_rap_rec.last_updated_by := p5_a7;
    ddp_rap_rec.last_update_date := p5_a8;
    ddp_rap_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_rap_rec okl_report_pvt.rap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rap_rec.acc_parameter_id := p5_a0;
    ddp_rap_rec.report_id := p5_a1;
    ddp_rap_rec.acct_param_type_code := p5_a2;
    ddp_rap_rec.segment_range_from := p5_a3;
    ddp_rap_rec.segment_range_to := p5_a4;
    ddp_rap_rec.created_by := p5_a5;
    ddp_rap_rec.creation_date := p5_a6;
    ddp_rap_rec.last_updated_by := p5_a7;
    ddp_rap_rec.last_update_date := p5_a8;
    ddp_rap_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddx_rap_tbl okl_report_pvt.rap_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_tbl,
      ddx_rap_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rap_pvt_w.rosetta_table_copy_out_p2(ddx_rap_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure update_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddx_rap_tbl okl_report_pvt.rap_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_tbl,
      ddx_rap_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rap_pvt_w.rosetta_table_copy_out_p2(ddx_rap_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure delete_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_acc_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_acc_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rap_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
  )

  as
    ddp_rps_rec okl_report_pvt.rps_rec_type;
    ddx_rps_rec okl_report_pvt.rps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rps_rec.stream_parameter_id := p5_a0;
    ddp_rps_rec.report_id := p5_a1;
    ddp_rps_rec.sty_id := p5_a2;
    ddp_rps_rec.activity_code := p5_a3;
    ddp_rps_rec.created_by := p5_a4;
    ddp_rps_rec.creation_date := p5_a5;
    ddp_rps_rec.last_updated_by := p5_a6;
    ddp_rps_rec.last_update_date := p5_a7;
    ddp_rps_rec.last_update_login := p5_a8;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_rec,
      ddx_rps_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rps_rec.stream_parameter_id;
    p6_a1 := ddx_rps_rec.report_id;
    p6_a2 := ddx_rps_rec.sty_id;
    p6_a3 := ddx_rps_rec.activity_code;
    p6_a4 := ddx_rps_rec.created_by;
    p6_a5 := ddx_rps_rec.creation_date;
    p6_a6 := ddx_rps_rec.last_updated_by;
    p6_a7 := ddx_rps_rec.last_update_date;
    p6_a8 := ddx_rps_rec.last_update_login;
  end;

  procedure update_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
  )

  as
    ddp_rps_rec okl_report_pvt.rps_rec_type;
    ddx_rps_rec okl_report_pvt.rps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rps_rec.stream_parameter_id := p5_a0;
    ddp_rps_rec.report_id := p5_a1;
    ddp_rps_rec.sty_id := p5_a2;
    ddp_rps_rec.activity_code := p5_a3;
    ddp_rps_rec.created_by := p5_a4;
    ddp_rps_rec.creation_date := p5_a5;
    ddp_rps_rec.last_updated_by := p5_a6;
    ddp_rps_rec.last_update_date := p5_a7;
    ddp_rps_rec.last_update_login := p5_a8;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_rec,
      ddx_rps_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rps_rec.stream_parameter_id;
    p6_a1 := ddx_rps_rec.report_id;
    p6_a2 := ddx_rps_rec.sty_id;
    p6_a3 := ddx_rps_rec.activity_code;
    p6_a4 := ddx_rps_rec.created_by;
    p6_a5 := ddx_rps_rec.creation_date;
    p6_a6 := ddx_rps_rec.last_updated_by;
    p6_a7 := ddx_rps_rec.last_update_date;
    p6_a8 := ddx_rps_rec.last_update_login;
  end;

  procedure delete_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
  )

  as
    ddp_rps_rec okl_report_pvt.rps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rps_rec.stream_parameter_id := p5_a0;
    ddp_rps_rec.report_id := p5_a1;
    ddp_rps_rec.sty_id := p5_a2;
    ddp_rps_rec.activity_code := p5_a3;
    ddp_rps_rec.created_by := p5_a4;
    ddp_rps_rec.creation_date := p5_a5;
    ddp_rps_rec.last_updated_by := p5_a6;
    ddp_rps_rec.last_update_date := p5_a7;
    ddp_rps_rec.last_update_login := p5_a8;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
  )

  as
    ddp_rps_rec okl_report_pvt.rps_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rps_rec.stream_parameter_id := p5_a0;
    ddp_rps_rec.report_id := p5_a1;
    ddp_rps_rec.sty_id := p5_a2;
    ddp_rps_rec.activity_code := p5_a3;
    ddp_rps_rec.created_by := p5_a4;
    ddp_rps_rec.creation_date := p5_a5;
    ddp_rps_rec.last_updated_by := p5_a6;
    ddp_rps_rec.last_update_date := p5_a7;
    ddp_rps_rec.last_update_login := p5_a8;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddx_rps_tbl okl_report_pvt.rps_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_tbl,
      ddx_rps_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rsp_pvt_w.rosetta_table_copy_out_p2(ddx_rps_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure update_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddx_rps_tbl okl_report_pvt.rps_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_tbl,
      ddx_rps_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rsp_pvt_w.rosetta_table_copy_out_p2(ddx_rps_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure delete_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
  )

  as
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_strm_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
  )

  as
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_strm_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rps_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_rtp_rec okl_report_pvt.rtp_rec_type;
    ddx_rtp_rec okl_report_pvt.rtp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rtp_rec.trx_parameter_id := p5_a0;
    ddp_rtp_rec.report_id := p5_a1;
    ddp_rtp_rec.try_id := p5_a2;
    ddp_rtp_rec.sty_id := p5_a3;
    ddp_rtp_rec.add_substract_code := p5_a4;
    ddp_rtp_rec.created_by := p5_a5;
    ddp_rtp_rec.creation_date := p5_a6;
    ddp_rtp_rec.last_updated_by := p5_a7;
    ddp_rtp_rec.last_update_date := p5_a8;
    ddp_rtp_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_rec,
      ddx_rtp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rtp_rec.trx_parameter_id;
    p6_a1 := ddx_rtp_rec.report_id;
    p6_a2 := ddx_rtp_rec.try_id;
    p6_a3 := ddx_rtp_rec.sty_id;
    p6_a4 := ddx_rtp_rec.add_substract_code;
    p6_a5 := ddx_rtp_rec.created_by;
    p6_a6 := ddx_rtp_rec.creation_date;
    p6_a7 := ddx_rtp_rec.last_updated_by;
    p6_a8 := ddx_rtp_rec.last_update_date;
    p6_a9 := ddx_rtp_rec.last_update_login;
  end;

  procedure update_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_rtp_rec okl_report_pvt.rtp_rec_type;
    ddx_rtp_rec okl_report_pvt.rtp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rtp_rec.trx_parameter_id := p5_a0;
    ddp_rtp_rec.report_id := p5_a1;
    ddp_rtp_rec.try_id := p5_a2;
    ddp_rtp_rec.sty_id := p5_a3;
    ddp_rtp_rec.add_substract_code := p5_a4;
    ddp_rtp_rec.created_by := p5_a5;
    ddp_rtp_rec.creation_date := p5_a6;
    ddp_rtp_rec.last_updated_by := p5_a7;
    ddp_rtp_rec.last_update_date := p5_a8;
    ddp_rtp_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_rec,
      ddx_rtp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rtp_rec.trx_parameter_id;
    p6_a1 := ddx_rtp_rec.report_id;
    p6_a2 := ddx_rtp_rec.try_id;
    p6_a3 := ddx_rtp_rec.sty_id;
    p6_a4 := ddx_rtp_rec.add_substract_code;
    p6_a5 := ddx_rtp_rec.created_by;
    p6_a6 := ddx_rtp_rec.creation_date;
    p6_a7 := ddx_rtp_rec.last_updated_by;
    p6_a8 := ddx_rtp_rec.last_update_date;
    p6_a9 := ddx_rtp_rec.last_update_login;
  end;

  procedure delete_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_rtp_rec okl_report_pvt.rtp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rtp_rec.trx_parameter_id := p5_a0;
    ddp_rtp_rec.report_id := p5_a1;
    ddp_rtp_rec.try_id := p5_a2;
    ddp_rtp_rec.sty_id := p5_a3;
    ddp_rtp_rec.add_substract_code := p5_a4;
    ddp_rtp_rec.created_by := p5_a5;
    ddp_rtp_rec.creation_date := p5_a6;
    ddp_rtp_rec.last_updated_by := p5_a7;
    ddp_rtp_rec.last_update_date := p5_a8;
    ddp_rtp_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_rtp_rec okl_report_pvt.rtp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rtp_rec.trx_parameter_id := p5_a0;
    ddp_rtp_rec.report_id := p5_a1;
    ddp_rtp_rec.try_id := p5_a2;
    ddp_rtp_rec.sty_id := p5_a3;
    ddp_rtp_rec.add_substract_code := p5_a4;
    ddp_rtp_rec.created_by := p5_a5;
    ddp_rtp_rec.creation_date := p5_a6;
    ddp_rtp_rec.last_updated_by := p5_a7;
    ddp_rtp_rec.last_update_date := p5_a8;
    ddp_rtp_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddx_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_tbl,
      ddx_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rtp_pvt_w.rosetta_table_copy_out_p2(ddx_rtp_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure update_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddx_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_tbl,
      ddx_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rtp_pvt_w.rosetta_table_copy_out_p2(ddx_rtp_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure delete_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.delete_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_report_trx_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.lock_report_trx_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_300
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_DATE_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_DATE_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_DATE_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_DATE_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_DATE_TABLE
    , p12_a8 out nocopy JTF_NUMBER_TABLE
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_VARCHAR2_TABLE_100
    , p13_a5 JTF_NUMBER_TABLE
    , p13_a6 JTF_DATE_TABLE
    , p13_a7 JTF_NUMBER_TABLE
    , p13_a8 JTF_DATE_TABLE
    , p13_a9 JTF_NUMBER_TABLE
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_NUMBER_TABLE
    , p14_a8 out nocopy JTF_DATE_TABLE
    , p14_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddx_repv_rec okl_report_pvt.repv_rec_type;
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddx_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddx_rap_tbl okl_report_pvt.rap_tbl_type;
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddx_rps_tbl okl_report_pvt.rps_tbl_type;
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddx_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;


    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p7_a0
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
      );


    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );


    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      );


    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.create_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec,
      ddx_repv_rec,
      ddp_rpp_tbl,
      ddx_rpp_tbl,
      ddp_rap_tbl,
      ddx_rap_tbl,
      ddp_rps_tbl,
      ddx_rps_tbl,
      ddp_rtp_tbl,
      ddx_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_repv_rec.report_id;
    p6_a1 := ddx_repv_rec.name;
    p6_a2 := ddx_repv_rec.chart_of_accounts_id;
    p6_a3 := ddx_repv_rec.book_classification_code;
    p6_a4 := ddx_repv_rec.ledger_id;
    p6_a5 := ddx_repv_rec.report_category_code;
    p6_a6 := ddx_repv_rec.report_type_code;
    p6_a7 := ddx_repv_rec.activity_code;
    p6_a8 := ddx_repv_rec.status_code;
    p6_a9 := ddx_repv_rec.description;
    p6_a10 := ddx_repv_rec.effective_from_date;
    p6_a11 := ddx_repv_rec.effective_to_date;
    p6_a12 := ddx_repv_rec.created_by;
    p6_a13 := ddx_repv_rec.creation_date;
    p6_a14 := ddx_repv_rec.last_updated_by;
    p6_a15 := ddx_repv_rec.last_update_date;
    p6_a16 := ddx_repv_rec.last_update_login;
    p6_a17 := ddx_repv_rec.language;
    p6_a18 := ddx_repv_rec.source_lang;
    p6_a19 := ddx_repv_rec.sfwt_flag;


    okl_rpp_pvt_w.rosetta_table_copy_out_p2(ddx_rpp_tbl, p8_a0
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
      );


    okl_rap_pvt_w.rosetta_table_copy_out_p2(ddx_rap_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      );


    okl_rsp_pvt_w.rosetta_table_copy_out_p2(ddx_rps_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      );


    okl_rtp_pvt_w.rosetta_table_copy_out_p2(ddx_rtp_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      );
  end;

  procedure update_report(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  DATE
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_300
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_DATE_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_DATE_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_DATE_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_DATE_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_DATE_TABLE
    , p12_a8 out nocopy JTF_NUMBER_TABLE
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_VARCHAR2_TABLE_100
    , p13_a5 JTF_NUMBER_TABLE
    , p13_a6 JTF_DATE_TABLE
    , p13_a7 JTF_NUMBER_TABLE
    , p13_a8 JTF_DATE_TABLE
    , p13_a9 JTF_NUMBER_TABLE
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_NUMBER_TABLE
    , p14_a8 out nocopy JTF_DATE_TABLE
    , p14_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_repv_rec okl_report_pvt.repv_rec_type;
    ddx_repv_rec okl_report_pvt.repv_rec_type;
    ddp_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddx_rpp_tbl okl_report_pvt.rpp_tbl_type;
    ddp_rap_tbl okl_report_pvt.rap_tbl_type;
    ddx_rap_tbl okl_report_pvt.rap_tbl_type;
    ddp_rps_tbl okl_report_pvt.rps_tbl_type;
    ddx_rps_tbl okl_report_pvt.rps_tbl_type;
    ddp_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddx_rtp_tbl okl_report_pvt.rtp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_repv_rec.report_id := p5_a0;
    ddp_repv_rec.name := p5_a1;
    ddp_repv_rec.chart_of_accounts_id := p5_a2;
    ddp_repv_rec.book_classification_code := p5_a3;
    ddp_repv_rec.ledger_id := p5_a4;
    ddp_repv_rec.report_category_code := p5_a5;
    ddp_repv_rec.report_type_code := p5_a6;
    ddp_repv_rec.activity_code := p5_a7;
    ddp_repv_rec.status_code := p5_a8;
    ddp_repv_rec.description := p5_a9;
    ddp_repv_rec.effective_from_date := p5_a10;
    ddp_repv_rec.effective_to_date := p5_a11;
    ddp_repv_rec.created_by := p5_a12;
    ddp_repv_rec.creation_date := p5_a13;
    ddp_repv_rec.last_updated_by := p5_a14;
    ddp_repv_rec.last_update_date := p5_a15;
    ddp_repv_rec.last_update_login := p5_a16;
    ddp_repv_rec.language := p5_a17;
    ddp_repv_rec.source_lang := p5_a18;
    ddp_repv_rec.sfwt_flag := p5_a19;


    okl_rpp_pvt_w.rosetta_table_copy_in_p2(ddp_rpp_tbl, p7_a0
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
      );


    okl_rap_pvt_w.rosetta_table_copy_in_p2(ddp_rap_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );


    okl_rsp_pvt_w.rosetta_table_copy_in_p2(ddp_rps_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      );


    okl_rtp_pvt_w.rosetta_table_copy_in_p2(ddp_rtp_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_report_pvt.update_report(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_repv_rec,
      ddx_repv_rec,
      ddp_rpp_tbl,
      ddx_rpp_tbl,
      ddp_rap_tbl,
      ddx_rap_tbl,
      ddp_rps_tbl,
      ddx_rps_tbl,
      ddp_rtp_tbl,
      ddx_rtp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_repv_rec.report_id;
    p6_a1 := ddx_repv_rec.name;
    p6_a2 := ddx_repv_rec.chart_of_accounts_id;
    p6_a3 := ddx_repv_rec.book_classification_code;
    p6_a4 := ddx_repv_rec.ledger_id;
    p6_a5 := ddx_repv_rec.report_category_code;
    p6_a6 := ddx_repv_rec.report_type_code;
    p6_a7 := ddx_repv_rec.activity_code;
    p6_a8 := ddx_repv_rec.status_code;
    p6_a9 := ddx_repv_rec.description;
    p6_a10 := ddx_repv_rec.effective_from_date;
    p6_a11 := ddx_repv_rec.effective_to_date;
    p6_a12 := ddx_repv_rec.created_by;
    p6_a13 := ddx_repv_rec.creation_date;
    p6_a14 := ddx_repv_rec.last_updated_by;
    p6_a15 := ddx_repv_rec.last_update_date;
    p6_a16 := ddx_repv_rec.last_update_login;
    p6_a17 := ddx_repv_rec.language;
    p6_a18 := ddx_repv_rec.source_lang;
    p6_a19 := ddx_repv_rec.sfwt_flag;


    okl_rpp_pvt_w.rosetta_table_copy_out_p2(ddx_rpp_tbl, p8_a0
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
      );


    okl_rap_pvt_w.rosetta_table_copy_out_p2(ddx_rap_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      );


    okl_rsp_pvt_w.rosetta_table_copy_out_p2(ddx_rps_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      );


    okl_rtp_pvt_w.rosetta_table_copy_out_p2(ddx_rtp_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      );
  end;

end okl_report_pvt_w;

/
