--------------------------------------------------------
--  DDL for Package Body AMS_IMPORT_XML_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORT_XML_PVT_W" as
  /* $Header: amswmixb.pls 120.1 2006/01/12 22:11 rmbhanda noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy ams_import_xml_pvt.xml_element_key_set_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t ams_import_xml_pvt.xml_element_key_set_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy ams_import_xml_pvt.xml_source_column_set_type, a0 JTF_VARCHAR2_TABLE_200) as
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
  procedure rosetta_table_copy_out_p1(t ams_import_xml_pvt.xml_source_column_set_type, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
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

  procedure rosetta_table_copy_in_p2(t out nocopy ams_import_xml_pvt.xml_target_column_set_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  procedure rosetta_table_copy_out_p2(t ams_import_xml_pvt.xml_target_column_set_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_import_xml_pvt.xml_element_set_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).imp_xml_element_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).imp_xml_document_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).order_initial := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).order_final := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).column_name := a10(indx);
          t(ddindx).data := a11(indx);
          t(ddindx).num_attr := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).data_type := a13(indx);
          t(ddindx).load_status := a14(indx);
          t(ddindx).error_text := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_import_xml_pvt.xml_element_set_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_2000();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_2000();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).imp_xml_element_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).imp_xml_document_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).order_initial);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).order_final);
          a10(indx) := t(ddindx).column_name;
          a11(indx) := t(ddindx).data;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).num_attr);
          a13(indx) := t(ddindx).data_type;
          a14(indx) := t(ddindx).load_status;
          a15(indx) := t(ddindx).error_text;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure is_leaf_node(p_imp_xml_element_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ams_import_xml_pvt.is_leaf_node(p_imp_xml_element_id,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;


  end;

  procedure get_root_node(p_import_list_header_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_node_rec ams_imp_xml_elements%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_root_node(p_import_list_header_id,
      ddx_node_rec,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_element_id);
    p1_a1 := ddx_node_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_node_rec.last_updated_by);
    p1_a3 := ddx_node_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_node_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_node_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_node_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_document_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_node_rec.order_initial);
    p1_a9 := rosetta_g_miss_num_map(ddx_node_rec.order_final);
    p1_a10 := ddx_node_rec.column_name;
    p1_a11 := ddx_node_rec.data;
    p1_a12 := rosetta_g_miss_num_map(ddx_node_rec.num_attr);
    p1_a13 := ddx_node_rec.data_type;
    p1_a14 := ddx_node_rec.load_status;
    p1_a15 := ddx_node_rec.error_text;


  end;

  procedure get_parent_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_node_rec ams_imp_xml_elements%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_parent_node(p_imp_xml_element_id,
      ddx_node_rec,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_element_id);
    p1_a1 := ddx_node_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_node_rec.last_updated_by);
    p1_a3 := ddx_node_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_node_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_node_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_node_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_document_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_node_rec.order_initial);
    p1_a9 := rosetta_g_miss_num_map(ddx_node_rec.order_final);
    p1_a10 := ddx_node_rec.column_name;
    p1_a11 := ddx_node_rec.data;
    p1_a12 := rosetta_g_miss_num_map(ddx_node_rec.num_attr);
    p1_a13 := ddx_node_rec.data_type;
    p1_a14 := ddx_node_rec.load_status;
    p1_a15 := ddx_node_rec.error_text;


  end;

  procedure get_first_child_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_node_rec ams_imp_xml_elements%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_first_child_node(p_imp_xml_element_id,
      ddx_node_rec,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_element_id);
    p1_a1 := ddx_node_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_node_rec.last_updated_by);
    p1_a3 := ddx_node_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_node_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_node_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_node_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_document_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_node_rec.order_initial);
    p1_a9 := rosetta_g_miss_num_map(ddx_node_rec.order_final);
    p1_a10 := ddx_node_rec.column_name;
    p1_a11 := ddx_node_rec.data;
    p1_a12 := rosetta_g_miss_num_map(ddx_node_rec.num_attr);
    p1_a13 := ddx_node_rec.data_type;
    p1_a14 := ddx_node_rec.load_status;
    p1_a15 := ddx_node_rec.error_text;


  end;

  procedure get_next_sibling_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_node_rec ams_imp_xml_elements%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_next_sibling_node(p_imp_xml_element_id,
      ddx_node_rec,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_element_id);
    p1_a1 := ddx_node_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_node_rec.last_updated_by);
    p1_a3 := ddx_node_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_node_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_node_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_node_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_node_rec.imp_xml_document_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_node_rec.order_initial);
    p1_a9 := rosetta_g_miss_num_map(ddx_node_rec.order_final);
    p1_a10 := ddx_node_rec.column_name;
    p1_a11 := ddx_node_rec.data;
    p1_a12 := rosetta_g_miss_num_map(ddx_node_rec.num_attr);
    p1_a13 := ddx_node_rec.data_type;
    p1_a14 := ddx_node_rec.load_status;
    p1_a15 := ddx_node_rec.error_text;


  end;

  procedure get_children_nodes(p_imp_xml_element_id  NUMBER
    , x_child_ids out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_child_ids ams_import_xml_pvt.xml_element_key_set_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_children_nodes(p_imp_xml_element_id,
      ddx_child_ids,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    ams_import_xml_pvt_w.rosetta_table_copy_out_p0(ddx_child_ids, x_child_ids);


  end;

  procedure get_children_nodes(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_DATE_TABLE
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_NUMBER_TABLE
    , p1_a5 out nocopy JTF_NUMBER_TABLE
    , p1_a6 out nocopy JTF_NUMBER_TABLE
    , p1_a7 out nocopy JTF_NUMBER_TABLE
    , p1_a8 out nocopy JTF_NUMBER_TABLE
    , p1_a9 out nocopy JTF_NUMBER_TABLE
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a12 out nocopy JTF_NUMBER_TABLE
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_child_set ams_import_xml_pvt.xml_element_set_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ams_import_xml_pvt.get_children_nodes(p_imp_xml_element_id,
      ddx_child_set,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    ams_import_xml_pvt_w.rosetta_table_copy_out_p3(ddx_child_set, p1_a0
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
      );


  end;

end ams_import_xml_pvt_w;

/
