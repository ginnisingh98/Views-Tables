--------------------------------------------------------
--  DDL for Package Body OKL_CNTR_GRP_BILLING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNTR_GRP_BILLING_PVT_W" as
  /* $Header: OKLICLBB.pls 120.3 2008/02/21 13:25:14 udhenuko noship $ */
  procedure rosetta_table_copy_in_p14(t out nocopy okl_cntr_grp_billing_pvt.cntr_bill_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).clg_id := a0(indx);
          t(ddindx).counter_group := a1(indx);
          t(ddindx).counter_number := a2(indx);
          t(ddindx).counter_name := a3(indx);
          t(ddindx).contract_number := a4(indx);
          t(ddindx).asset_number := a5(indx);
          t(ddindx).asset_serial_number := a6(indx);
          t(ddindx).asset_description := a7(indx);
          t(ddindx).effective_date_from := a8(indx);
          t(ddindx).effective_date_to := a9(indx);
          t(ddindx).counter_reading := a10(indx);
          t(ddindx).counter_reading_date := a11(indx);
          t(ddindx).counter_bill_amount := a12(indx);
          t(ddindx).legal_entity_id := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t okl_cntr_grp_billing_pvt.cntr_bill_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).clg_id;
          a1(indx) := t(ddindx).counter_group;
          a2(indx) := t(ddindx).counter_number;
          a3(indx) := t(ddindx).counter_name;
          a4(indx) := t(ddindx).contract_number;
          a5(indx) := t(ddindx).asset_number;
          a6(indx) := t(ddindx).asset_serial_number;
          a7(indx) := t(ddindx).asset_description;
          a8(indx) := t(ddindx).effective_date_from;
          a9(indx) := t(ddindx).effective_date_to;
          a10(indx) := t(ddindx).counter_reading;
          a11(indx) := t(ddindx).counter_reading_date;
          a12(indx) := t(ddindx).counter_bill_amount;
          a13(indx) := t(ddindx).legal_entity_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure counter_grp_billing_calc(p_api_version  NUMBER
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
    ddp_cntr_bill_rec okl_cntr_grp_billing_pvt.cntr_bill_rec_type;
    ddx_cntr_bill_rec okl_cntr_grp_billing_pvt.cntr_bill_rec_type;
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
    okl_cntr_grp_billing_pvt.counter_grp_billing_calc(p_api_version,
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

  procedure counter_grp_billing_calc(p_api_version  NUMBER
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
    ddp_cntr_bill_tbl okl_cntr_grp_billing_pvt.cntr_bill_tbl_type;
    ddx_cntr_bill_tbl okl_cntr_grp_billing_pvt.cntr_bill_tbl_type;
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
    okl_cntr_grp_billing_pvt.counter_grp_billing_calc(p_api_version,
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

  procedure counter_grp_billing_insert(p_api_version  NUMBER
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
    ddp_cntr_bill_rec okl_cntr_grp_billing_pvt.cntr_bill_rec_type;
    ddx_cntr_bill_rec okl_cntr_grp_billing_pvt.cntr_bill_rec_type;
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
    okl_cntr_grp_billing_pvt.counter_grp_billing_insert(p_api_version,
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

  procedure counter_grp_billing_insert(p_api_version  NUMBER
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
    ddp_cntr_bill_tbl okl_cntr_grp_billing_pvt.cntr_bill_tbl_type;
    ddx_cntr_bill_tbl okl_cntr_grp_billing_pvt.cntr_bill_tbl_type;
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
    okl_cntr_grp_billing_pvt.counter_grp_billing_insert(p_api_version,
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

end okl_cntr_grp_billing_pvt_w;

/
