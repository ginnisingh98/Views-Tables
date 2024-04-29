--------------------------------------------------------
--  DDL for Package Body AS_OSI_LEAD_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OSI_LEAD_PUB_W" as
  /* $Header: asxolpab.pls 115.2 2002/12/10 01:32:14 kichan ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy as_osi_lead_pub.osi_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_2000
    , a34 JTF_VARCHAR2_TABLE_2000
    , a35 JTF_VARCHAR2_TABLE_2000
    , a36 JTF_VARCHAR2_TABLE_2000
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := a1(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := a3(indx);
          t(ddindx).last_update_login := a4(indx);
          t(ddindx).lead_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).osi_lead_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).cvehicle := a7(indx);
          t(ddindx).cname_id := a8(indx);
          t(ddindx).po_from := a9(indx);
          t(ddindx).contr_type := a10(indx);
          t(ddindx).contr_drafting_req := a11(indx);
          t(ddindx).priority := a12(indx);
          t(ddindx).senior_contr_person_id := a13(indx);
          t(ddindx).contr_spec_person_id := a14(indx);
          t(ddindx).bom_person_id := a15(indx);
          t(ddindx).legal_person_id := a16(indx);
          t(ddindx).highest_apvl := a17(indx);
          t(ddindx).current_apvl_status := a18(indx);
          t(ddindx).support_apvl := a19(indx);
          t(ddindx).international_apvl := a20(indx);
          t(ddindx).credit_apvl := a21(indx);
          t(ddindx).fin_escrow_req := a22(indx);
          t(ddindx).fin_escrow_status := a23(indx);
          t(ddindx).csi_rollin := a24(indx);
          t(ddindx).licence_credit_ver := a25(indx);
          t(ddindx).support_credit_ver := a26(indx);
          t(ddindx).md_deal_summary := a27(indx);
          t(ddindx).prod_avail_ver := a28(indx);
          t(ddindx).ship_location := a29(indx);
          t(ddindx).tax_exempt_cert := a30(indx);
          t(ddindx).nl_rev_alloc_req := a31(indx);
          t(ddindx).consulting_cc := a32(indx);
          t(ddindx).senior_contr_notes := a33(indx);
          t(ddindx).legal_notes := a34(indx);
          t(ddindx).bom_notes := a35(indx);
          t(ddindx).contr_notes := a36(indx);
          t(ddindx).contr_status := a37(indx);
          t(ddindx).extra_docs := a38(indx);
          t(ddindx).cust_name := a39(indx);
          t(ddindx).site_name := a40(indx);
          t(ddindx).oppy_name := a41(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t as_osi_lead_pub.osi_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , a34 out nocopy JTF_VARCHAR2_TABLE_2000
    , a35 out nocopy JTF_VARCHAR2_TABLE_2000
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_2000();
    a34 := JTF_VARCHAR2_TABLE_2000();
    a35 := JTF_VARCHAR2_TABLE_2000();
    a36 := JTF_VARCHAR2_TABLE_2000();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_2000();
      a34 := JTF_VARCHAR2_TABLE_2000();
      a35 := JTF_VARCHAR2_TABLE_2000();
      a36 := JTF_VARCHAR2_TABLE_2000();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := t(ddindx).last_updated_by;
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := t(ddindx).created_by;
          a4(indx) := t(ddindx).last_update_login;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).osi_lead_id);
          a7(indx) := t(ddindx).cvehicle;
          a8(indx) := t(ddindx).cname_id;
          a9(indx) := t(ddindx).po_from;
          a10(indx) := t(ddindx).contr_type;
          a11(indx) := t(ddindx).contr_drafting_req;
          a12(indx) := t(ddindx).priority;
          a13(indx) := t(ddindx).senior_contr_person_id;
          a14(indx) := t(ddindx).contr_spec_person_id;
          a15(indx) := t(ddindx).bom_person_id;
          a16(indx) := t(ddindx).legal_person_id;
          a17(indx) := t(ddindx).highest_apvl;
          a18(indx) := t(ddindx).current_apvl_status;
          a19(indx) := t(ddindx).support_apvl;
          a20(indx) := t(ddindx).international_apvl;
          a21(indx) := t(ddindx).credit_apvl;
          a22(indx) := t(ddindx).fin_escrow_req;
          a23(indx) := t(ddindx).fin_escrow_status;
          a24(indx) := t(ddindx).csi_rollin;
          a25(indx) := t(ddindx).licence_credit_ver;
          a26(indx) := t(ddindx).support_credit_ver;
          a27(indx) := t(ddindx).md_deal_summary;
          a28(indx) := t(ddindx).prod_avail_ver;
          a29(indx) := t(ddindx).ship_location;
          a30(indx) := t(ddindx).tax_exempt_cert;
          a31(indx) := t(ddindx).nl_rev_alloc_req;
          a32(indx) := t(ddindx).consulting_cc;
          a33(indx) := t(ddindx).senior_contr_notes;
          a34(indx) := t(ddindx).legal_notes;
          a35(indx) := t(ddindx).bom_notes;
          a36(indx) := t(ddindx).contr_notes;
          a37(indx) := t(ddindx).contr_status;
          a38(indx) := t(ddindx).extra_docs;
          a39(indx) := t(ddindx).cust_name;
          a40(indx) := t(ddindx).site_name;
          a41(indx) := t(ddindx).oppy_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy as_osi_lead_pub.osi_cvb_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cvehicle := a0(indx);
          t(ddindx).vehicle := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t as_osi_lead_pub.osi_cvb_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cvehicle;
          a1(indx) := t(ddindx).vehicle;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p10(t out nocopy as_osi_lead_pub.osi_cnb_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cvehicle := a0(indx);
          t(ddindx).contr_name := a1(indx);
          t(ddindx).cname_id := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t as_osi_lead_pub.osi_cnb_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cvehicle;
          a1(indx) := t(ddindx).contr_name;
          a2(indx) := t(ddindx).cname_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p14(t out nocopy as_osi_lead_pub.osi_lkp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lkp_type := a0(indx);
          t(ddindx).lkp_code := a1(indx);
          t(ddindx).lkp_value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t as_osi_lead_pub.osi_lkp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).lkp_type;
          a1(indx) := t(ddindx).lkp_code;
          a2(indx) := t(ddindx).lkp_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p18(t out nocopy as_osi_lead_pub.osi_nam_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).nam_type := a0(indx);
          t(ddindx).nam_id := a1(indx);
          t(ddindx).nam_value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t as_osi_lead_pub.osi_nam_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).nam_type;
          a1(indx) := t(ddindx).nam_id;
          a2(indx) := t(ddindx).nam_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p22(t out nocopy as_osi_lead_pub.osi_ccs_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cc := a0(indx);
          t(ddindx).center_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t as_osi_lead_pub.osi_ccs_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cc;
          a1(indx) := t(ddindx).center_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p26(t out nocopy as_osi_lead_pub.osi_ovm_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ovm_code := a0(indx);
          t(ddindx).ovm_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t as_osi_lead_pub.osi_ovm_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ovm_code;
          a1(indx) := t(ddindx).ovm_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p30(t out nocopy as_osi_lead_pub.osi_ovd_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ovd_code := a0(indx);
          t(ddindx).ovd_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t as_osi_lead_pub.osi_ovd_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ovd_code;
          a1(indx) := t(ddindx).ovd_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure osi_lead_fetch(p_api_version_number  NUMBER
    , p_lead_id  VARCHAR2
    , p2_a0 out nocopy  DATE
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  DATE
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_rec as_osi_lead_pub.osi_rec_type;
    ddp_osi_ovd_tbl as_osi_lead_pub.osi_ovd_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_lead_fetch(p_api_version_number,
      p_lead_id,
      ddp_osi_rec,
      ddp_osi_ovd_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddp_osi_rec.last_update_date;
    p2_a1 := ddp_osi_rec.last_updated_by;
    p2_a2 := ddp_osi_rec.creation_date;
    p2_a3 := ddp_osi_rec.created_by;
    p2_a4 := ddp_osi_rec.last_update_login;
    p2_a5 := rosetta_g_miss_num_map(ddp_osi_rec.lead_id);
    p2_a6 := rosetta_g_miss_num_map(ddp_osi_rec.osi_lead_id);
    p2_a7 := ddp_osi_rec.cvehicle;
    p2_a8 := ddp_osi_rec.cname_id;
    p2_a9 := ddp_osi_rec.po_from;
    p2_a10 := ddp_osi_rec.contr_type;
    p2_a11 := ddp_osi_rec.contr_drafting_req;
    p2_a12 := ddp_osi_rec.priority;
    p2_a13 := ddp_osi_rec.senior_contr_person_id;
    p2_a14 := ddp_osi_rec.contr_spec_person_id;
    p2_a15 := ddp_osi_rec.bom_person_id;
    p2_a16 := ddp_osi_rec.legal_person_id;
    p2_a17 := ddp_osi_rec.highest_apvl;
    p2_a18 := ddp_osi_rec.current_apvl_status;
    p2_a19 := ddp_osi_rec.support_apvl;
    p2_a20 := ddp_osi_rec.international_apvl;
    p2_a21 := ddp_osi_rec.credit_apvl;
    p2_a22 := ddp_osi_rec.fin_escrow_req;
    p2_a23 := ddp_osi_rec.fin_escrow_status;
    p2_a24 := ddp_osi_rec.csi_rollin;
    p2_a25 := ddp_osi_rec.licence_credit_ver;
    p2_a26 := ddp_osi_rec.support_credit_ver;
    p2_a27 := ddp_osi_rec.md_deal_summary;
    p2_a28 := ddp_osi_rec.prod_avail_ver;
    p2_a29 := ddp_osi_rec.ship_location;
    p2_a30 := ddp_osi_rec.tax_exempt_cert;
    p2_a31 := ddp_osi_rec.nl_rev_alloc_req;
    p2_a32 := ddp_osi_rec.consulting_cc;
    p2_a33 := ddp_osi_rec.senior_contr_notes;
    p2_a34 := ddp_osi_rec.legal_notes;
    p2_a35 := ddp_osi_rec.bom_notes;
    p2_a36 := ddp_osi_rec.contr_notes;
    p2_a37 := ddp_osi_rec.contr_status;
    p2_a38 := ddp_osi_rec.extra_docs;
    p2_a39 := ddp_osi_rec.cust_name;
    p2_a40 := ddp_osi_rec.site_name;
    p2_a41 := ddp_osi_rec.oppy_name;

    as_osi_lead_pub_w.rosetta_table_copy_out_p30(ddp_osi_ovd_tbl, p3_a0
      , p3_a1
      );
  end;

  procedure osi_lead_fetch_all(p_api_version_number  NUMBER
    , p_lead_id  VARCHAR2
    , p2_a0 out nocopy  DATE
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  DATE
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_rec as_osi_lead_pub.osi_rec_type;
    ddp_osi_cvb_tbl as_osi_lead_pub.osi_cvb_tbl_type;
    ddp_osi_cnb_tbl as_osi_lead_pub.osi_cnb_tbl_type;
    ddp_osi_lkp_tbl as_osi_lead_pub.osi_lkp_tbl_type;
    ddp_osi_nam_tbl as_osi_lead_pub.osi_nam_tbl_type;
    ddp_osi_ccs_tbl as_osi_lead_pub.osi_ccs_tbl_type;
    ddp_osi_ovd_tbl as_osi_lead_pub.osi_ovd_tbl_type;
    ddp_osi_ovm_tbl as_osi_lead_pub.osi_ovm_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_lead_fetch_all(p_api_version_number,
      p_lead_id,
      ddp_osi_rec,
      ddp_osi_cvb_tbl,
      ddp_osi_cnb_tbl,
      ddp_osi_lkp_tbl,
      ddp_osi_nam_tbl,
      ddp_osi_ccs_tbl,
      ddp_osi_ovd_tbl,
      ddp_osi_ovm_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddp_osi_rec.last_update_date;
    p2_a1 := ddp_osi_rec.last_updated_by;
    p2_a2 := ddp_osi_rec.creation_date;
    p2_a3 := ddp_osi_rec.created_by;
    p2_a4 := ddp_osi_rec.last_update_login;
    p2_a5 := rosetta_g_miss_num_map(ddp_osi_rec.lead_id);
    p2_a6 := rosetta_g_miss_num_map(ddp_osi_rec.osi_lead_id);
    p2_a7 := ddp_osi_rec.cvehicle;
    p2_a8 := ddp_osi_rec.cname_id;
    p2_a9 := ddp_osi_rec.po_from;
    p2_a10 := ddp_osi_rec.contr_type;
    p2_a11 := ddp_osi_rec.contr_drafting_req;
    p2_a12 := ddp_osi_rec.priority;
    p2_a13 := ddp_osi_rec.senior_contr_person_id;
    p2_a14 := ddp_osi_rec.contr_spec_person_id;
    p2_a15 := ddp_osi_rec.bom_person_id;
    p2_a16 := ddp_osi_rec.legal_person_id;
    p2_a17 := ddp_osi_rec.highest_apvl;
    p2_a18 := ddp_osi_rec.current_apvl_status;
    p2_a19 := ddp_osi_rec.support_apvl;
    p2_a20 := ddp_osi_rec.international_apvl;
    p2_a21 := ddp_osi_rec.credit_apvl;
    p2_a22 := ddp_osi_rec.fin_escrow_req;
    p2_a23 := ddp_osi_rec.fin_escrow_status;
    p2_a24 := ddp_osi_rec.csi_rollin;
    p2_a25 := ddp_osi_rec.licence_credit_ver;
    p2_a26 := ddp_osi_rec.support_credit_ver;
    p2_a27 := ddp_osi_rec.md_deal_summary;
    p2_a28 := ddp_osi_rec.prod_avail_ver;
    p2_a29 := ddp_osi_rec.ship_location;
    p2_a30 := ddp_osi_rec.tax_exempt_cert;
    p2_a31 := ddp_osi_rec.nl_rev_alloc_req;
    p2_a32 := ddp_osi_rec.consulting_cc;
    p2_a33 := ddp_osi_rec.senior_contr_notes;
    p2_a34 := ddp_osi_rec.legal_notes;
    p2_a35 := ddp_osi_rec.bom_notes;
    p2_a36 := ddp_osi_rec.contr_notes;
    p2_a37 := ddp_osi_rec.contr_status;
    p2_a38 := ddp_osi_rec.extra_docs;
    p2_a39 := ddp_osi_rec.cust_name;
    p2_a40 := ddp_osi_rec.site_name;
    p2_a41 := ddp_osi_rec.oppy_name;

    as_osi_lead_pub_w.rosetta_table_copy_out_p6(ddp_osi_cvb_tbl, p3_a0
      , p3_a1
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p10(ddp_osi_cnb_tbl, p4_a0
      , p4_a1
      , p4_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p14(ddp_osi_lkp_tbl, p5_a0
      , p5_a1
      , p5_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p18(ddp_osi_nam_tbl, p6_a0
      , p6_a1
      , p6_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p22(ddp_osi_ccs_tbl, p7_a0
      , p7_a1
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p30(ddp_osi_ovd_tbl, p8_a0
      , p8_a1
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p26(ddp_osi_ovm_tbl, p9_a0
      , p9_a1
      );
  end;

  procedure osi_lookup_fetch_all(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_cvb_tbl as_osi_lead_pub.osi_cvb_tbl_type;
    ddp_osi_cnb_tbl as_osi_lead_pub.osi_cnb_tbl_type;
    ddp_osi_lkp_tbl as_osi_lead_pub.osi_lkp_tbl_type;
    ddp_osi_nam_tbl as_osi_lead_pub.osi_nam_tbl_type;
    ddp_osi_ccs_tbl as_osi_lead_pub.osi_ccs_tbl_type;
    ddp_osi_ovm_tbl as_osi_lead_pub.osi_ovm_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_lookup_fetch_all(p_api_version_number,
      ddp_osi_cvb_tbl,
      ddp_osi_cnb_tbl,
      ddp_osi_lkp_tbl,
      ddp_osi_nam_tbl,
      ddp_osi_ccs_tbl,
      ddp_osi_ovm_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    as_osi_lead_pub_w.rosetta_table_copy_out_p6(ddp_osi_cvb_tbl, p1_a0
      , p1_a1
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p10(ddp_osi_cnb_tbl, p2_a0
      , p2_a1
      , p2_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p14(ddp_osi_lkp_tbl, p3_a0
      , p3_a1
      , p3_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p18(ddp_osi_nam_tbl, p4_a0
      , p4_a1
      , p4_a2
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p22(ddp_osi_ccs_tbl, p5_a0
      , p5_a1
      );

    as_osi_lead_pub_w.rosetta_table_copy_out_p26(ddp_osi_ovm_tbl, p6_a0
      , p6_a1
      );
  end;

  procedure osi_lead_update(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  DATE := fnd_api.g_miss_date
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  VARCHAR2 := fnd_api.g_miss_char
    , p3_a34  VARCHAR2 := fnd_api.g_miss_char
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  VARCHAR2 := fnd_api.g_miss_char
    , p3_a37  VARCHAR2 := fnd_api.g_miss_char
    , p3_a38  VARCHAR2 := fnd_api.g_miss_char
    , p3_a39  VARCHAR2 := fnd_api.g_miss_char
    , p3_a40  VARCHAR2 := fnd_api.g_miss_char
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_osi_rec as_osi_lead_pub.osi_rec_type;
    ddp_osi_ovd_tbl as_osi_lead_pub.osi_ovd_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_osi_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a0);
    ddp_osi_rec.last_updated_by := p3_a1;
    ddp_osi_rec.creation_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_osi_rec.created_by := p3_a3;
    ddp_osi_rec.last_update_login := p3_a4;
    ddp_osi_rec.lead_id := rosetta_g_miss_num_map(p3_a5);
    ddp_osi_rec.osi_lead_id := rosetta_g_miss_num_map(p3_a6);
    ddp_osi_rec.cvehicle := p3_a7;
    ddp_osi_rec.cname_id := p3_a8;
    ddp_osi_rec.po_from := p3_a9;
    ddp_osi_rec.contr_type := p3_a10;
    ddp_osi_rec.contr_drafting_req := p3_a11;
    ddp_osi_rec.priority := p3_a12;
    ddp_osi_rec.senior_contr_person_id := p3_a13;
    ddp_osi_rec.contr_spec_person_id := p3_a14;
    ddp_osi_rec.bom_person_id := p3_a15;
    ddp_osi_rec.legal_person_id := p3_a16;
    ddp_osi_rec.highest_apvl := p3_a17;
    ddp_osi_rec.current_apvl_status := p3_a18;
    ddp_osi_rec.support_apvl := p3_a19;
    ddp_osi_rec.international_apvl := p3_a20;
    ddp_osi_rec.credit_apvl := p3_a21;
    ddp_osi_rec.fin_escrow_req := p3_a22;
    ddp_osi_rec.fin_escrow_status := p3_a23;
    ddp_osi_rec.csi_rollin := p3_a24;
    ddp_osi_rec.licence_credit_ver := p3_a25;
    ddp_osi_rec.support_credit_ver := p3_a26;
    ddp_osi_rec.md_deal_summary := p3_a27;
    ddp_osi_rec.prod_avail_ver := p3_a28;
    ddp_osi_rec.ship_location := p3_a29;
    ddp_osi_rec.tax_exempt_cert := p3_a30;
    ddp_osi_rec.nl_rev_alloc_req := p3_a31;
    ddp_osi_rec.consulting_cc := p3_a32;
    ddp_osi_rec.senior_contr_notes := p3_a33;
    ddp_osi_rec.legal_notes := p3_a34;
    ddp_osi_rec.bom_notes := p3_a35;
    ddp_osi_rec.contr_notes := p3_a36;
    ddp_osi_rec.contr_status := p3_a37;
    ddp_osi_rec.extra_docs := p3_a38;
    ddp_osi_rec.cust_name := p3_a39;
    ddp_osi_rec.site_name := p3_a40;
    ddp_osi_rec.oppy_name := p3_a41;

    as_osi_lead_pub_w.rosetta_table_copy_in_p30(ddp_osi_ovd_tbl, p4_a0
      , p4_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_lead_update(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_osi_rec,
      ddp_osi_ovd_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure osi_cvb_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_cvb_tbl as_osi_lead_pub.osi_cvb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_cvb_fetch(p_api_version_number,
      ddp_osi_cvb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    as_osi_lead_pub_w.rosetta_table_copy_out_p6(ddp_osi_cvb_tbl, p1_a0
      , p1_a1
      );
  end;

  procedure osi_cnb_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_cnb_tbl as_osi_lead_pub.osi_cnb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_cnb_fetch(p_api_version_number,
      ddp_osi_cnb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    as_osi_lead_pub_w.rosetta_table_copy_out_p10(ddp_osi_cnb_tbl, p1_a0
      , p1_a1
      , p1_a2
      );
  end;

  procedure osi_lkp_fetch(p_api_version_number  NUMBER
    , p_osi_lkp_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_osi_lkp_tbl as_osi_lead_pub.osi_lkp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_lkp_fetch(p_api_version_number,
      p_osi_lkp_type,
      ddp_osi_lkp_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    as_osi_lead_pub_w.rosetta_table_copy_out_p14(ddp_osi_lkp_tbl, p2_a0
      , p2_a1
      , p2_a2
      );
  end;

  procedure osi_nam_fetch(p_api_version_number  NUMBER
    , p_osi_nam_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_nam_tbl as_osi_lead_pub.osi_nam_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_nam_fetch(p_api_version_number,
      p_osi_nam_type,
      ddp_osi_nam_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    as_osi_lead_pub_w.rosetta_table_copy_out_p18(ddp_osi_nam_tbl, p2_a0
      , p2_a1
      , p2_a2
      );
  end;

end as_osi_lead_pub_w;

/
