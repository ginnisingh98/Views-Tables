--------------------------------------------------------
--  DDL for Package Body OKL_ACC_CALL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_CALL_PUB_W" as
  /* $Header: OKLUACCB.pls 120.1 2005/07/07 13:33:38 dkagrawa noship $ */
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

  procedure create_acc_trans(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_bpd_acc_rec okl_acc_call_pub.bpd_acc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_bpd_acc_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_bpd_acc_rec.source_table := p5_a1;

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_call_pub.create_acc_trans(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bpd_acc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_acc_trans(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_bpd_acc_tbl okl_acc_call_pub.bpd_acc_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_acc_call_pvt_w.rosetta_table_copy_in_p2(ddp_bpd_acc_tbl, p5_a0
      , p5_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_call_pub.create_acc_trans(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bpd_acc_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_acc_call_pub_w;

/
