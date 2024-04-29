--------------------------------------------------------
--  DDL for Package Body IEM_MAILITEM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MAILITEM_PUB_W" as
  /* $Header: IEMPMICB.pls 120.2.12010000.3 2009/08/28 07:12:54 shramana ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy iem_mailitem_pub.email_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).email_account_id := a0(indx);
          t(ddindx).rt_classification_id := a1(indx);
          t(ddindx).rt_classification_name := a2(indx);
          t(ddindx).email_account_name := a3(indx);
          t(ddindx).email_que_count := a4(indx);
          t(ddindx).email_acq_count := a5(indx);
          t(ddindx).email_max_qwait := a6(indx);
          t(ddindx).email_max_await := a7(indx);
          t(ddindx).email_status := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iem_mailitem_pub.email_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).email_account_id;
          a1(indx) := t(ddindx).rt_classification_id;
          a2(indx) := t(ddindx).rt_classification_name;
          a3(indx) := t(ddindx).email_account_name;
          a4(indx) := t(ddindx).email_que_count;
          a5(indx) := t(ddindx).email_acq_count;
          a6(indx) := t(ddindx).email_max_qwait;
          a7(indx) := t(ddindx).email_max_await;
          a8(indx) := t(ddindx).email_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy iem_mailitem_pub.class_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rt_classification_id := a0(indx);
          t(ddindx).rt_classification_name := a1(indx);
          t(ddindx).email_count := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iem_mailitem_pub.class_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rt_classification_id;
          a1(indx) := t(ddindx).rt_classification_name;
          a2(indx) := t(ddindx).email_count;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy iem_mailitem_pub.t_number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := iem_mailitem_pub.t_number_table();
  else
      if a0.count > 0 then
      t := iem_mailitem_pub.t_number_table();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t iem_mailitem_pub.t_number_table, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy iem_mailitem_pub.acq_email_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).message_id := a0(indx);
          t(ddindx).rt_classification_id := a1(indx);
          t(ddindx).rt_classification_name := a2(indx);
          t(ddindx).rt_media_item_id := a3(indx);
          t(ddindx).rt_interaction_id := a4(indx);
          t(ddindx).email_account_id := a5(indx);
          t(ddindx).message_flag := a6(indx);
          t(ddindx).sender_name := a7(indx);
          t(ddindx).subject := a8(indx);
          t(ddindx).priority := a9(indx);
          t(ddindx).msg_status := a10(indx);
          t(ddindx).sent_date := a11(indx);
          t(ddindx).mail_item_status := a12(indx);
          t(ddindx).from_agent_id := a13(indx);
          t(ddindx).read_status := a14(indx);
          t(ddindx).description := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t iem_mailitem_pub.acq_email_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).message_id;
          a1(indx) := t(ddindx).rt_classification_id;
          a2(indx) := t(ddindx).rt_classification_name;
          a3(indx) := t(ddindx).rt_media_item_id;
          a4(indx) := t(ddindx).rt_interaction_id;
          a5(indx) := t(ddindx).email_account_id;
          a6(indx) := t(ddindx).message_flag;
          a7(indx) := t(ddindx).sender_name;
          a8(indx) := t(ddindx).subject;
          a9(indx) := t(ddindx).priority;
          a10(indx) := t(ddindx).msg_status;
          a11(indx) := t(ddindx).sent_date;
          a12(indx) := t(ddindx).mail_item_status;
          a13(indx) := t(ddindx).from_agent_id;
          a14(indx) := t(ddindx).read_status;
          a15(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy iem_mailitem_pub.queue_email_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).message_id := a0(indx);
          t(ddindx).rt_classification_id := a1(indx);
          t(ddindx).rt_classification_name := a2(indx);
          t(ddindx).email_account_id := a3(indx);
          t(ddindx).sender_name := a4(indx);
          t(ddindx).subject := a5(indx);
          t(ddindx).sent_date := a6(indx);
          t(ddindx).from_agent_id := a7(indx);
          t(ddindx).party_name := a8(indx);
          t(ddindx).party_id := a9(indx);
          t(ddindx).contact_id := a10(indx);
          t(ddindx).group_name := a11(indx);
          t(ddindx).source := a12(indx);
          t(ddindx).source_number := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t iem_mailitem_pub.queue_email_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).message_id;
          a1(indx) := t(ddindx).rt_classification_id;
          a2(indx) := t(ddindx).rt_classification_name;
          a3(indx) := t(ddindx).email_account_id;
          a4(indx) := t(ddindx).sender_name;
          a5(indx) := t(ddindx).subject;
          a6(indx) := t(ddindx).sent_date;
          a7(indx) := t(ddindx).from_agent_id;
          a8(indx) := t(ddindx).party_name;
          a9(indx) := t(ddindx).party_id;
          a10(indx) := t(ddindx).contact_id;
          a11(indx) := t(ddindx).group_name;
          a12(indx) := t(ddindx).source;
          a13(indx) := t(ddindx).source_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy iem_mailitem_pub.keyvals_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).key := a0(indx);
          t(ddindx).value := a1(indx);
          t(ddindx).datatype := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t iem_mailitem_pub.keyvals_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).key;
          a1(indx) := t(ddindx).value;
          a2(indx) := t(ddindx).datatype;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure getmailitemcount(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_tbl JTF_NUMBER_TABLE
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tbl iem_mailitem_pub.t_number_table;
    ddx_email_count iem_mailitem_pub.email_count_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_in_p4(ddp_tbl, p_tbl);





    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitemcount(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddp_tbl,
      ddx_email_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    iem_mailitem_pub_w.rosetta_table_copy_out_p1(ddx_email_count, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );



  end;

  procedure getmailitemcount(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_tbl JTF_NUMBER_TABLE
    , p_email_account_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tbl iem_mailitem_pub.t_number_table;
    ddx_class_bin iem_mailitem_pub.class_count_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_in_p4(ddp_tbl, p_tbl);






    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitemcount(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddp_tbl,
      p_email_account_id,
      ddx_class_bin,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    iem_mailitem_pub_w.rosetta_table_copy_out_p3(ddx_class_bin, p6_a0
      , p6_a1
      , p6_a2
      );



  end;

  procedure getmailitemcount(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_class_bin iem_mailitem_pub.class_count_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitemcount(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      ddx_class_bin,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_out_p3(ddx_class_bin, p4_a0
      , p4_a1
      , p4_a2
      );



  end;

  procedure getmailitemcount(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_tbl JTF_NUMBER_TABLE
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , x_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tbl iem_mailitem_pub.t_number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_in_p4(ddp_tbl, p_tbl);







    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitemcount(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddp_tbl,
      p_email_account_id,
      p_classification_id,
      x_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure getmailitem(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_tbl JTF_NUMBER_TABLE
    , p_rt_classification  NUMBER
    , p_account_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tbl iem_mailitem_pub.t_number_table;
    ddx_email_data iem_rt_proc_emails%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_in_p4(ddp_tbl, p_tbl);







    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitem(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddp_tbl,
      p_rt_classification,
      p_account_id,
      ddx_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_email_data.message_id;
    p7_a1 := ddx_email_data.email_account_id;
    p7_a2 := ddx_email_data.priority;
    p7_a3 := ddx_email_data.resource_id;
    p7_a4 := ddx_email_data.group_id;
    p7_a5 := ddx_email_data.sent_date;
    p7_a6 := ddx_email_data.received_date;
    p7_a7 := ddx_email_data.rt_classification_id;
    p7_a8 := ddx_email_data.customer_id;
    p7_a9 := ddx_email_data.contact_id;
    p7_a10 := ddx_email_data.relationship_id;
    p7_a11 := ddx_email_data.ih_interaction_id;
    p7_a12 := ddx_email_data.ih_media_item_id;
    p7_a13 := ddx_email_data.message_flag;
    p7_a14 := ddx_email_data.msg_status;
    p7_a15 := ddx_email_data.mail_item_status;
    p7_a16 := ddx_email_data.mail_proc_status;
    p7_a17 := ddx_email_data.queue_status;
    p7_a18 := ddx_email_data.category_map_id;
    p7_a19 := ddx_email_data.rule_id;
    p7_a20 := ddx_email_data.subject;
    p7_a21 := ddx_email_data.from_address;
    p7_a22 := ddx_email_data.from_resource_id;
    p7_a23 := ddx_email_data.created_by;
    p7_a24 := ddx_email_data.creation_date;
    p7_a25 := ddx_email_data.last_updated_by;
    p7_a26 := ddx_email_data.last_update_date;
    p7_a27 := ddx_email_data.last_update_login;
    p7_a28 := ddx_email_data.attribute1;
    p7_a29 := ddx_email_data.attribute2;
    p7_a30 := ddx_email_data.attribute3;
    p7_a31 := ddx_email_data.attribute4;
    p7_a32 := ddx_email_data.attribute5;
    p7_a33 := ddx_email_data.attribute6;
    p7_a34 := ddx_email_data.attribute7;
    p7_a35 := ddx_email_data.attribute8;
    p7_a36 := ddx_email_data.attribute9;
    p7_a37 := ddx_email_data.attribute10;
    p7_a38 := ddx_email_data.attribute11;
    p7_a39 := ddx_email_data.attribute12;
    p7_a40 := ddx_email_data.attribute13;
    p7_a41 := ddx_email_data.attribute14;
    p7_a42 := ddx_email_data.attribute15;
    p7_a43 := ddx_email_data.security_group_id;



  end;

  procedure getmailitem(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_tbl JTF_NUMBER_TABLE
    , p_rt_classification  NUMBER
    , p_account_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tbl iem_mailitem_pub.t_number_table;
    ddx_email_data iem_rt_proc_emails%rowtype;
    ddx_tag_key_value iem_mailitem_pub.keyvals_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_in_p4(ddp_tbl, p_tbl);









    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitem(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddp_tbl,
      p_rt_classification,
      p_account_id,
      ddx_email_data,
      ddx_tag_key_value,
      x_encrypted_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_email_data.message_id;
    p7_a1 := ddx_email_data.email_account_id;
    p7_a2 := ddx_email_data.priority;
    p7_a3 := ddx_email_data.resource_id;
    p7_a4 := ddx_email_data.group_id;
    p7_a5 := ddx_email_data.sent_date;
    p7_a6 := ddx_email_data.received_date;
    p7_a7 := ddx_email_data.rt_classification_id;
    p7_a8 := ddx_email_data.customer_id;
    p7_a9 := ddx_email_data.contact_id;
    p7_a10 := ddx_email_data.relationship_id;
    p7_a11 := ddx_email_data.ih_interaction_id;
    p7_a12 := ddx_email_data.ih_media_item_id;
    p7_a13 := ddx_email_data.message_flag;
    p7_a14 := ddx_email_data.msg_status;
    p7_a15 := ddx_email_data.mail_item_status;
    p7_a16 := ddx_email_data.mail_proc_status;
    p7_a17 := ddx_email_data.queue_status;
    p7_a18 := ddx_email_data.category_map_id;
    p7_a19 := ddx_email_data.rule_id;
    p7_a20 := ddx_email_data.subject;
    p7_a21 := ddx_email_data.from_address;
    p7_a22 := ddx_email_data.from_resource_id;
    p7_a23 := ddx_email_data.created_by;
    p7_a24 := ddx_email_data.creation_date;
    p7_a25 := ddx_email_data.last_updated_by;
    p7_a26 := ddx_email_data.last_update_date;
    p7_a27 := ddx_email_data.last_update_login;
    p7_a28 := ddx_email_data.attribute1;
    p7_a29 := ddx_email_data.attribute2;
    p7_a30 := ddx_email_data.attribute3;
    p7_a31 := ddx_email_data.attribute4;
    p7_a32 := ddx_email_data.attribute5;
    p7_a33 := ddx_email_data.attribute6;
    p7_a34 := ddx_email_data.attribute7;
    p7_a35 := ddx_email_data.attribute8;
    p7_a36 := ddx_email_data.attribute9;
    p7_a37 := ddx_email_data.attribute10;
    p7_a38 := ddx_email_data.attribute11;
    p7_a39 := ddx_email_data.attribute12;
    p7_a40 := ddx_email_data.attribute13;
    p7_a41 := ddx_email_data.attribute14;
    p7_a42 := ddx_email_data.attribute15;
    p7_a43 := ddx_email_data.security_group_id;

    iem_mailitem_pub_w.rosetta_table_copy_out_p10(ddx_tag_key_value, p8_a0
      , p8_a1
      , p8_a2
      );




  end;

  procedure getmailitem(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_acct_rt_class_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  NUMBER
    , p5_a3 out nocopy  NUMBER
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  DATE
    , p5_a7 out nocopy  NUMBER
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  NUMBER
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  NUMBER
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  NUMBER
    , p5_a24 out nocopy  DATE
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  DATE
    , p5_a27 out nocopy  NUMBER
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  VARCHAR2
    , p5_a33 out nocopy  VARCHAR2
    , p5_a34 out nocopy  VARCHAR2
    , p5_a35 out nocopy  VARCHAR2
    , p5_a36 out nocopy  VARCHAR2
    , p5_a37 out nocopy  VARCHAR2
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  VARCHAR2
    , p5_a40 out nocopy  VARCHAR2
    , p5_a41 out nocopy  VARCHAR2
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_email_data iem_rt_proc_emails%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailitem(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_acct_rt_class_id,
      ddx_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_email_data.message_id;
    p5_a1 := ddx_email_data.email_account_id;
    p5_a2 := ddx_email_data.priority;
    p5_a3 := ddx_email_data.resource_id;
    p5_a4 := ddx_email_data.group_id;
    p5_a5 := ddx_email_data.sent_date;
    p5_a6 := ddx_email_data.received_date;
    p5_a7 := ddx_email_data.rt_classification_id;
    p5_a8 := ddx_email_data.customer_id;
    p5_a9 := ddx_email_data.contact_id;
    p5_a10 := ddx_email_data.relationship_id;
    p5_a11 := ddx_email_data.ih_interaction_id;
    p5_a12 := ddx_email_data.ih_media_item_id;
    p5_a13 := ddx_email_data.message_flag;
    p5_a14 := ddx_email_data.msg_status;
    p5_a15 := ddx_email_data.mail_item_status;
    p5_a16 := ddx_email_data.mail_proc_status;
    p5_a17 := ddx_email_data.queue_status;
    p5_a18 := ddx_email_data.category_map_id;
    p5_a19 := ddx_email_data.rule_id;
    p5_a20 := ddx_email_data.subject;
    p5_a21 := ddx_email_data.from_address;
    p5_a22 := ddx_email_data.from_resource_id;
    p5_a23 := ddx_email_data.created_by;
    p5_a24 := ddx_email_data.creation_date;
    p5_a25 := ddx_email_data.last_updated_by;
    p5_a26 := ddx_email_data.last_update_date;
    p5_a27 := ddx_email_data.last_update_login;
    p5_a28 := ddx_email_data.attribute1;
    p5_a29 := ddx_email_data.attribute2;
    p5_a30 := ddx_email_data.attribute3;
    p5_a31 := ddx_email_data.attribute4;
    p5_a32 := ddx_email_data.attribute5;
    p5_a33 := ddx_email_data.attribute6;
    p5_a34 := ddx_email_data.attribute7;
    p5_a35 := ddx_email_data.attribute8;
    p5_a36 := ddx_email_data.attribute9;
    p5_a37 := ddx_email_data.attribute10;
    p5_a38 := ddx_email_data.attribute11;
    p5_a39 := ddx_email_data.attribute12;
    p5_a40 := ddx_email_data.attribute13;
    p5_a41 := ddx_email_data.attribute14;
    p5_a42 := ddx_email_data.attribute15;
    p5_a43 := ddx_email_data.security_group_id;



  end;

  procedure getgroupdetails(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_tbl out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_tbl iem_mailitem_pub.t_number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getgroupdetails(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      ddx_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    iem_mailitem_pub_w.rosetta_table_copy_out_p4(ddx_tbl, x_tbl);



  end;

  procedure updatemailitem(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  VARCHAR2
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  NUMBER
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  DATE
    , p3_a25  NUMBER
    , p3_a26  DATE
    , p3_a27  NUMBER
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_email_data iem_rt_proc_emails%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_email_data.message_id := p3_a0;
    ddp_email_data.email_account_id := p3_a1;
    ddp_email_data.priority := p3_a2;
    ddp_email_data.resource_id := p3_a3;
    ddp_email_data.group_id := p3_a4;
    ddp_email_data.sent_date := p3_a5;
    ddp_email_data.received_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_email_data.rt_classification_id := p3_a7;
    ddp_email_data.customer_id := p3_a8;
    ddp_email_data.contact_id := p3_a9;
    ddp_email_data.relationship_id := p3_a10;
    ddp_email_data.ih_interaction_id := p3_a11;
    ddp_email_data.ih_media_item_id := p3_a12;
    ddp_email_data.message_flag := p3_a13;
    ddp_email_data.msg_status := p3_a14;
    ddp_email_data.mail_item_status := p3_a15;
    ddp_email_data.mail_proc_status := p3_a16;
    ddp_email_data.queue_status := p3_a17;
    ddp_email_data.category_map_id := p3_a18;
    ddp_email_data.rule_id := p3_a19;
    ddp_email_data.subject := p3_a20;
    ddp_email_data.from_address := p3_a21;
    ddp_email_data.from_resource_id := p3_a22;
    ddp_email_data.created_by := p3_a23;
    ddp_email_data.creation_date := rosetta_g_miss_date_in_map(p3_a24);
    ddp_email_data.last_updated_by := p3_a25;
    ddp_email_data.last_update_date := rosetta_g_miss_date_in_map(p3_a26);
    ddp_email_data.last_update_login := p3_a27;
    ddp_email_data.attribute1 := p3_a28;
    ddp_email_data.attribute2 := p3_a29;
    ddp_email_data.attribute3 := p3_a30;
    ddp_email_data.attribute4 := p3_a31;
    ddp_email_data.attribute5 := p3_a32;
    ddp_email_data.attribute6 := p3_a33;
    ddp_email_data.attribute7 := p3_a34;
    ddp_email_data.attribute8 := p3_a35;
    ddp_email_data.attribute9 := p3_a36;
    ddp_email_data.attribute10 := p3_a37;
    ddp_email_data.attribute11 := p3_a38;
    ddp_email_data.attribute12 := p3_a39;
    ddp_email_data.attribute13 := p3_a40;
    ddp_email_data.attribute14 := p3_a41;
    ddp_email_data.attribute15 := p3_a42;
    ddp_email_data.security_group_id := p3_a43;




    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.updatemailitem(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure getmailiteminfo(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_message_id  NUMBER
    , p_account_id  NUMBER
    , p_agent_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_email_data iem_rt_proc_emails%rowtype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getmailiteminfo(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_message_id,
      p_account_id,
      p_agent_id,
      ddx_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_email_data.message_id;
    p6_a1 := ddx_email_data.email_account_id;
    p6_a2 := ddx_email_data.priority;
    p6_a3 := ddx_email_data.resource_id;
    p6_a4 := ddx_email_data.group_id;
    p6_a5 := ddx_email_data.sent_date;
    p6_a6 := ddx_email_data.received_date;
    p6_a7 := ddx_email_data.rt_classification_id;
    p6_a8 := ddx_email_data.customer_id;
    p6_a9 := ddx_email_data.contact_id;
    p6_a10 := ddx_email_data.relationship_id;
    p6_a11 := ddx_email_data.ih_interaction_id;
    p6_a12 := ddx_email_data.ih_media_item_id;
    p6_a13 := ddx_email_data.message_flag;
    p6_a14 := ddx_email_data.msg_status;
    p6_a15 := ddx_email_data.mail_item_status;
    p6_a16 := ddx_email_data.mail_proc_status;
    p6_a17 := ddx_email_data.queue_status;
    p6_a18 := ddx_email_data.category_map_id;
    p6_a19 := ddx_email_data.rule_id;
    p6_a20 := ddx_email_data.subject;
    p6_a21 := ddx_email_data.from_address;
    p6_a22 := ddx_email_data.from_resource_id;
    p6_a23 := ddx_email_data.created_by;
    p6_a24 := ddx_email_data.creation_date;
    p6_a25 := ddx_email_data.last_updated_by;
    p6_a26 := ddx_email_data.last_update_date;
    p6_a27 := ddx_email_data.last_update_login;
    p6_a28 := ddx_email_data.attribute1;
    p6_a29 := ddx_email_data.attribute2;
    p6_a30 := ddx_email_data.attribute3;
    p6_a31 := ddx_email_data.attribute4;
    p6_a32 := ddx_email_data.attribute5;
    p6_a33 := ddx_email_data.attribute6;
    p6_a34 := ddx_email_data.attribute7;
    p6_a35 := ddx_email_data.attribute8;
    p6_a36 := ddx_email_data.attribute9;
    p6_a37 := ddx_email_data.attribute10;
    p6_a38 := ddx_email_data.attribute11;
    p6_a39 := ddx_email_data.attribute12;
    p6_a40 := ddx_email_data.attribute13;
    p6_a41 := ddx_email_data.attribute14;
    p6_a42 := ddx_email_data.attribute15;
    p6_a43 := ddx_email_data.security_group_id;



  end;

  procedure getemailheaders(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_email_account_id  NUMBER
    , p_display_size  NUMBER
    , p_page_count  NUMBER
    , p_sort_by  VARCHAR2
    , p_sort_order  NUMBER
    , x_total_message out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_acq_email_data iem_mailitem_pub.acq_email_info_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getemailheaders(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_email_account_id,
      p_display_size,
      p_page_count,
      p_sort_by,
      p_sort_order,
      x_total_message,
      ddx_acq_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    iem_mailitem_pub_w.rosetta_table_copy_out_p6(ddx_acq_email_data, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      );



  end;

  procedure getunreademailheaders(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_display_size  NUMBER
    , p_page_count  NUMBER
    , p_sort_by  VARCHAR2
    , p_sort_order  NUMBER
    , x_total_message out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_queue_email_data iem_mailitem_pub.queue_email_info_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getunreademailheaders(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_display_size,
      p_page_count,
      p_sort_by,
      p_sort_order,
      x_total_message,
      ddx_queue_email_data,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    iem_mailitem_pub_w.rosetta_table_copy_out_p8(ddx_queue_email_data, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      );



  end;

  procedure getqueueitemdata(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_message_id  NUMBER
    , p_from_agent_id  NUMBER
    , p_to_agent_id  NUMBER
    , p_mail_item_status  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_email_data iem_rt_proc_emails%rowtype;
    ddx_tag_key_value iem_mailitem_pub.keyvals_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    iem_mailitem_pub.getqueueitemdata(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_message_id,
      p_from_agent_id,
      p_to_agent_id,
      p_mail_item_status,
      ddx_email_data,
      ddx_tag_key_value,
      x_encrypted_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_email_data.message_id;
    p7_a1 := ddx_email_data.email_account_id;
    p7_a2 := ddx_email_data.priority;
    p7_a3 := ddx_email_data.resource_id;
    p7_a4 := ddx_email_data.group_id;
    p7_a5 := ddx_email_data.sent_date;
    p7_a6 := ddx_email_data.received_date;
    p7_a7 := ddx_email_data.rt_classification_id;
    p7_a8 := ddx_email_data.customer_id;
    p7_a9 := ddx_email_data.contact_id;
    p7_a10 := ddx_email_data.relationship_id;
    p7_a11 := ddx_email_data.ih_interaction_id;
    p7_a12 := ddx_email_data.ih_media_item_id;
    p7_a13 := ddx_email_data.message_flag;
    p7_a14 := ddx_email_data.msg_status;
    p7_a15 := ddx_email_data.mail_item_status;
    p7_a16 := ddx_email_data.mail_proc_status;
    p7_a17 := ddx_email_data.queue_status;
    p7_a18 := ddx_email_data.category_map_id;
    p7_a19 := ddx_email_data.rule_id;
    p7_a20 := ddx_email_data.subject;
    p7_a21 := ddx_email_data.from_address;
    p7_a22 := ddx_email_data.from_resource_id;
    p7_a23 := ddx_email_data.created_by;
    p7_a24 := ddx_email_data.creation_date;
    p7_a25 := ddx_email_data.last_updated_by;
    p7_a26 := ddx_email_data.last_update_date;
    p7_a27 := ddx_email_data.last_update_login;
    p7_a28 := ddx_email_data.attribute1;
    p7_a29 := ddx_email_data.attribute2;
    p7_a30 := ddx_email_data.attribute3;
    p7_a31 := ddx_email_data.attribute4;
    p7_a32 := ddx_email_data.attribute5;
    p7_a33 := ddx_email_data.attribute6;
    p7_a34 := ddx_email_data.attribute7;
    p7_a35 := ddx_email_data.attribute8;
    p7_a36 := ddx_email_data.attribute9;
    p7_a37 := ddx_email_data.attribute10;
    p7_a38 := ddx_email_data.attribute11;
    p7_a39 := ddx_email_data.attribute12;
    p7_a40 := ddx_email_data.attribute13;
    p7_a41 := ddx_email_data.attribute14;
    p7_a42 := ddx_email_data.attribute15;
    p7_a43 := ddx_email_data.security_group_id;

    iem_mailitem_pub_w.rosetta_table_copy_out_p10(ddx_tag_key_value, p8_a0
      , p8_a1
      , p8_a2
      );




  end;

end iem_mailitem_pub_w;

/
