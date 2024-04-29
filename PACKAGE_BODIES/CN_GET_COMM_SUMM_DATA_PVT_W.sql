--------------------------------------------------------
--  DDL for Package Body CN_GET_COMM_SUMM_DATA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_COMM_SUMM_DATA_PVT_W" as
  /* $Header: cnwcommb.pls 120.4 2005/10/24 07:22 sjustina noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_comm_summ_data_pvt.comm_summ_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_plan_assign_id := a0(indx);
          t(ddindx).role_name := a1(indx);
          t(ddindx).plan_name := a2(indx);
          t(ddindx).start_date := a3(indx);
          t(ddindx).end_date := a4(indx);
          t(ddindx).ytd_total_earnings := a5(indx);
          t(ddindx).ptd_total_earnings := a6(indx);
          t(ddindx).salesrep_id := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_get_comm_summ_data_pvt.comm_summ_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).srp_plan_assign_id;
          a1(indx) := t(ddindx).role_name;
          a2(indx) := t(ddindx).plan_name;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).ytd_total_earnings;
          a6(indx) := t(ddindx).ptd_total_earnings;
          a7(indx) := t(ddindx).salesrep_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy cn_get_comm_summ_data_pvt.salesrep_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_get_comm_summ_data_pvt.salesrep_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_get_comm_summ_data_pvt.group_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_get_comm_summ_data_pvt.group_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_get_comm_summ_data_pvt.pe_info_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_plan_assign_id := a0(indx);
          t(ddindx).quota_group_code := a1(indx);
          t(ddindx).x_annual_quota := a2(indx);
          t(ddindx).x_pct_annual_quota := a3(indx);
          t(ddindx).x_ytd_target := a4(indx);
          t(ddindx).x_ytd_credit := a5(indx);
          t(ddindx).x_ytd_earnings := a6(indx);
          t(ddindx).x_ptd_target := a7(indx);
          t(ddindx).x_ptd_credit := a8(indx);
          t(ddindx).x_ptd_earnings := a9(indx);
          t(ddindx).x_itd_unachieved_quota := a10(indx);
          t(ddindx).x_itd_tot_target := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_get_comm_summ_data_pvt.pe_info_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).srp_plan_assign_id;
          a1(indx) := t(ddindx).quota_group_code;
          a2(indx) := t(ddindx).x_annual_quota;
          a3(indx) := t(ddindx).x_pct_annual_quota;
          a4(indx) := t(ddindx).x_ytd_target;
          a5(indx) := t(ddindx).x_ytd_credit;
          a6(indx) := t(ddindx).x_ytd_earnings;
          a7(indx) := t(ddindx).x_ptd_target;
          a8(indx) := t(ddindx).x_ptd_credit;
          a9(indx) := t(ddindx).x_ptd_earnings;
          a10(indx) := t(ddindx).x_itd_unachieved_quota;
          a11(indx) := t(ddindx).x_itd_tot_target;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy cn_get_comm_summ_data_pvt.salesrep_info_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).x_name := a0(indx);
          t(ddindx).x_emp_num := a1(indx);
          t(ddindx).x_cost_center := a2(indx);
          t(ddindx).x_charge_to_cost_center := a3(indx);
          t(ddindx).x_analyst_name := a4(indx);
          t(ddindx).x_salesrep_id := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cn_get_comm_summ_data_pvt.salesrep_info_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_400();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_400();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).x_name;
          a1(indx) := t(ddindx).x_emp_num;
          a2(indx) := t(ddindx).x_cost_center;
          a3(indx) := t(ddindx).x_charge_to_cost_center;
          a4(indx) := t(ddindx).x_analyst_name;
          a5(indx) := t(ddindx).x_salesrep_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy cn_get_comm_summ_data_pvt.pe_ptd_credit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_id := a0(indx);
          t(ddindx).x_ptd_credit := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t cn_get_comm_summ_data_pvt.pe_ptd_credit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_id;
          a1(indx) := t(ddindx).x_ptd_credit;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure get_salesrep_list(p_first  NUMBER
    , p_last  NUMBER
    , p_period_id  NUMBER
    , p_analyst_id  NUMBER
    , p_org_id  NUMBER
    , x_total_rows out nocopy  NUMBER
    , x_salesrep_tbl out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_salesrep_tbl cn_get_comm_summ_data_pvt.salesrep_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_salesrep_list(p_first,
      p_last,
      p_period_id,
      p_analyst_id,
      p_org_id,
      x_total_rows,
      ddx_salesrep_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p2(ddx_salesrep_tbl, x_salesrep_tbl);
  end;

  procedure get_quota_summary(p_salesrep_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.comm_summ_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_quota_summary(p_salesrep_id,
      p_period_id,
      p_credit_type_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );
  end;

  procedure get_quota_manager_summary(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.comm_summ_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_quota_manager_summary(p_period_id,
      p_credit_type_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );
  end;

  procedure get_quota_analyst_summary(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.comm_summ_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_quota_analyst_summary(p_period_id,
      p_credit_type_id,
      p_org_id,
      p_analyst_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );
  end;

  procedure get_salesrep_pe_info(p_salesrep_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.pe_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_salesrep_pe_info(p_salesrep_id,
      p_period_id,
      p_credit_type_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p5(ddx_result_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      );
  end;

  procedure get_manager_pe_info(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.pe_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_manager_pe_info(p_period_id,
      p_credit_type_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p5(ddx_result_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      );
  end;

  procedure get_analyst_pe_info(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.pe_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_analyst_pe_info(p_period_id,
      p_credit_type_id,
      p_org_id,
      p_analyst_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p5(ddx_result_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      );
  end;

  procedure get_salesrep_details(p_salesrep_id  NUMBER
    , p_org_id  NUMBER
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.salesrep_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_salesrep_details(p_salesrep_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p7(ddx_result_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );
  end;

  procedure get_manager_details(p_org_id  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a5 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.salesrep_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_manager_details(p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p7(ddx_result_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      );
  end;

  procedure get_analyst_details(p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.salesrep_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_analyst_details(p_org_id,
      p_analyst_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p7(ddx_result_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );
  end;

  procedure get_group_codes(p_org_id  NUMBER
    , x_result_tbl out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.group_code_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_group_codes(p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p3(ddx_result_tbl, x_result_tbl);
  end;

  procedure get_ptd_credit(p_salesrep_id  NUMBER
    , p_payrun_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_get_comm_summ_data_pvt.pe_ptd_credit_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_in_p9(ddx_result_tbl, p3_a0
      , p3_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data_pvt.get_ptd_credit(p_salesrep_id,
      p_payrun_id,
      p_org_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    cn_get_comm_summ_data_pvt_w.rosetta_table_copy_out_p9(ddx_result_tbl, p3_a0
      , p3_a1
      );
  end;

end cn_get_comm_summ_data_pvt_w;

/
