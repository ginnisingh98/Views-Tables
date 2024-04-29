--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_GRP_W" as
  /* $Header: IBEGRMSB.pls 120.1 2005/06/13 11:24 appldev  $ */
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

  procedure rosetta_table_copy_in_p7(t out nocopy ibe_msite_grp.msite_currencies_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).currency_code := a0(indx);
          t(ddindx).walkin_prc_lst_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).registered_prc_lst_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).biz_partner_prc_lst_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).orderable_limit := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).default_flag := a5(indx);
          t(ddindx).payment_threshold := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).partner_prc_lst_id := rosetta_g_miss_num_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ibe_msite_grp.msite_currencies_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).currency_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).walkin_prc_lst_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).registered_prc_lst_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).biz_partner_prc_lst_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).orderable_limit);
          a5(indx) := t(ddindx).default_flag;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).payment_threshold);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).partner_prc_lst_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy ibe_msite_grp.msite_languages_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).language_code := a0(indx);
          t(ddindx).default_flag := a1(indx);
          t(ddindx).enable_flag := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ibe_msite_grp.msite_languages_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).language_code;
          a1(indx) := t(ddindx).default_flag;
          a2(indx) := t(ddindx).enable_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy ibe_msite_grp.msite_orgids_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).orgid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).default_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t ibe_msite_grp.msite_orgids_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).orgid);
          a1(indx) := t(ddindx).default_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy ibe_msite_grp.msite_delete_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).msite_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t ibe_msite_grp.msite_delete_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).msite_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p11(t out nocopy ibe_msite_grp.msite_prtyids_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t ibe_msite_grp.msite_prtyids_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p11;

  procedure delete_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
  )

  as
    ddp_msite_id_tbl ibe_msite_grp.msite_delete_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ibe_msite_grp_w.rosetta_table_copy_in_p10(ddp_msite_id_tbl, p6_a0
      , p6_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.delete_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_msite_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure save_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  VARCHAR2
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  VARCHAR2
    , p6_a13 in out nocopy  VARCHAR2
    , p6_a14 in out nocopy  DATE
    , p6_a15 in out nocopy  DATE
    , p6_a16 in out nocopy  VARCHAR2
    , p6_a17 in out nocopy  NUMBER
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
  )

  as
    ddp_msite_rec ibe_msite_grp.msite_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_msite_rec.msite_id := rosetta_g_miss_num_map(p6_a0);
    ddp_msite_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_msite_rec.display_name := p6_a2;
    ddp_msite_rec.description := p6_a3;
    ddp_msite_rec.profile_id := rosetta_g_miss_num_map(p6_a4);
    ddp_msite_rec.date_format := p6_a5;
    ddp_msite_rec.walkin_allowed_code := p6_a6;
    ddp_msite_rec.atp_check_flag := p6_a7;
    ddp_msite_rec.msite_master_flag := p6_a8;
    ddp_msite_rec.msite_root_section_id := rosetta_g_miss_num_map(p6_a9);
    ddp_msite_rec.enable_for_store := p6_a10;
    ddp_msite_rec.resp_access_flag := p6_a11;
    ddp_msite_rec.party_access_code := p6_a12;
    ddp_msite_rec.access_name := p6_a13;
    ddp_msite_rec.start_date_active := rosetta_g_miss_date_in_map(p6_a14);
    ddp_msite_rec.end_date_active := rosetta_g_miss_date_in_map(p6_a15);
    ddp_msite_rec.url := p6_a16;
    ddp_msite_rec.theme_id := rosetta_g_miss_num_map(p6_a17);
    ddp_msite_rec.payment_threshold_enable_flag := p6_a18;
    ddp_msite_rec.domain_name := p6_a19;
    ddp_msite_rec.enable_traffic_filter := p6_a20;
    ddp_msite_rec.reporting_status := p6_a21;
    ddp_msite_rec.site_type := p6_a22;

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.save_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_msite_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddp_msite_rec.msite_id);
    p6_a1 := rosetta_g_miss_num_map(ddp_msite_rec.object_version_number);
    p6_a2 := ddp_msite_rec.display_name;
    p6_a3 := ddp_msite_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddp_msite_rec.profile_id);
    p6_a5 := ddp_msite_rec.date_format;
    p6_a6 := ddp_msite_rec.walkin_allowed_code;
    p6_a7 := ddp_msite_rec.atp_check_flag;
    p6_a8 := ddp_msite_rec.msite_master_flag;
    p6_a9 := rosetta_g_miss_num_map(ddp_msite_rec.msite_root_section_id);
    p6_a10 := ddp_msite_rec.enable_for_store;
    p6_a11 := ddp_msite_rec.resp_access_flag;
    p6_a12 := ddp_msite_rec.party_access_code;
    p6_a13 := ddp_msite_rec.access_name;
    p6_a14 := ddp_msite_rec.start_date_active;
    p6_a15 := ddp_msite_rec.end_date_active;
    p6_a16 := ddp_msite_rec.url;
    p6_a17 := rosetta_g_miss_num_map(ddp_msite_rec.theme_id);
    p6_a18 := ddp_msite_rec.payment_threshold_enable_flag;
    p6_a19 := ddp_msite_rec.domain_name;
    p6_a20 := ddp_msite_rec.enable_traffic_filter;
    p6_a21 := ddp_msite_rec.reporting_status;
    p6_a22 := ddp_msite_rec.site_type;
  end;

  procedure duplicate_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_default_language_code  VARCHAR2
    , p_default_currency_code  VARCHAR2
    , p_walkin_pricing_id  NUMBER
    , x_minisite_id out nocopy  NUMBER
    , x_version_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  NUMBER
    , p11_a2 in out nocopy  VARCHAR2
    , p11_a3 in out nocopy  VARCHAR2
    , p11_a4 in out nocopy  NUMBER
    , p11_a5 in out nocopy  VARCHAR2
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  VARCHAR2
    , p11_a8 in out nocopy  VARCHAR2
    , p11_a9 in out nocopy  NUMBER
    , p11_a10 in out nocopy  VARCHAR2
    , p11_a11 in out nocopy  VARCHAR2
    , p11_a12 in out nocopy  VARCHAR2
    , p11_a13 in out nocopy  VARCHAR2
    , p11_a14 in out nocopy  DATE
    , p11_a15 in out nocopy  DATE
    , p11_a16 in out nocopy  VARCHAR2
    , p11_a17 in out nocopy  NUMBER
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  VARCHAR2
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
  )

  as
    ddp_msite_rec ibe_msite_grp.msite_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_msite_rec.msite_id := rosetta_g_miss_num_map(p11_a0);
    ddp_msite_rec.object_version_number := rosetta_g_miss_num_map(p11_a1);
    ddp_msite_rec.display_name := p11_a2;
    ddp_msite_rec.description := p11_a3;
    ddp_msite_rec.profile_id := rosetta_g_miss_num_map(p11_a4);
    ddp_msite_rec.date_format := p11_a5;
    ddp_msite_rec.walkin_allowed_code := p11_a6;
    ddp_msite_rec.atp_check_flag := p11_a7;
    ddp_msite_rec.msite_master_flag := p11_a8;
    ddp_msite_rec.msite_root_section_id := rosetta_g_miss_num_map(p11_a9);
    ddp_msite_rec.enable_for_store := p11_a10;
    ddp_msite_rec.resp_access_flag := p11_a11;
    ddp_msite_rec.party_access_code := p11_a12;
    ddp_msite_rec.access_name := p11_a13;
    ddp_msite_rec.start_date_active := rosetta_g_miss_date_in_map(p11_a14);
    ddp_msite_rec.end_date_active := rosetta_g_miss_date_in_map(p11_a15);
    ddp_msite_rec.url := p11_a16;
    ddp_msite_rec.theme_id := rosetta_g_miss_num_map(p11_a17);
    ddp_msite_rec.payment_threshold_enable_flag := p11_a18;
    ddp_msite_rec.domain_name := p11_a19;
    ddp_msite_rec.enable_traffic_filter := p11_a20;
    ddp_msite_rec.reporting_status := p11_a21;
    ddp_msite_rec.site_type := p11_a22;

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.duplicate_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      p_default_language_code,
      p_default_currency_code,
      p_walkin_pricing_id,
      x_minisite_id,
      x_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_msite_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddp_msite_rec.msite_id);
    p11_a1 := rosetta_g_miss_num_map(ddp_msite_rec.object_version_number);
    p11_a2 := ddp_msite_rec.display_name;
    p11_a3 := ddp_msite_rec.description;
    p11_a4 := rosetta_g_miss_num_map(ddp_msite_rec.profile_id);
    p11_a5 := ddp_msite_rec.date_format;
    p11_a6 := ddp_msite_rec.walkin_allowed_code;
    p11_a7 := ddp_msite_rec.atp_check_flag;
    p11_a8 := ddp_msite_rec.msite_master_flag;
    p11_a9 := rosetta_g_miss_num_map(ddp_msite_rec.msite_root_section_id);
    p11_a10 := ddp_msite_rec.enable_for_store;
    p11_a11 := ddp_msite_rec.resp_access_flag;
    p11_a12 := ddp_msite_rec.party_access_code;
    p11_a13 := ddp_msite_rec.access_name;
    p11_a14 := ddp_msite_rec.start_date_active;
    p11_a15 := ddp_msite_rec.end_date_active;
    p11_a16 := ddp_msite_rec.url;
    p11_a17 := rosetta_g_miss_num_map(ddp_msite_rec.theme_id);
    p11_a18 := ddp_msite_rec.payment_threshold_enable_flag;
    p11_a19 := ddp_msite_rec.domain_name;
    p11_a20 := ddp_msite_rec.enable_traffic_filter;
    p11_a21 := ddp_msite_rec.reporting_status;
    p11_a22 := ddp_msite_rec.site_type;
  end;

  procedure save_msite_languages(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_msite_languages_tbl ibe_msite_grp.msite_languages_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ibe_msite_grp_w.rosetta_table_copy_in_p8(ddp_msite_languages_tbl, p7_a0
      , p7_a1
      , p7_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.save_msite_languages(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_languages_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure save_msite_currencies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
  )

  as
    ddp_msite_currencies_tbl ibe_msite_grp.msite_currencies_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ibe_msite_grp_w.rosetta_table_copy_in_p7(ddp_msite_currencies_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.save_msite_currencies(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_currencies_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure save_msite_orgids(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_msite_orgids_tbl ibe_msite_grp.msite_orgids_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ibe_msite_grp_w.rosetta_table_copy_in_p9(ddp_msite_orgids_tbl, p7_a0
      , p7_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.save_msite_orgids(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_orgids_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure insert_row(x_rowid in out nocopy  VARCHAR2
    , x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
    , x_payment_thresh_enable_flag  VARCHAR2
    , x_domain_name  VARCHAR2
    , x_enable_traffic_filter  VARCHAR2
    , x_reporting_status  VARCHAR2
    , x_site_type  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddx_creation_date date;
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);












    ddx_creation_date := rosetta_g_miss_date_in_map(x_creation_date);


    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);













    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.insert_row(x_rowid,
      x_msite_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute11,
      x_attribute10,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_object_version_number,
      x_store_id,
      ddx_start_date_active,
      ddx_end_date_active,
      x_default_language_code,
      x_default_currency_code,
      x_default_date_format,
      x_default_org_id,
      x_atp_check_flag,
      x_walkin_allowed_flag,
      x_msite_root_section_id,
      x_profile_id,
      x_master_msite_flag,
      x_msite_name,
      x_msite_description,
      ddx_creation_date,
      x_created_by,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_resp_access_flag,
      x_party_access_code,
      x_access_name,
      x_url,
      x_theme_id,
      x_payment_thresh_enable_flag,
      x_domain_name,
      x_enable_traffic_filter,
      x_reporting_status,
      x_site_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















































  end;

  procedure lock_row(x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
    , x_payment_thresh_enable_flag  VARCHAR2
    , x_domain_name  VARCHAR2
    , x_enable_traffic_filter  VARCHAR2
    , x_reporting_status  VARCHAR2
    , x_site_type  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);






















    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.lock_row(x_msite_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute11,
      x_attribute10,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_object_version_number,
      x_store_id,
      ddx_start_date_active,
      ddx_end_date_active,
      x_default_language_code,
      x_default_currency_code,
      x_default_date_format,
      x_default_org_id,
      x_atp_check_flag,
      x_walkin_allowed_flag,
      x_msite_root_section_id,
      x_profile_id,
      x_master_msite_flag,
      x_msite_name,
      x_msite_description,
      x_resp_access_flag,
      x_party_access_code,
      x_access_name,
      x_url,
      x_theme_id,
      x_payment_thresh_enable_flag,
      x_domain_name,
      x_enable_traffic_filter,
      x_reporting_status,
      x_site_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









































  end;

  procedure update_row(x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
    , x_payment_thresh_enable_flag  VARCHAR2
    , x_domain_name  VARCHAR2
    , x_enable_traffic_filter  VARCHAR2
    , x_reporting_status  VARCHAR2
    , x_site_type  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);












    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);













    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.update_row(x_msite_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute11,
      x_attribute10,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_object_version_number,
      x_store_id,
      ddx_start_date_active,
      ddx_end_date_active,
      x_default_language_code,
      x_default_currency_code,
      x_default_date_format,
      x_default_org_id,
      x_atp_check_flag,
      x_walkin_allowed_flag,
      x_msite_root_section_id,
      x_profile_id,
      x_master_msite_flag,
      x_msite_name,
      x_msite_description,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_resp_access_flag,
      x_party_access_code,
      x_access_name,
      x_url,
      x_theme_id,
      x_payment_thresh_enable_flag,
      x_domain_name,
      x_enable_traffic_filter,
      x_reporting_status,
      x_site_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












































  end;

  procedure load_row(x_msite_id  NUMBER
    , x_owner  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
    , x_payment_thresh_enable_flag  VARCHAR2
    , x_domain_name  VARCHAR2
    , x_enable_traffic_filter  VARCHAR2
    , x_reporting_status  VARCHAR2
    , x_site_type  VARCHAR2
    , x_last_update_date  VARCHAR2
    , x_custom_mode  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);
























    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.load_row(x_msite_id,
      x_owner,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute11,
      x_attribute10,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_object_version_number,
      x_store_id,
      ddx_start_date_active,
      ddx_end_date_active,
      x_default_language_code,
      x_default_currency_code,
      x_default_date_format,
      x_default_org_id,
      x_atp_check_flag,
      x_walkin_allowed_flag,
      x_msite_root_section_id,
      x_profile_id,
      x_master_msite_flag,
      x_msite_name,
      x_msite_description,
      x_resp_access_flag,
      x_party_access_code,
      x_access_name,
      x_url,
      x_theme_id,
      x_payment_thresh_enable_flag,
      x_domain_name,
      x_enable_traffic_filter,
      x_reporting_status,
      x_site_type,
      x_last_update_date,
      x_custom_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












































  end;

  procedure load_seed_row(x_msite_id  NUMBER
    , x_owner  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  VARCHAR2
    , x_payment_thresh_enable_flag  VARCHAR2
    , x_domain_name  VARCHAR2
    , x_enable_traffic_filter  VARCHAR2
    , x_reporting_status  VARCHAR2
    , x_site_type  VARCHAR2
    , x_last_update_date  VARCHAR2
    , x_custom_mode  VARCHAR2
    , x_upload_mode  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






















    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);























    -- here's the delegated call to the old PL/SQL routine
    ibe_msite_grp.load_seed_row(x_msite_id,
      x_owner,
      x_msite_name,
      x_msite_description,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_object_version_number,
      x_store_id,
      ddx_start_date_active,
      ddx_end_date_active,
      x_default_language_code,
      x_default_currency_code,
      x_default_date_format,
      x_default_org_id,
      x_atp_check_flag,
      x_walkin_allowed_flag,
      x_msite_root_section_id,
      x_profile_id,
      x_master_msite_flag,
      x_resp_access_flag,
      x_party_access_code,
      x_access_name,
      x_url,
      x_theme_id,
      x_payment_thresh_enable_flag,
      x_domain_name,
      x_enable_traffic_filter,
      x_reporting_status,
      x_site_type,
      x_last_update_date,
      x_custom_mode,
      x_upload_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













































  end;

end ibe_msite_grp_w;

/
