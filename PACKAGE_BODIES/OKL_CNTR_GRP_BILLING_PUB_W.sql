--------------------------------------------------------
--  DDL for Package Body OKL_CNTR_GRP_BILLING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNTR_GRP_BILLING_PUB_W" as
  /* $Header: OKLUCLBB.pls 120.6 2008/02/21 13:26:26 udhenuko noship $ */
  procedure calculate_cntgrp_bill_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cntr_bill_tbl okl_cntr_grp_billing_pub.cntr_bill_tbl_type;
    ddx_cntr_bill_tbl okl_cntr_grp_billing_pub.cntr_bill_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cntr_grp_billing_pvt_w.rosetta_table_copy_in_p14(ddp_cntr_bill_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cntr_grp_billing_pub.calculate_cntgrp_bill_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cntr_bill_tbl,
      ddx_cntr_bill_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cntr_grp_billing_pvt_w.rosetta_table_copy_out_p14(ddx_cntr_bill_tbl, p6_a0
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
      );
  end;

  procedure calculate_cntgrp_bill_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
  )

  as
    ddp_cntr_bill_rec okl_cntr_grp_billing_pub.cntr_bill_rec_type;
    ddx_cntr_bill_rec okl_cntr_grp_billing_pub.cntr_bill_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cntr_bill_rec.clg_id := p5_a0;
    ddp_cntr_bill_rec.counter_group := p5_a1;
    ddp_cntr_bill_rec.counter_number := p5_a2;
    ddp_cntr_bill_rec.counter_name := p5_a3;
    ddp_cntr_bill_rec.contract_number := p5_a4;
    ddp_cntr_bill_rec.asset_number := p5_a5;
    ddp_cntr_bill_rec.asset_serial_number := p5_a6;
    ddp_cntr_bill_rec.asset_description := p5_a7;
    ddp_cntr_bill_rec.effective_date_from := p5_a8;
    ddp_cntr_bill_rec.effective_date_to := p5_a9;
    ddp_cntr_bill_rec.counter_reading := p5_a10;
    ddp_cntr_bill_rec.counter_reading_date := p5_a11;
    ddp_cntr_bill_rec.counter_bill_amount := p5_a12;
    ddp_cntr_bill_rec.legal_entity_id := p5_a13;


    -- here's the delegated call to the old PL/SQL routine
    okl_cntr_grp_billing_pub.calculate_cntgrp_bill_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cntr_bill_rec,
      ddx_cntr_bill_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_cntr_bill_rec.clg_id;
    p6_a1 := ddx_cntr_bill_rec.counter_group;
    p6_a2 := ddx_cntr_bill_rec.counter_number;
    p6_a3 := ddx_cntr_bill_rec.counter_name;
    p6_a4 := ddx_cntr_bill_rec.contract_number;
    p6_a5 := ddx_cntr_bill_rec.asset_number;
    p6_a6 := ddx_cntr_bill_rec.asset_serial_number;
    p6_a7 := ddx_cntr_bill_rec.asset_description;
    p6_a8 := ddx_cntr_bill_rec.effective_date_from;
    p6_a9 := ddx_cntr_bill_rec.effective_date_to;
    p6_a10 := ddx_cntr_bill_rec.counter_reading;
    p6_a11 := ddx_cntr_bill_rec.counter_reading_date;
    p6_a12 := ddx_cntr_bill_rec.counter_bill_amount;
    p6_a13 := ddx_cntr_bill_rec.legal_entity_id;
  end;

  procedure insert_cntr_grp_bill(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cntr_bill_tbl okl_cntr_grp_billing_pub.cntr_bill_tbl_type;
    ddx_cntr_bill_tbl okl_cntr_grp_billing_pub.cntr_bill_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cntr_grp_billing_pvt_w.rosetta_table_copy_in_p14(ddp_cntr_bill_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cntr_grp_billing_pub.insert_cntr_grp_bill(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cntr_bill_tbl,
      ddx_cntr_bill_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cntr_grp_billing_pvt_w.rosetta_table_copy_out_p14(ddx_cntr_bill_tbl, p6_a0
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
      );
  end;

  procedure insert_cntr_grp_bill(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
  )

  as
    ddp_cntr_bill_rec okl_cntr_grp_billing_pub.cntr_bill_rec_type;
    ddx_cntr_bill_rec okl_cntr_grp_billing_pub.cntr_bill_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cntr_bill_rec.clg_id := p5_a0;
    ddp_cntr_bill_rec.counter_group := p5_a1;
    ddp_cntr_bill_rec.counter_number := p5_a2;
    ddp_cntr_bill_rec.counter_name := p5_a3;
    ddp_cntr_bill_rec.contract_number := p5_a4;
    ddp_cntr_bill_rec.asset_number := p5_a5;
    ddp_cntr_bill_rec.asset_serial_number := p5_a6;
    ddp_cntr_bill_rec.asset_description := p5_a7;
    ddp_cntr_bill_rec.effective_date_from := p5_a8;
    ddp_cntr_bill_rec.effective_date_to := p5_a9;
    ddp_cntr_bill_rec.counter_reading := p5_a10;
    ddp_cntr_bill_rec.counter_reading_date := p5_a11;
    ddp_cntr_bill_rec.counter_bill_amount := p5_a12;
    ddp_cntr_bill_rec.legal_entity_id := p5_a13;


    -- here's the delegated call to the old PL/SQL routine
    okl_cntr_grp_billing_pub.insert_cntr_grp_bill(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cntr_bill_rec,
      ddx_cntr_bill_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_cntr_bill_rec.clg_id;
    p6_a1 := ddx_cntr_bill_rec.counter_group;
    p6_a2 := ddx_cntr_bill_rec.counter_number;
    p6_a3 := ddx_cntr_bill_rec.counter_name;
    p6_a4 := ddx_cntr_bill_rec.contract_number;
    p6_a5 := ddx_cntr_bill_rec.asset_number;
    p6_a6 := ddx_cntr_bill_rec.asset_serial_number;
    p6_a7 := ddx_cntr_bill_rec.asset_description;
    p6_a8 := ddx_cntr_bill_rec.effective_date_from;
    p6_a9 := ddx_cntr_bill_rec.effective_date_to;
    p6_a10 := ddx_cntr_bill_rec.counter_reading;
    p6_a11 := ddx_cntr_bill_rec.counter_reading_date;
    p6_a12 := ddx_cntr_bill_rec.counter_bill_amount;
    p6_a13 := ddx_cntr_bill_rec.legal_entity_id;
  end;

end okl_cntr_grp_billing_pub_w;

/
