--------------------------------------------------------
--  DDL for Package Body AMV_MATCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_MATCH_PVT_W" as
  /* $Header: amvwmatb.pls 120.2 2005/06/30 08:06 appldev ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy amv_match_pvt.terr_id_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t amv_match_pvt.terr_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy amv_match_pvt.terr_name_tbl_type, a0 JTF_VARCHAR2_TABLE_4000) as
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t amv_match_pvt.terr_name_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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

  procedure do_itemchannelmatch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_category_id  NUMBER
    , p_channel_id  NUMBER
    , p_item_id  NUMBER
    , p_table_name_code  VARCHAR2
    , p_match_type  VARCHAR2
    , p_territory_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_territory_tbl amv_match_pvt.terr_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    amv_match_pvt_w.rosetta_table_copy_in_p3(ddp_territory_tbl, p_territory_tbl);

    -- here's the delegated call to the old PL/SQL routine
    amv_match_pvt.do_itemchannelmatch(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      p_category_id,
      p_channel_id,
      p_item_id,
      p_table_name_code,
      p_match_type,
      ddp_territory_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure get_userterritory(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , x_terr_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_terr_name_tbl out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_terr_id_tbl amv_match_pvt.terr_id_tbl_type;
    ddx_terr_name_tbl amv_match_pvt.terr_name_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_match_pvt.get_userterritory(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_resource_type,
      ddx_terr_id_tbl,
      ddx_terr_name_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_match_pvt_w.rosetta_table_copy_out_p3(ddx_terr_id_tbl, x_terr_id_tbl);

    amv_match_pvt_w.rosetta_table_copy_out_p4(ddx_terr_name_tbl, x_terr_name_tbl);
  end;

  procedure get_publishedterritories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_terr_id  NUMBER
    , p_table_name_code  VARCHAR2
    , x_item_id_tbl out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_item_id_tbl amv_match_pvt.terr_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_match_pvt.get_publishedterritories(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_terr_id,
      p_table_name_code,
      ddx_item_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_match_pvt_w.rosetta_table_copy_out_p3(ddx_item_id_tbl, x_item_id_tbl);
  end;

end amv_match_pvt_w;

/
