--------------------------------------------------------
--  DDL for Package Body CN_CALC_FORMULAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_FORMULAS_PVT_W" as
  /* $Header: cnwformb.pls 120.3 2006/01/05 18:09 jxsingh ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy cn_calc_formulas_pvt.input_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).formula_input_id := a0(indx);
          t(ddindx).calc_sql_exp_id := a1(indx);
          t(ddindx).f_calc_sql_exp_id := a2(indx);
          t(ddindx).rate_dim_sequence := a3(indx);
          t(ddindx).calc_exp_name := a4(indx);
          t(ddindx).calc_exp_status := a5(indx);
          t(ddindx).f_calc_exp_name := a6(indx);
          t(ddindx).f_calc_exp_status := a7(indx);
          t(ddindx).object_version_number := a8(indx);
          t(ddindx).cumulative_flag := a9(indx);
          t(ddindx).split_flag := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_calc_formulas_pvt.input_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).formula_input_id;
          a1(indx) := t(ddindx).calc_sql_exp_id;
          a2(indx) := t(ddindx).f_calc_sql_exp_id;
          a3(indx) := t(ddindx).rate_dim_sequence;
          a4(indx) := t(ddindx).calc_exp_name;
          a5(indx) := t(ddindx).calc_exp_status;
          a6(indx) := t(ddindx).f_calc_exp_name;
          a7(indx) := t(ddindx).f_calc_exp_status;
          a8(indx) := t(ddindx).object_version_number;
          a9(indx) := t(ddindx).cumulative_flag;
          a10(indx) := t(ddindx).split_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy cn_calc_formulas_pvt.rt_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rt_formula_asgn_id := a0(indx);
          t(ddindx).rate_schedule_id := a1(indx);
          t(ddindx).start_date := a2(indx);
          t(ddindx).end_date := a3(indx);
          t(ddindx).rate_schedule_name := a4(indx);
          t(ddindx).rate_schedule_type := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cn_calc_formulas_pvt.rt_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rt_formula_asgn_id;
          a1(indx) := t(ddindx).rate_schedule_id;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := t(ddindx).rate_schedule_name;
          a5(indx) := t(ddindx).rate_schedule_type;
          a6(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_calc_formulas_pvt.parent_expression_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_calc_formulas_pvt.parent_expression_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy cn_calc_formulas_pvt.formula_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).calc_formula_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).formula_type := a3(indx);
          t(ddindx).formula_status := a4(indx);
          t(ddindx).trx_group_code := a5(indx);
          t(ddindx).number_dim := a6(indx);
          t(ddindx).cumulative_flag := a7(indx);
          t(ddindx).itd_flag := a8(indx);
          t(ddindx).split_flag := a9(indx);
          t(ddindx).threshold_all_tier_flag := a10(indx);
          t(ddindx).modeling_flag := a11(indx);
          t(ddindx).perf_measure_id := a12(indx);
          t(ddindx).output_exp_id := a13(indx);
          t(ddindx).f_output_exp_id := a14(indx);
          t(ddindx).object_version_number := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t cn_calc_formulas_pvt.formula_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).calc_formula_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).formula_type;
          a4(indx) := t(ddindx).formula_status;
          a5(indx) := t(ddindx).trx_group_code;
          a6(indx) := t(ddindx).number_dim;
          a7(indx) := t(ddindx).cumulative_flag;
          a8(indx) := t(ddindx).itd_flag;
          a9(indx) := t(ddindx).split_flag;
          a10(indx) := t(ddindx).threshold_all_tier_flag;
          a11(indx) := t(ddindx).modeling_flag;
          a12(indx) := t(ddindx).perf_measure_id;
          a13(indx) := t(ddindx).output_exp_id;
          a14(indx) := t(ddindx).f_output_exp_id;
          a15(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_generate_packages  VARCHAR2
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_formula_type  VARCHAR2
    , p_trx_group_code  VARCHAR2
    , p_number_dim  NUMBER
    , p_cumulative_flag  VARCHAR2
    , p_itd_flag  VARCHAR2
    , p_split_flag  VARCHAR2
    , p_threshold_all_tier_flag  VARCHAR2
    , p_modeling_flag  VARCHAR2
    , p_perf_measure_id  NUMBER
    , p_output_exp_id  NUMBER
    , p_f_output_exp_id  NUMBER
    , p18_a0 JTF_NUMBER_TABLE
    , p18_a1 JTF_NUMBER_TABLE
    , p18_a2 JTF_NUMBER_TABLE
    , p18_a3 JTF_NUMBER_TABLE
    , p18_a4 JTF_VARCHAR2_TABLE_100
    , p18_a5 JTF_VARCHAR2_TABLE_100
    , p18_a6 JTF_VARCHAR2_TABLE_100
    , p18_a7 JTF_VARCHAR2_TABLE_100
    , p18_a8 JTF_NUMBER_TABLE
    , p18_a9 JTF_VARCHAR2_TABLE_100
    , p18_a10 JTF_VARCHAR2_TABLE_100
    , p19_a0 JTF_NUMBER_TABLE
    , p19_a1 JTF_NUMBER_TABLE
    , p19_a2 JTF_DATE_TABLE
    , p19_a3 JTF_DATE_TABLE
    , p19_a4 JTF_VARCHAR2_TABLE_100
    , p19_a5 JTF_VARCHAR2_TABLE_100
    , p19_a6 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , x_calc_formula_id in out nocopy  NUMBER
    , x_formula_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_input_tbl cn_calc_formulas_pvt.input_tbl_type;
    ddp_rt_assign_tbl cn_calc_formulas_pvt.rt_assign_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    cn_calc_formulas_pvt_w.rosetta_table_copy_in_p3(ddp_input_tbl, p18_a0
      , p18_a1
      , p18_a2
      , p18_a3
      , p18_a4
      , p18_a5
      , p18_a6
      , p18_a7
      , p18_a8
      , p18_a9
      , p18_a10
      );

    cn_calc_formulas_pvt_w.rosetta_table_copy_in_p4(ddp_rt_assign_tbl, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      , p19_a4
      , p19_a5
      , p19_a6
      );







    -- here's the delegated call to the old PL/SQL routine
    cn_calc_formulas_pvt.create_formula(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_generate_packages,
      p_name,
      p_description,
      p_formula_type,
      p_trx_group_code,
      p_number_dim,
      p_cumulative_flag,
      p_itd_flag,
      p_split_flag,
      p_threshold_all_tier_flag,
      p_modeling_flag,
      p_perf_measure_id,
      p_output_exp_id,
      p_f_output_exp_id,
      ddp_input_tbl,
      ddp_rt_assign_tbl,
      p_org_id,
      x_calc_formula_id,
      x_formula_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

























  end;

  procedure update_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_generate_packages  VARCHAR2
    , p_calc_formula_id  NUMBER
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_formula_type  VARCHAR2
    , p_formula_status  VARCHAR2
    , p_trx_group_code  VARCHAR2
    , p_number_dim  NUMBER
    , p_cumulative_flag  VARCHAR2
    , p_itd_flag  VARCHAR2
    , p_split_flag  VARCHAR2
    , p_threshold_all_tier_flag  VARCHAR2
    , p_modeling_flag  VARCHAR2
    , p_perf_measure_id  NUMBER
    , p_output_exp_id  NUMBER
    , p_f_output_exp_id  NUMBER
    , p20_a0 JTF_NUMBER_TABLE
    , p20_a1 JTF_NUMBER_TABLE
    , p20_a2 JTF_NUMBER_TABLE
    , p20_a3 JTF_NUMBER_TABLE
    , p20_a4 JTF_VARCHAR2_TABLE_100
    , p20_a5 JTF_VARCHAR2_TABLE_100
    , p20_a6 JTF_VARCHAR2_TABLE_100
    , p20_a7 JTF_VARCHAR2_TABLE_100
    , p20_a8 JTF_NUMBER_TABLE
    , p20_a9 JTF_VARCHAR2_TABLE_100
    , p20_a10 JTF_VARCHAR2_TABLE_100
    , p21_a0 JTF_NUMBER_TABLE
    , p21_a1 JTF_NUMBER_TABLE
    , p21_a2 JTF_DATE_TABLE
    , p21_a3 JTF_DATE_TABLE
    , p21_a4 JTF_VARCHAR2_TABLE_100
    , p21_a5 JTF_VARCHAR2_TABLE_100
    , p21_a6 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_formula_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_input_tbl cn_calc_formulas_pvt.input_tbl_type;
    ddp_rt_assign_tbl cn_calc_formulas_pvt.rt_assign_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    cn_calc_formulas_pvt_w.rosetta_table_copy_in_p3(ddp_input_tbl, p20_a0
      , p20_a1
      , p20_a2
      , p20_a3
      , p20_a4
      , p20_a5
      , p20_a6
      , p20_a7
      , p20_a8
      , p20_a9
      , p20_a10
      );

    cn_calc_formulas_pvt_w.rosetta_table_copy_in_p4(ddp_rt_assign_tbl, p21_a0
      , p21_a1
      , p21_a2
      , p21_a3
      , p21_a4
      , p21_a5
      , p21_a6
      );







    -- here's the delegated call to the old PL/SQL routine
    cn_calc_formulas_pvt.update_formula(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_generate_packages,
      p_calc_formula_id,
      p_name,
      p_description,
      p_formula_type,
      p_formula_status,
      p_trx_group_code,
      p_number_dim,
      p_cumulative_flag,
      p_itd_flag,
      p_split_flag,
      p_threshold_all_tier_flag,
      p_modeling_flag,
      p_perf_measure_id,
      p_output_exp_id,
      p_f_output_exp_id,
      ddp_input_tbl,
      ddp_rt_assign_tbl,
      p_org_id,
      p_object_version_number,
      x_formula_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



























  end;

end cn_calc_formulas_pvt_w;

/
