--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_QUOTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_QUOTE_PVT_W" as
  /* $Header: OKLETNQB.pls 120.5 2007/11/02 21:06:36 rmunjulu ship $ */
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

  procedure rosetta_table_copy_in_p11(t out nocopy okl_am_termnt_quote_pvt.qte_ln_dtl_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qst_code := a0(indx);
          t(ddindx).qte_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).instance_quantity := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).tql_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).tqd_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).select_yn := a5(indx);
          t(ddindx).ib_line_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).fin_line_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_am_termnt_quote_pvt.qte_ln_dtl_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).qst_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).instance_quantity);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).tql_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).tqd_id);
          a5(indx) := t(ddindx).select_yn;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).ib_line_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).fin_line_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p25(t out nocopy okl_am_termnt_quote_pvt.unit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quote_number := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).qst_code := a1(indx);
          t(ddindx).qtp_code := a2(indx);
          t(ddindx).tql_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).tqd_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).asset_quantity := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).quote_quantity := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ib_line_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).fin_line_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).serial_number := a10(indx);
          t(ddindx).instance_quantity := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).instance_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).asset_number := a13(indx);
          t(ddindx).asset_description := a14(indx);
          t(ddindx).location_description := a15(indx);
          t(ddindx).qte_id := rosetta_g_miss_num_map(a16(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t okl_am_termnt_quote_pvt.unit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_NUMBER_TABLE();
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
        a15.extend(t.count);
        a16.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).quote_number);
          a1(indx) := t(ddindx).qst_code;
          a2(indx) := t(ddindx).qtp_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).tql_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).tqd_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).asset_quantity);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).quote_quantity);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).ib_line_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).fin_line_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a10(indx) := t(ddindx).serial_number;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).instance_quantity);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).instance_number);
          a13(indx) := t(ddindx).asset_number;
          a14(indx) := t(ddindx).asset_description;
          a15(indx) := t(ddindx).location_description;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure terminate_quote(p_api_version  NUMBER
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
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , x_err_msg out nocopy  VARCHAR2
    , p_acceptance_source  VARCHAR2
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
    ddp_term_rec okl_am_termnt_quote_pvt.term_rec_type;
    ddx_term_rec okl_am_termnt_quote_pvt.term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_term_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_term_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_term_rec.sfwt_flag := p5_a2;
    ddp_term_rec.qrs_code := p5_a3;
    ddp_term_rec.qst_code := p5_a4;
    ddp_term_rec.qtp_code := p5_a5;
    ddp_term_rec.trn_code := p5_a6;
    ddp_term_rec.pop_code_end := p5_a7;
    ddp_term_rec.pop_code_early := p5_a8;
    ddp_term_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_term_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_term_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_term_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_term_rec.early_termination_yn := p5_a13;
    ddp_term_rec.partial_yn := p5_a14;
    ddp_term_rec.preproceeds_yn := p5_a15;
    ddp_term_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_term_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_term_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_term_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_term_rec.summary_format_yn := p5_a20;
    ddp_term_rec.consolidated_yn := p5_a21;
    ddp_term_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_term_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_term_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_term_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_term_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_term_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_term_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_term_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_term_rec.comments := p5_a30;
    ddp_term_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_term_rec.payment_frequency := p5_a32;
    ddp_term_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_term_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_term_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_term_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_term_rec.approved_yn := p5_a37;
    ddp_term_rec.accepted_yn := p5_a38;
    ddp_term_rec.payment_received_yn := p5_a39;
    ddp_term_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_term_rec.attribute_category := p5_a41;
    ddp_term_rec.attribute1 := p5_a42;
    ddp_term_rec.attribute2 := p5_a43;
    ddp_term_rec.attribute3 := p5_a44;
    ddp_term_rec.attribute4 := p5_a45;
    ddp_term_rec.attribute5 := p5_a46;
    ddp_term_rec.attribute6 := p5_a47;
    ddp_term_rec.attribute7 := p5_a48;
    ddp_term_rec.attribute8 := p5_a49;
    ddp_term_rec.attribute9 := p5_a50;
    ddp_term_rec.attribute10 := p5_a51;
    ddp_term_rec.attribute11 := p5_a52;
    ddp_term_rec.attribute12 := p5_a53;
    ddp_term_rec.attribute13 := p5_a54;
    ddp_term_rec.attribute14 := p5_a55;
    ddp_term_rec.attribute15 := p5_a56;
    ddp_term_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_term_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_term_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_term_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_term_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_term_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_term_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_term_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_term_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_term_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_term_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_term_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_term_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_term_rec.purchase_formula := p5_a70;
    ddp_term_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_term_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_term_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_term_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_term_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_term_rec.currency_code := p5_a76;
    ddp_term_rec.currency_conversion_code := p5_a77;
    ddp_term_rec.currency_conversion_type := p5_a78;
    ddp_term_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_term_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_term_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_term_rec.repo_quote_indicator_yn := p5_a82;




    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.terminate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_term_rec,
      ddx_term_rec,
      x_err_msg,
      p_acceptance_source);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_term_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_term_rec.object_version_number);
    p6_a2 := ddx_term_rec.sfwt_flag;
    p6_a3 := ddx_term_rec.qrs_code;
    p6_a4 := ddx_term_rec.qst_code;
    p6_a5 := ddx_term_rec.qtp_code;
    p6_a6 := ddx_term_rec.trn_code;
    p6_a7 := ddx_term_rec.pop_code_end;
    p6_a8 := ddx_term_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_term_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_term_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_term_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_term_rec.pdt_id);
    p6_a13 := ddx_term_rec.early_termination_yn;
    p6_a14 := ddx_term_rec.partial_yn;
    p6_a15 := ddx_term_rec.preproceeds_yn;
    p6_a16 := ddx_term_rec.date_requested;
    p6_a17 := ddx_term_rec.date_proposal;
    p6_a18 := ddx_term_rec.date_effective_to;
    p6_a19 := ddx_term_rec.date_accepted;
    p6_a20 := ddx_term_rec.summary_format_yn;
    p6_a21 := ddx_term_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_term_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_term_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_term_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_term_rec.rent_amount);
    p6_a26 := ddx_term_rec.date_restructure_end;
    p6_a27 := ddx_term_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_term_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_term_rec.purchase_percent);
    p6_a30 := ddx_term_rec.comments;
    p6_a31 := ddx_term_rec.date_due;
    p6_a32 := ddx_term_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_term_rec.remaining_payments);
    p6_a34 := ddx_term_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_term_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_term_rec.requested_by);
    p6_a37 := ddx_term_rec.approved_yn;
    p6_a38 := ddx_term_rec.accepted_yn;
    p6_a39 := ddx_term_rec.payment_received_yn;
    p6_a40 := ddx_term_rec.date_payment_received;
    p6_a41 := ddx_term_rec.attribute_category;
    p6_a42 := ddx_term_rec.attribute1;
    p6_a43 := ddx_term_rec.attribute2;
    p6_a44 := ddx_term_rec.attribute3;
    p6_a45 := ddx_term_rec.attribute4;
    p6_a46 := ddx_term_rec.attribute5;
    p6_a47 := ddx_term_rec.attribute6;
    p6_a48 := ddx_term_rec.attribute7;
    p6_a49 := ddx_term_rec.attribute8;
    p6_a50 := ddx_term_rec.attribute9;
    p6_a51 := ddx_term_rec.attribute10;
    p6_a52 := ddx_term_rec.attribute11;
    p6_a53 := ddx_term_rec.attribute12;
    p6_a54 := ddx_term_rec.attribute13;
    p6_a55 := ddx_term_rec.attribute14;
    p6_a56 := ddx_term_rec.attribute15;
    p6_a57 := ddx_term_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_term_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_term_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_term_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_term_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_term_rec.program_id);
    p6_a63 := ddx_term_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_term_rec.created_by);
    p6_a65 := ddx_term_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_term_rec.last_updated_by);
    p6_a67 := ddx_term_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_term_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_term_rec.purchase_amount);
    p6_a70 := ddx_term_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_term_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_term_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_term_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_term_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_term_rec.perdiem_amount);
    p6_a76 := ddx_term_rec.currency_code;
    p6_a77 := ddx_term_rec.currency_conversion_code;
    p6_a78 := ddx_term_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_term_rec.currency_conversion_rate);
    p6_a80 := ddx_term_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_term_rec.legal_entity_id);
    p6_a82 := ddx_term_rec.repo_quote_indicator_yn;


  end;

  procedure terminate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_DATE_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_DATE_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_NUMBER_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_DATE_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , x_err_msg out nocopy  VARCHAR2
    , p_acceptance_source  VARCHAR2
  )

  as
    ddp_term_tbl okl_am_termnt_quote_pvt.term_tbl_type;
    ddx_term_tbl okl_am_termnt_quote_pvt.term_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_term_tbl, p5_a0
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
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.terminate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_term_tbl,
      ddx_term_tbl,
      x_err_msg,
      p_acceptance_source);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qte_pvt_w.rosetta_table_copy_out_p8(ddx_term_tbl, p6_a0
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
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      );


  end;

  procedure submit_for_approval(p_api_version  NUMBER
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
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
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
    ddp_term_rec okl_am_termnt_quote_pvt.term_rec_type;
    ddx_term_rec okl_am_termnt_quote_pvt.term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_term_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_term_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_term_rec.sfwt_flag := p5_a2;
    ddp_term_rec.qrs_code := p5_a3;
    ddp_term_rec.qst_code := p5_a4;
    ddp_term_rec.qtp_code := p5_a5;
    ddp_term_rec.trn_code := p5_a6;
    ddp_term_rec.pop_code_end := p5_a7;
    ddp_term_rec.pop_code_early := p5_a8;
    ddp_term_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_term_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_term_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_term_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_term_rec.early_termination_yn := p5_a13;
    ddp_term_rec.partial_yn := p5_a14;
    ddp_term_rec.preproceeds_yn := p5_a15;
    ddp_term_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_term_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_term_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_term_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_term_rec.summary_format_yn := p5_a20;
    ddp_term_rec.consolidated_yn := p5_a21;
    ddp_term_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_term_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_term_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_term_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_term_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_term_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_term_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_term_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_term_rec.comments := p5_a30;
    ddp_term_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_term_rec.payment_frequency := p5_a32;
    ddp_term_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_term_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_term_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_term_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_term_rec.approved_yn := p5_a37;
    ddp_term_rec.accepted_yn := p5_a38;
    ddp_term_rec.payment_received_yn := p5_a39;
    ddp_term_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_term_rec.attribute_category := p5_a41;
    ddp_term_rec.attribute1 := p5_a42;
    ddp_term_rec.attribute2 := p5_a43;
    ddp_term_rec.attribute3 := p5_a44;
    ddp_term_rec.attribute4 := p5_a45;
    ddp_term_rec.attribute5 := p5_a46;
    ddp_term_rec.attribute6 := p5_a47;
    ddp_term_rec.attribute7 := p5_a48;
    ddp_term_rec.attribute8 := p5_a49;
    ddp_term_rec.attribute9 := p5_a50;
    ddp_term_rec.attribute10 := p5_a51;
    ddp_term_rec.attribute11 := p5_a52;
    ddp_term_rec.attribute12 := p5_a53;
    ddp_term_rec.attribute13 := p5_a54;
    ddp_term_rec.attribute14 := p5_a55;
    ddp_term_rec.attribute15 := p5_a56;
    ddp_term_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_term_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_term_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_term_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_term_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_term_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_term_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_term_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_term_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_term_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_term_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_term_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_term_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_term_rec.purchase_formula := p5_a70;
    ddp_term_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_term_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_term_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_term_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_term_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_term_rec.currency_code := p5_a76;
    ddp_term_rec.currency_conversion_code := p5_a77;
    ddp_term_rec.currency_conversion_type := p5_a78;
    ddp_term_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_term_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_term_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_term_rec.repo_quote_indicator_yn := p5_a82;


    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.submit_for_approval(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_term_rec,
      ddx_term_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_term_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_term_rec.object_version_number);
    p6_a2 := ddx_term_rec.sfwt_flag;
    p6_a3 := ddx_term_rec.qrs_code;
    p6_a4 := ddx_term_rec.qst_code;
    p6_a5 := ddx_term_rec.qtp_code;
    p6_a6 := ddx_term_rec.trn_code;
    p6_a7 := ddx_term_rec.pop_code_end;
    p6_a8 := ddx_term_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_term_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_term_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_term_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_term_rec.pdt_id);
    p6_a13 := ddx_term_rec.early_termination_yn;
    p6_a14 := ddx_term_rec.partial_yn;
    p6_a15 := ddx_term_rec.preproceeds_yn;
    p6_a16 := ddx_term_rec.date_requested;
    p6_a17 := ddx_term_rec.date_proposal;
    p6_a18 := ddx_term_rec.date_effective_to;
    p6_a19 := ddx_term_rec.date_accepted;
    p6_a20 := ddx_term_rec.summary_format_yn;
    p6_a21 := ddx_term_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_term_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_term_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_term_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_term_rec.rent_amount);
    p6_a26 := ddx_term_rec.date_restructure_end;
    p6_a27 := ddx_term_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_term_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_term_rec.purchase_percent);
    p6_a30 := ddx_term_rec.comments;
    p6_a31 := ddx_term_rec.date_due;
    p6_a32 := ddx_term_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_term_rec.remaining_payments);
    p6_a34 := ddx_term_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_term_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_term_rec.requested_by);
    p6_a37 := ddx_term_rec.approved_yn;
    p6_a38 := ddx_term_rec.accepted_yn;
    p6_a39 := ddx_term_rec.payment_received_yn;
    p6_a40 := ddx_term_rec.date_payment_received;
    p6_a41 := ddx_term_rec.attribute_category;
    p6_a42 := ddx_term_rec.attribute1;
    p6_a43 := ddx_term_rec.attribute2;
    p6_a44 := ddx_term_rec.attribute3;
    p6_a45 := ddx_term_rec.attribute4;
    p6_a46 := ddx_term_rec.attribute5;
    p6_a47 := ddx_term_rec.attribute6;
    p6_a48 := ddx_term_rec.attribute7;
    p6_a49 := ddx_term_rec.attribute8;
    p6_a50 := ddx_term_rec.attribute9;
    p6_a51 := ddx_term_rec.attribute10;
    p6_a52 := ddx_term_rec.attribute11;
    p6_a53 := ddx_term_rec.attribute12;
    p6_a54 := ddx_term_rec.attribute13;
    p6_a55 := ddx_term_rec.attribute14;
    p6_a56 := ddx_term_rec.attribute15;
    p6_a57 := ddx_term_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_term_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_term_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_term_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_term_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_term_rec.program_id);
    p6_a63 := ddx_term_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_term_rec.created_by);
    p6_a65 := ddx_term_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_term_rec.last_updated_by);
    p6_a67 := ddx_term_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_term_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_term_rec.purchase_amount);
    p6_a70 := ddx_term_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_term_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_term_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_term_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_term_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_term_rec.perdiem_amount);
    p6_a76 := ddx_term_rec.currency_code;
    p6_a77 := ddx_term_rec.currency_conversion_code;
    p6_a78 := ddx_term_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_term_rec.currency_conversion_rate);
    p6_a80 := ddx_term_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_term_rec.legal_entity_id);
    p6_a82 := ddx_term_rec.repo_quote_indicator_yn;
  end;

  procedure quote_line_dtls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_qld_tbl okl_am_termnt_quote_pvt.qte_ln_dtl_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_termnt_quote_pvt_w.rosetta_table_copy_in_p11(ddp_qld_tbl, p5_a0
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
    okl_am_termnt_quote_pvt.quote_line_dtls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qld_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    okl_am_termnt_quote_pvt_w.rosetta_table_copy_out_p11(ddp_qld_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );
  end;

  procedure create_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
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
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_am_termnt_quote_pvt.tqlv_rec_type;
    ddx_tqlv_rec okl_am_termnt_quote_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.create_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec,
      ddx_tqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tqlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tqlv_rec.object_version_number);
    p6_a2 := ddx_tqlv_rec.sfwt_flag;
    p6_a3 := ddx_tqlv_rec.qlt_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tqlv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tqlv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tqlv_rec.qte_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tqlv_rec.line_number);
    p6_a8 := ddx_tqlv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_tqlv_rec.amount);
    p6_a10 := ddx_tqlv_rec.modified_yn;
    p6_a11 := ddx_tqlv_rec.taxed_yn;
    p6_a12 := ddx_tqlv_rec.defaulted_yn;
    p6_a13 := ddx_tqlv_rec.attribute_category;
    p6_a14 := ddx_tqlv_rec.attribute1;
    p6_a15 := ddx_tqlv_rec.attribute2;
    p6_a16 := ddx_tqlv_rec.attribute3;
    p6_a17 := ddx_tqlv_rec.attribute4;
    p6_a18 := ddx_tqlv_rec.attribute5;
    p6_a19 := ddx_tqlv_rec.attribute6;
    p6_a20 := ddx_tqlv_rec.attribute7;
    p6_a21 := ddx_tqlv_rec.attribute8;
    p6_a22 := ddx_tqlv_rec.attribute9;
    p6_a23 := ddx_tqlv_rec.attribute10;
    p6_a24 := ddx_tqlv_rec.attribute11;
    p6_a25 := ddx_tqlv_rec.attribute12;
    p6_a26 := ddx_tqlv_rec.attribute13;
    p6_a27 := ddx_tqlv_rec.attribute14;
    p6_a28 := ddx_tqlv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_tqlv_rec.org_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tqlv_rec.request_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_application_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_id);
    p6_a33 := ddx_tqlv_rec.program_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tqlv_rec.created_by);
    p6_a35 := ddx_tqlv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_updated_by);
    p6_a37 := ddx_tqlv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_update_login);
    p6_a39 := ddx_tqlv_rec.start_date;
    p6_a40 := ddx_tqlv_rec.period;
    p6_a41 := rosetta_g_miss_num_map(ddx_tqlv_rec.number_of_periods);
    p6_a42 := ddx_tqlv_rec.lock_level_step;
    p6_a43 := ddx_tqlv_rec.advance_or_arrears;
    p6_a44 := ddx_tqlv_rec.yield_name;
    p6_a45 := rosetta_g_miss_num_map(ddx_tqlv_rec.yield_value);
    p6_a46 := rosetta_g_miss_num_map(ddx_tqlv_rec.implicit_interest_rate);
    p6_a47 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_value);
    p6_a48 := rosetta_g_miss_num_map(ddx_tqlv_rec.residual_value);
    p6_a49 := rosetta_g_miss_num_map(ddx_tqlv_rec.unbilled_receivables);
    p6_a50 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_quantity);
    p6_a51 := rosetta_g_miss_num_map(ddx_tqlv_rec.quote_quantity);
    p6_a52 := rosetta_g_miss_num_map(ddx_tqlv_rec.split_kle_id);
    p6_a53 := ddx_tqlv_rec.split_kle_name;
    p6_a54 := ddx_tqlv_rec.currency_code;
    p6_a55 := ddx_tqlv_rec.currency_conversion_code;
    p6_a56 := ddx_tqlv_rec.currency_conversion_type;
    p6_a57 := rosetta_g_miss_num_map(ddx_tqlv_rec.currency_conversion_rate);
    p6_a58 := ddx_tqlv_rec.currency_conversion_date;
    p6_a59 := ddx_tqlv_rec.due_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_tqlv_rec.try_id);
  end;

  procedure create_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_am_termnt_quote_pvt.tqlv_tbl_type;
    ddx_tqlv_tbl okl_am_termnt_quote_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.create_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p6_a0
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
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      );
  end;

  procedure update_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
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
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_am_termnt_quote_pvt.tqlv_rec_type;
    ddx_tqlv_rec okl_am_termnt_quote_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.update_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec,
      ddx_tqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tqlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tqlv_rec.object_version_number);
    p6_a2 := ddx_tqlv_rec.sfwt_flag;
    p6_a3 := ddx_tqlv_rec.qlt_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tqlv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tqlv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tqlv_rec.qte_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tqlv_rec.line_number);
    p6_a8 := ddx_tqlv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_tqlv_rec.amount);
    p6_a10 := ddx_tqlv_rec.modified_yn;
    p6_a11 := ddx_tqlv_rec.taxed_yn;
    p6_a12 := ddx_tqlv_rec.defaulted_yn;
    p6_a13 := ddx_tqlv_rec.attribute_category;
    p6_a14 := ddx_tqlv_rec.attribute1;
    p6_a15 := ddx_tqlv_rec.attribute2;
    p6_a16 := ddx_tqlv_rec.attribute3;
    p6_a17 := ddx_tqlv_rec.attribute4;
    p6_a18 := ddx_tqlv_rec.attribute5;
    p6_a19 := ddx_tqlv_rec.attribute6;
    p6_a20 := ddx_tqlv_rec.attribute7;
    p6_a21 := ddx_tqlv_rec.attribute8;
    p6_a22 := ddx_tqlv_rec.attribute9;
    p6_a23 := ddx_tqlv_rec.attribute10;
    p6_a24 := ddx_tqlv_rec.attribute11;
    p6_a25 := ddx_tqlv_rec.attribute12;
    p6_a26 := ddx_tqlv_rec.attribute13;
    p6_a27 := ddx_tqlv_rec.attribute14;
    p6_a28 := ddx_tqlv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_tqlv_rec.org_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tqlv_rec.request_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_application_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_id);
    p6_a33 := ddx_tqlv_rec.program_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tqlv_rec.created_by);
    p6_a35 := ddx_tqlv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_updated_by);
    p6_a37 := ddx_tqlv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_update_login);
    p6_a39 := ddx_tqlv_rec.start_date;
    p6_a40 := ddx_tqlv_rec.period;
    p6_a41 := rosetta_g_miss_num_map(ddx_tqlv_rec.number_of_periods);
    p6_a42 := ddx_tqlv_rec.lock_level_step;
    p6_a43 := ddx_tqlv_rec.advance_or_arrears;
    p6_a44 := ddx_tqlv_rec.yield_name;
    p6_a45 := rosetta_g_miss_num_map(ddx_tqlv_rec.yield_value);
    p6_a46 := rosetta_g_miss_num_map(ddx_tqlv_rec.implicit_interest_rate);
    p6_a47 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_value);
    p6_a48 := rosetta_g_miss_num_map(ddx_tqlv_rec.residual_value);
    p6_a49 := rosetta_g_miss_num_map(ddx_tqlv_rec.unbilled_receivables);
    p6_a50 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_quantity);
    p6_a51 := rosetta_g_miss_num_map(ddx_tqlv_rec.quote_quantity);
    p6_a52 := rosetta_g_miss_num_map(ddx_tqlv_rec.split_kle_id);
    p6_a53 := ddx_tqlv_rec.split_kle_name;
    p6_a54 := ddx_tqlv_rec.currency_code;
    p6_a55 := ddx_tqlv_rec.currency_conversion_code;
    p6_a56 := ddx_tqlv_rec.currency_conversion_type;
    p6_a57 := rosetta_g_miss_num_map(ddx_tqlv_rec.currency_conversion_rate);
    p6_a58 := ddx_tqlv_rec.currency_conversion_date;
    p6_a59 := ddx_tqlv_rec.due_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_tqlv_rec.try_id);
  end;

  procedure update_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_am_termnt_quote_pvt.tqlv_tbl_type;
    ddx_tqlv_tbl okl_am_termnt_quote_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.update_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p6_a0
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
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      );
  end;

  procedure get_quote_units(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_tql_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a16 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_unit_tbl okl_am_termnt_quote_pvt.unit_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.get_quote_units(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tql_id,
      ddx_unit_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_termnt_quote_pvt_w.rosetta_table_copy_out_p25(ddx_unit_tbl, p6_a0
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
      );
  end;

  procedure delete_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_am_termnt_quote_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.delete_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_quote_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_am_termnt_quote_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.delete_quote_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure check_asset_validity_in_fa(p_kle_id  NUMBER
    , p_trn_date  date
    , p_check_fa_year  VARCHAR2
    , p_check_fa_trn  VARCHAR2
    , p_contract_number  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_trn_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_trn_date := rosetta_g_miss_date_in_map(p_trn_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_am_termnt_quote_pvt.check_asset_validity_in_fa(p_kle_id,
      ddp_trn_date,
      p_check_fa_year,
      p_check_fa_trn,
      p_contract_number,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_am_termnt_quote_pvt_w;

/
