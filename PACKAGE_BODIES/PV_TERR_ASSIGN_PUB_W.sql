--------------------------------------------------------
--  DDL for Package Body PV_TERR_ASSIGN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TERR_ASSIGN_PUB_W" as
  /* $Header: pvxwptab.pls 120.1 2005/08/10 01:44 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p15(t out nocopy pv_terr_assign_pub.partner_qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_name := a0(indx);
          t(ddindx).party_site_id := a1(indx);
          t(ddindx).party_id := a2(indx);
          t(ddindx).area_code := a3(indx);
          t(ddindx).city := a4(indx);
          t(ddindx).country := a5(indx);
          t(ddindx).county := a6(indx);
          t(ddindx).postal_code := a7(indx);
          t(ddindx).province := a8(indx);
          t(ddindx).state := a9(indx);
          t(ddindx).annual_revenue := a10(indx);
          t(ddindx).number_of_employee := a11(indx);
          t(ddindx).customer_category_code := a12(indx);
          t(ddindx).partner_type := a13(indx);
          t(ddindx).partner_level := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t pv_terr_assign_pub.partner_qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_400();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_400();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).partner_name;
          a1(indx) := t(ddindx).party_site_id;
          a2(indx) := t(ddindx).party_id;
          a3(indx) := t(ddindx).area_code;
          a4(indx) := t(ddindx).city;
          a5(indx) := t(ddindx).country;
          a6(indx) := t(ddindx).county;
          a7(indx) := t(ddindx).postal_code;
          a8(indx) := t(ddindx).province;
          a9(indx) := t(ddindx).state;
          a10(indx) := t(ddindx).annual_revenue;
          a11(indx) := t(ddindx).number_of_employee;
          a12(indx) := t(ddindx).customer_category_code;
          a13(indx) := t(ddindx).partner_type;
          a14(indx) := t(ddindx).partner_level;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p19(t out nocopy pv_terr_assign_pub.prtnr_qflr_flg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).partner_name_flg := a0(indx);
          t(ddindx).party_site_id_flg := a1(indx);
          t(ddindx).area_code_flg := a2(indx);
          t(ddindx).city_flg := a3(indx);
          t(ddindx).country_flg := a4(indx);
          t(ddindx).county_flg := a5(indx);
          t(ddindx).postal_code_flg := a6(indx);
          t(ddindx).province_flg := a7(indx);
          t(ddindx).state_flg := a8(indx);
          t(ddindx).annual_revenue_flg := a9(indx);
          t(ddindx).number_of_employee_flg := a10(indx);
          t(ddindx).cust_catgy_code_flg := a11(indx);
          t(ddindx).partner_type_flg := a12(indx);
          t(ddindx).partner_level_flg := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t pv_terr_assign_pub.prtnr_qflr_flg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).partner_name_flg;
          a1(indx) := t(ddindx).party_site_id_flg;
          a2(indx) := t(ddindx).area_code_flg;
          a3(indx) := t(ddindx).city_flg;
          a4(indx) := t(ddindx).country_flg;
          a5(indx) := t(ddindx).county_flg;
          a6(indx) := t(ddindx).postal_code_flg;
          a7(indx) := t(ddindx).province_flg;
          a8(indx) := t(ddindx).state_flg;
          a9(indx) := t(ddindx).annual_revenue_flg;
          a10(indx) := t(ddindx).number_of_employee_flg;
          a11(indx) := t(ddindx).cust_catgy_code_flg;
          a12(indx) := t(ddindx).partner_type_flg;
          a13(indx) := t(ddindx).partner_level_flg;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p22(t out nocopy pv_terr_assign_pub.resourcelist, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_terr_assign_pub.resourcelist();
  else
      if a0.count > 0 then
      t := pv_terr_assign_pub.resourcelist();
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
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t pv_terr_assign_pub.resourcelist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p23(t out nocopy pv_terr_assign_pub.personlist, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_terr_assign_pub.personlist();
  else
      if a0.count > 0 then
      t := pv_terr_assign_pub.personlist();
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
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t pv_terr_assign_pub.personlist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p24(t out nocopy pv_terr_assign_pub.resourcecategorylist, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_terr_assign_pub.resourcecategorylist();
  else
      if a0.count > 0 then
      t := pv_terr_assign_pub.resourcecategorylist();
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
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t pv_terr_assign_pub.resourcecategorylist, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p25(t out nocopy pv_terr_assign_pub.grouplist, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_terr_assign_pub.grouplist();
  else
      if a0.count > 0 then
      t := pv_terr_assign_pub.grouplist();
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
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t pv_terr_assign_pub.grouplist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p25;

  procedure rosetta_table_copy_in_p30(t out nocopy pv_terr_assign_pub.prtnr_aces_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_access_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t pv_terr_assign_pub.prtnr_aces_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).partner_access_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure get_res_from_team_group(p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p2_a0 out nocopy  JTF_NUMBER_TABLE
    , p2_a1 out nocopy  JTF_NUMBER_TABLE
    , p2_a2 out nocopy  JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy  JTF_NUMBER_TABLE
  )

  as
    ddx_resource_rec pv_terr_assign_pub.resourcerec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.get_res_from_team_group(p_resource_id,
      p_resource_type,
      ddx_resource_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    pv_terr_assign_pub_w.rosetta_table_copy_out_p22(ddx_resource_rec.resource_id, p2_a0);
    pv_terr_assign_pub_w.rosetta_table_copy_out_p23(ddx_resource_rec.person_id, p2_a1);
    pv_terr_assign_pub_w.rosetta_table_copy_out_p24(ddx_resource_rec.resource_category, p2_a2);
    pv_terr_assign_pub_w.rosetta_table_copy_out_p25(ddx_resource_rec.group_id, p2_a3);
  end;

  procedure get_partner_details(p_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a14 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_partner_qualifiers_tbl pv_terr_assign_pub.partner_qualifiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.get_partner_details(p_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_partner_qualifiers_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    pv_terr_assign_pub_w.rosetta_table_copy_out_p15(ddx_partner_qualifiers_tbl, p4_a0
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
      , p4_a12
      , p4_a13
      , p4_a14
      );
  end;

  procedure create_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.create_channel_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_partner_id,
      p_vad_partner_id,
      p_mode,
      p_login_user,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p11_a0
      );
  end;

  procedure do_create_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_400
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_500
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_partner_qualifiers_tbl pv_terr_assign_pub.partner_qualifiers_tbl_type;
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pv_terr_assign_pub_w.rosetta_table_copy_in_p15(ddp_partner_qualifiers_tbl, p8_a0
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
      , p8_a12
      , p8_a13
      , p8_a14
      );





    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.do_create_channel_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_partner_id,
      p_vad_partner_id,
      p_mode,
      p_login_user,
      ddp_partner_qualifiers_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p12_a0
      );
  end;

  procedure create_online_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.create_online_channel_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_partner_id,
      p_vad_partner_id,
      p_mode,
      p_login_user,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p11_a0
      );
  end;

  procedure do_cr_online_chnl_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_400
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_VARCHAR2_TABLE_100
    , p11_a8 JTF_VARCHAR2_TABLE_100
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_500
    , p11_a14 JTF_VARCHAR2_TABLE_100
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_partner_qualifiers_tbl pv_terr_assign_pub.partner_qualifiers_tbl_type;
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    pv_terr_assign_pub_w.rosetta_table_copy_in_p15(ddp_partner_qualifiers_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      );


    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.do_cr_online_chnl_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_partner_id,
      p_vad_partner_id,
      p_mode,
      p_login_user,
      ddp_partner_qualifiers_tbl,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p12_a0
      );
  end;

  procedure create_vad_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.create_vad_channel_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_partner_id,
      p_vad_partner_id,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p9_a0
      );
  end;

  procedure update_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_upd_prtnr_qflr_flg_rec pv_terr_assign_pub.prtnr_qflr_flg_rec_type;
    ddx_prtnr_access_id_tbl pv_terr_assign_pub.prtnr_aces_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_upd_prtnr_qflr_flg_rec.partner_name_flg := p8_a0;
    ddp_upd_prtnr_qflr_flg_rec.party_site_id_flg := p8_a1;
    ddp_upd_prtnr_qflr_flg_rec.area_code_flg := p8_a2;
    ddp_upd_prtnr_qflr_flg_rec.city_flg := p8_a3;
    ddp_upd_prtnr_qflr_flg_rec.country_flg := p8_a4;
    ddp_upd_prtnr_qflr_flg_rec.county_flg := p8_a5;
    ddp_upd_prtnr_qflr_flg_rec.postal_code_flg := p8_a6;
    ddp_upd_prtnr_qflr_flg_rec.province_flg := p8_a7;
    ddp_upd_prtnr_qflr_flg_rec.state_flg := p8_a8;
    ddp_upd_prtnr_qflr_flg_rec.annual_revenue_flg := p8_a9;
    ddp_upd_prtnr_qflr_flg_rec.number_of_employee_flg := p8_a10;
    ddp_upd_prtnr_qflr_flg_rec.cust_catgy_code_flg := p8_a11;
    ddp_upd_prtnr_qflr_flg_rec.partner_type_flg := p8_a12;
    ddp_upd_prtnr_qflr_flg_rec.partner_level_flg := p8_a13;





    -- here's the delegated call to the old PL/SQL routine
    pv_terr_assign_pub.update_channel_team(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_partner_id,
      p_vad_partner_id,
      p_mode,
      p_login_user,
      ddp_upd_prtnr_qflr_flg_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_prtnr_access_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    pv_terr_assign_pub_w.rosetta_table_copy_out_p30(ddx_prtnr_access_id_tbl, p12_a0
      );
  end;

end pv_terr_assign_pub_w;

/
