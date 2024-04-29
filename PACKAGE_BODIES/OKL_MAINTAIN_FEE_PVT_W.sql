--------------------------------------------------------
--  DDL for Package Body OKL_MAINTAIN_FEE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MAINTAIN_FEE_PVT_W" as
  /* $Header: OKLUFEEB.pls 120.13 2006/03/02 23:47:09 smereddy noship $ */
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

  procedure rosetta_table_copy_in_p18(t out nocopy okl_maintain_fee_pvt.fee_types_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).fee_type := a2(indx);
          t(ddindx).item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).item_name := a4(indx);
          t(ddindx).item_id1 := a5(indx);
          t(ddindx).item_id2 := a6(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).party_name := a8(indx);
          t(ddindx).party_id1 := a9(indx);
          t(ddindx).party_id2 := a10(indx);
          t(ddindx).effective_from := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).effective_to := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).initial_direct_cost := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).roll_qt := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).funding_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).fee_purpose_code := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).validate_dff_yn := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t okl_maintain_fee_pvt.fee_types_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_100();
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
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a2(indx) := t(ddindx).fee_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a4(indx) := t(ddindx).item_name;
          a5(indx) := t(ddindx).item_id1;
          a6(indx) := t(ddindx).item_id2;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a8(indx) := t(ddindx).party_name;
          a9(indx) := t(ddindx).party_id1;
          a10(indx) := t(ddindx).party_id2;
          a11(indx) := t(ddindx).effective_from;
          a12(indx) := t(ddindx).effective_to;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).initial_direct_cost);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).roll_qt);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a17(indx) := t(ddindx).funding_date;
          a18(indx) := t(ddindx).fee_purpose_code;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := t(ddindx).validate_dff_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p20(t out nocopy okl_maintain_fee_pvt.passthru_dtl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_DATE_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).b_dnz_chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).b_cle_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).b_ppl_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).b_passthru_term := a3(indx);
          t(ddindx).b_passthru_stream_type_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).b_passthru_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).b_payout_basis := a6(indx);
          t(ddindx).b_payout_basis_formula := a7(indx);
          t(ddindx).b_effective_from := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).b_effective_to := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).b_payment_dtls_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).b_cpl_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).b_vendor_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).b_pay_site_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).b_payment_term_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).b_payment_method_code := a15(indx);
          t(ddindx).b_pay_group_code := a16(indx);
          t(ddindx).b_payment_hdr_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).b_payment_basis := a18(indx);
          t(ddindx).b_payment_start_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).b_payment_frequency := a20(indx);
          t(ddindx).b_remit_days := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).b_disbursement_basis := a22(indx);
          t(ddindx).b_disbursement_fixed_amount := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).b_disbursement_percent := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).b_processing_fee_basis := a25(indx);
          t(ddindx).b_processing_fee_fixed_amount := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).b_processing_fee_percent := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).e_dnz_chr_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).e_cle_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).e_ppl_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).e_passthru_term := a31(indx);
          t(ddindx).e_passthru_stream_type_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).e_passthru_start_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).e_payout_basis := a34(indx);
          t(ddindx).e_payout_basis_formula := a35(indx);
          t(ddindx).e_effective_from := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).e_effective_to := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).e_payment_dtls_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).e_cpl_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).e_vendor_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).e_pay_site_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).e_payment_term_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).e_payment_method_code := a43(indx);
          t(ddindx).e_pay_group_code := a44(indx);
          t(ddindx).e_payment_hdr_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).e_payment_basis := a46(indx);
          t(ddindx).e_payment_start_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).e_payment_frequency := a48(indx);
          t(ddindx).e_remit_days := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).e_disbursement_basis := a50(indx);
          t(ddindx).e_disbursement_fixed_amount := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).e_disbursement_percent := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).e_processing_fee_basis := a53(indx);
          t(ddindx).e_processing_fee_fixed_amount := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).e_processing_fee_percent := rosetta_g_miss_num_map(a55(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t okl_maintain_fee_pvt.passthru_dtl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
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
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).b_dnz_chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).b_cle_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).b_ppl_id);
          a3(indx) := t(ddindx).b_passthru_term;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).b_passthru_stream_type_id);
          a5(indx) := t(ddindx).b_passthru_start_date;
          a6(indx) := t(ddindx).b_payout_basis;
          a7(indx) := t(ddindx).b_payout_basis_formula;
          a8(indx) := t(ddindx).b_effective_from;
          a9(indx) := t(ddindx).b_effective_to;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).b_payment_dtls_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).b_cpl_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).b_vendor_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).b_pay_site_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).b_payment_term_id);
          a15(indx) := t(ddindx).b_payment_method_code;
          a16(indx) := t(ddindx).b_pay_group_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).b_payment_hdr_id);
          a18(indx) := t(ddindx).b_payment_basis;
          a19(indx) := t(ddindx).b_payment_start_date;
          a20(indx) := t(ddindx).b_payment_frequency;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).b_remit_days);
          a22(indx) := t(ddindx).b_disbursement_basis;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).b_disbursement_fixed_amount);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).b_disbursement_percent);
          a25(indx) := t(ddindx).b_processing_fee_basis;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).b_processing_fee_fixed_amount);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).b_processing_fee_percent);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).e_dnz_chr_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).e_cle_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).e_ppl_id);
          a31(indx) := t(ddindx).e_passthru_term;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).e_passthru_stream_type_id);
          a33(indx) := t(ddindx).e_passthru_start_date;
          a34(indx) := t(ddindx).e_payout_basis;
          a35(indx) := t(ddindx).e_payout_basis_formula;
          a36(indx) := t(ddindx).e_effective_from;
          a37(indx) := t(ddindx).e_effective_to;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).e_payment_dtls_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).e_cpl_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).e_vendor_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).e_pay_site_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).e_payment_term_id);
          a43(indx) := t(ddindx).e_payment_method_code;
          a44(indx) := t(ddindx).e_pay_group_code;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).e_payment_hdr_id);
          a46(indx) := t(ddindx).e_payment_basis;
          a47(indx) := t(ddindx).e_payment_start_date;
          a48(indx) := t(ddindx).e_payment_frequency;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).e_remit_days);
          a50(indx) := t(ddindx).e_disbursement_basis;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).e_disbursement_fixed_amount);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).e_disbursement_percent);
          a53(indx) := t(ddindx).e_processing_fee_basis;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).e_processing_fee_fixed_amount);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).e_processing_fee_percent);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p22(t out nocopy okl_maintain_fee_pvt.passthru_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).base_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).evergreen_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).passthru_start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).payout_basis := a5(indx);
          t(ddindx).evergreen_eligible_yn := a6(indx);
          t(ddindx).evergreen_payout_basis := a7(indx);
          t(ddindx).evergreen_payout_basis_formula := a8(indx);
          t(ddindx).passthru_term := a9(indx);
          t(ddindx).base_stream_type_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).evg_stream_type_id := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t okl_maintain_fee_pvt.passthru_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).base_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).evergreen_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a4(indx) := t(ddindx).passthru_start_date;
          a5(indx) := t(ddindx).payout_basis;
          a6(indx) := t(ddindx).evergreen_eligible_yn;
          a7(indx) := t(ddindx).evergreen_payout_basis;
          a8(indx) := t(ddindx).evergreen_payout_basis_formula;
          a9(indx) := t(ddindx).passthru_term;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).base_stream_type_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).evg_stream_type_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p24(t out nocopy okl_maintain_fee_pvt.party_tab_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).attribute_category := a1(indx);
          t(ddindx).attribute1 := a2(indx);
          t(ddindx).attribute2 := a3(indx);
          t(ddindx).attribute3 := a4(indx);
          t(ddindx).attribute4 := a5(indx);
          t(ddindx).attribute5 := a6(indx);
          t(ddindx).attribute6 := a7(indx);
          t(ddindx).attribute7 := a8(indx);
          t(ddindx).attribute8 := a9(indx);
          t(ddindx).attribute9 := a10(indx);
          t(ddindx).attribute10 := a11(indx);
          t(ddindx).attribute11 := a12(indx);
          t(ddindx).attribute12 := a13(indx);
          t(ddindx).attribute13 := a14(indx);
          t(ddindx).attribute14 := a15(indx);
          t(ddindx).attribute15 := a16(indx);
          t(ddindx).object1_id1 := a17(indx);
          t(ddindx).object1_id2 := a18(indx);
          t(ddindx).jtot_object1_code := a19(indx);
          t(ddindx).rle_code := a20(indx);
          t(ddindx).chr_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a23(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t okl_maintain_fee_pvt.party_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
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
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).attribute_category;
          a2(indx) := t(ddindx).attribute1;
          a3(indx) := t(ddindx).attribute2;
          a4(indx) := t(ddindx).attribute3;
          a5(indx) := t(ddindx).attribute4;
          a6(indx) := t(ddindx).attribute5;
          a7(indx) := t(ddindx).attribute6;
          a8(indx) := t(ddindx).attribute7;
          a9(indx) := t(ddindx).attribute8;
          a10(indx) := t(ddindx).attribute9;
          a11(indx) := t(ddindx).attribute10;
          a12(indx) := t(ddindx).attribute11;
          a13(indx) := t(ddindx).attribute12;
          a14(indx) := t(ddindx).attribute13;
          a15(indx) := t(ddindx).attribute14;
          a16(indx) := t(ddindx).attribute15;
          a17(indx) := t(ddindx).object1_id1;
          a18(indx) := t(ddindx).object1_id2;
          a19(indx) := t(ddindx).jtot_object1_code;
          a20(indx) := t(ddindx).rle_code;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure create_payment_dtls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_passthru_dtl_rec okl_maintain_fee_pvt.passthru_dtl_rec_type;
    ddx_passthru_dtl_rec okl_maintain_fee_pvt.passthru_dtl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_passthru_dtl_rec.b_dnz_chr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_passthru_dtl_rec.b_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_passthru_dtl_rec.b_ppl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_passthru_dtl_rec.b_passthru_term := p5_a3;
    ddp_passthru_dtl_rec.b_passthru_stream_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_passthru_dtl_rec.b_passthru_start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_passthru_dtl_rec.b_payout_basis := p5_a6;
    ddp_passthru_dtl_rec.b_payout_basis_formula := p5_a7;
    ddp_passthru_dtl_rec.b_effective_from := rosetta_g_miss_date_in_map(p5_a8);
    ddp_passthru_dtl_rec.b_effective_to := rosetta_g_miss_date_in_map(p5_a9);
    ddp_passthru_dtl_rec.b_payment_dtls_id := rosetta_g_miss_num_map(p5_a10);
    ddp_passthru_dtl_rec.b_cpl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_passthru_dtl_rec.b_vendor_id := rosetta_g_miss_num_map(p5_a12);
    ddp_passthru_dtl_rec.b_pay_site_id := rosetta_g_miss_num_map(p5_a13);
    ddp_passthru_dtl_rec.b_payment_term_id := rosetta_g_miss_num_map(p5_a14);
    ddp_passthru_dtl_rec.b_payment_method_code := p5_a15;
    ddp_passthru_dtl_rec.b_pay_group_code := p5_a16;
    ddp_passthru_dtl_rec.b_payment_hdr_id := rosetta_g_miss_num_map(p5_a17);
    ddp_passthru_dtl_rec.b_payment_basis := p5_a18;
    ddp_passthru_dtl_rec.b_payment_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_passthru_dtl_rec.b_payment_frequency := p5_a20;
    ddp_passthru_dtl_rec.b_remit_days := rosetta_g_miss_num_map(p5_a21);
    ddp_passthru_dtl_rec.b_disbursement_basis := p5_a22;
    ddp_passthru_dtl_rec.b_disbursement_fixed_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_passthru_dtl_rec.b_disbursement_percent := rosetta_g_miss_num_map(p5_a24);
    ddp_passthru_dtl_rec.b_processing_fee_basis := p5_a25;
    ddp_passthru_dtl_rec.b_processing_fee_fixed_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_passthru_dtl_rec.b_processing_fee_percent := rosetta_g_miss_num_map(p5_a27);
    ddp_passthru_dtl_rec.e_dnz_chr_id := rosetta_g_miss_num_map(p5_a28);
    ddp_passthru_dtl_rec.e_cle_id := rosetta_g_miss_num_map(p5_a29);
    ddp_passthru_dtl_rec.e_ppl_id := rosetta_g_miss_num_map(p5_a30);
    ddp_passthru_dtl_rec.e_passthru_term := p5_a31;
    ddp_passthru_dtl_rec.e_passthru_stream_type_id := rosetta_g_miss_num_map(p5_a32);
    ddp_passthru_dtl_rec.e_passthru_start_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_passthru_dtl_rec.e_payout_basis := p5_a34;
    ddp_passthru_dtl_rec.e_payout_basis_formula := p5_a35;
    ddp_passthru_dtl_rec.e_effective_from := rosetta_g_miss_date_in_map(p5_a36);
    ddp_passthru_dtl_rec.e_effective_to := rosetta_g_miss_date_in_map(p5_a37);
    ddp_passthru_dtl_rec.e_payment_dtls_id := rosetta_g_miss_num_map(p5_a38);
    ddp_passthru_dtl_rec.e_cpl_id := rosetta_g_miss_num_map(p5_a39);
    ddp_passthru_dtl_rec.e_vendor_id := rosetta_g_miss_num_map(p5_a40);
    ddp_passthru_dtl_rec.e_pay_site_id := rosetta_g_miss_num_map(p5_a41);
    ddp_passthru_dtl_rec.e_payment_term_id := rosetta_g_miss_num_map(p5_a42);
    ddp_passthru_dtl_rec.e_payment_method_code := p5_a43;
    ddp_passthru_dtl_rec.e_pay_group_code := p5_a44;
    ddp_passthru_dtl_rec.e_payment_hdr_id := rosetta_g_miss_num_map(p5_a45);
    ddp_passthru_dtl_rec.e_payment_basis := p5_a46;
    ddp_passthru_dtl_rec.e_payment_start_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_passthru_dtl_rec.e_payment_frequency := p5_a48;
    ddp_passthru_dtl_rec.e_remit_days := rosetta_g_miss_num_map(p5_a49);
    ddp_passthru_dtl_rec.e_disbursement_basis := p5_a50;
    ddp_passthru_dtl_rec.e_disbursement_fixed_amount := rosetta_g_miss_num_map(p5_a51);
    ddp_passthru_dtl_rec.e_disbursement_percent := rosetta_g_miss_num_map(p5_a52);
    ddp_passthru_dtl_rec.e_processing_fee_basis := p5_a53;
    ddp_passthru_dtl_rec.e_processing_fee_fixed_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_passthru_dtl_rec.e_processing_fee_percent := rosetta_g_miss_num_map(p5_a55);


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.create_payment_dtls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_passthru_dtl_rec,
      ddx_passthru_dtl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_dnz_chr_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_cle_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_ppl_id);
    p6_a3 := ddx_passthru_dtl_rec.b_passthru_term;
    p6_a4 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_passthru_stream_type_id);
    p6_a5 := ddx_passthru_dtl_rec.b_passthru_start_date;
    p6_a6 := ddx_passthru_dtl_rec.b_payout_basis;
    p6_a7 := ddx_passthru_dtl_rec.b_payout_basis_formula;
    p6_a8 := ddx_passthru_dtl_rec.b_effective_from;
    p6_a9 := ddx_passthru_dtl_rec.b_effective_to;
    p6_a10 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_payment_dtls_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_cpl_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_vendor_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_pay_site_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_payment_term_id);
    p6_a15 := ddx_passthru_dtl_rec.b_payment_method_code;
    p6_a16 := ddx_passthru_dtl_rec.b_pay_group_code;
    p6_a17 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_payment_hdr_id);
    p6_a18 := ddx_passthru_dtl_rec.b_payment_basis;
    p6_a19 := ddx_passthru_dtl_rec.b_payment_start_date;
    p6_a20 := ddx_passthru_dtl_rec.b_payment_frequency;
    p6_a21 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_remit_days);
    p6_a22 := ddx_passthru_dtl_rec.b_disbursement_basis;
    p6_a23 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_disbursement_fixed_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_disbursement_percent);
    p6_a25 := ddx_passthru_dtl_rec.b_processing_fee_basis;
    p6_a26 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_processing_fee_fixed_amount);
    p6_a27 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.b_processing_fee_percent);
    p6_a28 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_dnz_chr_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_cle_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_ppl_id);
    p6_a31 := ddx_passthru_dtl_rec.e_passthru_term;
    p6_a32 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_passthru_stream_type_id);
    p6_a33 := ddx_passthru_dtl_rec.e_passthru_start_date;
    p6_a34 := ddx_passthru_dtl_rec.e_payout_basis;
    p6_a35 := ddx_passthru_dtl_rec.e_payout_basis_formula;
    p6_a36 := ddx_passthru_dtl_rec.e_effective_from;
    p6_a37 := ddx_passthru_dtl_rec.e_effective_to;
    p6_a38 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_payment_dtls_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_cpl_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_vendor_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_pay_site_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_payment_term_id);
    p6_a43 := ddx_passthru_dtl_rec.e_payment_method_code;
    p6_a44 := ddx_passthru_dtl_rec.e_pay_group_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_payment_hdr_id);
    p6_a46 := ddx_passthru_dtl_rec.e_payment_basis;
    p6_a47 := ddx_passthru_dtl_rec.e_payment_start_date;
    p6_a48 := ddx_passthru_dtl_rec.e_payment_frequency;
    p6_a49 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_remit_days);
    p6_a50 := ddx_passthru_dtl_rec.e_disbursement_basis;
    p6_a51 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_disbursement_fixed_amount);
    p6_a52 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_disbursement_percent);
    p6_a53 := ddx_passthru_dtl_rec.e_processing_fee_basis;
    p6_a54 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_processing_fee_fixed_amount);
    p6_a55 := rosetta_g_miss_num_map(ddx_passthru_dtl_rec.e_processing_fee_percent);
  end;

  procedure create_payment_hdrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_passthru_rec okl_maintain_fee_pvt.passthru_rec_type;
    ddx_passthru_rec okl_maintain_fee_pvt.passthru_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_passthru_rec.base_id := rosetta_g_miss_num_map(p5_a0);
    ddp_passthru_rec.evergreen_id := rosetta_g_miss_num_map(p5_a1);
    ddp_passthru_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_passthru_rec.cle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_passthru_rec.passthru_start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_passthru_rec.payout_basis := p5_a5;
    ddp_passthru_rec.evergreen_eligible_yn := p5_a6;
    ddp_passthru_rec.evergreen_payout_basis := p5_a7;
    ddp_passthru_rec.evergreen_payout_basis_formula := p5_a8;
    ddp_passthru_rec.passthru_term := p5_a9;
    ddp_passthru_rec.base_stream_type_id := rosetta_g_miss_num_map(p5_a10);
    ddp_passthru_rec.evg_stream_type_id := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.create_payment_hdrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_passthru_rec,
      ddx_passthru_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_passthru_rec.base_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_passthru_rec.evergreen_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_passthru_rec.dnz_chr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_passthru_rec.cle_id);
    p6_a4 := ddx_passthru_rec.passthru_start_date;
    p6_a5 := ddx_passthru_rec.payout_basis;
    p6_a6 := ddx_passthru_rec.evergreen_eligible_yn;
    p6_a7 := ddx_passthru_rec.evergreen_payout_basis;
    p6_a8 := ddx_passthru_rec.evergreen_payout_basis_formula;
    p6_a9 := ddx_passthru_rec.passthru_term;
    p6_a10 := rosetta_g_miss_num_map(ddx_passthru_rec.base_stream_type_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_passthru_rec.evg_stream_type_id);
  end;

  procedure delete_payment_hdrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_passthru_rec okl_maintain_fee_pvt.passthru_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_passthru_rec.base_id := rosetta_g_miss_num_map(p5_a0);
    ddp_passthru_rec.evergreen_id := rosetta_g_miss_num_map(p5_a1);
    ddp_passthru_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_passthru_rec.cle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_passthru_rec.passthru_start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_passthru_rec.payout_basis := p5_a5;
    ddp_passthru_rec.evergreen_eligible_yn := p5_a6;
    ddp_passthru_rec.evergreen_payout_basis := p5_a7;
    ddp_passthru_rec.evergreen_payout_basis_formula := p5_a8;
    ddp_passthru_rec.passthru_term := p5_a9;
    ddp_passthru_rec.base_stream_type_id := rosetta_g_miss_num_map(p5_a10);
    ddp_passthru_rec.evg_stream_type_id := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.delete_payment_hdrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_passthru_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_fee_type(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
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
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddx_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_types_rec.line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_fee_types_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_fee_types_rec.fee_type := p5_a2;
    ddp_fee_types_rec.item_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fee_types_rec.item_name := p5_a4;
    ddp_fee_types_rec.item_id1 := p5_a5;
    ddp_fee_types_rec.item_id2 := p5_a6;
    ddp_fee_types_rec.party_id := rosetta_g_miss_num_map(p5_a7);
    ddp_fee_types_rec.party_name := p5_a8;
    ddp_fee_types_rec.party_id1 := p5_a9;
    ddp_fee_types_rec.party_id2 := p5_a10;
    ddp_fee_types_rec.effective_from := rosetta_g_miss_date_in_map(p5_a11);
    ddp_fee_types_rec.effective_to := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fee_types_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_fee_types_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a14);
    ddp_fee_types_rec.roll_qt := rosetta_g_miss_num_map(p5_a15);
    ddp_fee_types_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_fee_types_rec.funding_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_fee_types_rec.fee_purpose_code := p5_a18;
    ddp_fee_types_rec.attribute_category := p5_a19;
    ddp_fee_types_rec.attribute1 := p5_a20;
    ddp_fee_types_rec.attribute2 := p5_a21;
    ddp_fee_types_rec.attribute3 := p5_a22;
    ddp_fee_types_rec.attribute4 := p5_a23;
    ddp_fee_types_rec.attribute5 := p5_a24;
    ddp_fee_types_rec.attribute6 := p5_a25;
    ddp_fee_types_rec.attribute7 := p5_a26;
    ddp_fee_types_rec.attribute8 := p5_a27;
    ddp_fee_types_rec.attribute9 := p5_a28;
    ddp_fee_types_rec.attribute10 := p5_a29;
    ddp_fee_types_rec.attribute11 := p5_a30;
    ddp_fee_types_rec.attribute12 := p5_a31;
    ddp_fee_types_rec.attribute13 := p5_a32;
    ddp_fee_types_rec.attribute14 := p5_a33;
    ddp_fee_types_rec.attribute15 := p5_a34;
    ddp_fee_types_rec.validate_dff_yn := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.create_fee_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_types_rec,
      ddx_fee_types_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fee_types_rec.line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fee_types_rec.dnz_chr_id);
    p6_a2 := ddx_fee_types_rec.fee_type;
    p6_a3 := rosetta_g_miss_num_map(ddx_fee_types_rec.item_id);
    p6_a4 := ddx_fee_types_rec.item_name;
    p6_a5 := ddx_fee_types_rec.item_id1;
    p6_a6 := ddx_fee_types_rec.item_id2;
    p6_a7 := rosetta_g_miss_num_map(ddx_fee_types_rec.party_id);
    p6_a8 := ddx_fee_types_rec.party_name;
    p6_a9 := ddx_fee_types_rec.party_id1;
    p6_a10 := ddx_fee_types_rec.party_id2;
    p6_a11 := ddx_fee_types_rec.effective_from;
    p6_a12 := ddx_fee_types_rec.effective_to;
    p6_a13 := rosetta_g_miss_num_map(ddx_fee_types_rec.amount);
    p6_a14 := rosetta_g_miss_num_map(ddx_fee_types_rec.initial_direct_cost);
    p6_a15 := rosetta_g_miss_num_map(ddx_fee_types_rec.roll_qt);
    p6_a16 := rosetta_g_miss_num_map(ddx_fee_types_rec.qte_id);
    p6_a17 := ddx_fee_types_rec.funding_date;
    p6_a18 := ddx_fee_types_rec.fee_purpose_code;
    p6_a19 := ddx_fee_types_rec.attribute_category;
    p6_a20 := ddx_fee_types_rec.attribute1;
    p6_a21 := ddx_fee_types_rec.attribute2;
    p6_a22 := ddx_fee_types_rec.attribute3;
    p6_a23 := ddx_fee_types_rec.attribute4;
    p6_a24 := ddx_fee_types_rec.attribute5;
    p6_a25 := ddx_fee_types_rec.attribute6;
    p6_a26 := ddx_fee_types_rec.attribute7;
    p6_a27 := ddx_fee_types_rec.attribute8;
    p6_a28 := ddx_fee_types_rec.attribute9;
    p6_a29 := ddx_fee_types_rec.attribute10;
    p6_a30 := ddx_fee_types_rec.attribute11;
    p6_a31 := ddx_fee_types_rec.attribute12;
    p6_a32 := ddx_fee_types_rec.attribute13;
    p6_a33 := ddx_fee_types_rec.attribute14;
    p6_a34 := ddx_fee_types_rec.attribute15;
    p6_a35 := ddx_fee_types_rec.validate_dff_yn;
  end;

  procedure validate_fee_type(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
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
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddx_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_types_rec.line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_fee_types_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_fee_types_rec.fee_type := p5_a2;
    ddp_fee_types_rec.item_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fee_types_rec.item_name := p5_a4;
    ddp_fee_types_rec.item_id1 := p5_a5;
    ddp_fee_types_rec.item_id2 := p5_a6;
    ddp_fee_types_rec.party_id := rosetta_g_miss_num_map(p5_a7);
    ddp_fee_types_rec.party_name := p5_a8;
    ddp_fee_types_rec.party_id1 := p5_a9;
    ddp_fee_types_rec.party_id2 := p5_a10;
    ddp_fee_types_rec.effective_from := rosetta_g_miss_date_in_map(p5_a11);
    ddp_fee_types_rec.effective_to := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fee_types_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_fee_types_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a14);
    ddp_fee_types_rec.roll_qt := rosetta_g_miss_num_map(p5_a15);
    ddp_fee_types_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_fee_types_rec.funding_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_fee_types_rec.fee_purpose_code := p5_a18;
    ddp_fee_types_rec.attribute_category := p5_a19;
    ddp_fee_types_rec.attribute1 := p5_a20;
    ddp_fee_types_rec.attribute2 := p5_a21;
    ddp_fee_types_rec.attribute3 := p5_a22;
    ddp_fee_types_rec.attribute4 := p5_a23;
    ddp_fee_types_rec.attribute5 := p5_a24;
    ddp_fee_types_rec.attribute6 := p5_a25;
    ddp_fee_types_rec.attribute7 := p5_a26;
    ddp_fee_types_rec.attribute8 := p5_a27;
    ddp_fee_types_rec.attribute9 := p5_a28;
    ddp_fee_types_rec.attribute10 := p5_a29;
    ddp_fee_types_rec.attribute11 := p5_a30;
    ddp_fee_types_rec.attribute12 := p5_a31;
    ddp_fee_types_rec.attribute13 := p5_a32;
    ddp_fee_types_rec.attribute14 := p5_a33;
    ddp_fee_types_rec.attribute15 := p5_a34;
    ddp_fee_types_rec.validate_dff_yn := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.validate_fee_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_types_rec,
      ddx_fee_types_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fee_types_rec.line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fee_types_rec.dnz_chr_id);
    p6_a2 := ddx_fee_types_rec.fee_type;
    p6_a3 := rosetta_g_miss_num_map(ddx_fee_types_rec.item_id);
    p6_a4 := ddx_fee_types_rec.item_name;
    p6_a5 := ddx_fee_types_rec.item_id1;
    p6_a6 := ddx_fee_types_rec.item_id2;
    p6_a7 := rosetta_g_miss_num_map(ddx_fee_types_rec.party_id);
    p6_a8 := ddx_fee_types_rec.party_name;
    p6_a9 := ddx_fee_types_rec.party_id1;
    p6_a10 := ddx_fee_types_rec.party_id2;
    p6_a11 := ddx_fee_types_rec.effective_from;
    p6_a12 := ddx_fee_types_rec.effective_to;
    p6_a13 := rosetta_g_miss_num_map(ddx_fee_types_rec.amount);
    p6_a14 := rosetta_g_miss_num_map(ddx_fee_types_rec.initial_direct_cost);
    p6_a15 := rosetta_g_miss_num_map(ddx_fee_types_rec.roll_qt);
    p6_a16 := rosetta_g_miss_num_map(ddx_fee_types_rec.qte_id);
    p6_a17 := ddx_fee_types_rec.funding_date;
    p6_a18 := ddx_fee_types_rec.fee_purpose_code;
    p6_a19 := ddx_fee_types_rec.attribute_category;
    p6_a20 := ddx_fee_types_rec.attribute1;
    p6_a21 := ddx_fee_types_rec.attribute2;
    p6_a22 := ddx_fee_types_rec.attribute3;
    p6_a23 := ddx_fee_types_rec.attribute4;
    p6_a24 := ddx_fee_types_rec.attribute5;
    p6_a25 := ddx_fee_types_rec.attribute6;
    p6_a26 := ddx_fee_types_rec.attribute7;
    p6_a27 := ddx_fee_types_rec.attribute8;
    p6_a28 := ddx_fee_types_rec.attribute9;
    p6_a29 := ddx_fee_types_rec.attribute10;
    p6_a30 := ddx_fee_types_rec.attribute11;
    p6_a31 := ddx_fee_types_rec.attribute12;
    p6_a32 := ddx_fee_types_rec.attribute13;
    p6_a33 := ddx_fee_types_rec.attribute14;
    p6_a34 := ddx_fee_types_rec.attribute15;
    p6_a35 := ddx_fee_types_rec.validate_dff_yn;
  end;

  procedure update_fee_type(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
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
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddx_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_types_rec.line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_fee_types_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_fee_types_rec.fee_type := p5_a2;
    ddp_fee_types_rec.item_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fee_types_rec.item_name := p5_a4;
    ddp_fee_types_rec.item_id1 := p5_a5;
    ddp_fee_types_rec.item_id2 := p5_a6;
    ddp_fee_types_rec.party_id := rosetta_g_miss_num_map(p5_a7);
    ddp_fee_types_rec.party_name := p5_a8;
    ddp_fee_types_rec.party_id1 := p5_a9;
    ddp_fee_types_rec.party_id2 := p5_a10;
    ddp_fee_types_rec.effective_from := rosetta_g_miss_date_in_map(p5_a11);
    ddp_fee_types_rec.effective_to := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fee_types_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_fee_types_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a14);
    ddp_fee_types_rec.roll_qt := rosetta_g_miss_num_map(p5_a15);
    ddp_fee_types_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_fee_types_rec.funding_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_fee_types_rec.fee_purpose_code := p5_a18;
    ddp_fee_types_rec.attribute_category := p5_a19;
    ddp_fee_types_rec.attribute1 := p5_a20;
    ddp_fee_types_rec.attribute2 := p5_a21;
    ddp_fee_types_rec.attribute3 := p5_a22;
    ddp_fee_types_rec.attribute4 := p5_a23;
    ddp_fee_types_rec.attribute5 := p5_a24;
    ddp_fee_types_rec.attribute6 := p5_a25;
    ddp_fee_types_rec.attribute7 := p5_a26;
    ddp_fee_types_rec.attribute8 := p5_a27;
    ddp_fee_types_rec.attribute9 := p5_a28;
    ddp_fee_types_rec.attribute10 := p5_a29;
    ddp_fee_types_rec.attribute11 := p5_a30;
    ddp_fee_types_rec.attribute12 := p5_a31;
    ddp_fee_types_rec.attribute13 := p5_a32;
    ddp_fee_types_rec.attribute14 := p5_a33;
    ddp_fee_types_rec.attribute15 := p5_a34;
    ddp_fee_types_rec.validate_dff_yn := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.update_fee_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_types_rec,
      ddx_fee_types_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fee_types_rec.line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fee_types_rec.dnz_chr_id);
    p6_a2 := ddx_fee_types_rec.fee_type;
    p6_a3 := rosetta_g_miss_num_map(ddx_fee_types_rec.item_id);
    p6_a4 := ddx_fee_types_rec.item_name;
    p6_a5 := ddx_fee_types_rec.item_id1;
    p6_a6 := ddx_fee_types_rec.item_id2;
    p6_a7 := rosetta_g_miss_num_map(ddx_fee_types_rec.party_id);
    p6_a8 := ddx_fee_types_rec.party_name;
    p6_a9 := ddx_fee_types_rec.party_id1;
    p6_a10 := ddx_fee_types_rec.party_id2;
    p6_a11 := ddx_fee_types_rec.effective_from;
    p6_a12 := ddx_fee_types_rec.effective_to;
    p6_a13 := rosetta_g_miss_num_map(ddx_fee_types_rec.amount);
    p6_a14 := rosetta_g_miss_num_map(ddx_fee_types_rec.initial_direct_cost);
    p6_a15 := rosetta_g_miss_num_map(ddx_fee_types_rec.roll_qt);
    p6_a16 := rosetta_g_miss_num_map(ddx_fee_types_rec.qte_id);
    p6_a17 := ddx_fee_types_rec.funding_date;
    p6_a18 := ddx_fee_types_rec.fee_purpose_code;
    p6_a19 := ddx_fee_types_rec.attribute_category;
    p6_a20 := ddx_fee_types_rec.attribute1;
    p6_a21 := ddx_fee_types_rec.attribute2;
    p6_a22 := ddx_fee_types_rec.attribute3;
    p6_a23 := ddx_fee_types_rec.attribute4;
    p6_a24 := ddx_fee_types_rec.attribute5;
    p6_a25 := ddx_fee_types_rec.attribute6;
    p6_a26 := ddx_fee_types_rec.attribute7;
    p6_a27 := ddx_fee_types_rec.attribute8;
    p6_a28 := ddx_fee_types_rec.attribute9;
    p6_a29 := ddx_fee_types_rec.attribute10;
    p6_a30 := ddx_fee_types_rec.attribute11;
    p6_a31 := ddx_fee_types_rec.attribute12;
    p6_a32 := ddx_fee_types_rec.attribute13;
    p6_a33 := ddx_fee_types_rec.attribute14;
    p6_a34 := ddx_fee_types_rec.attribute15;
    p6_a35 := ddx_fee_types_rec.validate_dff_yn;
  end;

  procedure delete_fee_type(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_types_rec.line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_fee_types_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_fee_types_rec.fee_type := p5_a2;
    ddp_fee_types_rec.item_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fee_types_rec.item_name := p5_a4;
    ddp_fee_types_rec.item_id1 := p5_a5;
    ddp_fee_types_rec.item_id2 := p5_a6;
    ddp_fee_types_rec.party_id := rosetta_g_miss_num_map(p5_a7);
    ddp_fee_types_rec.party_name := p5_a8;
    ddp_fee_types_rec.party_id1 := p5_a9;
    ddp_fee_types_rec.party_id2 := p5_a10;
    ddp_fee_types_rec.effective_from := rosetta_g_miss_date_in_map(p5_a11);
    ddp_fee_types_rec.effective_to := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fee_types_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_fee_types_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a14);
    ddp_fee_types_rec.roll_qt := rosetta_g_miss_num_map(p5_a15);
    ddp_fee_types_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_fee_types_rec.funding_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_fee_types_rec.fee_purpose_code := p5_a18;
    ddp_fee_types_rec.attribute_category := p5_a19;
    ddp_fee_types_rec.attribute1 := p5_a20;
    ddp_fee_types_rec.attribute2 := p5_a21;
    ddp_fee_types_rec.attribute3 := p5_a22;
    ddp_fee_types_rec.attribute4 := p5_a23;
    ddp_fee_types_rec.attribute5 := p5_a24;
    ddp_fee_types_rec.attribute6 := p5_a25;
    ddp_fee_types_rec.attribute7 := p5_a26;
    ddp_fee_types_rec.attribute8 := p5_a27;
    ddp_fee_types_rec.attribute9 := p5_a28;
    ddp_fee_types_rec.attribute10 := p5_a29;
    ddp_fee_types_rec.attribute11 := p5_a30;
    ddp_fee_types_rec.attribute12 := p5_a31;
    ddp_fee_types_rec.attribute13 := p5_a32;
    ddp_fee_types_rec.attribute14 := p5_a33;
    ddp_fee_types_rec.attribute15 := p5_a34;
    ddp_fee_types_rec.validate_dff_yn := p5_a35;

    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.delete_fee_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_types_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rollover_feeline(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_qte_id  NUMBER
    , p_for_qa_check  number
  )

  as
    ddp_for_qa_check boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    if p_for_qa_check is null
      then ddp_for_qa_check := null;
    elsif p_for_qa_check = 0
      then ddp_for_qa_check := false;
    else ddp_for_qa_check := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.validate_rollover_feeline(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_qte_id,
      ddp_for_qa_check);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_rvi_stream(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_box_value  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  DATE
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  NUMBER
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  DATE := fnd_api.g_miss_date
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddx_fee_types_rec okl_maintain_fee_pvt.fee_types_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_fee_types_rec.line_id := rosetta_g_miss_num_map(p6_a0);
    ddp_fee_types_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a1);
    ddp_fee_types_rec.fee_type := p6_a2;
    ddp_fee_types_rec.item_id := rosetta_g_miss_num_map(p6_a3);
    ddp_fee_types_rec.item_name := p6_a4;
    ddp_fee_types_rec.item_id1 := p6_a5;
    ddp_fee_types_rec.item_id2 := p6_a6;
    ddp_fee_types_rec.party_id := rosetta_g_miss_num_map(p6_a7);
    ddp_fee_types_rec.party_name := p6_a8;
    ddp_fee_types_rec.party_id1 := p6_a9;
    ddp_fee_types_rec.party_id2 := p6_a10;
    ddp_fee_types_rec.effective_from := rosetta_g_miss_date_in_map(p6_a11);
    ddp_fee_types_rec.effective_to := rosetta_g_miss_date_in_map(p6_a12);
    ddp_fee_types_rec.amount := rosetta_g_miss_num_map(p6_a13);
    ddp_fee_types_rec.initial_direct_cost := rosetta_g_miss_num_map(p6_a14);
    ddp_fee_types_rec.roll_qt := rosetta_g_miss_num_map(p6_a15);
    ddp_fee_types_rec.qte_id := rosetta_g_miss_num_map(p6_a16);
    ddp_fee_types_rec.funding_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_fee_types_rec.fee_purpose_code := p6_a18;
    ddp_fee_types_rec.attribute_category := p6_a19;
    ddp_fee_types_rec.attribute1 := p6_a20;
    ddp_fee_types_rec.attribute2 := p6_a21;
    ddp_fee_types_rec.attribute3 := p6_a22;
    ddp_fee_types_rec.attribute4 := p6_a23;
    ddp_fee_types_rec.attribute5 := p6_a24;
    ddp_fee_types_rec.attribute6 := p6_a25;
    ddp_fee_types_rec.attribute7 := p6_a26;
    ddp_fee_types_rec.attribute8 := p6_a27;
    ddp_fee_types_rec.attribute9 := p6_a28;
    ddp_fee_types_rec.attribute10 := p6_a29;
    ddp_fee_types_rec.attribute11 := p6_a30;
    ddp_fee_types_rec.attribute12 := p6_a31;
    ddp_fee_types_rec.attribute13 := p6_a32;
    ddp_fee_types_rec.attribute14 := p6_a33;
    ddp_fee_types_rec.attribute15 := p6_a34;
    ddp_fee_types_rec.validate_dff_yn := p6_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.process_rvi_stream(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_box_value,
      ddp_fee_types_rec,
      ddx_fee_types_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_fee_types_rec.line_id);
    p7_a1 := rosetta_g_miss_num_map(ddx_fee_types_rec.dnz_chr_id);
    p7_a2 := ddx_fee_types_rec.fee_type;
    p7_a3 := rosetta_g_miss_num_map(ddx_fee_types_rec.item_id);
    p7_a4 := ddx_fee_types_rec.item_name;
    p7_a5 := ddx_fee_types_rec.item_id1;
    p7_a6 := ddx_fee_types_rec.item_id2;
    p7_a7 := rosetta_g_miss_num_map(ddx_fee_types_rec.party_id);
    p7_a8 := ddx_fee_types_rec.party_name;
    p7_a9 := ddx_fee_types_rec.party_id1;
    p7_a10 := ddx_fee_types_rec.party_id2;
    p7_a11 := ddx_fee_types_rec.effective_from;
    p7_a12 := ddx_fee_types_rec.effective_to;
    p7_a13 := rosetta_g_miss_num_map(ddx_fee_types_rec.amount);
    p7_a14 := rosetta_g_miss_num_map(ddx_fee_types_rec.initial_direct_cost);
    p7_a15 := rosetta_g_miss_num_map(ddx_fee_types_rec.roll_qt);
    p7_a16 := rosetta_g_miss_num_map(ddx_fee_types_rec.qte_id);
    p7_a17 := ddx_fee_types_rec.funding_date;
    p7_a18 := ddx_fee_types_rec.fee_purpose_code;
    p7_a19 := ddx_fee_types_rec.attribute_category;
    p7_a20 := ddx_fee_types_rec.attribute1;
    p7_a21 := ddx_fee_types_rec.attribute2;
    p7_a22 := ddx_fee_types_rec.attribute3;
    p7_a23 := ddx_fee_types_rec.attribute4;
    p7_a24 := ddx_fee_types_rec.attribute5;
    p7_a25 := ddx_fee_types_rec.attribute6;
    p7_a26 := ddx_fee_types_rec.attribute7;
    p7_a27 := ddx_fee_types_rec.attribute8;
    p7_a28 := ddx_fee_types_rec.attribute9;
    p7_a29 := ddx_fee_types_rec.attribute10;
    p7_a30 := ddx_fee_types_rec.attribute11;
    p7_a31 := ddx_fee_types_rec.attribute12;
    p7_a32 := ddx_fee_types_rec.attribute13;
    p7_a33 := ddx_fee_types_rec.attribute14;
    p7_a34 := ddx_fee_types_rec.attribute15;
    p7_a35 := ddx_fee_types_rec.validate_dff_yn;
  end;

  procedure create_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
  )

  as
    ddp_kpl_rec okl_maintain_fee_pvt.party_rec_type;
    ddx_kpl_rec okl_maintain_fee_pvt.party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_kpl_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_kpl_rec.attribute_category := p5_a1;
    ddp_kpl_rec.attribute1 := p5_a2;
    ddp_kpl_rec.attribute2 := p5_a3;
    ddp_kpl_rec.attribute3 := p5_a4;
    ddp_kpl_rec.attribute4 := p5_a5;
    ddp_kpl_rec.attribute5 := p5_a6;
    ddp_kpl_rec.attribute6 := p5_a7;
    ddp_kpl_rec.attribute7 := p5_a8;
    ddp_kpl_rec.attribute8 := p5_a9;
    ddp_kpl_rec.attribute9 := p5_a10;
    ddp_kpl_rec.attribute10 := p5_a11;
    ddp_kpl_rec.attribute11 := p5_a12;
    ddp_kpl_rec.attribute12 := p5_a13;
    ddp_kpl_rec.attribute13 := p5_a14;
    ddp_kpl_rec.attribute14 := p5_a15;
    ddp_kpl_rec.attribute15 := p5_a16;
    ddp_kpl_rec.object1_id1 := p5_a17;
    ddp_kpl_rec.object1_id2 := p5_a18;
    ddp_kpl_rec.jtot_object1_code := p5_a19;
    ddp_kpl_rec.rle_code := p5_a20;
    ddp_kpl_rec.chr_id := rosetta_g_miss_num_map(p5_a21);
    ddp_kpl_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_kpl_rec.cle_id := rosetta_g_miss_num_map(p5_a23);


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.create_party(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_kpl_rec,
      ddx_kpl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_kpl_rec.id);
    p6_a1 := ddx_kpl_rec.attribute_category;
    p6_a2 := ddx_kpl_rec.attribute1;
    p6_a3 := ddx_kpl_rec.attribute2;
    p6_a4 := ddx_kpl_rec.attribute3;
    p6_a5 := ddx_kpl_rec.attribute4;
    p6_a6 := ddx_kpl_rec.attribute5;
    p6_a7 := ddx_kpl_rec.attribute6;
    p6_a8 := ddx_kpl_rec.attribute7;
    p6_a9 := ddx_kpl_rec.attribute8;
    p6_a10 := ddx_kpl_rec.attribute9;
    p6_a11 := ddx_kpl_rec.attribute10;
    p6_a12 := ddx_kpl_rec.attribute11;
    p6_a13 := ddx_kpl_rec.attribute12;
    p6_a14 := ddx_kpl_rec.attribute13;
    p6_a15 := ddx_kpl_rec.attribute14;
    p6_a16 := ddx_kpl_rec.attribute15;
    p6_a17 := ddx_kpl_rec.object1_id1;
    p6_a18 := ddx_kpl_rec.object1_id2;
    p6_a19 := ddx_kpl_rec.jtot_object1_code;
    p6_a20 := ddx_kpl_rec.rle_code;
    p6_a21 := rosetta_g_miss_num_map(ddx_kpl_rec.chr_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_kpl_rec.dnz_chr_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_kpl_rec.cle_id);
  end;

  procedure update_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
  )

  as
    ddp_kpl_rec okl_maintain_fee_pvt.party_rec_type;
    ddx_kpl_rec okl_maintain_fee_pvt.party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_kpl_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_kpl_rec.attribute_category := p5_a1;
    ddp_kpl_rec.attribute1 := p5_a2;
    ddp_kpl_rec.attribute2 := p5_a3;
    ddp_kpl_rec.attribute3 := p5_a4;
    ddp_kpl_rec.attribute4 := p5_a5;
    ddp_kpl_rec.attribute5 := p5_a6;
    ddp_kpl_rec.attribute6 := p5_a7;
    ddp_kpl_rec.attribute7 := p5_a8;
    ddp_kpl_rec.attribute8 := p5_a9;
    ddp_kpl_rec.attribute9 := p5_a10;
    ddp_kpl_rec.attribute10 := p5_a11;
    ddp_kpl_rec.attribute11 := p5_a12;
    ddp_kpl_rec.attribute12 := p5_a13;
    ddp_kpl_rec.attribute13 := p5_a14;
    ddp_kpl_rec.attribute14 := p5_a15;
    ddp_kpl_rec.attribute15 := p5_a16;
    ddp_kpl_rec.object1_id1 := p5_a17;
    ddp_kpl_rec.object1_id2 := p5_a18;
    ddp_kpl_rec.jtot_object1_code := p5_a19;
    ddp_kpl_rec.rle_code := p5_a20;
    ddp_kpl_rec.chr_id := rosetta_g_miss_num_map(p5_a21);
    ddp_kpl_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_kpl_rec.cle_id := rosetta_g_miss_num_map(p5_a23);


    -- here's the delegated call to the old PL/SQL routine
    okl_maintain_fee_pvt.update_party(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_kpl_rec,
      ddx_kpl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_kpl_rec.id);
    p6_a1 := ddx_kpl_rec.attribute_category;
    p6_a2 := ddx_kpl_rec.attribute1;
    p6_a3 := ddx_kpl_rec.attribute2;
    p6_a4 := ddx_kpl_rec.attribute3;
    p6_a5 := ddx_kpl_rec.attribute4;
    p6_a6 := ddx_kpl_rec.attribute5;
    p6_a7 := ddx_kpl_rec.attribute6;
    p6_a8 := ddx_kpl_rec.attribute7;
    p6_a9 := ddx_kpl_rec.attribute8;
    p6_a10 := ddx_kpl_rec.attribute9;
    p6_a11 := ddx_kpl_rec.attribute10;
    p6_a12 := ddx_kpl_rec.attribute11;
    p6_a13 := ddx_kpl_rec.attribute12;
    p6_a14 := ddx_kpl_rec.attribute13;
    p6_a15 := ddx_kpl_rec.attribute14;
    p6_a16 := ddx_kpl_rec.attribute15;
    p6_a17 := ddx_kpl_rec.object1_id1;
    p6_a18 := ddx_kpl_rec.object1_id2;
    p6_a19 := ddx_kpl_rec.jtot_object1_code;
    p6_a20 := ddx_kpl_rec.rle_code;
    p6_a21 := rosetta_g_miss_num_map(ddx_kpl_rec.chr_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_kpl_rec.dnz_chr_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_kpl_rec.cle_id);
  end;

end okl_maintain_fee_pvt_w;

/
