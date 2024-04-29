--------------------------------------------------------
--  DDL for Package Body OKS_COV_ENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COV_ENT_PUB_W" as
  /* $Header: OKSPCEWB.pls 120.3 2005/12/22 11:16 jvarghes noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure get_default_react_resolve_by(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  DATE
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  DATE
    , p6_a1 out nocopy  DATE
    , p7_a0 out nocopy  DATE
    , p7_a1 out nocopy  DATE
  )

  as
    ddp_inp_rec oks_cov_ent_pub.gdrt_inp_rec_type;
    ddx_react_rec oks_cov_ent_pub.rcn_rsn_rec_type;
    ddx_resolve_rec oks_cov_ent_pub.rcn_rsn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.coverage_template_id := p2_a0;
    ddp_inp_rec.business_process_id := p2_a1;
    ddp_inp_rec.request_date := rosetta_g_miss_date_in_map(p2_a2);
    ddp_inp_rec.severity_id := p2_a3;
    ddp_inp_rec.time_zone_id := p2_a4;
    ddp_inp_rec.dates_in_input_tz := p2_a5;






    -- here's the delegated call to the old PL/SQL routine
    oks_cov_ent_pub.get_default_react_resolve_by(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_react_rec,
      ddx_resolve_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_react_rec.by_date_start;
    p6_a1 := ddx_react_rec.by_date_end;

    p7_a0 := ddx_resolve_rec.by_date_start;
    p7_a1 := ddx_resolve_rec.by_date_end;
  end;

end oks_cov_ent_pub_w;

/
