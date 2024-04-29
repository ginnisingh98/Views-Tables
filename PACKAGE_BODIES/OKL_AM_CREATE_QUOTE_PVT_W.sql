--------------------------------------------------------
--  DDL for Package Body OKL_AM_CREATE_QUOTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CREATE_QUOTE_PVT_W" as
  /* $Header: OKLECQTB.pls 120.4 2007/11/02 21:03:44 rmunjulu ship $ */
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

  procedure rosetta_table_copy_in_p17(t out nocopy okl_am_create_quote_pvt.assn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).p_asset_number := a1(indx);
          t(ddindx).p_asset_qty := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).p_quote_qty := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).p_split_asset_number := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t okl_am_create_quote_pvt.assn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).p_asset_id);
          a1(indx) := t(ddindx).p_asset_number;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).p_asset_qty);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).p_quote_qty);
          a4(indx) := t(ddindx).p_split_asset_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p19(t out nocopy okl_am_create_quote_pvt.achr_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_number := a0(indx);
          t(ddindx).serial_number := a1(indx);
          t(ddindx).chr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).contract_number := a3(indx);
          t(ddindx).from_start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).to_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).from_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).to_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).sts_code := a8(indx);
          t(ddindx).sts_meaning := a9(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).party_name := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t okl_am_create_quote_pvt.achr_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_400();
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
          a0(indx) := t(ddindx).asset_number;
          a1(indx) := t(ddindx).serial_number;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a3(indx) := t(ddindx).contract_number;
          a4(indx) := t(ddindx).from_start_date;
          a5(indx) := t(ddindx).to_start_date;
          a6(indx) := t(ddindx).from_end_date;
          a7(indx) := t(ddindx).to_end_date;
          a8(indx) := t(ddindx).sts_code;
          a9(indx) := t(ddindx).sts_meaning;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a11(indx) := t(ddindx).party_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure advance_contract_search(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_achr_rec okl_am_create_quote_pvt.achr_rec_type;
    ddx_achr_tbl okl_am_create_quote_pvt.achr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_achr_rec.asset_number := p5_a0;
    ddp_achr_rec.serial_number := p5_a1;
    ddp_achr_rec.chr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_achr_rec.contract_number := p5_a3;
    ddp_achr_rec.from_start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_achr_rec.to_start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_achr_rec.from_end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_achr_rec.to_end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_achr_rec.sts_code := p5_a8;
    ddp_achr_rec.sts_meaning := p5_a9;
    ddp_achr_rec.org_id := rosetta_g_miss_num_map(p5_a10);
    ddp_achr_rec.party_name := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_am_create_quote_pvt.advance_contract_search(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_achr_rec,
      ddx_achr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_create_quote_pvt_w.rosetta_table_copy_out_p19(ddx_achr_tbl, p6_a0
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

  procedure quote_effectivity(p_rule_chr_id  NUMBER
    , x_quote_eff_days out nocopy  NUMBER
    , x_quote_eff_max_days out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  DATE := fnd_api.g_miss_date
    , p0_a58  NUMBER := 0-1962.0724
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
    , p0_a62  NUMBER := 0-1962.0724
    , p0_a63  DATE := fnd_api.g_miss_date
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  DATE := fnd_api.g_miss_date
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  NUMBER := 0-1962.0724
    , p0_a72  NUMBER := 0-1962.0724
    , p0_a73  NUMBER := 0-1962.0724
    , p0_a74  NUMBER := 0-1962.0724
    , p0_a75  NUMBER := 0-1962.0724
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  DATE := fnd_api.g_miss_date
    , p0_a81  NUMBER := 0-1962.0724
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_quot_rec okl_am_create_quote_pvt.quot_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_quot_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_quot_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_quot_rec.sfwt_flag := p0_a2;
    ddp_quot_rec.qrs_code := p0_a3;
    ddp_quot_rec.qst_code := p0_a4;
    ddp_quot_rec.qtp_code := p0_a5;
    ddp_quot_rec.trn_code := p0_a6;
    ddp_quot_rec.pop_code_end := p0_a7;
    ddp_quot_rec.pop_code_early := p0_a8;
    ddp_quot_rec.consolidated_qte_id := rosetta_g_miss_num_map(p0_a9);
    ddp_quot_rec.khr_id := rosetta_g_miss_num_map(p0_a10);
    ddp_quot_rec.art_id := rosetta_g_miss_num_map(p0_a11);
    ddp_quot_rec.pdt_id := rosetta_g_miss_num_map(p0_a12);
    ddp_quot_rec.early_termination_yn := p0_a13;
    ddp_quot_rec.partial_yn := p0_a14;
    ddp_quot_rec.preproceeds_yn := p0_a15;
    ddp_quot_rec.date_requested := rosetta_g_miss_date_in_map(p0_a16);
    ddp_quot_rec.date_proposal := rosetta_g_miss_date_in_map(p0_a17);
    ddp_quot_rec.date_effective_to := rosetta_g_miss_date_in_map(p0_a18);
    ddp_quot_rec.date_accepted := rosetta_g_miss_date_in_map(p0_a19);
    ddp_quot_rec.summary_format_yn := p0_a20;
    ddp_quot_rec.consolidated_yn := p0_a21;
    ddp_quot_rec.principal_paydown_amount := rosetta_g_miss_num_map(p0_a22);
    ddp_quot_rec.residual_amount := rosetta_g_miss_num_map(p0_a23);
    ddp_quot_rec.yield := rosetta_g_miss_num_map(p0_a24);
    ddp_quot_rec.rent_amount := rosetta_g_miss_num_map(p0_a25);
    ddp_quot_rec.date_restructure_end := rosetta_g_miss_date_in_map(p0_a26);
    ddp_quot_rec.date_restructure_start := rosetta_g_miss_date_in_map(p0_a27);
    ddp_quot_rec.term := rosetta_g_miss_num_map(p0_a28);
    ddp_quot_rec.purchase_percent := rosetta_g_miss_num_map(p0_a29);
    ddp_quot_rec.comments := p0_a30;
    ddp_quot_rec.date_due := rosetta_g_miss_date_in_map(p0_a31);
    ddp_quot_rec.payment_frequency := p0_a32;
    ddp_quot_rec.remaining_payments := rosetta_g_miss_num_map(p0_a33);
    ddp_quot_rec.date_effective_from := rosetta_g_miss_date_in_map(p0_a34);
    ddp_quot_rec.quote_number := rosetta_g_miss_num_map(p0_a35);
    ddp_quot_rec.requested_by := rosetta_g_miss_num_map(p0_a36);
    ddp_quot_rec.approved_yn := p0_a37;
    ddp_quot_rec.accepted_yn := p0_a38;
    ddp_quot_rec.payment_received_yn := p0_a39;
    ddp_quot_rec.date_payment_received := rosetta_g_miss_date_in_map(p0_a40);
    ddp_quot_rec.attribute_category := p0_a41;
    ddp_quot_rec.attribute1 := p0_a42;
    ddp_quot_rec.attribute2 := p0_a43;
    ddp_quot_rec.attribute3 := p0_a44;
    ddp_quot_rec.attribute4 := p0_a45;
    ddp_quot_rec.attribute5 := p0_a46;
    ddp_quot_rec.attribute6 := p0_a47;
    ddp_quot_rec.attribute7 := p0_a48;
    ddp_quot_rec.attribute8 := p0_a49;
    ddp_quot_rec.attribute9 := p0_a50;
    ddp_quot_rec.attribute10 := p0_a51;
    ddp_quot_rec.attribute11 := p0_a52;
    ddp_quot_rec.attribute12 := p0_a53;
    ddp_quot_rec.attribute13 := p0_a54;
    ddp_quot_rec.attribute14 := p0_a55;
    ddp_quot_rec.attribute15 := p0_a56;
    ddp_quot_rec.date_approved := rosetta_g_miss_date_in_map(p0_a57);
    ddp_quot_rec.approved_by := rosetta_g_miss_num_map(p0_a58);
    ddp_quot_rec.org_id := rosetta_g_miss_num_map(p0_a59);
    ddp_quot_rec.request_id := rosetta_g_miss_num_map(p0_a60);
    ddp_quot_rec.program_application_id := rosetta_g_miss_num_map(p0_a61);
    ddp_quot_rec.program_id := rosetta_g_miss_num_map(p0_a62);
    ddp_quot_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a63);
    ddp_quot_rec.created_by := rosetta_g_miss_num_map(p0_a64);
    ddp_quot_rec.creation_date := rosetta_g_miss_date_in_map(p0_a65);
    ddp_quot_rec.last_updated_by := rosetta_g_miss_num_map(p0_a66);
    ddp_quot_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_quot_rec.last_update_login := rosetta_g_miss_num_map(p0_a68);
    ddp_quot_rec.purchase_amount := rosetta_g_miss_num_map(p0_a69);
    ddp_quot_rec.purchase_formula := p0_a70;
    ddp_quot_rec.asset_value := rosetta_g_miss_num_map(p0_a71);
    ddp_quot_rec.residual_value := rosetta_g_miss_num_map(p0_a72);
    ddp_quot_rec.unbilled_receivables := rosetta_g_miss_num_map(p0_a73);
    ddp_quot_rec.gain_loss := rosetta_g_miss_num_map(p0_a74);
    ddp_quot_rec.perdiem_amount := rosetta_g_miss_num_map(p0_a75);
    ddp_quot_rec.currency_code := p0_a76;
    ddp_quot_rec.currency_conversion_code := p0_a77;
    ddp_quot_rec.currency_conversion_type := p0_a78;
    ddp_quot_rec.currency_conversion_rate := rosetta_g_miss_num_map(p0_a79);
    ddp_quot_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p0_a80);
    ddp_quot_rec.legal_entity_id := rosetta_g_miss_num_map(p0_a81);
    ddp_quot_rec.repo_quote_indicator_yn := p0_a82;





    -- here's the delegated call to the old PL/SQL routine
    okl_am_create_quote_pvt.quote_effectivity(ddp_quot_rec,
      p_rule_chr_id,
      x_quote_eff_days,
      x_quote_eff_max_days,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure create_terminate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_200
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_200
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_600
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_200
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_200
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  DATE
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  NUMBER
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  DATE
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  DATE
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  NUMBER
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  VARCHAR2
    , p8_a79 out nocopy  NUMBER
    , p8_a80 out nocopy  DATE
    , p8_a81 out nocopy  NUMBER
    , p8_a82 out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_NUMBER_TABLE
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_NUMBER_TABLE
    , p9_a33 out nocopy JTF_DATE_TABLE
    , p9_a34 out nocopy JTF_NUMBER_TABLE
    , p9_a35 out nocopy JTF_DATE_TABLE
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_DATE_TABLE
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_DATE_TABLE
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a45 out nocopy JTF_NUMBER_TABLE
    , p9_a46 out nocopy JTF_NUMBER_TABLE
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_NUMBER_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_NUMBER_TABLE
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_NUMBER_TABLE
    , p9_a58 out nocopy JTF_DATE_TABLE
    , p9_a59 out nocopy JTF_DATE_TABLE
    , p9_a60 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_quot_rec okl_am_create_quote_pvt.quot_rec_type;
    ddp_assn_tbl okl_am_create_quote_pvt.assn_tbl_type;
    ddp_qpyv_tbl okl_am_create_quote_pvt.qpyv_tbl_type;
    ddx_quot_rec okl_am_create_quote_pvt.quot_rec_type;
    ddx_tqlv_tbl okl_am_create_quote_pvt.tqlv_tbl_type;
    ddx_assn_tbl okl_am_create_quote_pvt.assn_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_quot_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_quot_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_quot_rec.sfwt_flag := p5_a2;
    ddp_quot_rec.qrs_code := p5_a3;
    ddp_quot_rec.qst_code := p5_a4;
    ddp_quot_rec.qtp_code := p5_a5;
    ddp_quot_rec.trn_code := p5_a6;
    ddp_quot_rec.pop_code_end := p5_a7;
    ddp_quot_rec.pop_code_early := p5_a8;
    ddp_quot_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_quot_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_quot_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_quot_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_quot_rec.early_termination_yn := p5_a13;
    ddp_quot_rec.partial_yn := p5_a14;
    ddp_quot_rec.preproceeds_yn := p5_a15;
    ddp_quot_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_quot_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_quot_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_quot_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_quot_rec.summary_format_yn := p5_a20;
    ddp_quot_rec.consolidated_yn := p5_a21;
    ddp_quot_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_quot_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_quot_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_quot_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_quot_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_quot_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_quot_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_quot_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_quot_rec.comments := p5_a30;
    ddp_quot_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_quot_rec.payment_frequency := p5_a32;
    ddp_quot_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_quot_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_quot_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_quot_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_quot_rec.approved_yn := p5_a37;
    ddp_quot_rec.accepted_yn := p5_a38;
    ddp_quot_rec.payment_received_yn := p5_a39;
    ddp_quot_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_quot_rec.attribute_category := p5_a41;
    ddp_quot_rec.attribute1 := p5_a42;
    ddp_quot_rec.attribute2 := p5_a43;
    ddp_quot_rec.attribute3 := p5_a44;
    ddp_quot_rec.attribute4 := p5_a45;
    ddp_quot_rec.attribute5 := p5_a46;
    ddp_quot_rec.attribute6 := p5_a47;
    ddp_quot_rec.attribute7 := p5_a48;
    ddp_quot_rec.attribute8 := p5_a49;
    ddp_quot_rec.attribute9 := p5_a50;
    ddp_quot_rec.attribute10 := p5_a51;
    ddp_quot_rec.attribute11 := p5_a52;
    ddp_quot_rec.attribute12 := p5_a53;
    ddp_quot_rec.attribute13 := p5_a54;
    ddp_quot_rec.attribute14 := p5_a55;
    ddp_quot_rec.attribute15 := p5_a56;
    ddp_quot_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_quot_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_quot_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_quot_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_quot_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_quot_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_quot_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_quot_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_quot_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_quot_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_quot_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_quot_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_quot_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_quot_rec.purchase_formula := p5_a70;
    ddp_quot_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_quot_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_quot_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_quot_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_quot_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_quot_rec.currency_code := p5_a76;
    ddp_quot_rec.currency_conversion_code := p5_a77;
    ddp_quot_rec.currency_conversion_type := p5_a78;
    ddp_quot_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_quot_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_quot_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_quot_rec.repo_quote_indicator_yn := p5_a82;

    okl_am_create_quote_pvt_w.rosetta_table_copy_in_p17(ddp_assn_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      );

    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p7_a0
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
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_am_create_quote_pvt.create_terminate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_quot_rec,
      ddp_assn_tbl,
      ddp_qpyv_tbl,
      ddx_quot_rec,
      ddx_tqlv_tbl,
      ddx_assn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_quot_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_quot_rec.object_version_number);
    p8_a2 := ddx_quot_rec.sfwt_flag;
    p8_a3 := ddx_quot_rec.qrs_code;
    p8_a4 := ddx_quot_rec.qst_code;
    p8_a5 := ddx_quot_rec.qtp_code;
    p8_a6 := ddx_quot_rec.trn_code;
    p8_a7 := ddx_quot_rec.pop_code_end;
    p8_a8 := ddx_quot_rec.pop_code_early;
    p8_a9 := rosetta_g_miss_num_map(ddx_quot_rec.consolidated_qte_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_quot_rec.khr_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_quot_rec.art_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_quot_rec.pdt_id);
    p8_a13 := ddx_quot_rec.early_termination_yn;
    p8_a14 := ddx_quot_rec.partial_yn;
    p8_a15 := ddx_quot_rec.preproceeds_yn;
    p8_a16 := ddx_quot_rec.date_requested;
    p8_a17 := ddx_quot_rec.date_proposal;
    p8_a18 := ddx_quot_rec.date_effective_to;
    p8_a19 := ddx_quot_rec.date_accepted;
    p8_a20 := ddx_quot_rec.summary_format_yn;
    p8_a21 := ddx_quot_rec.consolidated_yn;
    p8_a22 := rosetta_g_miss_num_map(ddx_quot_rec.principal_paydown_amount);
    p8_a23 := rosetta_g_miss_num_map(ddx_quot_rec.residual_amount);
    p8_a24 := rosetta_g_miss_num_map(ddx_quot_rec.yield);
    p8_a25 := rosetta_g_miss_num_map(ddx_quot_rec.rent_amount);
    p8_a26 := ddx_quot_rec.date_restructure_end;
    p8_a27 := ddx_quot_rec.date_restructure_start;
    p8_a28 := rosetta_g_miss_num_map(ddx_quot_rec.term);
    p8_a29 := rosetta_g_miss_num_map(ddx_quot_rec.purchase_percent);
    p8_a30 := ddx_quot_rec.comments;
    p8_a31 := ddx_quot_rec.date_due;
    p8_a32 := ddx_quot_rec.payment_frequency;
    p8_a33 := rosetta_g_miss_num_map(ddx_quot_rec.remaining_payments);
    p8_a34 := ddx_quot_rec.date_effective_from;
    p8_a35 := rosetta_g_miss_num_map(ddx_quot_rec.quote_number);
    p8_a36 := rosetta_g_miss_num_map(ddx_quot_rec.requested_by);
    p8_a37 := ddx_quot_rec.approved_yn;
    p8_a38 := ddx_quot_rec.accepted_yn;
    p8_a39 := ddx_quot_rec.payment_received_yn;
    p8_a40 := ddx_quot_rec.date_payment_received;
    p8_a41 := ddx_quot_rec.attribute_category;
    p8_a42 := ddx_quot_rec.attribute1;
    p8_a43 := ddx_quot_rec.attribute2;
    p8_a44 := ddx_quot_rec.attribute3;
    p8_a45 := ddx_quot_rec.attribute4;
    p8_a46 := ddx_quot_rec.attribute5;
    p8_a47 := ddx_quot_rec.attribute6;
    p8_a48 := ddx_quot_rec.attribute7;
    p8_a49 := ddx_quot_rec.attribute8;
    p8_a50 := ddx_quot_rec.attribute9;
    p8_a51 := ddx_quot_rec.attribute10;
    p8_a52 := ddx_quot_rec.attribute11;
    p8_a53 := ddx_quot_rec.attribute12;
    p8_a54 := ddx_quot_rec.attribute13;
    p8_a55 := ddx_quot_rec.attribute14;
    p8_a56 := ddx_quot_rec.attribute15;
    p8_a57 := ddx_quot_rec.date_approved;
    p8_a58 := rosetta_g_miss_num_map(ddx_quot_rec.approved_by);
    p8_a59 := rosetta_g_miss_num_map(ddx_quot_rec.org_id);
    p8_a60 := rosetta_g_miss_num_map(ddx_quot_rec.request_id);
    p8_a61 := rosetta_g_miss_num_map(ddx_quot_rec.program_application_id);
    p8_a62 := rosetta_g_miss_num_map(ddx_quot_rec.program_id);
    p8_a63 := ddx_quot_rec.program_update_date;
    p8_a64 := rosetta_g_miss_num_map(ddx_quot_rec.created_by);
    p8_a65 := ddx_quot_rec.creation_date;
    p8_a66 := rosetta_g_miss_num_map(ddx_quot_rec.last_updated_by);
    p8_a67 := ddx_quot_rec.last_update_date;
    p8_a68 := rosetta_g_miss_num_map(ddx_quot_rec.last_update_login);
    p8_a69 := rosetta_g_miss_num_map(ddx_quot_rec.purchase_amount);
    p8_a70 := ddx_quot_rec.purchase_formula;
    p8_a71 := rosetta_g_miss_num_map(ddx_quot_rec.asset_value);
    p8_a72 := rosetta_g_miss_num_map(ddx_quot_rec.residual_value);
    p8_a73 := rosetta_g_miss_num_map(ddx_quot_rec.unbilled_receivables);
    p8_a74 := rosetta_g_miss_num_map(ddx_quot_rec.gain_loss);
    p8_a75 := rosetta_g_miss_num_map(ddx_quot_rec.perdiem_amount);
    p8_a76 := ddx_quot_rec.currency_code;
    p8_a77 := ddx_quot_rec.currency_conversion_code;
    p8_a78 := ddx_quot_rec.currency_conversion_type;
    p8_a79 := rosetta_g_miss_num_map(ddx_quot_rec.currency_conversion_rate);
    p8_a80 := ddx_quot_rec.currency_conversion_date;
    p8_a81 := rosetta_g_miss_num_map(ddx_quot_rec.legal_entity_id);
    p8_a82 := ddx_quot_rec.repo_quote_indicator_yn;

    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p9_a0
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
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      );

    okl_am_create_quote_pvt_w.rosetta_table_copy_out_p17(ddx_assn_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      );
  end;

  procedure get_net_gain_loss(p_chr_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_net_gain_loss out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  DATE := fnd_api.g_miss_date
    , p0_a58  NUMBER := 0-1962.0724
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
    , p0_a62  NUMBER := 0-1962.0724
    , p0_a63  DATE := fnd_api.g_miss_date
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  DATE := fnd_api.g_miss_date
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  NUMBER := 0-1962.0724
    , p0_a72  NUMBER := 0-1962.0724
    , p0_a73  NUMBER := 0-1962.0724
    , p0_a74  NUMBER := 0-1962.0724
    , p0_a75  NUMBER := 0-1962.0724
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  DATE := fnd_api.g_miss_date
    , p0_a81  NUMBER := 0-1962.0724
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_quote_rec okl_am_create_quote_pvt.quot_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_quote_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_quote_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_quote_rec.sfwt_flag := p0_a2;
    ddp_quote_rec.qrs_code := p0_a3;
    ddp_quote_rec.qst_code := p0_a4;
    ddp_quote_rec.qtp_code := p0_a5;
    ddp_quote_rec.trn_code := p0_a6;
    ddp_quote_rec.pop_code_end := p0_a7;
    ddp_quote_rec.pop_code_early := p0_a8;
    ddp_quote_rec.consolidated_qte_id := rosetta_g_miss_num_map(p0_a9);
    ddp_quote_rec.khr_id := rosetta_g_miss_num_map(p0_a10);
    ddp_quote_rec.art_id := rosetta_g_miss_num_map(p0_a11);
    ddp_quote_rec.pdt_id := rosetta_g_miss_num_map(p0_a12);
    ddp_quote_rec.early_termination_yn := p0_a13;
    ddp_quote_rec.partial_yn := p0_a14;
    ddp_quote_rec.preproceeds_yn := p0_a15;
    ddp_quote_rec.date_requested := rosetta_g_miss_date_in_map(p0_a16);
    ddp_quote_rec.date_proposal := rosetta_g_miss_date_in_map(p0_a17);
    ddp_quote_rec.date_effective_to := rosetta_g_miss_date_in_map(p0_a18);
    ddp_quote_rec.date_accepted := rosetta_g_miss_date_in_map(p0_a19);
    ddp_quote_rec.summary_format_yn := p0_a20;
    ddp_quote_rec.consolidated_yn := p0_a21;
    ddp_quote_rec.principal_paydown_amount := rosetta_g_miss_num_map(p0_a22);
    ddp_quote_rec.residual_amount := rosetta_g_miss_num_map(p0_a23);
    ddp_quote_rec.yield := rosetta_g_miss_num_map(p0_a24);
    ddp_quote_rec.rent_amount := rosetta_g_miss_num_map(p0_a25);
    ddp_quote_rec.date_restructure_end := rosetta_g_miss_date_in_map(p0_a26);
    ddp_quote_rec.date_restructure_start := rosetta_g_miss_date_in_map(p0_a27);
    ddp_quote_rec.term := rosetta_g_miss_num_map(p0_a28);
    ddp_quote_rec.purchase_percent := rosetta_g_miss_num_map(p0_a29);
    ddp_quote_rec.comments := p0_a30;
    ddp_quote_rec.date_due := rosetta_g_miss_date_in_map(p0_a31);
    ddp_quote_rec.payment_frequency := p0_a32;
    ddp_quote_rec.remaining_payments := rosetta_g_miss_num_map(p0_a33);
    ddp_quote_rec.date_effective_from := rosetta_g_miss_date_in_map(p0_a34);
    ddp_quote_rec.quote_number := rosetta_g_miss_num_map(p0_a35);
    ddp_quote_rec.requested_by := rosetta_g_miss_num_map(p0_a36);
    ddp_quote_rec.approved_yn := p0_a37;
    ddp_quote_rec.accepted_yn := p0_a38;
    ddp_quote_rec.payment_received_yn := p0_a39;
    ddp_quote_rec.date_payment_received := rosetta_g_miss_date_in_map(p0_a40);
    ddp_quote_rec.attribute_category := p0_a41;
    ddp_quote_rec.attribute1 := p0_a42;
    ddp_quote_rec.attribute2 := p0_a43;
    ddp_quote_rec.attribute3 := p0_a44;
    ddp_quote_rec.attribute4 := p0_a45;
    ddp_quote_rec.attribute5 := p0_a46;
    ddp_quote_rec.attribute6 := p0_a47;
    ddp_quote_rec.attribute7 := p0_a48;
    ddp_quote_rec.attribute8 := p0_a49;
    ddp_quote_rec.attribute9 := p0_a50;
    ddp_quote_rec.attribute10 := p0_a51;
    ddp_quote_rec.attribute11 := p0_a52;
    ddp_quote_rec.attribute12 := p0_a53;
    ddp_quote_rec.attribute13 := p0_a54;
    ddp_quote_rec.attribute14 := p0_a55;
    ddp_quote_rec.attribute15 := p0_a56;
    ddp_quote_rec.date_approved := rosetta_g_miss_date_in_map(p0_a57);
    ddp_quote_rec.approved_by := rosetta_g_miss_num_map(p0_a58);
    ddp_quote_rec.org_id := rosetta_g_miss_num_map(p0_a59);
    ddp_quote_rec.request_id := rosetta_g_miss_num_map(p0_a60);
    ddp_quote_rec.program_application_id := rosetta_g_miss_num_map(p0_a61);
    ddp_quote_rec.program_id := rosetta_g_miss_num_map(p0_a62);
    ddp_quote_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a63);
    ddp_quote_rec.created_by := rosetta_g_miss_num_map(p0_a64);
    ddp_quote_rec.creation_date := rosetta_g_miss_date_in_map(p0_a65);
    ddp_quote_rec.last_updated_by := rosetta_g_miss_num_map(p0_a66);
    ddp_quote_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_quote_rec.last_update_login := rosetta_g_miss_num_map(p0_a68);
    ddp_quote_rec.purchase_amount := rosetta_g_miss_num_map(p0_a69);
    ddp_quote_rec.purchase_formula := p0_a70;
    ddp_quote_rec.asset_value := rosetta_g_miss_num_map(p0_a71);
    ddp_quote_rec.residual_value := rosetta_g_miss_num_map(p0_a72);
    ddp_quote_rec.unbilled_receivables := rosetta_g_miss_num_map(p0_a73);
    ddp_quote_rec.gain_loss := rosetta_g_miss_num_map(p0_a74);
    ddp_quote_rec.perdiem_amount := rosetta_g_miss_num_map(p0_a75);
    ddp_quote_rec.currency_code := p0_a76;
    ddp_quote_rec.currency_conversion_code := p0_a77;
    ddp_quote_rec.currency_conversion_type := p0_a78;
    ddp_quote_rec.currency_conversion_rate := rosetta_g_miss_num_map(p0_a79);
    ddp_quote_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p0_a80);
    ddp_quote_rec.legal_entity_id := rosetta_g_miss_num_map(p0_a81);
    ddp_quote_rec.repo_quote_indicator_yn := p0_a82;




    -- here's the delegated call to the old PL/SQL routine
    okl_am_create_quote_pvt.get_net_gain_loss(ddp_quote_rec,
      p_chr_id,
      x_return_status,
      x_net_gain_loss);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end okl_am_create_quote_pvt_w;

/
