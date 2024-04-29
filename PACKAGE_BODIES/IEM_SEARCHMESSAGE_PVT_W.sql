--------------------------------------------------------
--  DDL for Package Body IEM_SEARCHMESSAGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SEARCHMESSAGE_PVT_W" as
  /* $Header: iemsearchb.pls 120.0 2005/06/02 14:10:31 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy iem_searchmessage_pvt.message_rec_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).message_id := a0(indx);
          t(ddindx).ih_media_item_id := a1(indx);
          t(ddindx).from_str := a2(indx);
          t(ddindx).to_str := a3(indx);
          t(ddindx).subject := a4(indx);
          t(ddindx).sent_date := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iem_searchmessage_pvt.message_rec_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).message_id;
          a1(indx) := t(ddindx).ih_media_item_id;
          a2(indx) := t(ddindx).from_str;
          a3(indx) := t(ddindx).to_str;
          a4(indx) := t(ddindx).subject;
          a5(indx) := t(ddindx).sent_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure searchmessages(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_resource_id  NUMBER
    , p_email_queue  VARCHAR2
    , p_sent_date_from  VARCHAR2
    , p_sent_date_to  VARCHAR2
    , p_received_date_from  date
    , p_received_date_to  date
    , p_from_str  VARCHAR2
    , p_recepients  VARCHAR2
    , p_cc_flag  VARCHAR2
    , p_subject  VARCHAR2
    , p_message_body  VARCHAR2
    , p_customer_id  NUMBER
    , p_classification  VARCHAR2
    , p_resolved_agent  VARCHAR2
    , p_resolved_group  VARCHAR2
    , p19_a0 out nocopy JTF_NUMBER_TABLE
    , p19_a1 out nocopy JTF_NUMBER_TABLE
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p19_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_received_date_from date;
    ddp_received_date_to date;
    ddx_message_tbl iem_searchmessage_pvt.message_rec_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_received_date_from := rosetta_g_miss_date_in_map(p_received_date_from);

    ddp_received_date_to := rosetta_g_miss_date_in_map(p_received_date_to);














    -- here's the delegated call to the old PL/SQL routine
    iem_searchmessage_pvt.searchmessages(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_resource_id,
      p_email_queue,
      p_sent_date_from,
      p_sent_date_to,
      ddp_received_date_from,
      ddp_received_date_to,
      p_from_str,
      p_recepients,
      p_cc_flag,
      p_subject,
      p_message_body,
      p_customer_id,
      p_classification,
      p_resolved_agent,
      p_resolved_group,
      ddx_message_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















    iem_searchmessage_pvt_w.rosetta_table_copy_out_p1(ddx_message_tbl, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      , p19_a4
      , p19_a5
      );



  end;

end iem_searchmessage_pvt_w;

/
