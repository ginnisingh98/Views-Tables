--------------------------------------------------------
--  DDL for Package Body CN_WKSHT_GET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WKSHT_GET_PUB_W" as
  /* $Header: cnwwkgtb.pls 115.16 2003/06/27 20:36:01 achung ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_wksht_get_pub.wksht_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).payment_worksheet_id := a0(indx);
          t(ddindx).salesrep_id := a1(indx);
          t(ddindx).salesrep_name := a2(indx);
          t(ddindx).resource_id := a3(indx);
          t(ddindx).employee_number := a4(indx);
          t(ddindx).current_earnings := a5(indx);
          t(ddindx).pmt_amount_earnings := a6(indx);
          t(ddindx).pmt_amount_diff := a7(indx);
          t(ddindx).pmt_amount_adj := a8(indx);
          t(ddindx).pmt_amount_adj_rec := a9(indx);
          t(ddindx).pmt_amount_total := a10(indx);
          t(ddindx).held_amount := a11(indx);
          t(ddindx).worksheet_status := a12(indx);
          t(ddindx).worksheet_status_code := a13(indx);
          t(ddindx).analyst_name := a14(indx);
          t(ddindx).object_version_number := a15(indx);
          t(ddindx).view_notes := a16(indx);
          t(ddindx).view_ced := a17(indx);
          t(ddindx).status_by := a18(indx);
          t(ddindx).cost_center := a19(indx);
          t(ddindx).charge_to_cost_center := a20(indx);
          t(ddindx).notes := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_wksht_get_pub.wksht_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
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
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).payment_worksheet_id;
          a1(indx) := t(ddindx).salesrep_id;
          a2(indx) := t(ddindx).salesrep_name;
          a3(indx) := t(ddindx).resource_id;
          a4(indx) := t(ddindx).employee_number;
          a5(indx) := t(ddindx).current_earnings;
          a6(indx) := t(ddindx).pmt_amount_earnings;
          a7(indx) := t(ddindx).pmt_amount_diff;
          a8(indx) := t(ddindx).pmt_amount_adj;
          a9(indx) := t(ddindx).pmt_amount_adj_rec;
          a10(indx) := t(ddindx).pmt_amount_total;
          a11(indx) := t(ddindx).held_amount;
          a12(indx) := t(ddindx).worksheet_status;
          a13(indx) := t(ddindx).worksheet_status_code;
          a14(indx) := t(ddindx).analyst_name;
          a15(indx) := t(ddindx).object_version_number;
          a16(indx) := t(ddindx).view_notes;
          a17(indx) := t(ddindx).view_ced;
          a18(indx) := t(ddindx).status_by;
          a19(indx) := t(ddindx).cost_center;
          a20(indx) := t(ddindx).charge_to_cost_center;
          a21(indx) := t(ddindx).notes;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_srp_wksht(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_payrun_id  NUMBER
    , p_salesrep_name  VARCHAR2
    , p_employee_number  VARCHAR2
    , p_analyst_name  VARCHAR2
    , p_my_analyst  VARCHAR2
    , p_unassigned  VARCHAR2
    , p_worksheet_status  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_order_by  VARCHAR2
    , p18_a0 out nocopy JTF_NUMBER_TABLE
    , p18_a1 out nocopy JTF_NUMBER_TABLE
    , p18_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p18_a3 out nocopy JTF_NUMBER_TABLE
    , p18_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a5 out nocopy JTF_NUMBER_TABLE
    , p18_a6 out nocopy JTF_NUMBER_TABLE
    , p18_a7 out nocopy JTF_NUMBER_TABLE
    , p18_a8 out nocopy JTF_NUMBER_TABLE
    , p18_a9 out nocopy JTF_NUMBER_TABLE
    , p18_a10 out nocopy JTF_NUMBER_TABLE
    , p18_a11 out nocopy JTF_NUMBER_TABLE
    , p18_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a15 out nocopy JTF_NUMBER_TABLE
    , p18_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , x_tot_amount_earnings out nocopy  NUMBER
    , x_tot_amount_adj out nocopy  NUMBER
    , x_tot_amount_adj_rec out nocopy  NUMBER
    , x_tot_amount_total out nocopy  NUMBER
    , x_tot_held_amount out nocopy  NUMBER
    , x_tot_ced out nocopy  NUMBER
    , x_tot_earn_diff out nocopy  NUMBER
    , x_total_records out nocopy  NUMBER
  )

  as
    ddx_wksht_tbl cn_wksht_get_pub.wksht_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



























    -- here's the delegated call to the old PL/SQL routine
    cn_wksht_get_pub.get_srp_wksht(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_start_record,
      p_increment_count,
      p_payrun_id,
      p_salesrep_name,
      p_employee_number,
      p_analyst_name,
      p_my_analyst,
      p_unassigned,
      p_worksheet_status,
      p_currency_code,
      p_order_by,
      ddx_wksht_tbl,
      x_tot_amount_earnings,
      x_tot_amount_adj,
      x_tot_amount_adj_rec,
      x_tot_amount_total,
      x_tot_held_amount,
      x_tot_ced,
      x_tot_earn_diff,
      x_total_records);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















    cn_wksht_get_pub_w.rosetta_table_copy_out_p1(ddx_wksht_tbl, p18_a0
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
      , p18_a11
      , p18_a12
      , p18_a13
      , p18_a14
      , p18_a15
      , p18_a16
      , p18_a17
      , p18_a18
      , p18_a19
      , p18_a20
      , p18_a21
      );








  end;

end cn_wksht_get_pub_w;

/
