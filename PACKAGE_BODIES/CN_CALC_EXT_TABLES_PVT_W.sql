--------------------------------------------------------
--  DDL for Package Body CN_CALC_EXT_TABLES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_EXT_TABLES_PVT_W" as
  /* $Header: cnwexttb.pls 115.5 2003/01/31 08:44:27 hithanki ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_calc_ext_table(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_calc_ext_table_id out nocopy  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  NUMBER
    , p9_a3  NUMBER
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  NUMBER
  )

  as
    ddp_calc_ext_table_rec cn_calc_ext_tables_pvt.calc_ext_table_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_calc_ext_table_rec.calc_ext_table_id := p9_a0;
    ddp_calc_ext_table_rec.name := p9_a1;
    ddp_calc_ext_table_rec.internal_table_id := p9_a2;
    ddp_calc_ext_table_rec.external_table_id := p9_a3;
    ddp_calc_ext_table_rec.used_flag := p9_a4;
    ddp_calc_ext_table_rec.description := p9_a5;
    ddp_calc_ext_table_rec.schema := p9_a6;
    ddp_calc_ext_table_rec.external_table_name := p9_a7;
    ddp_calc_ext_table_rec.alias := p9_a8;
    ddp_calc_ext_table_rec.object_version_number := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    cn_calc_ext_tables_pvt.create_calc_ext_table(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      x_calc_ext_table_id,
      ddp_calc_ext_table_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_calc_ext_table(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  NUMBER
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  NUMBER
  )

  as
    ddp_old_calc_ext_table_rec cn_calc_ext_tables_pvt.calc_ext_table_rec_type;
    ddp_calc_ext_table_rec cn_calc_ext_tables_pvt.calc_ext_table_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_old_calc_ext_table_rec.calc_ext_table_id := p8_a0;
    ddp_old_calc_ext_table_rec.name := p8_a1;
    ddp_old_calc_ext_table_rec.internal_table_id := p8_a2;
    ddp_old_calc_ext_table_rec.external_table_id := p8_a3;
    ddp_old_calc_ext_table_rec.used_flag := p8_a4;
    ddp_old_calc_ext_table_rec.description := p8_a5;
    ddp_old_calc_ext_table_rec.schema := p8_a6;
    ddp_old_calc_ext_table_rec.external_table_name := p8_a7;
    ddp_old_calc_ext_table_rec.alias := p8_a8;
    ddp_old_calc_ext_table_rec.object_version_number := p8_a9;

    ddp_calc_ext_table_rec.calc_ext_table_id := p9_a0;
    ddp_calc_ext_table_rec.name := p9_a1;
    ddp_calc_ext_table_rec.internal_table_id := p9_a2;
    ddp_calc_ext_table_rec.external_table_id := p9_a3;
    ddp_calc_ext_table_rec.used_flag := p9_a4;
    ddp_calc_ext_table_rec.description := p9_a5;
    ddp_calc_ext_table_rec.schema := p9_a6;
    ddp_calc_ext_table_rec.external_table_name := p9_a7;
    ddp_calc_ext_table_rec.alias := p9_a8;
    ddp_calc_ext_table_rec.object_version_number := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    cn_calc_ext_tables_pvt.update_calc_ext_table(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_old_calc_ext_table_rec,
      ddp_calc_ext_table_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_old_calc_ext_table_rec.calc_ext_table_id;
    p8_a1 := ddp_old_calc_ext_table_rec.name;
    p8_a2 := ddp_old_calc_ext_table_rec.internal_table_id;
    p8_a3 := ddp_old_calc_ext_table_rec.external_table_id;
    p8_a4 := ddp_old_calc_ext_table_rec.used_flag;
    p8_a5 := ddp_old_calc_ext_table_rec.description;
    p8_a6 := ddp_old_calc_ext_table_rec.schema;
    p8_a7 := ddp_old_calc_ext_table_rec.external_table_name;
    p8_a8 := ddp_old_calc_ext_table_rec.alias;
    p8_a9 := ddp_old_calc_ext_table_rec.object_version_number;

    p9_a0 := ddp_calc_ext_table_rec.calc_ext_table_id;
    p9_a1 := ddp_calc_ext_table_rec.name;
    p9_a2 := ddp_calc_ext_table_rec.internal_table_id;
    p9_a3 := ddp_calc_ext_table_rec.external_table_id;
    p9_a4 := ddp_calc_ext_table_rec.used_flag;
    p9_a5 := ddp_calc_ext_table_rec.description;
    p9_a6 := ddp_calc_ext_table_rec.schema;
    p9_a7 := ddp_calc_ext_table_rec.external_table_name;
    p9_a8 := ddp_calc_ext_table_rec.alias;
    p9_a9 := ddp_calc_ext_table_rec.object_version_number;
  end;

end cn_calc_ext_tables_pvt_w;

/
