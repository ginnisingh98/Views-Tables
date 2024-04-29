--------------------------------------------------------
--  DDL for Package Body JTF_RS_GRP_MEMBERSHIP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GRP_MEMBERSHIP_PUB_W" as
  /* $Header: jtfrswmb.pls 120.0 2005/05/11 08:23:26 appldev ship $ */
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

  procedure create_group_membership(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_id  NUMBER
    , p_role_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
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
    jtf_rs_grp_membership_pub.create_group_membership(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_group_id,
      p_role_id,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

  procedure update_group_membership(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id  NUMBER
    , p_role_relate_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , p_object_version_num  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
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
    jtf_rs_grp_membership_pub.update_group_membership(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_role_id,
      p_role_relate_id,
      ddp_start_date,
      ddp_end_date,
      p_object_version_num,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

end jtf_rs_grp_membership_pub_w;

/
