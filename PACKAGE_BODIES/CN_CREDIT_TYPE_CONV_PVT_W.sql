--------------------------------------------------------
--  DDL for Package Body CN_CREDIT_TYPE_CONV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CREDIT_TYPE_CONV_PVT_W" as
  /* $Header: cnwctcnb.pls 115.3 2002/11/25 14:44:57 rarajara noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_conversion(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_from_credit_type  NUMBER
    , p_to_credit_type  NUMBER
    , p_conv_factor  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    cn_credit_type_conv_pvt.create_conversion(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_from_credit_type,
      p_to_credit_type,
      p_conv_factor,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_conversion(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version  NUMBER
    , p_conv_id  NUMBER
    , p_from_credit_type  NUMBER
    , p_to_credit_type  NUMBER
    , p_conv_factor  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    cn_credit_type_conv_pvt.update_conversion(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_object_version,
      p_conv_id,
      p_from_credit_type,
      p_to_credit_type,
      p_conv_factor,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

end cn_credit_type_conv_pvt_w;

/
