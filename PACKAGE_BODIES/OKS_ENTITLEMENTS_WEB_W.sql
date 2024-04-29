--------------------------------------------------------
--  DDL for Package Body OKS_ENTITLEMENTS_WEB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENTITLEMENTS_WEB_W" as
  /* $Header: OKSWENWB.pls 120.0 2005/05/25 18:33:56 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p19(t out nocopy oks_entitlements_web.output_tbl_contract, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_number := a0(indx);
          t(ddindx).contract_number_modifier := a1(indx);
          t(ddindx).contract_category := a2(indx);
          t(ddindx).contract_category_meaning := a3(indx);
          t(ddindx).contract_status_code := a4(indx);
          t(ddindx).contract_status_meaning := a5(indx);
          t(ddindx).known_as := a6(indx);
          t(ddindx).short_description := a7(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).contract_amount := a11(indx);
          t(ddindx).amount_code := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t oks_entitlements_web.output_tbl_contract, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).contract_number;
          a1(indx) := t(ddindx).contract_number_modifier;
          a2(indx) := t(ddindx).contract_category;
          a3(indx) := t(ddindx).contract_category_meaning;
          a4(indx) := t(ddindx).contract_status_code;
          a5(indx) := t(ddindx).contract_status_meaning;
          a6(indx) := t(ddindx).known_as;
          a7(indx) := t(ddindx).short_description;
          a8(indx) := t(ddindx).start_date;
          a9(indx) := t(ddindx).end_date;
          a10(indx) := t(ddindx).date_terminated;
          a11(indx) := t(ddindx).contract_amount;
          a12(indx) := t(ddindx).amount_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p21(t out nocopy oks_entitlements_web.account_all_id_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t oks_entitlements_web.account_all_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p23(t out nocopy oks_entitlements_web.party_sites_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id1 := a0(indx);
          t(ddindx).id2 := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t oks_entitlements_web.party_sites_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id1;
          a1(indx) := t(ddindx).id2;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p25(t out nocopy oks_entitlements_web.party_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id1 := a0(indx);
          t(ddindx).id2 := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t oks_entitlements_web.party_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id1;
          a1(indx) := t(ddindx).id2;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure rosetta_table_copy_in_p27(t out nocopy oks_entitlements_web.party_systems_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id1 := a0(indx);
          t(ddindx).id2 := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t oks_entitlements_web.party_systems_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id1;
          a1(indx) := t(ddindx).id2;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure rosetta_table_copy_in_p29(t out nocopy oks_entitlements_web.party_products_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id1 := a0(indx);
          t(ddindx).id2 := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t oks_entitlements_web.party_products_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id1;
          a1(indx) := t(ddindx).id2;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p31(t out nocopy oks_entitlements_web.contract_cat_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_cat_code := a0(indx);
          t(ddindx).contract_cat_meaning := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t oks_entitlements_web.contract_cat_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).contract_cat_code;
          a1(indx) := t(ddindx).contract_cat_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p33(t out nocopy oks_entitlements_web.contract_status_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_status_code := a0(indx);
          t(ddindx).contract_status_meaning := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t oks_entitlements_web.contract_status_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).contract_status_code;
          a1(indx) := t(ddindx).contract_status_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p37(t out nocopy oks_entitlements_web.party_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).rle_code := a1(indx);
          t(ddindx).party_role := a2(indx);
          t(ddindx).party_name := a3(indx);
          t(ddindx).party_number := a4(indx);
          t(ddindx).gsa_flag := a5(indx);
          t(ddindx).bill_profile := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t oks_entitlements_web.party_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_400();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_400();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).rle_code;
          a2(indx) := t(ddindx).party_role;
          a3(indx) := t(ddindx).party_name;
          a4(indx) := t(ddindx).party_number;
          a5(indx) := t(ddindx).gsa_flag;
          a6(indx) := t(ddindx).bill_profile;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p39(t out nocopy oks_entitlements_web.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_400
    , a12 JTF_VARCHAR2_TABLE_400
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_400
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_400
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).line_id := a1(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).exemption := a4(indx);
          t(ddindx).line_type := a5(indx);
          t(ddindx).line_number := a6(indx);
          t(ddindx).line_name := a7(indx);
          t(ddindx).line_description := a8(indx);
          t(ddindx).inv_print_flag := a9(indx);
          t(ddindx).invoice_text := a10(indx);
          t(ddindx).account_name := a11(indx);
          t(ddindx).account_desc := a12(indx);
          t(ddindx).account_number := a13(indx);
          t(ddindx).quantity := a14(indx);
          t(ddindx).coverage_name := a15(indx);
          t(ddindx).bill_to_site := a16(indx);
          t(ddindx).bill_to_address := a17(indx);
          t(ddindx).bill_to_city_state_zip := a18(indx);
          t(ddindx).bill_to_country := a19(indx);
          t(ddindx).ship_to_site := a20(indx);
          t(ddindx).ship_to_address := a21(indx);
          t(ddindx).ship_to_city_state_zip := a22(indx);
          t(ddindx).ship_to_country := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t oks_entitlements_web.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_400
    , a12 out nocopy JTF_VARCHAR2_TABLE_400
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_400
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_400
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_400();
    a12 := JTF_VARCHAR2_TABLE_400();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_400();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_400();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_400();
      a12 := JTF_VARCHAR2_TABLE_400();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_400();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_400();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).line_id;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := t(ddindx).exemption;
          a5(indx) := t(ddindx).line_type;
          a6(indx) := t(ddindx).line_number;
          a7(indx) := t(ddindx).line_name;
          a8(indx) := t(ddindx).line_description;
          a9(indx) := t(ddindx).inv_print_flag;
          a10(indx) := t(ddindx).invoice_text;
          a11(indx) := t(ddindx).account_name;
          a12(indx) := t(ddindx).account_desc;
          a13(indx) := t(ddindx).account_number;
          a14(indx) := t(ddindx).quantity;
          a15(indx) := t(ddindx).coverage_name;
          a16(indx) := t(ddindx).bill_to_site;
          a17(indx) := t(ddindx).bill_to_address;
          a18(indx) := t(ddindx).bill_to_city_state_zip;
          a19(indx) := t(ddindx).bill_to_country;
          a20(indx) := t(ddindx).ship_to_site;
          a21(indx) := t(ddindx).ship_to_address;
          a22(indx) := t(ddindx).ship_to_city_state_zip;
          a23(indx) := t(ddindx).ship_to_country;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p41(t out nocopy oks_entitlements_web.party_contact_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_400
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).rle_code := a1(indx);
          t(ddindx).owner_table_id := a2(indx);
          t(ddindx).contact_role := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).contact_name := a6(indx);
          t(ddindx).primary_email := a7(indx);
          t(ddindx).contact_id := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t oks_entitlements_web.party_contact_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_400
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_400();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_400();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).rle_code;
          a2(indx) := t(ddindx).owner_table_id;
          a3(indx) := t(ddindx).contact_role;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).contact_name;
          a7(indx) := t(ddindx).primary_email;
          a8(indx) := t(ddindx).contact_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p43(t out nocopy oks_entitlements_web.pty_cntct_dtls_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).owner_table_id := a0(indx);
          t(ddindx).contact_type := a1(indx);
          t(ddindx).email_address := a2(indx);
          t(ddindx).phone_type := a3(indx);
          t(ddindx).phone_country_cd := a4(indx);
          t(ddindx).phone_area_cd := a5(indx);
          t(ddindx).phone_number := a6(indx);
          t(ddindx).phone_extension := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t oks_entitlements_web.pty_cntct_dtls_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).owner_table_id;
          a1(indx) := t(ddindx).contact_type;
          a2(indx) := t(ddindx).email_address;
          a3(indx) := t(ddindx).phone_type;
          a4(indx) := t(ddindx).phone_country_cd;
          a5(indx) := t(ddindx).phone_area_cd;
          a6(indx) := t(ddindx).phone_number;
          a7(indx) := t(ddindx).phone_extension;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p46(t out nocopy oks_entitlements_web.covered_level_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).covered_level := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).duration := a5(indx);
          t(ddindx).period := a6(indx);
          t(ddindx).terminated := a7(indx);
          t(ddindx).renewal_type := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p46;
  procedure rosetta_table_copy_out_p46(t oks_entitlements_web.covered_level_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
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
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).covered_level;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).duration;
          a6(indx) := t(ddindx).period;
          a7(indx) := t(ddindx).terminated;
          a8(indx) := t(ddindx).renewal_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p46;

  procedure rosetta_table_copy_in_p48(t out nocopy oks_entitlements_web.cust_contacts_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cust_contacts_role := a0(indx);
          t(ddindx).cust_contacts_address := a1(indx);
          t(ddindx).cust_contacts_name := a2(indx);
          t(ddindx).cust_contacts_start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).cust_contacts_end_date := rosetta_g_miss_date_in_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p48;
  procedure rosetta_table_copy_out_p48(t oks_entitlements_web.cust_contacts_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cust_contacts_role;
          a1(indx) := t(ddindx).cust_contacts_address;
          a2(indx) := t(ddindx).cust_contacts_name;
          a3(indx) := t(ddindx).cust_contacts_start_date;
          a4(indx) := t(ddindx).cust_contacts_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p48;

  procedure rosetta_table_copy_in_p51(t out nocopy oks_entitlements_web.bus_proc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).bus_proc_id := a0(indx);
          t(ddindx).bus_proc_offset_duration := a1(indx);
          t(ddindx).bus_proc_name := a2(indx);
          t(ddindx).bus_proc_offset_period := a3(indx);
          t(ddindx).bus_proc_discount := a4(indx);
          t(ddindx).bus_proc_price_list := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p51;
  procedure rosetta_table_copy_out_p51(t oks_entitlements_web.bus_proc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).bus_proc_id;
          a1(indx) := t(ddindx).bus_proc_offset_duration;
          a2(indx) := t(ddindx).bus_proc_name;
          a3(indx) := t(ddindx).bus_proc_offset_period;
          a4(indx) := t(ddindx).bus_proc_discount;
          a5(indx) := t(ddindx).bus_proc_price_list;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p51;

  procedure rosetta_table_copy_in_p54(t out nocopy oks_entitlements_web.coverage_times_tbl_type, a0 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).day_of_week := a0(indx);
          t(ddindx).start_time := a1(indx);
          t(ddindx).end_time := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p54;
  procedure rosetta_table_copy_out_p54(t oks_entitlements_web.coverage_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).day_of_week;
          a1(indx) := t(ddindx).start_time;
          a2(indx) := t(ddindx).end_time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p54;

  procedure rosetta_table_copy_in_p56(t out nocopy oks_entitlements_web.reaction_times_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).severity := a1(indx);
          t(ddindx).work_thru_yn := a2(indx);
          t(ddindx).active_yn := a3(indx);
          t(ddindx).sun := a4(indx);
          t(ddindx).mon := a5(indx);
          t(ddindx).tue := a6(indx);
          t(ddindx).wed := a7(indx);
          t(ddindx).thr := a8(indx);
          t(ddindx).fri := a9(indx);
          t(ddindx).sat := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p56;
  procedure rosetta_table_copy_out_p56(t oks_entitlements_web.reaction_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).severity;
          a2(indx) := t(ddindx).work_thru_yn;
          a3(indx) := t(ddindx).active_yn;
          a4(indx) := t(ddindx).sun;
          a5(indx) := t(ddindx).mon;
          a6(indx) := t(ddindx).tue;
          a7(indx) := t(ddindx).wed;
          a8(indx) := t(ddindx).thr;
          a9(indx) := t(ddindx).fri;
          a10(indx) := t(ddindx).sat;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p56;

  procedure rosetta_table_copy_in_p58(t out nocopy oks_entitlements_web.resolution_times_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).severity := a1(indx);
          t(ddindx).work_thru_yn := a2(indx);
          t(ddindx).active_yn := a3(indx);
          t(ddindx).sun := a4(indx);
          t(ddindx).mon := a5(indx);
          t(ddindx).tue := a6(indx);
          t(ddindx).wed := a7(indx);
          t(ddindx).thr := a8(indx);
          t(ddindx).fri := a9(indx);
          t(ddindx).sat := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p58;
  procedure rosetta_table_copy_out_p58(t oks_entitlements_web.resolution_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).severity;
          a2(indx) := t(ddindx).work_thru_yn;
          a3(indx) := t(ddindx).active_yn;
          a4(indx) := t(ddindx).sun;
          a5(indx) := t(ddindx).mon;
          a6(indx) := t(ddindx).tue;
          a7(indx) := t(ddindx).wed;
          a8(indx) := t(ddindx).thr;
          a9(indx) := t(ddindx).fri;
          a10(indx) := t(ddindx).sat;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p58;

  procedure rosetta_table_copy_in_p60(t out nocopy oks_entitlements_web.pref_resource_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_type := a0(indx);
          t(ddindx).name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p60;
  procedure rosetta_table_copy_out_p60(t oks_entitlements_web.pref_resource_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_type;
          a1(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p60;

  procedure rosetta_table_copy_in_p62(t out nocopy oks_entitlements_web.bus_proc_bil_typ_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).bill_type := a0(indx);
          t(ddindx).max_amount := a1(indx);
          t(ddindx).per_covered := a2(indx);
          t(ddindx).billing_rate := a3(indx);
          t(ddindx).unit_of_measure := a4(indx);
          t(ddindx).flat_rate := a5(indx);
          t(ddindx).per_over_list_price := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p62;
  procedure rosetta_table_copy_out_p62(t oks_entitlements_web.bus_proc_bil_typ_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).bill_type;
          a1(indx) := t(ddindx).max_amount;
          a2(indx) := t(ddindx).per_covered;
          a3(indx) := t(ddindx).billing_rate;
          a4(indx) := t(ddindx).unit_of_measure;
          a5(indx) := t(ddindx).flat_rate;
          a6(indx) := t(ddindx).per_over_list_price;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p62;

  procedure rosetta_table_copy_in_p65(t out nocopy oks_entitlements_web.covered_prods_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_2000
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
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).covered_prod_id := a0(indx);
          t(ddindx).covered_prod_line_number := a1(indx);
          t(ddindx).covered_prod_invoice_text := a2(indx);
          t(ddindx).covered_prod_line_ref := a3(indx);
          t(ddindx).covered_prod_rate_fixed := a4(indx);
          t(ddindx).covered_prod_rate_minimum := a5(indx);
          t(ddindx).covered_prod_rate_default := a6(indx);
          t(ddindx).covered_prod_uom := a7(indx);
          t(ddindx).covered_prod_period := a8(indx);
          t(ddindx).covered_prod_amcv := a9(indx);
          t(ddindx).covered_prod_level_yn := a10(indx);
          t(ddindx).covered_prod_reading := a11(indx);
          t(ddindx).covered_prod_net_reading := a12(indx);
          t(ddindx).covered_prod_price := a13(indx);
          t(ddindx).covered_prod_name := a14(indx);
          t(ddindx).covered_prod_description := a15(indx);
          t(ddindx).covered_prod_details := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p65;
  procedure rosetta_table_copy_out_p65(t oks_entitlements_web.covered_prods_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_2000();
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
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_2000();
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
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).covered_prod_id;
          a1(indx) := t(ddindx).covered_prod_line_number;
          a2(indx) := t(ddindx).covered_prod_invoice_text;
          a3(indx) := t(ddindx).covered_prod_line_ref;
          a4(indx) := t(ddindx).covered_prod_rate_fixed;
          a5(indx) := t(ddindx).covered_prod_rate_minimum;
          a6(indx) := t(ddindx).covered_prod_rate_default;
          a7(indx) := t(ddindx).covered_prod_uom;
          a8(indx) := t(ddindx).covered_prod_period;
          a9(indx) := t(ddindx).covered_prod_amcv;
          a10(indx) := t(ddindx).covered_prod_level_yn;
          a11(indx) := t(ddindx).covered_prod_reading;
          a12(indx) := t(ddindx).covered_prod_net_reading;
          a13(indx) := t(ddindx).covered_prod_price;
          a14(indx) := t(ddindx).covered_prod_name;
          a15(indx) := t(ddindx).covered_prod_description;
          a16(indx) := t(ddindx).covered_prod_details;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p65;

  procedure rosetta_table_copy_in_p67(t out nocopy oks_entitlements_web.counter_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).counter_type := a0(indx);
          t(ddindx).counter_uom_code := a1(indx);
          t(ddindx).counter_name := a2(indx);
          t(ddindx).counter_time_stamp := a3(indx);
          t(ddindx).counter_net_reading := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p67;
  procedure rosetta_table_copy_out_p67(t oks_entitlements_web.counter_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).counter_type;
          a1(indx) := t(ddindx).counter_uom_code;
          a2(indx) := t(ddindx).counter_name;
          a3(indx) := t(ddindx).counter_time_stamp;
          a4(indx) := t(ddindx).counter_net_reading;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p67;

  procedure simple_srch_rslts(p_contract_party_id  NUMBER
    , p_account_id  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a8 out nocopy JTF_DATE_TABLE
    , p5_a9 out nocopy JTF_DATE_TABLE
    , p5_a10 out nocopy JTF_DATE_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_contract_tbl oks_entitlements_web.output_tbl_contract;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.simple_srch_rslts(p_contract_party_id,
      p_account_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_contract_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    oks_entitlements_web_w.rosetta_table_copy_out_p19(ddx_contract_tbl, p5_a0
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
      );
  end;

  procedure cntrct_srch_rslts(p_contract_number  VARCHAR2
    , p_contract_status_code  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_end_date_from  date
    , p_end_date_to  date
    , p_date_terminated_from  date
    , p_date_terminated_to  date
    , p_contract_party_id  NUMBER
    , p_covlvl_site_id  NUMBER
    , p_covlvl_site_name  VARCHAR2
    , p_covlvl_system_id  NUMBER
    , p_covlvl_system_name  VARCHAR2
    , p_covlvl_product_id  NUMBER
    , p_covlvl_product_name  VARCHAR2
    , p_covlvl_item_id  NUMBER
    , p_covlvl_item_name  VARCHAR2
    , p_entitlement_check_yn  VARCHAR2
    , p_account_check_all  VARCHAR2
    , p_account_id  VARCHAR2
    , p_covlvl_party_id  VARCHAR2
    , p21_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p25_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p25_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p25_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p25_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p25_a8 out nocopy JTF_DATE_TABLE
    , p25_a9 out nocopy JTF_DATE_TABLE
    , p25_a10 out nocopy JTF_DATE_TABLE
    , p25_a11 out nocopy JTF_NUMBER_TABLE
    , p25_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_start_date_from date;
    ddp_start_date_to date;
    ddp_end_date_from date;
    ddp_end_date_to date;
    ddp_date_terminated_from date;
    ddp_date_terminated_to date;
    ddp_account_all_id oks_entitlements_web.account_all_id_tbl_type;
    ddx_contract_tbl oks_entitlements_web.output_tbl_contract;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_start_date_from := rosetta_g_miss_date_in_map(p_start_date_from);

    ddp_start_date_to := rosetta_g_miss_date_in_map(p_start_date_to);

    ddp_end_date_from := rosetta_g_miss_date_in_map(p_end_date_from);

    ddp_end_date_to := rosetta_g_miss_date_in_map(p_end_date_to);

    ddp_date_terminated_from := rosetta_g_miss_date_in_map(p_date_terminated_from);

    ddp_date_terminated_to := rosetta_g_miss_date_in_map(p_date_terminated_to);














    oks_entitlements_web_w.rosetta_table_copy_in_p21(ddp_account_all_id, p21_a0
      );





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.cntrct_srch_rslts(p_contract_number,
      p_contract_status_code,
      ddp_start_date_from,
      ddp_start_date_to,
      ddp_end_date_from,
      ddp_end_date_to,
      ddp_date_terminated_from,
      ddp_date_terminated_to,
      p_contract_party_id,
      p_covlvl_site_id,
      p_covlvl_site_name,
      p_covlvl_system_id,
      p_covlvl_system_name,
      p_covlvl_product_id,
      p_covlvl_product_name,
      p_covlvl_item_id,
      p_covlvl_item_name,
      p_entitlement_check_yn,
      p_account_check_all,
      p_account_id,
      p_covlvl_party_id,
      ddp_account_all_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_contract_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

























    oks_entitlements_web_w.rosetta_table_copy_out_p19(ddx_contract_tbl, p25_a0
      , p25_a1
      , p25_a2
      , p25_a3
      , p25_a4
      , p25_a5
      , p25_a6
      , p25_a7
      , p25_a8
      , p25_a9
      , p25_a10
      , p25_a11
      , p25_a12
      );
  end;

  procedure party_sites(p_party_id_arg  VARCHAR2
    , p_site_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_party_sites_tbl_type oks_entitlements_web.party_sites_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_sites(p_party_id_arg,
      p_site_name_arg,
      x_return_status,
      ddx_party_sites_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    oks_entitlements_web_w.rosetta_table_copy_out_p23(ddx_party_sites_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      );
  end;

  function duration_period(p_start_date  date
    , p_end_date  date
  ) return number

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := oks_entitlements_web.duration_period(ddp_start_date,
      ddp_end_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  function duration_unit(p_start_date  date
    , p_end_date  date
  ) return varchar2

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := oks_entitlements_web.duration_unit(ddp_start_date,
      ddp_end_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  procedure party_items(p_party_id_arg  VARCHAR2
    , p_item_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_party_items_tbl_type oks_entitlements_web.party_items_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_items(p_party_id_arg,
      p_item_name_arg,
      x_return_status,
      ddx_party_items_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    oks_entitlements_web_w.rosetta_table_copy_out_p25(ddx_party_items_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      );
  end;

  procedure party_systems(p_party_id_arg  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p_system_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_account_id_all oks_entitlements_web.account_all_id_tbl_type;
    ddx_party_systems_tbl_type oks_entitlements_web.party_systems_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    oks_entitlements_web_w.rosetta_table_copy_in_p21(ddp_account_id_all, p1_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_systems(p_party_id_arg,
      ddp_account_id_all,
      p_system_name_arg,
      x_return_status,
      ddx_party_systems_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    oks_entitlements_web_w.rosetta_table_copy_out_p27(ddx_party_systems_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      );
  end;

  procedure party_products(p_party_id_arg  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p_product_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_account_id_all oks_entitlements_web.account_all_id_tbl_type;
    ddx_party_products_tbl_type oks_entitlements_web.party_products_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    oks_entitlements_web_w.rosetta_table_copy_in_p21(ddp_account_id_all, p1_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_products(p_party_id_arg,
      ddp_account_id_all,
      p_product_name_arg,
      x_return_status,
      ddx_party_products_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    oks_entitlements_web_w.rosetta_table_copy_out_p29(ddx_party_products_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      );
  end;

  procedure adv_search_overview(p_party_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_party_name out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_contract_cat_tbl_type oks_entitlements_web.contract_cat_tbl_type;
    ddx_contract_status_tbl_type oks_entitlements_web.contract_status_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.adv_search_overview(p_party_id_arg,
      x_return_status,
      x_party_name,
      ddx_contract_cat_tbl_type,
      ddx_contract_status_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    oks_entitlements_web_w.rosetta_table_copy_out_p31(ddx_contract_cat_tbl_type, p3_a0
      , p3_a1
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p33(ddx_contract_status_tbl_type, p4_a0
      , p4_a1
      );
  end;

  procedure contract_number_overview(p_contract_number_arg  VARCHAR2
    , p_contract_modifier_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  DATE
    , p3_a14 out nocopy  DATE
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  VARCHAR2
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_hdr_rec_type oks_entitlements_web.hdr_rec_type;
    ddx_hdr_addr_rec_type oks_entitlements_web.hdr_addr_rec_type;
    ddx_party_tbl_type oks_entitlements_web.party_tbl_type;
    ddx_line_tbl_type oks_entitlements_web.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.contract_number_overview(p_contract_number_arg,
      p_contract_modifier_arg,
      x_return_status,
      ddx_hdr_rec_type,
      ddx_hdr_addr_rec_type,
      ddx_party_tbl_type,
      ddx_line_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_hdr_rec_type.header_id;
    p3_a1 := ddx_hdr_rec_type.contract_number;
    p3_a2 := ddx_hdr_rec_type.modifier;
    p3_a3 := ddx_hdr_rec_type.version;
    p3_a4 := ddx_hdr_rec_type.known_as;
    p3_a5 := ddx_hdr_rec_type.short_description;
    p3_a6 := ddx_hdr_rec_type.contract_amount;
    p3_a7 := ddx_hdr_rec_type.currency_code;
    p3_a8 := ddx_hdr_rec_type.sts_code;
    p3_a9 := ddx_hdr_rec_type.status;
    p3_a10 := ddx_hdr_rec_type.scs_code;
    p3_a11 := ddx_hdr_rec_type.scs_category;
    p3_a12 := ddx_hdr_rec_type.order_number;
    p3_a13 := ddx_hdr_rec_type.start_date;
    p3_a14 := ddx_hdr_rec_type.end_date;
    p3_a15 := ddx_hdr_rec_type.duration;
    p3_a16 := ddx_hdr_rec_type.period_code;

    p4_a0 := ddx_hdr_addr_rec_type.header_id;
    p4_a1 := ddx_hdr_addr_rec_type.bill_to_customer;
    p4_a2 := ddx_hdr_addr_rec_type.bill_to_site;
    p4_a3 := ddx_hdr_addr_rec_type.bill_to_address;
    p4_a4 := ddx_hdr_addr_rec_type.bill_to_city_state_zip;
    p4_a5 := ddx_hdr_addr_rec_type.bill_to_country;
    p4_a6 := ddx_hdr_addr_rec_type.ship_to_customer;
    p4_a7 := ddx_hdr_addr_rec_type.ship_to_site;
    p4_a8 := ddx_hdr_addr_rec_type.ship_to_address;
    p4_a9 := ddx_hdr_addr_rec_type.ship_to_city_state_zip;
    p4_a10 := ddx_hdr_addr_rec_type.ship_to_country;

    oks_entitlements_web_w.rosetta_table_copy_out_p37(ddx_party_tbl_type, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p39(ddx_line_tbl_type, p6_a0
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
      );
  end;

  procedure contract_overview(p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  DATE
    , p2_a14 out nocopy  DATE
    , p2_a15 out nocopy  NUMBER
    , p2_a16 out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_DATE_TABLE
    , p5_a3 out nocopy JTF_DATE_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_hdr_rec_type oks_entitlements_web.hdr_rec_type;
    ddx_hdr_addr_rec_type oks_entitlements_web.hdr_addr_rec_type;
    ddx_party_tbl_type oks_entitlements_web.party_tbl_type;
    ddx_line_tbl_type oks_entitlements_web.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.contract_overview(p_contract_id_arg,
      x_return_status,
      ddx_hdr_rec_type,
      ddx_hdr_addr_rec_type,
      ddx_party_tbl_type,
      ddx_line_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_hdr_rec_type.header_id;
    p2_a1 := ddx_hdr_rec_type.contract_number;
    p2_a2 := ddx_hdr_rec_type.modifier;
    p2_a3 := ddx_hdr_rec_type.version;
    p2_a4 := ddx_hdr_rec_type.known_as;
    p2_a5 := ddx_hdr_rec_type.short_description;
    p2_a6 := ddx_hdr_rec_type.contract_amount;
    p2_a7 := ddx_hdr_rec_type.currency_code;
    p2_a8 := ddx_hdr_rec_type.sts_code;
    p2_a9 := ddx_hdr_rec_type.status;
    p2_a10 := ddx_hdr_rec_type.scs_code;
    p2_a11 := ddx_hdr_rec_type.scs_category;
    p2_a12 := ddx_hdr_rec_type.order_number;
    p2_a13 := ddx_hdr_rec_type.start_date;
    p2_a14 := ddx_hdr_rec_type.end_date;
    p2_a15 := ddx_hdr_rec_type.duration;
    p2_a16 := ddx_hdr_rec_type.period_code;

    p3_a0 := ddx_hdr_addr_rec_type.header_id;
    p3_a1 := ddx_hdr_addr_rec_type.bill_to_customer;
    p3_a2 := ddx_hdr_addr_rec_type.bill_to_site;
    p3_a3 := ddx_hdr_addr_rec_type.bill_to_address;
    p3_a4 := ddx_hdr_addr_rec_type.bill_to_city_state_zip;
    p3_a5 := ddx_hdr_addr_rec_type.bill_to_country;
    p3_a6 := ddx_hdr_addr_rec_type.ship_to_customer;
    p3_a7 := ddx_hdr_addr_rec_type.ship_to_site;
    p3_a8 := ddx_hdr_addr_rec_type.ship_to_address;
    p3_a9 := ddx_hdr_addr_rec_type.ship_to_city_state_zip;
    p3_a10 := ddx_hdr_addr_rec_type.ship_to_country;

    oks_entitlements_web_w.rosetta_table_copy_out_p37(ddx_party_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p39(ddx_line_tbl_type, p5_a0
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
      );
  end;

  procedure party_overview(p_contract_id_arg  VARCHAR2
    , p_party_rle_code_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_party_contact_tbl_type oks_entitlements_web.party_contact_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_overview(p_contract_id_arg,
      p_party_rle_code_arg,
      x_return_status,
      ddx_party_contact_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    oks_entitlements_web_w.rosetta_table_copy_out_p41(ddx_party_contact_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      );
  end;

  procedure party_contacts_overview(p_contact_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_pty_cntct_dtls_tbl_type oks_entitlements_web.pty_cntct_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.party_contacts_overview(p_contact_id_arg,
      x_return_status,
      ddx_pty_cntct_dtls_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    oks_entitlements_web_w.rosetta_table_copy_out_p43(ddx_pty_cntct_dtls_tbl_type, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );
  end;

  procedure line_overview(p_line_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  NUMBER
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  DATE
    , p2_a13 out nocopy  DATE
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  NUMBER
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  DATE
    , p2_a21 out nocopy  DATE
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_line_hdr_rec_type oks_entitlements_web.line_hdr_rec_type;
    ddx_covered_level_tbl_type oks_entitlements_web.covered_level_tbl_type;
    ddx_cust_contacts_tbl_type oks_entitlements_web.cust_contacts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.line_overview(p_line_id_arg,
      x_return_status,
      ddx_line_hdr_rec_type,
      ddx_covered_level_tbl_type,
      ddx_cust_contacts_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_line_hdr_rec_type.renewal_type;
    p2_a1 := ddx_line_hdr_rec_type.line_amount;
    p2_a2 := ddx_line_hdr_rec_type.line_amount_denomination;
    p2_a3 := ddx_line_hdr_rec_type.invoice_text;
    p2_a4 := ddx_line_hdr_rec_type.invoice_print_flag;
    p2_a5 := ddx_line_hdr_rec_type.tax_status_code;
    p2_a6 := ddx_line_hdr_rec_type.tax_status;
    p2_a7 := ddx_line_hdr_rec_type.tax_exempt_code;
    p2_a8 := ddx_line_hdr_rec_type.tax_code;
    p2_a9 := ddx_line_hdr_rec_type.coverage_id;
    p2_a10 := ddx_line_hdr_rec_type.coverage_name;
    p2_a11 := ddx_line_hdr_rec_type.coverage_description;
    p2_a12 := ddx_line_hdr_rec_type.coverage_start_date;
    p2_a13 := ddx_line_hdr_rec_type.coverage_end_date;
    p2_a14 := ddx_line_hdr_rec_type.coverage_warranty_yn;
    p2_a15 := ddx_line_hdr_rec_type.coverage_type;
    p2_a16 := ddx_line_hdr_rec_type.exception_cov_id;
    p2_a17 := ddx_line_hdr_rec_type.exception_cov_line_id;
    p2_a18 := ddx_line_hdr_rec_type.exception_cov_name;
    p2_a19 := ddx_line_hdr_rec_type.exception_cov_description;
    p2_a20 := ddx_line_hdr_rec_type.exception_cov_start_date;
    p2_a21 := ddx_line_hdr_rec_type.exception_cov_end_date;
    p2_a22 := ddx_line_hdr_rec_type.exception_cov_warranty_yn;
    p2_a23 := ddx_line_hdr_rec_type.exception_cov_type;

    oks_entitlements_web_w.rosetta_table_copy_out_p46(ddx_covered_level_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p48(ddx_cust_contacts_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      );
  end;

  procedure coverage_overview(p_coverage_id_arg  VARCHAR2
    , p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_coverage_rec_type oks_entitlements_web.coverage_rec_type;
    ddx_bus_proc_tbl_type oks_entitlements_web.bus_proc_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.coverage_overview(p_coverage_id_arg,
      p_contract_id_arg,
      x_return_status,
      ddx_coverage_rec_type,
      ddx_bus_proc_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_coverage_rec_type.coverage_billing_offset;
    p3_a1 := ddx_coverage_rec_type.coverage_wrrnty_inheritance;
    p3_a2 := ddx_coverage_rec_type.transfer_allowed;
    p3_a3 := ddx_coverage_rec_type.free_upgrade;

    oks_entitlements_web_w.rosetta_table_copy_out_p51(ddx_bus_proc_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      );
  end;

  procedure bus_proc_overview(p_bus_proc_id_arg  VARCHAR2
    , p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_bus_proc_hdr_rec_type oks_entitlements_web.bus_proc_hdr_rec_type;
    ddx_coverage_times_tbl_type oks_entitlements_web.coverage_times_tbl_type;
    ddx_reaction_times_tbl_type oks_entitlements_web.reaction_times_tbl_type;
    ddx_resolution_times_tbl_type oks_entitlements_web.resolution_times_tbl_type;
    ddx_pref_resource_tbl_type oks_entitlements_web.pref_resource_tbl_type;
    ddx_bus_proc_bil_typ_tbl_type oks_entitlements_web.bus_proc_bil_typ_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.bus_proc_overview(p_bus_proc_id_arg,
      p_contract_id_arg,
      x_return_status,
      ddx_bus_proc_hdr_rec_type,
      ddx_coverage_times_tbl_type,
      ddx_reaction_times_tbl_type,
      ddx_resolution_times_tbl_type,
      ddx_pref_resource_tbl_type,
      ddx_bus_proc_bil_typ_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_bus_proc_hdr_rec_type.bus_proc_hdr_time_zone;

    oks_entitlements_web_w.rosetta_table_copy_out_p54(ddx_coverage_times_tbl_type, p4_a0
      , p4_a1
      , p4_a2
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p56(ddx_reaction_times_tbl_type, p5_a0
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
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p58(ddx_resolution_times_tbl_type, p6_a0
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
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p60(ddx_pref_resource_tbl_type, p7_a0
      , p7_a1
      );

    oks_entitlements_web_w.rosetta_table_copy_out_p62(ddx_bus_proc_bil_typ_tbl_type, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      );
  end;

  procedure usage_overview(p_line_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  NUMBER
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_usage_hdr_rec_type oks_entitlements_web.usage_hdr_rec_type;
    ddx_covered_prods_tbl_type oks_entitlements_web.covered_prods_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.usage_overview(p_line_id_arg,
      x_return_status,
      ddx_usage_hdr_rec_type,
      ddx_covered_prods_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_usage_hdr_rec_type.usage_avg_allowed;
    p2_a1 := ddx_usage_hdr_rec_type.usage_avg_interval;
    p2_a2 := ddx_usage_hdr_rec_type.usage_avg_settlement_allowed;
    p2_a3 := ddx_usage_hdr_rec_type.usage_type;
    p2_a4 := ddx_usage_hdr_rec_type.usage_invoice_text;
    p2_a5 := ddx_usage_hdr_rec_type.usage_invoice_print_flag;
    p2_a6 := ddx_usage_hdr_rec_type.usage_tax_code;
    p2_a7 := ddx_usage_hdr_rec_type.usage_tax_status;
    p2_a8 := ddx_usage_hdr_rec_type.usage_amount;

    oks_entitlements_web_w.rosetta_table_copy_out_p65(ddx_covered_prods_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      );
  end;

  procedure product_overview(p_covered_prod_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_counter_tbl_type oks_entitlements_web.counter_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_web.product_overview(p_covered_prod_id_arg,
      x_return_status,
      ddx_counter_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    oks_entitlements_web_w.rosetta_table_copy_out_p67(ddx_counter_tbl_type, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );
  end;

end oks_entitlements_web_w;

/
