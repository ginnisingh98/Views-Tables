--------------------------------------------------------
--  DDL for Package Body OKL_VP_TERMINATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_TERMINATE_PUB_W" as
  /* $Header: OKLUTERB.pls 120.1 2005/07/22 10:20:42 dkagrawa noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure terminate_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ter_header_rec okl_vp_terminate_pub.terminate_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ter_header_rec.p_id := rosetta_g_miss_num_map(p5_a0);
    ddp_ter_header_rec.p_current_end_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_ter_header_rec.p_terminate_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_ter_header_rec.p_term_reason := p5_a3;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_terminate_pub.terminate_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ter_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_vp_terminate_pub_w;

/
