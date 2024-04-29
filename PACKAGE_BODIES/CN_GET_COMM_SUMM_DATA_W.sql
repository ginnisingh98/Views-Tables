--------------------------------------------------------
--  DDL for Package Body CN_GET_COMM_SUMM_DATA_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_COMM_SUMM_DATA_W" as
  /* $Header: cnwcommb.pls 115.3 2001/01/15 18:45:57 pkm ship     $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out cn_get_comm_summ_data.comm_summ_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_plan_assign_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).emp_num := a2(indx);
          t(ddindx).cost_center := a3(indx);
          t(ddindx).charge_to_cost_center := a4(indx);
          t(ddindx).analyst_name := a5(indx);
          t(ddindx).role_name := a6(indx);
          t(ddindx).plan_name := a7(indx);
          t(ddindx).begin_balance := a8(indx);
          t(ddindx).draw := a9(indx);
          t(ddindx).net_due := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_get_comm_summ_data.comm_summ_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).srp_plan_assign_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).emp_num;
          a3(indx) := t(ddindx).cost_center;
          a4(indx) := t(ddindx).charge_to_cost_center;
          a5(indx) := t(ddindx).analyst_name;
          a6(indx) := t(ddindx).role_name;
          a7(indx) := t(ddindx).plan_name;
          a8(indx) := t(ddindx).begin_balance;
          a9(indx) := t(ddindx).draw;
          a10(indx) := t(ddindx).net_due;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out cn_get_comm_summ_data.pe_info_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_group_code := a0(indx);
          t(ddindx).annual_quota := a1(indx);
          t(ddindx).pct_annual_quota := a2(indx);
          t(ddindx).target := a3(indx);
          t(ddindx).credit := a4(indx);
          t(ddindx).earnings := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_get_comm_summ_data.pe_info_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).quota_group_code;
          a1(indx) := t(ddindx).annual_quota;
          a2(indx) := t(ddindx).pct_annual_quota;
          a3(indx) := t(ddindx).target;
          a4(indx) := t(ddindx).credit;
          a5(indx) := t(ddindx).earnings;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_quota_summary(p_first  NUMBER
    , p_last  NUMBER
    , p_period_id  NUMBER
    , p_user_id  NUMBER
    , p_credit_type_id  NUMBER
    , x_total_rows out  NUMBER
    , p6_a0 out JTF_NUMBER_TABLE
    , p6_a1 out JTF_VARCHAR2_TABLE_300
    , p6_a2 out JTF_VARCHAR2_TABLE_100
    , p6_a3 out JTF_VARCHAR2_TABLE_100
    , p6_a4 out JTF_VARCHAR2_TABLE_100
    , p6_a5 out JTF_VARCHAR2_TABLE_300
    , p6_a6 out JTF_VARCHAR2_TABLE_100
    , p6_a7 out JTF_VARCHAR2_TABLE_100
    , p6_a8 out JTF_NUMBER_TABLE
    , p6_a9 out JTF_NUMBER_TABLE
    , p6_a10 out JTF_NUMBER_TABLE
  )
  as
    ddx_result_tbl cn_get_comm_summ_data.comm_summ_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data.get_quota_summary(p_first,
      p_last,
      p_period_id,
      p_user_id,
      p_credit_type_id,
      x_total_rows,
      ddx_result_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    cn_get_comm_summ_data_w.rosetta_table_copy_out_p1(ddx_result_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      );
  end;

  procedure get_pe_info(p_srp_plan_assign_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p3_a0 out JTF_VARCHAR2_TABLE_100
    , p3_a1 out JTF_NUMBER_TABLE
    , p3_a2 out JTF_NUMBER_TABLE
    , p3_a3 out JTF_NUMBER_TABLE
    , p3_a4 out JTF_NUMBER_TABLE
    , p3_a5 out JTF_NUMBER_TABLE
    , p4_a0 out JTF_VARCHAR2_TABLE_100
    , p4_a1 out JTF_NUMBER_TABLE
    , p4_a2 out JTF_NUMBER_TABLE
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_NUMBER_TABLE
    , p4_a5 out JTF_NUMBER_TABLE
    , x_ytd_total_earnings out  NUMBER
    , x_ptd_total_earnings out  NUMBER
  )
  as
    ddx_ytd_pe_info cn_get_comm_summ_data.pe_info_tbl_type;
    ddx_ptd_pe_info cn_get_comm_summ_data.pe_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data.get_pe_info(p_srp_plan_assign_id,
      p_period_id,
      p_credit_type_id,
      ddx_ytd_pe_info,
      ddx_ptd_pe_info,
      x_ytd_total_earnings,
      x_ptd_total_earnings);

    -- copy data back from the local OUT or IN-OUT args, if any



    cn_get_comm_summ_data_w.rosetta_table_copy_out_p3(ddx_ytd_pe_info, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      );

    cn_get_comm_summ_data_w.rosetta_table_copy_out_p3(ddx_ptd_pe_info, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      );


  end;

  procedure get_group_codes(p0_a0 out JTF_VARCHAR2_TABLE_100
    , p0_a1 out JTF_NUMBER_TABLE
    , p0_a2 out JTF_NUMBER_TABLE
    , p0_a3 out JTF_NUMBER_TABLE
    , p0_a4 out JTF_NUMBER_TABLE
    , p0_a5 out JTF_NUMBER_TABLE
  )
  as
    ddx_result_tbl cn_get_comm_summ_data.pe_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    cn_get_comm_summ_data.get_group_codes(ddx_result_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any
    cn_get_comm_summ_data_w.rosetta_table_copy_out_p3(ddx_result_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      );
  end;

end cn_get_comm_summ_data_w;

/
