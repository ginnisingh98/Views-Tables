--------------------------------------------------------
--  DDL for Package Body AHL_OSP_SERV_ITEM_RELS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_SERV_ITEM_RELS_PVT_W" as
  /* $Header: AHLWOSRB.pls 120.0 2005/07/06 15:54:20 jeli noship $ */
  procedure process_serv_itm_rels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  DATE
    , p5_a10 in out nocopy  DATE
    , p5_a11 in out nocopy  VARCHAR
    , p5_a12 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_inv_serv_item_rec ahl_osp_serv_item_rels_pvt.inv_serv_item_rels_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_inv_serv_item_rec.inv_ser_item_rel_id := p5_a0;
    ddp_x_inv_serv_item_rec.obj_ver_num := p5_a1;
    ddp_x_inv_serv_item_rec.inv_item_id := p5_a2;
    ddp_x_inv_serv_item_rec.inv_item_name := p5_a3;
    ddp_x_inv_serv_item_rec.inv_org_id := p5_a4;
    ddp_x_inv_serv_item_rec.inv_org_name := p5_a5;
    ddp_x_inv_serv_item_rec.service_item_id := p5_a6;
    ddp_x_inv_serv_item_rec.service_item_name := p5_a7;
    ddp_x_inv_serv_item_rec.rank := p5_a8;
    ddp_x_inv_serv_item_rec.active_start_date := p5_a9;
    ddp_x_inv_serv_item_rec.active_end_date := p5_a10;
    ddp_x_inv_serv_item_rec.for_all_org_flag := p5_a11;
    ddp_x_inv_serv_item_rec.operation_flag := p5_a12;




    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_serv_item_rels_pvt.process_serv_itm_rels(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_inv_serv_item_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_inv_serv_item_rec.inv_ser_item_rel_id;
    p5_a1 := ddp_x_inv_serv_item_rec.obj_ver_num;
    p5_a2 := ddp_x_inv_serv_item_rec.inv_item_id;
    p5_a3 := ddp_x_inv_serv_item_rec.inv_item_name;
    p5_a4 := ddp_x_inv_serv_item_rec.inv_org_id;
    p5_a5 := ddp_x_inv_serv_item_rec.inv_org_name;
    p5_a6 := ddp_x_inv_serv_item_rec.service_item_id;
    p5_a7 := ddp_x_inv_serv_item_rec.service_item_name;
    p5_a8 := ddp_x_inv_serv_item_rec.rank;
    p5_a9 := ddp_x_inv_serv_item_rec.active_start_date;
    p5_a10 := ddp_x_inv_serv_item_rec.active_end_date;
    p5_a11 := ddp_x_inv_serv_item_rec.for_all_org_flag;
    p5_a12 := ddp_x_inv_serv_item_rec.operation_flag;



  end;

end ahl_osp_serv_item_rels_pvt_w;

/
