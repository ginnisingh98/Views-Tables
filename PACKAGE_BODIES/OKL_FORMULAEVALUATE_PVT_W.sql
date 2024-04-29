--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAEVALUATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAEVALUATE_PVT_W" as
  /* $Header: OKLEEVAB.pls 120.1 2005/07/11 12:49:12 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p24(t out nocopy okl_formulaevaluate_pvt.ctxparameter_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parameter_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parameter_name := a1(indx);
          t(ddindx).parameter_value := rosetta_g_miss_num_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t okl_formulaevaluate_pvt.ctxparameter_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).parameter_id);
          a1(indx) := t(ddindx).parameter_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).parameter_value);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p26(t out nocopy okl_formulaevaluate_pvt.function_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_800
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).function_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).function_name := a1(indx);
          t(ddindx).function_source := a2(indx);
          t(ddindx).function_code := a3(indx);
          t(ddindx).function_value := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t okl_formulaevaluate_pvt.function_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_800
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_800();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_800();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).function_id);
          a1(indx) := t(ddindx).function_name;
          a2(indx) := t(ddindx).function_source;
          a3(indx) := t(ddindx).function_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).function_value);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  function eva_getparameterids(p_fma_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a2 out nocopy JTF_NUMBER_TABLE
  ) return number

  as
    ddp_ctx_parameter_tbl okl_formulaevaluate_pvt.ctxparameter_tbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_formulaevaluate_pvt.eva_getparameterids(p_fma_id,
      ddp_ctx_parameter_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    okl_formulaevaluate_pvt_w.rosetta_table_copy_out_p24(ddp_ctx_parameter_tbl, p1_a0
      , p1_a1
      , p1_a2
      );

    return ddrosetta_retval;
  end;

  procedure eva_getparametervalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p_line_id  NUMBER
  )

  as
    ddx_ctx_parameter_tbl okl_formulaevaluate_pvt.ctxparameter_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_formulaevaluate_pvt.eva_getparametervalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_fma_id,
      p_contract_id,
      ddx_ctx_parameter_tbl,
      p_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_formulaevaluate_pvt_w.rosetta_table_copy_out_p24(ddx_ctx_parameter_tbl, p7_a0
      , p7_a1
      , p7_a2
      );

  end;

  procedure eva_getfunctionvalue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_200
    , p8_a2 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ctx_parameter_tbl okl_formulaevaluate_pvt.ctxparameter_tbl;
    ddx_function_tbl okl_formulaevaluate_pvt.function_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_formulaevaluate_pvt_w.rosetta_table_copy_in_p24(ddp_ctx_parameter_tbl, p8_a0
      , p8_a1
      , p8_a2
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_formulaevaluate_pvt.eva_getfunctionvalue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_fma_id,
      p_contract_id,
      p_line_id,
      ddp_ctx_parameter_tbl,
      ddx_function_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_formulaevaluate_pvt_w.rosetta_table_copy_out_p26(ddx_function_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      );
  end;

end okl_formulaevaluate_pvt_w;

/
