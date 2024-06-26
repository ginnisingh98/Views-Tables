--------------------------------------------------------
--  DDL for Package Body OKL_REV_LOSS_PROV_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REV_LOSS_PROV_PUB_W" as
  /* $Header: OKLURPVB.pls 120.3 2005/10/30 04:49:39 appldev noship $ */
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

  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
  )

  as
    ddp_lprv_rec okl_rev_loss_prov_pub.lprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lprv_rec.cntrct_num := p5_a0;
    ddp_lprv_rec.reversal_type := p5_a1;
    ddp_lprv_rec.reversal_date := rosetta_g_miss_date_in_map(p5_a2);

    -- here's the delegated call to the old PL/SQL routine
    okl_rev_loss_prov_pub.reverse_loss_provisions(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_lprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
  )

  as
    ddp_lprv_tbl okl_rev_loss_prov_pub.lprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rev_loss_prov_pvt_w.rosetta_table_copy_in_p1(ddp_lprv_tbl, p5_a0
      , p5_a1
      , p5_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rev_loss_prov_pub.reverse_loss_provisions(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_lprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_rev_loss_prov_pub_w;

/
