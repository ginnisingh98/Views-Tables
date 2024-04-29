--------------------------------------------------------
--  DDL for Package Body OKL_VP_COPY_CONTRACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_COPY_CONTRACT_PVT_W" as
  /* $Header: OKLECPXB.pls 120.2 2005/08/03 07:58:49 sjalasut noship $ */
  procedure copy_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , x_new_contract_id out nocopy  NUMBER
  )

  as
    ddp_copy_rec okl_vp_copy_contract_pvt.copy_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_copy_rec.p_id := p5_a0;
    ddp_copy_rec.p_to_agreement_number := p5_a1;
    ddp_copy_rec.p_template_yn := p5_a2;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_copy_contract_pvt.copy_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_copy_rec,
      x_new_contract_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_vp_copy_contract_pvt_w;

/
