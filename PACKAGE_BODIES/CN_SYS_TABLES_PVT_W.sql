--------------------------------------------------------
--  DDL for Package Body CN_SYS_TABLES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SYS_TABLES_PVT_W" as
  /* $Header: cnwsytbb.pls 120.3 2005/09/14 03:44:02 vensrini noship $ */
  procedure create_table(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_table_rec cn_sys_tables_pvt.table_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_table_rec.object_id := p4_a0;
    ddp_table_rec.name := p4_a1;
    ddp_table_rec.description := p4_a2;
    ddp_table_rec.status := p4_a3;
    ddp_table_rec.repository_id := p4_a4;
    ddp_table_rec.alias := p4_a5;
    ddp_table_rec.table_level := p4_a6;
    ddp_table_rec.table_type := p4_a7;
    ddp_table_rec.object_type := p4_a8;
    ddp_table_rec.schema := p4_a9;
    ddp_table_rec.calc_eligible_flag := p4_a10;
    ddp_table_rec.user_name := p4_a11;
    ddp_table_rec.org_id := p4_a12;
    ddp_table_rec.object_version_number := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    cn_sys_tables_pvt.create_table(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_table_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_table_rec.object_id;
    p4_a1 := ddp_table_rec.name;
    p4_a2 := ddp_table_rec.description;
    p4_a3 := ddp_table_rec.status;
    p4_a4 := ddp_table_rec.repository_id;
    p4_a5 := ddp_table_rec.alias;
    p4_a6 := ddp_table_rec.table_level;
    p4_a7 := ddp_table_rec.table_type;
    p4_a8 := ddp_table_rec.object_type;
    p4_a9 := ddp_table_rec.schema;
    p4_a10 := ddp_table_rec.calc_eligible_flag;
    p4_a11 := ddp_table_rec.user_name;
    p4_a12 := ddp_table_rec.org_id;
    p4_a13 := ddp_table_rec.object_version_number;



  end;

  procedure update_table(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_table_rec cn_sys_tables_pvt.table_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_table_rec.object_id := p4_a0;
    ddp_table_rec.name := p4_a1;
    ddp_table_rec.description := p4_a2;
    ddp_table_rec.status := p4_a3;
    ddp_table_rec.repository_id := p4_a4;
    ddp_table_rec.alias := p4_a5;
    ddp_table_rec.table_level := p4_a6;
    ddp_table_rec.table_type := p4_a7;
    ddp_table_rec.object_type := p4_a8;
    ddp_table_rec.schema := p4_a9;
    ddp_table_rec.calc_eligible_flag := p4_a10;
    ddp_table_rec.user_name := p4_a11;
    ddp_table_rec.org_id := p4_a12;
    ddp_table_rec.object_version_number := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    cn_sys_tables_pvt.update_table(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_table_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_table_rec.object_id;
    p4_a1 := ddp_table_rec.name;
    p4_a2 := ddp_table_rec.description;
    p4_a3 := ddp_table_rec.status;
    p4_a4 := ddp_table_rec.repository_id;
    p4_a5 := ddp_table_rec.alias;
    p4_a6 := ddp_table_rec.table_level;
    p4_a7 := ddp_table_rec.table_type;
    p4_a8 := ddp_table_rec.object_type;
    p4_a9 := ddp_table_rec.schema;
    p4_a10 := ddp_table_rec.calc_eligible_flag;
    p4_a11 := ddp_table_rec.user_name;
    p4_a12 := ddp_table_rec.org_id;
    p4_a13 := ddp_table_rec.object_version_number;



  end;

  procedure delete_table(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_table_rec cn_sys_tables_pvt.table_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_table_rec.object_id := p4_a0;
    ddp_table_rec.name := p4_a1;
    ddp_table_rec.description := p4_a2;
    ddp_table_rec.status := p4_a3;
    ddp_table_rec.repository_id := p4_a4;
    ddp_table_rec.alias := p4_a5;
    ddp_table_rec.table_level := p4_a6;
    ddp_table_rec.table_type := p4_a7;
    ddp_table_rec.object_type := p4_a8;
    ddp_table_rec.schema := p4_a9;
    ddp_table_rec.calc_eligible_flag := p4_a10;
    ddp_table_rec.user_name := p4_a11;
    ddp_table_rec.org_id := p4_a12;
    ddp_table_rec.object_version_number := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    cn_sys_tables_pvt.delete_table(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_table_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_column(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p4_a11  VARCHAR2
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_column_rec cn_sys_tables_pvt.column_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_column_rec.object_id := p4_a0;
    ddp_column_rec.user_name := p4_a1;
    ddp_column_rec.usage := p4_a2;
    ddp_column_rec.foreign_key := p4_a3;
    ddp_column_rec.dimension_id := p4_a4;
    ddp_column_rec.user_column_name := p4_a5;
    ddp_column_rec.classification_column := p4_a6;
    ddp_column_rec.column_datatype := p4_a7;
    ddp_column_rec.value_set_id := p4_a8;
    ddp_column_rec.primary_key := p4_a9;
    ddp_column_rec.position := p4_a10;
    ddp_column_rec.custom_call := p4_a11;
    ddp_column_rec.org_id := p4_a12;
    ddp_column_rec.object_version_number := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    cn_sys_tables_pvt.update_column(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_column_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure insert_column(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_schema_name  VARCHAR2
    , p_table_name  VARCHAR2
    , p_column_name  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_column_rec cn_sys_tables_pvt.column_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_column_rec.object_id := p7_a0;
    ddp_column_rec.user_name := p7_a1;
    ddp_column_rec.usage := p7_a2;
    ddp_column_rec.foreign_key := p7_a3;
    ddp_column_rec.dimension_id := p7_a4;
    ddp_column_rec.user_column_name := p7_a5;
    ddp_column_rec.classification_column := p7_a6;
    ddp_column_rec.column_datatype := p7_a7;
    ddp_column_rec.value_set_id := p7_a8;
    ddp_column_rec.primary_key := p7_a9;
    ddp_column_rec.position := p7_a10;
    ddp_column_rec.custom_call := p7_a11;
    ddp_column_rec.org_id := p7_a12;
    ddp_column_rec.object_version_number := p7_a13;




    -- here's the delegated call to the old PL/SQL routine
    cn_sys_tables_pvt.insert_column(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_schema_name,
      p_table_name,
      p_column_name,
      ddp_column_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end cn_sys_tables_pvt_w;

/
