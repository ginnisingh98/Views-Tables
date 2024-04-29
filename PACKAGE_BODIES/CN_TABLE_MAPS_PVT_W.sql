--------------------------------------------------------
--  DDL for Package Body CN_TABLE_MAPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TABLE_MAPS_PVT_W" as
  /* $Header: cnwtmapb.pls 120.2 2005/09/14 03:44 vensrini noship $ */
  procedure create_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_name  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  DATE
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  NUMBER
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , x_event_id_out out nocopy  NUMBER
  )

  as
    ddp_table_map_rec cn_table_maps_pvt.table_map_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_table_map_rec.table_map_id := p8_a0;
    ddp_table_map_rec.mapping_type := p8_a1;
    ddp_table_map_rec.source_table_id := p8_a2;
    ddp_table_map_rec.destination_table_id := p8_a3;
    ddp_table_map_rec.module_id := p8_a4;
    ddp_table_map_rec.last_update_date := p8_a5;
    ddp_table_map_rec.last_updated_by := p8_a6;
    ddp_table_map_rec.creation_date := p8_a7;
    ddp_table_map_rec.created_by := p8_a8;
    ddp_table_map_rec.last_update_login := p8_a9;
    ddp_table_map_rec.org_id := p8_a10;
    ddp_table_map_rec.source_tbl_pkcol_id := p8_a11;
    ddp_table_map_rec.delete_flag := p8_a12;
    ddp_table_map_rec.source_hdr_tbl_pkcol_id := p8_a13;
    ddp_table_map_rec.source_tbl_hdr_fkcol_id := p8_a14;
    ddp_table_map_rec.notify_where := p8_a15;
    ddp_table_map_rec.collect_where := p8_a16;


    -- here's the delegated call to the old PL/SQL routine
    cn_table_maps_pvt.create_map(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_name,
      ddp_table_map_rec,
      x_event_id_out);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_table_map_rec.table_map_id;
    p8_a1 := ddp_table_map_rec.mapping_type;
    p8_a2 := ddp_table_map_rec.source_table_id;
    p8_a3 := ddp_table_map_rec.destination_table_id;
    p8_a4 := ddp_table_map_rec.module_id;
    p8_a5 := ddp_table_map_rec.last_update_date;
    p8_a6 := ddp_table_map_rec.last_updated_by;
    p8_a7 := ddp_table_map_rec.creation_date;
    p8_a8 := ddp_table_map_rec.created_by;
    p8_a9 := ddp_table_map_rec.last_update_login;
    p8_a10 := ddp_table_map_rec.org_id;
    p8_a11 := ddp_table_map_rec.source_tbl_pkcol_id;
    p8_a12 := ddp_table_map_rec.delete_flag;
    p8_a13 := ddp_table_map_rec.source_hdr_tbl_pkcol_id;
    p8_a14 := ddp_table_map_rec.source_tbl_hdr_fkcol_id;
    p8_a15 := ddp_table_map_rec.notify_where;
    p8_a16 := ddp_table_map_rec.collect_where;

  end;

end cn_table_maps_pvt_w;

/
