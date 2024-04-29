--------------------------------------------------------
--  DDL for Package Body HZ_MIXNM_WEBUI_UTILITY_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIXNM_WEBUI_UTILITY_JW" as
  /* $Header: ARHXWUJB.pls 120.2 2005/06/18 04:28:31 jhuang noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy hz_mixnm_webui_utility.idlist, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t hz_mixnm_webui_utility.idlist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy hz_mixnm_webui_utility.varcharlist, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t hz_mixnm_webui_utility.varcharlist, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p1;

  procedure create_rule_1(p_rule_type  VARCHAR2
    , p_rule_id in out nocopy  NUMBER
    , p_rule_name  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddp_attribute_group_name_tab hz_mixnm_webui_utility.varcharlist;
    ddp_flag_tab hz_mixnm_webui_utility.varcharlist;
    ddp_os_tab hz_mixnm_webui_utility.varcharlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_attribute_group_name_tab, p_attribute_group_name_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_flag_tab, p_flag_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_os_tab, p_os_tab);

    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.create_rule(p_rule_type,
      p_rule_id,
      p_rule_name,
      ddp_entity_attr_id_tab,
      ddp_attribute_group_name_tab,
      ddp_flag_tab,
      ddp_os_tab);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_rule_2(p_rule_type  VARCHAR2
    , p_rule_id  NUMBER
    , p_rule_name  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddp_attribute_group_name_tab hz_mixnm_webui_utility.varcharlist;
    ddp_flag_tab hz_mixnm_webui_utility.varcharlist;
    ddp_os_tab hz_mixnm_webui_utility.varcharlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_attribute_group_name_tab, p_attribute_group_name_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_flag_tab, p_flag_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_os_tab, p_os_tab);

    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.update_rule(p_rule_type,
      p_rule_id,
      p_rule_name,
      ddp_entity_attr_id_tab,
      ddp_attribute_group_name_tab,
      ddp_flag_tab,
      ddp_os_tab);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_thirdpartyrule_3(p_rule_exists  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddp_attribute_group_name_tab hz_mixnm_webui_utility.varcharlist;
    ddp_flag_tab hz_mixnm_webui_utility.varcharlist;
    ddp_os_tab hz_mixnm_webui_utility.varcharlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_attribute_group_name_tab, p_attribute_group_name_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_flag_tab, p_flag_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_os_tab, p_os_tab);

    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.update_thirdpartyrule(p_rule_exists,
      ddp_entity_attr_id_tab,
      ddp_attribute_group_name_tab,
      ddp_flag_tab,
      ddp_os_tab);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure set_datasources_4(p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_range_tab JTF_NUMBER_TABLE
    , p_data_sources_tab JTF_VARCHAR2_TABLE_100
    , p_ranking_tab JTF_NUMBER_TABLE
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddp_attribute_group_name_tab hz_mixnm_webui_utility.varcharlist;
    ddp_range_tab hz_mixnm_webui_utility.idlist;
    ddp_data_sources_tab hz_mixnm_webui_utility.varcharlist;
    ddp_ranking_tab hz_mixnm_webui_utility.idlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_attribute_group_name_tab, p_attribute_group_name_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_range_tab, p_range_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_data_sources_tab, p_data_sources_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_ranking_tab, p_ranking_tab);

    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.set_datasources(ddp_entity_attr_id_tab,
      ddp_attribute_group_name_tab,
      ddp_range_tab,
      ddp_data_sources_tab,
      ddp_ranking_tab);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure get_datasourcesforagroup_5(p_entity_type  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , x_has_same_setup out nocopy  VARCHAR2
    , x_data_sources_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_meaning_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_ranking_tab out nocopy JTF_NUMBER_TABLE
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddx_data_sources_tab hz_mixnm_webui_utility.varcharlist;
    ddx_meaning_tab hz_mixnm_webui_utility.varcharlist;
    ddx_ranking_tab hz_mixnm_webui_utility.idlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);





    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.get_datasourcesforagroup(p_entity_type,
      ddp_entity_attr_id_tab,
      x_has_same_setup,
      ddx_data_sources_tab,
      ddx_meaning_tab,
      ddx_ranking_tab);

    -- copy data back from the local OUT or IN-OUT args, if any



    hz_mixnm_webui_utility_jw.rosetta_table_copy_out_p1(ddx_data_sources_tab, x_data_sources_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_out_p1(ddx_meaning_tab, x_meaning_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_out_p0(ddx_ranking_tab, x_ranking_tab);
  end;

  procedure set_datasourcesforagroup_6(p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_data_sources_tab JTF_VARCHAR2_TABLE_100
    , p_ranking_tab JTF_NUMBER_TABLE
  )
  as
    ddp_entity_attr_id_tab hz_mixnm_webui_utility.idlist;
    ddp_attribute_group_name_tab hz_mixnm_webui_utility.varcharlist;
    ddp_data_sources_tab hz_mixnm_webui_utility.varcharlist;
    ddp_ranking_tab hz_mixnm_webui_utility.idlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_entity_attr_id_tab, p_entity_attr_id_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_attribute_group_name_tab, p_attribute_group_name_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p1(ddp_data_sources_tab, p_data_sources_tab);

    hz_mixnm_webui_utility_jw.rosetta_table_copy_in_p0(ddp_ranking_tab, p_ranking_tab);

    -- here's the delegated call to the old PL/SQL routine
    hz_mixnm_webui_utility.set_datasourcesforagroup(ddp_entity_attr_id_tab,
      ddp_attribute_group_name_tab,
      ddp_data_sources_tab,
      ddp_ranking_tab);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

end hz_mixnm_webui_utility_jw;

/
