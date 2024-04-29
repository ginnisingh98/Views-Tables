--------------------------------------------------------
--  DDL for Package Body OKL_IPY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IPY_PVT_W" as
  /* $Header: OKLIIPYB.pls 120.1 2005/09/19 11:35:59 pagarg noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_ipy_pvt.ipyv_tbl_type, a0 JTF_NUMBER_TABLE
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_ipy_pvt.ipyv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_ipy_pvt.ipy_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
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
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_DATE_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_DATE_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_DATE_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
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
          t(ddindx).name_of_insured := a2(indx);
          t(ddindx).policy_number := a3(indx);
          t(ddindx).insurance_factor := a4(indx);
          t(ddindx).factor_code := a5(indx);
          t(ddindx).calculated_premium := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).premium := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).covered_amount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).deductible := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).adjustment := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).payment_frequency := a11(indx);
          t(ddindx).crx_code := a12(indx);
          t(ddindx).ipf_code := a13(indx);
          t(ddindx).iss_code := a14(indx);
          t(ddindx).ipe_code := a15(indx);
          t(ddindx).date_to := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).date_from := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).date_quoted := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_proof_provided := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).date_proof_required := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).cancellation_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).date_quote_expiry := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).activation_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).quote_yn := a24(indx);
          t(ddindx).on_file_yn := a25(indx);
          t(ddindx).private_label_yn := a26(indx);
          t(ddindx).agent_yn := a27(indx);
          t(ddindx).lessor_insured_yn := a28(indx);
          t(ddindx).lessor_payee_yn := a29(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).ipt_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).ipy_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).int_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).isu_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).factor_value := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).agency_number := a37(indx);
          t(ddindx).agency_site_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).sales_rep_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).agent_site_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).adjusted_by_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).territory_code := a42(indx);
          t(ddindx).attribute_category := a43(indx);
          t(ddindx).attribute1 := a44(indx);
          t(ddindx).attribute2 := a45(indx);
          t(ddindx).attribute3 := a46(indx);
          t(ddindx).attribute4 := a47(indx);
          t(ddindx).attribute5 := a48(indx);
          t(ddindx).attribute6 := a49(indx);
          t(ddindx).attribute7 := a50(indx);
          t(ddindx).attribute8 := a51(indx);
          t(ddindx).attribute9 := a52(indx);
          t(ddindx).attribute10 := a53(indx);
          t(ddindx).attribute11 := a54(indx);
          t(ddindx).attribute12 := a55(indx);
          t(ddindx).attribute13 := a56(indx);
          t(ddindx).attribute14 := a57(indx);
          t(ddindx).attribute15 := a58(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a61(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a66(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a68(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).lease_application_id := rosetta_g_miss_num_map(a70(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_ipy_pvt.ipy_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_DATE_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_DATE_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_DATE_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
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
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_DATE_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_DATE_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_DATE_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
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
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_DATE_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_DATE_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_DATE_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).ipy_type;
          a2(indx) := t(ddindx).name_of_insured;
          a3(indx) := t(ddindx).policy_number;
          a4(indx) := t(ddindx).insurance_factor;
          a5(indx) := t(ddindx).factor_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).calculated_premium);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).premium);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).covered_amount);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).deductible);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).adjustment);
          a11(indx) := t(ddindx).payment_frequency;
          a12(indx) := t(ddindx).crx_code;
          a13(indx) := t(ddindx).ipf_code;
          a14(indx) := t(ddindx).iss_code;
          a15(indx) := t(ddindx).ipe_code;
          a16(indx) := t(ddindx).date_to;
          a17(indx) := t(ddindx).date_from;
          a18(indx) := t(ddindx).date_quoted;
          a19(indx) := t(ddindx).date_proof_provided;
          a20(indx) := t(ddindx).date_proof_required;
          a21(indx) := t(ddindx).cancellation_date;
          a22(indx) := t(ddindx).date_quote_expiry;
          a23(indx) := t(ddindx).activation_date;
          a24(indx) := t(ddindx).quote_yn;
          a25(indx) := t(ddindx).on_file_yn;
          a26(indx) := t(ddindx).private_label_yn;
          a27(indx) := t(ddindx).agent_yn;
          a28(indx) := t(ddindx).lessor_insured_yn;
          a29(indx) := t(ddindx).lessor_payee_yn;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).ipt_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).ipy_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).int_id);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).isu_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).factor_value);
          a37(indx) := t(ddindx).agency_number;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).agency_site_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).sales_rep_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).agent_site_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_by_id);
          a42(indx) := t(ddindx).territory_code;
          a43(indx) := t(ddindx).attribute_category;
          a44(indx) := t(ddindx).attribute1;
          a45(indx) := t(ddindx).attribute2;
          a46(indx) := t(ddindx).attribute3;
          a47(indx) := t(ddindx).attribute4;
          a48(indx) := t(ddindx).attribute5;
          a49(indx) := t(ddindx).attribute6;
          a50(indx) := t(ddindx).attribute7;
          a51(indx) := t(ddindx).attribute8;
          a52(indx) := t(ddindx).attribute9;
          a53(indx) := t(ddindx).attribute10;
          a54(indx) := t(ddindx).attribute11;
          a55(indx) := t(ddindx).attribute12;
          a56(indx) := t(ddindx).attribute13;
          a57(indx) := t(ddindx).attribute14;
          a58(indx) := t(ddindx).attribute15;
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a61(indx) := t(ddindx).program_update_date;
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a66(indx) := t(ddindx).creation_date;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a68(indx) := t(ddindx).last_update_date;
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).lease_application_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_ipy_pvt.okl_ins_policies_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_600
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).endorsement := a5(indx);
          t(ddindx).comments := a6(indx);
          t(ddindx).cancellation_comment := a7(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_ipy_pvt.okl_ins_policies_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_600
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_600();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_600();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).endorsement;
          a6(indx) := t(ddindx).comments;
          a7(indx) := t(ddindx).cancellation_comment;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure insert_row(p_api_version  NUMBER
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
    ddp_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
    ddx_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
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
    okl_ipy_pvt.insert_row(p_api_version,
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

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddx_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddpx_error_tbl okl_api.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );


    okl_api_w.rosetta_table_copy_in_p3(ddpx_error_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddx_ipyv_tbl,
      ddpx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ipy_pvt_w.rosetta_table_copy_out_p2(ddx_ipyv_tbl, p6_a0
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
      );

    okl_api_w.rosetta_table_copy_out_p3(ddpx_error_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddx_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddx_ipyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ipy_pvt_w.rosetta_table_copy_out_p2(ddx_ipyv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
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
    ddp_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
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
    okl_ipy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddpx_error_tbl okl_api.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    okl_api_w.rosetta_table_copy_in_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddpx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_api_w.rosetta_table_copy_out_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
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
    ddp_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
    ddx_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
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
    okl_ipy_pvt.update_row(p_api_version,
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

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddx_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddpx_error_tbl okl_api.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );


    okl_api_w.rosetta_table_copy_in_p3(ddpx_error_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddx_ipyv_tbl,
      ddpx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ipy_pvt_w.rosetta_table_copy_out_p2(ddx_ipyv_tbl, p6_a0
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
      );

    okl_api_w.rosetta_table_copy_out_p3(ddpx_error_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddx_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddx_ipyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ipy_pvt_w.rosetta_table_copy_out_p2(ddx_ipyv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
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
    ddp_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
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
    okl_ipy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddpx_error_tbl okl_api.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    okl_api_w.rosetta_table_copy_in_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddpx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_api_w.rosetta_table_copy_out_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
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
    ddp_ipyv_rec okl_ipy_pvt.ipyv_rec_type;
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
    okl_ipy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddpx_error_tbl okl_api.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    okl_api_w.rosetta_table_copy_in_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl,
      ddpx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_api_w.rosetta_table_copy_out_p3(ddpx_error_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );
  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  )

  as
    ddp_ipyv_tbl okl_ipy_pvt.ipyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ipy_pvt_w.rosetta_table_copy_in_p2(ddp_ipyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ipy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_ipy_pvt_w;

/
