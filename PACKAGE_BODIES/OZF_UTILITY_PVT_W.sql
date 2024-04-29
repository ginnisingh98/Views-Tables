--------------------------------------------------------
--  DDL for Package Body OZF_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_UTILITY_PVT_W" as
  /* $Header: ozfwutlb.pls 120.1 2006/04/04 08:30:06 sshivali noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p12(t out nocopy ozf_utility_pvt.operating_units_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t ozf_utility_pvt.operating_units_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p59(t out nocopy ozf_utility_pvt.dependent_objects_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).type := a1(indx);
          t(ddindx).status := a2(indx);
          t(ddindx).owner := a3(indx);
          t(ddindx).deletable_flag := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p59;
  procedure rosetta_table_copy_out_p59(t ozf_utility_pvt.dependent_objects_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).type;
          a2(indx) := t(ddindx).status;
          a3(indx) := t(ddindx).owner;
          a4(indx) := t(ddindx).deletable_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p59;

  procedure log_message(p_log_level  NUMBER
    , p_module_name  VARCHAR2
    , p_rcs_id  VARCHAR2
    , p_pop_message  number
  )

  as
    ddp_pop_message boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    if p_pop_message is null
      then ddp_pop_message := null;
    elsif p_pop_message = 0
      then ddp_pop_message := false;
    else ddp_pop_message := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.log_message(p_log_level,
      p_module_name,
      p_rcs_id,
      ddp_pop_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure logging_enabled(p_log_level  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ozf_utility_pvt.logging_enabled(p_log_level);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure create_log(x_return_status out nocopy  VARCHAR2
    , p_arc_log_used_by  VARCHAR2
    , p_log_used_by_id  VARCHAR2
    , p_msg_data  VARCHAR2
    , p_msg_level  NUMBER
    , p_msg_type  VARCHAR2
    , p_desc  VARCHAR2
    , p_budget_id  NUMBER
    , p_threshold_id  NUMBER
    , p_transaction_id  NUMBER
    , p_notification_creat_date  date
    , p_activity_log_id  NUMBER
  )

  as
    ddp_notification_creat_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_notification_creat_date := rosetta_g_miss_date_in_map(p_notification_creat_date);


    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.create_log(x_return_status,
      p_arc_log_used_by,
      p_log_used_by_id,
      p_msg_data,
      p_msg_level,
      p_msg_type,
      p_desc,
      p_budget_id,
      p_threshold_id,
      p_transaction_id,
      ddp_notification_creat_date,
      p_activity_log_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure convert_currency(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);



    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.convert_currency(x_return_status,
      p_from_currency,
      p_to_currency,
      ddp_conv_date,
      p_from_amount,
      x_to_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure convert_timezone(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_tz_id  NUMBER
    , p_in_time  date
    , p_convert_type  VARCHAR2
    , x_out_time out nocopy  DATE
  )

  as
    ddp_in_time date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_in_time := rosetta_g_miss_date_in_map(p_in_time);



    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.convert_timezone(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_user_tz_id,
      ddp_in_time,
      p_convert_type,
      x_out_time);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure convert_currency(p_set_of_books_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_conversion_date  date
    , p_conversion_type  VARCHAR2
    , p_conversion_rate  NUMBER
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_acc_amount out nocopy  NUMBER
    , x_rate out nocopy  NUMBER
  )

  as
    ddp_conversion_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_conversion_date := rosetta_g_miss_date_in_map(p_conversion_date);







    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.convert_currency(p_set_of_books_id,
      p_from_currency,
      ddp_conversion_date,
      p_conversion_type,
      p_conversion_rate,
      p_amount,
      x_return_status,
      x_acc_amount,
      x_rate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure calculate_functional_curr(p_from_amount  NUMBER
    , p_conv_date  date
    , p_tc_currency_code  VARCHAR2
    , p_org_id  NUMBER
    , x_to_amount out nocopy  NUMBER
    , x_set_of_books_id out nocopy  NUMBER
    , x_mrc_sob_type_code out nocopy  VARCHAR2
    , x_fc_currency_code out nocopy  VARCHAR2
    , x_exchange_rate_type in out nocopy  VARCHAR2
    , x_exchange_rate in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);










    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.calculate_functional_curr(p_from_amount,
      ddp_conv_date,
      p_tc_currency_code,
      p_org_id,
      x_to_amount,
      x_set_of_books_id,
      x_mrc_sob_type_code,
      x_fc_currency_code,
      x_exchange_rate_type,
      x_exchange_rate,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure calculate_functional_currency(p_from_amount  NUMBER
    , p_conv_date  date
    , p_tc_currency_code  VARCHAR2
    , p_ledger_id  NUMBER
    , x_to_amount out nocopy  NUMBER
    , x_mrc_sob_type_code out nocopy  VARCHAR2
    , x_fc_currency_code out nocopy  VARCHAR2
    , x_exchange_rate_type in out nocopy  VARCHAR2
    , x_exchange_rate in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);









    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.calculate_functional_currency(p_from_amount,
      ddp_conv_date,
      p_tc_currency_code,
      p_ledger_id,
      x_to_amount,
      x_mrc_sob_type_code,
      x_fc_currency_code,
      x_exchange_rate_type,
      x_exchange_rate,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure convert_currency(p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_type  VARCHAR2
    , p_conv_rate  NUMBER
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_to_amount out nocopy  NUMBER
    , x_rate out nocopy  NUMBER
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);





    -- here's the delegated call to the old PL/SQL routine
    ozf_utility_pvt.convert_currency(p_from_currency,
      p_to_currency,
      p_conv_type,
      p_conv_rate,
      ddp_conv_date,
      p_from_amount,
      x_return_status,
      x_to_amount,
      x_rate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ozf_utility_pvt_w;

/
