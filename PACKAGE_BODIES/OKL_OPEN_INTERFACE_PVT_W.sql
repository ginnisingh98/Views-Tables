--------------------------------------------------------
--  DDL for Package Body OKL_OPEN_INTERFACE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPEN_INTERFACE_PVT_W" as
  /* $Header: OKLEKOIB.pls 120.1 2005/10/04 20:21:17 cklee noship $ */
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

  procedure check_input_record(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_contract_number  VARCHAR2
    , p_customer_number  VARCHAR2
    , x_total_checked out nocopy  NUMBER
  )

  as
    ddp_start_date_from date;
    ddp_start_date_to date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_start_date_from := rosetta_g_miss_date_in_map(p_start_date_from);

    ddp_start_date_to := rosetta_g_miss_date_in_map(p_start_date_to);




    -- here's the delegated call to the old PL/SQL routine
    okl_open_interface_pvt.check_input_record(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_batch_number,
      ddp_start_date_from,
      ddp_start_date_to,
      p_contract_number,
      p_customer_number,
      x_total_checked);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure load_input_record(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_contract_number  VARCHAR2
    , p_customer_number  VARCHAR2
    , x_total_loaded out nocopy  NUMBER
  )

  as
    ddp_start_date_from date;
    ddp_start_date_to date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_start_date_from := rosetta_g_miss_date_in_map(p_start_date_from);

    ddp_start_date_to := rosetta_g_miss_date_in_map(p_start_date_to);




    -- here's the delegated call to the old PL/SQL routine
    okl_open_interface_pvt.load_input_record(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_batch_number,
      ddp_start_date_from,
      ddp_start_date_to,
      p_contract_number,
      p_customer_number,
      x_total_loaded);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  function submit_import_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_party_number  VARCHAR2
  ) return number

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_open_interface_pvt.submit_import_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_batch_number,
      p_contract_number,
      ddp_start_date,
      ddp_end_date,
      p_party_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    return ddrosetta_retval;
  end;

end okl_open_interface_pvt_w;

/
