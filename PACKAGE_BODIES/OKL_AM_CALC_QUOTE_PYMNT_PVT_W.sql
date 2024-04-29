--------------------------------------------------------
--  DDL for Package Body OKL_AM_CALC_QUOTE_PYMNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CALC_QUOTE_PYMNT_PVT_W" as
  /* $Header: OKLECQPB.pls 120.2 2005/10/30 04:05:33 appldev noship $ */
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

  procedure rosetta_table_copy_in_p23(t out nocopy okl_am_calc_quote_pymnt_pvt.pymt_smry_uv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_strm_type_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).p_strm_type_code := a1(indx);
          t(ddindx).p_curr_total := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).p_prop_total := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_am_calc_quote_pymnt_pvt.pymt_smry_uv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).p_strm_type_id);
          a1(indx) := t(ddindx).p_strm_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).p_curr_total);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).p_prop_total);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure get_payment_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_qte_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , x_pymt_smry_tbl_count out nocopy  NUMBER
    , x_total_curr_amt out nocopy  NUMBER
    , x_total_prop_amt out nocopy  NUMBER
  )

  as
    ddx_pymt_smry_tbl okl_am_calc_quote_pymnt_pvt.pymt_smry_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_am_calc_quote_pymnt_pvt.get_payment_summary(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      p_qte_id,
      ddx_pymt_smry_tbl,
      x_pymt_smry_tbl_count,
      x_total_curr_amt,
      x_total_prop_amt);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_calc_quote_pymnt_pvt_w.rosetta_table_copy_out_p23(ddx_pymt_smry_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );



  end;

end okl_am_calc_quote_pymnt_pvt_w;

/
