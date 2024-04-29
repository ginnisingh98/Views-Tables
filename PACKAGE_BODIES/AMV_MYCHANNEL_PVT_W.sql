--------------------------------------------------------
--  DDL for Package Body AMV_MYCHANNEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_MYCHANNEL_PVT_W" as
  /* $Header: amvwmycb.pls 120.2 2005/06/30 08:22 appldev ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy amv_mychannel_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_mychannel_pvt.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_mychannel_pvt.amv_number_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t amv_mychannel_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p4(t out nocopy amv_mychannel_pvt.amv_cat_hierarchy_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_mychannel_pvt.amv_cat_hierarchy_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_mychannel_pvt.amv_cat_hierarchy_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).hierarchy_level := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t amv_mychannel_pvt.amv_cat_hierarchy_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).hierarchy_level);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a2(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy amv_mychannel_pvt.amv_my_channel_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_mychannel_pvt.amv_my_channel_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_mychannel_pvt.amv_my_channel_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).my_channel_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).channel_type := a1(indx);
          t(ddindx).access_level_type := a2(indx);
          t(ddindx).user_or_group_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).user_or_group_type := a4(indx);
          t(ddindx).subscribing_to_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).subscribing_to_type := a6(indx);
          t(ddindx).subscription_reason_type := a7(indx);
          t(ddindx).order_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).status := a9(indx);
          t(ddindx).notify_flag := a10(indx);
          t(ddindx).notification_interval_type := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t amv_mychannel_pvt.amv_my_channel_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).my_channel_id);
          a1(indx) := t(ddindx).channel_type;
          a2(indx) := t(ddindx).access_level_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).user_or_group_id);
          a4(indx) := t(ddindx).user_or_group_type;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).subscribing_to_id);
          a6(indx) := t(ddindx).subscribing_to_type;
          a7(indx) := t(ddindx).subscription_reason_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).order_number);
          a9(indx) := t(ddindx).status;
          a10(indx) := t(ddindx).notify_flag;
          a11(indx) := t(ddindx).notification_interval_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy amv_mychannel_pvt.amv_wf_notif_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_4000
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_mychannel_pvt.amv_wf_notif_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_mychannel_pvt.amv_wf_notif_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).notification_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).subject := a1(indx);
          t(ddindx).begin_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).status := a5(indx);
          t(ddindx).priority := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).type := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t amv_mychannel_pvt.amv_wf_notif_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_4000();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_4000();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).notification_id);
          a1(indx) := t(ddindx).subject;
          a2(indx) := t(ddindx).begin_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := t(ddindx).due_date;
          a5(indx) := t(ddindx).status;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).priority);
          a7(indx) := t(ddindx).type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy amv_mychannel_pvt.amv_itemdisplay_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_mychannel_pvt.amv_itemdisplay_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_mychannel_pvt.amv_itemdisplay_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).type := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t amv_mychannel_pvt.amv_itemdisplay_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure add_subscription(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_mychannel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_mychannel_obj amv_mychannel_pvt.amv_my_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_mychannel_obj.my_channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_mychannel_obj.channel_type := p8_a1;
    ddp_mychannel_obj.access_level_type := p8_a2;
    ddp_mychannel_obj.user_or_group_id := rosetta_g_miss_num_map(p8_a3);
    ddp_mychannel_obj.user_or_group_type := p8_a4;
    ddp_mychannel_obj.subscribing_to_id := rosetta_g_miss_num_map(p8_a5);
    ddp_mychannel_obj.subscribing_to_type := p8_a6;
    ddp_mychannel_obj.subscription_reason_type := p8_a7;
    ddp_mychannel_obj.order_number := rosetta_g_miss_num_map(p8_a8);
    ddp_mychannel_obj.status := p8_a9;
    ddp_mychannel_obj.notify_flag := p8_a10;
    ddp_mychannel_obj.notification_interval_type := p8_a11;


    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.add_subscription(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_mychannel_obj,
      x_mychannel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_mychannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_mychannel_obj amv_mychannel_pvt.amv_my_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_mychannel_obj.my_channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_mychannel_obj.channel_type := p8_a1;
    ddp_mychannel_obj.access_level_type := p8_a2;
    ddp_mychannel_obj.user_or_group_id := rosetta_g_miss_num_map(p8_a3);
    ddp_mychannel_obj.user_or_group_type := p8_a4;
    ddp_mychannel_obj.subscribing_to_id := rosetta_g_miss_num_map(p8_a5);
    ddp_mychannel_obj.subscribing_to_type := p8_a6;
    ddp_mychannel_obj.subscription_reason_type := p8_a7;
    ddp_mychannel_obj.order_number := rosetta_g_miss_num_map(p8_a8);
    ddp_mychannel_obj.status := p8_a9;
    ddp_mychannel_obj.notify_flag := p8_a10;
    ddp_mychannel_obj.notification_interval_type := p8_a11;

    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.update_mychannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_mychannel_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_mychannels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_mychannel_array amv_mychannel_pvt.amv_my_channel_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.get_mychannels(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_id,
      ddx_mychannel_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_mychannel_pvt_w.rosetta_table_copy_out_p6(ddx_mychannel_array, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      );
  end;

  procedure get_mychannelspercategory(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_id  NUMBER
    , p_category_id  NUMBER
    , x_channel_array out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_channel_array amv_mychannel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.get_mychannelspercategory(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_id,
      p_category_id,
      ddx_channel_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_mychannel_pvt_w.rosetta_table_copy_out_p0(ddx_channel_array, x_channel_array);
  end;

  procedure get_mynotifications(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_user_id  NUMBER
    , p_user_name  VARCHAR2
    , p_notification_type  VARCHAR2
    , x_notification_url out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_DATE_TABLE
    , p12_a4 out nocopy JTF_DATE_TABLE
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_notifications_array amv_mychannel_pvt.amv_wf_notif_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.get_mynotifications(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_user_id,
      p_user_name,
      p_notification_type,
      x_notification_url,
      ddx_notifications_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    amv_mychannel_pvt_w.rosetta_table_copy_out_p8(ddx_notifications_array, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      );
  end;

  procedure get_itemsperuser(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_id  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_request_obj amv_mychannel_pvt.amv_request_obj_type;
    ddx_return_obj amv_mychannel_pvt.amv_return_obj_type;
    ddx_items_array amv_mychannel_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p8_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p8_a1);
    ddp_request_obj.return_total_count_flag := p8_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.get_itemsperuser(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_id,
      ddp_request_obj,
      ddx_return_obj,
      ddx_items_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p9_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p9_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_mychannel_pvt_w.rosetta_table_copy_out_p4(ddx_items_array, p10_a0
      , p10_a1
      , p10_a2
      );
  end;

  procedure get_useritems(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_user_id  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_request_obj amv_mychannel_pvt.amv_request_obj_type;
    ddx_return_obj amv_mychannel_pvt.amv_return_obj_type;
    ddx_items_array amv_mychannel_pvt.amv_itemdisplay_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_request_obj.return_total_count_flag := p9_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_mychannel_pvt.get_useritems(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      p_user_id,
      ddp_request_obj,
      ddx_return_obj,
      ddx_items_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p10_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p10_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_mychannel_pvt_w.rosetta_table_copy_out_p10(ddx_items_array, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      );
  end;

end amv_mychannel_pvt_w;

/
