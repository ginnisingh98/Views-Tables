--------------------------------------------------------
--  DDL for Package Body OKL_MLA_CREATE_UPDATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MLA_CREATE_UPDATE_PUB_W" as
 /* $Header: OKLEMCUB.pls 120.0 2006/11/22 12:15:18 zrehman noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p7(t out nocopy okl_mla_create_update_pub.deal_tab_type, a0 JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).chr_contract_number := a1(indx);
          t(ddindx).chr_description := a2(indx);
          t(ddindx).vers_version := a3(indx);
          t(ddindx).chr_sts_code := a4(indx);
          t(ddindx).chr_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).chr_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).khr_term_duration := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).chr_cust_po_number := a8(indx);
          t(ddindx).chr_inv_organization_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).chr_authoring_org_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).khr_generate_accrual_yn := a11(indx);
          t(ddindx).khr_syndicatable_yn := a12(indx);
          t(ddindx).khr_prefunding_eligible_yn := a13(indx);
          t(ddindx).khr_revolving_credit_yn := a14(indx);
          t(ddindx).khr_converted_account_yn := a15(indx);
          t(ddindx).khr_credit_act_yn := a16(indx);
          t(ddindx).chr_template_yn := a17(indx);
          t(ddindx).chr_date_signed := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).khr_date_deal_transferred := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).khr_accepted_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).khr_expected_delivery_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).khr_amd_code := a22(indx);
          t(ddindx).khr_deal_type := a23(indx);
          t(ddindx).mla_contract_number := a24(indx);
          t(ddindx).mla_gvr_chr_id_referred := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).mla_gvr_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).cust_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).cust_object1_id1 := a28(indx);
          t(ddindx).cust_object1_id2 := a29(indx);
          t(ddindx).cust_jtot_object1_code := a30(indx);
          t(ddindx).cust_name := a31(indx);
          t(ddindx).lessor_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).lessor_object1_id1 := a33(indx);
          t(ddindx).lessor_object1_id2 := a34(indx);
          t(ddindx).lessor_jtot_object1_code := a35(indx);
          t(ddindx).lessor_name := a36(indx);
          t(ddindx).chr_currency_code := a37(indx);
          t(ddindx).currency_name := a38(indx);
          t(ddindx).khr_pdt_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).product_name := a40(indx);
          t(ddindx).product_description := a41(indx);
          t(ddindx).khr_khr_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).program_contract_number := a43(indx);
          t(ddindx).cl_contract_number := a44(indx);
          t(ddindx).cl_gvr_chr_id_referred := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).cl_gvr_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).rg_larles_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).r_larles_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).r_larles_rule_information1 := a49(indx);
          t(ddindx).col_larles_form_left_prompt := a50(indx);
          t(ddindx).rg_larebl_id := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).r_larebl_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).r_larebl_rule_information1 := a53(indx);
          t(ddindx).col_larebl_form_left_prompt := a54(indx);
          t(ddindx).chr_cust_acct_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).customer_account := a56(indx);
          t(ddindx).cust_site_description := a57(indx);
          t(ddindx).contact_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).contact_object1_id1 := a59(indx);
          t(ddindx).contact_object1_id2 := a60(indx);
          t(ddindx).contact_jtot_object1_code := a61(indx);
          t(ddindx).contact_name := a62(indx);
          t(ddindx).rg_latown_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).r_latown_id := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).r_latown_rule_information1 := a65(indx);
          t(ddindx).col_latown_form_left_prompt := a66(indx);
          t(ddindx).rg_lanntf_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).r_lanntf_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).r_lanntf_rule_information1 := a69(indx);
          t(ddindx).col_lanntf_form_left_prompt := a70(indx);
          t(ddindx).rg_lacpln_id := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).r_lacpln_id := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).r_lacpln_rule_information1 := a73(indx);
          t(ddindx).col_lacpln_form_left_prompt := a74(indx);
          t(ddindx).rg_lapact_id := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).r_lapact_id := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).r_lapact_rule_information1 := a77(indx);
          t(ddindx).col_lapact_form_left_prompt := a78(indx);
          t(ddindx).khr_currency_conv_type := a79(indx);
          t(ddindx).khr_currency_conv_rate := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).khr_currency_conv_date := rosetta_g_miss_date_in_map(a81(indx));
          t(ddindx).khr_assignable_yn := a82(indx);
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a83(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_mla_create_update_pub.deal_tab_type, a0 out nocopy JTF_NUMBER_TABLE
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := t(ddindx).chr_contract_number;
          a2(indx) := t(ddindx).chr_description;
          a3(indx) := t(ddindx).vers_version;
          a4(indx) := t(ddindx).chr_sts_code;
          a5(indx) := t(ddindx).chr_start_date;
          a6(indx) := t(ddindx).chr_end_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).khr_term_duration);
          a8(indx) := t(ddindx).chr_cust_po_number;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).chr_inv_organization_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).chr_authoring_org_id);
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
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).mla_gvr_chr_id_referred);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).mla_gvr_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).cust_id);
          a28(indx) := t(ddindx).cust_object1_id1;
          a29(indx) := t(ddindx).cust_object1_id2;
          a30(indx) := t(ddindx).cust_jtot_object1_code;
          a31(indx) := t(ddindx).cust_name;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).lessor_id);
          a33(indx) := t(ddindx).lessor_object1_id1;
          a34(indx) := t(ddindx).lessor_object1_id2;
          a35(indx) := t(ddindx).lessor_jtot_object1_code;
          a36(indx) := t(ddindx).lessor_name;
          a37(indx) := t(ddindx).chr_currency_code;
          a38(indx) := t(ddindx).currency_name;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).khr_pdt_id);
          a40(indx) := t(ddindx).product_name;
          a41(indx) := t(ddindx).product_description;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).khr_khr_id);
          a43(indx) := t(ddindx).program_contract_number;
          a44(indx) := t(ddindx).cl_contract_number;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).cl_gvr_chr_id_referred);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).cl_gvr_id);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).rg_larles_id);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).r_larles_id);
          a49(indx) := t(ddindx).r_larles_rule_information1;
          a50(indx) := t(ddindx).col_larles_form_left_prompt;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).rg_larebl_id);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).r_larebl_id);
          a53(indx) := t(ddindx).r_larebl_rule_information1;
          a54(indx) := t(ddindx).col_larebl_form_left_prompt;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).chr_cust_acct_id);
          a56(indx) := t(ddindx).customer_account;
          a57(indx) := t(ddindx).cust_site_description;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a59(indx) := t(ddindx).contact_object1_id1;
          a60(indx) := t(ddindx).contact_object1_id2;
          a61(indx) := t(ddindx).contact_jtot_object1_code;
          a62(indx) := t(ddindx).contact_name;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).rg_latown_id);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).r_latown_id);
          a65(indx) := t(ddindx).r_latown_rule_information1;
          a66(indx) := t(ddindx).col_latown_form_left_prompt;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).rg_lanntf_id);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).r_lanntf_id);
          a69(indx) := t(ddindx).r_lanntf_rule_information1;
          a70(indx) := t(ddindx).col_lanntf_form_left_prompt;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).rg_lacpln_id);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).r_lacpln_id);
          a73(indx) := t(ddindx).r_lacpln_rule_information1;
          a74(indx) := t(ddindx).col_lacpln_form_left_prompt;
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).rg_lapact_id);
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).r_lapact_id);
          a77(indx) := t(ddindx).r_lapact_rule_information1;
          a78(indx) := t(ddindx).col_lapact_form_left_prompt;
          a79(indx) := t(ddindx).khr_currency_conv_type;
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).khr_currency_conv_rate);
          a81(indx) := t(ddindx).khr_currency_conv_date;
          a82(indx) := t(ddindx).khr_assignable_yn;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_mla_create_update_pub.party_tab_type, a0 JTF_NUMBER_TABLE
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
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_mla_create_update_pub.party_tab_type, a0 out nocopy JTF_NUMBER_TABLE
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
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_mla_create_update_pub.upd_deal_tab_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).chr_contract_number := a1(indx);
          t(ddindx).chr_description := a2(indx);
          t(ddindx).chr_start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).chr_end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).khr_converted_account_yn := a5(indx);
          t(ddindx).chr_template_yn := a6(indx);
          t(ddindx).chr_date_signed := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).chr_currency_code := a8(indx);
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_mla_create_update_pub.upd_deal_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := t(ddindx).chr_contract_number;
          a2(indx) := t(ddindx).chr_description;
          a3(indx) := t(ddindx).chr_start_date;
          a4(indx) := t(ddindx).chr_end_date;
          a5(indx) := t(ddindx).khr_converted_account_yn;
          a6(indx) := t(ddindx).chr_template_yn;
          a7(indx) := t(ddindx).chr_date_signed;
          a8(indx) := t(ddindx).chr_currency_code;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
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
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_durv_rec okl_mla_create_update_pub.upd_deal_rec_type;
    ddx_durv_rec okl_mla_create_update_pub.upd_deal_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_durv_rec.chr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_durv_rec.chr_contract_number := p5_a1;
    ddp_durv_rec.chr_description := p5_a2;
    ddp_durv_rec.chr_start_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_durv_rec.chr_end_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_durv_rec.khr_converted_account_yn := p5_a5;
    ddp_durv_rec.chr_template_yn := p5_a6;
    ddp_durv_rec.chr_date_signed := rosetta_g_miss_date_in_map(p5_a7);
    ddp_durv_rec.chr_currency_code := p5_a8;
    ddp_durv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a9);


    -- here's the delegated call to the old PL/SQL routine
    okl_mla_create_update_pub.update_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_durv_rec,
      ddx_durv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_durv_rec.chr_id);
    p6_a1 := ddx_durv_rec.chr_contract_number;
    p6_a2 := ddx_durv_rec.chr_description;
    p6_a3 := ddx_durv_rec.chr_start_date;
    p6_a4 := ddx_durv_rec.chr_end_date;
    p6_a5 := ddx_durv_rec.khr_converted_account_yn;
    p6_a6 := ddx_durv_rec.chr_template_yn;
    p6_a7 := ddx_durv_rec.chr_date_signed;
    p6_a8 := ddx_durv_rec.chr_currency_code;
    p6_a9 := rosetta_g_miss_num_map(ddx_durv_rec.legal_entity_id);
  end;

  procedure create_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_code  VARCHAR2
    , p_template_type  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_scs_code  VARCHAR2
    , p_customer_id1 in out nocopy  VARCHAR2
    , p_customer_id2 in out nocopy  VARCHAR2
    , p_customer_code  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_effective_from  date
    , p_program_name  VARCHAR2
    , p_program_id  NUMBER
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
    , p_source_chr_id in out nocopy  NUMBER
    , p_source_contract_number  VARCHAR2
    , x_chr_id out nocopy  NUMBER
    , p_legal_entity_id  NUMBER
  )

  as
    ddp_effective_from date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_effective_from := rosetta_g_miss_date_in_map(p_effective_from);









    -- here's the delegated call to the old PL/SQL routine
    okl_mla_create_update_pub.create_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_code,
      p_template_type,
      p_contract_number,
      p_scs_code,
      p_customer_id1,
      p_customer_id2,
      p_customer_code,
      p_customer_name,
      ddp_effective_from,
      p_program_name,
      p_program_id,
      p_org_id,
      p_organization_id,
      p_source_chr_id,
      p_source_contract_number,
      x_chr_id,
      p_legal_entity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















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
    ddp_kpl_rec okl_mla_create_update_pub.party_rec_type;
    ddx_kpl_rec okl_mla_create_update_pub.party_rec_type;
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
    okl_mla_create_update_pub.create_party(p_api_version,
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

end okl_mla_create_update_pub_w;

/
