--------------------------------------------------------
--  DDL for Package Body OZF_DENORM_QUERIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DENORM_QUERIES_PVT_W" as
  /* $Header: ozfwofdb.pls 120.0 2005/06/01 02:50:08 appldev noship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ozf_denorm_queries_pvt.stringarray, a0 JTF_VARCHAR2_TABLE_4000) as
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
  procedure rosetta_table_copy_out_p1(t ozf_denorm_queries_pvt.stringarray, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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

  procedure create_denorm_queries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_denorm_query_id OUT NOCOPY  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p4_a0);
    ddp_denorm_queries_rec.query_for := p4_a1;
    ddp_denorm_queries_rec.context := p4_a2;
    ddp_denorm_queries_rec.attribute := p4_a3;
    ddp_denorm_queries_rec.sql_statement := p4_a4;
    ddp_denorm_queries_rec.active_flag := p4_a5;
    ddp_denorm_queries_rec.condition_name_column := p4_a6;
    ddp_denorm_queries_rec.condition_id_column := p4_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p4_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p4_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p4_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p4_a14);





    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.create_denorm_queries(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_denorm_queries_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_denorm_query_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_denorm_queries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p4_a0);
    ddp_denorm_queries_rec.query_for := p4_a1;
    ddp_denorm_queries_rec.context := p4_a2;
    ddp_denorm_queries_rec.attribute := p4_a3;
    ddp_denorm_queries_rec.sql_statement := p4_a4;
    ddp_denorm_queries_rec.active_flag := p4_a5;
    ddp_denorm_queries_rec.condition_name_column := p4_a6;
    ddp_denorm_queries_rec.condition_id_column := p4_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p4_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p4_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p4_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p4_a14);




    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.update_denorm_queries(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_denorm_queries_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_denorm_queries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p4_a0);
    ddp_denorm_queries_rec.query_for := p4_a1;
    ddp_denorm_queries_rec.context := p4_a2;
    ddp_denorm_queries_rec.attribute := p4_a3;
    ddp_denorm_queries_rec.sql_statement := p4_a4;
    ddp_denorm_queries_rec.active_flag := p4_a5;
    ddp_denorm_queries_rec.condition_name_column := p4_a6;
    ddp_denorm_queries_rec.condition_id_column := p4_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p4_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p4_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p4_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p4_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p4_a14);




    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.validate_denorm_queries(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_denorm_queries_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_denorm_queries_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p0_a0);
    ddp_denorm_queries_rec.query_for := p0_a1;
    ddp_denorm_queries_rec.context := p0_a2;
    ddp_denorm_queries_rec.attribute := p0_a3;
    ddp_denorm_queries_rec.sql_statement := p0_a4;
    ddp_denorm_queries_rec.active_flag := p0_a5;
    ddp_denorm_queries_rec.condition_name_column := p0_a6;
    ddp_denorm_queries_rec.condition_id_column := p0_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p0_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p0_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p0_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p0_a14);



    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.check_denorm_queries_items(ddp_denorm_queries_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_denorm_queries_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p0_a0);
    ddp_denorm_queries_rec.query_for := p0_a1;
    ddp_denorm_queries_rec.context := p0_a2;
    ddp_denorm_queries_rec.attribute := p0_a3;
    ddp_denorm_queries_rec.sql_statement := p0_a4;
    ddp_denorm_queries_rec.active_flag := p0_a5;
    ddp_denorm_queries_rec.condition_name_column := p0_a6;
    ddp_denorm_queries_rec.condition_id_column := p0_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p0_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p0_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p0_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p0_a14);


    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.check_denorm_queries_record(ddp_denorm_queries_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure init_denorm_queries_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  VARCHAR2
    , p0_a2 OUT NOCOPY  VARCHAR2
    , p0_a3 OUT NOCOPY  VARCHAR2
    , p0_a4 OUT NOCOPY  VARCHAR2
    , p0_a5 OUT NOCOPY  VARCHAR2
    , p0_a6 OUT NOCOPY  VARCHAR2
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  DATE
    , p0_a9 OUT NOCOPY  NUMBER
    , p0_a10 OUT NOCOPY  DATE
    , p0_a11 OUT NOCOPY  NUMBER
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  NUMBER
  )
  as
    ddx_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.init_denorm_queries_rec(ddx_denorm_queries_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.denorm_query_id);
    p0_a1 := ddx_denorm_queries_rec.query_for;
    p0_a2 := ddx_denorm_queries_rec.context;
    p0_a3 := ddx_denorm_queries_rec.attribute;
    p0_a4 := ddx_denorm_queries_rec.sql_statement;
    p0_a5 := ddx_denorm_queries_rec.active_flag;
    p0_a6 := ddx_denorm_queries_rec.condition_name_column;
    p0_a7 := ddx_denorm_queries_rec.condition_id_column;
    p0_a8 := ddx_denorm_queries_rec.last_update_date;
    p0_a9 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.last_updated_by);
    p0_a10 := ddx_denorm_queries_rec.creation_date;
    p0_a11 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.created_by);
    p0_a12 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.last_update_login);
    p0_a13 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.object_version_number);
    p0_a14 := rosetta_g_miss_num_map(ddx_denorm_queries_rec.security_group_id);
  end;

  procedure complete_denorm_queries_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  VARCHAR2
    , p1_a2 OUT NOCOPY  VARCHAR2
    , p1_a3 OUT NOCOPY  VARCHAR2
    , p1_a4 OUT NOCOPY  VARCHAR2
    , p1_a5 OUT NOCOPY  VARCHAR2
    , p1_a6 OUT NOCOPY  VARCHAR2
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  DATE
    , p1_a9 OUT NOCOPY  NUMBER
    , p1_a10 OUT NOCOPY  DATE
    , p1_a11 OUT NOCOPY  NUMBER
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
  )
  as
    ddp_denorm_queries_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddx_complete_rec ozf_denorm_queries_pvt.denorm_queries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_denorm_queries_rec.denorm_query_id := rosetta_g_miss_num_map(p0_a0);
    ddp_denorm_queries_rec.query_for := p0_a1;
    ddp_denorm_queries_rec.context := p0_a2;
    ddp_denorm_queries_rec.attribute := p0_a3;
    ddp_denorm_queries_rec.sql_statement := p0_a4;
    ddp_denorm_queries_rec.active_flag := p0_a5;
    ddp_denorm_queries_rec.condition_name_column := p0_a6;
    ddp_denorm_queries_rec.condition_id_column := p0_a7;
    ddp_denorm_queries_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_denorm_queries_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_denorm_queries_rec.creation_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_denorm_queries_rec.created_by := rosetta_g_miss_num_map(p0_a11);
    ddp_denorm_queries_rec.last_update_login := rosetta_g_miss_num_map(p0_a12);
    ddp_denorm_queries_rec.object_version_number := rosetta_g_miss_num_map(p0_a13);
    ddp_denorm_queries_rec.security_group_id := rosetta_g_miss_num_map(p0_a14);


    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.complete_denorm_queries_rec(ddp_denorm_queries_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.denorm_query_id);
    p1_a1 := ddx_complete_rec.query_for;
    p1_a2 := ddx_complete_rec.context;
    p1_a3 := ddx_complete_rec.attribute;
    p1_a4 := ddx_complete_rec.sql_statement;
    p1_a5 := ddx_complete_rec.active_flag;
    p1_a6 := ddx_complete_rec.condition_name_column;
    p1_a7 := ddx_complete_rec.condition_id_column;
    p1_a8 := ddx_complete_rec.last_update_date;
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a10 := ddx_complete_rec.creation_date;
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a14 := rosetta_g_miss_num_map(ddx_complete_rec.security_group_id);
  end;

  procedure string_length_check(sqlst  VARCHAR2
    , sarray OUT NOCOPY JTF_VARCHAR2_TABLE_4000
  )
  as
    ddsarray ozf_denorm_queries_pvt.stringarray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ozf_denorm_queries_pvt.string_length_check(sqlst,
      ddsarray);

    -- copy data back from the local OUT or IN-OUT args, if any

    ozf_denorm_queries_pvt_w.rosetta_table_copy_out_p1(ddsarray, sarray);
  end;

end ozf_denorm_queries_pvt_w;

/
