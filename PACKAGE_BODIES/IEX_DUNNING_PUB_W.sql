--------------------------------------------------------
--  DDL for Package Body IEX_DUNNING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DUNNING_PUB_W" as
  /* $Header: iexwdunb.pls 120.6 2005/07/07 19:59:25 ctlee ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy iex_dunning_pub.ag_dn_xref_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ag_dn_xref_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).aging_bucket_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).aging_bucket_line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).callback_flag := a3(indx);
          t(ddindx).callback_days := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).fm_method := a5(indx);
          t(ddindx).template_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).xdo_template_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).score_range_low := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).score_range_high := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).dunning_level := a10(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a16(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iex_dunning_pub.ag_dn_xref_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ag_dn_xref_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).aging_bucket_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).aging_bucket_line_id);
          a3(indx) := t(ddindx).callback_flag;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).callback_days);
          a5(indx) := t(ddindx).fm_method;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).template_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).xdo_template_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).score_range_low);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).score_range_high);
          a10(indx) := t(ddindx).dunning_level;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy iex_dunning_pub.ag_dn_xref_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t iex_dunning_pub.ag_dn_xref_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p8(t out nocopy iex_dunning_pub.dunning_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).dunning_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).template_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).callback_yn := a2(indx);
          t(ddindx).callback_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).status := a4(indx);
          t(ddindx).campaign_sched_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).delinquency_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ffm_request_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).xml_request_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).xml_template_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).object_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).object_type := a11(indx);
          t(ddindx).dunning_level := a12(indx);
          t(ddindx).dunning_object_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).dunning_method := a14(indx);
          t(ddindx).amount_due_remaining := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).currency_code := a16(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).financial_charge := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).letter_name := a23(indx);
          t(ddindx).interest_amt := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).dunning_plan_id := rosetta_g_miss_num_map(a25(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t iex_dunning_pub.dunning_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
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
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).dunning_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).template_id);
          a2(indx) := t(ddindx).callback_yn;
          a3(indx) := t(ddindx).callback_date;
          a4(indx) := t(ddindx).status;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).campaign_sched_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).delinquency_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).ffm_request_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).xml_request_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).xml_template_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a11(indx) := t(ddindx).object_type;
          a12(indx) := t(ddindx).dunning_level;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).dunning_object_id);
          a14(indx) := t(ddindx).dunning_method;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).amount_due_remaining);
          a16(indx) := t(ddindx).currency_code;
          a17(indx) := t(ddindx).last_update_date;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a19(indx) := t(ddindx).creation_date;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).financial_charge);
          a23(indx) := t(ddindx).letter_name;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).interest_amt);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).dunning_plan_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy iex_dunning_pub.delid_numlist, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := iex_dunning_pub.delid_numlist();
  else
      if a0.count > 0 then
      t := iex_dunning_pub.delid_numlist();
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
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t iex_dunning_pub.delid_numlist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p9;

  procedure create_ag_dn_xref(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_DATE_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_DATE_TABLE
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_ag_dn_xref_id_tbl out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ag_dn_xref_tbl iex_dunning_pub.ag_dn_xref_tbl_type;
    ddx_ag_dn_xref_id_tbl iex_dunning_pub.ag_dn_xref_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_dunning_pub_w.rosetta_table_copy_in_p1(ddp_ag_dn_xref_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      );





    -- here's the delegated call to the old PL/SQL routine
    iex_dunning_pub.create_ag_dn_xref(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_ag_dn_xref_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ag_dn_xref_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    iex_dunning_pub_w.rosetta_table_copy_out_p2(ddx_ag_dn_xref_id_tbl, x_ag_dn_xref_id_tbl);
  end;

  procedure update_ag_dn_xref(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_DATE_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_DATE_TABLE
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ag_dn_xref_tbl iex_dunning_pub.ag_dn_xref_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_dunning_pub_w.rosetta_table_copy_in_p1(ddp_ag_dn_xref_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      );




    -- here's the delegated call to the old PL/SQL routine
    iex_dunning_pub.update_ag_dn_xref(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_ag_dn_xref_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end iex_dunning_pub_w;

/
