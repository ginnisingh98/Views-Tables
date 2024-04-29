--------------------------------------------------------
--  DDL for Package Body IEM_AGENT_INBOX_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_AGENT_INBOX_MGMT_PVT_W" as
  /* $Header: IEMPAIMB.pls 120.1 2006/02/14 15:17 chtang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy iem_agent_inbox_mgmt_pvt.message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_400
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).message_id := a0(indx);
          t(ddindx).email_account_id := a1(indx);
          t(ddindx).sender_name := a2(indx);
          t(ddindx).subject := a3(indx);
          t(ddindx).classification_name := a4(indx);
          t(ddindx).customer_name := a5(indx);
          t(ddindx).sent_date := a6(indx);
          t(ddindx).message_uid := a7(indx);
          t(ddindx).agent_account_id := a8(indx);
          t(ddindx).resource_name := a9(indx);
          t(ddindx).rt_media_item_id := a10(indx);
          t(ddindx).agent_id := a11(indx);
          t(ddindx).real_received_date := rosetta_g_miss_date_in_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iem_agent_inbox_mgmt_pvt.message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_400
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_400();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_400();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_400();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_400();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).message_id;
          a1(indx) := t(ddindx).email_account_id;
          a2(indx) := t(ddindx).sender_name;
          a3(indx) := t(ddindx).subject;
          a4(indx) := t(ddindx).classification_name;
          a5(indx) := t(ddindx).customer_name;
          a6(indx) := t(ddindx).sent_date;
          a7(indx) := t(ddindx).message_uid;
          a8(indx) := t(ddindx).agent_account_id;
          a9(indx) := t(ddindx).resource_name;
          a10(indx) := t(ddindx).rt_media_item_id;
          a11(indx) := t(ddindx).agent_id;
          a12(indx) := t(ddindx).real_received_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy iem_agent_inbox_mgmt_pvt.temp_message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_400
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
          t(ddindx).message_id := a0(indx);
          t(ddindx).email_account_id := a1(indx);
          t(ddindx).sender_name := a2(indx);
          t(ddindx).subject := a3(indx);
          t(ddindx).classification_name := a4(indx);
          t(ddindx).customer_name := a5(indx);
          t(ddindx).sent_date := a6(indx);
          t(ddindx).real_sent_date := a7(indx);
          t(ddindx).message_uid := a8(indx);
          t(ddindx).resource_name := a9(indx);
          t(ddindx).rt_media_item_id := a10(indx);
          t(ddindx).agent_id := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iem_agent_inbox_mgmt_pvt.temp_message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_400
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_400();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_400();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_400();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_400();
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
          a0(indx) := t(ddindx).message_id;
          a1(indx) := t(ddindx).email_account_id;
          a2(indx) := t(ddindx).sender_name;
          a3(indx) := t(ddindx).subject;
          a4(indx) := t(ddindx).classification_name;
          a5(indx) := t(ddindx).customer_name;
          a6(indx) := t(ddindx).sent_date;
          a7(indx) := t(ddindx).real_sent_date;
          a8(indx) := t(ddindx).message_uid;
          a9(indx) := t(ddindx).resource_name;
          a10(indx) := t(ddindx).rt_media_item_id;
          a11(indx) := t(ddindx).agent_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy iem_agent_inbox_mgmt_pvt.resource_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_name := a1(indx);
          t(ddindx).email_count := a2(indx);
          t(ddindx).last_login_time := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t iem_agent_inbox_mgmt_pvt.resource_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_name;
          a2(indx) := t(ddindx).email_count;
          a3(indx) := t(ddindx).last_login_time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure search_messages_in_inbox(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_subject  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_sender_name  VARCHAR2
    , p_sent_date_from  VARCHAR2
    , p_sent_date_to  VARCHAR2
    , p_sent_date_format  VARCHAR2
    , p_resource_name  VARCHAR2
    , p_resource_id  NUMBER
    , p_page_flag  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p16_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a5 out nocopy JTF_VARCHAR2_TABLE_400
    , p16_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a7 out nocopy JTF_NUMBER_TABLE
    , p16_a8 out nocopy JTF_NUMBER_TABLE
    , p16_a9 out nocopy JTF_VARCHAR2_TABLE_400
    , p16_a10 out nocopy JTF_NUMBER_TABLE
    , p16_a11 out nocopy JTF_NUMBER_TABLE
    , p16_a12 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_message_tbl iem_agent_inbox_mgmt_pvt.message_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    -- here's the delegated call to the old PL/SQL routine
    iem_agent_inbox_mgmt_pvt.search_messages_in_inbox(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_classification_id,
      p_subject,
      p_customer_name,
      p_sender_name,
      p_sent_date_from,
      p_sent_date_to,
      p_sent_date_format,
      p_resource_name,
      p_resource_id,
      p_page_flag,
      p_sort_column,
      p_sort_state,
      ddx_message_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















    iem_agent_inbox_mgmt_pvt_w.rosetta_table_copy_out_p1(ddx_message_tbl, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      , p16_a9
      , p16_a10
      , p16_a11
      , p16_a12
      );



  end;

  procedure show_agent_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p_resource_role  NUMBER
    , p_resource_name  VARCHAR2
    , p_transferrer_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_resource_count iem_agent_inbox_mgmt_pvt.resource_count_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    iem_agent_inbox_mgmt_pvt.show_agent_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_sort_column,
      p_sort_state,
      p_resource_role,
      p_resource_name,
      p_transferrer_id,
      ddx_resource_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    iem_agent_inbox_mgmt_pvt_w.rosetta_table_copy_out_p5(ddx_resource_count, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );



  end;

end iem_agent_inbox_mgmt_pvt_w;

/
