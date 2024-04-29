--------------------------------------------------------
--  DDL for Package Body IBU_ORDER_CAPTURE_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_ORDER_CAPTURE_W" as
  /* $Header: iburordb.pls 115.5.1159.1 2003/05/23 22:22:20 appldev noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ibu_order_capture.header_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
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
          t(ddindx).quote_header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).quote_source_code := a2(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cust_account_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).org_contact_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).invoice_to_party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).order_type_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).quote_category_code := a8(indx);
          t(ddindx).ordered_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).employee_person_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).currency_code := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ibu_order_capture.header_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).quote_header_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a2(indx) := t(ddindx).quote_source_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).cust_account_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).org_contact_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).order_type_id);
          a8(indx) := t(ddindx).quote_category_code;
          a9(indx) := t(ddindx).ordered_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).employee_person_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a12(indx) := t(ddindx).currency_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy ibu_order_capture.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).operation_code := a1(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).line_category_code := a3(indx);
          t(ddindx).order_line_type_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).invoice_to_party_site_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).invoice_to_party_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).uom_code := a10(indx);
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).currency_code := a12(indx);
          t(ddindx).line_list_price := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).line_quote_price := rosetta_g_miss_num_map(a14(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ibu_order_capture.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a1(indx) := t(ddindx).operation_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a3(indx) := t(ddindx).line_category_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).order_line_type_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a10(indx) := t(ddindx).uom_code;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a12(indx) := t(ddindx).currency_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).line_list_price);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).line_quote_price);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ibu_order_capture.line_dtl_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_code := a0(indx);
          t(ddindx).qte_line_index := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).return_ref_type := a2(indx);
          t(ddindx).return_ref_header_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).return_ref_line_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).return_attribute1 := a5(indx);
          t(ddindx).return_attribute2 := a6(indx);
          t(ddindx).return_attribute3 := a7(indx);
          t(ddindx).return_attribute4 := a8(indx);
          t(ddindx).return_reason_code := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ibu_order_capture.line_dtl_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).operation_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).qte_line_index);
          a2(indx) := t(ddindx).return_ref_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).return_ref_header_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).return_ref_line_id);
          a5(indx) := t(ddindx).return_attribute1;
          a6(indx) := t(ddindx).return_attribute2;
          a7(indx) := t(ddindx).return_attribute3;
          a8(indx) := t(ddindx).return_attribute4;
          a9(indx) := t(ddindx).return_reason_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy ibu_order_capture.line_shipment_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_code := a0(indx);
          t(ddindx).qte_line_index := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).schedule_ship_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).request_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).ship_to_party_site_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ship_to_party_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).freight_carrier_code := a6(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ibu_order_capture.line_shipment_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).operation_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).qte_line_index);
          a2(indx) := t(ddindx).schedule_ship_date;
          a3(indx) := t(ddindx).request_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_site_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_id);
          a6(indx) := t(ddindx).freight_carrier_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p11(t out nocopy ibu_order_capture.return_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).order_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).order_header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).status := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t ibu_order_capture.return_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).order_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).order_header_id);
          a2(indx) := t(ddindx).status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure create_return(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_header_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_300
    , p7_a6 JTF_VARCHAR2_TABLE_300
    , p7_a7 JTF_VARCHAR2_TABLE_300
    , p7_a8 JTF_VARCHAR2_TABLE_300
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_DATE_TABLE
    , p8_a3 JTF_DATE_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a0  DATE := fnd_api.g_miss_date
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
  )

  as
    ddheader_rec ibu_order_capture.header_rec_type;
    ddheader_shipment_rec ibu_order_capture.header_shipment_rec_type;
    ddline_tbl ibu_order_capture.line_tbl_type;
    ddline_dtl_tbl ibu_order_capture.line_dtl_tbl_type;
    ddline_shipment_tbl ibu_order_capture.line_shipment_tbl_type;
    ddx_return_header_rec ibu_order_capture.return_header_rec_type;
    ddx_return_line_tbl ibu_order_capture.return_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddheader_rec.quote_header_id := rosetta_g_miss_num_map(p4_a0);
    ddheader_rec.org_id := rosetta_g_miss_num_map(p4_a1);
    ddheader_rec.quote_source_code := p4_a2;
    ddheader_rec.party_id := rosetta_g_miss_num_map(p4_a3);
    ddheader_rec.cust_account_id := rosetta_g_miss_num_map(p4_a4);
    ddheader_rec.org_contact_id := rosetta_g_miss_num_map(p4_a5);
    ddheader_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p4_a6);
    ddheader_rec.order_type_id := rosetta_g_miss_num_map(p4_a7);
    ddheader_rec.quote_category_code := p4_a8;
    ddheader_rec.ordered_date := rosetta_g_miss_date_in_map(p4_a9);
    ddheader_rec.employee_person_id := rosetta_g_miss_num_map(p4_a10);
    ddheader_rec.price_list_id := rosetta_g_miss_num_map(p4_a11);
    ddheader_rec.currency_code := p4_a12;

    ddheader_shipment_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p5_a0);
    ddheader_shipment_rec.request_date := rosetta_g_miss_date_in_map(p5_a1);
    ddheader_shipment_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p5_a2);
    ddheader_shipment_rec.ship_to_party_id := rosetta_g_miss_num_map(p5_a3);
    ddheader_shipment_rec.freight_carrier_code := p5_a4;
    ddheader_shipment_rec.quantity := rosetta_g_miss_num_map(p5_a5);

    ibu_order_capture_w.rosetta_table_copy_in_p4(ddline_tbl, p6_a0
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
      );

    ibu_order_capture_w.rosetta_table_copy_in_p6(ddline_dtl_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );

    ibu_order_capture_w.rosetta_table_copy_in_p8(ddline_shipment_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );






    -- here's the delegated call to the old PL/SQL routine
    ibu_order_capture.create_return(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_header_id,
      ddheader_rec,
      ddheader_shipment_rec,
      ddline_tbl,
      ddline_dtl_tbl,
      ddline_shipment_tbl,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_return_header_rec,
      ddx_return_line_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := rosetta_g_miss_num_map(ddx_return_header_rec.order_number);
    p12_a1 := rosetta_g_miss_num_map(ddx_return_header_rec.order_header_id);
    p12_a2 := ddx_return_header_rec.status;

    ibu_order_capture_w.rosetta_table_copy_out_p11(ddx_return_line_tbl, p13_a0
      , p13_a1
      , p13_a2
      );
  end;

end ibu_order_capture_w;

/
