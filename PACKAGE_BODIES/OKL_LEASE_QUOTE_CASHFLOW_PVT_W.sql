--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_CASHFLOW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_CASHFLOW_PVT_W" as
  /* $Header: OKLEQUCB.pls 120.5 2006/02/10 07:41:27 asawanka noship $ */
  procedure rosetta_table_copy_in_p21(t out nocopy okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cashflow_level_id := a0(indx);
          t(ddindx).start_date := a1(indx);
          t(ddindx).rate := a2(indx);
          t(ddindx).stub_amount := a3(indx);
          t(ddindx).stub_days := a4(indx);
          t(ddindx).periods := a5(indx);
          t(ddindx).periodic_amount := a6(indx);
          t(ddindx).cashflow_level_ovn := a7(indx);
          t(ddindx).record_mode := a8(indx);
          t(ddindx).missing_pmt_flag := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cashflow_level_id;
          a1(indx) := t(ddindx).start_date;
          a2(indx) := t(ddindx).rate;
          a3(indx) := t(ddindx).stub_amount;
          a4(indx) := t(ddindx).stub_days;
          a5(indx) := t(ddindx).periods;
          a6(indx) := t(ddindx).periodic_amount;
          a7(indx) := t(ddindx).cashflow_level_ovn;
          a8(indx) := t(ddindx).record_mode;
          a9(indx) := t(ddindx).missing_pmt_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure create_cashflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  NUMBER
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  VARCHAR2
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  VARCHAR2
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  NUMBER
    , p3_a12 in out nocopy  NUMBER
    , p3_a13 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cashflow_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_cashflow_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_cashflow_header_rec.type_code := p3_a0;
    ddp_cashflow_header_rec.stream_type_id := p3_a1;
    ddp_cashflow_header_rec.status_code := p3_a2;
    ddp_cashflow_header_rec.arrears_flag := p3_a3;
    ddp_cashflow_header_rec.frequency_code := p3_a4;
    ddp_cashflow_header_rec.dnz_periods := p3_a5;
    ddp_cashflow_header_rec.dnz_periodic_amount := p3_a6;
    ddp_cashflow_header_rec.parent_object_code := p3_a7;
    ddp_cashflow_header_rec.parent_object_id := p3_a8;
    ddp_cashflow_header_rec.quote_type_code := p3_a9;
    ddp_cashflow_header_rec.quote_id := p3_a10;
    ddp_cashflow_header_rec.cashflow_header_id := p3_a11;
    ddp_cashflow_header_rec.cashflow_object_id := p3_a12;
    ddp_cashflow_header_rec.cashflow_header_ovn := p3_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cashflow_level_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_cashflow_pvt.create_cashflow(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_cashflow_header_rec,
      ddp_cashflow_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddp_cashflow_header_rec.type_code;
    p3_a1 := ddp_cashflow_header_rec.stream_type_id;
    p3_a2 := ddp_cashflow_header_rec.status_code;
    p3_a3 := ddp_cashflow_header_rec.arrears_flag;
    p3_a4 := ddp_cashflow_header_rec.frequency_code;
    p3_a5 := ddp_cashflow_header_rec.dnz_periods;
    p3_a6 := ddp_cashflow_header_rec.dnz_periodic_amount;
    p3_a7 := ddp_cashflow_header_rec.parent_object_code;
    p3_a8 := ddp_cashflow_header_rec.parent_object_id;
    p3_a9 := ddp_cashflow_header_rec.quote_type_code;
    p3_a10 := ddp_cashflow_header_rec.quote_id;
    p3_a11 := ddp_cashflow_header_rec.cashflow_header_id;
    p3_a12 := ddp_cashflow_header_rec.cashflow_object_id;
    p3_a13 := ddp_cashflow_header_rec.cashflow_header_ovn;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_out_p21(ddp_cashflow_level_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );



  end;

  procedure update_cashflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  NUMBER
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  VARCHAR2
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  VARCHAR2
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  NUMBER
    , p3_a12 in out nocopy  NUMBER
    , p3_a13 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cashflow_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_cashflow_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_cashflow_header_rec.type_code := p3_a0;
    ddp_cashflow_header_rec.stream_type_id := p3_a1;
    ddp_cashflow_header_rec.status_code := p3_a2;
    ddp_cashflow_header_rec.arrears_flag := p3_a3;
    ddp_cashflow_header_rec.frequency_code := p3_a4;
    ddp_cashflow_header_rec.dnz_periods := p3_a5;
    ddp_cashflow_header_rec.dnz_periodic_amount := p3_a6;
    ddp_cashflow_header_rec.parent_object_code := p3_a7;
    ddp_cashflow_header_rec.parent_object_id := p3_a8;
    ddp_cashflow_header_rec.quote_type_code := p3_a9;
    ddp_cashflow_header_rec.quote_id := p3_a10;
    ddp_cashflow_header_rec.cashflow_header_id := p3_a11;
    ddp_cashflow_header_rec.cashflow_object_id := p3_a12;
    ddp_cashflow_header_rec.cashflow_header_ovn := p3_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cashflow_level_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_cashflow_pvt.update_cashflow(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_cashflow_header_rec,
      ddp_cashflow_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddp_cashflow_header_rec.type_code;
    p3_a1 := ddp_cashflow_header_rec.stream_type_id;
    p3_a2 := ddp_cashflow_header_rec.status_code;
    p3_a3 := ddp_cashflow_header_rec.arrears_flag;
    p3_a4 := ddp_cashflow_header_rec.frequency_code;
    p3_a5 := ddp_cashflow_header_rec.dnz_periods;
    p3_a6 := ddp_cashflow_header_rec.dnz_periodic_amount;
    p3_a7 := ddp_cashflow_header_rec.parent_object_code;
    p3_a8 := ddp_cashflow_header_rec.parent_object_id;
    p3_a9 := ddp_cashflow_header_rec.quote_type_code;
    p3_a10 := ddp_cashflow_header_rec.quote_id;
    p3_a11 := ddp_cashflow_header_rec.cashflow_header_id;
    p3_a12 := ddp_cashflow_header_rec.cashflow_object_id;
    p3_a13 := ddp_cashflow_header_rec.cashflow_header_ovn;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_out_p21(ddp_cashflow_level_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );



  end;

end okl_lease_quote_cashflow_pvt_w;

/
