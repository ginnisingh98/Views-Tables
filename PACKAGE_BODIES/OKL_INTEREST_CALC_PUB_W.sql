--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_CALC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_CALC_PUB_W" as
  /* $Header: OKLUITUB.pls 120.1 2005/07/14 12:03:51 asawanka noship $ */
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

  procedure calc_interest_activate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_activation_date  date
    , x_amount out nocopy  NUMBER
    , x_source_id out nocopy  NUMBER
  )

  as
    ddp_activation_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_activation_date := rosetta_g_miss_date_in_map(p_activation_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_interest_calc_pub.calc_interest_activate(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_number,
      ddp_activation_date,
      x_amount,
      x_source_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end okl_interest_calc_pub_w;

/
