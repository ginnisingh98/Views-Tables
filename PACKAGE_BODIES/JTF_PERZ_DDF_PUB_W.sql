--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_DDF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_DDF_PUB_W" as
  /* $Header: jtfzwddb.pls 120.2 2005/11/02 23:00:25 skothe ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_ddf_pub.ddf_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
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
          t(ddindx).perz_ddf_id := a0(indx);
          t(ddindx).perz_ddf_context := a1(indx);
          t(ddindx).profile_id := a2(indx);
          t(ddindx).application_id := a3(indx);
          t(ddindx).gui_object_name := a4(indx);
          t(ddindx).gui_object_id := a5(indx);
          t(ddindx).ddf_value := a6(indx);
          t(ddindx).ddf_value_type := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_perz_ddf_pub.ddf_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).perz_ddf_id;
          a1(indx) := t(ddindx).perz_ddf_context;
          a2(indx) := t(ddindx).profile_id;
          a3(indx) := t(ddindx).application_id;
          a4(indx) := t(ddindx).gui_object_name;
          a5(indx) := t(ddindx).gui_object_id;
          a6(indx) := t(ddindx).ddf_value;
          a7(indx) := t(ddindx).ddf_value_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure save_data_default(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p_perz_ddf_id  NUMBER
    , p_perz_ddf_context  VARCHAR2
    , p_gui_object_name  VARCHAR2
    , p_gui_object_id  NUMBER
    , p_ddf_value  VARCHAR2
    , p_ddf_value_type  VARCHAR2
    , x_perz_ddf_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddp_profile_attrib jtf_perz_profile_pub.profile_attrib_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_perz_profile_pub_w.rosetta_table_copy_in_p1(ddp_profile_attrib, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      );











    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_ddf_pub.save_data_default(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_profile_type,
      ddp_profile_attrib,
      p_perz_ddf_id,
      p_perz_ddf_context,
      p_gui_object_name,
      p_gui_object_id,
      p_ddf_value,
      p_ddf_value_type,
      x_perz_ddf_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any

















  end;

  procedure get_data_default(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_perz_ddf_id  NUMBER
    , p_perz_ddf_context  VARCHAR2
    , p_gui_object_name  VARCHAR2
    , p_gui_object_id  NUMBER
    , p_ddf_value  VARCHAR2
    , p_ddf_value_type  VARCHAR2
    , p11_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddx_ddf_out_tbl jtf_perz_ddf_pub.ddf_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_ddf_pub.get_data_default(p_api_version_number,
      p_init_msg_list,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_perz_ddf_id,
      p_perz_ddf_context,
      p_gui_object_name,
      p_gui_object_id,
      p_ddf_value,
      p_ddf_value_type,
      ddx_ddf_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT  or IN-OUT args, if any











    jtf_perz_ddf_pub_w.rosetta_table_copy_out_p1(ddx_ddf_out_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      );



  end;

end jtf_perz_ddf_pub_w;

/
