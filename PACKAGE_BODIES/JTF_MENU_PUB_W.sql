--------------------------------------------------------
--  DDL for Package Body JTF_MENU_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MENU_PUB_W" as
  /* $Header: jtfmenwb.pls 120.2 2005/10/25 05:23:26 psanyal ship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.menu_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sub_menu_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).prompt := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).function_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).menu_name := a4(indx);
          t(ddindx).menu_entry_rowid := a5(indx);
          t(ddindx).func_web_host_name := a6(indx);
          t(ddindx).func_web_agent_name := a7(indx);
          t(ddindx).func_web_html_call := a8(indx);
          t(ddindx).func_web_encrypt_parameters := a9(indx);
          t(ddindx).func_web_secured := a10(indx);
          t(ddindx).func_web_icon := a11(indx);
          t(ddindx).func_function_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).func_function_name := a13(indx);
          t(ddindx).func_application_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).func_creation_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).func_type := a16(indx);
          t(ddindx).func_user_function_name := a17(indx);
          t(ddindx).func_description := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_menu_pub.menu_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).sub_menu_id);
          a1(indx) := t(ddindx).prompt;
          a2(indx) := t(ddindx).description;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).function_id);
          a4(indx) := t(ddindx).menu_name;
          a5(indx) := t(ddindx).menu_entry_rowid;
          a6(indx) := t(ddindx).func_web_host_name;
          a7(indx) := t(ddindx).func_web_agent_name;
          a8(indx) := t(ddindx).func_web_html_call;
          a9(indx) := t(ddindx).func_web_encrypt_parameters;
          a10(indx) := t(ddindx).func_web_secured;
          a11(indx) := t(ddindx).func_web_icon;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).func_function_id);
          a13(indx) := t(ddindx).func_function_name;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).func_application_id);
          a15(indx) := t(ddindx).func_creation_date;
          a16(indx) := t(ddindx).func_type;
          a17(indx) := t(ddindx).func_user_function_name;
          a18(indx) := t(ddindx).func_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.number_table, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p4(t jtf_menu_pub.number_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.responsibility_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).responsibility_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).responsibility_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jtf_menu_pub.responsibility_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).responsibility_id);
          a1(indx) := t(ddindx).responsibility_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure get_excl_entire_menu_tree_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p_max_depth  NUMBER
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p6_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p_kids_menu_ids OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p8_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_responsibility_table jtf_menu_pub.responsibility_table;
    ddp_root_menu_data jtf_menu_pub.root_menu_data;
    ddp_root_menu_table jtf_menu_pub.menu_table;
    ddp_kids_menu_ids jtf_menu_pub.number_table;
    ddp_kids_menu_data jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_excl_entire_menu_tree_tl(p_lang,
      p_respid,
      p_appid,
      p_max_depth,
      ddp_responsibility_table,
      ddp_root_menu_data,
      ddp_root_menu_table,
      ddp_kids_menu_ids,
      ddp_kids_menu_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    jtf_menu_pub_w.rosetta_table_copy_out_p5(ddp_responsibility_table, p4_a0
      , p4_a1
      );

    p5_a0 := rosetta_g_miss_num_map(ddp_root_menu_data.menu_id);
    p5_a1 := ddp_root_menu_data.menu_name;
    p5_a2 := ddp_root_menu_data.prompt;
    p5_a3 := ddp_root_menu_data.description;

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_root_menu_table, p6_a0
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
      );

    jtf_menu_pub_w.rosetta_table_copy_out_p4(ddp_kids_menu_ids, p_kids_menu_ids);

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_kids_menu_data, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      );
  end;

  procedure get_excluded_root_menu_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p5_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_responsibility_table jtf_menu_pub.responsibility_table;
    ddp_root_menu_data jtf_menu_pub.root_menu_data;
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_excluded_root_menu_tl(p_lang,
      p_respid,
      p_appid,
      ddp_responsibility_table,
      ddp_root_menu_data,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jtf_menu_pub_w.rosetta_table_copy_out_p5(ddp_responsibility_table, p3_a0
      , p3_a1
      );

    p4_a0 := rosetta_g_miss_num_map(ddp_root_menu_data.menu_id);
    p4_a1 := ddp_root_menu_data.menu_name;
    p4_a2 := ddp_root_menu_data.prompt;
    p4_a3 := ddp_root_menu_data.description;

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p5_a0
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
      );
  end;

  procedure get_root_menu_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p5_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_responsibility_table jtf_menu_pub.responsibility_table;
    ddp_root_menu_data jtf_menu_pub.root_menu_data;
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_root_menu_tl(p_lang,
      p_respid,
      p_appid,
      ddp_responsibility_table,
      ddp_root_menu_data,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jtf_menu_pub_w.rosetta_table_copy_out_p5(ddp_responsibility_table, p3_a0
      , p3_a1
      );

    p4_a0 := rosetta_g_miss_num_map(ddp_root_menu_data.menu_id);
    p4_a1 := ddp_root_menu_data.menu_name;
    p4_a2 := ddp_root_menu_data.prompt;
    p4_a3 := ddp_root_menu_data.description;

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p5_a0
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
      );
  end;

  procedure get_root_menu(p_respid  NUMBER
    , p_appid  NUMBER
    , p2_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p4_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_responsibility_table jtf_menu_pub.responsibility_table;
    ddp_root_menu_data jtf_menu_pub.root_menu_data;
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_root_menu(p_respid,
      p_appid,
      ddp_responsibility_table,
      ddp_root_menu_data,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    jtf_menu_pub_w.rosetta_table_copy_out_p5(ddp_responsibility_table, p2_a0
      , p2_a1
      );

    p3_a0 := rosetta_g_miss_num_map(ddp_root_menu_data.menu_id);
    p3_a1 := ddp_root_menu_data.menu_name;
    p3_a2 := ddp_root_menu_data.prompt;
    p3_a3 := ddp_root_menu_data.description;

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      );
  end;

  procedure get_excluded_menu_entries_tl(p_lang  VARCHAR2
    , p_menu_id  NUMBER
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p4_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_excluded_menu_entries_tl(p_lang,
      p_menu_id,
      p_respid,
      p_appid,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p4_a0
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
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      );
  end;

  procedure get_menu_entries_tl(p_lang  VARCHAR2
    , p_menu_id  NUMBER
    , p2_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p2_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_menu_entries_tl(p_lang,
      p_menu_id,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      );
  end;

  procedure get_menu_entries(p_menu_id  NUMBER
    , p1_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_menu_entries(p_menu_id,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      );
  end;

  procedure get_func_entries(p_menu_id  NUMBER
    , p1_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_menu_table jtf_menu_pub.menu_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    jtf_menu_pub.get_func_entries(p_menu_id,
      ddp_menu_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    jtf_menu_pub_w.rosetta_table_copy_out_p3(ddp_menu_table, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      );
  end;

end jtf_menu_pub_w;

/
