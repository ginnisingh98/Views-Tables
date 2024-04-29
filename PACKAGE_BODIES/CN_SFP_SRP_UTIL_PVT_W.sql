--------------------------------------------------------
--  DDL for Package Body CN_SFP_SRP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_SRP_UTIL_PVT_W" as
  /* $Header: cnwsfsrb.pls 115.0 2002/12/12 02:42:48 sbadami noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy cn_sfp_srp_util_pvt.string_tabletype, a0 JTF_VARCHAR2_TABLE_100) as
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
  procedure rosetta_table_copy_out_p0(t cn_sfp_srp_util_pvt.string_tabletype, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
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

  procedure get_valid_plan_statuses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default_all  VARCHAR2
    , p_type  VARCHAR2
    , x_values_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_meanings_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_values_tab cn_sfp_srp_util_pvt.string_tabletype;
    ddx_meanings_tab cn_sfp_srp_util_pvt.string_tabletype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    cn_sfp_srp_util_pvt.get_valid_plan_statuses(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default_all,
      p_type,
      ddx_values_tab,
      ddx_meanings_tab,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_sfp_srp_util_pvt_w.rosetta_table_copy_out_p0(ddx_values_tab, x_values_tab);

    cn_sfp_srp_util_pvt_w.rosetta_table_copy_out_p0(ddx_meanings_tab, x_meanings_tab);



  end;

end cn_sfp_srp_util_pvt_w;

/
