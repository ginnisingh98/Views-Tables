--------------------------------------------------------
--  DDL for Package Body OKL_MULTI_GAAP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MULTI_GAAP_PUB_W" as
  /* $Header: OKLUGAPB.pls 115.2 2004/02/06 22:36:13 sgiyer noship $ */
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

  function submit_multi_gaap(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_batch_name  VARCHAR2
  ) return number

  as
    ddp_date_from date;
    ddp_date_to date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_date_from := rosetta_g_miss_date_in_map(p_date_from);

    ddp_date_to := rosetta_g_miss_date_in_map(p_date_to);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_multi_gaap_pub.submit_multi_gaap(x_return_status,
      x_msg_count,
      x_msg_data,
      p_api_version,
      ddp_date_from,
      ddp_date_to,
      p_batch_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    return ddrosetta_retval;
  end;

end okl_multi_gaap_pub_w;

/