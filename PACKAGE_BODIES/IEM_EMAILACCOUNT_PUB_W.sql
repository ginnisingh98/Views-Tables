--------------------------------------------------------
--  DDL for Package Body IEM_EMAILACCOUNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAILACCOUNT_PUB_W" as
  /* $Header: IEMVEMAB.pls 120.3.12010000.2 2009/08/27 06:13:43 shramana ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy iem_emailaccount_pub.emacnt_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).account_name := a0(indx);
          t(ddindx).db_user := a1(indx);
          t(ddindx).account_password := a2(indx);
          t(ddindx).account_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iem_emailaccount_pub.emacnt_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).account_name;
          a1(indx) := t(ddindx).db_user;
          a2(indx) := t(ddindx).account_password;
          a3(indx) := t(ddindx).account_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy iem_emailaccount_pub.msg_header_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).msg_id := a0(indx);
          t(ddindx).smtp_msg_id := a1(indx);
          t(ddindx).sender_name := a2(indx);
          t(ddindx).received_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).from_str := a4(indx);
          t(ddindx).to_str := a5(indx);
          t(ddindx).priority := a6(indx);
          t(ddindx).replyto := a7(indx);
          t(ddindx).subject := a8(indx);
          t(ddindx).classification := a9(indx);
          t(ddindx).score := a10(indx);
          t(ddindx).folder_path := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t iem_emailaccount_pub.msg_header_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).msg_id;
          a1(indx) := t(ddindx).smtp_msg_id;
          a2(indx) := t(ddindx).sender_name;
          a3(indx) := t(ddindx).received_date;
          a4(indx) := t(ddindx).from_str;
          a5(indx) := t(ddindx).to_str;
          a6(indx) := t(ddindx).priority;
          a7(indx) := t(ddindx).replyto;
          a8(indx) := t(ddindx).subject;
          a9(indx) := t(ddindx).classification;
          a10(indx) := t(ddindx).score;
          a11(indx) := t(ddindx).folder_path;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy iem_emailaccount_pub.account_info_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).email_user := a0(indx);
          t(ddindx).email_password := a1(indx);
          t(ddindx).domain := a2(indx);
          t(ddindx).db_server_id := a3(indx);
          t(ddindx).email_account_id := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t iem_emailaccount_pub.account_info_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).email_user;
          a1(indx) := t(ddindx).email_password;
          a2(indx) := t(ddindx).domain;
          a3(indx) := t(ddindx).db_server_id;
          a4(indx) := t(ddindx).email_account_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy iem_emailaccount_pub.acntdetails_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
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
          t(ddindx).account_name := a0(indx);
          t(ddindx).email_user := a1(indx);
          t(ddindx).email_address := a2(indx);
          t(ddindx).reply_to_address := a3(indx);
          t(ddindx).from_name := a4(indx);
          t(ddindx).email_account_id := a5(indx);
          t(ddindx).smtp_server := a6(indx);
          t(ddindx).port := a7(indx);
          t(ddindx).template_category_id := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t iem_emailaccount_pub.acntdetails_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).account_name;
          a1(indx) := t(ddindx).email_user;
          a2(indx) := t(ddindx).email_address;
          a3(indx) := t(ddindx).reply_to_address;
          a4(indx) := t(ddindx).from_name;
          a5(indx) := t(ddindx).email_account_id;
          a6(indx) := t(ddindx).smtp_server;
          a7(indx) := t(ddindx).port;
          a8(indx) := t(ddindx).template_category_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy iem_emailaccount_pub.agntacntdetails_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
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
          t(ddindx).user_name := a2(indx);
          t(ddindx).role := a3(indx);
          t(ddindx).last_login_time := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t iem_emailaccount_pub.agntacntdetails_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_name;
          a2(indx) := t(ddindx).user_name;
          a3(indx) := t(ddindx).role;
          a4(indx) := t(ddindx).last_login_time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy iem_emailaccount_pub.agentacnt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).agent_account_id := a0(indx);
          t(ddindx).email_account_id := a1(indx);
          t(ddindx).account_name := a2(indx);
          t(ddindx).reply_to_address := a3(indx);
          t(ddindx).from_address := a4(indx);
          t(ddindx).from_name := a5(indx);
          t(ddindx).user_name := a6(indx);
          t(ddindx).signature := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t iem_emailaccount_pub.agentacnt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).agent_account_id;
          a1(indx) := t(ddindx).email_account_id;
          a2(indx) := t(ddindx).account_name;
          a3(indx) := t(ddindx).reply_to_address;
          a4(indx) := t(ddindx).from_address;
          a5(indx) := t(ddindx).from_name;
          a6(indx) := t(ddindx).user_name;
          a7(indx) := t(ddindx).signature;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure get_emailaccount_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_email_acnt_tbl iem_emailaccount_pub.emacnt_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.get_emailaccount_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_email_acnt_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    iem_emailaccount_pub_w.rosetta_table_copy_out_p1(ddx_email_acnt_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );
  end;

  procedure getemailheaders(p_agentname  VARCHAR2
    , p_top_n  INTEGER
    , p_top_option  INTEGER
    , p_folder_path  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddmessage_headers iem_emailaccount_pub.msg_header_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.getemailheaders(p_agentname,
      p_top_n,
      p_top_option,
      p_folder_path,
      ddmessage_headers);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    iem_emailaccount_pub_w.rosetta_table_copy_out_p4(ddmessage_headers, p4_a0
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

  procedure listagentaccounts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_agent_acnt_tbl iem_emailaccount_pub.agentacnt_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.listagentaccounts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_agent_acnt_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    iem_emailaccount_pub_w.rosetta_table_copy_out_p12(ddx_agent_acnt_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );
  end;

  procedure listagentcpaccounts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_agent_acnt_tbl iem_emailaccount_pub.agentacnt_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.listagentcpaccounts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_agent_acnt_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    iem_emailaccount_pub_w.rosetta_table_copy_out_p12(ddx_agent_acnt_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );
  end;

  procedure listagentaccountdetails(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_roleid  NUMBER
    , p_resource_id  NUMBER
    , p_search_criteria  VARCHAR2
    , p_display_size  NUMBER
    , p_page_count  NUMBER
    , p_sort_by  VARCHAR2
    , p_sort_order  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_search_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_agent_acnt_dtl_data iem_emailaccount_pub.agntacntdetails_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.listagentaccountdetails(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_roleid,
      p_resource_id,
      p_search_criteria,
      p_display_size,
      p_page_count,
      p_sort_by,
      p_sort_order,
      x_return_status,
      x_msg_count,
      x_search_count,
      x_msg_data,
      ddx_agent_acnt_dtl_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    iem_emailaccount_pub_w.rosetta_table_copy_out_p10(ddx_agent_acnt_dtl_data, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      );
  end;

  procedure listaccountdetails(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_acnt_details_tbl iem_emailaccount_pub.acntdetails_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iem_emailaccount_pub.listaccountdetails(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_acnt_details_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    iem_emailaccount_pub_w.rosetta_table_copy_out_p8(ddx_acnt_details_tbl, p7_a0
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

end iem_emailaccount_pub_w;

/
