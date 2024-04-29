--------------------------------------------------------
--  DDL for Package Body DPP_UIWRAPPER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_UIWRAPPER_PVT_W" as
  /* $Header: dppvuirb.pls 120.7.12010000.5 2010/03/26 11:42:06 rvkondur ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy dpp_uiwrapper_pvt.search_criteria_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).search_criteria := a0(indx);
          t(ddindx).search_text := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t dpp_uiwrapper_pvt.search_criteria_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).search_criteria;
          a1(indx) := t(ddindx).search_text;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy dpp_uiwrapper_pvt.vendor_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).vendor_id := a0(indx);
          t(ddindx).vendor_number := a1(indx);
          t(ddindx).vendor_name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t dpp_uiwrapper_pvt.vendor_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).vendor_id;
          a1(indx) := t(ddindx).vendor_number;
          a2(indx) := t(ddindx).vendor_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy dpp_uiwrapper_pvt.vendor_site_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).vendor_id := a0(indx);
          t(ddindx).vendor_site_id := a1(indx);
          t(ddindx).vendor_site_code := a2(indx);
          t(ddindx).address_line1 := a3(indx);
          t(ddindx).address_line2 := a4(indx);
          t(ddindx).address_line3 := a5(indx);
          t(ddindx).city := a6(indx);
          t(ddindx).state := a7(indx);
          t(ddindx).zip := a8(indx);
          t(ddindx).country := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t dpp_uiwrapper_pvt.vendor_site_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).vendor_id;
          a1(indx) := t(ddindx).vendor_site_id;
          a2(indx) := t(ddindx).vendor_site_code;
          a3(indx) := t(ddindx).address_line1;
          a4(indx) := t(ddindx).address_line2;
          a5(indx) := t(ddindx).address_line3;
          a6(indx) := t(ddindx).city;
          a7(indx) := t(ddindx).state;
          a8(indx) := t(ddindx).zip;
          a9(indx) := t(ddindx).country;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy dpp_uiwrapper_pvt.vendor_contact_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).vendor_site_id := a0(indx);
          t(ddindx).vendor_contact_id := a1(indx);
          t(ddindx).contact_first_name := a2(indx);
          t(ddindx).contact_middle_name := a3(indx);
          t(ddindx).contact_last_name := a4(indx);
          t(ddindx).contact_phone := a5(indx);
          t(ddindx).contact_email_address := a6(indx);
          t(ddindx).contact_fax := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t dpp_uiwrapper_pvt.vendor_contact_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).vendor_site_id;
          a1(indx) := t(ddindx).vendor_contact_id;
          a2(indx) := t(ddindx).contact_first_name;
          a3(indx) := t(ddindx).contact_middle_name;
          a4(indx) := t(ddindx).contact_last_name;
          a5(indx) := t(ddindx).contact_phone;
          a6(indx) := t(ddindx).contact_email_address;
          a7(indx) := t(ddindx).contact_fax;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy dpp_uiwrapper_pvt.customer_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_id := a0(indx);
          t(ddindx).customer_number := a1(indx);
          t(ddindx).customer_name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t dpp_uiwrapper_pvt.customer_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).customer_id;
          a1(indx) := t(ddindx).customer_number;
          a2(indx) := t(ddindx).customer_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p15(t out nocopy dpp_uiwrapper_pvt.item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).item_number := a1(indx);
          t(ddindx).description := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t dpp_uiwrapper_pvt.item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).item_number;
          a2(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p17(t out nocopy dpp_uiwrapper_pvt.itemnum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).item_number := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).vendor_part_no := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t dpp_uiwrapper_pvt.itemnum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).item_number;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).vendor_part_no;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p19(t out nocopy dpp_uiwrapper_pvt.warehouse_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).warehouse_id := a0(indx);
          t(ddindx).warehouse_code := a1(indx);
          t(ddindx).warehouse_name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t dpp_uiwrapper_pvt.warehouse_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).warehouse_id;
          a1(indx) := t(ddindx).warehouse_code;
          a2(indx) := t(ddindx).warehouse_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p22(t out nocopy dpp_uiwrapper_pvt.dpp_inv_cov_rct_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).date_received := a0(indx);
          t(ddindx).onhand_quantity := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t dpp_uiwrapper_pvt.dpp_inv_cov_rct_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).date_received;
          a1(indx) := t(ddindx).onhand_quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p24(t out nocopy dpp_uiwrapper_pvt.inventorydetails_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_line_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).uom_code := a2(indx);
          t(ddindx).onhand_quantity := a3(indx);
          t(ddindx).covered_quantity := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t dpp_uiwrapper_pvt.inventorydetails_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).transaction_line_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).uom_code;
          a3(indx) := t(ddindx).onhand_quantity;
          a4(indx) := t(ddindx).covered_quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p26(t out nocopy dpp_uiwrapper_pvt.dpp_cust_inv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).uom_code := a2(indx);
          t(ddindx).onhand_quantity := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t dpp_uiwrapper_pvt.dpp_cust_inv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).customer_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).uom_code;
          a3(indx) := t(ddindx).onhand_quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p28(t out nocopy dpp_uiwrapper_pvt.dpp_cust_price_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).uom_code := a2(indx);
          t(ddindx).last_price := a3(indx);
          t(ddindx).invoice_currency_code := a4(indx);
          t(ddindx).price_change := a5(indx);
          t(ddindx).converted_price_change := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t dpp_uiwrapper_pvt.dpp_cust_price_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).customer_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).uom_code;
          a3(indx) := t(ddindx).last_price;
          a4(indx) := t(ddindx).invoice_currency_code;
          a5(indx) := t(ddindx).price_change;
          a6(indx) := t(ddindx).converted_price_change;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure rosetta_table_copy_in_p30(t out nocopy dpp_uiwrapper_pvt.dpp_list_price_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).list_price := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t dpp_uiwrapper_pvt.dpp_list_price_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).list_price;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure rosetta_table_copy_in_p33(t out nocopy dpp_uiwrapper_pvt.approverstable, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).user_id := a0(indx);
          t(ddindx).person_id := a1(indx);
          t(ddindx).first_name := a2(indx);
          t(ddindx).last_name := a3(indx);
          t(ddindx).api_insertion := a4(indx);
          t(ddindx).authority := a5(indx);
          t(ddindx).approval_status := a6(indx);
          t(ddindx).approval_type_id := a7(indx);
          t(ddindx).group_or_chain_id := a8(indx);
          t(ddindx).occurrence := a9(indx);
          t(ddindx).source := a10(indx);
          t(ddindx).approver_sequence := a11(indx);
          t(ddindx).approver_email := a12(indx);
          t(ddindx).approver_group_name := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t dpp_uiwrapper_pvt.approverstable, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).user_id;
          a1(indx) := t(ddindx).person_id;
          a2(indx) := t(ddindx).first_name;
          a3(indx) := t(ddindx).last_name;
          a4(indx) := t(ddindx).api_insertion;
          a5(indx) := t(ddindx).authority;
          a6(indx) := t(ddindx).approval_status;
          a7(indx) := t(ddindx).approval_type_id;
          a8(indx) := t(ddindx).group_or_chain_id;
          a9(indx) := t(ddindx).occurrence;
          a10(indx) := t(ddindx).source;
          a11(indx) := t(ddindx).approver_sequence;
          a12(indx) := t(ddindx).approver_email;
          a13(indx) := t(ddindx).approver_group_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p35(t out nocopy dpp_uiwrapper_pvt.dpp_txn_line_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t dpp_uiwrapper_pvt.dpp_txn_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure search_vendors(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_vendor_tbl dpp_uiwrapper_pvt.vendor_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_vendors(ddp_search_criteria,
      ddx_vendor_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p7(ddx_vendor_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;

  procedure search_vendor_sites(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_vendor_site_tbl dpp_uiwrapper_pvt.vendor_site_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_vendor_sites(ddp_search_criteria,
      ddx_vendor_site_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p9(ddx_vendor_site_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      );


  end;

  procedure search_vendor_contacts(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_vendor_contact_tbl dpp_uiwrapper_pvt.vendor_contact_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_vendor_contacts(ddp_search_criteria,
      ddx_vendor_contact_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p11(ddx_vendor_contact_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      );


  end;

  procedure search_items(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_item_tbl dpp_uiwrapper_pvt.itemnum_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_items(ddp_search_criteria,
      ddx_item_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p17(ddx_item_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      );


  end;

  procedure search_customer_items(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_customer_item_tbl dpp_uiwrapper_pvt.item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_customer_items(ddp_search_criteria,
      ddx_customer_item_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p15(ddx_customer_item_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;


  procedure search_customer_items_all(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_customer_item_tbl dpp_uiwrapper_pvt.item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_customer_items_all(ddp_search_criteria,
      ddx_customer_item_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p15(ddx_customer_item_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;

  procedure search_warehouses(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_warehouse_tbl dpp_uiwrapper_pvt.warehouse_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_warehouses(ddp_search_criteria,
      ddx_warehouse_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p19(ddx_warehouse_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;

  procedure get_inventorydetails(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  DATE
    , p0_a3  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_hdr_rec dpp_uiwrapper_pvt.dpp_inv_hdr_rec_type;
    ddp_inventorydetails_tbl dpp_uiwrapper_pvt.inventorydetails_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_hdr_rec.org_id := p0_a0;
    ddp_hdr_rec.effective_start_date := p0_a1;
    ddp_hdr_rec.effective_end_date := p0_a2;
    ddp_hdr_rec.currency_code := p0_a3;

    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p24(ddp_inventorydetails_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_inventorydetails(ddp_hdr_rec,
      ddp_inventorydetails_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p24(ddp_inventorydetails_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );


  end;

  procedure get_customerinventory(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  DATE
    , p0_a3  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_hdr_rec dpp_uiwrapper_pvt.dpp_inv_hdr_rec_type;
    ddp_cust_inv_tbl dpp_uiwrapper_pvt.dpp_cust_inv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_hdr_rec.org_id := p0_a0;
    ddp_hdr_rec.effective_start_date := p0_a1;
    ddp_hdr_rec.effective_end_date := p0_a2;
    ddp_hdr_rec.currency_code := p0_a3;

    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p26(ddp_cust_inv_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_customerinventory(ddp_hdr_rec,
      ddp_cust_inv_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p26(ddp_cust_inv_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      );


  end;

  procedure search_customers(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_customer_tbl dpp_uiwrapper_pvt.customer_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_customers(ddp_search_criteria,
      ddx_customer_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p13(ddx_customer_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;


  procedure search_customers_all(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_search_criteria dpp_uiwrapper_pvt.search_criteria_tbl_type;
    ddx_customer_tbl dpp_uiwrapper_pvt.customer_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p5(ddp_search_criteria, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.search_customers_all(ddp_search_criteria,
      ddx_customer_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p13(ddx_customer_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;

  procedure get_lastprice(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  DATE
    , p0_a3  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a5 in out nocopy JTF_NUMBER_TABLE
    , p1_a6 in out nocopy JTF_NUMBER_TABLE
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_hdr_rec dpp_uiwrapper_pvt.dpp_inv_hdr_rec_type;
    ddp_cust_price_tbl dpp_uiwrapper_pvt.dpp_cust_price_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_hdr_rec.org_id := p0_a0;
    ddp_hdr_rec.effective_start_date := p0_a1;
    ddp_hdr_rec.effective_end_date := p0_a2;
    ddp_hdr_rec.currency_code := p0_a3;

    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p28(ddp_cust_price_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_lastprice(ddp_hdr_rec,
      ddp_cust_price_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p28(ddp_cust_price_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      );


  end;

  procedure get_listprice(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  DATE
    , p0_a3  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_hdr_rec dpp_uiwrapper_pvt.dpp_inv_hdr_rec_type;
    ddp_listprice_tbl dpp_uiwrapper_pvt.dpp_list_price_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_hdr_rec.org_id := p0_a0;
    ddp_hdr_rec.effective_start_date := p0_a1;
    ddp_hdr_rec.effective_end_date := p0_a2;
    ddp_hdr_rec.currency_code := p0_a3;

    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p30(ddp_listprice_tbl, p1_a0
      , p1_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_listprice(ddp_hdr_rec,
      ddp_listprice_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p30(ddp_listprice_tbl, p1_a0
      , p1_a1
      );


  end;

  procedure get_vendor(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  VARCHAR2
    , p0_a2 in out nocopy  VARCHAR2
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_vendor_rec dpp_uiwrapper_pvt.vendor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_vendor_rec.vendor_id := p0_a0;
    ddp_vendor_rec.vendor_number := p0_a1;
    ddp_vendor_rec.vendor_name := p0_a2;



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_vendor(ddp_vendor_rec,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_vendor_rec.vendor_id;
    p0_a1 := ddp_vendor_rec.vendor_number;
    p0_a2 := ddp_vendor_rec.vendor_name;


  end;

  procedure get_vendor_site(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  VARCHAR2
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_vendor_site_rec dpp_uiwrapper_pvt.vendor_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_vendor_site_rec.vendor_id := p0_a0;
    ddp_vendor_site_rec.vendor_site_id := p0_a1;
    ddp_vendor_site_rec.vendor_site_code := p0_a2;
    ddp_vendor_site_rec.address_line1 := p0_a3;
    ddp_vendor_site_rec.address_line2 := p0_a4;
    ddp_vendor_site_rec.address_line3 := p0_a5;
    ddp_vendor_site_rec.city := p0_a6;
    ddp_vendor_site_rec.state := p0_a7;
    ddp_vendor_site_rec.zip := p0_a8;
    ddp_vendor_site_rec.country := p0_a9;



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_vendor_site(ddp_vendor_site_rec,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_vendor_site_rec.vendor_id;
    p0_a1 := ddp_vendor_site_rec.vendor_site_id;
    p0_a2 := ddp_vendor_site_rec.vendor_site_code;
    p0_a3 := ddp_vendor_site_rec.address_line1;
    p0_a4 := ddp_vendor_site_rec.address_line2;
    p0_a5 := ddp_vendor_site_rec.address_line3;
    p0_a6 := ddp_vendor_site_rec.city;
    p0_a7 := ddp_vendor_site_rec.state;
    p0_a8 := ddp_vendor_site_rec.zip;
    p0_a9 := ddp_vendor_site_rec.country;


  end;

  procedure get_vendor_contact(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  VARCHAR2
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_vendor_contact_rec dpp_uiwrapper_pvt.vendor_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_vendor_contact_rec.vendor_site_id := p0_a0;
    ddp_vendor_contact_rec.vendor_contact_id := p0_a1;
    ddp_vendor_contact_rec.contact_first_name := p0_a2;
    ddp_vendor_contact_rec.contact_middle_name := p0_a3;
    ddp_vendor_contact_rec.contact_last_name := p0_a4;
    ddp_vendor_contact_rec.contact_phone := p0_a5;
    ddp_vendor_contact_rec.contact_email_address := p0_a6;
    ddp_vendor_contact_rec.contact_fax := p0_a7;



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_vendor_contact(ddp_vendor_contact_rec,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_vendor_contact_rec.vendor_site_id;
    p0_a1 := ddp_vendor_contact_rec.vendor_contact_id;
    p0_a2 := ddp_vendor_contact_rec.contact_first_name;
    p0_a3 := ddp_vendor_contact_rec.contact_middle_name;
    p0_a4 := ddp_vendor_contact_rec.contact_last_name;
    p0_a5 := ddp_vendor_contact_rec.contact_phone;
    p0_a6 := ddp_vendor_contact_rec.contact_email_address;
    p0_a7 := ddp_vendor_contact_rec.contact_fax;


  end;

  procedure get_warehouse(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_warehouse_tbl dpp_uiwrapper_pvt.warehouse_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p19(ddp_warehouse_tbl, p0_a0
      , p0_a1
      , p0_a2
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_warehouse(ddp_warehouse_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p19(ddp_warehouse_tbl, p0_a0
      , p0_a1
      , p0_a2
      );


  end;

  procedure get_customer(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a2 in out nocopy JTF_VARCHAR2_TABLE_400
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_customer_tbl dpp_uiwrapper_pvt.customer_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p13(ddp_customer_tbl, p0_a0
      , p0_a1
      , p0_a2
      );



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_customer(ddp_customer_tbl,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p13(ddp_customer_tbl, p0_a0
      , p0_a1
      , p0_a2
      );


  end;

  procedure get_product(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p_org_id  NUMBER
    , x_rec_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_item_tbl dpp_uiwrapper_pvt.item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p15(ddp_item_tbl, p0_a0
      , p0_a1
      , p0_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_product(ddp_item_tbl,
      p_org_id,
      x_rec_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p15(ddp_item_tbl, p0_a0
      , p0_a1
      , p0_a2
      );



  end;

  procedure get_allapprovers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_approval_rec dpp_uiwrapper_pvt.approval_rec_type;
    ddp_approversout dpp_uiwrapper_pvt.approverstable;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_approval_rec.object_type := p6_a0;
    ddp_approval_rec.object_id := p6_a1;
    ddp_approval_rec.status_code := p6_a2;
    ddp_approval_rec.action_code := p6_a3;
    ddp_approval_rec.action_performed_by := p6_a4;


    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.get_allapprovers(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_approval_rec,
      ddp_approversout);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    dpp_uiwrapper_pvt_w.rosetta_table_copy_out_p33(ddp_approversout, p7_a0
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
      );
  end;

  procedure process_user_action(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p_approver_id  NUMBER
    , x_final_approval_flag out nocopy  VARCHAR2
  )

  as
    ddp_approval_rec dpp_uiwrapper_pvt.approval_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_rec.object_type := p7_a0;
    ddp_approval_rec.object_id := p7_a1;
    ddp_approval_rec.status_code := p7_a2;
    ddp_approval_rec.action_code := p7_a3;
    ddp_approval_rec.action_performed_by := p7_a4;



    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.process_user_action(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_approval_rec,
      p_approver_id,
      x_final_approval_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure raise_business_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p_txn_line_id JTF_NUMBER_TABLE
  )

  as
    ddp_txn_hdr_rec dpp_uiwrapper_pvt.dpp_txn_hdr_rec_type;
    ddp_txn_line_id dpp_uiwrapper_pvt.dpp_txn_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_txn_hdr_rec.transaction_header_id := p7_a0;
    ddp_txn_hdr_rec.transaction_number := p7_a1;
    ddp_txn_hdr_rec.process_code := p7_a2;
    ddp_txn_hdr_rec.claim_id := p7_a3;
    ddp_txn_hdr_rec.claim_type_flag := p7_a4;
    ddp_txn_hdr_rec.claim_creation_source := p7_a5;

    dpp_uiwrapper_pvt_w.rosetta_table_copy_in_p35(ddp_txn_line_id, p_txn_line_id);

    -- here's the delegated call to the old PL/SQL routine
    dpp_uiwrapper_pvt.raise_business_event(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_txn_hdr_rec,
      ddp_txn_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end dpp_uiwrapper_pvt_w;

/
