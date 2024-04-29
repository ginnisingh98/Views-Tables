--------------------------------------------------------
--  DDL for Package Body WSMPLBMI_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLBMI_W" as
  /* $Header: WSMLBMWB.pls 120.0 2005/07/06 11:11 skaradib noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy wsmplbmi.t_sec_uom_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t wsmplbmi.t_sec_uom_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy wsmplbmi.t_sec_move_out_qty_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t wsmplbmi.t_sec_move_out_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy wsmplbmi.t_scrap_codes_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t wsmplbmi.t_scrap_codes_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy wsmplbmi.t_scrap_code_qty_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t wsmplbmi.t_scrap_code_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy wsmplbmi.t_bonus_codes_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t wsmplbmi.t_bonus_codes_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy wsmplbmi.t_bonus_code_qty_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t wsmplbmi.t_bonus_code_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy wsmplbmi.t_jobop_res_usages_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).time_entry_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).operation_seq_num := a4(indx);
          t(ddindx).resource_id := a5(indx);
          t(ddindx).resource_seq_num := a6(indx);
          t(ddindx).instance_id := a7(indx);
          t(ddindx).serial_number := a8(indx);
          t(ddindx).last_update_date := a9(indx);
          t(ddindx).last_updated_by := a10(indx);
          t(ddindx).creation_date := a11(indx);
          t(ddindx).created_by := a12(indx);
          t(ddindx).last_update_login := a13(indx);
          t(ddindx).status_type := a14(indx);
          t(ddindx).start_date := a15(indx);
          t(ddindx).end_date := a16(indx);
          t(ddindx).projected_completion_date := a17(indx);
          t(ddindx).duration := a18(indx);
          t(ddindx).uom_code := a19(indx);
          t(ddindx).employee_id := a20(indx);
          t(ddindx).time_entry_mode := a21(indx);
          t(ddindx).cost_flag := a22(indx);
          t(ddindx).add_to_rtg := a23(indx);
          t(ddindx).process_status := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t wsmplbmi.t_jobop_res_usages_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
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
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).time_entry_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).operation_seq_num;
          a5(indx) := t(ddindx).resource_id;
          a6(indx) := t(ddindx).resource_seq_num;
          a7(indx) := t(ddindx).instance_id;
          a8(indx) := t(ddindx).serial_number;
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := t(ddindx).last_updated_by;
          a11(indx) := t(ddindx).creation_date;
          a12(indx) := t(ddindx).created_by;
          a13(indx) := t(ddindx).last_update_login;
          a14(indx) := t(ddindx).status_type;
          a15(indx) := t(ddindx).start_date;
          a16(indx) := t(ddindx).end_date;
          a17(indx) := t(ddindx).projected_completion_date;
          a18(indx) := t(ddindx).duration;
          a19(indx) := t(ddindx).uom_code;
          a20(indx) := t(ddindx).employee_id;
          a21(indx) := t(ddindx).time_entry_mode;
          a22(indx) := t(ddindx).cost_flag;
          a23(indx) := t(ddindx).add_to_rtg;
          a24(indx) := t(ddindx).process_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_VARCHAR2_TABLE_200
    , a77 JTF_VARCHAR2_TABLE_200
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).serial_number := a0(indx);
          t(ddindx).assembly_item_id := a1(indx);
          t(ddindx).header_id := a2(indx);
          t(ddindx).generate_serial_number := a3(indx);
          t(ddindx).generate_for_qty := a4(indx);
          t(ddindx).action_flag := a5(indx);
          t(ddindx).current_wip_entity_name := a6(indx);
          t(ddindx).changed_wip_entity_name := a7(indx);
          t(ddindx).current_wip_entity_id := a8(indx);
          t(ddindx).changed_wip_entity_id := a9(indx);
          t(ddindx).serial_attribute_category := a10(indx);
          t(ddindx).territory_code := a11(indx);
          t(ddindx).origination_date := a12(indx);
          t(ddindx).c_attribute1 := a13(indx);
          t(ddindx).c_attribute2 := a14(indx);
          t(ddindx).c_attribute3 := a15(indx);
          t(ddindx).c_attribute4 := a16(indx);
          t(ddindx).c_attribute5 := a17(indx);
          t(ddindx).c_attribute6 := a18(indx);
          t(ddindx).c_attribute7 := a19(indx);
          t(ddindx).c_attribute8 := a20(indx);
          t(ddindx).c_attribute9 := a21(indx);
          t(ddindx).c_attribute10 := a22(indx);
          t(ddindx).c_attribute11 := a23(indx);
          t(ddindx).c_attribute12 := a24(indx);
          t(ddindx).c_attribute13 := a25(indx);
          t(ddindx).c_attribute14 := a26(indx);
          t(ddindx).c_attribute15 := a27(indx);
          t(ddindx).c_attribute16 := a28(indx);
          t(ddindx).c_attribute17 := a29(indx);
          t(ddindx).c_attribute18 := a30(indx);
          t(ddindx).c_attribute19 := a31(indx);
          t(ddindx).c_attribute20 := a32(indx);
          t(ddindx).d_attribute1 := a33(indx);
          t(ddindx).d_attribute2 := a34(indx);
          t(ddindx).d_attribute3 := a35(indx);
          t(ddindx).d_attribute4 := a36(indx);
          t(ddindx).d_attribute5 := a37(indx);
          t(ddindx).d_attribute6 := a38(indx);
          t(ddindx).d_attribute7 := a39(indx);
          t(ddindx).d_attribute8 := a40(indx);
          t(ddindx).d_attribute9 := a41(indx);
          t(ddindx).d_attribute10 := a42(indx);
          t(ddindx).n_attribute1 := a43(indx);
          t(ddindx).n_attribute2 := a44(indx);
          t(ddindx).n_attribute3 := a45(indx);
          t(ddindx).n_attribute4 := a46(indx);
          t(ddindx).n_attribute5 := a47(indx);
          t(ddindx).n_attribute6 := a48(indx);
          t(ddindx).n_attribute7 := a49(indx);
          t(ddindx).n_attribute8 := a50(indx);
          t(ddindx).n_attribute9 := a51(indx);
          t(ddindx).n_attribute10 := a52(indx);
          t(ddindx).status_id := a53(indx);
          t(ddindx).time_since_new := a54(indx);
          t(ddindx).cycles_since_new := a55(indx);
          t(ddindx).time_since_overhaul := a56(indx);
          t(ddindx).cycles_since_overhaul := a57(indx);
          t(ddindx).time_since_repair := a58(indx);
          t(ddindx).cycles_since_repair := a59(indx);
          t(ddindx).time_since_visit := a60(indx);
          t(ddindx).cycles_since_visit := a61(indx);
          t(ddindx).time_since_mark := a62(indx);
          t(ddindx).cycles_since_mark := a63(indx);
          t(ddindx).number_of_repairs := a64(indx);
          t(ddindx).attribute_category := a65(indx);
          t(ddindx).attribute1 := a66(indx);
          t(ddindx).attribute2 := a67(indx);
          t(ddindx).attribute3 := a68(indx);
          t(ddindx).attribute4 := a69(indx);
          t(ddindx).attribute5 := a70(indx);
          t(ddindx).attribute6 := a71(indx);
          t(ddindx).attribute7 := a72(indx);
          t(ddindx).attribute8 := a73(indx);
          t(ddindx).attribute9 := a74(indx);
          t(ddindx).attribute10 := a75(indx);
          t(ddindx).attribute11 := a76(indx);
          t(ddindx).attribute12 := a77(indx);
          t(ddindx).attribute13 := a78(indx);
          t(ddindx).attribute14 := a79(indx);
          t(ddindx).attribute15 := a80(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_VARCHAR2_TABLE_200
    , a77 out nocopy JTF_VARCHAR2_TABLE_200
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_200();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_VARCHAR2_TABLE_200();
    a72 := JTF_VARCHAR2_TABLE_200();
    a73 := JTF_VARCHAR2_TABLE_200();
    a74 := JTF_VARCHAR2_TABLE_200();
    a75 := JTF_VARCHAR2_TABLE_200();
    a76 := JTF_VARCHAR2_TABLE_200();
    a77 := JTF_VARCHAR2_TABLE_200();
    a78 := JTF_VARCHAR2_TABLE_200();
    a79 := JTF_VARCHAR2_TABLE_200();
    a80 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_200();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_VARCHAR2_TABLE_200();
      a72 := JTF_VARCHAR2_TABLE_200();
      a73 := JTF_VARCHAR2_TABLE_200();
      a74 := JTF_VARCHAR2_TABLE_200();
      a75 := JTF_VARCHAR2_TABLE_200();
      a76 := JTF_VARCHAR2_TABLE_200();
      a77 := JTF_VARCHAR2_TABLE_200();
      a78 := JTF_VARCHAR2_TABLE_200();
      a79 := JTF_VARCHAR2_TABLE_200();
      a80 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).serial_number;
          a1(indx) := t(ddindx).assembly_item_id;
          a2(indx) := t(ddindx).header_id;
          a3(indx) := t(ddindx).generate_serial_number;
          a4(indx) := t(ddindx).generate_for_qty;
          a5(indx) := t(ddindx).action_flag;
          a6(indx) := t(ddindx).current_wip_entity_name;
          a7(indx) := t(ddindx).changed_wip_entity_name;
          a8(indx) := t(ddindx).current_wip_entity_id;
          a9(indx) := t(ddindx).changed_wip_entity_id;
          a10(indx) := t(ddindx).serial_attribute_category;
          a11(indx) := t(ddindx).territory_code;
          a12(indx) := t(ddindx).origination_date;
          a13(indx) := t(ddindx).c_attribute1;
          a14(indx) := t(ddindx).c_attribute2;
          a15(indx) := t(ddindx).c_attribute3;
          a16(indx) := t(ddindx).c_attribute4;
          a17(indx) := t(ddindx).c_attribute5;
          a18(indx) := t(ddindx).c_attribute6;
          a19(indx) := t(ddindx).c_attribute7;
          a20(indx) := t(ddindx).c_attribute8;
          a21(indx) := t(ddindx).c_attribute9;
          a22(indx) := t(ddindx).c_attribute10;
          a23(indx) := t(ddindx).c_attribute11;
          a24(indx) := t(ddindx).c_attribute12;
          a25(indx) := t(ddindx).c_attribute13;
          a26(indx) := t(ddindx).c_attribute14;
          a27(indx) := t(ddindx).c_attribute15;
          a28(indx) := t(ddindx).c_attribute16;
          a29(indx) := t(ddindx).c_attribute17;
          a30(indx) := t(ddindx).c_attribute18;
          a31(indx) := t(ddindx).c_attribute19;
          a32(indx) := t(ddindx).c_attribute20;
          a33(indx) := t(ddindx).d_attribute1;
          a34(indx) := t(ddindx).d_attribute2;
          a35(indx) := t(ddindx).d_attribute3;
          a36(indx) := t(ddindx).d_attribute4;
          a37(indx) := t(ddindx).d_attribute5;
          a38(indx) := t(ddindx).d_attribute6;
          a39(indx) := t(ddindx).d_attribute7;
          a40(indx) := t(ddindx).d_attribute8;
          a41(indx) := t(ddindx).d_attribute9;
          a42(indx) := t(ddindx).d_attribute10;
          a43(indx) := t(ddindx).n_attribute1;
          a44(indx) := t(ddindx).n_attribute2;
          a45(indx) := t(ddindx).n_attribute3;
          a46(indx) := t(ddindx).n_attribute4;
          a47(indx) := t(ddindx).n_attribute5;
          a48(indx) := t(ddindx).n_attribute6;
          a49(indx) := t(ddindx).n_attribute7;
          a50(indx) := t(ddindx).n_attribute8;
          a51(indx) := t(ddindx).n_attribute9;
          a52(indx) := t(ddindx).n_attribute10;
          a53(indx) := t(ddindx).status_id;
          a54(indx) := t(ddindx).time_since_new;
          a55(indx) := t(ddindx).cycles_since_new;
          a56(indx) := t(ddindx).time_since_overhaul;
          a57(indx) := t(ddindx).cycles_since_overhaul;
          a58(indx) := t(ddindx).time_since_repair;
          a59(indx) := t(ddindx).cycles_since_repair;
          a60(indx) := t(ddindx).time_since_visit;
          a61(indx) := t(ddindx).cycles_since_visit;
          a62(indx) := t(ddindx).time_since_mark;
          a63(indx) := t(ddindx).cycles_since_mark;
          a64(indx) := t(ddindx).number_of_repairs;
          a65(indx) := t(ddindx).attribute_category;
          a66(indx) := t(ddindx).attribute1;
          a67(indx) := t(ddindx).attribute2;
          a68(indx) := t(ddindx).attribute3;
          a69(indx) := t(ddindx).attribute4;
          a70(indx) := t(ddindx).attribute5;
          a71(indx) := t(ddindx).attribute6;
          a72(indx) := t(ddindx).attribute7;
          a73(indx) := t(ddindx).attribute8;
          a74(indx) := t(ddindx).attribute9;
          a75(indx) := t(ddindx).attribute10;
          a76(indx) := t(ddindx).attribute11;
          a77(indx) := t(ddindx).attribute12;
          a78(indx) := t(ddindx).attribute13;
          a79(indx) := t(ddindx).attribute14;
          a80(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure movetransaction(p_group_id  NUMBER
    , p_transaction_id  NUMBER
    , p_source_code  VARCHAR2
    , p_transaction_type  NUMBER
    , p_organization_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_wip_entity_name  VARCHAR2
    , p_primary_item_id  NUMBER
    , p_transaction_date  DATE
    , p_fm_operation_seq_num  NUMBER
    , p_fm_operation_code  VARCHAR2
    , p_fm_department_id  NUMBER
    , p_fm_department_code  VARCHAR2
    , p_fm_intraoperation_step_type  NUMBER
    , p_to_operation_seq_num  NUMBER
    , p_to_operation_code  VARCHAR2
    , p_to_department_id  NUMBER
    , p_to_department_code  VARCHAR2
    , p_to_intraoperation_step_type  NUMBER
    , p_primary_quantity  NUMBER
    , p_low_yield_trigger_limit  NUMBER
    , p_primary_uom  VARCHAR2
    , p_scrap_account_id  NUMBER
    , p_reason_id  NUMBER
    , p_reason_name  VARCHAR2
    , p_reference  VARCHAR2
    , p_qa_collection_id  NUMBER
    , p_jump_flag  VARCHAR2
    , p_header_id  NUMBER
    , p_primary_scrap_quantity  NUMBER
    , p_bonus_quantity  NUMBER
    , p_scrap_at_operation_flag  NUMBER
    , p_bonus_account_id  NUMBER
    , p_employee_id  NUMBER
    , p_operation_start_date  DATE
    , p_operation_completion_date  DATE
    , p_expected_completion_date  DATE
    , p_mtl_txn_hdr_id  NUMBER
    , p_sec_uom_code_tbl JTF_VARCHAR2_TABLE_100
    , p_sec_move_out_qty_tbl JTF_NUMBER_TABLE
    , p40_a0 JTF_VARCHAR2_TABLE_100
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_NUMBER_TABLE
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_NUMBER_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_VARCHAR2_TABLE_300
    , p40_a7 JTF_VARCHAR2_TABLE_300
    , p40_a8 JTF_NUMBER_TABLE
    , p40_a9 JTF_NUMBER_TABLE
    , p40_a10 JTF_VARCHAR2_TABLE_100
    , p40_a11 JTF_VARCHAR2_TABLE_100
    , p40_a12 JTF_DATE_TABLE
    , p40_a13 JTF_VARCHAR2_TABLE_200
    , p40_a14 JTF_VARCHAR2_TABLE_200
    , p40_a15 JTF_VARCHAR2_TABLE_200
    , p40_a16 JTF_VARCHAR2_TABLE_200
    , p40_a17 JTF_VARCHAR2_TABLE_200
    , p40_a18 JTF_VARCHAR2_TABLE_200
    , p40_a19 JTF_VARCHAR2_TABLE_200
    , p40_a20 JTF_VARCHAR2_TABLE_200
    , p40_a21 JTF_VARCHAR2_TABLE_200
    , p40_a22 JTF_VARCHAR2_TABLE_200
    , p40_a23 JTF_VARCHAR2_TABLE_200
    , p40_a24 JTF_VARCHAR2_TABLE_200
    , p40_a25 JTF_VARCHAR2_TABLE_200
    , p40_a26 JTF_VARCHAR2_TABLE_200
    , p40_a27 JTF_VARCHAR2_TABLE_200
    , p40_a28 JTF_VARCHAR2_TABLE_200
    , p40_a29 JTF_VARCHAR2_TABLE_200
    , p40_a30 JTF_VARCHAR2_TABLE_200
    , p40_a31 JTF_VARCHAR2_TABLE_200
    , p40_a32 JTF_VARCHAR2_TABLE_200
    , p40_a33 JTF_DATE_TABLE
    , p40_a34 JTF_DATE_TABLE
    , p40_a35 JTF_DATE_TABLE
    , p40_a36 JTF_DATE_TABLE
    , p40_a37 JTF_DATE_TABLE
    , p40_a38 JTF_DATE_TABLE
    , p40_a39 JTF_DATE_TABLE
    , p40_a40 JTF_DATE_TABLE
    , p40_a41 JTF_DATE_TABLE
    , p40_a42 JTF_DATE_TABLE
    , p40_a43 JTF_NUMBER_TABLE
    , p40_a44 JTF_NUMBER_TABLE
    , p40_a45 JTF_NUMBER_TABLE
    , p40_a46 JTF_NUMBER_TABLE
    , p40_a47 JTF_NUMBER_TABLE
    , p40_a48 JTF_NUMBER_TABLE
    , p40_a49 JTF_NUMBER_TABLE
    , p40_a50 JTF_NUMBER_TABLE
    , p40_a51 JTF_NUMBER_TABLE
    , p40_a52 JTF_NUMBER_TABLE
    , p40_a53 JTF_NUMBER_TABLE
    , p40_a54 JTF_NUMBER_TABLE
    , p40_a55 JTF_NUMBER_TABLE
    , p40_a56 JTF_NUMBER_TABLE
    , p40_a57 JTF_NUMBER_TABLE
    , p40_a58 JTF_NUMBER_TABLE
    , p40_a59 JTF_NUMBER_TABLE
    , p40_a60 JTF_NUMBER_TABLE
    , p40_a61 JTF_NUMBER_TABLE
    , p40_a62 JTF_NUMBER_TABLE
    , p40_a63 JTF_NUMBER_TABLE
    , p40_a64 JTF_NUMBER_TABLE
    , p40_a65 JTF_VARCHAR2_TABLE_100
    , p40_a66 JTF_VARCHAR2_TABLE_200
    , p40_a67 JTF_VARCHAR2_TABLE_200
    , p40_a68 JTF_VARCHAR2_TABLE_200
    , p40_a69 JTF_VARCHAR2_TABLE_200
    , p40_a70 JTF_VARCHAR2_TABLE_200
    , p40_a71 JTF_VARCHAR2_TABLE_200
    , p40_a72 JTF_VARCHAR2_TABLE_200
    , p40_a73 JTF_VARCHAR2_TABLE_200
    , p40_a74 JTF_VARCHAR2_TABLE_200
    , p40_a75 JTF_VARCHAR2_TABLE_200
    , p40_a76 JTF_VARCHAR2_TABLE_200
    , p40_a77 JTF_VARCHAR2_TABLE_200
    , p40_a78 JTF_VARCHAR2_TABLE_200
    , p40_a79 JTF_VARCHAR2_TABLE_200
    , p40_a80 JTF_VARCHAR2_TABLE_200
    , p41_a0 JTF_VARCHAR2_TABLE_100
    , p41_a1 JTF_NUMBER_TABLE
    , p41_a2 JTF_NUMBER_TABLE
    , p41_a3 JTF_NUMBER_TABLE
    , p41_a4 JTF_NUMBER_TABLE
    , p41_a5 JTF_NUMBER_TABLE
    , p41_a6 JTF_VARCHAR2_TABLE_300
    , p41_a7 JTF_VARCHAR2_TABLE_300
    , p41_a8 JTF_NUMBER_TABLE
    , p41_a9 JTF_NUMBER_TABLE
    , p41_a10 JTF_VARCHAR2_TABLE_100
    , p41_a11 JTF_VARCHAR2_TABLE_100
    , p41_a12 JTF_DATE_TABLE
    , p41_a13 JTF_VARCHAR2_TABLE_200
    , p41_a14 JTF_VARCHAR2_TABLE_200
    , p41_a15 JTF_VARCHAR2_TABLE_200
    , p41_a16 JTF_VARCHAR2_TABLE_200
    , p41_a17 JTF_VARCHAR2_TABLE_200
    , p41_a18 JTF_VARCHAR2_TABLE_200
    , p41_a19 JTF_VARCHAR2_TABLE_200
    , p41_a20 JTF_VARCHAR2_TABLE_200
    , p41_a21 JTF_VARCHAR2_TABLE_200
    , p41_a22 JTF_VARCHAR2_TABLE_200
    , p41_a23 JTF_VARCHAR2_TABLE_200
    , p41_a24 JTF_VARCHAR2_TABLE_200
    , p41_a25 JTF_VARCHAR2_TABLE_200
    , p41_a26 JTF_VARCHAR2_TABLE_200
    , p41_a27 JTF_VARCHAR2_TABLE_200
    , p41_a28 JTF_VARCHAR2_TABLE_200
    , p41_a29 JTF_VARCHAR2_TABLE_200
    , p41_a30 JTF_VARCHAR2_TABLE_200
    , p41_a31 JTF_VARCHAR2_TABLE_200
    , p41_a32 JTF_VARCHAR2_TABLE_200
    , p41_a33 JTF_DATE_TABLE
    , p41_a34 JTF_DATE_TABLE
    , p41_a35 JTF_DATE_TABLE
    , p41_a36 JTF_DATE_TABLE
    , p41_a37 JTF_DATE_TABLE
    , p41_a38 JTF_DATE_TABLE
    , p41_a39 JTF_DATE_TABLE
    , p41_a40 JTF_DATE_TABLE
    , p41_a41 JTF_DATE_TABLE
    , p41_a42 JTF_DATE_TABLE
    , p41_a43 JTF_NUMBER_TABLE
    , p41_a44 JTF_NUMBER_TABLE
    , p41_a45 JTF_NUMBER_TABLE
    , p41_a46 JTF_NUMBER_TABLE
    , p41_a47 JTF_NUMBER_TABLE
    , p41_a48 JTF_NUMBER_TABLE
    , p41_a49 JTF_NUMBER_TABLE
    , p41_a50 JTF_NUMBER_TABLE
    , p41_a51 JTF_NUMBER_TABLE
    , p41_a52 JTF_NUMBER_TABLE
    , p41_a53 JTF_NUMBER_TABLE
    , p41_a54 JTF_NUMBER_TABLE
    , p41_a55 JTF_NUMBER_TABLE
    , p41_a56 JTF_NUMBER_TABLE
    , p41_a57 JTF_NUMBER_TABLE
    , p41_a58 JTF_NUMBER_TABLE
    , p41_a59 JTF_NUMBER_TABLE
    , p41_a60 JTF_NUMBER_TABLE
    , p41_a61 JTF_NUMBER_TABLE
    , p41_a62 JTF_NUMBER_TABLE
    , p41_a63 JTF_NUMBER_TABLE
    , p41_a64 JTF_NUMBER_TABLE
    , p41_a65 JTF_VARCHAR2_TABLE_100
    , p41_a66 JTF_VARCHAR2_TABLE_200
    , p41_a67 JTF_VARCHAR2_TABLE_200
    , p41_a68 JTF_VARCHAR2_TABLE_200
    , p41_a69 JTF_VARCHAR2_TABLE_200
    , p41_a70 JTF_VARCHAR2_TABLE_200
    , p41_a71 JTF_VARCHAR2_TABLE_200
    , p41_a72 JTF_VARCHAR2_TABLE_200
    , p41_a73 JTF_VARCHAR2_TABLE_200
    , p41_a74 JTF_VARCHAR2_TABLE_200
    , p41_a75 JTF_VARCHAR2_TABLE_200
    , p41_a76 JTF_VARCHAR2_TABLE_200
    , p41_a77 JTF_VARCHAR2_TABLE_200
    , p41_a78 JTF_VARCHAR2_TABLE_200
    , p41_a79 JTF_VARCHAR2_TABLE_200
    , p41_a80 JTF_VARCHAR2_TABLE_200
    , p_scrap_codes_tbl JTF_VARCHAR2_TABLE_100
    , p_scrap_code_qty_tbl JTF_NUMBER_TABLE
    , p_bonus_codes_tbl JTF_VARCHAR2_TABLE_100
    , p_bonus_code_qty_tbl JTF_NUMBER_TABLE
    , p46_a0 JTF_NUMBER_TABLE
    , p46_a1 JTF_NUMBER_TABLE
    , p46_a2 JTF_NUMBER_TABLE
    , p46_a3 JTF_NUMBER_TABLE
    , p46_a4 JTF_NUMBER_TABLE
    , p46_a5 JTF_NUMBER_TABLE
    , p46_a6 JTF_NUMBER_TABLE
    , p46_a7 JTF_NUMBER_TABLE
    , p46_a8 JTF_VARCHAR2_TABLE_100
    , p46_a9 JTF_DATE_TABLE
    , p46_a10 JTF_NUMBER_TABLE
    , p46_a11 JTF_DATE_TABLE
    , p46_a12 JTF_NUMBER_TABLE
    , p46_a13 JTF_NUMBER_TABLE
    , p46_a14 JTF_NUMBER_TABLE
    , p46_a15 JTF_DATE_TABLE
    , p46_a16 JTF_DATE_TABLE
    , p46_a17 JTF_DATE_TABLE
    , p46_a18 JTF_NUMBER_TABLE
    , p46_a19 JTF_VARCHAR2_TABLE_100
    , p46_a20 JTF_NUMBER_TABLE
    , p46_a21 JTF_NUMBER_TABLE
    , p46_a22 JTF_VARCHAR2_TABLE_100
    , p46_a23 JTF_VARCHAR2_TABLE_100
    , p46_a24 JTF_NUMBER_TABLE
    , x_wip_move_api_sucess_msg out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sec_uom_code_tbl wsmplbmi.t_sec_uom_code_tbl_type;
    ddp_sec_move_out_qty_tbl wsmplbmi.t_sec_move_out_qty_tbl_type;
    ddp_jobop_scrap_serials_tbl WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL;
    ddp_jobop_bonus_serials_tbl WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL;
    ddp_scrap_codes_tbl wsmplbmi.t_scrap_codes_tbl_type;
    ddp_scrap_code_qty_tbl wsmplbmi.t_scrap_code_qty_tbl_type;
    ddp_bonus_codes_tbl wsmplbmi.t_bonus_codes_tbl_type;
    ddp_bonus_code_qty_tbl wsmplbmi.t_bonus_code_qty_tbl_type;
    ddp_jobop_resource_usages_tbl wsmplbmi.t_jobop_res_usages_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






































    wsmplbmi_w.rosetta_table_copy_in_p0(ddp_sec_uom_code_tbl, p_sec_uom_code_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p1(ddp_sec_move_out_qty_tbl, p_sec_move_out_qty_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p9(ddp_jobop_scrap_serials_tbl, p40_a0
      , p40_a1
      , p40_a2
      , p40_a3
      , p40_a4
      , p40_a5
      , p40_a6
      , p40_a7
      , p40_a8
      , p40_a9
      , p40_a10
      , p40_a11
      , p40_a12
      , p40_a13
      , p40_a14
      , p40_a15
      , p40_a16
      , p40_a17
      , p40_a18
      , p40_a19
      , p40_a20
      , p40_a21
      , p40_a22
      , p40_a23
      , p40_a24
      , p40_a25
      , p40_a26
      , p40_a27
      , p40_a28
      , p40_a29
      , p40_a30
      , p40_a31
      , p40_a32
      , p40_a33
      , p40_a34
      , p40_a35
      , p40_a36
      , p40_a37
      , p40_a38
      , p40_a39
      , p40_a40
      , p40_a41
      , p40_a42
      , p40_a43
      , p40_a44
      , p40_a45
      , p40_a46
      , p40_a47
      , p40_a48
      , p40_a49
      , p40_a50
      , p40_a51
      , p40_a52
      , p40_a53
      , p40_a54
      , p40_a55
      , p40_a56
      , p40_a57
      , p40_a58
      , p40_a59
      , p40_a60
      , p40_a61
      , p40_a62
      , p40_a63
      , p40_a64
      , p40_a65
      , p40_a66
      , p40_a67
      , p40_a68
      , p40_a69
      , p40_a70
      , p40_a71
      , p40_a72
      , p40_a73
      , p40_a74
      , p40_a75
      , p40_a76
      , p40_a77
      , p40_a78
      , p40_a79
      , p40_a80
      );

    wsmplbmi_w.rosetta_table_copy_in_p9(ddp_jobop_bonus_serials_tbl, p41_a0
      , p41_a1
      , p41_a2
      , p41_a3
      , p41_a4
      , p41_a5
      , p41_a6
      , p41_a7
      , p41_a8
      , p41_a9
      , p41_a10
      , p41_a11
      , p41_a12
      , p41_a13
      , p41_a14
      , p41_a15
      , p41_a16
      , p41_a17
      , p41_a18
      , p41_a19
      , p41_a20
      , p41_a21
      , p41_a22
      , p41_a23
      , p41_a24
      , p41_a25
      , p41_a26
      , p41_a27
      , p41_a28
      , p41_a29
      , p41_a30
      , p41_a31
      , p41_a32
      , p41_a33
      , p41_a34
      , p41_a35
      , p41_a36
      , p41_a37
      , p41_a38
      , p41_a39
      , p41_a40
      , p41_a41
      , p41_a42
      , p41_a43
      , p41_a44
      , p41_a45
      , p41_a46
      , p41_a47
      , p41_a48
      , p41_a49
      , p41_a50
      , p41_a51
      , p41_a52
      , p41_a53
      , p41_a54
      , p41_a55
      , p41_a56
      , p41_a57
      , p41_a58
      , p41_a59
      , p41_a60
      , p41_a61
      , p41_a62
      , p41_a63
      , p41_a64
      , p41_a65
      , p41_a66
      , p41_a67
      , p41_a68
      , p41_a69
      , p41_a70
      , p41_a71
      , p41_a72
      , p41_a73
      , p41_a74
      , p41_a75
      , p41_a76
      , p41_a77
      , p41_a78
      , p41_a79
      , p41_a80
      );

    wsmplbmi_w.rosetta_table_copy_in_p2(ddp_scrap_codes_tbl, p_scrap_codes_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p3(ddp_scrap_code_qty_tbl, p_scrap_code_qty_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p4(ddp_bonus_codes_tbl, p_bonus_codes_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p5(ddp_bonus_code_qty_tbl, p_bonus_code_qty_tbl);

    wsmplbmi_w.rosetta_table_copy_in_p7(ddp_jobop_resource_usages_tbl, p46_a0
      , p46_a1
      , p46_a2
      , p46_a3
      , p46_a4
      , p46_a5
      , p46_a6
      , p46_a7
      , p46_a8
      , p46_a9
      , p46_a10
      , p46_a11
      , p46_a12
      , p46_a13
      , p46_a14
      , p46_a15
      , p46_a16
      , p46_a17
      , p46_a18
      , p46_a19
      , p46_a20
      , p46_a21
      , p46_a22
      , p46_a23
      , p46_a24
      );





    -- here's the delegated call to the old PL/SQL routine
    wsmplbmi.movetransaction(p_group_id,
      p_transaction_id,
      p_source_code,
      p_transaction_type,
      p_organization_id,
      p_wip_entity_id,
      p_wip_entity_name,
      p_primary_item_id,
      p_transaction_date,
      p_fm_operation_seq_num,
      p_fm_operation_code,
      p_fm_department_id,
      p_fm_department_code,
      p_fm_intraoperation_step_type,
      p_to_operation_seq_num,
      p_to_operation_code,
      p_to_department_id,
      p_to_department_code,
      p_to_intraoperation_step_type,
      p_primary_quantity,
      p_low_yield_trigger_limit,
      p_primary_uom,
      p_scrap_account_id,
      p_reason_id,
      p_reason_name,
      p_reference,
      p_qa_collection_id,
      p_jump_flag,
      p_header_id,
      p_primary_scrap_quantity,
      p_bonus_quantity,
      p_scrap_at_operation_flag,
      p_bonus_account_id,
      p_employee_id,
      p_operation_start_date,
      p_operation_completion_date,
      p_expected_completion_date,
      p_mtl_txn_hdr_id,
      ddp_sec_uom_code_tbl,
      ddp_sec_move_out_qty_tbl,
      ddp_jobop_scrap_serials_tbl,
      ddp_jobop_bonus_serials_tbl,
      ddp_scrap_codes_tbl,
      ddp_scrap_code_qty_tbl,
      ddp_bonus_codes_tbl,
      ddp_bonus_code_qty_tbl,
      ddp_jobop_resource_usages_tbl,
      x_wip_move_api_sucess_msg,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















































  end;

end wsmplbmi_w;

/
