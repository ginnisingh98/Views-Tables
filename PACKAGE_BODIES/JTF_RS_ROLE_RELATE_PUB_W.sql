--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLE_RELATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLE_RELATE_PUB_W" as
  /* $Header: jtfrsreb.pls 120.0 2005/05/11 08:21:34 appldev noship $ */
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

  procedure create_resource_role_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_role_resource_type  VARCHAR2
    , p_role_resource_id  NUMBER
    , p_role_id  NUMBER
    , p_role_code  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_role_relate_id out NOCOPY  NUMBER
  )
  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);





    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_role_relate_pub.create_resource_role_relate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_role_resource_type,
      p_role_resource_id,
      p_role_id,
      p_role_code,
      ddp_start_date_active,
      ddp_end_date_active,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_role_relate_id);

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

  procedure update_resource_role_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_role_relate_id  NUMBER
    , p_start_date_active  date
    , p_end_date_active  date
    , p_object_version_num in out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  )
  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);





    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_role_relate_pub.update_resource_role_relate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_role_relate_id,
      ddp_start_date_active,
      ddp_end_date_active,
      p_object_version_num,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

end jtf_rs_role_relate_pub_w;

/
