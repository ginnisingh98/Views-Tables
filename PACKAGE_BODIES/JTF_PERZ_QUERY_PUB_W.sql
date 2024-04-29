--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_QUERY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_QUERY_PUB_W" as
  /* $Header: jtfzwpqb.pls 120.2 2005/11/02 23:48:52 skothe ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_parameter_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).query_param_id := a0(indx);
          t(ddindx).query_id := a1(indx);
          t(ddindx).parameter_name := a2(indx);
          t(ddindx).parameter_type := a3(indx);
          t(ddindx).parameter_value := a4(indx);
          t(ddindx).parameter_condition := a5(indx);
          t(ddindx).parameter_sequence := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_perz_query_pub.query_parameter_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).query_param_id;
          a1(indx) := t(ddindx).query_id;
          a2(indx) := t(ddindx).parameter_name;
          a3(indx) := t(ddindx).parameter_type;
          a4(indx) := t(ddindx).parameter_value;
          a5(indx) := t(ddindx).parameter_condition;
          a6(indx) := t(ddindx).parameter_sequence;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).query_id := a0(indx);
          t(ddindx).profile_id := a1(indx);
          t(ddindx).application_id := a2(indx);
          t(ddindx).query_name := a3(indx);
          t(ddindx).query_type := a4(indx);
          t(ddindx).query_description := a5(indx);
          t(ddindx).query_data_source := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jtf_perz_query_pub.query_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).query_id;
          a1(indx) := t(ddindx).profile_id;
          a2(indx) := t(ddindx).application_id;
          a3(indx) := t(ddindx).query_name;
          a4(indx) := t(ddindx).query_type;
          a5(indx) := t(ddindx).query_description;
          a6(indx) := t(ddindx).query_data_source;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_order_by_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
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
          t(ddindx).query_order_by_id := a0(indx);
          t(ddindx).query_id := a1(indx);
          t(ddindx).parameter_name := a2(indx);
          t(ddindx).acnd_dcnd_flag := a3(indx);
          t(ddindx).parameter_sequence := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t jtf_perz_query_pub.query_order_by_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).query_order_by_id;
          a1(indx) := t(ddindx).query_id;
          a2(indx) := t(ddindx).parameter_name;
          a3(indx) := t(ddindx).acnd_dcnd_flag;
          a4(indx) := t(ddindx).parameter_sequence;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure save_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_100
    , p13_a3 JTF_VARCHAR2_TABLE_100
    , p13_a4 JTF_VARCHAR2_TABLE_300
    , p13_a5 JTF_VARCHAR2_TABLE_100
    , p13_a6 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_VARCHAR2_TABLE_100
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p15_a0  NUMBER
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  VARCHAR2
    , p15_a4  VARCHAR2
    , p15_a5  VARCHAR2
    , p15_a6  VARCHAR2
    , p15_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_profile_attrib jtf_perz_profile_pub.profile_attrib_tbl_type;
    ddp_query_param_tbl jtf_perz_query_pub.query_parameter_tbl_type;
    ddp_query_order_by_tbl jtf_perz_query_pub.query_order_by_tbl_type;
    ddp_query_raw_sql_rec jtf_perz_query_pub.query_raw_sql_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_perz_profile_pub_w.rosetta_table_copy_in_p1(ddp_profile_attrib, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      );






    jtf_perz_query_pub_w.rosetta_table_copy_in_p1(ddp_query_param_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      );

    jtf_perz_query_pub_w.rosetta_table_copy_in_p6(ddp_query_order_by_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      );

    ddp_query_raw_sql_rec.query_raw_sql_id := p15_a0;
    ddp_query_raw_sql_rec.query_id := p15_a1;
    ddp_query_raw_sql_rec.select_string := p15_a2;
    ddp_query_raw_sql_rec.from_string := p15_a3;
    ddp_query_raw_sql_rec.where_string := p15_a4;
    ddp_query_raw_sql_rec.order_by_string := p15_a5;
    ddp_query_raw_sql_rec.group_by_string := p15_a6;
    ddp_query_raw_sql_rec.having_string := p15_a7;





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_query_pub.save_perz_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_profile_type,
      ddp_profile_attrib,
      p_query_id,
      p_query_name,
      p_query_type,
      p_query_desc,
      p_query_data_source,
      ddp_query_param_tbl,
      ddp_query_order_by_tbl,
      ddp_query_raw_sql_rec,
      x_query_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT  or IN-OUT args, if any



















  end;

  procedure create_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_300
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_NUMBER_TABLE
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_NUMBER_TABLE
    , p13_a0  NUMBER
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  VARCHAR2
    , p13_a4  VARCHAR2
    , p13_a5  VARCHAR2
    , p13_a6  VARCHAR2
    , p13_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_query_param_tbl jtf_perz_query_pub.query_parameter_tbl_type;
    ddp_query_order_by_tbl jtf_perz_query_pub.query_order_by_tbl_type;
    ddp_query_raw_sql_rec jtf_perz_query_pub.query_raw_sql_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    jtf_perz_query_pub_w.rosetta_table_copy_in_p1(ddp_query_param_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      );

    jtf_perz_query_pub_w.rosetta_table_copy_in_p6(ddp_query_order_by_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      );

    ddp_query_raw_sql_rec.query_raw_sql_id := p13_a0;
    ddp_query_raw_sql_rec.query_id := p13_a1;
    ddp_query_raw_sql_rec.select_string := p13_a2;
    ddp_query_raw_sql_rec.from_string := p13_a3;
    ddp_query_raw_sql_rec.where_string := p13_a4;
    ddp_query_raw_sql_rec.order_by_string := p13_a5;
    ddp_query_raw_sql_rec.group_by_string := p13_a6;
    ddp_query_raw_sql_rec.having_string := p13_a7;





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_query_pub.create_perz_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_query_id,
      p_query_name,
      p_query_type,
      p_query_desc,
      p_query_data_source,
      ddp_query_param_tbl,
      ddp_query_order_by_tbl,
      ddp_query_raw_sql_rec,
      x_query_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT  or IN-OUT args, if any

















  end;

  procedure get_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_query_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_type OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_desc OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_data_source OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p13_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p13_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p13_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p13_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a6 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p14_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p14_a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p15_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p15_a1 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p15_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a4 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a5 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a6 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a7 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddx_query_param_tbl jtf_perz_query_pub.query_parameter_tbl_type;
    ddx_query_order_by_tbl jtf_perz_query_pub.query_order_by_tbl_type;
    ddx_query_raw_sql_rec jtf_perz_query_pub.query_raw_sql_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_query_pub.get_perz_query(p_api_version_number,
      p_init_msg_list,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_query_id,
      p_query_name,
      p_query_type,
      x_query_id,
      x_query_name,
      x_query_type,
      x_query_desc,
      x_query_data_source,
      ddx_query_param_tbl,
      ddx_query_order_by_tbl,
      ddx_query_raw_sql_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT  or IN-OUT args, if any













    jtf_perz_query_pub_w.rosetta_table_copy_out_p1(ddx_query_param_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      );

    jtf_perz_query_pub_w.rosetta_table_copy_out_p6(ddx_query_order_by_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      );

    p15_a0 := ddx_query_raw_sql_rec.query_raw_sql_id;
    p15_a1 := ddx_query_raw_sql_rec.query_id;
    p15_a2 := ddx_query_raw_sql_rec.select_string;
    p15_a3 := ddx_query_raw_sql_rec.from_string;
    p15_a4 := ddx_query_raw_sql_rec.where_string;
    p15_a5 := ddx_query_raw_sql_rec.order_by_string;
    p15_a6 := ddx_query_raw_sql_rec.group_by_string;
    p15_a7 := ddx_query_raw_sql_rec.having_string;



  end;

  procedure get_perz_query_summary(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddx_query_out_tbl jtf_perz_query_pub.query_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_query_pub.get_perz_query_summary(p_api_version_number,
      p_init_msg_list,
      p_application_id,
      p_profile_id,
      p_profile_name,
      p_query_id,
      p_query_name,
      p_query_type,
      ddx_query_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT  or IN-OUT args, if any








    jtf_perz_query_pub_w.rosetta_table_copy_out_p4(ddx_query_out_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      );



  end;

  procedure update_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_300
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , p12_a0  NUMBER
    , p12_a1  NUMBER
    , p12_a2  VARCHAR2
    , p12_a3  VARCHAR2
    , p12_a4  VARCHAR2
    , p12_a5  VARCHAR2
    , p12_a6  VARCHAR2
    , p12_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_query_param_tbl jtf_perz_query_pub.query_parameter_tbl_type;
    ddp_query_order_by_tbl jtf_perz_query_pub.query_order_by_tbl_type;
    ddp_query_raw_sql_rec jtf_perz_query_pub.query_raw_sql_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    jtf_perz_query_pub_w.rosetta_table_copy_in_p1(ddp_query_param_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      );

    jtf_perz_query_pub_w.rosetta_table_copy_in_p6(ddp_query_order_by_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      );

    ddp_query_raw_sql_rec.query_raw_sql_id := p12_a0;
    ddp_query_raw_sql_rec.query_id := p12_a1;
    ddp_query_raw_sql_rec.select_string := p12_a2;
    ddp_query_raw_sql_rec.from_string := p12_a3;
    ddp_query_raw_sql_rec.where_string := p12_a4;
    ddp_query_raw_sql_rec.order_by_string := p12_a5;
    ddp_query_raw_sql_rec.group_by_string := p12_a6;
    ddp_query_raw_sql_rec.having_string := p12_a7;





    -- here's the delegated call to the old PL/SQL routine
    jtf_perz_query_pub.update_perz_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_application_id,
      p_profile_id,
      p_query_id,
      p_query_name,
      p_query_type,
      p_query_desc,
      p_query_data_source,
      ddp_query_param_tbl,
      ddp_query_order_by_tbl,
      ddp_query_raw_sql_rec,
      x_query_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT  or IN-OUT args, if any
















  end;

end jtf_perz_query_pub_w;

/
