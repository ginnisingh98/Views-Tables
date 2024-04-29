--------------------------------------------------------
--  DDL for Package Body AML_TIMEFRAME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_TIMEFRAME_PUB_W" as
  /* $Header: amlwtfrb.pls 115.1 2003/01/03 18:45:19 chchandr noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy aml_timeframe_pub.timeframe_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).timeframe_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).decision_timeframe_code := a1(indx);
          t(ddindx).timeframe_days := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).enabled_flag := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t aml_timeframe_pub.timeframe_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).timeframe_id);
          a1(indx) := t(ddindx).decision_timeframe_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).timeframe_days);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).enabled_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_timeframe_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_timeframe_rec aml_timeframe_pub.timeframe_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p8_a0
      , p8_a1
      );

    ddp_timeframe_rec.timeframe_id := rosetta_g_miss_num_map(p9_a0);
    ddp_timeframe_rec.decision_timeframe_code := p9_a1;
    ddp_timeframe_rec.timeframe_days := rosetta_g_miss_num_map(p9_a2);
    ddp_timeframe_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_timeframe_rec.last_update_login := rosetta_g_miss_num_map(p9_a4);
    ddp_timeframe_rec.created_by := rosetta_g_miss_num_map(p9_a5);
    ddp_timeframe_rec.creation_date := rosetta_g_miss_date_in_map(p9_a6);
    ddp_timeframe_rec.last_updated_by := rosetta_g_miss_num_map(p9_a7);
    ddp_timeframe_rec.enabled_flag := p9_a8;





    -- here's the delegated call to the old PL/SQL routine
    aml_timeframe_pub.create_timeframe(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_profile_tbl,
      ddp_timeframe_rec,
      x_timeframe_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_timeframe_rec aml_timeframe_pub.timeframe_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p8_a0
      , p8_a1
      );

    ddp_timeframe_rec.timeframe_id := rosetta_g_miss_num_map(p9_a0);
    ddp_timeframe_rec.decision_timeframe_code := p9_a1;
    ddp_timeframe_rec.timeframe_days := rosetta_g_miss_num_map(p9_a2);
    ddp_timeframe_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_timeframe_rec.last_update_login := rosetta_g_miss_num_map(p9_a4);
    ddp_timeframe_rec.created_by := rosetta_g_miss_num_map(p9_a5);
    ddp_timeframe_rec.creation_date := rosetta_g_miss_date_in_map(p9_a6);
    ddp_timeframe_rec.last_updated_by := rosetta_g_miss_num_map(p9_a7);
    ddp_timeframe_rec.enabled_flag := p9_a8;




    -- here's the delegated call to the old PL/SQL routine
    aml_timeframe_pub.update_timeframe(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_profile_tbl,
      ddp_timeframe_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure delete_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_timeframe_rec aml_timeframe_pub.timeframe_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p8_a0
      , p8_a1
      );

    ddp_timeframe_rec.timeframe_id := rosetta_g_miss_num_map(p9_a0);
    ddp_timeframe_rec.decision_timeframe_code := p9_a1;
    ddp_timeframe_rec.timeframe_days := rosetta_g_miss_num_map(p9_a2);
    ddp_timeframe_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_timeframe_rec.last_update_login := rosetta_g_miss_num_map(p9_a4);
    ddp_timeframe_rec.created_by := rosetta_g_miss_num_map(p9_a5);
    ddp_timeframe_rec.creation_date := rosetta_g_miss_date_in_map(p9_a6);
    ddp_timeframe_rec.last_updated_by := rosetta_g_miss_num_map(p9_a7);
    ddp_timeframe_rec.enabled_flag := p9_a8;




    -- here's the delegated call to the old PL/SQL routine
    aml_timeframe_pub.delete_timeframe(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_profile_tbl,
      ddp_timeframe_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end aml_timeframe_pub_w;

/
