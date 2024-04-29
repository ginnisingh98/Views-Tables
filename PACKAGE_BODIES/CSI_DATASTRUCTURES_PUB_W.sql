--------------------------------------------------------
--  DDL for Package Body CSI_DATASTRUCTURES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_DATASTRUCTURES_PUB_W" as
  /* $Header: csipdswb.pls 120.20.12010000.3 2009/04/07 19:09:25 hyonlee ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy csi_datastructures_pub.parameter_name, a0 JTF_VARCHAR2_TABLE_100) as
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
  procedure rosetta_table_copy_out_p0(t csi_datastructures_pub.parameter_name, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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

  procedure rosetta_table_copy_in_p1(t out nocopy csi_datastructures_pub.parameter_value, a0 JTF_VARCHAR2_TABLE_200) as
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
  procedure rosetta_table_copy_out_p1(t csi_datastructures_pub.parameter_value, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
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

  procedure rosetta_table_copy_in_p6(t out nocopy csi_datastructures_pub.party_account_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ip_account_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).instance_party_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).party_account_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).relationship_type_code := a4(indx);
          t(ddindx).bill_to_address := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).ship_to_address := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).context := a9(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).call_contracts := a26(indx);
          t(ddindx).vld_organization_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).expire_flag := a28(indx);
          t(ddindx).grp_call_contracts := a29(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).system_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).cascade_ownership_flag := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t csi_datastructures_pub.party_account_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ip_account_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).party_account_id);
          a4(indx) := t(ddindx).relationship_type_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_address);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_address);
          a7(indx) := t(ddindx).active_start_date;
          a8(indx) := t(ddindx).active_end_date;
          a9(indx) := t(ddindx).context;
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
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a26(indx) := t(ddindx).call_contracts;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).vld_organization_id);
          a28(indx) := t(ddindx).expire_flag;
          a29(indx) := t(ddindx).grp_call_contracts;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a33(indx) := t(ddindx).program_update_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a35(indx) := t(ddindx).cascade_ownership_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy csi_datastructures_pub.party_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_party_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).party_source_table := a2(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).relationship_type_code := a4(indx);
          t(ddindx).contact_flag := a5(indx);
          t(ddindx).contact_ip_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).context := a9(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).primary_flag := a26(indx);
          t(ddindx).preferred_flag := a27(indx);
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).call_contracts := a29(indx);
          t(ddindx).interface_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).contact_parent_tbl_index := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).cascade_ownership_flag := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t csi_datastructures_pub.party_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := t(ddindx).party_source_table;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a4(indx) := t(ddindx).relationship_type_code;
          a5(indx) := t(ddindx).contact_flag;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).contact_ip_id);
          a7(indx) := t(ddindx).active_start_date;
          a8(indx) := t(ddindx).active_end_date;
          a9(indx) := t(ddindx).context;
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
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a26(indx) := t(ddindx).primary_flag;
          a27(indx) := t(ddindx).preferred_flag;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a29(indx) := t(ddindx).call_contracts;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).interface_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).contact_parent_tbl_index);
          a32(indx) := t(ddindx).cascade_ownership_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy csi_datastructures_pub.party_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_2000
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_party_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).party_source_table := a2(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).relationship_type_code := a4(indx);
          t(ddindx).contact_flag := a5(indx);
          t(ddindx).contact_ip_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).party_number := a7(indx);
          t(ddindx).party_name := a8(indx);
          t(ddindx).party_type := a9(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).context := a12(indx);
          t(ddindx).attribute1 := a13(indx);
          t(ddindx).attribute2 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).attribute10 := a22(indx);
          t(ddindx).attribute11 := a23(indx);
          t(ddindx).attribute12 := a24(indx);
          t(ddindx).attribute13 := a25(indx);
          t(ddindx).attribute14 := a26(indx);
          t(ddindx).attribute15 := a27(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).address1 := a29(indx);
          t(ddindx).address2 := a30(indx);
          t(ddindx).address3 := a31(indx);
          t(ddindx).address4 := a32(indx);
          t(ddindx).city := a33(indx);
          t(ddindx).state := a34(indx);
          t(ddindx).postal_code := a35(indx);
          t(ddindx).country := a36(indx);
          t(ddindx).work_phone_number := a37(indx);
          t(ddindx).email_address := a38(indx);
          t(ddindx).primary_flag := a39(indx);
          t(ddindx).preferred_flag := a40(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t csi_datastructures_pub.party_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_2000
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_2000();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_2000();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := t(ddindx).party_source_table;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a4(indx) := t(ddindx).relationship_type_code;
          a5(indx) := t(ddindx).contact_flag;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).contact_ip_id);
          a7(indx) := t(ddindx).party_number;
          a8(indx) := t(ddindx).party_name;
          a9(indx) := t(ddindx).party_type;
          a10(indx) := t(ddindx).active_start_date;
          a11(indx) := t(ddindx).active_end_date;
          a12(indx) := t(ddindx).context;
          a13(indx) := t(ddindx).attribute1;
          a14(indx) := t(ddindx).attribute2;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).attribute10;
          a23(indx) := t(ddindx).attribute11;
          a24(indx) := t(ddindx).attribute12;
          a25(indx) := t(ddindx).attribute13;
          a26(indx) := t(ddindx).attribute14;
          a27(indx) := t(ddindx).attribute15;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a29(indx) := t(ddindx).address1;
          a30(indx) := t(ddindx).address2;
          a31(indx) := t(ddindx).address3;
          a32(indx) := t(ddindx).address4;
          a33(indx) := t(ddindx).city;
          a34(indx) := t(ddindx).state;
          a35(indx) := t(ddindx).postal_code;
          a36(indx) := t(ddindx).country;
          a37(indx) := t(ddindx).work_phone_number;
          a38(indx) := t(ddindx).email_address;
          a39(indx) := t(ddindx).primary_flag;
          a40(indx) := t(ddindx).preferred_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p14(t out nocopy csi_datastructures_pub.version_label_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).version_label_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).version_label := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).date_time_stamp := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).context := a7(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t csi_datastructures_pub.version_label_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).version_label_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := t(ddindx).version_label;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).date_time_stamp;
          a5(indx) := t(ddindx).active_start_date;
          a6(indx) := t(ddindx).active_end_date;
          a7(indx) := t(ddindx).context;
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
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy csi_datastructures_pub.id_tbl, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t csi_datastructures_pub.id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p17(t out nocopy csi_datastructures_pub.instance_asset_location_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_location_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).location_table := a2(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t csi_datastructures_pub.instance_asset_location_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).asset_location_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a2(indx) := t(ddindx).location_table;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a4(indx) := t(ddindx).active_start_date;
          a5(indx) := t(ddindx).active_end_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p19(t out nocopy csi_datastructures_pub.instance_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_DATE_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_NUMBER_TABLE
    , a112 JTF_VARCHAR2_TABLE_100
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_NUMBER_TABLE
    , a116 JTF_VARCHAR2_TABLE_100
    , a117 JTF_VARCHAR2_TABLE_100
    , a118 JTF_NUMBER_TABLE
    , a119 JTF_VARCHAR2_TABLE_100
    , a120 JTF_NUMBER_TABLE
    , a121 JTF_NUMBER_TABLE
    , a122 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_number := a1(indx);
          t(ddindx).external_reference := a2(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).vld_organization_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).inventory_revision := a5(indx);
          t(ddindx).inv_master_organization_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).serial_number := a7(indx);
          t(ddindx).mfg_serial_number_flag := a8(indx);
          t(ddindx).lot_number := a9(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).unit_of_measure := a11(indx);
          t(ddindx).accounting_class_code := a12(indx);
          t(ddindx).instance_condition_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).instance_status_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).customer_view_flag := a15(indx);
          t(ddindx).merchant_view_flag := a16(indx);
          t(ddindx).sellable_flag := a17(indx);
          t(ddindx).system_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).instance_type_code := a19(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).location_type_code := a22(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).inv_organization_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).inv_subinventory_name := a25(indx);
          t(ddindx).inv_locator_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).pa_project_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).pa_project_task_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).in_transit_order_line_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).wip_job_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).po_order_line_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).last_oe_order_line_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).last_oe_rma_line_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).last_po_po_line_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).last_oe_po_number := a35(indx);
          t(ddindx).last_wip_job_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).last_pa_project_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).last_pa_task_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).last_oe_agreement_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).install_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).manually_created_flag := a41(indx);
          t(ddindx).return_by_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).actual_return_date := rosetta_g_miss_date_in_map(a43(indx));
          t(ddindx).creation_complete_flag := a44(indx);
          t(ddindx).completeness_flag := a45(indx);
          t(ddindx).version_label := a46(indx);
          t(ddindx).version_label_description := a47(indx);
          t(ddindx).context := a48(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).last_txn_line_detail_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).install_location_type_code := a66(indx);
          t(ddindx).install_location_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).instance_usage_code := a68(indx);
          t(ddindx).check_for_instance_expiry := a69(indx);
          t(ddindx).processed_flag := a70(indx);
          t(ddindx).call_contracts := a71(indx);
          t(ddindx).interface_id := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).grp_call_contracts := a73(indx);
          t(ddindx).config_inst_hdr_id := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).config_inst_rev_num := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).config_inst_item_id := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).config_valid_status := a77(indx);
          t(ddindx).instance_description := a78(indx);
          t(ddindx).call_batch_validation := a79(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a83(indx));
          t(ddindx).cascade_ownership_flag := a84(indx);
          t(ddindx).network_asset_flag := a85(indx);
          t(ddindx).maintainable_flag := a86(indx);
          t(ddindx).pn_location_id := rosetta_g_miss_num_map(a87(indx));
          t(ddindx).asset_criticality_code := a88(indx);
          t(ddindx).category_id := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).equipment_gen_object_id := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).instantiation_flag := a91(indx);
          t(ddindx).linear_location_id := rosetta_g_miss_num_map(a92(indx));
          t(ddindx).operational_log_flag := a93(indx);
          t(ddindx).checkin_status := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).supplier_warranty_exp_date := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).attribute16 := a96(indx);
          t(ddindx).attribute17 := a97(indx);
          t(ddindx).attribute18 := a98(indx);
          t(ddindx).attribute19 := a99(indx);
          t(ddindx).attribute20 := a100(indx);
          t(ddindx).attribute21 := a101(indx);
          t(ddindx).attribute22 := a102(indx);
          t(ddindx).attribute23 := a103(indx);
          t(ddindx).attribute24 := a104(indx);
          t(ddindx).attribute25 := a105(indx);
          t(ddindx).attribute26 := a106(indx);
          t(ddindx).attribute27 := a107(indx);
          t(ddindx).attribute28 := a108(indx);
          t(ddindx).attribute29 := a109(indx);
          t(ddindx).attribute30 := a110(indx);
          t(ddindx).purchase_unit_price := rosetta_g_miss_num_map(a111(indx));
          t(ddindx).purchase_currency_code := a112(indx);
          t(ddindx).payables_unit_price := rosetta_g_miss_num_map(a113(indx));
          t(ddindx).payables_currency_code := a114(indx);
          t(ddindx).sales_unit_price := rosetta_g_miss_num_map(a115(indx));
          t(ddindx).sales_currency_code := a116(indx);
          t(ddindx).operational_status_code := a117(indx);
          t(ddindx).department_id := rosetta_g_miss_num_map(a118(indx));
          t(ddindx).wip_accounting_class := a119(indx);
          t(ddindx).area_id := rosetta_g_miss_num_map(a120(indx));
          t(ddindx).owner_party_id := rosetta_g_miss_num_map(a121(indx));
          t(ddindx).source_code := a122(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t csi_datastructures_pub.instance_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_100
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_300
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_300
    , a104 out nocopy JTF_VARCHAR2_TABLE_300
    , a105 out nocopy JTF_VARCHAR2_TABLE_300
    , a106 out nocopy JTF_VARCHAR2_TABLE_300
    , a107 out nocopy JTF_VARCHAR2_TABLE_300
    , a108 out nocopy JTF_VARCHAR2_TABLE_300
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_NUMBER_TABLE
    , a112 out nocopy JTF_VARCHAR2_TABLE_100
    , a113 out nocopy JTF_NUMBER_TABLE
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
    , a115 out nocopy JTF_NUMBER_TABLE
    , a116 out nocopy JTF_VARCHAR2_TABLE_100
    , a117 out nocopy JTF_VARCHAR2_TABLE_100
    , a118 out nocopy JTF_NUMBER_TABLE
    , a119 out nocopy JTF_VARCHAR2_TABLE_100
    , a120 out nocopy JTF_NUMBER_TABLE
    , a121 out nocopy JTF_NUMBER_TABLE
    , a122 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_DATE_TABLE();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_NUMBER_TABLE();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_300();
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_300();
    a106 := JTF_VARCHAR2_TABLE_300();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_300();
    a109 := JTF_VARCHAR2_TABLE_300();
    a110 := JTF_VARCHAR2_TABLE_300();
    a111 := JTF_NUMBER_TABLE();
    a112 := JTF_VARCHAR2_TABLE_100();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_NUMBER_TABLE();
    a116 := JTF_VARCHAR2_TABLE_100();
    a117 := JTF_VARCHAR2_TABLE_100();
    a118 := JTF_NUMBER_TABLE();
    a119 := JTF_VARCHAR2_TABLE_100();
    a120 := JTF_NUMBER_TABLE();
    a121 := JTF_NUMBER_TABLE();
    a122 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_DATE_TABLE();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_NUMBER_TABLE();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_300();
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_300();
      a106 := JTF_VARCHAR2_TABLE_300();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_300();
      a109 := JTF_VARCHAR2_TABLE_300();
      a110 := JTF_VARCHAR2_TABLE_300();
      a111 := JTF_NUMBER_TABLE();
      a112 := JTF_VARCHAR2_TABLE_100();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_NUMBER_TABLE();
      a116 := JTF_VARCHAR2_TABLE_100();
      a117 := JTF_VARCHAR2_TABLE_100();
      a118 := JTF_NUMBER_TABLE();
      a119 := JTF_VARCHAR2_TABLE_100();
      a120 := JTF_NUMBER_TABLE();
      a121 := JTF_NUMBER_TABLE();
      a122 := JTF_VARCHAR2_TABLE_100();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).instance_number;
          a2(indx) := t(ddindx).external_reference;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).vld_organization_id);
          a5(indx) := t(ddindx).inventory_revision;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).inv_master_organization_id);
          a7(indx) := t(ddindx).serial_number;
          a8(indx) := t(ddindx).mfg_serial_number_flag;
          a9(indx) := t(ddindx).lot_number;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a11(indx) := t(ddindx).unit_of_measure;
          a12(indx) := t(ddindx).accounting_class_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).instance_condition_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).instance_status_id);
          a15(indx) := t(ddindx).customer_view_flag;
          a16(indx) := t(ddindx).merchant_view_flag;
          a17(indx) := t(ddindx).sellable_flag;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a19(indx) := t(ddindx).instance_type_code;
          a20(indx) := t(ddindx).active_start_date;
          a21(indx) := t(ddindx).active_end_date;
          a22(indx) := t(ddindx).location_type_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).inv_organization_id);
          a25(indx) := t(ddindx).inv_subinventory_name;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).inv_locator_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_task_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).in_transit_order_line_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).wip_job_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).po_order_line_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_order_line_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_rma_line_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).last_po_po_line_id);
          a35(indx) := t(ddindx).last_oe_po_number;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_wip_job_id);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_id);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_task_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_agreement_id);
          a40(indx) := t(ddindx).install_date;
          a41(indx) := t(ddindx).manually_created_flag;
          a42(indx) := t(ddindx).return_by_date;
          a43(indx) := t(ddindx).actual_return_date;
          a44(indx) := t(ddindx).creation_complete_flag;
          a45(indx) := t(ddindx).completeness_flag;
          a46(indx) := t(ddindx).version_label;
          a47(indx) := t(ddindx).version_label_description;
          a48(indx) := t(ddindx).context;
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
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).last_txn_line_detail_id);
          a66(indx) := t(ddindx).install_location_type_code;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).install_location_id);
          a68(indx) := t(ddindx).instance_usage_code;
          a69(indx) := t(ddindx).check_for_instance_expiry;
          a70(indx) := t(ddindx).processed_flag;
          a71(indx) := t(ddindx).call_contracts;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).interface_id);
          a73(indx) := t(ddindx).grp_call_contracts;
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_hdr_id);
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_rev_num);
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_item_id);
          a77(indx) := t(ddindx).config_valid_status;
          a78(indx) := t(ddindx).instance_description;
          a79(indx) := t(ddindx).call_batch_validation;
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a83(indx) := t(ddindx).program_update_date;
          a84(indx) := t(ddindx).cascade_ownership_flag;
          a85(indx) := t(ddindx).network_asset_flag;
          a86(indx) := t(ddindx).maintainable_flag;
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).pn_location_id);
          a88(indx) := t(ddindx).asset_criticality_code;
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).equipment_gen_object_id);
          a91(indx) := t(ddindx).instantiation_flag;
          a92(indx) := rosetta_g_miss_num_map(t(ddindx).linear_location_id);
          a93(indx) := t(ddindx).operational_log_flag;
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).checkin_status);
          a95(indx) := t(ddindx).supplier_warranty_exp_date;
          a96(indx) := t(ddindx).attribute16;
          a97(indx) := t(ddindx).attribute17;
          a98(indx) := t(ddindx).attribute18;
          a99(indx) := t(ddindx).attribute19;
          a100(indx) := t(ddindx).attribute20;
          a101(indx) := t(ddindx).attribute21;
          a102(indx) := t(ddindx).attribute22;
          a103(indx) := t(ddindx).attribute23;
          a104(indx) := t(ddindx).attribute24;
          a105(indx) := t(ddindx).attribute25;
          a106(indx) := t(ddindx).attribute26;
          a107(indx) := t(ddindx).attribute27;
          a108(indx) := t(ddindx).attribute28;
          a109(indx) := t(ddindx).attribute29;
          a110(indx) := t(ddindx).attribute30;
          a111(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_unit_price);
          a112(indx) := t(ddindx).purchase_currency_code;
          a113(indx) := rosetta_g_miss_num_map(t(ddindx).payables_unit_price);
          a114(indx) := t(ddindx).payables_currency_code;
          a115(indx) := rosetta_g_miss_num_map(t(ddindx).sales_unit_price);
          a116(indx) := t(ddindx).sales_currency_code;
          a117(indx) := t(ddindx).operational_status_code;
          a118(indx) := rosetta_g_miss_num_map(t(ddindx).department_id);
          a119(indx) := t(ddindx).wip_accounting_class;
          a120(indx) := rosetta_g_miss_num_map(t(ddindx).area_id);
          a121(indx) := rosetta_g_miss_num_map(t(ddindx).owner_party_id);
          a122(indx) := t(ddindx).source_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p22(t out nocopy csi_datastructures_pub.instance_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_DATE_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_DATE_TABLE
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_200
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_400
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_400
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_NUMBER_TABLE
    , a109 JTF_NUMBER_TABLE
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_300
    , a115 JTF_VARCHAR2_TABLE_300
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_100
    , a118 JTF_VARCHAR2_TABLE_100
    , a119 JTF_VARCHAR2_TABLE_100
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_VARCHAR2_TABLE_100
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_NUMBER_TABLE
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_VARCHAR2_TABLE_100
    , a139 JTF_NUMBER_TABLE
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_DATE_TABLE
    , a143 JTF_VARCHAR2_TABLE_300
    , a144 JTF_VARCHAR2_TABLE_300
    , a145 JTF_VARCHAR2_TABLE_300
    , a146 JTF_VARCHAR2_TABLE_300
    , a147 JTF_VARCHAR2_TABLE_300
    , a148 JTF_VARCHAR2_TABLE_300
    , a149 JTF_VARCHAR2_TABLE_300
    , a150 JTF_VARCHAR2_TABLE_300
    , a151 JTF_VARCHAR2_TABLE_300
    , a152 JTF_VARCHAR2_TABLE_300
    , a153 JTF_VARCHAR2_TABLE_300
    , a154 JTF_VARCHAR2_TABLE_300
    , a155 JTF_VARCHAR2_TABLE_300
    , a156 JTF_VARCHAR2_TABLE_300
    , a157 JTF_VARCHAR2_TABLE_300
    , a158 JTF_NUMBER_TABLE
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_NUMBER_TABLE
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_NUMBER_TABLE
    , a163 JTF_VARCHAR2_TABLE_100
    , a164 JTF_VARCHAR2_TABLE_100
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_VARCHAR2_TABLE_100
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_VARCHAR2_TABLE_100
    , a171 JTF_VARCHAR2_TABLE_100
    , a172 JTF_VARCHAR2_TABLE_200
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_VARCHAR2_TABLE_100
    , a175 JTF_VARCHAR2_TABLE_100
    , a176 JTF_VARCHAR2_TABLE_100
    , a177 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_number := a1(indx);
          t(ddindx).external_reference := a2(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).inventory_revision := a4(indx);
          t(ddindx).inv_master_organization_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).serial_number := a6(indx);
          t(ddindx).mfg_serial_number_flag := a7(indx);
          t(ddindx).lot_number := a8(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).unit_of_measure_name := a10(indx);
          t(ddindx).unit_of_measure := a11(indx);
          t(ddindx).accounting_class := a12(indx);
          t(ddindx).accounting_class_code := a13(indx);
          t(ddindx).instance_condition := a14(indx);
          t(ddindx).instance_condition_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).instance_status := a16(indx);
          t(ddindx).instance_status_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).customer_view_flag := a18(indx);
          t(ddindx).merchant_view_flag := a19(indx);
          t(ddindx).sellable_flag := a20(indx);
          t(ddindx).system_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).system_name := a22(indx);
          t(ddindx).instance_type_code := a23(indx);
          t(ddindx).instance_type_name := a24(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).location_type_code := a27(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).inv_organization_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).inv_organization_name := a30(indx);
          t(ddindx).inv_subinventory_name := a31(indx);
          t(ddindx).inv_locator_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).pa_project_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).pa_project_task_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).pa_project_name := a35(indx);
          t(ddindx).pa_project_number := a36(indx);
          t(ddindx).pa_task_name := a37(indx);
          t(ddindx).pa_task_number := a38(indx);
          t(ddindx).in_transit_order_line_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).in_transit_order_line_number := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).in_transit_order_number := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).wip_job_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).wip_entity_name := a43(indx);
          t(ddindx).po_order_line_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).last_oe_order_line_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).last_oe_rma_line_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).last_po_po_line_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).last_oe_po_number := a48(indx);
          t(ddindx).last_wip_job_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).last_pa_project_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).last_pa_task_id := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).last_oe_agreement_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).install_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).manually_created_flag := a54(indx);
          t(ddindx).return_by_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).actual_return_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).creation_complete_flag := a57(indx);
          t(ddindx).completeness_flag := a58(indx);
          t(ddindx).context := a59(indx);
          t(ddindx).attribute1 := a60(indx);
          t(ddindx).attribute2 := a61(indx);
          t(ddindx).attribute3 := a62(indx);
          t(ddindx).attribute4 := a63(indx);
          t(ddindx).attribute5 := a64(indx);
          t(ddindx).attribute6 := a65(indx);
          t(ddindx).attribute7 := a66(indx);
          t(ddindx).attribute8 := a67(indx);
          t(ddindx).attribute9 := a68(indx);
          t(ddindx).attribute10 := a69(indx);
          t(ddindx).attribute11 := a70(indx);
          t(ddindx).attribute12 := a71(indx);
          t(ddindx).attribute13 := a72(indx);
          t(ddindx).attribute14 := a73(indx);
          t(ddindx).attribute15 := a74(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).last_txn_line_detail_id := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).install_location_type_code := a77(indx);
          t(ddindx).install_location_id := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).instance_usage_code := a79(indx);
          t(ddindx).current_loc_address1 := a80(indx);
          t(ddindx).current_loc_address2 := a81(indx);
          t(ddindx).current_loc_address3 := a82(indx);
          t(ddindx).current_loc_address4 := a83(indx);
          t(ddindx).current_loc_city := a84(indx);
          t(ddindx).current_loc_state := a85(indx);
          t(ddindx).current_loc_postal_code := a86(indx);
          t(ddindx).current_loc_country := a87(indx);
          t(ddindx).sales_order_number := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).sales_order_line_number := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).sales_order_date := rosetta_g_miss_date_in_map(a90(indx));
          t(ddindx).purchase_order_number := a91(indx);
          t(ddindx).instance_usage_name := a92(indx);
          t(ddindx).install_loc_address1 := a93(indx);
          t(ddindx).install_loc_address2 := a94(indx);
          t(ddindx).install_loc_address3 := a95(indx);
          t(ddindx).install_loc_address4 := a96(indx);
          t(ddindx).install_loc_city := a97(indx);
          t(ddindx).install_loc_state := a98(indx);
          t(ddindx).install_loc_postal_code := a99(indx);
          t(ddindx).install_loc_country := a100(indx);
          t(ddindx).vld_organization_id := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).current_loc_number := a102(indx);
          t(ddindx).install_loc_number := a103(indx);
          t(ddindx).current_party_name := a104(indx);
          t(ddindx).current_party_number := a105(indx);
          t(ddindx).install_party_name := a106(indx);
          t(ddindx).install_party_number := a107(indx);
          t(ddindx).config_inst_hdr_id := rosetta_g_miss_num_map(a108(indx));
          t(ddindx).config_inst_rev_num := rosetta_g_miss_num_map(a109(indx));
          t(ddindx).config_inst_item_id := rosetta_g_miss_num_map(a110(indx));
          t(ddindx).config_valid_status := a111(indx);
          t(ddindx).instance_description := a112(indx);
          t(ddindx).start_loc_address1 := a113(indx);
          t(ddindx).start_loc_address2 := a114(indx);
          t(ddindx).start_loc_address3 := a115(indx);
          t(ddindx).start_loc_address4 := a116(indx);
          t(ddindx).start_loc_city := a117(indx);
          t(ddindx).start_loc_state := a118(indx);
          t(ddindx).start_loc_postal_code := a119(indx);
          t(ddindx).start_loc_country := a120(indx);
          t(ddindx).end_loc_address1 := a121(indx);
          t(ddindx).end_loc_address2 := a122(indx);
          t(ddindx).end_loc_address3 := a123(indx);
          t(ddindx).end_loc_address4 := a124(indx);
          t(ddindx).end_loc_city := a125(indx);
          t(ddindx).end_loc_state := a126(indx);
          t(ddindx).end_loc_postal_code := a127(indx);
          t(ddindx).end_loc_country := a128(indx);
          t(ddindx).vld_organization_name := a129(indx);
          t(ddindx).last_oe_agreement_name := a130(indx);
          t(ddindx).inv_locator_name := a131(indx);
          t(ddindx).network_asset_flag := a132(indx);
          t(ddindx).maintainable_flag := a133(indx);
          t(ddindx).pn_location_id := rosetta_g_miss_num_map(a134(indx));
          t(ddindx).asset_criticality_code := a135(indx);
          t(ddindx).category_id := rosetta_g_miss_num_map(a136(indx));
          t(ddindx).equipment_gen_object_id := rosetta_g_miss_num_map(a137(indx));
          t(ddindx).instantiation_flag := a138(indx);
          t(ddindx).linear_location_id := rosetta_g_miss_num_map(a139(indx));
          t(ddindx).operational_log_flag := a140(indx);
          t(ddindx).checkin_status := rosetta_g_miss_num_map(a141(indx));
          t(ddindx).supplier_warranty_exp_date := rosetta_g_miss_date_in_map(a142(indx));
          t(ddindx).attribute16 := a143(indx);
          t(ddindx).attribute17 := a144(indx);
          t(ddindx).attribute18 := a145(indx);
          t(ddindx).attribute19 := a146(indx);
          t(ddindx).attribute20 := a147(indx);
          t(ddindx).attribute21 := a148(indx);
          t(ddindx).attribute22 := a149(indx);
          t(ddindx).attribute23 := a150(indx);
          t(ddindx).attribute24 := a151(indx);
          t(ddindx).attribute25 := a152(indx);
          t(ddindx).attribute26 := a153(indx);
          t(ddindx).attribute27 := a154(indx);
          t(ddindx).attribute28 := a155(indx);
          t(ddindx).attribute29 := a156(indx);
          t(ddindx).attribute30 := a157(indx);
          t(ddindx).purchase_unit_price := rosetta_g_miss_num_map(a158(indx));
          t(ddindx).purchase_currency_code := a159(indx);
          t(ddindx).payables_unit_price := rosetta_g_miss_num_map(a160(indx));
          t(ddindx).payables_currency_code := a161(indx);
          t(ddindx).sales_unit_price := rosetta_g_miss_num_map(a162(indx));
          t(ddindx).sales_currency_code := a163(indx);
          t(ddindx).operational_status_code := a164(indx);
          t(ddindx).operational_status_name := a165(indx);
          t(ddindx).maintenance_organization := a166(indx);
          t(ddindx).department := a167(indx);
          t(ddindx).area := a168(indx);
          t(ddindx).wip_accounting_class := a169(indx);
          t(ddindx).parent_asset_group := a170(indx);
          t(ddindx).criticality := a171(indx);
          t(ddindx).category_name := a172(indx);
          t(ddindx).parent_asset_number := a173(indx);
          t(ddindx).maintainable := a174(indx);
          t(ddindx).version_label := a175(indx);
          t(ddindx).version_label_meaning := a176(indx);
          t(ddindx).inventory_item_name := a177(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t csi_datastructures_pub.instance_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_VARCHAR2_TABLE_300
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_100
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_DATE_TABLE
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_300
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
    , a99 out nocopy JTF_VARCHAR2_TABLE_100
    , a100 out nocopy JTF_VARCHAR2_TABLE_100
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_VARCHAR2_TABLE_100
    , a104 out nocopy JTF_VARCHAR2_TABLE_400
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_VARCHAR2_TABLE_400
    , a107 out nocopy JTF_VARCHAR2_TABLE_100
    , a108 out nocopy JTF_NUMBER_TABLE
    , a109 out nocopy JTF_NUMBER_TABLE
    , a110 out nocopy JTF_NUMBER_TABLE
    , a111 out nocopy JTF_VARCHAR2_TABLE_100
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_300
    , a114 out nocopy JTF_VARCHAR2_TABLE_300
    , a115 out nocopy JTF_VARCHAR2_TABLE_300
    , a116 out nocopy JTF_VARCHAR2_TABLE_300
    , a117 out nocopy JTF_VARCHAR2_TABLE_100
    , a118 out nocopy JTF_VARCHAR2_TABLE_100
    , a119 out nocopy JTF_VARCHAR2_TABLE_100
    , a120 out nocopy JTF_VARCHAR2_TABLE_100
    , a121 out nocopy JTF_VARCHAR2_TABLE_300
    , a122 out nocopy JTF_VARCHAR2_TABLE_300
    , a123 out nocopy JTF_VARCHAR2_TABLE_300
    , a124 out nocopy JTF_VARCHAR2_TABLE_300
    , a125 out nocopy JTF_VARCHAR2_TABLE_100
    , a126 out nocopy JTF_VARCHAR2_TABLE_100
    , a127 out nocopy JTF_VARCHAR2_TABLE_100
    , a128 out nocopy JTF_VARCHAR2_TABLE_100
    , a129 out nocopy JTF_VARCHAR2_TABLE_100
    , a130 out nocopy JTF_VARCHAR2_TABLE_300
    , a131 out nocopy JTF_VARCHAR2_TABLE_300
    , a132 out nocopy JTF_VARCHAR2_TABLE_100
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_NUMBER_TABLE
    , a135 out nocopy JTF_VARCHAR2_TABLE_100
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_VARCHAR2_TABLE_100
    , a139 out nocopy JTF_NUMBER_TABLE
    , a140 out nocopy JTF_VARCHAR2_TABLE_100
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_DATE_TABLE
    , a143 out nocopy JTF_VARCHAR2_TABLE_300
    , a144 out nocopy JTF_VARCHAR2_TABLE_300
    , a145 out nocopy JTF_VARCHAR2_TABLE_300
    , a146 out nocopy JTF_VARCHAR2_TABLE_300
    , a147 out nocopy JTF_VARCHAR2_TABLE_300
    , a148 out nocopy JTF_VARCHAR2_TABLE_300
    , a149 out nocopy JTF_VARCHAR2_TABLE_300
    , a150 out nocopy JTF_VARCHAR2_TABLE_300
    , a151 out nocopy JTF_VARCHAR2_TABLE_300
    , a152 out nocopy JTF_VARCHAR2_TABLE_300
    , a153 out nocopy JTF_VARCHAR2_TABLE_300
    , a154 out nocopy JTF_VARCHAR2_TABLE_300
    , a155 out nocopy JTF_VARCHAR2_TABLE_300
    , a156 out nocopy JTF_VARCHAR2_TABLE_300
    , a157 out nocopy JTF_VARCHAR2_TABLE_300
    , a158 out nocopy JTF_NUMBER_TABLE
    , a159 out nocopy JTF_VARCHAR2_TABLE_100
    , a160 out nocopy JTF_NUMBER_TABLE
    , a161 out nocopy JTF_VARCHAR2_TABLE_100
    , a162 out nocopy JTF_NUMBER_TABLE
    , a163 out nocopy JTF_VARCHAR2_TABLE_100
    , a164 out nocopy JTF_VARCHAR2_TABLE_100
    , a165 out nocopy JTF_VARCHAR2_TABLE_100
    , a166 out nocopy JTF_VARCHAR2_TABLE_100
    , a167 out nocopy JTF_VARCHAR2_TABLE_100
    , a168 out nocopy JTF_VARCHAR2_TABLE_100
    , a169 out nocopy JTF_VARCHAR2_TABLE_100
    , a170 out nocopy JTF_VARCHAR2_TABLE_100
    , a171 out nocopy JTF_VARCHAR2_TABLE_100
    , a172 out nocopy JTF_VARCHAR2_TABLE_200
    , a173 out nocopy JTF_VARCHAR2_TABLE_100
    , a174 out nocopy JTF_VARCHAR2_TABLE_100
    , a175 out nocopy JTF_VARCHAR2_TABLE_100
    , a176 out nocopy JTF_VARCHAR2_TABLE_100
    , a177 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_DATE_TABLE();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_VARCHAR2_TABLE_200();
    a99 := JTF_VARCHAR2_TABLE_100();
    a100 := JTF_VARCHAR2_TABLE_100();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_400();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_400();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_NUMBER_TABLE();
    a109 := JTF_NUMBER_TABLE();
    a110 := JTF_NUMBER_TABLE();
    a111 := JTF_VARCHAR2_TABLE_100();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_300();
    a114 := JTF_VARCHAR2_TABLE_300();
    a115 := JTF_VARCHAR2_TABLE_300();
    a116 := JTF_VARCHAR2_TABLE_300();
    a117 := JTF_VARCHAR2_TABLE_100();
    a118 := JTF_VARCHAR2_TABLE_100();
    a119 := JTF_VARCHAR2_TABLE_100();
    a120 := JTF_VARCHAR2_TABLE_100();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_300();
    a124 := JTF_VARCHAR2_TABLE_300();
    a125 := JTF_VARCHAR2_TABLE_100();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_100();
    a128 := JTF_VARCHAR2_TABLE_100();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_VARCHAR2_TABLE_300();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_100();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_NUMBER_TABLE();
    a135 := JTF_VARCHAR2_TABLE_100();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_NUMBER_TABLE();
    a138 := JTF_VARCHAR2_TABLE_100();
    a139 := JTF_NUMBER_TABLE();
    a140 := JTF_VARCHAR2_TABLE_100();
    a141 := JTF_NUMBER_TABLE();
    a142 := JTF_DATE_TABLE();
    a143 := JTF_VARCHAR2_TABLE_300();
    a144 := JTF_VARCHAR2_TABLE_300();
    a145 := JTF_VARCHAR2_TABLE_300();
    a146 := JTF_VARCHAR2_TABLE_300();
    a147 := JTF_VARCHAR2_TABLE_300();
    a148 := JTF_VARCHAR2_TABLE_300();
    a149 := JTF_VARCHAR2_TABLE_300();
    a150 := JTF_VARCHAR2_TABLE_300();
    a151 := JTF_VARCHAR2_TABLE_300();
    a152 := JTF_VARCHAR2_TABLE_300();
    a153 := JTF_VARCHAR2_TABLE_300();
    a154 := JTF_VARCHAR2_TABLE_300();
    a155 := JTF_VARCHAR2_TABLE_300();
    a156 := JTF_VARCHAR2_TABLE_300();
    a157 := JTF_VARCHAR2_TABLE_300();
    a158 := JTF_NUMBER_TABLE();
    a159 := JTF_VARCHAR2_TABLE_100();
    a160 := JTF_NUMBER_TABLE();
    a161 := JTF_VARCHAR2_TABLE_100();
    a162 := JTF_NUMBER_TABLE();
    a163 := JTF_VARCHAR2_TABLE_100();
    a164 := JTF_VARCHAR2_TABLE_100();
    a165 := JTF_VARCHAR2_TABLE_100();
    a166 := JTF_VARCHAR2_TABLE_100();
    a167 := JTF_VARCHAR2_TABLE_100();
    a168 := JTF_VARCHAR2_TABLE_100();
    a169 := JTF_VARCHAR2_TABLE_100();
    a170 := JTF_VARCHAR2_TABLE_100();
    a171 := JTF_VARCHAR2_TABLE_100();
    a172 := JTF_VARCHAR2_TABLE_200();
    a173 := JTF_VARCHAR2_TABLE_100();
    a174 := JTF_VARCHAR2_TABLE_100();
    a175 := JTF_VARCHAR2_TABLE_100();
    a176 := JTF_VARCHAR2_TABLE_100();
    a177 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_DATE_TABLE();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_VARCHAR2_TABLE_200();
      a99 := JTF_VARCHAR2_TABLE_100();
      a100 := JTF_VARCHAR2_TABLE_100();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_400();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_400();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_NUMBER_TABLE();
      a109 := JTF_NUMBER_TABLE();
      a110 := JTF_NUMBER_TABLE();
      a111 := JTF_VARCHAR2_TABLE_100();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_300();
      a114 := JTF_VARCHAR2_TABLE_300();
      a115 := JTF_VARCHAR2_TABLE_300();
      a116 := JTF_VARCHAR2_TABLE_300();
      a117 := JTF_VARCHAR2_TABLE_100();
      a118 := JTF_VARCHAR2_TABLE_100();
      a119 := JTF_VARCHAR2_TABLE_100();
      a120 := JTF_VARCHAR2_TABLE_100();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_300();
      a124 := JTF_VARCHAR2_TABLE_300();
      a125 := JTF_VARCHAR2_TABLE_100();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_100();
      a128 := JTF_VARCHAR2_TABLE_100();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_VARCHAR2_TABLE_300();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_100();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_NUMBER_TABLE();
      a135 := JTF_VARCHAR2_TABLE_100();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_NUMBER_TABLE();
      a138 := JTF_VARCHAR2_TABLE_100();
      a139 := JTF_NUMBER_TABLE();
      a140 := JTF_VARCHAR2_TABLE_100();
      a141 := JTF_NUMBER_TABLE();
      a142 := JTF_DATE_TABLE();
      a143 := JTF_VARCHAR2_TABLE_300();
      a144 := JTF_VARCHAR2_TABLE_300();
      a145 := JTF_VARCHAR2_TABLE_300();
      a146 := JTF_VARCHAR2_TABLE_300();
      a147 := JTF_VARCHAR2_TABLE_300();
      a148 := JTF_VARCHAR2_TABLE_300();
      a149 := JTF_VARCHAR2_TABLE_300();
      a150 := JTF_VARCHAR2_TABLE_300();
      a151 := JTF_VARCHAR2_TABLE_300();
      a152 := JTF_VARCHAR2_TABLE_300();
      a153 := JTF_VARCHAR2_TABLE_300();
      a154 := JTF_VARCHAR2_TABLE_300();
      a155 := JTF_VARCHAR2_TABLE_300();
      a156 := JTF_VARCHAR2_TABLE_300();
      a157 := JTF_VARCHAR2_TABLE_300();
      a158 := JTF_NUMBER_TABLE();
      a159 := JTF_VARCHAR2_TABLE_100();
      a160 := JTF_NUMBER_TABLE();
      a161 := JTF_VARCHAR2_TABLE_100();
      a162 := JTF_NUMBER_TABLE();
      a163 := JTF_VARCHAR2_TABLE_100();
      a164 := JTF_VARCHAR2_TABLE_100();
      a165 := JTF_VARCHAR2_TABLE_100();
      a166 := JTF_VARCHAR2_TABLE_100();
      a167 := JTF_VARCHAR2_TABLE_100();
      a168 := JTF_VARCHAR2_TABLE_100();
      a169 := JTF_VARCHAR2_TABLE_100();
      a170 := JTF_VARCHAR2_TABLE_100();
      a171 := JTF_VARCHAR2_TABLE_100();
      a172 := JTF_VARCHAR2_TABLE_200();
      a173 := JTF_VARCHAR2_TABLE_100();
      a174 := JTF_VARCHAR2_TABLE_100();
      a175 := JTF_VARCHAR2_TABLE_100();
      a176 := JTF_VARCHAR2_TABLE_100();
      a177 := JTF_VARCHAR2_TABLE_300();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).instance_number;
          a2(indx) := t(ddindx).external_reference;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a4(indx) := t(ddindx).inventory_revision;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).inv_master_organization_id);
          a6(indx) := t(ddindx).serial_number;
          a7(indx) := t(ddindx).mfg_serial_number_flag;
          a8(indx) := t(ddindx).lot_number;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a10(indx) := t(ddindx).unit_of_measure_name;
          a11(indx) := t(ddindx).unit_of_measure;
          a12(indx) := t(ddindx).accounting_class;
          a13(indx) := t(ddindx).accounting_class_code;
          a14(indx) := t(ddindx).instance_condition;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).instance_condition_id);
          a16(indx) := t(ddindx).instance_status;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).instance_status_id);
          a18(indx) := t(ddindx).customer_view_flag;
          a19(indx) := t(ddindx).merchant_view_flag;
          a20(indx) := t(ddindx).sellable_flag;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a22(indx) := t(ddindx).system_name;
          a23(indx) := t(ddindx).instance_type_code;
          a24(indx) := t(ddindx).instance_type_name;
          a25(indx) := t(ddindx).active_start_date;
          a26(indx) := t(ddindx).active_end_date;
          a27(indx) := t(ddindx).location_type_code;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).inv_organization_id);
          a30(indx) := t(ddindx).inv_organization_name;
          a31(indx) := t(ddindx).inv_subinventory_name;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).inv_locator_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_task_id);
          a35(indx) := t(ddindx).pa_project_name;
          a36(indx) := t(ddindx).pa_project_number;
          a37(indx) := t(ddindx).pa_task_name;
          a38(indx) := t(ddindx).pa_task_number;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).in_transit_order_line_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).in_transit_order_line_number);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).in_transit_order_number);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).wip_job_id);
          a43(indx) := t(ddindx).wip_entity_name;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).po_order_line_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_order_line_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_rma_line_id);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).last_po_po_line_id);
          a48(indx) := t(ddindx).last_oe_po_number;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).last_wip_job_id);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_id);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_task_id);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).last_oe_agreement_id);
          a53(indx) := t(ddindx).install_date;
          a54(indx) := t(ddindx).manually_created_flag;
          a55(indx) := t(ddindx).return_by_date;
          a56(indx) := t(ddindx).actual_return_date;
          a57(indx) := t(ddindx).creation_complete_flag;
          a58(indx) := t(ddindx).completeness_flag;
          a59(indx) := t(ddindx).context;
          a60(indx) := t(ddindx).attribute1;
          a61(indx) := t(ddindx).attribute2;
          a62(indx) := t(ddindx).attribute3;
          a63(indx) := t(ddindx).attribute4;
          a64(indx) := t(ddindx).attribute5;
          a65(indx) := t(ddindx).attribute6;
          a66(indx) := t(ddindx).attribute7;
          a67(indx) := t(ddindx).attribute8;
          a68(indx) := t(ddindx).attribute9;
          a69(indx) := t(ddindx).attribute10;
          a70(indx) := t(ddindx).attribute11;
          a71(indx) := t(ddindx).attribute12;
          a72(indx) := t(ddindx).attribute13;
          a73(indx) := t(ddindx).attribute14;
          a74(indx) := t(ddindx).attribute15;
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).last_txn_line_detail_id);
          a77(indx) := t(ddindx).install_location_type_code;
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).install_location_id);
          a79(indx) := t(ddindx).instance_usage_code;
          a80(indx) := t(ddindx).current_loc_address1;
          a81(indx) := t(ddindx).current_loc_address2;
          a82(indx) := t(ddindx).current_loc_address3;
          a83(indx) := t(ddindx).current_loc_address4;
          a84(indx) := t(ddindx).current_loc_city;
          a85(indx) := t(ddindx).current_loc_state;
          a86(indx) := t(ddindx).current_loc_postal_code;
          a87(indx) := t(ddindx).current_loc_country;
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).sales_order_number);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).sales_order_line_number);
          a90(indx) := t(ddindx).sales_order_date;
          a91(indx) := t(ddindx).purchase_order_number;
          a92(indx) := t(ddindx).instance_usage_name;
          a93(indx) := t(ddindx).install_loc_address1;
          a94(indx) := t(ddindx).install_loc_address2;
          a95(indx) := t(ddindx).install_loc_address3;
          a96(indx) := t(ddindx).install_loc_address4;
          a97(indx) := t(ddindx).install_loc_city;
          a98(indx) := t(ddindx).install_loc_state;
          a99(indx) := t(ddindx).install_loc_postal_code;
          a100(indx) := t(ddindx).install_loc_country;
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).vld_organization_id);
          a102(indx) := t(ddindx).current_loc_number;
          a103(indx) := t(ddindx).install_loc_number;
          a104(indx) := t(ddindx).current_party_name;
          a105(indx) := t(ddindx).current_party_number;
          a106(indx) := t(ddindx).install_party_name;
          a107(indx) := t(ddindx).install_party_number;
          a108(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_hdr_id);
          a109(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_rev_num);
          a110(indx) := rosetta_g_miss_num_map(t(ddindx).config_inst_item_id);
          a111(indx) := t(ddindx).config_valid_status;
          a112(indx) := t(ddindx).instance_description;
          a113(indx) := t(ddindx).start_loc_address1;
          a114(indx) := t(ddindx).start_loc_address2;
          a115(indx) := t(ddindx).start_loc_address3;
          a116(indx) := t(ddindx).start_loc_address4;
          a117(indx) := t(ddindx).start_loc_city;
          a118(indx) := t(ddindx).start_loc_state;
          a119(indx) := t(ddindx).start_loc_postal_code;
          a120(indx) := t(ddindx).start_loc_country;
          a121(indx) := t(ddindx).end_loc_address1;
          a122(indx) := t(ddindx).end_loc_address2;
          a123(indx) := t(ddindx).end_loc_address3;
          a124(indx) := t(ddindx).end_loc_address4;
          a125(indx) := t(ddindx).end_loc_city;
          a126(indx) := t(ddindx).end_loc_state;
          a127(indx) := t(ddindx).end_loc_postal_code;
          a128(indx) := t(ddindx).end_loc_country;
          a129(indx) := t(ddindx).vld_organization_name;
          a130(indx) := t(ddindx).last_oe_agreement_name;
          a131(indx) := t(ddindx).inv_locator_name;
          a132(indx) := t(ddindx).network_asset_flag;
          a133(indx) := t(ddindx).maintainable_flag;
          a134(indx) := rosetta_g_miss_num_map(t(ddindx).pn_location_id);
          a135(indx) := t(ddindx).asset_criticality_code;
          a136(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a137(indx) := rosetta_g_miss_num_map(t(ddindx).equipment_gen_object_id);
          a138(indx) := t(ddindx).instantiation_flag;
          a139(indx) := rosetta_g_miss_num_map(t(ddindx).linear_location_id);
          a140(indx) := t(ddindx).operational_log_flag;
          a141(indx) := rosetta_g_miss_num_map(t(ddindx).checkin_status);
          a142(indx) := t(ddindx).supplier_warranty_exp_date;
          a143(indx) := t(ddindx).attribute16;
          a144(indx) := t(ddindx).attribute17;
          a145(indx) := t(ddindx).attribute18;
          a146(indx) := t(ddindx).attribute19;
          a147(indx) := t(ddindx).attribute20;
          a148(indx) := t(ddindx).attribute21;
          a149(indx) := t(ddindx).attribute22;
          a150(indx) := t(ddindx).attribute23;
          a151(indx) := t(ddindx).attribute24;
          a152(indx) := t(ddindx).attribute25;
          a153(indx) := t(ddindx).attribute26;
          a154(indx) := t(ddindx).attribute27;
          a155(indx) := t(ddindx).attribute28;
          a156(indx) := t(ddindx).attribute29;
          a157(indx) := t(ddindx).attribute30;
          a158(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_unit_price);
          a159(indx) := t(ddindx).purchase_currency_code;
          a160(indx) := rosetta_g_miss_num_map(t(ddindx).payables_unit_price);
          a161(indx) := t(ddindx).payables_currency_code;
          a162(indx) := rosetta_g_miss_num_map(t(ddindx).sales_unit_price);
          a163(indx) := t(ddindx).sales_currency_code;
          a164(indx) := t(ddindx).operational_status_code;
          a165(indx) := t(ddindx).operational_status_name;
          a166(indx) := t(ddindx).maintenance_organization;
          a167(indx) := t(ddindx).department;
          a168(indx) := t(ddindx).area;
          a169(indx) := t(ddindx).wip_accounting_class;
          a170(indx) := t(ddindx).parent_asset_group;
          a171(indx) := t(ddindx).criticality;
          a172(indx) := t(ddindx).category_name;
          a173(indx) := t(ddindx).parent_asset_number;
          a174(indx) := t(ddindx).maintainable;
          a175(indx) := t(ddindx).version_label;
          a176(indx) := t(ddindx).version_label_meaning;
          a177(indx) := t(ddindx).inventory_item_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p24(t out nocopy csi_datastructures_pub.transactions_query_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).txn_sub_type_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).source_group_ref_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).source_group_ref := a4(indx);
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).source_header_ref := a6(indx);
          t(ddindx).source_line_ref_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).source_line_ref := a8(indx);
          t(ddindx).source_transaction_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).inv_material_transaction_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).transaction_start_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).transaction_end_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).transaction_status_code := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t csi_datastructures_pub.transactions_query_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).txn_sub_type_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).source_group_ref_id);
          a4(indx) := t(ddindx).source_group_ref;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a6(indx) := t(ddindx).source_header_ref;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).source_line_ref_id);
          a8(indx) := t(ddindx).source_line_ref;
          a9(indx) := t(ddindx).source_transaction_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).inv_material_transaction_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          a12(indx) := t(ddindx).transaction_start_date;
          a13(indx) := t(ddindx).transaction_end_date;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a15(indx) := t(ddindx).transaction_status_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p27(t out nocopy csi_datastructures_pub.transaction_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).source_transaction_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).txn_sub_type_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).source_group_ref_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).source_group_ref := a6(indx);
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).source_header_ref := a8(indx);
          t(ddindx).source_line_ref_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).source_line_ref := a10(indx);
          t(ddindx).source_dist_ref_id1 := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).source_dist_ref_id2 := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).inv_material_transaction_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).transaction_uom_code := a15(indx);
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).transaction_status_code := a17(indx);
          t(ddindx).transaction_action_code := a18(indx);
          t(ddindx).message_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).context := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).split_reason_code := a37(indx);
          t(ddindx).src_txn_creation_date := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).gl_interface_status_code := rosetta_g_miss_num_map(a39(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t csi_datastructures_pub.transaction_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := t(ddindx).transaction_date;
          a2(indx) := t(ddindx).source_transaction_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).txn_sub_type_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).source_group_ref_id);
          a6(indx) := t(ddindx).source_group_ref;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a8(indx) := t(ddindx).source_header_ref;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).source_line_ref_id);
          a10(indx) := t(ddindx).source_line_ref;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id1);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id2);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).inv_material_transaction_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a15(indx) := t(ddindx).transaction_uom_code;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a17(indx) := t(ddindx).transaction_status_code;
          a18(indx) := t(ddindx).transaction_action_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          a20(indx) := t(ddindx).context;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a37(indx) := t(ddindx).split_reason_code;
          a38(indx) := t(ddindx).src_txn_creation_date;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).gl_interface_status_code);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure rosetta_table_copy_in_p29(t out nocopy csi_datastructures_pub.transactions_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_error_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).error_text := a3(indx);
          t(ddindx).source_type := a4(indx);
          t(ddindx).source_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).processed_flag := a6(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).source_group_ref := a14(indx);
          t(ddindx).source_group_ref_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).source_header_ref := a16(indx);
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).source_line_ref := a18(indx);
          t(ddindx).source_line_ref_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).source_dist_ref_id1 := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).source_dist_ref_id2 := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).inv_material_transaction_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).error_stage := a23(indx);
          t(ddindx).message_string := a24(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).serial_number := a27(indx);
          t(ddindx).lot_number := a28(indx);
          t(ddindx).transaction_error_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).src_serial_num_ctrl_code := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).src_location_ctrl_code := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).src_lot_ctrl_code := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).src_rev_qty_ctrl_code := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).dst_serial_num_ctrl_code := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).dst_location_ctrl_code := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).dst_lot_ctrl_code := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).dst_rev_qty_ctrl_code := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).comms_nl_trackable_flag := a38(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t csi_datastructures_pub.transactions_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_4000();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_4000();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_error_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          a3(indx) := t(ddindx).error_text;
          a4(indx) := t(ddindx).source_type;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).source_id);
          a6(indx) := t(ddindx).processed_flag;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := t(ddindx).last_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a14(indx) := t(ddindx).source_group_ref;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).source_group_ref_id);
          a16(indx) := t(ddindx).source_header_ref;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a18(indx) := t(ddindx).source_line_ref;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).source_line_ref_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id1);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id2);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).inv_material_transaction_id);
          a23(indx) := t(ddindx).error_stage;
          a24(indx) := t(ddindx).message_string;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a27(indx) := t(ddindx).serial_number;
          a28(indx) := t(ddindx).lot_number;
          a29(indx) := t(ddindx).transaction_error_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).src_serial_num_ctrl_code);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).src_location_ctrl_code);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).src_lot_ctrl_code);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).src_rev_qty_ctrl_code);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).dst_serial_num_ctrl_code);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).dst_location_ctrl_code);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).dst_lot_ctrl_code);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).dst_rev_qty_ctrl_code);
          a38(indx) := t(ddindx).comms_nl_trackable_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p32(t out nocopy csi_datastructures_pub.ii_relationship_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).relationship_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).relationship_type_code := a1(indx);
          t(ddindx).object_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).subject_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).subject_has_child := a4(indx);
          t(ddindx).position_reference := a5(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).display_order := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).mandatory_flag := a9(indx);
          t(ddindx).context := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).processed_flag := a28(indx);
          t(ddindx).interface_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).cascade_ownership_flag := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p32;
  procedure rosetta_table_copy_out_p32(t csi_datastructures_pub.ii_relationship_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_id);
          a1(indx) := t(ddindx).relationship_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).subject_id);
          a4(indx) := t(ddindx).subject_has_child;
          a5(indx) := t(ddindx).position_reference;
          a6(indx) := t(ddindx).active_start_date;
          a7(indx) := t(ddindx).active_end_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).display_order);
          a9(indx) := t(ddindx).mandatory_flag;
          a10(indx) := t(ddindx).context;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a28(indx) := t(ddindx).processed_flag;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).interface_id);
          a30(indx) := t(ddindx).cascade_ownership_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p32;

  procedure rosetta_table_copy_in_p34(t out nocopy csi_datastructures_pub.relationship_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).relationship_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).relationship_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_subject_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).new_subject_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).old_position_reference := a5(indx);
          t(ddindx).new_position_reference := a6(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).old_mandatory_flag := a11(indx);
          t(ddindx).new_mandatory_flag := a12(indx);
          t(ddindx).old_context := a13(indx);
          t(ddindx).new_context := a14(indx);
          t(ddindx).old_attribute1 := a15(indx);
          t(ddindx).new_attribute1 := a16(indx);
          t(ddindx).old_attribute2 := a17(indx);
          t(ddindx).new_attribute2 := a18(indx);
          t(ddindx).old_attribute3 := a19(indx);
          t(ddindx).new_attribute3 := a20(indx);
          t(ddindx).old_attribute4 := a21(indx);
          t(ddindx).new_attribute4 := a22(indx);
          t(ddindx).old_attribute5 := a23(indx);
          t(ddindx).new_attribute5 := a24(indx);
          t(ddindx).old_attribute6 := a25(indx);
          t(ddindx).new_attribute6 := a26(indx);
          t(ddindx).old_attribute7 := a27(indx);
          t(ddindx).new_attribute7 := a28(indx);
          t(ddindx).old_attribute8 := a29(indx);
          t(ddindx).new_attribute8 := a30(indx);
          t(ddindx).old_attribute9 := a31(indx);
          t(ddindx).new_attribute9 := a32(indx);
          t(ddindx).old_attribute10 := a33(indx);
          t(ddindx).new_attribute10 := a34(indx);
          t(ddindx).old_attribute11 := a35(indx);
          t(ddindx).new_attribute11 := a36(indx);
          t(ddindx).old_attribute12 := a37(indx);
          t(ddindx).new_attribute12 := a38(indx);
          t(ddindx).old_attribute13 := a39(indx);
          t(ddindx).new_attribute13 := a40(indx);
          t(ddindx).old_attribute14 := a41(indx);
          t(ddindx).new_attribute14 := a42(indx);
          t(ddindx).old_attribute15 := a43(indx);
          t(ddindx).new_attribute15 := a44(indx);
          t(ddindx).full_dump_flag := a45(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).object_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).relationship_type_code := a50(indx);
          t(ddindx).relationship_type := a51(indx);
          t(ddindx).old_subject_number := a52(indx);
          t(ddindx).new_subject_number := a53(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t csi_datastructures_pub.relationship_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).old_subject_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).new_subject_id);
          a5(indx) := t(ddindx).old_position_reference;
          a6(indx) := t(ddindx).new_position_reference;
          a7(indx) := t(ddindx).old_active_start_date;
          a8(indx) := t(ddindx).new_active_start_date;
          a9(indx) := t(ddindx).old_active_end_date;
          a10(indx) := t(ddindx).new_active_end_date;
          a11(indx) := t(ddindx).old_mandatory_flag;
          a12(indx) := t(ddindx).new_mandatory_flag;
          a13(indx) := t(ddindx).old_context;
          a14(indx) := t(ddindx).new_context;
          a15(indx) := t(ddindx).old_attribute1;
          a16(indx) := t(ddindx).new_attribute1;
          a17(indx) := t(ddindx).old_attribute2;
          a18(indx) := t(ddindx).new_attribute2;
          a19(indx) := t(ddindx).old_attribute3;
          a20(indx) := t(ddindx).new_attribute3;
          a21(indx) := t(ddindx).old_attribute4;
          a22(indx) := t(ddindx).new_attribute4;
          a23(indx) := t(ddindx).old_attribute5;
          a24(indx) := t(ddindx).new_attribute5;
          a25(indx) := t(ddindx).old_attribute6;
          a26(indx) := t(ddindx).new_attribute6;
          a27(indx) := t(ddindx).old_attribute7;
          a28(indx) := t(ddindx).new_attribute7;
          a29(indx) := t(ddindx).old_attribute8;
          a30(indx) := t(ddindx).new_attribute8;
          a31(indx) := t(ddindx).old_attribute9;
          a32(indx) := t(ddindx).new_attribute9;
          a33(indx) := t(ddindx).old_attribute10;
          a34(indx) := t(ddindx).new_attribute10;
          a35(indx) := t(ddindx).old_attribute11;
          a36(indx) := t(ddindx).new_attribute11;
          a37(indx) := t(ddindx).old_attribute12;
          a38(indx) := t(ddindx).new_attribute12;
          a39(indx) := t(ddindx).old_attribute13;
          a40(indx) := t(ddindx).new_attribute13;
          a41(indx) := t(ddindx).old_attribute14;
          a42(indx) := t(ddindx).new_attribute14;
          a43(indx) := t(ddindx).old_attribute15;
          a44(indx) := t(ddindx).new_attribute15;
          a45(indx) := t(ddindx).full_dump_flag;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a47(indx) := t(ddindx).creation_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a50(indx) := t(ddindx).relationship_type_code;
          a51(indx) := t(ddindx).relationship_type;
          a52(indx) := t(ddindx).old_subject_number;
          a53(indx) := t(ddindx).new_subject_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure rosetta_table_copy_in_p36(t out nocopy csi_datastructures_pub.systems_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).system_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).customer_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).system_type_code := a2(indx);
          t(ddindx).system_number := a3(indx);
          t(ddindx).parent_system_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ship_to_contact_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).bill_to_contact_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).technical_contact_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).service_admin_contact_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).ship_to_site_use_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).install_site_use_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).coterminate_day_month := a12(indx);
          t(ddindx).autocreated_from_system_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).config_system_type := a14(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).context := a17(indx);
          t(ddindx).attribute1 := a18(indx);
          t(ddindx).attribute2 := a19(indx);
          t(ddindx).attribute3 := a20(indx);
          t(ddindx).attribute4 := a21(indx);
          t(ddindx).attribute5 := a22(indx);
          t(ddindx).attribute6 := a23(indx);
          t(ddindx).attribute7 := a24(indx);
          t(ddindx).attribute8 := a25(indx);
          t(ddindx).attribute9 := a26(indx);
          t(ddindx).attribute10 := a27(indx);
          t(ddindx).attribute11 := a28(indx);
          t(ddindx).attribute12 := a29(indx);
          t(ddindx).attribute13 := a30(indx);
          t(ddindx).attribute14 := a31(indx);
          t(ddindx).attribute15 := a32(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).name := a34(indx);
          t(ddindx).description := a35(indx);
          t(ddindx).tech_cont_change_flag := a36(indx);
          t(ddindx).bill_to_cont_change_flag := a37(indx);
          t(ddindx).ship_to_cont_change_flag := a38(indx);
          t(ddindx).serv_admin_cont_change_flag := a39(indx);
          t(ddindx).bill_to_site_change_flag := a40(indx);
          t(ddindx).ship_to_site_change_flag := a41(indx);
          t(ddindx).install_to_site_change_flag := a42(indx);
          t(ddindx).cascade_cust_to_ins_flag := a43(indx);
          t(ddindx).operating_unit_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a48(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p36;
  procedure rosetta_table_copy_out_p36(t csi_datastructures_pub.systems_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a2(indx) := t(ddindx).system_type_code;
          a3(indx) := t(ddindx).system_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).parent_system_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_contact_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_contact_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).technical_contact_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).service_admin_contact_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_use_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).install_site_use_id);
          a12(indx) := t(ddindx).coterminate_day_month;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).autocreated_from_system_id);
          a14(indx) := t(ddindx).config_system_type;
          a15(indx) := t(ddindx).start_date_active;
          a16(indx) := t(ddindx).end_date_active;
          a17(indx) := t(ddindx).context;
          a18(indx) := t(ddindx).attribute1;
          a19(indx) := t(ddindx).attribute2;
          a20(indx) := t(ddindx).attribute3;
          a21(indx) := t(ddindx).attribute4;
          a22(indx) := t(ddindx).attribute5;
          a23(indx) := t(ddindx).attribute6;
          a24(indx) := t(ddindx).attribute7;
          a25(indx) := t(ddindx).attribute8;
          a26(indx) := t(ddindx).attribute9;
          a27(indx) := t(ddindx).attribute10;
          a28(indx) := t(ddindx).attribute11;
          a29(indx) := t(ddindx).attribute12;
          a30(indx) := t(ddindx).attribute13;
          a31(indx) := t(ddindx).attribute14;
          a32(indx) := t(ddindx).attribute15;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a34(indx) := t(ddindx).name;
          a35(indx) := t(ddindx).description;
          a36(indx) := t(ddindx).tech_cont_change_flag;
          a37(indx) := t(ddindx).bill_to_cont_change_flag;
          a38(indx) := t(ddindx).ship_to_cont_change_flag;
          a39(indx) := t(ddindx).serv_admin_cont_change_flag;
          a40(indx) := t(ddindx).bill_to_site_change_flag;
          a41(indx) := t(ddindx).ship_to_site_change_flag;
          a42(indx) := t(ddindx).install_to_site_change_flag;
          a43(indx) := t(ddindx).cascade_cust_to_ins_flag;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).operating_unit_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a48(indx) := t(ddindx).program_update_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p36;

  procedure rosetta_table_copy_in_p38(t out nocopy csi_datastructures_pub.systems_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_400
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_400
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_100
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_100
    , a117 JTF_VARCHAR2_TABLE_100
    , a118 JTF_VARCHAR2_TABLE_400
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_100
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_VARCHAR2_TABLE_400
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_VARCHAR2_TABLE_100
    , a137 JTF_VARCHAR2_TABLE_100
    , a138 JTF_VARCHAR2_TABLE_400
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_400
    , a141 JTF_VARCHAR2_TABLE_100
    , a142 JTF_VARCHAR2_TABLE_400
    , a143 JTF_VARCHAR2_TABLE_100
    , a144 JTF_VARCHAR2_TABLE_400
    , a145 JTF_VARCHAR2_TABLE_100
    , a146 JTF_VARCHAR2_TABLE_400
    , a147 JTF_VARCHAR2_TABLE_100
    , a148 JTF_VARCHAR2_TABLE_400
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_VARCHAR2_TABLE_400
    , a151 JTF_VARCHAR2_TABLE_100
    , a152 JTF_VARCHAR2_TABLE_400
    , a153 JTF_VARCHAR2_TABLE_100
    , a154 JTF_VARCHAR2_TABLE_400
    , a155 JTF_VARCHAR2_TABLE_100
    , a156 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).system_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).system_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_customer_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).new_customer_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).old_system_type_code := a5(indx);
          t(ddindx).new_system_type_code := a6(indx);
          t(ddindx).old_system_number := a7(indx);
          t(ddindx).new_system_number := a8(indx);
          t(ddindx).old_parent_system_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).new_parent_system_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).old_ship_to_contact_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).new_ship_to_contact_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).old_bill_to_contact_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).new_bill_to_contact_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).old_technical_contact_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).new_technical_contact_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).old_service_admin_contact_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).new_service_admin_contact_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).old_ship_to_site_use_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).new_ship_to_site_use_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).old_install_site_use_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).new_install_site_use_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).old_bill_to_site_use_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).new_bill_to_site_use_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).old_coterminate_day_month := a25(indx);
          t(ddindx).new_coterminate_day_month := a26(indx);
          t(ddindx).old_start_date_active := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).new_start_date_active := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).old_end_date_active := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).new_end_date_active := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).old_autocreated_from_system := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).new_autocreated_from_system := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).old_config_system_type := a33(indx);
          t(ddindx).new_config_system_type := a34(indx);
          t(ddindx).old_context := a35(indx);
          t(ddindx).new_context := a36(indx);
          t(ddindx).old_attribute1 := a37(indx);
          t(ddindx).new_attribute1 := a38(indx);
          t(ddindx).old_attribute2 := a39(indx);
          t(ddindx).new_attribute2 := a40(indx);
          t(ddindx).old_attribute3 := a41(indx);
          t(ddindx).new_attribute3 := a42(indx);
          t(ddindx).old_attribute4 := a43(indx);
          t(ddindx).new_attribute4 := a44(indx);
          t(ddindx).old_attribute5 := a45(indx);
          t(ddindx).new_attribute5 := a46(indx);
          t(ddindx).old_attribute6 := a47(indx);
          t(ddindx).new_attribute6 := a48(indx);
          t(ddindx).old_attribute7 := a49(indx);
          t(ddindx).new_attribute7 := a50(indx);
          t(ddindx).old_attribute8 := a51(indx);
          t(ddindx).new_attribute8 := a52(indx);
          t(ddindx).old_attribute9 := a53(indx);
          t(ddindx).new_attribute9 := a54(indx);
          t(ddindx).old_attribute10 := a55(indx);
          t(ddindx).new_attribute10 := a56(indx);
          t(ddindx).old_attribute11 := a57(indx);
          t(ddindx).new_attribute11 := a58(indx);
          t(ddindx).old_attribute12 := a59(indx);
          t(ddindx).new_attribute12 := a60(indx);
          t(ddindx).old_attribute13 := a61(indx);
          t(ddindx).new_attribute13 := a62(indx);
          t(ddindx).old_attribute14 := a63(indx);
          t(ddindx).new_attribute14 := a64(indx);
          t(ddindx).old_attribute15 := a65(indx);
          t(ddindx).new_attribute15 := a66(indx);
          t(ddindx).full_dump_flag := a67(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).old_name := a69(indx);
          t(ddindx).new_name := a70(indx);
          t(ddindx).old_description := a71(indx);
          t(ddindx).new_description := a72(indx);
          t(ddindx).old_operating_unit_id := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).new_operating_unit_id := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).old_system_type := a75(indx);
          t(ddindx).new_system_type := a76(indx);
          t(ddindx).old_parent_name := a77(indx);
          t(ddindx).new_parent_name := a78(indx);
          t(ddindx).old_ship_to_address1 := a79(indx);
          t(ddindx).old_ship_to_address2 := a80(indx);
          t(ddindx).old_ship_to_address3 := a81(indx);
          t(ddindx).old_ship_to_address4 := a82(indx);
          t(ddindx).old_ship_to_location := a83(indx);
          t(ddindx).old_ship_state := a84(indx);
          t(ddindx).old_ship_postal_code := a85(indx);
          t(ddindx).old_ship_country := a86(indx);
          t(ddindx).old_ship_to_customer := a87(indx);
          t(ddindx).old_ship_to_customer_number := a88(indx);
          t(ddindx).new_ship_to_address1 := a89(indx);
          t(ddindx).new_ship_to_address2 := a90(indx);
          t(ddindx).new_ship_to_address3 := a91(indx);
          t(ddindx).new_ship_to_address4 := a92(indx);
          t(ddindx).new_ship_to_location := a93(indx);
          t(ddindx).new_ship_state := a94(indx);
          t(ddindx).new_ship_postal_code := a95(indx);
          t(ddindx).new_ship_country := a96(indx);
          t(ddindx).new_ship_to_customer := a97(indx);
          t(ddindx).new_ship_to_customer_number := a98(indx);
          t(ddindx).old_install_address1 := a99(indx);
          t(ddindx).old_install_address2 := a100(indx);
          t(ddindx).old_install_address3 := a101(indx);
          t(ddindx).old_install_address4 := a102(indx);
          t(ddindx).old_install_location := a103(indx);
          t(ddindx).old_install_state := a104(indx);
          t(ddindx).old_install_postal_code := a105(indx);
          t(ddindx).old_install_country := a106(indx);
          t(ddindx).old_install_customer_number := a107(indx);
          t(ddindx).old_install_customer := a108(indx);
          t(ddindx).new_install_address1 := a109(indx);
          t(ddindx).new_install_address2 := a110(indx);
          t(ddindx).new_install_address3 := a111(indx);
          t(ddindx).new_install_address4 := a112(indx);
          t(ddindx).new_install_location := a113(indx);
          t(ddindx).new_install_state := a114(indx);
          t(ddindx).new_install_postal_code := a115(indx);
          t(ddindx).new_install_country := a116(indx);
          t(ddindx).new_install_customer_number := a117(indx);
          t(ddindx).new_install_customer := a118(indx);
          t(ddindx).old_bill_to_address1 := a119(indx);
          t(ddindx).old_bill_to_address2 := a120(indx);
          t(ddindx).old_bill_to_address3 := a121(indx);
          t(ddindx).old_bill_to_address4 := a122(indx);
          t(ddindx).old_bill_to_location := a123(indx);
          t(ddindx).old_bill_state := a124(indx);
          t(ddindx).old_bill_postal_code := a125(indx);
          t(ddindx).old_bill_country := a126(indx);
          t(ddindx).old_bill_to_customer_number := a127(indx);
          t(ddindx).old_bill_to_customer := a128(indx);
          t(ddindx).new_bill_to_address1 := a129(indx);
          t(ddindx).new_bill_to_address2 := a130(indx);
          t(ddindx).new_bill_to_address3 := a131(indx);
          t(ddindx).new_bill_to_address4 := a132(indx);
          t(ddindx).new_bill_to_location := a133(indx);
          t(ddindx).new_bill_state := a134(indx);
          t(ddindx).new_bill_postal_code := a135(indx);
          t(ddindx).new_bill_country := a136(indx);
          t(ddindx).new_bill_to_customer_number := a137(indx);
          t(ddindx).new_bill_to_customer := a138(indx);
          t(ddindx).old_ship_to_contact_number := a139(indx);
          t(ddindx).old_ship_to_contact := a140(indx);
          t(ddindx).new_ship_to_contact_number := a141(indx);
          t(ddindx).new_ship_to_contact := a142(indx);
          t(ddindx).old_bill_to_contact_number := a143(indx);
          t(ddindx).old_bill_to_contact := a144(indx);
          t(ddindx).new_bill_to_contact_number := a145(indx);
          t(ddindx).new_bill_to_contact := a146(indx);
          t(ddindx).old_technical_contact_number := a147(indx);
          t(ddindx).old_technical_contact := a148(indx);
          t(ddindx).new_technical_contact_number := a149(indx);
          t(ddindx).new_technical_contact := a150(indx);
          t(ddindx).old_serv_admin_contact_number := a151(indx);
          t(ddindx).old_serv_admin_contact := a152(indx);
          t(ddindx).new_serv_admin_contact_number := a153(indx);
          t(ddindx).new_serv_admin_contact := a154(indx);
          t(ddindx).old_operating_unit_name := a155(indx);
          t(ddindx).new_operating_unit_name := a156(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t csi_datastructures_pub.systems_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_100
    , a87 out nocopy JTF_VARCHAR2_TABLE_400
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_VARCHAR2_TABLE_100
    , a95 out nocopy JTF_VARCHAR2_TABLE_100
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_400
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_100
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_VARCHAR2_TABLE_100
    , a107 out nocopy JTF_VARCHAR2_TABLE_100
    , a108 out nocopy JTF_VARCHAR2_TABLE_400
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_VARCHAR2_TABLE_300
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_100
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
    , a115 out nocopy JTF_VARCHAR2_TABLE_100
    , a116 out nocopy JTF_VARCHAR2_TABLE_100
    , a117 out nocopy JTF_VARCHAR2_TABLE_100
    , a118 out nocopy JTF_VARCHAR2_TABLE_400
    , a119 out nocopy JTF_VARCHAR2_TABLE_300
    , a120 out nocopy JTF_VARCHAR2_TABLE_300
    , a121 out nocopy JTF_VARCHAR2_TABLE_300
    , a122 out nocopy JTF_VARCHAR2_TABLE_300
    , a123 out nocopy JTF_VARCHAR2_TABLE_100
    , a124 out nocopy JTF_VARCHAR2_TABLE_100
    , a125 out nocopy JTF_VARCHAR2_TABLE_100
    , a126 out nocopy JTF_VARCHAR2_TABLE_100
    , a127 out nocopy JTF_VARCHAR2_TABLE_100
    , a128 out nocopy JTF_VARCHAR2_TABLE_400
    , a129 out nocopy JTF_VARCHAR2_TABLE_300
    , a130 out nocopy JTF_VARCHAR2_TABLE_300
    , a131 out nocopy JTF_VARCHAR2_TABLE_300
    , a132 out nocopy JTF_VARCHAR2_TABLE_300
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_VARCHAR2_TABLE_100
    , a136 out nocopy JTF_VARCHAR2_TABLE_100
    , a137 out nocopy JTF_VARCHAR2_TABLE_100
    , a138 out nocopy JTF_VARCHAR2_TABLE_400
    , a139 out nocopy JTF_VARCHAR2_TABLE_100
    , a140 out nocopy JTF_VARCHAR2_TABLE_400
    , a141 out nocopy JTF_VARCHAR2_TABLE_100
    , a142 out nocopy JTF_VARCHAR2_TABLE_400
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
    , a144 out nocopy JTF_VARCHAR2_TABLE_400
    , a145 out nocopy JTF_VARCHAR2_TABLE_100
    , a146 out nocopy JTF_VARCHAR2_TABLE_400
    , a147 out nocopy JTF_VARCHAR2_TABLE_100
    , a148 out nocopy JTF_VARCHAR2_TABLE_400
    , a149 out nocopy JTF_VARCHAR2_TABLE_100
    , a150 out nocopy JTF_VARCHAR2_TABLE_400
    , a151 out nocopy JTF_VARCHAR2_TABLE_100
    , a152 out nocopy JTF_VARCHAR2_TABLE_400
    , a153 out nocopy JTF_VARCHAR2_TABLE_100
    , a154 out nocopy JTF_VARCHAR2_TABLE_400
    , a155 out nocopy JTF_VARCHAR2_TABLE_100
    , a156 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_400();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_VARCHAR2_TABLE_100();
    a95 := JTF_VARCHAR2_TABLE_100();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_400();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_100();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_VARCHAR2_TABLE_400();
    a109 := JTF_VARCHAR2_TABLE_300();
    a110 := JTF_VARCHAR2_TABLE_300();
    a111 := JTF_VARCHAR2_TABLE_300();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_100();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_100();
    a117 := JTF_VARCHAR2_TABLE_100();
    a118 := JTF_VARCHAR2_TABLE_400();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_300();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_100();
    a124 := JTF_VARCHAR2_TABLE_100();
    a125 := JTF_VARCHAR2_TABLE_100();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_100();
    a128 := JTF_VARCHAR2_TABLE_400();
    a129 := JTF_VARCHAR2_TABLE_300();
    a130 := JTF_VARCHAR2_TABLE_300();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_300();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_VARCHAR2_TABLE_100();
    a136 := JTF_VARCHAR2_TABLE_100();
    a137 := JTF_VARCHAR2_TABLE_100();
    a138 := JTF_VARCHAR2_TABLE_400();
    a139 := JTF_VARCHAR2_TABLE_100();
    a140 := JTF_VARCHAR2_TABLE_400();
    a141 := JTF_VARCHAR2_TABLE_100();
    a142 := JTF_VARCHAR2_TABLE_400();
    a143 := JTF_VARCHAR2_TABLE_100();
    a144 := JTF_VARCHAR2_TABLE_400();
    a145 := JTF_VARCHAR2_TABLE_100();
    a146 := JTF_VARCHAR2_TABLE_400();
    a147 := JTF_VARCHAR2_TABLE_100();
    a148 := JTF_VARCHAR2_TABLE_400();
    a149 := JTF_VARCHAR2_TABLE_100();
    a150 := JTF_VARCHAR2_TABLE_400();
    a151 := JTF_VARCHAR2_TABLE_100();
    a152 := JTF_VARCHAR2_TABLE_400();
    a153 := JTF_VARCHAR2_TABLE_100();
    a154 := JTF_VARCHAR2_TABLE_400();
    a155 := JTF_VARCHAR2_TABLE_100();
    a156 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_400();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_VARCHAR2_TABLE_100();
      a95 := JTF_VARCHAR2_TABLE_100();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_400();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_100();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_VARCHAR2_TABLE_400();
      a109 := JTF_VARCHAR2_TABLE_300();
      a110 := JTF_VARCHAR2_TABLE_300();
      a111 := JTF_VARCHAR2_TABLE_300();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_100();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_100();
      a117 := JTF_VARCHAR2_TABLE_100();
      a118 := JTF_VARCHAR2_TABLE_400();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_300();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_100();
      a124 := JTF_VARCHAR2_TABLE_100();
      a125 := JTF_VARCHAR2_TABLE_100();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_100();
      a128 := JTF_VARCHAR2_TABLE_400();
      a129 := JTF_VARCHAR2_TABLE_300();
      a130 := JTF_VARCHAR2_TABLE_300();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_300();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_VARCHAR2_TABLE_100();
      a136 := JTF_VARCHAR2_TABLE_100();
      a137 := JTF_VARCHAR2_TABLE_100();
      a138 := JTF_VARCHAR2_TABLE_400();
      a139 := JTF_VARCHAR2_TABLE_100();
      a140 := JTF_VARCHAR2_TABLE_400();
      a141 := JTF_VARCHAR2_TABLE_100();
      a142 := JTF_VARCHAR2_TABLE_400();
      a143 := JTF_VARCHAR2_TABLE_100();
      a144 := JTF_VARCHAR2_TABLE_400();
      a145 := JTF_VARCHAR2_TABLE_100();
      a146 := JTF_VARCHAR2_TABLE_400();
      a147 := JTF_VARCHAR2_TABLE_100();
      a148 := JTF_VARCHAR2_TABLE_400();
      a149 := JTF_VARCHAR2_TABLE_100();
      a150 := JTF_VARCHAR2_TABLE_400();
      a151 := JTF_VARCHAR2_TABLE_100();
      a152 := JTF_VARCHAR2_TABLE_400();
      a153 := JTF_VARCHAR2_TABLE_100();
      a154 := JTF_VARCHAR2_TABLE_400();
      a155 := JTF_VARCHAR2_TABLE_100();
      a156 := JTF_VARCHAR2_TABLE_100();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).system_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).old_customer_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).new_customer_id);
          a5(indx) := t(ddindx).old_system_type_code;
          a6(indx) := t(ddindx).new_system_type_code;
          a7(indx) := t(ddindx).old_system_number;
          a8(indx) := t(ddindx).new_system_number;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).old_parent_system_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).new_parent_system_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).old_ship_to_contact_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).new_ship_to_contact_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).old_bill_to_contact_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).new_bill_to_contact_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).old_technical_contact_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).new_technical_contact_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).old_service_admin_contact_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).new_service_admin_contact_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).old_ship_to_site_use_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).new_ship_to_site_use_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).old_install_site_use_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).new_install_site_use_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).old_bill_to_site_use_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).new_bill_to_site_use_id);
          a25(indx) := t(ddindx).old_coterminate_day_month;
          a26(indx) := t(ddindx).new_coterminate_day_month;
          a27(indx) := t(ddindx).old_start_date_active;
          a28(indx) := t(ddindx).new_start_date_active;
          a29(indx) := t(ddindx).old_end_date_active;
          a30(indx) := t(ddindx).new_end_date_active;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).old_autocreated_from_system);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).new_autocreated_from_system);
          a33(indx) := t(ddindx).old_config_system_type;
          a34(indx) := t(ddindx).new_config_system_type;
          a35(indx) := t(ddindx).old_context;
          a36(indx) := t(ddindx).new_context;
          a37(indx) := t(ddindx).old_attribute1;
          a38(indx) := t(ddindx).new_attribute1;
          a39(indx) := t(ddindx).old_attribute2;
          a40(indx) := t(ddindx).new_attribute2;
          a41(indx) := t(ddindx).old_attribute3;
          a42(indx) := t(ddindx).new_attribute3;
          a43(indx) := t(ddindx).old_attribute4;
          a44(indx) := t(ddindx).new_attribute4;
          a45(indx) := t(ddindx).old_attribute5;
          a46(indx) := t(ddindx).new_attribute5;
          a47(indx) := t(ddindx).old_attribute6;
          a48(indx) := t(ddindx).new_attribute6;
          a49(indx) := t(ddindx).old_attribute7;
          a50(indx) := t(ddindx).new_attribute7;
          a51(indx) := t(ddindx).old_attribute8;
          a52(indx) := t(ddindx).new_attribute8;
          a53(indx) := t(ddindx).old_attribute9;
          a54(indx) := t(ddindx).new_attribute9;
          a55(indx) := t(ddindx).old_attribute10;
          a56(indx) := t(ddindx).new_attribute10;
          a57(indx) := t(ddindx).old_attribute11;
          a58(indx) := t(ddindx).new_attribute11;
          a59(indx) := t(ddindx).old_attribute12;
          a60(indx) := t(ddindx).new_attribute12;
          a61(indx) := t(ddindx).old_attribute13;
          a62(indx) := t(ddindx).new_attribute13;
          a63(indx) := t(ddindx).old_attribute14;
          a64(indx) := t(ddindx).new_attribute14;
          a65(indx) := t(ddindx).old_attribute15;
          a66(indx) := t(ddindx).new_attribute15;
          a67(indx) := t(ddindx).full_dump_flag;
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a69(indx) := t(ddindx).old_name;
          a70(indx) := t(ddindx).new_name;
          a71(indx) := t(ddindx).old_description;
          a72(indx) := t(ddindx).new_description;
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).old_operating_unit_id);
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).new_operating_unit_id);
          a75(indx) := t(ddindx).old_system_type;
          a76(indx) := t(ddindx).new_system_type;
          a77(indx) := t(ddindx).old_parent_name;
          a78(indx) := t(ddindx).new_parent_name;
          a79(indx) := t(ddindx).old_ship_to_address1;
          a80(indx) := t(ddindx).old_ship_to_address2;
          a81(indx) := t(ddindx).old_ship_to_address3;
          a82(indx) := t(ddindx).old_ship_to_address4;
          a83(indx) := t(ddindx).old_ship_to_location;
          a84(indx) := t(ddindx).old_ship_state;
          a85(indx) := t(ddindx).old_ship_postal_code;
          a86(indx) := t(ddindx).old_ship_country;
          a87(indx) := t(ddindx).old_ship_to_customer;
          a88(indx) := t(ddindx).old_ship_to_customer_number;
          a89(indx) := t(ddindx).new_ship_to_address1;
          a90(indx) := t(ddindx).new_ship_to_address2;
          a91(indx) := t(ddindx).new_ship_to_address3;
          a92(indx) := t(ddindx).new_ship_to_address4;
          a93(indx) := t(ddindx).new_ship_to_location;
          a94(indx) := t(ddindx).new_ship_state;
          a95(indx) := t(ddindx).new_ship_postal_code;
          a96(indx) := t(ddindx).new_ship_country;
          a97(indx) := t(ddindx).new_ship_to_customer;
          a98(indx) := t(ddindx).new_ship_to_customer_number;
          a99(indx) := t(ddindx).old_install_address1;
          a100(indx) := t(ddindx).old_install_address2;
          a101(indx) := t(ddindx).old_install_address3;
          a102(indx) := t(ddindx).old_install_address4;
          a103(indx) := t(ddindx).old_install_location;
          a104(indx) := t(ddindx).old_install_state;
          a105(indx) := t(ddindx).old_install_postal_code;
          a106(indx) := t(ddindx).old_install_country;
          a107(indx) := t(ddindx).old_install_customer_number;
          a108(indx) := t(ddindx).old_install_customer;
          a109(indx) := t(ddindx).new_install_address1;
          a110(indx) := t(ddindx).new_install_address2;
          a111(indx) := t(ddindx).new_install_address3;
          a112(indx) := t(ddindx).new_install_address4;
          a113(indx) := t(ddindx).new_install_location;
          a114(indx) := t(ddindx).new_install_state;
          a115(indx) := t(ddindx).new_install_postal_code;
          a116(indx) := t(ddindx).new_install_country;
          a117(indx) := t(ddindx).new_install_customer_number;
          a118(indx) := t(ddindx).new_install_customer;
          a119(indx) := t(ddindx).old_bill_to_address1;
          a120(indx) := t(ddindx).old_bill_to_address2;
          a121(indx) := t(ddindx).old_bill_to_address3;
          a122(indx) := t(ddindx).old_bill_to_address4;
          a123(indx) := t(ddindx).old_bill_to_location;
          a124(indx) := t(ddindx).old_bill_state;
          a125(indx) := t(ddindx).old_bill_postal_code;
          a126(indx) := t(ddindx).old_bill_country;
          a127(indx) := t(ddindx).old_bill_to_customer_number;
          a128(indx) := t(ddindx).old_bill_to_customer;
          a129(indx) := t(ddindx).new_bill_to_address1;
          a130(indx) := t(ddindx).new_bill_to_address2;
          a131(indx) := t(ddindx).new_bill_to_address3;
          a132(indx) := t(ddindx).new_bill_to_address4;
          a133(indx) := t(ddindx).new_bill_to_location;
          a134(indx) := t(ddindx).new_bill_state;
          a135(indx) := t(ddindx).new_bill_postal_code;
          a136(indx) := t(ddindx).new_bill_country;
          a137(indx) := t(ddindx).new_bill_to_customer_number;
          a138(indx) := t(ddindx).new_bill_to_customer;
          a139(indx) := t(ddindx).old_ship_to_contact_number;
          a140(indx) := t(ddindx).old_ship_to_contact;
          a141(indx) := t(ddindx).new_ship_to_contact_number;
          a142(indx) := t(ddindx).new_ship_to_contact;
          a143(indx) := t(ddindx).old_bill_to_contact_number;
          a144(indx) := t(ddindx).old_bill_to_contact;
          a145(indx) := t(ddindx).new_bill_to_contact_number;
          a146(indx) := t(ddindx).new_bill_to_contact;
          a147(indx) := t(ddindx).old_technical_contact_number;
          a148(indx) := t(ddindx).old_technical_contact;
          a149(indx) := t(ddindx).new_technical_contact_number;
          a150(indx) := t(ddindx).new_technical_contact;
          a151(indx) := t(ddindx).old_serv_admin_contact_number;
          a152(indx) := t(ddindx).old_serv_admin_contact;
          a153(indx) := t(ddindx).new_serv_admin_contact_number;
          a154(indx) := t(ddindx).new_serv_admin_contact;
          a155(indx) := t(ddindx).old_operating_unit_name;
          a156(indx) := t(ddindx).new_operating_unit_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p41(t out nocopy csi_datastructures_pub.extend_attrib_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a28 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).attribute_level := a1(indx);
          t(ddindx).master_organization_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).item_category_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).attribute_code := a6(indx);
          t(ddindx).attribute_name := a7(indx);
          t(ddindx).attribute_category := a8(indx);
          t(ddindx).description := a9(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).context := a12(indx);
          t(ddindx).attribute1 := a13(indx);
          t(ddindx).attribute2 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).attribute10 := a22(indx);
          t(ddindx).attribute11 := a23(indx);
          t(ddindx).attribute12 := a24(indx);
          t(ddindx).attribute13 := a25(indx);
          t(ddindx).attribute14 := a26(indx);
          t(ddindx).attribute15 := a27(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a28(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t csi_datastructures_pub.extend_attrib_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a28 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a28 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a28 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a1(indx) := t(ddindx).attribute_level;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).master_organization_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).item_category_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a6(indx) := t(ddindx).attribute_code;
          a7(indx) := t(ddindx).attribute_name;
          a8(indx) := t(ddindx).attribute_category;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).active_start_date;
          a11(indx) := t(ddindx).active_end_date;
          a12(indx) := t(ddindx).context;
          a13(indx) := t(ddindx).attribute1;
          a14(indx) := t(ddindx).attribute2;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).attribute10;
          a23(indx) := t(ddindx).attribute11;
          a24(indx) := t(ddindx).attribute12;
          a25(indx) := t(ddindx).attribute13;
          a26(indx) := t(ddindx).attribute14;
          a27(indx) := t(ddindx).attribute15;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p43(t out nocopy csi_datastructures_pub.extend_attrib_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).attribute_code := a3(indx);
          t(ddindx).attribute_value := a4(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).context := a7(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a24(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t csi_datastructures_pub.extend_attrib_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a23 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_value_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a3(indx) := t(ddindx).attribute_code;
          a4(indx) := t(ddindx).attribute_value;
          a5(indx) := t(ddindx).active_start_date;
          a6(indx) := t(ddindx).active_end_date;
          a7(indx) := t(ddindx).context;
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
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p46(t out nocopy csi_datastructures_pub.pricing_attribs_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
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
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_200
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_VARCHAR2_TABLE_200
    , a94 JTF_VARCHAR2_TABLE_200
    , a95 JTF_VARCHAR2_TABLE_200
    , a96 JTF_VARCHAR2_TABLE_200
    , a97 JTF_VARCHAR2_TABLE_200
    , a98 JTF_VARCHAR2_TABLE_200
    , a99 JTF_VARCHAR2_TABLE_200
    , a100 JTF_VARCHAR2_TABLE_200
    , a101 JTF_VARCHAR2_TABLE_200
    , a102 JTF_VARCHAR2_TABLE_200
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_200
    , a107 JTF_VARCHAR2_TABLE_200
    , a108 JTF_VARCHAR2_TABLE_200
    , a109 JTF_VARCHAR2_TABLE_200
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_200
    , a115 JTF_VARCHAR2_TABLE_200
    , a116 JTF_VARCHAR2_TABLE_200
    , a117 JTF_VARCHAR2_TABLE_200
    , a118 JTF_VARCHAR2_TABLE_200
    , a119 JTF_VARCHAR2_TABLE_200
    , a120 JTF_VARCHAR2_TABLE_200
    , a121 JTF_NUMBER_TABLE
    , a122 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pricing_attribute_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).pricing_context := a4(indx);
          t(ddindx).pricing_attribute1 := a5(indx);
          t(ddindx).pricing_attribute2 := a6(indx);
          t(ddindx).pricing_attribute3 := a7(indx);
          t(ddindx).pricing_attribute4 := a8(indx);
          t(ddindx).pricing_attribute5 := a9(indx);
          t(ddindx).pricing_attribute6 := a10(indx);
          t(ddindx).pricing_attribute7 := a11(indx);
          t(ddindx).pricing_attribute8 := a12(indx);
          t(ddindx).pricing_attribute9 := a13(indx);
          t(ddindx).pricing_attribute10 := a14(indx);
          t(ddindx).pricing_attribute11 := a15(indx);
          t(ddindx).pricing_attribute12 := a16(indx);
          t(ddindx).pricing_attribute13 := a17(indx);
          t(ddindx).pricing_attribute14 := a18(indx);
          t(ddindx).pricing_attribute15 := a19(indx);
          t(ddindx).pricing_attribute16 := a20(indx);
          t(ddindx).pricing_attribute17 := a21(indx);
          t(ddindx).pricing_attribute18 := a22(indx);
          t(ddindx).pricing_attribute19 := a23(indx);
          t(ddindx).pricing_attribute20 := a24(indx);
          t(ddindx).pricing_attribute21 := a25(indx);
          t(ddindx).pricing_attribute22 := a26(indx);
          t(ddindx).pricing_attribute23 := a27(indx);
          t(ddindx).pricing_attribute24 := a28(indx);
          t(ddindx).pricing_attribute25 := a29(indx);
          t(ddindx).pricing_attribute26 := a30(indx);
          t(ddindx).pricing_attribute27 := a31(indx);
          t(ddindx).pricing_attribute28 := a32(indx);
          t(ddindx).pricing_attribute29 := a33(indx);
          t(ddindx).pricing_attribute30 := a34(indx);
          t(ddindx).pricing_attribute31 := a35(indx);
          t(ddindx).pricing_attribute32 := a36(indx);
          t(ddindx).pricing_attribute33 := a37(indx);
          t(ddindx).pricing_attribute34 := a38(indx);
          t(ddindx).pricing_attribute35 := a39(indx);
          t(ddindx).pricing_attribute36 := a40(indx);
          t(ddindx).pricing_attribute37 := a41(indx);
          t(ddindx).pricing_attribute38 := a42(indx);
          t(ddindx).pricing_attribute39 := a43(indx);
          t(ddindx).pricing_attribute40 := a44(indx);
          t(ddindx).pricing_attribute41 := a45(indx);
          t(ddindx).pricing_attribute42 := a46(indx);
          t(ddindx).pricing_attribute43 := a47(indx);
          t(ddindx).pricing_attribute44 := a48(indx);
          t(ddindx).pricing_attribute45 := a49(indx);
          t(ddindx).pricing_attribute46 := a50(indx);
          t(ddindx).pricing_attribute47 := a51(indx);
          t(ddindx).pricing_attribute48 := a52(indx);
          t(ddindx).pricing_attribute49 := a53(indx);
          t(ddindx).pricing_attribute50 := a54(indx);
          t(ddindx).pricing_attribute51 := a55(indx);
          t(ddindx).pricing_attribute52 := a56(indx);
          t(ddindx).pricing_attribute53 := a57(indx);
          t(ddindx).pricing_attribute54 := a58(indx);
          t(ddindx).pricing_attribute55 := a59(indx);
          t(ddindx).pricing_attribute56 := a60(indx);
          t(ddindx).pricing_attribute57 := a61(indx);
          t(ddindx).pricing_attribute58 := a62(indx);
          t(ddindx).pricing_attribute59 := a63(indx);
          t(ddindx).pricing_attribute60 := a64(indx);
          t(ddindx).pricing_attribute61 := a65(indx);
          t(ddindx).pricing_attribute62 := a66(indx);
          t(ddindx).pricing_attribute63 := a67(indx);
          t(ddindx).pricing_attribute64 := a68(indx);
          t(ddindx).pricing_attribute65 := a69(indx);
          t(ddindx).pricing_attribute66 := a70(indx);
          t(ddindx).pricing_attribute67 := a71(indx);
          t(ddindx).pricing_attribute68 := a72(indx);
          t(ddindx).pricing_attribute69 := a73(indx);
          t(ddindx).pricing_attribute70 := a74(indx);
          t(ddindx).pricing_attribute71 := a75(indx);
          t(ddindx).pricing_attribute72 := a76(indx);
          t(ddindx).pricing_attribute73 := a77(indx);
          t(ddindx).pricing_attribute74 := a78(indx);
          t(ddindx).pricing_attribute75 := a79(indx);
          t(ddindx).pricing_attribute76 := a80(indx);
          t(ddindx).pricing_attribute77 := a81(indx);
          t(ddindx).pricing_attribute78 := a82(indx);
          t(ddindx).pricing_attribute79 := a83(indx);
          t(ddindx).pricing_attribute80 := a84(indx);
          t(ddindx).pricing_attribute81 := a85(indx);
          t(ddindx).pricing_attribute82 := a86(indx);
          t(ddindx).pricing_attribute83 := a87(indx);
          t(ddindx).pricing_attribute84 := a88(indx);
          t(ddindx).pricing_attribute85 := a89(indx);
          t(ddindx).pricing_attribute86 := a90(indx);
          t(ddindx).pricing_attribute87 := a91(indx);
          t(ddindx).pricing_attribute88 := a92(indx);
          t(ddindx).pricing_attribute89 := a93(indx);
          t(ddindx).pricing_attribute90 := a94(indx);
          t(ddindx).pricing_attribute91 := a95(indx);
          t(ddindx).pricing_attribute92 := a96(indx);
          t(ddindx).pricing_attribute93 := a97(indx);
          t(ddindx).pricing_attribute94 := a98(indx);
          t(ddindx).pricing_attribute95 := a99(indx);
          t(ddindx).pricing_attribute96 := a100(indx);
          t(ddindx).pricing_attribute97 := a101(indx);
          t(ddindx).pricing_attribute98 := a102(indx);
          t(ddindx).pricing_attribute99 := a103(indx);
          t(ddindx).pricing_attribute100 := a104(indx);
          t(ddindx).context := a105(indx);
          t(ddindx).attribute1 := a106(indx);
          t(ddindx).attribute2 := a107(indx);
          t(ddindx).attribute3 := a108(indx);
          t(ddindx).attribute4 := a109(indx);
          t(ddindx).attribute5 := a110(indx);
          t(ddindx).attribute6 := a111(indx);
          t(ddindx).attribute7 := a112(indx);
          t(ddindx).attribute8 := a113(indx);
          t(ddindx).attribute9 := a114(indx);
          t(ddindx).attribute10 := a115(indx);
          t(ddindx).attribute11 := a116(indx);
          t(ddindx).attribute12 := a117(indx);
          t(ddindx).attribute13 := a118(indx);
          t(ddindx).attribute14 := a119(indx);
          t(ddindx).attribute15 := a120(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a121(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a122(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p46;
  procedure rosetta_table_copy_out_p46(t csi_datastructures_pub.pricing_attribs_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_VARCHAR2_TABLE_200
    , a94 out nocopy JTF_VARCHAR2_TABLE_200
    , a95 out nocopy JTF_VARCHAR2_TABLE_200
    , a96 out nocopy JTF_VARCHAR2_TABLE_200
    , a97 out nocopy JTF_VARCHAR2_TABLE_200
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
    , a99 out nocopy JTF_VARCHAR2_TABLE_200
    , a100 out nocopy JTF_VARCHAR2_TABLE_200
    , a101 out nocopy JTF_VARCHAR2_TABLE_200
    , a102 out nocopy JTF_VARCHAR2_TABLE_200
    , a103 out nocopy JTF_VARCHAR2_TABLE_200
    , a104 out nocopy JTF_VARCHAR2_TABLE_200
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_VARCHAR2_TABLE_200
    , a107 out nocopy JTF_VARCHAR2_TABLE_200
    , a108 out nocopy JTF_VARCHAR2_TABLE_200
    , a109 out nocopy JTF_VARCHAR2_TABLE_200
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_200
    , a115 out nocopy JTF_VARCHAR2_TABLE_200
    , a116 out nocopy JTF_VARCHAR2_TABLE_200
    , a117 out nocopy JTF_VARCHAR2_TABLE_200
    , a118 out nocopy JTF_VARCHAR2_TABLE_200
    , a119 out nocopy JTF_VARCHAR2_TABLE_200
    , a120 out nocopy JTF_VARCHAR2_TABLE_200
    , a121 out nocopy JTF_NUMBER_TABLE
    , a122 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
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
    a81 := JTF_VARCHAR2_TABLE_200();
    a82 := JTF_VARCHAR2_TABLE_200();
    a83 := JTF_VARCHAR2_TABLE_200();
    a84 := JTF_VARCHAR2_TABLE_200();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_200();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_200();
    a90 := JTF_VARCHAR2_TABLE_200();
    a91 := JTF_VARCHAR2_TABLE_200();
    a92 := JTF_VARCHAR2_TABLE_200();
    a93 := JTF_VARCHAR2_TABLE_200();
    a94 := JTF_VARCHAR2_TABLE_200();
    a95 := JTF_VARCHAR2_TABLE_200();
    a96 := JTF_VARCHAR2_TABLE_200();
    a97 := JTF_VARCHAR2_TABLE_200();
    a98 := JTF_VARCHAR2_TABLE_200();
    a99 := JTF_VARCHAR2_TABLE_200();
    a100 := JTF_VARCHAR2_TABLE_200();
    a101 := JTF_VARCHAR2_TABLE_200();
    a102 := JTF_VARCHAR2_TABLE_200();
    a103 := JTF_VARCHAR2_TABLE_200();
    a104 := JTF_VARCHAR2_TABLE_200();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_200();
    a107 := JTF_VARCHAR2_TABLE_200();
    a108 := JTF_VARCHAR2_TABLE_200();
    a109 := JTF_VARCHAR2_TABLE_200();
    a110 := JTF_VARCHAR2_TABLE_200();
    a111 := JTF_VARCHAR2_TABLE_200();
    a112 := JTF_VARCHAR2_TABLE_200();
    a113 := JTF_VARCHAR2_TABLE_200();
    a114 := JTF_VARCHAR2_TABLE_200();
    a115 := JTF_VARCHAR2_TABLE_200();
    a116 := JTF_VARCHAR2_TABLE_200();
    a117 := JTF_VARCHAR2_TABLE_200();
    a118 := JTF_VARCHAR2_TABLE_200();
    a119 := JTF_VARCHAR2_TABLE_200();
    a120 := JTF_VARCHAR2_TABLE_200();
    a121 := JTF_NUMBER_TABLE();
    a122 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
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
      a81 := JTF_VARCHAR2_TABLE_200();
      a82 := JTF_VARCHAR2_TABLE_200();
      a83 := JTF_VARCHAR2_TABLE_200();
      a84 := JTF_VARCHAR2_TABLE_200();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_200();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_200();
      a90 := JTF_VARCHAR2_TABLE_200();
      a91 := JTF_VARCHAR2_TABLE_200();
      a92 := JTF_VARCHAR2_TABLE_200();
      a93 := JTF_VARCHAR2_TABLE_200();
      a94 := JTF_VARCHAR2_TABLE_200();
      a95 := JTF_VARCHAR2_TABLE_200();
      a96 := JTF_VARCHAR2_TABLE_200();
      a97 := JTF_VARCHAR2_TABLE_200();
      a98 := JTF_VARCHAR2_TABLE_200();
      a99 := JTF_VARCHAR2_TABLE_200();
      a100 := JTF_VARCHAR2_TABLE_200();
      a101 := JTF_VARCHAR2_TABLE_200();
      a102 := JTF_VARCHAR2_TABLE_200();
      a103 := JTF_VARCHAR2_TABLE_200();
      a104 := JTF_VARCHAR2_TABLE_200();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_200();
      a107 := JTF_VARCHAR2_TABLE_200();
      a108 := JTF_VARCHAR2_TABLE_200();
      a109 := JTF_VARCHAR2_TABLE_200();
      a110 := JTF_VARCHAR2_TABLE_200();
      a111 := JTF_VARCHAR2_TABLE_200();
      a112 := JTF_VARCHAR2_TABLE_200();
      a113 := JTF_VARCHAR2_TABLE_200();
      a114 := JTF_VARCHAR2_TABLE_200();
      a115 := JTF_VARCHAR2_TABLE_200();
      a116 := JTF_VARCHAR2_TABLE_200();
      a117 := JTF_VARCHAR2_TABLE_200();
      a118 := JTF_VARCHAR2_TABLE_200();
      a119 := JTF_VARCHAR2_TABLE_200();
      a120 := JTF_VARCHAR2_TABLE_200();
      a121 := JTF_NUMBER_TABLE();
      a122 := JTF_NUMBER_TABLE();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_attribute_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := t(ddindx).active_start_date;
          a3(indx) := t(ddindx).active_end_date;
          a4(indx) := t(ddindx).pricing_context;
          a5(indx) := t(ddindx).pricing_attribute1;
          a6(indx) := t(ddindx).pricing_attribute2;
          a7(indx) := t(ddindx).pricing_attribute3;
          a8(indx) := t(ddindx).pricing_attribute4;
          a9(indx) := t(ddindx).pricing_attribute5;
          a10(indx) := t(ddindx).pricing_attribute6;
          a11(indx) := t(ddindx).pricing_attribute7;
          a12(indx) := t(ddindx).pricing_attribute8;
          a13(indx) := t(ddindx).pricing_attribute9;
          a14(indx) := t(ddindx).pricing_attribute10;
          a15(indx) := t(ddindx).pricing_attribute11;
          a16(indx) := t(ddindx).pricing_attribute12;
          a17(indx) := t(ddindx).pricing_attribute13;
          a18(indx) := t(ddindx).pricing_attribute14;
          a19(indx) := t(ddindx).pricing_attribute15;
          a20(indx) := t(ddindx).pricing_attribute16;
          a21(indx) := t(ddindx).pricing_attribute17;
          a22(indx) := t(ddindx).pricing_attribute18;
          a23(indx) := t(ddindx).pricing_attribute19;
          a24(indx) := t(ddindx).pricing_attribute20;
          a25(indx) := t(ddindx).pricing_attribute21;
          a26(indx) := t(ddindx).pricing_attribute22;
          a27(indx) := t(ddindx).pricing_attribute23;
          a28(indx) := t(ddindx).pricing_attribute24;
          a29(indx) := t(ddindx).pricing_attribute25;
          a30(indx) := t(ddindx).pricing_attribute26;
          a31(indx) := t(ddindx).pricing_attribute27;
          a32(indx) := t(ddindx).pricing_attribute28;
          a33(indx) := t(ddindx).pricing_attribute29;
          a34(indx) := t(ddindx).pricing_attribute30;
          a35(indx) := t(ddindx).pricing_attribute31;
          a36(indx) := t(ddindx).pricing_attribute32;
          a37(indx) := t(ddindx).pricing_attribute33;
          a38(indx) := t(ddindx).pricing_attribute34;
          a39(indx) := t(ddindx).pricing_attribute35;
          a40(indx) := t(ddindx).pricing_attribute36;
          a41(indx) := t(ddindx).pricing_attribute37;
          a42(indx) := t(ddindx).pricing_attribute38;
          a43(indx) := t(ddindx).pricing_attribute39;
          a44(indx) := t(ddindx).pricing_attribute40;
          a45(indx) := t(ddindx).pricing_attribute41;
          a46(indx) := t(ddindx).pricing_attribute42;
          a47(indx) := t(ddindx).pricing_attribute43;
          a48(indx) := t(ddindx).pricing_attribute44;
          a49(indx) := t(ddindx).pricing_attribute45;
          a50(indx) := t(ddindx).pricing_attribute46;
          a51(indx) := t(ddindx).pricing_attribute47;
          a52(indx) := t(ddindx).pricing_attribute48;
          a53(indx) := t(ddindx).pricing_attribute49;
          a54(indx) := t(ddindx).pricing_attribute50;
          a55(indx) := t(ddindx).pricing_attribute51;
          a56(indx) := t(ddindx).pricing_attribute52;
          a57(indx) := t(ddindx).pricing_attribute53;
          a58(indx) := t(ddindx).pricing_attribute54;
          a59(indx) := t(ddindx).pricing_attribute55;
          a60(indx) := t(ddindx).pricing_attribute56;
          a61(indx) := t(ddindx).pricing_attribute57;
          a62(indx) := t(ddindx).pricing_attribute58;
          a63(indx) := t(ddindx).pricing_attribute59;
          a64(indx) := t(ddindx).pricing_attribute60;
          a65(indx) := t(ddindx).pricing_attribute61;
          a66(indx) := t(ddindx).pricing_attribute62;
          a67(indx) := t(ddindx).pricing_attribute63;
          a68(indx) := t(ddindx).pricing_attribute64;
          a69(indx) := t(ddindx).pricing_attribute65;
          a70(indx) := t(ddindx).pricing_attribute66;
          a71(indx) := t(ddindx).pricing_attribute67;
          a72(indx) := t(ddindx).pricing_attribute68;
          a73(indx) := t(ddindx).pricing_attribute69;
          a74(indx) := t(ddindx).pricing_attribute70;
          a75(indx) := t(ddindx).pricing_attribute71;
          a76(indx) := t(ddindx).pricing_attribute72;
          a77(indx) := t(ddindx).pricing_attribute73;
          a78(indx) := t(ddindx).pricing_attribute74;
          a79(indx) := t(ddindx).pricing_attribute75;
          a80(indx) := t(ddindx).pricing_attribute76;
          a81(indx) := t(ddindx).pricing_attribute77;
          a82(indx) := t(ddindx).pricing_attribute78;
          a83(indx) := t(ddindx).pricing_attribute79;
          a84(indx) := t(ddindx).pricing_attribute80;
          a85(indx) := t(ddindx).pricing_attribute81;
          a86(indx) := t(ddindx).pricing_attribute82;
          a87(indx) := t(ddindx).pricing_attribute83;
          a88(indx) := t(ddindx).pricing_attribute84;
          a89(indx) := t(ddindx).pricing_attribute85;
          a90(indx) := t(ddindx).pricing_attribute86;
          a91(indx) := t(ddindx).pricing_attribute87;
          a92(indx) := t(ddindx).pricing_attribute88;
          a93(indx) := t(ddindx).pricing_attribute89;
          a94(indx) := t(ddindx).pricing_attribute90;
          a95(indx) := t(ddindx).pricing_attribute91;
          a96(indx) := t(ddindx).pricing_attribute92;
          a97(indx) := t(ddindx).pricing_attribute93;
          a98(indx) := t(ddindx).pricing_attribute94;
          a99(indx) := t(ddindx).pricing_attribute95;
          a100(indx) := t(ddindx).pricing_attribute96;
          a101(indx) := t(ddindx).pricing_attribute97;
          a102(indx) := t(ddindx).pricing_attribute98;
          a103(indx) := t(ddindx).pricing_attribute99;
          a104(indx) := t(ddindx).pricing_attribute100;
          a105(indx) := t(ddindx).context;
          a106(indx) := t(ddindx).attribute1;
          a107(indx) := t(ddindx).attribute2;
          a108(indx) := t(ddindx).attribute3;
          a109(indx) := t(ddindx).attribute4;
          a110(indx) := t(ddindx).attribute5;
          a111(indx) := t(ddindx).attribute6;
          a112(indx) := t(ddindx).attribute7;
          a113(indx) := t(ddindx).attribute8;
          a114(indx) := t(ddindx).attribute9;
          a115(indx) := t(ddindx).attribute10;
          a116(indx) := t(ddindx).attribute11;
          a117(indx) := t(ddindx).attribute12;
          a118(indx) := t(ddindx).attribute13;
          a119(indx) := t(ddindx).attribute14;
          a120(indx) := t(ddindx).attribute15;
          a121(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a122(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p46;

  procedure rosetta_table_copy_in_p49(t out nocopy csi_datastructures_pub.organization_units_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
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
          t(ddindx).instance_ou_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).operating_unit_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).relationship_type_code := a3(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).context := a6(indx);
          t(ddindx).attribute1 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).attribute10 := a16(indx);
          t(ddindx).attribute11 := a17(indx);
          t(ddindx).attribute12 := a18(indx);
          t(ddindx).attribute13 := a19(indx);
          t(ddindx).attribute14 := a20(indx);
          t(ddindx).attribute15 := a21(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a23(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p49;
  procedure rosetta_table_copy_out_p49(t csi_datastructures_pub.organization_units_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_ou_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).operating_unit_id);
          a3(indx) := t(ddindx).relationship_type_code;
          a4(indx) := t(ddindx).active_start_date;
          a5(indx) := t(ddindx).active_end_date;
          a6(indx) := t(ddindx).context;
          a7(indx) := t(ddindx).attribute1;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).attribute10;
          a17(indx) := t(ddindx).attribute11;
          a18(indx) := t(ddindx).attribute12;
          a19(indx) := t(ddindx).attribute13;
          a20(indx) := t(ddindx).attribute14;
          a21(indx) := t(ddindx).attribute15;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p49;

  procedure rosetta_table_copy_in_p52(t out nocopy csi_datastructures_pub.instance_asset_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).fa_asset_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).fa_book_type_code := a3(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).asset_quantity := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).update_status := a6(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).check_for_instance_expiry := a10(indx);
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).fa_sync_flag := a12(indx);
          t(ddindx).fa_mass_addition_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_complete_flag := a14(indx);
          t(ddindx).fa_sync_validation_reqd := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p52;
  procedure rosetta_table_copy_out_p52(t csi_datastructures_pub.instance_asset_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_asset_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).fa_asset_id);
          a3(indx) := t(ddindx).fa_book_type_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).asset_quantity);
          a6(indx) := t(ddindx).update_status;
          a7(indx) := t(ddindx).active_start_date;
          a8(indx) := t(ddindx).active_end_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := t(ddindx).check_for_instance_expiry;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a12(indx) := t(ddindx).fa_sync_flag;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).fa_mass_addition_id);
          a14(indx) := t(ddindx).creation_complete_flag;
          a15(indx) := t(ddindx).fa_sync_validation_reqd;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p52;

  procedure rosetta_table_copy_in_p55(t out nocopy csi_datastructures_pub.party_account_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ip_account_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_party_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).party_account_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).party_account_number := a3(indx);
          t(ddindx).party_account_name := a4(indx);
          t(ddindx).relationship_type_code := a5(indx);
          t(ddindx).bill_to_address := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).bill_to_location := a7(indx);
          t(ddindx).ship_to_address := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).ship_to_location := a9(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).context := a12(indx);
          t(ddindx).attribute1 := a13(indx);
          t(ddindx).attribute2 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).attribute10 := a22(indx);
          t(ddindx).attribute11 := a23(indx);
          t(ddindx).attribute12 := a24(indx);
          t(ddindx).attribute13 := a25(indx);
          t(ddindx).attribute14 := a26(indx);
          t(ddindx).attribute15 := a27(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).bill_to_address1 := a29(indx);
          t(ddindx).bill_to_address2 := a30(indx);
          t(ddindx).bill_to_address3 := a31(indx);
          t(ddindx).bill_to_address4 := a32(indx);
          t(ddindx).bill_to_city := a33(indx);
          t(ddindx).bill_to_state := a34(indx);
          t(ddindx).bill_to_postal_code := a35(indx);
          t(ddindx).bill_to_country := a36(indx);
          t(ddindx).ship_to_address1 := a37(indx);
          t(ddindx).ship_to_address2 := a38(indx);
          t(ddindx).ship_to_address3 := a39(indx);
          t(ddindx).ship_to_address4 := a40(indx);
          t(ddindx).ship_to_city := a41(indx);
          t(ddindx).ship_to_state := a42(indx);
          t(ddindx).ship_to_postal_code := a43(indx);
          t(ddindx).ship_to_country := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p55;
  procedure rosetta_table_copy_out_p55(t csi_datastructures_pub.party_account_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ip_account_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).party_account_id);
          a3(indx) := t(ddindx).party_account_number;
          a4(indx) := t(ddindx).party_account_name;
          a5(indx) := t(ddindx).relationship_type_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_address);
          a7(indx) := t(ddindx).bill_to_location;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_address);
          a9(indx) := t(ddindx).ship_to_location;
          a10(indx) := t(ddindx).active_start_date;
          a11(indx) := t(ddindx).active_end_date;
          a12(indx) := t(ddindx).context;
          a13(indx) := t(ddindx).attribute1;
          a14(indx) := t(ddindx).attribute2;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).attribute10;
          a23(indx) := t(ddindx).attribute11;
          a24(indx) := t(ddindx).attribute12;
          a25(indx) := t(ddindx).attribute13;
          a26(indx) := t(ddindx).attribute14;
          a27(indx) := t(ddindx).attribute15;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a29(indx) := t(ddindx).bill_to_address1;
          a30(indx) := t(ddindx).bill_to_address2;
          a31(indx) := t(ddindx).bill_to_address3;
          a32(indx) := t(ddindx).bill_to_address4;
          a33(indx) := t(ddindx).bill_to_city;
          a34(indx) := t(ddindx).bill_to_state;
          a35(indx) := t(ddindx).bill_to_postal_code;
          a36(indx) := t(ddindx).bill_to_country;
          a37(indx) := t(ddindx).ship_to_address1;
          a38(indx) := t(ddindx).ship_to_address2;
          a39(indx) := t(ddindx).ship_to_address3;
          a40(indx) := t(ddindx).ship_to_address4;
          a41(indx) := t(ddindx).ship_to_city;
          a42(indx) := t(ddindx).ship_to_state;
          a43(indx) := t(ddindx).ship_to_postal_code;
          a44(indx) := t(ddindx).ship_to_country;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p55;

  procedure rosetta_table_copy_in_p57(t out nocopy csi_datastructures_pub.org_units_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_ou_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).operating_unit_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).operating_unit_name := a3(indx);
          t(ddindx).relationship_type_code := a4(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).context := a7(indx);
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).relationship_type_name := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p57;
  procedure rosetta_table_copy_out_p57(t csi_datastructures_pub.org_units_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_ou_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).operating_unit_id);
          a3(indx) := t(ddindx).operating_unit_name;
          a4(indx) := t(ddindx).relationship_type_code;
          a5(indx) := t(ddindx).active_start_date;
          a6(indx) := t(ddindx).active_end_date;
          a7(indx) := t(ddindx).context;
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
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := t(ddindx).relationship_type_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p57;

  procedure rosetta_table_copy_in_p59(t out nocopy csi_datastructures_pub.instance_asset_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
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
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).fa_asset_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).fa_book_type_code := a3(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).asset_quantity := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).update_status := a6(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).asset_number := a10(indx);
          t(ddindx).serial_number := a11(indx);
          t(ddindx).tag_number := a12(indx);
          t(ddindx).category := a13(indx);
          t(ddindx).fa_location_segment1 := a14(indx);
          t(ddindx).fa_location_segment2 := a15(indx);
          t(ddindx).fa_location_segment3 := a16(indx);
          t(ddindx).fa_location_segment4 := a17(indx);
          t(ddindx).fa_location_segment5 := a18(indx);
          t(ddindx).fa_location_segment6 := a19(indx);
          t(ddindx).fa_location_segment7 := a20(indx);
          t(ddindx).date_placed_in_service := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).description := a22(indx);
          t(ddindx).employee_name := a23(indx);
          t(ddindx).expense_account_number := a24(indx);
          t(ddindx).fa_mass_addition_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_complete_flag := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p59;
  procedure rosetta_table_copy_out_p59(t csi_datastructures_pub.instance_asset_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
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
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
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
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_asset_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).fa_asset_id);
          a3(indx) := t(ddindx).fa_book_type_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).asset_quantity);
          a6(indx) := t(ddindx).update_status;
          a7(indx) := t(ddindx).active_start_date;
          a8(indx) := t(ddindx).active_end_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := t(ddindx).asset_number;
          a11(indx) := t(ddindx).serial_number;
          a12(indx) := t(ddindx).tag_number;
          a13(indx) := t(ddindx).category;
          a14(indx) := t(ddindx).fa_location_segment1;
          a15(indx) := t(ddindx).fa_location_segment2;
          a16(indx) := t(ddindx).fa_location_segment3;
          a17(indx) := t(ddindx).fa_location_segment4;
          a18(indx) := t(ddindx).fa_location_segment5;
          a19(indx) := t(ddindx).fa_location_segment6;
          a20(indx) := t(ddindx).fa_location_segment7;
          a21(indx) := t(ddindx).date_placed_in_service;
          a22(indx) := t(ddindx).description;
          a23(indx) := t(ddindx).employee_name;
          a24(indx) := t(ddindx).expense_account_number;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).fa_mass_addition_id);
          a26(indx) := t(ddindx).creation_complete_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p59;

  procedure rosetta_table_copy_in_p61(t out nocopy csi_datastructures_pub.instance_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
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
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_DATE_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_NUMBER_TABLE
    , a105 JTF_DATE_TABLE
    , a106 JTF_DATE_TABLE
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_DATE_TABLE
    , a110 JTF_DATE_TABLE
    , a111 JTF_DATE_TABLE
    , a112 JTF_DATE_TABLE
    , a113 JTF_VARCHAR2_TABLE_100
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_100
    , a117 JTF_VARCHAR2_TABLE_100
    , a118 JTF_VARCHAR2_TABLE_100
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_300
    , a126 JTF_VARCHAR2_TABLE_300
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_300
    , a144 JTF_VARCHAR2_TABLE_300
    , a145 JTF_VARCHAR2_TABLE_300
    , a146 JTF_VARCHAR2_TABLE_300
    , a147 JTF_VARCHAR2_TABLE_300
    , a148 JTF_VARCHAR2_TABLE_300
    , a149 JTF_NUMBER_TABLE
    , a150 JTF_NUMBER_TABLE
    , a151 JTF_VARCHAR2_TABLE_100
    , a152 JTF_VARCHAR2_TABLE_100
    , a153 JTF_NUMBER_TABLE
    , a154 JTF_NUMBER_TABLE
    , a155 JTF_VARCHAR2_TABLE_100
    , a156 JTF_VARCHAR2_TABLE_100
    , a157 JTF_VARCHAR2_TABLE_300
    , a158 JTF_VARCHAR2_TABLE_300
    , a159 JTF_VARCHAR2_TABLE_300
    , a160 JTF_VARCHAR2_TABLE_300
    , a161 JTF_VARCHAR2_TABLE_300
    , a162 JTF_VARCHAR2_TABLE_300
    , a163 JTF_VARCHAR2_TABLE_300
    , a164 JTF_VARCHAR2_TABLE_300
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_VARCHAR2_TABLE_100
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_VARCHAR2_TABLE_100
    , a171 JTF_NUMBER_TABLE
    , a172 JTF_NUMBER_TABLE
    , a173 JTF_NUMBER_TABLE
    , a174 JTF_NUMBER_TABLE
    , a175 JTF_DATE_TABLE
    , a176 JTF_DATE_TABLE
    , a177 JTF_VARCHAR2_TABLE_100
    , a178 JTF_VARCHAR2_TABLE_100
    , a179 JTF_VARCHAR2_TABLE_100
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_VARCHAR2_TABLE_100
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_VARCHAR2_TABLE_300
    , a184 JTF_VARCHAR2_TABLE_300
    , a185 JTF_VARCHAR2_TABLE_300
    , a186 JTF_VARCHAR2_TABLE_300
    , a187 JTF_VARCHAR2_TABLE_300
    , a188 JTF_VARCHAR2_TABLE_300
    , a189 JTF_VARCHAR2_TABLE_300
    , a190 JTF_VARCHAR2_TABLE_300
    , a191 JTF_VARCHAR2_TABLE_100
    , a192 JTF_VARCHAR2_TABLE_100
    , a193 JTF_VARCHAR2_TABLE_100
    , a194 JTF_VARCHAR2_TABLE_100
    , a195 JTF_VARCHAR2_TABLE_100
    , a196 JTF_VARCHAR2_TABLE_100
    , a197 JTF_VARCHAR2_TABLE_100
    , a198 JTF_VARCHAR2_TABLE_100
    , a199 JTF_NUMBER_TABLE
    , a200 JTF_NUMBER_TABLE
    , a201 JTF_VARCHAR2_TABLE_100
    , a202 JTF_VARCHAR2_TABLE_100
    , a203 JTF_VARCHAR2_TABLE_300
    , a204 JTF_VARCHAR2_TABLE_300
    , a205 JTF_NUMBER_TABLE
    , a206 JTF_NUMBER_TABLE
    , a207 JTF_NUMBER_TABLE
    , a208 JTF_NUMBER_TABLE
    , a209 JTF_VARCHAR2_TABLE_300
    , a210 JTF_VARCHAR2_TABLE_300
    , a211 JTF_VARCHAR2_TABLE_300
    , a212 JTF_VARCHAR2_TABLE_300
    , a213 JTF_VARCHAR2_TABLE_100
    , a214 JTF_VARCHAR2_TABLE_100
    , a215 JTF_VARCHAR2_TABLE_100
    , a216 JTF_VARCHAR2_TABLE_100
    , a217 JTF_VARCHAR2_TABLE_100
    , a218 JTF_VARCHAR2_TABLE_100
    , a219 JTF_VARCHAR2_TABLE_100
    , a220 JTF_VARCHAR2_TABLE_100
    , a221 JTF_NUMBER_TABLE
    , a222 JTF_NUMBER_TABLE
    , a223 JTF_VARCHAR2_TABLE_100
    , a224 JTF_VARCHAR2_TABLE_100
    , a225 JTF_VARCHAR2_TABLE_100
    , a226 JTF_VARCHAR2_TABLE_100
    , a227 JTF_NUMBER_TABLE
    , a228 JTF_NUMBER_TABLE
    , a229 JTF_VARCHAR2_TABLE_200
    , a230 JTF_VARCHAR2_TABLE_200
    , a231 JTF_VARCHAR2_TABLE_100
    , a232 JTF_VARCHAR2_TABLE_100
    , a233 JTF_NUMBER_TABLE
    , a234 JTF_NUMBER_TABLE
    , a235 JTF_VARCHAR2_TABLE_100
    , a236 JTF_VARCHAR2_TABLE_100
    , a237 JTF_NUMBER_TABLE
    , a238 JTF_NUMBER_TABLE
    , a239 JTF_VARCHAR2_TABLE_100
    , a240 JTF_VARCHAR2_TABLE_100
    , a241 JTF_NUMBER_TABLE
    , a242 JTF_NUMBER_TABLE
    , a243 JTF_DATE_TABLE
    , a244 JTF_DATE_TABLE
    , a245 JTF_VARCHAR2_TABLE_300
    , a246 JTF_VARCHAR2_TABLE_300
    , a247 JTF_VARCHAR2_TABLE_300
    , a248 JTF_VARCHAR2_TABLE_300
    , a249 JTF_VARCHAR2_TABLE_300
    , a250 JTF_VARCHAR2_TABLE_300
    , a251 JTF_VARCHAR2_TABLE_300
    , a252 JTF_VARCHAR2_TABLE_300
    , a253 JTF_VARCHAR2_TABLE_300
    , a254 JTF_VARCHAR2_TABLE_300
    , a255 JTF_VARCHAR2_TABLE_300
    , a256 JTF_VARCHAR2_TABLE_300
    , a257 JTF_VARCHAR2_TABLE_300
    , a258 JTF_VARCHAR2_TABLE_300
    , a259 JTF_VARCHAR2_TABLE_300
    , a260 JTF_VARCHAR2_TABLE_300
    , a261 JTF_VARCHAR2_TABLE_300
    , a262 JTF_VARCHAR2_TABLE_300
    , a263 JTF_VARCHAR2_TABLE_300
    , a264 JTF_VARCHAR2_TABLE_300
    , a265 JTF_VARCHAR2_TABLE_300
    , a266 JTF_VARCHAR2_TABLE_300
    , a267 JTF_VARCHAR2_TABLE_300
    , a268 JTF_VARCHAR2_TABLE_300
    , a269 JTF_VARCHAR2_TABLE_300
    , a270 JTF_VARCHAR2_TABLE_300
    , a271 JTF_VARCHAR2_TABLE_300
    , a272 JTF_VARCHAR2_TABLE_300
    , a273 JTF_VARCHAR2_TABLE_300
    , a274 JTF_VARCHAR2_TABLE_300
    , a275 JTF_VARCHAR2_TABLE_100
    , a276 JTF_VARCHAR2_TABLE_100
    , a277 JTF_NUMBER_TABLE
    , a278 JTF_NUMBER_TABLE
    , a279 JTF_VARCHAR2_TABLE_100
    , a280 JTF_VARCHAR2_TABLE_100
    , a281 JTF_NUMBER_TABLE
    , a282 JTF_NUMBER_TABLE
    , a283 JTF_NUMBER_TABLE
    , a284 JTF_NUMBER_TABLE
    , a285 JTF_VARCHAR2_TABLE_100
    , a286 JTF_VARCHAR2_TABLE_100
    , a287 JTF_VARCHAR2_TABLE_100
    , a288 JTF_VARCHAR2_TABLE_100
    , a289 JTF_VARCHAR2_TABLE_100
    , a290 JTF_VARCHAR2_TABLE_300
    , a291 JTF_VARCHAR2_TABLE_300
    , a292 JTF_VARCHAR2_TABLE_100
    , a293 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).old_instance_number := a1(indx);
          t(ddindx).new_instance_number := a2(indx);
          t(ddindx).old_external_reference := a3(indx);
          t(ddindx).new_external_reference := a4(indx);
          t(ddindx).old_inventory_item_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).new_inventory_item_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).old_inventory_revision := a7(indx);
          t(ddindx).new_inventory_revision := a8(indx);
          t(ddindx).old_inv_master_org_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).new_inv_master_org_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).old_serial_number := a11(indx);
          t(ddindx).new_serial_number := a12(indx);
          t(ddindx).old_mfg_serial_number_flag := a13(indx);
          t(ddindx).new_mfg_serial_number_flag := a14(indx);
          t(ddindx).old_lot_number := a15(indx);
          t(ddindx).new_lot_number := a16(indx);
          t(ddindx).old_quantity := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).new_quantity := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).old_unit_of_measure_name := a19(indx);
          t(ddindx).new_unit_of_measure_name := a20(indx);
          t(ddindx).old_unit_of_measure := a21(indx);
          t(ddindx).new_unit_of_measure := a22(indx);
          t(ddindx).old_accounting_class := a23(indx);
          t(ddindx).new_accounting_class := a24(indx);
          t(ddindx).old_accounting_class_code := a25(indx);
          t(ddindx).new_accounting_class_code := a26(indx);
          t(ddindx).old_instance_condition := a27(indx);
          t(ddindx).new_instance_condition := a28(indx);
          t(ddindx).old_instance_condition_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).new_instance_condition_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).old_instance_status := a31(indx);
          t(ddindx).new_instance_status := a32(indx);
          t(ddindx).old_instance_status_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).new_instance_status_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).old_customer_view_flag := a35(indx);
          t(ddindx).new_customer_view_flag := a36(indx);
          t(ddindx).old_merchant_view_flag := a37(indx);
          t(ddindx).new_merchant_view_flag := a38(indx);
          t(ddindx).old_sellable_flag := a39(indx);
          t(ddindx).new_sellable_flag := a40(indx);
          t(ddindx).old_system_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).new_system_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).old_system_name := a43(indx);
          t(ddindx).new_system_name := a44(indx);
          t(ddindx).old_instance_type_code := a45(indx);
          t(ddindx).new_instance_type_code := a46(indx);
          t(ddindx).old_instance_type_name := a47(indx);
          t(ddindx).new_instance_type_name := a48(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a51(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).old_location_type_code := a53(indx);
          t(ddindx).new_location_type_code := a54(indx);
          t(ddindx).old_location_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).new_location_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).old_inv_organization_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).new_inv_organization_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).old_inv_organization_name := a59(indx);
          t(ddindx).new_inv_organization_name := a60(indx);
          t(ddindx).old_inv_subinventory_name := a61(indx);
          t(ddindx).new_inv_subinventory_name := a62(indx);
          t(ddindx).old_inv_locator_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).new_inv_locator_id := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).old_pa_project_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).new_pa_project_id := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).old_pa_project_task_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).new_pa_project_task_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).old_pa_project_name := a69(indx);
          t(ddindx).new_pa_project_name := a70(indx);
          t(ddindx).old_pa_project_number := a71(indx);
          t(ddindx).new_pa_project_number := a72(indx);
          t(ddindx).old_pa_task_name := a73(indx);
          t(ddindx).new_pa_task_name := a74(indx);
          t(ddindx).old_pa_task_number := a75(indx);
          t(ddindx).new_pa_task_number := a76(indx);
          t(ddindx).old_in_transit_order_line_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).new_in_transit_order_line_id := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).old_in_transit_order_line_num := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).new_in_transit_order_line_num := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).old_in_transit_order_number := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).new_in_transit_order_number := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).old_wip_job_id := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).new_wip_job_id := rosetta_g_miss_num_map(a84(indx));
          t(ddindx).old_wip_entity_name := a85(indx);
          t(ddindx).new_wip_entity_name := a86(indx);
          t(ddindx).old_po_order_line_id := rosetta_g_miss_num_map(a87(indx));
          t(ddindx).new_po_order_line_id := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).old_last_oe_order_line_id := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).new_last_oe_order_line_id := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).old_last_oe_rma_line_id := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).new_last_oe_rma_line_id := rosetta_g_miss_num_map(a92(indx));
          t(ddindx).old_last_po_po_line_id := rosetta_g_miss_num_map(a93(indx));
          t(ddindx).new_last_po_po_line_id := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).old_last_oe_po_number := a95(indx);
          t(ddindx).new_last_oe_po_number := a96(indx);
          t(ddindx).old_last_wip_job_id := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).new_last_wip_job_id := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).old_last_pa_project_id := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).new_last_pa_project_id := rosetta_g_miss_num_map(a100(indx));
          t(ddindx).old_last_pa_task_id := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).new_last_pa_task_id := rosetta_g_miss_num_map(a102(indx));
          t(ddindx).old_last_oe_agreement_id := rosetta_g_miss_num_map(a103(indx));
          t(ddindx).new_last_oe_agreement_id := rosetta_g_miss_num_map(a104(indx));
          t(ddindx).old_install_date := rosetta_g_miss_date_in_map(a105(indx));
          t(ddindx).new_install_date := rosetta_g_miss_date_in_map(a106(indx));
          t(ddindx).old_manually_created_flag := a107(indx);
          t(ddindx).new_manually_created_flag := a108(indx);
          t(ddindx).old_return_by_date := rosetta_g_miss_date_in_map(a109(indx));
          t(ddindx).new_return_by_date := rosetta_g_miss_date_in_map(a110(indx));
          t(ddindx).old_actual_return_date := rosetta_g_miss_date_in_map(a111(indx));
          t(ddindx).new_actual_return_date := rosetta_g_miss_date_in_map(a112(indx));
          t(ddindx).old_creation_complete_flag := a113(indx);
          t(ddindx).new_creation_complete_flag := a114(indx);
          t(ddindx).old_completeness_flag := a115(indx);
          t(ddindx).new_completeness_flag := a116(indx);
          t(ddindx).old_context := a117(indx);
          t(ddindx).new_context := a118(indx);
          t(ddindx).old_attribute1 := a119(indx);
          t(ddindx).new_attribute1 := a120(indx);
          t(ddindx).old_attribute2 := a121(indx);
          t(ddindx).new_attribute2 := a122(indx);
          t(ddindx).old_attribute3 := a123(indx);
          t(ddindx).new_attribute3 := a124(indx);
          t(ddindx).old_attribute4 := a125(indx);
          t(ddindx).new_attribute4 := a126(indx);
          t(ddindx).old_attribute5 := a127(indx);
          t(ddindx).new_attribute5 := a128(indx);
          t(ddindx).old_attribute6 := a129(indx);
          t(ddindx).new_attribute6 := a130(indx);
          t(ddindx).old_attribute7 := a131(indx);
          t(ddindx).new_attribute7 := a132(indx);
          t(ddindx).old_attribute8 := a133(indx);
          t(ddindx).new_attribute8 := a134(indx);
          t(ddindx).old_attribute9 := a135(indx);
          t(ddindx).new_attribute9 := a136(indx);
          t(ddindx).old_attribute10 := a137(indx);
          t(ddindx).new_attribute10 := a138(indx);
          t(ddindx).old_attribute11 := a139(indx);
          t(ddindx).new_attribute11 := a140(indx);
          t(ddindx).old_attribute12 := a141(indx);
          t(ddindx).new_attribute12 := a142(indx);
          t(ddindx).old_attribute13 := a143(indx);
          t(ddindx).new_attribute13 := a144(indx);
          t(ddindx).old_attribute14 := a145(indx);
          t(ddindx).new_attribute14 := a146(indx);
          t(ddindx).old_attribute15 := a147(indx);
          t(ddindx).new_attribute15 := a148(indx);
          t(ddindx).old_last_txn_line_detail_id := rosetta_g_miss_num_map(a149(indx));
          t(ddindx).new_last_txn_line_detail_id := rosetta_g_miss_num_map(a150(indx));
          t(ddindx).old_install_location_type_code := a151(indx);
          t(ddindx).new_install_location_type_code := a152(indx);
          t(ddindx).old_install_location_id := rosetta_g_miss_num_map(a153(indx));
          t(ddindx).new_install_location_id := rosetta_g_miss_num_map(a154(indx));
          t(ddindx).old_instance_usage_code := a155(indx);
          t(ddindx).new_instance_usage_code := a156(indx);
          t(ddindx).old_current_loc_address1 := a157(indx);
          t(ddindx).new_current_loc_address1 := a158(indx);
          t(ddindx).old_current_loc_address2 := a159(indx);
          t(ddindx).new_current_loc_address2 := a160(indx);
          t(ddindx).old_current_loc_address3 := a161(indx);
          t(ddindx).new_current_loc_address3 := a162(indx);
          t(ddindx).old_current_loc_address4 := a163(indx);
          t(ddindx).new_current_loc_address4 := a164(indx);
          t(ddindx).old_current_loc_city := a165(indx);
          t(ddindx).new_current_loc_city := a166(indx);
          t(ddindx).old_current_loc_postal_code := a167(indx);
          t(ddindx).new_current_loc_postal_code := a168(indx);
          t(ddindx).old_current_loc_country := a169(indx);
          t(ddindx).new_current_loc_country := a170(indx);
          t(ddindx).old_sales_order_number := rosetta_g_miss_num_map(a171(indx));
          t(ddindx).new_sales_order_number := rosetta_g_miss_num_map(a172(indx));
          t(ddindx).old_sales_order_line_number := rosetta_g_miss_num_map(a173(indx));
          t(ddindx).new_sales_order_line_number := rosetta_g_miss_num_map(a174(indx));
          t(ddindx).old_sales_order_date := rosetta_g_miss_date_in_map(a175(indx));
          t(ddindx).new_sales_order_date := rosetta_g_miss_date_in_map(a176(indx));
          t(ddindx).old_purchase_order_number := a177(indx);
          t(ddindx).new_purchase_order_number := a178(indx);
          t(ddindx).old_instance_usage_name := a179(indx);
          t(ddindx).new_instance_usage_name := a180(indx);
          t(ddindx).old_current_loc_state := a181(indx);
          t(ddindx).new_current_loc_state := a182(indx);
          t(ddindx).old_install_loc_address1 := a183(indx);
          t(ddindx).new_install_loc_address1 := a184(indx);
          t(ddindx).old_install_loc_address2 := a185(indx);
          t(ddindx).new_install_loc_address2 := a186(indx);
          t(ddindx).old_install_loc_address3 := a187(indx);
          t(ddindx).new_install_loc_address3 := a188(indx);
          t(ddindx).old_install_loc_address4 := a189(indx);
          t(ddindx).new_install_loc_address4 := a190(indx);
          t(ddindx).old_install_loc_city := a191(indx);
          t(ddindx).new_install_loc_city := a192(indx);
          t(ddindx).old_install_loc_state := a193(indx);
          t(ddindx).new_install_loc_state := a194(indx);
          t(ddindx).old_install_loc_postal_code := a195(indx);
          t(ddindx).new_install_loc_postal_code := a196(indx);
          t(ddindx).old_install_loc_country := a197(indx);
          t(ddindx).new_install_loc_country := a198(indx);
          t(ddindx).old_config_inst_rev_num := rosetta_g_miss_num_map(a199(indx));
          t(ddindx).new_config_inst_rev_num := rosetta_g_miss_num_map(a200(indx));
          t(ddindx).old_config_valid_status := a201(indx);
          t(ddindx).new_config_valid_status := a202(indx);
          t(ddindx).old_instance_description := a203(indx);
          t(ddindx).new_instance_description := a204(indx);
          t(ddindx).instance_history_id := rosetta_g_miss_num_map(a205(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a206(indx));
          t(ddindx).old_last_vld_organization_id := rosetta_g_miss_num_map(a207(indx));
          t(ddindx).new_last_vld_organization_id := rosetta_g_miss_num_map(a208(indx));
          t(ddindx).old_oe_agreement_name := a209(indx);
          t(ddindx).new_oe_agreement_name := a210(indx);
          t(ddindx).old_inv_locator_name := a211(indx);
          t(ddindx).new_inv_locator_name := a212(indx);
          t(ddindx).old_current_location_number := a213(indx);
          t(ddindx).new_current_location_number := a214(indx);
          t(ddindx).old_install_location_number := a215(indx);
          t(ddindx).new_install_location_number := a216(indx);
          t(ddindx).old_network_asset_flag := a217(indx);
          t(ddindx).new_network_asset_flag := a218(indx);
          t(ddindx).old_maintainable_flag := a219(indx);
          t(ddindx).new_maintainable_flag := a220(indx);
          t(ddindx).old_pn_location_id := rosetta_g_miss_num_map(a221(indx));
          t(ddindx).new_pn_location_id := rosetta_g_miss_num_map(a222(indx));
          t(ddindx).old_asset_criticality_code := a223(indx);
          t(ddindx).new_asset_criticality_code := a224(indx);
          t(ddindx).old_criticality := a225(indx);
          t(ddindx).new_criticality := a226(indx);
          t(ddindx).old_category_id := rosetta_g_miss_num_map(a227(indx));
          t(ddindx).new_category_id := rosetta_g_miss_num_map(a228(indx));
          t(ddindx).old_category_name := a229(indx);
          t(ddindx).new_category_name := a230(indx);
          t(ddindx).old_maintainable := a231(indx);
          t(ddindx).new_maintainable := a232(indx);
          t(ddindx).old_equipment_gen_object_id := rosetta_g_miss_num_map(a233(indx));
          t(ddindx).new_equipment_gen_object_id := rosetta_g_miss_num_map(a234(indx));
          t(ddindx).old_instantiation_flag := a235(indx);
          t(ddindx).new_instantiation_flag := a236(indx);
          t(ddindx).old_linear_location_id := rosetta_g_miss_num_map(a237(indx));
          t(ddindx).new_linear_location_id := rosetta_g_miss_num_map(a238(indx));
          t(ddindx).old_operational_log_flag := a239(indx);
          t(ddindx).new_operational_log_flag := a240(indx);
          t(ddindx).old_checkin_status := rosetta_g_miss_num_map(a241(indx));
          t(ddindx).new_checkin_status := rosetta_g_miss_num_map(a242(indx));
          t(ddindx).old_supplier_warranty_exp_date := rosetta_g_miss_date_in_map(a243(indx));
          t(ddindx).new_supplier_warranty_exp_date := rosetta_g_miss_date_in_map(a244(indx));
          t(ddindx).old_attribute16 := a245(indx);
          t(ddindx).new_attribute16 := a246(indx);
          t(ddindx).old_attribute17 := a247(indx);
          t(ddindx).new_attribute17 := a248(indx);
          t(ddindx).old_attribute18 := a249(indx);
          t(ddindx).new_attribute18 := a250(indx);
          t(ddindx).old_attribute19 := a251(indx);
          t(ddindx).new_attribute19 := a252(indx);
          t(ddindx).old_attribute20 := a253(indx);
          t(ddindx).new_attribute20 := a254(indx);
          t(ddindx).old_attribute21 := a255(indx);
          t(ddindx).new_attribute21 := a256(indx);
          t(ddindx).old_attribute22 := a257(indx);
          t(ddindx).new_attribute22 := a258(indx);
          t(ddindx).old_attribute23 := a259(indx);
          t(ddindx).new_attribute23 := a260(indx);
          t(ddindx).old_attribute24 := a261(indx);
          t(ddindx).new_attribute24 := a262(indx);
          t(ddindx).old_attribute25 := a263(indx);
          t(ddindx).new_attribute25 := a264(indx);
          t(ddindx).old_attribute26 := a265(indx);
          t(ddindx).new_attribute26 := a266(indx);
          t(ddindx).old_attribute27 := a267(indx);
          t(ddindx).new_attribute27 := a268(indx);
          t(ddindx).old_attribute28 := a269(indx);
          t(ddindx).new_attribute28 := a270(indx);
          t(ddindx).old_attribute29 := a271(indx);
          t(ddindx).new_attribute29 := a272(indx);
          t(ddindx).old_attribute30 := a273(indx);
          t(ddindx).new_attribute30 := a274(indx);
          t(ddindx).old_payables_currency_code := a275(indx);
          t(ddindx).new_payables_currency_code := a276(indx);
          t(ddindx).old_purchase_unit_price := rosetta_g_miss_num_map(a277(indx));
          t(ddindx).new_purchase_unit_price := rosetta_g_miss_num_map(a278(indx));
          t(ddindx).old_purchase_currency_code := a279(indx);
          t(ddindx).new_purchase_currency_code := a280(indx);
          t(ddindx).old_payables_unit_price := rosetta_g_miss_num_map(a281(indx));
          t(ddindx).new_payables_unit_price := rosetta_g_miss_num_map(a282(indx));
          t(ddindx).old_sales_unit_price := rosetta_g_miss_num_map(a283(indx));
          t(ddindx).new_sales_unit_price := rosetta_g_miss_num_map(a284(indx));
          t(ddindx).old_sales_currency_code := a285(indx);
          t(ddindx).new_sales_currency_code := a286(indx);
          t(ddindx).old_operational_status_code := a287(indx);
          t(ddindx).new_operational_status_code := a288(indx);
          t(ddindx).full_dump_flag := a289(indx);
          t(ddindx).old_inventory_item_name := a290(indx);
          t(ddindx).new_inventory_item_name := a291(indx);
          t(ddindx).old_source_code := a292(indx);
          t(ddindx).new_source_code := a293(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p61;
  procedure rosetta_table_copy_out_p61(t csi_datastructures_pub.instance_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
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
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_VARCHAR2_TABLE_100
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_NUMBER_TABLE
    , a98 out nocopy JTF_NUMBER_TABLE
    , a99 out nocopy JTF_NUMBER_TABLE
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_NUMBER_TABLE
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_NUMBER_TABLE
    , a105 out nocopy JTF_DATE_TABLE
    , a106 out nocopy JTF_DATE_TABLE
    , a107 out nocopy JTF_VARCHAR2_TABLE_100
    , a108 out nocopy JTF_VARCHAR2_TABLE_100
    , a109 out nocopy JTF_DATE_TABLE
    , a110 out nocopy JTF_DATE_TABLE
    , a111 out nocopy JTF_DATE_TABLE
    , a112 out nocopy JTF_DATE_TABLE
    , a113 out nocopy JTF_VARCHAR2_TABLE_100
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
    , a115 out nocopy JTF_VARCHAR2_TABLE_100
    , a116 out nocopy JTF_VARCHAR2_TABLE_100
    , a117 out nocopy JTF_VARCHAR2_TABLE_100
    , a118 out nocopy JTF_VARCHAR2_TABLE_100
    , a119 out nocopy JTF_VARCHAR2_TABLE_300
    , a120 out nocopy JTF_VARCHAR2_TABLE_300
    , a121 out nocopy JTF_VARCHAR2_TABLE_300
    , a122 out nocopy JTF_VARCHAR2_TABLE_300
    , a123 out nocopy JTF_VARCHAR2_TABLE_300
    , a124 out nocopy JTF_VARCHAR2_TABLE_300
    , a125 out nocopy JTF_VARCHAR2_TABLE_300
    , a126 out nocopy JTF_VARCHAR2_TABLE_300
    , a127 out nocopy JTF_VARCHAR2_TABLE_300
    , a128 out nocopy JTF_VARCHAR2_TABLE_300
    , a129 out nocopy JTF_VARCHAR2_TABLE_300
    , a130 out nocopy JTF_VARCHAR2_TABLE_300
    , a131 out nocopy JTF_VARCHAR2_TABLE_300
    , a132 out nocopy JTF_VARCHAR2_TABLE_300
    , a133 out nocopy JTF_VARCHAR2_TABLE_300
    , a134 out nocopy JTF_VARCHAR2_TABLE_300
    , a135 out nocopy JTF_VARCHAR2_TABLE_300
    , a136 out nocopy JTF_VARCHAR2_TABLE_300
    , a137 out nocopy JTF_VARCHAR2_TABLE_300
    , a138 out nocopy JTF_VARCHAR2_TABLE_300
    , a139 out nocopy JTF_VARCHAR2_TABLE_300
    , a140 out nocopy JTF_VARCHAR2_TABLE_300
    , a141 out nocopy JTF_VARCHAR2_TABLE_300
    , a142 out nocopy JTF_VARCHAR2_TABLE_300
    , a143 out nocopy JTF_VARCHAR2_TABLE_300
    , a144 out nocopy JTF_VARCHAR2_TABLE_300
    , a145 out nocopy JTF_VARCHAR2_TABLE_300
    , a146 out nocopy JTF_VARCHAR2_TABLE_300
    , a147 out nocopy JTF_VARCHAR2_TABLE_300
    , a148 out nocopy JTF_VARCHAR2_TABLE_300
    , a149 out nocopy JTF_NUMBER_TABLE
    , a150 out nocopy JTF_NUMBER_TABLE
    , a151 out nocopy JTF_VARCHAR2_TABLE_100
    , a152 out nocopy JTF_VARCHAR2_TABLE_100
    , a153 out nocopy JTF_NUMBER_TABLE
    , a154 out nocopy JTF_NUMBER_TABLE
    , a155 out nocopy JTF_VARCHAR2_TABLE_100
    , a156 out nocopy JTF_VARCHAR2_TABLE_100
    , a157 out nocopy JTF_VARCHAR2_TABLE_300
    , a158 out nocopy JTF_VARCHAR2_TABLE_300
    , a159 out nocopy JTF_VARCHAR2_TABLE_300
    , a160 out nocopy JTF_VARCHAR2_TABLE_300
    , a161 out nocopy JTF_VARCHAR2_TABLE_300
    , a162 out nocopy JTF_VARCHAR2_TABLE_300
    , a163 out nocopy JTF_VARCHAR2_TABLE_300
    , a164 out nocopy JTF_VARCHAR2_TABLE_300
    , a165 out nocopy JTF_VARCHAR2_TABLE_100
    , a166 out nocopy JTF_VARCHAR2_TABLE_100
    , a167 out nocopy JTF_VARCHAR2_TABLE_100
    , a168 out nocopy JTF_VARCHAR2_TABLE_100
    , a169 out nocopy JTF_VARCHAR2_TABLE_100
    , a170 out nocopy JTF_VARCHAR2_TABLE_100
    , a171 out nocopy JTF_NUMBER_TABLE
    , a172 out nocopy JTF_NUMBER_TABLE
    , a173 out nocopy JTF_NUMBER_TABLE
    , a174 out nocopy JTF_NUMBER_TABLE
    , a175 out nocopy JTF_DATE_TABLE
    , a176 out nocopy JTF_DATE_TABLE
    , a177 out nocopy JTF_VARCHAR2_TABLE_100
    , a178 out nocopy JTF_VARCHAR2_TABLE_100
    , a179 out nocopy JTF_VARCHAR2_TABLE_100
    , a180 out nocopy JTF_VARCHAR2_TABLE_100
    , a181 out nocopy JTF_VARCHAR2_TABLE_100
    , a182 out nocopy JTF_VARCHAR2_TABLE_100
    , a183 out nocopy JTF_VARCHAR2_TABLE_300
    , a184 out nocopy JTF_VARCHAR2_TABLE_300
    , a185 out nocopy JTF_VARCHAR2_TABLE_300
    , a186 out nocopy JTF_VARCHAR2_TABLE_300
    , a187 out nocopy JTF_VARCHAR2_TABLE_300
    , a188 out nocopy JTF_VARCHAR2_TABLE_300
    , a189 out nocopy JTF_VARCHAR2_TABLE_300
    , a190 out nocopy JTF_VARCHAR2_TABLE_300
    , a191 out nocopy JTF_VARCHAR2_TABLE_100
    , a192 out nocopy JTF_VARCHAR2_TABLE_100
    , a193 out nocopy JTF_VARCHAR2_TABLE_100
    , a194 out nocopy JTF_VARCHAR2_TABLE_100
    , a195 out nocopy JTF_VARCHAR2_TABLE_100
    , a196 out nocopy JTF_VARCHAR2_TABLE_100
    , a197 out nocopy JTF_VARCHAR2_TABLE_100
    , a198 out nocopy JTF_VARCHAR2_TABLE_100
    , a199 out nocopy JTF_NUMBER_TABLE
    , a200 out nocopy JTF_NUMBER_TABLE
    , a201 out nocopy JTF_VARCHAR2_TABLE_100
    , a202 out nocopy JTF_VARCHAR2_TABLE_100
    , a203 out nocopy JTF_VARCHAR2_TABLE_300
    , a204 out nocopy JTF_VARCHAR2_TABLE_300
    , a205 out nocopy JTF_NUMBER_TABLE
    , a206 out nocopy JTF_NUMBER_TABLE
    , a207 out nocopy JTF_NUMBER_TABLE
    , a208 out nocopy JTF_NUMBER_TABLE
    , a209 out nocopy JTF_VARCHAR2_TABLE_300
    , a210 out nocopy JTF_VARCHAR2_TABLE_300
    , a211 out nocopy JTF_VARCHAR2_TABLE_300
    , a212 out nocopy JTF_VARCHAR2_TABLE_300
    , a213 out nocopy JTF_VARCHAR2_TABLE_100
    , a214 out nocopy JTF_VARCHAR2_TABLE_100
    , a215 out nocopy JTF_VARCHAR2_TABLE_100
    , a216 out nocopy JTF_VARCHAR2_TABLE_100
    , a217 out nocopy JTF_VARCHAR2_TABLE_100
    , a218 out nocopy JTF_VARCHAR2_TABLE_100
    , a219 out nocopy JTF_VARCHAR2_TABLE_100
    , a220 out nocopy JTF_VARCHAR2_TABLE_100
    , a221 out nocopy JTF_NUMBER_TABLE
    , a222 out nocopy JTF_NUMBER_TABLE
    , a223 out nocopy JTF_VARCHAR2_TABLE_100
    , a224 out nocopy JTF_VARCHAR2_TABLE_100
    , a225 out nocopy JTF_VARCHAR2_TABLE_100
    , a226 out nocopy JTF_VARCHAR2_TABLE_100
    , a227 out nocopy JTF_NUMBER_TABLE
    , a228 out nocopy JTF_NUMBER_TABLE
    , a229 out nocopy JTF_VARCHAR2_TABLE_200
    , a230 out nocopy JTF_VARCHAR2_TABLE_200
    , a231 out nocopy JTF_VARCHAR2_TABLE_100
    , a232 out nocopy JTF_VARCHAR2_TABLE_100
    , a233 out nocopy JTF_NUMBER_TABLE
    , a234 out nocopy JTF_NUMBER_TABLE
    , a235 out nocopy JTF_VARCHAR2_TABLE_100
    , a236 out nocopy JTF_VARCHAR2_TABLE_100
    , a237 out nocopy JTF_NUMBER_TABLE
    , a238 out nocopy JTF_NUMBER_TABLE
    , a239 out nocopy JTF_VARCHAR2_TABLE_100
    , a240 out nocopy JTF_VARCHAR2_TABLE_100
    , a241 out nocopy JTF_NUMBER_TABLE
    , a242 out nocopy JTF_NUMBER_TABLE
    , a243 out nocopy JTF_DATE_TABLE
    , a244 out nocopy JTF_DATE_TABLE
    , a245 out nocopy JTF_VARCHAR2_TABLE_300
    , a246 out nocopy JTF_VARCHAR2_TABLE_300
    , a247 out nocopy JTF_VARCHAR2_TABLE_300
    , a248 out nocopy JTF_VARCHAR2_TABLE_300
    , a249 out nocopy JTF_VARCHAR2_TABLE_300
    , a250 out nocopy JTF_VARCHAR2_TABLE_300
    , a251 out nocopy JTF_VARCHAR2_TABLE_300
    , a252 out nocopy JTF_VARCHAR2_TABLE_300
    , a253 out nocopy JTF_VARCHAR2_TABLE_300
    , a254 out nocopy JTF_VARCHAR2_TABLE_300
    , a255 out nocopy JTF_VARCHAR2_TABLE_300
    , a256 out nocopy JTF_VARCHAR2_TABLE_300
    , a257 out nocopy JTF_VARCHAR2_TABLE_300
    , a258 out nocopy JTF_VARCHAR2_TABLE_300
    , a259 out nocopy JTF_VARCHAR2_TABLE_300
    , a260 out nocopy JTF_VARCHAR2_TABLE_300
    , a261 out nocopy JTF_VARCHAR2_TABLE_300
    , a262 out nocopy JTF_VARCHAR2_TABLE_300
    , a263 out nocopy JTF_VARCHAR2_TABLE_300
    , a264 out nocopy JTF_VARCHAR2_TABLE_300
    , a265 out nocopy JTF_VARCHAR2_TABLE_300
    , a266 out nocopy JTF_VARCHAR2_TABLE_300
    , a267 out nocopy JTF_VARCHAR2_TABLE_300
    , a268 out nocopy JTF_VARCHAR2_TABLE_300
    , a269 out nocopy JTF_VARCHAR2_TABLE_300
    , a270 out nocopy JTF_VARCHAR2_TABLE_300
    , a271 out nocopy JTF_VARCHAR2_TABLE_300
    , a272 out nocopy JTF_VARCHAR2_TABLE_300
    , a273 out nocopy JTF_VARCHAR2_TABLE_300
    , a274 out nocopy JTF_VARCHAR2_TABLE_300
    , a275 out nocopy JTF_VARCHAR2_TABLE_100
    , a276 out nocopy JTF_VARCHAR2_TABLE_100
    , a277 out nocopy JTF_NUMBER_TABLE
    , a278 out nocopy JTF_NUMBER_TABLE
    , a279 out nocopy JTF_VARCHAR2_TABLE_100
    , a280 out nocopy JTF_VARCHAR2_TABLE_100
    , a281 out nocopy JTF_NUMBER_TABLE
    , a282 out nocopy JTF_NUMBER_TABLE
    , a283 out nocopy JTF_NUMBER_TABLE
    , a284 out nocopy JTF_NUMBER_TABLE
    , a285 out nocopy JTF_VARCHAR2_TABLE_100
    , a286 out nocopy JTF_VARCHAR2_TABLE_100
    , a287 out nocopy JTF_VARCHAR2_TABLE_100
    , a288 out nocopy JTF_VARCHAR2_TABLE_100
    , a289 out nocopy JTF_VARCHAR2_TABLE_100
    , a290 out nocopy JTF_VARCHAR2_TABLE_300
    , a291 out nocopy JTF_VARCHAR2_TABLE_300
    , a292 out nocopy JTF_VARCHAR2_TABLE_100
    , a293 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
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
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_DATE_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_NUMBER_TABLE();
    a93 := JTF_NUMBER_TABLE();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_VARCHAR2_TABLE_100();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_NUMBER_TABLE();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_NUMBER_TABLE();
    a105 := JTF_DATE_TABLE();
    a106 := JTF_DATE_TABLE();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_VARCHAR2_TABLE_100();
    a109 := JTF_DATE_TABLE();
    a110 := JTF_DATE_TABLE();
    a111 := JTF_DATE_TABLE();
    a112 := JTF_DATE_TABLE();
    a113 := JTF_VARCHAR2_TABLE_100();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_100();
    a117 := JTF_VARCHAR2_TABLE_100();
    a118 := JTF_VARCHAR2_TABLE_100();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_300();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_300();
    a124 := JTF_VARCHAR2_TABLE_300();
    a125 := JTF_VARCHAR2_TABLE_300();
    a126 := JTF_VARCHAR2_TABLE_300();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_300();
    a129 := JTF_VARCHAR2_TABLE_300();
    a130 := JTF_VARCHAR2_TABLE_300();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_300();
    a133 := JTF_VARCHAR2_TABLE_300();
    a134 := JTF_VARCHAR2_TABLE_300();
    a135 := JTF_VARCHAR2_TABLE_300();
    a136 := JTF_VARCHAR2_TABLE_300();
    a137 := JTF_VARCHAR2_TABLE_300();
    a138 := JTF_VARCHAR2_TABLE_300();
    a139 := JTF_VARCHAR2_TABLE_300();
    a140 := JTF_VARCHAR2_TABLE_300();
    a141 := JTF_VARCHAR2_TABLE_300();
    a142 := JTF_VARCHAR2_TABLE_300();
    a143 := JTF_VARCHAR2_TABLE_300();
    a144 := JTF_VARCHAR2_TABLE_300();
    a145 := JTF_VARCHAR2_TABLE_300();
    a146 := JTF_VARCHAR2_TABLE_300();
    a147 := JTF_VARCHAR2_TABLE_300();
    a148 := JTF_VARCHAR2_TABLE_300();
    a149 := JTF_NUMBER_TABLE();
    a150 := JTF_NUMBER_TABLE();
    a151 := JTF_VARCHAR2_TABLE_100();
    a152 := JTF_VARCHAR2_TABLE_100();
    a153 := JTF_NUMBER_TABLE();
    a154 := JTF_NUMBER_TABLE();
    a155 := JTF_VARCHAR2_TABLE_100();
    a156 := JTF_VARCHAR2_TABLE_100();
    a157 := JTF_VARCHAR2_TABLE_300();
    a158 := JTF_VARCHAR2_TABLE_300();
    a159 := JTF_VARCHAR2_TABLE_300();
    a160 := JTF_VARCHAR2_TABLE_300();
    a161 := JTF_VARCHAR2_TABLE_300();
    a162 := JTF_VARCHAR2_TABLE_300();
    a163 := JTF_VARCHAR2_TABLE_300();
    a164 := JTF_VARCHAR2_TABLE_300();
    a165 := JTF_VARCHAR2_TABLE_100();
    a166 := JTF_VARCHAR2_TABLE_100();
    a167 := JTF_VARCHAR2_TABLE_100();
    a168 := JTF_VARCHAR2_TABLE_100();
    a169 := JTF_VARCHAR2_TABLE_100();
    a170 := JTF_VARCHAR2_TABLE_100();
    a171 := JTF_NUMBER_TABLE();
    a172 := JTF_NUMBER_TABLE();
    a173 := JTF_NUMBER_TABLE();
    a174 := JTF_NUMBER_TABLE();
    a175 := JTF_DATE_TABLE();
    a176 := JTF_DATE_TABLE();
    a177 := JTF_VARCHAR2_TABLE_100();
    a178 := JTF_VARCHAR2_TABLE_100();
    a179 := JTF_VARCHAR2_TABLE_100();
    a180 := JTF_VARCHAR2_TABLE_100();
    a181 := JTF_VARCHAR2_TABLE_100();
    a182 := JTF_VARCHAR2_TABLE_100();
    a183 := JTF_VARCHAR2_TABLE_300();
    a184 := JTF_VARCHAR2_TABLE_300();
    a185 := JTF_VARCHAR2_TABLE_300();
    a186 := JTF_VARCHAR2_TABLE_300();
    a187 := JTF_VARCHAR2_TABLE_300();
    a188 := JTF_VARCHAR2_TABLE_300();
    a189 := JTF_VARCHAR2_TABLE_300();
    a190 := JTF_VARCHAR2_TABLE_300();
    a191 := JTF_VARCHAR2_TABLE_100();
    a192 := JTF_VARCHAR2_TABLE_100();
    a193 := JTF_VARCHAR2_TABLE_100();
    a194 := JTF_VARCHAR2_TABLE_100();
    a195 := JTF_VARCHAR2_TABLE_100();
    a196 := JTF_VARCHAR2_TABLE_100();
    a197 := JTF_VARCHAR2_TABLE_100();
    a198 := JTF_VARCHAR2_TABLE_100();
    a199 := JTF_NUMBER_TABLE();
    a200 := JTF_NUMBER_TABLE();
    a201 := JTF_VARCHAR2_TABLE_100();
    a202 := JTF_VARCHAR2_TABLE_100();
    a203 := JTF_VARCHAR2_TABLE_300();
    a204 := JTF_VARCHAR2_TABLE_300();
    a205 := JTF_NUMBER_TABLE();
    a206 := JTF_NUMBER_TABLE();
    a207 := JTF_NUMBER_TABLE();
    a208 := JTF_NUMBER_TABLE();
    a209 := JTF_VARCHAR2_TABLE_300();
    a210 := JTF_VARCHAR2_TABLE_300();
    a211 := JTF_VARCHAR2_TABLE_300();
    a212 := JTF_VARCHAR2_TABLE_300();
    a213 := JTF_VARCHAR2_TABLE_100();
    a214 := JTF_VARCHAR2_TABLE_100();
    a215 := JTF_VARCHAR2_TABLE_100();
    a216 := JTF_VARCHAR2_TABLE_100();
    a217 := JTF_VARCHAR2_TABLE_100();
    a218 := JTF_VARCHAR2_TABLE_100();
    a219 := JTF_VARCHAR2_TABLE_100();
    a220 := JTF_VARCHAR2_TABLE_100();
    a221 := JTF_NUMBER_TABLE();
    a222 := JTF_NUMBER_TABLE();
    a223 := JTF_VARCHAR2_TABLE_100();
    a224 := JTF_VARCHAR2_TABLE_100();
    a225 := JTF_VARCHAR2_TABLE_100();
    a226 := JTF_VARCHAR2_TABLE_100();
    a227 := JTF_NUMBER_TABLE();
    a228 := JTF_NUMBER_TABLE();
    a229 := JTF_VARCHAR2_TABLE_200();
    a230 := JTF_VARCHAR2_TABLE_200();
    a231 := JTF_VARCHAR2_TABLE_100();
    a232 := JTF_VARCHAR2_TABLE_100();
    a233 := JTF_NUMBER_TABLE();
    a234 := JTF_NUMBER_TABLE();
    a235 := JTF_VARCHAR2_TABLE_100();
    a236 := JTF_VARCHAR2_TABLE_100();
    a237 := JTF_NUMBER_TABLE();
    a238 := JTF_NUMBER_TABLE();
    a239 := JTF_VARCHAR2_TABLE_100();
    a240 := JTF_VARCHAR2_TABLE_100();
    a241 := JTF_NUMBER_TABLE();
    a242 := JTF_NUMBER_TABLE();
    a243 := JTF_DATE_TABLE();
    a244 := JTF_DATE_TABLE();
    a245 := JTF_VARCHAR2_TABLE_300();
    a246 := JTF_VARCHAR2_TABLE_300();
    a247 := JTF_VARCHAR2_TABLE_300();
    a248 := JTF_VARCHAR2_TABLE_300();
    a249 := JTF_VARCHAR2_TABLE_300();
    a250 := JTF_VARCHAR2_TABLE_300();
    a251 := JTF_VARCHAR2_TABLE_300();
    a252 := JTF_VARCHAR2_TABLE_300();
    a253 := JTF_VARCHAR2_TABLE_300();
    a254 := JTF_VARCHAR2_TABLE_300();
    a255 := JTF_VARCHAR2_TABLE_300();
    a256 := JTF_VARCHAR2_TABLE_300();
    a257 := JTF_VARCHAR2_TABLE_300();
    a258 := JTF_VARCHAR2_TABLE_300();
    a259 := JTF_VARCHAR2_TABLE_300();
    a260 := JTF_VARCHAR2_TABLE_300();
    a261 := JTF_VARCHAR2_TABLE_300();
    a262 := JTF_VARCHAR2_TABLE_300();
    a263 := JTF_VARCHAR2_TABLE_300();
    a264 := JTF_VARCHAR2_TABLE_300();
    a265 := JTF_VARCHAR2_TABLE_300();
    a266 := JTF_VARCHAR2_TABLE_300();
    a267 := JTF_VARCHAR2_TABLE_300();
    a268 := JTF_VARCHAR2_TABLE_300();
    a269 := JTF_VARCHAR2_TABLE_300();
    a270 := JTF_VARCHAR2_TABLE_300();
    a271 := JTF_VARCHAR2_TABLE_300();
    a272 := JTF_VARCHAR2_TABLE_300();
    a273 := JTF_VARCHAR2_TABLE_300();
    a274 := JTF_VARCHAR2_TABLE_300();
    a275 := JTF_VARCHAR2_TABLE_100();
    a276 := JTF_VARCHAR2_TABLE_100();
    a277 := JTF_NUMBER_TABLE();
    a278 := JTF_NUMBER_TABLE();
    a279 := JTF_VARCHAR2_TABLE_100();
    a280 := JTF_VARCHAR2_TABLE_100();
    a281 := JTF_NUMBER_TABLE();
    a282 := JTF_NUMBER_TABLE();
    a283 := JTF_NUMBER_TABLE();
    a284 := JTF_NUMBER_TABLE();
    a285 := JTF_VARCHAR2_TABLE_100();
    a286 := JTF_VARCHAR2_TABLE_100();
    a287 := JTF_VARCHAR2_TABLE_100();
    a288 := JTF_VARCHAR2_TABLE_100();
    a289 := JTF_VARCHAR2_TABLE_100();
    a290 := JTF_VARCHAR2_TABLE_300();
    a291 := JTF_VARCHAR2_TABLE_300();
    a292 := JTF_VARCHAR2_TABLE_100();
    a293 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
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
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_DATE_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_NUMBER_TABLE();
      a93 := JTF_NUMBER_TABLE();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_VARCHAR2_TABLE_100();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_NUMBER_TABLE();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_NUMBER_TABLE();
      a105 := JTF_DATE_TABLE();
      a106 := JTF_DATE_TABLE();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_VARCHAR2_TABLE_100();
      a109 := JTF_DATE_TABLE();
      a110 := JTF_DATE_TABLE();
      a111 := JTF_DATE_TABLE();
      a112 := JTF_DATE_TABLE();
      a113 := JTF_VARCHAR2_TABLE_100();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_100();
      a117 := JTF_VARCHAR2_TABLE_100();
      a118 := JTF_VARCHAR2_TABLE_100();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_300();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_300();
      a124 := JTF_VARCHAR2_TABLE_300();
      a125 := JTF_VARCHAR2_TABLE_300();
      a126 := JTF_VARCHAR2_TABLE_300();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_300();
      a129 := JTF_VARCHAR2_TABLE_300();
      a130 := JTF_VARCHAR2_TABLE_300();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_300();
      a133 := JTF_VARCHAR2_TABLE_300();
      a134 := JTF_VARCHAR2_TABLE_300();
      a135 := JTF_VARCHAR2_TABLE_300();
      a136 := JTF_VARCHAR2_TABLE_300();
      a137 := JTF_VARCHAR2_TABLE_300();
      a138 := JTF_VARCHAR2_TABLE_300();
      a139 := JTF_VARCHAR2_TABLE_300();
      a140 := JTF_VARCHAR2_TABLE_300();
      a141 := JTF_VARCHAR2_TABLE_300();
      a142 := JTF_VARCHAR2_TABLE_300();
      a143 := JTF_VARCHAR2_TABLE_300();
      a144 := JTF_VARCHAR2_TABLE_300();
      a145 := JTF_VARCHAR2_TABLE_300();
      a146 := JTF_VARCHAR2_TABLE_300();
      a147 := JTF_VARCHAR2_TABLE_300();
      a148 := JTF_VARCHAR2_TABLE_300();
      a149 := JTF_NUMBER_TABLE();
      a150 := JTF_NUMBER_TABLE();
      a151 := JTF_VARCHAR2_TABLE_100();
      a152 := JTF_VARCHAR2_TABLE_100();
      a153 := JTF_NUMBER_TABLE();
      a154 := JTF_NUMBER_TABLE();
      a155 := JTF_VARCHAR2_TABLE_100();
      a156 := JTF_VARCHAR2_TABLE_100();
      a157 := JTF_VARCHAR2_TABLE_300();
      a158 := JTF_VARCHAR2_TABLE_300();
      a159 := JTF_VARCHAR2_TABLE_300();
      a160 := JTF_VARCHAR2_TABLE_300();
      a161 := JTF_VARCHAR2_TABLE_300();
      a162 := JTF_VARCHAR2_TABLE_300();
      a163 := JTF_VARCHAR2_TABLE_300();
      a164 := JTF_VARCHAR2_TABLE_300();
      a165 := JTF_VARCHAR2_TABLE_100();
      a166 := JTF_VARCHAR2_TABLE_100();
      a167 := JTF_VARCHAR2_TABLE_100();
      a168 := JTF_VARCHAR2_TABLE_100();
      a169 := JTF_VARCHAR2_TABLE_100();
      a170 := JTF_VARCHAR2_TABLE_100();
      a171 := JTF_NUMBER_TABLE();
      a172 := JTF_NUMBER_TABLE();
      a173 := JTF_NUMBER_TABLE();
      a174 := JTF_NUMBER_TABLE();
      a175 := JTF_DATE_TABLE();
      a176 := JTF_DATE_TABLE();
      a177 := JTF_VARCHAR2_TABLE_100();
      a178 := JTF_VARCHAR2_TABLE_100();
      a179 := JTF_VARCHAR2_TABLE_100();
      a180 := JTF_VARCHAR2_TABLE_100();
      a181 := JTF_VARCHAR2_TABLE_100();
      a182 := JTF_VARCHAR2_TABLE_100();
      a183 := JTF_VARCHAR2_TABLE_300();
      a184 := JTF_VARCHAR2_TABLE_300();
      a185 := JTF_VARCHAR2_TABLE_300();
      a186 := JTF_VARCHAR2_TABLE_300();
      a187 := JTF_VARCHAR2_TABLE_300();
      a188 := JTF_VARCHAR2_TABLE_300();
      a189 := JTF_VARCHAR2_TABLE_300();
      a190 := JTF_VARCHAR2_TABLE_300();
      a191 := JTF_VARCHAR2_TABLE_100();
      a192 := JTF_VARCHAR2_TABLE_100();
      a193 := JTF_VARCHAR2_TABLE_100();
      a194 := JTF_VARCHAR2_TABLE_100();
      a195 := JTF_VARCHAR2_TABLE_100();
      a196 := JTF_VARCHAR2_TABLE_100();
      a197 := JTF_VARCHAR2_TABLE_100();
      a198 := JTF_VARCHAR2_TABLE_100();
      a199 := JTF_NUMBER_TABLE();
      a200 := JTF_NUMBER_TABLE();
      a201 := JTF_VARCHAR2_TABLE_100();
      a202 := JTF_VARCHAR2_TABLE_100();
      a203 := JTF_VARCHAR2_TABLE_300();
      a204 := JTF_VARCHAR2_TABLE_300();
      a205 := JTF_NUMBER_TABLE();
      a206 := JTF_NUMBER_TABLE();
      a207 := JTF_NUMBER_TABLE();
      a208 := JTF_NUMBER_TABLE();
      a209 := JTF_VARCHAR2_TABLE_300();
      a210 := JTF_VARCHAR2_TABLE_300();
      a211 := JTF_VARCHAR2_TABLE_300();
      a212 := JTF_VARCHAR2_TABLE_300();
      a213 := JTF_VARCHAR2_TABLE_100();
      a214 := JTF_VARCHAR2_TABLE_100();
      a215 := JTF_VARCHAR2_TABLE_100();
      a216 := JTF_VARCHAR2_TABLE_100();
      a217 := JTF_VARCHAR2_TABLE_100();
      a218 := JTF_VARCHAR2_TABLE_100();
      a219 := JTF_VARCHAR2_TABLE_100();
      a220 := JTF_VARCHAR2_TABLE_100();
      a221 := JTF_NUMBER_TABLE();
      a222 := JTF_NUMBER_TABLE();
      a223 := JTF_VARCHAR2_TABLE_100();
      a224 := JTF_VARCHAR2_TABLE_100();
      a225 := JTF_VARCHAR2_TABLE_100();
      a226 := JTF_VARCHAR2_TABLE_100();
      a227 := JTF_NUMBER_TABLE();
      a228 := JTF_NUMBER_TABLE();
      a229 := JTF_VARCHAR2_TABLE_200();
      a230 := JTF_VARCHAR2_TABLE_200();
      a231 := JTF_VARCHAR2_TABLE_100();
      a232 := JTF_VARCHAR2_TABLE_100();
      a233 := JTF_NUMBER_TABLE();
      a234 := JTF_NUMBER_TABLE();
      a235 := JTF_VARCHAR2_TABLE_100();
      a236 := JTF_VARCHAR2_TABLE_100();
      a237 := JTF_NUMBER_TABLE();
      a238 := JTF_NUMBER_TABLE();
      a239 := JTF_VARCHAR2_TABLE_100();
      a240 := JTF_VARCHAR2_TABLE_100();
      a241 := JTF_NUMBER_TABLE();
      a242 := JTF_NUMBER_TABLE();
      a243 := JTF_DATE_TABLE();
      a244 := JTF_DATE_TABLE();
      a245 := JTF_VARCHAR2_TABLE_300();
      a246 := JTF_VARCHAR2_TABLE_300();
      a247 := JTF_VARCHAR2_TABLE_300();
      a248 := JTF_VARCHAR2_TABLE_300();
      a249 := JTF_VARCHAR2_TABLE_300();
      a250 := JTF_VARCHAR2_TABLE_300();
      a251 := JTF_VARCHAR2_TABLE_300();
      a252 := JTF_VARCHAR2_TABLE_300();
      a253 := JTF_VARCHAR2_TABLE_300();
      a254 := JTF_VARCHAR2_TABLE_300();
      a255 := JTF_VARCHAR2_TABLE_300();
      a256 := JTF_VARCHAR2_TABLE_300();
      a257 := JTF_VARCHAR2_TABLE_300();
      a258 := JTF_VARCHAR2_TABLE_300();
      a259 := JTF_VARCHAR2_TABLE_300();
      a260 := JTF_VARCHAR2_TABLE_300();
      a261 := JTF_VARCHAR2_TABLE_300();
      a262 := JTF_VARCHAR2_TABLE_300();
      a263 := JTF_VARCHAR2_TABLE_300();
      a264 := JTF_VARCHAR2_TABLE_300();
      a265 := JTF_VARCHAR2_TABLE_300();
      a266 := JTF_VARCHAR2_TABLE_300();
      a267 := JTF_VARCHAR2_TABLE_300();
      a268 := JTF_VARCHAR2_TABLE_300();
      a269 := JTF_VARCHAR2_TABLE_300();
      a270 := JTF_VARCHAR2_TABLE_300();
      a271 := JTF_VARCHAR2_TABLE_300();
      a272 := JTF_VARCHAR2_TABLE_300();
      a273 := JTF_VARCHAR2_TABLE_300();
      a274 := JTF_VARCHAR2_TABLE_300();
      a275 := JTF_VARCHAR2_TABLE_100();
      a276 := JTF_VARCHAR2_TABLE_100();
      a277 := JTF_NUMBER_TABLE();
      a278 := JTF_NUMBER_TABLE();
      a279 := JTF_VARCHAR2_TABLE_100();
      a280 := JTF_VARCHAR2_TABLE_100();
      a281 := JTF_NUMBER_TABLE();
      a282 := JTF_NUMBER_TABLE();
      a283 := JTF_NUMBER_TABLE();
      a284 := JTF_NUMBER_TABLE();
      a285 := JTF_VARCHAR2_TABLE_100();
      a286 := JTF_VARCHAR2_TABLE_100();
      a287 := JTF_VARCHAR2_TABLE_100();
      a288 := JTF_VARCHAR2_TABLE_100();
      a289 := JTF_VARCHAR2_TABLE_100();
      a290 := JTF_VARCHAR2_TABLE_300();
      a291 := JTF_VARCHAR2_TABLE_300();
      a292 := JTF_VARCHAR2_TABLE_100();
      a293 := JTF_VARCHAR2_TABLE_100();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        a178.extend(t.count);
        a179.extend(t.count);
        a180.extend(t.count);
        a181.extend(t.count);
        a182.extend(t.count);
        a183.extend(t.count);
        a184.extend(t.count);
        a185.extend(t.count);
        a186.extend(t.count);
        a187.extend(t.count);
        a188.extend(t.count);
        a189.extend(t.count);
        a190.extend(t.count);
        a191.extend(t.count);
        a192.extend(t.count);
        a193.extend(t.count);
        a194.extend(t.count);
        a195.extend(t.count);
        a196.extend(t.count);
        a197.extend(t.count);
        a198.extend(t.count);
        a199.extend(t.count);
        a200.extend(t.count);
        a201.extend(t.count);
        a202.extend(t.count);
        a203.extend(t.count);
        a204.extend(t.count);
        a205.extend(t.count);
        a206.extend(t.count);
        a207.extend(t.count);
        a208.extend(t.count);
        a209.extend(t.count);
        a210.extend(t.count);
        a211.extend(t.count);
        a212.extend(t.count);
        a213.extend(t.count);
        a214.extend(t.count);
        a215.extend(t.count);
        a216.extend(t.count);
        a217.extend(t.count);
        a218.extend(t.count);
        a219.extend(t.count);
        a220.extend(t.count);
        a221.extend(t.count);
        a222.extend(t.count);
        a223.extend(t.count);
        a224.extend(t.count);
        a225.extend(t.count);
        a226.extend(t.count);
        a227.extend(t.count);
        a228.extend(t.count);
        a229.extend(t.count);
        a230.extend(t.count);
        a231.extend(t.count);
        a232.extend(t.count);
        a233.extend(t.count);
        a234.extend(t.count);
        a235.extend(t.count);
        a236.extend(t.count);
        a237.extend(t.count);
        a238.extend(t.count);
        a239.extend(t.count);
        a240.extend(t.count);
        a241.extend(t.count);
        a242.extend(t.count);
        a243.extend(t.count);
        a244.extend(t.count);
        a245.extend(t.count);
        a246.extend(t.count);
        a247.extend(t.count);
        a248.extend(t.count);
        a249.extend(t.count);
        a250.extend(t.count);
        a251.extend(t.count);
        a252.extend(t.count);
        a253.extend(t.count);
        a254.extend(t.count);
        a255.extend(t.count);
        a256.extend(t.count);
        a257.extend(t.count);
        a258.extend(t.count);
        a259.extend(t.count);
        a260.extend(t.count);
        a261.extend(t.count);
        a262.extend(t.count);
        a263.extend(t.count);
        a264.extend(t.count);
        a265.extend(t.count);
        a266.extend(t.count);
        a267.extend(t.count);
        a268.extend(t.count);
        a269.extend(t.count);
        a270.extend(t.count);
        a271.extend(t.count);
        a272.extend(t.count);
        a273.extend(t.count);
        a274.extend(t.count);
        a275.extend(t.count);
        a276.extend(t.count);
        a277.extend(t.count);
        a278.extend(t.count);
        a279.extend(t.count);
        a280.extend(t.count);
        a281.extend(t.count);
        a282.extend(t.count);
        a283.extend(t.count);
        a284.extend(t.count);
        a285.extend(t.count);
        a286.extend(t.count);
        a287.extend(t.count);
        a288.extend(t.count);
        a289.extend(t.count);
        a290.extend(t.count);
        a291.extend(t.count);
        a292.extend(t.count);
        a293.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).old_instance_number;
          a2(indx) := t(ddindx).new_instance_number;
          a3(indx) := t(ddindx).old_external_reference;
          a4(indx) := t(ddindx).new_external_reference;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).old_inventory_item_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).new_inventory_item_id);
          a7(indx) := t(ddindx).old_inventory_revision;
          a8(indx) := t(ddindx).new_inventory_revision;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).old_inv_master_org_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).new_inv_master_org_id);
          a11(indx) := t(ddindx).old_serial_number;
          a12(indx) := t(ddindx).new_serial_number;
          a13(indx) := t(ddindx).old_mfg_serial_number_flag;
          a14(indx) := t(ddindx).new_mfg_serial_number_flag;
          a15(indx) := t(ddindx).old_lot_number;
          a16(indx) := t(ddindx).new_lot_number;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).old_quantity);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).new_quantity);
          a19(indx) := t(ddindx).old_unit_of_measure_name;
          a20(indx) := t(ddindx).new_unit_of_measure_name;
          a21(indx) := t(ddindx).old_unit_of_measure;
          a22(indx) := t(ddindx).new_unit_of_measure;
          a23(indx) := t(ddindx).old_accounting_class;
          a24(indx) := t(ddindx).new_accounting_class;
          a25(indx) := t(ddindx).old_accounting_class_code;
          a26(indx) := t(ddindx).new_accounting_class_code;
          a27(indx) := t(ddindx).old_instance_condition;
          a28(indx) := t(ddindx).new_instance_condition;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).old_instance_condition_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).new_instance_condition_id);
          a31(indx) := t(ddindx).old_instance_status;
          a32(indx) := t(ddindx).new_instance_status;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).old_instance_status_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).new_instance_status_id);
          a35(indx) := t(ddindx).old_customer_view_flag;
          a36(indx) := t(ddindx).new_customer_view_flag;
          a37(indx) := t(ddindx).old_merchant_view_flag;
          a38(indx) := t(ddindx).new_merchant_view_flag;
          a39(indx) := t(ddindx).old_sellable_flag;
          a40(indx) := t(ddindx).new_sellable_flag;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).old_system_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).new_system_id);
          a43(indx) := t(ddindx).old_system_name;
          a44(indx) := t(ddindx).new_system_name;
          a45(indx) := t(ddindx).old_instance_type_code;
          a46(indx) := t(ddindx).new_instance_type_code;
          a47(indx) := t(ddindx).old_instance_type_name;
          a48(indx) := t(ddindx).new_instance_type_name;
          a49(indx) := t(ddindx).old_active_start_date;
          a50(indx) := t(ddindx).new_active_start_date;
          a51(indx) := t(ddindx).old_active_end_date;
          a52(indx) := t(ddindx).new_active_end_date;
          a53(indx) := t(ddindx).old_location_type_code;
          a54(indx) := t(ddindx).new_location_type_code;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).old_location_id);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).new_location_id);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).old_inv_organization_id);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).new_inv_organization_id);
          a59(indx) := t(ddindx).old_inv_organization_name;
          a60(indx) := t(ddindx).new_inv_organization_name;
          a61(indx) := t(ddindx).old_inv_subinventory_name;
          a62(indx) := t(ddindx).new_inv_subinventory_name;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).old_inv_locator_id);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).new_inv_locator_id);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).old_pa_project_id);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).new_pa_project_id);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).old_pa_project_task_id);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).new_pa_project_task_id);
          a69(indx) := t(ddindx).old_pa_project_name;
          a70(indx) := t(ddindx).new_pa_project_name;
          a71(indx) := t(ddindx).old_pa_project_number;
          a72(indx) := t(ddindx).new_pa_project_number;
          a73(indx) := t(ddindx).old_pa_task_name;
          a74(indx) := t(ddindx).new_pa_task_name;
          a75(indx) := t(ddindx).old_pa_task_number;
          a76(indx) := t(ddindx).new_pa_task_number;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).old_in_transit_order_line_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).new_in_transit_order_line_id);
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).old_in_transit_order_line_num);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).new_in_transit_order_line_num);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).old_in_transit_order_number);
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).new_in_transit_order_number);
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).old_wip_job_id);
          a84(indx) := rosetta_g_miss_num_map(t(ddindx).new_wip_job_id);
          a85(indx) := t(ddindx).old_wip_entity_name;
          a86(indx) := t(ddindx).new_wip_entity_name;
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).old_po_order_line_id);
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).new_po_order_line_id);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_oe_order_line_id);
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_oe_order_line_id);
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_oe_rma_line_id);
          a92(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_oe_rma_line_id);
          a93(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_po_po_line_id);
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_po_po_line_id);
          a95(indx) := t(ddindx).old_last_oe_po_number;
          a96(indx) := t(ddindx).new_last_oe_po_number;
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_wip_job_id);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_wip_job_id);
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_pa_project_id);
          a100(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_pa_project_id);
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_pa_task_id);
          a102(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_pa_task_id);
          a103(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_oe_agreement_id);
          a104(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_oe_agreement_id);
          a105(indx) := t(ddindx).old_install_date;
          a106(indx) := t(ddindx).new_install_date;
          a107(indx) := t(ddindx).old_manually_created_flag;
          a108(indx) := t(ddindx).new_manually_created_flag;
          a109(indx) := t(ddindx).old_return_by_date;
          a110(indx) := t(ddindx).new_return_by_date;
          a111(indx) := t(ddindx).old_actual_return_date;
          a112(indx) := t(ddindx).new_actual_return_date;
          a113(indx) := t(ddindx).old_creation_complete_flag;
          a114(indx) := t(ddindx).new_creation_complete_flag;
          a115(indx) := t(ddindx).old_completeness_flag;
          a116(indx) := t(ddindx).new_completeness_flag;
          a117(indx) := t(ddindx).old_context;
          a118(indx) := t(ddindx).new_context;
          a119(indx) := t(ddindx).old_attribute1;
          a120(indx) := t(ddindx).new_attribute1;
          a121(indx) := t(ddindx).old_attribute2;
          a122(indx) := t(ddindx).new_attribute2;
          a123(indx) := t(ddindx).old_attribute3;
          a124(indx) := t(ddindx).new_attribute3;
          a125(indx) := t(ddindx).old_attribute4;
          a126(indx) := t(ddindx).new_attribute4;
          a127(indx) := t(ddindx).old_attribute5;
          a128(indx) := t(ddindx).new_attribute5;
          a129(indx) := t(ddindx).old_attribute6;
          a130(indx) := t(ddindx).new_attribute6;
          a131(indx) := t(ddindx).old_attribute7;
          a132(indx) := t(ddindx).new_attribute7;
          a133(indx) := t(ddindx).old_attribute8;
          a134(indx) := t(ddindx).new_attribute8;
          a135(indx) := t(ddindx).old_attribute9;
          a136(indx) := t(ddindx).new_attribute9;
          a137(indx) := t(ddindx).old_attribute10;
          a138(indx) := t(ddindx).new_attribute10;
          a139(indx) := t(ddindx).old_attribute11;
          a140(indx) := t(ddindx).new_attribute11;
          a141(indx) := t(ddindx).old_attribute12;
          a142(indx) := t(ddindx).new_attribute12;
          a143(indx) := t(ddindx).old_attribute13;
          a144(indx) := t(ddindx).new_attribute13;
          a145(indx) := t(ddindx).old_attribute14;
          a146(indx) := t(ddindx).new_attribute14;
          a147(indx) := t(ddindx).old_attribute15;
          a148(indx) := t(ddindx).new_attribute15;
          a149(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_txn_line_detail_id);
          a150(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_txn_line_detail_id);
          a151(indx) := t(ddindx).old_install_location_type_code;
          a152(indx) := t(ddindx).new_install_location_type_code;
          a153(indx) := rosetta_g_miss_num_map(t(ddindx).old_install_location_id);
          a154(indx) := rosetta_g_miss_num_map(t(ddindx).new_install_location_id);
          a155(indx) := t(ddindx).old_instance_usage_code;
          a156(indx) := t(ddindx).new_instance_usage_code;
          a157(indx) := t(ddindx).old_current_loc_address1;
          a158(indx) := t(ddindx).new_current_loc_address1;
          a159(indx) := t(ddindx).old_current_loc_address2;
          a160(indx) := t(ddindx).new_current_loc_address2;
          a161(indx) := t(ddindx).old_current_loc_address3;
          a162(indx) := t(ddindx).new_current_loc_address3;
          a163(indx) := t(ddindx).old_current_loc_address4;
          a164(indx) := t(ddindx).new_current_loc_address4;
          a165(indx) := t(ddindx).old_current_loc_city;
          a166(indx) := t(ddindx).new_current_loc_city;
          a167(indx) := t(ddindx).old_current_loc_postal_code;
          a168(indx) := t(ddindx).new_current_loc_postal_code;
          a169(indx) := t(ddindx).old_current_loc_country;
          a170(indx) := t(ddindx).new_current_loc_country;
          a171(indx) := rosetta_g_miss_num_map(t(ddindx).old_sales_order_number);
          a172(indx) := rosetta_g_miss_num_map(t(ddindx).new_sales_order_number);
          a173(indx) := rosetta_g_miss_num_map(t(ddindx).old_sales_order_line_number);
          a174(indx) := rosetta_g_miss_num_map(t(ddindx).new_sales_order_line_number);
          a175(indx) := t(ddindx).old_sales_order_date;
          a176(indx) := t(ddindx).new_sales_order_date;
          a177(indx) := t(ddindx).old_purchase_order_number;
          a178(indx) := t(ddindx).new_purchase_order_number;
          a179(indx) := t(ddindx).old_instance_usage_name;
          a180(indx) := t(ddindx).new_instance_usage_name;
          a181(indx) := t(ddindx).old_current_loc_state;
          a182(indx) := t(ddindx).new_current_loc_state;
          a183(indx) := t(ddindx).old_install_loc_address1;
          a184(indx) := t(ddindx).new_install_loc_address1;
          a185(indx) := t(ddindx).old_install_loc_address2;
          a186(indx) := t(ddindx).new_install_loc_address2;
          a187(indx) := t(ddindx).old_install_loc_address3;
          a188(indx) := t(ddindx).new_install_loc_address3;
          a189(indx) := t(ddindx).old_install_loc_address4;
          a190(indx) := t(ddindx).new_install_loc_address4;
          a191(indx) := t(ddindx).old_install_loc_city;
          a192(indx) := t(ddindx).new_install_loc_city;
          a193(indx) := t(ddindx).old_install_loc_state;
          a194(indx) := t(ddindx).new_install_loc_state;
          a195(indx) := t(ddindx).old_install_loc_postal_code;
          a196(indx) := t(ddindx).new_install_loc_postal_code;
          a197(indx) := t(ddindx).old_install_loc_country;
          a198(indx) := t(ddindx).new_install_loc_country;
          a199(indx) := rosetta_g_miss_num_map(t(ddindx).old_config_inst_rev_num);
          a200(indx) := rosetta_g_miss_num_map(t(ddindx).new_config_inst_rev_num);
          a201(indx) := t(ddindx).old_config_valid_status;
          a202(indx) := t(ddindx).new_config_valid_status;
          a203(indx) := t(ddindx).old_instance_description;
          a204(indx) := t(ddindx).new_instance_description;
          a205(indx) := rosetta_g_miss_num_map(t(ddindx).instance_history_id);
          a206(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a207(indx) := rosetta_g_miss_num_map(t(ddindx).old_last_vld_organization_id);
          a208(indx) := rosetta_g_miss_num_map(t(ddindx).new_last_vld_organization_id);
          a209(indx) := t(ddindx).old_oe_agreement_name;
          a210(indx) := t(ddindx).new_oe_agreement_name;
          a211(indx) := t(ddindx).old_inv_locator_name;
          a212(indx) := t(ddindx).new_inv_locator_name;
          a213(indx) := t(ddindx).old_current_location_number;
          a214(indx) := t(ddindx).new_current_location_number;
          a215(indx) := t(ddindx).old_install_location_number;
          a216(indx) := t(ddindx).new_install_location_number;
          a217(indx) := t(ddindx).old_network_asset_flag;
          a218(indx) := t(ddindx).new_network_asset_flag;
          a219(indx) := t(ddindx).old_maintainable_flag;
          a220(indx) := t(ddindx).new_maintainable_flag;
          a221(indx) := rosetta_g_miss_num_map(t(ddindx).old_pn_location_id);
          a222(indx) := rosetta_g_miss_num_map(t(ddindx).new_pn_location_id);
          a223(indx) := t(ddindx).old_asset_criticality_code;
          a224(indx) := t(ddindx).new_asset_criticality_code;
          a225(indx) := t(ddindx).old_criticality;
          a226(indx) := t(ddindx).new_criticality;
          a227(indx) := rosetta_g_miss_num_map(t(ddindx).old_category_id);
          a228(indx) := rosetta_g_miss_num_map(t(ddindx).new_category_id);
          a229(indx) := t(ddindx).old_category_name;
          a230(indx) := t(ddindx).new_category_name;
          a231(indx) := t(ddindx).old_maintainable;
          a232(indx) := t(ddindx).new_maintainable;
          a233(indx) := rosetta_g_miss_num_map(t(ddindx).old_equipment_gen_object_id);
          a234(indx) := rosetta_g_miss_num_map(t(ddindx).new_equipment_gen_object_id);
          a235(indx) := t(ddindx).old_instantiation_flag;
          a236(indx) := t(ddindx).new_instantiation_flag;
          a237(indx) := rosetta_g_miss_num_map(t(ddindx).old_linear_location_id);
          a238(indx) := rosetta_g_miss_num_map(t(ddindx).new_linear_location_id);
          a239(indx) := t(ddindx).old_operational_log_flag;
          a240(indx) := t(ddindx).new_operational_log_flag;
          a241(indx) := rosetta_g_miss_num_map(t(ddindx).old_checkin_status);
          a242(indx) := rosetta_g_miss_num_map(t(ddindx).new_checkin_status);
          a243(indx) := t(ddindx).old_supplier_warranty_exp_date;
          a244(indx) := t(ddindx).new_supplier_warranty_exp_date;
          a245(indx) := t(ddindx).old_attribute16;
          a246(indx) := t(ddindx).new_attribute16;
          a247(indx) := t(ddindx).old_attribute17;
          a248(indx) := t(ddindx).new_attribute17;
          a249(indx) := t(ddindx).old_attribute18;
          a250(indx) := t(ddindx).new_attribute18;
          a251(indx) := t(ddindx).old_attribute19;
          a252(indx) := t(ddindx).new_attribute19;
          a253(indx) := t(ddindx).old_attribute20;
          a254(indx) := t(ddindx).new_attribute20;
          a255(indx) := t(ddindx).old_attribute21;
          a256(indx) := t(ddindx).new_attribute21;
          a257(indx) := t(ddindx).old_attribute22;
          a258(indx) := t(ddindx).new_attribute22;
          a259(indx) := t(ddindx).old_attribute23;
          a260(indx) := t(ddindx).new_attribute23;
          a261(indx) := t(ddindx).old_attribute24;
          a262(indx) := t(ddindx).new_attribute24;
          a263(indx) := t(ddindx).old_attribute25;
          a264(indx) := t(ddindx).new_attribute25;
          a265(indx) := t(ddindx).old_attribute26;
          a266(indx) := t(ddindx).new_attribute26;
          a267(indx) := t(ddindx).old_attribute27;
          a268(indx) := t(ddindx).new_attribute27;
          a269(indx) := t(ddindx).old_attribute28;
          a270(indx) := t(ddindx).new_attribute28;
          a271(indx) := t(ddindx).old_attribute29;
          a272(indx) := t(ddindx).new_attribute29;
          a273(indx) := t(ddindx).old_attribute30;
          a274(indx) := t(ddindx).new_attribute30;
          a275(indx) := t(ddindx).old_payables_currency_code;
          a276(indx) := t(ddindx).new_payables_currency_code;
          a277(indx) := rosetta_g_miss_num_map(t(ddindx).old_purchase_unit_price);
          a278(indx) := rosetta_g_miss_num_map(t(ddindx).new_purchase_unit_price);
          a279(indx) := t(ddindx).old_purchase_currency_code;
          a280(indx) := t(ddindx).new_purchase_currency_code;
          a281(indx) := rosetta_g_miss_num_map(t(ddindx).old_payables_unit_price);
          a282(indx) := rosetta_g_miss_num_map(t(ddindx).new_payables_unit_price);
          a283(indx) := rosetta_g_miss_num_map(t(ddindx).old_sales_unit_price);
          a284(indx) := rosetta_g_miss_num_map(t(ddindx).new_sales_unit_price);
          a285(indx) := t(ddindx).old_sales_currency_code;
          a286(indx) := t(ddindx).new_sales_currency_code;
          a287(indx) := t(ddindx).old_operational_status_code;
          a288(indx) := t(ddindx).new_operational_status_code;
          a289(indx) := t(ddindx).full_dump_flag;
          a290(indx) := t(ddindx).old_inventory_item_name;
          a291(indx) := t(ddindx).new_inventory_item_name;
          a292(indx) := t(ddindx).old_source_code;
          a293(indx) := t(ddindx).new_source_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p61;

  procedure rosetta_table_copy_in_p63(t out nocopy csi_datastructures_pub.ins_asset_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
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
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).old_instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).new_instance_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_fa_asset_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).new_fa_asset_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).old_fa_book_type_code := a5(indx);
          t(ddindx).new_fa_book_type_code := a6(indx);
          t(ddindx).old_fa_location_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).new_fa_location_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).old_asset_quantity := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).new_asset_quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).old_update_status := a11(indx);
          t(ddindx).new_update_status := a12(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).old_asset_number := a17(indx);
          t(ddindx).new_asset_number := a18(indx);
          t(ddindx).old_serial_number := a19(indx);
          t(ddindx).new_serial_number := a20(indx);
          t(ddindx).old_tag_number := a21(indx);
          t(ddindx).new_tag_number := a22(indx);
          t(ddindx).old_category := a23(indx);
          t(ddindx).new_category := a24(indx);
          t(ddindx).old_fa_location_segment1 := a25(indx);
          t(ddindx).new_fa_location_segment1 := a26(indx);
          t(ddindx).old_fa_location_segment2 := a27(indx);
          t(ddindx).new_fa_location_segment2 := a28(indx);
          t(ddindx).old_fa_location_segment3 := a29(indx);
          t(ddindx).new_fa_location_segment3 := a30(indx);
          t(ddindx).old_fa_location_segment4 := a31(indx);
          t(ddindx).new_fa_location_segment4 := a32(indx);
          t(ddindx).old_fa_location_segment5 := a33(indx);
          t(ddindx).new_fa_location_segment5 := a34(indx);
          t(ddindx).old_fa_location_segment6 := a35(indx);
          t(ddindx).new_fa_location_segment6 := a36(indx);
          t(ddindx).old_fa_location_segment7 := a37(indx);
          t(ddindx).new_fa_location_segment7 := a38(indx);
          t(ddindx).old_date_placed_in_service := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).new_date_placed_in_service := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).old_description := a41(indx);
          t(ddindx).new_description := a42(indx);
          t(ddindx).old_employee_name := a43(indx);
          t(ddindx).new_employee_name := a44(indx);
          t(ddindx).old_expense_account_number := a45(indx);
          t(ddindx).new_expense_account_number := a46(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).instance_asset_history_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).old_fa_sync_flag := a50(indx);
          t(ddindx).new_fa_sync_flag := a51(indx);
          t(ddindx).old_fa_mass_addition_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).new_fa_mass_addition_id := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).old_creation_complete_flag := a54(indx);
          t(ddindx).new_creation_complete_flag := a55(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p63;
  procedure rosetta_table_copy_out_p63(t csi_datastructures_pub.ins_asset_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
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
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
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
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_asset_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).old_instance_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).new_instance_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).old_fa_asset_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).new_fa_asset_id);
          a5(indx) := t(ddindx).old_fa_book_type_code;
          a6(indx) := t(ddindx).new_fa_book_type_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).old_fa_location_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).new_fa_location_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).old_asset_quantity);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).new_asset_quantity);
          a11(indx) := t(ddindx).old_update_status;
          a12(indx) := t(ddindx).new_update_status;
          a13(indx) := t(ddindx).old_active_start_date;
          a14(indx) := t(ddindx).new_active_start_date;
          a15(indx) := t(ddindx).old_active_end_date;
          a16(indx) := t(ddindx).new_active_end_date;
          a17(indx) := t(ddindx).old_asset_number;
          a18(indx) := t(ddindx).new_asset_number;
          a19(indx) := t(ddindx).old_serial_number;
          a20(indx) := t(ddindx).new_serial_number;
          a21(indx) := t(ddindx).old_tag_number;
          a22(indx) := t(ddindx).new_tag_number;
          a23(indx) := t(ddindx).old_category;
          a24(indx) := t(ddindx).new_category;
          a25(indx) := t(ddindx).old_fa_location_segment1;
          a26(indx) := t(ddindx).new_fa_location_segment1;
          a27(indx) := t(ddindx).old_fa_location_segment2;
          a28(indx) := t(ddindx).new_fa_location_segment2;
          a29(indx) := t(ddindx).old_fa_location_segment3;
          a30(indx) := t(ddindx).new_fa_location_segment3;
          a31(indx) := t(ddindx).old_fa_location_segment4;
          a32(indx) := t(ddindx).new_fa_location_segment4;
          a33(indx) := t(ddindx).old_fa_location_segment5;
          a34(indx) := t(ddindx).new_fa_location_segment5;
          a35(indx) := t(ddindx).old_fa_location_segment6;
          a36(indx) := t(ddindx).new_fa_location_segment6;
          a37(indx) := t(ddindx).old_fa_location_segment7;
          a38(indx) := t(ddindx).new_fa_location_segment7;
          a39(indx) := t(ddindx).old_date_placed_in_service;
          a40(indx) := t(ddindx).new_date_placed_in_service;
          a41(indx) := t(ddindx).old_description;
          a42(indx) := t(ddindx).new_description;
          a43(indx) := t(ddindx).old_employee_name;
          a44(indx) := t(ddindx).new_employee_name;
          a45(indx) := t(ddindx).old_expense_account_number;
          a46(indx) := t(ddindx).new_expense_account_number;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).instance_asset_history_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a50(indx) := t(ddindx).old_fa_sync_flag;
          a51(indx) := t(ddindx).new_fa_sync_flag;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).old_fa_mass_addition_id);
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).new_fa_mass_addition_id);
          a54(indx) := t(ddindx).old_creation_complete_flag;
          a55(indx) := t(ddindx).new_creation_complete_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p63;

  procedure rosetta_table_copy_in_p65(t out nocopy csi_datastructures_pub.ext_attrib_val_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).old_attribute_value := a2(indx);
          t(ddindx).new_attribute_value := a3(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).old_context := a8(indx);
          t(ddindx).new_context := a9(indx);
          t(ddindx).old_attribute1 := a10(indx);
          t(ddindx).new_attribute1 := a11(indx);
          t(ddindx).old_attribute2 := a12(indx);
          t(ddindx).new_attribute2 := a13(indx);
          t(ddindx).old_attribute3 := a14(indx);
          t(ddindx).new_attribute3 := a15(indx);
          t(ddindx).old_attribute4 := a16(indx);
          t(ddindx).new_attribute4 := a17(indx);
          t(ddindx).old_attribute5 := a18(indx);
          t(ddindx).new_attribute5 := a19(indx);
          t(ddindx).old_attribute6 := a20(indx);
          t(ddindx).new_attribute6 := a21(indx);
          t(ddindx).old_attribute7 := a22(indx);
          t(ddindx).new_attribute7 := a23(indx);
          t(ddindx).old_attribute8 := a24(indx);
          t(ddindx).new_attribute8 := a25(indx);
          t(ddindx).old_attribute9 := a26(indx);
          t(ddindx).new_attribute9 := a27(indx);
          t(ddindx).old_attribute10 := a28(indx);
          t(ddindx).new_attribute10 := a29(indx);
          t(ddindx).old_attribute11 := a30(indx);
          t(ddindx).new_attribute11 := a31(indx);
          t(ddindx).old_attribute12 := a32(indx);
          t(ddindx).new_attribute12 := a33(indx);
          t(ddindx).old_attribute13 := a34(indx);
          t(ddindx).new_attribute13 := a35(indx);
          t(ddindx).old_attribute14 := a36(indx);
          t(ddindx).new_attribute14 := a37(indx);
          t(ddindx).old_attribute15 := a38(indx);
          t(ddindx).new_attribute15 := a39(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).attribute_code := a41(indx);
          t(ddindx).attribute_value_history_id := rosetta_g_miss_num_map(a42(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p65;
  procedure rosetta_table_copy_out_p65(t csi_datastructures_pub.ext_attrib_val_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_value_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a2(indx) := t(ddindx).old_attribute_value;
          a3(indx) := t(ddindx).new_attribute_value;
          a4(indx) := t(ddindx).old_active_start_date;
          a5(indx) := t(ddindx).new_active_start_date;
          a6(indx) := t(ddindx).old_active_end_date;
          a7(indx) := t(ddindx).new_active_end_date;
          a8(indx) := t(ddindx).old_context;
          a9(indx) := t(ddindx).new_context;
          a10(indx) := t(ddindx).old_attribute1;
          a11(indx) := t(ddindx).new_attribute1;
          a12(indx) := t(ddindx).old_attribute2;
          a13(indx) := t(ddindx).new_attribute2;
          a14(indx) := t(ddindx).old_attribute3;
          a15(indx) := t(ddindx).new_attribute3;
          a16(indx) := t(ddindx).old_attribute4;
          a17(indx) := t(ddindx).new_attribute4;
          a18(indx) := t(ddindx).old_attribute5;
          a19(indx) := t(ddindx).new_attribute5;
          a20(indx) := t(ddindx).old_attribute6;
          a21(indx) := t(ddindx).new_attribute6;
          a22(indx) := t(ddindx).old_attribute7;
          a23(indx) := t(ddindx).new_attribute7;
          a24(indx) := t(ddindx).old_attribute8;
          a25(indx) := t(ddindx).new_attribute8;
          a26(indx) := t(ddindx).old_attribute9;
          a27(indx) := t(ddindx).new_attribute9;
          a28(indx) := t(ddindx).old_attribute10;
          a29(indx) := t(ddindx).new_attribute10;
          a30(indx) := t(ddindx).old_attribute11;
          a31(indx) := t(ddindx).new_attribute11;
          a32(indx) := t(ddindx).old_attribute12;
          a33(indx) := t(ddindx).new_attribute12;
          a34(indx) := t(ddindx).old_attribute13;
          a35(indx) := t(ddindx).new_attribute13;
          a36(indx) := t(ddindx).old_attribute14;
          a37(indx) := t(ddindx).new_attribute14;
          a38(indx) := t(ddindx).old_attribute15;
          a39(indx) := t(ddindx).new_attribute15;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a41(indx) := t(ddindx).attribute_code;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_value_history_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p65;

  procedure rosetta_table_copy_in_p67(t out nocopy csi_datastructures_pub.party_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_400
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_400
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_2000
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_400
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_400
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_2000
    , a87 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_party_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_party_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_party_source_table := a3(indx);
          t(ddindx).new_party_source_table := a4(indx);
          t(ddindx).old_party_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).new_party_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).old_relationship_type_code := a7(indx);
          t(ddindx).new_relationship_type_code := a8(indx);
          t(ddindx).old_contact_flag := a9(indx);
          t(ddindx).new_contact_flag := a10(indx);
          t(ddindx).old_contact_ip_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).new_contact_ip_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).old_context := a17(indx);
          t(ddindx).new_context := a18(indx);
          t(ddindx).old_attribute1 := a19(indx);
          t(ddindx).new_attribute1 := a20(indx);
          t(ddindx).old_attribute2 := a21(indx);
          t(ddindx).new_attribute2 := a22(indx);
          t(ddindx).old_attribute3 := a23(indx);
          t(ddindx).new_attribute3 := a24(indx);
          t(ddindx).old_attribute4 := a25(indx);
          t(ddindx).new_attribute4 := a26(indx);
          t(ddindx).old_attribute5 := a27(indx);
          t(ddindx).new_attribute5 := a28(indx);
          t(ddindx).old_attribute6 := a29(indx);
          t(ddindx).new_attribute6 := a30(indx);
          t(ddindx).old_attribute7 := a31(indx);
          t(ddindx).new_attribute7 := a32(indx);
          t(ddindx).old_attribute8 := a33(indx);
          t(ddindx).new_attribute8 := a34(indx);
          t(ddindx).old_attribute9 := a35(indx);
          t(ddindx).new_attribute9 := a36(indx);
          t(ddindx).old_attribute10 := a37(indx);
          t(ddindx).new_attribute10 := a38(indx);
          t(ddindx).old_attribute11 := a39(indx);
          t(ddindx).new_attribute11 := a40(indx);
          t(ddindx).old_attribute12 := a41(indx);
          t(ddindx).new_attribute12 := a42(indx);
          t(ddindx).old_attribute13 := a43(indx);
          t(ddindx).new_attribute13 := a44(indx);
          t(ddindx).old_attribute14 := a45(indx);
          t(ddindx).new_attribute14 := a46(indx);
          t(ddindx).old_attribute15 := a47(indx);
          t(ddindx).new_attribute15 := a48(indx);
          t(ddindx).full_dump_flag := a49(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).old_preferred_flag := a51(indx);
          t(ddindx).new_preferred_flag := a52(indx);
          t(ddindx).old_primary_flag := a53(indx);
          t(ddindx).new_primary_flag := a54(indx);
          t(ddindx).old_party_number := a55(indx);
          t(ddindx).old_party_name := a56(indx);
          t(ddindx).old_party_type := a57(indx);
          t(ddindx).old_contact_party_number := a58(indx);
          t(ddindx).old_contact_party_name := a59(indx);
          t(ddindx).old_contact_party_type := a60(indx);
          t(ddindx).old_contact_address1 := a61(indx);
          t(ddindx).old_contact_address2 := a62(indx);
          t(ddindx).old_contact_address3 := a63(indx);
          t(ddindx).old_contact_address4 := a64(indx);
          t(ddindx).old_contact_city := a65(indx);
          t(ddindx).old_contact_state := a66(indx);
          t(ddindx).old_contact_postal_code := a67(indx);
          t(ddindx).old_contact_country := a68(indx);
          t(ddindx).old_contact_work_phone_num := a69(indx);
          t(ddindx).old_contact_email_address := a70(indx);
          t(ddindx).new_party_number := a71(indx);
          t(ddindx).new_party_name := a72(indx);
          t(ddindx).new_party_type := a73(indx);
          t(ddindx).new_contact_party_number := a74(indx);
          t(ddindx).new_contact_party_name := a75(indx);
          t(ddindx).new_contact_party_type := a76(indx);
          t(ddindx).new_contact_address1 := a77(indx);
          t(ddindx).new_contact_address2 := a78(indx);
          t(ddindx).new_contact_address3 := a79(indx);
          t(ddindx).new_contact_address4 := a80(indx);
          t(ddindx).new_contact_city := a81(indx);
          t(ddindx).new_contact_state := a82(indx);
          t(ddindx).new_contact_postal_code := a83(indx);
          t(ddindx).new_contact_country := a84(indx);
          t(ddindx).new_contact_work_phone_num := a85(indx);
          t(ddindx).new_contact_email_address := a86(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a87(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p67;
  procedure rosetta_table_copy_out_p67(t csi_datastructures_pub.party_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_400
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_400
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_400
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_400
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_2000
    , a87 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_400();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_400();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_2000();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_400();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_400();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_2000();
    a87 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_400();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_400();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_2000();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_400();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_400();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_2000();
      a87 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_party_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := t(ddindx).old_party_source_table;
          a4(indx) := t(ddindx).new_party_source_table;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).old_party_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).new_party_id);
          a7(indx) := t(ddindx).old_relationship_type_code;
          a8(indx) := t(ddindx).new_relationship_type_code;
          a9(indx) := t(ddindx).old_contact_flag;
          a10(indx) := t(ddindx).new_contact_flag;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).old_contact_ip_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).new_contact_ip_id);
          a13(indx) := t(ddindx).old_active_start_date;
          a14(indx) := t(ddindx).new_active_start_date;
          a15(indx) := t(ddindx).old_active_end_date;
          a16(indx) := t(ddindx).new_active_end_date;
          a17(indx) := t(ddindx).old_context;
          a18(indx) := t(ddindx).new_context;
          a19(indx) := t(ddindx).old_attribute1;
          a20(indx) := t(ddindx).new_attribute1;
          a21(indx) := t(ddindx).old_attribute2;
          a22(indx) := t(ddindx).new_attribute2;
          a23(indx) := t(ddindx).old_attribute3;
          a24(indx) := t(ddindx).new_attribute3;
          a25(indx) := t(ddindx).old_attribute4;
          a26(indx) := t(ddindx).new_attribute4;
          a27(indx) := t(ddindx).old_attribute5;
          a28(indx) := t(ddindx).new_attribute5;
          a29(indx) := t(ddindx).old_attribute6;
          a30(indx) := t(ddindx).new_attribute6;
          a31(indx) := t(ddindx).old_attribute7;
          a32(indx) := t(ddindx).new_attribute7;
          a33(indx) := t(ddindx).old_attribute8;
          a34(indx) := t(ddindx).new_attribute8;
          a35(indx) := t(ddindx).old_attribute9;
          a36(indx) := t(ddindx).new_attribute9;
          a37(indx) := t(ddindx).old_attribute10;
          a38(indx) := t(ddindx).new_attribute10;
          a39(indx) := t(ddindx).old_attribute11;
          a40(indx) := t(ddindx).new_attribute11;
          a41(indx) := t(ddindx).old_attribute12;
          a42(indx) := t(ddindx).new_attribute12;
          a43(indx) := t(ddindx).old_attribute13;
          a44(indx) := t(ddindx).new_attribute13;
          a45(indx) := t(ddindx).old_attribute14;
          a46(indx) := t(ddindx).new_attribute14;
          a47(indx) := t(ddindx).old_attribute15;
          a48(indx) := t(ddindx).new_attribute15;
          a49(indx) := t(ddindx).full_dump_flag;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a51(indx) := t(ddindx).old_preferred_flag;
          a52(indx) := t(ddindx).new_preferred_flag;
          a53(indx) := t(ddindx).old_primary_flag;
          a54(indx) := t(ddindx).new_primary_flag;
          a55(indx) := t(ddindx).old_party_number;
          a56(indx) := t(ddindx).old_party_name;
          a57(indx) := t(ddindx).old_party_type;
          a58(indx) := t(ddindx).old_contact_party_number;
          a59(indx) := t(ddindx).old_contact_party_name;
          a60(indx) := t(ddindx).old_contact_party_type;
          a61(indx) := t(ddindx).old_contact_address1;
          a62(indx) := t(ddindx).old_contact_address2;
          a63(indx) := t(ddindx).old_contact_address3;
          a64(indx) := t(ddindx).old_contact_address4;
          a65(indx) := t(ddindx).old_contact_city;
          a66(indx) := t(ddindx).old_contact_state;
          a67(indx) := t(ddindx).old_contact_postal_code;
          a68(indx) := t(ddindx).old_contact_country;
          a69(indx) := t(ddindx).old_contact_work_phone_num;
          a70(indx) := t(ddindx).old_contact_email_address;
          a71(indx) := t(ddindx).new_party_number;
          a72(indx) := t(ddindx).new_party_name;
          a73(indx) := t(ddindx).new_party_type;
          a74(indx) := t(ddindx).new_contact_party_number;
          a75(indx) := t(ddindx).new_contact_party_name;
          a76(indx) := t(ddindx).new_contact_party_type;
          a77(indx) := t(ddindx).new_contact_address1;
          a78(indx) := t(ddindx).new_contact_address2;
          a79(indx) := t(ddindx).new_contact_address3;
          a80(indx) := t(ddindx).new_contact_address4;
          a81(indx) := t(ddindx).new_contact_city;
          a82(indx) := t(ddindx).new_contact_state;
          a83(indx) := t(ddindx).new_contact_postal_code;
          a84(indx) := t(ddindx).new_contact_country;
          a85(indx) := t(ddindx).new_contact_work_phone_num;
          a86(indx) := t(ddindx).new_contact_email_address;
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p67;

  procedure rosetta_table_copy_in_p69(t out nocopy csi_datastructures_pub.account_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ip_account_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).ip_account_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_party_account_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).new_party_account_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).old_relationship_type_code := a5(indx);
          t(ddindx).new_relationship_type_code := a6(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).old_context := a11(indx);
          t(ddindx).new_context := a12(indx);
          t(ddindx).old_attribute1 := a13(indx);
          t(ddindx).new_attribute1 := a14(indx);
          t(ddindx).old_attribute2 := a15(indx);
          t(ddindx).new_attribute2 := a16(indx);
          t(ddindx).old_attribute3 := a17(indx);
          t(ddindx).new_attribute3 := a18(indx);
          t(ddindx).old_attribute4 := a19(indx);
          t(ddindx).new_attribute4 := a20(indx);
          t(ddindx).old_attribute5 := a21(indx);
          t(ddindx).new_attribute5 := a22(indx);
          t(ddindx).old_attribute6 := a23(indx);
          t(ddindx).new_attribute6 := a24(indx);
          t(ddindx).old_attribute7 := a25(indx);
          t(ddindx).new_attribute7 := a26(indx);
          t(ddindx).old_attribute8 := a27(indx);
          t(ddindx).new_attribute8 := a28(indx);
          t(ddindx).old_attribute9 := a29(indx);
          t(ddindx).new_attribute9 := a30(indx);
          t(ddindx).old_attribute10 := a31(indx);
          t(ddindx).new_attribute10 := a32(indx);
          t(ddindx).old_attribute11 := a33(indx);
          t(ddindx).new_attribute11 := a34(indx);
          t(ddindx).old_attribute12 := a35(indx);
          t(ddindx).new_attribute12 := a36(indx);
          t(ddindx).old_attribute13 := a37(indx);
          t(ddindx).new_attribute13 := a38(indx);
          t(ddindx).old_attribute14 := a39(indx);
          t(ddindx).new_attribute14 := a40(indx);
          t(ddindx).old_attribute15 := a41(indx);
          t(ddindx).new_attribute15 := a42(indx);
          t(ddindx).full_dump_flag := a43(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).old_bill_to_address := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).new_bill_to_address := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).old_ship_to_address := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).new_ship_to_address := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).old_party_account_number := a49(indx);
          t(ddindx).old_party_account_name := a50(indx);
          t(ddindx).old_bill_to_location := a51(indx);
          t(ddindx).old_ship_to_location := a52(indx);
          t(ddindx).new_party_account_number := a53(indx);
          t(ddindx).new_party_account_name := a54(indx);
          t(ddindx).new_bill_to_location := a55(indx);
          t(ddindx).new_ship_to_location := a56(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).old_bill_to_address1 := a58(indx);
          t(ddindx).new_bill_to_address1 := a59(indx);
          t(ddindx).old_bill_to_address2 := a60(indx);
          t(ddindx).new_bill_to_address2 := a61(indx);
          t(ddindx).old_bill_to_address3 := a62(indx);
          t(ddindx).new_bill_to_address3 := a63(indx);
          t(ddindx).old_bill_to_address4 := a64(indx);
          t(ddindx).new_bill_to_address4 := a65(indx);
          t(ddindx).old_bill_to_city := a66(indx);
          t(ddindx).new_bill_to_city := a67(indx);
          t(ddindx).old_bill_to_state := a68(indx);
          t(ddindx).new_bill_to_state := a69(indx);
          t(ddindx).old_bill_to_postal_code := a70(indx);
          t(ddindx).new_bill_to_postal_code := a71(indx);
          t(ddindx).old_bill_to_country := a72(indx);
          t(ddindx).new_bill_to_country := a73(indx);
          t(ddindx).old_ship_to_address1 := a74(indx);
          t(ddindx).new_ship_to_address1 := a75(indx);
          t(ddindx).old_ship_to_address2 := a76(indx);
          t(ddindx).new_ship_to_address2 := a77(indx);
          t(ddindx).old_ship_to_address3 := a78(indx);
          t(ddindx).new_ship_to_address3 := a79(indx);
          t(ddindx).old_ship_to_address4 := a80(indx);
          t(ddindx).new_ship_to_address4 := a81(indx);
          t(ddindx).old_ship_to_city := a82(indx);
          t(ddindx).new_ship_to_city := a83(indx);
          t(ddindx).old_ship_to_state := a84(indx);
          t(ddindx).new_ship_to_state := a85(indx);
          t(ddindx).old_ship_to_postal_code := a86(indx);
          t(ddindx).new_ship_to_postal_code := a87(indx);
          t(ddindx).old_ship_to_country := a88(indx);
          t(ddindx).new_ship_to_country := a89(indx);
          t(ddindx).old_instance_party_id := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).new_instance_party_id := rosetta_g_miss_num_map(a91(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p69;
  procedure rosetta_table_copy_out_p69(t csi_datastructures_pub.account_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_300
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_100
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ip_account_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).ip_account_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).old_party_account_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).new_party_account_id);
          a5(indx) := t(ddindx).old_relationship_type_code;
          a6(indx) := t(ddindx).new_relationship_type_code;
          a7(indx) := t(ddindx).old_active_start_date;
          a8(indx) := t(ddindx).new_active_start_date;
          a9(indx) := t(ddindx).old_active_end_date;
          a10(indx) := t(ddindx).new_active_end_date;
          a11(indx) := t(ddindx).old_context;
          a12(indx) := t(ddindx).new_context;
          a13(indx) := t(ddindx).old_attribute1;
          a14(indx) := t(ddindx).new_attribute1;
          a15(indx) := t(ddindx).old_attribute2;
          a16(indx) := t(ddindx).new_attribute2;
          a17(indx) := t(ddindx).old_attribute3;
          a18(indx) := t(ddindx).new_attribute3;
          a19(indx) := t(ddindx).old_attribute4;
          a20(indx) := t(ddindx).new_attribute4;
          a21(indx) := t(ddindx).old_attribute5;
          a22(indx) := t(ddindx).new_attribute5;
          a23(indx) := t(ddindx).old_attribute6;
          a24(indx) := t(ddindx).new_attribute6;
          a25(indx) := t(ddindx).old_attribute7;
          a26(indx) := t(ddindx).new_attribute7;
          a27(indx) := t(ddindx).old_attribute8;
          a28(indx) := t(ddindx).new_attribute8;
          a29(indx) := t(ddindx).old_attribute9;
          a30(indx) := t(ddindx).new_attribute9;
          a31(indx) := t(ddindx).old_attribute10;
          a32(indx) := t(ddindx).new_attribute10;
          a33(indx) := t(ddindx).old_attribute11;
          a34(indx) := t(ddindx).new_attribute11;
          a35(indx) := t(ddindx).old_attribute12;
          a36(indx) := t(ddindx).new_attribute12;
          a37(indx) := t(ddindx).old_attribute13;
          a38(indx) := t(ddindx).new_attribute13;
          a39(indx) := t(ddindx).old_attribute14;
          a40(indx) := t(ddindx).new_attribute14;
          a41(indx) := t(ddindx).old_attribute15;
          a42(indx) := t(ddindx).new_attribute15;
          a43(indx) := t(ddindx).full_dump_flag;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).old_bill_to_address);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).new_bill_to_address);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).old_ship_to_address);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).new_ship_to_address);
          a49(indx) := t(ddindx).old_party_account_number;
          a50(indx) := t(ddindx).old_party_account_name;
          a51(indx) := t(ddindx).old_bill_to_location;
          a52(indx) := t(ddindx).old_ship_to_location;
          a53(indx) := t(ddindx).new_party_account_number;
          a54(indx) := t(ddindx).new_party_account_name;
          a55(indx) := t(ddindx).new_bill_to_location;
          a56(indx) := t(ddindx).new_ship_to_location;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a58(indx) := t(ddindx).old_bill_to_address1;
          a59(indx) := t(ddindx).new_bill_to_address1;
          a60(indx) := t(ddindx).old_bill_to_address2;
          a61(indx) := t(ddindx).new_bill_to_address2;
          a62(indx) := t(ddindx).old_bill_to_address3;
          a63(indx) := t(ddindx).new_bill_to_address3;
          a64(indx) := t(ddindx).old_bill_to_address4;
          a65(indx) := t(ddindx).new_bill_to_address4;
          a66(indx) := t(ddindx).old_bill_to_city;
          a67(indx) := t(ddindx).new_bill_to_city;
          a68(indx) := t(ddindx).old_bill_to_state;
          a69(indx) := t(ddindx).new_bill_to_state;
          a70(indx) := t(ddindx).old_bill_to_postal_code;
          a71(indx) := t(ddindx).new_bill_to_postal_code;
          a72(indx) := t(ddindx).old_bill_to_country;
          a73(indx) := t(ddindx).new_bill_to_country;
          a74(indx) := t(ddindx).old_ship_to_address1;
          a75(indx) := t(ddindx).new_ship_to_address1;
          a76(indx) := t(ddindx).old_ship_to_address2;
          a77(indx) := t(ddindx).new_ship_to_address2;
          a78(indx) := t(ddindx).old_ship_to_address3;
          a79(indx) := t(ddindx).new_ship_to_address3;
          a80(indx) := t(ddindx).old_ship_to_address4;
          a81(indx) := t(ddindx).new_ship_to_address4;
          a82(indx) := t(ddindx).old_ship_to_city;
          a83(indx) := t(ddindx).new_ship_to_city;
          a84(indx) := t(ddindx).old_ship_to_state;
          a85(indx) := t(ddindx).new_ship_to_state;
          a86(indx) := t(ddindx).old_ship_to_postal_code;
          a87(indx) := t(ddindx).new_ship_to_postal_code;
          a88(indx) := t(ddindx).old_ship_to_country;
          a89(indx) := t(ddindx).new_ship_to_country;
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).old_instance_party_id);
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).new_instance_party_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p69;

  procedure rosetta_table_copy_in_p71(t out nocopy csi_datastructures_pub.org_units_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_ou_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_ou_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_operating_unit_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).new_operating_unit_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).old_relationship_type_code := a5(indx);
          t(ddindx).new_relationship_type_code := a6(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).old_context := a11(indx);
          t(ddindx).new_context := a12(indx);
          t(ddindx).old_attribute1 := a13(indx);
          t(ddindx).new_attribute1 := a14(indx);
          t(ddindx).old_attribute2 := a15(indx);
          t(ddindx).new_attribute2 := a16(indx);
          t(ddindx).old_attribute3 := a17(indx);
          t(ddindx).new_attribute3 := a18(indx);
          t(ddindx).old_attribute4 := a19(indx);
          t(ddindx).new_attribute4 := a20(indx);
          t(ddindx).old_attribute5 := a21(indx);
          t(ddindx).new_attribute5 := a22(indx);
          t(ddindx).old_attribute6 := a23(indx);
          t(ddindx).new_attribute6 := a24(indx);
          t(ddindx).old_attribute7 := a25(indx);
          t(ddindx).new_attribute7 := a26(indx);
          t(ddindx).old_attribute8 := a27(indx);
          t(ddindx).new_attribute8 := a28(indx);
          t(ddindx).old_attribute9 := a29(indx);
          t(ddindx).new_attribute9 := a30(indx);
          t(ddindx).old_attribute10 := a31(indx);
          t(ddindx).new_attribute10 := a32(indx);
          t(ddindx).old_attribute11 := a33(indx);
          t(ddindx).new_attribute11 := a34(indx);
          t(ddindx).old_attribute12 := a35(indx);
          t(ddindx).new_attribute12 := a36(indx);
          t(ddindx).old_attribute13 := a37(indx);
          t(ddindx).new_attribute13 := a38(indx);
          t(ddindx).old_attribute14 := a39(indx);
          t(ddindx).new_attribute14 := a40(indx);
          t(ddindx).old_attribute15 := a41(indx);
          t(ddindx).new_attribute15 := a42(indx);
          t(ddindx).full_dump_flag := a43(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).new_operating_unit_name := a45(indx);
          t(ddindx).old_operating_unit_name := a46(indx);
          t(ddindx).instance_id := rosetta_g_miss_num_map(a47(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p71;
  procedure rosetta_table_copy_out_p71(t csi_datastructures_pub.org_units_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_ou_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_ou_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).old_operating_unit_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).new_operating_unit_id);
          a5(indx) := t(ddindx).old_relationship_type_code;
          a6(indx) := t(ddindx).new_relationship_type_code;
          a7(indx) := t(ddindx).old_active_start_date;
          a8(indx) := t(ddindx).new_active_start_date;
          a9(indx) := t(ddindx).old_active_end_date;
          a10(indx) := t(ddindx).new_active_end_date;
          a11(indx) := t(ddindx).old_context;
          a12(indx) := t(ddindx).new_context;
          a13(indx) := t(ddindx).old_attribute1;
          a14(indx) := t(ddindx).new_attribute1;
          a15(indx) := t(ddindx).old_attribute2;
          a16(indx) := t(ddindx).new_attribute2;
          a17(indx) := t(ddindx).old_attribute3;
          a18(indx) := t(ddindx).new_attribute3;
          a19(indx) := t(ddindx).old_attribute4;
          a20(indx) := t(ddindx).new_attribute4;
          a21(indx) := t(ddindx).old_attribute5;
          a22(indx) := t(ddindx).new_attribute5;
          a23(indx) := t(ddindx).old_attribute6;
          a24(indx) := t(ddindx).new_attribute6;
          a25(indx) := t(ddindx).old_attribute7;
          a26(indx) := t(ddindx).new_attribute7;
          a27(indx) := t(ddindx).old_attribute8;
          a28(indx) := t(ddindx).new_attribute8;
          a29(indx) := t(ddindx).old_attribute9;
          a30(indx) := t(ddindx).new_attribute9;
          a31(indx) := t(ddindx).old_attribute10;
          a32(indx) := t(ddindx).new_attribute10;
          a33(indx) := t(ddindx).old_attribute11;
          a34(indx) := t(ddindx).new_attribute11;
          a35(indx) := t(ddindx).old_attribute12;
          a36(indx) := t(ddindx).new_attribute12;
          a37(indx) := t(ddindx).old_attribute13;
          a38(indx) := t(ddindx).new_attribute13;
          a39(indx) := t(ddindx).old_attribute14;
          a40(indx) := t(ddindx).new_attribute14;
          a41(indx) := t(ddindx).old_attribute15;
          a42(indx) := t(ddindx).new_attribute15;
          a43(indx) := t(ddindx).full_dump_flag;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a45(indx) := t(ddindx).new_operating_unit_name;
          a46(indx) := t(ddindx).old_operating_unit_name;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p71;

  procedure rosetta_table_copy_in_p73(t out nocopy csi_datastructures_pub.version_label_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).version_label_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).version_label_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_version_label := a3(indx);
          t(ddindx).new_version_label := a4(indx);
          t(ddindx).old_description := a5(indx);
          t(ddindx).new_description := a6(indx);
          t(ddindx).old_date_time_stamp := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).new_date_time_stamp := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).old_context := a13(indx);
          t(ddindx).new_context := a14(indx);
          t(ddindx).old_attribute1 := a15(indx);
          t(ddindx).new_attribute1 := a16(indx);
          t(ddindx).old_attribute2 := a17(indx);
          t(ddindx).new_attribute2 := a18(indx);
          t(ddindx).old_attribute3 := a19(indx);
          t(ddindx).new_attribute3 := a20(indx);
          t(ddindx).old_attribute4 := a21(indx);
          t(ddindx).new_attribute4 := a22(indx);
          t(ddindx).old_attribute5 := a23(indx);
          t(ddindx).new_attribute5 := a24(indx);
          t(ddindx).old_attribute6 := a25(indx);
          t(ddindx).new_attribute6 := a26(indx);
          t(ddindx).old_attribute7 := a27(indx);
          t(ddindx).new_attribute7 := a28(indx);
          t(ddindx).old_attribute8 := a29(indx);
          t(ddindx).new_attribute8 := a30(indx);
          t(ddindx).old_attribute9 := a31(indx);
          t(ddindx).new_attribute9 := a32(indx);
          t(ddindx).old_attribute10 := a33(indx);
          t(ddindx).new_attribute10 := a34(indx);
          t(ddindx).old_attribute11 := a35(indx);
          t(ddindx).new_attribute11 := a36(indx);
          t(ddindx).old_attribute12 := a37(indx);
          t(ddindx).new_attribute12 := a38(indx);
          t(ddindx).old_attribute13 := a39(indx);
          t(ddindx).new_attribute13 := a40(indx);
          t(ddindx).old_attribute14 := a41(indx);
          t(ddindx).new_attribute14 := a42(indx);
          t(ddindx).old_attribute15 := a43(indx);
          t(ddindx).new_attribute15 := a44(indx);
          t(ddindx).full_dump_flag := a45(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a47(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p73;
  procedure rosetta_table_copy_out_p73(t csi_datastructures_pub.version_label_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).version_label_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).version_label_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := t(ddindx).old_version_label;
          a4(indx) := t(ddindx).new_version_label;
          a5(indx) := t(ddindx).old_description;
          a6(indx) := t(ddindx).new_description;
          a7(indx) := t(ddindx).old_date_time_stamp;
          a8(indx) := t(ddindx).new_date_time_stamp;
          a9(indx) := t(ddindx).old_active_start_date;
          a10(indx) := t(ddindx).new_active_start_date;
          a11(indx) := t(ddindx).old_active_end_date;
          a12(indx) := t(ddindx).new_active_end_date;
          a13(indx) := t(ddindx).old_context;
          a14(indx) := t(ddindx).new_context;
          a15(indx) := t(ddindx).old_attribute1;
          a16(indx) := t(ddindx).new_attribute1;
          a17(indx) := t(ddindx).old_attribute2;
          a18(indx) := t(ddindx).new_attribute2;
          a19(indx) := t(ddindx).old_attribute3;
          a20(indx) := t(ddindx).new_attribute3;
          a21(indx) := t(ddindx).old_attribute4;
          a22(indx) := t(ddindx).new_attribute4;
          a23(indx) := t(ddindx).old_attribute5;
          a24(indx) := t(ddindx).new_attribute5;
          a25(indx) := t(ddindx).old_attribute6;
          a26(indx) := t(ddindx).new_attribute6;
          a27(indx) := t(ddindx).old_attribute7;
          a28(indx) := t(ddindx).new_attribute7;
          a29(indx) := t(ddindx).old_attribute8;
          a30(indx) := t(ddindx).new_attribute8;
          a31(indx) := t(ddindx).old_attribute9;
          a32(indx) := t(ddindx).new_attribute9;
          a33(indx) := t(ddindx).old_attribute10;
          a34(indx) := t(ddindx).new_attribute10;
          a35(indx) := t(ddindx).old_attribute11;
          a36(indx) := t(ddindx).new_attribute11;
          a37(indx) := t(ddindx).old_attribute12;
          a38(indx) := t(ddindx).new_attribute12;
          a39(indx) := t(ddindx).old_attribute13;
          a40(indx) := t(ddindx).new_attribute13;
          a41(indx) := t(ddindx).old_attribute14;
          a42(indx) := t(ddindx).new_attribute14;
          a43(indx) := t(ddindx).old_attribute15;
          a44(indx) := t(ddindx).new_attribute15;
          a45(indx) := t(ddindx).full_dump_flag;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p73;

  procedure rosetta_table_copy_in_p75(t out nocopy csi_datastructures_pub.transaction_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).source_transaction_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).txn_sub_type_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).source_group_ref_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).source_group_ref := a6(indx);
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).source_header_ref := a8(indx);
          t(ddindx).source_line_ref_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).source_line_ref := a10(indx);
          t(ddindx).source_dist_ref_id1 := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).source_dist_ref_id2 := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).inv_material_transaction_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).transaction_uom_code := a15(indx);
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).transaction_status_code := a17(indx);
          t(ddindx).transaction_action_code := a18(indx);
          t(ddindx).message_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).context := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).split_reason_code := a37(indx);
          t(ddindx).txn_user_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).txn_user_name := a39(indx);
          t(ddindx).transaction_type_name := a40(indx);
          t(ddindx).txn_sub_type_name := a41(indx);
          t(ddindx).source_application_name := a42(indx);
          t(ddindx).transaction_status_name := a43(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p75;
  procedure rosetta_table_copy_out_p75(t csi_datastructures_pub.transaction_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := t(ddindx).transaction_date;
          a2(indx) := t(ddindx).source_transaction_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).txn_sub_type_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).source_group_ref_id);
          a6(indx) := t(ddindx).source_group_ref;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a8(indx) := t(ddindx).source_header_ref;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).source_line_ref_id);
          a10(indx) := t(ddindx).source_line_ref;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id1);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).source_dist_ref_id2);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).inv_material_transaction_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a15(indx) := t(ddindx).transaction_uom_code;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a17(indx) := t(ddindx).transaction_status_code;
          a18(indx) := t(ddindx).transaction_action_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          a20(indx) := t(ddindx).context;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a37(indx) := t(ddindx).split_reason_code;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).txn_user_id);
          a39(indx) := t(ddindx).txn_user_name;
          a40(indx) := t(ddindx).transaction_type_name;
          a41(indx) := t(ddindx).txn_sub_type_name;
          a42(indx) := t(ddindx).source_application_name;
          a43(indx) := t(ddindx).transaction_status_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p75;

  procedure rosetta_table_copy_in_p77(t out nocopy csi_datastructures_pub.grp_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).group_inst_num := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).process_status := a1(indx);
          t(ddindx).error_message := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p77;
  procedure rosetta_table_copy_out_p77(t csi_datastructures_pub.grp_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).group_inst_num);
          a1(indx) := t(ddindx).process_status;
          a2(indx) := t(ddindx).error_message;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p77;

  procedure rosetta_table_copy_in_p79(t out nocopy csi_datastructures_pub.grp_upd_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).entity_name := a1(indx);
          t(ddindx).error_message := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p79;
  procedure rosetta_table_copy_out_p79(t csi_datastructures_pub.grp_upd_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).entity_name;
          a2(indx) := t(ddindx).error_message;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p79;

  procedure rosetta_table_copy_in_p81(t out nocopy csi_datastructures_pub.system_header_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_400
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_2000
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_400
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_VARCHAR2_TABLE_2000
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_400
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_2000
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_400
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_400
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_VARCHAR2_TABLE_400
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_400
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_VARCHAR2_TABLE_400
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).system_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).operating_unit_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).customer_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).customer_name := a3(indx);
          t(ddindx).customer_party_number := a4(indx);
          t(ddindx).customer_number := a5(indx);
          t(ddindx).system_type_code := a6(indx);
          t(ddindx).system_type := a7(indx);
          t(ddindx).system_number := a8(indx);
          t(ddindx).parent_system_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).technical_contact_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).service_admin_contact_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).install_site_use_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).bill_to_contact_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).ship_to_site_use_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).ship_to_contact_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).coterminate_day_month := a17(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).autocreated_from_system_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).context := a36(indx);
          t(ddindx).config_system_type := a37(indx);
          t(ddindx).name := a38(indx);
          t(ddindx).description := a39(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).ship_to_customer := a42(indx);
          t(ddindx).ship_to_customer_number := a43(indx);
          t(ddindx).ship_party_type := a44(indx);
          t(ddindx).ship_to_site_number := a45(indx);
          t(ddindx).ship_to_location_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).ship_description := a47(indx);
          t(ddindx).ship_to_address1 := a48(indx);
          t(ddindx).ship_to_address2 := a49(indx);
          t(ddindx).ship_to_address3 := a50(indx);
          t(ddindx).ship_to_address4 := a51(indx);
          t(ddindx).ship_to_location := a52(indx);
          t(ddindx).ship_state := a53(indx);
          t(ddindx).ship_postal_code := a54(indx);
          t(ddindx).ship_country := a55(indx);
          t(ddindx).install_customer_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).install_customer_number := a57(indx);
          t(ddindx).install_customer := a58(indx);
          t(ddindx).install_party_type := a59(indx);
          t(ddindx).install_site_number := a60(indx);
          t(ddindx).install_location_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).install_description := a62(indx);
          t(ddindx).install_address1 := a63(indx);
          t(ddindx).install_address2 := a64(indx);
          t(ddindx).install_address3 := a65(indx);
          t(ddindx).install_address4 := a66(indx);
          t(ddindx).install_location := a67(indx);
          t(ddindx).install_state := a68(indx);
          t(ddindx).install_postal_code := a69(indx);
          t(ddindx).install_country := a70(indx);
          t(ddindx).bill_to_customer_id := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).bill_to_customer_number := a72(indx);
          t(ddindx).bill_to_customer := a73(indx);
          t(ddindx).bill_party_type := a74(indx);
          t(ddindx).bill_to_site_number := a75(indx);
          t(ddindx).bill_to_location_id := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).bill_description := a77(indx);
          t(ddindx).bill_to_address1 := a78(indx);
          t(ddindx).bill_to_address2 := a79(indx);
          t(ddindx).bill_to_address3 := a80(indx);
          t(ddindx).bill_to_address4 := a81(indx);
          t(ddindx).bill_to_location := a82(indx);
          t(ddindx).bill_state := a83(indx);
          t(ddindx).bill_postal_code := a84(indx);
          t(ddindx).bill_country := a85(indx);
          t(ddindx).technical_contact_number := a86(indx);
          t(ddindx).technical_contact := a87(indx);
          t(ddindx).service_admin_contact_number := a88(indx);
          t(ddindx).service_admin_contact := a89(indx);
          t(ddindx).ship_to_contact_number := a90(indx);
          t(ddindx).ship_to_contact := a91(indx);
          t(ddindx).bill_to_contact_number := a92(indx);
          t(ddindx).bill_to_contact := a93(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).party_name := a95(indx);
          t(ddindx).parent_name := a96(indx);
          t(ddindx).parent_description := a97(indx);
          t(ddindx).parent_number := a98(indx);
          t(ddindx).operating_unit_name := a99(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p81;
  procedure rosetta_table_copy_out_p81(t csi_datastructures_pub.system_header_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_400
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_2000
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_400
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_VARCHAR2_TABLE_2000
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_400
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_2000
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_100
    , a87 out nocopy JTF_VARCHAR2_TABLE_400
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_VARCHAR2_TABLE_400
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_VARCHAR2_TABLE_400
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_VARCHAR2_TABLE_400
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_VARCHAR2_TABLE_400
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_400();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_400();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_2000();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_400();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_VARCHAR2_TABLE_2000();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_400();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_2000();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_400();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_400();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_VARCHAR2_TABLE_400();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_VARCHAR2_TABLE_400();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_VARCHAR2_TABLE_400();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_400();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_400();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_2000();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_400();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_VARCHAR2_TABLE_2000();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_400();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_2000();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_400();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_400();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_VARCHAR2_TABLE_400();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_VARCHAR2_TABLE_400();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_VARCHAR2_TABLE_400();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).operating_unit_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a3(indx) := t(ddindx).customer_name;
          a4(indx) := t(ddindx).customer_party_number;
          a5(indx) := t(ddindx).customer_number;
          a6(indx) := t(ddindx).system_type_code;
          a7(indx) := t(ddindx).system_type;
          a8(indx) := t(ddindx).system_number;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).parent_system_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).technical_contact_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).service_admin_contact_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).install_site_use_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_contact_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_use_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_contact_id);
          a17(indx) := t(ddindx).coterminate_day_month;
          a18(indx) := t(ddindx).start_date_active;
          a19(indx) := t(ddindx).end_date_active;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).autocreated_from_system_id);
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := t(ddindx).context;
          a37(indx) := t(ddindx).config_system_type;
          a38(indx) := t(ddindx).name;
          a39(indx) := t(ddindx).description;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a42(indx) := t(ddindx).ship_to_customer;
          a43(indx) := t(ddindx).ship_to_customer_number;
          a44(indx) := t(ddindx).ship_party_type;
          a45(indx) := t(ddindx).ship_to_site_number;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_location_id);
          a47(indx) := t(ddindx).ship_description;
          a48(indx) := t(ddindx).ship_to_address1;
          a49(indx) := t(ddindx).ship_to_address2;
          a50(indx) := t(ddindx).ship_to_address3;
          a51(indx) := t(ddindx).ship_to_address4;
          a52(indx) := t(ddindx).ship_to_location;
          a53(indx) := t(ddindx).ship_state;
          a54(indx) := t(ddindx).ship_postal_code;
          a55(indx) := t(ddindx).ship_country;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).install_customer_id);
          a57(indx) := t(ddindx).install_customer_number;
          a58(indx) := t(ddindx).install_customer;
          a59(indx) := t(ddindx).install_party_type;
          a60(indx) := t(ddindx).install_site_number;
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).install_location_id);
          a62(indx) := t(ddindx).install_description;
          a63(indx) := t(ddindx).install_address1;
          a64(indx) := t(ddindx).install_address2;
          a65(indx) := t(ddindx).install_address3;
          a66(indx) := t(ddindx).install_address4;
          a67(indx) := t(ddindx).install_location;
          a68(indx) := t(ddindx).install_state;
          a69(indx) := t(ddindx).install_postal_code;
          a70(indx) := t(ddindx).install_country;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_customer_id);
          a72(indx) := t(ddindx).bill_to_customer_number;
          a73(indx) := t(ddindx).bill_to_customer;
          a74(indx) := t(ddindx).bill_party_type;
          a75(indx) := t(ddindx).bill_to_site_number;
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_location_id);
          a77(indx) := t(ddindx).bill_description;
          a78(indx) := t(ddindx).bill_to_address1;
          a79(indx) := t(ddindx).bill_to_address2;
          a80(indx) := t(ddindx).bill_to_address3;
          a81(indx) := t(ddindx).bill_to_address4;
          a82(indx) := t(ddindx).bill_to_location;
          a83(indx) := t(ddindx).bill_state;
          a84(indx) := t(ddindx).bill_postal_code;
          a85(indx) := t(ddindx).bill_country;
          a86(indx) := t(ddindx).technical_contact_number;
          a87(indx) := t(ddindx).technical_contact;
          a88(indx) := t(ddindx).service_admin_contact_number;
          a89(indx) := t(ddindx).service_admin_contact;
          a90(indx) := t(ddindx).ship_to_contact_number;
          a91(indx) := t(ddindx).ship_to_contact;
          a92(indx) := t(ddindx).bill_to_contact_number;
          a93(indx) := t(ddindx).bill_to_contact;
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a95(indx) := t(ddindx).party_name;
          a96(indx) := t(ddindx).parent_name;
          a97(indx) := t(ddindx).parent_description;
          a98(indx) := t(ddindx).parent_number;
          a99(indx) := t(ddindx).operating_unit_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p81;

  procedure rosetta_table_copy_in_p83(t out nocopy csi_datastructures_pub.pricing_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
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
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
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
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_200
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_VARCHAR2_TABLE_200
    , a94 JTF_VARCHAR2_TABLE_200
    , a95 JTF_VARCHAR2_TABLE_200
    , a96 JTF_VARCHAR2_TABLE_200
    , a97 JTF_VARCHAR2_TABLE_200
    , a98 JTF_VARCHAR2_TABLE_200
    , a99 JTF_VARCHAR2_TABLE_200
    , a100 JTF_VARCHAR2_TABLE_200
    , a101 JTF_VARCHAR2_TABLE_200
    , a102 JTF_VARCHAR2_TABLE_200
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_VARCHAR2_TABLE_200
    , a106 JTF_VARCHAR2_TABLE_200
    , a107 JTF_VARCHAR2_TABLE_200
    , a108 JTF_VARCHAR2_TABLE_200
    , a109 JTF_VARCHAR2_TABLE_200
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_200
    , a115 JTF_VARCHAR2_TABLE_200
    , a116 JTF_VARCHAR2_TABLE_200
    , a117 JTF_VARCHAR2_TABLE_200
    , a118 JTF_VARCHAR2_TABLE_200
    , a119 JTF_VARCHAR2_TABLE_200
    , a120 JTF_VARCHAR2_TABLE_200
    , a121 JTF_VARCHAR2_TABLE_200
    , a122 JTF_VARCHAR2_TABLE_200
    , a123 JTF_VARCHAR2_TABLE_200
    , a124 JTF_VARCHAR2_TABLE_200
    , a125 JTF_VARCHAR2_TABLE_200
    , a126 JTF_VARCHAR2_TABLE_200
    , a127 JTF_VARCHAR2_TABLE_200
    , a128 JTF_VARCHAR2_TABLE_200
    , a129 JTF_VARCHAR2_TABLE_200
    , a130 JTF_VARCHAR2_TABLE_200
    , a131 JTF_VARCHAR2_TABLE_200
    , a132 JTF_VARCHAR2_TABLE_200
    , a133 JTF_VARCHAR2_TABLE_200
    , a134 JTF_VARCHAR2_TABLE_200
    , a135 JTF_VARCHAR2_TABLE_200
    , a136 JTF_VARCHAR2_TABLE_200
    , a137 JTF_VARCHAR2_TABLE_200
    , a138 JTF_VARCHAR2_TABLE_200
    , a139 JTF_VARCHAR2_TABLE_200
    , a140 JTF_VARCHAR2_TABLE_200
    , a141 JTF_VARCHAR2_TABLE_200
    , a142 JTF_VARCHAR2_TABLE_200
    , a143 JTF_VARCHAR2_TABLE_200
    , a144 JTF_VARCHAR2_TABLE_200
    , a145 JTF_VARCHAR2_TABLE_200
    , a146 JTF_VARCHAR2_TABLE_200
    , a147 JTF_VARCHAR2_TABLE_200
    , a148 JTF_VARCHAR2_TABLE_200
    , a149 JTF_VARCHAR2_TABLE_200
    , a150 JTF_VARCHAR2_TABLE_200
    , a151 JTF_VARCHAR2_TABLE_200
    , a152 JTF_VARCHAR2_TABLE_200
    , a153 JTF_VARCHAR2_TABLE_200
    , a154 JTF_VARCHAR2_TABLE_200
    , a155 JTF_VARCHAR2_TABLE_200
    , a156 JTF_VARCHAR2_TABLE_200
    , a157 JTF_VARCHAR2_TABLE_200
    , a158 JTF_VARCHAR2_TABLE_200
    , a159 JTF_VARCHAR2_TABLE_200
    , a160 JTF_VARCHAR2_TABLE_200
    , a161 JTF_VARCHAR2_TABLE_200
    , a162 JTF_VARCHAR2_TABLE_200
    , a163 JTF_VARCHAR2_TABLE_200
    , a164 JTF_VARCHAR2_TABLE_200
    , a165 JTF_VARCHAR2_TABLE_200
    , a166 JTF_VARCHAR2_TABLE_200
    , a167 JTF_VARCHAR2_TABLE_200
    , a168 JTF_VARCHAR2_TABLE_200
    , a169 JTF_VARCHAR2_TABLE_200
    , a170 JTF_VARCHAR2_TABLE_200
    , a171 JTF_VARCHAR2_TABLE_200
    , a172 JTF_VARCHAR2_TABLE_200
    , a173 JTF_VARCHAR2_TABLE_200
    , a174 JTF_VARCHAR2_TABLE_200
    , a175 JTF_VARCHAR2_TABLE_200
    , a176 JTF_VARCHAR2_TABLE_200
    , a177 JTF_VARCHAR2_TABLE_200
    , a178 JTF_VARCHAR2_TABLE_200
    , a179 JTF_VARCHAR2_TABLE_200
    , a180 JTF_VARCHAR2_TABLE_200
    , a181 JTF_VARCHAR2_TABLE_200
    , a182 JTF_VARCHAR2_TABLE_200
    , a183 JTF_VARCHAR2_TABLE_200
    , a184 JTF_VARCHAR2_TABLE_200
    , a185 JTF_VARCHAR2_TABLE_200
    , a186 JTF_VARCHAR2_TABLE_200
    , a187 JTF_VARCHAR2_TABLE_200
    , a188 JTF_VARCHAR2_TABLE_200
    , a189 JTF_VARCHAR2_TABLE_200
    , a190 JTF_VARCHAR2_TABLE_200
    , a191 JTF_VARCHAR2_TABLE_200
    , a192 JTF_VARCHAR2_TABLE_200
    , a193 JTF_VARCHAR2_TABLE_200
    , a194 JTF_VARCHAR2_TABLE_200
    , a195 JTF_VARCHAR2_TABLE_200
    , a196 JTF_VARCHAR2_TABLE_200
    , a197 JTF_VARCHAR2_TABLE_200
    , a198 JTF_VARCHAR2_TABLE_200
    , a199 JTF_VARCHAR2_TABLE_200
    , a200 JTF_VARCHAR2_TABLE_200
    , a201 JTF_VARCHAR2_TABLE_200
    , a202 JTF_VARCHAR2_TABLE_200
    , a203 JTF_VARCHAR2_TABLE_200
    , a204 JTF_VARCHAR2_TABLE_200
    , a205 JTF_DATE_TABLE
    , a206 JTF_DATE_TABLE
    , a207 JTF_DATE_TABLE
    , a208 JTF_DATE_TABLE
    , a209 JTF_VARCHAR2_TABLE_100
    , a210 JTF_VARCHAR2_TABLE_100
    , a211 JTF_VARCHAR2_TABLE_200
    , a212 JTF_VARCHAR2_TABLE_200
    , a213 JTF_VARCHAR2_TABLE_200
    , a214 JTF_VARCHAR2_TABLE_200
    , a215 JTF_VARCHAR2_TABLE_200
    , a216 JTF_VARCHAR2_TABLE_200
    , a217 JTF_VARCHAR2_TABLE_200
    , a218 JTF_VARCHAR2_TABLE_200
    , a219 JTF_VARCHAR2_TABLE_200
    , a220 JTF_VARCHAR2_TABLE_200
    , a221 JTF_VARCHAR2_TABLE_200
    , a222 JTF_VARCHAR2_TABLE_200
    , a223 JTF_VARCHAR2_TABLE_200
    , a224 JTF_VARCHAR2_TABLE_200
    , a225 JTF_VARCHAR2_TABLE_200
    , a226 JTF_VARCHAR2_TABLE_200
    , a227 JTF_VARCHAR2_TABLE_200
    , a228 JTF_VARCHAR2_TABLE_200
    , a229 JTF_VARCHAR2_TABLE_200
    , a230 JTF_VARCHAR2_TABLE_200
    , a231 JTF_VARCHAR2_TABLE_200
    , a232 JTF_VARCHAR2_TABLE_200
    , a233 JTF_VARCHAR2_TABLE_200
    , a234 JTF_VARCHAR2_TABLE_200
    , a235 JTF_VARCHAR2_TABLE_200
    , a236 JTF_VARCHAR2_TABLE_200
    , a237 JTF_VARCHAR2_TABLE_200
    , a238 JTF_VARCHAR2_TABLE_200
    , a239 JTF_VARCHAR2_TABLE_200
    , a240 JTF_VARCHAR2_TABLE_200
    , a241 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).price_attrib_history_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).pricing_attribute_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).old_pricing_context := a3(indx);
          t(ddindx).new_pricing_context := a4(indx);
          t(ddindx).old_pricing_attribute1 := a5(indx);
          t(ddindx).new_pricing_attribute1 := a6(indx);
          t(ddindx).old_pricing_attribute2 := a7(indx);
          t(ddindx).new_pricing_attribute2 := a8(indx);
          t(ddindx).old_pricing_attribute3 := a9(indx);
          t(ddindx).new_pricing_attribute3 := a10(indx);
          t(ddindx).old_pricing_attribute4 := a11(indx);
          t(ddindx).new_pricing_attribute4 := a12(indx);
          t(ddindx).old_pricing_attribute5 := a13(indx);
          t(ddindx).new_pricing_attribute5 := a14(indx);
          t(ddindx).old_pricing_attribute6 := a15(indx);
          t(ddindx).new_pricing_attribute6 := a16(indx);
          t(ddindx).old_pricing_attribute7 := a17(indx);
          t(ddindx).new_pricing_attribute7 := a18(indx);
          t(ddindx).old_pricing_attribute8 := a19(indx);
          t(ddindx).new_pricing_attribute8 := a20(indx);
          t(ddindx).old_pricing_attribute9 := a21(indx);
          t(ddindx).new_pricing_attribute9 := a22(indx);
          t(ddindx).old_pricing_attribute10 := a23(indx);
          t(ddindx).new_pricing_attribute10 := a24(indx);
          t(ddindx).old_pricing_attribute11 := a25(indx);
          t(ddindx).new_pricing_attribute11 := a26(indx);
          t(ddindx).old_pricing_attribute12 := a27(indx);
          t(ddindx).new_pricing_attribute12 := a28(indx);
          t(ddindx).old_pricing_attribute13 := a29(indx);
          t(ddindx).new_pricing_attribute13 := a30(indx);
          t(ddindx).old_pricing_attribute14 := a31(indx);
          t(ddindx).new_pricing_attribute14 := a32(indx);
          t(ddindx).old_pricing_attribute15 := a33(indx);
          t(ddindx).new_pricing_attribute15 := a34(indx);
          t(ddindx).old_pricing_attribute16 := a35(indx);
          t(ddindx).new_pricing_attribute16 := a36(indx);
          t(ddindx).old_pricing_attribute17 := a37(indx);
          t(ddindx).new_pricing_attribute17 := a38(indx);
          t(ddindx).old_pricing_attribute18 := a39(indx);
          t(ddindx).new_pricing_attribute18 := a40(indx);
          t(ddindx).old_pricing_attribute19 := a41(indx);
          t(ddindx).new_pricing_attribute19 := a42(indx);
          t(ddindx).old_pricing_attribute20 := a43(indx);
          t(ddindx).new_pricing_attribute20 := a44(indx);
          t(ddindx).old_pricing_attribute21 := a45(indx);
          t(ddindx).new_pricing_attribute21 := a46(indx);
          t(ddindx).old_pricing_attribute22 := a47(indx);
          t(ddindx).new_pricing_attribute22 := a48(indx);
          t(ddindx).old_pricing_attribute23 := a49(indx);
          t(ddindx).new_pricing_attribute23 := a50(indx);
          t(ddindx).old_pricing_attribute24 := a51(indx);
          t(ddindx).new_pricing_attribute24 := a52(indx);
          t(ddindx).new_pricing_attribute25 := a53(indx);
          t(ddindx).old_pricing_attribute25 := a54(indx);
          t(ddindx).old_pricing_attribute26 := a55(indx);
          t(ddindx).new_pricing_attribute26 := a56(indx);
          t(ddindx).old_pricing_attribute27 := a57(indx);
          t(ddindx).new_pricing_attribute27 := a58(indx);
          t(ddindx).old_pricing_attribute28 := a59(indx);
          t(ddindx).new_pricing_attribute28 := a60(indx);
          t(ddindx).old_pricing_attribute29 := a61(indx);
          t(ddindx).new_pricing_attribute29 := a62(indx);
          t(ddindx).old_pricing_attribute30 := a63(indx);
          t(ddindx).new_pricing_attribute30 := a64(indx);
          t(ddindx).old_pricing_attribute31 := a65(indx);
          t(ddindx).new_pricing_attribute31 := a66(indx);
          t(ddindx).old_pricing_attribute32 := a67(indx);
          t(ddindx).new_pricing_attribute32 := a68(indx);
          t(ddindx).old_pricing_attribute33 := a69(indx);
          t(ddindx).new_pricing_attribute33 := a70(indx);
          t(ddindx).old_pricing_attribute34 := a71(indx);
          t(ddindx).new_pricing_attribute34 := a72(indx);
          t(ddindx).old_pricing_attribute35 := a73(indx);
          t(ddindx).new_pricing_attribute35 := a74(indx);
          t(ddindx).old_pricing_attribute36 := a75(indx);
          t(ddindx).new_pricing_attribute36 := a76(indx);
          t(ddindx).old_pricing_attribute37 := a77(indx);
          t(ddindx).new_pricing_attribute37 := a78(indx);
          t(ddindx).old_pricing_attribute38 := a79(indx);
          t(ddindx).new_pricing_attribute38 := a80(indx);
          t(ddindx).old_pricing_attribute39 := a81(indx);
          t(ddindx).new_pricing_attribute39 := a82(indx);
          t(ddindx).old_pricing_attribute40 := a83(indx);
          t(ddindx).new_pricing_attribute40 := a84(indx);
          t(ddindx).old_pricing_attribute41 := a85(indx);
          t(ddindx).new_pricing_attribute41 := a86(indx);
          t(ddindx).old_pricing_attribute42 := a87(indx);
          t(ddindx).new_pricing_attribute42 := a88(indx);
          t(ddindx).old_pricing_attribute43 := a89(indx);
          t(ddindx).new_pricing_attribute43 := a90(indx);
          t(ddindx).old_pricing_attribute44 := a91(indx);
          t(ddindx).new_pricing_attribute44 := a92(indx);
          t(ddindx).old_pricing_attribute45 := a93(indx);
          t(ddindx).new_pricing_attribute45 := a94(indx);
          t(ddindx).old_pricing_attribute46 := a95(indx);
          t(ddindx).new_pricing_attribute46 := a96(indx);
          t(ddindx).old_pricing_attribute47 := a97(indx);
          t(ddindx).new_pricing_attribute47 := a98(indx);
          t(ddindx).old_pricing_attribute48 := a99(indx);
          t(ddindx).new_pricing_attribute48 := a100(indx);
          t(ddindx).old_pricing_attribute49 := a101(indx);
          t(ddindx).new_pricing_attribute49 := a102(indx);
          t(ddindx).old_pricing_attribute50 := a103(indx);
          t(ddindx).new_pricing_attribute50 := a104(indx);
          t(ddindx).old_pricing_attribute51 := a105(indx);
          t(ddindx).new_pricing_attribute51 := a106(indx);
          t(ddindx).old_pricing_attribute52 := a107(indx);
          t(ddindx).new_pricing_attribute52 := a108(indx);
          t(ddindx).old_pricing_attribute53 := a109(indx);
          t(ddindx).new_pricing_attribute53 := a110(indx);
          t(ddindx).old_pricing_attribute54 := a111(indx);
          t(ddindx).new_pricing_attribute54 := a112(indx);
          t(ddindx).old_pricing_attribute55 := a113(indx);
          t(ddindx).new_pricing_attribute55 := a114(indx);
          t(ddindx).old_pricing_attribute56 := a115(indx);
          t(ddindx).new_pricing_attribute56 := a116(indx);
          t(ddindx).old_pricing_attribute57 := a117(indx);
          t(ddindx).new_pricing_attribute57 := a118(indx);
          t(ddindx).old_pricing_attribute58 := a119(indx);
          t(ddindx).new_pricing_attribute58 := a120(indx);
          t(ddindx).old_pricing_attribute59 := a121(indx);
          t(ddindx).new_pricing_attribute59 := a122(indx);
          t(ddindx).old_pricing_attribute60 := a123(indx);
          t(ddindx).new_pricing_attribute60 := a124(indx);
          t(ddindx).old_pricing_attribute61 := a125(indx);
          t(ddindx).new_pricing_attribute61 := a126(indx);
          t(ddindx).old_pricing_attribute62 := a127(indx);
          t(ddindx).new_pricing_attribute62 := a128(indx);
          t(ddindx).old_pricing_attribute63 := a129(indx);
          t(ddindx).new_pricing_attribute63 := a130(indx);
          t(ddindx).old_pricing_attribute64 := a131(indx);
          t(ddindx).new_pricing_attribute64 := a132(indx);
          t(ddindx).old_pricing_attribute65 := a133(indx);
          t(ddindx).new_pricing_attribute65 := a134(indx);
          t(ddindx).old_pricing_attribute66 := a135(indx);
          t(ddindx).new_pricing_attribute66 := a136(indx);
          t(ddindx).old_pricing_attribute67 := a137(indx);
          t(ddindx).new_pricing_attribute67 := a138(indx);
          t(ddindx).old_pricing_attribute68 := a139(indx);
          t(ddindx).new_pricing_attribute68 := a140(indx);
          t(ddindx).old_pricing_attribute69 := a141(indx);
          t(ddindx).new_pricing_attribute69 := a142(indx);
          t(ddindx).old_pricing_attribute70 := a143(indx);
          t(ddindx).new_pricing_attribute70 := a144(indx);
          t(ddindx).old_pricing_attribute71 := a145(indx);
          t(ddindx).new_pricing_attribute71 := a146(indx);
          t(ddindx).old_pricing_attribute72 := a147(indx);
          t(ddindx).new_pricing_attribute72 := a148(indx);
          t(ddindx).old_pricing_attribute73 := a149(indx);
          t(ddindx).new_pricing_attribute73 := a150(indx);
          t(ddindx).old_pricing_attribute74 := a151(indx);
          t(ddindx).new_pricing_attribute74 := a152(indx);
          t(ddindx).old_pricing_attribute75 := a153(indx);
          t(ddindx).new_pricing_attribute75 := a154(indx);
          t(ddindx).old_pricing_attribute76 := a155(indx);
          t(ddindx).new_pricing_attribute76 := a156(indx);
          t(ddindx).old_pricing_attribute77 := a157(indx);
          t(ddindx).new_pricing_attribute77 := a158(indx);
          t(ddindx).old_pricing_attribute78 := a159(indx);
          t(ddindx).new_pricing_attribute78 := a160(indx);
          t(ddindx).old_pricing_attribute79 := a161(indx);
          t(ddindx).new_pricing_attribute79 := a162(indx);
          t(ddindx).old_pricing_attribute80 := a163(indx);
          t(ddindx).new_pricing_attribute80 := a164(indx);
          t(ddindx).old_pricing_attribute81 := a165(indx);
          t(ddindx).new_pricing_attribute81 := a166(indx);
          t(ddindx).old_pricing_attribute82 := a167(indx);
          t(ddindx).new_pricing_attribute82 := a168(indx);
          t(ddindx).old_pricing_attribute83 := a169(indx);
          t(ddindx).new_pricing_attribute83 := a170(indx);
          t(ddindx).old_pricing_attribute84 := a171(indx);
          t(ddindx).new_pricing_attribute84 := a172(indx);
          t(ddindx).old_pricing_attribute85 := a173(indx);
          t(ddindx).new_pricing_attribute85 := a174(indx);
          t(ddindx).old_pricing_attribute86 := a175(indx);
          t(ddindx).new_pricing_attribute86 := a176(indx);
          t(ddindx).old_pricing_attribute87 := a177(indx);
          t(ddindx).new_pricing_attribute87 := a178(indx);
          t(ddindx).old_pricing_attribute88 := a179(indx);
          t(ddindx).new_pricing_attribute88 := a180(indx);
          t(ddindx).old_pricing_attribute89 := a181(indx);
          t(ddindx).new_pricing_attribute89 := a182(indx);
          t(ddindx).old_pricing_attribute90 := a183(indx);
          t(ddindx).new_pricing_attribute90 := a184(indx);
          t(ddindx).old_pricing_attribute91 := a185(indx);
          t(ddindx).new_pricing_attribute91 := a186(indx);
          t(ddindx).old_pricing_attribute92 := a187(indx);
          t(ddindx).new_pricing_attribute92 := a188(indx);
          t(ddindx).old_pricing_attribute93 := a189(indx);
          t(ddindx).new_pricing_attribute93 := a190(indx);
          t(ddindx).old_pricing_attribute94 := a191(indx);
          t(ddindx).new_pricing_attribute94 := a192(indx);
          t(ddindx).old_pricing_attribute95 := a193(indx);
          t(ddindx).new_pricing_attribute95 := a194(indx);
          t(ddindx).old_pricing_attribute96 := a195(indx);
          t(ddindx).new_pricing_attribute96 := a196(indx);
          t(ddindx).old_pricing_attribute97 := a197(indx);
          t(ddindx).new_pricing_attribute97 := a198(indx);
          t(ddindx).old_pricing_attribute98 := a199(indx);
          t(ddindx).new_pricing_attribute98 := a200(indx);
          t(ddindx).old_pricing_attribute99 := a201(indx);
          t(ddindx).new_pricing_attribute99 := a202(indx);
          t(ddindx).old_pricing_attribute100 := a203(indx);
          t(ddindx).new_pricing_attribute100 := a204(indx);
          t(ddindx).old_active_start_date := rosetta_g_miss_date_in_map(a205(indx));
          t(ddindx).new_active_start_date := rosetta_g_miss_date_in_map(a206(indx));
          t(ddindx).old_active_end_date := rosetta_g_miss_date_in_map(a207(indx));
          t(ddindx).new_active_end_date := rosetta_g_miss_date_in_map(a208(indx));
          t(ddindx).old_context := a209(indx);
          t(ddindx).new_context := a210(indx);
          t(ddindx).old_attribute1 := a211(indx);
          t(ddindx).new_attribute1 := a212(indx);
          t(ddindx).old_attribute2 := a213(indx);
          t(ddindx).new_attribute2 := a214(indx);
          t(ddindx).old_attribute3 := a215(indx);
          t(ddindx).new_attribute3 := a216(indx);
          t(ddindx).old_attribute4 := a217(indx);
          t(ddindx).new_attribute4 := a218(indx);
          t(ddindx).old_attribute5 := a219(indx);
          t(ddindx).new_attribute5 := a220(indx);
          t(ddindx).old_attribute6 := a221(indx);
          t(ddindx).new_attribute6 := a222(indx);
          t(ddindx).old_attribute7 := a223(indx);
          t(ddindx).new_attribute7 := a224(indx);
          t(ddindx).old_attribute8 := a225(indx);
          t(ddindx).new_attribute8 := a226(indx);
          t(ddindx).old_attribute9 := a227(indx);
          t(ddindx).new_attribute9 := a228(indx);
          t(ddindx).old_attribute10 := a229(indx);
          t(ddindx).new_attribute10 := a230(indx);
          t(ddindx).old_attribute11 := a231(indx);
          t(ddindx).new_attribute11 := a232(indx);
          t(ddindx).old_attribute12 := a233(indx);
          t(ddindx).new_attribute12 := a234(indx);
          t(ddindx).old_attribute13 := a235(indx);
          t(ddindx).new_attribute13 := a236(indx);
          t(ddindx).old_attribute14 := a237(indx);
          t(ddindx).new_attribute14 := a238(indx);
          t(ddindx).old_attribute15 := a239(indx);
          t(ddindx).new_attribute15 := a240(indx);
          t(ddindx).full_dump_flag := a241(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p83;
  procedure rosetta_table_copy_out_p83(t csi_datastructures_pub.pricing_history_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_VARCHAR2_TABLE_200
    , a94 out nocopy JTF_VARCHAR2_TABLE_200
    , a95 out nocopy JTF_VARCHAR2_TABLE_200
    , a96 out nocopy JTF_VARCHAR2_TABLE_200
    , a97 out nocopy JTF_VARCHAR2_TABLE_200
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
    , a99 out nocopy JTF_VARCHAR2_TABLE_200
    , a100 out nocopy JTF_VARCHAR2_TABLE_200
    , a101 out nocopy JTF_VARCHAR2_TABLE_200
    , a102 out nocopy JTF_VARCHAR2_TABLE_200
    , a103 out nocopy JTF_VARCHAR2_TABLE_200
    , a104 out nocopy JTF_VARCHAR2_TABLE_200
    , a105 out nocopy JTF_VARCHAR2_TABLE_200
    , a106 out nocopy JTF_VARCHAR2_TABLE_200
    , a107 out nocopy JTF_VARCHAR2_TABLE_200
    , a108 out nocopy JTF_VARCHAR2_TABLE_200
    , a109 out nocopy JTF_VARCHAR2_TABLE_200
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_200
    , a115 out nocopy JTF_VARCHAR2_TABLE_200
    , a116 out nocopy JTF_VARCHAR2_TABLE_200
    , a117 out nocopy JTF_VARCHAR2_TABLE_200
    , a118 out nocopy JTF_VARCHAR2_TABLE_200
    , a119 out nocopy JTF_VARCHAR2_TABLE_200
    , a120 out nocopy JTF_VARCHAR2_TABLE_200
    , a121 out nocopy JTF_VARCHAR2_TABLE_200
    , a122 out nocopy JTF_VARCHAR2_TABLE_200
    , a123 out nocopy JTF_VARCHAR2_TABLE_200
    , a124 out nocopy JTF_VARCHAR2_TABLE_200
    , a125 out nocopy JTF_VARCHAR2_TABLE_200
    , a126 out nocopy JTF_VARCHAR2_TABLE_200
    , a127 out nocopy JTF_VARCHAR2_TABLE_200
    , a128 out nocopy JTF_VARCHAR2_TABLE_200
    , a129 out nocopy JTF_VARCHAR2_TABLE_200
    , a130 out nocopy JTF_VARCHAR2_TABLE_200
    , a131 out nocopy JTF_VARCHAR2_TABLE_200
    , a132 out nocopy JTF_VARCHAR2_TABLE_200
    , a133 out nocopy JTF_VARCHAR2_TABLE_200
    , a134 out nocopy JTF_VARCHAR2_TABLE_200
    , a135 out nocopy JTF_VARCHAR2_TABLE_200
    , a136 out nocopy JTF_VARCHAR2_TABLE_200
    , a137 out nocopy JTF_VARCHAR2_TABLE_200
    , a138 out nocopy JTF_VARCHAR2_TABLE_200
    , a139 out nocopy JTF_VARCHAR2_TABLE_200
    , a140 out nocopy JTF_VARCHAR2_TABLE_200
    , a141 out nocopy JTF_VARCHAR2_TABLE_200
    , a142 out nocopy JTF_VARCHAR2_TABLE_200
    , a143 out nocopy JTF_VARCHAR2_TABLE_200
    , a144 out nocopy JTF_VARCHAR2_TABLE_200
    , a145 out nocopy JTF_VARCHAR2_TABLE_200
    , a146 out nocopy JTF_VARCHAR2_TABLE_200
    , a147 out nocopy JTF_VARCHAR2_TABLE_200
    , a148 out nocopy JTF_VARCHAR2_TABLE_200
    , a149 out nocopy JTF_VARCHAR2_TABLE_200
    , a150 out nocopy JTF_VARCHAR2_TABLE_200
    , a151 out nocopy JTF_VARCHAR2_TABLE_200
    , a152 out nocopy JTF_VARCHAR2_TABLE_200
    , a153 out nocopy JTF_VARCHAR2_TABLE_200
    , a154 out nocopy JTF_VARCHAR2_TABLE_200
    , a155 out nocopy JTF_VARCHAR2_TABLE_200
    , a156 out nocopy JTF_VARCHAR2_TABLE_200
    , a157 out nocopy JTF_VARCHAR2_TABLE_200
    , a158 out nocopy JTF_VARCHAR2_TABLE_200
    , a159 out nocopy JTF_VARCHAR2_TABLE_200
    , a160 out nocopy JTF_VARCHAR2_TABLE_200
    , a161 out nocopy JTF_VARCHAR2_TABLE_200
    , a162 out nocopy JTF_VARCHAR2_TABLE_200
    , a163 out nocopy JTF_VARCHAR2_TABLE_200
    , a164 out nocopy JTF_VARCHAR2_TABLE_200
    , a165 out nocopy JTF_VARCHAR2_TABLE_200
    , a166 out nocopy JTF_VARCHAR2_TABLE_200
    , a167 out nocopy JTF_VARCHAR2_TABLE_200
    , a168 out nocopy JTF_VARCHAR2_TABLE_200
    , a169 out nocopy JTF_VARCHAR2_TABLE_200
    , a170 out nocopy JTF_VARCHAR2_TABLE_200
    , a171 out nocopy JTF_VARCHAR2_TABLE_200
    , a172 out nocopy JTF_VARCHAR2_TABLE_200
    , a173 out nocopy JTF_VARCHAR2_TABLE_200
    , a174 out nocopy JTF_VARCHAR2_TABLE_200
    , a175 out nocopy JTF_VARCHAR2_TABLE_200
    , a176 out nocopy JTF_VARCHAR2_TABLE_200
    , a177 out nocopy JTF_VARCHAR2_TABLE_200
    , a178 out nocopy JTF_VARCHAR2_TABLE_200
    , a179 out nocopy JTF_VARCHAR2_TABLE_200
    , a180 out nocopy JTF_VARCHAR2_TABLE_200
    , a181 out nocopy JTF_VARCHAR2_TABLE_200
    , a182 out nocopy JTF_VARCHAR2_TABLE_200
    , a183 out nocopy JTF_VARCHAR2_TABLE_200
    , a184 out nocopy JTF_VARCHAR2_TABLE_200
    , a185 out nocopy JTF_VARCHAR2_TABLE_200
    , a186 out nocopy JTF_VARCHAR2_TABLE_200
    , a187 out nocopy JTF_VARCHAR2_TABLE_200
    , a188 out nocopy JTF_VARCHAR2_TABLE_200
    , a189 out nocopy JTF_VARCHAR2_TABLE_200
    , a190 out nocopy JTF_VARCHAR2_TABLE_200
    , a191 out nocopy JTF_VARCHAR2_TABLE_200
    , a192 out nocopy JTF_VARCHAR2_TABLE_200
    , a193 out nocopy JTF_VARCHAR2_TABLE_200
    , a194 out nocopy JTF_VARCHAR2_TABLE_200
    , a195 out nocopy JTF_VARCHAR2_TABLE_200
    , a196 out nocopy JTF_VARCHAR2_TABLE_200
    , a197 out nocopy JTF_VARCHAR2_TABLE_200
    , a198 out nocopy JTF_VARCHAR2_TABLE_200
    , a199 out nocopy JTF_VARCHAR2_TABLE_200
    , a200 out nocopy JTF_VARCHAR2_TABLE_200
    , a201 out nocopy JTF_VARCHAR2_TABLE_200
    , a202 out nocopy JTF_VARCHAR2_TABLE_200
    , a203 out nocopy JTF_VARCHAR2_TABLE_200
    , a204 out nocopy JTF_VARCHAR2_TABLE_200
    , a205 out nocopy JTF_DATE_TABLE
    , a206 out nocopy JTF_DATE_TABLE
    , a207 out nocopy JTF_DATE_TABLE
    , a208 out nocopy JTF_DATE_TABLE
    , a209 out nocopy JTF_VARCHAR2_TABLE_100
    , a210 out nocopy JTF_VARCHAR2_TABLE_100
    , a211 out nocopy JTF_VARCHAR2_TABLE_200
    , a212 out nocopy JTF_VARCHAR2_TABLE_200
    , a213 out nocopy JTF_VARCHAR2_TABLE_200
    , a214 out nocopy JTF_VARCHAR2_TABLE_200
    , a215 out nocopy JTF_VARCHAR2_TABLE_200
    , a216 out nocopy JTF_VARCHAR2_TABLE_200
    , a217 out nocopy JTF_VARCHAR2_TABLE_200
    , a218 out nocopy JTF_VARCHAR2_TABLE_200
    , a219 out nocopy JTF_VARCHAR2_TABLE_200
    , a220 out nocopy JTF_VARCHAR2_TABLE_200
    , a221 out nocopy JTF_VARCHAR2_TABLE_200
    , a222 out nocopy JTF_VARCHAR2_TABLE_200
    , a223 out nocopy JTF_VARCHAR2_TABLE_200
    , a224 out nocopy JTF_VARCHAR2_TABLE_200
    , a225 out nocopy JTF_VARCHAR2_TABLE_200
    , a226 out nocopy JTF_VARCHAR2_TABLE_200
    , a227 out nocopy JTF_VARCHAR2_TABLE_200
    , a228 out nocopy JTF_VARCHAR2_TABLE_200
    , a229 out nocopy JTF_VARCHAR2_TABLE_200
    , a230 out nocopy JTF_VARCHAR2_TABLE_200
    , a231 out nocopy JTF_VARCHAR2_TABLE_200
    , a232 out nocopy JTF_VARCHAR2_TABLE_200
    , a233 out nocopy JTF_VARCHAR2_TABLE_200
    , a234 out nocopy JTF_VARCHAR2_TABLE_200
    , a235 out nocopy JTF_VARCHAR2_TABLE_200
    , a236 out nocopy JTF_VARCHAR2_TABLE_200
    , a237 out nocopy JTF_VARCHAR2_TABLE_200
    , a238 out nocopy JTF_VARCHAR2_TABLE_200
    , a239 out nocopy JTF_VARCHAR2_TABLE_200
    , a240 out nocopy JTF_VARCHAR2_TABLE_200
    , a241 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
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
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
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
    a81 := JTF_VARCHAR2_TABLE_200();
    a82 := JTF_VARCHAR2_TABLE_200();
    a83 := JTF_VARCHAR2_TABLE_200();
    a84 := JTF_VARCHAR2_TABLE_200();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_200();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_200();
    a90 := JTF_VARCHAR2_TABLE_200();
    a91 := JTF_VARCHAR2_TABLE_200();
    a92 := JTF_VARCHAR2_TABLE_200();
    a93 := JTF_VARCHAR2_TABLE_200();
    a94 := JTF_VARCHAR2_TABLE_200();
    a95 := JTF_VARCHAR2_TABLE_200();
    a96 := JTF_VARCHAR2_TABLE_200();
    a97 := JTF_VARCHAR2_TABLE_200();
    a98 := JTF_VARCHAR2_TABLE_200();
    a99 := JTF_VARCHAR2_TABLE_200();
    a100 := JTF_VARCHAR2_TABLE_200();
    a101 := JTF_VARCHAR2_TABLE_200();
    a102 := JTF_VARCHAR2_TABLE_200();
    a103 := JTF_VARCHAR2_TABLE_200();
    a104 := JTF_VARCHAR2_TABLE_200();
    a105 := JTF_VARCHAR2_TABLE_200();
    a106 := JTF_VARCHAR2_TABLE_200();
    a107 := JTF_VARCHAR2_TABLE_200();
    a108 := JTF_VARCHAR2_TABLE_200();
    a109 := JTF_VARCHAR2_TABLE_200();
    a110 := JTF_VARCHAR2_TABLE_200();
    a111 := JTF_VARCHAR2_TABLE_200();
    a112 := JTF_VARCHAR2_TABLE_200();
    a113 := JTF_VARCHAR2_TABLE_200();
    a114 := JTF_VARCHAR2_TABLE_200();
    a115 := JTF_VARCHAR2_TABLE_200();
    a116 := JTF_VARCHAR2_TABLE_200();
    a117 := JTF_VARCHAR2_TABLE_200();
    a118 := JTF_VARCHAR2_TABLE_200();
    a119 := JTF_VARCHAR2_TABLE_200();
    a120 := JTF_VARCHAR2_TABLE_200();
    a121 := JTF_VARCHAR2_TABLE_200();
    a122 := JTF_VARCHAR2_TABLE_200();
    a123 := JTF_VARCHAR2_TABLE_200();
    a124 := JTF_VARCHAR2_TABLE_200();
    a125 := JTF_VARCHAR2_TABLE_200();
    a126 := JTF_VARCHAR2_TABLE_200();
    a127 := JTF_VARCHAR2_TABLE_200();
    a128 := JTF_VARCHAR2_TABLE_200();
    a129 := JTF_VARCHAR2_TABLE_200();
    a130 := JTF_VARCHAR2_TABLE_200();
    a131 := JTF_VARCHAR2_TABLE_200();
    a132 := JTF_VARCHAR2_TABLE_200();
    a133 := JTF_VARCHAR2_TABLE_200();
    a134 := JTF_VARCHAR2_TABLE_200();
    a135 := JTF_VARCHAR2_TABLE_200();
    a136 := JTF_VARCHAR2_TABLE_200();
    a137 := JTF_VARCHAR2_TABLE_200();
    a138 := JTF_VARCHAR2_TABLE_200();
    a139 := JTF_VARCHAR2_TABLE_200();
    a140 := JTF_VARCHAR2_TABLE_200();
    a141 := JTF_VARCHAR2_TABLE_200();
    a142 := JTF_VARCHAR2_TABLE_200();
    a143 := JTF_VARCHAR2_TABLE_200();
    a144 := JTF_VARCHAR2_TABLE_200();
    a145 := JTF_VARCHAR2_TABLE_200();
    a146 := JTF_VARCHAR2_TABLE_200();
    a147 := JTF_VARCHAR2_TABLE_200();
    a148 := JTF_VARCHAR2_TABLE_200();
    a149 := JTF_VARCHAR2_TABLE_200();
    a150 := JTF_VARCHAR2_TABLE_200();
    a151 := JTF_VARCHAR2_TABLE_200();
    a152 := JTF_VARCHAR2_TABLE_200();
    a153 := JTF_VARCHAR2_TABLE_200();
    a154 := JTF_VARCHAR2_TABLE_200();
    a155 := JTF_VARCHAR2_TABLE_200();
    a156 := JTF_VARCHAR2_TABLE_200();
    a157 := JTF_VARCHAR2_TABLE_200();
    a158 := JTF_VARCHAR2_TABLE_200();
    a159 := JTF_VARCHAR2_TABLE_200();
    a160 := JTF_VARCHAR2_TABLE_200();
    a161 := JTF_VARCHAR2_TABLE_200();
    a162 := JTF_VARCHAR2_TABLE_200();
    a163 := JTF_VARCHAR2_TABLE_200();
    a164 := JTF_VARCHAR2_TABLE_200();
    a165 := JTF_VARCHAR2_TABLE_200();
    a166 := JTF_VARCHAR2_TABLE_200();
    a167 := JTF_VARCHAR2_TABLE_200();
    a168 := JTF_VARCHAR2_TABLE_200();
    a169 := JTF_VARCHAR2_TABLE_200();
    a170 := JTF_VARCHAR2_TABLE_200();
    a171 := JTF_VARCHAR2_TABLE_200();
    a172 := JTF_VARCHAR2_TABLE_200();
    a173 := JTF_VARCHAR2_TABLE_200();
    a174 := JTF_VARCHAR2_TABLE_200();
    a175 := JTF_VARCHAR2_TABLE_200();
    a176 := JTF_VARCHAR2_TABLE_200();
    a177 := JTF_VARCHAR2_TABLE_200();
    a178 := JTF_VARCHAR2_TABLE_200();
    a179 := JTF_VARCHAR2_TABLE_200();
    a180 := JTF_VARCHAR2_TABLE_200();
    a181 := JTF_VARCHAR2_TABLE_200();
    a182 := JTF_VARCHAR2_TABLE_200();
    a183 := JTF_VARCHAR2_TABLE_200();
    a184 := JTF_VARCHAR2_TABLE_200();
    a185 := JTF_VARCHAR2_TABLE_200();
    a186 := JTF_VARCHAR2_TABLE_200();
    a187 := JTF_VARCHAR2_TABLE_200();
    a188 := JTF_VARCHAR2_TABLE_200();
    a189 := JTF_VARCHAR2_TABLE_200();
    a190 := JTF_VARCHAR2_TABLE_200();
    a191 := JTF_VARCHAR2_TABLE_200();
    a192 := JTF_VARCHAR2_TABLE_200();
    a193 := JTF_VARCHAR2_TABLE_200();
    a194 := JTF_VARCHAR2_TABLE_200();
    a195 := JTF_VARCHAR2_TABLE_200();
    a196 := JTF_VARCHAR2_TABLE_200();
    a197 := JTF_VARCHAR2_TABLE_200();
    a198 := JTF_VARCHAR2_TABLE_200();
    a199 := JTF_VARCHAR2_TABLE_200();
    a200 := JTF_VARCHAR2_TABLE_200();
    a201 := JTF_VARCHAR2_TABLE_200();
    a202 := JTF_VARCHAR2_TABLE_200();
    a203 := JTF_VARCHAR2_TABLE_200();
    a204 := JTF_VARCHAR2_TABLE_200();
    a205 := JTF_DATE_TABLE();
    a206 := JTF_DATE_TABLE();
    a207 := JTF_DATE_TABLE();
    a208 := JTF_DATE_TABLE();
    a209 := JTF_VARCHAR2_TABLE_100();
    a210 := JTF_VARCHAR2_TABLE_100();
    a211 := JTF_VARCHAR2_TABLE_200();
    a212 := JTF_VARCHAR2_TABLE_200();
    a213 := JTF_VARCHAR2_TABLE_200();
    a214 := JTF_VARCHAR2_TABLE_200();
    a215 := JTF_VARCHAR2_TABLE_200();
    a216 := JTF_VARCHAR2_TABLE_200();
    a217 := JTF_VARCHAR2_TABLE_200();
    a218 := JTF_VARCHAR2_TABLE_200();
    a219 := JTF_VARCHAR2_TABLE_200();
    a220 := JTF_VARCHAR2_TABLE_200();
    a221 := JTF_VARCHAR2_TABLE_200();
    a222 := JTF_VARCHAR2_TABLE_200();
    a223 := JTF_VARCHAR2_TABLE_200();
    a224 := JTF_VARCHAR2_TABLE_200();
    a225 := JTF_VARCHAR2_TABLE_200();
    a226 := JTF_VARCHAR2_TABLE_200();
    a227 := JTF_VARCHAR2_TABLE_200();
    a228 := JTF_VARCHAR2_TABLE_200();
    a229 := JTF_VARCHAR2_TABLE_200();
    a230 := JTF_VARCHAR2_TABLE_200();
    a231 := JTF_VARCHAR2_TABLE_200();
    a232 := JTF_VARCHAR2_TABLE_200();
    a233 := JTF_VARCHAR2_TABLE_200();
    a234 := JTF_VARCHAR2_TABLE_200();
    a235 := JTF_VARCHAR2_TABLE_200();
    a236 := JTF_VARCHAR2_TABLE_200();
    a237 := JTF_VARCHAR2_TABLE_200();
    a238 := JTF_VARCHAR2_TABLE_200();
    a239 := JTF_VARCHAR2_TABLE_200();
    a240 := JTF_VARCHAR2_TABLE_200();
    a241 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
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
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
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
      a81 := JTF_VARCHAR2_TABLE_200();
      a82 := JTF_VARCHAR2_TABLE_200();
      a83 := JTF_VARCHAR2_TABLE_200();
      a84 := JTF_VARCHAR2_TABLE_200();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_200();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_200();
      a90 := JTF_VARCHAR2_TABLE_200();
      a91 := JTF_VARCHAR2_TABLE_200();
      a92 := JTF_VARCHAR2_TABLE_200();
      a93 := JTF_VARCHAR2_TABLE_200();
      a94 := JTF_VARCHAR2_TABLE_200();
      a95 := JTF_VARCHAR2_TABLE_200();
      a96 := JTF_VARCHAR2_TABLE_200();
      a97 := JTF_VARCHAR2_TABLE_200();
      a98 := JTF_VARCHAR2_TABLE_200();
      a99 := JTF_VARCHAR2_TABLE_200();
      a100 := JTF_VARCHAR2_TABLE_200();
      a101 := JTF_VARCHAR2_TABLE_200();
      a102 := JTF_VARCHAR2_TABLE_200();
      a103 := JTF_VARCHAR2_TABLE_200();
      a104 := JTF_VARCHAR2_TABLE_200();
      a105 := JTF_VARCHAR2_TABLE_200();
      a106 := JTF_VARCHAR2_TABLE_200();
      a107 := JTF_VARCHAR2_TABLE_200();
      a108 := JTF_VARCHAR2_TABLE_200();
      a109 := JTF_VARCHAR2_TABLE_200();
      a110 := JTF_VARCHAR2_TABLE_200();
      a111 := JTF_VARCHAR2_TABLE_200();
      a112 := JTF_VARCHAR2_TABLE_200();
      a113 := JTF_VARCHAR2_TABLE_200();
      a114 := JTF_VARCHAR2_TABLE_200();
      a115 := JTF_VARCHAR2_TABLE_200();
      a116 := JTF_VARCHAR2_TABLE_200();
      a117 := JTF_VARCHAR2_TABLE_200();
      a118 := JTF_VARCHAR2_TABLE_200();
      a119 := JTF_VARCHAR2_TABLE_200();
      a120 := JTF_VARCHAR2_TABLE_200();
      a121 := JTF_VARCHAR2_TABLE_200();
      a122 := JTF_VARCHAR2_TABLE_200();
      a123 := JTF_VARCHAR2_TABLE_200();
      a124 := JTF_VARCHAR2_TABLE_200();
      a125 := JTF_VARCHAR2_TABLE_200();
      a126 := JTF_VARCHAR2_TABLE_200();
      a127 := JTF_VARCHAR2_TABLE_200();
      a128 := JTF_VARCHAR2_TABLE_200();
      a129 := JTF_VARCHAR2_TABLE_200();
      a130 := JTF_VARCHAR2_TABLE_200();
      a131 := JTF_VARCHAR2_TABLE_200();
      a132 := JTF_VARCHAR2_TABLE_200();
      a133 := JTF_VARCHAR2_TABLE_200();
      a134 := JTF_VARCHAR2_TABLE_200();
      a135 := JTF_VARCHAR2_TABLE_200();
      a136 := JTF_VARCHAR2_TABLE_200();
      a137 := JTF_VARCHAR2_TABLE_200();
      a138 := JTF_VARCHAR2_TABLE_200();
      a139 := JTF_VARCHAR2_TABLE_200();
      a140 := JTF_VARCHAR2_TABLE_200();
      a141 := JTF_VARCHAR2_TABLE_200();
      a142 := JTF_VARCHAR2_TABLE_200();
      a143 := JTF_VARCHAR2_TABLE_200();
      a144 := JTF_VARCHAR2_TABLE_200();
      a145 := JTF_VARCHAR2_TABLE_200();
      a146 := JTF_VARCHAR2_TABLE_200();
      a147 := JTF_VARCHAR2_TABLE_200();
      a148 := JTF_VARCHAR2_TABLE_200();
      a149 := JTF_VARCHAR2_TABLE_200();
      a150 := JTF_VARCHAR2_TABLE_200();
      a151 := JTF_VARCHAR2_TABLE_200();
      a152 := JTF_VARCHAR2_TABLE_200();
      a153 := JTF_VARCHAR2_TABLE_200();
      a154 := JTF_VARCHAR2_TABLE_200();
      a155 := JTF_VARCHAR2_TABLE_200();
      a156 := JTF_VARCHAR2_TABLE_200();
      a157 := JTF_VARCHAR2_TABLE_200();
      a158 := JTF_VARCHAR2_TABLE_200();
      a159 := JTF_VARCHAR2_TABLE_200();
      a160 := JTF_VARCHAR2_TABLE_200();
      a161 := JTF_VARCHAR2_TABLE_200();
      a162 := JTF_VARCHAR2_TABLE_200();
      a163 := JTF_VARCHAR2_TABLE_200();
      a164 := JTF_VARCHAR2_TABLE_200();
      a165 := JTF_VARCHAR2_TABLE_200();
      a166 := JTF_VARCHAR2_TABLE_200();
      a167 := JTF_VARCHAR2_TABLE_200();
      a168 := JTF_VARCHAR2_TABLE_200();
      a169 := JTF_VARCHAR2_TABLE_200();
      a170 := JTF_VARCHAR2_TABLE_200();
      a171 := JTF_VARCHAR2_TABLE_200();
      a172 := JTF_VARCHAR2_TABLE_200();
      a173 := JTF_VARCHAR2_TABLE_200();
      a174 := JTF_VARCHAR2_TABLE_200();
      a175 := JTF_VARCHAR2_TABLE_200();
      a176 := JTF_VARCHAR2_TABLE_200();
      a177 := JTF_VARCHAR2_TABLE_200();
      a178 := JTF_VARCHAR2_TABLE_200();
      a179 := JTF_VARCHAR2_TABLE_200();
      a180 := JTF_VARCHAR2_TABLE_200();
      a181 := JTF_VARCHAR2_TABLE_200();
      a182 := JTF_VARCHAR2_TABLE_200();
      a183 := JTF_VARCHAR2_TABLE_200();
      a184 := JTF_VARCHAR2_TABLE_200();
      a185 := JTF_VARCHAR2_TABLE_200();
      a186 := JTF_VARCHAR2_TABLE_200();
      a187 := JTF_VARCHAR2_TABLE_200();
      a188 := JTF_VARCHAR2_TABLE_200();
      a189 := JTF_VARCHAR2_TABLE_200();
      a190 := JTF_VARCHAR2_TABLE_200();
      a191 := JTF_VARCHAR2_TABLE_200();
      a192 := JTF_VARCHAR2_TABLE_200();
      a193 := JTF_VARCHAR2_TABLE_200();
      a194 := JTF_VARCHAR2_TABLE_200();
      a195 := JTF_VARCHAR2_TABLE_200();
      a196 := JTF_VARCHAR2_TABLE_200();
      a197 := JTF_VARCHAR2_TABLE_200();
      a198 := JTF_VARCHAR2_TABLE_200();
      a199 := JTF_VARCHAR2_TABLE_200();
      a200 := JTF_VARCHAR2_TABLE_200();
      a201 := JTF_VARCHAR2_TABLE_200();
      a202 := JTF_VARCHAR2_TABLE_200();
      a203 := JTF_VARCHAR2_TABLE_200();
      a204 := JTF_VARCHAR2_TABLE_200();
      a205 := JTF_DATE_TABLE();
      a206 := JTF_DATE_TABLE();
      a207 := JTF_DATE_TABLE();
      a208 := JTF_DATE_TABLE();
      a209 := JTF_VARCHAR2_TABLE_100();
      a210 := JTF_VARCHAR2_TABLE_100();
      a211 := JTF_VARCHAR2_TABLE_200();
      a212 := JTF_VARCHAR2_TABLE_200();
      a213 := JTF_VARCHAR2_TABLE_200();
      a214 := JTF_VARCHAR2_TABLE_200();
      a215 := JTF_VARCHAR2_TABLE_200();
      a216 := JTF_VARCHAR2_TABLE_200();
      a217 := JTF_VARCHAR2_TABLE_200();
      a218 := JTF_VARCHAR2_TABLE_200();
      a219 := JTF_VARCHAR2_TABLE_200();
      a220 := JTF_VARCHAR2_TABLE_200();
      a221 := JTF_VARCHAR2_TABLE_200();
      a222 := JTF_VARCHAR2_TABLE_200();
      a223 := JTF_VARCHAR2_TABLE_200();
      a224 := JTF_VARCHAR2_TABLE_200();
      a225 := JTF_VARCHAR2_TABLE_200();
      a226 := JTF_VARCHAR2_TABLE_200();
      a227 := JTF_VARCHAR2_TABLE_200();
      a228 := JTF_VARCHAR2_TABLE_200();
      a229 := JTF_VARCHAR2_TABLE_200();
      a230 := JTF_VARCHAR2_TABLE_200();
      a231 := JTF_VARCHAR2_TABLE_200();
      a232 := JTF_VARCHAR2_TABLE_200();
      a233 := JTF_VARCHAR2_TABLE_200();
      a234 := JTF_VARCHAR2_TABLE_200();
      a235 := JTF_VARCHAR2_TABLE_200();
      a236 := JTF_VARCHAR2_TABLE_200();
      a237 := JTF_VARCHAR2_TABLE_200();
      a238 := JTF_VARCHAR2_TABLE_200();
      a239 := JTF_VARCHAR2_TABLE_200();
      a240 := JTF_VARCHAR2_TABLE_200();
      a241 := JTF_VARCHAR2_TABLE_100();
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
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        a178.extend(t.count);
        a179.extend(t.count);
        a180.extend(t.count);
        a181.extend(t.count);
        a182.extend(t.count);
        a183.extend(t.count);
        a184.extend(t.count);
        a185.extend(t.count);
        a186.extend(t.count);
        a187.extend(t.count);
        a188.extend(t.count);
        a189.extend(t.count);
        a190.extend(t.count);
        a191.extend(t.count);
        a192.extend(t.count);
        a193.extend(t.count);
        a194.extend(t.count);
        a195.extend(t.count);
        a196.extend(t.count);
        a197.extend(t.count);
        a198.extend(t.count);
        a199.extend(t.count);
        a200.extend(t.count);
        a201.extend(t.count);
        a202.extend(t.count);
        a203.extend(t.count);
        a204.extend(t.count);
        a205.extend(t.count);
        a206.extend(t.count);
        a207.extend(t.count);
        a208.extend(t.count);
        a209.extend(t.count);
        a210.extend(t.count);
        a211.extend(t.count);
        a212.extend(t.count);
        a213.extend(t.count);
        a214.extend(t.count);
        a215.extend(t.count);
        a216.extend(t.count);
        a217.extend(t.count);
        a218.extend(t.count);
        a219.extend(t.count);
        a220.extend(t.count);
        a221.extend(t.count);
        a222.extend(t.count);
        a223.extend(t.count);
        a224.extend(t.count);
        a225.extend(t.count);
        a226.extend(t.count);
        a227.extend(t.count);
        a228.extend(t.count);
        a229.extend(t.count);
        a230.extend(t.count);
        a231.extend(t.count);
        a232.extend(t.count);
        a233.extend(t.count);
        a234.extend(t.count);
        a235.extend(t.count);
        a236.extend(t.count);
        a237.extend(t.count);
        a238.extend(t.count);
        a239.extend(t.count);
        a240.extend(t.count);
        a241.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).price_attrib_history_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_attribute_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a3(indx) := t(ddindx).old_pricing_context;
          a4(indx) := t(ddindx).new_pricing_context;
          a5(indx) := t(ddindx).old_pricing_attribute1;
          a6(indx) := t(ddindx).new_pricing_attribute1;
          a7(indx) := t(ddindx).old_pricing_attribute2;
          a8(indx) := t(ddindx).new_pricing_attribute2;
          a9(indx) := t(ddindx).old_pricing_attribute3;
          a10(indx) := t(ddindx).new_pricing_attribute3;
          a11(indx) := t(ddindx).old_pricing_attribute4;
          a12(indx) := t(ddindx).new_pricing_attribute4;
          a13(indx) := t(ddindx).old_pricing_attribute5;
          a14(indx) := t(ddindx).new_pricing_attribute5;
          a15(indx) := t(ddindx).old_pricing_attribute6;
          a16(indx) := t(ddindx).new_pricing_attribute6;
          a17(indx) := t(ddindx).old_pricing_attribute7;
          a18(indx) := t(ddindx).new_pricing_attribute7;
          a19(indx) := t(ddindx).old_pricing_attribute8;
          a20(indx) := t(ddindx).new_pricing_attribute8;
          a21(indx) := t(ddindx).old_pricing_attribute9;
          a22(indx) := t(ddindx).new_pricing_attribute9;
          a23(indx) := t(ddindx).old_pricing_attribute10;
          a24(indx) := t(ddindx).new_pricing_attribute10;
          a25(indx) := t(ddindx).old_pricing_attribute11;
          a26(indx) := t(ddindx).new_pricing_attribute11;
          a27(indx) := t(ddindx).old_pricing_attribute12;
          a28(indx) := t(ddindx).new_pricing_attribute12;
          a29(indx) := t(ddindx).old_pricing_attribute13;
          a30(indx) := t(ddindx).new_pricing_attribute13;
          a31(indx) := t(ddindx).old_pricing_attribute14;
          a32(indx) := t(ddindx).new_pricing_attribute14;
          a33(indx) := t(ddindx).old_pricing_attribute15;
          a34(indx) := t(ddindx).new_pricing_attribute15;
          a35(indx) := t(ddindx).old_pricing_attribute16;
          a36(indx) := t(ddindx).new_pricing_attribute16;
          a37(indx) := t(ddindx).old_pricing_attribute17;
          a38(indx) := t(ddindx).new_pricing_attribute17;
          a39(indx) := t(ddindx).old_pricing_attribute18;
          a40(indx) := t(ddindx).new_pricing_attribute18;
          a41(indx) := t(ddindx).old_pricing_attribute19;
          a42(indx) := t(ddindx).new_pricing_attribute19;
          a43(indx) := t(ddindx).old_pricing_attribute20;
          a44(indx) := t(ddindx).new_pricing_attribute20;
          a45(indx) := t(ddindx).old_pricing_attribute21;
          a46(indx) := t(ddindx).new_pricing_attribute21;
          a47(indx) := t(ddindx).old_pricing_attribute22;
          a48(indx) := t(ddindx).new_pricing_attribute22;
          a49(indx) := t(ddindx).old_pricing_attribute23;
          a50(indx) := t(ddindx).new_pricing_attribute23;
          a51(indx) := t(ddindx).old_pricing_attribute24;
          a52(indx) := t(ddindx).new_pricing_attribute24;
          a53(indx) := t(ddindx).new_pricing_attribute25;
          a54(indx) := t(ddindx).old_pricing_attribute25;
          a55(indx) := t(ddindx).old_pricing_attribute26;
          a56(indx) := t(ddindx).new_pricing_attribute26;
          a57(indx) := t(ddindx).old_pricing_attribute27;
          a58(indx) := t(ddindx).new_pricing_attribute27;
          a59(indx) := t(ddindx).old_pricing_attribute28;
          a60(indx) := t(ddindx).new_pricing_attribute28;
          a61(indx) := t(ddindx).old_pricing_attribute29;
          a62(indx) := t(ddindx).new_pricing_attribute29;
          a63(indx) := t(ddindx).old_pricing_attribute30;
          a64(indx) := t(ddindx).new_pricing_attribute30;
          a65(indx) := t(ddindx).old_pricing_attribute31;
          a66(indx) := t(ddindx).new_pricing_attribute31;
          a67(indx) := t(ddindx).old_pricing_attribute32;
          a68(indx) := t(ddindx).new_pricing_attribute32;
          a69(indx) := t(ddindx).old_pricing_attribute33;
          a70(indx) := t(ddindx).new_pricing_attribute33;
          a71(indx) := t(ddindx).old_pricing_attribute34;
          a72(indx) := t(ddindx).new_pricing_attribute34;
          a73(indx) := t(ddindx).old_pricing_attribute35;
          a74(indx) := t(ddindx).new_pricing_attribute35;
          a75(indx) := t(ddindx).old_pricing_attribute36;
          a76(indx) := t(ddindx).new_pricing_attribute36;
          a77(indx) := t(ddindx).old_pricing_attribute37;
          a78(indx) := t(ddindx).new_pricing_attribute37;
          a79(indx) := t(ddindx).old_pricing_attribute38;
          a80(indx) := t(ddindx).new_pricing_attribute38;
          a81(indx) := t(ddindx).old_pricing_attribute39;
          a82(indx) := t(ddindx).new_pricing_attribute39;
          a83(indx) := t(ddindx).old_pricing_attribute40;
          a84(indx) := t(ddindx).new_pricing_attribute40;
          a85(indx) := t(ddindx).old_pricing_attribute41;
          a86(indx) := t(ddindx).new_pricing_attribute41;
          a87(indx) := t(ddindx).old_pricing_attribute42;
          a88(indx) := t(ddindx).new_pricing_attribute42;
          a89(indx) := t(ddindx).old_pricing_attribute43;
          a90(indx) := t(ddindx).new_pricing_attribute43;
          a91(indx) := t(ddindx).old_pricing_attribute44;
          a92(indx) := t(ddindx).new_pricing_attribute44;
          a93(indx) := t(ddindx).old_pricing_attribute45;
          a94(indx) := t(ddindx).new_pricing_attribute45;
          a95(indx) := t(ddindx).old_pricing_attribute46;
          a96(indx) := t(ddindx).new_pricing_attribute46;
          a97(indx) := t(ddindx).old_pricing_attribute47;
          a98(indx) := t(ddindx).new_pricing_attribute47;
          a99(indx) := t(ddindx).old_pricing_attribute48;
          a100(indx) := t(ddindx).new_pricing_attribute48;
          a101(indx) := t(ddindx).old_pricing_attribute49;
          a102(indx) := t(ddindx).new_pricing_attribute49;
          a103(indx) := t(ddindx).old_pricing_attribute50;
          a104(indx) := t(ddindx).new_pricing_attribute50;
          a105(indx) := t(ddindx).old_pricing_attribute51;
          a106(indx) := t(ddindx).new_pricing_attribute51;
          a107(indx) := t(ddindx).old_pricing_attribute52;
          a108(indx) := t(ddindx).new_pricing_attribute52;
          a109(indx) := t(ddindx).old_pricing_attribute53;
          a110(indx) := t(ddindx).new_pricing_attribute53;
          a111(indx) := t(ddindx).old_pricing_attribute54;
          a112(indx) := t(ddindx).new_pricing_attribute54;
          a113(indx) := t(ddindx).old_pricing_attribute55;
          a114(indx) := t(ddindx).new_pricing_attribute55;
          a115(indx) := t(ddindx).old_pricing_attribute56;
          a116(indx) := t(ddindx).new_pricing_attribute56;
          a117(indx) := t(ddindx).old_pricing_attribute57;
          a118(indx) := t(ddindx).new_pricing_attribute57;
          a119(indx) := t(ddindx).old_pricing_attribute58;
          a120(indx) := t(ddindx).new_pricing_attribute58;
          a121(indx) := t(ddindx).old_pricing_attribute59;
          a122(indx) := t(ddindx).new_pricing_attribute59;
          a123(indx) := t(ddindx).old_pricing_attribute60;
          a124(indx) := t(ddindx).new_pricing_attribute60;
          a125(indx) := t(ddindx).old_pricing_attribute61;
          a126(indx) := t(ddindx).new_pricing_attribute61;
          a127(indx) := t(ddindx).old_pricing_attribute62;
          a128(indx) := t(ddindx).new_pricing_attribute62;
          a129(indx) := t(ddindx).old_pricing_attribute63;
          a130(indx) := t(ddindx).new_pricing_attribute63;
          a131(indx) := t(ddindx).old_pricing_attribute64;
          a132(indx) := t(ddindx).new_pricing_attribute64;
          a133(indx) := t(ddindx).old_pricing_attribute65;
          a134(indx) := t(ddindx).new_pricing_attribute65;
          a135(indx) := t(ddindx).old_pricing_attribute66;
          a136(indx) := t(ddindx).new_pricing_attribute66;
          a137(indx) := t(ddindx).old_pricing_attribute67;
          a138(indx) := t(ddindx).new_pricing_attribute67;
          a139(indx) := t(ddindx).old_pricing_attribute68;
          a140(indx) := t(ddindx).new_pricing_attribute68;
          a141(indx) := t(ddindx).old_pricing_attribute69;
          a142(indx) := t(ddindx).new_pricing_attribute69;
          a143(indx) := t(ddindx).old_pricing_attribute70;
          a144(indx) := t(ddindx).new_pricing_attribute70;
          a145(indx) := t(ddindx).old_pricing_attribute71;
          a146(indx) := t(ddindx).new_pricing_attribute71;
          a147(indx) := t(ddindx).old_pricing_attribute72;
          a148(indx) := t(ddindx).new_pricing_attribute72;
          a149(indx) := t(ddindx).old_pricing_attribute73;
          a150(indx) := t(ddindx).new_pricing_attribute73;
          a151(indx) := t(ddindx).old_pricing_attribute74;
          a152(indx) := t(ddindx).new_pricing_attribute74;
          a153(indx) := t(ddindx).old_pricing_attribute75;
          a154(indx) := t(ddindx).new_pricing_attribute75;
          a155(indx) := t(ddindx).old_pricing_attribute76;
          a156(indx) := t(ddindx).new_pricing_attribute76;
          a157(indx) := t(ddindx).old_pricing_attribute77;
          a158(indx) := t(ddindx).new_pricing_attribute77;
          a159(indx) := t(ddindx).old_pricing_attribute78;
          a160(indx) := t(ddindx).new_pricing_attribute78;
          a161(indx) := t(ddindx).old_pricing_attribute79;
          a162(indx) := t(ddindx).new_pricing_attribute79;
          a163(indx) := t(ddindx).old_pricing_attribute80;
          a164(indx) := t(ddindx).new_pricing_attribute80;
          a165(indx) := t(ddindx).old_pricing_attribute81;
          a166(indx) := t(ddindx).new_pricing_attribute81;
          a167(indx) := t(ddindx).old_pricing_attribute82;
          a168(indx) := t(ddindx).new_pricing_attribute82;
          a169(indx) := t(ddindx).old_pricing_attribute83;
          a170(indx) := t(ddindx).new_pricing_attribute83;
          a171(indx) := t(ddindx).old_pricing_attribute84;
          a172(indx) := t(ddindx).new_pricing_attribute84;
          a173(indx) := t(ddindx).old_pricing_attribute85;
          a174(indx) := t(ddindx).new_pricing_attribute85;
          a175(indx) := t(ddindx).old_pricing_attribute86;
          a176(indx) := t(ddindx).new_pricing_attribute86;
          a177(indx) := t(ddindx).old_pricing_attribute87;
          a178(indx) := t(ddindx).new_pricing_attribute87;
          a179(indx) := t(ddindx).old_pricing_attribute88;
          a180(indx) := t(ddindx).new_pricing_attribute88;
          a181(indx) := t(ddindx).old_pricing_attribute89;
          a182(indx) := t(ddindx).new_pricing_attribute89;
          a183(indx) := t(ddindx).old_pricing_attribute90;
          a184(indx) := t(ddindx).new_pricing_attribute90;
          a185(indx) := t(ddindx).old_pricing_attribute91;
          a186(indx) := t(ddindx).new_pricing_attribute91;
          a187(indx) := t(ddindx).old_pricing_attribute92;
          a188(indx) := t(ddindx).new_pricing_attribute92;
          a189(indx) := t(ddindx).old_pricing_attribute93;
          a190(indx) := t(ddindx).new_pricing_attribute93;
          a191(indx) := t(ddindx).old_pricing_attribute94;
          a192(indx) := t(ddindx).new_pricing_attribute94;
          a193(indx) := t(ddindx).old_pricing_attribute95;
          a194(indx) := t(ddindx).new_pricing_attribute95;
          a195(indx) := t(ddindx).old_pricing_attribute96;
          a196(indx) := t(ddindx).new_pricing_attribute96;
          a197(indx) := t(ddindx).old_pricing_attribute97;
          a198(indx) := t(ddindx).new_pricing_attribute97;
          a199(indx) := t(ddindx).old_pricing_attribute98;
          a200(indx) := t(ddindx).new_pricing_attribute98;
          a201(indx) := t(ddindx).old_pricing_attribute99;
          a202(indx) := t(ddindx).new_pricing_attribute99;
          a203(indx) := t(ddindx).old_pricing_attribute100;
          a204(indx) := t(ddindx).new_pricing_attribute100;
          a205(indx) := t(ddindx).old_active_start_date;
          a206(indx) := t(ddindx).new_active_start_date;
          a207(indx) := t(ddindx).old_active_end_date;
          a208(indx) := t(ddindx).new_active_end_date;
          a209(indx) := t(ddindx).old_context;
          a210(indx) := t(ddindx).new_context;
          a211(indx) := t(ddindx).old_attribute1;
          a212(indx) := t(ddindx).new_attribute1;
          a213(indx) := t(ddindx).old_attribute2;
          a214(indx) := t(ddindx).new_attribute2;
          a215(indx) := t(ddindx).old_attribute3;
          a216(indx) := t(ddindx).new_attribute3;
          a217(indx) := t(ddindx).old_attribute4;
          a218(indx) := t(ddindx).new_attribute4;
          a219(indx) := t(ddindx).old_attribute5;
          a220(indx) := t(ddindx).new_attribute5;
          a221(indx) := t(ddindx).old_attribute6;
          a222(indx) := t(ddindx).new_attribute6;
          a223(indx) := t(ddindx).old_attribute7;
          a224(indx) := t(ddindx).new_attribute7;
          a225(indx) := t(ddindx).old_attribute8;
          a226(indx) := t(ddindx).new_attribute8;
          a227(indx) := t(ddindx).old_attribute9;
          a228(indx) := t(ddindx).new_attribute9;
          a229(indx) := t(ddindx).old_attribute10;
          a230(indx) := t(ddindx).new_attribute10;
          a231(indx) := t(ddindx).old_attribute11;
          a232(indx) := t(ddindx).new_attribute11;
          a233(indx) := t(ddindx).old_attribute12;
          a234(indx) := t(ddindx).new_attribute12;
          a235(indx) := t(ddindx).old_attribute13;
          a236(indx) := t(ddindx).new_attribute13;
          a237(indx) := t(ddindx).old_attribute14;
          a238(indx) := t(ddindx).new_attribute14;
          a239(indx) := t(ddindx).old_attribute15;
          a240(indx) := t(ddindx).new_attribute15;
          a241(indx) := t(ddindx).full_dump_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p83;

  procedure rosetta_table_copy_in_p85(t out nocopy csi_datastructures_pub.instance_link_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).start_loc_address1 := a1(indx);
          t(ddindx).start_loc_address2 := a2(indx);
          t(ddindx).start_loc_address3 := a3(indx);
          t(ddindx).start_loc_address4 := a4(indx);
          t(ddindx).start_loc_city := a5(indx);
          t(ddindx).start_loc_state := a6(indx);
          t(ddindx).start_loc_postal_code := a7(indx);
          t(ddindx).start_loc_country := a8(indx);
          t(ddindx).end_loc_address1 := a9(indx);
          t(ddindx).end_loc_address2 := a10(indx);
          t(ddindx).end_loc_address3 := a11(indx);
          t(ddindx).end_loc_address4 := a12(indx);
          t(ddindx).end_loc_city := a13(indx);
          t(ddindx).end_loc_state := a14(indx);
          t(ddindx).end_loc_postal_code := a15(indx);
          t(ddindx).end_loc_country := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p85;
  procedure rosetta_table_copy_out_p85(t csi_datastructures_pub.instance_link_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).start_loc_address1;
          a2(indx) := t(ddindx).start_loc_address2;
          a3(indx) := t(ddindx).start_loc_address3;
          a4(indx) := t(ddindx).start_loc_address4;
          a5(indx) := t(ddindx).start_loc_city;
          a6(indx) := t(ddindx).start_loc_state;
          a7(indx) := t(ddindx).start_loc_postal_code;
          a8(indx) := t(ddindx).start_loc_country;
          a9(indx) := t(ddindx).end_loc_address1;
          a10(indx) := t(ddindx).end_loc_address2;
          a11(indx) := t(ddindx).end_loc_address3;
          a12(indx) := t(ddindx).end_loc_address4;
          a13(indx) := t(ddindx).end_loc_city;
          a14(indx) := t(ddindx).end_loc_state;
          a15(indx) := t(ddindx).end_loc_postal_code;
          a16(indx) := t(ddindx).end_loc_country;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p85;

  procedure rosetta_table_copy_in_p87(t out nocopy csi_datastructures_pub.instance_cz_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).config_instance_hdr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).config_instance_rev_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).config_instance_item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ship_to_site_use_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).sold_to_org_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).instance_name := a7(indx);
          t(ddindx).instance_sequence := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).bill_to_contact_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).ship_to_contact_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).ib_owner := a11(indx);
          t(ddindx).action := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p87;
  procedure rosetta_table_copy_out_p87(t csi_datastructures_pub.instance_cz_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_instance_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).config_instance_hdr_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).config_instance_rev_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).config_instance_item_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_use_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_org_id);
          a7(indx) := t(ddindx).instance_name;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).instance_sequence);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_contact_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_contact_id);
          a11(indx) := t(ddindx).ib_owner;
          a12(indx) := t(ddindx).action;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p87;

  procedure rosetta_table_copy_in_p89(t out nocopy csi_datastructures_pub.ext_attrib_values_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
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
          t(ddindx).attribute_level := a0(indx);
          t(ddindx).attribute_code := a1(indx);
          t(ddindx).attribute_value := a2(indx);
          t(ddindx).attribute_sequence := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p89;
  procedure rosetta_table_copy_out_p89(t csi_datastructures_pub.ext_attrib_values_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).attribute_level;
          a1(indx) := t(ddindx).attribute_code;
          a2(indx) := t(ddindx).attribute_value;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_sequence);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p89;

  procedure rosetta_table_copy_in_p92(t out nocopy csi_datastructures_pub.mtl_txn_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).lot_number := a5(indx);
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).transaction_uom := a7(indx);
          t(ddindx).primary_quantity := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).primary_uom := a9(indx);
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).transaction_action_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).transaction_source_type_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).transfer_transaction_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).serial_control_code := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).lot_control_code := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).trx_source_line_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).transaction_source_id := rosetta_g_miss_num_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p92;
  procedure rosetta_table_copy_out_p92(t csi_datastructures_pub.mtl_txn_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := t(ddindx).transaction_date;
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a5(indx) := t(ddindx).lot_number;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a7(indx) := t(ddindx).transaction_uom;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).primary_quantity);
          a9(indx) := t(ddindx).primary_uom;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_action_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_source_type_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).transfer_transaction_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).serial_control_code);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).lot_control_code);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).trx_source_line_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_source_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p92;

  procedure rosetta_table_copy_in_p94(t out nocopy csi_datastructures_pub.mu_systems_tbl, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).system_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p94;
  procedure rosetta_table_copy_out_p94(t csi_datastructures_pub.mu_systems_tbl, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p94;

end csi_datastructures_pub_w;

/
