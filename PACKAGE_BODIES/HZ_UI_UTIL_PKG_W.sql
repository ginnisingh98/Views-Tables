--------------------------------------------------------
--  DDL for Package Body HZ_UI_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_UI_UTIL_PKG_W" as
  /* $Header: ARHPUIJB.pls 115.1 2003/02/25 00:54:26 chsaulit noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy HZ_MIXNM_UTILITY.indexvarchar30list, a0 JTF_VARCHAR2_TABLE_100) as
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
  procedure rosetta_table_copy_out_p0(t HZ_MIXNM_UTILITY.indexvarchar30list, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy HZ_MIXNM_UTILITY.indexvarchar1list, a0 JTF_VARCHAR2_TABLE_100) as
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
  procedure rosetta_table_copy_out_p1(t HZ_MIXNM_UTILITY.indexvarchar1list, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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

  procedure check_columns(p_entity_name  VARCHAR2
    , p_data_source  VARCHAR2
    , p_entity_pk1  VARCHAR2
    , p_entity_pk2  VARCHAR2
    , p_party_id  NUMBER
    , p_function_name  VARCHAR2
    , p_attribute_list JTF_VARCHAR2_TABLE_100
    , p_value_is_null_list JTF_VARCHAR2_TABLE_100
    , x_viewable_list out nocopy JTF_VARCHAR2_TABLE_100
    , x_updateable_list out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_attribute_list HZ_MIXNM_UTILITY.indexvarchar30list;
    ddp_value_is_null_list HZ_MIXNM_UTILITY.indexvarchar1list;
    ddx_viewable_list HZ_MIXNM_UTILITY.indexvarchar1list;
    ddx_updateable_list HZ_MIXNM_UTILITY.indexvarchar1list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    hz_ui_util_pkg_w.rosetta_table_copy_in_p0(ddp_attribute_list, p_attribute_list);

    hz_ui_util_pkg_w.rosetta_table_copy_in_p1(ddp_value_is_null_list, p_value_is_null_list);



    -- here's the delegated call to the old PL/SQL routine
    hz_ui_util_pkg.check_columns(p_entity_name,
      p_data_source,
      p_entity_pk1,
      p_entity_pk2,
      p_party_id,
      p_function_name,
      ddp_attribute_list,
      ddp_value_is_null_list,
      ddx_viewable_list,
      ddx_updateable_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    hz_ui_util_pkg_w.rosetta_table_copy_out_p1(ddx_viewable_list, x_viewable_list);

    hz_ui_util_pkg_w.rosetta_table_copy_out_p1(ddx_updateable_list, x_updateable_list);
  end;

end hz_ui_util_pkg_w;

/
