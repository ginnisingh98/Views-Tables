--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_CREAT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_CREAT_PVT_W" as
  /* $Header: OKLEDCRB.pls 120.11.12010000.2 2009/06/02 10:32:52 racheruv ship $ */
  procedure rosetta_table_copy_in_p7(t out nocopy okl_deal_creat_pvt.deal_tab_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_500
    , a86 JTF_VARCHAR2_TABLE_500
    , a87 JTF_VARCHAR2_TABLE_500
    , a88 JTF_VARCHAR2_TABLE_500
    , a89 JTF_VARCHAR2_TABLE_500
    , a90 JTF_VARCHAR2_TABLE_500
    , a91 JTF_VARCHAR2_TABLE_500
    , a92 JTF_VARCHAR2_TABLE_500
    , a93 JTF_VARCHAR2_TABLE_500
    , a94 JTF_VARCHAR2_TABLE_500
    , a95 JTF_VARCHAR2_TABLE_500
    , a96 JTF_VARCHAR2_TABLE_500
    , a97 JTF_VARCHAR2_TABLE_500
    , a98 JTF_VARCHAR2_TABLE_500
    , a99 JTF_VARCHAR2_TABLE_500
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := a0(indx);
          t(ddindx).chr_contract_number := a1(indx);
          t(ddindx).chr_description := a2(indx);
          t(ddindx).vers_version := a3(indx);
          t(ddindx).chr_sts_code := a4(indx);
          t(ddindx).chr_start_date := a5(indx);
          t(ddindx).chr_end_date := a6(indx);
          t(ddindx).khr_term_duration := a7(indx);
          t(ddindx).chr_cust_po_number := a8(indx);
          t(ddindx).chr_inv_organization_id := a9(indx);
          t(ddindx).chr_authoring_org_id := a10(indx);
          t(ddindx).khr_generate_accrual_yn := a11(indx);
          t(ddindx).khr_syndicatable_yn := a12(indx);
          t(ddindx).khr_prefunding_eligible_yn := a13(indx);
          t(ddindx).khr_revolving_credit_yn := a14(indx);
          t(ddindx).khr_converted_account_yn := a15(indx);
          t(ddindx).khr_credit_act_yn := a16(indx);
          t(ddindx).chr_template_yn := a17(indx);
          t(ddindx).chr_date_signed := a18(indx);
          t(ddindx).khr_date_deal_transferred := a19(indx);
          t(ddindx).khr_accepted_date := a20(indx);
          t(ddindx).khr_expected_delivery_date := a21(indx);
          t(ddindx).khr_amd_code := a22(indx);
          t(ddindx).khr_deal_type := a23(indx);
          t(ddindx).mla_contract_number := a24(indx);
          t(ddindx).mla_gvr_chr_id_referred := a25(indx);
          t(ddindx).mla_gvr_id := a26(indx);
          t(ddindx).cust_id := a27(indx);
          t(ddindx).cust_object1_id1 := a28(indx);
          t(ddindx).cust_object1_id2 := a29(indx);
          t(ddindx).cust_jtot_object1_code := a30(indx);
          t(ddindx).cust_name := a31(indx);
          t(ddindx).lessor_id := a32(indx);
          t(ddindx).lessor_object1_id1 := a33(indx);
          t(ddindx).lessor_object1_id2 := a34(indx);
          t(ddindx).lessor_jtot_object1_code := a35(indx);
          t(ddindx).lessor_name := a36(indx);
          t(ddindx).chr_currency_code := a37(indx);
          t(ddindx).currency_name := a38(indx);
          t(ddindx).khr_pdt_id := a39(indx);
          t(ddindx).product_name := a40(indx);
          t(ddindx).product_description := a41(indx);
          t(ddindx).khr_khr_id := a42(indx);
          t(ddindx).program_contract_number := a43(indx);
          t(ddindx).cl_contract_number := a44(indx);
          t(ddindx).cl_gvr_chr_id_referred := a45(indx);
          t(ddindx).cl_gvr_id := a46(indx);
          t(ddindx).rg_larles_id := a47(indx);
          t(ddindx).r_larles_id := a48(indx);
          t(ddindx).r_larles_rule_information1 := a49(indx);
          t(ddindx).col_larles_form_left_prompt := a50(indx);
          t(ddindx).rg_larebl_id := a51(indx);
          t(ddindx).r_larebl_id := a52(indx);
          t(ddindx).r_larebl_rule_information1 := a53(indx);
          t(ddindx).col_larebl_form_left_prompt := a54(indx);
          t(ddindx).chr_cust_acct_id := a55(indx);
          t(ddindx).customer_account := a56(indx);
          t(ddindx).cust_site_description := a57(indx);
          t(ddindx).contact_id := a58(indx);
          t(ddindx).contact_object1_id1 := a59(indx);
          t(ddindx).contact_object1_id2 := a60(indx);
          t(ddindx).contact_jtot_object1_code := a61(indx);
          t(ddindx).contact_name := a62(indx);
          t(ddindx).rg_latown_id := a63(indx);
          t(ddindx).r_latown_id := a64(indx);
          t(ddindx).r_latown_rule_information1 := a65(indx);
          t(ddindx).col_latown_form_left_prompt := a66(indx);
          t(ddindx).rg_lanntf_id := a67(indx);
          t(ddindx).r_lanntf_id := a68(indx);
          t(ddindx).r_lanntf_rule_information1 := a69(indx);
          t(ddindx).col_lanntf_form_left_prompt := a70(indx);
          t(ddindx).rg_lacpln_id := a71(indx);
          t(ddindx).r_lacpln_id := a72(indx);
          t(ddindx).r_lacpln_rule_information1 := a73(indx);
          t(ddindx).col_lacpln_form_left_prompt := a74(indx);
          t(ddindx).rg_lapact_id := a75(indx);
          t(ddindx).r_lapact_id := a76(indx);
          t(ddindx).r_lapact_rule_information1 := a77(indx);
          t(ddindx).col_lapact_form_left_prompt := a78(indx);
          t(ddindx).khr_currency_conv_type := a79(indx);
          t(ddindx).khr_currency_conv_rate := a80(indx);
          t(ddindx).khr_currency_conv_date := a81(indx);
          t(ddindx).khr_assignable_yn := a82(indx);
          t(ddindx).legal_entity_id := a83(indx);
          t(ddindx).attribute_category := a84(indx);
          t(ddindx).attribute1 := a85(indx);
          t(ddindx).attribute2 := a86(indx);
          t(ddindx).attribute3 := a87(indx);
          t(ddindx).attribute4 := a88(indx);
          t(ddindx).attribute5 := a89(indx);
          t(ddindx).attribute6 := a90(indx);
          t(ddindx).attribute7 := a91(indx);
          t(ddindx).attribute8 := a92(indx);
          t(ddindx).attribute9 := a93(indx);
          t(ddindx).attribute10 := a94(indx);
          t(ddindx).attribute11 := a95(indx);
          t(ddindx).attribute12 := a96(indx);
          t(ddindx).attribute13 := a97(indx);
          t(ddindx).attribute14 := a98(indx);
          t(ddindx).attribute15 := a99(indx);
          t(ddindx).labill_labacc_billto := a100(indx);
          t(ddindx).labill_labacc_rgp_id := a101(indx);
          t(ddindx).labill_labacc_rgd_code := a102(indx);
          t(ddindx).labill_labacc_rul_id := a103(indx);
          t(ddindx).labill_labacc_rul_info_cat := a104(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_deal_creat_pvt.deal_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_500
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_500
    , a86 out nocopy JTF_VARCHAR2_TABLE_500
    , a87 out nocopy JTF_VARCHAR2_TABLE_500
    , a88 out nocopy JTF_VARCHAR2_TABLE_500
    , a89 out nocopy JTF_VARCHAR2_TABLE_500
    , a90 out nocopy JTF_VARCHAR2_TABLE_500
    , a91 out nocopy JTF_VARCHAR2_TABLE_500
    , a92 out nocopy JTF_VARCHAR2_TABLE_500
    , a93 out nocopy JTF_VARCHAR2_TABLE_500
    , a94 out nocopy JTF_VARCHAR2_TABLE_500
    , a95 out nocopy JTF_VARCHAR2_TABLE_500
    , a96 out nocopy JTF_VARCHAR2_TABLE_500
    , a97 out nocopy JTF_VARCHAR2_TABLE_500
    , a98 out nocopy JTF_VARCHAR2_TABLE_500
    , a99 out nocopy JTF_VARCHAR2_TABLE_500
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_2000();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_500();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_500();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_DATE_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_500();
    a86 := JTF_VARCHAR2_TABLE_500();
    a87 := JTF_VARCHAR2_TABLE_500();
    a88 := JTF_VARCHAR2_TABLE_500();
    a89 := JTF_VARCHAR2_TABLE_500();
    a90 := JTF_VARCHAR2_TABLE_500();
    a91 := JTF_VARCHAR2_TABLE_500();
    a92 := JTF_VARCHAR2_TABLE_500();
    a93 := JTF_VARCHAR2_TABLE_500();
    a94 := JTF_VARCHAR2_TABLE_500();
    a95 := JTF_VARCHAR2_TABLE_500();
    a96 := JTF_VARCHAR2_TABLE_500();
    a97 := JTF_VARCHAR2_TABLE_500();
    a98 := JTF_VARCHAR2_TABLE_500();
    a99 := JTF_VARCHAR2_TABLE_500();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_2000();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_500();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_500();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_DATE_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_500();
      a86 := JTF_VARCHAR2_TABLE_500();
      a87 := JTF_VARCHAR2_TABLE_500();
      a88 := JTF_VARCHAR2_TABLE_500();
      a89 := JTF_VARCHAR2_TABLE_500();
      a90 := JTF_VARCHAR2_TABLE_500();
      a91 := JTF_VARCHAR2_TABLE_500();
      a92 := JTF_VARCHAR2_TABLE_500();
      a93 := JTF_VARCHAR2_TABLE_500();
      a94 := JTF_VARCHAR2_TABLE_500();
      a95 := JTF_VARCHAR2_TABLE_500();
      a96 := JTF_VARCHAR2_TABLE_500();
      a97 := JTF_VARCHAR2_TABLE_500();
      a98 := JTF_VARCHAR2_TABLE_500();
      a99 := JTF_VARCHAR2_TABLE_500();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_VARCHAR2_TABLE_100();
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
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).chr_id;
          a1(indx) := t(ddindx).chr_contract_number;
          a2(indx) := t(ddindx).chr_description;
          a3(indx) := t(ddindx).vers_version;
          a4(indx) := t(ddindx).chr_sts_code;
          a5(indx) := t(ddindx).chr_start_date;
          a6(indx) := t(ddindx).chr_end_date;
          a7(indx) := t(ddindx).khr_term_duration;
          a8(indx) := t(ddindx).chr_cust_po_number;
          a9(indx) := t(ddindx).chr_inv_organization_id;
          a10(indx) := t(ddindx).chr_authoring_org_id;
          a11(indx) := t(ddindx).khr_generate_accrual_yn;
          a12(indx) := t(ddindx).khr_syndicatable_yn;
          a13(indx) := t(ddindx).khr_prefunding_eligible_yn;
          a14(indx) := t(ddindx).khr_revolving_credit_yn;
          a15(indx) := t(ddindx).khr_converted_account_yn;
          a16(indx) := t(ddindx).khr_credit_act_yn;
          a17(indx) := t(ddindx).chr_template_yn;
          a18(indx) := t(ddindx).chr_date_signed;
          a19(indx) := t(ddindx).khr_date_deal_transferred;
          a20(indx) := t(ddindx).khr_accepted_date;
          a21(indx) := t(ddindx).khr_expected_delivery_date;
          a22(indx) := t(ddindx).khr_amd_code;
          a23(indx) := t(ddindx).khr_deal_type;
          a24(indx) := t(ddindx).mla_contract_number;
          a25(indx) := t(ddindx).mla_gvr_chr_id_referred;
          a26(indx) := t(ddindx).mla_gvr_id;
          a27(indx) := t(ddindx).cust_id;
          a28(indx) := t(ddindx).cust_object1_id1;
          a29(indx) := t(ddindx).cust_object1_id2;
          a30(indx) := t(ddindx).cust_jtot_object1_code;
          a31(indx) := t(ddindx).cust_name;
          a32(indx) := t(ddindx).lessor_id;
          a33(indx) := t(ddindx).lessor_object1_id1;
          a34(indx) := t(ddindx).lessor_object1_id2;
          a35(indx) := t(ddindx).lessor_jtot_object1_code;
          a36(indx) := t(ddindx).lessor_name;
          a37(indx) := t(ddindx).chr_currency_code;
          a38(indx) := t(ddindx).currency_name;
          a39(indx) := t(ddindx).khr_pdt_id;
          a40(indx) := t(ddindx).product_name;
          a41(indx) := t(ddindx).product_description;
          a42(indx) := t(ddindx).khr_khr_id;
          a43(indx) := t(ddindx).program_contract_number;
          a44(indx) := t(ddindx).cl_contract_number;
          a45(indx) := t(ddindx).cl_gvr_chr_id_referred;
          a46(indx) := t(ddindx).cl_gvr_id;
          a47(indx) := t(ddindx).rg_larles_id;
          a48(indx) := t(ddindx).r_larles_id;
          a49(indx) := t(ddindx).r_larles_rule_information1;
          a50(indx) := t(ddindx).col_larles_form_left_prompt;
          a51(indx) := t(ddindx).rg_larebl_id;
          a52(indx) := t(ddindx).r_larebl_id;
          a53(indx) := t(ddindx).r_larebl_rule_information1;
          a54(indx) := t(ddindx).col_larebl_form_left_prompt;
          a55(indx) := t(ddindx).chr_cust_acct_id;
          a56(indx) := t(ddindx).customer_account;
          a57(indx) := t(ddindx).cust_site_description;
          a58(indx) := t(ddindx).contact_id;
          a59(indx) := t(ddindx).contact_object1_id1;
          a60(indx) := t(ddindx).contact_object1_id2;
          a61(indx) := t(ddindx).contact_jtot_object1_code;
          a62(indx) := t(ddindx).contact_name;
          a63(indx) := t(ddindx).rg_latown_id;
          a64(indx) := t(ddindx).r_latown_id;
          a65(indx) := t(ddindx).r_latown_rule_information1;
          a66(indx) := t(ddindx).col_latown_form_left_prompt;
          a67(indx) := t(ddindx).rg_lanntf_id;
          a68(indx) := t(ddindx).r_lanntf_id;
          a69(indx) := t(ddindx).r_lanntf_rule_information1;
          a70(indx) := t(ddindx).col_lanntf_form_left_prompt;
          a71(indx) := t(ddindx).rg_lacpln_id;
          a72(indx) := t(ddindx).r_lacpln_id;
          a73(indx) := t(ddindx).r_lacpln_rule_information1;
          a74(indx) := t(ddindx).col_lacpln_form_left_prompt;
          a75(indx) := t(ddindx).rg_lapact_id;
          a76(indx) := t(ddindx).r_lapact_id;
          a77(indx) := t(ddindx).r_lapact_rule_information1;
          a78(indx) := t(ddindx).col_lapact_form_left_prompt;
          a79(indx) := t(ddindx).khr_currency_conv_type;
          a80(indx) := t(ddindx).khr_currency_conv_rate;
          a81(indx) := t(ddindx).khr_currency_conv_date;
          a82(indx) := t(ddindx).khr_assignable_yn;
          a83(indx) := t(ddindx).legal_entity_id;
          a84(indx) := t(ddindx).attribute_category;
          a85(indx) := t(ddindx).attribute1;
          a86(indx) := t(ddindx).attribute2;
          a87(indx) := t(ddindx).attribute3;
          a88(indx) := t(ddindx).attribute4;
          a89(indx) := t(ddindx).attribute5;
          a90(indx) := t(ddindx).attribute6;
          a91(indx) := t(ddindx).attribute7;
          a92(indx) := t(ddindx).attribute8;
          a93(indx) := t(ddindx).attribute9;
          a94(indx) := t(ddindx).attribute10;
          a95(indx) := t(ddindx).attribute11;
          a96(indx) := t(ddindx).attribute12;
          a97(indx) := t(ddindx).attribute13;
          a98(indx) := t(ddindx).attribute14;
          a99(indx) := t(ddindx).attribute15;
          a100(indx) := t(ddindx).labill_labacc_billto;
          a101(indx) := t(ddindx).labill_labacc_rgp_id;
          a102(indx) := t(ddindx).labill_labacc_rgd_code;
          a103(indx) := t(ddindx).labill_labacc_rul_id;
          a104(indx) := t(ddindx).labill_labacc_rul_info_cat;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_deal_creat_pvt.party_tab_type, a0 JTF_NUMBER_TABLE
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
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
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
          t(ddindx).chr_id := a21(indx);
          t(ddindx).dnz_chr_id := a22(indx);
          t(ddindx).cle_id := a23(indx);
          t(ddindx).cognomen := a24(indx);
          t(ddindx).alias := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_deal_creat_pvt.party_tab_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
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
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_200();
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
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
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
          a21(indx) := t(ddindx).chr_id;
          a22(indx) := t(ddindx).dnz_chr_id;
          a23(indx) := t(ddindx).cle_id;
          a24(indx) := t(ddindx).cognomen;
          a25(indx) := t(ddindx).alias;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_deal_creat_pvt.deal_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_500
    , a86 JTF_VARCHAR2_TABLE_500
    , a87 JTF_VARCHAR2_TABLE_500
    , a88 JTF_VARCHAR2_TABLE_500
    , a89 JTF_VARCHAR2_TABLE_500
    , a90 JTF_VARCHAR2_TABLE_500
    , a91 JTF_VARCHAR2_TABLE_500
    , a92 JTF_VARCHAR2_TABLE_500
    , a93 JTF_VARCHAR2_TABLE_500
    , a94 JTF_VARCHAR2_TABLE_500
    , a95 JTF_VARCHAR2_TABLE_500
    , a96 JTF_VARCHAR2_TABLE_500
    , a97 JTF_VARCHAR2_TABLE_500
    , a98 JTF_VARCHAR2_TABLE_500
    , a99 JTF_VARCHAR2_TABLE_500
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := a0(indx);
          t(ddindx).chr_contract_number := a1(indx);
          t(ddindx).chr_description := a2(indx);
          t(ddindx).vers_version := a3(indx);
          t(ddindx).chr_sts_code := a4(indx);
          t(ddindx).chr_start_date := a5(indx);
          t(ddindx).chr_end_date := a6(indx);
          t(ddindx).khr_term_duration := a7(indx);
          t(ddindx).chr_cust_po_number := a8(indx);
          t(ddindx).chr_inv_organization_id := a9(indx);
          t(ddindx).chr_authoring_org_id := a10(indx);
          t(ddindx).khr_generate_accrual_yn := a11(indx);
          t(ddindx).khr_syndicatable_yn := a12(indx);
          t(ddindx).khr_prefunding_eligible_yn := a13(indx);
          t(ddindx).khr_revolving_credit_yn := a14(indx);
          t(ddindx).khr_converted_account_yn := a15(indx);
          t(ddindx).khr_credit_act_yn := a16(indx);
          t(ddindx).chr_template_yn := a17(indx);
          t(ddindx).chr_date_signed := a18(indx);
          t(ddindx).khr_date_deal_transferred := a19(indx);
          t(ddindx).khr_accepted_date := a20(indx);
          t(ddindx).khr_expected_delivery_date := a21(indx);
          t(ddindx).khr_amd_code := a22(indx);
          t(ddindx).khr_deal_type := a23(indx);
          t(ddindx).mla_contract_number := a24(indx);
          t(ddindx).mla_gvr_chr_id_referred := a25(indx);
          t(ddindx).mla_gvr_id := a26(indx);
          t(ddindx).cust_id := a27(indx);
          t(ddindx).cust_object1_id1 := a28(indx);
          t(ddindx).cust_object1_id2 := a29(indx);
          t(ddindx).cust_jtot_object1_code := a30(indx);
          t(ddindx).cust_name := a31(indx);
          t(ddindx).lessor_id := a32(indx);
          t(ddindx).lessor_object1_id1 := a33(indx);
          t(ddindx).lessor_object1_id2 := a34(indx);
          t(ddindx).lessor_jtot_object1_code := a35(indx);
          t(ddindx).lessor_name := a36(indx);
          t(ddindx).chr_currency_code := a37(indx);
          t(ddindx).currency_name := a38(indx);
          t(ddindx).khr_pdt_id := a39(indx);
          t(ddindx).product_name := a40(indx);
          t(ddindx).product_description := a41(indx);
          t(ddindx).khr_khr_id := a42(indx);
          t(ddindx).program_contract_number := a43(indx);
          t(ddindx).cl_contract_number := a44(indx);
          t(ddindx).cl_gvr_chr_id_referred := a45(indx);
          t(ddindx).cl_gvr_id := a46(indx);
          t(ddindx).rg_larles_id := a47(indx);
          t(ddindx).r_larles_id := a48(indx);
          t(ddindx).r_larles_rule_information1 := a49(indx);
          t(ddindx).col_larles_form_left_prompt := a50(indx);
          t(ddindx).rg_larebl_id := a51(indx);
          t(ddindx).r_larebl_id := a52(indx);
          t(ddindx).r_larebl_rule_information1 := a53(indx);
          t(ddindx).col_larebl_form_left_prompt := a54(indx);
          t(ddindx).chr_cust_acct_id := a55(indx);
          t(ddindx).customer_account := a56(indx);
          t(ddindx).cust_site_description := a57(indx);
          t(ddindx).contact_id := a58(indx);
          t(ddindx).contact_object1_id1 := a59(indx);
          t(ddindx).contact_object1_id2 := a60(indx);
          t(ddindx).contact_jtot_object1_code := a61(indx);
          t(ddindx).contact_name := a62(indx);
          t(ddindx).rg_latown_id := a63(indx);
          t(ddindx).r_latown_id := a64(indx);
          t(ddindx).r_latown_rule_information1 := a65(indx);
          t(ddindx).col_latown_form_left_prompt := a66(indx);
          t(ddindx).rg_lanntf_id := a67(indx);
          t(ddindx).r_lanntf_id := a68(indx);
          t(ddindx).r_lanntf_rule_information1 := a69(indx);
          t(ddindx).col_lanntf_form_left_prompt := a70(indx);
          t(ddindx).rg_lacpln_id := a71(indx);
          t(ddindx).r_lacpln_id := a72(indx);
          t(ddindx).r_lacpln_rule_information1 := a73(indx);
          t(ddindx).col_lacpln_form_left_prompt := a74(indx);
          t(ddindx).rg_lapact_id := a75(indx);
          t(ddindx).r_lapact_id := a76(indx);
          t(ddindx).r_lapact_rule_information1 := a77(indx);
          t(ddindx).col_lapact_form_left_prompt := a78(indx);
          t(ddindx).khr_currency_conv_type := a79(indx);
          t(ddindx).khr_currency_conv_rate := a80(indx);
          t(ddindx).khr_currency_conv_date := a81(indx);
          t(ddindx).khr_assignable_yn := a82(indx);
          t(ddindx).legal_entity_id := a83(indx);
          t(ddindx).attribute_category := a84(indx);
          t(ddindx).attribute1 := a85(indx);
          t(ddindx).attribute2 := a86(indx);
          t(ddindx).attribute3 := a87(indx);
          t(ddindx).attribute4 := a88(indx);
          t(ddindx).attribute5 := a89(indx);
          t(ddindx).attribute6 := a90(indx);
          t(ddindx).attribute7 := a91(indx);
          t(ddindx).attribute8 := a92(indx);
          t(ddindx).attribute9 := a93(indx);
          t(ddindx).attribute10 := a94(indx);
          t(ddindx).attribute11 := a95(indx);
          t(ddindx).attribute12 := a96(indx);
          t(ddindx).attribute13 := a97(indx);
          t(ddindx).attribute14 := a98(indx);
          t(ddindx).attribute15 := a99(indx);
          t(ddindx).labill_labacc_billto := a100(indx);
          t(ddindx).labill_labacc_rgp_id := a101(indx);
          t(ddindx).labill_labacc_rgd_code := a102(indx);
          t(ddindx).labill_labacc_rul_id := a103(indx);
          t(ddindx).labill_labacc_rul_info_cat := a104(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_deal_creat_pvt.deal_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_500
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_500
    , a86 out nocopy JTF_VARCHAR2_TABLE_500
    , a87 out nocopy JTF_VARCHAR2_TABLE_500
    , a88 out nocopy JTF_VARCHAR2_TABLE_500
    , a89 out nocopy JTF_VARCHAR2_TABLE_500
    , a90 out nocopy JTF_VARCHAR2_TABLE_500
    , a91 out nocopy JTF_VARCHAR2_TABLE_500
    , a92 out nocopy JTF_VARCHAR2_TABLE_500
    , a93 out nocopy JTF_VARCHAR2_TABLE_500
    , a94 out nocopy JTF_VARCHAR2_TABLE_500
    , a95 out nocopy JTF_VARCHAR2_TABLE_500
    , a96 out nocopy JTF_VARCHAR2_TABLE_500
    , a97 out nocopy JTF_VARCHAR2_TABLE_500
    , a98 out nocopy JTF_VARCHAR2_TABLE_500
    , a99 out nocopy JTF_VARCHAR2_TABLE_500
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_2000();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_500();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_500();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_DATE_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_500();
    a86 := JTF_VARCHAR2_TABLE_500();
    a87 := JTF_VARCHAR2_TABLE_500();
    a88 := JTF_VARCHAR2_TABLE_500();
    a89 := JTF_VARCHAR2_TABLE_500();
    a90 := JTF_VARCHAR2_TABLE_500();
    a91 := JTF_VARCHAR2_TABLE_500();
    a92 := JTF_VARCHAR2_TABLE_500();
    a93 := JTF_VARCHAR2_TABLE_500();
    a94 := JTF_VARCHAR2_TABLE_500();
    a95 := JTF_VARCHAR2_TABLE_500();
    a96 := JTF_VARCHAR2_TABLE_500();
    a97 := JTF_VARCHAR2_TABLE_500();
    a98 := JTF_VARCHAR2_TABLE_500();
    a99 := JTF_VARCHAR2_TABLE_500();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_2000();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_500();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_500();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_DATE_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_500();
      a86 := JTF_VARCHAR2_TABLE_500();
      a87 := JTF_VARCHAR2_TABLE_500();
      a88 := JTF_VARCHAR2_TABLE_500();
      a89 := JTF_VARCHAR2_TABLE_500();
      a90 := JTF_VARCHAR2_TABLE_500();
      a91 := JTF_VARCHAR2_TABLE_500();
      a92 := JTF_VARCHAR2_TABLE_500();
      a93 := JTF_VARCHAR2_TABLE_500();
      a94 := JTF_VARCHAR2_TABLE_500();
      a95 := JTF_VARCHAR2_TABLE_500();
      a96 := JTF_VARCHAR2_TABLE_500();
      a97 := JTF_VARCHAR2_TABLE_500();
      a98 := JTF_VARCHAR2_TABLE_500();
      a99 := JTF_VARCHAR2_TABLE_500();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_VARCHAR2_TABLE_100();
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
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).chr_id;
          a1(indx) := t(ddindx).chr_contract_number;
          a2(indx) := t(ddindx).chr_description;
          a3(indx) := t(ddindx).vers_version;
          a4(indx) := t(ddindx).chr_sts_code;
          a5(indx) := t(ddindx).chr_start_date;
          a6(indx) := t(ddindx).chr_end_date;
          a7(indx) := t(ddindx).khr_term_duration;
          a8(indx) := t(ddindx).chr_cust_po_number;
          a9(indx) := t(ddindx).chr_inv_organization_id;
          a10(indx) := t(ddindx).chr_authoring_org_id;
          a11(indx) := t(ddindx).khr_generate_accrual_yn;
          a12(indx) := t(ddindx).khr_syndicatable_yn;
          a13(indx) := t(ddindx).khr_prefunding_eligible_yn;
          a14(indx) := t(ddindx).khr_revolving_credit_yn;
          a15(indx) := t(ddindx).khr_converted_account_yn;
          a16(indx) := t(ddindx).khr_credit_act_yn;
          a17(indx) := t(ddindx).chr_template_yn;
          a18(indx) := t(ddindx).chr_date_signed;
          a19(indx) := t(ddindx).khr_date_deal_transferred;
          a20(indx) := t(ddindx).khr_accepted_date;
          a21(indx) := t(ddindx).khr_expected_delivery_date;
          a22(indx) := t(ddindx).khr_amd_code;
          a23(indx) := t(ddindx).khr_deal_type;
          a24(indx) := t(ddindx).mla_contract_number;
          a25(indx) := t(ddindx).mla_gvr_chr_id_referred;
          a26(indx) := t(ddindx).mla_gvr_id;
          a27(indx) := t(ddindx).cust_id;
          a28(indx) := t(ddindx).cust_object1_id1;
          a29(indx) := t(ddindx).cust_object1_id2;
          a30(indx) := t(ddindx).cust_jtot_object1_code;
          a31(indx) := t(ddindx).cust_name;
          a32(indx) := t(ddindx).lessor_id;
          a33(indx) := t(ddindx).lessor_object1_id1;
          a34(indx) := t(ddindx).lessor_object1_id2;
          a35(indx) := t(ddindx).lessor_jtot_object1_code;
          a36(indx) := t(ddindx).lessor_name;
          a37(indx) := t(ddindx).chr_currency_code;
          a38(indx) := t(ddindx).currency_name;
          a39(indx) := t(ddindx).khr_pdt_id;
          a40(indx) := t(ddindx).product_name;
          a41(indx) := t(ddindx).product_description;
          a42(indx) := t(ddindx).khr_khr_id;
          a43(indx) := t(ddindx).program_contract_number;
          a44(indx) := t(ddindx).cl_contract_number;
          a45(indx) := t(ddindx).cl_gvr_chr_id_referred;
          a46(indx) := t(ddindx).cl_gvr_id;
          a47(indx) := t(ddindx).rg_larles_id;
          a48(indx) := t(ddindx).r_larles_id;
          a49(indx) := t(ddindx).r_larles_rule_information1;
          a50(indx) := t(ddindx).col_larles_form_left_prompt;
          a51(indx) := t(ddindx).rg_larebl_id;
          a52(indx) := t(ddindx).r_larebl_id;
          a53(indx) := t(ddindx).r_larebl_rule_information1;
          a54(indx) := t(ddindx).col_larebl_form_left_prompt;
          a55(indx) := t(ddindx).chr_cust_acct_id;
          a56(indx) := t(ddindx).customer_account;
          a57(indx) := t(ddindx).cust_site_description;
          a58(indx) := t(ddindx).contact_id;
          a59(indx) := t(ddindx).contact_object1_id1;
          a60(indx) := t(ddindx).contact_object1_id2;
          a61(indx) := t(ddindx).contact_jtot_object1_code;
          a62(indx) := t(ddindx).contact_name;
          a63(indx) := t(ddindx).rg_latown_id;
          a64(indx) := t(ddindx).r_latown_id;
          a65(indx) := t(ddindx).r_latown_rule_information1;
          a66(indx) := t(ddindx).col_latown_form_left_prompt;
          a67(indx) := t(ddindx).rg_lanntf_id;
          a68(indx) := t(ddindx).r_lanntf_id;
          a69(indx) := t(ddindx).r_lanntf_rule_information1;
          a70(indx) := t(ddindx).col_lanntf_form_left_prompt;
          a71(indx) := t(ddindx).rg_lacpln_id;
          a72(indx) := t(ddindx).r_lacpln_id;
          a73(indx) := t(ddindx).r_lacpln_rule_information1;
          a74(indx) := t(ddindx).col_lacpln_form_left_prompt;
          a75(indx) := t(ddindx).rg_lapact_id;
          a76(indx) := t(ddindx).r_lapact_id;
          a77(indx) := t(ddindx).r_lapact_rule_information1;
          a78(indx) := t(ddindx).col_lapact_form_left_prompt;
          a79(indx) := t(ddindx).khr_currency_conv_type;
          a80(indx) := t(ddindx).khr_currency_conv_rate;
          a81(indx) := t(ddindx).khr_currency_conv_date;
          a82(indx) := t(ddindx).khr_assignable_yn;
          a83(indx) := t(ddindx).legal_entity_id;
          a84(indx) := t(ddindx).attribute_category;
          a85(indx) := t(ddindx).attribute1;
          a86(indx) := t(ddindx).attribute2;
          a87(indx) := t(ddindx).attribute3;
          a88(indx) := t(ddindx).attribute4;
          a89(indx) := t(ddindx).attribute5;
          a90(indx) := t(ddindx).attribute6;
          a91(indx) := t(ddindx).attribute7;
          a92(indx) := t(ddindx).attribute8;
          a93(indx) := t(ddindx).attribute9;
          a94(indx) := t(ddindx).attribute10;
          a95(indx) := t(ddindx).attribute11;
          a96(indx) := t(ddindx).attribute12;
          a97(indx) := t(ddindx).attribute13;
          a98(indx) := t(ddindx).attribute14;
          a99(indx) := t(ddindx).attribute15;
          a100(indx) := t(ddindx).labill_labacc_billto;
          a101(indx) := t(ddindx).labill_labacc_rgp_id;
          a102(indx) := t(ddindx).labill_labacc_rgd_code;
          a103(indx) := t(ddindx).labill_labacc_rul_id;
          a104(indx) := t(ddindx).labill_labacc_rul_info_cat;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure update_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  DATE
    , p5_a19  DATE
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  NUMBER
    , p5_a52  NUMBER
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  NUMBER
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  NUMBER
    , p5_a64  NUMBER
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  NUMBER
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  NUMBER
    , p5_a72  NUMBER
    , p5_a73  VARCHAR2
    , p5_a74  VARCHAR2
    , p5_a75  NUMBER
    , p5_a76  NUMBER
    , p5_a77  VARCHAR2
    , p5_a78  VARCHAR2
    , p5_a79  VARCHAR2
    , p5_a80  NUMBER
    , p5_a81  DATE
    , p5_a82  VARCHAR2
    , p5_a83  NUMBER
    , p5_a84  VARCHAR2
    , p5_a85  VARCHAR2
    , p5_a86  VARCHAR2
    , p5_a87  VARCHAR2
    , p5_a88  VARCHAR2
    , p5_a89  VARCHAR2
    , p5_a90  VARCHAR2
    , p5_a91  VARCHAR2
    , p5_a92  VARCHAR2
    , p5_a93  VARCHAR2
    , p5_a94  VARCHAR2
    , p5_a95  VARCHAR2
    , p5_a96  VARCHAR2
    , p5_a97  VARCHAR2
    , p5_a98  VARCHAR2
    , p5_a99  VARCHAR2
    , p5_a100  NUMBER
    , p5_a101  NUMBER
    , p5_a102  VARCHAR2
    , p5_a103  NUMBER
    , p5_a104  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  VARCHAR2
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  NUMBER
    , p6_a101 out nocopy  NUMBER
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  NUMBER
    , p6_a104 out nocopy  VARCHAR2
  )

  as
    ddp_durv_rec okl_deal_creat_pvt.deal_rec_type;
    ddx_durv_rec okl_deal_creat_pvt.deal_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_durv_rec.chr_id := p5_a0;
    ddp_durv_rec.chr_contract_number := p5_a1;
    ddp_durv_rec.chr_description := p5_a2;
    ddp_durv_rec.vers_version := p5_a3;
    ddp_durv_rec.chr_sts_code := p5_a4;
    ddp_durv_rec.chr_start_date := p5_a5;
    ddp_durv_rec.chr_end_date := p5_a6;
    ddp_durv_rec.khr_term_duration := p5_a7;
    ddp_durv_rec.chr_cust_po_number := p5_a8;
    ddp_durv_rec.chr_inv_organization_id := p5_a9;
    ddp_durv_rec.chr_authoring_org_id := p5_a10;
    ddp_durv_rec.khr_generate_accrual_yn := p5_a11;
    ddp_durv_rec.khr_syndicatable_yn := p5_a12;
    ddp_durv_rec.khr_prefunding_eligible_yn := p5_a13;
    ddp_durv_rec.khr_revolving_credit_yn := p5_a14;
    ddp_durv_rec.khr_converted_account_yn := p5_a15;
    ddp_durv_rec.khr_credit_act_yn := p5_a16;
    ddp_durv_rec.chr_template_yn := p5_a17;
    ddp_durv_rec.chr_date_signed := p5_a18;
    ddp_durv_rec.khr_date_deal_transferred := p5_a19;
    ddp_durv_rec.khr_accepted_date := p5_a20;
    ddp_durv_rec.khr_expected_delivery_date := p5_a21;
    ddp_durv_rec.khr_amd_code := p5_a22;
    ddp_durv_rec.khr_deal_type := p5_a23;
    ddp_durv_rec.mla_contract_number := p5_a24;
    ddp_durv_rec.mla_gvr_chr_id_referred := p5_a25;
    ddp_durv_rec.mla_gvr_id := p5_a26;
    ddp_durv_rec.cust_id := p5_a27;
    ddp_durv_rec.cust_object1_id1 := p5_a28;
    ddp_durv_rec.cust_object1_id2 := p5_a29;
    ddp_durv_rec.cust_jtot_object1_code := p5_a30;
    ddp_durv_rec.cust_name := p5_a31;
    ddp_durv_rec.lessor_id := p5_a32;
    ddp_durv_rec.lessor_object1_id1 := p5_a33;
    ddp_durv_rec.lessor_object1_id2 := p5_a34;
    ddp_durv_rec.lessor_jtot_object1_code := p5_a35;
    ddp_durv_rec.lessor_name := p5_a36;
    ddp_durv_rec.chr_currency_code := p5_a37;
    ddp_durv_rec.currency_name := p5_a38;
    ddp_durv_rec.khr_pdt_id := p5_a39;
    ddp_durv_rec.product_name := p5_a40;
    ddp_durv_rec.product_description := p5_a41;
    ddp_durv_rec.khr_khr_id := p5_a42;
    ddp_durv_rec.program_contract_number := p5_a43;
    ddp_durv_rec.cl_contract_number := p5_a44;
    ddp_durv_rec.cl_gvr_chr_id_referred := p5_a45;
    ddp_durv_rec.cl_gvr_id := p5_a46;
    ddp_durv_rec.rg_larles_id := p5_a47;
    ddp_durv_rec.r_larles_id := p5_a48;
    ddp_durv_rec.r_larles_rule_information1 := p5_a49;
    ddp_durv_rec.col_larles_form_left_prompt := p5_a50;
    ddp_durv_rec.rg_larebl_id := p5_a51;
    ddp_durv_rec.r_larebl_id := p5_a52;
    ddp_durv_rec.r_larebl_rule_information1 := p5_a53;
    ddp_durv_rec.col_larebl_form_left_prompt := p5_a54;
    ddp_durv_rec.chr_cust_acct_id := p5_a55;
    ddp_durv_rec.customer_account := p5_a56;
    ddp_durv_rec.cust_site_description := p5_a57;
    ddp_durv_rec.contact_id := p5_a58;
    ddp_durv_rec.contact_object1_id1 := p5_a59;
    ddp_durv_rec.contact_object1_id2 := p5_a60;
    ddp_durv_rec.contact_jtot_object1_code := p5_a61;
    ddp_durv_rec.contact_name := p5_a62;
    ddp_durv_rec.rg_latown_id := p5_a63;
    ddp_durv_rec.r_latown_id := p5_a64;
    ddp_durv_rec.r_latown_rule_information1 := p5_a65;
    ddp_durv_rec.col_latown_form_left_prompt := p5_a66;
    ddp_durv_rec.rg_lanntf_id := p5_a67;
    ddp_durv_rec.r_lanntf_id := p5_a68;
    ddp_durv_rec.r_lanntf_rule_information1 := p5_a69;
    ddp_durv_rec.col_lanntf_form_left_prompt := p5_a70;
    ddp_durv_rec.rg_lacpln_id := p5_a71;
    ddp_durv_rec.r_lacpln_id := p5_a72;
    ddp_durv_rec.r_lacpln_rule_information1 := p5_a73;
    ddp_durv_rec.col_lacpln_form_left_prompt := p5_a74;
    ddp_durv_rec.rg_lapact_id := p5_a75;
    ddp_durv_rec.r_lapact_id := p5_a76;
    ddp_durv_rec.r_lapact_rule_information1 := p5_a77;
    ddp_durv_rec.col_lapact_form_left_prompt := p5_a78;
    ddp_durv_rec.khr_currency_conv_type := p5_a79;
    ddp_durv_rec.khr_currency_conv_rate := p5_a80;
    ddp_durv_rec.khr_currency_conv_date := p5_a81;
    ddp_durv_rec.khr_assignable_yn := p5_a82;
    ddp_durv_rec.legal_entity_id := p5_a83;
    ddp_durv_rec.attribute_category := p5_a84;
    ddp_durv_rec.attribute1 := p5_a85;
    ddp_durv_rec.attribute2 := p5_a86;
    ddp_durv_rec.attribute3 := p5_a87;
    ddp_durv_rec.attribute4 := p5_a88;
    ddp_durv_rec.attribute5 := p5_a89;
    ddp_durv_rec.attribute6 := p5_a90;
    ddp_durv_rec.attribute7 := p5_a91;
    ddp_durv_rec.attribute8 := p5_a92;
    ddp_durv_rec.attribute9 := p5_a93;
    ddp_durv_rec.attribute10 := p5_a94;
    ddp_durv_rec.attribute11 := p5_a95;
    ddp_durv_rec.attribute12 := p5_a96;
    ddp_durv_rec.attribute13 := p5_a97;
    ddp_durv_rec.attribute14 := p5_a98;
    ddp_durv_rec.attribute15 := p5_a99;
    ddp_durv_rec.labill_labacc_billto := p5_a100;
    ddp_durv_rec.labill_labacc_rgp_id := p5_a101;
    ddp_durv_rec.labill_labacc_rgd_code := p5_a102;
    ddp_durv_rec.labill_labacc_rul_id := p5_a103;
    ddp_durv_rec.labill_labacc_rul_info_cat := p5_a104;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.update_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_durv_rec,
      ddx_durv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_durv_rec.chr_id;
    p6_a1 := ddx_durv_rec.chr_contract_number;
    p6_a2 := ddx_durv_rec.chr_description;
    p6_a3 := ddx_durv_rec.vers_version;
    p6_a4 := ddx_durv_rec.chr_sts_code;
    p6_a5 := ddx_durv_rec.chr_start_date;
    p6_a6 := ddx_durv_rec.chr_end_date;
    p6_a7 := ddx_durv_rec.khr_term_duration;
    p6_a8 := ddx_durv_rec.chr_cust_po_number;
    p6_a9 := ddx_durv_rec.chr_inv_organization_id;
    p6_a10 := ddx_durv_rec.chr_authoring_org_id;
    p6_a11 := ddx_durv_rec.khr_generate_accrual_yn;
    p6_a12 := ddx_durv_rec.khr_syndicatable_yn;
    p6_a13 := ddx_durv_rec.khr_prefunding_eligible_yn;
    p6_a14 := ddx_durv_rec.khr_revolving_credit_yn;
    p6_a15 := ddx_durv_rec.khr_converted_account_yn;
    p6_a16 := ddx_durv_rec.khr_credit_act_yn;
    p6_a17 := ddx_durv_rec.chr_template_yn;
    p6_a18 := ddx_durv_rec.chr_date_signed;
    p6_a19 := ddx_durv_rec.khr_date_deal_transferred;
    p6_a20 := ddx_durv_rec.khr_accepted_date;
    p6_a21 := ddx_durv_rec.khr_expected_delivery_date;
    p6_a22 := ddx_durv_rec.khr_amd_code;
    p6_a23 := ddx_durv_rec.khr_deal_type;
    p6_a24 := ddx_durv_rec.mla_contract_number;
    p6_a25 := ddx_durv_rec.mla_gvr_chr_id_referred;
    p6_a26 := ddx_durv_rec.mla_gvr_id;
    p6_a27 := ddx_durv_rec.cust_id;
    p6_a28 := ddx_durv_rec.cust_object1_id1;
    p6_a29 := ddx_durv_rec.cust_object1_id2;
    p6_a30 := ddx_durv_rec.cust_jtot_object1_code;
    p6_a31 := ddx_durv_rec.cust_name;
    p6_a32 := ddx_durv_rec.lessor_id;
    p6_a33 := ddx_durv_rec.lessor_object1_id1;
    p6_a34 := ddx_durv_rec.lessor_object1_id2;
    p6_a35 := ddx_durv_rec.lessor_jtot_object1_code;
    p6_a36 := ddx_durv_rec.lessor_name;
    p6_a37 := ddx_durv_rec.chr_currency_code;
    p6_a38 := ddx_durv_rec.currency_name;
    p6_a39 := ddx_durv_rec.khr_pdt_id;
    p6_a40 := ddx_durv_rec.product_name;
    p6_a41 := ddx_durv_rec.product_description;
    p6_a42 := ddx_durv_rec.khr_khr_id;
    p6_a43 := ddx_durv_rec.program_contract_number;
    p6_a44 := ddx_durv_rec.cl_contract_number;
    p6_a45 := ddx_durv_rec.cl_gvr_chr_id_referred;
    p6_a46 := ddx_durv_rec.cl_gvr_id;
    p6_a47 := ddx_durv_rec.rg_larles_id;
    p6_a48 := ddx_durv_rec.r_larles_id;
    p6_a49 := ddx_durv_rec.r_larles_rule_information1;
    p6_a50 := ddx_durv_rec.col_larles_form_left_prompt;
    p6_a51 := ddx_durv_rec.rg_larebl_id;
    p6_a52 := ddx_durv_rec.r_larebl_id;
    p6_a53 := ddx_durv_rec.r_larebl_rule_information1;
    p6_a54 := ddx_durv_rec.col_larebl_form_left_prompt;
    p6_a55 := ddx_durv_rec.chr_cust_acct_id;
    p6_a56 := ddx_durv_rec.customer_account;
    p6_a57 := ddx_durv_rec.cust_site_description;
    p6_a58 := ddx_durv_rec.contact_id;
    p6_a59 := ddx_durv_rec.contact_object1_id1;
    p6_a60 := ddx_durv_rec.contact_object1_id2;
    p6_a61 := ddx_durv_rec.contact_jtot_object1_code;
    p6_a62 := ddx_durv_rec.contact_name;
    p6_a63 := ddx_durv_rec.rg_latown_id;
    p6_a64 := ddx_durv_rec.r_latown_id;
    p6_a65 := ddx_durv_rec.r_latown_rule_information1;
    p6_a66 := ddx_durv_rec.col_latown_form_left_prompt;
    p6_a67 := ddx_durv_rec.rg_lanntf_id;
    p6_a68 := ddx_durv_rec.r_lanntf_id;
    p6_a69 := ddx_durv_rec.r_lanntf_rule_information1;
    p6_a70 := ddx_durv_rec.col_lanntf_form_left_prompt;
    p6_a71 := ddx_durv_rec.rg_lacpln_id;
    p6_a72 := ddx_durv_rec.r_lacpln_id;
    p6_a73 := ddx_durv_rec.r_lacpln_rule_information1;
    p6_a74 := ddx_durv_rec.col_lacpln_form_left_prompt;
    p6_a75 := ddx_durv_rec.rg_lapact_id;
    p6_a76 := ddx_durv_rec.r_lapact_id;
    p6_a77 := ddx_durv_rec.r_lapact_rule_information1;
    p6_a78 := ddx_durv_rec.col_lapact_form_left_prompt;
    p6_a79 := ddx_durv_rec.khr_currency_conv_type;
    p6_a80 := ddx_durv_rec.khr_currency_conv_rate;
    p6_a81 := ddx_durv_rec.khr_currency_conv_date;
    p6_a82 := ddx_durv_rec.khr_assignable_yn;
    p6_a83 := ddx_durv_rec.legal_entity_id;
    p6_a84 := ddx_durv_rec.attribute_category;
    p6_a85 := ddx_durv_rec.attribute1;
    p6_a86 := ddx_durv_rec.attribute2;
    p6_a87 := ddx_durv_rec.attribute3;
    p6_a88 := ddx_durv_rec.attribute4;
    p6_a89 := ddx_durv_rec.attribute5;
    p6_a90 := ddx_durv_rec.attribute6;
    p6_a91 := ddx_durv_rec.attribute7;
    p6_a92 := ddx_durv_rec.attribute8;
    p6_a93 := ddx_durv_rec.attribute9;
    p6_a94 := ddx_durv_rec.attribute10;
    p6_a95 := ddx_durv_rec.attribute11;
    p6_a96 := ddx_durv_rec.attribute12;
    p6_a97 := ddx_durv_rec.attribute13;
    p6_a98 := ddx_durv_rec.attribute14;
    p6_a99 := ddx_durv_rec.attribute15;
    p6_a100 := ddx_durv_rec.labill_labacc_billto;
    p6_a101 := ddx_durv_rec.labill_labacc_rgp_id;
    p6_a102 := ddx_durv_rec.labill_labacc_rgd_code;
    p6_a103 := ddx_durv_rec.labill_labacc_rul_id;
    p6_a104 := ddx_durv_rec.labill_labacc_rul_info_cat;
  end;

  procedure load_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  DATE
    , p5_a19  DATE
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  NUMBER
    , p5_a52  NUMBER
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  NUMBER
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  NUMBER
    , p5_a64  NUMBER
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  NUMBER
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  NUMBER
    , p5_a72  NUMBER
    , p5_a73  VARCHAR2
    , p5_a74  VARCHAR2
    , p5_a75  NUMBER
    , p5_a76  NUMBER
    , p5_a77  VARCHAR2
    , p5_a78  VARCHAR2
    , p5_a79  VARCHAR2
    , p5_a80  NUMBER
    , p5_a81  DATE
    , p5_a82  VARCHAR2
    , p5_a83  NUMBER
    , p5_a84  VARCHAR2
    , p5_a85  VARCHAR2
    , p5_a86  VARCHAR2
    , p5_a87  VARCHAR2
    , p5_a88  VARCHAR2
    , p5_a89  VARCHAR2
    , p5_a90  VARCHAR2
    , p5_a91  VARCHAR2
    , p5_a92  VARCHAR2
    , p5_a93  VARCHAR2
    , p5_a94  VARCHAR2
    , p5_a95  VARCHAR2
    , p5_a96  VARCHAR2
    , p5_a97  VARCHAR2
    , p5_a98  VARCHAR2
    , p5_a99  VARCHAR2
    , p5_a100  NUMBER
    , p5_a101  NUMBER
    , p5_a102  VARCHAR2
    , p5_a103  NUMBER
    , p5_a104  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  VARCHAR2
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  NUMBER
    , p6_a101 out nocopy  NUMBER
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  NUMBER
    , p6_a104 out nocopy  VARCHAR2
  )

  as
    ddp_durv_rec okl_deal_creat_pvt.deal_rec_type;
    ddx_durv_rec okl_deal_creat_pvt.deal_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_durv_rec.chr_id := p5_a0;
    ddp_durv_rec.chr_contract_number := p5_a1;
    ddp_durv_rec.chr_description := p5_a2;
    ddp_durv_rec.vers_version := p5_a3;
    ddp_durv_rec.chr_sts_code := p5_a4;
    ddp_durv_rec.chr_start_date := p5_a5;
    ddp_durv_rec.chr_end_date := p5_a6;
    ddp_durv_rec.khr_term_duration := p5_a7;
    ddp_durv_rec.chr_cust_po_number := p5_a8;
    ddp_durv_rec.chr_inv_organization_id := p5_a9;
    ddp_durv_rec.chr_authoring_org_id := p5_a10;
    ddp_durv_rec.khr_generate_accrual_yn := p5_a11;
    ddp_durv_rec.khr_syndicatable_yn := p5_a12;
    ddp_durv_rec.khr_prefunding_eligible_yn := p5_a13;
    ddp_durv_rec.khr_revolving_credit_yn := p5_a14;
    ddp_durv_rec.khr_converted_account_yn := p5_a15;
    ddp_durv_rec.khr_credit_act_yn := p5_a16;
    ddp_durv_rec.chr_template_yn := p5_a17;
    ddp_durv_rec.chr_date_signed := p5_a18;
    ddp_durv_rec.khr_date_deal_transferred := p5_a19;
    ddp_durv_rec.khr_accepted_date := p5_a20;
    ddp_durv_rec.khr_expected_delivery_date := p5_a21;
    ddp_durv_rec.khr_amd_code := p5_a22;
    ddp_durv_rec.khr_deal_type := p5_a23;
    ddp_durv_rec.mla_contract_number := p5_a24;
    ddp_durv_rec.mla_gvr_chr_id_referred := p5_a25;
    ddp_durv_rec.mla_gvr_id := p5_a26;
    ddp_durv_rec.cust_id := p5_a27;
    ddp_durv_rec.cust_object1_id1 := p5_a28;
    ddp_durv_rec.cust_object1_id2 := p5_a29;
    ddp_durv_rec.cust_jtot_object1_code := p5_a30;
    ddp_durv_rec.cust_name := p5_a31;
    ddp_durv_rec.lessor_id := p5_a32;
    ddp_durv_rec.lessor_object1_id1 := p5_a33;
    ddp_durv_rec.lessor_object1_id2 := p5_a34;
    ddp_durv_rec.lessor_jtot_object1_code := p5_a35;
    ddp_durv_rec.lessor_name := p5_a36;
    ddp_durv_rec.chr_currency_code := p5_a37;
    ddp_durv_rec.currency_name := p5_a38;
    ddp_durv_rec.khr_pdt_id := p5_a39;
    ddp_durv_rec.product_name := p5_a40;
    ddp_durv_rec.product_description := p5_a41;
    ddp_durv_rec.khr_khr_id := p5_a42;
    ddp_durv_rec.program_contract_number := p5_a43;
    ddp_durv_rec.cl_contract_number := p5_a44;
    ddp_durv_rec.cl_gvr_chr_id_referred := p5_a45;
    ddp_durv_rec.cl_gvr_id := p5_a46;
    ddp_durv_rec.rg_larles_id := p5_a47;
    ddp_durv_rec.r_larles_id := p5_a48;
    ddp_durv_rec.r_larles_rule_information1 := p5_a49;
    ddp_durv_rec.col_larles_form_left_prompt := p5_a50;
    ddp_durv_rec.rg_larebl_id := p5_a51;
    ddp_durv_rec.r_larebl_id := p5_a52;
    ddp_durv_rec.r_larebl_rule_information1 := p5_a53;
    ddp_durv_rec.col_larebl_form_left_prompt := p5_a54;
    ddp_durv_rec.chr_cust_acct_id := p5_a55;
    ddp_durv_rec.customer_account := p5_a56;
    ddp_durv_rec.cust_site_description := p5_a57;
    ddp_durv_rec.contact_id := p5_a58;
    ddp_durv_rec.contact_object1_id1 := p5_a59;
    ddp_durv_rec.contact_object1_id2 := p5_a60;
    ddp_durv_rec.contact_jtot_object1_code := p5_a61;
    ddp_durv_rec.contact_name := p5_a62;
    ddp_durv_rec.rg_latown_id := p5_a63;
    ddp_durv_rec.r_latown_id := p5_a64;
    ddp_durv_rec.r_latown_rule_information1 := p5_a65;
    ddp_durv_rec.col_latown_form_left_prompt := p5_a66;
    ddp_durv_rec.rg_lanntf_id := p5_a67;
    ddp_durv_rec.r_lanntf_id := p5_a68;
    ddp_durv_rec.r_lanntf_rule_information1 := p5_a69;
    ddp_durv_rec.col_lanntf_form_left_prompt := p5_a70;
    ddp_durv_rec.rg_lacpln_id := p5_a71;
    ddp_durv_rec.r_lacpln_id := p5_a72;
    ddp_durv_rec.r_lacpln_rule_information1 := p5_a73;
    ddp_durv_rec.col_lacpln_form_left_prompt := p5_a74;
    ddp_durv_rec.rg_lapact_id := p5_a75;
    ddp_durv_rec.r_lapact_id := p5_a76;
    ddp_durv_rec.r_lapact_rule_information1 := p5_a77;
    ddp_durv_rec.col_lapact_form_left_prompt := p5_a78;
    ddp_durv_rec.khr_currency_conv_type := p5_a79;
    ddp_durv_rec.khr_currency_conv_rate := p5_a80;
    ddp_durv_rec.khr_currency_conv_date := p5_a81;
    ddp_durv_rec.khr_assignable_yn := p5_a82;
    ddp_durv_rec.legal_entity_id := p5_a83;
    ddp_durv_rec.attribute_category := p5_a84;
    ddp_durv_rec.attribute1 := p5_a85;
    ddp_durv_rec.attribute2 := p5_a86;
    ddp_durv_rec.attribute3 := p5_a87;
    ddp_durv_rec.attribute4 := p5_a88;
    ddp_durv_rec.attribute5 := p5_a89;
    ddp_durv_rec.attribute6 := p5_a90;
    ddp_durv_rec.attribute7 := p5_a91;
    ddp_durv_rec.attribute8 := p5_a92;
    ddp_durv_rec.attribute9 := p5_a93;
    ddp_durv_rec.attribute10 := p5_a94;
    ddp_durv_rec.attribute11 := p5_a95;
    ddp_durv_rec.attribute12 := p5_a96;
    ddp_durv_rec.attribute13 := p5_a97;
    ddp_durv_rec.attribute14 := p5_a98;
    ddp_durv_rec.attribute15 := p5_a99;
    ddp_durv_rec.labill_labacc_billto := p5_a100;
    ddp_durv_rec.labill_labacc_rgp_id := p5_a101;
    ddp_durv_rec.labill_labacc_rgd_code := p5_a102;
    ddp_durv_rec.labill_labacc_rul_id := p5_a103;
    ddp_durv_rec.labill_labacc_rul_info_cat := p5_a104;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.load_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_durv_rec,
      ddx_durv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_durv_rec.chr_id;
    p6_a1 := ddx_durv_rec.chr_contract_number;
    p6_a2 := ddx_durv_rec.chr_description;
    p6_a3 := ddx_durv_rec.vers_version;
    p6_a4 := ddx_durv_rec.chr_sts_code;
    p6_a5 := ddx_durv_rec.chr_start_date;
    p6_a6 := ddx_durv_rec.chr_end_date;
    p6_a7 := ddx_durv_rec.khr_term_duration;
    p6_a8 := ddx_durv_rec.chr_cust_po_number;
    p6_a9 := ddx_durv_rec.chr_inv_organization_id;
    p6_a10 := ddx_durv_rec.chr_authoring_org_id;
    p6_a11 := ddx_durv_rec.khr_generate_accrual_yn;
    p6_a12 := ddx_durv_rec.khr_syndicatable_yn;
    p6_a13 := ddx_durv_rec.khr_prefunding_eligible_yn;
    p6_a14 := ddx_durv_rec.khr_revolving_credit_yn;
    p6_a15 := ddx_durv_rec.khr_converted_account_yn;
    p6_a16 := ddx_durv_rec.khr_credit_act_yn;
    p6_a17 := ddx_durv_rec.chr_template_yn;
    p6_a18 := ddx_durv_rec.chr_date_signed;
    p6_a19 := ddx_durv_rec.khr_date_deal_transferred;
    p6_a20 := ddx_durv_rec.khr_accepted_date;
    p6_a21 := ddx_durv_rec.khr_expected_delivery_date;
    p6_a22 := ddx_durv_rec.khr_amd_code;
    p6_a23 := ddx_durv_rec.khr_deal_type;
    p6_a24 := ddx_durv_rec.mla_contract_number;
    p6_a25 := ddx_durv_rec.mla_gvr_chr_id_referred;
    p6_a26 := ddx_durv_rec.mla_gvr_id;
    p6_a27 := ddx_durv_rec.cust_id;
    p6_a28 := ddx_durv_rec.cust_object1_id1;
    p6_a29 := ddx_durv_rec.cust_object1_id2;
    p6_a30 := ddx_durv_rec.cust_jtot_object1_code;
    p6_a31 := ddx_durv_rec.cust_name;
    p6_a32 := ddx_durv_rec.lessor_id;
    p6_a33 := ddx_durv_rec.lessor_object1_id1;
    p6_a34 := ddx_durv_rec.lessor_object1_id2;
    p6_a35 := ddx_durv_rec.lessor_jtot_object1_code;
    p6_a36 := ddx_durv_rec.lessor_name;
    p6_a37 := ddx_durv_rec.chr_currency_code;
    p6_a38 := ddx_durv_rec.currency_name;
    p6_a39 := ddx_durv_rec.khr_pdt_id;
    p6_a40 := ddx_durv_rec.product_name;
    p6_a41 := ddx_durv_rec.product_description;
    p6_a42 := ddx_durv_rec.khr_khr_id;
    p6_a43 := ddx_durv_rec.program_contract_number;
    p6_a44 := ddx_durv_rec.cl_contract_number;
    p6_a45 := ddx_durv_rec.cl_gvr_chr_id_referred;
    p6_a46 := ddx_durv_rec.cl_gvr_id;
    p6_a47 := ddx_durv_rec.rg_larles_id;
    p6_a48 := ddx_durv_rec.r_larles_id;
    p6_a49 := ddx_durv_rec.r_larles_rule_information1;
    p6_a50 := ddx_durv_rec.col_larles_form_left_prompt;
    p6_a51 := ddx_durv_rec.rg_larebl_id;
    p6_a52 := ddx_durv_rec.r_larebl_id;
    p6_a53 := ddx_durv_rec.r_larebl_rule_information1;
    p6_a54 := ddx_durv_rec.col_larebl_form_left_prompt;
    p6_a55 := ddx_durv_rec.chr_cust_acct_id;
    p6_a56 := ddx_durv_rec.customer_account;
    p6_a57 := ddx_durv_rec.cust_site_description;
    p6_a58 := ddx_durv_rec.contact_id;
    p6_a59 := ddx_durv_rec.contact_object1_id1;
    p6_a60 := ddx_durv_rec.contact_object1_id2;
    p6_a61 := ddx_durv_rec.contact_jtot_object1_code;
    p6_a62 := ddx_durv_rec.contact_name;
    p6_a63 := ddx_durv_rec.rg_latown_id;
    p6_a64 := ddx_durv_rec.r_latown_id;
    p6_a65 := ddx_durv_rec.r_latown_rule_information1;
    p6_a66 := ddx_durv_rec.col_latown_form_left_prompt;
    p6_a67 := ddx_durv_rec.rg_lanntf_id;
    p6_a68 := ddx_durv_rec.r_lanntf_id;
    p6_a69 := ddx_durv_rec.r_lanntf_rule_information1;
    p6_a70 := ddx_durv_rec.col_lanntf_form_left_prompt;
    p6_a71 := ddx_durv_rec.rg_lacpln_id;
    p6_a72 := ddx_durv_rec.r_lacpln_id;
    p6_a73 := ddx_durv_rec.r_lacpln_rule_information1;
    p6_a74 := ddx_durv_rec.col_lacpln_form_left_prompt;
    p6_a75 := ddx_durv_rec.rg_lapact_id;
    p6_a76 := ddx_durv_rec.r_lapact_id;
    p6_a77 := ddx_durv_rec.r_lapact_rule_information1;
    p6_a78 := ddx_durv_rec.col_lapact_form_left_prompt;
    p6_a79 := ddx_durv_rec.khr_currency_conv_type;
    p6_a80 := ddx_durv_rec.khr_currency_conv_rate;
    p6_a81 := ddx_durv_rec.khr_currency_conv_date;
    p6_a82 := ddx_durv_rec.khr_assignable_yn;
    p6_a83 := ddx_durv_rec.legal_entity_id;
    p6_a84 := ddx_durv_rec.attribute_category;
    p6_a85 := ddx_durv_rec.attribute1;
    p6_a86 := ddx_durv_rec.attribute2;
    p6_a87 := ddx_durv_rec.attribute3;
    p6_a88 := ddx_durv_rec.attribute4;
    p6_a89 := ddx_durv_rec.attribute5;
    p6_a90 := ddx_durv_rec.attribute6;
    p6_a91 := ddx_durv_rec.attribute7;
    p6_a92 := ddx_durv_rec.attribute8;
    p6_a93 := ddx_durv_rec.attribute9;
    p6_a94 := ddx_durv_rec.attribute10;
    p6_a95 := ddx_durv_rec.attribute11;
    p6_a96 := ddx_durv_rec.attribute12;
    p6_a97 := ddx_durv_rec.attribute13;
    p6_a98 := ddx_durv_rec.attribute14;
    p6_a99 := ddx_durv_rec.attribute15;
    p6_a100 := ddx_durv_rec.labill_labacc_billto;
    p6_a101 := ddx_durv_rec.labill_labacc_rgp_id;
    p6_a102 := ddx_durv_rec.labill_labacc_rgd_code;
    p6_a103 := ddx_durv_rec.labill_labacc_rul_id;
    p6_a104 := ddx_durv_rec.labill_labacc_rul_info_cat;
  end;

  procedure create_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
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
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
  )

  as
    ddp_kpl_rec okl_deal_creat_pvt.party_rec_type;
    ddx_kpl_rec okl_deal_creat_pvt.party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_kpl_rec.id := p5_a0;
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
    ddp_kpl_rec.chr_id := p5_a21;
    ddp_kpl_rec.dnz_chr_id := p5_a22;
    ddp_kpl_rec.cle_id := p5_a23;
    ddp_kpl_rec.cognomen := p5_a24;
    ddp_kpl_rec.alias := p5_a25;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.create_party(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_kpl_rec,
      ddx_kpl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_kpl_rec.id;
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
    p6_a21 := ddx_kpl_rec.chr_id;
    p6_a22 := ddx_kpl_rec.dnz_chr_id;
    p6_a23 := ddx_kpl_rec.cle_id;
    p6_a24 := ddx_kpl_rec.cognomen;
    p6_a25 := ddx_kpl_rec.alias;
  end;

  procedure update_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
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
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
  )

  as
    ddp_kpl_rec okl_deal_creat_pvt.party_rec_type;
    ddx_kpl_rec okl_deal_creat_pvt.party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_kpl_rec.id := p5_a0;
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
    ddp_kpl_rec.chr_id := p5_a21;
    ddp_kpl_rec.dnz_chr_id := p5_a22;
    ddp_kpl_rec.cle_id := p5_a23;
    ddp_kpl_rec.cognomen := p5_a24;
    ddp_kpl_rec.alias := p5_a25;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.update_party(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_kpl_rec,
      ddx_kpl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_kpl_rec.id;
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
    p6_a21 := ddx_kpl_rec.chr_id;
    p6_a22 := ddx_kpl_rec.dnz_chr_id;
    p6_a23 := ddx_kpl_rec.cle_id;
    p6_a24 := ddx_kpl_rec.cognomen;
    p6_a25 := ddx_kpl_rec.alias;
  end;

  procedure load_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
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
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
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
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  NUMBER
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  VARCHAR2
    , p6_a101 out nocopy  VARCHAR2
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  VARCHAR2
    , p6_a104 out nocopy  VARCHAR2
    , p6_a105 out nocopy  VARCHAR2
    , p6_a106 out nocopy  NUMBER
    , p6_a107 out nocopy  VARCHAR2
    , p6_a108 out nocopy  VARCHAR2
    , p6_a109 out nocopy  VARCHAR2
    , p6_a110 out nocopy  VARCHAR2
    , p6_a111 out nocopy  VARCHAR2
    , p6_a112 out nocopy  VARCHAR2
    , p6_a113 out nocopy  VARCHAR2
    , p6_a114 out nocopy  VARCHAR2
    , p6_a115 out nocopy  NUMBER
    , p6_a116 out nocopy  DATE
  )

  as
    ddx_deal_values_rec okl_deal_creat_pvt.deal_values_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.load_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_deal_values_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_deal_values_rec.acceptance_method_meaning;
    p6_a1 := ddx_deal_values_rec.assignable_meaning;
    p6_a2 := ddx_deal_values_rec.bill_to_address_desc;
    p6_a3 := ddx_deal_values_rec.bill_to_site_use_id;
    p6_a4 := ddx_deal_values_rec.book_class_meaning;
    p6_a5 := ddx_deal_values_rec.cap_interim_interst_meaning;
    p6_a6 := ddx_deal_values_rec.cap_interim_int_rgd_code;
    p6_a7 := ddx_deal_values_rec.cap_interim_int_rgp_id;
    p6_a8 := ddx_deal_values_rec.cap_interim_int_rul_id;
    p6_a9 := ddx_deal_values_rec.cap_interim_int_rul_inf1;
    p6_a10 := ddx_deal_values_rec.cap_interim_int_rul_inf_cat;
    p6_a11 := ddx_deal_values_rec.col_lacpln_form_left_prompt;
    p6_a12 := ddx_deal_values_rec.col_lanntf_form_left_prompt;
    p6_a13 := ddx_deal_values_rec.col_lapact_form_left_prompt;
    p6_a14 := ddx_deal_values_rec.col_larebl_form_left_prompt;
    p6_a15 := ddx_deal_values_rec.col_larles_form_left_prompt;
    p6_a16 := ddx_deal_values_rec.col_latown_form_left_prompt;
    p6_a17 := ddx_deal_values_rec.consumer_credit_act_meaning;
    p6_a18 := ddx_deal_values_rec.converted_acct_meaning;
    p6_a19 := ddx_deal_values_rec.credit_gvr_id;
    p6_a20 := ddx_deal_values_rec.credit_line_chr_id;
    p6_a21 := ddx_deal_values_rec.credit_line_contract_number;
    p6_a22 := ddx_deal_values_rec.currency_conv_type_meaning;
    p6_a23 := ddx_deal_values_rec.customer_account;
    p6_a24 := ddx_deal_values_rec.customer_cpl_id;
    p6_a25 := ddx_deal_values_rec.customer_jtot_object1_code;
    p6_a26 := ddx_deal_values_rec.customer_name;
    p6_a27 := ddx_deal_values_rec.customer_object1_id1;
    p6_a28 := ddx_deal_values_rec.customer_object1_id2;
    p6_a29 := ddx_deal_values_rec.cust_acct_id;
    p6_a30 := ddx_deal_values_rec.cust_po_number;
    p6_a31 := ddx_deal_values_rec.deal_type;
    p6_a32 := ddx_deal_values_rec.description;
    p6_a33 := ddx_deal_values_rec.elig_for_prefunding_meaning;
    p6_a34 := ddx_deal_values_rec.id;
    p6_a35 := ddx_deal_values_rec.interest_calc_meaning;
    p6_a36 := ddx_deal_values_rec.lease_application_id;
    p6_a37 := ddx_deal_values_rec.lease_application_name;
    p6_a38 := ddx_deal_values_rec.ledger_id;
    p6_a39 := ddx_deal_values_rec.ledger_name;
    p6_a40 := ddx_deal_values_rec.legacy_number;
    p6_a41 := ddx_deal_values_rec.legal_address;
    p6_a42 := ddx_deal_values_rec.legal_address_id;
    p6_a43 := ddx_deal_values_rec.legal_entity_name;
    p6_a44 := ddx_deal_values_rec.lessor_insured_meaning;
    p6_a45 := ddx_deal_values_rec.lessor_payee_meaning;
    p6_a46 := ddx_deal_values_rec.lessor_serv_org_code;
    p6_a47 := ddx_deal_values_rec.mla_chr_id;
    p6_a48 := ddx_deal_values_rec.mla_contract_number;
    p6_a49 := ddx_deal_values_rec.mla_gvr_id;
    p6_a50 := ddx_deal_values_rec.nntf_rgd_code;
    p6_a51 := ddx_deal_values_rec.nntf_rgp_id;
    p6_a52 := ddx_deal_values_rec.nntf_rul_id;
    p6_a53 := ddx_deal_values_rec.nntf_rul_inf1;
    p6_a54 := ddx_deal_values_rec.nntf_rul_inf_cat;
    p6_a55 := ddx_deal_values_rec.non_notification_meaning;
    p6_a56 := ddx_deal_values_rec.operating_unit_name;
    p6_a57 := ddx_deal_values_rec.origination_lease_application;
    p6_a58 := ddx_deal_values_rec.origination_quote_id;
    p6_a59 := ddx_deal_values_rec.origination_quote_name;
    p6_a60 := ddx_deal_values_rec.orig_system_id1;
    p6_a61 := ddx_deal_values_rec.orig_system_reference1;
    p6_a62 := ddx_deal_values_rec.orig_system_source_code;
    p6_a63 := ddx_deal_values_rec.private_act_bond_meaning;
    p6_a64 := ddx_deal_values_rec.product_description;
    p6_a65 := ddx_deal_values_rec.product_name;
    p6_a66 := ddx_deal_values_rec.program_template_chr_id;
    p6_a67 := ddx_deal_values_rec.program_template_name;
    p6_a68 := ddx_deal_values_rec.prv_act_bond_rgd_code;
    p6_a69 := ddx_deal_values_rec.prv_act_bond_rgp_id;
    p6_a70 := ddx_deal_values_rec.prv_act_bond_rul_id;
    p6_a71 := ddx_deal_values_rec.prv_act_bond_rul_inf1;
    p6_a72 := ddx_deal_values_rec.prv_act_bond_rul_inf_cat;
    p6_a73 := ddx_deal_values_rec.rebook_limit_date;
    p6_a74 := ddx_deal_values_rec.rebook_limit_date_rgd_code;
    p6_a75 := ddx_deal_values_rec.rebook_limit_date_rgp_id;
    p6_a76 := ddx_deal_values_rec.rebook_limit_date_rul_id;
    p6_a77 := ddx_deal_values_rec.rebook_limit_rul_inf1;
    p6_a78 := ddx_deal_values_rec.rebook_limit_rul_inf_cat;
    p6_a79 := ddx_deal_values_rec.replaces_chr_id;
    p6_a80 := ddx_deal_values_rec.replaces_contract_number;
    p6_a81 := ddx_deal_values_rec.rep_contact_id;
    p6_a82 := ddx_deal_values_rec.rep_contact_jtot_object1_code;
    p6_a83 := ddx_deal_values_rec.rep_contact_object1_id1;
    p6_a84 := ddx_deal_values_rec.rep_contact_object1_id2;
    p6_a85 := ddx_deal_values_rec.revenue_recognition_meaning;
    p6_a86 := ddx_deal_values_rec.revolving_credit_yn;
    p6_a87 := ddx_deal_values_rec.rles_rgd_code;
    p6_a88 := ddx_deal_values_rec.rles_rgp_id;
    p6_a89 := ddx_deal_values_rec.rles_rul_id;
    p6_a90 := ddx_deal_values_rec.rles_rul_inf1;
    p6_a91 := ddx_deal_values_rec.rles_rul_inf_cat;
    p6_a92 := ddx_deal_values_rec.released_asset_meaning;
    p6_a93 := ddx_deal_values_rec.sales_representative_name;
    p6_a94 := ddx_deal_values_rec.scs_code_meaning;
    p6_a95 := ddx_deal_values_rec.split_from_chr_id;
    p6_a96 := ddx_deal_values_rec.split_from_contract_number;
    p6_a97 := ddx_deal_values_rec.sts_code_meaning;
    p6_a98 := ddx_deal_values_rec.tax_owner_code;
    p6_a99 := ddx_deal_values_rec.tax_owner_meaning;
    p6_a100 := ddx_deal_values_rec.tax_owner_rgd_code;
    p6_a101 := ddx_deal_values_rec.tax_owner_rgp_id;
    p6_a102 := ddx_deal_values_rec.tax_owner_rul_id;
    p6_a103 := ddx_deal_values_rec.tax_owner_rul_inf1;
    p6_a104 := ddx_deal_values_rec.tax_owner_rul_inf_cat;
    p6_a105 := ddx_deal_values_rec.upg_orig_system_ref;
    p6_a106 := ddx_deal_values_rec.upg_orig_system_ref_id;
    p6_a107 := ddx_deal_values_rec.vpa_contract_number;
    p6_a108 := ddx_deal_values_rec.vpa_khr_id;
    p6_a109 := ddx_deal_values_rec.vers_version;
    p6_a110 := ddx_deal_values_rec.product_subclass_code;
    p6_a111 := ddx_deal_values_rec.bill_to_rgp_id;
    p6_a112 := ddx_deal_values_rec.bill_to_rul_id;
    p6_a113 := ddx_deal_values_rec.bill_to_rgd_code;
    p6_a114 := ddx_deal_values_rec.bill_to_rul_inf_cat;
    p6_a115 := ddx_deal_values_rec.bill_to_rul_inf1;
    p6_a116 := ddx_deal_values_rec.last_activation_date;
  end;

  procedure load_booking_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
  )

  as
    ddx_booking_summary_rec okl_deal_creat_pvt.booking_summary_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_deal_creat_pvt.load_booking_summary(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_booking_summary_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_booking_summary_rec.dnz_chr_id;
    p6_a1 := ddx_booking_summary_rec.total_financed_amount;
    p6_a2 := ddx_booking_summary_rec.total_residual_amount;
    p6_a3 := ddx_booking_summary_rec.total_funded;
    p6_a4 := ddx_booking_summary_rec.total_subsidies;
    p6_a5 := ddx_booking_summary_rec.eot_option;
    p6_a6 := ddx_booking_summary_rec.eot_amount;
    p6_a7 := ddx_booking_summary_rec.total_upfront_sales_tax;
    p6_a8 := ddx_booking_summary_rec.rvi_premium;
  end;

end okl_deal_creat_pvt_w;

/
