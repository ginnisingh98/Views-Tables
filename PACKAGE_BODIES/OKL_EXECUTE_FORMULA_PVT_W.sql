--------------------------------------------------------
--  DDL for Package Body OKL_EXECUTE_FORMULA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXECUTE_FORMULA_PVT_W" as
  /* $Header: OKLEFMLB.pls 120.1 2005/07/11 12:49:41 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p23(t out nocopy okl_execute_formula_pvt.operand_val_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_800
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).label := a1(indx);
          t(ddindx).value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_execute_formula_pvt.operand_val_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_800
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_800();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_800();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).label;
          a2(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p25(t out nocopy okl_execute_formula_pvt.ctxt_val_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t okl_execute_formula_pvt.ctxt_val_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

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
    ddp_additional_parameters okl_execute_formula_pvt.ctxt_val_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_execute_formula_pvt_w.rosetta_table_copy_in_p25(ddp_additional_parameters, p8_a0
      , p8_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_execute_formula_pvt.execute(p_api_version,
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
    ddp_additional_parameters okl_execute_formula_pvt.ctxt_val_tbl_type;
    ddx_operand_val_tbl okl_execute_formula_pvt.operand_val_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_execute_formula_pvt_w.rosetta_table_copy_in_p25(ddp_additional_parameters, p8_a0
      , p8_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_execute_formula_pvt.execute(p_api_version,
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

end okl_execute_formula_pvt_w;

/
