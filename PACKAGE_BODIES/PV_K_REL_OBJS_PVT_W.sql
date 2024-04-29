--------------------------------------------------------
--  DDL for Package Body PV_K_REL_OBJS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_K_REL_OBJS_PVT_W" as
  /* $Header: pvxwkrob.pls 115.0 2002/12/04 01:40:03 ktsao ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_k_rel_obj(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
  )

  as
    ddp_crj_rel_hdr_full_rec pv_k_rel_objs_pvt.crj_rel_hdr_full_rec_type;
    ddx_crj_rel_hdr_full_rec pv_k_rel_objs_pvt.crj_rel_hdr_full_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crj_rel_hdr_full_rec.chr_id := p5_a0;
    ddp_crj_rel_hdr_full_rec.object1_id1 := p5_a1;
    ddp_crj_rel_hdr_full_rec.object1_id2 := p5_a2;
    ddp_crj_rel_hdr_full_rec.jtot_object1_code := p5_a3;
    ddp_crj_rel_hdr_full_rec.line_jtot_object1_code := p5_a4;
    ddp_crj_rel_hdr_full_rec.rty_code := p5_a5;


    -- here's the delegated call to the old PL/SQL routine
    pv_k_rel_objs_pvt.create_k_rel_obj(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crj_rel_hdr_full_rec,
      ddx_crj_rel_hdr_full_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_crj_rel_hdr_full_rec.chr_id;
    p6_a1 := ddx_crj_rel_hdr_full_rec.object1_id1;
    p6_a2 := ddx_crj_rel_hdr_full_rec.object1_id2;
    p6_a3 := ddx_crj_rel_hdr_full_rec.jtot_object1_code;
    p6_a4 := ddx_crj_rel_hdr_full_rec.line_jtot_object1_code;
    p6_a5 := ddx_crj_rel_hdr_full_rec.rty_code;
  end;

end pv_k_rel_objs_pvt_w;

/
