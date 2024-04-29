--------------------------------------------------------
--  DDL for Package Body JTF_UM_SUBSCRIPTION_INFO_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_SUBSCRIPTION_INFO_W" as
  /* $Header: JTFWSBIB.pls 120.2 2005/09/02 18:36:12 applrt ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy jtf_um_subscription_info.subscription_info_table, a0 JTF_VARCHAR2_TABLE_1000
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).key := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).display_order := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).activation_mode := a4(indx);
          t(ddindx).delegation_role := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).checkbox_status := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).approval_required := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).subscription_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).subscription_reg_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).approval_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).is_user_enrolled := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).subscription_status := a12(indx);
          t(ddindx).template_handler := a13(indx);
          t(ddindx).page_name := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t jtf_um_subscription_info.subscription_info_table, a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).key;
          a2(indx) := t(ddindx).description;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).display_order);
          a4(indx) := t(ddindx).activation_mode;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).delegation_role);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).checkbox_status);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).approval_required);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).subscription_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).subscription_reg_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).approval_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).is_user_enrolled);
          a12(indx) := t(ddindx).subscription_status;
          a13(indx) := t(ddindx).template_handler;
          a14(indx) := t(ddindx).page_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_um_subscription_info.subscription_list, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).subscription_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_um_subscription_info.subscription_list, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).subscription_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_usertype_sub_info(p_usertype_id  NUMBER
    , p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_result jtf_um_subscription_info.subscription_info_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_subscription_info.get_usertype_sub_info(p_usertype_id,
      p_user_id,
      p_is_admin,
      ddx_result);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jtf_um_subscription_info_w.rosetta_table_copy_out_p2(ddx_result, p3_a0
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
      );
  end;

  procedure get_user_sub_info(p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p_logged_in_user_id  NUMBER
    , p_administrator  NUMBER
    , p_sub_status  VARCHAR2
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_result jtf_um_subscription_info.subscription_info_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    jtf_um_subscription_info.get_user_sub_info(p_user_id,
      p_is_admin,
      p_logged_in_user_id,
      p_administrator,
      p_sub_status,
      ddx_result);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    jtf_um_subscription_info_w.rosetta_table_copy_out_p2(ddx_result, p5_a0
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
      );
  end;

  procedure get_conf_sub_info(p_user_id  NUMBER
    , p_usertype_id  NUMBER
    , p_is_admin  NUMBER
    , p_admin_id  NUMBER
    , p_administrator  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_sub_list jtf_um_subscription_info.subscription_list;
    ddx_result jtf_um_subscription_info.subscription_info_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    jtf_um_subscription_info_w.rosetta_table_copy_in_p3(ddp_sub_list, p5_a0
      );


    -- here's the delegated call to the old PL/SQL routine
    jtf_um_subscription_info.get_conf_sub_info(p_user_id,
      p_usertype_id,
      p_is_admin,
      p_admin_id,
      p_administrator,
      ddp_sub_list,
      ddx_result);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    jtf_um_subscription_info_w.rosetta_table_copy_out_p2(ddx_result, p6_a0
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
  end;

  procedure get_usertype_sub(p_usertype_id  NUMBER
    , p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p_admin_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_sub_list jtf_um_subscription_info.subscription_list;
    ddx_result jtf_um_subscription_info.subscription_info_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    jtf_um_subscription_info_w.rosetta_table_copy_in_p3(ddp_sub_list, p4_a0
      );


    -- here's the delegated call to the old PL/SQL routine
    jtf_um_subscription_info.get_usertype_sub(p_usertype_id,
      p_user_id,
      p_is_admin,
      p_admin_id,
      ddp_sub_list,
      ddx_result);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    jtf_um_subscription_info_w.rosetta_table_copy_out_p2(ddx_result, p5_a0
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
      );
  end;

end jtf_um_subscription_info_w;

/
