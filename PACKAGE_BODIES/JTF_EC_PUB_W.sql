--------------------------------------------------------
--  DDL for Package Body JTF_EC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_PUB_W" as
  /* $Header: jtfpecwb.pls 115.1 2002/02/14 13:07:33 pkm ship     $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p7(t out jtf_ec_pub.esc_ref_docs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
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
    , a22 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).reference_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_type_code := a1(indx);
          t(ddindx).object_name := a2(indx);
          t(ddindx).object_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).reference_code := a4(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).action_code := a6(indx);
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
          t(ddindx).attribute_category := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_ec_pub.esc_ref_docs_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_NUMBER_TABLE
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_200
    , a8 out JTF_VARCHAR2_TABLE_200
    , a9 out JTF_VARCHAR2_TABLE_200
    , a10 out JTF_VARCHAR2_TABLE_200
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_VARCHAR2_TABLE_200
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
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
      a22 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).reference_id);
          a1(indx) := t(ddindx).object_type_code;
          a2(indx) := t(ddindx).object_name;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a4(indx) := t(ddindx).reference_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := t(ddindx).action_code;
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
          a22(indx) := t(ddindx).attribute_category;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out jtf_ec_pub.esc_contacts_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
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
    , a22 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).task_contact_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).contact_type_code := a3(indx);
          t(ddindx).escalation_notify_flag := a4(indx);
          t(ddindx).escalation_requester_flag := a5(indx);
          t(ddindx).action_code := a6(indx);
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
          t(ddindx).attribute_category := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jtf_ec_pub.esc_contacts_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_200
    , a8 out JTF_VARCHAR2_TABLE_200
    , a9 out JTF_VARCHAR2_TABLE_200
    , a10 out JTF_VARCHAR2_TABLE_200
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_VARCHAR2_TABLE_200
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
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
      a22 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).task_contact_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).contact_type_code;
          a4(indx) := t(ddindx).escalation_notify_flag;
          a5(indx) := t(ddindx).escalation_requester_flag;
          a6(indx) := t(ddindx).action_code;
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
          a22(indx) := t(ddindx).attribute_category;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out jtf_ec_pub.esc_cont_points_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contact_type_code := a1(indx);
          t(ddindx).contact_point_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).task_phone_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).action_code := a5(indx);
          t(ddindx).attribute1 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).attribute10 := a15(indx);
          t(ddindx).attribute11 := a16(indx);
          t(ddindx).attribute12 := a17(indx);
          t(ddindx).attribute13 := a18(indx);
          t(ddindx).attribute14 := a19(indx);
          t(ddindx).attribute15 := a20(indx);
          t(ddindx).attribute_category := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t jtf_ec_pub.esc_cont_points_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_200
    , a7 out JTF_VARCHAR2_TABLE_200
    , a8 out JTF_VARCHAR2_TABLE_200
    , a9 out JTF_VARCHAR2_TABLE_200
    , a10 out JTF_VARCHAR2_TABLE_200
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a1(indx) := t(ddindx).contact_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).contact_point_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).task_phone_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).action_code;
          a6(indx) := t(ddindx).attribute1;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).attribute10;
          a16(indx) := t(ddindx).attribute11;
          a17(indx) := t(ddindx).attribute12;
          a18(indx) := t(ddindx).attribute13;
          a19(indx) := t(ddindx).attribute14;
          a20(indx) := t(ddindx).attribute15;
          a21(indx) := t(ddindx).attribute_category;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out jtf_ec_pub.notes_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_32767
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).action_code := a0(indx);
          t(ddindx).note_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).note := a2(indx);
          t(ddindx).note_detail := a3(indx);
          t(ddindx).note_type := a4(indx);
          t(ddindx).note_status := a5(indx);
          t(ddindx).note_context_type_01 := a6(indx);
          t(ddindx).note_context_type_id_01 := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).note_context_type_02 := a8(indx);
          t(ddindx).note_context_type_id_02 := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).note_context_type_03 := a10(indx);
          t(ddindx).note_context_type_id_03 := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t jtf_ec_pub.notes_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_2000
    , a3 out JTF_VARCHAR2_TABLE_32767
    , a4 out JTF_VARCHAR2_TABLE_300
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_300
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_300
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_VARCHAR2_TABLE_300
    , a11 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_32767();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_32767();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).action_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).note_id);
          a2(indx) := t(ddindx).note;
          a3(indx) := t(ddindx).note_detail;
          a4(indx) := t(ddindx).note_type;
          a5(indx) := t(ddindx).note_status;
          a6(indx) := t(ddindx).note_context_type_01;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).note_context_type_id_01);
          a8(indx) := t(ddindx).note_context_type_02;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).note_context_type_id_02);
          a10(indx) := t(ddindx).note_context_type_03;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).note_context_type_id_03);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure create_escalation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_esc_id  NUMBER
    , p11_a0  VARCHAR2
    , p11_a1  VARCHAR2
    , p11_a2  VARCHAR2
    , p11_a3  NUMBER
    , p11_a4  DATE
    , p11_a5  NUMBER
    , p11_a6  NUMBER
    , p11_a7  VARCHAR2
    , p11_a8  NUMBER
    , p11_a9  VARCHAR2
    , p11_a10  NUMBER
    , p11_a11  VARCHAR2
    , p11_a12  DATE
    , p11_a13  VARCHAR2
    , p11_a14  VARCHAR2
    , p11_a15  VARCHAR2
    , p11_a16  VARCHAR2
    , p11_a17  VARCHAR2
    , p11_a18  VARCHAR2
    , p11_a19  VARCHAR2
    , p11_a20  VARCHAR2
    , p11_a21  VARCHAR2
    , p11_a22  VARCHAR2
    , p11_a23  VARCHAR2
    , p11_a24  VARCHAR2
    , p11_a25  VARCHAR2
    , p11_a26  VARCHAR2
    , p11_a27  VARCHAR2
    , p11_a28  VARCHAR2
    , p11_a29  VARCHAR2
    , p11_a30  VARCHAR2
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_NUMBER_TABLE
    , p12_a6 JTF_VARCHAR2_TABLE_100
    , p12_a7 JTF_VARCHAR2_TABLE_200
    , p12_a8 JTF_VARCHAR2_TABLE_200
    , p12_a9 JTF_VARCHAR2_TABLE_200
    , p12_a10 JTF_VARCHAR2_TABLE_200
    , p12_a11 JTF_VARCHAR2_TABLE_200
    , p12_a12 JTF_VARCHAR2_TABLE_200
    , p12_a13 JTF_VARCHAR2_TABLE_200
    , p12_a14 JTF_VARCHAR2_TABLE_200
    , p12_a15 JTF_VARCHAR2_TABLE_200
    , p12_a16 JTF_VARCHAR2_TABLE_200
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_200
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_200
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_VARCHAR2_TABLE_100
    , p13_a4 JTF_VARCHAR2_TABLE_100
    , p13_a5 JTF_VARCHAR2_TABLE_100
    , p13_a6 JTF_VARCHAR2_TABLE_100
    , p13_a7 JTF_VARCHAR2_TABLE_200
    , p13_a8 JTF_VARCHAR2_TABLE_200
    , p13_a9 JTF_VARCHAR2_TABLE_200
    , p13_a10 JTF_VARCHAR2_TABLE_200
    , p13_a11 JTF_VARCHAR2_TABLE_200
    , p13_a12 JTF_VARCHAR2_TABLE_200
    , p13_a13 JTF_VARCHAR2_TABLE_200
    , p13_a14 JTF_VARCHAR2_TABLE_200
    , p13_a15 JTF_VARCHAR2_TABLE_200
    , p13_a16 JTF_VARCHAR2_TABLE_200
    , p13_a17 JTF_VARCHAR2_TABLE_200
    , p13_a18 JTF_VARCHAR2_TABLE_200
    , p13_a19 JTF_VARCHAR2_TABLE_200
    , p13_a20 JTF_VARCHAR2_TABLE_200
    , p13_a21 JTF_VARCHAR2_TABLE_200
    , p13_a22 JTF_VARCHAR2_TABLE_200
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_VARCHAR2_TABLE_100
    , p14_a2 JTF_NUMBER_TABLE
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_VARCHAR2_TABLE_200
    , p14_a7 JTF_VARCHAR2_TABLE_200
    , p14_a8 JTF_VARCHAR2_TABLE_200
    , p14_a9 JTF_VARCHAR2_TABLE_200
    , p14_a10 JTF_VARCHAR2_TABLE_200
    , p14_a11 JTF_VARCHAR2_TABLE_200
    , p14_a12 JTF_VARCHAR2_TABLE_200
    , p14_a13 JTF_VARCHAR2_TABLE_200
    , p14_a14 JTF_VARCHAR2_TABLE_200
    , p14_a15 JTF_VARCHAR2_TABLE_200
    , p14_a16 JTF_VARCHAR2_TABLE_200
    , p14_a17 JTF_VARCHAR2_TABLE_200
    , p14_a18 JTF_VARCHAR2_TABLE_200
    , p14_a19 JTF_VARCHAR2_TABLE_200
    , p14_a20 JTF_VARCHAR2_TABLE_200
    , p14_a21 JTF_VARCHAR2_TABLE_200
    , p15_a0 JTF_VARCHAR2_TABLE_100
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_VARCHAR2_TABLE_2000
    , p15_a3 JTF_VARCHAR2_TABLE_32767
    , p15_a4 JTF_VARCHAR2_TABLE_300
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_300
    , p15_a7 JTF_NUMBER_TABLE
    , p15_a8 JTF_VARCHAR2_TABLE_300
    , p15_a9 JTF_NUMBER_TABLE
    , p15_a10 JTF_VARCHAR2_TABLE_300
    , p15_a11 JTF_NUMBER_TABLE
    , x_esc_id out  NUMBER
    , x_esc_number out  NUMBER
    , x_workflow_process_id out  VARCHAR2
  )
  as
    ddp_esc_record jtf_ec_pub.esc_rec_type;
    ddp_reference_documents jtf_ec_pub.esc_ref_docs_tbl_type;
    ddp_esc_contacts jtf_ec_pub.esc_contacts_tbl_type;
    ddp_cont_points jtf_ec_pub.esc_cont_points_tbl_type;
    ddp_notes jtf_ec_pub.notes_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_esc_record.esc_name := p11_a0;
    ddp_esc_record.esc_description := p11_a1;
    ddp_esc_record.status_name := p11_a2;
    ddp_esc_record.status_id := rosetta_g_miss_num_map(p11_a3);
    ddp_esc_record.esc_open_date := rosetta_g_miss_date_in_map(p11_a4);
    ddp_esc_record.esc_owner_id := rosetta_g_miss_num_map(p11_a5);
    ddp_esc_record.customer_id := rosetta_g_miss_num_map(p11_a6);
    ddp_esc_record.customer_number := p11_a7;
    ddp_esc_record.cust_account_id := rosetta_g_miss_num_map(p11_a8);
    ddp_esc_record.cust_account_number := p11_a9;
    ddp_esc_record.cust_address_id := rosetta_g_miss_num_map(p11_a10);
    ddp_esc_record.cust_address_number := p11_a11;
    ddp_esc_record.esc_target_date := rosetta_g_miss_date_in_map(p11_a12);
    ddp_esc_record.reason_code := p11_a13;
    ddp_esc_record.escalation_level := p11_a14;
    ddp_esc_record.attribute1 := p11_a15;
    ddp_esc_record.attribute2 := p11_a16;
    ddp_esc_record.attribute3 := p11_a17;
    ddp_esc_record.attribute4 := p11_a18;
    ddp_esc_record.attribute5 := p11_a19;
    ddp_esc_record.attribute6 := p11_a20;
    ddp_esc_record.attribute7 := p11_a21;
    ddp_esc_record.attribute8 := p11_a22;
    ddp_esc_record.attribute9 := p11_a23;
    ddp_esc_record.attribute10 := p11_a24;
    ddp_esc_record.attribute11 := p11_a25;
    ddp_esc_record.attribute12 := p11_a26;
    ddp_esc_record.attribute13 := p11_a27;
    ddp_esc_record.attribute14 := p11_a28;
    ddp_esc_record.attribute15 := p11_a29;
    ddp_esc_record.attribute_category := p11_a30;

    jtf_ec_pub_w.rosetta_table_copy_in_p7(ddp_reference_documents, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p9(ddp_esc_contacts, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p11(ddp_cont_points, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p13(ddp_notes, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    jtf_ec_pub.create_escalation(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_esc_id,
      ddp_esc_record,
      ddp_reference_documents,
      ddp_esc_contacts,
      ddp_cont_points,
      ddp_notes,
      x_esc_id,
      x_esc_number,
      x_workflow_process_id);

    -- copy data back from the local OUT or IN-OUT args, if any


















  end;

  procedure update_escalation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_esc_id  NUMBER
    , p_esc_number  VARCHAR2
    , p_object_version  NUMBER
    , p13_a0  VARCHAR2
    , p13_a1  VARCHAR2
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  DATE
    , p13_a5  NUMBER
    , p13_a6  NUMBER
    , p13_a7  VARCHAR2
    , p13_a8  NUMBER
    , p13_a9  VARCHAR2
    , p13_a10  NUMBER
    , p13_a11  VARCHAR2
    , p13_a12  DATE
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  VARCHAR2
    , p13_a16  VARCHAR2
    , p13_a17  VARCHAR2
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  VARCHAR2
    , p13_a21  VARCHAR2
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  VARCHAR2
    , p13_a25  VARCHAR2
    , p13_a26  VARCHAR2
    , p13_a27  VARCHAR2
    , p13_a28  VARCHAR2
    , p13_a29  VARCHAR2
    , p13_a30  VARCHAR2
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_VARCHAR2_TABLE_100
    , p14_a2 JTF_VARCHAR2_TABLE_100
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_VARCHAR2_TABLE_100
    , p14_a5 JTF_NUMBER_TABLE
    , p14_a6 JTF_VARCHAR2_TABLE_100
    , p14_a7 JTF_VARCHAR2_TABLE_200
    , p14_a8 JTF_VARCHAR2_TABLE_200
    , p14_a9 JTF_VARCHAR2_TABLE_200
    , p14_a10 JTF_VARCHAR2_TABLE_200
    , p14_a11 JTF_VARCHAR2_TABLE_200
    , p14_a12 JTF_VARCHAR2_TABLE_200
    , p14_a13 JTF_VARCHAR2_TABLE_200
    , p14_a14 JTF_VARCHAR2_TABLE_200
    , p14_a15 JTF_VARCHAR2_TABLE_200
    , p14_a16 JTF_VARCHAR2_TABLE_200
    , p14_a17 JTF_VARCHAR2_TABLE_200
    , p14_a18 JTF_VARCHAR2_TABLE_200
    , p14_a19 JTF_VARCHAR2_TABLE_200
    , p14_a20 JTF_VARCHAR2_TABLE_200
    , p14_a21 JTF_VARCHAR2_TABLE_200
    , p14_a22 JTF_VARCHAR2_TABLE_200
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_VARCHAR2_TABLE_200
    , p15_a8 JTF_VARCHAR2_TABLE_200
    , p15_a9 JTF_VARCHAR2_TABLE_200
    , p15_a10 JTF_VARCHAR2_TABLE_200
    , p15_a11 JTF_VARCHAR2_TABLE_200
    , p15_a12 JTF_VARCHAR2_TABLE_200
    , p15_a13 JTF_VARCHAR2_TABLE_200
    , p15_a14 JTF_VARCHAR2_TABLE_200
    , p15_a15 JTF_VARCHAR2_TABLE_200
    , p15_a16 JTF_VARCHAR2_TABLE_200
    , p15_a17 JTF_VARCHAR2_TABLE_200
    , p15_a18 JTF_VARCHAR2_TABLE_200
    , p15_a19 JTF_VARCHAR2_TABLE_200
    , p15_a20 JTF_VARCHAR2_TABLE_200
    , p15_a21 JTF_VARCHAR2_TABLE_200
    , p15_a22 JTF_VARCHAR2_TABLE_200
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_VARCHAR2_TABLE_100
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_NUMBER_TABLE
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_VARCHAR2_TABLE_200
    , p16_a7 JTF_VARCHAR2_TABLE_200
    , p16_a8 JTF_VARCHAR2_TABLE_200
    , p16_a9 JTF_VARCHAR2_TABLE_200
    , p16_a10 JTF_VARCHAR2_TABLE_200
    , p16_a11 JTF_VARCHAR2_TABLE_200
    , p16_a12 JTF_VARCHAR2_TABLE_200
    , p16_a13 JTF_VARCHAR2_TABLE_200
    , p16_a14 JTF_VARCHAR2_TABLE_200
    , p16_a15 JTF_VARCHAR2_TABLE_200
    , p16_a16 JTF_VARCHAR2_TABLE_200
    , p16_a17 JTF_VARCHAR2_TABLE_200
    , p16_a18 JTF_VARCHAR2_TABLE_200
    , p16_a19 JTF_VARCHAR2_TABLE_200
    , p16_a20 JTF_VARCHAR2_TABLE_200
    , p16_a21 JTF_VARCHAR2_TABLE_200
    , p17_a0 JTF_VARCHAR2_TABLE_100
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_VARCHAR2_TABLE_2000
    , p17_a3 JTF_VARCHAR2_TABLE_32767
    , p17_a4 JTF_VARCHAR2_TABLE_300
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p17_a6 JTF_VARCHAR2_TABLE_300
    , p17_a7 JTF_NUMBER_TABLE
    , p17_a8 JTF_VARCHAR2_TABLE_300
    , p17_a9 JTF_NUMBER_TABLE
    , p17_a10 JTF_VARCHAR2_TABLE_300
    , p17_a11 JTF_NUMBER_TABLE
    , x_object_version_number out  NUMBER
    , x_workflow_process_id out  VARCHAR2
  )
  as
    ddp_esc_record jtf_ec_pub.esc_rec_type;
    ddp_reference_documents jtf_ec_pub.esc_ref_docs_tbl_type;
    ddp_esc_contacts jtf_ec_pub.esc_contacts_tbl_type;
    ddp_cont_points jtf_ec_pub.esc_cont_points_tbl_type;
    ddp_notes jtf_ec_pub.notes_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_esc_record.esc_name := p13_a0;
    ddp_esc_record.esc_description := p13_a1;
    ddp_esc_record.status_name := p13_a2;
    ddp_esc_record.status_id := rosetta_g_miss_num_map(p13_a3);
    ddp_esc_record.esc_open_date := rosetta_g_miss_date_in_map(p13_a4);
    ddp_esc_record.esc_owner_id := rosetta_g_miss_num_map(p13_a5);
    ddp_esc_record.customer_id := rosetta_g_miss_num_map(p13_a6);
    ddp_esc_record.customer_number := p13_a7;
    ddp_esc_record.cust_account_id := rosetta_g_miss_num_map(p13_a8);
    ddp_esc_record.cust_account_number := p13_a9;
    ddp_esc_record.cust_address_id := rosetta_g_miss_num_map(p13_a10);
    ddp_esc_record.cust_address_number := p13_a11;
    ddp_esc_record.esc_target_date := rosetta_g_miss_date_in_map(p13_a12);
    ddp_esc_record.reason_code := p13_a13;
    ddp_esc_record.escalation_level := p13_a14;
    ddp_esc_record.attribute1 := p13_a15;
    ddp_esc_record.attribute2 := p13_a16;
    ddp_esc_record.attribute3 := p13_a17;
    ddp_esc_record.attribute4 := p13_a18;
    ddp_esc_record.attribute5 := p13_a19;
    ddp_esc_record.attribute6 := p13_a20;
    ddp_esc_record.attribute7 := p13_a21;
    ddp_esc_record.attribute8 := p13_a22;
    ddp_esc_record.attribute9 := p13_a23;
    ddp_esc_record.attribute10 := p13_a24;
    ddp_esc_record.attribute11 := p13_a25;
    ddp_esc_record.attribute12 := p13_a26;
    ddp_esc_record.attribute13 := p13_a27;
    ddp_esc_record.attribute14 := p13_a28;
    ddp_esc_record.attribute15 := p13_a29;
    ddp_esc_record.attribute_category := p13_a30;

    jtf_ec_pub_w.rosetta_table_copy_in_p7(ddp_reference_documents, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p9(ddp_esc_contacts, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p11(ddp_cont_points, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      , p16_a9
      , p16_a10
      , p16_a11
      , p16_a12
      , p16_a13
      , p16_a14
      , p16_a15
      , p16_a16
      , p16_a17
      , p16_a18
      , p16_a19
      , p16_a20
      , p16_a21
      );

    jtf_ec_pub_w.rosetta_table_copy_in_p13(ddp_notes, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      , p17_a9
      , p17_a10
      , p17_a11
      );



    -- here's the delegated call to the old PL/SQL routine
    jtf_ec_pub.update_escalation(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_esc_id,
      p_esc_number,
      p_object_version,
      ddp_esc_record,
      ddp_reference_documents,
      ddp_esc_contacts,
      ddp_cont_points,
      ddp_notes,
      x_object_version_number,
      x_workflow_process_id);

    -- copy data back from the local OUT or IN-OUT args, if any



















  end;

end jtf_ec_pub_w;

/
