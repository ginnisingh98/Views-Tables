--------------------------------------------------------
--  DDL for Package Body OKL_EXECUTE_FORMULA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXECUTE_FORMULA_PUB_W" as
  /* $Header: OKLUFMLB.pls 120.1 2005/07/12 07:06:29 asawanka noship $ */
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

  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  )

  as
    ddp_additional_parameters okl_execute_formula_pub.ctxt_val_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_execute_formula_pvt_w.rosetta_table_copy_in_p25(ddp_additional_parameters, p8_a0
      , p8_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_execute_formula_pub.execute(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_formula_name,
      p_contract_id,
      p_line_id,
      ddp_additional_parameters,
      x_value);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  )

  as
    ddp_additional_parameters okl_execute_formula_pub.ctxt_val_tbl_type;
    ddx_operand_val_tbl okl_execute_formula_pub.operand_val_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_execute_formula_pvt_w.rosetta_table_copy_in_p25(ddp_additional_parameters, p8_a0
      , p8_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_execute_formula_pub.execute(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_formula_name,
      p_contract_id,
      p_line_id,
      ddp_additional_parameters,
      ddx_operand_val_tbl,
      x_value);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_execute_formula_pvt_w.rosetta_table_copy_out_p23(ddx_operand_val_tbl, p9_a0
      , p9_a1
      , p9_a2
      );

  end;

end okl_execute_formula_pub_w;

/
