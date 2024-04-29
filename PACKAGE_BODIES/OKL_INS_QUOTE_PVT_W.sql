--------------------------------------------------------
--  DDL for Package Body OKL_INS_QUOTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_QUOTE_PVT_W" as
  /* $Header: OKLEINQB.pls 120.2 2005/09/19 11:35:35 pagarg noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_ins_quote_pvt.ipyv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_600
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_500
    , a51 JTF_VARCHAR2_TABLE_500
    , a52 JTF_VARCHAR2_TABLE_500
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_DATE_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_DATE_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_DATE_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).ipy_type := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).endorsement := a3(indx);
          t(ddindx).sfwt_flag := a4(indx);
          t(ddindx).cancellation_comment := a5(indx);
          t(ddindx).comments := a6(indx);
          t(ddindx).name_of_insured := a7(indx);
          t(ddindx).policy_number := a8(indx);
          t(ddindx).calculated_premium := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).premium := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).covered_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).deductible := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).adjustment := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).payment_frequency := a14(indx);
          t(ddindx).crx_code := a15(indx);
          t(ddindx).ipf_code := a16(indx);
          t(ddindx).iss_code := a17(indx);
          t(ddindx).ipe_code := a18(indx);
          t(ddindx).date_to := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).date_from := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).date_quoted := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).date_proof_provided := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).date_proof_required := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).cancellation_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).date_quote_expiry := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).activation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).quote_yn := a27(indx);
          t(ddindx).on_file_yn := a28(indx);
          t(ddindx).private_label_yn := a29(indx);
          t(ddindx).agent_yn := a30(indx);
          t(ddindx).lessor_insured_yn := a31(indx);
          t(ddindx).lessor_payee_yn := a32(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).ipt_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).ipy_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).int_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).isu_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).insurance_factor := a39(indx);
          t(ddindx).factor_code := a40(indx);
          t(ddindx).factor_value := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).agency_number := a42(indx);
          t(ddindx).agency_site_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).sales_rep_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).agent_site_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).adjusted_by_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).territory_code := a47(indx);
          t(ddindx).attribute_category := a48(indx);
          t(ddindx).attribute1 := a49(indx);
          t(ddindx).attribute2 := a50(indx);
          t(ddindx).attribute3 := a51(indx);
          t(ddindx).attribute4 := a52(indx);
          t(ddindx).attribute5 := a53(indx);
          t(ddindx).attribute6 := a54(indx);
          t(ddindx).attribute7 := a55(indx);
          t(ddindx).attribute8 := a56(indx);
          t(ddindx).attribute9 := a57(indx);
          t(ddindx).attribute10 := a58(indx);
          t(ddindx).attribute11 := a59(indx);
          t(ddindx).attribute12 := a60(indx);
          t(ddindx).attribute13 := a61(indx);
          t(ddindx).attribute14 := a62(indx);
          t(ddindx).attribute15 := a63(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a66(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a71(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a73(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).lease_application_id := rosetta_g_miss_num_map(a75(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_ins_quote_pvt.ipyv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_600
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_500
    , a51 out nocopy JTF_VARCHAR2_TABLE_500
    , a52 out nocopy JTF_VARCHAR2_TABLE_500
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_DATE_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_DATE_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_DATE_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_600();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_500();
    a51 := JTF_VARCHAR2_TABLE_500();
    a52 := JTF_VARCHAR2_TABLE_500();
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_VARCHAR2_TABLE_500();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_VARCHAR2_TABLE_500();
    a63 := JTF_VARCHAR2_TABLE_500();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_DATE_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_DATE_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_DATE_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_600();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_500();
      a51 := JTF_VARCHAR2_TABLE_500();
      a52 := JTF_VARCHAR2_TABLE_500();
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_VARCHAR2_TABLE_500();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_VARCHAR2_TABLE_500();
      a63 := JTF_VARCHAR2_TABLE_500();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_DATE_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_DATE_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_DATE_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).ipy_type;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).endorsement;
          a4(indx) := t(ddindx).sfwt_flag;
          a5(indx) := t(ddindx).cancellation_comment;
          a6(indx) := t(ddindx).comments;
          a7(indx) := t(ddindx).name_of_insured;
          a8(indx) := t(ddindx).policy_number;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).calculated_premium);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).premium);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).covered_amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).deductible);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).adjustment);
          a14(indx) := t(ddindx).payment_frequency;
          a15(indx) := t(ddindx).crx_code;
          a16(indx) := t(ddindx).ipf_code;
          a17(indx) := t(ddindx).iss_code;
          a18(indx) := t(ddindx).ipe_code;
          a19(indx) := t(ddindx).date_to;
          a20(indx) := t(ddindx).date_from;
          a21(indx) := t(ddindx).date_quoted;
          a22(indx) := t(ddindx).date_proof_provided;
          a23(indx) := t(ddindx).date_proof_required;
          a24(indx) := t(ddindx).cancellation_date;
          a25(indx) := t(ddindx).date_quote_expiry;
          a26(indx) := t(ddindx).activation_date;
          a27(indx) := t(ddindx).quote_yn;
          a28(indx) := t(ddindx).on_file_yn;
          a29(indx) := t(ddindx).private_label_yn;
          a30(indx) := t(ddindx).agent_yn;
          a31(indx) := t(ddindx).lessor_insured_yn;
          a32(indx) := t(ddindx).lessor_payee_yn;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).ipt_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).ipy_id);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).int_id);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).isu_id);
          a39(indx) := t(ddindx).insurance_factor;
          a40(indx) := t(ddindx).factor_code;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).factor_value);
          a42(indx) := t(ddindx).agency_number;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).agency_site_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).sales_rep_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).agent_site_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_by_id);
          a47(indx) := t(ddindx).territory_code;
          a48(indx) := t(ddindx).attribute_category;
          a49(indx) := t(ddindx).attribute1;
          a50(indx) := t(ddindx).attribute2;
          a51(indx) := t(ddindx).attribute3;
          a52(indx) := t(ddindx).attribute4;
          a53(indx) := t(ddindx).attribute5;
          a54(indx) := t(ddindx).attribute6;
          a55(indx) := t(ddindx).attribute7;
          a56(indx) := t(ddindx).attribute8;
          a57(indx) := t(ddindx).attribute9;
          a58(indx) := t(ddindx).attribute10;
          a59(indx) := t(ddindx).attribute11;
          a60(indx) := t(ddindx).attribute12;
          a61(indx) := t(ddindx).attribute13;
          a62(indx) := t(ddindx).attribute14;
          a63(indx) := t(ddindx).attribute15;
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a66(indx) := t(ddindx).program_update_date;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a71(indx) := t(ddindx).creation_date;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a73(indx) := t(ddindx).last_update_date;
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).lease_application_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_ins_quote_pvt.inav_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
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
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_NUMBER_TABLE
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
          t(ddindx).ipy_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).calculated_premium := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).asset_premium := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).lessor_premium := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).attribute_category := a7(indx);
          t(ddindx).attribute1 := a8(indx);
          t(ddindx).attribute2 := a9(indx);
          t(ddindx).attribute3 := a10(indx);
          t(ddindx).attribute4 := a11(indx);
          t(ddindx).attribute5 := a12(indx);
          t(ddindx).attribute6 := a13(indx);
          t(ddindx).attribute7 := a14(indx);
          t(ddindx).attribute8 := a15(indx);
          t(ddindx).attribute9 := a16(indx);
          t(ddindx).attribute10 := a17(indx);
          t(ddindx).attribute11 := a18(indx);
          t(ddindx).attribute12 := a19(indx);
          t(ddindx).attribute13 := a20(indx);
          t(ddindx).attribute14 := a21(indx);
          t(ddindx).attribute15 := a22(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a32(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_ins_quote_pvt.inav_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
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
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
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
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).ipy_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).calculated_premium);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).asset_premium);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).lessor_premium);
          a7(indx) := t(ddindx).attribute_category;
          a8(indx) := t(ddindx).attribute1;
          a9(indx) := t(ddindx).attribute2;
          a10(indx) := t(ddindx).attribute3;
          a11(indx) := t(ddindx).attribute4;
          a12(indx) := t(ddindx).attribute5;
          a13(indx) := t(ddindx).attribute6;
          a14(indx) := t(ddindx).attribute7;
          a15(indx) := t(ddindx).attribute8;
          a16(indx) := t(ddindx).attribute9;
          a17(indx) := t(ddindx).attribute10;
          a18(indx) := t(ddindx).attribute11;
          a19(indx) := t(ddindx).attribute12;
          a20(indx) := t(ddindx).attribute13;
          a21(indx) := t(ddindx).attribute14;
          a22(indx) := t(ddindx).attribute15;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a27(indx) := t(ddindx).program_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a29(indx) := t(ddindx).creation_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a31(indx) := t(ddindx).last_update_date;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_ins_quote_pvt.iasset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).kle_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).premium := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).lessor_premium := rosetta_g_miss_num_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_ins_quote_pvt.iasset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).premium);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).lessor_premium);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy okl_ins_quote_pvt.policy_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).policy_number := a0(indx);
          t(ddindx).contract_number := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_ins_quote_pvt.policy_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).policy_number;
          a1(indx) := t(ddindx).contract_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_ins_quote_pvt.payment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).amount := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_ins_quote_pvt.payment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a1(indx) := t(ddindx).due_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_ins_quote_pvt.insexp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).amount := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).period := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_ins_quote_pvt.insexp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).period);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure save_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  DATE
    , p5_a20 in out nocopy  DATE
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  NUMBER
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  NUMBER
    , p5_a45 in out nocopy  NUMBER
    , p5_a46 in out nocopy  NUMBER
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  VARCHAR2
    , p5_a61 in out nocopy  VARCHAR2
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  VARCHAR2
    , p5_a64 in out nocopy  NUMBER
    , p5_a65 in out nocopy  NUMBER
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  NUMBER
    , p5_a68 in out nocopy  NUMBER
    , p5_a69 in out nocopy  NUMBER
    , p5_a70 in out nocopy  NUMBER
    , p5_a71 in out nocopy  DATE
    , p5_a72 in out nocopy  NUMBER
    , p5_a73 in out nocopy  DATE
    , p5_a74 in out nocopy  NUMBER
    , p5_a75 in out nocopy  NUMBER
    , x_message out nocopy  VARCHAR2
  )

  as
    ddpx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddpx_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddpx_ipyv_rec.ipy_type := p5_a1;
    ddpx_ipyv_rec.description := p5_a2;
    ddpx_ipyv_rec.endorsement := p5_a3;
    ddpx_ipyv_rec.sfwt_flag := p5_a4;
    ddpx_ipyv_rec.cancellation_comment := p5_a5;
    ddpx_ipyv_rec.comments := p5_a6;
    ddpx_ipyv_rec.name_of_insured := p5_a7;
    ddpx_ipyv_rec.policy_number := p5_a8;
    ddpx_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddpx_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddpx_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddpx_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddpx_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddpx_ipyv_rec.payment_frequency := p5_a14;
    ddpx_ipyv_rec.crx_code := p5_a15;
    ddpx_ipyv_rec.ipf_code := p5_a16;
    ddpx_ipyv_rec.iss_code := p5_a17;
    ddpx_ipyv_rec.ipe_code := p5_a18;
    ddpx_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddpx_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddpx_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddpx_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddpx_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddpx_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddpx_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddpx_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddpx_ipyv_rec.quote_yn := p5_a27;
    ddpx_ipyv_rec.on_file_yn := p5_a28;
    ddpx_ipyv_rec.private_label_yn := p5_a29;
    ddpx_ipyv_rec.agent_yn := p5_a30;
    ddpx_ipyv_rec.lessor_insured_yn := p5_a31;
    ddpx_ipyv_rec.lessor_payee_yn := p5_a32;
    ddpx_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddpx_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddpx_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddpx_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddpx_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddpx_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddpx_ipyv_rec.insurance_factor := p5_a39;
    ddpx_ipyv_rec.factor_code := p5_a40;
    ddpx_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddpx_ipyv_rec.agency_number := p5_a42;
    ddpx_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddpx_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddpx_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddpx_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddpx_ipyv_rec.territory_code := p5_a47;
    ddpx_ipyv_rec.attribute_category := p5_a48;
    ddpx_ipyv_rec.attribute1 := p5_a49;
    ddpx_ipyv_rec.attribute2 := p5_a50;
    ddpx_ipyv_rec.attribute3 := p5_a51;
    ddpx_ipyv_rec.attribute4 := p5_a52;
    ddpx_ipyv_rec.attribute5 := p5_a53;
    ddpx_ipyv_rec.attribute6 := p5_a54;
    ddpx_ipyv_rec.attribute7 := p5_a55;
    ddpx_ipyv_rec.attribute8 := p5_a56;
    ddpx_ipyv_rec.attribute9 := p5_a57;
    ddpx_ipyv_rec.attribute10 := p5_a58;
    ddpx_ipyv_rec.attribute11 := p5_a59;
    ddpx_ipyv_rec.attribute12 := p5_a60;
    ddpx_ipyv_rec.attribute13 := p5_a61;
    ddpx_ipyv_rec.attribute14 := p5_a62;
    ddpx_ipyv_rec.attribute15 := p5_a63;
    ddpx_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddpx_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddpx_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddpx_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddpx_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddpx_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddpx_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddpx_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddpx_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddpx_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddpx_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddpx_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.save_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpx_ipyv_rec,
      x_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddpx_ipyv_rec.id);
    p5_a1 := ddpx_ipyv_rec.ipy_type;
    p5_a2 := ddpx_ipyv_rec.description;
    p5_a3 := ddpx_ipyv_rec.endorsement;
    p5_a4 := ddpx_ipyv_rec.sfwt_flag;
    p5_a5 := ddpx_ipyv_rec.cancellation_comment;
    p5_a6 := ddpx_ipyv_rec.comments;
    p5_a7 := ddpx_ipyv_rec.name_of_insured;
    p5_a8 := ddpx_ipyv_rec.policy_number;
    p5_a9 := rosetta_g_miss_num_map(ddpx_ipyv_rec.calculated_premium);
    p5_a10 := rosetta_g_miss_num_map(ddpx_ipyv_rec.premium);
    p5_a11 := rosetta_g_miss_num_map(ddpx_ipyv_rec.covered_amount);
    p5_a12 := rosetta_g_miss_num_map(ddpx_ipyv_rec.deductible);
    p5_a13 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjustment);
    p5_a14 := ddpx_ipyv_rec.payment_frequency;
    p5_a15 := ddpx_ipyv_rec.crx_code;
    p5_a16 := ddpx_ipyv_rec.ipf_code;
    p5_a17 := ddpx_ipyv_rec.iss_code;
    p5_a18 := ddpx_ipyv_rec.ipe_code;
    p5_a19 := ddpx_ipyv_rec.date_to;
    p5_a20 := ddpx_ipyv_rec.date_from;
    p5_a21 := ddpx_ipyv_rec.date_quoted;
    p5_a22 := ddpx_ipyv_rec.date_proof_provided;
    p5_a23 := ddpx_ipyv_rec.date_proof_required;
    p5_a24 := ddpx_ipyv_rec.cancellation_date;
    p5_a25 := ddpx_ipyv_rec.date_quote_expiry;
    p5_a26 := ddpx_ipyv_rec.activation_date;
    p5_a27 := ddpx_ipyv_rec.quote_yn;
    p5_a28 := ddpx_ipyv_rec.on_file_yn;
    p5_a29 := ddpx_ipyv_rec.private_label_yn;
    p5_a30 := ddpx_ipyv_rec.agent_yn;
    p5_a31 := ddpx_ipyv_rec.lessor_insured_yn;
    p5_a32 := ddpx_ipyv_rec.lessor_payee_yn;
    p5_a33 := rosetta_g_miss_num_map(ddpx_ipyv_rec.khr_id);
    p5_a34 := rosetta_g_miss_num_map(ddpx_ipyv_rec.kle_id);
    p5_a35 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipt_id);
    p5_a36 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipy_id);
    p5_a37 := rosetta_g_miss_num_map(ddpx_ipyv_rec.int_id);
    p5_a38 := rosetta_g_miss_num_map(ddpx_ipyv_rec.isu_id);
    p5_a39 := ddpx_ipyv_rec.insurance_factor;
    p5_a40 := ddpx_ipyv_rec.factor_code;
    p5_a41 := rosetta_g_miss_num_map(ddpx_ipyv_rec.factor_value);
    p5_a42 := ddpx_ipyv_rec.agency_number;
    p5_a43 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agency_site_id);
    p5_a44 := rosetta_g_miss_num_map(ddpx_ipyv_rec.sales_rep_id);
    p5_a45 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agent_site_id);
    p5_a46 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjusted_by_id);
    p5_a47 := ddpx_ipyv_rec.territory_code;
    p5_a48 := ddpx_ipyv_rec.attribute_category;
    p5_a49 := ddpx_ipyv_rec.attribute1;
    p5_a50 := ddpx_ipyv_rec.attribute2;
    p5_a51 := ddpx_ipyv_rec.attribute3;
    p5_a52 := ddpx_ipyv_rec.attribute4;
    p5_a53 := ddpx_ipyv_rec.attribute5;
    p5_a54 := ddpx_ipyv_rec.attribute6;
    p5_a55 := ddpx_ipyv_rec.attribute7;
    p5_a56 := ddpx_ipyv_rec.attribute8;
    p5_a57 := ddpx_ipyv_rec.attribute9;
    p5_a58 := ddpx_ipyv_rec.attribute10;
    p5_a59 := ddpx_ipyv_rec.attribute11;
    p5_a60 := ddpx_ipyv_rec.attribute12;
    p5_a61 := ddpx_ipyv_rec.attribute13;
    p5_a62 := ddpx_ipyv_rec.attribute14;
    p5_a63 := ddpx_ipyv_rec.attribute15;
    p5_a64 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_id);
    p5_a65 := rosetta_g_miss_num_map(ddpx_ipyv_rec.org_id);
    p5_a66 := ddpx_ipyv_rec.program_update_date;
    p5_a67 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_application_id);
    p5_a68 := rosetta_g_miss_num_map(ddpx_ipyv_rec.request_id);
    p5_a69 := rosetta_g_miss_num_map(ddpx_ipyv_rec.object_version_number);
    p5_a70 := rosetta_g_miss_num_map(ddpx_ipyv_rec.created_by);
    p5_a71 := ddpx_ipyv_rec.creation_date;
    p5_a72 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_updated_by);
    p5_a73 := ddpx_ipyv_rec.last_update_date;
    p5_a74 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_update_login);
    p5_a75 := rosetta_g_miss_num_map(ddpx_ipyv_rec.lease_application_id);

  end;

  procedure save_accept_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.save_accept_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      x_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_ins_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.create_ins_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure calc_lease_premium(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  DATE
    , p5_a20 in out nocopy  DATE
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  NUMBER
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  NUMBER
    , p5_a45 in out nocopy  NUMBER
    , p5_a46 in out nocopy  NUMBER
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  VARCHAR2
    , p5_a61 in out nocopy  VARCHAR2
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  VARCHAR2
    , p5_a64 in out nocopy  NUMBER
    , p5_a65 in out nocopy  NUMBER
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  NUMBER
    , p5_a68 in out nocopy  NUMBER
    , p5_a69 in out nocopy  NUMBER
    , p5_a70 in out nocopy  NUMBER
    , p5_a71 in out nocopy  DATE
    , p5_a72 in out nocopy  NUMBER
    , p5_a73 in out nocopy  DATE
    , p5_a74 in out nocopy  NUMBER
    , p5_a75 in out nocopy  NUMBER
    , x_message out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddpx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddx_iasset_tbl okl_ins_quote_pvt.iasset_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddpx_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddpx_ipyv_rec.ipy_type := p5_a1;
    ddpx_ipyv_rec.description := p5_a2;
    ddpx_ipyv_rec.endorsement := p5_a3;
    ddpx_ipyv_rec.sfwt_flag := p5_a4;
    ddpx_ipyv_rec.cancellation_comment := p5_a5;
    ddpx_ipyv_rec.comments := p5_a6;
    ddpx_ipyv_rec.name_of_insured := p5_a7;
    ddpx_ipyv_rec.policy_number := p5_a8;
    ddpx_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddpx_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddpx_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddpx_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddpx_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddpx_ipyv_rec.payment_frequency := p5_a14;
    ddpx_ipyv_rec.crx_code := p5_a15;
    ddpx_ipyv_rec.ipf_code := p5_a16;
    ddpx_ipyv_rec.iss_code := p5_a17;
    ddpx_ipyv_rec.ipe_code := p5_a18;
    ddpx_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddpx_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddpx_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddpx_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddpx_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddpx_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddpx_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddpx_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddpx_ipyv_rec.quote_yn := p5_a27;
    ddpx_ipyv_rec.on_file_yn := p5_a28;
    ddpx_ipyv_rec.private_label_yn := p5_a29;
    ddpx_ipyv_rec.agent_yn := p5_a30;
    ddpx_ipyv_rec.lessor_insured_yn := p5_a31;
    ddpx_ipyv_rec.lessor_payee_yn := p5_a32;
    ddpx_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddpx_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddpx_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddpx_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddpx_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddpx_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddpx_ipyv_rec.insurance_factor := p5_a39;
    ddpx_ipyv_rec.factor_code := p5_a40;
    ddpx_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddpx_ipyv_rec.agency_number := p5_a42;
    ddpx_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddpx_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddpx_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddpx_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddpx_ipyv_rec.territory_code := p5_a47;
    ddpx_ipyv_rec.attribute_category := p5_a48;
    ddpx_ipyv_rec.attribute1 := p5_a49;
    ddpx_ipyv_rec.attribute2 := p5_a50;
    ddpx_ipyv_rec.attribute3 := p5_a51;
    ddpx_ipyv_rec.attribute4 := p5_a52;
    ddpx_ipyv_rec.attribute5 := p5_a53;
    ddpx_ipyv_rec.attribute6 := p5_a54;
    ddpx_ipyv_rec.attribute7 := p5_a55;
    ddpx_ipyv_rec.attribute8 := p5_a56;
    ddpx_ipyv_rec.attribute9 := p5_a57;
    ddpx_ipyv_rec.attribute10 := p5_a58;
    ddpx_ipyv_rec.attribute11 := p5_a59;
    ddpx_ipyv_rec.attribute12 := p5_a60;
    ddpx_ipyv_rec.attribute13 := p5_a61;
    ddpx_ipyv_rec.attribute14 := p5_a62;
    ddpx_ipyv_rec.attribute15 := p5_a63;
    ddpx_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddpx_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddpx_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddpx_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddpx_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddpx_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddpx_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddpx_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddpx_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddpx_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddpx_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddpx_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);



    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.calc_lease_premium(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpx_ipyv_rec,
      x_message,
      ddx_iasset_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddpx_ipyv_rec.id);
    p5_a1 := ddpx_ipyv_rec.ipy_type;
    p5_a2 := ddpx_ipyv_rec.description;
    p5_a3 := ddpx_ipyv_rec.endorsement;
    p5_a4 := ddpx_ipyv_rec.sfwt_flag;
    p5_a5 := ddpx_ipyv_rec.cancellation_comment;
    p5_a6 := ddpx_ipyv_rec.comments;
    p5_a7 := ddpx_ipyv_rec.name_of_insured;
    p5_a8 := ddpx_ipyv_rec.policy_number;
    p5_a9 := rosetta_g_miss_num_map(ddpx_ipyv_rec.calculated_premium);
    p5_a10 := rosetta_g_miss_num_map(ddpx_ipyv_rec.premium);
    p5_a11 := rosetta_g_miss_num_map(ddpx_ipyv_rec.covered_amount);
    p5_a12 := rosetta_g_miss_num_map(ddpx_ipyv_rec.deductible);
    p5_a13 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjustment);
    p5_a14 := ddpx_ipyv_rec.payment_frequency;
    p5_a15 := ddpx_ipyv_rec.crx_code;
    p5_a16 := ddpx_ipyv_rec.ipf_code;
    p5_a17 := ddpx_ipyv_rec.iss_code;
    p5_a18 := ddpx_ipyv_rec.ipe_code;
    p5_a19 := ddpx_ipyv_rec.date_to;
    p5_a20 := ddpx_ipyv_rec.date_from;
    p5_a21 := ddpx_ipyv_rec.date_quoted;
    p5_a22 := ddpx_ipyv_rec.date_proof_provided;
    p5_a23 := ddpx_ipyv_rec.date_proof_required;
    p5_a24 := ddpx_ipyv_rec.cancellation_date;
    p5_a25 := ddpx_ipyv_rec.date_quote_expiry;
    p5_a26 := ddpx_ipyv_rec.activation_date;
    p5_a27 := ddpx_ipyv_rec.quote_yn;
    p5_a28 := ddpx_ipyv_rec.on_file_yn;
    p5_a29 := ddpx_ipyv_rec.private_label_yn;
    p5_a30 := ddpx_ipyv_rec.agent_yn;
    p5_a31 := ddpx_ipyv_rec.lessor_insured_yn;
    p5_a32 := ddpx_ipyv_rec.lessor_payee_yn;
    p5_a33 := rosetta_g_miss_num_map(ddpx_ipyv_rec.khr_id);
    p5_a34 := rosetta_g_miss_num_map(ddpx_ipyv_rec.kle_id);
    p5_a35 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipt_id);
    p5_a36 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipy_id);
    p5_a37 := rosetta_g_miss_num_map(ddpx_ipyv_rec.int_id);
    p5_a38 := rosetta_g_miss_num_map(ddpx_ipyv_rec.isu_id);
    p5_a39 := ddpx_ipyv_rec.insurance_factor;
    p5_a40 := ddpx_ipyv_rec.factor_code;
    p5_a41 := rosetta_g_miss_num_map(ddpx_ipyv_rec.factor_value);
    p5_a42 := ddpx_ipyv_rec.agency_number;
    p5_a43 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agency_site_id);
    p5_a44 := rosetta_g_miss_num_map(ddpx_ipyv_rec.sales_rep_id);
    p5_a45 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agent_site_id);
    p5_a46 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjusted_by_id);
    p5_a47 := ddpx_ipyv_rec.territory_code;
    p5_a48 := ddpx_ipyv_rec.attribute_category;
    p5_a49 := ddpx_ipyv_rec.attribute1;
    p5_a50 := ddpx_ipyv_rec.attribute2;
    p5_a51 := ddpx_ipyv_rec.attribute3;
    p5_a52 := ddpx_ipyv_rec.attribute4;
    p5_a53 := ddpx_ipyv_rec.attribute5;
    p5_a54 := ddpx_ipyv_rec.attribute6;
    p5_a55 := ddpx_ipyv_rec.attribute7;
    p5_a56 := ddpx_ipyv_rec.attribute8;
    p5_a57 := ddpx_ipyv_rec.attribute9;
    p5_a58 := ddpx_ipyv_rec.attribute10;
    p5_a59 := ddpx_ipyv_rec.attribute11;
    p5_a60 := ddpx_ipyv_rec.attribute12;
    p5_a61 := ddpx_ipyv_rec.attribute13;
    p5_a62 := ddpx_ipyv_rec.attribute14;
    p5_a63 := ddpx_ipyv_rec.attribute15;
    p5_a64 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_id);
    p5_a65 := rosetta_g_miss_num_map(ddpx_ipyv_rec.org_id);
    p5_a66 := ddpx_ipyv_rec.program_update_date;
    p5_a67 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_application_id);
    p5_a68 := rosetta_g_miss_num_map(ddpx_ipyv_rec.request_id);
    p5_a69 := rosetta_g_miss_num_map(ddpx_ipyv_rec.object_version_number);
    p5_a70 := rosetta_g_miss_num_map(ddpx_ipyv_rec.created_by);
    p5_a71 := ddpx_ipyv_rec.creation_date;
    p5_a72 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_updated_by);
    p5_a73 := ddpx_ipyv_rec.last_update_date;
    p5_a74 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_update_login);
    p5_a75 := rosetta_g_miss_num_map(ddpx_ipyv_rec.lease_application_id);


    okl_ins_quote_pvt_w.rosetta_table_copy_out_p5(ddx_iasset_tbl, p7_a0
      , p7_a1
      , p7_a2
      );
  end;

  procedure calc_optional_premium(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  DATE
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  DATE
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  DATE
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  DATE
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  DATE
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);



    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.calc_optional_premium(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      x_message,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p7_a1 := ddx_ipyv_rec.ipy_type;
    p7_a2 := ddx_ipyv_rec.description;
    p7_a3 := ddx_ipyv_rec.endorsement;
    p7_a4 := ddx_ipyv_rec.sfwt_flag;
    p7_a5 := ddx_ipyv_rec.cancellation_comment;
    p7_a6 := ddx_ipyv_rec.comments;
    p7_a7 := ddx_ipyv_rec.name_of_insured;
    p7_a8 := ddx_ipyv_rec.policy_number;
    p7_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p7_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p7_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p7_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p7_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p7_a14 := ddx_ipyv_rec.payment_frequency;
    p7_a15 := ddx_ipyv_rec.crx_code;
    p7_a16 := ddx_ipyv_rec.ipf_code;
    p7_a17 := ddx_ipyv_rec.iss_code;
    p7_a18 := ddx_ipyv_rec.ipe_code;
    p7_a19 := ddx_ipyv_rec.date_to;
    p7_a20 := ddx_ipyv_rec.date_from;
    p7_a21 := ddx_ipyv_rec.date_quoted;
    p7_a22 := ddx_ipyv_rec.date_proof_provided;
    p7_a23 := ddx_ipyv_rec.date_proof_required;
    p7_a24 := ddx_ipyv_rec.cancellation_date;
    p7_a25 := ddx_ipyv_rec.date_quote_expiry;
    p7_a26 := ddx_ipyv_rec.activation_date;
    p7_a27 := ddx_ipyv_rec.quote_yn;
    p7_a28 := ddx_ipyv_rec.on_file_yn;
    p7_a29 := ddx_ipyv_rec.private_label_yn;
    p7_a30 := ddx_ipyv_rec.agent_yn;
    p7_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p7_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p7_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p7_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p7_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p7_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p7_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p7_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p7_a39 := ddx_ipyv_rec.insurance_factor;
    p7_a40 := ddx_ipyv_rec.factor_code;
    p7_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p7_a42 := ddx_ipyv_rec.agency_number;
    p7_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p7_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p7_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p7_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p7_a47 := ddx_ipyv_rec.territory_code;
    p7_a48 := ddx_ipyv_rec.attribute_category;
    p7_a49 := ddx_ipyv_rec.attribute1;
    p7_a50 := ddx_ipyv_rec.attribute2;
    p7_a51 := ddx_ipyv_rec.attribute3;
    p7_a52 := ddx_ipyv_rec.attribute4;
    p7_a53 := ddx_ipyv_rec.attribute5;
    p7_a54 := ddx_ipyv_rec.attribute6;
    p7_a55 := ddx_ipyv_rec.attribute7;
    p7_a56 := ddx_ipyv_rec.attribute8;
    p7_a57 := ddx_ipyv_rec.attribute9;
    p7_a58 := ddx_ipyv_rec.attribute10;
    p7_a59 := ddx_ipyv_rec.attribute11;
    p7_a60 := ddx_ipyv_rec.attribute12;
    p7_a61 := ddx_ipyv_rec.attribute13;
    p7_a62 := ddx_ipyv_rec.attribute14;
    p7_a63 := ddx_ipyv_rec.attribute15;
    p7_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p7_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p7_a66 := ddx_ipyv_rec.program_update_date;
    p7_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p7_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p7_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p7_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p7_a71 := ddx_ipyv_rec.creation_date;
    p7_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p7_a73 := ddx_ipyv_rec.last_update_date;
    p7_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p7_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure activate_ins_stream(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.activate_ins_stream(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_third_prt_ins(p_api_version  NUMBER
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
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
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
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.create_third_prt_ins(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure crt_lseapp_thrdprt_ins(p_api_version  NUMBER
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
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
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
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
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
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.crt_lseapp_thrdprt_ins(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure lseapp_thrdprty_to_ctrct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lakhr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
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
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
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
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
  )

  as
    ddx_ipyv_rec okl_ins_quote_pvt.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pvt.lseapp_thrdprty_to_ctrct(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lakhr_id,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

end okl_ins_quote_pvt_w;

/
