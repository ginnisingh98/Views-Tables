--------------------------------------------------------
--  DDL for Package Body JTF_ASSIGN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ASSIGN_PUB_W" as
  /* $Header: jtfampwb.pls 120.2 2006/06/27 12:01:42 abraina ship $ */
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

  procedure rosetta_table_copy_in_p8(t out nocopy jtf_assign_pub.avail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).resource_type := a1(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).shift_construct_id := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t jtf_assign_pub.avail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).shift_construct_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p11(t out nocopy jtf_assign_pub.assignresources_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).terr_rsc_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).resource_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).resource_type := a2(indx);
          t(ddindx).role := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).shift_construct_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).terr_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).terr_name := a8(indx);
          t(ddindx).terr_rank := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).travel_time := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).travel_uom := a11(indx);
          t(ddindx).preference_type := a12(indx);
          t(ddindx).primary_contact_flag := a13(indx);
          t(ddindx).full_access_flag := a14(indx);
          t(ddindx).group_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).location := a16(indx);
          t(ddindx).trans_object_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).resource_source := a18(indx);
          t(ddindx).source_start_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).source_end_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).support_site_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).support_site_name := a22(indx);
          t(ddindx).web_availability_flag := a23(indx);
          t(ddindx).skill_level := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).skill_name := a25(indx);
          t(ddindx).primary_flag := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t jtf_assign_pub.assignresources_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
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
        a26.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).terr_rsc_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a2(indx) := t(ddindx).resource_type;
          a3(indx) := t(ddindx).role;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).shift_construct_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).terr_id);
          a8(indx) := t(ddindx).terr_name;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).terr_rank);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).travel_time);
          a11(indx) := t(ddindx).travel_uom;
          a12(indx) := t(ddindx).preference_type;
          a13(indx) := t(ddindx).primary_contact_flag;
          a14(indx) := t(ddindx).full_access_flag;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).group_id);
          a16(indx) := t(ddindx).location;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).trans_object_id);
          a18(indx) := t(ddindx).resource_source;
          a19(indx) := t(ddindx).source_start_date;
          a20(indx) := t(ddindx).source_end_date;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).support_site_id);
          a22(indx) := t(ddindx).support_site_name;
          a23(indx) := t(ddindx).web_availability_flag;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).skill_level);
          a25(indx) := t(ddindx).skill_name;
          a26(indx) := t(ddindx).primary_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p24(t out nocopy jtf_assign_pub.prfeng_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).engineer_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).resource_type := a1(indx);
          t(ddindx).primary_flag := a2(indx);
          t(ddindx).preferred_flag := a3(indx);
          t(ddindx).resource_class := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t jtf_assign_pub.prfeng_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).engineer_id);
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).primary_flag;
          a3(indx) := t(ddindx).preferred_flag;
          a4(indx) := t(ddindx).resource_class;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p26(t out nocopy jtf_assign_pub.preferred_engineers_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).engineer_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).resource_type := a1(indx);
          t(ddindx).preference_type := a2(indx);
          t(ddindx).primary_flag := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t jtf_assign_pub.preferred_engineers_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).engineer_id);
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).preference_type;
          a3(indx) := t(ddindx).primary_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p28(t out nocopy jtf_assign_pub.escalations_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).source_object_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).source_object_type := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t jtf_assign_pub.escalations_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).source_object_id);
          a1(indx) := t(ddindx).source_object_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure rosetta_table_copy_in_p30(t out nocopy jtf_assign_pub.excluded_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).resource_type := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t jtf_assign_pub.excluded_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a1(indx) := t(ddindx).resource_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure get_assign_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_category_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_inventory_org_id  NUMBER
    , p_problem_code  VARCHAR2
    , p_calling_doc_id  NUMBER
    , p_calling_doc_type  VARCHAR2
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p32_a0 out nocopy JTF_NUMBER_TABLE
    , p32_a1 out nocopy JTF_NUMBER_TABLE
    , p32_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a4 out nocopy JTF_DATE_TABLE
    , p32_a5 out nocopy JTF_DATE_TABLE
    , p32_a6 out nocopy JTF_NUMBER_TABLE
    , p32_a7 out nocopy JTF_NUMBER_TABLE
    , p32_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p32_a9 out nocopy JTF_NUMBER_TABLE
    , p32_a10 out nocopy JTF_NUMBER_TABLE
    , p32_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a15 out nocopy JTF_NUMBER_TABLE
    , p32_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a17 out nocopy JTF_NUMBER_TABLE
    , p32_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a19 out nocopy JTF_DATE_TABLE
    , p32_a20 out nocopy JTF_DATE_TABLE
    , p32_a21 out nocopy JTF_NUMBER_TABLE
    , p32_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p32_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a24 out nocopy JTF_NUMBER_TABLE
    , p32_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p26_a0  NUMBER := 0-1962.0724
    , p26_a1  NUMBER := 0-1962.0724
    , p26_a2  VARCHAR2 := fnd_api.g_miss_char
    , p26_a3  NUMBER := 0-1962.0724
    , p26_a4  VARCHAR2 := fnd_api.g_miss_char
    , p26_a5  VARCHAR2 := fnd_api.g_miss_char
    , p26_a6  VARCHAR2 := fnd_api.g_miss_char
    , p26_a7  VARCHAR2 := fnd_api.g_miss_char
    , p26_a8  VARCHAR2 := fnd_api.g_miss_char
    , p26_a9  VARCHAR2 := fnd_api.g_miss_char
    , p26_a10  VARCHAR2 := fnd_api.g_miss_char
    , p26_a11  NUMBER := 0-1962.0724
    , p26_a12  NUMBER := 0-1962.0724
    , p26_a13  NUMBER := 0-1962.0724
    , p26_a14  NUMBER := 0-1962.0724
    , p26_a15  VARCHAR2 := fnd_api.g_miss_char
    , p26_a16  NUMBER := 0-1962.0724
    , p26_a17  NUMBER := 0-1962.0724
    , p26_a18  NUMBER := 0-1962.0724
    , p26_a19  NUMBER := 0-1962.0724
    , p26_a20  VARCHAR2 := fnd_api.g_miss_char
    , p26_a21  NUMBER := 0-1962.0724
    , p26_a22  VARCHAR2 := fnd_api.g_miss_char
    , p26_a23  VARCHAR2 := fnd_api.g_miss_char
    , p26_a24  VARCHAR2 := fnd_api.g_miss_char
    , p26_a25  VARCHAR2 := fnd_api.g_miss_char
    , p26_a26  VARCHAR2 := fnd_api.g_miss_char
    , p26_a27  VARCHAR2 := fnd_api.g_miss_char
    , p26_a28  VARCHAR2 := fnd_api.g_miss_char
    , p26_a29  VARCHAR2 := fnd_api.g_miss_char
    , p26_a30  VARCHAR2 := fnd_api.g_miss_char
    , p26_a31  VARCHAR2 := fnd_api.g_miss_char
    , p26_a32  VARCHAR2 := fnd_api.g_miss_char
    , p26_a33  VARCHAR2 := fnd_api.g_miss_char
    , p26_a34  VARCHAR2 := fnd_api.g_miss_char
    , p26_a35  VARCHAR2 := fnd_api.g_miss_char
    , p26_a36  VARCHAR2 := fnd_api.g_miss_char
    , p26_a37  NUMBER := 0-1962.0724
    , p26_a38  NUMBER := 0-1962.0724
    , p26_a39  NUMBER := 0-1962.0724
    , p26_a40  NUMBER := 0-1962.0724
    , p26_a41  NUMBER := 0-1962.0724
    , p26_a42  NUMBER := 0-1962.0724
    , p26_a43  NUMBER := 0-1962.0724
    , p26_a44  NUMBER := 0-1962.0724
    , p26_a45  NUMBER := 0-1962.0724
    , p26_a46  NUMBER := 0-1962.0724
    , p26_a47  VARCHAR2 := fnd_api.g_miss_char
    , p26_a48  VARCHAR2 := fnd_api.g_miss_char
    , p26_a49  VARCHAR2 := fnd_api.g_miss_char
    , p26_a50  VARCHAR2 := fnd_api.g_miss_char
    , p26_a51  VARCHAR2 := fnd_api.g_miss_char
    , p26_a52  NUMBER := 0-1962.0724
    , p26_a53  NUMBER := 0-1962.0724
    , p27_a0  NUMBER := 0-1962.0724
    , p27_a1  NUMBER := 0-1962.0724
    , p27_a2  NUMBER := 0-1962.0724
    , p27_a3  VARCHAR2 := fnd_api.g_miss_char
    , p27_a4  NUMBER := 0-1962.0724
    , p27_a5  VARCHAR2 := fnd_api.g_miss_char
    , p27_a6  VARCHAR2 := fnd_api.g_miss_char
    , p27_a7  VARCHAR2 := fnd_api.g_miss_char
    , p27_a8  VARCHAR2 := fnd_api.g_miss_char
    , p27_a9  VARCHAR2 := fnd_api.g_miss_char
    , p27_a10  VARCHAR2 := fnd_api.g_miss_char
    , p27_a11  VARCHAR2 := fnd_api.g_miss_char
    , p27_a12  NUMBER := 0-1962.0724
    , p27_a13  NUMBER := 0-1962.0724
    , p27_a14  NUMBER := 0-1962.0724
    , p27_a15  NUMBER := 0-1962.0724
    , p27_a16  NUMBER := 0-1962.0724
    , p27_a17  NUMBER := 0-1962.0724
    , p27_a18  NUMBER := 0-1962.0724
    , p27_a19  VARCHAR2 := fnd_api.g_miss_char
    , p27_a20  NUMBER := 0-1962.0724
    , p27_a21  NUMBER := 0-1962.0724
    , p27_a22  NUMBER := 0-1962.0724
    , p27_a23  NUMBER := 0-1962.0724
    , p27_a24  VARCHAR2 := fnd_api.g_miss_char
    , p27_a25  NUMBER := 0-1962.0724
    , p27_a26  VARCHAR2 := fnd_api.g_miss_char
    , p27_a27  VARCHAR2 := fnd_api.g_miss_char
    , p27_a28  VARCHAR2 := fnd_api.g_miss_char
    , p27_a29  VARCHAR2 := fnd_api.g_miss_char
    , p27_a30  VARCHAR2 := fnd_api.g_miss_char
    , p27_a31  VARCHAR2 := fnd_api.g_miss_char
    , p27_a32  VARCHAR2 := fnd_api.g_miss_char
    , p27_a33  VARCHAR2 := fnd_api.g_miss_char
    , p27_a34  VARCHAR2 := fnd_api.g_miss_char
    , p27_a35  VARCHAR2 := fnd_api.g_miss_char
    , p27_a36  VARCHAR2 := fnd_api.g_miss_char
    , p27_a37  VARCHAR2 := fnd_api.g_miss_char
    , p27_a38  VARCHAR2 := fnd_api.g_miss_char
    , p27_a39  VARCHAR2 := fnd_api.g_miss_char
    , p27_a40  VARCHAR2 := fnd_api.g_miss_char
    , p27_a41  NUMBER := 0-1962.0724
    , p27_a42  NUMBER := 0-1962.0724
    , p27_a43  NUMBER := 0-1962.0724
    , p27_a44  NUMBER := 0-1962.0724
    , p27_a45  NUMBER := 0-1962.0724
    , p27_a46  NUMBER := 0-1962.0724
    , p27_a47  NUMBER := 0-1962.0724
    , p27_a48  NUMBER := 0-1962.0724
    , p27_a49  NUMBER := 0-1962.0724
    , p27_a50  NUMBER := 0-1962.0724
    , p27_a51  VARCHAR2 := fnd_api.g_miss_char
    , p27_a52  VARCHAR2 := fnd_api.g_miss_char
    , p27_a53  VARCHAR2 := fnd_api.g_miss_char
    , p27_a54  VARCHAR2 := fnd_api.g_miss_char
    , p27_a55  VARCHAR2 := fnd_api.g_miss_char
    , p27_a56  NUMBER := 0-1962.0724
    , p27_a57  NUMBER := 0-1962.0724
    , p28_a0  VARCHAR2 := fnd_api.g_miss_char
    , p28_a1  VARCHAR2 := fnd_api.g_miss_char
    , p28_a2  VARCHAR2 := fnd_api.g_miss_char
    , p28_a3  VARCHAR2 := fnd_api.g_miss_char
    , p28_a4  VARCHAR2 := fnd_api.g_miss_char
    , p28_a5  VARCHAR2 := fnd_api.g_miss_char
    , p28_a6  VARCHAR2 := fnd_api.g_miss_char
    , p28_a7  VARCHAR2 := fnd_api.g_miss_char
    , p28_a8  VARCHAR2 := fnd_api.g_miss_char
    , p28_a9  VARCHAR2 := fnd_api.g_miss_char
    , p28_a10  VARCHAR2 := fnd_api.g_miss_char
    , p28_a11  VARCHAR2 := fnd_api.g_miss_char
    , p28_a12  VARCHAR2 := fnd_api.g_miss_char
    , p28_a13  VARCHAR2 := fnd_api.g_miss_char
    , p28_a14  VARCHAR2 := fnd_api.g_miss_char
    , p28_a15  VARCHAR2 := fnd_api.g_miss_char
    , p28_a16  VARCHAR2 := fnd_api.g_miss_char
    , p28_a17  VARCHAR2 := fnd_api.g_miss_char
    , p28_a18  VARCHAR2 := fnd_api.g_miss_char
    , p28_a19  VARCHAR2 := fnd_api.g_miss_char
    , p28_a20  VARCHAR2 := fnd_api.g_miss_char
    , p28_a21  VARCHAR2 := fnd_api.g_miss_char
    , p28_a22  VARCHAR2 := fnd_api.g_miss_char
    , p28_a23  VARCHAR2 := fnd_api.g_miss_char
    , p28_a24  VARCHAR2 := fnd_api.g_miss_char
    , p28_a25  NUMBER := 0-1962.0724
    , p28_a26  NUMBER := 0-1962.0724
    , p28_a27  NUMBER := 0-1962.0724
    , p28_a28  NUMBER := 0-1962.0724
    , p28_a29  NUMBER := 0-1962.0724
    , p28_a30  NUMBER := 0-1962.0724
    , p28_a31  NUMBER := 0-1962.0724
    , p28_a32  NUMBER := 0-1962.0724
    , p28_a33  NUMBER := 0-1962.0724
    , p28_a34  NUMBER := 0-1962.0724
    , p28_a35  NUMBER := 0-1962.0724
    , p28_a36  NUMBER := 0-1962.0724
    , p28_a37  NUMBER := 0-1962.0724
    , p28_a38  NUMBER := 0-1962.0724
    , p28_a39  NUMBER := 0-1962.0724
    , p28_a40  NUMBER := 0-1962.0724
    , p28_a41  NUMBER := 0-1962.0724
    , p28_a42  NUMBER := 0-1962.0724
    , p28_a43  NUMBER := 0-1962.0724
    , p28_a44  NUMBER := 0-1962.0724
    , p28_a45  NUMBER := 0-1962.0724
    , p28_a46  NUMBER := 0-1962.0724
    , p28_a47  NUMBER := 0-1962.0724
    , p28_a48  NUMBER := 0-1962.0724
    , p28_a49  NUMBER := 0-1962.0724
    , p28_a50  VARCHAR2 := fnd_api.g_miss_char
    , p28_a51  VARCHAR2 := fnd_api.g_miss_char
    , p28_a52  VARCHAR2 := fnd_api.g_miss_char
    , p28_a53  VARCHAR2 := fnd_api.g_miss_char
    , p28_a54  VARCHAR2 := fnd_api.g_miss_char
    , p28_a55  VARCHAR2 := fnd_api.g_miss_char
    , p28_a56  VARCHAR2 := fnd_api.g_miss_char
    , p28_a57  VARCHAR2 := fnd_api.g_miss_char
    , p28_a58  VARCHAR2 := fnd_api.g_miss_char
    , p28_a59  VARCHAR2 := fnd_api.g_miss_char
    , p28_a60  VARCHAR2 := fnd_api.g_miss_char
    , p28_a61  VARCHAR2 := fnd_api.g_miss_char
    , p28_a62  VARCHAR2 := fnd_api.g_miss_char
    , p28_a63  VARCHAR2 := fnd_api.g_miss_char
    , p28_a64  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_sr_rec jtf_assign_pub.jtf_serv_req_rec_type;
    ddp_sr_task_rec jtf_assign_pub.jtf_srv_task_rec_type;
    ddp_defect_rec jtf_assign_pub.jtf_def_mgmt_rec_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);











    ddp_sr_rec.service_request_id := rosetta_g_miss_num_map(p26_a0);
    ddp_sr_rec.party_id := rosetta_g_miss_num_map(p26_a1);
    ddp_sr_rec.country := p26_a2;
    ddp_sr_rec.party_site_id := rosetta_g_miss_num_map(p26_a3);
    ddp_sr_rec.city := p26_a4;
    ddp_sr_rec.postal_code := p26_a5;
    ddp_sr_rec.state := p26_a6;
    ddp_sr_rec.area_code := p26_a7;
    ddp_sr_rec.county := p26_a8;
    ddp_sr_rec.comp_name_range := p26_a9;
    ddp_sr_rec.province := p26_a10;
    ddp_sr_rec.num_of_employees := rosetta_g_miss_num_map(p26_a11);
    ddp_sr_rec.incident_type_id := rosetta_g_miss_num_map(p26_a12);
    ddp_sr_rec.incident_severity_id := rosetta_g_miss_num_map(p26_a13);
    ddp_sr_rec.incident_urgency_id := rosetta_g_miss_num_map(p26_a14);
    ddp_sr_rec.problem_code := p26_a15;
    ddp_sr_rec.incident_status_id := rosetta_g_miss_num_map(p26_a16);
    ddp_sr_rec.platform_id := rosetta_g_miss_num_map(p26_a17);
    ddp_sr_rec.support_site_id := rosetta_g_miss_num_map(p26_a18);
    ddp_sr_rec.customer_site_id := rosetta_g_miss_num_map(p26_a19);
    ddp_sr_rec.sr_creation_channel := p26_a20;
    ddp_sr_rec.inventory_item_id := rosetta_g_miss_num_map(p26_a21);
    ddp_sr_rec.attribute1 := p26_a22;
    ddp_sr_rec.attribute2 := p26_a23;
    ddp_sr_rec.attribute3 := p26_a24;
    ddp_sr_rec.attribute4 := p26_a25;
    ddp_sr_rec.attribute5 := p26_a26;
    ddp_sr_rec.attribute6 := p26_a27;
    ddp_sr_rec.attribute7 := p26_a28;
    ddp_sr_rec.attribute8 := p26_a29;
    ddp_sr_rec.attribute9 := p26_a30;
    ddp_sr_rec.attribute10 := p26_a31;
    ddp_sr_rec.attribute11 := p26_a32;
    ddp_sr_rec.attribute12 := p26_a33;
    ddp_sr_rec.attribute13 := p26_a34;
    ddp_sr_rec.attribute14 := p26_a35;
    ddp_sr_rec.attribute15 := p26_a36;
    ddp_sr_rec.organization_id := rosetta_g_miss_num_map(p26_a37);
    ddp_sr_rec.squal_num12 := rosetta_g_miss_num_map(p26_a38);
    ddp_sr_rec.squal_num13 := rosetta_g_miss_num_map(p26_a39);
    ddp_sr_rec.squal_num14 := rosetta_g_miss_num_map(p26_a40);
    ddp_sr_rec.squal_num15 := rosetta_g_miss_num_map(p26_a41);
    ddp_sr_rec.squal_num16 := rosetta_g_miss_num_map(p26_a42);
    ddp_sr_rec.squal_num17 := rosetta_g_miss_num_map(p26_a43);
    ddp_sr_rec.squal_num18 := rosetta_g_miss_num_map(p26_a44);
    ddp_sr_rec.squal_num19 := rosetta_g_miss_num_map(p26_a45);
    ddp_sr_rec.squal_num30 := rosetta_g_miss_num_map(p26_a46);
    ddp_sr_rec.squal_char11 := p26_a47;
    ddp_sr_rec.squal_char12 := p26_a48;
    ddp_sr_rec.squal_char13 := p26_a49;
    ddp_sr_rec.squal_char20 := p26_a50;
    ddp_sr_rec.squal_char21 := p26_a51;
    ddp_sr_rec.item_component := rosetta_g_miss_num_map(p26_a52);
    ddp_sr_rec.item_subcomponent := rosetta_g_miss_num_map(p26_a53);

    ddp_sr_task_rec.task_id := rosetta_g_miss_num_map(p27_a0);
    ddp_sr_task_rec.service_request_id := rosetta_g_miss_num_map(p27_a1);
    ddp_sr_task_rec.party_id := rosetta_g_miss_num_map(p27_a2);
    ddp_sr_task_rec.country := p27_a3;
    ddp_sr_task_rec.party_site_id := rosetta_g_miss_num_map(p27_a4);
    ddp_sr_task_rec.city := p27_a5;
    ddp_sr_task_rec.postal_code := p27_a6;
    ddp_sr_task_rec.state := p27_a7;
    ddp_sr_task_rec.area_code := p27_a8;
    ddp_sr_task_rec.county := p27_a9;
    ddp_sr_task_rec.comp_name_range := p27_a10;
    ddp_sr_task_rec.province := p27_a11;
    ddp_sr_task_rec.num_of_employees := rosetta_g_miss_num_map(p27_a12);
    ddp_sr_task_rec.task_type_id := rosetta_g_miss_num_map(p27_a13);
    ddp_sr_task_rec.task_status_id := rosetta_g_miss_num_map(p27_a14);
    ddp_sr_task_rec.task_priority_id := rosetta_g_miss_num_map(p27_a15);
    ddp_sr_task_rec.incident_type_id := rosetta_g_miss_num_map(p27_a16);
    ddp_sr_task_rec.incident_severity_id := rosetta_g_miss_num_map(p27_a17);
    ddp_sr_task_rec.incident_urgency_id := rosetta_g_miss_num_map(p27_a18);
    ddp_sr_task_rec.problem_code := p27_a19;
    ddp_sr_task_rec.incident_status_id := rosetta_g_miss_num_map(p27_a20);
    ddp_sr_task_rec.platform_id := rosetta_g_miss_num_map(p27_a21);
    ddp_sr_task_rec.support_site_id := rosetta_g_miss_num_map(p27_a22);
    ddp_sr_task_rec.customer_site_id := rosetta_g_miss_num_map(p27_a23);
    ddp_sr_task_rec.sr_creation_channel := p27_a24;
    ddp_sr_task_rec.inventory_item_id := rosetta_g_miss_num_map(p27_a25);
    ddp_sr_task_rec.attribute1 := p27_a26;
    ddp_sr_task_rec.attribute2 := p27_a27;
    ddp_sr_task_rec.attribute3 := p27_a28;
    ddp_sr_task_rec.attribute4 := p27_a29;
    ddp_sr_task_rec.attribute5 := p27_a30;
    ddp_sr_task_rec.attribute6 := p27_a31;
    ddp_sr_task_rec.attribute7 := p27_a32;
    ddp_sr_task_rec.attribute8 := p27_a33;
    ddp_sr_task_rec.attribute9 := p27_a34;
    ddp_sr_task_rec.attribute10 := p27_a35;
    ddp_sr_task_rec.attribute11 := p27_a36;
    ddp_sr_task_rec.attribute12 := p27_a37;
    ddp_sr_task_rec.attribute13 := p27_a38;
    ddp_sr_task_rec.attribute14 := p27_a39;
    ddp_sr_task_rec.attribute15 := p27_a40;
    ddp_sr_task_rec.organization_id := rosetta_g_miss_num_map(p27_a41);
    ddp_sr_task_rec.squal_num12 := rosetta_g_miss_num_map(p27_a42);
    ddp_sr_task_rec.squal_num13 := rosetta_g_miss_num_map(p27_a43);
    ddp_sr_task_rec.squal_num14 := rosetta_g_miss_num_map(p27_a44);
    ddp_sr_task_rec.squal_num15 := rosetta_g_miss_num_map(p27_a45);
    ddp_sr_task_rec.squal_num16 := rosetta_g_miss_num_map(p27_a46);
    ddp_sr_task_rec.squal_num17 := rosetta_g_miss_num_map(p27_a47);
    ddp_sr_task_rec.squal_num18 := rosetta_g_miss_num_map(p27_a48);
    ddp_sr_task_rec.squal_num19 := rosetta_g_miss_num_map(p27_a49);
    ddp_sr_task_rec.squal_num30 := rosetta_g_miss_num_map(p27_a50);
    ddp_sr_task_rec.squal_char11 := p27_a51;
    ddp_sr_task_rec.squal_char12 := p27_a52;
    ddp_sr_task_rec.squal_char13 := p27_a53;
    ddp_sr_task_rec.squal_char20 := p27_a54;
    ddp_sr_task_rec.squal_char21 := p27_a55;
    ddp_sr_task_rec.item_component := rosetta_g_miss_num_map(p27_a56);
    ddp_sr_task_rec.item_subcomponent := rosetta_g_miss_num_map(p27_a57);

    ddp_defect_rec.squal_char01 := p28_a0;
    ddp_defect_rec.squal_char02 := p28_a1;
    ddp_defect_rec.squal_char03 := p28_a2;
    ddp_defect_rec.squal_char04 := p28_a3;
    ddp_defect_rec.squal_char05 := p28_a4;
    ddp_defect_rec.squal_char06 := p28_a5;
    ddp_defect_rec.squal_char07 := p28_a6;
    ddp_defect_rec.squal_char08 := p28_a7;
    ddp_defect_rec.squal_char09 := p28_a8;
    ddp_defect_rec.squal_char10 := p28_a9;
    ddp_defect_rec.squal_char11 := p28_a10;
    ddp_defect_rec.squal_char12 := p28_a11;
    ddp_defect_rec.squal_char13 := p28_a12;
    ddp_defect_rec.squal_char14 := p28_a13;
    ddp_defect_rec.squal_char15 := p28_a14;
    ddp_defect_rec.squal_char16 := p28_a15;
    ddp_defect_rec.squal_char17 := p28_a16;
    ddp_defect_rec.squal_char18 := p28_a17;
    ddp_defect_rec.squal_char19 := p28_a18;
    ddp_defect_rec.squal_char20 := p28_a19;
    ddp_defect_rec.squal_char21 := p28_a20;
    ddp_defect_rec.squal_char22 := p28_a21;
    ddp_defect_rec.squal_char23 := p28_a22;
    ddp_defect_rec.squal_char24 := p28_a23;
    ddp_defect_rec.squal_char25 := p28_a24;
    ddp_defect_rec.squal_num01 := rosetta_g_miss_num_map(p28_a25);
    ddp_defect_rec.squal_num02 := rosetta_g_miss_num_map(p28_a26);
    ddp_defect_rec.squal_num03 := rosetta_g_miss_num_map(p28_a27);
    ddp_defect_rec.squal_num04 := rosetta_g_miss_num_map(p28_a28);
    ddp_defect_rec.squal_num05 := rosetta_g_miss_num_map(p28_a29);
    ddp_defect_rec.squal_num06 := rosetta_g_miss_num_map(p28_a30);
    ddp_defect_rec.squal_num07 := rosetta_g_miss_num_map(p28_a31);
    ddp_defect_rec.squal_num08 := rosetta_g_miss_num_map(p28_a32);
    ddp_defect_rec.squal_num09 := rosetta_g_miss_num_map(p28_a33);
    ddp_defect_rec.squal_num10 := rosetta_g_miss_num_map(p28_a34);
    ddp_defect_rec.squal_num11 := rosetta_g_miss_num_map(p28_a35);
    ddp_defect_rec.squal_num12 := rosetta_g_miss_num_map(p28_a36);
    ddp_defect_rec.squal_num13 := rosetta_g_miss_num_map(p28_a37);
    ddp_defect_rec.squal_num14 := rosetta_g_miss_num_map(p28_a38);
    ddp_defect_rec.squal_num15 := rosetta_g_miss_num_map(p28_a39);
    ddp_defect_rec.squal_num16 := rosetta_g_miss_num_map(p28_a40);
    ddp_defect_rec.squal_num17 := rosetta_g_miss_num_map(p28_a41);
    ddp_defect_rec.squal_num18 := rosetta_g_miss_num_map(p28_a42);
    ddp_defect_rec.squal_num19 := rosetta_g_miss_num_map(p28_a43);
    ddp_defect_rec.squal_num20 := rosetta_g_miss_num_map(p28_a44);
    ddp_defect_rec.squal_num21 := rosetta_g_miss_num_map(p28_a45);
    ddp_defect_rec.squal_num22 := rosetta_g_miss_num_map(p28_a46);
    ddp_defect_rec.squal_num23 := rosetta_g_miss_num_map(p28_a47);
    ddp_defect_rec.squal_num24 := rosetta_g_miss_num_map(p28_a48);
    ddp_defect_rec.squal_num25 := rosetta_g_miss_num_map(p28_a49);
    ddp_defect_rec.attribute1 := p28_a50;
    ddp_defect_rec.attribute2 := p28_a51;
    ddp_defect_rec.attribute3 := p28_a52;
    ddp_defect_rec.attribute4 := p28_a53;
    ddp_defect_rec.attribute5 := p28_a54;
    ddp_defect_rec.attribute6 := p28_a55;
    ddp_defect_rec.attribute7 := p28_a56;
    ddp_defect_rec.attribute8 := p28_a57;
    ddp_defect_rec.attribute9 := p28_a58;
    ddp_defect_rec.attribute10 := p28_a59;
    ddp_defect_rec.attribute11 := p28_a60;
    ddp_defect_rec.attribute12 := p28_a61;
    ddp_defect_rec.attribute13 := p28_a62;
    ddp_defect_rec.attribute14 := p28_a63;
    ddp_defect_rec.attribute15 := p28_a64;


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);






    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_resources(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_contracts_preferred_engineer,
      p_ib_preferred_engineer,
      p_contract_id,
      p_customer_product_id,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      p_web_availability_flag,
      p_category_id,
      p_inventory_item_id,
      p_inventory_org_id,
      p_problem_code,
      p_calling_doc_id,
      p_calling_doc_type,
      p_column_list,
      ddp_sr_rec,
      ddp_sr_task_rec,
      ddp_defect_rec,
      p_business_process_id,
      ddp_business_process_date,
      p_filter_excluded_resource,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
































    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p32_a0
      , p32_a1
      , p32_a2
      , p32_a3
      , p32_a4
      , p32_a5
      , p32_a6
      , p32_a7
      , p32_a8
      , p32_a9
      , p32_a10
      , p32_a11
      , p32_a12
      , p32_a13
      , p32_a14
      , p32_a15
      , p32_a16
      , p32_a17
      , p32_a18
      , p32_a19
      , p32_a20
      , p32_a21
      , p32_a22
      , p32_a23
      , p32_a24
      , p32_a25
      , p32_a26
      );



  end;

  procedure get_assign_task_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_task_id  NUMBER
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p20_a0 out nocopy JTF_NUMBER_TABLE
    , p20_a1 out nocopy JTF_NUMBER_TABLE
    , p20_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a4 out nocopy JTF_DATE_TABLE
    , p20_a5 out nocopy JTF_DATE_TABLE
    , p20_a6 out nocopy JTF_NUMBER_TABLE
    , p20_a7 out nocopy JTF_NUMBER_TABLE
    , p20_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a9 out nocopy JTF_NUMBER_TABLE
    , p20_a10 out nocopy JTF_NUMBER_TABLE
    , p20_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a15 out nocopy JTF_NUMBER_TABLE
    , p20_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a17 out nocopy JTF_NUMBER_TABLE
    , p20_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a19 out nocopy JTF_DATE_TABLE
    , p20_a20 out nocopy JTF_DATE_TABLE
    , p20_a21 out nocopy JTF_NUMBER_TABLE
    , p20_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p20_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a24 out nocopy JTF_NUMBER_TABLE
    , p20_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);







    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);






    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_task_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_contracts_preferred_engineer,
      p_ib_preferred_engineer,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      p_web_availability_flag,
      p_task_id,
      p_column_list,
      p_business_process_id,
      ddp_business_process_date,
      p_filter_excluded_resource,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




















    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p20_a0
      , p20_a1
      , p20_a2
      , p20_a3
      , p20_a4
      , p20_a5
      , p20_a6
      , p20_a7
      , p20_a8
      , p20_a9
      , p20_a10
      , p20_a11
      , p20_a12
      , p20_a13
      , p20_a14
      , p20_a15
      , p20_a16
      , p20_a17
      , p20_a18
      , p20_a19
      , p20_a20
      , p20_a21
      , p20_a22
      , p20_a23
      , p20_a24
      , p20_a25
      , p20_a26
      );



  end;

  procedure get_assign_dr_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_category_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_inventory_org_id  NUMBER
    , p_problem_code  VARCHAR2
    , p_dr_id  NUMBER
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p27_a0 out nocopy JTF_NUMBER_TABLE
    , p27_a1 out nocopy JTF_NUMBER_TABLE
    , p27_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a4 out nocopy JTF_DATE_TABLE
    , p27_a5 out nocopy JTF_DATE_TABLE
    , p27_a6 out nocopy JTF_NUMBER_TABLE
    , p27_a7 out nocopy JTF_NUMBER_TABLE
    , p27_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p27_a9 out nocopy JTF_NUMBER_TABLE
    , p27_a10 out nocopy JTF_NUMBER_TABLE
    , p27_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a15 out nocopy JTF_NUMBER_TABLE
    , p27_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a17 out nocopy JTF_NUMBER_TABLE
    , p27_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a19 out nocopy JTF_DATE_TABLE
    , p27_a20 out nocopy JTF_DATE_TABLE
    , p27_a21 out nocopy JTF_NUMBER_TABLE
    , p27_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p27_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a24 out nocopy JTF_NUMBER_TABLE
    , p27_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p23_a0  NUMBER := 0-1962.0724
    , p23_a1  NUMBER := 0-1962.0724
    , p23_a2  NUMBER := 0-1962.0724
    , p23_a3  VARCHAR2 := fnd_api.g_miss_char
    , p23_a4  NUMBER := 0-1962.0724
    , p23_a5  VARCHAR2 := fnd_api.g_miss_char
    , p23_a6  VARCHAR2 := fnd_api.g_miss_char
    , p23_a7  VARCHAR2 := fnd_api.g_miss_char
    , p23_a8  VARCHAR2 := fnd_api.g_miss_char
    , p23_a9  VARCHAR2 := fnd_api.g_miss_char
    , p23_a10  VARCHAR2 := fnd_api.g_miss_char
    , p23_a11  VARCHAR2 := fnd_api.g_miss_char
    , p23_a12  NUMBER := 0-1962.0724
    , p23_a13  NUMBER := 0-1962.0724
    , p23_a14  NUMBER := 0-1962.0724
    , p23_a15  NUMBER := 0-1962.0724
    , p23_a16  NUMBER := 0-1962.0724
    , p23_a17  NUMBER := 0-1962.0724
    , p23_a18  NUMBER := 0-1962.0724
    , p23_a19  VARCHAR2 := fnd_api.g_miss_char
    , p23_a20  NUMBER := 0-1962.0724
    , p23_a21  NUMBER := 0-1962.0724
    , p23_a22  NUMBER := 0-1962.0724
    , p23_a23  NUMBER := 0-1962.0724
    , p23_a24  VARCHAR2 := fnd_api.g_miss_char
    , p23_a25  NUMBER := 0-1962.0724
    , p23_a26  VARCHAR2 := fnd_api.g_miss_char
    , p23_a27  VARCHAR2 := fnd_api.g_miss_char
    , p23_a28  VARCHAR2 := fnd_api.g_miss_char
    , p23_a29  VARCHAR2 := fnd_api.g_miss_char
    , p23_a30  VARCHAR2 := fnd_api.g_miss_char
    , p23_a31  VARCHAR2 := fnd_api.g_miss_char
    , p23_a32  VARCHAR2 := fnd_api.g_miss_char
    , p23_a33  VARCHAR2 := fnd_api.g_miss_char
    , p23_a34  VARCHAR2 := fnd_api.g_miss_char
    , p23_a35  VARCHAR2 := fnd_api.g_miss_char
    , p23_a36  VARCHAR2 := fnd_api.g_miss_char
    , p23_a37  VARCHAR2 := fnd_api.g_miss_char
    , p23_a38  VARCHAR2 := fnd_api.g_miss_char
    , p23_a39  VARCHAR2 := fnd_api.g_miss_char
    , p23_a40  VARCHAR2 := fnd_api.g_miss_char
    , p23_a41  NUMBER := 0-1962.0724
    , p23_a42  NUMBER := 0-1962.0724
    , p23_a43  NUMBER := 0-1962.0724
    , p23_a44  NUMBER := 0-1962.0724
    , p23_a45  NUMBER := 0-1962.0724
    , p23_a46  NUMBER := 0-1962.0724
    , p23_a47  NUMBER := 0-1962.0724
    , p23_a48  NUMBER := 0-1962.0724
    , p23_a49  NUMBER := 0-1962.0724
    , p23_a50  NUMBER := 0-1962.0724
    , p23_a51  VARCHAR2 := fnd_api.g_miss_char
    , p23_a52  VARCHAR2 := fnd_api.g_miss_char
    , p23_a53  VARCHAR2 := fnd_api.g_miss_char
    , p23_a54  VARCHAR2 := fnd_api.g_miss_char
    , p23_a55  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_dr_rec jtf_assign_pub.jtf_dr_rec_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);










    ddp_dr_rec.task_id := rosetta_g_miss_num_map(p23_a0);
    ddp_dr_rec.service_request_id := rosetta_g_miss_num_map(p23_a1);
    ddp_dr_rec.party_id := rosetta_g_miss_num_map(p23_a2);
    ddp_dr_rec.country := p23_a3;
    ddp_dr_rec.party_site_id := rosetta_g_miss_num_map(p23_a4);
    ddp_dr_rec.city := p23_a5;
    ddp_dr_rec.postal_code := p23_a6;
    ddp_dr_rec.state := p23_a7;
    ddp_dr_rec.area_code := p23_a8;
    ddp_dr_rec.county := p23_a9;
    ddp_dr_rec.comp_name_range := p23_a10;
    ddp_dr_rec.province := p23_a11;
    ddp_dr_rec.num_of_employees := rosetta_g_miss_num_map(p23_a12);
    ddp_dr_rec.task_type_id := rosetta_g_miss_num_map(p23_a13);
    ddp_dr_rec.task_status_id := rosetta_g_miss_num_map(p23_a14);
    ddp_dr_rec.task_priority_id := rosetta_g_miss_num_map(p23_a15);
    ddp_dr_rec.incident_type_id := rosetta_g_miss_num_map(p23_a16);
    ddp_dr_rec.incident_severity_id := rosetta_g_miss_num_map(p23_a17);
    ddp_dr_rec.incident_urgency_id := rosetta_g_miss_num_map(p23_a18);
    ddp_dr_rec.problem_code := p23_a19;
    ddp_dr_rec.incident_status_id := rosetta_g_miss_num_map(p23_a20);
    ddp_dr_rec.platform_id := rosetta_g_miss_num_map(p23_a21);
    ddp_dr_rec.support_site_id := rosetta_g_miss_num_map(p23_a22);
    ddp_dr_rec.customer_site_id := rosetta_g_miss_num_map(p23_a23);
    ddp_dr_rec.sr_creation_channel := p23_a24;
    ddp_dr_rec.inventory_item_id := rosetta_g_miss_num_map(p23_a25);
    ddp_dr_rec.attribute1 := p23_a26;
    ddp_dr_rec.attribute2 := p23_a27;
    ddp_dr_rec.attribute3 := p23_a28;
    ddp_dr_rec.attribute4 := p23_a29;
    ddp_dr_rec.attribute5 := p23_a30;
    ddp_dr_rec.attribute6 := p23_a31;
    ddp_dr_rec.attribute7 := p23_a32;
    ddp_dr_rec.attribute8 := p23_a33;
    ddp_dr_rec.attribute9 := p23_a34;
    ddp_dr_rec.attribute10 := p23_a35;
    ddp_dr_rec.attribute11 := p23_a36;
    ddp_dr_rec.attribute12 := p23_a37;
    ddp_dr_rec.attribute13 := p23_a38;
    ddp_dr_rec.attribute14 := p23_a39;
    ddp_dr_rec.attribute15 := p23_a40;
    ddp_dr_rec.organization_id := rosetta_g_miss_num_map(p23_a41);
    ddp_dr_rec.squal_num12 := rosetta_g_miss_num_map(p23_a42);
    ddp_dr_rec.squal_num13 := rosetta_g_miss_num_map(p23_a43);
    ddp_dr_rec.squal_num14 := rosetta_g_miss_num_map(p23_a44);
    ddp_dr_rec.squal_num15 := rosetta_g_miss_num_map(p23_a45);
    ddp_dr_rec.squal_num16 := rosetta_g_miss_num_map(p23_a46);
    ddp_dr_rec.squal_num17 := rosetta_g_miss_num_map(p23_a47);
    ddp_dr_rec.squal_num18 := rosetta_g_miss_num_map(p23_a48);
    ddp_dr_rec.squal_num19 := rosetta_g_miss_num_map(p23_a49);
    ddp_dr_rec.squal_num30 := rosetta_g_miss_num_map(p23_a50);
    ddp_dr_rec.squal_char11 := p23_a51;
    ddp_dr_rec.squal_char12 := p23_a52;
    ddp_dr_rec.squal_char13 := p23_a53;
    ddp_dr_rec.squal_char20 := p23_a54;
    ddp_dr_rec.squal_char21 := p23_a55;


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);






    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_dr_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_contracts_preferred_engineer,
      p_ib_preferred_engineer,
      p_contract_id,
      p_customer_product_id,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      p_web_availability_flag,
      p_category_id,
      p_inventory_item_id,
      p_inventory_org_id,
      p_problem_code,
      p_dr_id,
      p_column_list,
      ddp_dr_rec,
      p_business_process_id,
      ddp_business_process_date,
      p_filter_excluded_resource,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



























    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p27_a0
      , p27_a1
      , p27_a2
      , p27_a3
      , p27_a4
      , p27_a5
      , p27_a6
      , p27_a7
      , p27_a8
      , p27_a9
      , p27_a10
      , p27_a11
      , p27_a12
      , p27_a13
      , p27_a14
      , p27_a15
      , p27_a16
      , p27_a17
      , p27_a18
      , p27_a19
      , p27_a20
      , p27_a21
      , p27_a22
      , p27_a23
      , p27_a24
      , p27_a25
      , p27_a26
      );



  end;

  procedure get_assign_oppr_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  VARCHAR2 := fnd_api.g_miss_char
    , p12_a18  NUMBER := 0-1962.0724
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  NUMBER := 0-1962.0724
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  NUMBER := 0-1962.0724
    , p12_a25  VARCHAR2 := fnd_api.g_miss_char
    , p12_a26  DATE := fnd_api.g_miss_date
    , p12_a27  VARCHAR2 := fnd_api.g_miss_char
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  NUMBER := 0-1962.0724
    , p12_a32  NUMBER := 0-1962.0724
    , p12_a33  NUMBER := 0-1962.0724
    , p12_a34  NUMBER := 0-1962.0724
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  VARCHAR2 := fnd_api.g_miss_char
    , p12_a48  VARCHAR2 := fnd_api.g_miss_char
    , p12_a49  VARCHAR2 := fnd_api.g_miss_char
    , p12_a50  NUMBER := 0-1962.0724
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_opportunity_rec jtf_assign_pub.jtf_oppor_rec_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);



    ddp_opportunity_rec.lead_id := rosetta_g_miss_num_map(p12_a0);
    ddp_opportunity_rec.lead_line_id := rosetta_g_miss_num_map(p12_a1);
    ddp_opportunity_rec.city := p12_a2;
    ddp_opportunity_rec.postal_code := p12_a3;
    ddp_opportunity_rec.state := p12_a4;
    ddp_opportunity_rec.province := p12_a5;
    ddp_opportunity_rec.county := p12_a6;
    ddp_opportunity_rec.country := p12_a7;
    ddp_opportunity_rec.interest_type_id := rosetta_g_miss_num_map(p12_a8);
    ddp_opportunity_rec.primary_interest_id := rosetta_g_miss_num_map(p12_a9);
    ddp_opportunity_rec.secondary_interest_id := rosetta_g_miss_num_map(p12_a10);
    ddp_opportunity_rec.contact_interest_type_id := rosetta_g_miss_num_map(p12_a11);
    ddp_opportunity_rec.contact_primary_interest_id := rosetta_g_miss_num_map(p12_a12);
    ddp_opportunity_rec.contact_secondary_interest_id := rosetta_g_miss_num_map(p12_a13);
    ddp_opportunity_rec.party_site_id := rosetta_g_miss_num_map(p12_a14);
    ddp_opportunity_rec.area_code := p12_a15;
    ddp_opportunity_rec.party_id := rosetta_g_miss_num_map(p12_a16);
    ddp_opportunity_rec.comp_name_range := p12_a17;
    ddp_opportunity_rec.partner_id := rosetta_g_miss_num_map(p12_a18);
    ddp_opportunity_rec.num_of_employees := rosetta_g_miss_num_map(p12_a19);
    ddp_opportunity_rec.category_code := p12_a20;
    ddp_opportunity_rec.party_relationship_id := rosetta_g_miss_num_map(p12_a21);
    ddp_opportunity_rec.sic_code := p12_a22;
    ddp_opportunity_rec.target_segment_current := p12_a23;
    ddp_opportunity_rec.total_amount := rosetta_g_miss_num_map(p12_a24);
    ddp_opportunity_rec.currency_code := p12_a25;
    ddp_opportunity_rec.pricing_date := rosetta_g_miss_date_in_map(p12_a26);
    ddp_opportunity_rec.channel_code := p12_a27;
    ddp_opportunity_rec.inventory_item_id := rosetta_g_miss_num_map(p12_a28);
    ddp_opportunity_rec.opp_interest_type_id := rosetta_g_miss_num_map(p12_a29);
    ddp_opportunity_rec.opp_primary_interest_id := rosetta_g_miss_num_map(p12_a30);
    ddp_opportunity_rec.opp_secondary_interest_id := rosetta_g_miss_num_map(p12_a31);
    ddp_opportunity_rec.opclss_interest_type_id := rosetta_g_miss_num_map(p12_a32);
    ddp_opportunity_rec.opclss_primary_interest_id := rosetta_g_miss_num_map(p12_a33);
    ddp_opportunity_rec.opclss_secondary_interest_id := rosetta_g_miss_num_map(p12_a34);
    ddp_opportunity_rec.attribute1 := p12_a35;
    ddp_opportunity_rec.attribute2 := p12_a36;
    ddp_opportunity_rec.attribute3 := p12_a37;
    ddp_opportunity_rec.attribute4 := p12_a38;
    ddp_opportunity_rec.attribute5 := p12_a39;
    ddp_opportunity_rec.attribute6 := p12_a40;
    ddp_opportunity_rec.attribute7 := p12_a41;
    ddp_opportunity_rec.attribute8 := p12_a42;
    ddp_opportunity_rec.attribute9 := p12_a43;
    ddp_opportunity_rec.attribute10 := p12_a44;
    ddp_opportunity_rec.attribute11 := p12_a45;
    ddp_opportunity_rec.attribute12 := p12_a46;
    ddp_opportunity_rec.attribute13 := p12_a47;
    ddp_opportunity_rec.attribute14 := p12_a48;
    ddp_opportunity_rec.attribute15 := p12_a49;
    ddp_opportunity_rec.org_id := rosetta_g_miss_num_map(p12_a50);


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_oppr_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      ddp_opportunity_rec,
      p_business_process_id,
      ddp_business_process_date,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      );



  end;

  procedure get_assign_lead_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  VARCHAR2 := fnd_api.g_miss_char
    , p12_a18  NUMBER := 0-1962.0724
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  NUMBER := 0-1962.0724
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  NUMBER := 0-1962.0724
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  DATE := fnd_api.g_miss_date
    , p12_a26  NUMBER := 0-1962.0724
    , p12_a27  NUMBER := 0-1962.0724
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  NUMBER := 0-1962.0724
    , p12_a32  VARCHAR2 := fnd_api.g_miss_char
    , p12_a33  VARCHAR2 := fnd_api.g_miss_char
    , p12_a34  VARCHAR2 := fnd_api.g_miss_char
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  NUMBER := 0-1962.0724
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_lead_rec jtf_assign_pub.jtf_lead_rec_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);



    ddp_lead_rec.sales_lead_id := rosetta_g_miss_num_map(p12_a0);
    ddp_lead_rec.sales_lead_line_id := rosetta_g_miss_num_map(p12_a1);
    ddp_lead_rec.city := p12_a2;
    ddp_lead_rec.postal_code := p12_a3;
    ddp_lead_rec.state := p12_a4;
    ddp_lead_rec.province := p12_a5;
    ddp_lead_rec.county := p12_a6;
    ddp_lead_rec.country := p12_a7;
    ddp_lead_rec.interest_type_id := rosetta_g_miss_num_map(p12_a8);
    ddp_lead_rec.primary_interest_id := rosetta_g_miss_num_map(p12_a9);
    ddp_lead_rec.secondary_interest_id := rosetta_g_miss_num_map(p12_a10);
    ddp_lead_rec.contact_interest_type_id := rosetta_g_miss_num_map(p12_a11);
    ddp_lead_rec.contact_primary_interest_id := rosetta_g_miss_num_map(p12_a12);
    ddp_lead_rec.contact_secondary_interest_id := rosetta_g_miss_num_map(p12_a13);
    ddp_lead_rec.party_site_id := rosetta_g_miss_num_map(p12_a14);
    ddp_lead_rec.area_code := p12_a15;
    ddp_lead_rec.party_id := rosetta_g_miss_num_map(p12_a16);
    ddp_lead_rec.comp_name_range := p12_a17;
    ddp_lead_rec.partner_id := rosetta_g_miss_num_map(p12_a18);
    ddp_lead_rec.num_of_employees := rosetta_g_miss_num_map(p12_a19);
    ddp_lead_rec.category_code := p12_a20;
    ddp_lead_rec.party_relationship_id := rosetta_g_miss_num_map(p12_a21);
    ddp_lead_rec.sic_code := p12_a22;
    ddp_lead_rec.budget_amount := rosetta_g_miss_num_map(p12_a23);
    ddp_lead_rec.currency_code := p12_a24;
    ddp_lead_rec.pricing_date := rosetta_g_miss_date_in_map(p12_a25);
    ddp_lead_rec.source_promotion_id := rosetta_g_miss_num_map(p12_a26);
    ddp_lead_rec.inventory_item_id := rosetta_g_miss_num_map(p12_a27);
    ddp_lead_rec.lead_interest_type_id := rosetta_g_miss_num_map(p12_a28);
    ddp_lead_rec.lead_primary_interest_id := rosetta_g_miss_num_map(p12_a29);
    ddp_lead_rec.lead_secondary_interest_id := rosetta_g_miss_num_map(p12_a30);
    ddp_lead_rec.purchase_amount := rosetta_g_miss_num_map(p12_a31);
    ddp_lead_rec.attribute1 := p12_a32;
    ddp_lead_rec.attribute2 := p12_a33;
    ddp_lead_rec.attribute3 := p12_a34;
    ddp_lead_rec.attribute4 := p12_a35;
    ddp_lead_rec.attribute5 := p12_a36;
    ddp_lead_rec.attribute6 := p12_a37;
    ddp_lead_rec.attribute7 := p12_a38;
    ddp_lead_rec.attribute8 := p12_a39;
    ddp_lead_rec.attribute9 := p12_a40;
    ddp_lead_rec.attribute10 := p12_a41;
    ddp_lead_rec.attribute11 := p12_a42;
    ddp_lead_rec.attribute12 := p12_a43;
    ddp_lead_rec.attribute13 := p12_a44;
    ddp_lead_rec.attribute14 := p12_a45;
    ddp_lead_rec.attribute15 := p12_a46;
    ddp_lead_rec.org_id := rosetta_g_miss_num_map(p12_a47);


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_lead_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      ddp_lead_rec,
      p_business_process_id,
      ddp_business_process_date,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      );



  end;

  procedure get_assign_account_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a1  VARCHAR2 := fnd_api.g_miss_char
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  NUMBER := 0-1962.0724
    , p12_a7  NUMBER := 0-1962.0724
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  VARCHAR2 := fnd_api.g_miss_char
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  VARCHAR2 := fnd_api.g_miss_char
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  VARCHAR2 := fnd_api.g_miss_char
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  VARCHAR2 := fnd_api.g_miss_char
    , p12_a26  VARCHAR2 := fnd_api.g_miss_char
    , p12_a27  VARCHAR2 := fnd_api.g_miss_char
    , p12_a28  VARCHAR2 := fnd_api.g_miss_char
    , p12_a29  VARCHAR2 := fnd_api.g_miss_char
    , p12_a30  VARCHAR2 := fnd_api.g_miss_char
    , p12_a31  VARCHAR2 := fnd_api.g_miss_char
    , p12_a32  VARCHAR2 := fnd_api.g_miss_char
    , p12_a33  VARCHAR2 := fnd_api.g_miss_char
    , p12_a34  VARCHAR2 := fnd_api.g_miss_char
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  NUMBER := 0-1962.0724
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_account_rec jtf_assign_pub.jtf_account_rec_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);



    ddp_account_rec.city := p12_a0;
    ddp_account_rec.postal_code := p12_a1;
    ddp_account_rec.state := p12_a2;
    ddp_account_rec.province := p12_a3;
    ddp_account_rec.county := p12_a4;
    ddp_account_rec.country := p12_a5;
    ddp_account_rec.interest_type_id := rosetta_g_miss_num_map(p12_a6);
    ddp_account_rec.primary_interest_id := rosetta_g_miss_num_map(p12_a7);
    ddp_account_rec.secondary_interest_id := rosetta_g_miss_num_map(p12_a8);
    ddp_account_rec.contact_interest_type_id := rosetta_g_miss_num_map(p12_a9);
    ddp_account_rec.contact_primary_interest_id := rosetta_g_miss_num_map(p12_a10);
    ddp_account_rec.contact_secondary_interest_id := rosetta_g_miss_num_map(p12_a11);
    ddp_account_rec.party_site_id := rosetta_g_miss_num_map(p12_a12);
    ddp_account_rec.area_code := p12_a13;
    ddp_account_rec.party_id := rosetta_g_miss_num_map(p12_a14);
    ddp_account_rec.comp_name_range := p12_a15;
    ddp_account_rec.partner_id := rosetta_g_miss_num_map(p12_a16);
    ddp_account_rec.num_of_employees := rosetta_g_miss_num_map(p12_a17);
    ddp_account_rec.category_code := p12_a18;
    ddp_account_rec.party_relationship_id := rosetta_g_miss_num_map(p12_a19);
    ddp_account_rec.sic_code := p12_a20;
    ddp_account_rec.attribute1 := p12_a21;
    ddp_account_rec.attribute2 := p12_a22;
    ddp_account_rec.attribute3 := p12_a23;
    ddp_account_rec.attribute4 := p12_a24;
    ddp_account_rec.attribute5 := p12_a25;
    ddp_account_rec.attribute6 := p12_a26;
    ddp_account_rec.attribute7 := p12_a27;
    ddp_account_rec.attribute8 := p12_a28;
    ddp_account_rec.attribute9 := p12_a29;
    ddp_account_rec.attribute10 := p12_a30;
    ddp_account_rec.attribute11 := p12_a31;
    ddp_account_rec.attribute12 := p12_a32;
    ddp_account_rec.attribute13 := p12_a33;
    ddp_account_rec.attribute14 := p12_a34;
    ddp_account_rec.attribute15 := p12_a35;
    ddp_account_rec.org_id := rosetta_g_miss_num_map(p12_a36);


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_account_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      ddp_account_rec,
      p_business_process_id,
      ddp_business_process_date,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      );



  end;

  procedure get_assign_esc_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_VARCHAR2_TABLE_100
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a4 out nocopy JTF_DATE_TABLE
    , p16_a5 out nocopy JTF_DATE_TABLE
    , p16_a6 out nocopy JTF_NUMBER_TABLE
    , p16_a7 out nocopy JTF_NUMBER_TABLE
    , p16_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a9 out nocopy JTF_NUMBER_TABLE
    , p16_a10 out nocopy JTF_NUMBER_TABLE
    , p16_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a15 out nocopy JTF_NUMBER_TABLE
    , p16_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a17 out nocopy JTF_NUMBER_TABLE
    , p16_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a19 out nocopy JTF_DATE_TABLE
    , p16_a20 out nocopy JTF_DATE_TABLE
    , p16_a21 out nocopy JTF_NUMBER_TABLE
    , p16_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p16_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a24 out nocopy JTF_NUMBER_TABLE
    , p16_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_esc_tbl jtf_assign_pub.escalations_tbl_type;
    ddp_business_process_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);




    jtf_assign_pub_w.rosetta_table_copy_in_p28(ddp_esc_tbl, p13_a0
      , p13_a1
      );


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_assign_esc_resources(p_api_version,
      p_init_msg_list,
      p_resource_type,
      p_role,
      p_no_of_resources,
      p_auto_select_flag,
      p_effort_duration,
      p_effort_uom,
      ddp_start_date,
      ddp_end_date,
      p_territory_flag,
      p_calendar_flag,
      p_web_availability_flag,
      ddp_esc_tbl,
      p_business_process_id,
      ddp_business_process_date,
      ddx_assign_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p16_a0
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
      , p16_a13
      , p16_a14
      , p16_a15
      , p16_a16
      , p16_a17
      , p16_a18
      , p16_a19
      , p16_a20
      , p16_a21
      , p16_a22
      , p16_a23
      , p16_a24
      , p16_a25
      , p16_a26
      );



  end;

  procedure get_excluded_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_calling_doc_id  NUMBER
    , p_calling_doc_type  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  NUMBER := 0-1962.0724
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  NUMBER := 0-1962.0724
    , p8_a42  NUMBER := 0-1962.0724
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  NUMBER := 0-1962.0724
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  NUMBER := 0-1962.0724
    , p8_a48  NUMBER := 0-1962.0724
    , p8_a49  NUMBER := 0-1962.0724
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  VARCHAR2 := fnd_api.g_miss_char
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  VARCHAR2 := fnd_api.g_miss_char
    , p8_a54  VARCHAR2 := fnd_api.g_miss_char
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  NUMBER := 0-1962.0724
    , p8_a57  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  NUMBER := 0-1962.0724
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  NUMBER := 0-1962.0724
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  NUMBER := 0-1962.0724
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  NUMBER := 0-1962.0724
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  NUMBER := 0-1962.0724
    , p9_a47  NUMBER := 0-1962.0724
    , p9_a48  NUMBER := 0-1962.0724
    , p9_a49  NUMBER := 0-1962.0724
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sr_rec jtf_assign_pub.jtf_serv_req_rec_type;
    ddp_sr_task_rec jtf_assign_pub.jtf_srv_task_rec_type;
    ddp_dr_rec jtf_assign_pub.jtf_dr_rec_type;
    ddp_business_process_date date;
    ddx_excluded_resouurce_tbl jtf_assign_pub.excluded_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sr_rec.service_request_id := rosetta_g_miss_num_map(p7_a0);
    ddp_sr_rec.party_id := rosetta_g_miss_num_map(p7_a1);
    ddp_sr_rec.country := p7_a2;
    ddp_sr_rec.party_site_id := rosetta_g_miss_num_map(p7_a3);
    ddp_sr_rec.city := p7_a4;
    ddp_sr_rec.postal_code := p7_a5;
    ddp_sr_rec.state := p7_a6;
    ddp_sr_rec.area_code := p7_a7;
    ddp_sr_rec.county := p7_a8;
    ddp_sr_rec.comp_name_range := p7_a9;
    ddp_sr_rec.province := p7_a10;
    ddp_sr_rec.num_of_employees := rosetta_g_miss_num_map(p7_a11);
    ddp_sr_rec.incident_type_id := rosetta_g_miss_num_map(p7_a12);
    ddp_sr_rec.incident_severity_id := rosetta_g_miss_num_map(p7_a13);
    ddp_sr_rec.incident_urgency_id := rosetta_g_miss_num_map(p7_a14);
    ddp_sr_rec.problem_code := p7_a15;
    ddp_sr_rec.incident_status_id := rosetta_g_miss_num_map(p7_a16);
    ddp_sr_rec.platform_id := rosetta_g_miss_num_map(p7_a17);
    ddp_sr_rec.support_site_id := rosetta_g_miss_num_map(p7_a18);
    ddp_sr_rec.customer_site_id := rosetta_g_miss_num_map(p7_a19);
    ddp_sr_rec.sr_creation_channel := p7_a20;
    ddp_sr_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a21);
    ddp_sr_rec.attribute1 := p7_a22;
    ddp_sr_rec.attribute2 := p7_a23;
    ddp_sr_rec.attribute3 := p7_a24;
    ddp_sr_rec.attribute4 := p7_a25;
    ddp_sr_rec.attribute5 := p7_a26;
    ddp_sr_rec.attribute6 := p7_a27;
    ddp_sr_rec.attribute7 := p7_a28;
    ddp_sr_rec.attribute8 := p7_a29;
    ddp_sr_rec.attribute9 := p7_a30;
    ddp_sr_rec.attribute10 := p7_a31;
    ddp_sr_rec.attribute11 := p7_a32;
    ddp_sr_rec.attribute12 := p7_a33;
    ddp_sr_rec.attribute13 := p7_a34;
    ddp_sr_rec.attribute14 := p7_a35;
    ddp_sr_rec.attribute15 := p7_a36;
    ddp_sr_rec.organization_id := rosetta_g_miss_num_map(p7_a37);
    ddp_sr_rec.squal_num12 := rosetta_g_miss_num_map(p7_a38);
    ddp_sr_rec.squal_num13 := rosetta_g_miss_num_map(p7_a39);
    ddp_sr_rec.squal_num14 := rosetta_g_miss_num_map(p7_a40);
    ddp_sr_rec.squal_num15 := rosetta_g_miss_num_map(p7_a41);
    ddp_sr_rec.squal_num16 := rosetta_g_miss_num_map(p7_a42);
    ddp_sr_rec.squal_num17 := rosetta_g_miss_num_map(p7_a43);
    ddp_sr_rec.squal_num18 := rosetta_g_miss_num_map(p7_a44);
    ddp_sr_rec.squal_num19 := rosetta_g_miss_num_map(p7_a45);
    ddp_sr_rec.squal_num30 := rosetta_g_miss_num_map(p7_a46);
    ddp_sr_rec.squal_char11 := p7_a47;
    ddp_sr_rec.squal_char12 := p7_a48;
    ddp_sr_rec.squal_char13 := p7_a49;
    ddp_sr_rec.squal_char20 := p7_a50;
    ddp_sr_rec.squal_char21 := p7_a51;
    ddp_sr_rec.item_component := rosetta_g_miss_num_map(p7_a52);
    ddp_sr_rec.item_subcomponent := rosetta_g_miss_num_map(p7_a53);

    ddp_sr_task_rec.task_id := rosetta_g_miss_num_map(p8_a0);
    ddp_sr_task_rec.service_request_id := rosetta_g_miss_num_map(p8_a1);
    ddp_sr_task_rec.party_id := rosetta_g_miss_num_map(p8_a2);
    ddp_sr_task_rec.country := p8_a3;
    ddp_sr_task_rec.party_site_id := rosetta_g_miss_num_map(p8_a4);
    ddp_sr_task_rec.city := p8_a5;
    ddp_sr_task_rec.postal_code := p8_a6;
    ddp_sr_task_rec.state := p8_a7;
    ddp_sr_task_rec.area_code := p8_a8;
    ddp_sr_task_rec.county := p8_a9;
    ddp_sr_task_rec.comp_name_range := p8_a10;
    ddp_sr_task_rec.province := p8_a11;
    ddp_sr_task_rec.num_of_employees := rosetta_g_miss_num_map(p8_a12);
    ddp_sr_task_rec.task_type_id := rosetta_g_miss_num_map(p8_a13);
    ddp_sr_task_rec.task_status_id := rosetta_g_miss_num_map(p8_a14);
    ddp_sr_task_rec.task_priority_id := rosetta_g_miss_num_map(p8_a15);
    ddp_sr_task_rec.incident_type_id := rosetta_g_miss_num_map(p8_a16);
    ddp_sr_task_rec.incident_severity_id := rosetta_g_miss_num_map(p8_a17);
    ddp_sr_task_rec.incident_urgency_id := rosetta_g_miss_num_map(p8_a18);
    ddp_sr_task_rec.problem_code := p8_a19;
    ddp_sr_task_rec.incident_status_id := rosetta_g_miss_num_map(p8_a20);
    ddp_sr_task_rec.platform_id := rosetta_g_miss_num_map(p8_a21);
    ddp_sr_task_rec.support_site_id := rosetta_g_miss_num_map(p8_a22);
    ddp_sr_task_rec.customer_site_id := rosetta_g_miss_num_map(p8_a23);
    ddp_sr_task_rec.sr_creation_channel := p8_a24;
    ddp_sr_task_rec.inventory_item_id := rosetta_g_miss_num_map(p8_a25);
    ddp_sr_task_rec.attribute1 := p8_a26;
    ddp_sr_task_rec.attribute2 := p8_a27;
    ddp_sr_task_rec.attribute3 := p8_a28;
    ddp_sr_task_rec.attribute4 := p8_a29;
    ddp_sr_task_rec.attribute5 := p8_a30;
    ddp_sr_task_rec.attribute6 := p8_a31;
    ddp_sr_task_rec.attribute7 := p8_a32;
    ddp_sr_task_rec.attribute8 := p8_a33;
    ddp_sr_task_rec.attribute9 := p8_a34;
    ddp_sr_task_rec.attribute10 := p8_a35;
    ddp_sr_task_rec.attribute11 := p8_a36;
    ddp_sr_task_rec.attribute12 := p8_a37;
    ddp_sr_task_rec.attribute13 := p8_a38;
    ddp_sr_task_rec.attribute14 := p8_a39;
    ddp_sr_task_rec.attribute15 := p8_a40;
    ddp_sr_task_rec.organization_id := rosetta_g_miss_num_map(p8_a41);
    ddp_sr_task_rec.squal_num12 := rosetta_g_miss_num_map(p8_a42);
    ddp_sr_task_rec.squal_num13 := rosetta_g_miss_num_map(p8_a43);
    ddp_sr_task_rec.squal_num14 := rosetta_g_miss_num_map(p8_a44);
    ddp_sr_task_rec.squal_num15 := rosetta_g_miss_num_map(p8_a45);
    ddp_sr_task_rec.squal_num16 := rosetta_g_miss_num_map(p8_a46);
    ddp_sr_task_rec.squal_num17 := rosetta_g_miss_num_map(p8_a47);
    ddp_sr_task_rec.squal_num18 := rosetta_g_miss_num_map(p8_a48);
    ddp_sr_task_rec.squal_num19 := rosetta_g_miss_num_map(p8_a49);
    ddp_sr_task_rec.squal_num30 := rosetta_g_miss_num_map(p8_a50);
    ddp_sr_task_rec.squal_char11 := p8_a51;
    ddp_sr_task_rec.squal_char12 := p8_a52;
    ddp_sr_task_rec.squal_char13 := p8_a53;
    ddp_sr_task_rec.squal_char20 := p8_a54;
    ddp_sr_task_rec.squal_char21 := p8_a55;
    ddp_sr_task_rec.item_component := rosetta_g_miss_num_map(p8_a56);
    ddp_sr_task_rec.item_subcomponent := rosetta_g_miss_num_map(p8_a57);

    ddp_dr_rec.task_id := rosetta_g_miss_num_map(p9_a0);
    ddp_dr_rec.service_request_id := rosetta_g_miss_num_map(p9_a1);
    ddp_dr_rec.party_id := rosetta_g_miss_num_map(p9_a2);
    ddp_dr_rec.country := p9_a3;
    ddp_dr_rec.party_site_id := rosetta_g_miss_num_map(p9_a4);
    ddp_dr_rec.city := p9_a5;
    ddp_dr_rec.postal_code := p9_a6;
    ddp_dr_rec.state := p9_a7;
    ddp_dr_rec.area_code := p9_a8;
    ddp_dr_rec.county := p9_a9;
    ddp_dr_rec.comp_name_range := p9_a10;
    ddp_dr_rec.province := p9_a11;
    ddp_dr_rec.num_of_employees := rosetta_g_miss_num_map(p9_a12);
    ddp_dr_rec.task_type_id := rosetta_g_miss_num_map(p9_a13);
    ddp_dr_rec.task_status_id := rosetta_g_miss_num_map(p9_a14);
    ddp_dr_rec.task_priority_id := rosetta_g_miss_num_map(p9_a15);
    ddp_dr_rec.incident_type_id := rosetta_g_miss_num_map(p9_a16);
    ddp_dr_rec.incident_severity_id := rosetta_g_miss_num_map(p9_a17);
    ddp_dr_rec.incident_urgency_id := rosetta_g_miss_num_map(p9_a18);
    ddp_dr_rec.problem_code := p9_a19;
    ddp_dr_rec.incident_status_id := rosetta_g_miss_num_map(p9_a20);
    ddp_dr_rec.platform_id := rosetta_g_miss_num_map(p9_a21);
    ddp_dr_rec.support_site_id := rosetta_g_miss_num_map(p9_a22);
    ddp_dr_rec.customer_site_id := rosetta_g_miss_num_map(p9_a23);
    ddp_dr_rec.sr_creation_channel := p9_a24;
    ddp_dr_rec.inventory_item_id := rosetta_g_miss_num_map(p9_a25);
    ddp_dr_rec.attribute1 := p9_a26;
    ddp_dr_rec.attribute2 := p9_a27;
    ddp_dr_rec.attribute3 := p9_a28;
    ddp_dr_rec.attribute4 := p9_a29;
    ddp_dr_rec.attribute5 := p9_a30;
    ddp_dr_rec.attribute6 := p9_a31;
    ddp_dr_rec.attribute7 := p9_a32;
    ddp_dr_rec.attribute8 := p9_a33;
    ddp_dr_rec.attribute9 := p9_a34;
    ddp_dr_rec.attribute10 := p9_a35;
    ddp_dr_rec.attribute11 := p9_a36;
    ddp_dr_rec.attribute12 := p9_a37;
    ddp_dr_rec.attribute13 := p9_a38;
    ddp_dr_rec.attribute14 := p9_a39;
    ddp_dr_rec.attribute15 := p9_a40;
    ddp_dr_rec.organization_id := rosetta_g_miss_num_map(p9_a41);
    ddp_dr_rec.squal_num12 := rosetta_g_miss_num_map(p9_a42);
    ddp_dr_rec.squal_num13 := rosetta_g_miss_num_map(p9_a43);
    ddp_dr_rec.squal_num14 := rosetta_g_miss_num_map(p9_a44);
    ddp_dr_rec.squal_num15 := rosetta_g_miss_num_map(p9_a45);
    ddp_dr_rec.squal_num16 := rosetta_g_miss_num_map(p9_a46);
    ddp_dr_rec.squal_num17 := rosetta_g_miss_num_map(p9_a47);
    ddp_dr_rec.squal_num18 := rosetta_g_miss_num_map(p9_a48);
    ddp_dr_rec.squal_num19 := rosetta_g_miss_num_map(p9_a49);
    ddp_dr_rec.squal_num30 := rosetta_g_miss_num_map(p9_a50);
    ddp_dr_rec.squal_char11 := p9_a51;
    ddp_dr_rec.squal_char12 := p9_a52;
    ddp_dr_rec.squal_char13 := p9_a53;
    ddp_dr_rec.squal_char20 := p9_a54;
    ddp_dr_rec.squal_char21 := p9_a55;


    ddp_business_process_date := rosetta_g_miss_date_in_map(p_business_process_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_excluded_resources(p_api_version,
      p_init_msg_list,
      p_commit,
      p_contract_id,
      p_customer_product_id,
      p_calling_doc_id,
      p_calling_doc_type,
      ddp_sr_rec,
      ddp_sr_task_rec,
      ddp_dr_rec,
      p_business_process_id,
      ddp_business_process_date,
      ddx_excluded_resouurce_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    jtf_assign_pub_w.rosetta_table_copy_out_p30(ddx_excluded_resouurce_tbl, p12_a0
      , p12_a1
      );



  end;

  procedure get_resource_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_breakdown  NUMBER
    , p_breakdown_uom  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_continuous_task  VARCHAR2
    , x_return_status in out nocopy  VARCHAR2
    , x_msg_count in out nocopy  NUMBER
    , x_msg_data in out nocopy  VARCHAR2
    , p14_a0 in out nocopy JTF_NUMBER_TABLE
    , p14_a1 in out nocopy JTF_NUMBER_TABLE
    , p14_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 in out nocopy JTF_DATE_TABLE
    , p14_a5 in out nocopy JTF_DATE_TABLE
    , p14_a6 in out nocopy JTF_NUMBER_TABLE
    , p14_a7 in out nocopy JTF_NUMBER_TABLE
    , p14_a8 in out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a9 in out nocopy JTF_NUMBER_TABLE
    , p14_a10 in out nocopy JTF_NUMBER_TABLE
    , p14_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 in out nocopy JTF_NUMBER_TABLE
    , p14_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 in out nocopy JTF_NUMBER_TABLE
    , p14_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 in out nocopy JTF_DATE_TABLE
    , p14_a20 in out nocopy JTF_DATE_TABLE
    , p14_a21 in out nocopy JTF_NUMBER_TABLE
    , p14_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a24 in out nocopy JTF_NUMBER_TABLE
    , p14_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddx_assign_resources_tbl jtf_assign_pub.assignresources_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);





    jtf_assign_pub_w.rosetta_table_copy_in_p11(ddx_assign_resources_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_assign_pub.get_resource_availability(p_api_version,
      p_init_msg_list,
      p_commit,
      p_calendar_flag,
      p_effort_duration,
      p_effort_uom,
      p_breakdown,
      p_breakdown_uom,
      ddp_planned_start_date,
      ddp_planned_end_date,
      p_continuous_task,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_assign_resources_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    jtf_assign_pub_w.rosetta_table_copy_out_p11(ddx_assign_resources_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      );
  end;

end jtf_assign_pub_w;

/
