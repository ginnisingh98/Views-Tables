--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_PUB_W" as
  /* $Header: cssrrswb.pls 120.3.12010000.4 2010/04/04 04:02:15 rgandhi ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy cs_servicerequest_pub.notes_table, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_32767
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).note := a0(indx);
          t(ddindx).note_detail := a1(indx);
          t(ddindx).note_type := a2(indx);
          t(ddindx).note_context_type_01 := a3(indx);
          t(ddindx).note_context_type_id_01 := a4(indx);
          t(ddindx).note_context_type_02 := a5(indx);
          t(ddindx).note_context_type_id_02 := a6(indx);
          t(ddindx).note_context_type_03 := a7(indx);
          t(ddindx).note_context_type_id_03 := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cs_servicerequest_pub.notes_table, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_32767
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
    a1 := JTF_VARCHAR2_TABLE_32767();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      a1 := JTF_VARCHAR2_TABLE_32767();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).note;
          a1(indx) := t(ddindx).note_detail;
          a2(indx) := t(ddindx).note_type;
          a3(indx) := t(ddindx).note_context_type_01;
          a4(indx) := t(ddindx).note_context_type_id_01;
          a5(indx) := t(ddindx).note_context_type_02;
          a6(indx) := t(ddindx).note_context_type_id_02;
          a7(indx) := t(ddindx).note_context_type_03;
          a8(indx) := t(ddindx).note_context_type_id_03;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cs_servicerequest_pub.contacts_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sr_contact_point_id := a0(indx);
          t(ddindx).party_id := a1(indx);
          t(ddindx).contact_point_id := a2(indx);
          t(ddindx).contact_point_type := a3(indx);
          t(ddindx).primary_flag := a4(indx);
          t(ddindx).contact_type := a5(indx);
          t(ddindx).party_role_code := a6(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cs_servicerequest_pub.contacts_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).sr_contact_point_id;
          a1(indx) := t(ddindx).party_id;
          a2(indx) := t(ddindx).contact_point_id;
          a3(indx) := t(ddindx).contact_point_type;
          a4(indx) := t(ddindx).primary_flag;
          a5(indx) := t(ddindx).contact_type;
          a6(indx) := t(ddindx).party_role_code;
          a7(indx) := t(ddindx).start_date_active;
          a8(indx) := t(ddindx).end_date_active;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p8(t out nocopy cs_servicerequest_pub.ext_attr_grp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).row_identifier := a0(indx);
          t(ddindx).pk_column_1 := a1(indx);
          t(ddindx).pk_column_2 := a2(indx);
          t(ddindx).pk_column_3 := a3(indx);
          t(ddindx).pk_column_4 := a4(indx);
          t(ddindx).pk_column_5 := a5(indx);
          t(ddindx).context := a6(indx);
          t(ddindx).object_name := a7(indx);
          t(ddindx).attr_group_id := a8(indx);
          t(ddindx).attr_group_app_id := a9(indx);
          t(ddindx).attr_group_type := a10(indx);
          t(ddindx).attr_group_name := a11(indx);
          t(ddindx).attr_group_disp_name := a12(indx);
          t(ddindx).mapping_req := a13(indx);
          t(ddindx).operation := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t cs_servicerequest_pub.ext_attr_grp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).row_identifier;
          a1(indx) := t(ddindx).pk_column_1;
          a2(indx) := t(ddindx).pk_column_2;
          a3(indx) := t(ddindx).pk_column_3;
          a4(indx) := t(ddindx).pk_column_4;
          a5(indx) := t(ddindx).pk_column_5;
          a6(indx) := t(ddindx).context;
          a7(indx) := t(ddindx).object_name;
          a8(indx) := t(ddindx).attr_group_id;
          a9(indx) := t(ddindx).attr_group_app_id;
          a10(indx) := t(ddindx).attr_group_type;
          a11(indx) := t(ddindx).attr_group_name;
          a12(indx) := t(ddindx).attr_group_disp_name;
          a13(indx) := t(ddindx).mapping_req;
          a14(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy cs_servicerequest_pub.ext_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).row_identifier := a0(indx);
          t(ddindx).column_name := a1(indx);
          t(ddindx).attr_name := a2(indx);
          t(ddindx).attr_disp_name := a3(indx);
          t(ddindx).attr_value_str := a4(indx);
          t(ddindx).attr_value_num := a5(indx);
          t(ddindx).attr_value_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).attr_value_display := a7(indx);
          t(ddindx).attr_unit_of_measure := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t cs_servicerequest_pub.ext_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_4000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_4000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := t(ddindx).row_identifier;
          a1(indx) := t(ddindx).column_name;
          a2(indx) := t(ddindx).attr_name;
          a3(indx) := t(ddindx).attr_disp_name;
          a4(indx) := t(ddindx).attr_value_str;
          a5(indx) := t(ddindx).attr_value_num;
          a6(indx) := t(ddindx).attr_value_date;
          a7(indx) := t(ddindx).attr_value_display;
          a8(indx) := t(ddindx).attr_unit_of_measure;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p11(t out nocopy cs_servicerequest_pub.resource_validate_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t cs_servicerequest_pub.resource_validate_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy cs_servicerequest_pub.vc2_table, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t cs_servicerequest_pub.vc2_table, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_out_p13;

  procedure initialize_rec(p0_a0 in out nocopy  DATE
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  DATE
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  NUMBER
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  VARCHAR2
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  VARCHAR2
    , p0_a36 in out nocopy  VARCHAR2
    , p0_a37 in out nocopy  VARCHAR2
    , p0_a38 in out nocopy  VARCHAR2
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  VARCHAR2
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  NUMBER
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  NUMBER
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  DATE
    , p0_a61 in out nocopy  NUMBER
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  VARCHAR2
    , p0_a69 in out nocopy  VARCHAR2
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  VARCHAR2
    , p0_a78 in out nocopy  VARCHAR2
    , p0_a79 in out nocopy  VARCHAR2
    , p0_a80 in out nocopy  VARCHAR2
    , p0_a81 in out nocopy  VARCHAR2
    , p0_a82 in out nocopy  VARCHAR2
    , p0_a83 in out nocopy  VARCHAR2
    , p0_a84 in out nocopy  VARCHAR2
    , p0_a85 in out nocopy  VARCHAR2
    , p0_a86 in out nocopy  VARCHAR2
    , p0_a87 in out nocopy  VARCHAR2
    , p0_a88 in out nocopy  VARCHAR2
    , p0_a89 in out nocopy  VARCHAR2
    , p0_a90 in out nocopy  VARCHAR2
    , p0_a91 in out nocopy  VARCHAR2
    , p0_a92 in out nocopy  VARCHAR2
    , p0_a93 in out nocopy  VARCHAR2
    , p0_a94 in out nocopy  NUMBER
    , p0_a95 in out nocopy  NUMBER
    , p0_a96 in out nocopy  NUMBER
    , p0_a97 in out nocopy  NUMBER
    , p0_a98 in out nocopy  VARCHAR2
    , p0_a99 in out nocopy  DATE
    , p0_a100 in out nocopy  VARCHAR2
    , p0_a101 in out nocopy  NUMBER
    , p0_a102 in out nocopy  NUMBER
    , p0_a103 in out nocopy  VARCHAR2
    , p0_a104 in out nocopy  NUMBER
    , p0_a105 in out nocopy  VARCHAR2
    , p0_a106 in out nocopy  NUMBER
    , p0_a107 in out nocopy  NUMBER
    , p0_a108 in out nocopy  VARCHAR2
    , p0_a109 in out nocopy  NUMBER
    , p0_a110 in out nocopy  VARCHAR2
    , p0_a111 in out nocopy  VARCHAR2
    , p0_a112 in out nocopy  VARCHAR2
    , p0_a113 in out nocopy  DATE
    , p0_a114 in out nocopy  NUMBER
    , p0_a115 in out nocopy  NUMBER
    , p0_a116 in out nocopy  NUMBER
    , p0_a117 in out nocopy  NUMBER
    , p0_a118 in out nocopy  NUMBER
    , p0_a119 in out nocopy  VARCHAR2
    , p0_a120 in out nocopy  NUMBER
    , p0_a121 in out nocopy  VARCHAR2
    , p0_a122 in out nocopy  NUMBER
    , p0_a123 in out nocopy  VARCHAR2
    , p0_a124 in out nocopy  NUMBER
    , p0_a125 in out nocopy  VARCHAR2
    , p0_a126 in out nocopy  VARCHAR2
    , p0_a127 in out nocopy  VARCHAR2
    , p0_a128 in out nocopy  VARCHAR2
    , p0_a129 in out nocopy  VARCHAR2
    , p0_a130 in out nocopy  VARCHAR2
    , p0_a131 in out nocopy  NUMBER
    , p0_a132 in out nocopy  NUMBER
    , p0_a133 in out nocopy  VARCHAR2
    , p0_a134 in out nocopy  NUMBER
    , p0_a135 in out nocopy  NUMBER
    , p0_a136 in out nocopy  VARCHAR2
    , p0_a137 in out nocopy  VARCHAR2
    , p0_a138 in out nocopy  VARCHAR2
    , p0_a139 in out nocopy  VARCHAR2
    , p0_a140 in out nocopy  VARCHAR2
    , p0_a141 in out nocopy  VARCHAR2
    , p0_a142 in out nocopy  NUMBER
    , p0_a143 in out nocopy  VARCHAR2
    , p0_a144 in out nocopy  NUMBER
    , p0_a145 in out nocopy  VARCHAR2
    , p0_a146 in out nocopy  DATE
    , p0_a147 in out nocopy  DATE
    , p0_a148 in out nocopy  DATE
    , p0_a149 in out nocopy  VARCHAR2
    , p0_a150 in out nocopy  NUMBER
    , p0_a151 in out nocopy  VARCHAR2
    , p0_a152 in out nocopy  VARCHAR2
    , p0_a153 in out nocopy  VARCHAR2
    , p0_a154 in out nocopy  VARCHAR2
    , p0_a155 in out nocopy  VARCHAR2
    , p0_a156 in out nocopy  VARCHAR2
    , p0_a157 in out nocopy  VARCHAR2
    , p0_a158 in out nocopy  VARCHAR2
    , p0_a159 in out nocopy  VARCHAR2
    , p0_a160 in out nocopy  VARCHAR2
    , p0_a161 in out nocopy  VARCHAR2
    , p0_a162 in out nocopy  VARCHAR2
    , p0_a163 in out nocopy  VARCHAR2
    , p0_a164 in out nocopy  DATE
    , p0_a165 in out nocopy  VARCHAR
    , p0_a166 in out nocopy  VARCHAR
    , p0_a167 in out nocopy  VARCHAR
    , p0_a168 in out nocopy  VARCHAR
    , p0_a169 in out nocopy  NUMBER
    , p0_a170 in out nocopy  NUMBER
    , p0_a171 in out nocopy  NUMBER
    , p0_a172 in out nocopy  NUMBER
    , p0_a173 in out nocopy  NUMBER
    , p0_a174 in out nocopy  VARCHAR2
    , p0_a175 in out nocopy  VARCHAR2
    , p0_a176 in out nocopy  NUMBER
    , p0_a177 in out nocopy  NUMBER
    , p0_a178 in out nocopy  NUMBER
    , p0_a179 in out nocopy  NUMBER
    , p0_a180 in out nocopy  NUMBER
    , p0_a181 in out nocopy  NUMBER
    , p0_a182 in out nocopy  NUMBER
    , p0_a183 in out nocopy  NUMBER
    , p0_a184 in out nocopy  VARCHAR2
    , p0_a185 in out nocopy  VARCHAR2
    , p0_a186 in out nocopy  VARCHAR2
    , p0_a187 in out nocopy  VARCHAR2
    , p0_a188 in out nocopy  VARCHAR2
    , p0_a189 in out nocopy  VARCHAR2
    , p0_a190 in out nocopy  VARCHAR2
    , p0_a191 in out nocopy  VARCHAR2
    , p0_a192 in out nocopy  VARCHAR2
    , p0_a193 in out nocopy  VARCHAR2
    , p0_a194 in out nocopy  VARCHAR2
    , p0_a195 in out nocopy  VARCHAR2
    , p0_a196 in out nocopy  VARCHAR2
    , p0_a197 in out nocopy  VARCHAR2
    , p0_a198 in out nocopy  VARCHAR2
    , p0_a199 in out nocopy  VARCHAR2
    , p0_a200 in out nocopy  VARCHAR2
    , p0_a201 in out nocopy  VARCHAR2
    , p0_a202 in out nocopy  VARCHAR2
    , p0_a203 in out nocopy  VARCHAR2
    , p0_a204 in out nocopy  VARCHAR2
    , p0_a205 in out nocopy  NUMBER
    , p0_a206 in out nocopy  VARCHAR2
    , p0_a207 in out nocopy  NUMBER
    , p0_a208 in out nocopy  VARCHAR2
    , p0_a209 in out nocopy  VARCHAR2
    , p0_a210 in out nocopy  NUMBER
    , p0_a211 in out nocopy  DATE
    , p0_a212 in out nocopy  NUMBER
    , p0_a213 in out nocopy  NUMBER
  )

  as
    ddp_sr_record cs_servicerequest_pub.service_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_sr_record.request_date := rosetta_g_miss_date_in_map(p0_a0);
    ddp_sr_record.type_id := p0_a1;
    ddp_sr_record.type_name := p0_a2;
    ddp_sr_record.status_id := p0_a3;
    ddp_sr_record.status_name := p0_a4;
    ddp_sr_record.severity_id := p0_a5;
    ddp_sr_record.severity_name := p0_a6;
    ddp_sr_record.urgency_id := p0_a7;
    ddp_sr_record.urgency_name := p0_a8;
    ddp_sr_record.closed_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_sr_record.owner_id := p0_a10;
    ddp_sr_record.owner_group_id := p0_a11;
    ddp_sr_record.publish_flag := p0_a12;
    ddp_sr_record.summary := p0_a13;
    ddp_sr_record.caller_type := p0_a14;
    ddp_sr_record.customer_id := p0_a15;
    ddp_sr_record.customer_number := p0_a16;
    ddp_sr_record.employee_id := p0_a17;
    ddp_sr_record.employee_number := p0_a18;
    ddp_sr_record.verify_cp_flag := p0_a19;
    ddp_sr_record.customer_product_id := p0_a20;
    ddp_sr_record.platform_id := p0_a21;
    ddp_sr_record.platform_version := p0_a22;
    ddp_sr_record.db_version := p0_a23;
    ddp_sr_record.platform_version_id := p0_a24;
    ddp_sr_record.cp_component_id := p0_a25;
    ddp_sr_record.cp_component_version_id := p0_a26;
    ddp_sr_record.cp_subcomponent_id := p0_a27;
    ddp_sr_record.cp_subcomponent_version_id := p0_a28;
    ddp_sr_record.language_id := p0_a29;
    ddp_sr_record.language := p0_a30;
    ddp_sr_record.cp_ref_number := p0_a31;
    ddp_sr_record.inventory_item_id := p0_a32;
    ddp_sr_record.inventory_item_conc_segs := p0_a33;
    ddp_sr_record.inventory_item_segment1 := p0_a34;
    ddp_sr_record.inventory_item_segment2 := p0_a35;
    ddp_sr_record.inventory_item_segment3 := p0_a36;
    ddp_sr_record.inventory_item_segment4 := p0_a37;
    ddp_sr_record.inventory_item_segment5 := p0_a38;
    ddp_sr_record.inventory_item_segment6 := p0_a39;
    ddp_sr_record.inventory_item_segment7 := p0_a40;
    ddp_sr_record.inventory_item_segment8 := p0_a41;
    ddp_sr_record.inventory_item_segment9 := p0_a42;
    ddp_sr_record.inventory_item_segment10 := p0_a43;
    ddp_sr_record.inventory_item_segment11 := p0_a44;
    ddp_sr_record.inventory_item_segment12 := p0_a45;
    ddp_sr_record.inventory_item_segment13 := p0_a46;
    ddp_sr_record.inventory_item_segment14 := p0_a47;
    ddp_sr_record.inventory_item_segment15 := p0_a48;
    ddp_sr_record.inventory_item_segment16 := p0_a49;
    ddp_sr_record.inventory_item_segment17 := p0_a50;
    ddp_sr_record.inventory_item_segment18 := p0_a51;
    ddp_sr_record.inventory_item_segment19 := p0_a52;
    ddp_sr_record.inventory_item_segment20 := p0_a53;
    ddp_sr_record.inventory_item_vals_or_ids := p0_a54;
    ddp_sr_record.inventory_org_id := p0_a55;
    ddp_sr_record.current_serial_number := p0_a56;
    ddp_sr_record.original_order_number := p0_a57;
    ddp_sr_record.purchase_order_num := p0_a58;
    ddp_sr_record.problem_code := p0_a59;
    ddp_sr_record.exp_resolution_date := rosetta_g_miss_date_in_map(p0_a60);
    ddp_sr_record.install_site_use_id := p0_a61;
    ddp_sr_record.request_attribute_1 := p0_a62;
    ddp_sr_record.request_attribute_2 := p0_a63;
    ddp_sr_record.request_attribute_3 := p0_a64;
    ddp_sr_record.request_attribute_4 := p0_a65;
    ddp_sr_record.request_attribute_5 := p0_a66;
    ddp_sr_record.request_attribute_6 := p0_a67;
    ddp_sr_record.request_attribute_7 := p0_a68;
    ddp_sr_record.request_attribute_8 := p0_a69;
    ddp_sr_record.request_attribute_9 := p0_a70;
    ddp_sr_record.request_attribute_10 := p0_a71;
    ddp_sr_record.request_attribute_11 := p0_a72;
    ddp_sr_record.request_attribute_12 := p0_a73;
    ddp_sr_record.request_attribute_13 := p0_a74;
    ddp_sr_record.request_attribute_14 := p0_a75;
    ddp_sr_record.request_attribute_15 := p0_a76;
    ddp_sr_record.request_context := p0_a77;
    ddp_sr_record.external_attribute_1 := p0_a78;
    ddp_sr_record.external_attribute_2 := p0_a79;
    ddp_sr_record.external_attribute_3 := p0_a80;
    ddp_sr_record.external_attribute_4 := p0_a81;
    ddp_sr_record.external_attribute_5 := p0_a82;
    ddp_sr_record.external_attribute_6 := p0_a83;
    ddp_sr_record.external_attribute_7 := p0_a84;
    ddp_sr_record.external_attribute_8 := p0_a85;
    ddp_sr_record.external_attribute_9 := p0_a86;
    ddp_sr_record.external_attribute_10 := p0_a87;
    ddp_sr_record.external_attribute_11 := p0_a88;
    ddp_sr_record.external_attribute_12 := p0_a89;
    ddp_sr_record.external_attribute_13 := p0_a90;
    ddp_sr_record.external_attribute_14 := p0_a91;
    ddp_sr_record.external_attribute_15 := p0_a92;
    ddp_sr_record.external_context := p0_a93;
    ddp_sr_record.bill_to_site_use_id := p0_a94;
    ddp_sr_record.bill_to_contact_id := p0_a95;
    ddp_sr_record.ship_to_site_use_id := p0_a96;
    ddp_sr_record.ship_to_contact_id := p0_a97;
    ddp_sr_record.resolution_code := p0_a98;
    ddp_sr_record.act_resolution_date := rosetta_g_miss_date_in_map(p0_a99);
    ddp_sr_record.public_comment_flag := p0_a100;
    ddp_sr_record.parent_interaction_id := p0_a101;
    ddp_sr_record.contract_service_id := p0_a102;
    ddp_sr_record.contract_service_number := p0_a103;
    ddp_sr_record.contract_id := p0_a104;
    ddp_sr_record.project_number := p0_a105;
    ddp_sr_record.qa_collection_plan_id := p0_a106;
    ddp_sr_record.account_id := p0_a107;
    ddp_sr_record.resource_type := p0_a108;
    ddp_sr_record.resource_subtype_id := p0_a109;
    ddp_sr_record.cust_po_number := p0_a110;
    ddp_sr_record.cust_ticket_number := p0_a111;
    ddp_sr_record.sr_creation_channel := p0_a112;
    ddp_sr_record.obligation_date := rosetta_g_miss_date_in_map(p0_a113);
    ddp_sr_record.time_zone_id := p0_a114;
    ddp_sr_record.time_difference := p0_a115;
    ddp_sr_record.site_id := p0_a116;
    ddp_sr_record.customer_site_id := p0_a117;
    ddp_sr_record.territory_id := p0_a118;
    ddp_sr_record.initialize_flag := p0_a119;
    ddp_sr_record.cp_revision_id := p0_a120;
    ddp_sr_record.inv_item_revision := p0_a121;
    ddp_sr_record.inv_component_id := p0_a122;
    ddp_sr_record.inv_component_version := p0_a123;
    ddp_sr_record.inv_subcomponent_id := p0_a124;
    ddp_sr_record.inv_subcomponent_version := p0_a125;
    ddp_sr_record.tier := p0_a126;
    ddp_sr_record.tier_version := p0_a127;
    ddp_sr_record.operating_system := p0_a128;
    ddp_sr_record.operating_system_version := p0_a129;
    ddp_sr_record.database := p0_a130;
    ddp_sr_record.cust_pref_lang_id := p0_a131;
    ddp_sr_record.category_id := p0_a132;
    ddp_sr_record.group_type := p0_a133;
    ddp_sr_record.group_territory_id := p0_a134;
    ddp_sr_record.inv_platform_org_id := p0_a135;
    ddp_sr_record.component_version := p0_a136;
    ddp_sr_record.subcomponent_version := p0_a137;
    ddp_sr_record.product_revision := p0_a138;
    ddp_sr_record.comm_pref_code := p0_a139;
    ddp_sr_record.cust_pref_lang_code := p0_a140;
    ddp_sr_record.last_update_channel := p0_a141;
    ddp_sr_record.category_set_id := p0_a142;
    ddp_sr_record.external_reference := p0_a143;
    ddp_sr_record.system_id := p0_a144;
    ddp_sr_record.error_code := p0_a145;
    ddp_sr_record.incident_occurred_date := rosetta_g_miss_date_in_map(p0_a146);
    ddp_sr_record.incident_resolved_date := rosetta_g_miss_date_in_map(p0_a147);
    ddp_sr_record.inc_responded_by_date := rosetta_g_miss_date_in_map(p0_a148);
    ddp_sr_record.resolution_summary := p0_a149;
    ddp_sr_record.incident_location_id := p0_a150;
    ddp_sr_record.incident_address := p0_a151;
    ddp_sr_record.incident_city := p0_a152;
    ddp_sr_record.incident_state := p0_a153;
    ddp_sr_record.incident_country := p0_a154;
    ddp_sr_record.incident_province := p0_a155;
    ddp_sr_record.incident_postal_code := p0_a156;
    ddp_sr_record.incident_county := p0_a157;
    ddp_sr_record.site_number := p0_a158;
    ddp_sr_record.site_name := p0_a159;
    ddp_sr_record.addressee := p0_a160;
    ddp_sr_record.owner := p0_a161;
    ddp_sr_record.group_owner := p0_a162;
    ddp_sr_record.cc_number := p0_a163;
    ddp_sr_record.cc_expiration_date := rosetta_g_miss_date_in_map(p0_a164);
    ddp_sr_record.cc_type_code := p0_a165;
    ddp_sr_record.cc_first_name := p0_a166;
    ddp_sr_record.cc_last_name := p0_a167;
    ddp_sr_record.cc_middle_name := p0_a168;
    ddp_sr_record.cc_id := p0_a169;
    ddp_sr_record.bill_to_account_id := p0_a170;
    ddp_sr_record.ship_to_account_id := p0_a171;
    ddp_sr_record.customer_phone_id := p0_a172;
    ddp_sr_record.customer_email_id := p0_a173;
    ddp_sr_record.creation_program_code := p0_a174;
    ddp_sr_record.last_update_program_code := p0_a175;
    ddp_sr_record.bill_to_party_id := p0_a176;
    ddp_sr_record.ship_to_party_id := p0_a177;
    ddp_sr_record.program_id := p0_a178;
    ddp_sr_record.program_application_id := p0_a179;
    ddp_sr_record.conc_request_id := p0_a180;
    ddp_sr_record.program_login_id := p0_a181;
    ddp_sr_record.bill_to_site_id := p0_a182;
    ddp_sr_record.ship_to_site_id := p0_a183;
    ddp_sr_record.incident_point_of_interest := p0_a184;
    ddp_sr_record.incident_cross_street := p0_a185;
    ddp_sr_record.incident_direction_qualifier := p0_a186;
    ddp_sr_record.incident_distance_qualifier := p0_a187;
    ddp_sr_record.incident_distance_qual_uom := p0_a188;
    ddp_sr_record.incident_address2 := p0_a189;
    ddp_sr_record.incident_address3 := p0_a190;
    ddp_sr_record.incident_address4 := p0_a191;
    ddp_sr_record.incident_address_style := p0_a192;
    ddp_sr_record.incident_addr_lines_phonetic := p0_a193;
    ddp_sr_record.incident_po_box_number := p0_a194;
    ddp_sr_record.incident_house_number := p0_a195;
    ddp_sr_record.incident_street_suffix := p0_a196;
    ddp_sr_record.incident_street := p0_a197;
    ddp_sr_record.incident_street_number := p0_a198;
    ddp_sr_record.incident_floor := p0_a199;
    ddp_sr_record.incident_suite := p0_a200;
    ddp_sr_record.incident_postal_plus4_code := p0_a201;
    ddp_sr_record.incident_position := p0_a202;
    ddp_sr_record.incident_location_directions := p0_a203;
    ddp_sr_record.incident_location_description := p0_a204;
    ddp_sr_record.install_site_id := p0_a205;
    ddp_sr_record.item_serial_number := p0_a206;
    ddp_sr_record.owning_department_id := p0_a207;
    ddp_sr_record.incident_location_type := p0_a208;
    ddp_sr_record.coverage_type := p0_a209;
    ddp_sr_record.maint_organization_id := p0_a210;
    ddp_sr_record.creation_date := rosetta_g_miss_date_in_map(p0_a211);
    ddp_sr_record.created_by := p0_a212;
    ddp_sr_record.instrument_payment_use_id := p0_a213;

    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.initialize_rec(ddp_sr_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_sr_record.request_date;
    p0_a1 := ddp_sr_record.type_id;
    p0_a2 := ddp_sr_record.type_name;
    p0_a3 := ddp_sr_record.status_id;
    p0_a4 := ddp_sr_record.status_name;
    p0_a5 := ddp_sr_record.severity_id;
    p0_a6 := ddp_sr_record.severity_name;
    p0_a7 := ddp_sr_record.urgency_id;
    p0_a8 := ddp_sr_record.urgency_name;
    p0_a9 := ddp_sr_record.closed_date;
    p0_a10 := ddp_sr_record.owner_id;
    p0_a11 := ddp_sr_record.owner_group_id;
    p0_a12 := ddp_sr_record.publish_flag;
    p0_a13 := ddp_sr_record.summary;
    p0_a14 := ddp_sr_record.caller_type;
    p0_a15 := ddp_sr_record.customer_id;
    p0_a16 := ddp_sr_record.customer_number;
    p0_a17 := ddp_sr_record.employee_id;
    p0_a18 := ddp_sr_record.employee_number;
    p0_a19 := ddp_sr_record.verify_cp_flag;
    p0_a20 := ddp_sr_record.customer_product_id;
    p0_a21 := ddp_sr_record.platform_id;
    p0_a22 := ddp_sr_record.platform_version;
    p0_a23 := ddp_sr_record.db_version;
    p0_a24 := ddp_sr_record.platform_version_id;
    p0_a25 := ddp_sr_record.cp_component_id;
    p0_a26 := ddp_sr_record.cp_component_version_id;
    p0_a27 := ddp_sr_record.cp_subcomponent_id;
    p0_a28 := ddp_sr_record.cp_subcomponent_version_id;
    p0_a29 := ddp_sr_record.language_id;
    p0_a30 := ddp_sr_record.language;
    p0_a31 := ddp_sr_record.cp_ref_number;
    p0_a32 := ddp_sr_record.inventory_item_id;
    p0_a33 := ddp_sr_record.inventory_item_conc_segs;
    p0_a34 := ddp_sr_record.inventory_item_segment1;
    p0_a35 := ddp_sr_record.inventory_item_segment2;
    p0_a36 := ddp_sr_record.inventory_item_segment3;
    p0_a37 := ddp_sr_record.inventory_item_segment4;
    p0_a38 := ddp_sr_record.inventory_item_segment5;
    p0_a39 := ddp_sr_record.inventory_item_segment6;
    p0_a40 := ddp_sr_record.inventory_item_segment7;
    p0_a41 := ddp_sr_record.inventory_item_segment8;
    p0_a42 := ddp_sr_record.inventory_item_segment9;
    p0_a43 := ddp_sr_record.inventory_item_segment10;
    p0_a44 := ddp_sr_record.inventory_item_segment11;
    p0_a45 := ddp_sr_record.inventory_item_segment12;
    p0_a46 := ddp_sr_record.inventory_item_segment13;
    p0_a47 := ddp_sr_record.inventory_item_segment14;
    p0_a48 := ddp_sr_record.inventory_item_segment15;
    p0_a49 := ddp_sr_record.inventory_item_segment16;
    p0_a50 := ddp_sr_record.inventory_item_segment17;
    p0_a51 := ddp_sr_record.inventory_item_segment18;
    p0_a52 := ddp_sr_record.inventory_item_segment19;
    p0_a53 := ddp_sr_record.inventory_item_segment20;
    p0_a54 := ddp_sr_record.inventory_item_vals_or_ids;
    p0_a55 := ddp_sr_record.inventory_org_id;
    p0_a56 := ddp_sr_record.current_serial_number;
    p0_a57 := ddp_sr_record.original_order_number;
    p0_a58 := ddp_sr_record.purchase_order_num;
    p0_a59 := ddp_sr_record.problem_code;
    p0_a60 := ddp_sr_record.exp_resolution_date;
    p0_a61 := ddp_sr_record.install_site_use_id;
    p0_a62 := ddp_sr_record.request_attribute_1;
    p0_a63 := ddp_sr_record.request_attribute_2;
    p0_a64 := ddp_sr_record.request_attribute_3;
    p0_a65 := ddp_sr_record.request_attribute_4;
    p0_a66 := ddp_sr_record.request_attribute_5;
    p0_a67 := ddp_sr_record.request_attribute_6;
    p0_a68 := ddp_sr_record.request_attribute_7;
    p0_a69 := ddp_sr_record.request_attribute_8;
    p0_a70 := ddp_sr_record.request_attribute_9;
    p0_a71 := ddp_sr_record.request_attribute_10;
    p0_a72 := ddp_sr_record.request_attribute_11;
    p0_a73 := ddp_sr_record.request_attribute_12;
    p0_a74 := ddp_sr_record.request_attribute_13;
    p0_a75 := ddp_sr_record.request_attribute_14;
    p0_a76 := ddp_sr_record.request_attribute_15;
    p0_a77 := ddp_sr_record.request_context;
    p0_a78 := ddp_sr_record.external_attribute_1;
    p0_a79 := ddp_sr_record.external_attribute_2;
    p0_a80 := ddp_sr_record.external_attribute_3;
    p0_a81 := ddp_sr_record.external_attribute_4;
    p0_a82 := ddp_sr_record.external_attribute_5;
    p0_a83 := ddp_sr_record.external_attribute_6;
    p0_a84 := ddp_sr_record.external_attribute_7;
    p0_a85 := ddp_sr_record.external_attribute_8;
    p0_a86 := ddp_sr_record.external_attribute_9;
    p0_a87 := ddp_sr_record.external_attribute_10;
    p0_a88 := ddp_sr_record.external_attribute_11;
    p0_a89 := ddp_sr_record.external_attribute_12;
    p0_a90 := ddp_sr_record.external_attribute_13;
    p0_a91 := ddp_sr_record.external_attribute_14;
    p0_a92 := ddp_sr_record.external_attribute_15;
    p0_a93 := ddp_sr_record.external_context;
    p0_a94 := ddp_sr_record.bill_to_site_use_id;
    p0_a95 := ddp_sr_record.bill_to_contact_id;
    p0_a96 := ddp_sr_record.ship_to_site_use_id;
    p0_a97 := ddp_sr_record.ship_to_contact_id;
    p0_a98 := ddp_sr_record.resolution_code;
    p0_a99 := ddp_sr_record.act_resolution_date;
    p0_a100 := ddp_sr_record.public_comment_flag;
    p0_a101 := ddp_sr_record.parent_interaction_id;
    p0_a102 := ddp_sr_record.contract_service_id;
    p0_a103 := ddp_sr_record.contract_service_number;
    p0_a104 := ddp_sr_record.contract_id;
    p0_a105 := ddp_sr_record.project_number;
    p0_a106 := ddp_sr_record.qa_collection_plan_id;
    p0_a107 := ddp_sr_record.account_id;
    p0_a108 := ddp_sr_record.resource_type;
    p0_a109 := ddp_sr_record.resource_subtype_id;
    p0_a110 := ddp_sr_record.cust_po_number;
    p0_a111 := ddp_sr_record.cust_ticket_number;
    p0_a112 := ddp_sr_record.sr_creation_channel;
    p0_a113 := ddp_sr_record.obligation_date;
    p0_a114 := ddp_sr_record.time_zone_id;
    p0_a115 := ddp_sr_record.time_difference;
    p0_a116 := ddp_sr_record.site_id;
    p0_a117 := ddp_sr_record.customer_site_id;
    p0_a118 := ddp_sr_record.territory_id;
    p0_a119 := ddp_sr_record.initialize_flag;
    p0_a120 := ddp_sr_record.cp_revision_id;
    p0_a121 := ddp_sr_record.inv_item_revision;
    p0_a122 := ddp_sr_record.inv_component_id;
    p0_a123 := ddp_sr_record.inv_component_version;
    p0_a124 := ddp_sr_record.inv_subcomponent_id;
    p0_a125 := ddp_sr_record.inv_subcomponent_version;
    p0_a126 := ddp_sr_record.tier;
    p0_a127 := ddp_sr_record.tier_version;
    p0_a128 := ddp_sr_record.operating_system;
    p0_a129 := ddp_sr_record.operating_system_version;
    p0_a130 := ddp_sr_record.database;
    p0_a131 := ddp_sr_record.cust_pref_lang_id;
    p0_a132 := ddp_sr_record.category_id;
    p0_a133 := ddp_sr_record.group_type;
    p0_a134 := ddp_sr_record.group_territory_id;
    p0_a135 := ddp_sr_record.inv_platform_org_id;
    p0_a136 := ddp_sr_record.component_version;
    p0_a137 := ddp_sr_record.subcomponent_version;
    p0_a138 := ddp_sr_record.product_revision;
    p0_a139 := ddp_sr_record.comm_pref_code;
    p0_a140 := ddp_sr_record.cust_pref_lang_code;
    p0_a141 := ddp_sr_record.last_update_channel;
    p0_a142 := ddp_sr_record.category_set_id;
    p0_a143 := ddp_sr_record.external_reference;
    p0_a144 := ddp_sr_record.system_id;
    p0_a145 := ddp_sr_record.error_code;
    p0_a146 := ddp_sr_record.incident_occurred_date;
    p0_a147 := ddp_sr_record.incident_resolved_date;
    p0_a148 := ddp_sr_record.inc_responded_by_date;
    p0_a149 := ddp_sr_record.resolution_summary;
    p0_a150 := ddp_sr_record.incident_location_id;
    p0_a151 := ddp_sr_record.incident_address;
    p0_a152 := ddp_sr_record.incident_city;
    p0_a153 := ddp_sr_record.incident_state;
    p0_a154 := ddp_sr_record.incident_country;
    p0_a155 := ddp_sr_record.incident_province;
    p0_a156 := ddp_sr_record.incident_postal_code;
    p0_a157 := ddp_sr_record.incident_county;
    p0_a158 := ddp_sr_record.site_number;
    p0_a159 := ddp_sr_record.site_name;
    p0_a160 := ddp_sr_record.addressee;
    p0_a161 := ddp_sr_record.owner;
    p0_a162 := ddp_sr_record.group_owner;
    p0_a163 := ddp_sr_record.cc_number;
    p0_a164 := ddp_sr_record.cc_expiration_date;
    p0_a165 := ddp_sr_record.cc_type_code;
    p0_a166 := ddp_sr_record.cc_first_name;
    p0_a167 := ddp_sr_record.cc_last_name;
    p0_a168 := ddp_sr_record.cc_middle_name;
    p0_a169 := ddp_sr_record.cc_id;
    p0_a170 := ddp_sr_record.bill_to_account_id;
    p0_a171 := ddp_sr_record.ship_to_account_id;
    p0_a172 := ddp_sr_record.customer_phone_id;
    p0_a173 := ddp_sr_record.customer_email_id;
    p0_a174 := ddp_sr_record.creation_program_code;
    p0_a175 := ddp_sr_record.last_update_program_code;
    p0_a176 := ddp_sr_record.bill_to_party_id;
    p0_a177 := ddp_sr_record.ship_to_party_id;
    p0_a178 := ddp_sr_record.program_id;
    p0_a179 := ddp_sr_record.program_application_id;
    p0_a180 := ddp_sr_record.conc_request_id;
    p0_a181 := ddp_sr_record.program_login_id;
    p0_a182 := ddp_sr_record.bill_to_site_id;
    p0_a183 := ddp_sr_record.ship_to_site_id;
    p0_a184 := ddp_sr_record.incident_point_of_interest;
    p0_a185 := ddp_sr_record.incident_cross_street;
    p0_a186 := ddp_sr_record.incident_direction_qualifier;
    p0_a187 := ddp_sr_record.incident_distance_qualifier;
    p0_a188 := ddp_sr_record.incident_distance_qual_uom;
    p0_a189 := ddp_sr_record.incident_address2;
    p0_a190 := ddp_sr_record.incident_address3;
    p0_a191 := ddp_sr_record.incident_address4;
    p0_a192 := ddp_sr_record.incident_address_style;
    p0_a193 := ddp_sr_record.incident_addr_lines_phonetic;
    p0_a194 := ddp_sr_record.incident_po_box_number;
    p0_a195 := ddp_sr_record.incident_house_number;
    p0_a196 := ddp_sr_record.incident_street_suffix;
    p0_a197 := ddp_sr_record.incident_street;
    p0_a198 := ddp_sr_record.incident_street_number;
    p0_a199 := ddp_sr_record.incident_floor;
    p0_a200 := ddp_sr_record.incident_suite;
    p0_a201 := ddp_sr_record.incident_postal_plus4_code;
    p0_a202 := ddp_sr_record.incident_position;
    p0_a203 := ddp_sr_record.incident_location_directions;
    p0_a204 := ddp_sr_record.incident_location_description;
    p0_a205 := ddp_sr_record.install_site_id;
    p0_a206 := ddp_sr_record.item_serial_number;
    p0_a207 := ddp_sr_record.owning_department_id;
    p0_a208 := ddp_sr_record.incident_location_type;
    p0_a209 := ddp_sr_record.coverage_type;
    p0_a210 := ddp_sr_record.maint_organization_id;
    p0_a211 := ddp_sr_record.creation_date;
    p0_a212 := ddp_sr_record.created_by;
    p0_a213 := ddp_sr_record.instrument_payment_use_id;
  end;

  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_auto_assign  VARCHAR2
    , p_auto_generate_tasks  VARCHAR2
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  VARCHAR2
    , p18_a2 out nocopy  NUMBER
    , p18_a3 out nocopy  NUMBER
    , p18_a4 out nocopy  NUMBER
    , p18_a5 out nocopy  NUMBER
    , p18_a6 out nocopy  VARCHAR2
    , p18_a7 out nocopy  VARCHAR2
    , p18_a8 out nocopy  NUMBER
    , p18_a9 out nocopy  NUMBER
    , p18_a10 out nocopy  NUMBER
    , p18_a11 out nocopy  DATE
    , p18_a12 out nocopy  DATE
    , p18_a13 out nocopy  DATE
    , p18_a14 out nocopy  DATE
    , p18_a15 out nocopy  NUMBER
    , p_default_contract_sla_ind  VARCHAR2
    , p_default_coverage_template_id  NUMBER
  )

  as
    ddp_service_request_rec cs_servicerequest_pub.service_request_rec_type;
    ddp_notes cs_servicerequest_pub.notes_table;
    ddp_contacts cs_servicerequest_pub.contacts_table;
    ddx_sr_create_out_rec cs_servicerequest_pub.sr_create_out_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p13_a0);
    ddp_service_request_rec.type_id := p13_a1;
    ddp_service_request_rec.type_name := p13_a2;
    ddp_service_request_rec.status_id := p13_a3;
    ddp_service_request_rec.status_name := p13_a4;
    ddp_service_request_rec.severity_id := p13_a5;
    ddp_service_request_rec.severity_name := p13_a6;
    ddp_service_request_rec.urgency_id := p13_a7;
    ddp_service_request_rec.urgency_name := p13_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p13_a9);
    ddp_service_request_rec.owner_id := p13_a10;
    ddp_service_request_rec.owner_group_id := p13_a11;
    ddp_service_request_rec.publish_flag := p13_a12;
    ddp_service_request_rec.summary := p13_a13;
    ddp_service_request_rec.caller_type := p13_a14;
    ddp_service_request_rec.customer_id := p13_a15;
    ddp_service_request_rec.customer_number := p13_a16;
    ddp_service_request_rec.employee_id := p13_a17;
    ddp_service_request_rec.employee_number := p13_a18;
    ddp_service_request_rec.verify_cp_flag := p13_a19;
    ddp_service_request_rec.customer_product_id := p13_a20;
    ddp_service_request_rec.platform_id := p13_a21;
    ddp_service_request_rec.platform_version := p13_a22;
    ddp_service_request_rec.db_version := p13_a23;
    ddp_service_request_rec.platform_version_id := p13_a24;
    ddp_service_request_rec.cp_component_id := p13_a25;
    ddp_service_request_rec.cp_component_version_id := p13_a26;
    ddp_service_request_rec.cp_subcomponent_id := p13_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p13_a28;
    ddp_service_request_rec.language_id := p13_a29;
    ddp_service_request_rec.language := p13_a30;
    ddp_service_request_rec.cp_ref_number := p13_a31;
    ddp_service_request_rec.inventory_item_id := p13_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p13_a33;
    ddp_service_request_rec.inventory_item_segment1 := p13_a34;
    ddp_service_request_rec.inventory_item_segment2 := p13_a35;
    ddp_service_request_rec.inventory_item_segment3 := p13_a36;
    ddp_service_request_rec.inventory_item_segment4 := p13_a37;
    ddp_service_request_rec.inventory_item_segment5 := p13_a38;
    ddp_service_request_rec.inventory_item_segment6 := p13_a39;
    ddp_service_request_rec.inventory_item_segment7 := p13_a40;
    ddp_service_request_rec.inventory_item_segment8 := p13_a41;
    ddp_service_request_rec.inventory_item_segment9 := p13_a42;
    ddp_service_request_rec.inventory_item_segment10 := p13_a43;
    ddp_service_request_rec.inventory_item_segment11 := p13_a44;
    ddp_service_request_rec.inventory_item_segment12 := p13_a45;
    ddp_service_request_rec.inventory_item_segment13 := p13_a46;
    ddp_service_request_rec.inventory_item_segment14 := p13_a47;
    ddp_service_request_rec.inventory_item_segment15 := p13_a48;
    ddp_service_request_rec.inventory_item_segment16 := p13_a49;
    ddp_service_request_rec.inventory_item_segment17 := p13_a50;
    ddp_service_request_rec.inventory_item_segment18 := p13_a51;
    ddp_service_request_rec.inventory_item_segment19 := p13_a52;
    ddp_service_request_rec.inventory_item_segment20 := p13_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p13_a54;
    ddp_service_request_rec.inventory_org_id := p13_a55;
    ddp_service_request_rec.current_serial_number := p13_a56;
    ddp_service_request_rec.original_order_number := p13_a57;
    ddp_service_request_rec.purchase_order_num := p13_a58;
    ddp_service_request_rec.problem_code := p13_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p13_a60);
    ddp_service_request_rec.install_site_use_id := p13_a61;
    ddp_service_request_rec.request_attribute_1 := p13_a62;
    ddp_service_request_rec.request_attribute_2 := p13_a63;
    ddp_service_request_rec.request_attribute_3 := p13_a64;
    ddp_service_request_rec.request_attribute_4 := p13_a65;
    ddp_service_request_rec.request_attribute_5 := p13_a66;
    ddp_service_request_rec.request_attribute_6 := p13_a67;
    ddp_service_request_rec.request_attribute_7 := p13_a68;
    ddp_service_request_rec.request_attribute_8 := p13_a69;
    ddp_service_request_rec.request_attribute_9 := p13_a70;
    ddp_service_request_rec.request_attribute_10 := p13_a71;
    ddp_service_request_rec.request_attribute_11 := p13_a72;
    ddp_service_request_rec.request_attribute_12 := p13_a73;
    ddp_service_request_rec.request_attribute_13 := p13_a74;
    ddp_service_request_rec.request_attribute_14 := p13_a75;
    ddp_service_request_rec.request_attribute_15 := p13_a76;
    ddp_service_request_rec.request_context := p13_a77;
    ddp_service_request_rec.external_attribute_1 := p13_a78;
    ddp_service_request_rec.external_attribute_2 := p13_a79;
    ddp_service_request_rec.external_attribute_3 := p13_a80;
    ddp_service_request_rec.external_attribute_4 := p13_a81;
    ddp_service_request_rec.external_attribute_5 := p13_a82;
    ddp_service_request_rec.external_attribute_6 := p13_a83;
    ddp_service_request_rec.external_attribute_7 := p13_a84;
    ddp_service_request_rec.external_attribute_8 := p13_a85;
    ddp_service_request_rec.external_attribute_9 := p13_a86;
    ddp_service_request_rec.external_attribute_10 := p13_a87;
    ddp_service_request_rec.external_attribute_11 := p13_a88;
    ddp_service_request_rec.external_attribute_12 := p13_a89;
    ddp_service_request_rec.external_attribute_13 := p13_a90;
    ddp_service_request_rec.external_attribute_14 := p13_a91;
    ddp_service_request_rec.external_attribute_15 := p13_a92;
    ddp_service_request_rec.external_context := p13_a93;
    ddp_service_request_rec.bill_to_site_use_id := p13_a94;
    ddp_service_request_rec.bill_to_contact_id := p13_a95;
    ddp_service_request_rec.ship_to_site_use_id := p13_a96;
    ddp_service_request_rec.ship_to_contact_id := p13_a97;
    ddp_service_request_rec.resolution_code := p13_a98;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p13_a99);
    ddp_service_request_rec.public_comment_flag := p13_a100;
    ddp_service_request_rec.parent_interaction_id := p13_a101;
    ddp_service_request_rec.contract_service_id := p13_a102;
    ddp_service_request_rec.contract_service_number := p13_a103;
    ddp_service_request_rec.contract_id := p13_a104;
    ddp_service_request_rec.project_number := p13_a105;
    ddp_service_request_rec.qa_collection_plan_id := p13_a106;
    ddp_service_request_rec.account_id := p13_a107;
    ddp_service_request_rec.resource_type := p13_a108;
    ddp_service_request_rec.resource_subtype_id := p13_a109;
    ddp_service_request_rec.cust_po_number := p13_a110;
    ddp_service_request_rec.cust_ticket_number := p13_a111;
    ddp_service_request_rec.sr_creation_channel := p13_a112;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p13_a113);
    ddp_service_request_rec.time_zone_id := p13_a114;
    ddp_service_request_rec.time_difference := p13_a115;
    ddp_service_request_rec.site_id := p13_a116;
    ddp_service_request_rec.customer_site_id := p13_a117;
    ddp_service_request_rec.territory_id := p13_a118;
    ddp_service_request_rec.initialize_flag := p13_a119;
    ddp_service_request_rec.cp_revision_id := p13_a120;
    ddp_service_request_rec.inv_item_revision := p13_a121;
    ddp_service_request_rec.inv_component_id := p13_a122;
    ddp_service_request_rec.inv_component_version := p13_a123;
    ddp_service_request_rec.inv_subcomponent_id := p13_a124;
    ddp_service_request_rec.inv_subcomponent_version := p13_a125;
    ddp_service_request_rec.tier := p13_a126;
    ddp_service_request_rec.tier_version := p13_a127;
    ddp_service_request_rec.operating_system := p13_a128;
    ddp_service_request_rec.operating_system_version := p13_a129;
    ddp_service_request_rec.database := p13_a130;
    ddp_service_request_rec.cust_pref_lang_id := p13_a131;
    ddp_service_request_rec.category_id := p13_a132;
    ddp_service_request_rec.group_type := p13_a133;
    ddp_service_request_rec.group_territory_id := p13_a134;
    ddp_service_request_rec.inv_platform_org_id := p13_a135;
    ddp_service_request_rec.component_version := p13_a136;
    ddp_service_request_rec.subcomponent_version := p13_a137;
    ddp_service_request_rec.product_revision := p13_a138;
    ddp_service_request_rec.comm_pref_code := p13_a139;
    ddp_service_request_rec.cust_pref_lang_code := p13_a140;
    ddp_service_request_rec.last_update_channel := p13_a141;
    ddp_service_request_rec.category_set_id := p13_a142;
    ddp_service_request_rec.external_reference := p13_a143;
    ddp_service_request_rec.system_id := p13_a144;
    ddp_service_request_rec.error_code := p13_a145;
    ddp_service_request_rec.incident_occurred_date := rosetta_g_miss_date_in_map(p13_a146);
    ddp_service_request_rec.incident_resolved_date := rosetta_g_miss_date_in_map(p13_a147);
    ddp_service_request_rec.inc_responded_by_date := rosetta_g_miss_date_in_map(p13_a148);
    ddp_service_request_rec.resolution_summary := p13_a149;
    ddp_service_request_rec.incident_location_id := p13_a150;
    ddp_service_request_rec.incident_address := p13_a151;
    ddp_service_request_rec.incident_city := p13_a152;
    ddp_service_request_rec.incident_state := p13_a153;
    ddp_service_request_rec.incident_country := p13_a154;
    ddp_service_request_rec.incident_province := p13_a155;
    ddp_service_request_rec.incident_postal_code := p13_a156;
    ddp_service_request_rec.incident_county := p13_a157;
    ddp_service_request_rec.site_number := p13_a158;
    ddp_service_request_rec.site_name := p13_a159;
    ddp_service_request_rec.addressee := p13_a160;
    ddp_service_request_rec.owner := p13_a161;
    ddp_service_request_rec.group_owner := p13_a162;
    ddp_service_request_rec.cc_number := p13_a163;
    ddp_service_request_rec.cc_expiration_date := rosetta_g_miss_date_in_map(p13_a164);
    ddp_service_request_rec.cc_type_code := p13_a165;
    ddp_service_request_rec.cc_first_name := p13_a166;
    ddp_service_request_rec.cc_last_name := p13_a167;
    ddp_service_request_rec.cc_middle_name := p13_a168;
    ddp_service_request_rec.cc_id := p13_a169;
    ddp_service_request_rec.bill_to_account_id := p13_a170;
    ddp_service_request_rec.ship_to_account_id := p13_a171;
    ddp_service_request_rec.customer_phone_id := p13_a172;
    ddp_service_request_rec.customer_email_id := p13_a173;
    ddp_service_request_rec.creation_program_code := p13_a174;
    ddp_service_request_rec.last_update_program_code := p13_a175;
    ddp_service_request_rec.bill_to_party_id := p13_a176;
    ddp_service_request_rec.ship_to_party_id := p13_a177;
    ddp_service_request_rec.program_id := p13_a178;
    ddp_service_request_rec.program_application_id := p13_a179;
    ddp_service_request_rec.conc_request_id := p13_a180;
    ddp_service_request_rec.program_login_id := p13_a181;
    ddp_service_request_rec.bill_to_site_id := p13_a182;
    ddp_service_request_rec.ship_to_site_id := p13_a183;
    ddp_service_request_rec.incident_point_of_interest := p13_a184;
    ddp_service_request_rec.incident_cross_street := p13_a185;
    ddp_service_request_rec.incident_direction_qualifier := p13_a186;
    ddp_service_request_rec.incident_distance_qualifier := p13_a187;
    ddp_service_request_rec.incident_distance_qual_uom := p13_a188;
    ddp_service_request_rec.incident_address2 := p13_a189;
    ddp_service_request_rec.incident_address3 := p13_a190;
    ddp_service_request_rec.incident_address4 := p13_a191;
    ddp_service_request_rec.incident_address_style := p13_a192;
    ddp_service_request_rec.incident_addr_lines_phonetic := p13_a193;
    ddp_service_request_rec.incident_po_box_number := p13_a194;
    ddp_service_request_rec.incident_house_number := p13_a195;
    ddp_service_request_rec.incident_street_suffix := p13_a196;
    ddp_service_request_rec.incident_street := p13_a197;
    ddp_service_request_rec.incident_street_number := p13_a198;
    ddp_service_request_rec.incident_floor := p13_a199;
    ddp_service_request_rec.incident_suite := p13_a200;
    ddp_service_request_rec.incident_postal_plus4_code := p13_a201;
    ddp_service_request_rec.incident_position := p13_a202;
    ddp_service_request_rec.incident_location_directions := p13_a203;
    ddp_service_request_rec.incident_location_description := p13_a204;
    ddp_service_request_rec.install_site_id := p13_a205;
    ddp_service_request_rec.item_serial_number := p13_a206;
    ddp_service_request_rec.owning_department_id := p13_a207;
    ddp_service_request_rec.incident_location_type := p13_a208;
    ddp_service_request_rec.coverage_type := p13_a209;
    ddp_service_request_rec.maint_organization_id := p13_a210;
    ddp_service_request_rec.creation_date := rosetta_g_miss_date_in_map(p13_a211);
    ddp_service_request_rec.created_by := p13_a212;
    ddp_service_request_rec.instrument_payment_use_id := p13_a213;

    cs_servicerequest_pub_w.rosetta_table_copy_in_p1(ddp_notes, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p3(ddp_contacts, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      );






    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.create_servicerequest(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_request_id,
      p_request_number,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_auto_assign,
      p_auto_generate_tasks,
      ddx_sr_create_out_rec,
      p_default_contract_sla_ind,
      p_default_coverage_template_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















    p18_a0 := ddx_sr_create_out_rec.request_id;
    p18_a1 := ddx_sr_create_out_rec.request_number;
    p18_a2 := ddx_sr_create_out_rec.interaction_id;
    p18_a3 := ddx_sr_create_out_rec.workflow_process_id;
    p18_a4 := ddx_sr_create_out_rec.individual_owner;
    p18_a5 := ddx_sr_create_out_rec.group_owner;
    p18_a6 := ddx_sr_create_out_rec.individual_type;
    p18_a7 := ddx_sr_create_out_rec.auto_task_gen_status;
    if ddx_sr_create_out_rec.auto_task_gen_attempted is null
      then p18_a8 := null;
    elsif ddx_sr_create_out_rec.auto_task_gen_attempted
      then p18_a8 := 1;
    else p18_a8 := 0;
    end if;
    if ddx_sr_create_out_rec.field_service_task_created is null
      then p18_a9 := null;
    elsif ddx_sr_create_out_rec.field_service_task_created
      then p18_a9 := 1;
    else p18_a9 := 0;
    end if;
    p18_a10 := ddx_sr_create_out_rec.contract_service_id;
    p18_a11 := ddx_sr_create_out_rec.resolve_by_date;
    p18_a12 := ddx_sr_create_out_rec.respond_by_date;
    p18_a13 := ddx_sr_create_out_rec.resolved_on_date;
    p18_a14 := ddx_sr_create_out_rec.responded_on_date;
    p18_a15 := ddx_sr_create_out_rec.incident_location_id;


  end;

  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_auto_assign  VARCHAR2
    , p_default_contract_sla_ind  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
    , x_individual_owner out nocopy  NUMBER
    , x_group_owner out nocopy  NUMBER
    , x_individual_type out nocopy  VARCHAR2
  )

  as
    ddp_service_request_rec cs_servicerequest_pub.service_request_rec_type;
    ddp_notes cs_servicerequest_pub.notes_table;
    ddp_contacts cs_servicerequest_pub.contacts_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p13_a0);
    ddp_service_request_rec.type_id := p13_a1;
    ddp_service_request_rec.type_name := p13_a2;
    ddp_service_request_rec.status_id := p13_a3;
    ddp_service_request_rec.status_name := p13_a4;
    ddp_service_request_rec.severity_id := p13_a5;
    ddp_service_request_rec.severity_name := p13_a6;
    ddp_service_request_rec.urgency_id := p13_a7;
    ddp_service_request_rec.urgency_name := p13_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p13_a9);
    ddp_service_request_rec.owner_id := p13_a10;
    ddp_service_request_rec.owner_group_id := p13_a11;
    ddp_service_request_rec.publish_flag := p13_a12;
    ddp_service_request_rec.summary := p13_a13;
    ddp_service_request_rec.caller_type := p13_a14;
    ddp_service_request_rec.customer_id := p13_a15;
    ddp_service_request_rec.customer_number := p13_a16;
    ddp_service_request_rec.employee_id := p13_a17;
    ddp_service_request_rec.employee_number := p13_a18;
    ddp_service_request_rec.verify_cp_flag := p13_a19;
    ddp_service_request_rec.customer_product_id := p13_a20;
    ddp_service_request_rec.platform_id := p13_a21;
    ddp_service_request_rec.platform_version := p13_a22;
    ddp_service_request_rec.db_version := p13_a23;
    ddp_service_request_rec.platform_version_id := p13_a24;
    ddp_service_request_rec.cp_component_id := p13_a25;
    ddp_service_request_rec.cp_component_version_id := p13_a26;
    ddp_service_request_rec.cp_subcomponent_id := p13_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p13_a28;
    ddp_service_request_rec.language_id := p13_a29;
    ddp_service_request_rec.language := p13_a30;
    ddp_service_request_rec.cp_ref_number := p13_a31;
    ddp_service_request_rec.inventory_item_id := p13_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p13_a33;
    ddp_service_request_rec.inventory_item_segment1 := p13_a34;
    ddp_service_request_rec.inventory_item_segment2 := p13_a35;
    ddp_service_request_rec.inventory_item_segment3 := p13_a36;
    ddp_service_request_rec.inventory_item_segment4 := p13_a37;
    ddp_service_request_rec.inventory_item_segment5 := p13_a38;
    ddp_service_request_rec.inventory_item_segment6 := p13_a39;
    ddp_service_request_rec.inventory_item_segment7 := p13_a40;
    ddp_service_request_rec.inventory_item_segment8 := p13_a41;
    ddp_service_request_rec.inventory_item_segment9 := p13_a42;
    ddp_service_request_rec.inventory_item_segment10 := p13_a43;
    ddp_service_request_rec.inventory_item_segment11 := p13_a44;
    ddp_service_request_rec.inventory_item_segment12 := p13_a45;
    ddp_service_request_rec.inventory_item_segment13 := p13_a46;
    ddp_service_request_rec.inventory_item_segment14 := p13_a47;
    ddp_service_request_rec.inventory_item_segment15 := p13_a48;
    ddp_service_request_rec.inventory_item_segment16 := p13_a49;
    ddp_service_request_rec.inventory_item_segment17 := p13_a50;
    ddp_service_request_rec.inventory_item_segment18 := p13_a51;
    ddp_service_request_rec.inventory_item_segment19 := p13_a52;
    ddp_service_request_rec.inventory_item_segment20 := p13_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p13_a54;
    ddp_service_request_rec.inventory_org_id := p13_a55;
    ddp_service_request_rec.current_serial_number := p13_a56;
    ddp_service_request_rec.original_order_number := p13_a57;
    ddp_service_request_rec.purchase_order_num := p13_a58;
    ddp_service_request_rec.problem_code := p13_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p13_a60);
    ddp_service_request_rec.install_site_use_id := p13_a61;
    ddp_service_request_rec.request_attribute_1 := p13_a62;
    ddp_service_request_rec.request_attribute_2 := p13_a63;
    ddp_service_request_rec.request_attribute_3 := p13_a64;
    ddp_service_request_rec.request_attribute_4 := p13_a65;
    ddp_service_request_rec.request_attribute_5 := p13_a66;
    ddp_service_request_rec.request_attribute_6 := p13_a67;
    ddp_service_request_rec.request_attribute_7 := p13_a68;
    ddp_service_request_rec.request_attribute_8 := p13_a69;
    ddp_service_request_rec.request_attribute_9 := p13_a70;
    ddp_service_request_rec.request_attribute_10 := p13_a71;
    ddp_service_request_rec.request_attribute_11 := p13_a72;
    ddp_service_request_rec.request_attribute_12 := p13_a73;
    ddp_service_request_rec.request_attribute_13 := p13_a74;
    ddp_service_request_rec.request_attribute_14 := p13_a75;
    ddp_service_request_rec.request_attribute_15 := p13_a76;
    ddp_service_request_rec.request_context := p13_a77;
    ddp_service_request_rec.external_attribute_1 := p13_a78;
    ddp_service_request_rec.external_attribute_2 := p13_a79;
    ddp_service_request_rec.external_attribute_3 := p13_a80;
    ddp_service_request_rec.external_attribute_4 := p13_a81;
    ddp_service_request_rec.external_attribute_5 := p13_a82;
    ddp_service_request_rec.external_attribute_6 := p13_a83;
    ddp_service_request_rec.external_attribute_7 := p13_a84;
    ddp_service_request_rec.external_attribute_8 := p13_a85;
    ddp_service_request_rec.external_attribute_9 := p13_a86;
    ddp_service_request_rec.external_attribute_10 := p13_a87;
    ddp_service_request_rec.external_attribute_11 := p13_a88;
    ddp_service_request_rec.external_attribute_12 := p13_a89;
    ddp_service_request_rec.external_attribute_13 := p13_a90;
    ddp_service_request_rec.external_attribute_14 := p13_a91;
    ddp_service_request_rec.external_attribute_15 := p13_a92;
    ddp_service_request_rec.external_context := p13_a93;
    ddp_service_request_rec.bill_to_site_use_id := p13_a94;
    ddp_service_request_rec.bill_to_contact_id := p13_a95;
    ddp_service_request_rec.ship_to_site_use_id := p13_a96;
    ddp_service_request_rec.ship_to_contact_id := p13_a97;
    ddp_service_request_rec.resolution_code := p13_a98;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p13_a99);
    ddp_service_request_rec.public_comment_flag := p13_a100;
    ddp_service_request_rec.parent_interaction_id := p13_a101;
    ddp_service_request_rec.contract_service_id := p13_a102;
    ddp_service_request_rec.contract_service_number := p13_a103;
    ddp_service_request_rec.contract_id := p13_a104;
    ddp_service_request_rec.project_number := p13_a105;
    ddp_service_request_rec.qa_collection_plan_id := p13_a106;
    ddp_service_request_rec.account_id := p13_a107;
    ddp_service_request_rec.resource_type := p13_a108;
    ddp_service_request_rec.resource_subtype_id := p13_a109;
    ddp_service_request_rec.cust_po_number := p13_a110;
    ddp_service_request_rec.cust_ticket_number := p13_a111;
    ddp_service_request_rec.sr_creation_channel := p13_a112;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p13_a113);
    ddp_service_request_rec.time_zone_id := p13_a114;
    ddp_service_request_rec.time_difference := p13_a115;
    ddp_service_request_rec.site_id := p13_a116;
    ddp_service_request_rec.customer_site_id := p13_a117;
    ddp_service_request_rec.territory_id := p13_a118;
    ddp_service_request_rec.initialize_flag := p13_a119;
    ddp_service_request_rec.cp_revision_id := p13_a120;
    ddp_service_request_rec.inv_item_revision := p13_a121;
    ddp_service_request_rec.inv_component_id := p13_a122;
    ddp_service_request_rec.inv_component_version := p13_a123;
    ddp_service_request_rec.inv_subcomponent_id := p13_a124;
    ddp_service_request_rec.inv_subcomponent_version := p13_a125;
    ddp_service_request_rec.tier := p13_a126;
    ddp_service_request_rec.tier_version := p13_a127;
    ddp_service_request_rec.operating_system := p13_a128;
    ddp_service_request_rec.operating_system_version := p13_a129;
    ddp_service_request_rec.database := p13_a130;
    ddp_service_request_rec.cust_pref_lang_id := p13_a131;
    ddp_service_request_rec.category_id := p13_a132;
    ddp_service_request_rec.group_type := p13_a133;
    ddp_service_request_rec.group_territory_id := p13_a134;
    ddp_service_request_rec.inv_platform_org_id := p13_a135;
    ddp_service_request_rec.component_version := p13_a136;
    ddp_service_request_rec.subcomponent_version := p13_a137;
    ddp_service_request_rec.product_revision := p13_a138;
    ddp_service_request_rec.comm_pref_code := p13_a139;
    ddp_service_request_rec.cust_pref_lang_code := p13_a140;
    ddp_service_request_rec.last_update_channel := p13_a141;
    ddp_service_request_rec.category_set_id := p13_a142;
    ddp_service_request_rec.external_reference := p13_a143;
    ddp_service_request_rec.system_id := p13_a144;
    ddp_service_request_rec.error_code := p13_a145;
    ddp_service_request_rec.incident_occurred_date := rosetta_g_miss_date_in_map(p13_a146);
    ddp_service_request_rec.incident_resolved_date := rosetta_g_miss_date_in_map(p13_a147);
    ddp_service_request_rec.inc_responded_by_date := rosetta_g_miss_date_in_map(p13_a148);
    ddp_service_request_rec.resolution_summary := p13_a149;
    ddp_service_request_rec.incident_location_id := p13_a150;
    ddp_service_request_rec.incident_address := p13_a151;
    ddp_service_request_rec.incident_city := p13_a152;
    ddp_service_request_rec.incident_state := p13_a153;
    ddp_service_request_rec.incident_country := p13_a154;
    ddp_service_request_rec.incident_province := p13_a155;
    ddp_service_request_rec.incident_postal_code := p13_a156;
    ddp_service_request_rec.incident_county := p13_a157;
    ddp_service_request_rec.site_number := p13_a158;
    ddp_service_request_rec.site_name := p13_a159;
    ddp_service_request_rec.addressee := p13_a160;
    ddp_service_request_rec.owner := p13_a161;
    ddp_service_request_rec.group_owner := p13_a162;
    ddp_service_request_rec.cc_number := p13_a163;
    ddp_service_request_rec.cc_expiration_date := rosetta_g_miss_date_in_map(p13_a164);
    ddp_service_request_rec.cc_type_code := p13_a165;
    ddp_service_request_rec.cc_first_name := p13_a166;
    ddp_service_request_rec.cc_last_name := p13_a167;
    ddp_service_request_rec.cc_middle_name := p13_a168;
    ddp_service_request_rec.cc_id := p13_a169;
    ddp_service_request_rec.bill_to_account_id := p13_a170;
    ddp_service_request_rec.ship_to_account_id := p13_a171;
    ddp_service_request_rec.customer_phone_id := p13_a172;
    ddp_service_request_rec.customer_email_id := p13_a173;
    ddp_service_request_rec.creation_program_code := p13_a174;
    ddp_service_request_rec.last_update_program_code := p13_a175;
    ddp_service_request_rec.bill_to_party_id := p13_a176;
    ddp_service_request_rec.ship_to_party_id := p13_a177;
    ddp_service_request_rec.program_id := p13_a178;
    ddp_service_request_rec.program_application_id := p13_a179;
    ddp_service_request_rec.conc_request_id := p13_a180;
    ddp_service_request_rec.program_login_id := p13_a181;
    ddp_service_request_rec.bill_to_site_id := p13_a182;
    ddp_service_request_rec.ship_to_site_id := p13_a183;
    ddp_service_request_rec.incident_point_of_interest := p13_a184;
    ddp_service_request_rec.incident_cross_street := p13_a185;
    ddp_service_request_rec.incident_direction_qualifier := p13_a186;
    ddp_service_request_rec.incident_distance_qualifier := p13_a187;
    ddp_service_request_rec.incident_distance_qual_uom := p13_a188;
    ddp_service_request_rec.incident_address2 := p13_a189;
    ddp_service_request_rec.incident_address3 := p13_a190;
    ddp_service_request_rec.incident_address4 := p13_a191;
    ddp_service_request_rec.incident_address_style := p13_a192;
    ddp_service_request_rec.incident_addr_lines_phonetic := p13_a193;
    ddp_service_request_rec.incident_po_box_number := p13_a194;
    ddp_service_request_rec.incident_house_number := p13_a195;
    ddp_service_request_rec.incident_street_suffix := p13_a196;
    ddp_service_request_rec.incident_street := p13_a197;
    ddp_service_request_rec.incident_street_number := p13_a198;
    ddp_service_request_rec.incident_floor := p13_a199;
    ddp_service_request_rec.incident_suite := p13_a200;
    ddp_service_request_rec.incident_postal_plus4_code := p13_a201;
    ddp_service_request_rec.incident_position := p13_a202;
    ddp_service_request_rec.incident_location_directions := p13_a203;
    ddp_service_request_rec.incident_location_description := p13_a204;
    ddp_service_request_rec.install_site_id := p13_a205;
    ddp_service_request_rec.item_serial_number := p13_a206;
    ddp_service_request_rec.owning_department_id := p13_a207;
    ddp_service_request_rec.incident_location_type := p13_a208;
    ddp_service_request_rec.coverage_type := p13_a209;
    ddp_service_request_rec.maint_organization_id := p13_a210;
    ddp_service_request_rec.creation_date := rosetta_g_miss_date_in_map(p13_a211);
    ddp_service_request_rec.created_by := p13_a212;
    ddp_service_request_rec.instrument_payment_use_id := p13_a213;

    cs_servicerequest_pub_w.rosetta_table_copy_in_p1(ddp_notes, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p3(ddp_contacts, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      );










    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.create_servicerequest(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_request_id,
      p_request_number,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_auto_assign,
      p_default_contract_sla_ind,
      x_request_id,
      x_request_number,
      x_interaction_id,
      x_workflow_process_id,
      x_individual_owner,
      x_group_owner,
      x_individual_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























  end;

  procedure update_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  VARCHAR2
    , p15_a79  VARCHAR2
    , p15_a80  VARCHAR2
    , p15_a81  VARCHAR2
    , p15_a82  VARCHAR2
    , p15_a83  VARCHAR2
    , p15_a84  VARCHAR2
    , p15_a85  VARCHAR2
    , p15_a86  VARCHAR2
    , p15_a87  VARCHAR2
    , p15_a88  VARCHAR2
    , p15_a89  VARCHAR2
    , p15_a90  VARCHAR2
    , p15_a91  VARCHAR2
    , p15_a92  VARCHAR2
    , p15_a93  VARCHAR2
    , p15_a94  NUMBER
    , p15_a95  NUMBER
    , p15_a96  NUMBER
    , p15_a97  NUMBER
    , p15_a98  VARCHAR2
    , p15_a99  DATE
    , p15_a100  VARCHAR2
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  NUMBER
    , p15_a108  VARCHAR2
    , p15_a109  NUMBER
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  DATE
    , p15_a114  NUMBER
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  NUMBER
    , p15_a118  NUMBER
    , p15_a119  VARCHAR2
    , p15_a120  NUMBER
    , p15_a121  VARCHAR2
    , p15_a122  NUMBER
    , p15_a123  VARCHAR2
    , p15_a124  NUMBER
    , p15_a125  VARCHAR2
    , p15_a126  VARCHAR2
    , p15_a127  VARCHAR2
    , p15_a128  VARCHAR2
    , p15_a129  VARCHAR2
    , p15_a130  VARCHAR2
    , p15_a131  NUMBER
    , p15_a132  NUMBER
    , p15_a133  VARCHAR2
    , p15_a134  NUMBER
    , p15_a135  NUMBER
    , p15_a136  VARCHAR2
    , p15_a137  VARCHAR2
    , p15_a138  VARCHAR2
    , p15_a139  VARCHAR2
    , p15_a140  VARCHAR2
    , p15_a141  VARCHAR2
    , p15_a142  NUMBER
    , p15_a143  VARCHAR2
    , p15_a144  NUMBER
    , p15_a145  VARCHAR2
    , p15_a146  DATE
    , p15_a147  DATE
    , p15_a148  DATE
    , p15_a149  VARCHAR2
    , p15_a150  NUMBER
    , p15_a151  VARCHAR2
    , p15_a152  VARCHAR2
    , p15_a153  VARCHAR2
    , p15_a154  VARCHAR2
    , p15_a155  VARCHAR2
    , p15_a156  VARCHAR2
    , p15_a157  VARCHAR2
    , p15_a158  VARCHAR2
    , p15_a159  VARCHAR2
    , p15_a160  VARCHAR2
    , p15_a161  VARCHAR2
    , p15_a162  VARCHAR2
    , p15_a163  VARCHAR2
    , p15_a164  DATE
    , p15_a165  VARCHAR
    , p15_a166  VARCHAR
    , p15_a167  VARCHAR
    , p15_a168  VARCHAR
    , p15_a169  NUMBER
    , p15_a170  NUMBER
    , p15_a171  NUMBER
    , p15_a172  NUMBER
    , p15_a173  NUMBER
    , p15_a174  VARCHAR2
    , p15_a175  VARCHAR2
    , p15_a176  NUMBER
    , p15_a177  NUMBER
    , p15_a178  NUMBER
    , p15_a179  NUMBER
    , p15_a180  NUMBER
    , p15_a181  NUMBER
    , p15_a182  NUMBER
    , p15_a183  NUMBER
    , p15_a184  VARCHAR2
    , p15_a185  VARCHAR2
    , p15_a186  VARCHAR2
    , p15_a187  VARCHAR2
    , p15_a188  VARCHAR2
    , p15_a189  VARCHAR2
    , p15_a190  VARCHAR2
    , p15_a191  VARCHAR2
    , p15_a192  VARCHAR2
    , p15_a193  VARCHAR2
    , p15_a194  VARCHAR2
    , p15_a195  VARCHAR2
    , p15_a196  VARCHAR2
    , p15_a197  VARCHAR2
    , p15_a198  VARCHAR2
    , p15_a199  VARCHAR2
    , p15_a200  VARCHAR2
    , p15_a201  VARCHAR2
    , p15_a202  VARCHAR2
    , p15_a203  VARCHAR2
    , p15_a204  VARCHAR2
    , p15_a205  NUMBER
    , p15_a206  VARCHAR2
    , p15_a207  NUMBER
    , p15_a208  VARCHAR2
    , p15_a209  VARCHAR2
    , p15_a210  NUMBER
    , p15_a211  DATE
    , p15_a212  NUMBER
    , p15_a213  NUMBER
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p17_a6 JTF_VARCHAR2_TABLE_100
    , p17_a7 JTF_DATE_TABLE
    , p17_a8 JTF_DATE_TABLE
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_auto_assign  VARCHAR2
    , p_validate_sr_closure  VARCHAR2
    , p_auto_close_child_entities  VARCHAR2
    , p_default_contract_sla_ind  VARCHAR2
    , p24_a0 out nocopy  NUMBER
    , p24_a1 out nocopy  NUMBER
    , p24_a2 out nocopy  NUMBER
    , p24_a3 out nocopy  NUMBER
    , p24_a4 out nocopy  VARCHAR2
    , p24_a5 out nocopy  DATE
    , p24_a6 out nocopy  DATE
    , p24_a7 out nocopy  NUMBER
    , p24_a8 out nocopy  DATE
    , p24_a9 out nocopy  NUMBER
  )

  as
    ddp_last_update_date date;
    ddp_service_request_rec cs_servicerequest_pub.service_request_rec_type;
    ddp_notes cs_servicerequest_pub.notes_table;
    ddp_contacts cs_servicerequest_pub.contacts_table;
    ddx_sr_update_out_rec cs_servicerequest_pub.sr_update_out_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);

    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p15_a0);
    ddp_service_request_rec.type_id := p15_a1;
    ddp_service_request_rec.type_name := p15_a2;
    ddp_service_request_rec.status_id := p15_a3;
    ddp_service_request_rec.status_name := p15_a4;
    ddp_service_request_rec.severity_id := p15_a5;
    ddp_service_request_rec.severity_name := p15_a6;
    ddp_service_request_rec.urgency_id := p15_a7;
    ddp_service_request_rec.urgency_name := p15_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p15_a9);
    ddp_service_request_rec.owner_id := p15_a10;
    ddp_service_request_rec.owner_group_id := p15_a11;
    ddp_service_request_rec.publish_flag := p15_a12;
    ddp_service_request_rec.summary := p15_a13;
    ddp_service_request_rec.caller_type := p15_a14;
    ddp_service_request_rec.customer_id := p15_a15;
    ddp_service_request_rec.customer_number := p15_a16;
    ddp_service_request_rec.employee_id := p15_a17;
    ddp_service_request_rec.employee_number := p15_a18;
    ddp_service_request_rec.verify_cp_flag := p15_a19;
    ddp_service_request_rec.customer_product_id := p15_a20;
    ddp_service_request_rec.platform_id := p15_a21;
    ddp_service_request_rec.platform_version := p15_a22;
    ddp_service_request_rec.db_version := p15_a23;
    ddp_service_request_rec.platform_version_id := p15_a24;
    ddp_service_request_rec.cp_component_id := p15_a25;
    ddp_service_request_rec.cp_component_version_id := p15_a26;
    ddp_service_request_rec.cp_subcomponent_id := p15_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p15_a28;
    ddp_service_request_rec.language_id := p15_a29;
    ddp_service_request_rec.language := p15_a30;
    ddp_service_request_rec.cp_ref_number := p15_a31;
    ddp_service_request_rec.inventory_item_id := p15_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p15_a33;
    ddp_service_request_rec.inventory_item_segment1 := p15_a34;
    ddp_service_request_rec.inventory_item_segment2 := p15_a35;
    ddp_service_request_rec.inventory_item_segment3 := p15_a36;
    ddp_service_request_rec.inventory_item_segment4 := p15_a37;
    ddp_service_request_rec.inventory_item_segment5 := p15_a38;
    ddp_service_request_rec.inventory_item_segment6 := p15_a39;
    ddp_service_request_rec.inventory_item_segment7 := p15_a40;
    ddp_service_request_rec.inventory_item_segment8 := p15_a41;
    ddp_service_request_rec.inventory_item_segment9 := p15_a42;
    ddp_service_request_rec.inventory_item_segment10 := p15_a43;
    ddp_service_request_rec.inventory_item_segment11 := p15_a44;
    ddp_service_request_rec.inventory_item_segment12 := p15_a45;
    ddp_service_request_rec.inventory_item_segment13 := p15_a46;
    ddp_service_request_rec.inventory_item_segment14 := p15_a47;
    ddp_service_request_rec.inventory_item_segment15 := p15_a48;
    ddp_service_request_rec.inventory_item_segment16 := p15_a49;
    ddp_service_request_rec.inventory_item_segment17 := p15_a50;
    ddp_service_request_rec.inventory_item_segment18 := p15_a51;
    ddp_service_request_rec.inventory_item_segment19 := p15_a52;
    ddp_service_request_rec.inventory_item_segment20 := p15_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p15_a54;
    ddp_service_request_rec.inventory_org_id := p15_a55;
    ddp_service_request_rec.current_serial_number := p15_a56;
    ddp_service_request_rec.original_order_number := p15_a57;
    ddp_service_request_rec.purchase_order_num := p15_a58;
    ddp_service_request_rec.problem_code := p15_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p15_a60);
    ddp_service_request_rec.install_site_use_id := p15_a61;
    ddp_service_request_rec.request_attribute_1 := p15_a62;
    ddp_service_request_rec.request_attribute_2 := p15_a63;
    ddp_service_request_rec.request_attribute_3 := p15_a64;
    ddp_service_request_rec.request_attribute_4 := p15_a65;
    ddp_service_request_rec.request_attribute_5 := p15_a66;
    ddp_service_request_rec.request_attribute_6 := p15_a67;
    ddp_service_request_rec.request_attribute_7 := p15_a68;
    ddp_service_request_rec.request_attribute_8 := p15_a69;
    ddp_service_request_rec.request_attribute_9 := p15_a70;
    ddp_service_request_rec.request_attribute_10 := p15_a71;
    ddp_service_request_rec.request_attribute_11 := p15_a72;
    ddp_service_request_rec.request_attribute_12 := p15_a73;
    ddp_service_request_rec.request_attribute_13 := p15_a74;
    ddp_service_request_rec.request_attribute_14 := p15_a75;
    ddp_service_request_rec.request_attribute_15 := p15_a76;
    ddp_service_request_rec.request_context := p15_a77;
    ddp_service_request_rec.external_attribute_1 := p15_a78;
    ddp_service_request_rec.external_attribute_2 := p15_a79;
    ddp_service_request_rec.external_attribute_3 := p15_a80;
    ddp_service_request_rec.external_attribute_4 := p15_a81;
    ddp_service_request_rec.external_attribute_5 := p15_a82;
    ddp_service_request_rec.external_attribute_6 := p15_a83;
    ddp_service_request_rec.external_attribute_7 := p15_a84;
    ddp_service_request_rec.external_attribute_8 := p15_a85;
    ddp_service_request_rec.external_attribute_9 := p15_a86;
    ddp_service_request_rec.external_attribute_10 := p15_a87;
    ddp_service_request_rec.external_attribute_11 := p15_a88;
    ddp_service_request_rec.external_attribute_12 := p15_a89;
    ddp_service_request_rec.external_attribute_13 := p15_a90;
    ddp_service_request_rec.external_attribute_14 := p15_a91;
    ddp_service_request_rec.external_attribute_15 := p15_a92;
    ddp_service_request_rec.external_context := p15_a93;
    ddp_service_request_rec.bill_to_site_use_id := p15_a94;
    ddp_service_request_rec.bill_to_contact_id := p15_a95;
    ddp_service_request_rec.ship_to_site_use_id := p15_a96;
    ddp_service_request_rec.ship_to_contact_id := p15_a97;
    ddp_service_request_rec.resolution_code := p15_a98;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p15_a99);
    ddp_service_request_rec.public_comment_flag := p15_a100;
    ddp_service_request_rec.parent_interaction_id := p15_a101;
    ddp_service_request_rec.contract_service_id := p15_a102;
    ddp_service_request_rec.contract_service_number := p15_a103;
    ddp_service_request_rec.contract_id := p15_a104;
    ddp_service_request_rec.project_number := p15_a105;
    ddp_service_request_rec.qa_collection_plan_id := p15_a106;
    ddp_service_request_rec.account_id := p15_a107;
    ddp_service_request_rec.resource_type := p15_a108;
    ddp_service_request_rec.resource_subtype_id := p15_a109;
    ddp_service_request_rec.cust_po_number := p15_a110;
    ddp_service_request_rec.cust_ticket_number := p15_a111;
    ddp_service_request_rec.sr_creation_channel := p15_a112;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p15_a113);
    ddp_service_request_rec.time_zone_id := p15_a114;
    ddp_service_request_rec.time_difference := p15_a115;
    ddp_service_request_rec.site_id := p15_a116;
    ddp_service_request_rec.customer_site_id := p15_a117;
    ddp_service_request_rec.territory_id := p15_a118;
    ddp_service_request_rec.initialize_flag := p15_a119;
    ddp_service_request_rec.cp_revision_id := p15_a120;
    ddp_service_request_rec.inv_item_revision := p15_a121;
    ddp_service_request_rec.inv_component_id := p15_a122;
    ddp_service_request_rec.inv_component_version := p15_a123;
    ddp_service_request_rec.inv_subcomponent_id := p15_a124;
    ddp_service_request_rec.inv_subcomponent_version := p15_a125;
    ddp_service_request_rec.tier := p15_a126;
    ddp_service_request_rec.tier_version := p15_a127;
    ddp_service_request_rec.operating_system := p15_a128;
    ddp_service_request_rec.operating_system_version := p15_a129;
    ddp_service_request_rec.database := p15_a130;
    ddp_service_request_rec.cust_pref_lang_id := p15_a131;
    ddp_service_request_rec.category_id := p15_a132;
    ddp_service_request_rec.group_type := p15_a133;
    ddp_service_request_rec.group_territory_id := p15_a134;
    ddp_service_request_rec.inv_platform_org_id := p15_a135;
    ddp_service_request_rec.component_version := p15_a136;
    ddp_service_request_rec.subcomponent_version := p15_a137;
    ddp_service_request_rec.product_revision := p15_a138;
    ddp_service_request_rec.comm_pref_code := p15_a139;
    ddp_service_request_rec.cust_pref_lang_code := p15_a140;
    ddp_service_request_rec.last_update_channel := p15_a141;
    ddp_service_request_rec.category_set_id := p15_a142;
    ddp_service_request_rec.external_reference := p15_a143;
    ddp_service_request_rec.system_id := p15_a144;
    ddp_service_request_rec.error_code := p15_a145;
    ddp_service_request_rec.incident_occurred_date := rosetta_g_miss_date_in_map(p15_a146);
    ddp_service_request_rec.incident_resolved_date := rosetta_g_miss_date_in_map(p15_a147);
    ddp_service_request_rec.inc_responded_by_date := rosetta_g_miss_date_in_map(p15_a148);
    ddp_service_request_rec.resolution_summary := p15_a149;
    ddp_service_request_rec.incident_location_id := p15_a150;
    ddp_service_request_rec.incident_address := p15_a151;
    ddp_service_request_rec.incident_city := p15_a152;
    ddp_service_request_rec.incident_state := p15_a153;
    ddp_service_request_rec.incident_country := p15_a154;
    ddp_service_request_rec.incident_province := p15_a155;
    ddp_service_request_rec.incident_postal_code := p15_a156;
    ddp_service_request_rec.incident_county := p15_a157;
    ddp_service_request_rec.site_number := p15_a158;
    ddp_service_request_rec.site_name := p15_a159;
    ddp_service_request_rec.addressee := p15_a160;
    ddp_service_request_rec.owner := p15_a161;
    ddp_service_request_rec.group_owner := p15_a162;
    ddp_service_request_rec.cc_number := p15_a163;
    ddp_service_request_rec.cc_expiration_date := rosetta_g_miss_date_in_map(p15_a164);
    ddp_service_request_rec.cc_type_code := p15_a165;
    ddp_service_request_rec.cc_first_name := p15_a166;
    ddp_service_request_rec.cc_last_name := p15_a167;
    ddp_service_request_rec.cc_middle_name := p15_a168;
    ddp_service_request_rec.cc_id := p15_a169;
    ddp_service_request_rec.bill_to_account_id := p15_a170;
    ddp_service_request_rec.ship_to_account_id := p15_a171;
    ddp_service_request_rec.customer_phone_id := p15_a172;
    ddp_service_request_rec.customer_email_id := p15_a173;
    ddp_service_request_rec.creation_program_code := p15_a174;
    ddp_service_request_rec.last_update_program_code := p15_a175;
    ddp_service_request_rec.bill_to_party_id := p15_a176;
    ddp_service_request_rec.ship_to_party_id := p15_a177;
    ddp_service_request_rec.program_id := p15_a178;
    ddp_service_request_rec.program_application_id := p15_a179;
    ddp_service_request_rec.conc_request_id := p15_a180;
    ddp_service_request_rec.program_login_id := p15_a181;
    ddp_service_request_rec.bill_to_site_id := p15_a182;
    ddp_service_request_rec.ship_to_site_id := p15_a183;
    ddp_service_request_rec.incident_point_of_interest := p15_a184;
    ddp_service_request_rec.incident_cross_street := p15_a185;
    ddp_service_request_rec.incident_direction_qualifier := p15_a186;
    ddp_service_request_rec.incident_distance_qualifier := p15_a187;
    ddp_service_request_rec.incident_distance_qual_uom := p15_a188;
    ddp_service_request_rec.incident_address2 := p15_a189;
    ddp_service_request_rec.incident_address3 := p15_a190;
    ddp_service_request_rec.incident_address4 := p15_a191;
    ddp_service_request_rec.incident_address_style := p15_a192;
    ddp_service_request_rec.incident_addr_lines_phonetic := p15_a193;
    ddp_service_request_rec.incident_po_box_number := p15_a194;
    ddp_service_request_rec.incident_house_number := p15_a195;
    ddp_service_request_rec.incident_street_suffix := p15_a196;
    ddp_service_request_rec.incident_street := p15_a197;
    ddp_service_request_rec.incident_street_number := p15_a198;
    ddp_service_request_rec.incident_floor := p15_a199;
    ddp_service_request_rec.incident_suite := p15_a200;
    ddp_service_request_rec.incident_postal_plus4_code := p15_a201;
    ddp_service_request_rec.incident_position := p15_a202;
    ddp_service_request_rec.incident_location_directions := p15_a203;
    ddp_service_request_rec.incident_location_description := p15_a204;
    ddp_service_request_rec.install_site_id := p15_a205;
    ddp_service_request_rec.item_serial_number := p15_a206;
    ddp_service_request_rec.owning_department_id := p15_a207;
    ddp_service_request_rec.incident_location_type := p15_a208;
    ddp_service_request_rec.coverage_type := p15_a209;
    ddp_service_request_rec.maint_organization_id := p15_a210;
    ddp_service_request_rec.creation_date := rosetta_g_miss_date_in_map(p15_a211);
    ddp_service_request_rec.created_by := p15_a212;
    ddp_service_request_rec.instrument_payment_use_id := p15_a213;

    cs_servicerequest_pub_w.rosetta_table_copy_in_p1(ddp_notes, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p3(ddp_contacts, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      );








    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.update_servicerequest(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      p_request_number,
      p_audit_comments,
      p_object_version_number,
      p_resp_appl_id,
      p_resp_id,
      p_last_updated_by,
      p_last_update_login,
      ddp_last_update_date,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_called_by_workflow,
      p_workflow_process_id,
      p_auto_assign,
      p_validate_sr_closure,
      p_auto_close_child_entities,
      p_default_contract_sla_ind,
      ddx_sr_update_out_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























    p24_a0 := ddx_sr_update_out_rec.interaction_id;
    p24_a1 := ddx_sr_update_out_rec.workflow_process_id;
    p24_a2 := ddx_sr_update_out_rec.individual_owner;
    p24_a3 := ddx_sr_update_out_rec.group_owner;
    p24_a4 := ddx_sr_update_out_rec.individual_type;
    p24_a5 := ddx_sr_update_out_rec.resolved_on_date;
    p24_a6 := ddx_sr_update_out_rec.responded_on_date;
    p24_a7 := ddx_sr_update_out_rec.status_id;
    p24_a8 := ddx_sr_update_out_rec.close_date;
    p24_a9 := ddx_sr_update_out_rec.incident_location_id;
  end;

  procedure update_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  VARCHAR2
    , p15_a79  VARCHAR2
    , p15_a80  VARCHAR2
    , p15_a81  VARCHAR2
    , p15_a82  VARCHAR2
    , p15_a83  VARCHAR2
    , p15_a84  VARCHAR2
    , p15_a85  VARCHAR2
    , p15_a86  VARCHAR2
    , p15_a87  VARCHAR2
    , p15_a88  VARCHAR2
    , p15_a89  VARCHAR2
    , p15_a90  VARCHAR2
    , p15_a91  VARCHAR2
    , p15_a92  VARCHAR2
    , p15_a93  VARCHAR2
    , p15_a94  NUMBER
    , p15_a95  NUMBER
    , p15_a96  NUMBER
    , p15_a97  NUMBER
    , p15_a98  VARCHAR2
    , p15_a99  DATE
    , p15_a100  VARCHAR2
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  NUMBER
    , p15_a108  VARCHAR2
    , p15_a109  NUMBER
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  DATE
    , p15_a114  NUMBER
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  NUMBER
    , p15_a118  NUMBER
    , p15_a119  VARCHAR2
    , p15_a120  NUMBER
    , p15_a121  VARCHAR2
    , p15_a122  NUMBER
    , p15_a123  VARCHAR2
    , p15_a124  NUMBER
    , p15_a125  VARCHAR2
    , p15_a126  VARCHAR2
    , p15_a127  VARCHAR2
    , p15_a128  VARCHAR2
    , p15_a129  VARCHAR2
    , p15_a130  VARCHAR2
    , p15_a131  NUMBER
    , p15_a132  NUMBER
    , p15_a133  VARCHAR2
    , p15_a134  NUMBER
    , p15_a135  NUMBER
    , p15_a136  VARCHAR2
    , p15_a137  VARCHAR2
    , p15_a138  VARCHAR2
    , p15_a139  VARCHAR2
    , p15_a140  VARCHAR2
    , p15_a141  VARCHAR2
    , p15_a142  NUMBER
    , p15_a143  VARCHAR2
    , p15_a144  NUMBER
    , p15_a145  VARCHAR2
    , p15_a146  DATE
    , p15_a147  DATE
    , p15_a148  DATE
    , p15_a149  VARCHAR2
    , p15_a150  NUMBER
    , p15_a151  VARCHAR2
    , p15_a152  VARCHAR2
    , p15_a153  VARCHAR2
    , p15_a154  VARCHAR2
    , p15_a155  VARCHAR2
    , p15_a156  VARCHAR2
    , p15_a157  VARCHAR2
    , p15_a158  VARCHAR2
    , p15_a159  VARCHAR2
    , p15_a160  VARCHAR2
    , p15_a161  VARCHAR2
    , p15_a162  VARCHAR2
    , p15_a163  VARCHAR2
    , p15_a164  DATE
    , p15_a165  VARCHAR
    , p15_a166  VARCHAR
    , p15_a167  VARCHAR
    , p15_a168  VARCHAR
    , p15_a169  NUMBER
    , p15_a170  NUMBER
    , p15_a171  NUMBER
    , p15_a172  NUMBER
    , p15_a173  NUMBER
    , p15_a174  VARCHAR2
    , p15_a175  VARCHAR2
    , p15_a176  NUMBER
    , p15_a177  NUMBER
    , p15_a178  NUMBER
    , p15_a179  NUMBER
    , p15_a180  NUMBER
    , p15_a181  NUMBER
    , p15_a182  NUMBER
    , p15_a183  NUMBER
    , p15_a184  VARCHAR2
    , p15_a185  VARCHAR2
    , p15_a186  VARCHAR2
    , p15_a187  VARCHAR2
    , p15_a188  VARCHAR2
    , p15_a189  VARCHAR2
    , p15_a190  VARCHAR2
    , p15_a191  VARCHAR2
    , p15_a192  VARCHAR2
    , p15_a193  VARCHAR2
    , p15_a194  VARCHAR2
    , p15_a195  VARCHAR2
    , p15_a196  VARCHAR2
    , p15_a197  VARCHAR2
    , p15_a198  VARCHAR2
    , p15_a199  VARCHAR2
    , p15_a200  VARCHAR2
    , p15_a201  VARCHAR2
    , p15_a202  VARCHAR2
    , p15_a203  VARCHAR2
    , p15_a204  VARCHAR2
    , p15_a205  NUMBER
    , p15_a206  VARCHAR2
    , p15_a207  NUMBER
    , p15_a208  VARCHAR2
    , p15_a209  VARCHAR2
    , p15_a210  NUMBER
    , p15_a211  DATE
    , p15_a212  NUMBER
    , p15_a213  NUMBER
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p17_a6 JTF_VARCHAR2_TABLE_100
    , p17_a7 JTF_DATE_TABLE
    , p17_a8 JTF_DATE_TABLE
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_default_contract_sla_ind  VARCHAR2
    , x_workflow_process_id out nocopy  NUMBER
    , x_interaction_id out nocopy  NUMBER
  )

  as
    ddp_last_update_date date;
    ddp_service_request_rec cs_servicerequest_pub.service_request_rec_type;
    ddp_notes cs_servicerequest_pub.notes_table;
    ddp_contacts cs_servicerequest_pub.contacts_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);

    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p15_a0);
    ddp_service_request_rec.type_id := p15_a1;
    ddp_service_request_rec.type_name := p15_a2;
    ddp_service_request_rec.status_id := p15_a3;
    ddp_service_request_rec.status_name := p15_a4;
    ddp_service_request_rec.severity_id := p15_a5;
    ddp_service_request_rec.severity_name := p15_a6;
    ddp_service_request_rec.urgency_id := p15_a7;
    ddp_service_request_rec.urgency_name := p15_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p15_a9);
    ddp_service_request_rec.owner_id := p15_a10;
    ddp_service_request_rec.owner_group_id := p15_a11;
    ddp_service_request_rec.publish_flag := p15_a12;
    ddp_service_request_rec.summary := p15_a13;
    ddp_service_request_rec.caller_type := p15_a14;
    ddp_service_request_rec.customer_id := p15_a15;
    ddp_service_request_rec.customer_number := p15_a16;
    ddp_service_request_rec.employee_id := p15_a17;
    ddp_service_request_rec.employee_number := p15_a18;
    ddp_service_request_rec.verify_cp_flag := p15_a19;
    ddp_service_request_rec.customer_product_id := p15_a20;
    ddp_service_request_rec.platform_id := p15_a21;
    ddp_service_request_rec.platform_version := p15_a22;
    ddp_service_request_rec.db_version := p15_a23;
    ddp_service_request_rec.platform_version_id := p15_a24;
    ddp_service_request_rec.cp_component_id := p15_a25;
    ddp_service_request_rec.cp_component_version_id := p15_a26;
    ddp_service_request_rec.cp_subcomponent_id := p15_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p15_a28;
    ddp_service_request_rec.language_id := p15_a29;
    ddp_service_request_rec.language := p15_a30;
    ddp_service_request_rec.cp_ref_number := p15_a31;
    ddp_service_request_rec.inventory_item_id := p15_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p15_a33;
    ddp_service_request_rec.inventory_item_segment1 := p15_a34;
    ddp_service_request_rec.inventory_item_segment2 := p15_a35;
    ddp_service_request_rec.inventory_item_segment3 := p15_a36;
    ddp_service_request_rec.inventory_item_segment4 := p15_a37;
    ddp_service_request_rec.inventory_item_segment5 := p15_a38;
    ddp_service_request_rec.inventory_item_segment6 := p15_a39;
    ddp_service_request_rec.inventory_item_segment7 := p15_a40;
    ddp_service_request_rec.inventory_item_segment8 := p15_a41;
    ddp_service_request_rec.inventory_item_segment9 := p15_a42;
    ddp_service_request_rec.inventory_item_segment10 := p15_a43;
    ddp_service_request_rec.inventory_item_segment11 := p15_a44;
    ddp_service_request_rec.inventory_item_segment12 := p15_a45;
    ddp_service_request_rec.inventory_item_segment13 := p15_a46;
    ddp_service_request_rec.inventory_item_segment14 := p15_a47;
    ddp_service_request_rec.inventory_item_segment15 := p15_a48;
    ddp_service_request_rec.inventory_item_segment16 := p15_a49;
    ddp_service_request_rec.inventory_item_segment17 := p15_a50;
    ddp_service_request_rec.inventory_item_segment18 := p15_a51;
    ddp_service_request_rec.inventory_item_segment19 := p15_a52;
    ddp_service_request_rec.inventory_item_segment20 := p15_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p15_a54;
    ddp_service_request_rec.inventory_org_id := p15_a55;
    ddp_service_request_rec.current_serial_number := p15_a56;
    ddp_service_request_rec.original_order_number := p15_a57;
    ddp_service_request_rec.purchase_order_num := p15_a58;
    ddp_service_request_rec.problem_code := p15_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p15_a60);
    ddp_service_request_rec.install_site_use_id := p15_a61;
    ddp_service_request_rec.request_attribute_1 := p15_a62;
    ddp_service_request_rec.request_attribute_2 := p15_a63;
    ddp_service_request_rec.request_attribute_3 := p15_a64;
    ddp_service_request_rec.request_attribute_4 := p15_a65;
    ddp_service_request_rec.request_attribute_5 := p15_a66;
    ddp_service_request_rec.request_attribute_6 := p15_a67;
    ddp_service_request_rec.request_attribute_7 := p15_a68;
    ddp_service_request_rec.request_attribute_8 := p15_a69;
    ddp_service_request_rec.request_attribute_9 := p15_a70;
    ddp_service_request_rec.request_attribute_10 := p15_a71;
    ddp_service_request_rec.request_attribute_11 := p15_a72;
    ddp_service_request_rec.request_attribute_12 := p15_a73;
    ddp_service_request_rec.request_attribute_13 := p15_a74;
    ddp_service_request_rec.request_attribute_14 := p15_a75;
    ddp_service_request_rec.request_attribute_15 := p15_a76;
    ddp_service_request_rec.request_context := p15_a77;
    ddp_service_request_rec.external_attribute_1 := p15_a78;
    ddp_service_request_rec.external_attribute_2 := p15_a79;
    ddp_service_request_rec.external_attribute_3 := p15_a80;
    ddp_service_request_rec.external_attribute_4 := p15_a81;
    ddp_service_request_rec.external_attribute_5 := p15_a82;
    ddp_service_request_rec.external_attribute_6 := p15_a83;
    ddp_service_request_rec.external_attribute_7 := p15_a84;
    ddp_service_request_rec.external_attribute_8 := p15_a85;
    ddp_service_request_rec.external_attribute_9 := p15_a86;
    ddp_service_request_rec.external_attribute_10 := p15_a87;
    ddp_service_request_rec.external_attribute_11 := p15_a88;
    ddp_service_request_rec.external_attribute_12 := p15_a89;
    ddp_service_request_rec.external_attribute_13 := p15_a90;
    ddp_service_request_rec.external_attribute_14 := p15_a91;
    ddp_service_request_rec.external_attribute_15 := p15_a92;
    ddp_service_request_rec.external_context := p15_a93;
    ddp_service_request_rec.bill_to_site_use_id := p15_a94;
    ddp_service_request_rec.bill_to_contact_id := p15_a95;
    ddp_service_request_rec.ship_to_site_use_id := p15_a96;
    ddp_service_request_rec.ship_to_contact_id := p15_a97;
    ddp_service_request_rec.resolution_code := p15_a98;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p15_a99);
    ddp_service_request_rec.public_comment_flag := p15_a100;
    ddp_service_request_rec.parent_interaction_id := p15_a101;
    ddp_service_request_rec.contract_service_id := p15_a102;
    ddp_service_request_rec.contract_service_number := p15_a103;
    ddp_service_request_rec.contract_id := p15_a104;
    ddp_service_request_rec.project_number := p15_a105;
    ddp_service_request_rec.qa_collection_plan_id := p15_a106;
    ddp_service_request_rec.account_id := p15_a107;
    ddp_service_request_rec.resource_type := p15_a108;
    ddp_service_request_rec.resource_subtype_id := p15_a109;
    ddp_service_request_rec.cust_po_number := p15_a110;
    ddp_service_request_rec.cust_ticket_number := p15_a111;
    ddp_service_request_rec.sr_creation_channel := p15_a112;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p15_a113);
    ddp_service_request_rec.time_zone_id := p15_a114;
    ddp_service_request_rec.time_difference := p15_a115;
    ddp_service_request_rec.site_id := p15_a116;
    ddp_service_request_rec.customer_site_id := p15_a117;
    ddp_service_request_rec.territory_id := p15_a118;
    ddp_service_request_rec.initialize_flag := p15_a119;
    ddp_service_request_rec.cp_revision_id := p15_a120;
    ddp_service_request_rec.inv_item_revision := p15_a121;
    ddp_service_request_rec.inv_component_id := p15_a122;
    ddp_service_request_rec.inv_component_version := p15_a123;
    ddp_service_request_rec.inv_subcomponent_id := p15_a124;
    ddp_service_request_rec.inv_subcomponent_version := p15_a125;
    ddp_service_request_rec.tier := p15_a126;
    ddp_service_request_rec.tier_version := p15_a127;
    ddp_service_request_rec.operating_system := p15_a128;
    ddp_service_request_rec.operating_system_version := p15_a129;
    ddp_service_request_rec.database := p15_a130;
    ddp_service_request_rec.cust_pref_lang_id := p15_a131;
    ddp_service_request_rec.category_id := p15_a132;
    ddp_service_request_rec.group_type := p15_a133;
    ddp_service_request_rec.group_territory_id := p15_a134;
    ddp_service_request_rec.inv_platform_org_id := p15_a135;
    ddp_service_request_rec.component_version := p15_a136;
    ddp_service_request_rec.subcomponent_version := p15_a137;
    ddp_service_request_rec.product_revision := p15_a138;
    ddp_service_request_rec.comm_pref_code := p15_a139;
    ddp_service_request_rec.cust_pref_lang_code := p15_a140;
    ddp_service_request_rec.last_update_channel := p15_a141;
    ddp_service_request_rec.category_set_id := p15_a142;
    ddp_service_request_rec.external_reference := p15_a143;
    ddp_service_request_rec.system_id := p15_a144;
    ddp_service_request_rec.error_code := p15_a145;
    ddp_service_request_rec.incident_occurred_date := rosetta_g_miss_date_in_map(p15_a146);
    ddp_service_request_rec.incident_resolved_date := rosetta_g_miss_date_in_map(p15_a147);
    ddp_service_request_rec.inc_responded_by_date := rosetta_g_miss_date_in_map(p15_a148);
    ddp_service_request_rec.resolution_summary := p15_a149;
    ddp_service_request_rec.incident_location_id := p15_a150;
    ddp_service_request_rec.incident_address := p15_a151;
    ddp_service_request_rec.incident_city := p15_a152;
    ddp_service_request_rec.incident_state := p15_a153;
    ddp_service_request_rec.incident_country := p15_a154;
    ddp_service_request_rec.incident_province := p15_a155;
    ddp_service_request_rec.incident_postal_code := p15_a156;
    ddp_service_request_rec.incident_county := p15_a157;
    ddp_service_request_rec.site_number := p15_a158;
    ddp_service_request_rec.site_name := p15_a159;
    ddp_service_request_rec.addressee := p15_a160;
    ddp_service_request_rec.owner := p15_a161;
    ddp_service_request_rec.group_owner := p15_a162;
    ddp_service_request_rec.cc_number := p15_a163;
    ddp_service_request_rec.cc_expiration_date := rosetta_g_miss_date_in_map(p15_a164);
    ddp_service_request_rec.cc_type_code := p15_a165;
    ddp_service_request_rec.cc_first_name := p15_a166;
    ddp_service_request_rec.cc_last_name := p15_a167;
    ddp_service_request_rec.cc_middle_name := p15_a168;
    ddp_service_request_rec.cc_id := p15_a169;
    ddp_service_request_rec.bill_to_account_id := p15_a170;
    ddp_service_request_rec.ship_to_account_id := p15_a171;
    ddp_service_request_rec.customer_phone_id := p15_a172;
    ddp_service_request_rec.customer_email_id := p15_a173;
    ddp_service_request_rec.creation_program_code := p15_a174;
    ddp_service_request_rec.last_update_program_code := p15_a175;
    ddp_service_request_rec.bill_to_party_id := p15_a176;
    ddp_service_request_rec.ship_to_party_id := p15_a177;
    ddp_service_request_rec.program_id := p15_a178;
    ddp_service_request_rec.program_application_id := p15_a179;
    ddp_service_request_rec.conc_request_id := p15_a180;
    ddp_service_request_rec.program_login_id := p15_a181;
    ddp_service_request_rec.bill_to_site_id := p15_a182;
    ddp_service_request_rec.ship_to_site_id := p15_a183;
    ddp_service_request_rec.incident_point_of_interest := p15_a184;
    ddp_service_request_rec.incident_cross_street := p15_a185;
    ddp_service_request_rec.incident_direction_qualifier := p15_a186;
    ddp_service_request_rec.incident_distance_qualifier := p15_a187;
    ddp_service_request_rec.incident_distance_qual_uom := p15_a188;
    ddp_service_request_rec.incident_address2 := p15_a189;
    ddp_service_request_rec.incident_address3 := p15_a190;
    ddp_service_request_rec.incident_address4 := p15_a191;
    ddp_service_request_rec.incident_address_style := p15_a192;
    ddp_service_request_rec.incident_addr_lines_phonetic := p15_a193;
    ddp_service_request_rec.incident_po_box_number := p15_a194;
    ddp_service_request_rec.incident_house_number := p15_a195;
    ddp_service_request_rec.incident_street_suffix := p15_a196;
    ddp_service_request_rec.incident_street := p15_a197;
    ddp_service_request_rec.incident_street_number := p15_a198;
    ddp_service_request_rec.incident_floor := p15_a199;
    ddp_service_request_rec.incident_suite := p15_a200;
    ddp_service_request_rec.incident_postal_plus4_code := p15_a201;
    ddp_service_request_rec.incident_position := p15_a202;
    ddp_service_request_rec.incident_location_directions := p15_a203;
    ddp_service_request_rec.incident_location_description := p15_a204;
    ddp_service_request_rec.install_site_id := p15_a205;
    ddp_service_request_rec.item_serial_number := p15_a206;
    ddp_service_request_rec.owning_department_id := p15_a207;
    ddp_service_request_rec.incident_location_type := p15_a208;
    ddp_service_request_rec.coverage_type := p15_a209;
    ddp_service_request_rec.maint_organization_id := p15_a210;
    ddp_service_request_rec.creation_date := rosetta_g_miss_date_in_map(p15_a211);
    ddp_service_request_rec.created_by := p15_a212;
    ddp_service_request_rec.instrument_payment_use_id := p15_a213;

    cs_servicerequest_pub_w.rosetta_table_copy_in_p1(ddp_notes, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p3(ddp_contacts, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      );






    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.update_servicerequest(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      p_request_number,
      p_audit_comments,
      p_object_version_number,
      p_resp_appl_id,
      p_resp_id,
      p_last_updated_by,
      p_last_update_login,
      ddp_last_update_date,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_called_by_workflow,
      p_workflow_process_id,
      p_default_contract_sla_ind,
      x_workflow_process_id,
      x_interaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















  end;

  procedure update_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_object_version_number  NUMBER
    , p_status_id  NUMBER
    , p_status  VARCHAR2
    , p_closed_date  date
    , p_audit_comments  VARCHAR2
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_comments  VARCHAR2
    , p_public_comment_flag  VARCHAR2
    , p_validate_sr_closure  VARCHAR2
    , p_auto_close_child_entities  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
  )

  as
    ddp_closed_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    ddp_closed_date := rosetta_g_miss_date_in_map(p_closed_date);









    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.update_status(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_request_id,
      p_request_number,
      p_object_version_number,
      p_status_id,
      p_status,
      ddp_closed_date,
      p_audit_comments,
      p_called_by_workflow,
      p_workflow_process_id,
      p_comments,
      p_public_comment_flag,
      p_validate_sr_closure,
      p_auto_close_child_entities,
      x_interaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























  end;

  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_default_contract_sla_ind  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
  )

  as
    ddp_service_request_rec cs_servicerequest_pub.service_request_rec_type;
    ddp_notes cs_servicerequest_pub.notes_table;
    ddp_contacts cs_servicerequest_pub.contacts_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p13_a0);
    ddp_service_request_rec.type_id := p13_a1;
    ddp_service_request_rec.type_name := p13_a2;
    ddp_service_request_rec.status_id := p13_a3;
    ddp_service_request_rec.status_name := p13_a4;
    ddp_service_request_rec.severity_id := p13_a5;
    ddp_service_request_rec.severity_name := p13_a6;
    ddp_service_request_rec.urgency_id := p13_a7;
    ddp_service_request_rec.urgency_name := p13_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p13_a9);
    ddp_service_request_rec.owner_id := p13_a10;
    ddp_service_request_rec.owner_group_id := p13_a11;
    ddp_service_request_rec.publish_flag := p13_a12;
    ddp_service_request_rec.summary := p13_a13;
    ddp_service_request_rec.caller_type := p13_a14;
    ddp_service_request_rec.customer_id := p13_a15;
    ddp_service_request_rec.customer_number := p13_a16;
    ddp_service_request_rec.employee_id := p13_a17;
    ddp_service_request_rec.employee_number := p13_a18;
    ddp_service_request_rec.verify_cp_flag := p13_a19;
    ddp_service_request_rec.customer_product_id := p13_a20;
    ddp_service_request_rec.platform_id := p13_a21;
    ddp_service_request_rec.platform_version := p13_a22;
    ddp_service_request_rec.db_version := p13_a23;
    ddp_service_request_rec.platform_version_id := p13_a24;
    ddp_service_request_rec.cp_component_id := p13_a25;
    ddp_service_request_rec.cp_component_version_id := p13_a26;
    ddp_service_request_rec.cp_subcomponent_id := p13_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p13_a28;
    ddp_service_request_rec.language_id := p13_a29;
    ddp_service_request_rec.language := p13_a30;
    ddp_service_request_rec.cp_ref_number := p13_a31;
    ddp_service_request_rec.inventory_item_id := p13_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p13_a33;
    ddp_service_request_rec.inventory_item_segment1 := p13_a34;
    ddp_service_request_rec.inventory_item_segment2 := p13_a35;
    ddp_service_request_rec.inventory_item_segment3 := p13_a36;
    ddp_service_request_rec.inventory_item_segment4 := p13_a37;
    ddp_service_request_rec.inventory_item_segment5 := p13_a38;
    ddp_service_request_rec.inventory_item_segment6 := p13_a39;
    ddp_service_request_rec.inventory_item_segment7 := p13_a40;
    ddp_service_request_rec.inventory_item_segment8 := p13_a41;
    ddp_service_request_rec.inventory_item_segment9 := p13_a42;
    ddp_service_request_rec.inventory_item_segment10 := p13_a43;
    ddp_service_request_rec.inventory_item_segment11 := p13_a44;
    ddp_service_request_rec.inventory_item_segment12 := p13_a45;
    ddp_service_request_rec.inventory_item_segment13 := p13_a46;
    ddp_service_request_rec.inventory_item_segment14 := p13_a47;
    ddp_service_request_rec.inventory_item_segment15 := p13_a48;
    ddp_service_request_rec.inventory_item_segment16 := p13_a49;
    ddp_service_request_rec.inventory_item_segment17 := p13_a50;
    ddp_service_request_rec.inventory_item_segment18 := p13_a51;
    ddp_service_request_rec.inventory_item_segment19 := p13_a52;
    ddp_service_request_rec.inventory_item_segment20 := p13_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p13_a54;
    ddp_service_request_rec.inventory_org_id := p13_a55;
    ddp_service_request_rec.current_serial_number := p13_a56;
    ddp_service_request_rec.original_order_number := p13_a57;
    ddp_service_request_rec.purchase_order_num := p13_a58;
    ddp_service_request_rec.problem_code := p13_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p13_a60);
    ddp_service_request_rec.install_site_use_id := p13_a61;
    ddp_service_request_rec.request_attribute_1 := p13_a62;
    ddp_service_request_rec.request_attribute_2 := p13_a63;
    ddp_service_request_rec.request_attribute_3 := p13_a64;
    ddp_service_request_rec.request_attribute_4 := p13_a65;
    ddp_service_request_rec.request_attribute_5 := p13_a66;
    ddp_service_request_rec.request_attribute_6 := p13_a67;
    ddp_service_request_rec.request_attribute_7 := p13_a68;
    ddp_service_request_rec.request_attribute_8 := p13_a69;
    ddp_service_request_rec.request_attribute_9 := p13_a70;
    ddp_service_request_rec.request_attribute_10 := p13_a71;
    ddp_service_request_rec.request_attribute_11 := p13_a72;
    ddp_service_request_rec.request_attribute_12 := p13_a73;
    ddp_service_request_rec.request_attribute_13 := p13_a74;
    ddp_service_request_rec.request_attribute_14 := p13_a75;
    ddp_service_request_rec.request_attribute_15 := p13_a76;
    ddp_service_request_rec.request_context := p13_a77;
    ddp_service_request_rec.external_attribute_1 := p13_a78;
    ddp_service_request_rec.external_attribute_2 := p13_a79;
    ddp_service_request_rec.external_attribute_3 := p13_a80;
    ddp_service_request_rec.external_attribute_4 := p13_a81;
    ddp_service_request_rec.external_attribute_5 := p13_a82;
    ddp_service_request_rec.external_attribute_6 := p13_a83;
    ddp_service_request_rec.external_attribute_7 := p13_a84;
    ddp_service_request_rec.external_attribute_8 := p13_a85;
    ddp_service_request_rec.external_attribute_9 := p13_a86;
    ddp_service_request_rec.external_attribute_10 := p13_a87;
    ddp_service_request_rec.external_attribute_11 := p13_a88;
    ddp_service_request_rec.external_attribute_12 := p13_a89;
    ddp_service_request_rec.external_attribute_13 := p13_a90;
    ddp_service_request_rec.external_attribute_14 := p13_a91;
    ddp_service_request_rec.external_attribute_15 := p13_a92;
    ddp_service_request_rec.external_context := p13_a93;
    ddp_service_request_rec.bill_to_site_use_id := p13_a94;
    ddp_service_request_rec.bill_to_contact_id := p13_a95;
    ddp_service_request_rec.ship_to_site_use_id := p13_a96;
    ddp_service_request_rec.ship_to_contact_id := p13_a97;
    ddp_service_request_rec.resolution_code := p13_a98;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p13_a99);
    ddp_service_request_rec.public_comment_flag := p13_a100;
    ddp_service_request_rec.parent_interaction_id := p13_a101;
    ddp_service_request_rec.contract_service_id := p13_a102;
    ddp_service_request_rec.contract_service_number := p13_a103;
    ddp_service_request_rec.contract_id := p13_a104;
    ddp_service_request_rec.project_number := p13_a105;
    ddp_service_request_rec.qa_collection_plan_id := p13_a106;
    ddp_service_request_rec.account_id := p13_a107;
    ddp_service_request_rec.resource_type := p13_a108;
    ddp_service_request_rec.resource_subtype_id := p13_a109;
    ddp_service_request_rec.cust_po_number := p13_a110;
    ddp_service_request_rec.cust_ticket_number := p13_a111;
    ddp_service_request_rec.sr_creation_channel := p13_a112;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p13_a113);
    ddp_service_request_rec.time_zone_id := p13_a114;
    ddp_service_request_rec.time_difference := p13_a115;
    ddp_service_request_rec.site_id := p13_a116;
    ddp_service_request_rec.customer_site_id := p13_a117;
    ddp_service_request_rec.territory_id := p13_a118;
    ddp_service_request_rec.initialize_flag := p13_a119;
    ddp_service_request_rec.cp_revision_id := p13_a120;
    ddp_service_request_rec.inv_item_revision := p13_a121;
    ddp_service_request_rec.inv_component_id := p13_a122;
    ddp_service_request_rec.inv_component_version := p13_a123;
    ddp_service_request_rec.inv_subcomponent_id := p13_a124;
    ddp_service_request_rec.inv_subcomponent_version := p13_a125;
    ddp_service_request_rec.tier := p13_a126;
    ddp_service_request_rec.tier_version := p13_a127;
    ddp_service_request_rec.operating_system := p13_a128;
    ddp_service_request_rec.operating_system_version := p13_a129;
    ddp_service_request_rec.database := p13_a130;
    ddp_service_request_rec.cust_pref_lang_id := p13_a131;
    ddp_service_request_rec.category_id := p13_a132;
    ddp_service_request_rec.group_type := p13_a133;
    ddp_service_request_rec.group_territory_id := p13_a134;
    ddp_service_request_rec.inv_platform_org_id := p13_a135;
    ddp_service_request_rec.component_version := p13_a136;
    ddp_service_request_rec.subcomponent_version := p13_a137;
    ddp_service_request_rec.product_revision := p13_a138;
    ddp_service_request_rec.comm_pref_code := p13_a139;
    ddp_service_request_rec.cust_pref_lang_code := p13_a140;
    ddp_service_request_rec.last_update_channel := p13_a141;
    ddp_service_request_rec.category_set_id := p13_a142;
    ddp_service_request_rec.external_reference := p13_a143;
    ddp_service_request_rec.system_id := p13_a144;
    ddp_service_request_rec.error_code := p13_a145;
    ddp_service_request_rec.incident_occurred_date := rosetta_g_miss_date_in_map(p13_a146);
    ddp_service_request_rec.incident_resolved_date := rosetta_g_miss_date_in_map(p13_a147);
    ddp_service_request_rec.inc_responded_by_date := rosetta_g_miss_date_in_map(p13_a148);
    ddp_service_request_rec.resolution_summary := p13_a149;
    ddp_service_request_rec.incident_location_id := p13_a150;
    ddp_service_request_rec.incident_address := p13_a151;
    ddp_service_request_rec.incident_city := p13_a152;
    ddp_service_request_rec.incident_state := p13_a153;
    ddp_service_request_rec.incident_country := p13_a154;
    ddp_service_request_rec.incident_province := p13_a155;
    ddp_service_request_rec.incident_postal_code := p13_a156;
    ddp_service_request_rec.incident_county := p13_a157;
    ddp_service_request_rec.site_number := p13_a158;
    ddp_service_request_rec.site_name := p13_a159;
    ddp_service_request_rec.addressee := p13_a160;
    ddp_service_request_rec.owner := p13_a161;
    ddp_service_request_rec.group_owner := p13_a162;
    ddp_service_request_rec.cc_number := p13_a163;
    ddp_service_request_rec.cc_expiration_date := rosetta_g_miss_date_in_map(p13_a164);
    ddp_service_request_rec.cc_type_code := p13_a165;
    ddp_service_request_rec.cc_first_name := p13_a166;
    ddp_service_request_rec.cc_last_name := p13_a167;
    ddp_service_request_rec.cc_middle_name := p13_a168;
    ddp_service_request_rec.cc_id := p13_a169;
    ddp_service_request_rec.bill_to_account_id := p13_a170;
    ddp_service_request_rec.ship_to_account_id := p13_a171;
    ddp_service_request_rec.customer_phone_id := p13_a172;
    ddp_service_request_rec.customer_email_id := p13_a173;
    ddp_service_request_rec.creation_program_code := p13_a174;
    ddp_service_request_rec.last_update_program_code := p13_a175;
    ddp_service_request_rec.bill_to_party_id := p13_a176;
    ddp_service_request_rec.ship_to_party_id := p13_a177;
    ddp_service_request_rec.program_id := p13_a178;
    ddp_service_request_rec.program_application_id := p13_a179;
    ddp_service_request_rec.conc_request_id := p13_a180;
    ddp_service_request_rec.program_login_id := p13_a181;
    ddp_service_request_rec.bill_to_site_id := p13_a182;
    ddp_service_request_rec.ship_to_site_id := p13_a183;
    ddp_service_request_rec.incident_point_of_interest := p13_a184;
    ddp_service_request_rec.incident_cross_street := p13_a185;
    ddp_service_request_rec.incident_direction_qualifier := p13_a186;
    ddp_service_request_rec.incident_distance_qualifier := p13_a187;
    ddp_service_request_rec.incident_distance_qual_uom := p13_a188;
    ddp_service_request_rec.incident_address2 := p13_a189;
    ddp_service_request_rec.incident_address3 := p13_a190;
    ddp_service_request_rec.incident_address4 := p13_a191;
    ddp_service_request_rec.incident_address_style := p13_a192;
    ddp_service_request_rec.incident_addr_lines_phonetic := p13_a193;
    ddp_service_request_rec.incident_po_box_number := p13_a194;
    ddp_service_request_rec.incident_house_number := p13_a195;
    ddp_service_request_rec.incident_street_suffix := p13_a196;
    ddp_service_request_rec.incident_street := p13_a197;
    ddp_service_request_rec.incident_street_number := p13_a198;
    ddp_service_request_rec.incident_floor := p13_a199;
    ddp_service_request_rec.incident_suite := p13_a200;
    ddp_service_request_rec.incident_postal_plus4_code := p13_a201;
    ddp_service_request_rec.incident_position := p13_a202;
    ddp_service_request_rec.incident_location_directions := p13_a203;
    ddp_service_request_rec.incident_location_description := p13_a204;
    ddp_service_request_rec.install_site_id := p13_a205;
    ddp_service_request_rec.item_serial_number := p13_a206;
    ddp_service_request_rec.owning_department_id := p13_a207;
    ddp_service_request_rec.incident_location_type := p13_a208;
    ddp_service_request_rec.coverage_type := p13_a209;
    ddp_service_request_rec.maint_organization_id := p13_a210;
    ddp_service_request_rec.creation_date := rosetta_g_miss_date_in_map(p13_a211);
    ddp_service_request_rec.created_by := p13_a212;
    ddp_service_request_rec.instrument_payment_use_id := p13_a213;

    cs_servicerequest_pub_w.rosetta_table_copy_in_p1(ddp_notes, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p3(ddp_contacts, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      );






    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.create_servicerequest(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_request_id,
      p_request_number,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_default_contract_sla_ind,
      x_request_id,
      x_request_number,
      x_interaction_id,
      x_workflow_process_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




















  end;

  procedure process_sr_ext_attrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_incident_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_200
    , p4_a2 JTF_VARCHAR2_TABLE_200
    , p4_a3 JTF_VARCHAR2_TABLE_200
    , p4_a4 JTF_VARCHAR2_TABLE_200
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_failed_row_id_list out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_errorcode out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ext_attr_grp_tbl cs_servicerequest_pub.ext_attr_grp_tbl_type;
    ddp_ext_attr_tbl cs_servicerequest_pub.ext_attr_tbl_type;
    ddp_modified_on date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cs_servicerequest_pub_w.rosetta_table_copy_in_p8(ddp_ext_attr_grp_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p10(ddp_ext_attr_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    ddp_modified_on := rosetta_g_miss_date_in_map(p_modified_on);






    -- here's the delegated call to the old PL/SQL routine
    cs_servicerequest_pub.process_sr_ext_attrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_incident_id,
      ddp_ext_attr_grp_tbl,
      ddp_ext_attr_tbl,
      p_modified_by,
      ddp_modified_on,
      x_failed_row_id_list,
      x_return_status,
      x_errorcode,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end cs_servicerequest_pub_w;

/
