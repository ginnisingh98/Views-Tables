--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_PROCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_PROCESS_PUB_W" as
  /* $Header: OKLUAECB.pls 120.1 2005/07/07 13:34:49 dkagrawa noship $ */
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

  procedure do_accounting_con(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_process_pub.do_accounting_con(p_api_version,
      p_init_msg_list,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_request_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_accounting_process_pub_w;

/
