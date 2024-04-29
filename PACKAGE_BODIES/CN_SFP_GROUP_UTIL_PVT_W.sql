--------------------------------------------------------
--  DDL for Package Body CN_SFP_GROUP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_GROUP_UTIL_PVT_W" as
  /* $Header: cnwsfgrb.pls 115.0 2003/08/19 20:50:22 sbadami noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_sfp_group_util_pvt.srprole_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_role_id := a0(indx);
          t(ddindx).comp_group_id := a1(indx);
          t(ddindx).org_code := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_sfp_group_util_pvt.srprole_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).srp_role_id;
          a1(indx) := t(ddindx).comp_group_id;
          a2(indx) := t(ddindx).org_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_sfp_group_util_pvt.grporg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_code := a0(indx);
          t(ddindx).org_meaning := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_sfp_group_util_pvt.grporg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).org_code;
          a1(indx) := t(ddindx).org_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy cn_sfp_group_util_pvt.grpnum_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p4(t cn_sfp_group_util_pvt.grpnum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p4;

  procedure get_descendant_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_selected_groups JTF_NUMBER_TABLE
    , p_effective_date  date
    , x_descendant_groups out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_selected_groups cn_sfp_group_util_pvt.grpnum_tbl_type;
    ddp_effective_date date;
    ddx_descendant_groups cn_sfp_group_util_pvt.grpnum_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cn_sfp_group_util_pvt_w.rosetta_table_copy_in_p4(ddp_selected_groups, p_selected_groups);

    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    cn_sfp_group_util_pvt.get_descendant_groups(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_selected_groups,
      ddp_effective_date,
      ddx_descendant_groups,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p4(ddx_descendant_groups, x_descendant_groups);



  end;

  procedure get_salesrep_roles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_selected_groups JTF_NUMBER_TABLE
    , p_status  VARCHAR2
    , p_effective_date  date
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_selected_groups cn_sfp_group_util_pvt.grpnum_tbl_type;
    ddp_effective_date date;
    ddx_salesrep_roles cn_sfp_group_util_pvt.srprole_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cn_sfp_group_util_pvt_w.rosetta_table_copy_in_p4(ddp_selected_groups, p_selected_groups);


    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    cn_sfp_group_util_pvt.get_salesrep_roles(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_selected_groups,
      p_status,
      ddp_effective_date,
      ddx_salesrep_roles,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p1(ddx_salesrep_roles, p7_a0
      , p7_a1
      , p7_a2
      );



  end;

  procedure get_grp_organization_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_group_id  NUMBER
    , p_effective_date  date
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_effective_date date;
    ddx_updview_organization cn_sfp_group_util_pvt.grporg_tbl_type;
    ddx_upd_organization cn_sfp_group_util_pvt.grporg_tbl_type;
    ddx_view_organization cn_sfp_group_util_pvt.grporg_tbl_type;
    ddx_noview_organization cn_sfp_group_util_pvt.grporg_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);








    -- here's the delegated call to the old PL/SQL routine
    cn_sfp_group_util_pvt.get_grp_organization_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_comp_group_id,
      ddp_effective_date,
      ddx_updview_organization,
      ddx_upd_organization,
      ddx_view_organization,
      ddx_noview_organization,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p3(ddx_updview_organization, p6_a0
      , p6_a1
      );

    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p3(ddx_upd_organization, p7_a0
      , p7_a1
      );

    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p3(ddx_view_organization, p8_a0
      , p8_a1
      );

    cn_sfp_group_util_pvt_w.rosetta_table_copy_out_p3(ddx_noview_organization, p9_a0
      , p9_a1
      );



  end;

end cn_sfp_group_util_pvt_w;

/
