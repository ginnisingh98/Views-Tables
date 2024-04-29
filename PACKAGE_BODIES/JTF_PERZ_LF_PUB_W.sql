--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_LF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_LF_PUB_W" as
  /* $Header: jtfzwlfb.pls 120.2 2005/11/02 23:01:03 skothe ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.attrib_rec_tbl_type, a0 JTF_NUMBER_TABLE
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
          t(ddindx).attribute_id := a0(indx);
          t(ddindx).attribute_name := a1(indx);
          t(ddindx).attribute_type := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_perz_lf_pub.attrib_rec_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).attribute_id;
          a1(indx) := t(ddindx).attribute_name;
          a2(indx) := t(ddindx).attribute_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.attrib_value_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_id := a0(indx);
          t(ddindx).attribute_name := a1(indx);
          t(ddindx).attribute_type := a2(indx);
          t(ddindx).attribute_value := a3(indx);
          t(ddindx).priority := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jtf_perz_lf_pub.attrib_value_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).attribute_id;
          a1(indx) := t(ddindx).attribute_name;
          a2(indx) := t(ddindx).attribute_type;
          a3(indx) := t(ddindx).attribute_value;
          a4(indx) := t(ddindx).priority;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.lf_object_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_id := a0(indx);
          t(ddindx).object_id := a1(indx);
          t(ddindx).application_id := a2(indx);
          t(ddindx).object_name := a3(indx);
          t(ddindx).object_description := a4(indx);
          t(ddindx).object_type_id := a5(indx);
          t(ddindx).object_type := a6(indx);
          t(ddindx).attribute_id := a7(indx);
          t(ddindx).attribute_name := a8(indx);
          t(ddindx).attribute_type := a9(indx);
          t(ddindx).attribute_value := a10(indx);
          t(ddindx).active_flag := a11(indx);
          t(ddindx).priority := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_perz_lf_pub.lf_object_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).parent_id;
          a1(indx) := t(ddindx).object_id;
          a2(indx) := t(ddindx).application_id;
          a3(indx) := t(ddindx).object_name;
          a4(indx) := t(ddindx).object_description;
          a5(indx) := t(ddindx).object_type_id;
          a6(indx) := t(ddindx).object_type;
          a7(indx) := t(ddindx).attribute_id;
          a8(indx) := t(ddindx).attribute_name;
          a9(indx) := t(ddindx).attribute_type;
          a10(indx) := t(ddindx).attribute_value;
          a11(indx) := t(ddindx).active_flag;
          a12(indx) := t(ddindx).priority;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure save_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_object_description  VARCHAR2
    , p_active_flag  VARCHAR2
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_VARCHAR2_TABLE_100
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddp_profile_attrib_tbl jtf_perz_profile_pub.profile_attrib_tbl_type;
    ddp_attrib_value_tbl jtf_perz_lf_pub.attrib_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_perz_profile_pub_w.rosetta_table_copy_in_p1(ddp_profile_attrib_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      );









    jtf_perz_lf_pub_w.rosetta_table_copy_in_p4(ddp_attrib_value_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.save_lf_object(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_profile_id,
      p_profile_name,
      p_profile_type,
      ddp_profile_attrib_tbl,
      p_application_id,
      p_parent_id,
      p_object_type_id,
      p_object_type,
      p_object_id,
      p_object_name,
      p_object_description,
      p_active_flag,
      ddp_attrib_value_tbl,
      x_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any



















  end;

  procedure save_lf_object_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_type_desc  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , x_object_type_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddp_attrib_rec_tbl jtf_perz_lf_pub.attrib_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_perz_lf_pub_w.rosetta_table_copy_in_p1(ddp_attrib_rec_tbl, p6_a0
      , p6_a1
      , p6_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.save_lf_object_type(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_type_id,
      p_object_type,
      p_object_type_desc,
      ddp_attrib_rec_tbl,
      x_object_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any










  end;

  procedure create_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddp_attrib_value_tbl jtf_perz_lf_pub.attrib_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    jtf_perz_lf_pub_w.rosetta_table_copy_in_p4(ddp_attrib_value_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.create_lf_object(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_profile_id,
      p_profile_name,
      p_application_id,
      p_parent_id,
      p_object_id,
      p_object_name,
      p_object_type_id,
      p_object_type,
      ddp_attrib_value_tbl,
      x_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any















  end;

  procedure get_lf_object_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_object_type  VARCHAR
    , p_object_type_id  NUMBER
    , x_object_type_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_object_type_desc OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddx_attrib_rec_tbl jtf_perz_lf_pub.attrib_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.get_lf_object_type(p_api_version_number,
      p_init_msg_list,
      p_object_type,
      p_object_type_id,
      x_object_type_id,
      x_object_type_desc,
      ddx_attrib_rec_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_perz_lf_pub_w.rosetta_table_copy_out_p1(ddx_attrib_rec_tbl, p6_a0
      , p6_a1
      , p6_a2
      );



  end;

  procedure get_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_priority  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_object_id  NUMBER
    , p_object_name  VARCHAR
    , p_obj_active_flag  VARCHAR2
    , p_get_children_flag  VARCHAR2
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p10_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddx_object_tbl jtf_perz_lf_pub.lf_object_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.get_lf_object(p_api_version_number,
      p_init_msg_list,
      p_application_id,
      p_priority,
      p_profile_id,
      p_profile_name,
      p_object_id,
      p_object_name,
      p_obj_active_flag,
      p_get_children_flag,
      ddx_object_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any










    jtf_perz_lf_pub_w.rosetta_table_copy_out_p7(ddx_object_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );



  end;

  procedure update_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_active_flag  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddp_attrib_value_tbl jtf_perz_lf_pub.attrib_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    jtf_perz_lf_pub_w.rosetta_table_copy_in_p4(ddp_attrib_value_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_lf_pub.update_lf_object(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_profile_id,
      p_profile_name,
      p_application_id,
      p_parent_id,
      p_object_id,
      p_object_name,
      p_active_flag,
      p_object_type_id,
      p_object_type,
      ddp_attrib_value_tbl,
      x_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any
















  end;

end jtf_perz_lf_pub_w;

/
