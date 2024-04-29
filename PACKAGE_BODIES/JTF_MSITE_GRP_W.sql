--------------------------------------------------------
--  DDL for Package Body JTF_MSITE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MSITE_GRP_W" as
  /* $Header: JTFGRMSB.pls 115.9 2004/07/09 18:50:52 applrt ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p7(t out jtf_msite_grp.msite_currencies_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_msite_grp.msite_currencies_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_VARCHAR2_TABLE_100
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
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).currency_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).walkin_prc_lst_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).registered_prc_lst_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).biz_partner_prc_lst_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).orderable_limit);
          a5(indx) := t(ddindx).default_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out jtf_msite_grp.msite_languages_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t jtf_msite_grp.msite_languages_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).language_code;
          a1(indx) := t(ddindx).default_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out jtf_msite_grp.msite_orgids_tbl_type, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p9(t jtf_msite_grp.msite_orgids_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
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

  procedure rosetta_table_copy_in_p10(t out jtf_msite_grp.msite_delete_tbl_type, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p10(t jtf_msite_grp.msite_delete_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
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

  procedure rosetta_table_copy_in_p11(t out jtf_msite_grp.msite_prtyids_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t jtf_msite_grp.msite_prtyids_tbl_type, a0 out JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
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
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
  )
  as
    ddp_msite_id_tbl jtf_msite_grp.msite_delete_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_msite_grp_w.rosetta_table_copy_in_p10(ddp_msite_id_tbl, p6_a0
      , p6_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_msite_grp.delete_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_msite_id_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure save_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  NUMBER
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  NUMBER
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  VARCHAR2
    , p6_a8 in out  VARCHAR2
    , p6_a9 in out  NUMBER
    , p6_a10 in out  VARCHAR2
    , p6_a11 in out  VARCHAR2
    , p6_a12 in out  VARCHAR2
    , p6_a13 in out  VARCHAR2
    , p6_a14 in out  DATE
    , p6_a15 in out  DATE
    , p6_a16 in out  VARCHAR2
    , p6_a17 in out  NUMBER
  )
  as
    ddp_msite_rec jtf_msite_grp.msite_rec_type;
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

    -- here's the delegated call to the old PL/SQL routine
    jtf_msite_grp.save_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_msite_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






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
  end;

  procedure save_msite_languages(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_msite_languages_tbl jtf_msite_grp.msite_languages_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_msite_grp_w.rosetta_table_copy_in_p8(ddp_msite_languages_tbl, p7_a0
      , p7_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_msite_grp.save_msite_languages(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_languages_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure save_msite_currencies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_msite_currencies_tbl jtf_msite_grp.msite_currencies_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_msite_grp_w.rosetta_table_copy_in_p7(ddp_msite_currencies_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_msite_grp.save_msite_currencies(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_currencies_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure save_msite_orgids(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_msite_orgids_tbl jtf_msite_grp.msite_orgids_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_msite_grp_w.rosetta_table_copy_in_p9(ddp_msite_orgids_tbl, p7_a0
      , p7_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_msite_grp.save_msite_orgids(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_msite_id,
      ddp_msite_orgids_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure insert_row(x_rowid in out  VARCHAR2
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
    , x_security_group_id  NUMBER
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
    jtf_msite_grp.insert_row(x_rowid,
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
      x_security_group_id,
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
      x_theme_id);

    -- copy data back from the local OUT or IN-OUT args, if any











































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
    , x_security_group_id  NUMBER
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
    jtf_msite_grp.lock_row(x_msite_id,
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
      x_security_group_id,
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
      x_theme_id);

    -- copy data back from the local OUT or IN-OUT args, if any





































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
    , x_security_group_id  NUMBER
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
    jtf_msite_grp.update_row(x_msite_id,
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
      x_security_group_id,
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
      x_theme_id);

    -- copy data back from the local OUT or IN-OUT args, if any








































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
    , x_security_group_id  NUMBER
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
    jtf_msite_grp.load_row(x_msite_id,
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
      x_security_group_id,
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
      x_theme_id);

    -- copy data back from the local OUT or IN-OUT args, if any






































  end;

end jtf_msite_grp_w;

/
