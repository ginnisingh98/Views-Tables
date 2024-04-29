--------------------------------------------------------
--  DDL for Package Body PVX_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_UTILITY_PVT_W" as
  /* $Header: pvxwutlb.pls 120.1 2008/02/28 22:22:48 hekkiral ship $ */
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

  procedure rosetta_table_copy_in_p11(t out nocopy pvx_utility_pvt.log_params_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).param_name := a0(indx);
          t(ddindx).param_value := a1(indx);
          t(ddindx).param_type := a2(indx);
          t(ddindx).param_lookup_type := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t pvx_utility_pvt.log_params_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).param_name;
          a1(indx) := t(ddindx).param_value;
          a2(indx) := t(ddindx).param_type;
          a3(indx) := t(ddindx).param_lookup_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

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
    pvx_utility_pvt.convert_timezone(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_user_tz_id,
      ddp_in_time,
      p_convert_type,
      x_out_time);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_history_log(p_arc_history_for_entity_code  VARCHAR2
    , p_history_for_entity_id  NUMBER
    , p_history_category_code  VARCHAR2
    , p_message_code  VARCHAR2
    , p_partner_id  NUMBER
    , p_access_level_flag  VARCHAR2
    , p_interaction_level  NUMBER
    , p_comments  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_2000
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_log_params_tbl pvx_utility_pvt.log_params_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pvx_utility_pvt_w.rosetta_table_copy_in_p11(ddp_log_params_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      );






    -- here's the delegated call to the old PL/SQL routine
    pvx_utility_pvt.create_history_log(p_arc_history_for_entity_code,
      p_history_for_entity_id,
      p_history_category_code,
      p_message_code,
      p_partner_id,
      p_access_level_flag,
      p_interaction_level,
      p_comments,
      ddp_log_params_tbl,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure get_business_days(p_from_date  date
    , p_to_date  date
    , x_bus_days out nocopy  NUMBER
  )

  as
    ddp_from_date date;
    ddp_to_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_from_date := rosetta_g_miss_date_in_map(p_from_date);

    ddp_to_date := rosetta_g_miss_date_in_map(p_to_date);


    -- here's the delegated call to the old PL/SQL routine
    pvx_utility_pvt.get_business_days(ddp_from_date,
      ddp_to_date,
      x_bus_days);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

end pvx_utility_pvt_w;

/
