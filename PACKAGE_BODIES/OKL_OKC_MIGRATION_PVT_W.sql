--------------------------------------------------------
--  DDL for Package Body OKL_OKC_MIGRATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OKC_MIGRATION_PVT_W" as
  /* $Header: OKLEOKCB.pls 115.6 2003/10/16 09:58:47 avsingh noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_okc_migration_pvt.cvmv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).major_version := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).minor_version := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_okc_migration_pvt.cvmv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).major_version);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).minor_version);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := t(ddindx).creation_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := t(ddindx).last_update_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_okc_migration_pvt.chrv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_600
    , a19 JTF_VARCHAR2_TABLE_2000
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_2000
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_DATE_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_DATE_TABLE
    , a63 JTF_DATE_TABLE
    , a64 JTF_DATE_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_VARCHAR2_TABLE_500
    , a72 JTF_VARCHAR2_TABLE_500
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_500
    , a75 JTF_VARCHAR2_TABLE_500
    , a76 JTF_VARCHAR2_TABLE_500
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_500
    , a79 JTF_VARCHAR2_TABLE_500
    , a80 JTF_VARCHAR2_TABLE_500
    , a81 JTF_VARCHAR2_TABLE_500
    , a82 JTF_VARCHAR2_TABLE_500
    , a83 JTF_VARCHAR2_TABLE_500
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_DATE_TABLE
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).chr_id_response := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).chr_id_award := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).chr_id_renewed := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).inv_organization_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).sts_code := a7(indx);
          t(ddindx).qcl_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).scs_code := a9(indx);
          t(ddindx).contract_number := a10(indx);
          t(ddindx).currency_code := a11(indx);
          t(ddindx).contract_number_modifier := a12(indx);
          t(ddindx).archived_yn := a13(indx);
          t(ddindx).deleted_yn := a14(indx);
          t(ddindx).cust_po_number_req_yn := a15(indx);
          t(ddindx).pre_pay_req_yn := a16(indx);
          t(ddindx).cust_po_number := a17(indx);
          t(ddindx).short_description := a18(indx);
          t(ddindx).comments := a19(indx);
          t(ddindx).description := a20(indx);
          t(ddindx).dpas_rating := a21(indx);
          t(ddindx).cognomen := a22(indx);
          t(ddindx).template_yn := a23(indx);
          t(ddindx).template_used := a24(indx);
          t(ddindx).date_approved := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).datetime_cancelled := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).auto_renew_days := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).date_issued := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).datetime_responded := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).non_response_reason := a30(indx);
          t(ddindx).non_response_explain := a31(indx);
          t(ddindx).rfp_type := a32(indx);
          t(ddindx).chr_type := a33(indx);
          t(ddindx).keep_on_mail_list := a34(indx);
          t(ddindx).set_aside_reason := a35(indx);
          t(ddindx).set_aside_percent := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).response_copies_req := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).date_close_projected := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).datetime_proposed := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).date_signed := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).date_renewed := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).trn_code := a43(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).authoring_org_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).buy_or_sell := a47(indx);
          t(ddindx).issue_or_receive := a48(indx);
          t(ddindx).estimated_amount := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).chr_id_renewed_to := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).estimated_amount_renewed := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).currency_code_renewed := a52(indx);
          t(ddindx).upg_orig_system_ref := a53(indx);
          t(ddindx).upg_orig_system_ref_id := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).application_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).orig_system_source_code := a56(indx);
          t(ddindx).orig_system_id1 := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).orig_system_reference1 := a58(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).pricing_date := rosetta_g_miss_date_in_map(a62(indx));
          t(ddindx).sign_by_date := rosetta_g_miss_date_in_map(a63(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a64(indx));
          t(ddindx).total_line_list_price := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).user_estimated_amount := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).attribute_category := a68(indx);
          t(ddindx).attribute1 := a69(indx);
          t(ddindx).attribute2 := a70(indx);
          t(ddindx).attribute3 := a71(indx);
          t(ddindx).attribute4 := a72(indx);
          t(ddindx).attribute5 := a73(indx);
          t(ddindx).attribute6 := a74(indx);
          t(ddindx).attribute7 := a75(indx);
          t(ddindx).attribute8 := a76(indx);
          t(ddindx).attribute9 := a77(indx);
          t(ddindx).attribute10 := a78(indx);
          t(ddindx).attribute11 := a79(indx);
          t(ddindx).attribute12 := a80(indx);
          t(ddindx).attribute13 := a81(indx);
          t(ddindx).attribute14 := a82(indx);
          t(ddindx).attribute15 := a83(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a84(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a86(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).old_sts_code := a89(indx);
          t(ddindx).new_sts_code := a90(indx);
          t(ddindx).old_ste_code := a91(indx);
          t(ddindx).new_ste_code := a92(indx);
          t(ddindx).conversion_type := a93(indx);
          t(ddindx).conversion_rate := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).conversion_rate_date := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).conversion_euro_rate := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).cust_acct_id := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).inv_rule_id := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).renewal_type_code := a100(indx);
          t(ddindx).renewal_notify_to := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).renewal_end_date := rosetta_g_miss_date_in_map(a102(indx));
          t(ddindx).ship_to_site_use_id := rosetta_g_miss_num_map(a103(indx));
          t(ddindx).payment_term_id := rosetta_g_miss_num_map(a104(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_okc_migration_pvt.chrv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_600
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_DATE_TABLE
    , a63 out nocopy JTF_DATE_TABLE
    , a64 out nocopy JTF_DATE_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_500
    , a71 out nocopy JTF_VARCHAR2_TABLE_500
    , a72 out nocopy JTF_VARCHAR2_TABLE_500
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_500
    , a75 out nocopy JTF_VARCHAR2_TABLE_500
    , a76 out nocopy JTF_VARCHAR2_TABLE_500
    , a77 out nocopy JTF_VARCHAR2_TABLE_500
    , a78 out nocopy JTF_VARCHAR2_TABLE_500
    , a79 out nocopy JTF_VARCHAR2_TABLE_500
    , a80 out nocopy JTF_VARCHAR2_TABLE_500
    , a81 out nocopy JTF_VARCHAR2_TABLE_500
    , a82 out nocopy JTF_VARCHAR2_TABLE_500
    , a83 out nocopy JTF_VARCHAR2_TABLE_500
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_NUMBER_TABLE
    , a98 out nocopy JTF_NUMBER_TABLE
    , a99 out nocopy JTF_NUMBER_TABLE
    , a100 out nocopy JTF_VARCHAR2_TABLE_100
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_DATE_TABLE
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_600();
    a19 := JTF_VARCHAR2_TABLE_2000();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_2000();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_DATE_TABLE();
    a63 := JTF_DATE_TABLE();
    a64 := JTF_DATE_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_500();
    a71 := JTF_VARCHAR2_TABLE_500();
    a72 := JTF_VARCHAR2_TABLE_500();
    a73 := JTF_VARCHAR2_TABLE_500();
    a74 := JTF_VARCHAR2_TABLE_500();
    a75 := JTF_VARCHAR2_TABLE_500();
    a76 := JTF_VARCHAR2_TABLE_500();
    a77 := JTF_VARCHAR2_TABLE_500();
    a78 := JTF_VARCHAR2_TABLE_500();
    a79 := JTF_VARCHAR2_TABLE_500();
    a80 := JTF_VARCHAR2_TABLE_500();
    a81 := JTF_VARCHAR2_TABLE_500();
    a82 := JTF_VARCHAR2_TABLE_500();
    a83 := JTF_VARCHAR2_TABLE_500();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_VARCHAR2_TABLE_100();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_DATE_TABLE();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_600();
      a19 := JTF_VARCHAR2_TABLE_2000();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_2000();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_DATE_TABLE();
      a63 := JTF_DATE_TABLE();
      a64 := JTF_DATE_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_500();
      a71 := JTF_VARCHAR2_TABLE_500();
      a72 := JTF_VARCHAR2_TABLE_500();
      a73 := JTF_VARCHAR2_TABLE_500();
      a74 := JTF_VARCHAR2_TABLE_500();
      a75 := JTF_VARCHAR2_TABLE_500();
      a76 := JTF_VARCHAR2_TABLE_500();
      a77 := JTF_VARCHAR2_TABLE_500();
      a78 := JTF_VARCHAR2_TABLE_500();
      a79 := JTF_VARCHAR2_TABLE_500();
      a80 := JTF_VARCHAR2_TABLE_500();
      a81 := JTF_VARCHAR2_TABLE_500();
      a82 := JTF_VARCHAR2_TABLE_500();
      a83 := JTF_VARCHAR2_TABLE_500();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_VARCHAR2_TABLE_100();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_DATE_TABLE();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id_response);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id_award);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id_renewed);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).inv_organization_id);
          a7(indx) := t(ddindx).sts_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).qcl_id);
          a9(indx) := t(ddindx).scs_code;
          a10(indx) := t(ddindx).contract_number;
          a11(indx) := t(ddindx).currency_code;
          a12(indx) := t(ddindx).contract_number_modifier;
          a13(indx) := t(ddindx).archived_yn;
          a14(indx) := t(ddindx).deleted_yn;
          a15(indx) := t(ddindx).cust_po_number_req_yn;
          a16(indx) := t(ddindx).pre_pay_req_yn;
          a17(indx) := t(ddindx).cust_po_number;
          a18(indx) := t(ddindx).short_description;
          a19(indx) := t(ddindx).comments;
          a20(indx) := t(ddindx).description;
          a21(indx) := t(ddindx).dpas_rating;
          a22(indx) := t(ddindx).cognomen;
          a23(indx) := t(ddindx).template_yn;
          a24(indx) := t(ddindx).template_used;
          a25(indx) := t(ddindx).date_approved;
          a26(indx) := t(ddindx).datetime_cancelled;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).auto_renew_days);
          a28(indx) := t(ddindx).date_issued;
          a29(indx) := t(ddindx).datetime_responded;
          a30(indx) := t(ddindx).non_response_reason;
          a31(indx) := t(ddindx).non_response_explain;
          a32(indx) := t(ddindx).rfp_type;
          a33(indx) := t(ddindx).chr_type;
          a34(indx) := t(ddindx).keep_on_mail_list;
          a35(indx) := t(ddindx).set_aside_reason;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).set_aside_percent);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).response_copies_req);
          a38(indx) := t(ddindx).date_close_projected;
          a39(indx) := t(ddindx).datetime_proposed;
          a40(indx) := t(ddindx).date_signed;
          a41(indx) := t(ddindx).date_terminated;
          a42(indx) := t(ddindx).date_renewed;
          a43(indx) := t(ddindx).trn_code;
          a44(indx) := t(ddindx).start_date;
          a45(indx) := t(ddindx).end_date;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).authoring_org_id);
          a47(indx) := t(ddindx).buy_or_sell;
          a48(indx) := t(ddindx).issue_or_receive;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).estimated_amount);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id_renewed_to);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).estimated_amount_renewed);
          a52(indx) := t(ddindx).currency_code_renewed;
          a53(indx) := t(ddindx).upg_orig_system_ref;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).upg_orig_system_ref_id);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a56(indx) := t(ddindx).orig_system_source_code;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).orig_system_id1);
          a58(indx) := t(ddindx).orig_system_reference1;
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a62(indx) := t(ddindx).pricing_date;
          a63(indx) := t(ddindx).sign_by_date;
          a64(indx) := t(ddindx).program_update_date;
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).total_line_list_price);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).user_estimated_amount);
          a68(indx) := t(ddindx).attribute_category;
          a69(indx) := t(ddindx).attribute1;
          a70(indx) := t(ddindx).attribute2;
          a71(indx) := t(ddindx).attribute3;
          a72(indx) := t(ddindx).attribute4;
          a73(indx) := t(ddindx).attribute5;
          a74(indx) := t(ddindx).attribute6;
          a75(indx) := t(ddindx).attribute7;
          a76(indx) := t(ddindx).attribute8;
          a77(indx) := t(ddindx).attribute9;
          a78(indx) := t(ddindx).attribute10;
          a79(indx) := t(ddindx).attribute11;
          a80(indx) := t(ddindx).attribute12;
          a81(indx) := t(ddindx).attribute13;
          a82(indx) := t(ddindx).attribute14;
          a83(indx) := t(ddindx).attribute15;
          a84(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a85(indx) := t(ddindx).creation_date;
          a86(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a87(indx) := t(ddindx).last_update_date;
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a89(indx) := t(ddindx).old_sts_code;
          a90(indx) := t(ddindx).new_sts_code;
          a91(indx) := t(ddindx).old_ste_code;
          a92(indx) := t(ddindx).new_ste_code;
          a93(indx) := t(ddindx).conversion_type;
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).conversion_rate);
          a95(indx) := t(ddindx).conversion_rate_date;
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).conversion_euro_rate);
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).cust_acct_id);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).inv_rule_id);
          a100(indx) := t(ddindx).renewal_type_code;
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).renewal_notify_to);
          a102(indx) := t(ddindx).renewal_end_date;
          a103(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_use_id);
          a104(indx) := rosetta_g_miss_num_map(t(ddindx).payment_term_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_okc_migration_pvt.clev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_500
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_500
    , a51 JTF_VARCHAR2_TABLE_500
    , a52 JTF_VARCHAR2_TABLE_500
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_DATE_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_DATE_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_DATE_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).chr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).cle_id_renewed := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).cle_id_renewed_to := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).lse_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).line_number := a8(indx);
          t(ddindx).sts_code := a9(indx);
          t(ddindx).display_sequence := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).trn_code := a11(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).comments := a13(indx);
          t(ddindx).item_description := a14(indx);
          t(ddindx).oke_boe_description := a15(indx);
          t(ddindx).cognomen := a16(indx);
          t(ddindx).hidden_ind := a17(indx);
          t(ddindx).price_unit := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).price_unit_percent := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).price_negotiated := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).price_negotiated_renewed := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).price_level_ind := a22(indx);
          t(ddindx).invoice_line_level_ind := a23(indx);
          t(ddindx).dpas_rating := a24(indx);
          t(ddindx).block23text := a25(indx);
          t(ddindx).exception_yn := a26(indx);
          t(ddindx).template_used := a27(indx);
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).name := a29(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).date_renewed := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).upg_orig_system_ref := a33(indx);
          t(ddindx).upg_orig_system_ref_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).orig_system_source_code := a35(indx);
          t(ddindx).orig_system_id1 := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).orig_system_reference1 := a37(indx);
          t(ddindx).attribute_category := a38(indx);
          t(ddindx).attribute1 := a39(indx);
          t(ddindx).attribute2 := a40(indx);
          t(ddindx).attribute3 := a41(indx);
          t(ddindx).attribute4 := a42(indx);
          t(ddindx).attribute5 := a43(indx);
          t(ddindx).attribute6 := a44(indx);
          t(ddindx).attribute7 := a45(indx);
          t(ddindx).attribute8 := a46(indx);
          t(ddindx).attribute9 := a47(indx);
          t(ddindx).attribute10 := a48(indx);
          t(ddindx).attribute11 := a49(indx);
          t(ddindx).attribute12 := a50(indx);
          t(ddindx).attribute13 := a51(indx);
          t(ddindx).attribute14 := a52(indx);
          t(ddindx).attribute15 := a53(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).price_type := a58(indx);
          t(ddindx).currency_code := a59(indx);
          t(ddindx).currency_code_renewed := a60(indx);
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).old_sts_code := a62(indx);
          t(ddindx).new_sts_code := a63(indx);
          t(ddindx).old_ste_code := a64(indx);
          t(ddindx).new_ste_code := a65(indx);
          t(ddindx).call_action_asmblr := a66(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a70(indx));
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).pricing_date := rosetta_g_miss_date_in_map(a72(indx));
          t(ddindx).price_list_line_id := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).line_list_price := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).item_to_price_yn := a75(indx);
          t(ddindx).price_basis_yn := a76(indx);
          t(ddindx).config_header_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).config_revision_number := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).config_complete_yn := a79(indx);
          t(ddindx).config_valid_yn := a80(indx);
          t(ddindx).config_top_model_line_id := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).config_item_type := a82(indx);
          t(ddindx).config_item_id := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).cust_acct_id := rosetta_g_miss_num_map(a84(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a85(indx));
          t(ddindx).inv_rule_id := rosetta_g_miss_num_map(a86(indx));
          t(ddindx).line_renewal_type_code := a87(indx);
          t(ddindx).ship_to_site_use_id := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).payment_term_id := rosetta_g_miss_num_map(a89(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_okc_migration_pvt.clev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_500
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_500
    , a51 out nocopy JTF_VARCHAR2_TABLE_500
    , a52 out nocopy JTF_VARCHAR2_TABLE_500
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_DATE_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_NUMBER_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_500();
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_500();
    a51 := JTF_VARCHAR2_TABLE_500();
    a52 := JTF_VARCHAR2_TABLE_500();
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_DATE_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_NUMBER_TABLE();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_500();
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_500();
      a51 := JTF_VARCHAR2_TABLE_500();
      a52 := JTF_VARCHAR2_TABLE_500();
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_DATE_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_NUMBER_TABLE();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id_renewed);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id_renewed_to);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).lse_id);
          a8(indx) := t(ddindx).line_number;
          a9(indx) := t(ddindx).sts_code;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).display_sequence);
          a11(indx) := t(ddindx).trn_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a13(indx) := t(ddindx).comments;
          a14(indx) := t(ddindx).item_description;
          a15(indx) := t(ddindx).oke_boe_description;
          a16(indx) := t(ddindx).cognomen;
          a17(indx) := t(ddindx).hidden_ind;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).price_unit);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).price_unit_percent);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).price_negotiated);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).price_negotiated_renewed);
          a22(indx) := t(ddindx).price_level_ind;
          a23(indx) := t(ddindx).invoice_line_level_ind;
          a24(indx) := t(ddindx).dpas_rating;
          a25(indx) := t(ddindx).block23text;
          a26(indx) := t(ddindx).exception_yn;
          a27(indx) := t(ddindx).template_used;
          a28(indx) := t(ddindx).date_terminated;
          a29(indx) := t(ddindx).name;
          a30(indx) := t(ddindx).start_date;
          a31(indx) := t(ddindx).end_date;
          a32(indx) := t(ddindx).date_renewed;
          a33(indx) := t(ddindx).upg_orig_system_ref;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).upg_orig_system_ref_id);
          a35(indx) := t(ddindx).orig_system_source_code;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).orig_system_id1);
          a37(indx) := t(ddindx).orig_system_reference1;
          a38(indx) := t(ddindx).attribute_category;
          a39(indx) := t(ddindx).attribute1;
          a40(indx) := t(ddindx).attribute2;
          a41(indx) := t(ddindx).attribute3;
          a42(indx) := t(ddindx).attribute4;
          a43(indx) := t(ddindx).attribute5;
          a44(indx) := t(ddindx).attribute6;
          a45(indx) := t(ddindx).attribute7;
          a46(indx) := t(ddindx).attribute8;
          a47(indx) := t(ddindx).attribute9;
          a48(indx) := t(ddindx).attribute10;
          a49(indx) := t(ddindx).attribute11;
          a50(indx) := t(ddindx).attribute12;
          a51(indx) := t(ddindx).attribute13;
          a52(indx) := t(ddindx).attribute14;
          a53(indx) := t(ddindx).attribute15;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a55(indx) := t(ddindx).creation_date;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a57(indx) := t(ddindx).last_update_date;
          a58(indx) := t(ddindx).price_type;
          a59(indx) := t(ddindx).currency_code;
          a60(indx) := t(ddindx).currency_code_renewed;
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a62(indx) := t(ddindx).old_sts_code;
          a63(indx) := t(ddindx).new_sts_code;
          a64(indx) := t(ddindx).old_ste_code;
          a65(indx) := t(ddindx).new_ste_code;
          a66(indx) := t(ddindx).call_action_asmblr;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a70(indx) := t(ddindx).program_update_date;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a72(indx) := t(ddindx).pricing_date;
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_line_id);
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).line_list_price);
          a75(indx) := t(ddindx).item_to_price_yn;
          a76(indx) := t(ddindx).price_basis_yn;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).config_header_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).config_revision_number);
          a79(indx) := t(ddindx).config_complete_yn;
          a80(indx) := t(ddindx).config_valid_yn;
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).config_top_model_line_id);
          a82(indx) := t(ddindx).config_item_type;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).config_item_id);
          a84(indx) := rosetta_g_miss_num_map(t(ddindx).cust_acct_id);
          a85(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a86(indx) := rosetta_g_miss_num_map(t(ddindx).inv_rule_id);
          a87(indx) := t(ddindx).line_renewal_type_code;
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_use_id);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).payment_term_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy okl_okc_migration_pvt.cimv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cle_id_for := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object1_id1 := a6(indx);
          t(ddindx).object1_id2 := a7(indx);
          t(ddindx).jtot_object1_code := a8(indx);
          t(ddindx).uom_code := a9(indx);
          t(ddindx).exception_yn := a10(indx);
          t(ddindx).number_of_items := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).upg_orig_system_ref := a12(indx);
          t(ddindx).upg_orig_system_ref_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).priced_item_yn := a14(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_okc_migration_pvt.cimv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id_for);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a6(indx) := t(ddindx).object1_id1;
          a7(indx) := t(ddindx).object1_id2;
          a8(indx) := t(ddindx).jtot_object1_code;
          a9(indx) := t(ddindx).uom_code;
          a10(indx) := t(ddindx).exception_yn;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_items);
          a12(indx) := t(ddindx).upg_orig_system_ref;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).upg_orig_system_ref_id);
          a14(indx) := t(ddindx).priced_item_yn;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_okc_migration_pvt.cplv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_500
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
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).rle_code := a6(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).object1_id1 := a8(indx);
          t(ddindx).object1_id2 := a9(indx);
          t(ddindx).jtot_object1_code := a10(indx);
          t(ddindx).cognomen := a11(indx);
          t(ddindx).code := a12(indx);
          t(ddindx).facility := a13(indx);
          t(ddindx).minority_group_lookup_code := a14(indx);
          t(ddindx).small_business_flag := a15(indx);
          t(ddindx).women_owned_flag := a16(indx);
          t(ddindx).alias := a17(indx);
          t(ddindx).attribute_category := a18(indx);
          t(ddindx).attribute1 := a19(indx);
          t(ddindx).attribute2 := a20(indx);
          t(ddindx).attribute3 := a21(indx);
          t(ddindx).attribute4 := a22(indx);
          t(ddindx).attribute5 := a23(indx);
          t(ddindx).attribute6 := a24(indx);
          t(ddindx).attribute7 := a25(indx);
          t(ddindx).attribute8 := a26(indx);
          t(ddindx).attribute9 := a27(indx);
          t(ddindx).attribute10 := a28(indx);
          t(ddindx).attribute11 := a29(indx);
          t(ddindx).attribute12 := a30(indx);
          t(ddindx).attribute13 := a31(indx);
          t(ddindx).attribute14 := a32(indx);
          t(ddindx).attribute15 := a33(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).cust_acct_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a40(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_okc_migration_pvt.cplv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_500();
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
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_500();
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
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a6(indx) := t(ddindx).rle_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a8(indx) := t(ddindx).object1_id1;
          a9(indx) := t(ddindx).object1_id2;
          a10(indx) := t(ddindx).jtot_object1_code;
          a11(indx) := t(ddindx).cognomen;
          a12(indx) := t(ddindx).code;
          a13(indx) := t(ddindx).facility;
          a14(indx) := t(ddindx).minority_group_lookup_code;
          a15(indx) := t(ddindx).small_business_flag;
          a16(indx) := t(ddindx).women_owned_flag;
          a17(indx) := t(ddindx).alias;
          a18(indx) := t(ddindx).attribute_category;
          a19(indx) := t(ddindx).attribute1;
          a20(indx) := t(ddindx).attribute2;
          a21(indx) := t(ddindx).attribute3;
          a22(indx) := t(ddindx).attribute4;
          a23(indx) := t(ddindx).attribute5;
          a24(indx) := t(ddindx).attribute6;
          a25(indx) := t(ddindx).attribute7;
          a26(indx) := t(ddindx).attribute8;
          a27(indx) := t(ddindx).attribute9;
          a28(indx) := t(ddindx).attribute10;
          a29(indx) := t(ddindx).attribute11;
          a30(indx) := t(ddindx).attribute12;
          a31(indx) := t(ddindx).attribute13;
          a32(indx) := t(ddindx).attribute14;
          a33(indx) := t(ddindx).attribute15;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a35(indx) := t(ddindx).creation_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a37(indx) := t(ddindx).last_update_date;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).cust_acct_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_okc_migration_pvt.gvev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).isa_agreement_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).chr_id_referred := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).cle_id_referred := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).copied_only_yn := a8(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a13(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_okc_migration_pvt.gvev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).isa_agreement_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id_referred);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id_referred);
          a8(indx) := t(ddindx).copied_only_yn;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy okl_okc_migration_pvt.rgpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).rgd_code := a3(indx);
          t(ddindx).sat_code := a4(indx);
          t(ddindx).rgp_type := a5(indx);
          t(ddindx).cle_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).parent_rgp_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).comments := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a31(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t okl_okc_migration_pvt.rgpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).rgd_code;
          a4(indx) := t(ddindx).sat_code;
          a5(indx) := t(ddindx).rgp_type;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).parent_rgp_id);
          a10(indx) := t(ddindx).comments;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a28(indx) := t(ddindx).creation_date;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a30(indx) := t(ddindx).last_update_date;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p15(t out nocopy okl_okc_migration_pvt.rmpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rgp_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).rrd_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t okl_okc_migration_pvt.rmpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).rgp_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).rrd_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p17(t out nocopy okl_okc_migration_pvt.ctcv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cro_code := a3(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).contact_sequence := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object1_id1 := a6(indx);
          t(ddindx).object1_id2 := a7(indx);
          t(ddindx).jtot_object1_code := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a31(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t okl_okc_migration_pvt.ctcv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a3(indx) := t(ddindx).cro_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).contact_sequence);
          a6(indx) := t(ddindx).object1_id1;
          a7(indx) := t(ddindx).object1_id2;
          a8(indx) := t(ddindx).jtot_object1_code;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a26(indx) := t(ddindx).creation_date;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a28(indx) := t(ddindx).last_update_date;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a30(indx) := t(ddindx).start_date;
          a31(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure create_contract_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
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
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  DATE
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  DATE
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  VARCHAR2
    , p6_a84 out nocopy  NUMBER
    , p6_a85 out nocopy  DATE
    , p6_a86 out nocopy  NUMBER
    , p6_a87 out nocopy  DATE
    , p6_a88 out nocopy  NUMBER
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  NUMBER
    , p6_a95 out nocopy  DATE
    , p6_a96 out nocopy  NUMBER
    , p6_a97 out nocopy  NUMBER
    , p6_a98 out nocopy  NUMBER
    , p6_a99 out nocopy  NUMBER
    , p6_a100 out nocopy  VARCHAR2
    , p6_a101 out nocopy  NUMBER
    , p6_a102 out nocopy  DATE
    , p6_a103 out nocopy  NUMBER
    , p6_a104 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  DATE := fnd_api.g_miss_date
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  DATE := fnd_api.g_miss_date
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  NUMBER := 0-1962.0724
    , p5_a97  NUMBER := 0-1962.0724
    , p5_a98  NUMBER := 0-1962.0724
    , p5_a99  NUMBER := 0-1962.0724
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  NUMBER := 0-1962.0724
    , p5_a102  DATE := fnd_api.g_miss_date
    , p5_a103  NUMBER := 0-1962.0724
    , p5_a104  NUMBER := 0-1962.0724
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddx_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_chrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_chrv_rec.sfwt_flag := p5_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p5_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p5_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p5_a6);
    ddp_chrv_rec.sts_code := p5_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_chrv_rec.scs_code := p5_a9;
    ddp_chrv_rec.contract_number := p5_a10;
    ddp_chrv_rec.currency_code := p5_a11;
    ddp_chrv_rec.contract_number_modifier := p5_a12;
    ddp_chrv_rec.archived_yn := p5_a13;
    ddp_chrv_rec.deleted_yn := p5_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p5_a15;
    ddp_chrv_rec.pre_pay_req_yn := p5_a16;
    ddp_chrv_rec.cust_po_number := p5_a17;
    ddp_chrv_rec.short_description := p5_a18;
    ddp_chrv_rec.comments := p5_a19;
    ddp_chrv_rec.description := p5_a20;
    ddp_chrv_rec.dpas_rating := p5_a21;
    ddp_chrv_rec.cognomen := p5_a22;
    ddp_chrv_rec.template_yn := p5_a23;
    ddp_chrv_rec.template_used := p5_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p5_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p5_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p5_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p5_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p5_a29);
    ddp_chrv_rec.non_response_reason := p5_a30;
    ddp_chrv_rec.non_response_explain := p5_a31;
    ddp_chrv_rec.rfp_type := p5_a32;
    ddp_chrv_rec.chr_type := p5_a33;
    ddp_chrv_rec.keep_on_mail_list := p5_a34;
    ddp_chrv_rec.set_aside_reason := p5_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p5_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p5_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p5_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p5_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p5_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_chrv_rec.trn_code := p5_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p5_a46);
    ddp_chrv_rec.buy_or_sell := p5_a47;
    ddp_chrv_rec.issue_or_receive := p5_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p5_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p5_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p5_a51);
    ddp_chrv_rec.currency_code_renewed := p5_a52;
    ddp_chrv_rec.upg_orig_system_ref := p5_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p5_a55);
    ddp_chrv_rec.orig_system_source_code := p5_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a57);
    ddp_chrv_rec.orig_system_reference1 := p5_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p5_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p5_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p5_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p5_a67);
    ddp_chrv_rec.attribute_category := p5_a68;
    ddp_chrv_rec.attribute1 := p5_a69;
    ddp_chrv_rec.attribute2 := p5_a70;
    ddp_chrv_rec.attribute3 := p5_a71;
    ddp_chrv_rec.attribute4 := p5_a72;
    ddp_chrv_rec.attribute5 := p5_a73;
    ddp_chrv_rec.attribute6 := p5_a74;
    ddp_chrv_rec.attribute7 := p5_a75;
    ddp_chrv_rec.attribute8 := p5_a76;
    ddp_chrv_rec.attribute9 := p5_a77;
    ddp_chrv_rec.attribute10 := p5_a78;
    ddp_chrv_rec.attribute11 := p5_a79;
    ddp_chrv_rec.attribute12 := p5_a80;
    ddp_chrv_rec.attribute13 := p5_a81;
    ddp_chrv_rec.attribute14 := p5_a82;
    ddp_chrv_rec.attribute15 := p5_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p5_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a88);
    ddp_chrv_rec.old_sts_code := p5_a89;
    ddp_chrv_rec.new_sts_code := p5_a90;
    ddp_chrv_rec.old_ste_code := p5_a91;
    ddp_chrv_rec.new_ste_code := p5_a92;
    ddp_chrv_rec.conversion_type := p5_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p5_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p5_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p5_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a99);
    ddp_chrv_rec.renewal_type_code := p5_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p5_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p5_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p5_a104);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contract_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chrv_rec,
      ddx_chrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_chrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_chrv_rec.object_version_number);
    p6_a2 := ddx_chrv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_response);
    p6_a4 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_award);
    p6_a5 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed);
    p6_a6 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_organization_id);
    p6_a7 := ddx_chrv_rec.sts_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_chrv_rec.qcl_id);
    p6_a9 := ddx_chrv_rec.scs_code;
    p6_a10 := ddx_chrv_rec.contract_number;
    p6_a11 := ddx_chrv_rec.currency_code;
    p6_a12 := ddx_chrv_rec.contract_number_modifier;
    p6_a13 := ddx_chrv_rec.archived_yn;
    p6_a14 := ddx_chrv_rec.deleted_yn;
    p6_a15 := ddx_chrv_rec.cust_po_number_req_yn;
    p6_a16 := ddx_chrv_rec.pre_pay_req_yn;
    p6_a17 := ddx_chrv_rec.cust_po_number;
    p6_a18 := ddx_chrv_rec.short_description;
    p6_a19 := ddx_chrv_rec.comments;
    p6_a20 := ddx_chrv_rec.description;
    p6_a21 := ddx_chrv_rec.dpas_rating;
    p6_a22 := ddx_chrv_rec.cognomen;
    p6_a23 := ddx_chrv_rec.template_yn;
    p6_a24 := ddx_chrv_rec.template_used;
    p6_a25 := ddx_chrv_rec.date_approved;
    p6_a26 := ddx_chrv_rec.datetime_cancelled;
    p6_a27 := rosetta_g_miss_num_map(ddx_chrv_rec.auto_renew_days);
    p6_a28 := ddx_chrv_rec.date_issued;
    p6_a29 := ddx_chrv_rec.datetime_responded;
    p6_a30 := ddx_chrv_rec.non_response_reason;
    p6_a31 := ddx_chrv_rec.non_response_explain;
    p6_a32 := ddx_chrv_rec.rfp_type;
    p6_a33 := ddx_chrv_rec.chr_type;
    p6_a34 := ddx_chrv_rec.keep_on_mail_list;
    p6_a35 := ddx_chrv_rec.set_aside_reason;
    p6_a36 := rosetta_g_miss_num_map(ddx_chrv_rec.set_aside_percent);
    p6_a37 := rosetta_g_miss_num_map(ddx_chrv_rec.response_copies_req);
    p6_a38 := ddx_chrv_rec.date_close_projected;
    p6_a39 := ddx_chrv_rec.datetime_proposed;
    p6_a40 := ddx_chrv_rec.date_signed;
    p6_a41 := ddx_chrv_rec.date_terminated;
    p6_a42 := ddx_chrv_rec.date_renewed;
    p6_a43 := ddx_chrv_rec.trn_code;
    p6_a44 := ddx_chrv_rec.start_date;
    p6_a45 := ddx_chrv_rec.end_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_chrv_rec.authoring_org_id);
    p6_a47 := ddx_chrv_rec.buy_or_sell;
    p6_a48 := ddx_chrv_rec.issue_or_receive;
    p6_a49 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount);
    p6_a50 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed_to);
    p6_a51 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount_renewed);
    p6_a52 := ddx_chrv_rec.currency_code_renewed;
    p6_a53 := ddx_chrv_rec.upg_orig_system_ref;
    p6_a54 := rosetta_g_miss_num_map(ddx_chrv_rec.upg_orig_system_ref_id);
    p6_a55 := rosetta_g_miss_num_map(ddx_chrv_rec.application_id);
    p6_a56 := ddx_chrv_rec.orig_system_source_code;
    p6_a57 := rosetta_g_miss_num_map(ddx_chrv_rec.orig_system_id1);
    p6_a58 := ddx_chrv_rec.orig_system_reference1;
    p6_a59 := rosetta_g_miss_num_map(ddx_chrv_rec.program_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_chrv_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_chrv_rec.price_list_id);
    p6_a62 := ddx_chrv_rec.pricing_date;
    p6_a63 := ddx_chrv_rec.sign_by_date;
    p6_a64 := ddx_chrv_rec.program_update_date;
    p6_a65 := rosetta_g_miss_num_map(ddx_chrv_rec.total_line_list_price);
    p6_a66 := rosetta_g_miss_num_map(ddx_chrv_rec.program_application_id);
    p6_a67 := rosetta_g_miss_num_map(ddx_chrv_rec.user_estimated_amount);
    p6_a68 := ddx_chrv_rec.attribute_category;
    p6_a69 := ddx_chrv_rec.attribute1;
    p6_a70 := ddx_chrv_rec.attribute2;
    p6_a71 := ddx_chrv_rec.attribute3;
    p6_a72 := ddx_chrv_rec.attribute4;
    p6_a73 := ddx_chrv_rec.attribute5;
    p6_a74 := ddx_chrv_rec.attribute6;
    p6_a75 := ddx_chrv_rec.attribute7;
    p6_a76 := ddx_chrv_rec.attribute8;
    p6_a77 := ddx_chrv_rec.attribute9;
    p6_a78 := ddx_chrv_rec.attribute10;
    p6_a79 := ddx_chrv_rec.attribute11;
    p6_a80 := ddx_chrv_rec.attribute12;
    p6_a81 := ddx_chrv_rec.attribute13;
    p6_a82 := ddx_chrv_rec.attribute14;
    p6_a83 := ddx_chrv_rec.attribute15;
    p6_a84 := rosetta_g_miss_num_map(ddx_chrv_rec.created_by);
    p6_a85 := ddx_chrv_rec.creation_date;
    p6_a86 := rosetta_g_miss_num_map(ddx_chrv_rec.last_updated_by);
    p6_a87 := ddx_chrv_rec.last_update_date;
    p6_a88 := rosetta_g_miss_num_map(ddx_chrv_rec.last_update_login);
    p6_a89 := ddx_chrv_rec.old_sts_code;
    p6_a90 := ddx_chrv_rec.new_sts_code;
    p6_a91 := ddx_chrv_rec.old_ste_code;
    p6_a92 := ddx_chrv_rec.new_ste_code;
    p6_a93 := ddx_chrv_rec.conversion_type;
    p6_a94 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_rate);
    p6_a95 := ddx_chrv_rec.conversion_rate_date;
    p6_a96 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_euro_rate);
    p6_a97 := rosetta_g_miss_num_map(ddx_chrv_rec.cust_acct_id);
    p6_a98 := rosetta_g_miss_num_map(ddx_chrv_rec.bill_to_site_use_id);
    p6_a99 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_rule_id);
    p6_a100 := ddx_chrv_rec.renewal_type_code;
    p6_a101 := rosetta_g_miss_num_map(ddx_chrv_rec.renewal_notify_to);
    p6_a102 := ddx_chrv_rec.renewal_end_date;
    p6_a103 := rosetta_g_miss_num_map(ddx_chrv_rec.ship_to_site_use_id);
    p6_a104 := rosetta_g_miss_num_map(ddx_chrv_rec.payment_term_id);
  end;

  procedure update_contract_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  DATE
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  DATE
    , p7_a39 out nocopy  DATE
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  DATE
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  DATE
    , p7_a45 out nocopy  DATE
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  NUMBER
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  DATE
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  DATE
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  VARCHAR2
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  VARCHAR2
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  VARCHAR2
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  DATE
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  DATE
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  VARCHAR2
    , p7_a90 out nocopy  VARCHAR2
    , p7_a91 out nocopy  VARCHAR2
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  VARCHAR2
    , p7_a94 out nocopy  NUMBER
    , p7_a95 out nocopy  DATE
    , p7_a96 out nocopy  NUMBER
    , p7_a97 out nocopy  NUMBER
    , p7_a98 out nocopy  NUMBER
    , p7_a99 out nocopy  NUMBER
    , p7_a100 out nocopy  VARCHAR2
    , p7_a101 out nocopy  NUMBER
    , p7_a102 out nocopy  DATE
    , p7_a103 out nocopy  NUMBER
    , p7_a104 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  DATE := fnd_api.g_miss_date
    , p6_a29  DATE := fnd_api.g_miss_date
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  DATE := fnd_api.g_miss_date
    , p6_a40  DATE := fnd_api.g_miss_date
    , p6_a41  DATE := fnd_api.g_miss_date
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  DATE := fnd_api.g_miss_date
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  DATE := fnd_api.g_miss_date
    , p6_a63  DATE := fnd_api.g_miss_date
    , p6_a64  DATE := fnd_api.g_miss_date
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  NUMBER := 0-1962.0724
    , p6_a87  DATE := fnd_api.g_miss_date
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  NUMBER := 0-1962.0724
    , p6_a97  NUMBER := 0-1962.0724
    , p6_a98  NUMBER := 0-1962.0724
    , p6_a99  NUMBER := 0-1962.0724
    , p6_a100  VARCHAR2 := fnd_api.g_miss_char
    , p6_a101  NUMBER := 0-1962.0724
    , p6_a102  DATE := fnd_api.g_miss_date
    , p6_a103  NUMBER := 0-1962.0724
    , p6_a104  NUMBER := 0-1962.0724
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddx_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_chrv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_chrv_rec.sfwt_flag := p6_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p6_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p6_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p6_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p6_a6);
    ddp_chrv_rec.sts_code := p6_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p6_a8);
    ddp_chrv_rec.scs_code := p6_a9;
    ddp_chrv_rec.contract_number := p6_a10;
    ddp_chrv_rec.currency_code := p6_a11;
    ddp_chrv_rec.contract_number_modifier := p6_a12;
    ddp_chrv_rec.archived_yn := p6_a13;
    ddp_chrv_rec.deleted_yn := p6_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p6_a15;
    ddp_chrv_rec.pre_pay_req_yn := p6_a16;
    ddp_chrv_rec.cust_po_number := p6_a17;
    ddp_chrv_rec.short_description := p6_a18;
    ddp_chrv_rec.comments := p6_a19;
    ddp_chrv_rec.description := p6_a20;
    ddp_chrv_rec.dpas_rating := p6_a21;
    ddp_chrv_rec.cognomen := p6_a22;
    ddp_chrv_rec.template_yn := p6_a23;
    ddp_chrv_rec.template_used := p6_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p6_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p6_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p6_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p6_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p6_a29);
    ddp_chrv_rec.non_response_reason := p6_a30;
    ddp_chrv_rec.non_response_explain := p6_a31;
    ddp_chrv_rec.rfp_type := p6_a32;
    ddp_chrv_rec.chr_type := p6_a33;
    ddp_chrv_rec.keep_on_mail_list := p6_a34;
    ddp_chrv_rec.set_aside_reason := p6_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p6_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p6_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p6_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p6_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p6_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p6_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p6_a42);
    ddp_chrv_rec.trn_code := p6_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p6_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p6_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p6_a46);
    ddp_chrv_rec.buy_or_sell := p6_a47;
    ddp_chrv_rec.issue_or_receive := p6_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p6_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p6_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p6_a51);
    ddp_chrv_rec.currency_code_renewed := p6_a52;
    ddp_chrv_rec.upg_orig_system_ref := p6_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p6_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p6_a55);
    ddp_chrv_rec.orig_system_source_code := p6_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p6_a57);
    ddp_chrv_rec.orig_system_reference1 := p6_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p6_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p6_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p6_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p6_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p6_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p6_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p6_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p6_a67);
    ddp_chrv_rec.attribute_category := p6_a68;
    ddp_chrv_rec.attribute1 := p6_a69;
    ddp_chrv_rec.attribute2 := p6_a70;
    ddp_chrv_rec.attribute3 := p6_a71;
    ddp_chrv_rec.attribute4 := p6_a72;
    ddp_chrv_rec.attribute5 := p6_a73;
    ddp_chrv_rec.attribute6 := p6_a74;
    ddp_chrv_rec.attribute7 := p6_a75;
    ddp_chrv_rec.attribute8 := p6_a76;
    ddp_chrv_rec.attribute9 := p6_a77;
    ddp_chrv_rec.attribute10 := p6_a78;
    ddp_chrv_rec.attribute11 := p6_a79;
    ddp_chrv_rec.attribute12 := p6_a80;
    ddp_chrv_rec.attribute13 := p6_a81;
    ddp_chrv_rec.attribute14 := p6_a82;
    ddp_chrv_rec.attribute15 := p6_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p6_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p6_a88);
    ddp_chrv_rec.old_sts_code := p6_a89;
    ddp_chrv_rec.new_sts_code := p6_a90;
    ddp_chrv_rec.old_ste_code := p6_a91;
    ddp_chrv_rec.new_ste_code := p6_a92;
    ddp_chrv_rec.conversion_type := p6_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p6_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p6_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p6_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p6_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p6_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p6_a99);
    ddp_chrv_rec.renewal_type_code := p6_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p6_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p6_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p6_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p6_a104);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contract_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      ddp_chrv_rec,
      ddx_chrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_chrv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_chrv_rec.object_version_number);
    p7_a2 := ddx_chrv_rec.sfwt_flag;
    p7_a3 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_response);
    p7_a4 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_award);
    p7_a5 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed);
    p7_a6 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_organization_id);
    p7_a7 := ddx_chrv_rec.sts_code;
    p7_a8 := rosetta_g_miss_num_map(ddx_chrv_rec.qcl_id);
    p7_a9 := ddx_chrv_rec.scs_code;
    p7_a10 := ddx_chrv_rec.contract_number;
    p7_a11 := ddx_chrv_rec.currency_code;
    p7_a12 := ddx_chrv_rec.contract_number_modifier;
    p7_a13 := ddx_chrv_rec.archived_yn;
    p7_a14 := ddx_chrv_rec.deleted_yn;
    p7_a15 := ddx_chrv_rec.cust_po_number_req_yn;
    p7_a16 := ddx_chrv_rec.pre_pay_req_yn;
    p7_a17 := ddx_chrv_rec.cust_po_number;
    p7_a18 := ddx_chrv_rec.short_description;
    p7_a19 := ddx_chrv_rec.comments;
    p7_a20 := ddx_chrv_rec.description;
    p7_a21 := ddx_chrv_rec.dpas_rating;
    p7_a22 := ddx_chrv_rec.cognomen;
    p7_a23 := ddx_chrv_rec.template_yn;
    p7_a24 := ddx_chrv_rec.template_used;
    p7_a25 := ddx_chrv_rec.date_approved;
    p7_a26 := ddx_chrv_rec.datetime_cancelled;
    p7_a27 := rosetta_g_miss_num_map(ddx_chrv_rec.auto_renew_days);
    p7_a28 := ddx_chrv_rec.date_issued;
    p7_a29 := ddx_chrv_rec.datetime_responded;
    p7_a30 := ddx_chrv_rec.non_response_reason;
    p7_a31 := ddx_chrv_rec.non_response_explain;
    p7_a32 := ddx_chrv_rec.rfp_type;
    p7_a33 := ddx_chrv_rec.chr_type;
    p7_a34 := ddx_chrv_rec.keep_on_mail_list;
    p7_a35 := ddx_chrv_rec.set_aside_reason;
    p7_a36 := rosetta_g_miss_num_map(ddx_chrv_rec.set_aside_percent);
    p7_a37 := rosetta_g_miss_num_map(ddx_chrv_rec.response_copies_req);
    p7_a38 := ddx_chrv_rec.date_close_projected;
    p7_a39 := ddx_chrv_rec.datetime_proposed;
    p7_a40 := ddx_chrv_rec.date_signed;
    p7_a41 := ddx_chrv_rec.date_terminated;
    p7_a42 := ddx_chrv_rec.date_renewed;
    p7_a43 := ddx_chrv_rec.trn_code;
    p7_a44 := ddx_chrv_rec.start_date;
    p7_a45 := ddx_chrv_rec.end_date;
    p7_a46 := rosetta_g_miss_num_map(ddx_chrv_rec.authoring_org_id);
    p7_a47 := ddx_chrv_rec.buy_or_sell;
    p7_a48 := ddx_chrv_rec.issue_or_receive;
    p7_a49 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount);
    p7_a50 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed_to);
    p7_a51 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount_renewed);
    p7_a52 := ddx_chrv_rec.currency_code_renewed;
    p7_a53 := ddx_chrv_rec.upg_orig_system_ref;
    p7_a54 := rosetta_g_miss_num_map(ddx_chrv_rec.upg_orig_system_ref_id);
    p7_a55 := rosetta_g_miss_num_map(ddx_chrv_rec.application_id);
    p7_a56 := ddx_chrv_rec.orig_system_source_code;
    p7_a57 := rosetta_g_miss_num_map(ddx_chrv_rec.orig_system_id1);
    p7_a58 := ddx_chrv_rec.orig_system_reference1;
    p7_a59 := rosetta_g_miss_num_map(ddx_chrv_rec.program_id);
    p7_a60 := rosetta_g_miss_num_map(ddx_chrv_rec.request_id);
    p7_a61 := rosetta_g_miss_num_map(ddx_chrv_rec.price_list_id);
    p7_a62 := ddx_chrv_rec.pricing_date;
    p7_a63 := ddx_chrv_rec.sign_by_date;
    p7_a64 := ddx_chrv_rec.program_update_date;
    p7_a65 := rosetta_g_miss_num_map(ddx_chrv_rec.total_line_list_price);
    p7_a66 := rosetta_g_miss_num_map(ddx_chrv_rec.program_application_id);
    p7_a67 := rosetta_g_miss_num_map(ddx_chrv_rec.user_estimated_amount);
    p7_a68 := ddx_chrv_rec.attribute_category;
    p7_a69 := ddx_chrv_rec.attribute1;
    p7_a70 := ddx_chrv_rec.attribute2;
    p7_a71 := ddx_chrv_rec.attribute3;
    p7_a72 := ddx_chrv_rec.attribute4;
    p7_a73 := ddx_chrv_rec.attribute5;
    p7_a74 := ddx_chrv_rec.attribute6;
    p7_a75 := ddx_chrv_rec.attribute7;
    p7_a76 := ddx_chrv_rec.attribute8;
    p7_a77 := ddx_chrv_rec.attribute9;
    p7_a78 := ddx_chrv_rec.attribute10;
    p7_a79 := ddx_chrv_rec.attribute11;
    p7_a80 := ddx_chrv_rec.attribute12;
    p7_a81 := ddx_chrv_rec.attribute13;
    p7_a82 := ddx_chrv_rec.attribute14;
    p7_a83 := ddx_chrv_rec.attribute15;
    p7_a84 := rosetta_g_miss_num_map(ddx_chrv_rec.created_by);
    p7_a85 := ddx_chrv_rec.creation_date;
    p7_a86 := rosetta_g_miss_num_map(ddx_chrv_rec.last_updated_by);
    p7_a87 := ddx_chrv_rec.last_update_date;
    p7_a88 := rosetta_g_miss_num_map(ddx_chrv_rec.last_update_login);
    p7_a89 := ddx_chrv_rec.old_sts_code;
    p7_a90 := ddx_chrv_rec.new_sts_code;
    p7_a91 := ddx_chrv_rec.old_ste_code;
    p7_a92 := ddx_chrv_rec.new_ste_code;
    p7_a93 := ddx_chrv_rec.conversion_type;
    p7_a94 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_rate);
    p7_a95 := ddx_chrv_rec.conversion_rate_date;
    p7_a96 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_euro_rate);
    p7_a97 := rosetta_g_miss_num_map(ddx_chrv_rec.cust_acct_id);
    p7_a98 := rosetta_g_miss_num_map(ddx_chrv_rec.bill_to_site_use_id);
    p7_a99 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_rule_id);
    p7_a100 := ddx_chrv_rec.renewal_type_code;
    p7_a101 := rosetta_g_miss_num_map(ddx_chrv_rec.renewal_notify_to);
    p7_a102 := ddx_chrv_rec.renewal_end_date;
    p7_a103 := rosetta_g_miss_num_map(ddx_chrv_rec.ship_to_site_use_id);
    p7_a104 := rosetta_g_miss_num_map(ddx_chrv_rec.payment_term_id);
  end;

  procedure delete_contract_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  DATE := fnd_api.g_miss_date
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  DATE := fnd_api.g_miss_date
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  NUMBER := 0-1962.0724
    , p5_a97  NUMBER := 0-1962.0724
    , p5_a98  NUMBER := 0-1962.0724
    , p5_a99  NUMBER := 0-1962.0724
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  NUMBER := 0-1962.0724
    , p5_a102  DATE := fnd_api.g_miss_date
    , p5_a103  NUMBER := 0-1962.0724
    , p5_a104  NUMBER := 0-1962.0724
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_chrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_chrv_rec.sfwt_flag := p5_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p5_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p5_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p5_a6);
    ddp_chrv_rec.sts_code := p5_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_chrv_rec.scs_code := p5_a9;
    ddp_chrv_rec.contract_number := p5_a10;
    ddp_chrv_rec.currency_code := p5_a11;
    ddp_chrv_rec.contract_number_modifier := p5_a12;
    ddp_chrv_rec.archived_yn := p5_a13;
    ddp_chrv_rec.deleted_yn := p5_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p5_a15;
    ddp_chrv_rec.pre_pay_req_yn := p5_a16;
    ddp_chrv_rec.cust_po_number := p5_a17;
    ddp_chrv_rec.short_description := p5_a18;
    ddp_chrv_rec.comments := p5_a19;
    ddp_chrv_rec.description := p5_a20;
    ddp_chrv_rec.dpas_rating := p5_a21;
    ddp_chrv_rec.cognomen := p5_a22;
    ddp_chrv_rec.template_yn := p5_a23;
    ddp_chrv_rec.template_used := p5_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p5_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p5_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p5_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p5_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p5_a29);
    ddp_chrv_rec.non_response_reason := p5_a30;
    ddp_chrv_rec.non_response_explain := p5_a31;
    ddp_chrv_rec.rfp_type := p5_a32;
    ddp_chrv_rec.chr_type := p5_a33;
    ddp_chrv_rec.keep_on_mail_list := p5_a34;
    ddp_chrv_rec.set_aside_reason := p5_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p5_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p5_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p5_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p5_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p5_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_chrv_rec.trn_code := p5_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p5_a46);
    ddp_chrv_rec.buy_or_sell := p5_a47;
    ddp_chrv_rec.issue_or_receive := p5_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p5_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p5_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p5_a51);
    ddp_chrv_rec.currency_code_renewed := p5_a52;
    ddp_chrv_rec.upg_orig_system_ref := p5_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p5_a55);
    ddp_chrv_rec.orig_system_source_code := p5_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a57);
    ddp_chrv_rec.orig_system_reference1 := p5_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p5_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p5_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p5_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p5_a67);
    ddp_chrv_rec.attribute_category := p5_a68;
    ddp_chrv_rec.attribute1 := p5_a69;
    ddp_chrv_rec.attribute2 := p5_a70;
    ddp_chrv_rec.attribute3 := p5_a71;
    ddp_chrv_rec.attribute4 := p5_a72;
    ddp_chrv_rec.attribute5 := p5_a73;
    ddp_chrv_rec.attribute6 := p5_a74;
    ddp_chrv_rec.attribute7 := p5_a75;
    ddp_chrv_rec.attribute8 := p5_a76;
    ddp_chrv_rec.attribute9 := p5_a77;
    ddp_chrv_rec.attribute10 := p5_a78;
    ddp_chrv_rec.attribute11 := p5_a79;
    ddp_chrv_rec.attribute12 := p5_a80;
    ddp_chrv_rec.attribute13 := p5_a81;
    ddp_chrv_rec.attribute14 := p5_a82;
    ddp_chrv_rec.attribute15 := p5_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p5_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a88);
    ddp_chrv_rec.old_sts_code := p5_a89;
    ddp_chrv_rec.new_sts_code := p5_a90;
    ddp_chrv_rec.old_ste_code := p5_a91;
    ddp_chrv_rec.new_ste_code := p5_a92;
    ddp_chrv_rec.conversion_type := p5_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p5_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p5_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p5_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a99);
    ddp_chrv_rec.renewal_type_code := p5_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p5_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p5_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p5_a104);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contract_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_contract_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  DATE := fnd_api.g_miss_date
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  DATE := fnd_api.g_miss_date
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  NUMBER := 0-1962.0724
    , p5_a97  NUMBER := 0-1962.0724
    , p5_a98  NUMBER := 0-1962.0724
    , p5_a99  NUMBER := 0-1962.0724
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  NUMBER := 0-1962.0724
    , p5_a102  DATE := fnd_api.g_miss_date
    , p5_a103  NUMBER := 0-1962.0724
    , p5_a104  NUMBER := 0-1962.0724
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_chrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_chrv_rec.sfwt_flag := p5_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p5_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p5_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p5_a6);
    ddp_chrv_rec.sts_code := p5_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_chrv_rec.scs_code := p5_a9;
    ddp_chrv_rec.contract_number := p5_a10;
    ddp_chrv_rec.currency_code := p5_a11;
    ddp_chrv_rec.contract_number_modifier := p5_a12;
    ddp_chrv_rec.archived_yn := p5_a13;
    ddp_chrv_rec.deleted_yn := p5_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p5_a15;
    ddp_chrv_rec.pre_pay_req_yn := p5_a16;
    ddp_chrv_rec.cust_po_number := p5_a17;
    ddp_chrv_rec.short_description := p5_a18;
    ddp_chrv_rec.comments := p5_a19;
    ddp_chrv_rec.description := p5_a20;
    ddp_chrv_rec.dpas_rating := p5_a21;
    ddp_chrv_rec.cognomen := p5_a22;
    ddp_chrv_rec.template_yn := p5_a23;
    ddp_chrv_rec.template_used := p5_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p5_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p5_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p5_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p5_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p5_a29);
    ddp_chrv_rec.non_response_reason := p5_a30;
    ddp_chrv_rec.non_response_explain := p5_a31;
    ddp_chrv_rec.rfp_type := p5_a32;
    ddp_chrv_rec.chr_type := p5_a33;
    ddp_chrv_rec.keep_on_mail_list := p5_a34;
    ddp_chrv_rec.set_aside_reason := p5_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p5_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p5_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p5_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p5_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p5_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_chrv_rec.trn_code := p5_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p5_a46);
    ddp_chrv_rec.buy_or_sell := p5_a47;
    ddp_chrv_rec.issue_or_receive := p5_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p5_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p5_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p5_a51);
    ddp_chrv_rec.currency_code_renewed := p5_a52;
    ddp_chrv_rec.upg_orig_system_ref := p5_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p5_a55);
    ddp_chrv_rec.orig_system_source_code := p5_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a57);
    ddp_chrv_rec.orig_system_reference1 := p5_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p5_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p5_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p5_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p5_a67);
    ddp_chrv_rec.attribute_category := p5_a68;
    ddp_chrv_rec.attribute1 := p5_a69;
    ddp_chrv_rec.attribute2 := p5_a70;
    ddp_chrv_rec.attribute3 := p5_a71;
    ddp_chrv_rec.attribute4 := p5_a72;
    ddp_chrv_rec.attribute5 := p5_a73;
    ddp_chrv_rec.attribute6 := p5_a74;
    ddp_chrv_rec.attribute7 := p5_a75;
    ddp_chrv_rec.attribute8 := p5_a76;
    ddp_chrv_rec.attribute9 := p5_a77;
    ddp_chrv_rec.attribute10 := p5_a78;
    ddp_chrv_rec.attribute11 := p5_a79;
    ddp_chrv_rec.attribute12 := p5_a80;
    ddp_chrv_rec.attribute13 := p5_a81;
    ddp_chrv_rec.attribute14 := p5_a82;
    ddp_chrv_rec.attribute15 := p5_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p5_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a88);
    ddp_chrv_rec.old_sts_code := p5_a89;
    ddp_chrv_rec.new_sts_code := p5_a90;
    ddp_chrv_rec.old_ste_code := p5_a91;
    ddp_chrv_rec.new_ste_code := p5_a92;
    ddp_chrv_rec.conversion_type := p5_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p5_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p5_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p5_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a99);
    ddp_chrv_rec.renewal_type_code := p5_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p5_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p5_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p5_a104);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.lock_contract_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_contract_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  DATE := fnd_api.g_miss_date
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  DATE := fnd_api.g_miss_date
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  NUMBER := 0-1962.0724
    , p5_a97  NUMBER := 0-1962.0724
    , p5_a98  NUMBER := 0-1962.0724
    , p5_a99  NUMBER := 0-1962.0724
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  NUMBER := 0-1962.0724
    , p5_a102  DATE := fnd_api.g_miss_date
    , p5_a103  NUMBER := 0-1962.0724
    , p5_a104  NUMBER := 0-1962.0724
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_chrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_chrv_rec.sfwt_flag := p5_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p5_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p5_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p5_a6);
    ddp_chrv_rec.sts_code := p5_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_chrv_rec.scs_code := p5_a9;
    ddp_chrv_rec.contract_number := p5_a10;
    ddp_chrv_rec.currency_code := p5_a11;
    ddp_chrv_rec.contract_number_modifier := p5_a12;
    ddp_chrv_rec.archived_yn := p5_a13;
    ddp_chrv_rec.deleted_yn := p5_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p5_a15;
    ddp_chrv_rec.pre_pay_req_yn := p5_a16;
    ddp_chrv_rec.cust_po_number := p5_a17;
    ddp_chrv_rec.short_description := p5_a18;
    ddp_chrv_rec.comments := p5_a19;
    ddp_chrv_rec.description := p5_a20;
    ddp_chrv_rec.dpas_rating := p5_a21;
    ddp_chrv_rec.cognomen := p5_a22;
    ddp_chrv_rec.template_yn := p5_a23;
    ddp_chrv_rec.template_used := p5_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p5_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p5_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p5_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p5_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p5_a29);
    ddp_chrv_rec.non_response_reason := p5_a30;
    ddp_chrv_rec.non_response_explain := p5_a31;
    ddp_chrv_rec.rfp_type := p5_a32;
    ddp_chrv_rec.chr_type := p5_a33;
    ddp_chrv_rec.keep_on_mail_list := p5_a34;
    ddp_chrv_rec.set_aside_reason := p5_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p5_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p5_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p5_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p5_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p5_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_chrv_rec.trn_code := p5_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p5_a46);
    ddp_chrv_rec.buy_or_sell := p5_a47;
    ddp_chrv_rec.issue_or_receive := p5_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p5_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p5_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p5_a51);
    ddp_chrv_rec.currency_code_renewed := p5_a52;
    ddp_chrv_rec.upg_orig_system_ref := p5_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p5_a55);
    ddp_chrv_rec.orig_system_source_code := p5_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a57);
    ddp_chrv_rec.orig_system_reference1 := p5_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p5_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p5_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p5_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p5_a67);
    ddp_chrv_rec.attribute_category := p5_a68;
    ddp_chrv_rec.attribute1 := p5_a69;
    ddp_chrv_rec.attribute2 := p5_a70;
    ddp_chrv_rec.attribute3 := p5_a71;
    ddp_chrv_rec.attribute4 := p5_a72;
    ddp_chrv_rec.attribute5 := p5_a73;
    ddp_chrv_rec.attribute6 := p5_a74;
    ddp_chrv_rec.attribute7 := p5_a75;
    ddp_chrv_rec.attribute8 := p5_a76;
    ddp_chrv_rec.attribute9 := p5_a77;
    ddp_chrv_rec.attribute10 := p5_a78;
    ddp_chrv_rec.attribute11 := p5_a79;
    ddp_chrv_rec.attribute12 := p5_a80;
    ddp_chrv_rec.attribute13 := p5_a81;
    ddp_chrv_rec.attribute14 := p5_a82;
    ddp_chrv_rec.attribute15 := p5_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p5_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a88);
    ddp_chrv_rec.old_sts_code := p5_a89;
    ddp_chrv_rec.new_sts_code := p5_a90;
    ddp_chrv_rec.old_ste_code := p5_a91;
    ddp_chrv_rec.new_ste_code := p5_a92;
    ddp_chrv_rec.conversion_type := p5_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p5_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p5_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p5_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a99);
    ddp_chrv_rec.renewal_type_code := p5_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p5_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p5_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p5_a104);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.validate_contract_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  DATE
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  DATE
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  DATE
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  DATE
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  NUMBER
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  VARCHAR2
    , p7_a81 out nocopy  NUMBER
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  NUMBER
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  NUMBER
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  VARCHAR2
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  DATE := fnd_api.g_miss_date
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  DATE := fnd_api.g_miss_date
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  DATE := fnd_api.g_miss_date
    , p6_a73  NUMBER := 0-1962.0724
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  NUMBER := 0-1962.0724
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  NUMBER := 0-1962.0724
    , p6_a86  NUMBER := 0-1962.0724
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddx_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_clev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_clev_rec.sfwt_flag := p6_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p6_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p6_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p6_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p6_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p6_a7);
    ddp_clev_rec.line_number := p6_a8;
    ddp_clev_rec.sts_code := p6_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p6_a10);
    ddp_clev_rec.trn_code := p6_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a12);
    ddp_clev_rec.comments := p6_a13;
    ddp_clev_rec.item_description := p6_a14;
    ddp_clev_rec.oke_boe_description := p6_a15;
    ddp_clev_rec.cognomen := p6_a16;
    ddp_clev_rec.hidden_ind := p6_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p6_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p6_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p6_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p6_a21);
    ddp_clev_rec.price_level_ind := p6_a22;
    ddp_clev_rec.invoice_line_level_ind := p6_a23;
    ddp_clev_rec.dpas_rating := p6_a24;
    ddp_clev_rec.block23text := p6_a25;
    ddp_clev_rec.exception_yn := p6_a26;
    ddp_clev_rec.template_used := p6_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p6_a28);
    ddp_clev_rec.name := p6_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p6_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p6_a32);
    ddp_clev_rec.upg_orig_system_ref := p6_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p6_a34);
    ddp_clev_rec.orig_system_source_code := p6_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p6_a36);
    ddp_clev_rec.orig_system_reference1 := p6_a37;
    ddp_clev_rec.attribute_category := p6_a38;
    ddp_clev_rec.attribute1 := p6_a39;
    ddp_clev_rec.attribute2 := p6_a40;
    ddp_clev_rec.attribute3 := p6_a41;
    ddp_clev_rec.attribute4 := p6_a42;
    ddp_clev_rec.attribute5 := p6_a43;
    ddp_clev_rec.attribute6 := p6_a44;
    ddp_clev_rec.attribute7 := p6_a45;
    ddp_clev_rec.attribute8 := p6_a46;
    ddp_clev_rec.attribute9 := p6_a47;
    ddp_clev_rec.attribute10 := p6_a48;
    ddp_clev_rec.attribute11 := p6_a49;
    ddp_clev_rec.attribute12 := p6_a50;
    ddp_clev_rec.attribute13 := p6_a51;
    ddp_clev_rec.attribute14 := p6_a52;
    ddp_clev_rec.attribute15 := p6_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p6_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a57);
    ddp_clev_rec.price_type := p6_a58;
    ddp_clev_rec.currency_code := p6_a59;
    ddp_clev_rec.currency_code_renewed := p6_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p6_a61);
    ddp_clev_rec.old_sts_code := p6_a62;
    ddp_clev_rec.new_sts_code := p6_a63;
    ddp_clev_rec.old_ste_code := p6_a64;
    ddp_clev_rec.new_ste_code := p6_a65;
    ddp_clev_rec.call_action_asmblr := p6_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p6_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p6_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p6_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p6_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p6_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p6_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p6_a74);
    ddp_clev_rec.item_to_price_yn := p6_a75;
    ddp_clev_rec.price_basis_yn := p6_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p6_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p6_a78);
    ddp_clev_rec.config_complete_yn := p6_a79;
    ddp_clev_rec.config_valid_yn := p6_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p6_a81);
    ddp_clev_rec.config_item_type := p6_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p6_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p6_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p6_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p6_a86);
    ddp_clev_rec.line_renewal_type_code := p6_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p6_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p6_a89);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      ddp_clev_rec,
      ddx_clev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_clev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_clev_rec.object_version_number);
    p7_a2 := ddx_clev_rec.sfwt_flag;
    p7_a3 := rosetta_g_miss_num_map(ddx_clev_rec.chr_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed);
    p7_a6 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed_to);
    p7_a7 := rosetta_g_miss_num_map(ddx_clev_rec.lse_id);
    p7_a8 := ddx_clev_rec.line_number;
    p7_a9 := ddx_clev_rec.sts_code;
    p7_a10 := rosetta_g_miss_num_map(ddx_clev_rec.display_sequence);
    p7_a11 := ddx_clev_rec.trn_code;
    p7_a12 := rosetta_g_miss_num_map(ddx_clev_rec.dnz_chr_id);
    p7_a13 := ddx_clev_rec.comments;
    p7_a14 := ddx_clev_rec.item_description;
    p7_a15 := ddx_clev_rec.oke_boe_description;
    p7_a16 := ddx_clev_rec.cognomen;
    p7_a17 := ddx_clev_rec.hidden_ind;
    p7_a18 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit);
    p7_a19 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit_percent);
    p7_a20 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated);
    p7_a21 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated_renewed);
    p7_a22 := ddx_clev_rec.price_level_ind;
    p7_a23 := ddx_clev_rec.invoice_line_level_ind;
    p7_a24 := ddx_clev_rec.dpas_rating;
    p7_a25 := ddx_clev_rec.block23text;
    p7_a26 := ddx_clev_rec.exception_yn;
    p7_a27 := ddx_clev_rec.template_used;
    p7_a28 := ddx_clev_rec.date_terminated;
    p7_a29 := ddx_clev_rec.name;
    p7_a30 := ddx_clev_rec.start_date;
    p7_a31 := ddx_clev_rec.end_date;
    p7_a32 := ddx_clev_rec.date_renewed;
    p7_a33 := ddx_clev_rec.upg_orig_system_ref;
    p7_a34 := rosetta_g_miss_num_map(ddx_clev_rec.upg_orig_system_ref_id);
    p7_a35 := ddx_clev_rec.orig_system_source_code;
    p7_a36 := rosetta_g_miss_num_map(ddx_clev_rec.orig_system_id1);
    p7_a37 := ddx_clev_rec.orig_system_reference1;
    p7_a38 := ddx_clev_rec.attribute_category;
    p7_a39 := ddx_clev_rec.attribute1;
    p7_a40 := ddx_clev_rec.attribute2;
    p7_a41 := ddx_clev_rec.attribute3;
    p7_a42 := ddx_clev_rec.attribute4;
    p7_a43 := ddx_clev_rec.attribute5;
    p7_a44 := ddx_clev_rec.attribute6;
    p7_a45 := ddx_clev_rec.attribute7;
    p7_a46 := ddx_clev_rec.attribute8;
    p7_a47 := ddx_clev_rec.attribute9;
    p7_a48 := ddx_clev_rec.attribute10;
    p7_a49 := ddx_clev_rec.attribute11;
    p7_a50 := ddx_clev_rec.attribute12;
    p7_a51 := ddx_clev_rec.attribute13;
    p7_a52 := ddx_clev_rec.attribute14;
    p7_a53 := ddx_clev_rec.attribute15;
    p7_a54 := rosetta_g_miss_num_map(ddx_clev_rec.created_by);
    p7_a55 := ddx_clev_rec.creation_date;
    p7_a56 := rosetta_g_miss_num_map(ddx_clev_rec.last_updated_by);
    p7_a57 := ddx_clev_rec.last_update_date;
    p7_a58 := ddx_clev_rec.price_type;
    p7_a59 := ddx_clev_rec.currency_code;
    p7_a60 := ddx_clev_rec.currency_code_renewed;
    p7_a61 := rosetta_g_miss_num_map(ddx_clev_rec.last_update_login);
    p7_a62 := ddx_clev_rec.old_sts_code;
    p7_a63 := ddx_clev_rec.new_sts_code;
    p7_a64 := ddx_clev_rec.old_ste_code;
    p7_a65 := ddx_clev_rec.new_ste_code;
    p7_a66 := ddx_clev_rec.call_action_asmblr;
    p7_a67 := rosetta_g_miss_num_map(ddx_clev_rec.request_id);
    p7_a68 := rosetta_g_miss_num_map(ddx_clev_rec.program_application_id);
    p7_a69 := rosetta_g_miss_num_map(ddx_clev_rec.program_id);
    p7_a70 := ddx_clev_rec.program_update_date;
    p7_a71 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_id);
    p7_a72 := ddx_clev_rec.pricing_date;
    p7_a73 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_line_id);
    p7_a74 := rosetta_g_miss_num_map(ddx_clev_rec.line_list_price);
    p7_a75 := ddx_clev_rec.item_to_price_yn;
    p7_a76 := ddx_clev_rec.price_basis_yn;
    p7_a77 := rosetta_g_miss_num_map(ddx_clev_rec.config_header_id);
    p7_a78 := rosetta_g_miss_num_map(ddx_clev_rec.config_revision_number);
    p7_a79 := ddx_clev_rec.config_complete_yn;
    p7_a80 := ddx_clev_rec.config_valid_yn;
    p7_a81 := rosetta_g_miss_num_map(ddx_clev_rec.config_top_model_line_id);
    p7_a82 := ddx_clev_rec.config_item_type;
    p7_a83 := rosetta_g_miss_num_map(ddx_clev_rec.config_item_id);
    p7_a84 := rosetta_g_miss_num_map(ddx_clev_rec.cust_acct_id);
    p7_a85 := rosetta_g_miss_num_map(ddx_clev_rec.bill_to_site_use_id);
    p7_a86 := rosetta_g_miss_num_map(ddx_clev_rec.inv_rule_id);
    p7_a87 := ddx_clev_rec.line_renewal_type_code;
    p7_a88 := rosetta_g_miss_num_map(ddx_clev_rec.ship_to_site_use_id);
    p7_a89 := rosetta_g_miss_num_map(ddx_clev_rec.payment_term_id);
  end;

  procedure create_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_VARCHAR2_TABLE_2000
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_VARCHAR2_TABLE_2000
    , p6_a26 JTF_VARCHAR2_TABLE_100
    , p6_a27 JTF_VARCHAR2_TABLE_200
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_VARCHAR2_TABLE_200
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_DATE_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_NUMBER_TABLE
    , p6_a70 JTF_DATE_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_DATE_TABLE
    , p6_a73 JTF_NUMBER_TABLE
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_VARCHAR2_TABLE_100
    , p6_a80 JTF_VARCHAR2_TABLE_100
    , p6_a81 JTF_NUMBER_TABLE
    , p6_a82 JTF_VARCHAR2_TABLE_100
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_NUMBER_TABLE
    , p6_a85 JTF_NUMBER_TABLE
    , p6_a86 JTF_NUMBER_TABLE
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a20 out nocopy JTF_NUMBER_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_DATE_TABLE
    , p7_a31 out nocopy JTF_DATE_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a54 out nocopy JTF_NUMBER_TABLE
    , p7_a55 out nocopy JTF_DATE_TABLE
    , p7_a56 out nocopy JTF_NUMBER_TABLE
    , p7_a57 out nocopy JTF_DATE_TABLE
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a61 out nocopy JTF_NUMBER_TABLE
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_NUMBER_TABLE
    , p7_a68 out nocopy JTF_NUMBER_TABLE
    , p7_a69 out nocopy JTF_NUMBER_TABLE
    , p7_a70 out nocopy JTF_DATE_TABLE
    , p7_a71 out nocopy JTF_NUMBER_TABLE
    , p7_a72 out nocopy JTF_DATE_TABLE
    , p7_a73 out nocopy JTF_NUMBER_TABLE
    , p7_a74 out nocopy JTF_NUMBER_TABLE
    , p7_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a77 out nocopy JTF_NUMBER_TABLE
    , p7_a78 out nocopy JTF_NUMBER_TABLE
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a81 out nocopy JTF_NUMBER_TABLE
    , p7_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a83 out nocopy JTF_NUMBER_TABLE
    , p7_a84 out nocopy JTF_NUMBER_TABLE
    , p7_a85 out nocopy JTF_NUMBER_TABLE
    , p7_a86 out nocopy JTF_NUMBER_TABLE
    , p7_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a88 out nocopy JTF_NUMBER_TABLE
    , p7_a89 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddx_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p6_a0
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
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      ddp_clev_tbl,
      ddx_clev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p7_a0
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
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );
  end;

  procedure update_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  DATE
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  DATE
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  DATE
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  DATE
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  NUMBER
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  VARCHAR2
    , p7_a81 out nocopy  NUMBER
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  NUMBER
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  NUMBER
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  VARCHAR2
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  DATE := fnd_api.g_miss_date
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  DATE := fnd_api.g_miss_date
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  DATE := fnd_api.g_miss_date
    , p6_a73  NUMBER := 0-1962.0724
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  NUMBER := 0-1962.0724
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  NUMBER := 0-1962.0724
    , p6_a86  NUMBER := 0-1962.0724
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddx_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_clev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_clev_rec.sfwt_flag := p6_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p6_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p6_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p6_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p6_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p6_a7);
    ddp_clev_rec.line_number := p6_a8;
    ddp_clev_rec.sts_code := p6_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p6_a10);
    ddp_clev_rec.trn_code := p6_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a12);
    ddp_clev_rec.comments := p6_a13;
    ddp_clev_rec.item_description := p6_a14;
    ddp_clev_rec.oke_boe_description := p6_a15;
    ddp_clev_rec.cognomen := p6_a16;
    ddp_clev_rec.hidden_ind := p6_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p6_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p6_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p6_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p6_a21);
    ddp_clev_rec.price_level_ind := p6_a22;
    ddp_clev_rec.invoice_line_level_ind := p6_a23;
    ddp_clev_rec.dpas_rating := p6_a24;
    ddp_clev_rec.block23text := p6_a25;
    ddp_clev_rec.exception_yn := p6_a26;
    ddp_clev_rec.template_used := p6_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p6_a28);
    ddp_clev_rec.name := p6_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p6_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p6_a32);
    ddp_clev_rec.upg_orig_system_ref := p6_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p6_a34);
    ddp_clev_rec.orig_system_source_code := p6_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p6_a36);
    ddp_clev_rec.orig_system_reference1 := p6_a37;
    ddp_clev_rec.attribute_category := p6_a38;
    ddp_clev_rec.attribute1 := p6_a39;
    ddp_clev_rec.attribute2 := p6_a40;
    ddp_clev_rec.attribute3 := p6_a41;
    ddp_clev_rec.attribute4 := p6_a42;
    ddp_clev_rec.attribute5 := p6_a43;
    ddp_clev_rec.attribute6 := p6_a44;
    ddp_clev_rec.attribute7 := p6_a45;
    ddp_clev_rec.attribute8 := p6_a46;
    ddp_clev_rec.attribute9 := p6_a47;
    ddp_clev_rec.attribute10 := p6_a48;
    ddp_clev_rec.attribute11 := p6_a49;
    ddp_clev_rec.attribute12 := p6_a50;
    ddp_clev_rec.attribute13 := p6_a51;
    ddp_clev_rec.attribute14 := p6_a52;
    ddp_clev_rec.attribute15 := p6_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p6_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a57);
    ddp_clev_rec.price_type := p6_a58;
    ddp_clev_rec.currency_code := p6_a59;
    ddp_clev_rec.currency_code_renewed := p6_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p6_a61);
    ddp_clev_rec.old_sts_code := p6_a62;
    ddp_clev_rec.new_sts_code := p6_a63;
    ddp_clev_rec.old_ste_code := p6_a64;
    ddp_clev_rec.new_ste_code := p6_a65;
    ddp_clev_rec.call_action_asmblr := p6_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p6_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p6_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p6_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p6_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p6_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p6_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p6_a74);
    ddp_clev_rec.item_to_price_yn := p6_a75;
    ddp_clev_rec.price_basis_yn := p6_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p6_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p6_a78);
    ddp_clev_rec.config_complete_yn := p6_a79;
    ddp_clev_rec.config_valid_yn := p6_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p6_a81);
    ddp_clev_rec.config_item_type := p6_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p6_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p6_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p6_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p6_a86);
    ddp_clev_rec.line_renewal_type_code := p6_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p6_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p6_a89);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      ddp_clev_rec,
      ddx_clev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_clev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_clev_rec.object_version_number);
    p7_a2 := ddx_clev_rec.sfwt_flag;
    p7_a3 := rosetta_g_miss_num_map(ddx_clev_rec.chr_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed);
    p7_a6 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed_to);
    p7_a7 := rosetta_g_miss_num_map(ddx_clev_rec.lse_id);
    p7_a8 := ddx_clev_rec.line_number;
    p7_a9 := ddx_clev_rec.sts_code;
    p7_a10 := rosetta_g_miss_num_map(ddx_clev_rec.display_sequence);
    p7_a11 := ddx_clev_rec.trn_code;
    p7_a12 := rosetta_g_miss_num_map(ddx_clev_rec.dnz_chr_id);
    p7_a13 := ddx_clev_rec.comments;
    p7_a14 := ddx_clev_rec.item_description;
    p7_a15 := ddx_clev_rec.oke_boe_description;
    p7_a16 := ddx_clev_rec.cognomen;
    p7_a17 := ddx_clev_rec.hidden_ind;
    p7_a18 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit);
    p7_a19 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit_percent);
    p7_a20 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated);
    p7_a21 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated_renewed);
    p7_a22 := ddx_clev_rec.price_level_ind;
    p7_a23 := ddx_clev_rec.invoice_line_level_ind;
    p7_a24 := ddx_clev_rec.dpas_rating;
    p7_a25 := ddx_clev_rec.block23text;
    p7_a26 := ddx_clev_rec.exception_yn;
    p7_a27 := ddx_clev_rec.template_used;
    p7_a28 := ddx_clev_rec.date_terminated;
    p7_a29 := ddx_clev_rec.name;
    p7_a30 := ddx_clev_rec.start_date;
    p7_a31 := ddx_clev_rec.end_date;
    p7_a32 := ddx_clev_rec.date_renewed;
    p7_a33 := ddx_clev_rec.upg_orig_system_ref;
    p7_a34 := rosetta_g_miss_num_map(ddx_clev_rec.upg_orig_system_ref_id);
    p7_a35 := ddx_clev_rec.orig_system_source_code;
    p7_a36 := rosetta_g_miss_num_map(ddx_clev_rec.orig_system_id1);
    p7_a37 := ddx_clev_rec.orig_system_reference1;
    p7_a38 := ddx_clev_rec.attribute_category;
    p7_a39 := ddx_clev_rec.attribute1;
    p7_a40 := ddx_clev_rec.attribute2;
    p7_a41 := ddx_clev_rec.attribute3;
    p7_a42 := ddx_clev_rec.attribute4;
    p7_a43 := ddx_clev_rec.attribute5;
    p7_a44 := ddx_clev_rec.attribute6;
    p7_a45 := ddx_clev_rec.attribute7;
    p7_a46 := ddx_clev_rec.attribute8;
    p7_a47 := ddx_clev_rec.attribute9;
    p7_a48 := ddx_clev_rec.attribute10;
    p7_a49 := ddx_clev_rec.attribute11;
    p7_a50 := ddx_clev_rec.attribute12;
    p7_a51 := ddx_clev_rec.attribute13;
    p7_a52 := ddx_clev_rec.attribute14;
    p7_a53 := ddx_clev_rec.attribute15;
    p7_a54 := rosetta_g_miss_num_map(ddx_clev_rec.created_by);
    p7_a55 := ddx_clev_rec.creation_date;
    p7_a56 := rosetta_g_miss_num_map(ddx_clev_rec.last_updated_by);
    p7_a57 := ddx_clev_rec.last_update_date;
    p7_a58 := ddx_clev_rec.price_type;
    p7_a59 := ddx_clev_rec.currency_code;
    p7_a60 := ddx_clev_rec.currency_code_renewed;
    p7_a61 := rosetta_g_miss_num_map(ddx_clev_rec.last_update_login);
    p7_a62 := ddx_clev_rec.old_sts_code;
    p7_a63 := ddx_clev_rec.new_sts_code;
    p7_a64 := ddx_clev_rec.old_ste_code;
    p7_a65 := ddx_clev_rec.new_ste_code;
    p7_a66 := ddx_clev_rec.call_action_asmblr;
    p7_a67 := rosetta_g_miss_num_map(ddx_clev_rec.request_id);
    p7_a68 := rosetta_g_miss_num_map(ddx_clev_rec.program_application_id);
    p7_a69 := rosetta_g_miss_num_map(ddx_clev_rec.program_id);
    p7_a70 := ddx_clev_rec.program_update_date;
    p7_a71 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_id);
    p7_a72 := ddx_clev_rec.pricing_date;
    p7_a73 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_line_id);
    p7_a74 := rosetta_g_miss_num_map(ddx_clev_rec.line_list_price);
    p7_a75 := ddx_clev_rec.item_to_price_yn;
    p7_a76 := ddx_clev_rec.price_basis_yn;
    p7_a77 := rosetta_g_miss_num_map(ddx_clev_rec.config_header_id);
    p7_a78 := rosetta_g_miss_num_map(ddx_clev_rec.config_revision_number);
    p7_a79 := ddx_clev_rec.config_complete_yn;
    p7_a80 := ddx_clev_rec.config_valid_yn;
    p7_a81 := rosetta_g_miss_num_map(ddx_clev_rec.config_top_model_line_id);
    p7_a82 := ddx_clev_rec.config_item_type;
    p7_a83 := rosetta_g_miss_num_map(ddx_clev_rec.config_item_id);
    p7_a84 := rosetta_g_miss_num_map(ddx_clev_rec.cust_acct_id);
    p7_a85 := rosetta_g_miss_num_map(ddx_clev_rec.bill_to_site_use_id);
    p7_a86 := rosetta_g_miss_num_map(ddx_clev_rec.inv_rule_id);
    p7_a87 := ddx_clev_rec.line_renewal_type_code;
    p7_a88 := rosetta_g_miss_num_map(ddx_clev_rec.ship_to_site_use_id);
    p7_a89 := rosetta_g_miss_num_map(ddx_clev_rec.payment_term_id);
  end;

  procedure update_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_VARCHAR2_TABLE_2000
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_VARCHAR2_TABLE_2000
    , p6_a26 JTF_VARCHAR2_TABLE_100
    , p6_a27 JTF_VARCHAR2_TABLE_200
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_VARCHAR2_TABLE_200
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_DATE_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_NUMBER_TABLE
    , p6_a70 JTF_DATE_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_DATE_TABLE
    , p6_a73 JTF_NUMBER_TABLE
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_VARCHAR2_TABLE_100
    , p6_a80 JTF_VARCHAR2_TABLE_100
    , p6_a81 JTF_NUMBER_TABLE
    , p6_a82 JTF_VARCHAR2_TABLE_100
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_NUMBER_TABLE
    , p6_a85 JTF_NUMBER_TABLE
    , p6_a86 JTF_NUMBER_TABLE
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a20 out nocopy JTF_NUMBER_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_DATE_TABLE
    , p7_a31 out nocopy JTF_DATE_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a54 out nocopy JTF_NUMBER_TABLE
    , p7_a55 out nocopy JTF_DATE_TABLE
    , p7_a56 out nocopy JTF_NUMBER_TABLE
    , p7_a57 out nocopy JTF_DATE_TABLE
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a61 out nocopy JTF_NUMBER_TABLE
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_NUMBER_TABLE
    , p7_a68 out nocopy JTF_NUMBER_TABLE
    , p7_a69 out nocopy JTF_NUMBER_TABLE
    , p7_a70 out nocopy JTF_DATE_TABLE
    , p7_a71 out nocopy JTF_NUMBER_TABLE
    , p7_a72 out nocopy JTF_DATE_TABLE
    , p7_a73 out nocopy JTF_NUMBER_TABLE
    , p7_a74 out nocopy JTF_NUMBER_TABLE
    , p7_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a77 out nocopy JTF_NUMBER_TABLE
    , p7_a78 out nocopy JTF_NUMBER_TABLE
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a81 out nocopy JTF_NUMBER_TABLE
    , p7_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a83 out nocopy JTF_NUMBER_TABLE
    , p7_a84 out nocopy JTF_NUMBER_TABLE
    , p7_a85 out nocopy JTF_NUMBER_TABLE
    , p7_a86 out nocopy JTF_NUMBER_TABLE
    , p7_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a88 out nocopy JTF_NUMBER_TABLE
    , p7_a89 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddx_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p6_a0
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
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      ddp_clev_tbl,
      ddx_clev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p7_a0
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
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );
  end;

  procedure delete_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_contract_line(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
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
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
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
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.lock_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.validate_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_governance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddx_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gvev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_gvev_rec.isa_agreement_id := rosetta_g_miss_num_map(p5_a2);
    ddp_gvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_gvev_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_gvev_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_gvev_rec.chr_id_referred := rosetta_g_miss_num_map(p5_a6);
    ddp_gvev_rec.cle_id_referred := rosetta_g_miss_num_map(p5_a7);
    ddp_gvev_rec.copied_only_yn := p5_a8;
    ddp_gvev_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_governance(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gvev_rec,
      ddx_gvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_gvev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_gvev_rec.dnz_chr_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_gvev_rec.isa_agreement_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_gvev_rec.object_version_number);
    p6_a4 := rosetta_g_miss_num_map(ddx_gvev_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_gvev_rec.cle_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_gvev_rec.chr_id_referred);
    p6_a7 := rosetta_g_miss_num_map(ddx_gvev_rec.cle_id_referred);
    p6_a8 := ddx_gvev_rec.copied_only_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_gvev_rec.created_by);
    p6_a10 := ddx_gvev_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_gvev_rec.last_updated_by);
    p6_a12 := ddx_gvev_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_gvev_rec.last_update_login);
  end;

  procedure update_governance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddx_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gvev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_gvev_rec.isa_agreement_id := rosetta_g_miss_num_map(p5_a2);
    ddp_gvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_gvev_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_gvev_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_gvev_rec.chr_id_referred := rosetta_g_miss_num_map(p5_a6);
    ddp_gvev_rec.cle_id_referred := rosetta_g_miss_num_map(p5_a7);
    ddp_gvev_rec.copied_only_yn := p5_a8;
    ddp_gvev_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_governance(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gvev_rec,
      ddx_gvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_gvev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_gvev_rec.dnz_chr_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_gvev_rec.isa_agreement_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_gvev_rec.object_version_number);
    p6_a4 := rosetta_g_miss_num_map(ddx_gvev_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_gvev_rec.cle_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_gvev_rec.chr_id_referred);
    p6_a7 := rosetta_g_miss_num_map(ddx_gvev_rec.cle_id_referred);
    p6_a8 := ddx_gvev_rec.copied_only_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_gvev_rec.created_by);
    p6_a10 := ddx_gvev_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_gvev_rec.last_updated_by);
    p6_a12 := ddx_gvev_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_gvev_rec.last_update_login);
  end;

  procedure delete_governance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gvev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_gvev_rec.isa_agreement_id := rosetta_g_miss_num_map(p5_a2);
    ddp_gvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_gvev_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_gvev_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_gvev_rec.chr_id_referred := rosetta_g_miss_num_map(p5_a6);
    ddp_gvev_rec.cle_id_referred := rosetta_g_miss_num_map(p5_a7);
    ddp_gvev_rec.copied_only_yn := p5_a8;
    ddp_gvev_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_governance(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_governance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gvev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_gvev_rec.isa_agreement_id := rosetta_g_miss_num_map(p5_a2);
    ddp_gvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_gvev_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_gvev_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_gvev_rec.chr_id_referred := rosetta_g_miss_num_map(p5_a6);
    ddp_gvev_rec.cle_id_referred := rosetta_g_miss_num_map(p5_a7);
    ddp_gvev_rec.copied_only_yn := p5_a8;
    ddp_gvev_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.lock_governance(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_governance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_gvev_rec okl_okc_migration_pvt.gvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_gvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_gvev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_gvev_rec.isa_agreement_id := rosetta_g_miss_num_map(p5_a2);
    ddp_gvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_gvev_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_gvev_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_gvev_rec.chr_id_referred := rosetta_g_miss_num_map(p5_a6);
    ddp_gvev_rec.cle_id_referred := rosetta_g_miss_num_map(p5_a7);
    ddp_gvev_rec.copied_only_yn := p5_a8;
    ddp_gvev_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_gvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_gvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_gvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_gvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.validate_governance(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_gvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure version_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_commit  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
  )

  as
    ddp_cvmv_rec okl_okc_migration_pvt.cvmv_rec_type;
    ddx_cvmv_rec okl_okc_migration_pvt.cvmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cvmv_rec.chr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_cvmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cvmv_rec.major_version := rosetta_g_miss_num_map(p5_a2);
    ddp_cvmv_rec.minor_version := rosetta_g_miss_num_map(p5_a3);
    ddp_cvmv_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_cvmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_cvmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_cvmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_cvmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a8);



    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.version_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cvmv_rec,
      p_commit,
      ddx_cvmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_cvmv_rec.chr_id);
    p7_a1 := rosetta_g_miss_num_map(ddx_cvmv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_cvmv_rec.major_version);
    p7_a3 := rosetta_g_miss_num_map(ddx_cvmv_rec.minor_version);
    p7_a4 := rosetta_g_miss_num_map(ddx_cvmv_rec.created_by);
    p7_a5 := ddx_cvmv_rec.creation_date;
    p7_a6 := rosetta_g_miss_num_map(ddx_cvmv_rec.last_updated_by);
    p7_a7 := ddx_cvmv_rec.last_update_date;
    p7_a8 := rosetta_g_miss_num_map(ddx_cvmv_rec.last_update_login);
  end;

  procedure version_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p_commit  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_DATE_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cvmv_tbl okl_okc_migration_pvt.cvmv_tbl_type;
    ddx_cvmv_tbl okl_okc_migration_pvt.cvmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p1(ddp_cvmv_tbl, p5_a0
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
    okl_okc_migration_pvt.version_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cvmv_tbl,
      p_commit,
      ddx_cvmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_out_p1(ddx_cvmv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      );
  end;

  procedure create_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_cimv_rec okl_okc_migration_pvt.cimv_rec_type;
    ddx_cimv_rec okl_okc_migration_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cimv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p5_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cimv_rec.object1_id1 := p5_a6;
    ddp_cimv_rec.object1_id2 := p5_a7;
    ddp_cimv_rec.jtot_object1_code := p5_a8;
    ddp_cimv_rec.uom_code := p5_a9;
    ddp_cimv_rec.exception_yn := p5_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p5_a11);
    ddp_cimv_rec.upg_orig_system_ref := p5_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a13);
    ddp_cimv_rec.priced_item_yn := p5_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_rec,
      ddx_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cimv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cimv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_cimv_rec.chr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id_for);
    p6_a5 := rosetta_g_miss_num_map(ddx_cimv_rec.dnz_chr_id);
    p6_a6 := ddx_cimv_rec.object1_id1;
    p6_a7 := ddx_cimv_rec.object1_id2;
    p6_a8 := ddx_cimv_rec.jtot_object1_code;
    p6_a9 := ddx_cimv_rec.uom_code;
    p6_a10 := ddx_cimv_rec.exception_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_cimv_rec.number_of_items);
    p6_a12 := ddx_cimv_rec.upg_orig_system_ref;
    p6_a13 := rosetta_g_miss_num_map(ddx_cimv_rec.upg_orig_system_ref_id);
    p6_a14 := ddx_cimv_rec.priced_item_yn;
    p6_a15 := rosetta_g_miss_num_map(ddx_cimv_rec.created_by);
    p6_a16 := ddx_cimv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_cimv_rec.last_updated_by);
    p6_a18 := ddx_cimv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_cimv_rec.last_update_login);
  end;

  procedure create_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cimv_tbl okl_okc_migration_pvt.cimv_tbl_type;
    ddx_cimv_tbl okl_okc_migration_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p5_a0
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
    okl_okc_migration_pvt.create_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_tbl,
      ddx_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p6_a0
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

  procedure update_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_cimv_rec okl_okc_migration_pvt.cimv_rec_type;
    ddx_cimv_rec okl_okc_migration_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cimv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p5_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cimv_rec.object1_id1 := p5_a6;
    ddp_cimv_rec.object1_id2 := p5_a7;
    ddp_cimv_rec.jtot_object1_code := p5_a8;
    ddp_cimv_rec.uom_code := p5_a9;
    ddp_cimv_rec.exception_yn := p5_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p5_a11);
    ddp_cimv_rec.upg_orig_system_ref := p5_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a13);
    ddp_cimv_rec.priced_item_yn := p5_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_rec,
      ddx_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cimv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cimv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_cimv_rec.chr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id_for);
    p6_a5 := rosetta_g_miss_num_map(ddx_cimv_rec.dnz_chr_id);
    p6_a6 := ddx_cimv_rec.object1_id1;
    p6_a7 := ddx_cimv_rec.object1_id2;
    p6_a8 := ddx_cimv_rec.jtot_object1_code;
    p6_a9 := ddx_cimv_rec.uom_code;
    p6_a10 := ddx_cimv_rec.exception_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_cimv_rec.number_of_items);
    p6_a12 := ddx_cimv_rec.upg_orig_system_ref;
    p6_a13 := rosetta_g_miss_num_map(ddx_cimv_rec.upg_orig_system_ref_id);
    p6_a14 := ddx_cimv_rec.priced_item_yn;
    p6_a15 := rosetta_g_miss_num_map(ddx_cimv_rec.created_by);
    p6_a16 := ddx_cimv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_cimv_rec.last_updated_by);
    p6_a18 := ddx_cimv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_cimv_rec.last_update_login);
  end;

  procedure update_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cimv_tbl okl_okc_migration_pvt.cimv_tbl_type;
    ddx_cimv_tbl okl_okc_migration_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p5_a0
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
    okl_okc_migration_pvt.update_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_tbl,
      ddx_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p6_a0
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

  procedure delete_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_cimv_rec okl_okc_migration_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cimv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p5_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cimv_rec.object1_id1 := p5_a6;
    ddp_cimv_rec.object1_id2 := p5_a7;
    ddp_cimv_rec.jtot_object1_code := p5_a8;
    ddp_cimv_rec.uom_code := p5_a9;
    ddp_cimv_rec.exception_yn := p5_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p5_a11);
    ddp_cimv_rec.upg_orig_system_ref := p5_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a13);
    ddp_cimv_rec.priced_item_yn := p5_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_contract_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_cimv_tbl okl_okc_migration_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p5_a0
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
    okl_okc_migration_pvt.delete_contract_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_k_party_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  )

  as
    ddp_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    ddx_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cplv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cplv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cplv_rec.sfwt_flag := p5_a2;
    ddp_cplv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cplv_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cplv_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cplv_rec.rle_code := p5_a6;
    ddp_cplv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cplv_rec.object1_id1 := p5_a8;
    ddp_cplv_rec.object1_id2 := p5_a9;
    ddp_cplv_rec.jtot_object1_code := p5_a10;
    ddp_cplv_rec.cognomen := p5_a11;
    ddp_cplv_rec.code := p5_a12;
    ddp_cplv_rec.facility := p5_a13;
    ddp_cplv_rec.minority_group_lookup_code := p5_a14;
    ddp_cplv_rec.small_business_flag := p5_a15;
    ddp_cplv_rec.women_owned_flag := p5_a16;
    ddp_cplv_rec.alias := p5_a17;
    ddp_cplv_rec.attribute_category := p5_a18;
    ddp_cplv_rec.attribute1 := p5_a19;
    ddp_cplv_rec.attribute2 := p5_a20;
    ddp_cplv_rec.attribute3 := p5_a21;
    ddp_cplv_rec.attribute4 := p5_a22;
    ddp_cplv_rec.attribute5 := p5_a23;
    ddp_cplv_rec.attribute6 := p5_a24;
    ddp_cplv_rec.attribute7 := p5_a25;
    ddp_cplv_rec.attribute8 := p5_a26;
    ddp_cplv_rec.attribute9 := p5_a27;
    ddp_cplv_rec.attribute10 := p5_a28;
    ddp_cplv_rec.attribute11 := p5_a29;
    ddp_cplv_rec.attribute12 := p5_a30;
    ddp_cplv_rec.attribute13 := p5_a31;
    ddp_cplv_rec.attribute14 := p5_a32;
    ddp_cplv_rec.attribute15 := p5_a33;
    ddp_cplv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_cplv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_cplv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cplv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_cplv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_cplv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a39);
    ddp_cplv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a40);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_rec,
      ddx_cplv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cplv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cplv_rec.object_version_number);
    p6_a2 := ddx_cplv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_cplv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cplv_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_cplv_rec.cle_id);
    p6_a6 := ddx_cplv_rec.rle_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_cplv_rec.dnz_chr_id);
    p6_a8 := ddx_cplv_rec.object1_id1;
    p6_a9 := ddx_cplv_rec.object1_id2;
    p6_a10 := ddx_cplv_rec.jtot_object1_code;
    p6_a11 := ddx_cplv_rec.cognomen;
    p6_a12 := ddx_cplv_rec.code;
    p6_a13 := ddx_cplv_rec.facility;
    p6_a14 := ddx_cplv_rec.minority_group_lookup_code;
    p6_a15 := ddx_cplv_rec.small_business_flag;
    p6_a16 := ddx_cplv_rec.women_owned_flag;
    p6_a17 := ddx_cplv_rec.alias;
    p6_a18 := ddx_cplv_rec.attribute_category;
    p6_a19 := ddx_cplv_rec.attribute1;
    p6_a20 := ddx_cplv_rec.attribute2;
    p6_a21 := ddx_cplv_rec.attribute3;
    p6_a22 := ddx_cplv_rec.attribute4;
    p6_a23 := ddx_cplv_rec.attribute5;
    p6_a24 := ddx_cplv_rec.attribute6;
    p6_a25 := ddx_cplv_rec.attribute7;
    p6_a26 := ddx_cplv_rec.attribute8;
    p6_a27 := ddx_cplv_rec.attribute9;
    p6_a28 := ddx_cplv_rec.attribute10;
    p6_a29 := ddx_cplv_rec.attribute11;
    p6_a30 := ddx_cplv_rec.attribute12;
    p6_a31 := ddx_cplv_rec.attribute13;
    p6_a32 := ddx_cplv_rec.attribute14;
    p6_a33 := ddx_cplv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_cplv_rec.created_by);
    p6_a35 := ddx_cplv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_cplv_rec.last_updated_by);
    p6_a37 := ddx_cplv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_cplv_rec.last_update_login);
    p6_a39 := rosetta_g_miss_num_map(ddx_cplv_rec.cust_acct_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_cplv_rec.bill_to_site_use_id);
  end;

  procedure create_k_party_role(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cplv_tbl okl_okc_migration_pvt.cplv_tbl_type;
    ddx_cplv_tbl okl_okc_migration_pvt.cplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p9(ddp_cplv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_tbl,
      ddx_cplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p9(ddx_cplv_tbl, p6_a0
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
      );
  end;

  procedure update_k_party_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  )

  as
    ddp_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    ddx_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cplv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cplv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cplv_rec.sfwt_flag := p5_a2;
    ddp_cplv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cplv_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cplv_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cplv_rec.rle_code := p5_a6;
    ddp_cplv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cplv_rec.object1_id1 := p5_a8;
    ddp_cplv_rec.object1_id2 := p5_a9;
    ddp_cplv_rec.jtot_object1_code := p5_a10;
    ddp_cplv_rec.cognomen := p5_a11;
    ddp_cplv_rec.code := p5_a12;
    ddp_cplv_rec.facility := p5_a13;
    ddp_cplv_rec.minority_group_lookup_code := p5_a14;
    ddp_cplv_rec.small_business_flag := p5_a15;
    ddp_cplv_rec.women_owned_flag := p5_a16;
    ddp_cplv_rec.alias := p5_a17;
    ddp_cplv_rec.attribute_category := p5_a18;
    ddp_cplv_rec.attribute1 := p5_a19;
    ddp_cplv_rec.attribute2 := p5_a20;
    ddp_cplv_rec.attribute3 := p5_a21;
    ddp_cplv_rec.attribute4 := p5_a22;
    ddp_cplv_rec.attribute5 := p5_a23;
    ddp_cplv_rec.attribute6 := p5_a24;
    ddp_cplv_rec.attribute7 := p5_a25;
    ddp_cplv_rec.attribute8 := p5_a26;
    ddp_cplv_rec.attribute9 := p5_a27;
    ddp_cplv_rec.attribute10 := p5_a28;
    ddp_cplv_rec.attribute11 := p5_a29;
    ddp_cplv_rec.attribute12 := p5_a30;
    ddp_cplv_rec.attribute13 := p5_a31;
    ddp_cplv_rec.attribute14 := p5_a32;
    ddp_cplv_rec.attribute15 := p5_a33;
    ddp_cplv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_cplv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_cplv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cplv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_cplv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_cplv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a39);
    ddp_cplv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a40);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_rec,
      ddx_cplv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cplv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cplv_rec.object_version_number);
    p6_a2 := ddx_cplv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_cplv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cplv_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_cplv_rec.cle_id);
    p6_a6 := ddx_cplv_rec.rle_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_cplv_rec.dnz_chr_id);
    p6_a8 := ddx_cplv_rec.object1_id1;
    p6_a9 := ddx_cplv_rec.object1_id2;
    p6_a10 := ddx_cplv_rec.jtot_object1_code;
    p6_a11 := ddx_cplv_rec.cognomen;
    p6_a12 := ddx_cplv_rec.code;
    p6_a13 := ddx_cplv_rec.facility;
    p6_a14 := ddx_cplv_rec.minority_group_lookup_code;
    p6_a15 := ddx_cplv_rec.small_business_flag;
    p6_a16 := ddx_cplv_rec.women_owned_flag;
    p6_a17 := ddx_cplv_rec.alias;
    p6_a18 := ddx_cplv_rec.attribute_category;
    p6_a19 := ddx_cplv_rec.attribute1;
    p6_a20 := ddx_cplv_rec.attribute2;
    p6_a21 := ddx_cplv_rec.attribute3;
    p6_a22 := ddx_cplv_rec.attribute4;
    p6_a23 := ddx_cplv_rec.attribute5;
    p6_a24 := ddx_cplv_rec.attribute6;
    p6_a25 := ddx_cplv_rec.attribute7;
    p6_a26 := ddx_cplv_rec.attribute8;
    p6_a27 := ddx_cplv_rec.attribute9;
    p6_a28 := ddx_cplv_rec.attribute10;
    p6_a29 := ddx_cplv_rec.attribute11;
    p6_a30 := ddx_cplv_rec.attribute12;
    p6_a31 := ddx_cplv_rec.attribute13;
    p6_a32 := ddx_cplv_rec.attribute14;
    p6_a33 := ddx_cplv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_cplv_rec.created_by);
    p6_a35 := ddx_cplv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_cplv_rec.last_updated_by);
    p6_a37 := ddx_cplv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_cplv_rec.last_update_login);
    p6_a39 := rosetta_g_miss_num_map(ddx_cplv_rec.cust_acct_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_cplv_rec.bill_to_site_use_id);
  end;

  procedure update_k_party_role(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cplv_tbl okl_okc_migration_pvt.cplv_tbl_type;
    ddx_cplv_tbl okl_okc_migration_pvt.cplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p9(ddp_cplv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_tbl,
      ddx_cplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p9(ddx_cplv_tbl, p6_a0
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
      );
  end;

  procedure delete_k_party_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  )

  as
    ddp_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cplv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cplv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cplv_rec.sfwt_flag := p5_a2;
    ddp_cplv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cplv_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cplv_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cplv_rec.rle_code := p5_a6;
    ddp_cplv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cplv_rec.object1_id1 := p5_a8;
    ddp_cplv_rec.object1_id2 := p5_a9;
    ddp_cplv_rec.jtot_object1_code := p5_a10;
    ddp_cplv_rec.cognomen := p5_a11;
    ddp_cplv_rec.code := p5_a12;
    ddp_cplv_rec.facility := p5_a13;
    ddp_cplv_rec.minority_group_lookup_code := p5_a14;
    ddp_cplv_rec.small_business_flag := p5_a15;
    ddp_cplv_rec.women_owned_flag := p5_a16;
    ddp_cplv_rec.alias := p5_a17;
    ddp_cplv_rec.attribute_category := p5_a18;
    ddp_cplv_rec.attribute1 := p5_a19;
    ddp_cplv_rec.attribute2 := p5_a20;
    ddp_cplv_rec.attribute3 := p5_a21;
    ddp_cplv_rec.attribute4 := p5_a22;
    ddp_cplv_rec.attribute5 := p5_a23;
    ddp_cplv_rec.attribute6 := p5_a24;
    ddp_cplv_rec.attribute7 := p5_a25;
    ddp_cplv_rec.attribute8 := p5_a26;
    ddp_cplv_rec.attribute9 := p5_a27;
    ddp_cplv_rec.attribute10 := p5_a28;
    ddp_cplv_rec.attribute11 := p5_a29;
    ddp_cplv_rec.attribute12 := p5_a30;
    ddp_cplv_rec.attribute13 := p5_a31;
    ddp_cplv_rec.attribute14 := p5_a32;
    ddp_cplv_rec.attribute15 := p5_a33;
    ddp_cplv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_cplv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_cplv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cplv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_cplv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_cplv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a39);
    ddp_cplv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a40);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_k_party_role(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
  )

  as
    ddp_cplv_tbl okl_okc_migration_pvt.cplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p9(ddp_cplv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_k_party_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
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
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
  )

  as
    ddp_ctcv_rec okl_okc_migration_pvt.ctcv_rec_type;
    ddx_ctcv_rec okl_okc_migration_pvt.ctcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ctcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ctcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ctcv_rec.cpl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ctcv_rec.cro_code := p5_a3;
    ddp_ctcv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ctcv_rec.contact_sequence := rosetta_g_miss_num_map(p5_a5);
    ddp_ctcv_rec.object1_id1 := p5_a6;
    ddp_ctcv_rec.object1_id2 := p5_a7;
    ddp_ctcv_rec.jtot_object1_code := p5_a8;
    ddp_ctcv_rec.attribute_category := p5_a9;
    ddp_ctcv_rec.attribute1 := p5_a10;
    ddp_ctcv_rec.attribute2 := p5_a11;
    ddp_ctcv_rec.attribute3 := p5_a12;
    ddp_ctcv_rec.attribute4 := p5_a13;
    ddp_ctcv_rec.attribute5 := p5_a14;
    ddp_ctcv_rec.attribute6 := p5_a15;
    ddp_ctcv_rec.attribute7 := p5_a16;
    ddp_ctcv_rec.attribute8 := p5_a17;
    ddp_ctcv_rec.attribute9 := p5_a18;
    ddp_ctcv_rec.attribute10 := p5_a19;
    ddp_ctcv_rec.attribute11 := p5_a20;
    ddp_ctcv_rec.attribute12 := p5_a21;
    ddp_ctcv_rec.attribute13 := p5_a22;
    ddp_ctcv_rec.attribute14 := p5_a23;
    ddp_ctcv_rec.attribute15 := p5_a24;
    ddp_ctcv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_ctcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ctcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_ctcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_ctcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_ctcv_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_ctcv_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_rec,
      ddx_ctcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ctcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ctcv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ctcv_rec.cpl_id);
    p6_a3 := ddx_ctcv_rec.cro_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_ctcv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_ctcv_rec.contact_sequence);
    p6_a6 := ddx_ctcv_rec.object1_id1;
    p6_a7 := ddx_ctcv_rec.object1_id2;
    p6_a8 := ddx_ctcv_rec.jtot_object1_code;
    p6_a9 := ddx_ctcv_rec.attribute_category;
    p6_a10 := ddx_ctcv_rec.attribute1;
    p6_a11 := ddx_ctcv_rec.attribute2;
    p6_a12 := ddx_ctcv_rec.attribute3;
    p6_a13 := ddx_ctcv_rec.attribute4;
    p6_a14 := ddx_ctcv_rec.attribute5;
    p6_a15 := ddx_ctcv_rec.attribute6;
    p6_a16 := ddx_ctcv_rec.attribute7;
    p6_a17 := ddx_ctcv_rec.attribute8;
    p6_a18 := ddx_ctcv_rec.attribute9;
    p6_a19 := ddx_ctcv_rec.attribute10;
    p6_a20 := ddx_ctcv_rec.attribute11;
    p6_a21 := ddx_ctcv_rec.attribute12;
    p6_a22 := ddx_ctcv_rec.attribute13;
    p6_a23 := ddx_ctcv_rec.attribute14;
    p6_a24 := ddx_ctcv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_ctcv_rec.created_by);
    p6_a26 := ddx_ctcv_rec.creation_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_ctcv_rec.last_updated_by);
    p6_a28 := ddx_ctcv_rec.last_update_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_ctcv_rec.last_update_login);
    p6_a30 := ddx_ctcv_rec.start_date;
    p6_a31 := ddx_ctcv_rec.end_date;
  end;

  procedure create_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_ctcv_tbl okl_okc_migration_pvt.ctcv_tbl_type;
    ddx_ctcv_tbl okl_okc_migration_pvt.ctcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p17(ddp_ctcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_tbl,
      ddx_ctcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p17(ddx_ctcv_tbl, p6_a0
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
      );
  end;

  procedure update_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
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
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
  )

  as
    ddp_ctcv_rec okl_okc_migration_pvt.ctcv_rec_type;
    ddx_ctcv_rec okl_okc_migration_pvt.ctcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ctcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ctcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ctcv_rec.cpl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ctcv_rec.cro_code := p5_a3;
    ddp_ctcv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ctcv_rec.contact_sequence := rosetta_g_miss_num_map(p5_a5);
    ddp_ctcv_rec.object1_id1 := p5_a6;
    ddp_ctcv_rec.object1_id2 := p5_a7;
    ddp_ctcv_rec.jtot_object1_code := p5_a8;
    ddp_ctcv_rec.attribute_category := p5_a9;
    ddp_ctcv_rec.attribute1 := p5_a10;
    ddp_ctcv_rec.attribute2 := p5_a11;
    ddp_ctcv_rec.attribute3 := p5_a12;
    ddp_ctcv_rec.attribute4 := p5_a13;
    ddp_ctcv_rec.attribute5 := p5_a14;
    ddp_ctcv_rec.attribute6 := p5_a15;
    ddp_ctcv_rec.attribute7 := p5_a16;
    ddp_ctcv_rec.attribute8 := p5_a17;
    ddp_ctcv_rec.attribute9 := p5_a18;
    ddp_ctcv_rec.attribute10 := p5_a19;
    ddp_ctcv_rec.attribute11 := p5_a20;
    ddp_ctcv_rec.attribute12 := p5_a21;
    ddp_ctcv_rec.attribute13 := p5_a22;
    ddp_ctcv_rec.attribute14 := p5_a23;
    ddp_ctcv_rec.attribute15 := p5_a24;
    ddp_ctcv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_ctcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ctcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_ctcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_ctcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_ctcv_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_ctcv_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_rec,
      ddx_ctcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ctcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ctcv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ctcv_rec.cpl_id);
    p6_a3 := ddx_ctcv_rec.cro_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_ctcv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_ctcv_rec.contact_sequence);
    p6_a6 := ddx_ctcv_rec.object1_id1;
    p6_a7 := ddx_ctcv_rec.object1_id2;
    p6_a8 := ddx_ctcv_rec.jtot_object1_code;
    p6_a9 := ddx_ctcv_rec.attribute_category;
    p6_a10 := ddx_ctcv_rec.attribute1;
    p6_a11 := ddx_ctcv_rec.attribute2;
    p6_a12 := ddx_ctcv_rec.attribute3;
    p6_a13 := ddx_ctcv_rec.attribute4;
    p6_a14 := ddx_ctcv_rec.attribute5;
    p6_a15 := ddx_ctcv_rec.attribute6;
    p6_a16 := ddx_ctcv_rec.attribute7;
    p6_a17 := ddx_ctcv_rec.attribute8;
    p6_a18 := ddx_ctcv_rec.attribute9;
    p6_a19 := ddx_ctcv_rec.attribute10;
    p6_a20 := ddx_ctcv_rec.attribute11;
    p6_a21 := ddx_ctcv_rec.attribute12;
    p6_a22 := ddx_ctcv_rec.attribute13;
    p6_a23 := ddx_ctcv_rec.attribute14;
    p6_a24 := ddx_ctcv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_ctcv_rec.created_by);
    p6_a26 := ddx_ctcv_rec.creation_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_ctcv_rec.last_updated_by);
    p6_a28 := ddx_ctcv_rec.last_update_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_ctcv_rec.last_update_login);
    p6_a30 := ddx_ctcv_rec.start_date;
    p6_a31 := ddx_ctcv_rec.end_date;
  end;

  procedure update_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_ctcv_tbl okl_okc_migration_pvt.ctcv_tbl_type;
    ddx_ctcv_tbl okl_okc_migration_pvt.ctcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p17(ddp_ctcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_tbl,
      ddx_ctcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p17(ddx_ctcv_tbl, p6_a0
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
      );
  end;

  procedure delete_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
  )

  as
    ddp_ctcv_rec okl_okc_migration_pvt.ctcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ctcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ctcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ctcv_rec.cpl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ctcv_rec.cro_code := p5_a3;
    ddp_ctcv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ctcv_rec.contact_sequence := rosetta_g_miss_num_map(p5_a5);
    ddp_ctcv_rec.object1_id1 := p5_a6;
    ddp_ctcv_rec.object1_id2 := p5_a7;
    ddp_ctcv_rec.jtot_object1_code := p5_a8;
    ddp_ctcv_rec.attribute_category := p5_a9;
    ddp_ctcv_rec.attribute1 := p5_a10;
    ddp_ctcv_rec.attribute2 := p5_a11;
    ddp_ctcv_rec.attribute3 := p5_a12;
    ddp_ctcv_rec.attribute4 := p5_a13;
    ddp_ctcv_rec.attribute5 := p5_a14;
    ddp_ctcv_rec.attribute6 := p5_a15;
    ddp_ctcv_rec.attribute7 := p5_a16;
    ddp_ctcv_rec.attribute8 := p5_a17;
    ddp_ctcv_rec.attribute9 := p5_a18;
    ddp_ctcv_rec.attribute10 := p5_a19;
    ddp_ctcv_rec.attribute11 := p5_a20;
    ddp_ctcv_rec.attribute12 := p5_a21;
    ddp_ctcv_rec.attribute13 := p5_a22;
    ddp_ctcv_rec.attribute14 := p5_a23;
    ddp_ctcv_rec.attribute15 := p5_a24;
    ddp_ctcv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_ctcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ctcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_ctcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_ctcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_ctcv_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_ctcv_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
  )

  as
    ddp_ctcv_tbl okl_okc_migration_pvt.ctcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p17(ddp_ctcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_contact(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ctcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_rule_group(p_api_version  NUMBER
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
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
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
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rgpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rgpv_rec.object_version_number);
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_rgpv_rec.cle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_rgpv_rec.chr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rgpv_rec.dnz_chr_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_rgpv_rec.parent_rgp_id);
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_rgpv_rec.created_by);
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_updated_by);
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_update_login);
  end;

  procedure update_rule_group(p_api_version  NUMBER
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
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
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
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rgpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rgpv_rec.object_version_number);
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_rgpv_rec.cle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_rgpv_rec.chr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rgpv_rec.dnz_chr_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_rgpv_rec.parent_rgp_id);
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_rgpv_rec.created_by);
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_updated_by);
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_update_login);
  end;

  procedure delete_rule_group(p_api_version  NUMBER
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
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rule_group(p_api_version  NUMBER
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
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.lock_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rule_group(p_api_version  NUMBER
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
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.validate_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddx_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.create_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec,
      ddx_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rmpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rmpv_rec.rgp_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_rmpv_rec.rrd_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_rmpv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_rmpv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_rmpv_rec.object_version_number);
    p6_a6 := rosetta_g_miss_num_map(ddx_rmpv_rec.created_by);
    p6_a7 := ddx_rmpv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_updated_by);
    p6_a9 := ddx_rmpv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_update_login);
  end;

  procedure update_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddx_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.update_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec,
      ddx_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rmpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rmpv_rec.rgp_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_rmpv_rec.rrd_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_rmpv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_rmpv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_rmpv_rec.object_version_number);
    p6_a6 := rosetta_g_miss_num_map(ddx_rmpv_rec.created_by);
    p6_a7 := ddx_rmpv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_updated_by);
    p6_a9 := ddx_rmpv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_update_login);
  end;

  procedure delete_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.delete_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.lock_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_okc_migration_pvt.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_pvt.validate_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_okc_migration_pvt_w;

/
