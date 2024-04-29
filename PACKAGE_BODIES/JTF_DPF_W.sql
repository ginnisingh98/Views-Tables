--------------------------------------------------------
--  DDL for Package Body JTF_DPF_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF_W" as
  /* $Header: jtfdpwb.pls 120.2 2005/10/25 05:19:14 psanyal ship $ */
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

  procedure rosetta_table_copy_in_p9(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_rule_param_tbl, a0 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).condition := a0(indx);
          t(ddindx).param_name := a1(indx);
          t(ddindx).param_value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jtf_dpf.new_rule_param_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).condition;
          a1(indx) := t(ddindx).param_name;
          a2(indx) := t(ddindx).param_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_phys_non_def_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).physical_page_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t jtf_dpf.new_phys_non_def_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).physical_page_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_next_log_non_def_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).logical_page_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t jtf_dpf.new_next_log_non_def_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).logical_page_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p15(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_phys_attribs_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t jtf_dpf.new_phys_attribs_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
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
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p16(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.dpf_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).dpf_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).dpf_name := a1(indx);
          t(ddindx).head_logical_asn := a2(indx);
          t(ddindx).head_logical_name := a3(indx);
          t(ddindx).rtn_to_page_logical_asn := a4(indx);
          t(ddindx).rtn_to_page_logical_name := a5(indx);
          t(ddindx).flow_finalizer_class := a6(indx);
          t(ddindx).logical_flow_description := a7(indx);
          t(ddindx).validate_flag := a8(indx);
          t(ddindx).secure_flow_flag := a9(indx);
          t(ddindx).active_flag := a10(indx);
          t(ddindx).editable_flag := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t jtf_dpf.dpf_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).dpf_id);
          a1(indx) := t(ddindx).dpf_name;
          a2(indx) := t(ddindx).head_logical_asn;
          a3(indx) := t(ddindx).head_logical_name;
          a4(indx) := t(ddindx).rtn_to_page_logical_asn;
          a5(indx) := t(ddindx).rtn_to_page_logical_name;
          a6(indx) := t(ddindx).flow_finalizer_class;
          a7(indx) := t(ddindx).logical_flow_description;
          a8(indx) := t(ddindx).validate_flag;
          a9(indx) := t(ddindx).secure_flow_flag;
          a10(indx) := t(ddindx).active_flag;
          a11(indx) := t(ddindx).editable_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p17(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.logical_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).logical_page_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).logical_page_name := a1(indx);
          t(ddindx).logical_page_type := a2(indx);
          t(ddindx).logical_page_description := a3(indx);
          t(ddindx).page_controller_class := a4(indx);
          t(ddindx).page_permission_name := a5(indx);
          t(ddindx).def_phys_asn := a6(indx);
          t(ddindx).def_phys_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).def_phys_name := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t jtf_dpf.logical_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).logical_page_id);
          a1(indx) := t(ddindx).logical_page_name;
          a2(indx) := t(ddindx).logical_page_type;
          a3(indx) := t(ddindx).logical_page_description;
          a4(indx) := t(ddindx).page_controller_class;
          a5(indx) := t(ddindx).page_permission_name;
          a6(indx) := t(ddindx).def_phys_asn;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).def_phys_id);
          a8(indx) := t(ddindx).def_phys_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p18(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_tbl, a0 JTF_NUMBER_TABLE
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
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).descr := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t jtf_dpf.physical_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).descr;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_non_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).logical_name := a0(indx);
          t(ddindx).rule_eval_sequence := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).rule_asn := a2(indx);
          t(ddindx).rule_name := a3(indx);
          t(ddindx).phys_asn := a4(indx);
          t(ddindx).phys_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).phys_name := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t jtf_dpf.physical_non_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).logical_name;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).rule_eval_sequence);
          a2(indx) := t(ddindx).rule_asn;
          a3(indx) := t(ddindx).rule_name;
          a4(indx) := t(ddindx).phys_asn;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).phys_id);
          a6(indx) := t(ddindx).phys_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.rule_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rule_name := a1(indx);
          t(ddindx).rule_description := a2(indx);
          t(ddindx).rule_param_name := a3(indx);
          t(ddindx).rule_param_value := a4(indx);
          t(ddindx).rule_param_condition := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t jtf_dpf.rule_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a1(indx) := t(ddindx).rule_name;
          a2(indx) := t(ddindx).rule_description;
          a3(indx) := t(ddindx).rule_param_name;
          a4(indx) := t(ddindx).rule_param_value;
          a5(indx) := t(ddindx).rule_param_condition;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p21(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.next_logical_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).dpf_name := a0(indx);
          t(ddindx).dpf_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).key_log_asn := a2(indx);
          t(ddindx).key_log_name := a3(indx);
          t(ddindx).result_log_asn := a4(indx);
          t(ddindx).result_log_name := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t jtf_dpf.next_logical_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).dpf_name;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).dpf_id);
          a2(indx) := t(ddindx).key_log_asn;
          a3(indx) := t(ddindx).key_log_name;
          a4(indx) := t(ddindx).result_log_asn;
          a5(indx) := t(ddindx).result_log_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p22(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.next_logical_non_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).dpf_name := a0(indx);
          t(ddindx).dpf_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).rule_asn := a2(indx);
          t(ddindx).rule_name := a3(indx);
          t(ddindx).key_log_asn := a4(indx);
          t(ddindx).key_log_name := a5(indx);
          t(ddindx).result_log_asn := a6(indx);
          t(ddindx).result_log_name := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t jtf_dpf.next_logical_non_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).dpf_name;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).dpf_id);
          a2(indx) := t(ddindx).rule_asn;
          a3(indx) := t(ddindx).rule_name;
          a4(indx) := t(ddindx).key_log_asn;
          a5(indx) := t(ddindx).key_log_name;
          a6(indx) := t(ddindx).result_log_asn;
          a7(indx) := t(ddindx).result_log_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p23(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_attribs_tbl, a0 JTF_NUMBER_TABLE
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
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t jtf_dpf.physical_attribs_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure get(asn  VARCHAR2
    , p_lang IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , descrs_only  number
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p3_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p7_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p9_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )
  as
    dddescrs_only boolean;
    dddpf jtf_dpf.dpf_tbl;
    ddlog jtf_dpf.logical_tbl;
    ddphys jtf_dpf.physical_tbl;
    ddphys_non_def jtf_dpf.physical_non_default_tbl;
    ddrule jtf_dpf.rule_tbl;
    ddnext_log_def jtf_dpf.next_logical_default_tbl;
    ddnext_log_non_def jtf_dpf.next_logical_non_default_tbl;
    ddphys_atts jtf_dpf.physical_attribs_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    if descrs_only is null
      then dddescrs_only := null;
    elsif descrs_only = 0
      then dddescrs_only := false;
    else dddescrs_only := true;
    end if;









    -- here's the delegated call to the old PL/SQL routine
    jtf_dpf.get(asn,
      p_lang,
      dddescrs_only,
      dddpf,
      ddlog,
      ddphys,
      ddphys_non_def,
      ddrule,
      ddnext_log_def,
      ddnext_log_non_def,
      ddphys_atts);

    -- copy data back from the local OUT  or IN-OUT args, if any



    jtf_dpf_w.rosetta_table_copy_out_p16(dddpf, p3_a0
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
      );

    jtf_dpf_w.rosetta_table_copy_out_p17(ddlog, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      );

    jtf_dpf_w.rosetta_table_copy_out_p18(ddphys, p5_a0
      , p5_a1
      , p5_a2
      );

    jtf_dpf_w.rosetta_table_copy_out_p19(ddphys_non_def, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );

    jtf_dpf_w.rosetta_table_copy_out_p20(ddrule, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      );

    jtf_dpf_w.rosetta_table_copy_out_p21(ddnext_log_def, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      );

    jtf_dpf_w.rosetta_table_copy_out_p22(ddnext_log_non_def, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      );

    jtf_dpf_w.rosetta_table_copy_out_p23(ddphys_atts, p10_a0
      , p10_a1
      , p10_a2
      );
  end;

  function rule_update(p_rule_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  ) return number
  as
    ddupd jtf_dpf.rule_update_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddupd.p_new_asn := p1_a0;
    ddupd.p_new_name := p1_a1;
    ddupd.p_new_descr := p1_a2;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_dpf.rule_update(p_rule_id,
      ddupd);

    -- copy data back from the local OUT  or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  function rule_new(p_asn  VARCHAR2
    , p_name  VARCHAR2
    , p_descr  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
  ) return number
  as
    ddrules jtf_dpf.new_rule_param_tbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    jtf_dpf_w.rosetta_table_copy_in_p9(ddrules, p3_a0
      , p3_a1
      , p3_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_dpf.rule_new(p_asn,
      p_name,
      p_descr,
      ddrules);

    -- copy data back from the local OUT or IN-OUT args, if any




    return ddrosetta_retval;
  end;

  procedure rule_set_params(p_rule_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
  )
  as
    ddrules jtf_dpf.new_rule_param_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jtf_dpf_w.rosetta_table_copy_in_p9(ddrules, p1_a0
      , p1_a1
      , p1_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_dpf.rule_set_params(p_rule_id,
      ddrules);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  function phys_update(p_ppid  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  ) return number
  as
    ddupd jtf_dpf.phys_update_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddupd.p_new_asn := p1_a0;
    ddupd.p_name := p1_a1;
    ddupd.p_descr := p1_a2;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_dpf.phys_update(p_ppid,
      ddupd);

    -- copy data back from the local OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  procedure phys_attribs_update(p_ppid  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_300
  )
  as
    ddp_new_ones jtf_dpf.new_phys_attribs_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jtf_dpf_w.rosetta_table_copy_in_p15(ddp_new_ones, p1_a0
      , p1_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_dpf.phys_attribs_update(p_ppid,
      ddp_new_ones);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  function flow_update(p_logical_flow_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
  ) return number
  as
    ddupd jtf_dpf.flow_update_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddupd.p_new_asn := p1_a0;
    ddupd.p_new_name := p1_a1;
    ddupd.p_new_flow_finalizer_class := p1_a2;
    ddupd.p_new_descr := p1_a3;
    ddupd.p_new_validate_flag := p1_a4;
    ddupd.p_new_secure_flow_flag := p1_a5;
    ddupd.p_new_header_logical_page_id := rosetta_g_miss_num_map(p1_a6);
    ddupd.p_rtn_to_logical_page_id := rosetta_g_miss_num_map(p1_a7);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_dpf.flow_update(p_logical_flow_id,
      ddupd);

    -- copy data back from the local OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  function logical_update(p_logical_page_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
  ) return number
  as
    ddupd jtf_dpf.logical_update_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddupd.p_new_asn := p1_a0;
    ddupd.p_new_name := p1_a1;
    ddupd.p_new_type := p1_a2;
    ddupd.p_new_descr := p1_a3;
    ddupd.p_new_page_controller_class := p1_a4;
    ddupd.p_new_page_permission_name := p1_a5;
    ddupd.p_default_physical_id := rosetta_g_miss_num_map(p1_a6);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_dpf.logical_update(p_logical_page_id,
      ddupd);

    -- copy data back from the local OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  procedure logical_set_non_default_phys(p_logical_page_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
  )
  as
    ddp_new_ones jtf_dpf.new_phys_non_def_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jtf_dpf_w.rosetta_table_copy_in_p11(ddp_new_ones, p1_a0
      , p1_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_dpf.logical_set_non_default_phys(p_logical_page_id,
      ddp_new_ones);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure next_logical_set_non_default(p_flow_id  NUMBER
    , p_log_page_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
  )
  as
    ddp_new_ones jtf_dpf.new_next_log_non_def_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    jtf_dpf_w.rosetta_table_copy_in_p13(ddp_new_ones, p2_a0
      , p2_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_dpf.next_logical_set_non_default(p_flow_id,
      p_log_page_id,
      ddp_new_ones);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

end jtf_dpf_w;

/
