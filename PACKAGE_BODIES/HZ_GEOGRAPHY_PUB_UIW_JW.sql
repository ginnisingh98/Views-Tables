--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_PUB_UIW_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_PUB_UIW_JW" as
  /* $Header: ARHGEOJS.pls 120.2 2006/02/17 09:08:50 idali noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy hz_geography_pub_uiw.parent_geography_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := hz_geography_pub_uiw.parent_geography_tbl_type();
  else
      if a0.count > 0 then
      t := hz_geography_pub_uiw.parent_geography_tbl_type();
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t hz_geography_pub_uiw.parent_geography_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy hz_geography_pub_uiw.zone_relation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := hz_geography_pub_uiw.zone_relation_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := hz_geography_pub_uiw.zone_relation_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).included_geography_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).geography_from := a1(indx);
          t(ddindx).geography_to := a2(indx);
          t(ddindx).identifier_type := a3(indx);
          t(ddindx).geography_type := a4(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t hz_geography_pub_uiw.zone_relation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).included_geography_id);
          a1(indx) := t(ddindx).geography_from;
          a2(indx) := t(ddindx).geography_to;
          a3(indx) := t(ddindx).identifier_type;
          a4(indx) := t(ddindx).geography_type;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_master_relation(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  DATE := SYSDATE
    , p1_a3  DATE := to_date('31-12-4712','DD-MM-YYYY')
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
  )
  as
    ddp_master_relation_rec hz_geography_pub_uiw.master_relation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_master_relation_rec.geography_id := rosetta_g_miss_num_map(p1_a0);
    ddp_master_relation_rec.parent_geography_id := rosetta_g_miss_num_map(p1_a1);
    ddp_master_relation_rec.start_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_master_relation_rec.end_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_master_relation_rec.created_by_module := p1_a4;
    ddp_master_relation_rec.application_id := rosetta_g_miss_num_map(p1_a5);





    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_master_relation(p_init_msg_list,
      ddp_master_relation_rec,
      x_relationship_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_geo_identifier(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := 'USER_ENTERED'
    , p1_a5  VARCHAR2 := 'N'
    , p1_a6  VARCHAR2 := userenv('LANG')
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
  )
  as
    ddp_geo_identifier_rec hz_geography_pub_uiw.geo_identifier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_identifier_rec.geography_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geo_identifier_rec.identifier_subtype := p1_a1;
    ddp_geo_identifier_rec.identifier_value := p1_a2;
    ddp_geo_identifier_rec.identifier_type := p1_a3;
    ddp_geo_identifier_rec.geo_data_provider := p1_a4;
    ddp_geo_identifier_rec.primary_flag := p1_a5;
    ddp_geo_identifier_rec.language_code := p1_a6;
    ddp_geo_identifier_rec.created_by_module := p1_a7;
    ddp_geo_identifier_rec.application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_geo_identifier_rec.new_identifier_value := p1_a9;
    ddp_geo_identifier_rec.new_identifier_subtype := p1_a10;




    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_geo_identifier(p_init_msg_list,
      ddp_geo_identifier_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_geo_identifier(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_cp_request_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := userenv('LANG')
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
  )
  as
    ddp_geo_identifier_rec hz_geography_pub_uiw.geo_identifier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_identifier_rec.geography_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geo_identifier_rec.identifier_subtype := p1_a1;
    ddp_geo_identifier_rec.identifier_value := p1_a2;
    ddp_geo_identifier_rec.identifier_type := p1_a3;
    ddp_geo_identifier_rec.geo_data_provider := p1_a4;
    ddp_geo_identifier_rec.primary_flag := p1_a5;
    ddp_geo_identifier_rec.language_code := p1_a6;
    ddp_geo_identifier_rec.created_by_module := p1_a7;
    ddp_geo_identifier_rec.application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_geo_identifier_rec.new_identifier_value := p1_a9;
    ddp_geo_identifier_rec.new_identifier_subtype := p1_a10;






    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.update_geo_identifier(p_init_msg_list,
      ddp_geo_identifier_rec,
      p_object_version_number,
      x_cp_request_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_master_geography(p_init_msg_list  VARCHAR2
    , p_parent_geography_id JTF_NUMBER_TABLE
    , x_geography_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := SYSDATE
    , p1_a5  DATE := to_date('31-12-4712','DD-MM-YYYY')
    , p1_a6  VARCHAR2 := 'USER_ENTERED'
    , p1_a7  VARCHAR2 := userenv('LANG')
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  NUMBER := null
  )
  as
    ddp_master_geography_rec hz_geography_pub_uiw.master_geography_rec_type;
    ddp_parent_geography_id hz_geography_pub_uiw.parent_geography_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_master_geography_rec.geography_type := p1_a0;
    ddp_master_geography_rec.geography_name := p1_a1;
    ddp_master_geography_rec.geography_code := p1_a2;
    ddp_master_geography_rec.geography_code_type := p1_a3;
    ddp_master_geography_rec.start_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_master_geography_rec.end_date := rosetta_g_miss_date_in_map(p1_a5);
    ddp_master_geography_rec.geo_data_provider := p1_a6;
    ddp_master_geography_rec.language_code := p1_a7;
    ddp_master_geography_rec.timezone_code := p1_a8;
    ddp_master_geography_rec.created_by_module := p1_a9;
    ddp_master_geography_rec.application_id := rosetta_g_miss_num_map(p1_a10);

    hz_geography_pub_uiw_jw.rosetta_table_copy_in_p2(ddp_parent_geography_id, p_parent_geography_id);





    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_master_geography(p_init_msg_list,
      ddp_master_geography_rec,
      ddp_parent_geography_id,
      x_geography_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_geography(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p_end_date  date
    , p_timezone_code  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);






    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.update_geography(p_init_msg_list,
      p_geography_id,
      ddp_end_date,
      p_timezone_code,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_geography_range(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := SYSDATE
    , p1_a7  DATE := to_date('31-12-4712','DD-MM-YYYY')
    , p1_a8  VARCHAR2 := null
    , p1_a9  NUMBER := null
  )
  as
    ddp_geography_range_rec hz_geography_pub_uiw.geography_range_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geography_range_rec.zone_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geography_range_rec.master_ref_geography_id := rosetta_g_miss_num_map(p1_a1);
    ddp_geography_range_rec.identifier_type := p1_a2;
    ddp_geography_range_rec.geography_from := p1_a3;
    ddp_geography_range_rec.geography_to := p1_a4;
    ddp_geography_range_rec.geography_type := p1_a5;
    ddp_geography_range_rec.start_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_geography_range_rec.end_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_geography_range_rec.created_by_module := p1_a8;
    ddp_geography_range_rec.application_id := rosetta_g_miss_num_map(p1_a9);




    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_geography_range(p_init_msg_list,
      ddp_geography_range_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_geography_range(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p_geography_from  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.update_geography_range(p_init_msg_list,
      p_geography_id,
      p_geography_from,
      ddp_start_date,
      ddp_end_date,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_zone_relation(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_400
    , p2_a2 JTF_VARCHAR2_TABLE_400
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_DATE_TABLE
    , p_created_by_module  VARCHAR2
    , p_application_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_zone_relation_tbl hz_geography_pub_uiw.zone_relation_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    hz_geography_pub_uiw_jw.rosetta_table_copy_in_p6(ddp_zone_relation_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      );






    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_zone_relation(p_init_msg_list,
      p_geography_id,
      ddp_zone_relation_tbl,
      p_created_by_module,
      p_application_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_zone(p_init_msg_list  VARCHAR2
    , p_zone_type  VARCHAR2
    , p_zone_name  VARCHAR2
    , p_zone_code  VARCHAR2
    , p_zone_code_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_geo_data_provider  VARCHAR2
    , p_language_code  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_400
    , p9_a2 JTF_VARCHAR2_TABLE_400
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_DATE_TABLE
    , p_timezone_code  VARCHAR2
    , x_geography_id out nocopy  NUMBER
    , p_created_by_module  VARCHAR2
    , p_application_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_zone_relation_tbl hz_geography_pub_uiw.zone_relation_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);



    hz_geography_pub_uiw_jw.rosetta_table_copy_in_p6(ddp_zone_relation_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_geography_pub_uiw.create_zone(p_init_msg_list,
      p_zone_type,
      p_zone_name,
      p_zone_code,
      p_zone_code_type,
      ddp_start_date,
      ddp_end_date,
      p_geo_data_provider,
      p_language_code,
      ddp_zone_relation_tbl,
      p_timezone_code,
      x_geography_id,
      p_created_by_module,
      p_application_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any
















  end;

end hz_geography_pub_uiw_jw;

/
