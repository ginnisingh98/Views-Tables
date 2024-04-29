--------------------------------------------------------
--  DDL for Package Body CN_PAY_GROUP_DTLS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_GROUP_DTLS_PVT_W" as
  /* $Header: cnwpgdtb.pls 115.5 2002/11/27 12:20:46 pramadas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_pay_group_dtls_pvt.pay_group_dtls_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pay_group_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).period_set_name := a2(indx);
          t(ddindx).period_type := a3(indx);
          t(ddindx).period_name := a4(indx);
          t(ddindx).period_year := a5(indx);
          t(ddindx).quarter_num := a6(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_pay_group_dtls_pvt.pay_group_dtls_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).pay_group_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).period_set_name;
          a3(indx) := t(ddindx).period_type;
          a4(indx) := t(ddindx).period_name;
          a5(indx) := t(ddindx).period_year;
          a6(indx) := t(ddindx).quarter_num;
          a7(indx) := t(ddindx).start_date;
          a8(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy cn_pay_group_dtls_pvt.pay_group_sales_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_400
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pay_group_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).period_set_name := a2(indx);
          t(ddindx).period_type := a3(indx);
          t(ddindx).salesrep_name := a4(indx);
          t(ddindx).employee_number := a5(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cn_pay_group_dtls_pvt.pay_group_sales_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_400
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_400();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_400();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).pay_group_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).period_set_name;
          a3(indx) := t(ddindx).period_type;
          a4(indx) := t(ddindx).salesrep_name;
          a5(indx) := t(ddindx).employee_number;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_pay_group_dtls_pvt.pay_group_roles_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pay_group_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).period_set_name := a2(indx);
          t(ddindx).period_type := a3(indx);
          t(ddindx).role_name := a4(indx);
          t(ddindx).role_id := a5(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_pay_group_dtls_pvt.pay_group_roles_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).pay_group_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).period_set_name;
          a3(indx) := t(ddindx).period_type;
          a4(indx) := t(ddindx).role_name;
          a5(indx) := t(ddindx).role_id;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure get_pay_group_dtls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_record  NUMBER
    , p_fetch_size  NUMBER
    , p_pay_group_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , x_total_record out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_pay_group_dtls cn_pay_group_dtls_pvt.pay_group_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    cn_pay_group_dtls_pvt.get_pay_group_dtls(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_start_record,
      p_fetch_size,
      p_pay_group_id,
      ddx_pay_group_dtls,
      x_total_record,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_pay_group_dtls_pvt_w.rosetta_table_copy_out_p3(ddx_pay_group_dtls, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      );




  end;

  procedure get_pay_group_sales(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_record  NUMBER
    , p_fetch_size  NUMBER
    , p_pay_group_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , x_total_record out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_pay_group_sales cn_pay_group_dtls_pvt.pay_group_sales_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    cn_pay_group_dtls_pvt.get_pay_group_sales(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_start_record,
      p_fetch_size,
      p_pay_group_id,
      ddx_pay_group_sales,
      x_total_record,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_pay_group_dtls_pvt_w.rosetta_table_copy_out_p4(ddx_pay_group_sales, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );




  end;

  procedure get_pay_group_roles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_record  NUMBER
    , p_fetch_size  NUMBER
    , p_pay_group_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , x_total_record out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_pay_group_roles cn_pay_group_dtls_pvt.pay_group_roles_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    cn_pay_group_dtls_pvt.get_pay_group_roles(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_start_record,
      p_fetch_size,
      p_pay_group_id,
      ddx_pay_group_roles,
      x_total_record,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_pay_group_dtls_pvt_w.rosetta_table_copy_out_p5(ddx_pay_group_roles, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );




  end;

end cn_pay_group_dtls_pvt_w;

/
