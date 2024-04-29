--------------------------------------------------------
--  DDL for Package Body JTF_ATTACHMENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ATTACHMENT_GRP_W" as
  /* $Header: JTFGRATB.pls 115.8 2004/07/09 18:50:20 applrt ship $ */
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

  procedure rosetta_table_copy_in_p1(t out jtf_attachment_grp.attachment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_1100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
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
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_VARCHAR2_TABLE_1000
    , a43 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attachment_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).deliverable_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).file_name := a2(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).x_action_status := a4(indx);
          t(ddindx).attachment_used_by := a5(indx);
          t(ddindx).enabled_flag := a6(indx);
          t(ddindx).can_fulfill_electronic_flag := a7(indx);
          t(ddindx).file_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).file_extension := a9(indx);
          t(ddindx).keywords := a10(indx);
          t(ddindx).display_width := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).display_height := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).display_location := a13(indx);
          t(ddindx).link_to := a14(indx);
          t(ddindx).link_url := a15(indx);
          t(ddindx).send_for_preview_flag := a16(indx);
          t(ddindx).attachment_type := a17(indx);
          t(ddindx).language_code := a18(indx);
          t(ddindx).application_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).description := a20(indx);
          t(ddindx).default_style_sheet := a21(indx);
          t(ddindx).display_url := a22(indx);
          t(ddindx).display_rule_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).display_program := a24(indx);
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          t(ddindx).display_text := a41(indx);
          t(ddindx).alternate_text := a42(indx);
          t(ddindx).attachment_sub_type := a43(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_attachment_grp.attachment_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_VARCHAR2_TABLE_300
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    , a13 out JTF_VARCHAR2_TABLE_2000
    , a14 out JTF_VARCHAR2_TABLE_2000
    , a15 out JTF_VARCHAR2_TABLE_2000
    , a16 out JTF_VARCHAR2_TABLE_100
    , a17 out JTF_VARCHAR2_TABLE_100
    , a18 out JTF_VARCHAR2_TABLE_100
    , a19 out JTF_NUMBER_TABLE
    , a20 out JTF_VARCHAR2_TABLE_2000
    , a21 out JTF_VARCHAR2_TABLE_300
    , a22 out JTF_VARCHAR2_TABLE_1100
    , a23 out JTF_NUMBER_TABLE
    , a24 out JTF_VARCHAR2_TABLE_300
    , a25 out JTF_VARCHAR2_TABLE_100
    , a26 out JTF_VARCHAR2_TABLE_200
    , a27 out JTF_VARCHAR2_TABLE_200
    , a28 out JTF_VARCHAR2_TABLE_200
    , a29 out JTF_VARCHAR2_TABLE_200
    , a30 out JTF_VARCHAR2_TABLE_200
    , a31 out JTF_VARCHAR2_TABLE_200
    , a32 out JTF_VARCHAR2_TABLE_200
    , a33 out JTF_VARCHAR2_TABLE_200
    , a34 out JTF_VARCHAR2_TABLE_200
    , a35 out JTF_VARCHAR2_TABLE_200
    , a36 out JTF_VARCHAR2_TABLE_200
    , a37 out JTF_VARCHAR2_TABLE_200
    , a38 out JTF_VARCHAR2_TABLE_200
    , a39 out JTF_VARCHAR2_TABLE_200
    , a40 out JTF_VARCHAR2_TABLE_200
    , a41 out JTF_VARCHAR2_TABLE_2000
    , a42 out JTF_VARCHAR2_TABLE_1000
    , a43 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_1100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_100();
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
    a41 := JTF_VARCHAR2_TABLE_2000();
    a42 := JTF_VARCHAR2_TABLE_1000();
    a43 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_1100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_100();
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
      a41 := JTF_VARCHAR2_TABLE_2000();
      a42 := JTF_VARCHAR2_TABLE_1000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attachment_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).deliverable_id);
          a2(indx) := t(ddindx).file_name;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a4(indx) := t(ddindx).x_action_status;
          a5(indx) := t(ddindx).attachment_used_by;
          a6(indx) := t(ddindx).enabled_flag;
          a7(indx) := t(ddindx).can_fulfill_electronic_flag;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).file_id);
          a9(indx) := t(ddindx).file_extension;
          a10(indx) := t(ddindx).keywords;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).display_width);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).display_height);
          a13(indx) := t(ddindx).display_location;
          a14(indx) := t(ddindx).link_to;
          a15(indx) := t(ddindx).link_url;
          a16(indx) := t(ddindx).send_for_preview_flag;
          a17(indx) := t(ddindx).attachment_type;
          a18(indx) := t(ddindx).language_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a20(indx) := t(ddindx).description;
          a21(indx) := t(ddindx).default_style_sheet;
          a22(indx) := t(ddindx).display_url;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).display_rule_id);
          a24(indx) := t(ddindx).display_program;
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          a41(indx) := t(ddindx).display_text;
          a42(indx) := t(ddindx).alternate_text;
          a43(indx) := t(ddindx).attachment_sub_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out jtf_attachment_grp.ath_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attachment_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).file_name := a1(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).x_action_status := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_attachment_grp.ath_id_ver_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attachment_id);
          a1(indx) := t(ddindx).file_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).x_action_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out jtf_attachment_grp.number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_attachment_grp.number_table();
  else
      if a0.count > 0 then
      t := jtf_attachment_grp.number_table();
      t.extend(a0.count);
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
  procedure rosetta_table_copy_out_p4(t jtf_attachment_grp.number_table, a0 out JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out jtf_attachment_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_attachment_grp.varchar2_table_300();
  else
      if a0.count > 0 then
      t := jtf_attachment_grp.varchar2_table_300();
      t.extend(a0.count);
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
  procedure rosetta_table_copy_out_p5(t jtf_attachment_grp.varchar2_table_300, a0 out JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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

  procedure rosetta_table_copy_in_p6(t out jtf_attachment_grp.varchar2_table_20, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_attachment_grp.varchar2_table_20();
  else
      if a0.count > 0 then
      t := jtf_attachment_grp.varchar2_table_20();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t jtf_attachment_grp.varchar2_table_20, a0 out JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p6;

  procedure list_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_appl_id  NUMBER
    , p_deliverable_id  NUMBER
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_ath_id_tbl out JTF_NUMBER_TABLE
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
    , x_file_ext_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_width_tbl out JTF_NUMBER_TABLE
    , x_dsp_height_tbl out JTF_NUMBER_TABLE
    , x_version_tbl out JTF_NUMBER_TABLE
  )
  as
    ddx_ath_id_tbl jtf_attachment_grp.number_table;
    ddx_dlv_id_tbl jtf_attachment_grp.number_table;
    ddx_file_name_tbl jtf_attachment_grp.varchar2_table_300;
    ddx_file_id_tbl jtf_attachment_grp.number_table;
    ddx_file_ext_tbl jtf_attachment_grp.varchar2_table_20;
    ddx_dsp_width_tbl jtf_attachment_grp.number_table;
    ddx_dsp_height_tbl jtf_attachment_grp.number_table;
    ddx_version_tbl jtf_attachment_grp.number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    -- here's the delegated call to the old PL/SQL routine
    jtf_attachment_grp.list_attachment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_appl_id,
      p_deliverable_id,
      p_start_id,
      p_batch_size,
      x_row_count,
      ddx_ath_id_tbl,
      ddx_dlv_id_tbl,
      ddx_file_name_tbl,
      ddx_file_id_tbl,
      ddx_file_ext_tbl,
      ddx_dsp_width_tbl,
      ddx_dsp_height_tbl,
      ddx_version_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any










    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_ath_id_tbl, x_ath_id_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_dlv_id_tbl, x_dlv_id_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p5(ddx_file_name_tbl, x_file_name_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_file_id_tbl, x_file_id_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p6(ddx_file_ext_tbl, x_file_ext_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_dsp_width_tbl, x_dsp_width_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_dsp_height_tbl, x_dsp_height_tbl);

    jtf_attachment_grp_w.rosetta_table_copy_out_p4(ddx_version_tbl, x_version_tbl);
  end;

  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  NUMBER
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  NUMBER
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  VARCHAR2
    , p6_a8 in out  NUMBER
    , p6_a9 in out  VARCHAR2
    , p6_a10 in out  VARCHAR2
    , p6_a11 in out  NUMBER
    , p6_a12 in out  NUMBER
    , p6_a13 in out  VARCHAR2
    , p6_a14 in out  VARCHAR2
    , p6_a15 in out  VARCHAR2
    , p6_a16 in out  VARCHAR2
    , p6_a17 in out  VARCHAR2
    , p6_a18 in out  VARCHAR2
    , p6_a19 in out  NUMBER
    , p6_a20 in out  VARCHAR2
    , p6_a21 in out  VARCHAR2
    , p6_a22 in out  VARCHAR2
    , p6_a23 in out  NUMBER
    , p6_a24 in out  VARCHAR2
    , p6_a25 in out  VARCHAR2
    , p6_a26 in out  VARCHAR2
    , p6_a27 in out  VARCHAR2
    , p6_a28 in out  VARCHAR2
    , p6_a29 in out  VARCHAR2
    , p6_a30 in out  VARCHAR2
    , p6_a31 in out  VARCHAR2
    , p6_a32 in out  VARCHAR2
    , p6_a33 in out  VARCHAR2
    , p6_a34 in out  VARCHAR2
    , p6_a35 in out  VARCHAR2
    , p6_a36 in out  VARCHAR2
    , p6_a37 in out  VARCHAR2
    , p6_a38 in out  VARCHAR2
    , p6_a39 in out  VARCHAR2
    , p6_a40 in out  VARCHAR2
    , p6_a41 in out  VARCHAR2
    , p6_a42 in out  VARCHAR2
    , p6_a43 in out  VARCHAR2
  )
  as
    ddp_attachment_rec jtf_attachment_grp.attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_attachment_rec.attachment_id := rosetta_g_miss_num_map(p6_a0);
    ddp_attachment_rec.deliverable_id := rosetta_g_miss_num_map(p6_a1);
    ddp_attachment_rec.file_name := p6_a2;
    ddp_attachment_rec.object_version_number := rosetta_g_miss_num_map(p6_a3);
    ddp_attachment_rec.x_action_status := p6_a4;
    ddp_attachment_rec.attachment_used_by := p6_a5;
    ddp_attachment_rec.enabled_flag := p6_a6;
    ddp_attachment_rec.can_fulfill_electronic_flag := p6_a7;
    ddp_attachment_rec.file_id := rosetta_g_miss_num_map(p6_a8);
    ddp_attachment_rec.file_extension := p6_a9;
    ddp_attachment_rec.keywords := p6_a10;
    ddp_attachment_rec.display_width := rosetta_g_miss_num_map(p6_a11);
    ddp_attachment_rec.display_height := rosetta_g_miss_num_map(p6_a12);
    ddp_attachment_rec.display_location := p6_a13;
    ddp_attachment_rec.link_to := p6_a14;
    ddp_attachment_rec.link_url := p6_a15;
    ddp_attachment_rec.send_for_preview_flag := p6_a16;
    ddp_attachment_rec.attachment_type := p6_a17;
    ddp_attachment_rec.language_code := p6_a18;
    ddp_attachment_rec.application_id := rosetta_g_miss_num_map(p6_a19);
    ddp_attachment_rec.description := p6_a20;
    ddp_attachment_rec.default_style_sheet := p6_a21;
    ddp_attachment_rec.display_url := p6_a22;
    ddp_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p6_a23);
    ddp_attachment_rec.display_program := p6_a24;
    ddp_attachment_rec.attribute_category := p6_a25;
    ddp_attachment_rec.attribute1 := p6_a26;
    ddp_attachment_rec.attribute2 := p6_a27;
    ddp_attachment_rec.attribute3 := p6_a28;
    ddp_attachment_rec.attribute4 := p6_a29;
    ddp_attachment_rec.attribute5 := p6_a30;
    ddp_attachment_rec.attribute6 := p6_a31;
    ddp_attachment_rec.attribute7 := p6_a32;
    ddp_attachment_rec.attribute8 := p6_a33;
    ddp_attachment_rec.attribute9 := p6_a34;
    ddp_attachment_rec.attribute10 := p6_a35;
    ddp_attachment_rec.attribute11 := p6_a36;
    ddp_attachment_rec.attribute12 := p6_a37;
    ddp_attachment_rec.attribute13 := p6_a38;
    ddp_attachment_rec.attribute14 := p6_a39;
    ddp_attachment_rec.attribute15 := p6_a40;
    ddp_attachment_rec.display_text := p6_a41;
    ddp_attachment_rec.alternate_text := p6_a42;
    ddp_attachment_rec.attachment_sub_type := p6_a43;

    -- here's the delegated call to the old PL/SQL routine
    jtf_attachment_grp.save_attachment(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attachment_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddp_attachment_rec.attachment_id);
    p6_a1 := rosetta_g_miss_num_map(ddp_attachment_rec.deliverable_id);
    p6_a2 := ddp_attachment_rec.file_name;
    p6_a3 := rosetta_g_miss_num_map(ddp_attachment_rec.object_version_number);
    p6_a4 := ddp_attachment_rec.x_action_status;
    p6_a5 := ddp_attachment_rec.attachment_used_by;
    p6_a6 := ddp_attachment_rec.enabled_flag;
    p6_a7 := ddp_attachment_rec.can_fulfill_electronic_flag;
    p6_a8 := rosetta_g_miss_num_map(ddp_attachment_rec.file_id);
    p6_a9 := ddp_attachment_rec.file_extension;
    p6_a10 := ddp_attachment_rec.keywords;
    p6_a11 := rosetta_g_miss_num_map(ddp_attachment_rec.display_width);
    p6_a12 := rosetta_g_miss_num_map(ddp_attachment_rec.display_height);
    p6_a13 := ddp_attachment_rec.display_location;
    p6_a14 := ddp_attachment_rec.link_to;
    p6_a15 := ddp_attachment_rec.link_url;
    p6_a16 := ddp_attachment_rec.send_for_preview_flag;
    p6_a17 := ddp_attachment_rec.attachment_type;
    p6_a18 := ddp_attachment_rec.language_code;
    p6_a19 := rosetta_g_miss_num_map(ddp_attachment_rec.application_id);
    p6_a20 := ddp_attachment_rec.description;
    p6_a21 := ddp_attachment_rec.default_style_sheet;
    p6_a22 := ddp_attachment_rec.display_url;
    p6_a23 := rosetta_g_miss_num_map(ddp_attachment_rec.display_rule_id);
    p6_a24 := ddp_attachment_rec.display_program;
    p6_a25 := ddp_attachment_rec.attribute_category;
    p6_a26 := ddp_attachment_rec.attribute1;
    p6_a27 := ddp_attachment_rec.attribute2;
    p6_a28 := ddp_attachment_rec.attribute3;
    p6_a29 := ddp_attachment_rec.attribute4;
    p6_a30 := ddp_attachment_rec.attribute5;
    p6_a31 := ddp_attachment_rec.attribute6;
    p6_a32 := ddp_attachment_rec.attribute7;
    p6_a33 := ddp_attachment_rec.attribute8;
    p6_a34 := ddp_attachment_rec.attribute9;
    p6_a35 := ddp_attachment_rec.attribute10;
    p6_a36 := ddp_attachment_rec.attribute11;
    p6_a37 := ddp_attachment_rec.attribute12;
    p6_a38 := ddp_attachment_rec.attribute13;
    p6_a39 := ddp_attachment_rec.attribute14;
    p6_a40 := ddp_attachment_rec.attribute15;
    p6_a41 := ddp_attachment_rec.display_text;
    p6_a42 := ddp_attachment_rec.alternate_text;
    p6_a43 := ddp_attachment_rec.attachment_sub_type;
  end;

  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_NUMBER_TABLE
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_NUMBER_TABLE
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_100
    , p6_a6 in out JTF_VARCHAR2_TABLE_100
    , p6_a7 in out JTF_VARCHAR2_TABLE_100
    , p6_a8 in out JTF_NUMBER_TABLE
    , p6_a9 in out JTF_VARCHAR2_TABLE_100
    , p6_a10 in out JTF_VARCHAR2_TABLE_300
    , p6_a11 in out JTF_NUMBER_TABLE
    , p6_a12 in out JTF_NUMBER_TABLE
    , p6_a13 in out JTF_VARCHAR2_TABLE_2000
    , p6_a14 in out JTF_VARCHAR2_TABLE_2000
    , p6_a15 in out JTF_VARCHAR2_TABLE_2000
    , p6_a16 in out JTF_VARCHAR2_TABLE_100
    , p6_a17 in out JTF_VARCHAR2_TABLE_100
    , p6_a18 in out JTF_VARCHAR2_TABLE_100
    , p6_a19 in out JTF_NUMBER_TABLE
    , p6_a20 in out JTF_VARCHAR2_TABLE_2000
    , p6_a21 in out JTF_VARCHAR2_TABLE_300
    , p6_a22 in out JTF_VARCHAR2_TABLE_1100
    , p6_a23 in out JTF_NUMBER_TABLE
    , p6_a24 in out JTF_VARCHAR2_TABLE_300
    , p6_a25 in out JTF_VARCHAR2_TABLE_100
    , p6_a26 in out JTF_VARCHAR2_TABLE_200
    , p6_a27 in out JTF_VARCHAR2_TABLE_200
    , p6_a28 in out JTF_VARCHAR2_TABLE_200
    , p6_a29 in out JTF_VARCHAR2_TABLE_200
    , p6_a30 in out JTF_VARCHAR2_TABLE_200
    , p6_a31 in out JTF_VARCHAR2_TABLE_200
    , p6_a32 in out JTF_VARCHAR2_TABLE_200
    , p6_a33 in out JTF_VARCHAR2_TABLE_200
    , p6_a34 in out JTF_VARCHAR2_TABLE_200
    , p6_a35 in out JTF_VARCHAR2_TABLE_200
    , p6_a36 in out JTF_VARCHAR2_TABLE_200
    , p6_a37 in out JTF_VARCHAR2_TABLE_200
    , p6_a38 in out JTF_VARCHAR2_TABLE_200
    , p6_a39 in out JTF_VARCHAR2_TABLE_200
    , p6_a40 in out JTF_VARCHAR2_TABLE_200
    , p6_a41 in out JTF_VARCHAR2_TABLE_2000
    , p6_a42 in out JTF_VARCHAR2_TABLE_1000
    , p6_a43 in out JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_attachment_tbl jtf_attachment_grp.attachment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_attachment_grp_w.rosetta_table_copy_in_p1(ddp_attachment_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_attachment_grp.save_attachment(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attachment_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_attachment_grp_w.rosetta_table_copy_out_p1(ddp_attachment_tbl, p6_a0
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
      );
  end;

  procedure delete_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_300
    , p6_a2 in out JTF_NUMBER_TABLE
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_ath_id_ver_tbl jtf_attachment_grp.ath_id_ver_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_attachment_grp_w.rosetta_table_copy_in_p3(ddp_ath_id_ver_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_attachment_grp.delete_attachment(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ath_id_ver_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_attachment_grp_w.rosetta_table_copy_out_p3(ddp_ath_id_ver_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

end jtf_attachment_grp_w;

/
