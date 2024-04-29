--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUPS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUPS_PUB_W" as
  /* $Header: jtfrsrob.pls 120.0 2005/05/11 08:21:44 appldev ship $ */
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

  procedure create_resource_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_group_id out NOCOPY  NUMBER
    , x_group_number out NOCOPY  VARCHAR2
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
    jtf_rs_groups_pub.create_resource_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_group_name,
      p_group_desc,
      p_exclusive_flag,
      p_email_address,
      ddp_start_date_active,
      ddp_end_date_active,
      p_accounting_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_group_id,
      x_group_number);

    -- copy data back from the local OUT or IN-OUT args, if any














  end;

  procedure create_resource_group_migrate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
    , p_group_id  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_group_id out NOCOPY  NUMBER
    , x_group_number out NOCOPY  VARCHAR2
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
    jtf_rs_groups_pub.create_resource_group_migrate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_group_name,
      p_group_desc,
      p_exclusive_flag,
      p_email_address,
      ddp_start_date_active,
      ddp_end_date_active,
      p_accounting_code,
      p_group_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_group_id,
      x_group_number);

    -- copy data back from the local OUT or IN-OUT args, if any































  end;

  procedure update_resource_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_id  NUMBER
    , p_group_number  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
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
    jtf_rs_groups_pub.update_resource_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_group_id,
      p_group_number,
      p_group_name,
      p_group_desc,
      p_exclusive_flag,
      p_email_address,
      ddp_start_date_active,
      ddp_end_date_active,
      p_accounting_code,
      p_object_version_num,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any















  end;

end jtf_rs_groups_pub_w;

/
