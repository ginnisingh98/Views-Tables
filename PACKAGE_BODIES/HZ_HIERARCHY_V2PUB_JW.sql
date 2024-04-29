--------------------------------------------------------
--  DDL for Package Body HZ_HIERARCHY_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_HIERARCHY_V2PUB_JW" as
  /* $Header: ARH2HIJB.pls 120.2 2005/06/18 04:28:22 jhuang noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy hz_hierarchy_v2pub.related_nodes_list_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).related_node_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).related_node_table_name := a1(indx);
          t(ddindx).related_node_object_type := a2(indx);
          t(ddindx).level_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).top_parent_flag := a4(indx);
          t(ddindx).leaf_child_flag := a5(indx);
          t(ddindx).effective_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).effective_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).relationship_id := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t hz_hierarchy_v2pub.related_nodes_list_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).related_node_id);
          a1(indx) := t(ddindx).related_node_table_name;
          a2(indx) := t(ddindx).related_node_object_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).level_number);
          a4(indx) := t(ddindx).top_parent_flag;
          a5(indx) := t(ddindx).leaf_child_flag;
          a6(indx) := t(ddindx).effective_start_date;
          a7(indx) := t(ddindx).effective_end_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure is_top_parent_1(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_effective_date  date
    , x_result out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_effective_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    hz_hierarchy_v2pub.is_top_parent(p_init_msg_list,
      p_hierarchy_type,
      p_parent_id,
      p_parent_table_name,
      p_parent_object_type,
      ddp_effective_date,
      x_result,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure check_parent_child_2(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_child_id  NUMBER
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_effective_date  date
    , x_result out nocopy  VARCHAR2
    , x_level_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_effective_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);






    -- here's the delegated call to the old PL/SQL routine
    hz_hierarchy_v2pub.check_parent_child(p_init_msg_list,
      p_hierarchy_type,
      p_parent_id,
      p_parent_table_name,
      p_parent_object_type,
      p_child_id,
      p_child_table_name,
      p_child_object_type,
      ddp_effective_date,
      x_result,
      x_level_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any













  end;

  procedure get_parent_nodes_3(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_child_id  NUMBER
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_include_node  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_effective_date date;
    ddx_related_nodes_list hz_hierarchy_v2pub.related_nodes_list_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);






    -- here's the delegated call to the old PL/SQL routine
    hz_hierarchy_v2pub.get_parent_nodes(p_init_msg_list,
      p_hierarchy_type,
      p_child_id,
      p_child_table_name,
      p_child_object_type,
      p_parent_table_name,
      p_parent_object_type,
      p_include_node,
      ddp_effective_date,
      p_no_of_records,
      ddx_related_nodes_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










    hz_hierarchy_v2pub_jw.rosetta_table_copy_out_p1(ddx_related_nodes_list, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      );



  end;

  procedure get_child_nodes_4(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_include_node  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_effective_date date;
    ddx_related_nodes_list hz_hierarchy_v2pub.related_nodes_list_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);






    -- here's the delegated call to the old PL/SQL routine
    hz_hierarchy_v2pub.get_child_nodes(p_init_msg_list,
      p_hierarchy_type,
      p_parent_id,
      p_parent_table_name,
      p_parent_object_type,
      p_child_table_name,
      p_child_object_type,
      p_include_node,
      ddp_effective_date,
      p_no_of_records,
      ddx_related_nodes_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










    hz_hierarchy_v2pub_jw.rosetta_table_copy_out_p1(ddx_related_nodes_list, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      );



  end;

  procedure get_top_parent_nodes_5(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_effective_date date;
    ddx_top_parent_list hz_hierarchy_v2pub.related_nodes_list_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);






    -- here's the delegated call to the old PL/SQL routine
    hz_hierarchy_v2pub.get_top_parent_nodes(p_init_msg_list,
      p_hierarchy_type,
      p_parent_table_name,
      p_parent_object_type,
      ddp_effective_date,
      p_no_of_records,
      ddx_top_parent_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






    hz_hierarchy_v2pub_jw.rosetta_table_copy_out_p1(ddx_top_parent_list, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );



  end;

end hz_hierarchy_v2pub_jw;

/
