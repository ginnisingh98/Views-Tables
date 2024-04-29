--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_CONTRACT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_CONTRACT_PUB_W" as
  /* $Header: OKLUSKHB.pls 115.3 2004/01/24 00:58:37 rravikir noship $ */
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

  procedure create_split_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_old_contract_number  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_200
    , p6_a2 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_new_khr_top_line okl_split_contract_pub.ktl_tbl_type;
    ddx_new_khr_top_line okl_split_contract_pub.ktl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_split_contract_pvt_w.rosetta_table_copy_in_p1(ddp_new_khr_top_line, p6_a0
      , p6_a1
      , p6_a2
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_split_contract_pub.create_split_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_old_contract_number,
      ddp_new_khr_top_line,
      ddx_new_khr_top_line);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_split_contract_pvt_w.rosetta_table_copy_out_p1(ddx_new_khr_top_line, p7_a0
      , p7_a1
      , p7_a2
      );
  end;

end okl_split_contract_pub_w;

/
